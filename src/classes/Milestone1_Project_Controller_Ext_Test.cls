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
private class Milestone1_Project_Controller_Ext_Test {

    public static testMethod void test_Fact_Sheet_Controller(){
      // create a sample task
      Milestone1_Project__c project = Milestone1_Test_Utility.sampleProjectWithUtilityBill('test-proj', false);
      insert project;

      ApexPages.Standardcontroller standController = new ApexPages.Standardcontroller(project);
      Fact_Sheet_Controller_Extension fsce = new Fact_Sheet_Controller_Extension(standController);
    }

    public static testMethod void testTaskListTab() {
		
    	// create a sample task
		Milestone1_Project__c project = Milestone1_Test_Utility.sampleProjectWithUtilityBill('test-proj', false);
    	insert project;
    			    	
		Milestone1_Milestone__c milestone = Milestone1_Test_Utility.sampleMilestone(project);
		insert milestone;
    
    Test.startTest();

    	Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(milestone);
    	
    	Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(milestone);
    	
		List<Milestone1_Task__c> theTasks = new List<Milestone1_Task__c>();
		theTasks.add(task1);
		theTasks.add(task2);
		insert theTasks;
		
		ApexPages.Standardcontroller standController = new ApexPages.Standardcontroller(project);
		Milestone1_Project_Controller_Extension projectController = new Milestone1_Project_Controller_Extension(standController);
  		
  		List<TaskDetailHolder> taskDetailHolders = projectController.taskDetailHolders;
  		
  		Integer expectedTasks = 2;
  		System.assertEquals(expectedTasks, taskDetailHolders.size());
  		
  		Test.stopTest();
    }      
    
    public static testMethod void computeMilestoneColor_AllTasksCompleteAndMilestoneComplete() {

    	// create a sample task
		Milestone1_Project__c project = Milestone1_Test_Utility.sampleProjectWithUtilityBill('test-proj', false);
    	insert project;
    			    	
		Milestone1_Milestone__c milestone = Milestone1_Test_Utility.sampleMilestone(project);
		insert milestone;
    
    Test.startTest();

    	Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(milestone);
    	task1.Complete__c = true;
    	task1.Complete_Date__c = Date.today();
    	
    	Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(milestone);
    	task2.Complete__c = true;
    	task2.Complete_Date__c = Date.today();
    	
		List<Milestone1_Task__c> theTasks = new List<Milestone1_Task__c>();
		theTasks.add(task1);
		theTasks.add(task2);
		insert theTasks;
		
		ApexPages.Standardcontroller standController = new ApexPages.Standardcontroller(project);
		Milestone1_Project_Controller_Extension projectController = new Milestone1_Project_Controller_Extension(standController);
  		
  		List<TaskDetailHolder> taskDetailHolders = projectController.taskDetailHolders;
  		
  		String expected = Milestone1_Project_Controller_Extension.COMPLETE_COLOR;
  		
  		for (TaskDetailHolder temp : taskDetailHolders) {
  			System.assertEquals(expected, temp.milestoneColor);	
  		}
  		
  		Test.stopTest();
    }      

    public static testMethod void computeMilestoneColor_MilestoneNotComplete() {
		
    	// create a sample task
		Milestone1_Project__c project = Milestone1_Test_Utility.sampleProjectWithUtilityBill('test-proj', false);
    	insert project;
    			    	
		Milestone1_Milestone__c milestone = Milestone1_Test_Utility.sampleMilestone(project);
		insert milestone;
    
    Test.startTest();

    	Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(milestone);
    	task1.Complete__c = true;
    	task1.Complete_Date__c = Date.today();
    	
    	Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(milestone);
    	task2.Complete__c = false;
    	
		List<Milestone1_Task__c> theTasks = new List<Milestone1_Task__c>();
		theTasks.add(task1);
		theTasks.add(task2);
		insert theTasks;
		
		ApexPages.Standardcontroller standController = new ApexPages.Standardcontroller(project);
		Milestone1_Project_Controller_Extension projectController = new Milestone1_Project_Controller_Extension(standController);
  		
  		List<TaskDetailHolder> taskDetailHolders = projectController.taskDetailHolders;
  		
  		String expected = Milestone1_Project_Controller_Extension.OPEN_COLOR;
  		
  		for (TaskDetailHolder temp : taskDetailHolders) {
  			System.assertEquals(expected, temp.milestoneColor);	
  		}
  		
  		Test.stopTest();
    }      

    public static testMethod void computeMilestoneColor_TaskBlocked() {
		
    	// create a sample task
		Milestone1_Project__c project = Milestone1_Test_Utility.sampleProjectWithUtilityBill('test-proj', false);
    	insert project;
    			    	
		Milestone1_Milestone__c milestone = Milestone1_Test_Utility.sampleMilestone(project);
		insert milestone;
    
    Test.startTest();

    	Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(milestone);
    	task1.Complete__c = false;
    	task1.Blocked__c = true;
    	task1.Blocked_Reason__c = 'test';
    	
    	Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(milestone);
    	task2.Complete__c = false;
    	task2.Blocked__c = true;
    	task2.Blocked_Reason__c = 'test';
    	
		List<Milestone1_Task__c> theTasks = new List<Milestone1_Task__c>();
		theTasks.add(task1);
		theTasks.add(task2);
		insert theTasks;
		
		ApexPages.Standardcontroller standController = new ApexPages.Standardcontroller(project);
		Milestone1_Project_Controller_Extension projectController = new Milestone1_Project_Controller_Extension(standController);
  		
  		List<TaskDetailHolder> taskDetailHolders = projectController.taskDetailHolders;
  		
  		String expected = Milestone1_Project_Controller_Extension.LATE_BLOCKED_COLOR;
  		
  		for (TaskDetailHolder temp : taskDetailHolders) {
  			System.assertEquals(expected, temp.milestoneColor);	
  		}
  		
  		Test.stopTest();
    }      

    public static testMethod void computeTaskColor_TaskComplete() {
		
    	// create a sample task
		Milestone1_Project__c project = Milestone1_Test_Utility.sampleProjectWithUtilityBill('test-proj', false);
    	insert project;
    			    	
		Milestone1_Milestone__c milestone = Milestone1_Test_Utility.sampleMilestone(project);
		insert milestone;
    
    Test.startTest();

    	Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(milestone);
    	task1.Complete__c = true;
    	task1.Complete_Date__c = Date.today();
    	
    	Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(milestone);
    	task2.Complete__c = true;
    	task2.Complete_Date__c = Date.today();
    	
		List<Milestone1_Task__c> theTasks = new List<Milestone1_Task__c>();
		theTasks.add(task1);
		theTasks.add(task2);
		insert theTasks;
		
		ApexPages.Standardcontroller standController = new ApexPages.Standardcontroller(project);
		Milestone1_Project_Controller_Extension projectController = new Milestone1_Project_Controller_Extension(standController);
  		
  		List<TaskDetailHolder> taskDetailHolders = projectController.taskDetailHolders;
  		
  		String expected = Milestone1_Project_Controller_Extension.COMPLETE_COLOR;
  		
  		for (TaskDetailHolder temp : taskDetailHolders) {
  			System.assertEquals(expected, temp.taskColor);	
  		}
  		
  		Test.stopTest();
    }      


    public static testMethod void computeTaskColor_TaskNotComplete() {
		
    	// create a sample task
		Milestone1_Project__c project = Milestone1_Test_Utility.sampleProjectWithUtilityBill('test-proj', false);
    	insert project;
    			    	
		Milestone1_Milestone__c milestone = Milestone1_Test_Utility.sampleMilestone(project);
		insert milestone;
    
    Test.startTest();

    	Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(milestone);
    	task1.Complete__c = false;
    	
    	Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(milestone);
    	task2.Complete__c = false;
    	
		List<Milestone1_Task__c> theTasks = new List<Milestone1_Task__c>();
		theTasks.add(task1);
		theTasks.add(task2);
		insert theTasks;
		
		ApexPages.Standardcontroller standController = new ApexPages.Standardcontroller(project);
		Milestone1_Project_Controller_Extension projectController = new Milestone1_Project_Controller_Extension(standController);
  		
  		List<TaskDetailHolder> taskDetailHolders = projectController.taskDetailHolders;
  		
  		String expected = Milestone1_Project_Controller_Extension.OPEN_COLOR;
  		
  		for (TaskDetailHolder temp : taskDetailHolders) {
  			System.assertEquals(expected, temp.taskColor);	
  		}
  		
  		Test.stopTest();
    }      

    public static testMethod void computeTaskColor_TaskBlocked() {
		
    	// create a sample task
		Milestone1_Project__c project = Milestone1_Test_Utility.sampleProjectWithUtilityBill('test-proj', false);
    	insert project;
    			    	
		Milestone1_Milestone__c milestone = Milestone1_Test_Utility.sampleMilestone(project);
		insert milestone;
    
    Test.startTest();

    	Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(milestone);
    	task1.Complete__c = false;
    	task1.Blocked__c = true;
    	task1.Blocked_Reason__c = 'test';
    	
    	Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(milestone);
    	task2.Complete__c = false;
    	task2.Blocked__c = true;
    	task2.Blocked_Reason__c = 'test';
    	
		List<Milestone1_Task__c> theTasks = new List<Milestone1_Task__c>();
		theTasks.add(task1);
		theTasks.add(task2);
		insert theTasks;
		
		ApexPages.Standardcontroller standController = new ApexPages.Standardcontroller(project);
		Milestone1_Project_Controller_Extension projectController = new Milestone1_Project_Controller_Extension(standController);
  		
  		List<TaskDetailHolder> taskDetailHolders = projectController.taskDetailHolders;
  		
  		String expected = Milestone1_Project_Controller_Extension.LATE_BLOCKED_COLOR;
  		
  		for (TaskDetailHolder temp : taskDetailHolders) {
  			System.assertEquals(expected, temp.taskColor);	
  		}
  		
  		Test.stopTest();
    }      
    
}