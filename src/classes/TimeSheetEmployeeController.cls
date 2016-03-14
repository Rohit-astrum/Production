/* changelog
 * TIME-20: SZ - modified getProjectRecs (3/30/2015)
 */
public with sharing class TimeSheetEmployeeController {

	public TimeSheetEmployeeController () {
    }    

    /* changelog
     * 3/18/2015, SZ, Removed the need to run a separate query for isMobile
     * 3/20/2015, SZ, Changed the query to use employee instead of UserInfo
     * 3/30/2015, SZ, Changed the query to use employee's install team so we find more than just the team lead
     */
    @RemoteAction
    public static List<Install_Project__c> getProjectRecs(Boolean isMobile,String username){ 
        /*
        if(isMobile)
        {       
            return [select Id,Name,Astrum_Office__c,Sales_Order__r.Name, Wo_Status__c 
                  from Install_Project__c 
                 Where Installer_Team__r.Team_Lead__r.SFDC_User__c = :Userinfo.getUserId()  
                     OR Electrician_Team__r.Team_Lead__r.SFDC_User__c = :Userinfo.getUserId() ];
        }
        else
        {
            return [select Id,Name,Astrum_Office__c,Sales_Order__r.Name, Wo_Status__c 
                  from Install_Project__c 
                 Where complete__c = false];   
        }
        */
        Decimal usern = Decimal.valueOf(username);
        Employee__c employee = [SELECT Id, Install_Team__c FROM Employee__c WHERE Employee_Number__c = :usern];
        System.debug('username: ' + username + '; employee id: ' + employee.Id);
        return [select Id,Name,Astrum_Office__c,Sales_Order__r.Name, Wo_Status__c 
                from Install_Project__c 
                Where (complete__c = false OR complete2__c = false)
                 AND (Installer_Team__c = :employee.Install_Team__c  
                 OR Electrician_Team__c = :employee.Install_Team__c) 
                ORDER BY Name];
                 //AND (Installer_Team__r.Team_Lead__r.Id = :employee.Id  
                 //OR Electrician_Team__r.Team_Lead__r.Id = :employee.Id) ];
                 //AND (Installer_Team__r.Team_Lead__r.SFDC_User__c = :Userinfo.getUserId()  
                 //OR Electrician_Team__r.Team_Lead__r.SFDC_User__c = :Userinfo.getUserId()) ];
    } 

    @RemoteAction
    public static List<Timesheet_Purpose__c> getPurpose(String empClass, String woStatus){
        return [select Id,Name from Timesheet_Purpose__c 
                 Where Active__c = true 
                  AND Applicable_Employee_Class__c includes (:empClass) 
                  AND Applicable_WO_Status__c includes (:woStatus)  order by Name ];
    }

    @RemoteAction
    public static Install_Project__c getProjectRecByBarCode(String barCode) {
        System.debug('Bar Code is:'+barCode);
        Install_Project__c[] rec = [select Id,Name,Astrum_Office__c,Sales_Order__r.Name, Wo_Status__c from Install_Project__c
                                where id = :barCode limit 1];
        if (rec.size() == 1)
           return rec[0];
        else          
           return null;
    }

    /* changelog
     * 3/20/2015, SZ, Added SFDC_User__c to employee__c query and set the employee property to the record
     */
    @RemoteAction
    public static EmployeeLoginDetail employeeLogin(String username,String passwd) {
        System.debug('username is:'+username);
        System.debug('passwd is:'+passwd);
        Decimal usern = Decimal.valueOf(username);
        Employee__c[] rec = [select id, employee_class__c 
                               From Employee__c 
                              where Employee_Number__c = :usern 
                                AND Employee_PIN__c = :passwd 
                                AND  Status__c != 'Inactive' limit 1];
        if (rec.size() == 1)           
        {
            //return rec[0].employee_class__c;
            //Check for open time sheet
            
            Time_Sheet_Entry__c[] openTimesheets = [Select Id,start_time__c, Time_Sheet__r.employee__r.employee_class__c
                                                           ,timesheet_purpose__r.Name,Project_Client_Job__r.Name,Project_Client_Job__c
                                                      from Time_Sheet_Entry__c 
                                                     where Time_Sheet__r.employee__c = :rec[0].id
                                                       AND End_Time__c = null ]; 
            EmployeeLoginDetail eld = new EmployeeLoginDetail();
            eld.empClass = rec[0].employee_class__c;
            eld.empId = rec[0].Id;
            Datetime todayDate = Datetime.newInstance(Date.today() , Time.newInstance(0,0, 0, 0) );
            if (openTimesheets.size() > 0)           
            {                
                for(Time_Sheet_Entry__c tse : openTimesheets)
                {
                    if(tse.start_time__c >= todayDate)
                    {
                        eld.timeSheetEntry = tse;   
                    }
                    else
                    {
                        tse.End_Time__c = Datetime.newInstance(tse.Start_Time__c.date(), Time.newInstance(23,59, 59, 0));
                        update tse;   
                    }
                }
               
            }                
            return  eld;      

        }
        else
        {          
           return null;
        }
    }

    /*JS Remoting function invoked from the VF page to complete the Check-In*/
    @RemoteAction
    public static Datetime completeCheckIn(Decimal lat, Decimal lon, String employeeId, String projectId, String purposeId,String timesheetEntryId) {
        System.debug(Logginglevel.INFO, 'Current location:'+lat+','+lon);
        System.debug(Logginglevel.INFO, 'Purpose:'+purposeId);
        System.debug(Logginglevel.INFO, 'timesheetEntryId:'+timesheetEntryId);
        if(purposeId != null && purposeId != '')
        {
            
            Datetime stTime = System.now();
            Time_Sheet_Entry__c  tse = new Time_Sheet_Entry__c();

            if(timesheetEntryId != null && timesheetEntryId != '')
            {
                stTime = completeCheckOut(lat,lon,timesheetEntryId);   
            }
            if(projectId != null && projectId != '')
            {
                tse.Project_Client_Job__c = projectId;
            }

            tse.Timesheet_Purpose__c = purposeId;
            tse.checkin_location__latitude__s = lat;
            tse.checkin_location__longitude__s = lon;
            tse.Start_Time__c = stTime;

            // Check for Open TimeSheet for this week
            Date monday = Date.newInstance(1900, 1, 1); // MOnday
            Date todayDate = Date.today();
            Integer dayOfWeek = Math.mod(monday.daysBetween(todayDate), 7);  // 0 for MOnday , 1 for Tuesday and so on          
            Date weekStart = todayDate - dayOfWeek ; 
            Time_Sheet__c[] timeSheet = [Select id from Time_Sheet__c Where employee__c = :employeeId AND For_The_Week_Starting__c = :weekStart ];

            if(timeSheet.size() > 0)
            {
                tse.Time_Sheet__c = timeSheet[0].Id;
            }
            else
            {
                Time_Sheet__c ts = new Time_Sheet__c();
                ts.Employee__c = employeeId;
                ts.For_The_Week_Starting__c = weekStart;
                insert ts;
                tse.Time_Sheet__c =ts.Id;
            }

            insert tse;

            return tse.Start_Time__c;
        }        
        else
        {
            return null;
        }
    }

    @RemoteAction
    public static Datetime completeCheckOut(Decimal lat, Decimal lon,String timesheetEntryId) {
      
        if(timesheetEntryId != null && timesheetEntryId != '')
        {
            Time_Sheet_Entry__c  tse = [select End_Time__c from Time_Sheet_Entry__c where id = :timesheetEntryId ];
            tse.End_Time__c = System.now();
            tse.checkout_location__latitude__s = lat;
            tse.checkout_location__longitude__s = lon;

            update tse;

            return tse.End_Time__c;
        }        
        else
        {
            return null;
        }
    }

    public class EmployeeLoginDetail
    {
        public String empClass {get;set;}
        public String empId {get;set;}
        public Time_Sheet_Entry__c timeSheetEntry {get;set;}
    }


    
}