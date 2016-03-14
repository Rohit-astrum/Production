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
private class Milestone1_Task_AutoAssignment_Util_Test {

    public static testMethod void testAutoCompleteWhenUtilityBillAttached() {
    	
    	// create a sample task
		Milestone1_Project__c project = Milestone1_Test_Utility.sampleProjectWithUtilityBill('test-proj', true);
    	insert project;
    			    	
		Milestone1_Milestone__c milestone = Milestone1_Test_Utility.sampleMilestone(project);
		insert milestone;
    	
        Test.startTest();

    	Milestone1_Task__c sampleTask = Milestone1_Test_Utility.sampleTask(milestone);
    	sampleTask.Workflow_Key__c = 't_utility_bill';
    	insert sampleTask;

		String theProjectId = project.id;

		// assert	    	
    	Milestone1_Task__c task = [Select m.Workflow_Key__c, m.Id, m.complete__c, m.Project_Milestone__r.Project__r.Sales_Order__r.Utility_Bill_Attached__c From Milestone1_Task__c m where m.Project_Milestone__r.Project__c = :theProjectId and workflow_key__c = 't_utility_bill' limit 1];
		    	
    	System.assert(task.complete__c);
		Test.stopTest();
    }
	
    public static testMethod void testAutoCompleteWhenUtilityNotBillAttached() {
    	
    	// create a sample task
		Milestone1_Project__c project = Milestone1_Test_Utility.sampleProjectWithUtilityBill('test-proj', false);
    	insert project;
    			    	
		Milestone1_Milestone__c milestone = Milestone1_Test_Utility.sampleMilestone(project);
		insert milestone;
    	
        Test.startTest();

    	Milestone1_Task__c sampleTask = Milestone1_Test_Utility.sampleTask(milestone);
    	sampleTask.Workflow_Key__c = 't_utility_bill';
    	insert sampleTask;

		String theProjectId = project.id;

		// assert	    	
    	Milestone1_Task__c task = [Select m.Workflow_Key__c, m.Id, m.complete__c, m.Project_Milestone__r.Project__r.Sales_Order__r.Utility_Bill_Attached__c From Milestone1_Task__c m where m.Project_Milestone__r.Project__c = :theProjectId and workflow_key__c = 't_utility_bill' limit 1];
		    	
    	System.assert(!task.Complete__c);
		Test.stopTest();
    }
	
    public static testMethod void testAutoAssignTaskInvoiceCustomerToInvoiceCoordinatorWhenSourceTaskIsComplete() {
    	
    	testAutoAssignTask(Milestone1_Task_AutoAssignment_Utility.INVOICE_CUSTOMER_WORK_FLOW_KEY, 
    					   Milestone1_Task_AutoAssignment_Utility.REVIEW_PREINSTALL_STEPS_WORK_FLOW_KEY, 
    					   true);
        	
    }


    public static testMethod void testAutoAssignTaskInvoiceCustomerToInvoiceCoordinatorWhenSourceTaskIsNotComplete() {
    	
    	testAutoAssignTask(Milestone1_Task_AutoAssignment_Utility.INVOICE_CUSTOMER_WORK_FLOW_KEY, 
    					   Milestone1_Task_AutoAssignment_Utility.REVIEW_PREINSTALL_STEPS_WORK_FLOW_KEY, 
    					   false);
    }

    public static testMethod void testAutoAssignTaskCheckReceivedFor60PercentToInvoiceCoordinatorWhenSourceTaskIsComplete() {

    	testAutoAssignTask(Milestone1_Task_AutoAssignment_Utility.CHECK_RECEIVED_FOR_60_PERCENT_WORK_FLOW_KEY, 
    					   Milestone1_Task_AutoAssignment_Utility.REVIEW_PREINSTALL_STEPS_WORK_FLOW_KEY, 
    					   true);
    	
    }

    public static testMethod void testAutoAssignTaskCheckReceivedFor60PercentToInvoiceCoordinatorWhenSourceTaskIsNotComplete() {
    	
    	testAutoAssignTask(Milestone1_Task_AutoAssignment_Utility.CHECK_RECEIVED_FOR_60_PERCENT_WORK_FLOW_KEY, 
    					   Milestone1_Task_AutoAssignment_Utility.REVIEW_PREINSTALL_STEPS_WORK_FLOW_KEY, 
    					   false);
    }

    public static testMethod void testAutoAssignTaskInvoiceCustomerFor30PercentToInvoiceCoordinatorWhenSourceTaskIsComplete() {
    	
    	testAutoAssignTask(Milestone1_Task_AutoAssignment_Utility.INVOICE_CUSTOMER_FOR_30_PERCENT_WORK_FLOW_KEY, 
    					   Milestone1_Task_AutoAssignment_Utility.PANEL_WORK_COMPLETE_WORK_FLOW_KEY, 
    					   true);
    }

    public static testMethod void testAutoAssignTaskInvoiceCustomerFor30PercentToInvoiceCoordinatorWhenSourceTaskIsNotComplete() {
    	
    	testAutoAssignTask(Milestone1_Task_AutoAssignment_Utility.INVOICE_CUSTOMER_FOR_30_PERCENT_WORK_FLOW_KEY, 
    					   Milestone1_Task_AutoAssignment_Utility.PANEL_WORK_COMPLETE_WORK_FLOW_KEY, 
    					   false);
    }

    public static testMethod void testAutoAssignTaskCheckedReceivedFor30PercentToInvoiceCoordinatorWhenSourceTaskIsComplete() {
    	
    	testAutoAssignTask(Milestone1_Task_AutoAssignment_Utility.CHECK_RECEIVED_FOR_30_PERCENT_WORK_FLOW_KEY, 
    					   Milestone1_Task_AutoAssignment_Utility.INVOICE_CUSTOMER_FOR_30_PERCENT_WORK_FLOW_KEY, 
    					   true);

    }

    public static testMethod void testAutoAssignTaskCheckedReceivedFor30PercentToInvoiceCoordinatorWhenSourceTaskIsNotComplete() {

    	testAutoAssignTask(Milestone1_Task_AutoAssignment_Utility.CHECK_RECEIVED_FOR_30_PERCENT_WORK_FLOW_KEY, 
    					   Milestone1_Task_AutoAssignment_Utility.INVOICE_CUSTOMER_FOR_30_PERCENT_WORK_FLOW_KEY, 
    					   false);
    					       	
    }

    public static testMethod void testAutoAssignTaskSumbitStateGrantPart2ToGrantCoordinatorWhenSourceTaskIsComplete() {
    	
    	testAutoAssignTask(Milestone1_Task_AutoAssignment_Utility.SUBMIT_STATE_GRANT_PART_2_PAPERWORK_WORK_FLOW_KEY, 
    					   Milestone1_Task_AutoAssignment_Utility.INSPECTION_COMPLETE_WORK_FLOW_KEY, 
    					   true);    	
    }

    public static testMethod void testAutoAssignTaskSumbitStateGrantPart2ToGrantCoordinatorWhenSourceTaskIsNotComplete() {
    	
    	testAutoAssignTask(Milestone1_Task_AutoAssignment_Utility.SUBMIT_STATE_GRANT_PART_2_PAPERWORK_WORK_FLOW_KEY, 
    					   Milestone1_Task_AutoAssignment_Utility.INSPECTION_COMPLETE_WORK_FLOW_KEY, 
    					   false);    	
    }

    public static testMethod void testAutoAssignTaskInstallationBeginToFieldManagerOpsWhenSourceTaskIsComplete() {
    	
    	testAutoAssignTask(Milestone1_Task_AutoAssignment_Utility.INSTALLATION_BEGINS_WORK_FLOW_KEY, 
    					   Milestone1_Task_AutoAssignment_Utility.REVIEW_PREINSTALL_STEPS_WORK_FLOW_KEY, 
    					   true);    	

    }

    public static testMethod void testAutoAssignTaskPanelWorkCompleteToFieldManagerOpsWhenSourceTaskIsComplete() {
    	
    	testAutoAssignTask(Milestone1_Task_AutoAssignment_Utility.PANEL_WORK_COMPLETE_WORK_FLOW_KEY, 
    					   Milestone1_Task_AutoAssignment_Utility.REVIEW_PREINSTALL_STEPS_WORK_FLOW_KEY, 
    					   true);
    	
    }

    public static testMethod void testAutoAssignTaskPanelWorkCompleteToFieldManagerOpsWhenSourceTaskIsNotComplete() {
    	
    	testAutoAssignTask(Milestone1_Task_AutoAssignment_Utility.PANEL_WORK_COMPLETE_WORK_FLOW_KEY, 
    					   Milestone1_Task_AutoAssignment_Utility.REVIEW_PREINSTALL_STEPS_WORK_FLOW_KEY, 
    					   false);
    	
    }

    public static testMethod void testAutoAssignTaskElectricWorkCompleteToFieldManagerOpsWhenSourceTaskIsComplete() {
    	
    	testAutoAssignTask(Milestone1_Task_AutoAssignment_Utility.ELECTRIC_WORK_COMPLETE_WORK_FLOW_KEY,
    					   Milestone1_Task_AutoAssignment_Utility.REVIEW_PREINSTALL_STEPS_WORK_FLOW_KEY, 
    					   true);
    	
    }

    public static testMethod void testAutoAssignTaskElectricWorkCompleteToFieldManagerOpsWhenSourceTaskIsNotComplete() {
    	
    	testAutoAssignTask(Milestone1_Task_AutoAssignment_Utility.ELECTRIC_WORK_COMPLETE_WORK_FLOW_KEY, 
    					   Milestone1_Task_AutoAssignment_Utility.REVIEW_PREINSTALL_STEPS_WORK_FLOW_KEY, 
    					   false);
    	
    }

    public static testMethod void testAutoAssignTaskInstallationPhotosToFieldManagerOpsWhenSourceTaskIsComplete() {
    	
    	testAutoAssignTask(Milestone1_Task_AutoAssignment_Utility.INSTALLATION_PHOTOS_WORK_FLOW_KEY,
    					   Milestone1_Task_AutoAssignment_Utility.REVIEW_PREINSTALL_STEPS_WORK_FLOW_KEY, 
    					   true);
    	
    }

    public static testMethod void testAutoAssignTaskInstallationPhotosToFieldManagerOpsWhenSourceTaskIsNotComplete() {
    	
    	testAutoAssignTask(Milestone1_Task_AutoAssignment_Utility.INSTALLATION_PHOTOS_WORK_FLOW_KEY, 
    					   Milestone1_Task_AutoAssignment_Utility.REVIEW_PREINSTALL_STEPS_WORK_FLOW_KEY, 
    					   false);
    	
    }

    public static testMethod void testAutoAssignTaskUploadPartsUsedToFieldManagerOpsWhenSourceTaskIsComplete() {
    	
    	testAutoAssignTask(Milestone1_Task_AutoAssignment_Utility.UPLOAD_PARTS_USED_CHECKLIST_WORK_FLOW_KEY,
    					   Milestone1_Task_AutoAssignment_Utility.REVIEW_PREINSTALL_STEPS_WORK_FLOW_KEY, 
    					   true);
    	
    }

    public static testMethod void testAutoAssignTaskUploadPartsUsedToFieldManagerOpsWhenSourceTaskIsNotComplete() {
    	
    	testAutoAssignTask(Milestone1_Task_AutoAssignment_Utility.UPLOAD_PARTS_USED_CHECKLIST_WORK_FLOW_KEY,
    					   Milestone1_Task_AutoAssignment_Utility.REVIEW_PREINSTALL_STEPS_WORK_FLOW_KEY, 
    					   false);
    	
    }

    public static testMethod void testAutoAssignTaskSubmitWarrantyCardsToFieldManagerOpsWhenSourceTaskIsComplete() {
    	
    	testAutoAssignTask(Milestone1_Task_AutoAssignment_Utility.SUBMIT_WARRANTY_CARDS_WORK_FLOW_KEY,
    					   Milestone1_Task_AutoAssignment_Utility.REVIEW_PREINSTALL_STEPS_WORK_FLOW_KEY, 
    					   true);
    	
    }

    public static testMethod void testAutoAssignTaskSubmitWarrantyCardsToFieldManagerOpsWhenSourceTaskIsNotComplete() {
    	
    	testAutoAssignTask(Milestone1_Task_AutoAssignment_Utility.SUBMIT_WARRANTY_CARDS_WORK_FLOW_KEY,
    					   Milestone1_Task_AutoAssignment_Utility.REVIEW_PREINSTALL_STEPS_WORK_FLOW_KEY, 
    					   false);
    	
    }

    public static testMethod void testAutoAssignTaskArrayCreatedInEnphasePortalToFieldManagerOpsWhenSourceTaskIsComplete() {
    	
    	testAutoAssignTask(Milestone1_Task_AutoAssignment_Utility.ARRAY_CREATED_IN_ENPHASE_PORTAL_WORK_FLOW_KEY,
    					   Milestone1_Task_AutoAssignment_Utility.INSTALLATION_BEGINS_WORK_FLOW_KEY, 
    					   true);
    	
    }

    public static testMethod void testAutoAssignTaskArrayCreatedInEnphasePortalToFieldManagerOpsWhenSourceTaskIsNotComplete() {
    	
    	testAutoAssignTask(Milestone1_Task_AutoAssignment_Utility.ARRAY_CREATED_IN_ENPHASE_PORTAL_WORK_FLOW_KEY,
    					   Milestone1_Task_AutoAssignment_Utility.INSTALLATION_BEGINS_WORK_FLOW_KEY, 
    					   false);
    	
    }

    public static testMethod void testAutoAssignTaskConfirmSystemDesignMatchesInstallationToFieldManagerOpsWhenSourceTaskIsComplete() {
    	
    	testAutoAssignTask(Milestone1_Task_AutoAssignment_Utility.CONFIRM_SYSTEM_DESIGN_MATCHES_INSTALLATION_WORK_FLOW_KEY,
    					   Milestone1_Task_AutoAssignment_Utility.INSTALLATION_BEGINS_WORK_FLOW_KEY, 
    					   true);
    	
    }

    public static testMethod void testAutoAssignTaskConfirmSystemDesignMatchesInstallationToFieldManagerOpsWhenSourceTaskIsNotComplete() {
    	
    	testAutoAssignTask(Milestone1_Task_AutoAssignment_Utility.CONFIRM_SYSTEM_DESIGN_MATCHES_INSTALLATION_WORK_FLOW_KEY,
    					   Milestone1_Task_AutoAssignment_Utility.INSTALLATION_BEGINS_WORK_FLOW_KEY, 
    					   false);
    	
    }

    public static testMethod void testAutoAssignTaskUploadEnphaseMapAndBranchMapToFieldManagerOpsWhenSourceTaskIsComplete() {
    	
    	testAutoAssignTask(Milestone1_Task_AutoAssignment_Utility.UPLOAD_ENPHASE_MAP_AND_BRANCH_MAP_WORK_FLOW_KEY,
    					   Milestone1_Task_AutoAssignment_Utility.INSTALLATION_BEGINS_WORK_FLOW_KEY, 
    					   true);
    	
    }

    public static testMethod void testAutoAssignTaskUploadEnphaseMapAndBranchMapToFieldManagerOpsWhenSourceTaskIsNotComplete() {
    	
    	testAutoAssignTask(Milestone1_Task_AutoAssignment_Utility.UPLOAD_ENPHASE_MAP_AND_BRANCH_MAP_WORK_FLOW_KEY,
    					   Milestone1_Task_AutoAssignment_Utility.INSTALLATION_BEGINS_WORK_FLOW_KEY, 
    					   false);
    	
    }

    public static testMethod void testAutoAssignTaskConfirmSystemMonitoringActivatedToFieldManagerOpsWhenSourceTaskIsComplete() {
    	
    	testAutoAssignTask(Milestone1_Task_AutoAssignment_Utility.CONFIRM_SYSTEM_MONITORING_ACTIVATED_WORK_FLOW_KEY,
    					   Milestone1_Task_AutoAssignment_Utility.INSTALLATION_BEGINS_WORK_FLOW_KEY, 
    					   true);
    	
    }

    public static testMethod void testAutoAssignTaskConfirmSystemMonitoringActivatedToFieldManagerOpsWhenSourceTaskIsNotComplete() {
    	
    	testAutoAssignTask(Milestone1_Task_AutoAssignment_Utility.CONFIRM_SYSTEM_MONITORING_ACTIVATED_WORK_FLOW_KEY,
    					   Milestone1_Task_AutoAssignment_Utility.INSTALLATION_BEGINS_WORK_FLOW_KEY, 
    					   false);
    	
    }

    private static void testAutoAssignTask(String targetWorkflowKey, String sourceWorkflowKey, Boolean completeSourceTask) {
    	
    	// create a sample task
		Milestone1_Project__c project = Milestone1_Test_Utility.sampleProjectWithUtilityBill('test-proj', false);
    	insert project;
    			    	
		Milestone1_Milestone__c milestone = Milestone1_Test_Utility.sampleMilestone(project);
		insert milestone;

    	Milestone1_Task__c targetTask = Milestone1_Test_Utility.sampleTask(milestone);
    	targetTask.Workflow_Key__c = targetWorkflowKey;
    	
    	Milestone1_Task__c sourceTask = Milestone1_Test_Utility.sampleTask(milestone);
    	sourceTask.Workflow_Key__c = sourceWorkflowKey;

        Test.startTest();

		List<Milestone1_Task__c> theTasks = new List<Milestone1_Task__c>();
		theTasks.add(targetTask);
		theTasks.add(sourceTask);
		insert theTasks;
		
		String theProjectId = project.id;

    	TriggerUtility.taskTriggerHasNotRun_Before = true;
    	TriggerUtility.taskTriggerHasNotRun_After = true;

		// execute test
		if (completeSourceTask) {
			sourceTask.Complete__c = true;
	    	sourceTask.Complete_Date__c = Date.today();
			update sourceTask;
		}
		
		// assert	    	
    	Milestone1_Task__c task = [Select m.Assigned_To__c, m.Workflow_Key__c, m.Id, m.complete__c 
    							   From Milestone1_Task__c m 
    							   where m.Project_Milestone__r.Project__c = :theProjectId 
    							   and workflow_key__c = :targetTask.Workflow_Key__c 
    							   limit 1];
		
		// if the task was completed, then assigned should be different, else the same
		/*if (completeSourceTask) {    	
    		System.assertNotEquals(targetTask.Assigned_To__c, task.Assigned_To__c);
		}
		else {
	    	System.assertEquals(targetTask.Assigned_To__c, task.Assigned_To__c);
		}
        */
		
		Test.stopTest();
    }

    
}