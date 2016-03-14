/*
 * Created By: Steve Zilligen
 * Created On: 3/23/2015
 * Description: This controller performs the multiple timesheet post operation requested by TIME-18
 * Dependency: This code will need to be updated when TIME-12 is resolved, since they use the same code
 */
public with sharing class TimesheetPostController {

	private ApexPages.StandardSetController standardController;
	
    private List<TimeSheet_Payroll_Entry__c> payrollEntries {get;set;}
    private Map<Id, Time_Sheet__c> selectedTimesheetsMap {get;set;}

	/*
	 * Created By: Steve Zilligen
	 * Created On: 3/23/2015
	 * Description: This constructor uses the StandardSetController so it can be the target of a List View custom button
	 */
    public TimesheetPostController(ApexPages.StandardSetController controller) {
    	this.standardController = controller;
    }

	/*
	 * Created By: Steve Zilligen
	 * Created On: 3/23/2015
	 * Description: This method fires upon page load to provide the user with a list of the selected Time_Sheet__c objects
	 */
    public PageReference confirm()
    {
        // Get the selected records (optional, you can use getSelected to obtain ID's and do your own SOQL)
        Set<Id> selectedTimesheetIds = new Set<Id>();
        for(sObject obj : standardController.getSelected()){
        	selectedTimesheetIds.add(obj.Id);
        }

        selectedTimesheetsMap = new Map<Id, Time_Sheet__c>([SELECT Id, Employee__r.Home_Office_Location__r.State__c,Employee__r.Name,Employee__r.Employee_Number__c 
									        				FROM Time_Sheet__c 
									        				WHERE ID IN :selectedTimesheetIds]);
		payrollEntries = TimesheetService.ProcessTimesheets(selectedTimesheetsMap);
		
        return null;
	}

	/*
	 * Created By: Steve Zilligen
	 * Created On: 3/23/2015
	 * Description: This method is fired when the Post button is clicked and commits the new payroll entries to the system
	 */
    public PageReference post()
    {
    	TimesheetService.ProcessPost(selectedTimesheetsMap, payrollEntries);
    	
		return standardController.cancel();
    }
}