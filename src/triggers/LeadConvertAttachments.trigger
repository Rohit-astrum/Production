/* FILE: LeadConvertAttachments.trigger
 * AUTHOR: Tino Mattheou
 * DATE: September 10, 2012
 * PURPOSE: copies Contact attachments from converted lead to Opportunity
 * MODIFICATION HISTORY
 *
 */
 
trigger LeadConvertAttachments on Lead (after update) {
    //don't perform updates if bypass is on	
	if (TriggerUtility.bypassLeadTriggersForBatchProcessing) { return; }
	
	Map<Id, Lead> contactLeadMap = new Map<Id, Lead>();

	for (Lead l : Trigger.new) {
		if (l.IsConverted == true) {
			if (l.ConvertedContactId != null && l.ConvertedOpportunityId != null) {
				contactLeadMap.put(l.ConvertedContactId, l);
			}
		}
	}
	
	if (contactLeadMap.isEmpty()) {
		return;
	}

	List<Attachment> attachmentsToDelete  = 
		[SELECT Id, ParentId, Name, Description, ContentType, BodyLength, Body 
		FROM Attachment
		WHERE CreatedDate = TODAY //TODO: maybe more recent (last hour?)
		AND ParentId IN :contactLeadMap.keySet()]; 
	
	List<Attachment> attachmentsToInsert = new List<Attachment>();
		
	for (Attachment att : attachmentsToDelete) {
		Lead l = contactLeadMap.get(att.ParentId);
		if (l != null) {
			Attachment att2 = att.clone(false);
			att2.ParentId = l.ConvertedOpportunityId;
			attachmentsToInsert.add(att2);
		}
	}	

	if (!attachmentsToDelete.isEmpty()) {
		delete attachmentsToDelete;
	}
	
	if (!attachmentsToInsert.isEmpty()) {
		insert attachmentsToInsert;
	}
}