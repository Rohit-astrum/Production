public without sharing class TimeSheetDeleteUtility {

    public static void copyTimeSheetToDeletedTimeSheet(Map<Id, Time_Sheet__c> timesheets){
    	//return;
        Map<Id, Time_Sheet_Entry__c> timeSheetEntries = new Map<Id, Time_Sheet_Entry__c>(
                [SELECT Id, Approval_Date__c, Approved__c, Approved_By__c, Bonus_Type__c, CheckIn_Location__latitude__s, 
                    Checkout_Location__latitude__s, CheckIn_Location__longitude__s, Checkout_Location__longitude__s,
                    End_Time__c, Entry_Date__c, Half_Hour_Lunch_Break__c, Hotel_Cost__c, Job_Id__c, Labor_Processed__c,
                    Maintenance_Type__c, Posted__c, Posted_By__c, Project_Client_Job__c, Purpose__c,
                    Start_Time__c, Start_Time_Off_Site__c, Start_Time_On_Site__c, Stayed_Overnight__c,
                    Time_Sheet__r.Employee__c, Timesheet_Purpose__c, Total_Hours__c
                FROM Time_Sheet_Entry__c WHERE Time_Sheet__c IN :timesheets.keySet()]);
        copyTimeSheetEntryToDeletedTimeSheetEntry(timeSheetEntries);

        List<Deleted_Time_Sheet__c> deletedTimesheets = new List<Deleted_Time_Sheet__c>();
        for(Time_Sheet__c timesheet : timesheets.values()){
        	deletedTimesheets.add(new Deleted_Time_Sheet__c(
        		Employee__c = timesheet.Employee__c,
        		Employee_Email__c = timesheet.Employee_Email__c,
        		For_The_Week_Starting__c = timesheet.For_The_Week_Starting__c,
        		Weekly_Budget_Impact_Hours__c = timesheet.Weekly_Budget_Impact_Hours__c,
        		Weekly_Holiday_Hours__c = timesheet.Weekly_Holiday_Hours__c,
        		Weekly_Hotel_Costs__c = timesheet.Weekly_Hotel_Costs__c,
        		Weekly_Hours_Worked__c = timesheet.Weekly_Hours_Worked__c,
        		Weekly_Overtime_Hours__c = timesheet.Weekly_Overtime_Hours__c,
        		Weekly_Overtime_Hours_Percentage__c = timesheet.Weekly_Overtime_Hours_Percentage__c,
        		Weekly_Overtime_Pay__c = timesheet.Weekly_Overtime_Pay__c,
        		Weekly_Paid_Time_Off_Hours__c = timesheet.Weekly_Paid_Time_Off_Hours__c,
        		Weekly_Sick_Time_Hours__c = timesheet.Weekly_Sick_Time_Hours__c,
        		Weekly_Standard_Hours__c = timesheet.Weekly_Standard_Hours__c,
        		Weekly_Standard_Pay__c = timesheet.Weekly_Standard_Pay__c,
        		Weekly_Total_Hours__c = timesheet.Weekly_Total_Hours__c,
        		Weekly_Total_Pay__c = timesheet.Weekly_Total_Pay__c,
        		Weekly_Vacation_Time_Hours__c = timesheet.Weekly_Vacation_Time_Hours__c
        		)
        	);
        }

        if(deletedTimesheets.size() > 0){
            insert deletedTimesheets;
        }
    }   

    public static void copyTimeSheetEntryToDeletedTimeSheetEntry(Map<Id, Time_Sheet_Entry__c> timeSheetEntries){
        //return;
        Set<Id> timesheetIds = new Set<Id>();
        for(Time_Sheet_Entry__c tse : timeSheetEntries.values()){
            if(!timesheetIds.contains(tse.Time_Sheet__c)){
                timesheetIds.add(tse.Time_Sheet__c);
            }
        }
        Map<Id, Time_Sheet__c> timesheets = new Map<Id, Time_Sheet__c>([SELECT Id, Employee__c FROM Time_Sheet__c WHERE Id IN :timesheetIds]);

        List<Deleted_Time_Sheet_Entry__c> deletedTimesheetEntries = new List<Deleted_Time_Sheet_Entry__c>();
        for(Time_Sheet_Entry__c timesheetEntry : timeSheetEntries.values()){
            deletedTimesheetEntries.add(new Deleted_Time_Sheet_Entry__c(
                Approval_Date__c = timesheetEntry.Approval_Date__c,
                Approved__c = timesheetEntry.Approved__c,
                Approved_By__c = timesheetEntry.Approved_By__c,
                Bonus_Type__c = timesheetEntry.Bonus_Type__c,
                CheckIn_Location__latitude__s = timesheetEntry.CheckIn_Location__latitude__s,
                Checkout_Location__latitude__s = timesheetEntry.Checkout_Location__latitude__s,
                CheckIn_Location__longitude__s = timesheetEntry.CheckIn_Location__longitude__s,
                Checkout_Location__longitude__s = timesheetEntry.Checkout_Location__longitude__s,
                End_Time__c = timesheetEntry.End_Time__c,
                Entry_Date__c = timesheetEntry.Entry_Date__c,
                Half_Hour_Lunch_Break__c = timesheetEntry.Half_Hour_Lunch_Break__c,
                Hotel_Cost__c = timesheetEntry.Hotel_Cost__c,
                Job_Id__c = timesheetEntry.Job_Id__c,
                Labor_Processed__c = timesheetEntry.Labor_Processed__c,
                Maintenance_Type__c = timesheetEntry.Maintenance_Type__c,
                Posted__c = timesheetEntry.Posted__c,
                Posted_By__c = timesheetEntry.Posted_By__c,
                Project_Client_Job__c = timesheetEntry.Project_Client_Job__c,
                Purpose__c = timesheetEntry.Purpose__c,
                Start_Time__c = timesheetEntry.Start_Time__c,
                Start_Time_Off_Site__c = timesheetEntry.Start_Time_Off_Site__c,
                Start_Time_On_Site__c = timesheetEntry.Start_Time_On_Site__c,
                Stayed_Overnight__c = timesheetEntry.Stayed_Overnight__c,
                Time_Sheet_Employee__c = timesheets.get(timesheetEntry.Time_Sheet__c).Employee__c,
                Timesheet_Purpose__c = timesheetEntry.Timesheet_Purpose__c,
                Total_Hours__c = timesheetEntry.Total_Hours__c
                )
            );
        }

        if(deletedTimesheetEntries.size() > 0){
            insert deletedTimesheetEntries;
        }
    }
}