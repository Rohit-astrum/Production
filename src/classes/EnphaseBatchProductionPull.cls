global class EnphaseBatchProductionPull {
    /*
    public String query;

    global Database.QueryLocator start(Database.BatchableContext BC){
        query = 'SELECT Id, Enphase_ID__c, SREC_Generation_Start_Date__c,Quoted_System_Design__r.System_Design__r.Total_System_Size_kW__c,Quoted_System_Design__r.System_Design__r.Total_Projected_Annual_Output_kWh_y__c, ';
        query = query + ' Property__r.Snow_De_Rate_kWh_y_kW__c, Lease_Purchase__c FROM Installed_System__c WHERE Enphase_ID__c <> NULL AND Id NOT IN '; 
        query = query + ' (SELECT Installed_System__c FROM Enphase_Pull_Log__c WHERE Pull_Date__c = THIS_MONTH) ' ;
              
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        String status; 
        List<Monthly_Production__c> productionToUpdate = new List<Monthly_Production__c>();   
        List<Enphase_Pull_Log__c> pullLogs = new List<Enphase_Pull_Log__c>();        
        for(sObject s : scope)
        {
          
          Installed_System__c sys = (Installed_System__c)s;
          status =       processSystem(sys,productionToUpdate  ,pullLogs  );    
          System.debug('*Sys - '+Sys.Enphase_ID__c+' - '+Status);     
                
        }   
        
        if (!pullLogs.isEmpty()) {
          insert pullLogs;
        }
    
        if (!productionToUpdate.isEmpty()) {
          upsert productionToUpdate;
        }    
    }
    
    global void execute(SchedulableContext SC) {
      EnphaseBatchProductionPull batch = new EnphaseBatchProductionPull();
      Id batchId = Database.executeBatch(batch, 10);
    }
    
    global void finish(Database.BatchableContext BC){
    } 
    
    public String processSystem(Installed_System__c sys, List<Monthly_Production__c> productionToUpdate   ,List<Enphase_Pull_Log__c> pullLogs  ) {
    
        Date thisMonthStart = System.today().toStartOfMonth();
        Date lastMonthStart = thisMonthStart.addMonths(-1);
        //List<Monthly_Production__c> productionToUpdate = new List<Monthly_Production__c>();
    
        //get the currently monthly production    
        List<Monthly_Production__c> monthlyProduction = 
          [SELECT Id, Installed_System__c, Start_of_Month__c, Enphase_kWh__c, Guaranteed__c, Estimated__c
          FROM Monthly_Production__c
          WHERE Installed_System__c = :sys.Id];
        
        Map<Date, Monthly_Production__c> productionMap = new Map<Date, Monthly_Production__c>(); 
    
        //put into installed system, date map
        for (Monthly_Production__c mp : monthlyProduction) {
          productionMap.put(mp.Start_of_Month__c.toStartOfMonth(), mp); 
        }
    
        EnphaseAPI api = new EnphaseAPI();
        //List<Enphase_Pull_Log__c> pullLogs = new List<Enphase_Pull_Log__c>();
        Integer recordNumber = 0;
    
        try {
          System.debug('*1 Calling API Callouts ');          
          //get lifetime production by month from Enphase
          List<EnphaseAPI.EnphaseProduction> production = api.energy_lifetime_monthly(Integer.valueOf(sys.Enphase_ID__c));
          System.debug('*2 Calling API Callouts ');  
          if (production.isEmpty()) {
            System.debug('* 3 Calling API Callouts '); 
            return 'No Production Data';
          }
          
          //calculate production estimates / guarantees
          Installed_System__c pvw = 
            [SELECT PVWatts_January_Estimate_kWh__c, PVWatts_February_Estimate_kWh__c, 
                PVWatts_March_Estimate_kWh__c, PVWatts_April_Estimate_kWh__c, 
                PVWatts_May_Estimate_kWh__c, PVWatts_June_Estimate_kWh__c,
                PVWatts_July_Estimate_kWh__c, PVWatts_August_Estimate_kWh__c, 
                PVWatts_September_Estimate_kWh__c, PVWatts_October_Estimate_kWh__c, 
                PVWatts_November_Estimate_kWh__c, PVWatts_December_Estimate_kWh__c, 
                PVWatts_Annual_Estimate_kWh__c
            FROM Installed_System__c
            WHERE Id = :sys.Id];
    
          Map<Date, ProductionGuaranteeCalculator.ProductionGuarantee> guaranteeMap 
            = new Map<Date, ProductionGuaranteeCalculator.ProductionGuarantee>();
            
          Date generationStart = sys.SREC_Generation_Start_Date__c;
          if (generationStart == null) {
            generationStart = production[0].productionDate.date().toStartOfMonth();
          }
    
          if (pvw.PVWatts_Annual_Estimate_kWh__c != null && pvw.PVWatts_Annual_Estimate_kWh__c != 0) {
            List<ProductionGuaranteeCalculator.ProductionGuarantee> guar 
              = ProductionGuaranteeCalculator.getProductionGuarantee (
                pvw,
                sys.Quoted_System_Design__r.System_Design__r.Total_System_Size_kW__c,
                sys.Quoted_System_Design__r.System_Design__r.Total_Projected_Annual_Output_kWh_y__c,
                generationStart,
                sys.Property__r.Snow_De_Rate_kWh_y_kW__c
              );
    
            for (ProductionGuaranteeCalculator.ProductionGuarantee g : guar) {
              guaranteeMap.put(g.startOfMonth, g);
            }
          }
          
          Enphase_Pull_Log__c accum = new Enphase_Pull_Log__c();
          
          for (EnphaseAPI.EnphaseProduction prod : production) {
            Integer year = prod.productionDate.year();
            if (accum.Start_of_Year__c == null) {
              accum.Start_of_Year__c = Date.newInstance(year, 1, 1);
              accum.Installed_System__c = sys.Id;
              accum.Pull_Date__c = System.today();
            } else if (year != accum.Start_of_Year__c.year()) {
              pullLogs.add(accum);
              accum = new Enphase_Pull_Log__c();
            }
            Integer month = prod.productionDate.month();
            if (month == 1) {
              accum.January__c = prod.wattHours;
            } else if (month == 2) {
              accum.February__c = prod.wattHours;
            } else if (month == 3) {
              accum.March__c = prod.wattHours;
            } else if (month == 4) {
              accum.April__c = prod.wattHours;
            } else if (month == 5) {
              accum.May__c = prod.wattHours;
            } else if (month == 6) {
              accum.June__c = prod.wattHours;
            } else if (month == 7) {
              accum.July__c = prod.wattHours;
            } else if (month == 8) {
              accum.August__c = prod.wattHours;
            } else if (month == 9) {
              accum.September__c = prod.wattHours;
            } else if (month == 10) {
              accum.October__c = prod.wattHours;
            } else if (month == 11) {
              accum.November__c = prod.wattHours;
            } else if (month == 12) {
              accum.December__c = prod.wattHours;
            }
              
            //update monthly production, if not this month
            if (prod.productionDate.date() < thisMonthStart) {
              Monthly_Production__c mp = productionMap.get(prod.productionDate.date().toStartOfMonth()); 
              if (mp == null) {
                mp = new Monthly_Production__c (
                  Installed_System__c = sys.Id,
                  Start_of_Month__c = prod.productionDate.date().toStartOfMonth()
                );
                productionMap.put(prod.productionDate.date(), mp);
              } 
              
              Boolean changed = false;
              
              if (mp.Enphase_kWh__c != prod.kilowattHours) {
                mp.Enphase_kWh__c = prod.kilowattHours;
                changed = true;
              }
              
              ProductionGuaranteeCalculator.ProductionGuarantee pg 
                = guaranteeMap.get(mp.Start_of_Month__c.toStartOfMonth());
    
              if (pg != null) {
              
                if (mp.Guaranteed__c != pg.guarantee_kWh) {
                  mp.Guaranteed__c = pg.guarantee_kWh;
                  changed = true;
                }
      
                if (mp.Estimated__c != pg.estimate_kWh) {
                  mp.Estimated__c = pg.estimate_kWh;
                  changed = true;
                }
              
              } else {
                
                if (mp.Guaranteed__c != null) {
                  mp.Guaranteed__c = null;
                  changed = true;
                }
                
                if (mp.Estimated__c != null) {
                  mp.Estimated__c = null;
                  changed = true;
                }
                
              }
              
              if (changed == true) {
                productionToUpdate.add(mp);
              }
              
            }
            
          }
            
          if (accum.Start_of_Year__c != null) {
            pullLogs.add(accum);
          }
            
        } catch (Exception e) {
          return e.getMessage() + ' \n' + e.getStackTraceString();
        }
          
       /* if (!pullLogs.isEmpty()) {
          insert pullLogs;
        }
    
        if (!productionToUpdate.isEmpty()) {
          upsert productionToUpdate;
        }
        
        return 'Success';    
        
      }*/
}