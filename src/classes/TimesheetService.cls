/*
 * Created By: Steve Zilligen
 * Created On: 3/23/2015
 * Description: This service class performs the timesheet post operation requested by TIME-18 (TimesheetPostController),
 * but consolidates the code that is also used for the single operation (TimesheetEntryPostController)
 * Dependency: This code will need to be updated when TIME-12 is resolved, since it uses the same code
 */
public with sharing class TimesheetService {
	
	/*
	 * Created By: Steve Zilligen
	 * Created On: 3/23/2015
	 * Description: This method takes a single Time_Sheet__c as a parameter and processes it.  This method will be used
	 *				to replace the code in the TimesheetEntryPostController
	 */
	public static List<TimeSheet_Payroll_Entry__c> ProcessTimesheets(Time_Sheet__c timesheet) {
		Map<Id, Time_Sheet__c> selectedTimesheetsMap = new Map<Id, Time_Sheet__c>();
		selectedTimesheetsMap.put(timesheet.Id, timesheet);
		return ProcessTimesheets(selectedTimesheetsMap);
	}
	
	/*
	 * Created By: Steve Zilligen
	 * Created On: 3/23/2015
	 * Description: This method takes a Map of Time_Sheet__c objects and builds the payroll entries
	 */
    public static List<TimeSheet_Payroll_Entry__c> ProcessTimesheets(Map<Id, Time_Sheet__c> selectedTimesheetsMap) {
    	// Create a map of Employee to Home Office
    	system.debug('**SZ: selectedTimesheetsMap size - '+selectedTimesheetsMap.size());
    	system.debug('**SZ: Populate employeeHomeOffices');
    	Map<Id, String> employeeHomeOffices = new Map<Id, String>();
    	for(Time_Sheet__c timesheet : selectedTimesheetsMap.values()){
    		if(!employeeHomeOffices.containsKey(timesheet.Employee__c)){
		    	system.debug('**SZ: employeeHomeOffice - ' + timesheet.Employee__c);
		    	system.debug('**SZ: employeeHomeOffice - ' + timesheet.Employee__r.Home_Office_Location__c);
		    	system.debug('**SZ: employeeHomeOffice - ' + timesheet.Employee__r.Home_Office_Location__r.State__c);
    			employeeHomeOffices.put(timesheet.Employee__c, timesheet.Employee__r.Home_Office_Location__r.State__c);
    		}
    	}
    	
    	system.debug('**SZ: Get AggregateResults');
        // Regular Hours
        AggregateResult[] groupedEntries =  [SELECT Time_Sheet__r.Employee__c emp, Entry_Date__c entryDate, Project_Client_Job__r.Sales_Order__r.Property__r.Astrum_Office_New__r.State__c entryState, Sum(Total_Hours__c ) hours
   										   		FROM Time_Sheet_Entry__c 
   										  		WHERE Time_Sheet__c IN :selectedTimesheetsMap.keyset() 
       										    	AND Approved__c = true 
       										    	AND Posted__c = false 
       										  		AND Timesheet_Purpose__r.DE_Code__c  = '9005'  
       										  	GROUP BY Time_Sheet__r.Employee__c, Entry_Date__c, Project_Client_Job__r.Sales_Order__r.Property__r.Astrum_Office_New__r.State__c Order by Entry_Date__c];

        // Non Regular Hours
        AggregateResult[] groupedNonEntries =  [SELECT Time_Sheet__r.Employee__c emp, Timesheet_Purpose__r.DE_Code__c deCode,Entry_Date__c entryDate, Sum(Total_Hours__c ) hours
       										   	FROM Time_Sheet_Entry__c 
       										  	WHERE Time_Sheet__c IN :selectedTimesheetsMap.keyset() 
       										    	AND Approved__c = true 
       										    	AND Posted__c = false 
       										  		AND Timesheet_Purpose__r.DE_Code__c  != '9005'  
       										  	GROUP BY Time_Sheet__r.Employee__c, Timesheet_Purpose__r.DE_Code__c,Entry_Date__c Order by Entry_Date__c];

    	system.debug('**SZ: Populate payrollEntries');
        List<TimeSheet_Payroll_Entry__c> payrollEntries = new List<TimeSheet_Payroll_Entry__c>();
		Integer day = 1;
		for (AggregateResult ar : groupedEntries)
		{
	        System.debug('aggregate emp '+ ar.get('emp'));
			String officeState = employeeHomeOffices.get((Id)ar.get('emp'));
	        System.debug('officeState '+ officeState);
			if(officeState != 'CA' && ar.get('entryState') != 'CA'){
				System.debug('Not CA State  days' + groupedEntries.size() );
				TimeSheet_Payroll_Entry__c tpe = new TimeSheet_Payroll_Entry__c();
				tpe.DE_Code__c = '9005';
				tpe.Employee__c = (Id)ar.get('emp');
				tpe.Hours__c = (Decimal)ar.get('hours');
				tpe.Time_Entry_Date__c = (Date)ar.get('entryDate');
				payrollEntries.add(tpe);
			} else {
				System.debug('CA State  days' + groupedEntries.size() );
				Date entryDate = (Date)ar.get('entryDate');
				Id employeeId = (Id)ar.get('emp');

				Decimal dayHours = (Decimal)ar.get('hours');
				if(dayHours > 12 )
				{
					if(day != 7)
					{
						TimeSheet_Payroll_Entry__c tpe = createPayrollEntry( '9005' , employeeId, 8, entryDate);
						payrollEntries.add(tpe);
						TimeSheet_Payroll_Entry__c tpe1 = createPayrollEntry( '9020' , employeeId, 4, entryDate);
						payrollEntries.add(tpe1);
						TimeSheet_Payroll_Entry__c tpe2 = createPayrollEntry( '9025' , employeeId, dayHours - 12 , entryDate);
						payrollEntries.add(tpe2);
					}
					else
					{
						TimeSheet_Payroll_Entry__c tpe1 = createPayrollEntry( '9020' , employeeId, 8, entryDate);
						payrollEntries.add(tpe1);
						TimeSheet_Payroll_Entry__c tpe2 = createPayrollEntry( '9025' , employeeId, dayHours - 8 , entryDate);
						payrollEntries.add(tpe2);	
					}
				}
				else if (dayHours <=12  && dayHours > 8)
				{
					if(day != 7)
					{
						TimeSheet_Payroll_Entry__c tpe = createPayrollEntry( '9005' , employeeId, 8, entryDate);
						payrollEntries.add(tpe);						
						TimeSheet_Payroll_Entry__c tpe2 = createPayrollEntry( '9020' , employeeId, dayHours - 8 , entryDate);
						payrollEntries.add(tpe2);
					}
					else
					{
						TimeSheet_Payroll_Entry__c tpe1 = createPayrollEntry( '9020' , employeeId, 8, entryDate);
						payrollEntries.add(tpe1);
						TimeSheet_Payroll_Entry__c tpe2 = createPayrollEntry( '9025' , employeeId, dayHours - 8 , entryDate);
						payrollEntries.add(tpe2);	
					}	
				}
				else 
				{
					if(day != 7)
					{	
						TimeSheet_Payroll_Entry__c tpe2 = createPayrollEntry( '9005' , employeeId, dayHours , entryDate);
						payrollEntries.add(tpe2);
					}
					else
					{
						TimeSheet_Payroll_Entry__c tpe1 = createPayrollEntry( '9020' , employeeId, dayHours, entryDate);
						payrollEntries.add(tpe1);						
					}		
				}
				day = day +1;
			}
		}

		for (AggregateResult ar : groupedNonEntries)
		{	
			Date entryDate = (Date)ar.get('entryDate');
			Id employeeId = (Id)ar.get('emp');
			Decimal dayHours = (Decimal)ar.get('hours');
			String deCode = (String)ar.get('deCode');
			TimeSheet_Payroll_Entry__c tpe = createPayrollEntry( deCode, employeeId, dayHours , entryDate);
			payrollEntries.add(tpe);
		}
		
		return payrollEntries;
    }

	/*
	 * Created By: Steve Zilligen
	 * Created On: 3/23/2015
	 * Description: This method inserts the payrollEntries list and then updates the Posted__c flag for the approved
	 *				Time_Sheet_Entry__c objects in the Time_Sheet__c
	 */
    public static void ProcessPost(Time_Sheet__c timesheet, List<TimeSheet_Payroll_Entry__c> payrollEntries) {
		Map<Id, Time_Sheet__c> selectedTimesheetsMap = new Map<Id, Time_Sheet__c>();
		selectedTimesheetsMap.put(timesheet.Id, timesheet);
		ProcessPost(selectedTimesheetsMap, payrollEntries);
    }
    
	/*
	 * Created By: Steve Zilligen
	 * Created On: 3/23/2015
	 * Description: This method inserts the payrollEntries list and then updates the Posted__c flag for the approved
	 *				Time_Sheet_Entry__c objects in the map of Time_Sheet__c objects
	 */
    public static void ProcessPost(Map<Id, Time_Sheet__c> selectedTimesheetsMap, List<TimeSheet_Payroll_Entry__c> payrollEntries) {
		if(payrollEntries.size() > 0)
		{
			insert payrollEntries;
		}
		
		List<Time_Sheet_Entry__c> tsentries = [SELECT Id,Posted__c,Posted_By__c 
												FROM Time_Sheet_Entry__c 
       										  	WHERE Time_Sheet__c IN :selectedTimesheetsMap.keyset() 
													AND Approved__c = true];
		for (Time_Sheet_Entry__c tse : tsentries)
		{
			tse.posted__c = true;	
			tse.Posted_By__c = UserInfo.getUserId();
		}

		update tsentries;
    }

	/*
	 * Created By: Steve Zilligen
	 * Created On: 3/23/2015
	 * Description: This method creates a TimeSheet_Payroll_Entry__c object from the provided parameters
	 */
    private static TimeSheet_Payroll_Entry__c createPayrollEntry( String deCode , Id employeeId, Decimal hours, Date entryDate)
    {
    	TimeSheet_Payroll_Entry__c tpe = new TimeSheet_Payroll_Entry__c();
		tpe.DE_Code__c = deCode;
		tpe.Employee__c = employeeId;
		tpe.Hours__c = hours;
		tpe.Time_Entry_Date__c = entryDate;	

		return tpe;
    }
}