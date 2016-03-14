/*
* MODIFICATION HISTORY: 
* 07/16/2015 PB FPO Phase2- Set active field on Office Location
*/
@isTest
public class AstrumTimeTestData {
	
    public Map<String, Id> pmProjectsNameIdMap {get;set;}
    public Map<String, Id> employeesNameIdMap {get;set;}
    public Map<String, Id> installTeamsNameIdMap {get;set;}
    public Map<String, Id> installProjectsNameIdMap {get;set;}

    public Map<Id, PM_Project__c> pmProjectsMap {get;set;}
    public Map<Id, Employee__c> employeesMap {get;set;}
    public Map<Id, Install_Team__c> installTeamsMap {get;set;}
    public Map<Id, Install_Project__c> installProjectsMap {get;set;}

    public Map<String, Id> timesheetPurposeMap {get;set;}
    public Date today {get;set;}
    public Date weekStart {get;set;}

    public Map<Id, Time_Sheet__c> timesheets {get;set;}
    public Map<Id, Time_Sheet_Entry__c> timesheetEntries {get;set;}

    public AstrumTimeTestData(){
        this.pmProjectsMap = new Map<Id, PM_Project__c>();
        this.employeesMap = new Map<Id, Employee__c>();
        this.installTeamsMap = new Map<Id, Install_Team__c>();
        this.installProjectsMap = new Map<Id, Install_Project__c>();

        this.pmProjectsNameIdMap = new Map<String, Id>();
        this.employeesNameIdMap = new Map<String, Id>();
        this.installTeamsNameIdMap = new Map<String, Id>();
        this.installProjectsNameIdMap = new Map<String, Id>();

        this.timesheetPurposeMap = new Map<String, Id>();

        this.today = date.today();
        this.weekStart = this.today.toStartofWeek() + 1;

        this.timesheets = new Map<Id, Time_Sheet__c>();
        this.timesheetEntries = new Map<Id, Time_Sheet_Entry__c>();
    }

    public void PopulateTestData(){
        CreateTimesheetServiceTestData();

        this.pmProjectsMap = new Map<Id, PM_Project__c>([SELECT Id, Name FROM PM_Project__c]);
        for(PM_Project__c p : this.pmProjectsMap.values()){
            this.pmProjectsNameIdMap.put(p.Name, p.Id);
        }

        this.employeesMap = new Map<Id, Employee__c>([SELECT Id, Name FROM Employee__c]);
        for(Employee__c e : this.employeesMap.values()){
            this.employeesNameIdMap.put(e.Name, e.Id);
        }

        this.installTeamsMap = new Map<Id, Install_Team__c>([SELECT Id, Name FROM Install_Team__c]);
        for(Install_Team__c it : this.installTeamsMap.values()){
            this.installTeamsNameIdMap.put(it.Name, it.Id);
        }

        this.installProjectsMap = new Map<Id, Install_Project__c>([SELECT Id, Name FROM Install_Project__c]);
        for(Install_Project__c ip : this.installProjectsMap.values()){
            this.installProjectsNameIdMap.put(ip.Name, ip.Id);
        }

        List<Timesheet_Purpose__c> purposes = [SELECT Id, Name FROM Timesheet_Purpose__c];
        for(Timesheet_Purpose__c tp : purposes){
            this.timesheetPurposeMap.put(tp.Name, tp.Id);
        }
    }

    private void CreateTimesheetServiceTestData() {
        List<PM_Project__c> pmProjects = new List<PM_Project__c>();
        PM_Project__c pmProj = setupProject();
        pmProjects.add(pmProj);
        PM_Project__c pmProj2 = setupProject();
        pmProjects.add(pmProj2);

        insert pmProjects;

        // AstrumTIME Specific Tests
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

        List<Install_Project__c> instProjects = new List<Install_Project__c>();

        Install_Project__c instProj = new Install_Project__c();
        instProj.name = 'Install Project';
        instProj.PM_Project__c = pmProj.id;
        instProj.Installer_Team__c = inTeam.id;
        instProj.Electrician_Team__c = elTeam.id;
        instProj.Drive_Time_Office_To_Site__c = 1.0;
        instProj.Electrician_Drive_Time_To_Site__c = 1.0;
        instProjects.add(instProj);
        
        Install_Project__c instProj2 = new Install_Project__c();
        instProj2.name = 'Install Project 2';
        instProj2.PM_Project__c = pmProj2.id;
        instProj2.Installer_Team__c = inTeam.id;
        instProj2.Electrician_Team__c = elTeam.id;
        instProj2.Drive_Time_Office_To_Site__c = 1.0;
        instProj2.Electrician_Drive_Time_To_Site__c = 1.0;
        instProjects.add(instProj2);

        insert instProjects;

        List<Timesheet_Purpose__c> tplist = new List<Timesheet_Purpose__c>();
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
    }

    private PM_Project__c setupProject() {

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

        TriggerUtility.isOpportunityUpdate = true; 
        Opportunity opp = CreateAstrumPM2ProjectTest.createOpportunity(customer.Id, 'Test Oppty');
             
        SCRB_SalesOrder__c salesOrder = CreateAstrumPM2ProjectTest.createSalesOrder(property.Id, opp.Id);
        salesOrder.AccountId__c = customer.Id;
        salesOrder.StatusCode__c = 'Final/Accounting Approved';
        salesOrder.Opportunity_Close_Date__c = System.today().addDays(-8);
        update salesOrder;
        
        salesOrder = [SELECT Id, Name, AccountId__c, AccountId__r.Name, RequestedShipmentOn__c, StatusCode__c
                            FROM SCRB_SalesOrder__c 
                            WHERE Id = :salesOrder.Id];

        
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
        
        return newProject;
    }
    
    //find the first day of week after the requested date
    private Date nextWeekday(Date dt) {
        
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
}