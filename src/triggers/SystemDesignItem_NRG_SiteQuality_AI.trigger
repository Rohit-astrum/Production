/* FILE: SystemDesignItem_NRG_SiteQuality_AI
 * AUTHOR: Rohit Jain
 * DATE:Aug 13, 2013
 * PURPOSE: NRG PV Watts Web Service Callout for Site Quality before Insert on System Design Item
 * MODIFICATION HISTORY 
 */
trigger SystemDesignItem_NRG_SiteQuality_AI on System_Design_Item__c (After Insert) {   
    if(Trigger.IsInsert){       
        List<ID> sda = new List<ID>();
        for(System_Design_Item__c item : Trigger.New){
            sda.add(item.System_Design_Array__c );        
        }                
        if(!sda.isEmpty())
        {
            Map<Id,System_Design_Array__c> sdmap = new Map<Id,System_Design_Array__c>([Select Id,System_Design__r.Property__c,System_Design__r.Property__r.QAS_Latitude__c,System_Design__r.Property__r.QAS_Longitude__c from System_Design_Array__c Where Id in :sda]);
            
            for(System_Design_Item__c item : Trigger.New){
                System_Design_Array__c say = sdmap.get(item.System_Design_Array__c);
                if (say.System_Design__r.Property__c != null && item.Panel_Azimuth__c != null && item.Panel_Pitch__c != null && Item.Panel_Annual_Solar_Access__c != null ) {
                    PVWatts_ServiceClient.updateNRGSiteQualityForItem(item.Id,say.System_Design__r.Property__r.QAS_Latitude__c , say.System_Design__r.Property__r.QAS_Longitude__c,String.valueOf(item.Panel_Azimuth__c),String.valueOf(item.Panel_Pitch__c),String.valueOf(item.NRG_PV_Watts_De_Rate__c));                                       
                }
            }
        }   
    }
}