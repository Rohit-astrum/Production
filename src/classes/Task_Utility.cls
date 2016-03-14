public with sharing class Task_Utility {

	public static final String ON_HOLD_STATUS = 'On Hold';
	
	public static final String TASK_STATUS = 'Not Started';
	public static final String TASK_PRIORITY = 'Normal';
	public static final String TASK_SUBJECT = 'Follow-Up';
	public static final String TASK_DESCRIPTION = 'Please contact the lead by given due date.';
	
	public static void processStatusForOnHold(Map<Id, Lead> oldLeadsMap, Map<Id, Lead> newLeadsMap) {
	
		createTasksForLeadsInOnHoldStatus(newLeadsMap);
		
		clearOnHoldDateForLeadsLeavingOnHoldStatus(oldLeadsMap, newLeadsMap);
	}

	public static void clearOnHoldDateForLeadsLeavingOnHoldStatus(Map<Id, Lead> oldLeadsMap, Map<Id, Lead> newLeadsMap) {
		
		Set<Id> theIds = oldLeadsMap.keySet();
		
		for (Id tempId : theIds) {
			Lead oldTempLead = oldLeadsMap.get(tempId);
			Lead newTempLead = newLeadsMap.get(tempId);
			
			if (isMovingFromOnHoldStatus(oldTempLead, newTempLead)) {
				newTempLead.On_Hold_Until__c = null;
			}
		}
	}
	
	private static boolean isMovingFromOnHoldStatus(Lead oldLead, Lead newLead) {
		return oldLead.Status == ON_HOLD_STATUS && newLead.Status != ON_HOLD_STATUS;
	}
	
	public static void createTasksForLeadsInOnHoldStatus(Map<Id, Lead> newLeadsMap) {

		List<Lead> leadsInOnHoldStatus = getLeadsInOnHoldStatus(newLeadsMap);		

		System.debug('leadsInOnHoldStatus.size() = ' + leadsInOnHoldStatus.size());
		
		List<Task> tasksToAdd = new List<Task>();

		for (Lead tempLead : leadsInOnHoldStatus) {
			Task tempTask = createTask(tempLead.id, tempLead.On_Hold_Until__c);
			tasksToAdd.add(tempTask);
		}

		if (!tasksToAdd.isEmpty()) {
			insert tasksToAdd;
		}		
	}
	
	public static List<Lead> getLeadsInOnHoldStatus(Map<Id, Lead> newLeadsMap) {

		List<Lead> leadsInOnHoldStatus = new List<Lead>();

		List<Lead> newLeads = newLeadsMap.values();
					
		for (Lead tempLead : newLeads) {
			
			if (tempLead.status == ON_HOLD_STATUS) {
				leadsInOnHoldStatus.add(tempLead);
			}
		}
		
		return leadsInOnHoldStatus;
	}	
	
	public static Task createTask(Id theId, Date onHoldUntil) {

		Task tempTask = new Task();
		tempTask.whoId = theId;  // give the id of the Lead
		tempTask.activityDate = onHoldUntil;
		
		tempTask.description = TASK_DESCRIPTION;
		tempTask.priority = TASK_PRIORITY;
		tempTask.status = TASK_STATUS;
		tempTask.subject = TASK_SUBJECT;
		
		return tempTask;		
	}
	
}