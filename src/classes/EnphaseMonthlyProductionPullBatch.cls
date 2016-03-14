/* FILE: EnphaseMonthlyProductionPullBatch.cls
 * AUTHOR: Rohit Jain
 * DATE: May 14, 2013
 * PURPOSE: Collects enphase production data and updates database
 *   to invoke: EnphaseMonthlyProductionPullBatch batch = new EnphaseMonthlyProductionPullBatch();
 *              Id batchId = Database.executeBatch(batch, 10); //must be 10 - callout governor limit
 *   enphase limits calls to 25 at a time, then throws 503 errors
 * MODIFICATION HISTORY 
 */
global class EnphaseMonthlyProductionPullBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Schedulable,Database.Stateful{
    public String query;
    private String batchErrors = '';
    private Integer batchNumber = 0;

    global Database.QueryLocator start(Database.BatchableContext BC){
        query = 'SELECT Id, Generation_Start_date__C,Enphase_ID__c, Quoted_System_Design__r.System_Design__r.Total_System_Size_kW__c,Quoted_System_Design__r.System_Design__r.Total_Projected_Annual_Output_kWh_y__c  ' ;
        query = query + '  ,Property__r.Snow_De_Rate_kWh_y_kW__c, Monthly_Production_Factor_Jan__c ,Monthly_Production_Factor_Feb__c,Monthly_Production_Factor_Mar__c,Monthly_Production_Factor_Apr__c,Monthly_Production_Factor_May__c  ' ;
        query = query + '  ,Monthly_Production_Factor_Jun__c ,Monthly_Production_Factor_Jul__c,Monthly_Production_Factor_Aug__c,Monthly_Production_Factor_Sep__c,Monthly_Production_Factor_Oct__c ,Monthly_Production_Factor_Nov__c ,Monthly_Production_Factor_Dec__c  ' ;
        query = query + ' , PM_Project__r.Approved_Utility_Interconnect_Part_2__c ' ;
        query = query + ' , PM_Project__c , Project__c,production_estimate_started__c ' ;
        query = query + '  FROM Installed_System__c WHERE Enphase_ID__c <> NULL AND Id NOT IN  ' ; 
        query = query + ' (SELECT Installed_System__c FROM Enphase_Pull_Log__c WHERE Batch_Date__c = THIS_MONTH) ' ;
              
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        String status; 
        List<Monthly_Production__c> productionToUpdate = new List<Monthly_Production__c>();   
        List<Enphase_Pull_Log__c> pullLogs = new List<Enphase_Pull_Log__c>();   
        List<Installed_System__c> installSystemUpdate = new List<Installed_System__c>();            
        for(sObject s : scope)
        {
          
          Installed_System__c sys = (Installed_System__c)s;
          status =       processSystem(sys,productionToUpdate  ,pullLogs,installSystemUpdate   );             
                
        }   
        
        if (!pullLogs.isEmpty()) {
          insert pullLogs;
        }
    
        if (!productionToUpdate.isEmpty()) {
          upsert productionToUpdate;
        }    
        
        if (!installSystemUpdate   .isEmpty()) {
          update installSystemUpdate;
        }   
    }
    
    global void execute(SchedulableContext SC) {
      EnphaseMonthlyProductionPullBatch  batch = new EnphaseMonthlyProductionPullBatch ();
      Id batchId = Database.executeBatch(batch, 10);
    }
    
    global void finish(Database.BatchableContext bc) {
        
        if (batchErrors != '') {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(UserInfo.getUserId());
            mail.setSubject('Enphase Monthly Production Pull Batch Errors');
            mail.setPlainTextBody(batchErrors);
            mail.setSaveAsActivity(false);
            Messaging.sendEmail(new Messaging.Email[] { mail }, false);     
        }
        
        if (batchNumber > 0) {
            //EnphaseBatchHelper.runNextPull(lastEnphaseId);
        }
        
    } 
    
    public String processSystem(Installed_System__c sys, List<Monthly_Production__c> productionToUpdate   ,List<Enphase_Pull_Log__c> pullLogs ,List<Installed_System__c> installSystemUpdate ) {
    
        batchNumber++;
        Date thisMonthStart = System.today().toStartOfMonth();
        Date lastMonthStart = thisMonthStart.addMonths(-1);
        Boolean estimateStarted = sys.production_estimate_started__c;
        Boolean sysUpdated = false;
        
        System.debug('*processSystem - '+ Sys.Enphase_ID__c );     
    
        //get the currently monthly production    
        List<Monthly_Production__c> monthlyProduction = 
          [SELECT Id, Installed_System__c, Start_of_Month__c, Enphase_kWh__c, Production_Guarantee__c, Astrum_Estimated__c
          FROM Monthly_Production__c
          WHERE Installed_System__c = :sys.Id];        
        
        Map<Date, Monthly_Production__c> productionMap = new Map<Date, Monthly_Production__c>(); 
    
        //put into installed system, date map
        for (Monthly_Production__c mp : monthlyProduction) {
          productionMap.put(mp.Start_of_Month__c.toStartOfMonth(), mp); 
        }
        
        EnphaseAPI api = new EnphaseAPI();   
        Integer recordNumber = 0;
        try {
            
          //get lifetime production by month from Enphase
          List<EnphaseAPI.EnphaseProduction> production;
          if(!Test.isRunningTest())
          {
              production = api.energy_lifetime_monthly(Integer.valueOf(sys.Enphase_ID__c));
          }
          else
          {
              production = new List<EnphaseAPI.EnphaseProduction>();             
              EnphaseAPI.EnphaseProduction prod = new  EnphaseAPI.EnphaseProduction();
              
              prod.productiondate = System.now() - 40 ;
              prod.wattHours  = 0;
              production.add(prod);  
              
              EnphaseAPI.EnphaseProduction prod1 = new  EnphaseAPI.EnphaseProduction();
              prod1.productiondate = System.now();
              prod1.wattHours  = 0;
              production.add(prod1);  
          }    
          
          if (production.isEmpty()) {
            System.debug('*processSystem - '+ 'No Production Data' );  
            return 'No Production Data';
          }
         
          
          if(sys.Generation_Start_Date__C == null )
          {
              sys.Generation_Start_date__C =  production[0].productionDate.date();
              sysUpdated  = true;
          }    
          
          
          //calculate production estimates / guarantees
          List<PVWatts_Production_Estimates__c> pvw = 
            [SELECT January__c, February__c, March__c, April__c, May__c, June__c,
            July__c, August__c, September__c, October__c, November__c, December__c, Annual_Total__c
            FROM PVWatts_Production_Estimates__c
            WHERE Installed_System__c = :sys.Id
            ORDER BY LastModifiedDate DESC 
            LIMIT 1];
    
          Map<Date, ProductionMonthlyGuaranteeCalculator.ProductionGuarantee> guaranteeMap 
            = new Map<Date, ProductionMonthlyGuaranteeCalculator.ProductionGuarantee>();
    
          if (!pvw.isEmpty()) {
            System.debug('*pvw[0]- '+pvw[0]);  
            List<ProductionMonthlyGuaranteeCalculator.ProductionGuarantee> guar 
              = ProductionMonthlyGuaranteeCalculator.getProductionGuarantee (
                pvw[0],
                sys,              // Installed System
                production[0].productionDate.date()  // Production start Date
              );
    
            for (ProductionMonthlyGuaranteeCalculator.ProductionGuarantee g : guar) {
              guaranteeMap.put(g.startOfMonth, g);
            }
          }
          
          Enphase_Pull_Log__c accum = new Enphase_Pull_Log__c();
          
          for (EnphaseAPI.EnphaseProduction prod : production) {
            
                
            Integer year = prod.productionDate.year();
            if (accum.Start_of_Year__c == null) {
              accum.Start_of_Year__c = Date.newInstance(year, 1, 1);
              accum.Installed_System__c = sys.Id;
              accum.Batch_Date__c = System.today();
            } else if (year != accum.Start_of_Year__c.year()) {
              pullLogs.add(accum);
              accum = new Enphase_Pull_Log__c();
            }
            Integer month = prod.productionDate.month();
           
            if (month == 1) {
              accum.Jan_Prod__c = prod.wattHours;
            } else if (month == 2) {
              accum.Feb_Prod__c = prod.wattHours;
            } else if (month == 3) {
              accum.Mar_Prod__c = prod.wattHours;
            } else if (month == 4) {
              accum.Apr_Prod__c = prod.wattHours;
            } else if (month == 5) {
              accum.May_Prod__c = prod.wattHours;
            } else if (month == 6) {
              accum.Jun_Prod__c = prod.wattHours;
            } else if (month == 7) {
              accum.Jul_Prod__c = prod.wattHours;
            } else if (month == 8) {
              accum.Aug_Prod__c = prod.wattHours;
            } else if (month == 9) {
              accum.Sep_Prod__c = prod.wattHours;
            } else if (month == 10) {
              accum.Oct_Prod__c = prod.wattHours;
            } else if (month == 11) {
              accum.Nov_Prod__c = prod.wattHours;
            } else if (month == 12) {
              accum.Dec_Prod__c = prod.wattHours;
            }
              
            //update monthly production, if not this month
            if (prod.productionDate.date() < thisMonthStart) {
              Monthly_Production__c mp = productionMap.get(prod.productionDate.date().toStartOfMonth()); 
              if (mp == null) {
                mp = new Monthly_Production__c (
                  Installed_System__c = sys.Id,
                  Start_of_Month__c = prod.productionDate.date().toStartOfMonth()
                );
               // System.debug('*mp - '+mp  ); 
                productionMap.put(prod.productionDate.date(), mp);
              } 
              
              Boolean changed = false;
              
              if (mp.Enphase_kWh__c != prod.kilowattHours) {
                mp.Enphase_kWh__c = prod.kilowattHours;
                
                changed = true;
              }
              
              ProductionMonthlyGuaranteeCalculator.ProductionGuarantee pg 
                = guaranteeMap.get(mp.Start_of_Month__c.toStartOfMonth());
              
              //System.debug('*pg  - '+pg );   
              if (pg != null) {
              
                if (mp.Production_Guarantee__c != pg.guarantee_kWh) {
                  mp.Production_Guarantee__c = pg.guarantee_kWh;
                  changed = true;
                }
                
                
                //System.debug('*pg.estimate_kWh- '+pg.estimate_kWh  ); 
                //System.debug('*prod.kilowattHours- '+prod.kilowattHours  ); 
                //System.debug('*prod.firstfullmonth- '+ prod.firstfullmonth  ); 
                if(prod.FirstFullMOnth == null)
                {
                  prod.FirstFullMOnth = false;
                }
                if (mp.Astrum_Estimated__c != pg.estimate_kWh && (estimateStarted || prod.FirstFullMOnth)) {                    
                  estimateStarted = true;
                  mp.Astrum_Estimated__c = pg.estimate_kWh;
                  changed = true;
                }
              
              }
              
              if (changed == true) {
                productionToUpdate.add(mp);
              }
              
            }
            
          }
          if(sys.production_estimate_started__c != estimateStarted )
          {
              sys.production_estimate_started__c =  estimateStarted ;
              sysUpdated = true;  
          }  
          if (sysUpdated )
          {
            installSystemUpdate.add(sys); 
          }
            
          if (accum.Start_of_Year__c != null) {
            pullLogs.add(accum);
          }
            
        } 
        catch (NullPointerException e) {
          batchErrors += 'Batch #' + batchNumber + ' Record #' + recordNumber + ' ' + sys.Enphase_ID__c + ' ' + sys.Id + ' \n' + 'Production Factor not defined for Installed System' + ' \n' + e.getStackTraceString() + '\n\n';
        }  
        catch (Exception e) {
          batchErrors += 'Batch #' + batchNumber + ' Record #' + recordNumber + ' ' + sys.Enphase_ID__c + ' ' + sys.Id + ' \n' + e.getMessage() + ' \n' + e.getStackTraceString() + '\n\n';
        }          
     
        return 'Success';    
        
      }
}