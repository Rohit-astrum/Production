/* FILE: OpportunitySalesRegion.trigger
 * AUTHOR: Tino Mattheou
 * DATE: August 15, 2012
 * PURPOSE: set the sales region on opportunity based on the property sales region when opportunity is attached to a property
 * MODIFICATION HISTORY
 *
 */
 
trigger OpportunitySalesRegion on Opportunity (before insert, before update) {
	
	//don't perform updates if property opportunity trigger is updating the opportunity or bypass is on
	if (SalesRegionHelper.propertyOpportunityTriggerFiring || SalesRegionHelper.bypassSalesRegionTriggers) return;
	
	//MK - 2014-08-25 - prevent recursive firing of triggers, saves unecessary processing
	if(Opportunity_Trigger_Utility.isOpportunityTriggerRunning || Opportunity_Trigger_Utility.skipOpportunityTrigger) return;
	Opportunity_Trigger_Utility.isOpportunityTriggerRunning = true;

	List<Opportunity> oppsToUpdate = new List<Opportunity>();
	Set<Id> propertyIds = new Set<Id>();

	for (Opportunity opp : Trigger.new) {
		if (opp.Property__c != null
		&& (Trigger.isInsert
		|| opp.Sales_Region__c == null
		|| SalesRegionHelper.reprocessSalesRegions //force update to sales region
		|| opp.Property__c != Trigger.oldMap.get(opp.Id).Property__c)) {
			propertyIds.add(opp.Property__c);
			oppsToUpdate.add(opp);
		}
	}
	
	if (!oppsToUpdate.isEmpty()) {
	
		Map<Id, Property__c> propertyMap = new Map<Id, Property__c>(
			[SELECT Id, Sales_Region__c
			FROM Property__c
			WHERE Id IN :propertyIds]
		);
	
		for (Opportunity opp : oppsToUpdate) {
			Property__c property = propertyMap.get(opp.Property__c);
			if (property != null) {
				opp.Sales_Region__c = property.Sales_Region__c;
			}	
		}
	
	}

	//MK - 2014-08-25 - prevent recursive firing of triggers, saves unecessary processing
	Opportunity_Trigger_Utility.isOpportunityTriggerRunning = false;
	
}