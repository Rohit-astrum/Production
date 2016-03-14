trigger Milestone1_Task_Trigger on Milestone1_Task__c ( before insert, before update,after insert,after update ) {
					
	System.debug('Milestone1_Task_Trigger:  TriggerUtility.taskTriggerHasNotRun_Before = ' + TriggerUtility.taskTriggerHasNotRun_Before);
	System.debug('Milestone1_Task_Trigger:  TriggerUtility.taskTriggerHasNotRun_After = ' + TriggerUtility.taskTriggerHasNotRun_After);
	
	if (trigger.isBefore && TriggerUtility.taskTriggerHasNotRun_Before) {
		TriggerUtility.taskTriggerHasNotRun_Before = false;
		Milestone1_Task_Trigger_Utility.handleTaskBeforeTrigger(trigger.new);  
	} 

	if (trigger.isAfter && TriggerUtility.taskTriggerHasNotRun_After) {
		TriggerUtility.taskTriggerHasNotRun_After = false;
		Milestone1_Task_Trigger_Utility.handleTaskAfterTrigger(trigger.new,trigger.old);
		//Milestone1_Task_Trigger_Utility.setProjectKeyDates(trigger.new);
	} 

	if (trigger.isAfter && trigger.isUpdate) {
		Milestone1_Task_Trigger_Utility.performTaskAutoAssignment(trigger.new);
	} 
}