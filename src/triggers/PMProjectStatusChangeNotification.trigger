/* FILE: PMProjectStatusChangeNotification.trigger
 * AUTHOR: Tino Mattheou
 * DATE: June 7, 2012
 * PURPOSE: sends an email to the Director of Operations when a project's status is changed  
 * MODIFICATION HISTORY
 *
 */ 

trigger PMProjectStatusChangeNotification on PM_Project__c (after update) {

	if(TriggerUtility.skipPMProjectTriggers){
        return;
    }

	Set<Id> salesOrderIds = new Set<Id>();
	List<PM_Project__c> statusChangedProjects = new List<PM_Project__c>();
	
	for (PM_Project__c project : Trigger.new) {
		
		String oldStatus = Trigger.oldMap.get(project.Id).Status__c;
		
		if (project.Status__c != oldStatus && project.Sales_Order__c != null) {
			salesOrderIds.add(project.Sales_Order__c);
			statusChangedProjects.add(project);
		}
		
	}
	
	if (salesOrderIds.isEmpty()) {
		return;
	}
	
	Map<Id, SCRB_SalesOrder__c> salesOrderMap = new Map<Id, SCRB_SalesOrder__c>(
		[SELECT Id, Director_of_Operations__c
		FROM SCRB_SalesOrder__c
		WHERE Id IN :salesOrderIds 
		AND Director_of_Operations__c <> NULL]
	);
	
	if (salesOrderMap.isEmpty()) {
		return;
	}

	List<Messaging.Email> emailsToSend = new List<Messaging.Email>();
	
	for (PM_Project__c project : statusChangedProjects) {
		SCRB_SalesOrder__c salesOrder = salesOrderMap.get(project.Sales_Order__c);
		if (salesOrder != null) {
			Id director = salesOrder.Director_of_Operations__c;
			
			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			email.setTargetObjectId(director);
			email.setSubject('Project: ' + project.Name + ' - status changed to ' + project.Status__c);
			email.setPlainTextBody(
				'Project: ' + project.Name
				+ '\nLink: ' + Url.getSalesforceBaseUrl().toExternalForm() + '/' + project.Id 
			);
			email.setSaveAsActivity(false);
			emailsToSend.add(email);
		}
	}
	
	if (emailsToSend.isEmpty()) {
		return;
	}
	
	Messaging.sendEmail(emailsToSend, false);

}