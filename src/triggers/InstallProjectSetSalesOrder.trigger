/* FILE: InstallProjectSetSalesOrder.trigger
 * AUTHOR: Tino Mattheou
 * DATE: July 5, 2012
 * PURPOSE: Values the Sales Order from the PM 2.0 Project onto Install Project (zen-26 AstrumTime update)
 * MODIFICATION History 
 * 07/30/2012 TCM - zen-41 - prevent having more than one install project for an Astrum PM 2.0 project
 */
 
trigger InstallProjectSetSalesOrder on Install_Project__c (before insert, before update) {

	List<Install_Project__c> installProjectsToUpdate = new List<Install_Project__c>();
	Set<Id> pmProjectIds = new Set<Id>(); 
	
	for (Install_Project__c p : Trigger.new) {
		p.Astrum_PM_2_0_Unique_Index__c = p.PM_Project__c; 
		if (p.PM_Project__c != null && (Trigger.isInsert || p.PM_Project__c != Trigger.oldMap.get(p.Id).PM_Project__c)) {
			installProjectsToUpdate.add(p);
			pmProjectIds.add(p.PM_Project__c);
		}
	}

	if (pmProjectIds.isEmpty() || installProjectsToUpdate.isEmpty()) {
		return;
	}

	Map<Id, PM_Project__c> pmProjectMap = new Map<Id, PM_Project__c>(
		[SELECT Id, Sales_Order__c
		FROM PM_Project__c
		WHERE Id IN :pmProjectIds]
	);
	
	for (Install_Project__c p : installProjectsToUpdate) {
		PM_Project__c pmProject = pmProjectMap.get(p.PM_Project__c);
		if (pmProject != null) {
			p.Sales_Order__c = pmProject.Sales_Order__c;
		}
	}
		
}