public class TimesheetWeeklySummaryController {
	public Id timesheetId {get;set;}
    public List<Time_Sheet_Entry__c> getTimeEntries()
    {
        List<Time_Sheet_Entry__c> entries = [SELECT Id,start_time__c, end_time__c,Approved__c
	                                               ,timesheet_purpose__r.Name,Project_Client_Job__r.Name
	                                          from Time_Sheet_Entry__c 
	                                         where Time_Sheet__c = :timesheetId];
        return entries;
    }
}