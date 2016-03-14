trigger Update_SDI_On_Location_Change on Install_Location__c (after update) {
    List<System_Design_Item__c> sdisToUpdate = new List<System_Design_Item__c>();
    for ( Install_Location__c rec : Trigger.new) {
        List<System_Design_Item__c> SDIs = [Select id from System_Design_Item__c sdi where sdi.Install_Location__c = :rec.Id];
        sdisToUpdate.addAll(SDIs);
    }
    update(sdisToUpdate);
}