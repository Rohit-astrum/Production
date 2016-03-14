/* FILE: TimeSheetLaborEntryEoMProcessor.cls
 * AUTHOR: Pavitra Burla
 * DATE: Feb 10, 2015
 * PURPOSE: Create Labor Entries for corresponding Time Sheet Entries for EoM processsing
 * MODIFICATION HISTORY
 * 04/17/2015 SZ - Updated the query to account for the new way of determining the State 
 * 06/23/2015 PB - Added filter for CreatedDate to the query
 */
global class TimeSheetLaborEntryEoMProcessor extends TimeSheetLaborEntryProcessor implements Schedulable{
    
    public override String getQuery(){
        
        String endOfWeek =  String.valueof(date.today().toStartOfMonth().addDays(16));
		String startOfWeek =  String.valueof(date.today().toStartOfWeek().addDays(1));		
		        
        //String query = 'SELECT End_Time__c,Entry_Date__c,Id,Name,Posted__c,Project_Client_Job__r.Work_Order__c, Project_Client_Job__r.Work_Order__r.rstk__wocst_qtyreq__c, Project_Client_Job__r.Work_Order__r.rstk__externalid__c ,Start_Time__c,Timesheet_Purpose__r.name, Timesheet_Purpose__r.DE_Code__c ,Time_Sheet__r.Employee__c,Time_Sheet__r.Employee__r.Home_Office_Location__c,Total_Hours__c,Time_Sheet__r.Employee__r.Employee_Number__c';
        String query = 'SELECT End_Time__c,Entry_Date__c,Id,Name,Posted__c,Project_Client_Job__r.Work_Order__c, Project_Client_Job__r.Work_Order__r.rstk__wocst_qtyreq__c, Project_Client_Job__r.Work_Order__r.rstk__externalid__c , Start_Time__c,Timesheet_Purpose__r.name, Timesheet_Purpose__r.DE_Code__c ,Time_Sheet__r.Employee__c, Time_Sheet__r.Employee__r.Home_Office_Location__r.State__c,Total_Hours__c,Time_Sheet__r.Employee__r.Employee_Number__c';
        query+= ' FROM Time_Sheet_Entry__c';
        query+= ' WHERE CreatedDate = LAST_N_DAYS:45';
        query+= ' AND Posted__c = true';
        query+= ' AND Entry_Date__c >=' + startOfWeek;
        query+= ' AND Entry_Date__c <' + endOfWeek;
        query+= ' AND Timesheet_Purpose__r.DE_Code__c = \'9005\'';
        query+= ' AND Labor_Processed__c = false';
        query+= ' AND Total_Hours__c > 0';
        query+= ' ORDER BY Time_Sheet__r.Employee__r.Employee_Number__c, Entry_Date__c';
        
        return query;
        
    }    

}