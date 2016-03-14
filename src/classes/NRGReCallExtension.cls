/* FILE: NRGReCallExtension.cls
 * AUTHOR: Rohit Jain
 * DATE: July 24, 2013
 * PURPOSE: NRG Web Service Callout for Site Quality. Called from Button on Install Location.
 * MODIFICATION HISTORY 
      11/25/14  DK  Added Utility Service relationship lookups to the SDI query (for PVWatts_ServiceClient)
      Commented by RJ on 05/5/2015
 */
public class NRGReCallExtension {

    /*
    private ApexPages.StandardController controller;
    
    public NRGReCallExtension (ApexPages.StandardController controller) {
        this.controller = controller;
    }
    
    public PageReference reCallNRG() {

        System_Design_Item__c item = (System_Design_Item__c) controller.getRecord();
        item = [Select System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_After_Solar__c
                      ,System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Solar_Compensation_Method__c
                      ,System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Value_of_Solar_Tariff__c
                      ,Panel_Annual_Solar_Access__c,NRG_PV_Watts_De_Rate__c,NRG_Site_Quality__c
                      ,System_Design_Array__r.System_Design__r.Property__r.QAS_Latitude__c
                      ,System_Design_Array__r.System_Design__r.Property__r.QAS_Longitude__c
                       ,System_Design_Array__r.System_Design__r.Property__r.Longitude__c
                       ,System_Design_Array__r.System_Design__r.Property__r.Latitude__c
                      ,System_Design_Array__r.System_Design__r.Property__r.Snow_De_Rate_kWh_y_kW__c,Panel_Azimuth__c
                      ,Panel_Pitch__c,System_Design_Array__r.System_Design__r.Property__r.Property_State__c
                      ,System_Design_Array__r.System_Design__r.Property__r.Property_zip__c 
                      ,System_Design_Array__r.System_Design__r.Property__r.Utility_Company__c                      
                      ,NRG_Balance_of_System_Derate__c,NRG_PV_Watts_Derate_Text__c,NRG_Balance_of_System_Derate_Text__c                     
                  from System_Design_Item__c Where id = :item.Id];       
         
         String latitude = (item.System_Design_Array__r.System_Design__r.Property__r.QAS_Latitude__c != null ? item.System_Design_Array__r.System_Design__r.Property__r.QAS_Latitude__c : String.valueOf(item.System_Design_Array__r.System_Design__r.Property__r.Latitude__c)  ) ;  
         String longitude = (item.System_Design_Array__r.System_Design__r.Property__r.QAS_Longitude__c != null ? item.System_Design_Array__r.System_Design__r.Property__r.QAS_Longitude__c : String.valueOf(item.System_Design_Array__r.System_Design__r.Property__r.Longitude__c)  ) ;  
        
        if( latitude == null ||  longitude == null  || item.System_Design_Array__r.System_Design__r.Property__r.Utility_Company__c == null )         
        {
            throw new customException ('One of Required fields - Latitude,Longitude,Utility are missing on Property record to calculate NRG Site Quality.');
        }  
        if ( item.Panel_Azimuth__c != null 
            && item.Panel_Pitch__c != null && item.Panel_Annual_Solar_Access__c != null ) {            
            
            Double siteQuality;
            if(item.System_Design_Array__r.System_Design__r.Property__r.Property_State__c == 'NJ')
            {
              siteQuality = PVWatts_ServiceClient.getNRGNJSiteQuality(item.NRG_PV_Watts_De_Rate__c.toPlainString(),item.Panel_Pitch__c.toPlainString(),item.Panel_Azimuth__c.toPLainString(),item.System_Design_Array__r.System_Design__r.Property__r.Property_ZIP__c.subString(0,5));                       
            }
            else
            {
                //siteQuality = PVWatts_ServiceClient.getNRGSiteQuality(item.System_Design_Array__r.System_Design__r.Property__r.QAS_Latitude__c, item.System_Design_Array__r.System_Design__r.Property__r.QAS_Longitude__c ,item.NRG_PV_Watts_De_Rate__c.toPlainString(),item.Panel_Pitch__c.toPlainString(),item.Panel_Azimuth__c.toPLainString());                       
                try {
                  item = PVWatts_ServiceClient.getSiteQualityHourly(item,'NRG');//item.System_Design_Array__r.System_Design__r.Property__r.QAS_Latitude__c, item.System_Design_Array__r.System_Design__r.Property__r.QAS_Longitude__c ,item.NRG_PV_Watts_De_Rate__c.toPlainString(),item.Panel_Pitch__c.toPlainString(),item.Panel_Azimuth__c.toPLainString());                       
                }
                catch(Exception e)
                {
                  throw new customException (e.getMessage());        
                }
                update item;
            }
            if (siteQuality != null) {
                
                item.NRG_Site_Quality__c = siteQuality ;  
                update item;    
            }            
        }
        else
        { 
            throw new customException ('One of Required fields - Azimuth,Tilt,Shading are missing on System Design Item record to calculate NRG Site Quality.');
        }
        
        return controller.cancel();
    } 
    
    public class customException extends Exception {} 
    */

}