/* FILE: SiteQualityCalculator.cls
 * AUTHOR: Rohit Jain
 * DATE: July 24, 2013
 * PURPOSE: Clean Power Estimator Web Service Callout for Site Quality
 * MODIFICATION HISTORY 
 *      11/25/14  DK  Added Utility Service relationship lookups to the SDI query (for PVWatts_ServiceClient)
 *      01/09/15  DK  Made class "without sharing". Was previously "with".
 */

public without sharing class SiteQualityCalculator { 
   
    @Future(callout=true)
    public static void updateSiteQualityForItem(String itemids, String sdIds, Boolean isCPRE , Boolean isNRG, Boolean isAstrum, Boolean isHeroku) {         
        
                
        String[] sdiIds = itemids.split(';');
        String[] designsIds = sdIds.split(';');
        
        List<System_Design_Item__c> items = [Select System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_After_Solar__c
                                            ,System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Solar_Compensation_Method__c
                                            ,System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Value_of_Solar_Tariff__c
                                            ,MasterSD__c,System_Design_Array__r.System_Design__r.Property__r.QAS_Latitude__c
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
                                            ,System_Design_Array__r.System_Design__c, Name, Sunnova_Upgrade_factor__c,Rated_Output_kW__c
                                            ,Jan_Solar_Access__c,Feb_Solar_Access__c,Mar_Solar_Access__c,Apr_Solar_Access__c,May_Solar_Access__c,Jun_Solar_Access__c
                                            ,Jul_Solar_Access__c,Aug_Solar_Access__c,Sep_Solar_Access__c,Oct_Solar_Access__c,Nov_Solar_Access__c,Dec_Solar_Access__c
                                       from System_Design_Item__c 
                                       Where id IN :sdiIds order by MasterSD__c];       
            
        List<Id> systemDesigns = new List<Id>();
        for( System_Design__c sd : [Select Id from  System_Design__c Where Id IN :designsIds])
        {
            systemDesigns.add(sd.Id);
        }
        if(isHeroku)
        {
            SiteQualityProcessor.processBulkSiteQuality(items, systemDesigns, isCPRE, isNRG, isAstrum);
        }
        else
        {
            SiteQualityProcessor.processSiteQuality(items, systemDesigns, isCPRE, isNRG, isAstrum);
        }
    }
}