/* FILE: LeadSalesRegion_AIAU.trigger
 * AUTHOR: Tino Mattheou
 * DATE: August 22, 2012
 * PURPOSE: create or update the Lead_Sales_Region object based on the lead sales region
 * MODIFICATION HISTORY
 * 09/10/2012 TCM - delete Lead_Sales_Region__c record when Lead is deleted - zen-52
 *
 */
 
trigger LeadSalesRegion_AIAU on Lead (after insert, after update, after delete) {

/* 
     MK - 2014-03-20
     IMPORTANT: This logic is replicated in a few places.  All places are listed here so be sure to modify all logic for changes.
       LeadSalesRegionBatch.cls
       LeadSalesRegion.trigger
       LeadSalesRegion_AIAU.trigger
 */
 
 
	//don't perform updates if bypass is on	
	if (SalesRegionHelper.bypassSalesRegionTriggers || TriggerUtility.bypassLeadTriggersForBatchProcessing) { return; }
	

	//if insert or update, upsert the Lead_Sales_Region	
	if (Trigger.isInsert || Trigger.isUpdate) {
		
		List<Lead_Sales_Region__c> lsrsToUpdate = new List<Lead_Sales_Region__c>();
			
		for (Lead l : Trigger.new) {
			if (Trigger.isInsert 
			|| SalesRegionHelper.reprocessSalesRegions //force update to sales region
			|| l.Sales_Region__c != Trigger.oldMap.get(l.Id).Sales_Region__c) { //if sales region changed
				lsrsToUpdate.add(new Lead_Sales_Region__c(
					Sales_Region__c = l.Sales_Region__c,
					Lead_ID_Unique__c = l.Id,
					Lead_Created_Date__c = l.CreatedDate.date()
				));
			}
		}
		
		if (lsrsToUpdate.isEmpty()) {
			return;
		}
	
		Database.upsert(lsrsToUpdate, Lead_Sales_Region__c.Lead_ID_Unique__c);
		
	}
	
	if (Trigger.isDelete) {
		
		List<Lead_Sales_Region__c> lsrsToDelete =
			[SELECT Id 
			FROM Lead_Sales_Region__c
			WHERE Lead_ID_Unique__c IN :Trigger.oldMap.keySet()];

		if (!lsrsToDelete.isEmpty()) {
			Database.delete(lsrsToDelete, false);
		}
		
	}
	
}