/* MODIFICATION HISTORY
 * 04/03/2015 SZ - Update code to retrieve the correct office state based on Home_Office_c changing to a lookup instead of a picklist
 * 04/06/2015 SZ - Update code to take the entry state into account based on the Project_Client_Job__c field
 */
public with sharing class TimesheetEntryPostController {

	
    public Time_Sheet__c timeSheet{get;set;}     
    public List<TimeSheet_Payroll_Entry__c> payrollEntries{get;set;}
    

    public TimesheetEntryPostController(ApexPages.StandardController stdController) {
        this.timeSheet = (Time_Sheet__c)stdController.getRecord();
        // SZ: Change query to retrieve State__c from the lookup
        timeSheet = [Select Id, Employee__r.Home_Office_Location__r.State__c,Employee__r.Name,Employee__r.Employee_Number__c from Time_Sheet__c where id = :timeSheet.Id];
        // SZ: Refactor to use the TimesheetService class
        payrollEntries = TimesheetService.ProcessTimesheets(timeSheet);
    }

    public PageReference PostEntries()
	{		
		// SZ: Refactor to use the TimesheetService
		TimesheetService.ProcessPost(this.timeSheet, payrollEntries);

		return new PageReference('/' + timeSheet.Id );
	}
}