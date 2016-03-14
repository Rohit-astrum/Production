/* FILE: MyProjects2Test.cls
 * AUTHOR: Tino Mattheou
 * DATE: June 11, 2012
 * PURPOSE: Controller for MyProjects2 page
 * MODIFICATION HISTORY:
 * 06/27/2012 TCM - zen-2 Newly entered dates aren't sorted correctly (install, work completed, and customer care handoff)
 */

@isTest
public class MyProjects2Test {

	static testMethod void projectLeadRole_checkgCalEnabled_true() {
		
		UserRole plRole = [SELECT Id FROM UserRole WHERE Name LIKE '%Project Lead' LIMIT 1];
		Profile opsUser = [SELECT Id FROM Profile WHERE Name = 'Operations User'];
		User plUser = new User(
			UserName = 'project.lead@test.com',
			LastName = 'Lead',
			Email = 'project.lead@test.com',
			Alias = 'PLTest3',
			CommunityNickName = 'Project Lead Test',
			TimeZoneSidKey = 'America/New_York',
			LocaleSidKey = 'en_US',
			LanguageLocaleKey = 'en_US',
			EmailEncodingKey = 'UTF-8',
			ProfileId = opsUser.Id,
			UserRoleId = plRole.Id
		);
		insert plUser;
		
		System.runAs(plUser) {
			Test.startTest();
			MyProjects2Controller controller = new MyProjects2Controller();
			System.assertEquals(true, controller.googleCalendarEnabled);
			System.assert(controller.getProjectLeads().size() >= 2);
			Test.stopTest();
		}
	}

	static testMethod void opsDirectorRole_checkgCalEnabled_false() {
		
		UserRole directorRole = [SELECT Id FROM UserRole WHERE Name LIKE '%Director%' AND Name LIKE '%Operations%' LIMIT 1];
		Profile directorProfile = [SELECT Id FROM Profile WHERE Name = 'Director of Operations'];
		User directorUser = new User(
			UserName = 'project.lead@test.com',
			LastName = 'Lead',
			Email = 'project.lead@test.com',
			Alias = 'PLTest3',
			CommunityNickName = 'Project Lead Test',
			TimeZoneSidKey = 'America/New_York',
			LocaleSidKey = 'en_US',
			LanguageLocaleKey = 'en_US',
			EmailEncodingKey = 'UTF-8',
			ProfileId = directorProfile.Id,
			UserRoleId = directorRole.Id
		);
		insert directorUser;
		
		System.runAs(directorUser) {
			Test.startTest();
			MyProjects2Controller controller = new MyProjects2Controller();
			System.assertEquals(false, controller.googleCalendarEnabled);
			System.assertEquals('America/New_York', controller.userTimeZone);
			Test.stopTest();
		}
	}

	static testMethod void noProjects_checkAccess_noAccess() {

		Test.setCurrentPage(Page.MyProjects2);
		MyProjects2Controller controller = new MyProjects2Controller();
		
		PageReference result = controller.checkAccess();
		
		System.assertEquals(null, result);
		System.assertEquals(false, controller.showAccessLink);
		
	}

	static testMethod void noProjects_requestGoogleAccess_noAccess() {

		Test.setCurrentPage(Page.MyProjects2);
		MyProjects2Controller controller = new MyProjects2Controller();
		
		PageReference result = controller.requestGoogleAccess();
		
		System.assertNotEquals(null, result);
		
	}
	
	static testMethod void noProjects_revokeAccess_noAccess() {

		Test.setCurrentPage(Page.MyProjects2);
		MyProjects2Controller controller = new MyProjects2Controller();
		
		PageReference result = controller.revokeAccess();
		System.assertEquals(Page.MyProjects2.getUrl(), result.getUrl());
		System.assertEquals(true, controller.showAccessLink);
		
	}

	static testMethod void twoProjects_load_hasColumns() {
		
		DocumentBinTest.createBinConfiguration();
		
		Account customer = new Account(Name = 'Test Customer');
		insert customer;
		Property__c property = CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');
		SalesOrderTriggerHandler.skipSalesOrderTrigger = true;
		SCRB_SalesOrder__c salesOrder = CreateAstrumPM2ProjectTest.createSalesOrder(property.Id, null);
		SalesOrderTriggerHandler.skipSalesOrderTrigger = false;
		
		PM_Project__c project1 = new PM_Project__c ( Name = 'Test Project 1', Sales_Order__c = salesOrder.Id );
		insert project1;
		PM_Project__c project2 = new PM_Project__c ( Name = 'Test Project 2', Status__c = 'Active' );
		insert project2;
		
		Test.setCurrentPage(Page.MyProjects2);
		MyProjects2Controller controller = new MyProjects2Controller();
	
		System.assertEquals(1, MyProjects2Controller.binConfig.size());	
		System.assertEquals(3, MyProjects2Controller.specialCategories.size());	
		System.assertNotEquals(0, controller.getOffices().size());
		System.assertNotEquals(0, controller.getStates().size());
		System.assertNotEquals(0, controller.getStatuses().size());
		
		
		List<String> allFilter = new List<String> { 'state:All' };	
		List<String> paFilter = new List<String> { 'state:PA' };	
		
		Test.startTest();
		
		List<PM_Project__c> newProjects = MyProjects2Controller.getProjects('PL', 'New', paFilter);
		List<PM_Project__c> activeProjects = MyProjects2Controller.getProjects('PL', 'Active', allFilter);
		List<PM_Project__c> cancelledProjects = MyProjects2Controller.getProjects('PL', 'Cancelled', allFilter);
		
		Test.stopTest();

		System.assertEquals(1, newProjects.size());
		System.assertEquals(project1.Id, newProjects[0].Id);
		System.assertEquals(1, activeProjects.size());
		System.assertEquals(project2.Id, activeProjects[0].Id);
		System.assertEquals(0, cancelledProjects.size());
		
	}

	static testMethod void newProject_testBinWorkflow_statesCorrect() {

		DocumentBinTest.createBinConfiguration();
		
		Date prepareDate = Date.newInstance(2012,5,1);
		Date signDate = Date.newInstance(2012,5,3);
		Date submitDate = Date.newInstance(2012,5,5);
		Date completeDate = Date.newInstance(2012,6,14);
		
		PM_Project__c project = new PM_Project__c ( 
			Name = 'Test Project', 
			Grant_Completion_Completed__c = prepareDate,
			Status__c = 'Active'
		);
		insert project;
		
		Test.setCurrentPage(Page.MyProjects2);
		MyProjects2Controller controller = new MyProjects2Controller();

		List<String> filters = new List<String> { 'states:All' };	

		Test.startTest();

		//prepared
		PM_Project__c projectResult = MyProjects2Controller.getProjects('Grants', 'Active', filters)[0];
		System.assertEquals(prepareDate.addYears(2000), projectResult.Grant_Completion__c);
		
		//signed
		project = new PM_Project__c ( Id = project.Id, Grant_Completion_Signed__c = signDate);
		update project;
		projectResult = MyProjects2Controller.getProjects('Grants', 'Active', filters)[0];
		System.assertEquals(signDate.addYears(4000), projectResult.Grant_Completion__c);
			
		//submitted
		project = new PM_Project__c ( Id = project.Id, Grant_Completion_Submitted__c = submitDate);
		update project;
		projectResult = MyProjects2Controller.getProjects('Grants', 'Active', filters)[0];
		System.assertEquals(submitDate.addYears(6000), projectResult.Grant_Completion__c);

		//approved
		project = new PM_Project__c ( Id = project.Id, Grant_Completion__c = completeDate);
		update project;
		projectResult = MyProjects2Controller.getProjects('Grants', 'Active', filters)[0];
		System.assertEquals(completeDate, projectResult.Grant_Completion__c);
		
		Test.stopTest();
	}
	
	static testMethod void newProject_setDates_datesSet() {
		
		PM_Project__c project = new PM_Project__c ( Name = 'Test Project' );
		insert project;
		
		Test.setCurrentPage(Page.MyProjects2);
		MyProjects2Controller controller = new MyProjects2Controller();
	
		Datetime kickoff = DateTime.newInstance(2012,5,5,12,0,0);
		Date install = kickoff.date().addDays(90);
		Datetime inspection = DateTime.newInstance(2012,5,5,11,30,0);
		
		Test.startTest();

		MyProjects2Controller.setProjectDate(project.Id, 'Kickoff__c', String.valueOf(kickoff.getTime()));
		MyProjects2Controller.setProjectDate(project.Id, 'Install__c', '' + Datetime.newInstance(install.year(), install.month(), install.day()).getTime());
		MyProjects2Controller.setProjectDate(project.Id, 'Inspection__c', String.valueOf(inspection.getTime()));
		
		project = [SELECT Id, Kickoff__c, Install__c, Inspection__c FROM PM_Project__c WHERE Id = :project.Id];
		System.assertEquals(kickoff, project.Kickoff__c);
		System.assertEquals(install, project.Install__c);
		System.assertEquals(inspection, project.Inspection__c);

		MyProjects2Controller.setProjectDate(project.Id, 'Kickoff__c', null);
		MyProjects2Controller.setProjectDate(project.Id, 'Install__c', '');

		project = [SELECT Id, Kickoff__c, Install__c, Inspection__c FROM PM_Project__c WHERE Id = :project.Id];
		System.assertEquals(null, project.Kickoff__c);
		System.assertEquals(null, project.Install__c);

		Test.stopTest();
	}

	static testMethod void newProject_addCustomerAction_actionSet() {
		
		PM_Project__c project = new PM_Project__c ( Name = 'Test Project' );
		insert project;
		
		Test.setCurrentPage(Page.MyProjects2);
		MyProjects2Controller controller = new MyProjects2Controller();

		String customerNote = 'Customer must remove trees';
		
		project = [SELECT Id, Customer_Action_Notes__c, Customer_Action_Resolved__c FROM PM_Project__c WHERE Id = :project.Id];
		System.assertEquals(null, project.Customer_Action_Notes__c);	
		System.assertEquals(false, project.Customer_Action_Resolved__c);	
		
		Test.startTest();
		
		MyProjects2Controller.updateCustomerAction(project.Id, customerNote, true);
		
		Test.stopTest();
		
		project = [SELECT Id, Customer_Action_Notes__c, Customer_Action_Resolved__c FROM PM_Project__c WHERE Id = :project.Id];
		System.assertEquals(customerNote, project.Customer_Action_Notes__c);	
		System.assertEquals(true, project.Customer_Action_Resolved__c);	
	}
	
	static testMethod void newProject_readyForInstall_readySet() {
		
		PM_Project__c project = new PM_Project__c ( Name = 'Test Project' );
		insert project;
		
		Test.setCurrentPage(Page.MyProjects2);
		MyProjects2Controller controller = new MyProjects2Controller();

		project = [SELECT Id, Ready_for_Install__c FROM PM_Project__c WHERE Id = :project.Id];
		System.assertEquals(false, project.Ready_for_Install__c);	
		
		Test.startTest();
		
		MyProjects2Controller.setReadyForInstall(project.Id, true);

		project = [SELECT Id, Ready_for_Install__c FROM PM_Project__c WHERE Id = :project.Id];
		System.assertEquals(true, project.Ready_for_Install__c);	

		MyProjects2Controller.setReadyForInstall(project.Id, false);

		project = [SELECT Id, Ready_for_Install__c FROM PM_Project__c WHERE Id = :project.Id];
		System.assertEquals(false, project.Ready_for_Install__c);	
		
		Test.stopTest();
		
	}

	static testMethod void noFilter_setDefault_set() {
		
		MyProjects2Controller controller = new MyProjects2Controller();

		List<String> filters = controller.getDefaultFilter();
		System.assertEquals(0, filters.size());
		
		MyProjects2Controller.setDefaultFilter('state', 'NJ;PA');
		
		filters = controller.getDefaultFilter();
		System.assertEquals('state:NJ;PA', filters[0]);

		MyProjects2Controller.setDefaultFilter('status', 'Active;New');
		
		filters = controller.getDefaultFilter();
		System.assertEquals('status:Active;New', filters[0]);
		System.assertEquals(2, filters.size());
		
	}
	
	static testMethod void gCal_synch_test() {

		Datetime kickoff = DateTime.newInstance(2012,5,5,12,0,0);
		Date install = kickoff.date().addDays(90);
		Datetime inspection = DateTime.newInstance(2012,5,5,11,30,0);

		PM_Project__c project = new PM_Project__c ( 
			Name = 'Test Project',
			Kickoff__c = kickoff,
			Install__c = install,
			Inspection__c = inspection,
			Project_Lead__c = UserInfo.getUserId()
		);			
		insert project;
		
		Test.setCurrentPage(Page.MyProjects2);
		MyProjects2Controller controller = new MyProjects2Controller();
	
		Test.startTest();
		
		controller.synchronizeEvents();
			
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
		MyProjects2Controller.updateSurveyEventDate(project.Id, surveyDate.format());
		
		project = [SELECT Id
					, Survey_Date__c
					, (SELECT StartDateTime FROM Events) 
					FROM PM_Project__c 
					WHERE Id = :project.Id];
		
		System.assertEquals(surveyDate, project.Events[0].StartDateTime);
		
		Test.stopTest();
	}

	static testmethod void getfiltersTest(){

		MyProjects2Controller controller = new MyProjects2Controller();
		controller.getOperationsSurveyors();
		controller.getElecDesigners();
		controller.getEngineers();
		controller.getReadyForInstall();
		controller.getSOStatuses();

	}	

}