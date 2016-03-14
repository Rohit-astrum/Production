/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class My_Projects_Controller_Extension_Test {

    public static testMethod void testRetrieveOnlyActiveProjects() {

		String expectedStatus = 'Active';
		
		// setup
		Id userId = UserInfo.getUserId();
		
		String activeProjectName = '1600 Pennsylvania Ave - Active';
		String inactiveProjectName = '1200 Main St - Inactive';
		Map<String, Milestone1_Project__c> projects = Milestone1_Test_Utility.sampleProjectOneOfEach(activeProjectName, inactiveProjectName);
		Milestone1_Project__c activeProject = projects.get(activeProjectName);
		activeProject.OwnerId = userId;		
		Milestone1_Project__c inactiveProject = projects.get(inactiveProjectName);
		inactiveProject.OwnerId = userId;		
		insert projects.values();

		Milestone1_Milestone__c milestone = Milestone1_Test_Utility.sampleMilestone(activeProject);
		milestone.Workflow_Key__c = 'HOA';

		Milestone1_Milestone__c milestone2 = Milestone1_Test_Utility.sampleMilestone(activeProject);
		milestone2.Workflow_Key__c = 'permits';

		List<Milestone1_Milestone__c> milestones = new List<Milestone1_Milestone__c>();
		milestones.add(milestone);
		milestones.add(milestone2);
		insert milestones;

		Test.startTest();

    	Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(milestone);
    	task1.Workflow_Key__c = 't_hoa_submitted';
    	
    	Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(milestone);
    	task2.Workflow_Key__c = 't_hoa_submitted';
    	
		List<Milestone1_Task__c> theTasks = new List<Milestone1_Task__c>();
		theTasks.add(task1);
		theTasks.add(task2);
		insert theTasks;

		// 
		// setup for web
		PageReference page = new PageReference('My_Projects');
		Test.setCurrentPage(page);
		
		// execute
		ApexPages.Standardcontroller standController = new ApexPages.Standardcontroller(new Milestone1_Project__c());
		My_Projects_Controller_Extension myProjController = new My_Projects_Controller_Extension(standController);
				
		// assert data
		List<Milestone1_Project__c> activeProjects = myProjController.projects;
		
		// confirm only active projects for this user
		for (Milestone1_Project__c tempProj : activeProjects) {
			String tempStatus = tempProj.Status__c;
			String tempOwnerId = tempProj.OwnerId;
			
			System.assertEquals(expectedStatus, tempStatus);			
			System.assertEquals(userId, tempOwnerId);			
		}

		Test.stopTest();
    }
  
    public static testMethod void testIsHoaRequired() {
  		Boolean expected = true;
  		
  		String data = 'Unknown;HOA;Historical Area';
		
		ApexPages.Standardcontroller standController = new ApexPages.Standardcontroller(new Milestone1_Project__c());
		My_Projects_Controller_Extension myProjController = new My_Projects_Controller_Extension(standController);
  		
		// execute
  		Boolean actual = myProjController.isHoaRequired(data);
  		
  		System.assertEquals(expected, actual);		
    }      
    
    public static testMethod void testIsHoaRequiredWithEmptyString() {
  		Boolean expected = false;
  		
  		String data = '';

		ApexPages.Standardcontroller standController = new ApexPages.Standardcontroller(new Milestone1_Project__c());
		My_Projects_Controller_Extension myProjController = new My_Projects_Controller_Extension(standController);
  		
		// execute
  		Boolean actual = myProjController.isHoaRequired(data);
  		
  		System.assertEquals(expected, actual);		
    }      

    public static testMethod void testIsHoaRequiredWithSingleEntryNegative() {
  		Boolean expected = false;
  		
  		String data = 'Other';

		ApexPages.Standardcontroller standController = new ApexPages.Standardcontroller(new Milestone1_Project__c());
		My_Projects_Controller_Extension myProjController = new My_Projects_Controller_Extension(standController);
  		
		// execute
  		Boolean actual = myProjController.isHoaRequired(data);
  		
  		System.assertEquals(expected, actual);		
    }      

    public static testMethod void testIsHoaRequiredWithSingleEntryPositive() {
  		Boolean expected = true;
  		
  		String data = 'HOA';
		
		ApexPages.Standardcontroller standController = new ApexPages.Standardcontroller(new Milestone1_Project__c());
		My_Projects_Controller_Extension myProjController = new My_Projects_Controller_Extension(standController);
  		
		// execute
  		Boolean actual = myProjController.isHoaRequired(data);
  		
  		System.assertEquals(expected, actual);		
    }         
}