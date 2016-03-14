/* FILE: InstallLocation_CPRE_SiteQuality_BI.cls
 * AUTHOR: Rohit Jain
 * DATE: July 24, 2013
 * PURPOSE: Clean Power Estimator Web Service Callout for Site Quality before Insert on Install Location
 * MODIFICATION HISTORY 
 */
trigger InstallLocation_CPRE_SiteQuality_AI on Install_Location__c (After Insert) {   
    //if(Trigger.IsInsert){
        //for(Install_Location__c location : Trigger.New){            
            //if (location.Property__c != null && location.Azimuth__c != null && location.Pitch__c != null && location.Annual_Solar_Access__c != null ) {
                //Property__c prop = [Select Property_ZIP__c, Property_State__c from Property__c Where Id = :location.Property__c ];               
                //CleanPowerEstimator_ServiceClient.updateSiteQualityForLocation(location.Id,prop.Property_ZIP__c.subString(0,5), prop.Property_State__c,String.valueOf(location.Azimuth__c),String.valueOf(location.Pitch__c),String.valueOf(location.Annual_Solar_Access__c));                           
            
            //}
        //}
    //}
}