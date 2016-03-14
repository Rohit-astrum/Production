public with sharing class TaskDetailHolder {

	public String milestoneName {get; set;}
	public String milestoneColor {get; private set;}

	public Milestone1_Task__c task {get; set;}		
	
	public String complete {get; set;}
	public String blocked {get; set;}
	public String requiresDocumentation {get; set;}

	public String taskColor {get; private set;}
	
	public static final String YES = 'Yes';
	public static final String NO = 'No';
		
	public TaskDetailHolder(String theMilestoneName, String theMilestoneColor, Milestone1_Task__c theTask, String theTaskColor) {
		milestoneName = theMilestoneName;
		milestoneColor = theMilestoneColor;
		
		task = theTask;
		taskColor = theTaskColor;
		
		complete = toStringYesNo(task.complete__c);
		blocked = toStringYesNo(task.blocked__c);
		requiresDocumentation = toStringYesNo(task.Requires_Documentation__c);		
	}

	public static String toStringYesNo(Boolean flag) {
		String result = null;
				
		if (flag) {
			result = YES;
		}
		else {
			result = NO;
		}
		
		return result;
	}	
}