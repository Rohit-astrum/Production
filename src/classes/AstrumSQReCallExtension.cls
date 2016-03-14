/* FILE: AstrumSQReCallExtension.cls
 * AUTHOR: Rohit Jain
 * DATE: July 24, 2013
 * PURPOSE: NRG Web Service Callout for Site Quality. Called from Button on Install Location.
 * MODIFICATION HISTORY 
      11/25/14  DK  Added Utility Service relationship lookups to the SDI query (for PVWatts_ServiceClient)
 */
public class AstrumSQReCallExtension {

    private ApexPages.StandardController controller;
    
    public AstrumSQReCallExtension (ApexPages.StandardController controller) {
        this.controller = controller;
    }
    
    public PageReference reCallAstrumSQ() {

        System_Design_Item__c item = (System_Design_Item__c) controller.getRecord();
        item = [Select System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_After_Solar__c
                      ,System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Solar_Compensation_Method__c
                      ,System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Value_of_Solar_Tariff__c
                      ,Panel_Annual_Solar_Access__c,NRG_Site_Quality__c
                      ,System_Design_Array__r.System_Design__r.Property__r.QAS_Latitude__c
                      ,System_Design_Array__r.System_Design__r.Property__r.QAS_Longitude__c
                       ,System_Design_Array__r.System_Design__r.Property__r.Latitude__c
                      ,System_Design_Array__r.System_Design__r.Property__r.Longitude__c
                      ,Panel_Azimuth__c,Panel_Pitch__c, System_Design_Array__r.System_Design__r.Property__r.Community_Program_Offer__r.OneRoof_SiteQuality__c
                      ,System_Design_Array__r.System_Design__r.Property__r.Property_State__c
                      ,System_Design_Array__r.System_Design__r.Property__r.Property_zip__c 
                      ,System_Design_Array__r.System_Design__r.Property__r.Utility_Company__c                      
                      ,Astrum_PV_Watts_Derate__c,Astrum_PV_Watts_Optimal_Site_Quality__c,Astrum_PV_Watts_Site_Quality__c
                      ,Astrum_Balance_of_System_Derate_Text__c,Astrum_PV_Watts_Derate_Text__c
                      ,Astrum_Balance_of_System_Derate__c,Inverter_and_Transformer_Efficiency__c
                      ,Inverter_Transformer_Efficiency_Text__c,Snow_Derate_Text__c,Snow_De_Rate_kWh_y_kW__c
                      ,Jan_Solar_Access__c,Feb_Solar_Access__c,Mar_Solar_Access__c,Apr_Solar_Access__c,May_Solar_Access__c,Jun_Solar_Access__c
                      ,Jul_Solar_Access__c,Aug_Solar_Access__c,Sep_Solar_Access__c,Oct_Solar_Access__c,Nov_Solar_Access__c,Dec_Solar_Access__c
                  from System_Design_Item__c Where id = :item.Id];       
         
         System.debug('JanSolar***'+item.Jan_Solar_Access__c);
         String latitude = (item.System_Design_Array__r.System_Design__r.Property__r.QAS_Latitude__c != null ? item.System_Design_Array__r.System_Design__r.Property__r.QAS_Latitude__c : String.valueOf(item.System_Design_Array__r.System_Design__r.Property__r.Latitude__c)  ) ;  
         String longitude = (item.System_Design_Array__r.System_Design__r.Property__r.QAS_Longitude__c != null ? item.System_Design_Array__r.System_Design__r.Property__r.QAS_Longitude__c : String.valueOf(item.System_Design_Array__r.System_Design__r.Property__r.Longitude__c)  ) ;  
        
        if( latitude == null ||  longitude == null  || item.System_Design_Array__r.System_Design__r.Property__r.Utility_Company__c == null )         
        {
            throw new customException ('One of Required fields - Latitude,Longitude,Utility are missing on Property record to calculate Astrum Site Quality.');
        }  
        if ( item.Panel_Azimuth__c != null 
            && item.Panel_Pitch__c != null && item.Panel_Annual_Solar_Access__c != null ) {             
              //siteQuality = PVWatts_ServiceClient.getNRGSiteQuality(item.System_Design_Array__r.System_Design__r.Property__r.QAS_Latitude__c, item.System_Design_Array__r.System_Design__r.Property__r.QAS_Longitude__c ,item.NRG_PV_Watts_De_Rate__c.toPlainString(),item.Panel_Pitch__c.toPlainString(),item.Panel_Azimuth__c.toPLainString());                       
              try {
                item = PVWatts_ServiceClient.getSiteQualityHourly(item,'ASTRUM');//item.System_Design_Array__r.System_Design__r.Property__r.QAS_Latitude__c, item.System_Design_Array__r.System_Design__r.Property__r.QAS_Longitude__c ,item.NRG_PV_Watts_De_Rate__c.toPlainString(),item.Panel_Pitch__c.toPlainString(),item.Panel_Azimuth__c.toPLainString());                       
              }
              catch(Exception e)
              {
                throw new customException (e.getMessage());        
              }
              update item;                    
        }
        else
        { 
            throw new customException ('One of Required fields - Azimuth,Tilt,Shading are missing on System Design Item record to calculate Astrum Site Quality.');
        }
        
        return controller.cancel();
    } 
    
    public class customException extends Exception {} 

}