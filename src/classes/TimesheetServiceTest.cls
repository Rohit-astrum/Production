@isTest
private class TimesheetServiceTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out

    @isTest
    static void test_ProcessSingleTimesheet() {
        if(!runalltests){ return; }

        AstrumTimeTestData testData = new AstrumTimeTestData();
        testData.PopulateTestData();

        List<Time_Sheet__c> timeSheets = new List<Time_Sheet__c>();
        
        Time_Sheet__c tsInstall = new Time_Sheet__c();
        tsInstall.Employee__c = testData.employeesNameIdMap.get('Test Installer');
        tsInstall.For_The_Week_Starting__c = testData.weekStart;
        timeSheets.add(tsInstall);
        
        insert timeSheets;

        List<Time_Sheet_Entry__c> timeSheetEntries = new List<Time_Sheet_Entry__c>();
        
        Time_Sheet_Entry__c tseInstall = new Time_Sheet_Entry__c();
        tseInstall.Start_Time__c = datetime.newInstance(testData.today,time.newInstance(9, 0, 0, 0));
        tseInstall.Start_Time_On_Site__c = tseInstall.Start_Time__c.addHours(1);
        tseInstall.Start_Time_Off_Site__c = tseInstall.Start_Time__c.addHours(9);
        tseInstall.End_Time__c = tseInstall.Start_Time__c.addHours(12);
        tseInstall.Purpose__c = 'Install';
        tseInstall.Timesheet_Purpose__c = testData.timesheetPurposeMap.get('Install');
        tseInstall.Project_Client_Job__c = testData.installProjectsNameIdMap.get('Install Project');
        tseInstall.Half_Hour_Lunch_Break__c = 'Yes';
        tseInstall.Approved__c = true;
        tseInstall.Time_Sheet__c = tsInstall.id;
        timeSheetEntries.add(tseInstall);

        Time_Sheet_Entry__c tseInstall2 = new Time_Sheet_Entry__c();
        tseInstall2.Start_Time__c = datetime.newInstance(testData.today,time.newInstance(9, 0, 0, 0));
        tseInstall2.Start_Time_On_Site__c = tseInstall.Start_Time__c.addHours(1);
        tseInstall2.Start_Time_Off_Site__c = tseInstall.Start_Time__c.addHours(9);
        tseInstall2.End_Time__c = tseInstall.Start_Time__c.addHours(12);
        tseInstall2.Purpose__c = 'Maintenance';
        tseInstall2.Timesheet_Purpose__c = testData.timesheetPurposeMap.get('Maintenance');
        tseInstall2.Project_Client_Job__c = testData.installProjectsNameIdMap.get('Install Project');
        tseInstall2.Half_Hour_Lunch_Break__c = 'Yes';
        tseInstall2.Approved__c = true;
        tseInstall2.Time_Sheet__c = tsInstall.id;
        timeSheetEntries.add(tseInstall2);
        
        insert timeSheetEntries;
        
        // Process the timesheet
        Test.startTest();
        
        tsInstall = [SELECT Id, Employee__r.Home_Office_Location__r.State__c,Employee__r.Name,Employee__r.Employee_Number__c 
                        FROM Time_Sheet__c LIMIT 1];
        List<TimeSheet_Payroll_Entry__c> payrollEntries = TimesheetService.ProcessTimesheets(tsInstall);

        // tsInstall is CA, so results in 3 entries
        system.assertEquals(3, payrollEntries.size());

        Test.stopTest();        
    }
    
    @isTest
    static void test_ProcessTimesheetsForMultipleEmployees() {
        if(!runalltests){ return; }

        AstrumTimeTestData testData = new AstrumTimeTestData();
        testData.PopulateTestData();

        List<Time_Sheet__c> timeSheets = new List<Time_Sheet__c>();
        
        Time_Sheet__c tsInstall = new Time_Sheet__c();
        tsInstall.Employee__c = testData.employeesNameIdMap.get('Test Installer');
        tsInstall.For_The_Week_Starting__c = testData.weekStart;
        timeSheets.add(tsInstall);
        
        Time_Sheet__c tsElec = new Time_Sheet__c();
        tsElec.Employee__c = testData.employeesNameIdMap.get('Test Electrician');
        tsElec.For_The_Week_Starting__c = testData.weekStart;
        timeSheets.add(tsElec);
        
        insert timeSheets;

        List<Time_Sheet_Entry__c> timeSheetEntries = new List<Time_Sheet_Entry__c>();
        
        Time_Sheet_Entry__c tseInstall = new Time_Sheet_Entry__c();
        tseInstall.Start_Time__c = datetime.newInstance(testData.today,time.newInstance(9, 0, 0, 0));
        tseInstall.Start_Time_On_Site__c = tseInstall.Start_Time__c.addHours(1);
        tseInstall.Start_Time_Off_Site__c = tseInstall.Start_Time__c.addHours(9);
        tseInstall.End_Time__c = tseInstall.Start_Time__c.addHours(12);
        tseInstall.Purpose__c = 'Install';
        tseInstall.Timesheet_Purpose__c = testData.timesheetPurposeMap.get('Install');
        tseInstall.Project_Client_Job__c = testData.installProjectsNameIdMap.get('Install Project');
        tseInstall.Half_Hour_Lunch_Break__c = 'Yes';
        tseInstall.Approved__c = true;
        tseInstall.Time_Sheet__c = tsInstall.id;
        timeSheetEntries.add(tseInstall);

        Time_Sheet_Entry__c tseInstall2 = new Time_Sheet_Entry__c();
        tseInstall2.Start_Time__c = datetime.newInstance(testData.today,time.newInstance(9, 0, 0, 0));
        tseInstall2.Start_Time_On_Site__c = tseInstall.Start_Time__c.addHours(1);
        tseInstall2.Start_Time_Off_Site__c = tseInstall.Start_Time__c.addHours(9);
        tseInstall2.End_Time__c = tseInstall.Start_Time__c.addHours(12);
        tseInstall2.Purpose__c = 'Maintenance';
        tseInstall2.Timesheet_Purpose__c = testData.timesheetPurposeMap.get('Maintenance');
        tseInstall2.Project_Client_Job__c = testData.installProjectsNameIdMap.get('Install Project');
        tseInstall2.Half_Hour_Lunch_Break__c = 'Yes';
        tseInstall2.Approved__c = true;
        tseInstall2.Time_Sheet__c = tsInstall.id;
        timeSheetEntries.add(tseInstall2);
        
        Time_Sheet_Entry__c tseElec = new Time_Sheet_Entry__c();
        tseElec.Start_Time__c = datetime.newInstance(testData.today,time.newInstance(9, 0, 0, 0));
        tseElec.Start_Time_On_Site__c = tseElec.Start_Time__c.addHours(1);
        tseElec.Start_Time_Off_Site__c = tseElec.Start_Time__c.addHours(9);
        tseElec.End_Time__c = tseElec.Start_Time__c.addHours(12);
        tseElec.Purpose__c = 'Install';
        tseElec.Timesheet_Purpose__c = testData.timesheetPurposeMap.get('Install');
        tseElec.Project_Client_Job__c = testData.installProjectsNameIdMap.get('Install Project');
        tseElec.Half_Hour_Lunch_Break__c = 'Yes';
        tseElec.Approved__c = true;
        tseElec.Time_Sheet__c = tsElec.id;
        timeSheetEntries.add(tseElec);

        Time_Sheet_Entry__c tseElec2 = new Time_Sheet_Entry__c();
        tseElec2.Start_Time__c = datetime.newInstance(testData.today,time.newInstance(9, 0, 0, 0));
        tseElec2.Start_Time_On_Site__c = tseElec.Start_Time__c.addHours(1);
        tseElec2.Start_Time_Off_Site__c = tseElec.Start_Time__c.addHours(9);
        tseElec2.End_Time__c = tseElec.Start_Time__c.addHours(12);
        tseElec2.Purpose__c = 'Maintenance';
        tseElec2.Timesheet_Purpose__c = testData.timesheetPurposeMap.get('Maintenance');
        tseElec2.Project_Client_Job__c = testData.installProjectsNameIdMap.get('Install Project');
        tseElec2.Half_Hour_Lunch_Break__c = 'Yes';
        tseElec2.Approved__c = true;
        tseElec2.Time_Sheet__c = tsElec.id;
        timeSheetEntries.add(tseElec2);
        
        insert timeSheetEntries;
        
        // Process the timesheets
        Test.startTest();

        Map<Id, Time_Sheet__c> timesheetsMap = new Map<Id, Time_Sheet__c>(
            [SELECT Id, Employee__r.Home_Office_Location__r.State__c,Employee__r.Name,Employee__r.Employee_Number__c 
                FROM Time_Sheet__c]);
        List<TimeSheet_Payroll_Entry__c> payrollEntries = TimesheetService.ProcessTimesheets(timesheetsMap);

        // tsInstall is CA, so results in 3 entries
        // tsElec is not CA, so results in only 4 entry
        system.assertEquals(4, payrollEntries.size());

        Test.stopTest();        
    }
    
    @isTest
    static void test_PostSingleTimesheet() {
        if(!runalltests){ return; }

        AstrumTimeTestData testData = new AstrumTimeTestData();
        testData.PopulateTestData();

        List<Time_Sheet__c> timeSheets = new List<Time_Sheet__c>();
        
        Time_Sheet__c tsInstall = new Time_Sheet__c();
        tsInstall.Employee__c = testData.employeesNameIdMap.get('Test Installer');
        tsInstall.For_The_Week_Starting__c = testData.weekStart;
        timeSheets.add(tsInstall);
        
        insert timeSheets;

        List<Time_Sheet_Entry__c> timeSheetEntries = new List<Time_Sheet_Entry__c>();
        
        Time_Sheet_Entry__c tseInstall = new Time_Sheet_Entry__c();
        tseInstall.Start_Time__c = datetime.newInstance(testData.today,time.newInstance(9, 0, 0, 0));
        tseInstall.Start_Time_On_Site__c = tseInstall.Start_Time__c.addHours(1);
        tseInstall.Start_Time_Off_Site__c = tseInstall.Start_Time__c.addHours(9);
        tseInstall.End_Time__c = tseInstall.Start_Time__c.addHours(12);
        tseInstall.Purpose__c = 'Install';
        tseInstall.Timesheet_Purpose__c = testData.timesheetPurposeMap.get('Install');
        tseInstall.Project_Client_Job__c = testData.installProjectsNameIdMap.get('Install Project');
        tseInstall.Half_Hour_Lunch_Break__c = 'Yes';
        tseInstall.Approved__c = true;
        tseInstall.Time_Sheet__c = tsInstall.id;
        timeSheetEntries.add(tseInstall);

        Time_Sheet_Entry__c tseInstall2 = new Time_Sheet_Entry__c();
        tseInstall2.Start_Time__c = datetime.newInstance(testData.today,time.newInstance(9, 0, 0, 0));
        tseInstall2.Start_Time_On_Site__c = tseInstall.Start_Time__c.addHours(1);
        tseInstall2.Start_Time_Off_Site__c = tseInstall.Start_Time__c.addHours(9);
        tseInstall2.End_Time__c = tseInstall.Start_Time__c.addHours(12);
        tseInstall2.Purpose__c = 'Maintenance';
        tseInstall2.Timesheet_Purpose__c = testData.timesheetPurposeMap.get('Maintenance');
        tseInstall2.Project_Client_Job__c = testData.installProjectsNameIdMap.get('Install Project');
        tseInstall2.Half_Hour_Lunch_Break__c = 'Yes';
        tseInstall2.Approved__c = true;
        tseInstall2.Time_Sheet__c = tsInstall.id;
        timeSheetEntries.add(tseInstall2);
        
        insert timeSheetEntries;
        
        // Process the timesheet
        Test.startTest();
        
        system.assertEquals(2, timeSheetEntries.size());
        tsInstall = [SELECT Id, Employee__r.Home_Office_Location__r.State__c,Employee__r.Name,Employee__r.Employee_Number__c 
                        FROM Time_Sheet__c LIMIT 1];
        List<TimeSheet_Payroll_Entry__c> payrollEntries = TimesheetService.ProcessTimesheets(tsInstall);
        TimesheetService.ProcessPost(tsInstall, payrollEntries);

        timeSheetEntries = [SELECT Id FROM Time_Sheet_Entry__c WHERE Posted__c = false];
        system.assertEquals(0, timeSheetEntries.size());

        Test.stopTest();        
    }
    
    @isTest
    static void test_PostTimesheetsForMutipleEmployees() {
        if(!runalltests){ return; }

        AstrumTimeTestData testData = new AstrumTimeTestData();
        testData.PopulateTestData();

        List<Time_Sheet__c> timeSheets = new List<Time_Sheet__c>();
        
        Time_Sheet__c tsInstall = new Time_Sheet__c();
        tsInstall.Employee__c = testData.employeesNameIdMap.get('Test Installer');
        tsInstall.For_The_Week_Starting__c = testData.weekStart;
        timeSheets.add(tsInstall);
        
        Time_Sheet__c tsElec = new Time_Sheet__c();
        tsElec.Employee__c = testData.employeesNameIdMap.get('Test Electrician');
        tsElec.For_The_Week_Starting__c = testData.weekStart;
        timeSheets.add(tsElec);
        
        insert timeSheets;

        List<Time_Sheet_Entry__c> timeSheetEntries = new List<Time_Sheet_Entry__c>();
        
        Time_Sheet_Entry__c tseInstall = new Time_Sheet_Entry__c();
        tseInstall.Start_Time__c = datetime.newInstance(testData.today,time.newInstance(9, 0, 0, 0));
        tseInstall.Start_Time_On_Site__c = tseInstall.Start_Time__c.addHours(1);
        tseInstall.Start_Time_Off_Site__c = tseInstall.Start_Time__c.addHours(9);
        tseInstall.End_Time__c = tseInstall.Start_Time__c.addHours(12);
        tseInstall.Purpose__c = 'Install';
        tseInstall.Timesheet_Purpose__c = testData.timesheetPurposeMap.get('Install');
        tseInstall.Project_Client_Job__c = testData.installProjectsNameIdMap.get('Install Project');
        tseInstall.Half_Hour_Lunch_Break__c = 'Yes';
        tseInstall.Approved__c = true;
        tseInstall.Time_Sheet__c = tsInstall.id;
        timeSheetEntries.add(tseInstall);

        Time_Sheet_Entry__c tseInstall2 = new Time_Sheet_Entry__c();
        tseInstall2.Start_Time__c = datetime.newInstance(testData.today,time.newInstance(9, 0, 0, 0));
        tseInstall2.Start_Time_On_Site__c = tseInstall.Start_Time__c.addHours(1);
        tseInstall2.Start_Time_Off_Site__c = tseInstall.Start_Time__c.addHours(9);
        tseInstall2.End_Time__c = tseInstall.Start_Time__c.addHours(12);
        tseInstall2.Purpose__c = 'Maintenance';
        tseInstall2.Timesheet_Purpose__c = testData.timesheetPurposeMap.get('Maintenance');
        tseInstall2.Project_Client_Job__c = testData.installProjectsNameIdMap.get('Install Project');
        tseInstall2.Half_Hour_Lunch_Break__c = 'Yes';
        tseInstall2.Approved__c = true;
        tseInstall2.Time_Sheet__c = tsInstall.id;
        timeSheetEntries.add(tseInstall2);
        
        Time_Sheet_Entry__c tseElec = new Time_Sheet_Entry__c();
        tseElec.Start_Time__c = datetime.newInstance(testData.today,time.newInstance(9, 0, 0, 0));
        tseElec.Start_Time_On_Site__c = tseElec.Start_Time__c.addHours(1);
        tseElec.Start_Time_Off_Site__c = tseElec.Start_Time__c.addHours(9);
        tseElec.End_Time__c = tseElec.Start_Time__c.addHours(12);
        tseElec.Purpose__c = 'Install';
        tseElec.Timesheet_Purpose__c = testData.timesheetPurposeMap.get('Install');
        tseElec.Project_Client_Job__c = testData.installProjectsNameIdMap.get('Install Project');
        tseElec.Half_Hour_Lunch_Break__c = 'Yes';
        tseElec.Approved__c = true;
        tseElec.Time_Sheet__c = tsElec.id;
        timeSheetEntries.add(tseElec);

        Time_Sheet_Entry__c tseElec2 = new Time_Sheet_Entry__c();
        tseElec2.Start_Time__c = datetime.newInstance(testData.today,time.newInstance(9, 0, 0, 0));
        tseElec2.Start_Time_On_Site__c = tseElec.Start_Time__c.addHours(1);
        tseElec2.Start_Time_Off_Site__c = tseElec.Start_Time__c.addHours(9);
        tseElec2.End_Time__c = tseElec.Start_Time__c.addHours(12);
        tseElec2.Purpose__c = 'Maintenance';
        tseElec2.Timesheet_Purpose__c = testData.timesheetPurposeMap.get('Maintenance');
        tseElec2.Project_Client_Job__c = testData.installProjectsNameIdMap.get('Install Project');
        tseElec2.Half_Hour_Lunch_Break__c = 'Yes';
        tseElec2.Approved__c = true;
        tseElec2.Time_Sheet__c = tsElec.id;
        timeSheetEntries.add(tseElec2);
        
        insert timeSheetEntries;
        
        // Process the timesheets
        Test.startTest();

        system.assertEquals(4, timeSheetEntries.size());
        Map<Id, Time_Sheet__c> timesheetsMap = new Map<Id, Time_Sheet__c>(
            [SELECT Id, Employee__r.Home_Office_Location__r.State__c,Employee__r.Name,Employee__r.Employee_Number__c 
                FROM Time_Sheet__c]);
        List<TimeSheet_Payroll_Entry__c> payrollEntries = TimesheetService.ProcessTimesheets(timesheetsMap);
        TimesheetService.ProcessPost(timesheetsMap, payrollEntries);

        timeSheetEntries = [SELECT Id FROM Time_Sheet_Entry__c WHERE Posted__c = false];
        system.assertEquals(0, timeSheetEntries.size());

        Test.stopTest();        
    }
}