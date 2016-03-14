/* FILE: SalesOrderTrigger.trigger
 * AUTHOR: Michael Katulka
 * DATE: 2014-04-03
 * PURPOSE: Common trigger for all triggers on SCRB_SalesOrder__c object.
 * MODIFICATION HISTORY: 
 *  			2014-04-04: Moved other trigger code into this combined trigger
 *				2015-04-14: SZ - Added code for setting fields related to commissions
 *
 */
trigger SalesOrderTrigger on SCRB_SalesOrder__c (before update, before insert, after insert, after update) {
    
    system.debug('***SalesOrderTrigger begin');
    if(SalesOrderTriggerHandler.isSalesOrderTriggerRunning || SalesOrderTriggerHandler.skipSalesOrderTrigger) return;
    SalesOrderTriggerHandler.isSalesOrderTriggerRunning = true;

	//Set SO name and assign to director of operations as needed	
	if(Trigger.isBefore && Trigger.isInsert) SalesOrderTriggerHandler.setNameAndAssignOnInsert(trigger.new, true);

	//Update sales region
	if(Trigger.isBefore && (Trigger.isInsert || trigger.isUpdate)) SalesOrderTriggerHandler.updateSalesRegion(trigger.new, trigger.oldMap, true, trigger.isInsert);	

	//Capture Data and original data
    if(trigger.isbefore && trigger.isupdate) SalesOrderTriggerHandler.salesOrderCaptureData(trigger.new, trigger.oldMap, true);   

    //Sale Bonus Status/Approval process change history tracking	
	if(trigger.isbefore && trigger.isupdate) SalesOrderTriggerHandler.trackSalesOrderStatusHistory(trigger.new, trigger.oldMap, true);    

	// SZ - 2015-040-14: Code for setting of commissions related fields
	if(Trigger.isBefore){
		if(Trigger.isInsert){
			SalesOrderTriggerHandler.updateCommissionsFields(Trigger.new, null, true);
		}
		else if (Trigger.isUpdate){
			SalesOrderTriggerHandler.updateCommissionsFields(Trigger.new, Trigger.oldMap, true);
		}
	} else if(Trigger.isAfter){
		if(Trigger.isUpdate){
			SalesOrderTriggerHandler.updateOpportunityFields(Trigger.new, Trigger.oldMap);
			SalesOrderTriggerHandler.sendSalesOrderEmails(Trigger.new, Trigger.oldMap);//SOA PB
					
		}
	}
	
	SalesOrderTriggerHandler.isSalesOrderTriggerRunning = false;
	system.debug('***SalesOrderTrigger end');
}