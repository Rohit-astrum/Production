public with sharing class Milestone1_Task_AutoAssignment_Utility {

	private static final String COPY_OF_UTILITY_BILL_WORK_FLOW_KEY = 't_utility_bill';
	public static final String INVOICE_CUSTOMER_WORK_FLOW_KEY = 't_invoice_customer';
	public static final String REVIEW_PREINSTALL_STEPS_WORK_FLOW_KEY = 't_review_pre_dir_ops';
	public static final String CHECK_RECEIVED_FOR_60_PERCENT_WORK_FLOW_KEY = 't_check_received_for_60%';	
	public static final String INVOICE_CUSTOMER_FOR_30_PERCENT_WORK_FLOW_KEY = 't_final_30_invoice';
	public static final String CHECK_RECEIVED_FOR_30_PERCENT_WORK_FLOW_KEY = 't_final_30_received';		
	public static final String SUBMIT_STATE_GRANT_PART_2_PAPERWORK_WORK_FLOW_KEY = 't_grant_part2_submitted';
	public static final String PANEL_WORK_COMPLETE_WORK_FLOW_KEY = 't_panel_work_complete';
	public static final String INSPECTION_COMPLETE_WORK_FLOW_KEY = 't_inspection_complete';
	
	public static final String INSTALLATION_BEGINS_WORK_FLOW_KEY = 't_installation_begins';
	public static final String ELECTRIC_WORK_COMPLETE_WORK_FLOW_KEY = 't_electric_work_complete';
	public static final String INSTALLATION_PHOTOS_WORK_FLOW_KEY = 't_installation_photos';
	public static final String UPLOAD_PARTS_USED_CHECKLIST_WORK_FLOW_KEY = 't_parts_used_checklist';
	public static final String SUBMIT_WARRANTY_CARDS_WORK_FLOW_KEY = 't_sunpower_warranty_cards';
 
	public static final String ARRAY_CREATED_IN_ENPHASE_PORTAL_WORK_FLOW_KEY = 't_array_created_in_enphase_web';
	public static final String CONFIRM_SYSTEM_DESIGN_MATCHES_INSTALLATION_WORK_FLOW_KEY = 't_system_design_matches_instal';
	public static final String UPLOAD_ENPHASE_MAP_AND_BRANCH_MAP_WORK_FLOW_KEY = 't_upload_enphase_map';
	public static final String CONFIRM_SYSTEM_MONITORING_ACTIVATED_WORK_FLOW_KEY = 't_confirm_enphase_operating';
	
	public static void performTaskAutoAssignment(Milestone1_Task__c task, List<Milestone1_Task__c> tasksForThisMilestone, User accountingUser, User grantUser, User fieldManagerUser) {
	
		handleInvoiceCustomer(task, tasksForThisMilestone, accountingUser);
		handleCheckReceivedFor60Percent(task, tasksForThisMilestone, accountingUser);
		handleInvoiceCustomerFor30Percent(task, tasksForThisMilestone, accountingUser);
		handleCheckReceivedFor30Percent(task, tasksForThisMilestone, accountingUser);
		handleSubmitStateGrantPart2(task, tasksForThisMilestone, grantUser);
		
		if (fieldManagerUser != null) {
			handleInstallationBegins(task, tasksForThisMilestone, fieldManagerUser);
			handlePanelWorkComplete(task, tasksForThisMilestone, fieldManagerUser);
			handleElectricWorkComplete(task, tasksForThisMilestone, fieldManagerUser);
			handleInstallationPhotos(task, tasksForThisMilestone, fieldManagerUser);
			handleUploadPartsUsedChecklist(task, tasksForThisMilestone, fieldManagerUser);
			handleSubmitWarrantyCards(task, tasksForThisMilestone, fieldManagerUser);

			handleArrayCreatedInEnphasePortal(task, tasksForThisMilestone, fieldManagerUser);
			handleConfirmSystemDesignMatchesInstallation(task, tasksForThisMilestone, fieldManagerUser);
			handleUploadEnphaseMapAndBranchMap(task, tasksForThisMilestone, fieldManagerUser);
			handleConfirmSystemMonitoringActivated(task, tasksForThisMilestone, fieldManagerUser);
		}	
	}

    private static void handleReviewPreinstallSteps(Milestone1_Task__c task, User directorOpsUser) {
		if (directorOpsUser != null) {
			Boolean taskMatch = task.Workflow_Key__c == INSTALLATION_BEGINS_WORK_FLOW_KEY;
		
			if (taskMatch) {
				task.Assigned_To__c = directorOpsUser.Id;
			}
		}    	
    }

	private static void handleConfirmSystemMonitoringActivated(Milestone1_Task__c sourceTask, List<Milestone1_Task__c> tasksForThisMilestone, User fieldManagerUser) {

		Boolean taskMatch = sourceTask.Workflow_Key__c == INSTALLATION_BEGINS_WORK_FLOW_KEY;
		
		if (taskMatch && sourceTask.Complete__c) {
			assignTask(CONFIRM_SYSTEM_MONITORING_ACTIVATED_WORK_FLOW_KEY, tasksForThisMilestone, fieldManagerUser);			
		}
	}

	private static void handleUploadEnphaseMapAndBranchMap(Milestone1_Task__c sourceTask, List<Milestone1_Task__c> tasksForThisMilestone, User fieldManagerUser) {

		Boolean taskMatch = sourceTask.Workflow_Key__c == INSTALLATION_BEGINS_WORK_FLOW_KEY;
		
		if (taskMatch && sourceTask.Complete__c) {
			assignTask(UPLOAD_ENPHASE_MAP_AND_BRANCH_MAP_WORK_FLOW_KEY, tasksForThisMilestone, fieldManagerUser);			
		}
	}

	private static void handleConfirmSystemDesignMatchesInstallation(Milestone1_Task__c sourceTask, List<Milestone1_Task__c> tasksForThisMilestone, User fieldManagerUser) {

		Boolean taskMatch = sourceTask.Workflow_Key__c == INSTALLATION_BEGINS_WORK_FLOW_KEY;
		
		if (taskMatch && sourceTask.Complete__c) {
			assignTask(CONFIRM_SYSTEM_DESIGN_MATCHES_INSTALLATION_WORK_FLOW_KEY, tasksForThisMilestone, fieldManagerUser);			
		}
	}

	private static void handleArrayCreatedInEnphasePortal(Milestone1_Task__c sourceTask, List<Milestone1_Task__c> tasksForThisMilestone, User fieldManagerUser) {

		Boolean taskMatch = sourceTask.Workflow_Key__c == INSTALLATION_BEGINS_WORK_FLOW_KEY;
		
		if (taskMatch && sourceTask.Complete__c) {
			assignTask(ARRAY_CREATED_IN_ENPHASE_PORTAL_WORK_FLOW_KEY, tasksForThisMilestone, fieldManagerUser);			
		}
	}

	private static void handleSubmitWarrantyCards(Milestone1_Task__c sourceTask, List<Milestone1_Task__c> tasksForThisMilestone, User fieldManagerUser) {

		Boolean taskMatch = sourceTask.Workflow_Key__c == REVIEW_PREINSTALL_STEPS_WORK_FLOW_KEY;
		
		if (taskMatch && sourceTask.Complete__c) {
			assignTask(SUBMIT_WARRANTY_CARDS_WORK_FLOW_KEY, tasksForThisMilestone, fieldManagerUser);			
		}
	}

	private static void handleUploadPartsUsedChecklist(Milestone1_Task__c sourceTask, List<Milestone1_Task__c> tasksForThisMilestone, User fieldManagerUser) {

		Boolean taskMatch = sourceTask.Workflow_Key__c == REVIEW_PREINSTALL_STEPS_WORK_FLOW_KEY;
		
		if (taskMatch && sourceTask.Complete__c) {
			assignTask(UPLOAD_PARTS_USED_CHECKLIST_WORK_FLOW_KEY, tasksForThisMilestone, fieldManagerUser);			
		}
	}

	private static void handleInstallationPhotos(Milestone1_Task__c sourceTask, List<Milestone1_Task__c> tasksForThisMilestone, User fieldManagerUser) {

		Boolean taskMatch = sourceTask.Workflow_Key__c == REVIEW_PREINSTALL_STEPS_WORK_FLOW_KEY;
		
		if (taskMatch && sourceTask.Complete__c) {
			assignTask(INSTALLATION_PHOTOS_WORK_FLOW_KEY, tasksForThisMilestone, fieldManagerUser);			
		}
	}

	private static void handleElectricWorkComplete(Milestone1_Task__c sourceTask, List<Milestone1_Task__c> tasksForThisMilestone, User fieldManagerUser) {

		Boolean taskMatch = sourceTask.Workflow_Key__c == REVIEW_PREINSTALL_STEPS_WORK_FLOW_KEY;
		
		if (taskMatch && sourceTask.Complete__c) {
			assignTask(ELECTRIC_WORK_COMPLETE_WORK_FLOW_KEY, tasksForThisMilestone, fieldManagerUser);			
		}
	}

	private static void handlePanelWorkComplete(Milestone1_Task__c sourceTask, List<Milestone1_Task__c> tasksForThisMilestone, User fieldManagerUser) {

		Boolean taskMatch = sourceTask.Workflow_Key__c == REVIEW_PREINSTALL_STEPS_WORK_FLOW_KEY;
		
		if (taskMatch && sourceTask.Complete__c) {
			assignTask(PANEL_WORK_COMPLETE_WORK_FLOW_KEY, tasksForThisMilestone, fieldManagerUser);			
		}
	}

	private static void handleInstallationBegins(Milestone1_Task__c sourceTask, List<Milestone1_Task__c> tasksForThisMilestone, User fieldManagerUser) {

		Boolean taskMatch = sourceTask.Workflow_Key__c == REVIEW_PREINSTALL_STEPS_WORK_FLOW_KEY;
		
		if (taskMatch && sourceTask.Complete__c) {
			assignTask(INSTALLATION_BEGINS_WORK_FLOW_KEY, tasksForThisMilestone, fieldManagerUser);			
		}
	}

	private static void handleInvoiceCustomer(Milestone1_Task__c sourceTask, List<Milestone1_Task__c> tasksForThisMilestone, User accountingUser) {

		Boolean taskMatch = sourceTask.Workflow_Key__c == REVIEW_PREINSTALL_STEPS_WORK_FLOW_KEY;
		
		if (taskMatch && sourceTask.Complete__c) {
			assignTask(INVOICE_CUSTOMER_WORK_FLOW_KEY, tasksForThisMilestone, accountingUser);			
		}
	}

	private static void handleCheckReceivedFor60Percent(Milestone1_Task__c sourceTask, List<Milestone1_Task__c> tasksForThisMilestone, User accountingUser) {

		Boolean taskMatch = sourceTask.Workflow_Key__c == REVIEW_PREINSTALL_STEPS_WORK_FLOW_KEY;
		
		if (taskMatch && sourceTask.Complete__c) {
			assignTask(CHECK_RECEIVED_FOR_60_PERCENT_WORK_FLOW_KEY, tasksForThisMilestone, accountingUser);			
		}
	}

	private static void handleInvoiceCustomerFor30Percent(Milestone1_Task__c sourceTask, List<Milestone1_Task__c> tasksForThisMilestone, User accountingUser) {

		Boolean taskMatch = sourceTask.Workflow_Key__c == PANEL_WORK_COMPLETE_WORK_FLOW_KEY;
		
		if (taskMatch && sourceTask.Complete__c) {
			assignTask(INVOICE_CUSTOMER_FOR_30_PERCENT_WORK_FLOW_KEY, tasksForThisMilestone, accountingUser);			
		}
	}

	private static void handleCheckReceivedFor30Percent(Milestone1_Task__c sourceTask, List<Milestone1_Task__c> tasksForThisMilestone, User accountingUser) {

		Boolean taskMatch = sourceTask.Workflow_Key__c == INVOICE_CUSTOMER_FOR_30_PERCENT_WORK_FLOW_KEY;
		
		if (taskMatch && sourceTask.Complete__c) {
			assignTask(CHECK_RECEIVED_FOR_30_PERCENT_WORK_FLOW_KEY, tasksForThisMilestone, accountingUser);			
		}
	}

	private static void handleSubmitStateGrantPart2(Milestone1_Task__c sourceTask, List<Milestone1_Task__c> tasksForThisMilestone, User grantUser) {

		Boolean taskMatch = sourceTask.Workflow_Key__c == INSPECTION_COMPLETE_WORK_FLOW_KEY;
		
		if (taskMatch && sourceTask.Complete__c) {
			assignTask(SUBMIT_STATE_GRANT_PART_2_PAPERWORK_WORK_FLOW_KEY, tasksForThisMilestone, grantUser);			
		}
	}
	
	/**
	 * Retrieve the task from the list that matches workflow key
	 * If not found, returns null
	 */
	private static Milestone1_Task__c getTask(String workflowKey, List<Milestone1_Task__c> tasks) {
		Milestone1_Task__c theTask = null;
		
		for (Milestone1_Task__c tempTask : tasks) {
			if (tempTask.Workflow_Key__c == workflowKey) {
				theTask = tempTask;
				break;
			}	
		}
		
		return theTask;
	}
	
	/**
	 * Assign the target task to the user
	 */
	private static void assignTask(String targetTaskWorkflowKey, List<Milestone1_Task__c> tasksForThisMilestone, User theUser) {
		// get the target task
		Milestone1_Task__c targetTask = getTask(targetTaskWorkflowKey, tasksForThisMilestone);
				
		if (targetTask != null) {
			targetTask.Assigned_To__c = theUser.Id;
			update targetTask;		
		}			
	}
}