/*
* MODIFICATION HISTORY:
*  07/03/2012 TCM - zen-26 Astrum Time update for Astrum PM 2.0
*  04/03/2015 SZ, Update code for Home_Office__c as a lookup from a picklist 
*  07/16/2015 PB FPO Phase2- Set active field on Office Location
*/

@isTest
private class AstrumTimeTests {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out

    private static Map<String,Id> createPurpose()
    {
        List<Timesheet_Purpose__c> tplist = new List<Timesheet_Purpose__c>();
        Map<String,Id>  tsMap = new  Map<String,Id>();
        Timesheet_Purpose__c tp = new Timesheet_Purpose__c();
        tp.Name = 'Install';
        tp.Applicable_Employee_class__c = 'Field Sales';
        tp.Active__c = true;
        tp.DE_Code__c = '9005';
        tp.Applicable_WO_Status__c = 'Open';
        tplist.add(tp);

        Timesheet_Purpose__c tp1 = new Timesheet_Purpose__c();
        tp1.Name = 'Install-Electric';
        tp1.Applicable_Employee_class__c = 'Field Sales';
        tp1.Active__c = true;
        tp1.DE_Code__c = '9005';
        tp1.Applicable_WO_Status__c = 'Open';
        tplist.add(tp1);

        Timesheet_Purpose__c tp2 = new Timesheet_Purpose__c();
        tp2.Name = 'Maintenance';
        tp2.Applicable_Employee_class__c = 'Field Sales';
        tp2.Active__c = true;
        tp2.DE_Code__c = '9005';
        tp2.Applicable_WO_Status__c = 'Open';
        tplist.add(tp2);

        insert tplist;

        tsMap.put('Install' , tp.Id);
        tsMap.put('Install-Electric', tp1.Id);
        tsMap.put('Maintenance', tp2.Id);

        return tsMap;
    }
    
    static testMethod void AstrumTimeModelTests() {
        if(!runalltests){ return; }

        // setup base project
        PM_Project__c pmProj = setupProject();
        
        // AstrumTIME Specific Tests
        Test.startTest();
        List<Office_Location__c> offices = new List<Office_Location__c>();

        Office_Location__c coronaOffice = new Office_Location__c(Name='Corona, CA', Street__c='123 Test St', City__c='Corona', State__c='CA', Zip_Code__c='10101', Active__c = true);
        offices.add(coronaOffice);

        Office_Location__c norristownOffice = new Office_Location__c(Name='Norristown, PA', Street__c='123 Test St', City__c='Norristown', State__c='PA', Zip_Code__c='12345', Active__c = true);
        offices.add(norristownOffice);

        insert offices;

        List<Employee__c> employees = new List<Employee__c>();
        
        Employee__c empInstall = new Employee__c(name='Test Installer', Department__c='Install', Job_Title__c='Solar Installer', Status__c='W-2', Home_Office_Location__c=coronaOffice.Id);
        employees.add(empInstall);
        
        Employee__c empInstallLead = new Employee__c(name='Test Install Lead', Department__c='Install', Job_Title__c='Lead Installer', Status__c='W-2', Home_Office_Location__c=coronaOffice.Id);
        employees.add(empInstallLead);
        
        Employee__c empElectric = new Employee__c(name='Test Electrician', Department__c='Electrical', Job_Title__c='Electrician', Status__c='W-2', Home_Office_Location__c=norristownOffice.Id);
        employees.add(empElectric);
        
        Employee__c empElectricLead = new Employee__c(name='Test Electrician Lead', Department__c='Electrical', Job_Title__c='Lead Electrician', Status__c='W-2', Home_Office_Location__c=norristownOffice.Id);
        employees.add(empElectricLead);
        
        insert employees;
        
        List<Install_Team__c> insertTeams = new List<Install_Team__c>();
        Install_Team__c inTeam = new Install_Team__c();
        inTeam.name = 'Installers Team';
        inTeam.Team_Lead__c = empInstallLead.id;
        insertTeams.add(inTeam);
        
        Install_Team__c elTeam = new Install_Team__c();
        elTeam.name = 'Electricians Team';
        elTeam.Team_Lead__c = empElectricLead.id;
        insertTeams.add(elTeam);
        insert insertTeams;
        
        List<Employee__c> updateEmployees = new List<Employee__c>();

        // add installers to install team        
        empInstall.Install_Team__c = inTeam.id;
        updateEmployees.add(empInstall);
        empInstallLead.Install_Team__c = inTeam.id;
        updateEmployees.add(empInstallLead);

        // add electricians to electricians team
        empElectric.Install_Team__c = elTeam.id;
        updateEmployees.add(empElectric);
        empElectricLead.Install_Team__c = elTeam.id;
        updateEmployees.add(empElectricLead);
        
        update updateEmployees;
        
        Install_Project__c instProj = new Install_Project__c();
        instProj.name = 'Install Project';
        instProj.PM_Project__c = pmProj.id;
        instProj.Installer_Team__c = inTeam.id;
        instProj.Electrician_Team__c = elTeam.id;
        instProj.Drive_Time_Office_To_Site__c = 1.0;
        instProj.Electrician_Drive_Time_To_Site__c = 1.0;
        
        insert instProj;
        
        PM_Project__c pmProj2 = setupProject();
        
         Install_Project__c instProj2 = new Install_Project__c();
        instProj2.name = 'Install Project 2';
        instProj2.PM_Project__c = pmProj2.id;
        instProj2.Installer_Team__c = inTeam.id;
        instProj2.Electrician_Team__c = elTeam.id;
        instProj2.Drive_Time_Office_To_Site__c = 1.0;
        instProj2.Electrician_Drive_Time_To_Site__c = 1.0;
        
        insert instProj2;
        
        Date myDate = date.today();
        Date weekStart = myDate.toStartofWeek()+1;
        
        List<Time_Sheet__c> timeSheets = new List<Time_Sheet__c>();
        
        Time_Sheet__c tsInstall = new Time_Sheet__c();
        tsInstall.Employee__c = empInstall.id;
        tsInstall.For_The_Week_Starting__c = weekStart;
        timeSheets.add(tsInstall);
        
        Time_Sheet__c tsInstallLead = new Time_Sheet__c();
        tsInstallLead.Employee__c = empInstallLead.id;
        tsInstallLead.For_The_Week_Starting__c = weekStart;
        timeSheets.add(tsInstallLead);
        
        Time_Sheet__c tsElectric = new Time_Sheet__c();
        tsElectric.Employee__c = empElectric.id;
        tsElectric.For_The_Week_Starting__c = weekStart;
        timeSheets.add(tsElectric);
        
        Time_Sheet__c tsElectricLead = new Time_Sheet__c();
        tsElectricLead.Employee__c = empElectricLead.id;
        tsElectricLead.For_The_Week_Starting__c = weekStart;
        timeSheets.add(tsElectricLead);
        
        insert timeSheets;

        Map<String,Id> tpMap = createPurpose();
        
        List<Time_Sheet_Entry__c> timeSheetEntries = new List<Time_Sheet_Entry__c>();
        
        Time_Sheet_Entry__c tseInstall = new Time_Sheet_Entry__c();
        tseInstall.Start_Time__c = datetime.newInstance(date.today(),time.newInstance(9, 0, 0, 0));
        tseInstall.Start_Time_On_Site__c = tseInstall.Start_Time__c.addHours(1);
        tseInstall.Start_Time_Off_Site__c = tseInstall.Start_Time__c.addHours(9);
        tseInstall.End_Time__c = tseInstall.Start_Time__c.addHours(12);
        tseInstall.Purpose__c = 'Install';
        tseInstall.Timesheet_Purpose__c = tpMap.get('Install');
        tseInstall.Project_Client_Job__c = instProj.id;
        tseInstall.Half_Hour_Lunch_Break__c = 'Yes';
        tseInstall.Time_Sheet__c = tsInstall.id;
        timeSheetEntries.add(tseInstall);
        
        Time_Sheet_Entry__c tseInstallLead = new Time_Sheet_Entry__c();
        tseInstallLead.Start_Time__c = datetime.newInstance(date.today(),time.newInstance(9, 0, 0, 0));
        tseInstallLead.Start_Time_On_Site__c = tseInstallLead.Start_Time__c.addHours(1);
        tseInstallLead.Start_Time_Off_Site__c = tseInstallLead.Start_Time__c.addHours(9);
        tseInstallLead.End_Time__c = tseInstallLead.Start_Time__c.addHours(12);
        tseInstallLead.Purpose__c = 'Install';
        tseInstallLead.Timesheet_Purpose__c = tpMap.get('Install');
        tseInstallLead.Project_Client_Job__c = instProj.id;
        tseInstallLead.Half_Hour_Lunch_Break__c = 'Yes';
        tseInstallLead.Time_Sheet__c = tsInstallLead.id;
        timeSheetEntries.add(tseInstallLead);
        
        Time_Sheet_Entry__c tseElectric = new Time_Sheet_Entry__c();
        tseElectric.Start_Time__c = datetime.newInstance(date.today(),time.newInstance(9, 0, 0, 0));
        tseElectric.Start_Time_On_Site__c = tseElectric.Start_Time__c.addHours(1);
        tseElectric.Start_Time_Off_Site__c = tseElectric.Start_Time__c.addHours(9);
        tseElectric.End_Time__c = tseElectric.Start_Time__c.addHours(12);
        tseElectric.Purpose__c = 'Install';
        tseElectric.Timesheet_Purpose__c = tpMap.get('Install');
        tseElectric.Project_Client_Job__c = instProj.id;
        tseElectric.Half_Hour_Lunch_Break__c = 'Yes';
        tseElectric.Time_Sheet__c = tsElectric.id;
        timeSheetEntries.add(tseElectric);
        
        Time_Sheet_Entry__c tseElectricLead = new Time_Sheet_Entry__c();
        tseElectricLead.Start_Time__c = datetime.newInstance(date.today(),time.newInstance(9, 0, 0, 0));
        tseElectricLead.Start_Time_On_Site__c = tseElectricLead.Start_Time__c.addHours(1);
        tseElectricLead.Start_Time_Off_Site__c = tseElectricLead.Start_Time__c.addHours(9);
        tseElectricLead.End_Time__c = tseElectricLead.Start_Time__c.addHours(12);
        tseElectricLead.Purpose__c = 'Install';
        tseElectricLead.Timesheet_Purpose__c = tpMap.get('Install');
        tseElectricLead.Project_Client_Job__c = instProj.id;
        tseElectricLead.Half_Hour_Lunch_Break__c = 'Yes';
        tseElectricLead.Time_Sheet__c = tsElectricLead.id;
        timeSheetEntries.add(tseElectricLead);
        
        Time_Sheet_Entry__c tseInstall2 = new Time_Sheet_Entry__c();
        tseInstall2.Start_Time__c = datetime.newInstance(date.today(),time.newInstance(9, 0, 0, 0));
        tseInstall2.Start_Time_On_Site__c = tseInstall.Start_Time__c.addHours(1);
        tseInstall2.Start_Time_Off_Site__c = tseInstall.Start_Time__c.addHours(9);
        tseInstall2.End_Time__c = tseInstall.Start_Time__c.addHours(12);
        tseInstall2.Purpose__c = 'Maintenance';
        tseInstall2.Timesheet_Purpose__c = tpMap.get('Maintenance');
        tseInstall2.Project_Client_Job__c = instProj.id;
        tseInstall2.Half_Hour_Lunch_Break__c = 'Yes';
        tseInstall2.Time_Sheet__c = tsInstall.id;
        timeSheetEntries.add(tseInstall2);
        
        Time_Sheet_Entry__c tseInstallLead2 = new Time_Sheet_Entry__c();
        tseInstallLead2.Start_Time__c = datetime.newInstance(date.today(),time.newInstance(9, 0, 0, 0));
        tseInstallLead2.Start_Time_On_Site__c = tseInstallLead.Start_Time__c.addHours(1);
        tseInstallLead2.Start_Time_Off_Site__c = tseInstallLead.Start_Time__c.addHours(9);
        tseInstallLead2.End_Time__c = tseInstallLead.Start_Time__c.addHours(12);
        tseInstallLead2.Purpose__c = 'Maintenance';
        tseInstallLead2.Timesheet_Purpose__c = tpMap.get('Maintenance');
        tseInstallLead2.Project_Client_Job__c = instProj.id;
        tseInstallLead2.Half_Hour_Lunch_Break__c = 'Yes';
        tseInstallLead2.Time_Sheet__c = tsInstallLead.id;
        timeSheetEntries.add(tseInstallLead2);
        
        Time_Sheet_Entry__c tseElectric2 = new Time_Sheet_Entry__c();
        tseElectric2.Start_Time__c = datetime.newInstance(date.today(),time.newInstance(9, 0, 0, 0));
        tseElectric2.Start_Time_On_Site__c = tseElectric.Start_Time__c.addHours(1);
        tseElectric2.Start_Time_Off_Site__c = tseElectric.Start_Time__c.addHours(9);
        tseElectric2.End_Time__c = tseElectric.Start_Time__c.addHours(12);
        tseElectric2.Purpose__c = 'Maintenance';
        tseElectric2.Timesheet_Purpose__c = tpMap.get('Maintenance');
        tseElectric2.Project_Client_Job__c = instProj.id;
        tseElectric2.Half_Hour_Lunch_Break__c = 'Yes';
        tseElectric2.Time_Sheet__c = tsElectric.id;
        timeSheetEntries.add(tseElectric2);
        
        Time_Sheet_Entry__c tseElectricLead2 = new Time_Sheet_Entry__c();
        tseElectricLead2.Start_Time__c = datetime.newInstance(date.today(),time.newInstance(9, 0, 0, 0));
        tseElectricLead2.Start_Time_On_Site__c = tseElectricLead.Start_Time__c.addHours(1);
        tseElectricLead2.Start_Time_Off_Site__c = tseElectricLead.Start_Time__c.addHours(9);
        tseElectricLead2.End_Time__c = tseElectricLead.Start_Time__c.addHours(12);
        tseElectricLead2.Purpose__c = 'Maintenance';
        tseElectricLead2.Timesheet_Purpose__c = tpMap.get('Maintenance');
        tseElectricLead2.Project_Client_Job__c = instProj.id;
        tseElectricLead2.Half_Hour_Lunch_Break__c = 'Yes';
        tseElectricLead2.Time_Sheet__c = tsElectricLead.id;
        timeSheetEntries.add(tseElectricLead2);
        
        insert timeSheetEntries;
        
        tseElectric.Project_Client_Job__c = instProj2.id;
        
        update tseElectric;
        
        Test.stopTest();        
   }
   
    public static testMethod void testComputeTotals_SingleTimeSheet_SingleTimeSheetEntry_NoOvertime() {
        if(!runalltests){ return; }

        // setup base project
        PM_Project__c pmProj = setupProject();
        
        // AstrumTIME Specific Tests
        Test.startTest();
        List<Office_Location__c> offices = new List<Office_Location__c>();

        Office_Location__c coronaOffice = new Office_Location__c(Name='Corona, CA', Street__c='123 Test St', City__c='Corona', State__c='CA', Zip_Code__c='10101', Active__c = true);
        offices.add(coronaOffice);

        Office_Location__c norristownOffice = new Office_Location__c(Name='Norristown, PA', Street__c='123 Test St', City__c='Norristown', State__c='PA', Zip_Code__c='12345', Active__c = true);
        offices.add(norristownOffice);

        insert offices;

        List<Employee__c> employees = new List<Employee__c>();
        
        Employee__c empInstall = new Employee__c(name='Test Installer', Department__c='Install', Job_Title__c='Solar Installer', Status__c='W-2', Home_Office_Location__c=coronaOffice.Id);
        employees.add(empInstall);
        
        Employee__c empInstallLead = new Employee__c(name='Test Install Lead', Department__c='Install', Job_Title__c='Lead Installer', Status__c='W-2', Home_Office_Location__c=coronaOffice.Id);
        employees.add(empInstallLead);
        
        insert employees;
        
        List<Install_Team__c> insertTeams = new List<Install_Team__c>();
        Install_Team__c inTeam = new Install_Team__c();
        inTeam.name = 'Installers Team';
        inTeam.Team_Lead__c = empInstallLead.id;
        insertTeams.add(inTeam);        
        insert insertTeams;
        
        List<Employee__c> updateEmployees = new List<Employee__c>();

        // add installers to install team        
        empInstall.Install_Team__c = inTeam.id;
        updateEmployees.add(empInstall);
        empInstallLead.Install_Team__c = inTeam.id;
        updateEmployees.add(empInstallLead);
        update updateEmployees;
        
        Install_Project__c instProj = new Install_Project__c();
        instProj.name = 'Install Project';
        instProj.PM_Project__c = pmProj.id;
        instProj.Installer_Team__c = inTeam.id;
        instProj.Drive_Time_Office_To_Site__c = 1.0;
        instProj.Electrician_Drive_Time_To_Site__c = 1.0;
        insert instProj;

        Map<String,Id> tpMap = createPurpose();
        
        Date myDate = date.today();
        Date weekStart = myDate.toStartofWeek()+1;
        
        List<Time_Sheet__c> timeSheets = new List<Time_Sheet__c>();
        
        Time_Sheet__c tsInstall = new Time_Sheet__c();
        tsInstall.Employee__c = empInstall.id;
        tsInstall.For_The_Week_Starting__c = weekStart;
        timeSheets.add(tsInstall);
        
        Time_Sheet__c tsInstallLead = new Time_Sheet__c();
        tsInstallLead.Employee__c = empInstallLead.id;
        tsInstallLead.For_The_Week_Starting__c = weekStart;
        timeSheets.add(tsInstallLead);
        
        insert timeSheets;
        
        List<Time_Sheet_Entry__c> timeSheetEntries = new List<Time_Sheet_Entry__c>();
        
        Time_Sheet_Entry__c tseInstall = new Time_Sheet_Entry__c();
        tseInstall.Start_Time__c = datetime.newInstance(date.today(),time.newInstance(9, 0, 0, 0));
        tseInstall.Start_Time_On_Site__c = tseInstall.Start_Time__c.addHours(1);
        tseInstall.Purpose__c = 'Install';
        tseInstall.Timesheet_Purpose__c = tpMap.get('Install');
        tseInstall.Project_Client_Job__c = instProj.id;
        tseInstall.Half_Hour_Lunch_Break__c = 'Yes';
        tseInstall.Time_Sheet__c = tsInstall.id;
        timeSheetEntries.add(tseInstall);
                        
        insert timeSheetEntries;

        tseInstall.End_Time__c = tseInstall.Start_Time__c.addHours(12);
        tseInstall.Start_Time_Off_Site__c = tseInstall.Start_Time__c.addHours(9);
        update timeSheetEntries;
        
        //
        // assert timesheet values
        // 
        Double expectedWeeklyTotalHours = 11.5;
        Double expectedWeeklyOvertimeHours = 0;
        Double expectedWeeklyStandardHours = 11.5;
        Double expectedWeeklyTotalHoursWorked = expectedWeeklyOvertimeHours + expectedWeeklyStandardHours;
        
        Time_Sheet__c actualTsInstall = [Select t.Weekly_Total_Hours__c, t.Weekly_Standard_Hours__c, t.Weekly_Overtime_Hours__c, t.Weekly_Hours_Worked__c, t.Weekly_Hotel_Costs__c 
                                         From Time_Sheet__c t 
                                         where t.id = :tsInstall.id limit 1];
        
        System.assertEquals(expectedWeeklyTotalHours, actualTsInstall.Weekly_Total_Hours__c);
        System.assertEquals(expectedWeeklyOvertimeHours, actualTsInstall.Weekly_Overtime_Hours__c);
        System.assertEquals(expectedWeeklyStandardHours, actualTsInstall.Weekly_Standard_Hours__c);
        System.assertEquals(expectedWeeklyTotalHoursWorked, actualTsInstall.Weekly_Hours_Worked__c);
        
        //
        // assert install project values
        //
         Double expectedTotalMaintenanceHours = 0;
        Double expectedTotalInstallationHours = 11.5;
        Double expectedTotalHotelCosts = 0;
        
        Double expectedInstallerOvertimeHours = null;
        Double expectedInstallerInstallHours = 11.5;
        Double expectedInstallerHotelCosts = 0;

        Double expectedElectricianOvertimeHours = null;
        Double expectedElectricianInstallHours = 0;
        Double expectedElectricianHotelCosts = 0;
        
        Install_Project__c actualInstProj = [Select i.Total_Maintenance_Hours__c, i.Total_Installation_Hours__c, i.Total_Hotel_Costs__c,         
                                                    i.Installer_Overtime_Hours__c, i.Installer_Install_Hours__c, i.Installer_Hotel_Costs__c, 
                                                    i.Electrician_Overtime_Hours__c, i.Electrician_Install_Hours__c, i.Electrician_Hotel_Costs__c 
                                             From Install_Project__c i 
                                             where id = :instProj.id limit 1];
        
        System.assertEquals(expectedInstallerOvertimeHours, actualInstProj.Installer_Overtime_Hours__c);
        System.assertEquals(expectedInstallerInstallHours, actualInstProj.Installer_Install_Hours__c);
        System.assertEquals(expectedInstallerHotelCosts, actualInstProj.Installer_Hotel_Costs__c);
        
        System.assertEquals(expectedElectricianOvertimeHours, actualInstProj.Electrician_Overtime_Hours__c);
        System.assertEquals(expectedElectricianInstallHours, actualInstProj.Electrician_Install_Hours__c);
        System.assertEquals(expectedElectricianHotelCosts, actualInstProj.Electrician_Hotel_Costs__c);
        
        Test.stopTest();   
    }

    public static testMethod void testComputeTotals_SingleTimeSheet_SingleTimeSheetEntry_NoOvertime_MaintenanceHours_Install_and_Electrician() {
        if(!runalltests){ return; }

        // setup base project
        PM_Project__c pmProj = setupProject();
        
        // AstrumTIME Specific Tests
        Test.startTest();
        Office_Location__c coronaOffice = new Office_Location__c(Name='Corona, CA', Street__c='123 Test St', City__c='Corona', State__c='CA', Zip_Code__c='10101', Active__c = true);
        insert coronaOffice;

        List<Employee__c> employees = new List<Employee__c>();

        Employee__c empElec = new Employee__c(name='Test Electrician', Department__c='Electrical', Job_Title__c='Electrician', Status__c='W-2', Home_Office_Location__c=coronaOffice.Id);
        employees.add(empElec);

        Employee__c empElecLead = new Employee__c(name='Test Electrical Lead', Department__c='Electrical', Job_Title__c='Lead Electrician', Status__c='W-2', Home_Office_Location__c=coronaOffice.Id);
        employees.add(empElecLead);
        
        insert employees;
        
        List<Install_Team__c> insertTeams = new List<Install_Team__c>();
        Install_Team__c inTeam = new Install_Team__c();
        inTeam.name = 'Install Team';
        inTeam.Team_Lead__c = empElecLead.id;
        insertTeams.add(inTeam);        
        insert insertTeams;

        Map<String,Id> tpMap = createPurpose();
        
        List<Employee__c> updateEmployees = new List<Employee__c>();

        // add electrician to install team        
        empElecLead.Install_Team__c = inTeam.id;
        updateEmployees.add(empElecLead);

        empElec.Install_Team__c = inTeam.id;
        updateEmployees.add(empElec);

        update updateEmployees;
        
        Install_Project__c instProj = new Install_Project__c();
        instProj.name = 'Install Project';
        instProj.PM_Project__c = pmProj.id;
        instProj.Installer_Team__c = inTeam.id;
        instProj.Drive_Time_Office_To_Site__c = 1.0;
        instProj.Electrician_Drive_Time_To_Site__c = 1.0;
        //instProj.Complete__c = true;
        //instProj.Date_Completed__c = Date.today().addDays(-45);  // to handle for post30
        
        insert instProj;
        
        pmProj.Work_Completed__c = Date.today().addDays(-45);
        update pmProj;
        
        Date myDate = date.today();
        Date weekStart = myDate.toStartofWeek()+1;
        
        
        List<Time_Sheet__c> timeSheets = new List<Time_Sheet__c>();
        
        Time_Sheet__c tsInstall = new Time_Sheet__c();
        tsInstall.Employee__c = empElec.id;
        tsInstall.For_The_Week_Starting__c = weekStart;
        timeSheets.add(tsInstall);
        
        Time_Sheet__c tsInstallLead = new Time_Sheet__c();
        tsInstallLead.Employee__c = empElecLead.id;
        tsInstallLead.For_The_Week_Starting__c = weekStart;
        timeSheets.add(tsInstallLead);
        
        insert timeSheets;
        
        List<Time_Sheet_Entry__c> timeSheetEntries = new List<Time_Sheet_Entry__c>();
        
        Time_Sheet_Entry__c tseInstall = new Time_Sheet_Entry__c();
        tseInstall.Start_Time__c = datetime.newInstance(myDate,time.newInstance(9, 0, 0, 0));
        tseInstall.Start_Time_On_Site__c = tseInstall.Start_Time__c.addHours(1);
        tseInstall.Purpose__c = 'Maintenance';
        tseInstall.Timesheet_Purpose__c = tpMap.get('Maintenance');
        tseInstall.Project_Client_Job__c = instProj.id;
        tseInstall.Half_Hour_Lunch_Break__c = 'Yes';
        tseInstall.Time_Sheet__c = tsInstall.id;
        timeSheetEntries.add(tseInstall);
                        
        insert timeSheetEntries;

        tseInstall.End_Time__c = tseInstall.Start_Time__c.addHours(12);
        tseInstall.Start_Time_Off_Site__c = tseInstall.Start_Time__c.addHours(9);
        update timeSheetEntries;
        
        //
        // assert install project values
        //
        Double expectedTotalMaintenanceHours = 11.5;
        Double expectedTotalInstallationHours = 0;
        Double expectedTotalHotelCosts = 0;
        
        Double expectedInstallerMaintHours = expectedTotalMaintenanceHours / 2;
        Double expectedElectricianMaintHours = expectedTotalMaintenanceHours / 2;
        
        Install_Project__c actualInstProj = [Select i.Total_Maintenance_Hours__c, 
                                                    Installer_Post30_Maintenance_Hours__c,  Electrician_Post30_Maintenance_Hours__c
                                             From Install_Project__c i 
                                             where id = :instProj.id limit 1];

        System.debug('AstrumTIME test: Maintenance Hrs: Installer: ' + actualInstProj.Installer_Post30_Maintenance_Hours__c + '  Electrician: ' + actualInstProj.Electrician_Post30_Maintenance_Hours__c);
        System.assertEquals(expectedTotalMaintenanceHours, actualInstProj.Total_Maintenance_Hours__c);
        System.assertEquals(expectedInstallerMaintHours, actualInstProj.Installer_Post30_Maintenance_Hours__c);
        System.assertEquals(expectedElectricianMaintHours, actualInstProj.Electrician_Post30_Maintenance_Hours__c);
        
        Test.stopTest();   
    }

    
    
    public static testMethod void testComputeTotals_SingleTimeSheet_MultipleTimeSheetEntries_WithOvertime() {
        if(!runalltests){ return; }

        // setup base project
        PM_Project__c pmProj = setupProject();
        
        // AstrumTIME Specific Tests
        Test.startTest();
        Office_Location__c coronaOffice = new Office_Location__c(Name='Corona, CA', Street__c='123 Test St', City__c='Corona', State__c='CA', Zip_Code__c='10101', Active__c = true);
        insert coronaOffice;

        List<Employee__c> employees = new List<Employee__c>();
        
        Employee__c empInstall = new Employee__c(name='Test Installer', Department__c='Install', Job_Title__c='Solar Installer', Status__c='W-2', Home_Office_Location__c=coronaOffice.Id);
        employees.add(empInstall);
        
        Employee__c empInstallLead = new Employee__c(name='Test Install Lead', Department__c='Install', Job_Title__c='Lead Installer', Status__c='W-2', Home_Office_Location__c=coronaOffice.Id);
        employees.add(empInstallLead);
        
        insert employees;
        
        List<Install_Team__c> insertTeams = new List<Install_Team__c>();
        Install_Team__c inTeam = new Install_Team__c();
        inTeam.name = 'Installers Team';
        inTeam.Team_Lead__c = empInstallLead.id;
        insertTeams.add(inTeam);        
        insert insertTeams;
        
        List<Employee__c> updateEmployees = new List<Employee__c>();

        // add installers to install team        
        empInstall.Install_Team__c = inTeam.id;
        updateEmployees.add(empInstall);
        empInstallLead.Install_Team__c = inTeam.id;
        updateEmployees.add(empInstallLead);
        update updateEmployees;
        
        Install_Project__c instProj = new Install_Project__c();
        instProj.name = 'Install Project';
        instProj.PM_Project__c = pmProj.id;
        instProj.Installer_Team__c = inTeam.id;
        instProj.Drive_Time_Office_To_Site__c = 1.0;
        instProj.Electrician_Drive_Time_To_Site__c = 1.0;
        insert instProj;
        
        Date myDate = date.today();
        Date weekStart = myDate.toStartofWeek()+1;
        
        List<Time_Sheet__c> timeSheets = new List<Time_Sheet__c>();
        
        Time_Sheet__c tsInstall = new Time_Sheet__c();
        tsInstall.Employee__c = empInstall.id;
        tsInstall.For_The_Week_Starting__c = weekStart;
        timeSheets.add(tsInstall);
        
        Time_Sheet__c tsInstallLead = new Time_Sheet__c();
        tsInstallLead.Employee__c = empInstallLead.id;
        tsInstallLead.For_The_Week_Starting__c = weekStart;
        timeSheets.add(tsInstallLead);
        
        insert timeSheets;
        
        List<Time_Sheet_Entry__c> timeSheetEntries = new List<Time_Sheet_Entry__c>();

        Map<String,Id> tpMap = createPurpose();
        
        // add timesheet entries
        for (Integer i=1; i <= 5; i++) {
            Date theDate = weekStart.addDays(i);
            Integer numberOfHours = 12;
            Id purpose = tpMap.get('Install');
            Time_Sheet_Entry__c tseInstall = clockInEntry(tsInstall.id, instProj.id, theDate, purpose);  
            timeSheetEntries.add(tseInstall);
        }                
        insert timeSheetEntries;
        
        for (Integer i=0; i <= timeSheetEntries.size()-1; i++) {
            Integer numberOfHours = 12;
            clockOutEntry(timeSheetEntries[i], numberOfHours, 0);  
        }                
        update timeSheetEntries;
        
        //
         //
        // assert timesheet values
        // 
        Double expectedWeeklyTotalHours = 57.5;
        Double expectedWeeklyStandardHours = 40.0;
        Double expectedWeeklyOvertimeHours = expectedWeeklyTotalHours - expectedWeeklyStandardHours;
        Double expectedWeeklyTotalHoursWorked = expectedWeeklyOvertimeHours + expectedWeeklyStandardHours;
        
        Time_Sheet__c actualTsInstall = [Select t.Weekly_Total_Hours__c, t.Weekly_Standard_Hours__c, t.Weekly_Overtime_Hours__c, t.Weekly_Hours_Worked__c, t.Weekly_Hotel_Costs__c 
                                         From Time_Sheet__c t 
                                         where t.id = :tsInstall.id limit 1];
        
        System.assertEquals(expectedWeeklyTotalHours, actualTsInstall.Weekly_Total_Hours__c);
        System.assertEquals(expectedWeeklyOvertimeHours, actualTsInstall.Weekly_Overtime_Hours__c);
        System.assertEquals(expectedWeeklyStandardHours, actualTsInstall.Weekly_Standard_Hours__c);
        System.assertEquals(expectedWeeklyTotalHoursWorked, actualTsInstall.Weekly_Hours_Worked__c);
        
        //
        // assert install project values
        //
        Double expectedTotalMaintenanceHours = 0;
        Double expectedTotalInstallationHours = 11.5;
        Double expectedTotalHotelCosts = 0;
        
        Double expectedInstallerOvertimeHours = expectedWeeklyTotalHours - expectedWeeklyStandardHours;
        Double expectedInstallerInstallHours = expectedWeeklyTotalHours;
        Double expectedInstallerHotelCosts = 0;

        Double expectedElectricianOvertimeHours = null;
        Double expectedElectricianInstallHours = 0;
        Double expectedElectricianHotelCosts = 0;
        
        Install_Project__c actualInstProj = [Select i.Total_Maintenance_Hours__c, i.Total_Installation_Hours__c, i.Total_Hotel_Costs__c,         
                                                    i.Installer_Overtime_Hours__c, i.Installer_Install_Hours__c, i.Installer_Hotel_Costs__c, 
                                                    i.Electrician_Overtime_Hours__c, i.Electrician_Install_Hours__c, i.Electrician_Hotel_Costs__c 
                                             From Install_Project__c i 
                                             where id = :instProj.id limit 1];
        
        System.assertEquals(expectedInstallerOvertimeHours, actualInstProj.Installer_Overtime_Hours__c);
        System.assertEquals(expectedInstallerInstallHours, actualInstProj.Installer_Install_Hours__c);
        System.assertEquals(expectedInstallerHotelCosts, actualInstProj.Installer_Hotel_Costs__c);
        
        System.assertEquals(expectedElectricianOvertimeHours, actualInstProj.Electrician_Overtime_Hours__c);
        System.assertEquals(expectedElectricianInstallHours, actualInstProj.Electrician_Install_Hours__c);
        System.assertEquals(expectedElectricianHotelCosts, actualInstProj.Electrician_Hotel_Costs__c);
        
        Test.stopTest();   
    }
    
    public static testMethod void testComputeTotals_SingleTimeSheet_MultipleTimeSheetEntries_WithOvertime_Install_Electrical() {
        if(!runalltests){ return; }

        // setup base project
        PM_Project__c pmProj = setupProject();
        
        // AstrumTIME Specific Tests
        Test.startTest();
        Office_Location__c coronaOffice = new Office_Location__c(Name='Corona, CA', Street__c='123 Test St', City__c='Corona', State__c='CA', Zip_Code__c='10101', Active__c = true);
        insert coronaOffice;

        List<Employee__c> employees = new List<Employee__c>();
        
        Employee__c emp = new Employee__c(name='Test Electrician', Department__c='Electrical', Job_Title__c='Electrician', Status__c='W-2', Home_Office_Location__c=coronaOffice.Id);
        employees.add(emp);
        
        Employee__c empLead = new Employee__c(name='Test Electrician Lead', Department__c='Electrical', Job_Title__c='Lead Electrician', Status__c='W-2', Home_Office_Location__c=coronaOffice.Id);
        employees.add(empLead);
        
        insert employees;
        
        List<Install_Team__c> insertTeams = new List<Install_Team__c>();
        Install_Team__c inTeam = new Install_Team__c();
        inTeam.name = 'Electrical Team';
        inTeam.Team_Lead__c = empLead.id;
        insertTeams.add(inTeam);        
        insert insertTeams;
        
        List<Employee__c> updateEmployees = new List<Employee__c>();

        // add installers to install team        
        emp.Install_Team__c = inTeam.id;
        updateEmployees.add(emp);
        empLead.Install_Team__c = inTeam.id;
        updateEmployees.add(empLead);
        update updateEmployees;
        
        Install_Project__c instProj = new Install_Project__c();
        instProj.name = 'Install Project';
        instProj.PM_Project__c = pmProj.id;
        instProj.Installer_Team__c = inTeam.id;
        instProj.Drive_Time_Office_To_Site__c = 1.0;
        instProj.Electrician_Drive_Time_To_Site__c = 1.0;
        insert instProj;
        
        Date myDate = date.today();
        Date weekStart = myDate.toStartofWeek()+1;
        
        List<Time_Sheet__c> timeSheets = new List<Time_Sheet__c>();
        
        Time_Sheet__c timesheet = new Time_Sheet__c();
        timesheet.Employee__c = emp.id;
        timesheet.For_The_Week_Starting__c = weekStart;
        timeSheets.add(timesheet);
        
        Time_Sheet__c timesheetLead = new Time_Sheet__c();
        timesheetLead.Employee__c = empLead.id;
        timesheetLead.For_The_Week_Starting__c = weekStart;
        timeSheets.add(timesheetLead);
        
        insert timeSheets;
        
        List<Time_Sheet_Entry__c> timeSheetEntries = new List<Time_Sheet_Entry__c>();

        Map<String,Id> tpMap = createPurpose();
        
        // add timesheet entries
        for (Integer i=1; i <= 5; i++) {
            Date theDate = weekStart.addDays(i);
            Integer numberOfHours = 12;
            Id purpose = tpMap.get('Install-Electric');
            Time_Sheet_Entry__c tseInstall = clockInEntry(timesheet.id, instProj.id, theDate, purpose);  
            timeSheetEntries.add(tseInstall);
        }                
        insert timeSheetEntries;
        
        for (Integer i=0; i <= timeSheetEntries.size()-1; i++) {
            Integer numberOfHours = 12;
            clockOutEntry(timeSheetEntries[i], numberOfHours, 0);  
        }                
        update timeSheetEntries;
        
        //
        // assert timesheet values
        // 
        Double expectedWeeklyTotalHours = 57.5;
        Double expectedWeeklyStandardHours = 40.0;
        Double expectedWeeklyOvertimeHours = expectedWeeklyTotalHours - expectedWeeklyStandardHours;
        Double expectedWeeklyTotalHoursWorked = expectedWeeklyOvertimeHours + expectedWeeklyStandardHours;
        
        Time_Sheet__c actualtimesheet = [Select t.Weekly_Total_Hours__c, t.Weekly_Standard_Hours__c, t.Weekly_Overtime_Hours__c, t.Weekly_Hours_Worked__c, t.Weekly_Hotel_Costs__c 
                                         From Time_Sheet__c t 
                                         where t.id = :timesheet.id limit 1];
        
        System.assertEquals(expectedWeeklyTotalHours, actualtimesheet.Weekly_Total_Hours__c);
        System.assertEquals(expectedWeeklyOvertimeHours, actualtimesheet.Weekly_Overtime_Hours__c);
        System.assertEquals(expectedWeeklyStandardHours, actualtimesheet.Weekly_Standard_Hours__c);
        System.assertEquals(expectedWeeklyTotalHoursWorked, actualtimesheet.Weekly_Hours_Worked__c);
        
        //
        // assert install project values
        //
        Double expectedTotalMaintenanceHours = 0;
        Double expectedTotalInstallationHours = 11.5;
        Double expectedTotalHotelCosts = 0;
        
        Double expectedInstallerOvertimeHours = null;
        Double expectedInstallerInstallHours = 0;
        Double expectedInstallerHotelCosts = 0;

        Double expectedElectricianOvertimeHours = expectedWeeklyTotalHours - expectedWeeklyStandardHours;
        Double expectedElectricianInstallHours = expectedWeeklyTotalHours;
        Double expectedElectricianHotelCosts = 0;
        
        Install_Project__c actualInstProj = [Select i.Total_Maintenance_Hours__c, i.Total_Installation_Hours__c, i.Total_Hotel_Costs__c,         
                                                    i.Installer_Overtime_Hours__c, i.Installer_Install_Hours__c, i.Installer_Hotel_Costs__c, 
                                                    i.Electrician_Overtime_Hours__c, i.Electrician_Install_Hours__c, i.Electrician_Hotel_Costs__c 
                                             From Install_Project__c i 
                                             where id = :instProj.id limit 1];
        
        System.assertEquals(expectedInstallerOvertimeHours, actualInstProj.Installer_Overtime_Hours__c);
        System.assertEquals(expectedInstallerInstallHours, actualInstProj.Installer_Install_Hours__c);
        System.assertEquals(expectedInstallerHotelCosts, actualInstProj.Installer_Hotel_Costs__c);
        
        System.assertEquals(expectedElectricianOvertimeHours, actualInstProj.Electrician_Overtime_Hours__c);
        System.assertEquals(expectedElectricianInstallHours, actualInstProj.Electrician_Install_Hours__c);
        System.assertEquals(expectedElectricianHotelCosts, actualInstProj.Electrician_Hotel_Costs__c);
        
        Test.stopTest();   
    }
        
  public static testMethod void testComputeInstallerInstallPay_SingleInstaller_NoOvertime() {
        if(!runalltests){ return; }

        Decimal hourlyRate = 20.00;
        
        // setup base project
        PM_Project__c pmProj = setupProject();

        Test.startTest();   
        
        // AstrumTIME Specific Tests
        Office_Location__c coronaOffice = new Office_Location__c(Name='Corona, CA', Street__c='123 Test St', City__c='Corona', State__c='CA', Zip_Code__c='10101', Active__c = true);
        insert coronaOffice;

        List<Employee__c> employees = new List<Employee__c>();
        
        Employee__c emp = new Employee__c(name='Test Installer', Department__c='Install', Job_Title__c='Solar Installer', Status__c='W-2', Hourly_Rate__c=hourlyRate, Home_Office_Location__c=coronaOffice.Id);
        employees.add(emp);
        
        Employee__c empLead = new Employee__c(name='Test Install Lead', Department__c='Install', Job_Title__c='Lead Installer', Status__c='W-2', Home_Office_Location__c=coronaOffice.Id);
        employees.add(empLead);
        
        insert employees;
        
        List<Install_Team__c> insertTeams = new List<Install_Team__c>();
        Install_Team__c inTeam = new Install_Team__c();
        inTeam.name = 'Test Install Team';
        inTeam.Team_Lead__c = empLead.id;
        insertTeams.add(inTeam);        
        insert insertTeams;
        
        List<Employee__c> updateEmployees = new List<Employee__c>();

        // add installers to install team        
        emp.Install_Team__c = inTeam.id;
        updateEmployees.add(emp);
        empLead.Install_Team__c = inTeam.id;
        updateEmployees.add(empLead);
        update updateEmployees;
        
        Install_Project__c instProj = new Install_Project__c();
        instProj.name = 'Install Project';
        instProj.PM_Project__c = pmProj.id;
        instProj.Installer_Team__c = inTeam.id;
        instProj.Drive_Time_Office_To_Site__c = 1.0;
        instProj.Electrician_Drive_Time_To_Site__c = 1.0;
        insert instProj;
        
        Date myDate = date.today();
        Date weekStart = myDate.toStartofWeek()+1;
        
        List<Time_Sheet__c> timeSheets = new List<Time_Sheet__c>();
        
        Time_Sheet__c timesheet = new Time_Sheet__c();
        timesheet.Employee__c = emp.id;
        timesheet.For_The_Week_Starting__c = weekStart;
        timeSheets.add(timesheet);
        
        Time_Sheet__c timesheetLead = new Time_Sheet__c();
        timesheetLead.Employee__c = empLead.id;
        timesheetLead.For_The_Week_Starting__c = weekStart;
        timeSheets.add(timesheetLead);
        
        insert timeSheets;
        
        List<Time_Sheet_Entry__c> timeSheetEntries = new List<Time_Sheet_Entry__c>();

        Map<String,Id> tpMap = createPurpose();
        
        // add timesheet entries for the installer: 5 days @ 8 hours per day
        Integer totalHours = 40;
        Integer hoursPerDay = totalHours / 5;
        for (Integer i=1; i <= 5; i++) {
            Date theDate = weekStart.addDays(i);
            Integer numberOfHours = hoursPerDay;  
            Integer numberOfMinutes = 30; // 30 mins for lunch break
            Id purpose = tpMap.get('Install');
            //Time_Sheet_Entry__c tseInstall = createTimeSheetEntry(timesheet.id, instProj.id, theDate, numberOfHours, numberOfMinutes, purpose); 
            Time_Sheet_Entry__c tseInstall = clockInEntry(timesheet.id, instProj.id, theDate, purpose); 
            timeSheetEntries.add(tseInstall);
        }                
        insert timeSheetEntries;

        for (Integer i=0; i <= timeSheetEntries.size()-1; i++) {
            clockOutEntry(timeSheetEntries[i], hoursPerDay, 30); 
        }                
        update timeSheetEntries; // hours are not computed on insert, so update
                
        //
        // assert install project values
        //
        Decimal expectedInstallerRegularPay = 800.0;
        Decimal expectedInstallerOvertimePay = null;
        
        Install_Project__c actualInstProj = [Select Installer_Install_Pay__c, Installer_Overtime_Pay__c  
                                             From Install_Project__c  
                                             where id = :instProj.id limit 1];
        
        System.assertEquals(expectedInstallerRegularPay, actualInstProj.Installer_Install_Pay__c);
        System.assertEquals(expectedInstallerOvertimePay, actualInstProj.Installer_Overtime_Pay__c);
   
        Test.stopTest();           
    }
    
  public static testMethod void testComputeInstallerInstallPay_TwoInstallers_NoOvertime() {
        if(!runalltests){ return; }

        Decimal hourlyRate = 20.00;
        Decimal hourlyRateEmp2 = 8.00;
        
        // setup base project
        PM_Project__c pmProj = setupProject();

        Test.startTest();   
        
        // AstrumTIME Specific Tests
        Office_Location__c coronaOffice = new Office_Location__c(Name='Corona, CA', Street__c='123 Test St', City__c='Corona', State__c='CA', Zip_Code__c='10101', Active__c = true);
        insert coronaOffice;

        List<Employee__c> employees = new List<Employee__c>();
        
        Employee__c emp = new Employee__c(name='Test Installer', Department__c='Install', Job_Title__c='Solar Installer', Status__c='W-2', Hourly_Rate__c=hourlyRate, Home_Office_Location__c=coronaOffice.Id);
        employees.add(emp);

        Employee__c emp2 = new Employee__c(name='Test Installer 2', Department__c='Install', Job_Title__c='Solar Installer', Status__c='W-2', Hourly_Rate__c=hourlyRateEmp2, Home_Office_Location__c=coronaOffice.Id);
        employees.add(emp2);
        
        Employee__c empLead = new Employee__c(name='Test Install Lead', Department__c='Install', Job_Title__c='Lead Installer', Status__c='W-2', Home_Office_Location__c=coronaOffice.Id);
        employees.add(empLead);
        
        insert employees;
        
        List<Install_Team__c> insertTeams = new List<Install_Team__c>();
        Install_Team__c inTeam = new Install_Team__c();
        inTeam.name = 'Test Install Team';
        inTeam.Team_Lead__c = empLead.id;
        insertTeams.add(inTeam);        
        insert insertTeams;
        
        List<Employee__c> updateEmployees = new List<Employee__c>();

        // add installers to install team        
        emp.Install_Team__c = inTeam.id;
        updateEmployees.add(emp);

        emp2.Install_Team__c = inTeam.id;
        updateEmployees.add(emp2);
        
        empLead.Install_Team__c = inTeam.id;
        updateEmployees.add(empLead);
        
        update updateEmployees;
        
        Install_Project__c instProj = new Install_Project__c();
        instProj.name = 'Install Project';
        instProj.PM_Project__c = pmProj.id;
        instProj.Installer_Team__c = inTeam.id;
        instProj.Drive_Time_Office_To_Site__c = 1.0;
        instProj.Electrician_Drive_Time_To_Site__c = 1.0;
        insert instProj;
        
        Date myDate = date.today();
        Date weekStart = myDate.toStartofWeek()+1;
        
        List<Time_Sheet__c> timeSheets = new List<Time_Sheet__c>();
        
        Time_Sheet__c timesheet = new Time_Sheet__c();
        timesheet.Employee__c = emp.id;
        timesheet.For_The_Week_Starting__c = weekStart;
        timeSheets.add(timesheet);

        Time_Sheet__c timesheetEmp2 = new Time_Sheet__c();
        timesheetEmp2.Employee__c = emp2.id;
        timesheetEmp2.For_The_Week_Starting__c = weekStart;
        timeSheets.add(timesheetEmp2);
        
        Time_Sheet__c timesheetLead = new Time_Sheet__c();
        timesheetLead.Employee__c = empLead.id;
        timesheetLead.For_The_Week_Starting__c = weekStart;
        timeSheets.add(timesheetLead);
        
        insert timeSheets;
        
        List<Time_Sheet_Entry__c> timeSheetEntries = new List<Time_Sheet_Entry__c>();
        Map<String,Id> tpMap = createPurpose();
        // add timesheet entries for the installer: 5 days @ 8 hours per day
        Integer totalHours = 40;
        Integer hoursPerDay = totalHours / 5;
        for (Integer i=1; i <= 5; i++) {
            Date theDate = weekStart.addDays(i);
            Integer numberOfHours = hoursPerDay;  
            Integer numberOfMinutes = 30; // 30 mins for lunch break
            Id purpose = tpMap.get('Install');
            
            Time_Sheet_Entry__c tseInstall = clockInEntry(timesheet.id, instProj.id, theDate, purpose); 
            timeSheetEntries.add(tseInstall);

            Time_Sheet_Entry__c tseInstallEmp2 = clockInEntry(timesheetEmp2.id, instProj.id, theDate, purpose); 
            timeSheetEntries.add(tseInstallEmp2);
        }
        insert timeSheetEntries;
                
        for (Integer i=0; i <= timeSheetEntries.size()-1; i++) {
            clockOutEntry(timeSheetEntries[i], hoursPerDay, 30); 
        }
        update timeSheetEntries;
                
        //
        // assert install project values
        //
        Decimal expectedInstallerRegularPay = (hourlyRate * totalHours) + (hourlyRateEmp2 * totalHours);
        Decimal expectedInstallerOvertimePay = null;
        
        Install_Project__c actualInstProj = [Select Installer_Install_Pay__c, Installer_Overtime_Pay__c  
                                             From Install_Project__c  
                                             where id = :instProj.id limit 1];
        
        System.assertEquals(expectedInstallerRegularPay, actualInstProj.Installer_Install_Pay__c);
        System.assertEquals(expectedInstallerOvertimePay, actualInstProj.Installer_Overtime_Pay__c);
   
        Test.stopTest();           
    } 
         
  public static testMethod void testComputeInstallerInstallPay_SingleInstaller_WithOvertime() {
        if(!runalltests){ return; }

        Decimal hourlyRate = 20.00;
        Decimal overtimeRate = hourlyRate * 1.5;
        
        // setup base project
        PM_Project__c pmProj = setupProject();

        Test.startTest();   
        
        // AstrumTIME Specific Tests
        Office_Location__c coronaOffice = new Office_Location__c(Name='Corona, CA', Street__c='123 Test St', City__c='Corona', State__c='CA', Zip_Code__c='10101', Active__c = true);
        insert coronaOffice;

        List<Employee__c> employees = new List<Employee__c>();
        
        Employee__c emp = new Employee__c(name='Test Installer', Department__c='Install', Job_Title__c='Solar Installer', Status__c='W-2', Hourly_Rate__c=hourlyRate, Home_Office_Location__c=coronaOffice.Id);
        employees.add(emp);
        
        Employee__c empLead = new Employee__c(name='Test Install Lead', Department__c='Install', Job_Title__c='Lead Installer', Status__c='W-2', Home_Office_Location__c=coronaOffice.Id);
        employees.add(empLead);
        
        insert employees;
        
        List<Install_Team__c> insertTeams = new List<Install_Team__c>();
        Install_Team__c inTeam = new Install_Team__c();
        inTeam.name = 'Test Install Team';
        inTeam.Team_Lead__c = empLead.id;
        insertTeams.add(inTeam);        
        insert insertTeams;
        
        List<Employee__c> updateEmployees = new List<Employee__c>();

        // add installers to install team        
        emp.Install_Team__c = inTeam.id;
        updateEmployees.add(emp);
        empLead.Install_Team__c = inTeam.id;
        updateEmployees.add(empLead);
        update updateEmployees;
        
        Install_Project__c instProj = new Install_Project__c();
        instProj.name = 'Install Project';
        instProj.PM_Project__c = pmProj.id;
        instProj.Installer_Team__c = inTeam.id;
        instProj.Drive_Time_Office_To_Site__c = 1.0;
        instProj.Electrician_Drive_Time_To_Site__c = 1.0;
        insert instProj;
        
        Date myDate = date.today();
        Date weekStart = myDate.toStartofWeek()+1;
        
        List<Time_Sheet__c> timeSheets = new List<Time_Sheet__c>();
        
        Time_Sheet__c timesheet = new Time_Sheet__c();
        timesheet.Employee__c = emp.id;
        timesheet.For_The_Week_Starting__c = weekStart;
        timeSheets.add(timesheet);
        
        Time_Sheet__c timesheetLead = new Time_Sheet__c();
        timesheetLead.Employee__c = empLead.id;
        timesheetLead.For_The_Week_Starting__c = weekStart;
        timeSheets.add(timesheetLead);
        
        insert timeSheets;
        
        List<Time_Sheet_Entry__c> timeSheetEntries = new List<Time_Sheet_Entry__c>();
        Map<String,Id> tpMap = createPurpose();
        
        // add timesheet entries for the installer: 5 days @ 9 hours per day
        Integer totalHours = 45;
        Integer hoursPerDay = totalHours / 5;
        for (Integer i=1; i <= 5; i++) {
            Date theDate = weekStart.addDays(i);
            Integer numberOfHours = hoursPerDay;  
            Integer numberOfMinutes = 30; // 30 mins for lunch break
            Id purpose = tpMap.get('Install');
            Time_Sheet_Entry__c tseInstall = clockInEntry(timesheet.id, instProj.id, theDate, purpose); 
            timeSheetEntries.add(tseInstall);
        }
        insert timeSheetEntries;
                
        for (Integer i=0; i <= timeSheetEntries.size()-1; i++) {
            clockOutEntry(timeSheetEntries[i], hoursPerDay, 30);
        }
        update timeSheetEntries;
                
        //
        // assert install project values
        //
        Decimal expectedInstallerRegularPay = 40.0 * hourlyRate;
        Decimal expectedInstallerOvertimePay = (totalHours - 40.0) * overtimeRate;
        
        Install_Project__c actualInstProj = [Select Installer_Install_Pay__c, Installer_Overtime_Pay__c  
                                             From Install_Project__c  
                                             where id = :instProj.id limit 1];
        
        System.assertEquals(expectedInstallerRegularPay, actualInstProj.Installer_Install_Pay__c);
        System.assertEquals(expectedInstallerOvertimePay, actualInstProj.Installer_Overtime_Pay__c);
   
        Test.stopTest();           
    }       
    
  public static testMethod void testComputePre30MaintenancePay_SingleInstaller_NoOvertime() {
        if(!runalltests){ return; }

        Decimal hourlyRate = 20.00;
        
        // setup base project
        PM_Project__c pmProj = setupProject();

        Test.startTest();   
        
        // AstrumTIME Specific Tests
        Office_Location__c coronaOffice = new Office_Location__c(Name='Corona, CA', Street__c='123 Test St', City__c='Corona', State__c='CA', Zip_Code__c='10101', Active__c = true);
        insert coronaOffice;

        List<Employee__c> employees = new List<Employee__c>();
        
        Employee__c emp = new Employee__c(name='Test Installer', Department__c='Install', Job_Title__c='Solar Installer', Status__c='W-2', Hourly_Rate__c=hourlyRate, Home_Office_Location__c=coronaOffice.Id);
        employees.add(emp);
        
        Employee__c empLead = new Employee__c(name='Test Install Lead', Department__c='Install', Job_Title__c='Lead Installer', Status__c='W-2', Home_Office_Location__c=coronaOffice.Id);
        employees.add(empLead);
        
        insert employees;
        
        List<Install_Team__c> insertTeams = new List<Install_Team__c>();
        Install_Team__c inTeam = new Install_Team__c();
        inTeam.name = 'Test Install Team';
        inTeam.Team_Lead__c = empLead.id;
        insertTeams.add(inTeam);        
        insert insertTeams;
        
        List<Employee__c> updateEmployees = new List<Employee__c>();

        // add installers to install team        
        emp.Install_Team__c = inTeam.id;
        updateEmployees.add(emp);
        empLead.Install_Team__c = inTeam.id;
        updateEmployees.add(empLead);
        update updateEmployees;
        
        Install_Project__c instProj = new Install_Project__c();
        instProj.name = 'Install Project';
        instProj.PM_Project__c = pmProj.id;
        instProj.Installer_Team__c = inTeam.id;
        instProj.Drive_Time_Office_To_Site__c = 1.0;
        instProj.Electrician_Drive_Time_To_Site__c = 1.0;
        //instProj.Complete__c = true;
        //instProj.Date_Completed__c = Date.today().addDays(-15);  // to handle for pre30
        
        insert instProj;
        
        pmProj.Work_Completed__c = Date.today().addDays(-15);
        update pmProj;
        
        Date myDate = date.today();
        Date weekStart = myDate.toStartofWeek()+1;
        
        List<Time_Sheet__c> timeSheets = new List<Time_Sheet__c>();
        
        Time_Sheet__c timesheet = new Time_Sheet__c();
        timesheet.Employee__c = emp.id;
        timesheet.For_The_Week_Starting__c = weekStart;
        timeSheets.add(timesheet);
        
        Time_Sheet__c timesheetLead = new Time_Sheet__c();
        timesheetLead.Employee__c = empLead.id;
        timesheetLead.For_The_Week_Starting__c = weekStart;
        timeSheets.add(timesheetLead);
        
        insert timeSheets;
        
        List<Time_Sheet_Entry__c> timeSheetEntries = new List<Time_Sheet_Entry__c>();
        Map<String,Id> tpMap = createPurpose();
        
        // add timesheet entries for the installer: 5 days @ 8 hours per day
        Integer totalHours = 40;
        Integer hoursPerDay = totalHours / 5;
        for (Integer i=1; i <= 5; i++) {
            Date theDate = weekStart.addDays(i);
            Integer numberOfHours = hoursPerDay;  
            Integer numberOfMinutes = 30; // 30 mins for lunch break
            Id purpose = tpMap.get('Maintenance');
            Time_Sheet_Entry__c tseInstall = createTimeSheetEntry(timesheet.id, instProj.id, theDate, numberOfHours, numberOfMinutes, purpose); 
            timeSheetEntries.add(tseInstall);
        }
        insert timeSheetEntries;
                
        for (Integer i=0; i <= timeSheetEntries.size()-1; i++) {
            clockOutEntry(timeSheetEntries[i], hoursPerDay, 30);
        }
        update timeSheetEntries;
                
        //
        // assert install project values
        //
        Decimal expectedInstallerPre30MaintenancePay = (hourlyRate * totalHours) / 2;
        Decimal expectedInstallerPost30MaintenancePay = 0;

        Decimal expectedElectricianPre30MaintenancePay = (hourlyRate * totalHours) / 2;
        Decimal expectedElectricianPost30MaintenancePay = 0;
        
        Install_Project__c actualInstProj = [Select Installer_Pre30_Maintenance_Pay__c, Installer_Post30_Maintenance_Pay__c,
                                                    Electrician_Pre30_Maintenance_Pay__c, Electrician_Post30_Maintenance_Pay__c    
                                             From Install_Project__c  
                                             where id = :instProj.id limit 1];
        
        System.assertEquals(expectedInstallerPre30MaintenancePay, actualInstProj.Installer_Pre30_Maintenance_Pay__c);
        System.assertEquals(expectedInstallerPost30MaintenancePay, actualInstProj.Installer_Post30_Maintenance_Pay__c);

        System.assertEquals(expectedElectricianPre30MaintenancePay, actualInstProj.Electrician_Pre30_Maintenance_Pay__c);
        System.assertEquals(expectedElectricianPost30MaintenancePay, actualInstProj.Electrician_Post30_Maintenance_Pay__c);
   
        Test.stopTest();           
    }
    
    public static testMethod void testApproveAndPostEntries() {
        if(!runalltests){ return; }

        Decimal hourlyRate = 20.00;
        
        // setup base project
        PM_Project__c pmProj = setupProject();

        Test.startTest();   
        
        // AstrumTIME Specific Tests
        // SZ: update to use Office_Location__c
        List<Office_Location__c> offices = new List<Office_Location__c>();

        Office_Location__c coronaOffice = new Office_Location__c(Name='Corona, CA', Street__c='123 Test St', City__c='Corona', State__c='CA', Zip_Code__c='10101', Active__c = true);
        offices.add(coronaOffice);

        Office_Location__c norristownOffice = new Office_Location__c(Name='Norristown, PA', Street__c='123 Test St', City__c='Norristown', State__c='PA', Zip_Code__c='12345', Active__c = true);
        offices.add(norristownOffice);

        insert offices;

        List<Employee__c> employees = new List<Employee__c>();

        Employee__c emp = new Employee__c(name='Test Installer', Department__c='Install', Job_Title__c='Solar Installer', Status__c='W-2', Hourly_Rate__c=hourlyRate ,Home_Office_Location__c = coronaOffice.Id);
        employees.add(emp);
        
        Employee__c empLead = new Employee__c(name='Test Install Lead', Department__c='Install', Job_Title__c='Lead Installer', Status__c='W-2',Home_Office_Location__c = norristownOffice.Id);
        employees.add(empLead);

        Employee__c emp2 = new Employee__c(name='Test Install 2', Department__c='Install', Job_Title__c='Lead Installer', Status__c='W-2',Home_Office_Location__c = coronaOffice.Id);
        employees.add(emp2);
        
        insert employees;

        List<Install_Team__c> insertTeams = new List<Install_Team__c>();
        Install_Team__c inTeam = new Install_Team__c();
        inTeam.name = 'Test Install Team';
        inTeam.Team_Lead__c = empLead.id;
        insertTeams.add(inTeam);        
        insert insertTeams;
        
        List<Employee__c> updateEmployees = new List<Employee__c>();

        // add installers to install team        
        emp.Install_Team__c = inTeam.id;
        updateEmployees.add(emp);
        emp2.Install_Team__c = inTeam.id;
        updateEmployees.add(emp2);
        empLead.Install_Team__c = inTeam.id;
        updateEmployees.add(empLead);
        update updateEmployees;
        
        Install_Project__c instProj = new Install_Project__c();
        instProj.name = 'Install Project';
        instProj.PM_Project__c = pmProj.id;
        instProj.Installer_Team__c = inTeam.id;
        instProj.Drive_Time_Office_To_Site__c = 1.0;
        instProj.Electrician_Drive_Time_To_Site__c = 1.0;
        //instProj.Complete__c = true;
        //instProj.Date_Completed__c = Date.today().addDays(-15);  // to handle for pre30
        
        insert instProj;
        
        pmProj.Work_Completed__c = Date.today().addDays(-15);
        update pmProj;
        
        Date myDate = date.today();
        Date weekStart = myDate.toStartofWeek()+1;
        
        List<Time_Sheet__c> timeSheets = new List<Time_Sheet__c>();
        
        Time_Sheet__c timesheet = new Time_Sheet__c();
        timesheet.Employee__c = emp.id;
        timesheet.For_The_Week_Starting__c = weekStart;
        timeSheets.add(timesheet);

        Time_Sheet__c timesheet2 = new Time_Sheet__c();
        timesheet2.Employee__c = emp2.id;
        timesheet2.For_The_Week_Starting__c = weekStart;
        timeSheets.add(timesheet2);
        
        Time_Sheet__c timesheetLead = new Time_Sheet__c();
        timesheetLead.Employee__c = empLead.id;
        timesheetLead.For_The_Week_Starting__c = weekStart;
        timeSheets.add(timesheetLead);
        
        insert timeSheets;
        
        List<Time_Sheet_Entry__c> timeSheetEntries = new List<Time_Sheet_Entry__c>();
        Map<String,Id> tpMap = createPurpose();
        
        // add timesheet entries for the installer: 5 days @ 8 hours per day
        Integer totalHours = 96;
        Integer hoursPerDay = totalHours /7;
        for (Integer i=1; i <= 7; i++) {
            Date theDate = weekStart.addDays(i);
            Integer numberOfHours = hoursPerDay;  
            Integer numberOfMinutes = 0; // 30 mins for lunch break
            Id purpose = tpMap.get('Maintenance');
            Time_Sheet_Entry__c tseInstall = createTimeSheetEntry(timesheet.id, instProj.id, theDate, numberOfHours, numberOfMinutes, purpose); 
            timeSheetEntries.add(tseInstall);
        }

        totalHours = 70;
        hoursPerDay = totalHours /7;
        for (Integer i=1; i <=7; i++) {
            Date theDate = weekStart.addDays(i);

            Integer numberOfHours = hoursPerDay;  
            if(i==5)
            {
                numberOfHours = 7;    
            }
            if(i==7)
            {
                numberOfHours = 7;    
            }
            Integer numberOfMinutes = 0; // 30 mins for lunch break
            Id purpose = tpMap.get('Maintenance');
            Time_Sheet_Entry__c tseInstall = createTimeSheetEntry(timesheet2.id, instProj.id, theDate, numberOfHours, numberOfMinutes, purpose); 
            timeSheetEntries.add(tseInstall);
        }

        totalHours = 72;
        hoursPerDay = totalHours /5;
        for (Integer i=1; i <=5; i++) {
            Date theDate = weekStart.addDays(i);
            Integer numberOfHours = hoursPerDay;  
            Integer numberOfMinutes = 0; // 30 mins for lunch break
            Id purpose = tpMap.get('Maintenance');
            Time_Sheet_Entry__c tseInstall = createTimeSheetEntry(timesheetLead.id, instProj.id, theDate, numberOfHours, numberOfMinutes, purpose); 
            timeSheetEntries.add(tseInstall);
        }
                
        
                
        insert timeSheetEntries;
        
        ApexPages.StandardController crcontroller = new ApexPages.StandardController(timesheet);
        TimesheetEntryApprovalController appController = new TimesheetEntryApprovalController(crcontroller);  
        
       
        for(TimesheetEntryApprovalController.TimesheetEntryWrapper tsw :appController.wrappers )
        {
            tsw.selected = true;
        }
        appController.approveEntries();

        List<Time_Sheet_Entry__c> tse = [Select Approved__c
                                             From Time_Sheet_Entry__c  Where id in :timeSheetEntries
                                            limit 1];
        
        System.assertEquals(true, tse[0].Approved__c);

        ApexPages.StandardController prcontroller = new ApexPages.StandardController(timesheet);
        TimesheetEntryPostController postController = new TimesheetEntryPostController(prcontroller);  
        postController.PostEntries();

        List<Time_Sheet_Entry__c> tsep = [Select Posted__c
                                             From Time_Sheet_Entry__c  Where id in :timeSheetEntries
                                            limit 1];
   
        System.assertEquals(true, tsep[0].Posted__c);


        List<Time_Sheet_Entry__c> timeSheetEntriesLead = new List<Time_Sheet_Entry__c>();
        
        
        // add timesheet entries for the installer: 5 days @ 8 hours per day
        
        
        crcontroller = new ApexPages.StandardController(timesheetLead);
        appController = new TimesheetEntryApprovalController(crcontroller);  
        
       
        for(TimesheetEntryApprovalController.TimesheetEntryWrapper tsw :appController.wrappers )
        {
            tsw.selected = true;
        }
        appController.approveEntries();

        tse = [Select Approved__c
                                             From Time_Sheet_Entry__c  Where id in :timeSheetEntries
                                            limit 1];
        
        System.assertEquals(true, tse[0].Approved__c);

        prcontroller = new ApexPages.StandardController(timesheetLead);
        postController = new TimesheetEntryPostController(prcontroller);  
        postController.PostEntries();

        tsep = [Select Posted__c
                                             From Time_Sheet_Entry__c  Where id in :timeSheetEntries
                                            limit 1];
   
        System.assertEquals(true, tsep[0].Posted__c);

        crcontroller = new ApexPages.StandardController(timesheet2);
        appController = new TimesheetEntryApprovalController(crcontroller);  
        
       
        for(TimesheetEntryApprovalController.TimesheetEntryWrapper tsw :appController.wrappers )
        {
            tsw.selected = true;
        }
        appController.approveEntries();

        tse = [Select Approved__c
                                             From Time_Sheet_Entry__c  Where id in :timeSheetEntries
                                            limit 1];
        
        System.assertEquals(true, tse[0].Approved__c);

        prcontroller = new ApexPages.StandardController(timesheet2);
        postController = new TimesheetEntryPostController(prcontroller);  
        postController.PostEntries();

        tsep = [Select Posted__c
                                             From Time_Sheet_Entry__c  Where id in :timeSheetEntries
                                            limit 1];
   
        System.assertEquals(true, tsep[0].Posted__c);

        Test.stopTest();           
    }


    public static testMethod void testTimesheetEmployeeController() {
        if(!runalltests){ return; }

        Decimal hourlyRate = 20.00;
        
        // setup base project
        PM_Project__c pmProj = setupProject();

        
        
        // AstrumTIME Specific Tests
        // SZ: Update to use Office_Location__c
        List<Office_Location__c> offices = new List<Office_Location__c>();

        Office_Location__c coronaOffice = new Office_Location__c(Name='Corona, CA', Street__c='123 Test St', City__c='Corona', State__c='CA', Zip_Code__c='10101', Active__c = true);
        offices.add(coronaOffice);

        Office_Location__c norristownOffice = new Office_Location__c(Name='Norristown, PA', Street__c='123 Test St', City__c='Norristown', State__c='PA', Zip_Code__c='12345', Active__c = true);
        offices.add(norristownOffice);

        insert offices;

        List<Employee__c> employees = new List<Employee__c>();
        
        Employee__c emp = new Employee__c(name='Test Installer', Department__c='Install', Job_Title__c='Solar Installer', Status__c='W-2', Hourly_Rate__c=hourlyRate ,Home_Office_Location__c = coronaOffice.Id,employee_class__c = 'Field Sales',Employee_Number__c = 9677);        
        employees.add(emp);
        
        Employee__c empLead = new Employee__c(name='Test Install Lead', Department__c='Install', Job_Title__c='Lead Installer', Status__c='W-2',Home_Office_Location__c = norristownOffice.Id ,employee_class__c = 'Inside Sales',Employee_Number__c = 9678);
        employees.add(empLead);        
        
        insert employees;

        Test.startTest();   

        ApexPages.StandardController econtroller = new ApexPages.StandardController(emp);
        EmployeePINGenerator empController = new EmployeePINGenerator(econtroller); 
        empController.getRandomInt();
        emp = [Select Employee_PIN__c from Employee__c where id = :emp.id];
        
        List<Install_Team__c> insertTeams = new List<Install_Team__c>();
        Install_Team__c inTeam = new Install_Team__c();
        inTeam.name = 'Test Install Team';
        inTeam.Team_Lead__c = empLead.id;
        insertTeams.add(inTeam);        
        insert insertTeams;
        
        List<Employee__c> updateEmployees = new List<Employee__c>();

        // add installers to install team        
        emp.Install_Team__c = inTeam.id;
        emp.Employee_PIN__c = '1234';
        updateEmployees.add(emp);        
        empLead.Install_Team__c = inTeam.id;
        empLead.Employee_PIN__c = '1234';
        updateEmployees.add(empLead);
        update updateEmployees;
        
        Install_Project__c instProj = new Install_Project__c();
        instProj.name = 'Install Project';
        instProj.PM_Project__c = pmProj.id;
        instProj.Installer_Team__c = inTeam.id;
        instProj.Drive_Time_Office_To_Site__c = 1.0;
        instProj.Electrician_Drive_Time_To_Site__c = 1.0;
        //instProj.Complete__c = true;
        //instProj.Date_Completed__c = Date.today().addDays(-15);  // to handle for pre30
        
        insert instProj;
        
        pmProj.Work_Completed__c = Date.today().addDays(-15);
        update pmProj;

        TimesheetEmployeeController tec = new  TimesheetEmployeeController();
        TimesheetEmployeeController.EmployeeLoginDetail elogin = TimesheetEmployeeController.employeeLogin('9677','1234') ;  
        System.assertEquals(elogin.empClass , 'Field Sales');

        Map<String,Id> tpMap = createPurpose();

        List<Timesheet_Purpose__c> purposes = TimesheetEmployeeController.getPurpose('Field Sales', 'Open');
        
        List<Install_Project__c> projects = TimesheetEmployeeController.getProjectRecs(true, '9677');
        projects = TimesheetEmployeeController.getProjectRecs(false, '9677');
        

        Install_Project__c prj = TimesheetEmployeeController.getProjectRecByBarCode(instProj.Id);
        System.assertEquals( 'Open' ,prj.Wo_Status__c  );

        Datetime checkinTime = TimesheetEmployeeController.completeCheckIn( 40.013893 , -76.631760, String.valueOf(emp.Id), String.valueOf(instProj.Id), String.valueOf(tpMap.get('Maintenance')),null);
        Time_Sheet_Entry__c[] entries = [Select id,time_sheet__c from Time_Sheet_Entry__c Where Time_sheet__r.Employee__c = :emp.Id];
        System.assertEquals(1,entries.size());
        elogin = TimesheetEmployeeController.employeeLogin('9677','1234') ; 

        Time_Sheet_Entry__c tseInstall = createTimeSheetEntry(entries[0].time_sheet__c, instProj.id, System.today(), 6, 0, tpMap.get('Maintenance'));
        insert tseInstall;

        Datetime checkOutTime = TimesheetEmployeeController.completeCheckOut( 40.013893 , -76.631760, String.valueOf(tseInstall.Id));
        

        Test.stopTest();           
    }


        
    private static Time_Sheet_Entry__c createTimeSheetEntry(Id timeSheetId, Id installProjectId, Date theDate, Integer numberOfHours, Id purpose) {
        
        Integer numberOfMinutes = 0;
        Time_Sheet_Entry__c tseInstall = createTimeSheetEntry(timeSheetId, installProjectId, theDate, numberOfHours, numberOfMinutes, purpose);

        return tseInstall;      
    }

    private static Time_Sheet_Entry__c createTimeSheetEntry(Id timeSheetId, Id installProjectId, Date theDate, Integer numberOfHours, Integer numberOfMinutes, Id purpose) {
        Time_Sheet_Entry__c tseInstall = new Time_Sheet_Entry__c();
        tseInstall.Start_Time__c = datetime.newInstance(theDate,time.newInstance(0, 0, 0, 0));
        tseInstall.Start_Time_On_Site__c = tseInstall.Start_Time__c.addHours(1);
        
        tseInstall.End_Time__c = tseInstall.Start_Time__c.addHours(numberOfHours);
        tseInstall.End_Time__c = tseInstall.End_Time__c.addMinutes(numberOfMinutes);

        tseInstall.Start_Time_Off_Site__c = tseInstall.End_Time__c.addHours(-1);
        
        tseInstall.Timesheet_Purpose__c = purpose;
        tseInstall.Project_Client_Job__c = installProjectId;
        tseInstall.Half_Hour_Lunch_Break__c = 'Yes';
        tseInstall.Time_Sheet__c = timeSheetId;
 
        System.debug('tseInstall.Time_Sheet__c  = ' + tseInstall.Time_Sheet__c );
        
        return tseInstall;      
    }

    private static Time_Sheet_Entry__c clockInEntry(Id timesheetId, Id installProjectId, Date theDate, Id purpose){
        Time_Sheet_Entry__c tseInstall = new Time_Sheet_Entry__c();
        tseInstall.Start_Time__c = datetime.newInstance(theDate,time.newInstance(0, 0, 0, 0));
        tseInstall.Start_Time_On_Site__c = tseInstall.Start_Time__c.addHours(1);
        
        tseInstall.Timesheet_Purpose__c = purpose;
        tseInstall.Project_Client_Job__c = installProjectId;
        tseInstall.Half_Hour_Lunch_Break__c = 'Yes';
        tseInstall.Time_Sheet__c = timeSheetId;
 
        System.debug('tseInstall.Time_Sheet__c  = ' + tseInstall.Time_Sheet__c );
        
        return tseInstall;      
    }

    private static void clockOutEntry(Time_Sheet_Entry__c tseInstall, Integer numberOfHours, Integer numberOfMinutes){
        tseInstall.End_Time__c = tseInstall.Start_Time__c.addHours(numberOfHours);
        tseInstall.End_Time__c = tseInstall.End_Time__c.addMinutes(numberOfMinutes);

        tseInstall.Start_Time_Off_Site__c = tseInstall.End_Time__c.addHours(-1);
    }

    private static PM_Project__c setupProject() {
        

        Account customer = new Account(Name = 'Test Customer',
                                BillingStreet = '244 Torrey Pine',
                                BillingState = 'PA' ,
                                BillingPostalCode = '19380',
                                BillingCountry = 'USA',
                                BillingCity = 'West Chester');
        insert customer;

        Office_Location__c norristownOffice = new Office_Location__c(Name='Norristown, PA', Street__c='123 Test St', City__c='Norristown', State__c='PA', Zip_Code__c='19403', Active__c = true);
        insert norristownOffice;
        
        Property__c property = CreateAstrumPM2ProjectTest.createNewProperty(customer.Id, '123 Test St');
        
        Opportunity opp = CreateAstrumPM2ProjectTest.createOpportunity(customer.Id, 'Test Oppty');
             
        SCRB_SalesOrder__c salesOrder = CreateAstrumPM2ProjectTest.createSalesOrder(property.Id, opp.Id);
        salesOrder.AccountId__c = customer.Id;
        salesOrder.StatusCode__c = 'Final/Accounting Approved';
        salesOrder.Opportunity_Close_Date__c = System.today().addDays(-8);
        update salesOrder;
        
        salesOrder = [SELECT Id, Name, AccountId__c, AccountId__r.Name, RequestedShipmentOn__c, StatusCode__c
                            FROM SCRB_SalesOrder__c 
                            WHERE Id = :salesOrder.Id];

        
    //public String createProject(SCRB_SalesOrder__c salesOrder) {
        
        Id projectId; 
        //create a new PM 2.0 project
        PM_Project__c newProject = new PM_Project__c(
            Name = salesOrder.AccountId__r.Name,
            Sales_Order__c = salesOrder.Id,
            //Salesperson__c = salesOrder.OpportunityId__r.OwnerId
            Work_Completed__c = null
        );
        
        Date requestedInstall = salesOrder.RequestedShipmentOn__c;
        if (requestedInstall == null) {
            requestedInstall = Date.today().addDays(90);
        }
        newProject.Install__c = nextWeekday(requestedInstall); 
        
        //default to noon
        newProject.Kickoff__c = Datetime.newInstance(nextWeekDay(Date.today().addDays(7)), Time.newInstance(12,0,0,0));
        
        //System.debug('DML: createProject: insert');
        insert newProject;
        
        return newProject;
        
    }
    
    //find the first day of week after the requested date
    private static Date nextWeekday(Date dt) {
        
      Date startOfWeek = dt.toStartOfWeek();
      Integer days = startOfWeek.daysBetween(dt);
      if (days == 0) { //Sunday
        return dt.addDays(1);
      } 
      if (days == 6) { //Saturday
        return dt.addDays(2);
      }
      return dt; 
    }
        
    
/*
     private static Milestone1_Project__c setupProject() {
       //[Select u.SystemModstamp, u.States_Serviced__c, u.Rate__c, u.OwnerId, u.Name, u.LastModifiedDate, u.LastModifiedById, u.IsDeleted, u.Id, u.CreatedDate, u.CreatedById, u.ConnectionSentId, u.ConnectionReceivedId From Utility_Company__c u where u.Name = 'BG&E'];
              
        
         Utility_Company__c uc = new Utility_Company__c();
        uc.Name = 'BG&E';
        uc.States_Serviced__c = 'MD';
        uc.Weekend_Schedule__c = '111111111111111111111111222111111111111111111111111111111133111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';
        uc.Weekday_Schedule__c  = '111111111111111111111111111111111111111111111111221111111111111111111111111111133333311111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';
        Database.Saveresult ucDBResult = Database.Insert(uc,false);
        Id ucId = ucDBResult.getId();
        if(ucId == null){
          System.debug('ucDBResult Insert Errors --> ' + ucDBResult.getErrors());
        }
        System.debug('Added Utility Company with Id --> ' + ucId);

        List<Rate_Period__c> rps = new List<Rate_Period__c>();
        Rate_period__c rp = new Rate_period__c();
        rp.Period_Type__c = 'Peak';
        rp.Name = 'Period 1';
        rp.Utility_Company__c = ucId;
        rp.Rate_Period__c = 1;
        rps.add(rp);

        Rate_period__c rp1 = new Rate_period__c();
        rp1.Period_Type__c = 'Part_Peak';
        rp1.Name = 'Period 2';
        rp1.Utility_Company__c = ucId;
        rp1.Rate_Period__c = 2;
         rps.add(rp1);

        Rate_period__c rp2 = new Rate_period__c();
        rp2.Period_Type__c = 'Off_Peak';
        rp2.Name = 'Period 3';
        rp2.Utility_Company__c = ucId;
        rp2.Rate_Period__c = 3;
        rps.add(rp2);

        insert rps;
        
        Account acct = new Account();
        acct.Name = 'test account';
        Database.Saveresult acctDBResult = Database.Insert(acct,false);
        Id acctId = acctDBResult.getId();
        if(acctId == null){
            System.debug('acctDBResult Insert Errors --> ' + acctDBResult.getErrors());
        }
        System.debug('Added Account with Id --> ' + acctId);
        
        Office_Location__c off = new Office_Location__c();
        off.Name = 'Annapolis Junction, MD';
        off.City__c = 'Annapolis Junction';
        off.State__c = 'MD';
        off.Street__c = '123 Test';
        off.Zip_Code__c = '20701';
        insert off;
        
        Property__c prop = new Property__c();
        prop.Name = '123 Test St';
        prop.Property_Owner__c = acctId;
        prop.Optimal_Site_Quality_kWh_y_kW__c = double.valueOf('1250');
        prop.Property_State__c = 'MD';
        prop.Property_City__c = 'Annapolis Junction';
        prop.Property_ZIP__c = '20701';
        prop.Permit_Jurisdiction__c = 'Howard';
        prop.Property_County__c = 'Howard';
        prop.Astrum_Office__c = 'Annapolis Junction, MD';
        prop.Hours_From_Nearest_Office__c = 1.0;
          prop.Utility_Company__c =  ucId; 
        Database.Saveresult propDBResult = Database.Insert(prop,false);
        Id propId = propDBResult.getId();
        if(propId == null){
            System.debug('propDBResult Insert Errors --> ' + propDBResult.getErrors());
        }        
        
        System.debug('Added Property with Id --> ' + propId);
        
        Survey__c surv = new Survey__c();
        surv.Property__c = propId;
        surv.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'Survey__c' and r.Name = 'Field Survey'].id;
        
        insert surv;
        
        Utility_Service__c utilService = new Utility_Service__c();
        utilService.Amperage__c = double.valueOf('200');
        utilService.Utility_Company__c = ucId;
        utilService.Property__c = propId;
        utilService.Service_Account_Number__c = 'abc123';
        Database.Saveresult utilServiceDBResult = Database.Insert(utilService,false);
        Id utilServiceId = utilServiceDBResult.getId();
        if(utilServiceId == null){
            System.debug('utilServiceDBResult Insert Errors --> ' + utilServiceDBResult.getErrors());
        }        
        System.debug('Added Utility_Service__c with Id --> ' + utilServiceId);

        CB_Panel__c mainPanel = new CB_Panel__c();
        mainPanel.Utility_Service__c = utilServiceId;
        mainPanel.Main_Breaker_Rating_Amps__c =Double.valueOf('200');
        
        Database.Saveresult mainPanelDBResult = Database.Insert(mainPanel,false);
        Id mainPanelId = mainPanelDBResult.getId();
        if(mainPanelId == null){
            System.debug('mainPanelDBResult Insert Errors --> ' + mainPanelDBResult.getErrors());
        }        
        System.debug('Added CB_Panel__c with Id --> ' + mainPanelId);
        
        
        //MK 2014-05-02
        //Insert Physical Surface & link survey        
        Physical_Surface__c ps = new Physical_Surface__c();
        ps.Property__c = prop.Id; //New link to property
        ps.Surface_Tilt__c = 10;
        ps.Surface_Azimuth__c = 90;
        ps.Trenching_Dist_to_Intercon_Pt_ft__c = 10;
        ps.Suneye_Tilt_and_Orien_Factor__c = 2;        
        ps.Physical_Surface_Assigned_Letter__c = 'A'; //MK 2014-05-02
        ps.Surface_Type__c = 'Asphalt Shingle';//MK 2014-05-02
        insert ps;
        //MK 2014-05-02
        //Get PS in order to get the default mounting type
        ps = [select id, Default_Mounting_Type__c, Property__c, Surface_Tilt__c, Surface_Azimuth__c,
                Trenching_Dist_to_Intercon_Pt_ft__c, Suneye_Tilt_and_Orien_Factor__c, Surface_Type__c, 
                Name, Physical_Surface_Assigned_Letter__c from Physical_Surface__c where id =: ps.id];

        Install_Location__c instLoc = new Install_Location__c();
        instLoc.Location__c = 'S01';//MK 2014-05-02
        instLoc.Physical_Surface__c = ps.id;//MK 2014-05-02
        instLoc.Survey__c = surv.id;//MK 2014-05-02
        //instLoc.Property__c = propt.Id; //MK 2014-05-02
        instLoc.Azimuth__c = double.valueOf('180');
        instLoc.Pitch__c = double.valueOf('23');
        instLoc.TSRF__c = double.valueOf('90');
        Database.Saveresult instLocDBResult = Database.Insert(instLoc,false);
        Id instLocId = instLocDBResult.getId();
        if(instLocId == null){
          System.debug('instLocDBResult Insert Errors --> ' + instLocDBResult.getErrors());
        }
        System.debug('Added Install Location with Id --> ' + instLocId);
        
        
        System_Design__c sd = new System_Design__c();
        sd.Property__c = propId;
        Database.Saveresult sdDBResult = Database.Insert(sd,false);
        Id sdId = sdDBResult.getId();
        if(sdId == null){
            System.debug('sdDBResult Insert Errors --> ' + sdDBResult.getErrors());
        }
        System.debug('Added System_Design__c with Id --> ' + sdId);
        
        
        System_Design_Array__c sda = new System_Design_Array__c();
        sda.CB_Panel__c = mainPanelId;
        sda.System_Design__c = sdId;
        sda.Physical_Surface__c = ps.id;//MK 2014-05-02
        sda.Survey__c = surv.id;//MK 2014-05-02
        sda.Mounting_Type__c = ps.Default_Mounting_Type__c;//MK 2014-05-02

        Database.Saveresult sdaDBResult = Database.Insert(sda,false);
        Id sdaId = sdaDBResult.getId();
        if(sdaId == null){
            System.debug('sdaDBResult Insert Errors --> ' + sdaDBResult.getErrors());
        }
        System.debug('Added System_Design_Array__c with Id --> ' + sdaId);

        System_Design_Product__c sdp = new System_Design_Product__c();
        sdp.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Product__c' and r.Name = 'Panel'].id;
        sdp.Description__c  = 'Sanyo 215';
        sdp.End_Clamp_Type__c = 'F End Clamp';  
        sdp.Make__c = 'Sanyo';
        sdp.Max_Voltage__c = double.valueOf('600');
        sdp.Mid_Clamp_Type__c = 'F Mid Clamp';  
        sdp.Model__c = 'HIT Power 215N';
        sdp.Rated_Output_W__c = double.valueOf('215');  
        sdp.Unit__c = 'Count';

        Database.Saveresult sdpDBResult = Database.Insert(sdp,false);
        Id sdpId = sdpDBResult.getId();
        if(sdpId == null){
            System.debug('sdpDBResult Insert Errors --> ' + sdpDBResult.getErrors());
        }
        System.debug('Added System_Design_Product__c with Id --> ' + sdpId);
        
        
        
         System_Design_Item__c sdi = new System_Design_Item__c();
        sdi.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Item__c' and r.Name = 'Panel'].id;
        sdi.System_Design_Array__c = sdaId;
        sdi.Install_Location__c = instLocId;
        sdi.System_Design_Product__c = sdp.Id;
        sdi.Quantity__c = double.valueOf('29');
        sdi.Annual_Solar_Access__c = double.valueOf('100');
        sdi.NRG_Site_Quality__c= double.valueOf('90');
        sdi.Rated_Output_kW__c = 12;
        sdi.Tilt__c = double.valueOf('3');
        sdi.Azimuth__c = double.valueOf('3');
        sdi.Astrum_PV_Watts_Site_Quality__c = double.valueOf('1200');
        
        
        
        Database.Saveresult sdiDBResult = Database.Insert(sdi,false);
        Id sdiId = sdiDBResult.getId();
        if(sdiId == null){
            System.debug('sdiDBResult Insert Errors --> ' + sdiDBResult.getErrors());
        }
        System.debug('Added System_Design_Item__c with Id --> ' + sdiId);
                
        
        sd.Calculated_System_Price__c = decimal.valueOf('100000.25');
        update(sd);
        
        
        //Test Install Location Trigger: Update_SDI_onLocation_Change
        // Making the change to the Install Location should update the related SDIs by re-running their triggers.
        instLoc.TSRF__c = double.valueOf('94');
        update(instLoc);
        
        
        
        System_Design_Quote__c sdq = new System_Design_Quote__c();
        sdq.System_Design__c = sdId;
        
        system.debug('SDA --> ' + [Select s.System_Design__c, s.SystemModstamp, s.Special_Parts_Required__c, s.Projected_Annual_Output_kWh_y__c, s.Panel_Count__c, s.Name, s.Mounting_Type__c, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Id, s.Electrical_Adder__c, s.CreatedDate, s.CreatedById, s.ConnectionSentId, s.ConnectionReceivedId, s.CB_Panel__c, s.Array_Size_kW__c From System_Design_Array__c s where s.Id = :sdaId]);
        system.debug('SD --> ' + [Select s.Total_System_Size_kW__c, s.Total_Projected_Annual_Output_kWh_y__c, s.SystemModstamp, s.Survey__c, s.Property__c, s.Panel_Count__c, s.Overall_TSRF__c, s.Overall_Site_Quality__c, s.Notes__c, s.Name, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Id, s.CreatedDate, s.CreatedById, s.ConnectionSentId, s.ConnectionReceivedId, s.Calculated_System_Price__c, s.Calculated_Price_per_Watt__c, s.Account_Number__c From System_Design__c s where s.Id = :sdId]);
        Database.Saveresult sdqDBResult = Database.Insert(sdq,false);
        Id sdqId = sdqDBResult.getId();
        if(sdqId == null){
            System.debug('sdqDBResult Insert Errors --> ' + sdqDBResult.getErrors());
        }
        System.debug('Added System_Design_Quote__c with Id --> ' + sdqId);
   
        Opportunity opp = new Opportunity();
        opp.Name = 'Pete';
        opp.AccountId = acctId;
        opp.StageName = 'On Hold';
        opp.CloseDate = Date.today() + 20;
        opp.SREC__c = 'Yearly';
        opp.State_Grant_Amount__c = double.valueOf('100.00');
        opp.System_Design_Quote__c = sdqId;
        opp.Property__c = propId;
        opp.Financing_Type__c = 'Purchase';
        opp.Financing_Option__c = 'No Financing';
        opp.On_Hold_Until__c = Date.today().addDays(14);     
        opp.LeadSource = 'Unknown';
        opp.leasing_Option__c = null;
        opp.Lead_Source_Detail__c = 'Email';          
       
        Database.Saveresult oppDBResult = Database.Insert(opp,false);
        Id oppId = oppDBResult.getId();
        if(oppId == null){
            System.debug('oppDBResult Insert Errors --> ' + oppDBResult.getErrors());
        }
        System.debug('Added Opportunity with Id --> ' + oppId);

        Contact c = new Contact();
        c.FirstName = 'Pete';
        c.LastName = 'Varga';
        c.AccountId = acctId;
        Database.Saveresult contactDBResult = Database.Insert(c,false);
        Id cId = contactDBResult.getId();
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = cId;
        ocr.IsPrimary = true;
        ocr.Role = 'Decision Maker';
        ocr.OpportunityId = oppId;
        
        Database.Saveresult ocrDBResult = Database.Insert(ocr,false);
        Id ocrId = ocrDBResult.getId();
       
        //Add Price Adjustment to SDQ to trigger opp Update. 
        Price_Adjustment__c pa = new Price_Adjustment__c();
        pa.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'Price_Adjustment__c' and r.Name = 'Dollar Amount'].id;
        pa.Amount__c = decimal.valueof('-5000');
        pa.Type__c = 'Standard';        
        pa.System_Design_Quote__c = sdq.id;
        
        Database.Saveresult paDBResult = Database.Insert(pa,false);
        Id paId = paDBResult.getId();
        if(paId == null){
            System.debug('paDBResult Insert Errors --> ' + paDBResult.getErrors());
        }
        System.debug('Added Price Adjustment with Id --> ' + paId);
        
        opp.StageName = 'Closed - Won';
        opp.Type = 'New Business';
        update(opp);                
        
        SCRB_SalesOrder__c so = new SCRB_SalesOrder__c();
        so.Requires_Tree_Removal__c = 'No';
        so.OpportunityId__c = oppId;
        so.Property__c = propId;

        Database.Saveresult soDBResult = Database.Insert(so,false);
        Id soId = soDBResult.getId();
        if(soId == null){
            System.debug('soDBResult Insert Errors --> ' + soDBResult.getErrors());
        }
        System.debug('Added Sales Order with Id --> ' + soId);
        
        so.StatusCode__c = 'Sales Manager Approved';
        System.debug('About to update Sales Order --> ' + so);
        update(so);

        // Change Calculated System Price on SD to trigger Opp Update.
        
        sd.Calculated_System_Price__c = sd.Calculated_System_Price__c + decimal.valueOf('5000');
        update(sd);
        
        
        SalesOrderController.syncToOpp(soId, oppId);
        
        Milestone1_Project__c pmProj = new Milestone1_Project__c();
        pmProj.name = 'Unit Testing 12345azv09y';
        pmProj.Sales_Order__c = so.id;
        insert pmProj;

        pmProj.name = 'Updated Test Project 000X';
        update pmProj;
  
        return pmProj;      
    }
*/
      
}