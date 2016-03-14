/* FILE: ProjectDetailGridTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: June 11, 2012
 * PURPOSE: Test class for ProjectDetailGrid component  
 * MODIFICATION HISTORY
 *
 */ 

@isTest
public class ProjectDetailGridTest {

	static testMethod void newProject_load_hasBlankFields() {
		
		DocumentBinTest.createBinConfiguration();
		
		Account partner = new Account(Name = 'Fund Partner');
		insert partner;
	
		Lease_Fund__c leasefund = new Lease_Fund__c(
			Name = 'NRG Residential Solar Solutions, LLC',
			Fund_Partner__c = partner.id,
			Fund_Open_Date__c = date.today(),
			Eligible_States__c = 'CA;CT;DC;DE;KY;MA;MD;MI;NJ;NY;OH;PA;VA;WV',
			Eligible_Leasing_Options__c = 'One-Pay - Keep SRECs'
		);
		insert(leasefund);	
		
		Lease_Fund__c leasefund2 = new Lease_Fund__c(
			Name = 'Sunnova Energy Corporation',
			Fund_Partner__c = partner.id,
			Fund_Open_Date__c = date.today(),
			Eligible_States__c = 'CA;CT;DC;DE;KY;MA;MD;MI;NJ;NY;OH;PA;VA;WV',
			Eligible_Leasing_Options__c = 'One-Pay - Keep SRECs'
		);					
		insert(leasefund2);
		
		PM_Project__c project = new PM_Project__c ( Name = 'Test Project' );
		insert project;
		
		PM_Project_Issue__c projectIssue1 = new PM_Project_Issue__c ( PM_Project__c = project.Id, Status__c = 'Open', Bin__c = 'Electrical Review' );
		insert projectIssue1;
		
		PM_Project_Issue__c projectIssue2 = new PM_Project_Issue__c ( PM_Project__c = project.Id, Status__c = 'Fixed', Bin__c = 'Electrical Review' );
		insert projectIssue2;
		
		Test.setCurrentPage(Page.PMProjectDetail);
		ProjectDetailGridController controller = new ProjectDetailGridController();
		controller.projectId = project.Id;
	
		System.assertEquals(1, ProjectDetailGridController.binConfig.size());	
		System.assertEquals(3, ProjectDetailGridController.specialCategories.size());	
		System.assertEquals(project.Id, controller.projectId);
		
		Test.startTest();
		
		PM_Project__c projectResult = ProjectDetailGridController.getProject(project.Id);
		
		Test.stopTest();

		System.assertEquals(project.Id, projectResult.Id);
		//will fail if not retrieved		
		System.assertEquals(null, projectResult.Grant_Completion_Completed__c);
		System.assertEquals(null, projectResult.Grant_Completion_Signed__c);
		System.assertEquals(null, projectResult.Grant_Completion_Submitted__c);
		System.assertEquals(null, projectResult.Grant_Completion__c);
		
	}

	static testMethod void newProject_setDates_datesSet() {
		
		PM_Project__c project = new PM_Project__c ( Name = 'Test Project' );
		insert project;
		
		Test.setCurrentPage(Page.PMProjectDetail);
		ProjectDetailGridController controller = new ProjectDetailGridController();
		controller.projectId = project.Id;
	
		Datetime kickoff = DateTime.newInstance(2012,5,5,12,0,0);
		Date install = kickoff.date().addDays(90);
		Datetime inspection = DateTime.newInstance(2012,5,5,11,30,0);
		
		Test.startTest();

		ProjectDetailGridController.setProjectDate(project.Id, 'Kickoff__c', String.valueOf(kickoff.getTime()));
		ProjectDetailGridController.setProjectDate(project.Id, 'Install__c', install.format());
		ProjectDetailGridController.setProjectDate(project.Id, 'Inspection__c', String.valueOf(inspection.getTime()));
		
		project = [SELECT Id, Kickoff__c, Install__c, Inspection__c FROM PM_Project__c WHERE Id = :project.Id];
		System.assertEquals(kickoff, project.Kickoff__c);
		System.assertEquals(install, project.Install__c);
		System.assertEquals(inspection, project.Inspection__c);

		ProjectDetailGridController.setProjectDate(project.Id, 'Kickoff__c', null);
		ProjectDetailGridController.setProjectDate(project.Id, 'Install__c', '');

		project = [SELECT Id, Kickoff__c, Install__c, Inspection__c FROM PM_Project__c WHERE Id = :project.Id];
		System.assertEquals(null, project.Kickoff__c);
		System.assertEquals(null, project.Install__c);

		Test.stopTest();
	}

	static testMethod void newProject_addCustomerAction_actionSet() {
		
		PM_Project__c project = new PM_Project__c ( Name = 'Test Project' );
		insert project;
		
		Test.setCurrentPage(Page.PMProjectDetail);
		ProjectDetailGridController controller = new ProjectDetailGridController();
		controller.projectId = project.Id;

		String customerNote = 'Customer must remove trees';
		
		project = [SELECT Id, Customer_Action_Notes__c, Customer_Action_Resolved__c FROM PM_Project__c WHERE Id = :project.Id];
		System.assertEquals(null, project.Customer_Action_Notes__c);	
		System.assertEquals(false, project.Customer_Action_Resolved__c);	
		
		Test.startTest();
		
		ProjectDetailGridController.updateCustomerAction(project.Id, customerNote, true);
		
		Test.stopTest();
		
		project = [SELECT Id, Customer_Action_Notes__c, Customer_Action_Resolved__c FROM PM_Project__c WHERE Id = :project.Id];
		System.assertEquals(customerNote, project.Customer_Action_Notes__c);	
		System.assertEquals(true, project.Customer_Action_Resolved__c);	
	}
	
	static testMethod void newProject_readyForInstall_readySet() {
		
		PM_Project__c project = new PM_Project__c ( Name = 'Test Project' );
		insert project;
		
		Test.setCurrentPage(Page.PMProjectDetail);
		ProjectDetailGridController controller = new ProjectDetailGridController();
		controller.projectId = project.Id;

		project = [SELECT Id, Ready_for_Install__c FROM PM_Project__c WHERE Id = :project.Id];
		System.assertEquals(false, project.Ready_for_Install__c);	
		
		Test.startTest();
		
		ProjectDetailGridController.setReadyForInstall(project.Id, true);

		project = [SELECT Id, Ready_for_Install__c FROM PM_Project__c WHERE Id = :project.Id];
		System.assertEquals(true, project.Ready_for_Install__c);	

		ProjectDetailGridController.setReadyForInstall(project.Id, false);

		project = [SELECT Id, Ready_for_Install__c FROM PM_Project__c WHERE Id = :project.Id];
		System.assertEquals(false, project.Ready_for_Install__c);	
		
		Test.stopTest();
		
	}
	
	static testMethod void newProject_testBinWorkflow_statesCorrect() {

		DocumentBinTest.createBinConfiguration();
		
		Date prepareDate = Date.newInstance(2012,5,1);
		Date signDate = Date.newInstance(2012,5,3);
		Date submitDate = Date.newInstance(2012,5,5);
		Date completeDate = Date.newInstance(2012,6,14);
		
		PM_Project__c project = new PM_Project__c ( 
			Name = 'Test Project', 
			Grant_Completion_Completed__c = prepareDate
		);
		insert project;
		
		Test.setCurrentPage(Page.PMProjectDetail);
		ProjectDetailGridController controller = new ProjectDetailGridController();
		controller.projectId = project.Id;

		Test.startTest();

		//prepared
		PM_Project__c projectResult = ProjectDetailGridController.getProject(project.Id);
		System.assertEquals(prepareDate.addYears(2000), projectResult.Grant_Completion__c);
		
		//signed
		project = new PM_Project__c ( Id = project.Id, Grant_Completion_Signed__c = signDate);
		update project;
		projectResult = ProjectDetailGridController.getProject(project.Id);
		System.assertEquals(signDate.addYears(4000), projectResult.Grant_Completion__c);
			
		//submitted
		project = new PM_Project__c ( Id = project.Id, Grant_Completion_Submitted__c = submitDate);
		update project;
		projectResult = ProjectDetailGridController.getProject(project.Id);
		System.assertEquals(submitDate.addYears(6000), projectResult.Grant_Completion__c);

		//approved
		project = new PM_Project__c ( Id = project.Id, Grant_Completion__c = completeDate);
		update project;
		projectResult = ProjectDetailGridController.getProject(project.Id);
		System.assertEquals(completeDate, projectResult.Grant_Completion__c);
		
		Test.stopTest();
	}

	@isTest static void test_getElectricalIssues() {
		
		PM_Project__c project = new PM_Project__c ( Name = 'Test Project' );
		insert project;
		
		PM_Project_Issue__c projectIssue1 = new PM_Project_Issue__c ( PM_Project__c = project.Id, Status__c = 'Open', Bin__c = 'Electrical Review' );
		insert projectIssue1;
		
		PM_Project_Issue__c projectIssue2 = new PM_Project_Issue__c ( PM_Project__c = project.Id, Status__c = 'Fixed', Bin__c = 'Electrical Review' );
		insert projectIssue2;
		
		Test.startTest();

		List<PM_Project_Issue__c> openIssues = ProjectDetailGridController.getOpenElectricIssueCount(project);
		system.assertEquals(1, openIssues.size());

		List<PM_Project_Issue__c> fixedIssues = ProjectDetailGridController.getFixedElectricIssueCount(project);
		system.assertEquals(1, fixedIssues.size());
		
		Test.stopTest();
	}

	static testMethod void newProject_updateSurveyEventDate() {
		
		Datetime surveyDate = DateTime.newInstance(2025,5,5,12,0,0);		
		
		PM_Project__c project = new PM_Project__c ( Name = 'Test Project' 
													,Survey_Date__c = surveyDate);
		insert project;

		Id recId = Schema.Sobjecttype.Event.getRecordTypeInfosByName().get('Site Survey Onsite').getRecordTypeId();        
        
		Event projEvent = new Event(
			EndDateTime = Date.today(),
            StartDateTime = Date.today(),
            whatId = project.Id,
            RecordTypeId=recId,
            Site_Survey_Type__c = 'Site Survey Onsite',
        	ownerId = UserInfo.getUserId());
		insert projEvent;			
		
		Test.startTest();
		System.debug(String.valueOf(surveyDate));
		ProjectDetailGridController.updateSurveyEventDate(project.Id, surveyDate.format());
		
		project = [SELECT Id
					, Survey_Date__c
					, (SELECT StartDateTime FROM Events) 
					FROM PM_Project__c 
					WHERE Id = :project.Id];
		
		System.assertEquals(surveyDate, project.Events[0].StartDateTime);
		
		Test.stopTest();
	}		
}