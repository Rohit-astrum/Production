/* FILE: PropertyOpportunitySalesRegion.trigger
 * AUTHOR: Tino Mattheou
 * DATE: August 15, 2012
 * PURPOSE: set the sales region on opportunity and Sales Order based on the property sales region when sales region changes
 * MODIFICATION HISTORY
 *
 */
 
trigger PropertyOppSOSalesRegion on Property__c (after insert, after update) {

	//don't perform updates if bypass is on
	if (SalesRegionHelper.bypassSalesRegionTriggers) {
		return;
	}

	Set<Id> changedPropertyIds = new Set<Id>();
	
	for (Property__c p : Trigger.new) {
		if (p.Sales_Region__c != null && 
		(Trigger.isInsert 
		|| p.Sales_Region__c != Trigger.oldMap.get(p.Id).Sales_Region__c)) {
			changedPropertyIds.add(p.Id);
		}
	}
	
	if (changedPropertyIds.isEmpty()) {
		return;
	}


	//update opportunities
	List<Opportunity> oppsToUpdate = 
		[SELECT Id, Property__c, Sales_Region__c
		FROM Opportunity
		WHERE Property__c IN :changedPropertyIds];

	if (!oppsToUpdate.isEmpty()) {
		
		for (Opportunity opp : oppsToUpdate) {
			Property__c p = Trigger.newMap.get(opp.Property__c);
			if (p != null) {
				opp.Sales_Region__c = p.Sales_Region__c;
			}	
		}
		
		SalesRegionHelper.propertyOpportunityTriggerFiring = true;
		try { 
		
			//opportunity updates can fail
			Database.update(oppsToUpdate, false);
			
		} finally {
		
			SalesRegionHelper.propertyOpportunityTriggerFiring = false;
		
		}
		
	}
	
	//update sales orders
	List<SCRB_SalesOrder__c> ordersToUpdate = 
		[SELECT Id, Property__c, Sales_Region__c
		FROM SCRB_SalesOrder__c
		WHERE Property__c IN :changedPropertyIds];
		
	if (!ordersToUpdate.isEmpty()) {
		
		for (SCRB_SalesOrder__c so : ordersToUpdate) {
			Property__c p = Trigger.newMap.get(so.Property__c);
			if (p != null) {
				so.Sales_Region__c = p.Sales_Region__c;
			}	
		}
		
		//sales order updates can fail
		Database.update(ordersToUpdate, false);
		
	}


}