/* FILE: EP_LeadConvertODMContact.trigger
 * AUTHOR: Tino Mattheou
 * DATE: December 21, 2012
 * PURPOSE: Creates Other Decision Maker (ODM) contact when lead is converted
 * MODIFICATION HISTORY:
 *
 */
 
trigger EP_LeadConvertODMContact on Lead (after update) {

    //don't perform updates if bypass is on	
	if (TriggerUtility.bypassLeadTriggersForBatchProcessing) { return; }
	
    List<Contact> newContacts = new List<Contact>();
    
    for (Lead l : Trigger.new) {
        if (l.isConverted == true && Trigger.oldMap.get(l.Id).isConverted == false
        && l.ConvertedAccountId != null && l.ODM_Last_Name__c != null) {
            Contact c = new Contact(
                AccountId = l.ConvertedAccountId,
                LastName = l.ODM_Last_Name__c,
                FirstName = l.ODM_First_Name__c,
                Salutation = l.ODM_Salutation__c,
                Email = l.ODM_Email__c,
                HomePhone = l.ODM_Phone__c,
                MobilePhone = l.ODM_Mobile_Phone__c,
                Work_Phone__c = l.ODM_Work_Phone__c,
                Primary_Phone__c = l.ODM_Primary_Phone__c
            );
            newContacts.add(c);
        }
    }
    
    if (!newContacts.isEmpty()) {
        insert newContacts;
    }

}