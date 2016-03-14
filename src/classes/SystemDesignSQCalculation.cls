/* FILE: SystemDesignSQCalculation.cls
 * AUTHOR: Rohit Jain
 * DATE: Feb 24, 2014
 * PURPOSE: Calucate from System Design.
 * MODIFICATION HISTORY 
      11/25/14  DK  Added Utility Service relationship lookups to the SDI query (for PVWatts_ServiceClient)
      06/02/15  DK  Handle Heroku time-outs with another attempt through regular processing (JIRA ticket: CPQ-223)
 */
public class SystemDesignSQCalculation{
    public static void calculateSQ(System_Design__c sysDesign,String method) {

        sysDesign = [Select Id,Property__r.Property_State__c, Property__r.Property_Zip__c ,Legacy_Astrum_Site_Quality__c
                            ,Astrum_Balance_of_System_Derate__c,NRG_Balance_of_System_Derate__c,NRG_SQ_Calculation_Status__c
                            ,Astrum_SQ_Calculation_Status__c,CPRE_SQ_Calculation_Status__c, NRG_Invalid_SQ_Error_Message__c
                           ,Astrum_Invalid_SQ_Error_Message__c,CPRE_Invalid_SQ_Error_Message__c
                       from System_Design__c 
                      Where Id = :sysDesign.Id];     

        //List<System_Design_Array__C>  sysArrays = [Select Id from System_Design_Array__C Where System_Design__c = :sysDesign.Id ];
       
        List<System_Design_Item__c> sysItems = [Select System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_After_Solar__c
                                            ,System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Solar_Compensation_Method__c
                                            ,System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Value_of_Solar_Tariff__c
                                            ,MasterSD__c,System_Design_Array__r.System_Design__r.Property__r.QAS_Latitude__c,Rated_Output_kW__c
                                            ,System_Design_Array__r.System_Design__r.Property__r.QAS_Longitude__c
                                            ,System_Design_Array__r.System_Design__r.Property__r.Latitude__c
                                            ,System_Design_Array__r.System_Design__r.Property__r.Longitude__c
                                            ,System_Design_Array__r.System_Design__r.Property__r.Confirmed_Location__Latitude__s
                                            ,System_Design_Array__r.System_Design__r.Property__r.Confirmed_Location__Longitude__s
                                            ,System_Design_Array__r.System_Design__r.Property__r.Snow_De_Rate_kWh_y_kW__c
                                            ,Panel_Azimuth__c , Panel_Annual_Solar_Access__c,Panel_Pitch__c , CPRE_Azimuth__c
                                            ,System_Design_Array__r.System_Design__r.Property__r.Property_State__c
                                            ,System_Design_Array__r.System_Design__r.Property__r.Property_zip__c 
                                            ,System_Design_Array__r.System_Design__r.Property__r.Utility_Company__c   
                                            ,Astrum_PV_Watts_Derate__c,Astrum_PV_Watts_Optimal_Site_Quality__c
                                            ,Astrum_PV_Watts_Site_Quality__c,Astrum_Balance_of_System_Derate_Text__c
                                            ,Astrum_PV_Watts_Derate_Text__c,Astrum_Balance_of_System_Derate__c
                                            ,Inverter_and_Transformer_Efficiency__c,Inverter_Transformer_Efficiency_Text__c
                                            ,Snow_Derate_Text__c,Snow_De_Rate_kWh_y_kW__c, System_Design_Array__r.System_Design__r.Property__r.Community_Program_Offer__r.OneRoof_SiteQuality__c
                                            ,NRG_Balance_of_System_Derate__c,NRG_PV_Watts_Derate_Text__c
                                            ,NRG_Balance_of_System_Derate_Text__c,NRG_PV_Watts_De_Rate__c,NRG_Site_Quality__c
                                            ,System_Design_Array__r.System_Design__c, Name, Sunnova_Upgrade_factor__c
                                            ,Jan_Solar_Access__c,Feb_Solar_Access__c,Mar_Solar_Access__c,Apr_Solar_Access__c,May_Solar_Access__c,Jun_Solar_Access__c
                                            ,Jul_Solar_Access__c,Aug_Solar_Access__c,Sep_Solar_Access__c,Oct_Solar_Access__c,Nov_Solar_Access__c,Dec_Solar_Access__c
                                       from System_Design_Item__c 
                                      Where RecordType.Name = 'Panel' 
                                        AND System_Design_Array__r.System_Design__c = :sysDesign.Id ];       
            
        if(sysItems != null && !sysItems.isEmpty())
        {                
          SiteQualitySettings__c sq = SiteQualitySettings__c.getValues('SiteQuality');
          System_Derate_Defaults__c sdd = System_Derate_Defaults__c.getInstance();

          if(method == 'ASTRUM')
          {
            sysDesign.Astrum_SQ_Calculation_Status__c = 'Processing'; 
            sysDesign.Astrum_Invalid_SQ_Error_Message__c = '';   
            if(sysDesign.Legacy_Astrum_Site_Quality__c)
            {
              sysDesign.Legacy_Astrum_Site_Quality__c = false;        
            }
          }
          if(method == 'NRG')
          {
            sysDesign.NRG_SQ_Calculation_Status__c = 'Processing' ;  
            sysDesign.NRG_Invalid_SQ_Error_Message__c = ''; 
          }
          if(method == 'CPRE')
          {
            sysDesign.CPRE_SQ_Calculation_Status__c = 'Processing' ;   
            sysDesign.CPRE_Invalid_SQ_Error_Message__c = ''; 
          }
          if(sysDesign.Astrum_Balance_of_System_Derate__c == null)
          {                      
            sysDesign.Astrum_Balance_of_System_Derate__c =  sdd.Astrum_Balance_of_System_Derate__c;
          }
          if(sysDesign.NRG_Balance_of_System_Derate__c == null)
          {                      
            sysDesign.NRG_Balance_of_System_Derate__c =  sdd.NRG_Balance_of_System_Derate__c;
          }

          
          Integer batchSize = Integer.ValueOf(sq.Batch_Size__c);
          System.debug(loggingLevel.ERROR,'**SQ BATCH SIZE IS:' + batchSize) ;

          Boolean isCPRE = (method == 'CPRE' ? true : false);
          Boolean isNRG = (method == 'NRG' ? true : false);
          Boolean isAstrum = (method == 'ASTRUM' ? true : false);
          List<Id> sysDesigns = new List<Id>();
          sysDesigns.add(sysDesign.Id);
          
          Boolean runBatch = !sq.isHerokuProcess__c;
          if (!isCPRE && sq.isHerokuProcess__c) {
              System.debug('**********Heroku Processing***********');
              SiteQualityProcessor.processBulkSiteQuality(sysItems, sysDesigns , isCPRE, isNRG, isAstrum);
              sysDesign = [Select Id,Property__r.Property_State__c, Property__r.Property_Zip__c ,Legacy_Astrum_Site_Quality__c
                            ,Astrum_Balance_of_System_Derate__c,NRG_Balance_of_System_Derate__c,NRG_SQ_Calculation_Status__c
                            ,Astrum_SQ_Calculation_Status__c,CPRE_SQ_Calculation_Status__c, NRG_Invalid_SQ_Error_Message__c
                           ,Astrum_Invalid_SQ_Error_Message__c,CPRE_Invalid_SQ_Error_Message__c
                       from System_Design__c 
                      Where Id = :sysDesign.Id];
              if (String.isNotBlank(sysDesign.Astrum_Invalid_SQ_Error_Message__c) && sysDesign.Astrum_Invalid_SQ_Error_Message__c.containsIgnoreCase('Unexpected character')){
                  runBatch = true;  //If Heroku failed, then try the regular method  (See JIRA ticket CPQ-223)
                  sysDesign.Astrum_SQ_Calculation_Status__c = 'Processing';
                  sysDesign.Astrum_Invalid_SQ_Error_Message__c = 'Processing Site Quality. This process may take up to a couple of minutes. Please refresh the System Design page for updated calculation status.';
              }
          }

          if (isCPRE || runBatch) {   //Will run if sq.isHerokuProcess__c is false, and also if Heroku timed out in the previous attempt
            
            if (sysItems.size() > batchSize){     
              
              System.debug(isNRG + ' ' + sysDesign.NRG_SQ_Calculation_Status__c);
              update sysDesign; 

              SystemDesignSiteQualityBatch pwb = new SystemDesignSiteQualityBatch ();            
              pwb.isCPRE = isCPRE;
              pwb.isNRG = isNRG;
              pwb.isAstrum = isAstrum;
              pwb.sysDesigns = sysDesigns;
              pwb.sdItems = sysItems;
              Integer nrgbatchSize = Integer.ValueOf(sq.NRG_Batch_Size__c);       

              pwb.Query = 'Select Name,MasterSD__c,System_Design_Array__r.System_Design__r.Name,Sunnova_Site_Quality__c ,Rated_Output_kW__c '
                          + ',System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_After_Solar__c '
                          +',System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Solar_Compensation_Method__c '
                          +' ,System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Value_of_Solar_Tariff__c '
                           + ',Panel_Annual_Solar_Access__c,NRG_PV_Watts_De_Rate__c,NRG_Site_Quality__c '
                           + ',System_Design_Array__r.System_Design__r.Property__r.Property_ZIP__c '
                           + ' ,System_Design_Array__r.System_Design__r.Property__r.QAS_Latitude__c '
                           + ' ,System_Design_Array__r.System_Design__r.Property__r.QAS_Longitude__c'
                           + ' ,System_Design_Array__r.System_Design__r.Property__r.Latitude__c'
                           + ' ,System_Design_Array__r.System_Design__r.Property__r.Longitude__c'
                           +  ',System_Design_Array__r.System_Design__r.Property__r.Confirmed_Location__Latitude__s '
                           +  ',System_Design_Array__r.System_Design__r.Property__r.Confirmed_Location__Longitude__s '
                           + ' ,System_Design_Array__r.System_Design__r.Property__r.Snow_De_Rate_kWh_y_kW__c'
                           + ',System_Design_Array__r.System_Design__r.Property__r.Property_State__c,CPRE_Azimuth__c '
                           + ',Panel_Pitch__c,Sunnova_Upgrade_factor__c,Panel_Azimuth__c,System_Design_Array__r.System_Design__r.Property__r.Utility_Company__c ' 
                           + ',System_Design_Array__r.System_Design__r.Property__r.Community_Program_Offer__r.OneRoof_SiteQuality__c '
                           + ',Astrum_PV_Watts_Derate__c,Astrum_PV_Watts_Optimal_Site_Quality__c,Astrum_PV_Watts_Site_Quality__c '
                           + ',Astrum_Balance_of_System_Derate_Text__c,Astrum_PV_Watts_Derate_Text__c '
                           + ',Astrum_Balance_of_System_Derate__c,Inverter_and_Transformer_Efficiency__c '
                           + ',Inverter_Transformer_Efficiency_Text__c,Snow_Derate_Text__c,Snow_De_Rate_kWh_y_kW__c'
                           + ' ,NRG_Balance_of_System_Derate__c,NRG_PV_Watts_Derate_Text__c,NRG_Balance_of_System_Derate_Text__c '
                            + ',Jan_Solar_Access__c,Feb_Solar_Access__c,Mar_Solar_Access__c,Apr_Solar_Access__c,May_Solar_Access__c,Jun_Solar_Access__c '
                            + ',Jul_Solar_Access__c,Aug_Solar_Access__c,Sep_Solar_Access__c,Oct_Solar_Access__c,Nov_Solar_Access__c,Dec_Solar_Access__c '
                           + ' from System_Design_Item__c Where RecordType.Name = \'Panel\' AND Id in :sdItems ';

            System.debug(pwb.Query);
              Id batchId = Database.executeBatch(pwb, nrgbatchSize); 
            }
            else
            {            
              SiteQualityProcessor.processSiteQuality(sysItems, sysDesigns , isCPRE, isNRG, isAstrum);  
            }  
          }    
        }
    }
    public class customException extends Exception {} 
}