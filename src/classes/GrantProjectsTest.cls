/* FILE: GrantProjectsTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: June 11, 2012
 * PURPOSE: Test class for 3 GrantProjectsBase component
 * MODIFICATION HISTORY
 *
 */

@isTest
public class GrantProjectsTest {

	static testMethod void twoProjects_load_hasColumns() {
		
		DocumentBinTest.createBinConfiguration();
		
		Account customer = new Account(Name = 'Test Customer');
		insert customer;
		Property__c property = CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');
		SCRB_SalesOrder__c salesOrder = CreateAstrumPM2ProjectTest.createSalesOrder(property.Id, null);
		
		PM_Project__c project1 = new PM_Project__c ( Name = 'Test Project 1', Sales_Order__c = salesOrder.Id );
		insert project1;
		PM_Project__c project2 = new PM_Project__c ( Name = 'Test Project 2', Status__c = 'Active' );
		insert project2;
		
		GrantProjectsController controller = new GrantProjectsController();
	
		System.assertEquals(1, GrantProjectsController.binConfig.size());	
		System.assertEquals(3, GrantProjectsController.specialCategories.size());	
		System.assertNotEquals(0, controller.getStates().size());
		
		List<String> allFilter = new List<String> { 'state:All' };	
		List<String> paFilter = new List<String> { 'state:PA' };	
		
		Test.startTest();
		
		List<PM_Project__c> newProjects = GrantProjectsController.getProjects('Grants', 'New', paFilter);
		List<PM_Project__c> activeProjects = GrantProjectsController.getProjects('Grants', 'Active', allFilter);
		List<PM_Project__c> cancelledProjects = GrantProjectsController.getProjects('Grants', 'Cancelled', allFilter);
		
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
		
		Test.setCurrentPage(Page.PMProjectDetail);
		GrantProjectsController controller = new GrantProjectsController();

		List<String> filters = new List<String> { 'states:All' };	

		Test.startTest();

		//prepared
		PM_Project__c projectResult = GrantProjectsController.getProjects('Grants', 'Active', filters)[0];
		System.assertEquals(prepareDate.addYears(2000), projectResult.Grant_Completion__c);
		
		//signed
		project = new PM_Project__c ( Id = project.Id, Grant_Completion_Signed__c = signDate);
		update project;
		projectResult = GrantProjectsController.getProjects('Grants', 'Active', filters)[0];
		System.assertEquals(signDate.addYears(4000), projectResult.Grant_Completion__c);
			
		//submitted
		project = new PM_Project__c ( Id = project.Id, Grant_Completion_Submitted__c = submitDate);
		update project;
		projectResult = GrantProjectsController.getProjects('Grants', 'Active', filters)[0];
		System.assertEquals(submitDate.addYears(6000), projectResult.Grant_Completion__c);

		//approved
		project = new PM_Project__c ( Id = project.Id, Grant_Completion__c = completeDate);
		update project;
		projectResult = GrantProjectsController.getProjects('Grants', 'Active', filters)[0];
		System.assertEquals(completeDate, projectResult.Grant_Completion__c);
		
		Test.stopTest();
	}
	
	static testMethod void noSettings_addSetting_settingAdded() {
		
		GrantProjectsController controller = new GrantProjectsController();
		
		String setting = 'MD;PA';

		Test.startTest();
				
		GrantProjectsController.setStateSettings(setting);
		System.assertEquals(setting, controller.getStateSettings());

		setting = 'PA';	
		GrantProjectsController.setStateSettings(setting);
		System.assertEquals(setting, controller.getStateSettings());
		
		Test.stopTest();
	}
	
	static testMethod void newProject_setFields_fieldsSet() {
		
		PM_Project__c project = new PM_Project__c ( Name = 'Test Project' );
		insert project;
		
		Decimal reservationAmount = 3500;
		String reservationNumber = 'A-230493';
		
		Test.startTest();
		
		GrantProjectsController.setProjectField(project.Id, 'Grant_Reservation_Amount__c', String.valueOf(reservationAmount));
		GrantProjectsController.setProjectField(project.Id, 'Grant_Reservation_Number__c', reservationNumber);
				
		project = [SELECT Id, Grant_Reservation_Amount__c, Grant_Reservation_Number__c FROM PM_Project__c WHERE Id = :project.Id];
		System.assertEquals(reservationAmount, project.Grant_Reservation_Amount__c);
		System.assertEquals(reservationNumber, project.Grant_Reservation_Number__c);
		
		GrantProjectsController.setProjectField(project.Id, 'Grant_Reservation_Amount__c', null);
		GrantProjectsController.setProjectField(project.Id, 'Grant_Reservation_Number__c', '');

		project = [SELECT Id, Grant_Reservation_Amount__c, Grant_Reservation_Number__c FROM PM_Project__c WHERE Id = :project.Id];
		System.assertEquals(null, project.Grant_Reservation_Amount__c);
		System.assertEquals(null, project.Grant_Reservation_Number__c);
				
		Test.stopTest();
		
	}
}