//TCM 06/15/2012 - Snow Derate bug - update system design items if Optimal Site Quality changes
//TCM 08/16/2012 - prevent callout if running test
//TCM 08/23/2012 - remove bing call - QAS will update LAT/LON
//TCM 10/12/2012 - add dc-to-ac-derate parameter
trigger BingMaps_UpdateGeoPoints_Trigger on Property__c (before update, after insert, after update) {

    if (Trigger.isBefore && Trigger.isUpdate) {
        for(Property__c property : Trigger.New){
            
            /*if (property.Max_Site_Quality__c != null) {
                
                if (property.Snow_De_Rate_kWh_y_kW__c == null) {
                    property.Snow_De_Rate_kWh_y_kW__c = 0;
                }
                
                property.Optimal_Site_Quality_kWh_y_kW__c = property.Max_Site_Quality__c - property.Snow_De_Rate_kWh_y_kW__c;
            }*/
        }
    }      
        
    if (Trigger.isAfter) {
        
        if(Trigger.IsInsert){
            for(Property__c property : Trigger.New){
                
                if (property.Latitude__c != 0 && property.Longitude__c != 0 && !Test.isRunningTest()) {
                    BingMaps_BingService.updateGeoPointsAndMaxSiteQuality(property.name, property.Property_ZIP__c, property.id, Property.DC_to_AC_Derate__c, Property.Property_State__c); 
                } 
            }
        }
        
           
        if(Trigger.IsUpdate) {

            List<Property__c> propertiesSiteQualChange = new List<Property__c>();
              
            for(Property__c property : Trigger.New){
                Property__c oldProperty = Trigger.oldMap.get(property.id);
                
                //boolean hasDifferentAddresses = BingMaps_BingServiceUtility.hasDifferentAddresses(property, oldProperty);
                //boolean hasDifferentAstrumOffice = BingMaps_BingServiceUtility.hasDifferentAstrumOffice(property, oldProperty);
                Boolean optimalSiteQualityChanged = property.Optimal_Site_Quality_kWh_y_kW__c != oldProperty.Optimal_Site_Quality_kWh_y_kW__c;
                
               // if ((hasDifferentAddresses || hasDifferentAstrumOffice) && !Test.isRunningTest()) {
                    //BingMaps_BingService.updateGeoPoints(property.name, property.Property_ZIP__c, property.id);
                //}
                
                if (optimalSiteQualityChanged) {
                    propertiesSiteQualChange.add(property);
                }
            }
            
            if (!propertiesSiteQualChange.isEmpty()) {
                List<System_Design_Item__c> designItems = 
                    [SELECT Id 
                    FROM System_Design_Item__c
                    WHERE System_Design_Array__r.System_Design__r.Property__c
                        IN :propertiesSiteQualChange];
                
                PropertyTriggerHelper.propertyTriggerFiring = true;
                update designItems;
                PropertyTriggerHelper.propertyTriggerFiring = false;
            }   
            
        }
        
    }   
}