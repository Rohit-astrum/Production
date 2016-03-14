trigger UpdateOppOnSDQChange on System_Design_Quote__c (after update) {
	
	/* MK - 2014-07-21: Moved to trigger handler
	Map<Id, System_Design_Quote__c> sdqNewMap = Trigger.newMap;
	List<Opportunity> oppsToUpdate = new List<Opportunity>([Select o.id, o.Name, o.System_Design_Quote__c 
															From Opportunity o 
															Where o.System_Design_Quote__c 
															IN :sdqNewMap.keySet()]);
	
	update(oppsToUpdate);
	*/
}