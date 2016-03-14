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
private class Milestone1_Milestone_Autocomplete_Test {

    public static testMethod void testIsMilestoneReadyForAutoCompleteWhenOneTaskIsNotComplete() {

		// setup
		Milestone1_Milestone__c ms1 = createMilestone();	
				
        //create tasks linked to milestones
        Integer numberOfTasks = 3;
        List<Milestone1_Task__c> tasks = getSampleTasks(ms1, numberOfTasks, true);
		
		// change first task to incomplete
		tasks[0].Complete__c = false;
		tasks[0].Complete_Date__c = null;
		                				
		// execute		
        insert tasks;
		
		// assert
		Boolean expected = false;
		
		Milestone1_Milestone__c testMilestone = [Select Name, Complete__c, Complete_Date__c from Milestone1_Milestone__c where id = :ms1.id LIMIT 1];
		System.assertEquals(expected, testMilestone.Complete__c);
    }

    public static testMethod void testIsMilestoneReadyForAutoCompleteWhenNoTaskIsComplete() {

		// setup
		Milestone1_Milestone__c ms1 = createMilestone();	
				
        //create tasks linked to milestones
        Integer numberOfTasks = 3;        
        List<Milestone1_Task__c> tasks = getSampleTasksNotComplete(ms1, numberOfTasks);				                
				
		// execute		
        insert tasks;
		
		// assert
		Boolean expected = false;
		
		Milestone1_Milestone__c testMilestone = [Select Name, Complete__c, Complete_Date__c from Milestone1_Milestone__c where id = :ms1.id LIMIT 1];
		System.assertEquals(expected, testMilestone.Complete__c);
    }
	
    public static testMethod void testGetMilestonesForTasks() {

		Integer expectedSize = 1;
		
		// setup
		Milestone1_Milestone__c ms1 = createMilestone();	
				
        //create tasks linked to milestones
        Integer numberOfTasks = 3;        
        List<Milestone1_Task__c> tasks = getSampleTasksNotComplete(ms1, numberOfTasks);
        insert tasks;
				
		// execute
		Map<Id, Milestone1_Milestone__c> milestones = Milestone1_Task_Trigger_Utility.getMilestonesForTasks(tasks);
		Integer actualSize = milestones.values().size();
		
		// assert
		System.assertEquals(expectedSize, actualSize);
    }


    public static testMethod void testGetAllTasksForMilestones() {

		Integer expectedMilestoneCount = 1;
				
		// setup
		Milestone1_Milestone__c ms1 = createMilestone();	
				
        //create tasks linked to milestones
        Integer numberOfTasks = 3;        
        List<Milestone1_Task__c> tasks = getSampleTasksNotComplete(ms1, numberOfTasks);
        insert tasks;
				
		// execute
		List<Milestone1_Milestone__c> milestones = new List<Milestone1_Milestone__c>();
		milestones.add(ms1);
				
		Map<Id, List<Milestone1_Task__c>> milestoneMap = Milestone1_Task_Trigger_Utility.getAllTasksForMilestones(milestones);
		Integer milestoneCount = milestoneMap.keySet().size();
		
		Integer tasksCount = getTotalTaskCount(milestoneMap);
				
		// assert
		System.assertEquals(expectedMilestoneCount, milestoneCount);
		System.assertEquals(numberOfTasks, tasksCount);
    }
	
    
	private static Milestone1_Milestone__c createMilestone() {
        //create Property
        Property__c prop = new Property__c();
        prop.Name = '123 Main St';       
        prop.Optimal_Site_Quality_kWh_y_kW__c = double.valueOf('1250');
        prop.Property_State__c = 'MD';
        prop.Property_City__c = 'Annapolis Junction';
        prop.Property_ZIP__c = '20701';
        prop.Permit_Jurisdiction__c = 'Howard';
        prop.Property_County__c = 'Howard';
        prop.Astrum_Office__c = testdata.defaultOffLocationName;// FPO Phase4 //'Annapolis Junction, MD';
        insert prop;
        
        //create sales order
        SCRB_SalesOrder__c order = new SCRB_SalesOrder__c();
        order.name = 'SO-TEST';
        order.StatusCode__c = 'Submitted';
        order.Property__c = prop.id;
        
        insert order; 
	
        Milestone1_Project__c proj = new Milestone1_Project__c();
        proj.name = 'proj-test';
        proj.Sales_Order__c = order.id;        
        insert proj;
        
        //create a milestone
        Milestone1_Milestone__c ms1 = Milestone1_Test_Utility.sampleMilestone(proj);
		insert ms1;
		
		return ms1;
	}    
	
	private static Integer getTotalTaskCount(Map<Id, List<Milestone1_Task__c>> milestoneMap) {
		
		Integer tasksCount = 0;		
		for (Id tempMilestoneId : milestoneMap.keySet()) {
			List<Milestone1_Task__c> theTasks = milestoneMap.get(tempMilestoneId);
			tasksCount += theTasks.size();	
		}

		return tasksCount;		
	}
	
	private static List<Milestone1_Task__c> getSampleTasks(Milestone1_Milestone__c milestone, Integer numberOfTasks, Boolean allComplete) {
        List<Milestone1_Task__c> tasks = new List<Milestone1_Task__c>();
        
        for(Integer i = 0; i < numberOfTasks; i++){
            Id parentMilestoneId = milestone.Id;
            Milestone1_Task__c taskRec = Milestone1_Test_Utility.sampleTask(parentMilestoneId);
            tasks.add(taskRec);
			
			// complete the task 
			if (allComplete) {           
				taskRec.Complete__c = true;
				taskRec.Complete_Date__c = Date.today();
			}
        }
		
		return tasks;
	}
	
	private static List<Milestone1_Task__c> getSampleTasksNotComplete(Milestone1_Milestone__c milestone, Integer numberOfTasks) {
		Boolean complete = false;
		return getSampleTasks(milestone, numberOfTasks, complete);
	}
	
}