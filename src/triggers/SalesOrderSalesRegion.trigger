/* FILE: OpportunitySalesRegion.trigger
 * AUTHOR: Tino Mattheou
 * DATE: August 16, 2012
 * PURPOSE: set the sales region on sales order based on the property sales region when sales order is attached to a property
 * MODIFICATION HISTORY
 *
 */
 
trigger SalesOrderSalesRegion on SCRB_SalesOrder__c (before insert, before update) {

	//don't perform updates if property opportunity trigger is updating the opportunity or bypass is on
	if (SalesRegionHelper.propertyOpportunityTriggerFiring
	|| SalesRegionHelper.bypassSalesRegionTriggers) {
		return;
	}

	List<SCRB_SalesOrder__c> ordersToUpdate = new List<SCRB_SalesOrder__c>();
	Set<Id> propertyIds = new Set<Id>();

	for (SCRB_SalesOrder__c so : Trigger.new) {
		if (so.Property__c != null
		&& (Trigger.isInsert
		|| so.Sales_Region__c == null
		|| SalesRegionHelper.reprocessSalesRegions //force update to sales region
		|| so.Property__c != Trigger.oldMap.get(so.Id).Property__c)) {
			propertyIds.add(so.Property__c);
			ordersToUpdate.add(so);
		}
	}
	
	if (!ordersToUpdate.isEmpty()) {
	
		Map<Id, Property__c> propertyMap = new Map<Id, Property__c>(
			[SELECT Id, Sales_Region__c
			FROM Property__c
			WHERE Id IN :propertyIds]
		);
	
		for (SCRB_SalesOrder__c so : ordersToUpdate) {
			Property__c property = propertyMap.get(so.Property__c);
			if (property != null) {
				so.Sales_Region__c = property.Sales_Region__c;
			}	
		}
	
	}

}