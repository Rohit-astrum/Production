public with sharing class My_Projects_Controller_Extension {

    public List<Milestone1_Project__c> projects {get; private set;}
    public List<My_Projects_Holder> projectHolders {get; private set;}

	public String ownerFirstName {get; private set;}
	public String ownerLastName {get; private set;}
	
	public String KICK_OFF_VISIT_WORKFLOW_KEY {get; private set;}
	public String CREATE_PARTS_CALCULATOR_WORKFLOW_KEY {get; private set;}
	public String SUBMITTED_INTERCONNECT_WORKFLOW_KEY {get; private set;}
	public String APPROVED_INTERCONNECT_WORKFLOW_KEY {get; private set;}
	public String PERMITS_APPROVED_WORKFLOW_KEY {get; private set;}
	public String INSPECTION_WORKFLOW_KEY {get; private set;}

	public String ENGINEER_APPROVED_WORKFLOW_KEY {get; private set;}
	public String PERMITS_SENT_WORKFLOW_KEY {get; private set;}	

	public String HOA_REQUIRED_WORKFLOW_KEY {get; private set;}	
	public String HOA_SUBMITTED_WORKFLOW_KEY {get; private set;}	
	public String HOA_APPROVED_WORKFLOW_KEY {get; private set;}	
	public String INSTALLATION_BEGINS_WORKFLOW_KEY {get; private set;}
	public String PANEL_WORK_COMPLETE_WORKFLOW_KEY {get; private set;}
	public String ELECTRICAL_WORK_COMPLETE_WORKFLOW_KEY {get; private set;}
	
	
	private Id userId;
	private Set<String> projectIds;
	
	private List<Milestone1_Milestone__c> milestones;
	public Map<Id, Milestone1_Milestone__c> kickOffVisitMilestones {get; private set;}
	public Map<Id, Milestone1_Milestone__c> createPartsCalculatorMilestones {get; private set;}
	public Map<Id, Milestone1_Milestone__c> submittedInterconnectMilestones {get; private set;}
	public Map<Id, Milestone1_Milestone__c> approvedInterconnectMilestones {get; private set;}
	public Map<Id, Milestone1_Milestone__c> permitsApprovedMilestones {get; private set;}
	public Map<Id, Milestone1_Milestone__c> inspectionMilestones {get; private set;}
	public Map<Id, Milestone1_Milestone__c> hoaRequiredMilestones {get; private set;}

	
	private List<Milestone1_Task__c> tasks;
	public Map<Id, Milestone1_Task__c> engineerApprovedTasks {get; private set;}
	public Map<Id, Milestone1_Task__c> permitsSentTasks {get; private set;}

	public Map<Id, Milestone1_Task__c> hoaSubmittedTasks {get; private set;}
	public Map<Id, Milestone1_Task__c> hoaApprovedTasks {get; private set;}

	public Map<Id, Milestone1_Task__c> installationBeginsTasks {get; private set;}
	public Map<Id, Milestone1_Task__c> panelWorkCompleteTasks {get; private set;}
	public Map<Id, Milestone1_Task__c> electricalWorkCompleteTasks {get; private set;}
	
	public static final String HOA_REQUIRED = 'HOA';
	
	public My_Projects_Controller_Extension(ApexPages.StandardController stdController) {

		KICK_OFF_VISIT_WORKFLOW_KEY = 'kick_off_visit';
		CREATE_PARTS_CALCULATOR_WORKFLOW_KEY = 'create_parts_calculator';
		SUBMITTED_INTERCONNECT_WORKFLOW_KEY = 'utility_interconnect_1';
		APPROVED_INTERCONNECT_WORKFLOW_KEY = 'utility_interconnect_2';
		PERMITS_APPROVED_WORKFLOW_KEY = 'permits';
		INSPECTION_WORKFLOW_KEY = 'inspection';
				
		ENGINEER_APPROVED_WORKFLOW_KEY = 't_structural_review';			
		PERMITS_SENT_WORKFLOW_KEY = 't_permit_app_sent';

		HOA_REQUIRED_WORKFLOW_KEY = 'HOA';
		HOA_SUBMITTED_WORKFLOW_KEY = 't_hoa_submitted';
		HOA_APPROVED_WORKFLOW_KEY = 't_hoa_approved';	

		INSTALLATION_BEGINS_WORKFLOW_KEY = 't_installation_begins';
		PANEL_WORK_COMPLETE_WORKFLOW_KEY = 't_panel_work_complete';
		ELECTRICAL_WORK_COMPLETE_WORKFLOW_KEY = 't_electric_work_complete';
						
		loadData();	
	}
	
	private void loadData() {
				
		userId = UserInfo.getUserId();
		ownerFirstName = UserInfo.getFirstName();
		ownerLastName = UserInfo.getLastName();
		
		projects = loadProjects();
		
		projectIds = getProjectIds(projects);

		handleMilestones();		

		handleTasks();
				
		projectHolders = buildProjectHolders();		
	}

	private void handleMilestones() {
		// load all milestones
		milestones = loadMilestones();		
		
		// now load data for each milestone type
		kickOffVisitMilestones = getMilestones(KICK_OFF_VISIT_WORKFLOW_KEY);
		
		createPartsCalculatorMilestones = getMilestones(CREATE_PARTS_CALCULATOR_WORKFLOW_KEY);		
		submittedInterconnectMilestones = getMilestones(SUBMITTED_INTERCONNECT_WORKFLOW_KEY);
		approvedInterconnectMilestones = getMilestones(APPROVED_INTERCONNECT_WORKFLOW_KEY);
		permitsApprovedMilestones = getMilestones(PERMITS_APPROVED_WORKFLOW_KEY);
		inspectionMilestones = getMilestones(INSPECTION_WORKFLOW_KEY);		
		
		hoaRequiredMilestones = getMilestones(HOA_REQUIRED_WORKFLOW_KEY);		
	}	
	
	private void handleTasks() {
		// load all tasks
		tasks = loadTasks();
		
		// now load data for each task
		engineerApprovedTasks = getTasks(ENGINEER_APPROVED_WORKFLOW_KEY);		
		permitsSentTasks = getTasks(PERMITS_SENT_WORKFLOW_KEY);	
		
		hoaSubmittedTasks = getTasks(HOA_SUBMITTED_WORKFLOW_KEY);
		hoaApprovedTasks = getTasks(HOA_APPROVED_WORKFLOW_KEY);
		
		installationBeginsTasks = getTasks(INSTALLATION_BEGINS_WORKFLOW_KEY);			
		panelWorkCompleteTasks = getTasks(PANEL_WORK_COMPLETE_WORKFLOW_KEY);			
		electricalWorkCompleteTasks = getTasks(ELECTRICAL_WORK_COMPLETE_WORKFLOW_KEY);			
	}
	
	private List<My_Projects_Holder> buildProjectHolders() {
		List<My_Projects_Holder> theProjectHolders = new List<My_Projects_Holder>();
		
		for (Milestone1_Project__c tempProj : projects) {
			Id projId = tempProj.id;			
			
			My_Projects_Holder tempProjectHolder = new My_Projects_Holder();
			tempProjectHolder.project = tempProj;
			
			//
			// GET MILESTONE DATA FOR THIS PROJECT
			//
			Milestone1_Milestone__c theKickOffVisitMilestoneForProject = kickOffVisitMilestones.get(projId);
			updateCompleteFields(tempProjectHolder, theKickOffVisitMilestoneForProject, KICK_OFF_VISIT_WORKFLOW_KEY, projId);
			
			Milestone1_Milestone__c theCreatePartsCalculatorMilestoneForProject = createPartsCalculatorMilestones.get(projId);
			updateCompleteFields(tempProjectHolder, theCreatePartsCalculatorMilestoneForProject, CREATE_PARTS_CALCULATOR_WORKFLOW_KEY, projId);
			
			Milestone1_Milestone__c submittedInterconnectMilestoneForProject = submittedInterconnectMilestones.get(projId);
			updateCompleteFields(tempProjectHolder, submittedInterconnectMilestoneForProject, SUBMITTED_INTERCONNECT_WORKFLOW_KEY, projId);

			Milestone1_Milestone__c approvedInterconnectMilestoneForProject = approvedInterconnectMilestones.get(projId);
			updateCompleteFields(tempProjectHolder, approvedInterconnectMilestoneForProject, APPROVED_INTERCONNECT_WORKFLOW_KEY, projId);

			Milestone1_Milestone__c permitsApprovedMilestoneForProject = permitsApprovedMilestones.get(projId);
			updateCompleteFields(tempProjectHolder, permitsApprovedMilestoneForProject, PERMITS_APPROVED_WORKFLOW_KEY, projId);

			Milestone1_Milestone__c inspectionMilestoneForProject = inspectionMilestones.get(projId);
			updateCompleteFields(tempProjectHolder, inspectionMilestoneForProject, INSPECTION_WORKFLOW_KEY, projId);

			Milestone1_Milestone__c hoaRequiredMilestoneForProject = hoaRequiredMilestones.get(projId);
			updateHoaCompleteFields(tempProjectHolder, hoaRequiredMilestoneForProject, HOA_REQUIRED_WORKFLOW_KEY, projId);
						
			//
			// GET TASK DATA FOR THIS PROJECT
			//
			Milestone1_Task__c engineerApprovedTaskForProject = engineerApprovedTasks.get(projId);			
			updateTaskCompleteFields(tempProjectHolder, engineerApprovedTaskForProject, ENGINEER_APPROVED_WORKFLOW_KEY, projId);
			
			Milestone1_Task__c permitsSentTaskForProject = permitsSentTasks.get(projId);			
			updateTaskCompleteFields(tempProjectHolder, permitsSentTaskForProject, PERMITS_SENT_WORKFLOW_KEY, projId);

			Milestone1_Task__c hoaSubmittedTaskForProject = hoaSubmittedTasks.get(projId);			
			updateTaskCompleteFields(tempProjectHolder, hoaSubmittedTaskForProject, HOA_SUBMITTED_WORKFLOW_KEY, projId);

			Milestone1_Task__c hoaApprovedTaskForProject = hoaApprovedTasks.get(projId);			
			updateTaskCompleteFields(tempProjectHolder, hoaApprovedTaskForProject, HOA_APPROVED_WORKFLOW_KEY, projId);

			Milestone1_Task__c installationBeginsTaskForProject = installationBeginsTasks.get(projId);			
			updateTaskCompleteFields(tempProjectHolder, installationBeginsTaskForProject, INSTALLATION_BEGINS_WORKFLOW_KEY, projId);

			Milestone1_Task__c panelWorkCompleteTaskForProject = panelWorkCompleteTasks.get(projId);			
			updateTaskCompleteFields(tempProjectHolder, panelWorkCompleteTaskForProject, PANEL_WORK_COMPLETE_WORKFLOW_KEY, projId);

			Milestone1_Task__c electricalWorkCompleteTaskForProject = electricalWorkCompleteTasks.get(projId);			
			updateTaskCompleteFields(tempProjectHolder, electricalWorkCompleteTaskForProject, ELECTRICAL_WORK_COMPLETE_WORKFLOW_KEY, projId);
			
			theProjectHolders.add(tempProjectHolder);
		}
		
		return theProjectHolders;
	}
	
	private void updateCompleteFields(My_Projects_Holder tempProjectHolder, Milestone1_Milestone__c theMilestone, String workFlowKey, String projId) {
			
		if (theMilestone != null) {	
			tempProjectHolder.completeId.put(workFlowKey, theMilestone.Id);
			
			String value = null;
			
			if (theMilestone.Complete__c) {
				Date completeDate = theMilestone.Complete_Date__c;
				
				if (completeDate != null) {
					value = completeDate.format();
				}
				else {
					value = 'Complete';
				}
			}
			else {
				value = 'Incomplete';
			}		

			tempProjectHolder.complete.put(workFlowKey, value);
		}
		else {
			tempProjectHolder.completeId.put(workFlowKey, projId);
			tempProjectHolder.complete.put(workFlowKey, 'NA');			
		}
	}

	private void updateHoaCompleteFields(My_Projects_Holder tempProjectHolder, Milestone1_Milestone__c theMilestone, String workFlowKey, String projId) {
			
		if (theMilestone != null) {	
			tempProjectHolder.completeId.put(workFlowKey, theMilestone.Id);
			
			String value = null;
			
			if (isHoaRequired(theMilestone)) {
				value = 'Yes';
			}
			else {
				value = 'No';
			}

			tempProjectHolder.complete.put(workFlowKey, value);
		}
		else {
			tempProjectHolder.completeId.put(workFlowKey, projId);
			tempProjectHolder.complete.put(workFlowKey, 'NA');			
		}
	}
	
	private void updateTaskCompleteFields(My_Projects_Holder tempProjectHolder, Milestone1_Task__c theTask, String workFlowKey, String projId) {
			
		if (theTask != null) {	
			tempProjectHolder.completeId.put(workFlowKey, theTask.Id);
			
			String value = null;
			
			if (theTask.Not_Applicable__c) {
				value = 'NA';
			}
			else if (theTask.Complete__c) {
				value = theTask.Complete_Date__c.format();
			}
			else {
				value = 'Incomplete';
			}	

			tempProjectHolder.complete.put(workFlowKey, value);
		}
		else {
			tempProjectHolder.completeId.put(workFlowKey, projId);
			tempProjectHolder.complete.put(workFlowKey, 'NA');			
		}
	}

	
	private List<Milestone1_Project__c> loadProjects() {
		List<Milestone1_Project__c> theProjects = [SELECT id, Name, Total_Open_Task_Count__c, Status__c, OwnerId, Project_Lead__r.Name, Deadline__c, Kickoff__c, Sales_Order__r.OpportunityId__r.Property__r.Id, 
						   Sales_Order__r.OpportunityId__r.Property__r.Name, Salesperson__r.Name, Sale_Date__c, Sales_Order__r.Name,
						   Sales_Order__r.OpportunityId__r.Property__r.Property_County__c 
                     FROM Milestone1_Project__c
                     WHERE Status__c = 'Active' and OwnerId = :userId
                     ORDER BY Name];                     
		
		return theProjects;
	}
	
	private Set<String> getProjectIds(List<Milestone1_Project__c> theProjects) {
		Set<String> theProjectIds = new Set<String>();
		
		for (Milestone1_Project__c tempProj : theProjects) {
			String shortId = Milestone1_General_Utility.truncateId(tempProj.id);			
			theProjectIds.add(shortId);	
		}
		
		return theProjectIds;	
	}
	
	
	private List<Milestone1_Milestone__c> loadMilestones() {
		List<Milestone1_Milestone__c> theMilestones = [SELECT Id,
														   Name,
                                                           Project__c,
                                                           Complete__c,
														   Complete_Date__c,                                                           
                                                           Deadline__c,
                                                           Project__r.Sales_Order__r.Property__r.Authorization_Bodies__c,
                                                           Workflow_Key__c
                                                    FROM Milestone1_Milestone__c
                                                    WHERE Project__c IN :projectIds
                                                   ];		
		return theMilestones;
	}
	
	private Map<Id, Milestone1_Milestone__c> getMilestones(String workflowKey) {
		Map<Id, Milestone1_Milestone__c> results = new Map<Id, Milestone1_Milestone__c>();
		
		for (Milestone1_Milestone__c tempMilestone : milestones) {
			if (tempMilestone.Workflow_Key__c != null && tempMilestone.Workflow_Key__c.equals(workflowKey)) {
				results.put(tempMilestone.Project__c, tempMilestone);
			}
		}
			
		return results;
	}
	
	private List<Milestone1_Task__c> loadTasks() {		
		List<Milestone1_Task__c> theTasks =    [SELECT Id,
												   	Name,
                                            		ProjectId__c,
                                                    Complete__c,
                                                    Complete_Date__c,
                                                    Not_Applicable__c,
                                                    Workflow_Key__c
                                                    FROM Milestone1_Task__c
                                                    WHERE ProjectId__c IN :projectIds
                                                   ];  
                                                                                                            		
		return theTasks;
	}
	
	private Map<Id, Milestone1_Task__c> getTasks(String workflowKey) {
		Map<Id, Milestone1_Task__c> results = new Map<Id, Milestone1_Task__c>();
		
		for (Milestone1_Task__c tempTask : tasks) {
			
			String tempWorkFlowKey = tempTask.Workflow_Key__c;
			
			if (tempWorkFlowKey != null && tempWorkFlowKey.equals(workflowKey)) {
				results.put(tempTask.ProjectId__c, tempTask);
			}
		}
			
		return results;
	}

	public boolean isHoaRequired(Milestone1_Milestone__c theMilestone) {
		boolean result = false;

		String authorizationBodies = theMilestone.Project__r.Sales_Order__r.Property__r.Authorization_Bodies__c;
		
		result = isHoaRequired(authorizationBodies);
		
		return result;
	}
		
	public boolean isHoaRequired(String requiredAuthorizations) {
		boolean result = false;
		
		if (requiredAuthorizations == null) {
			return false;
		}
		
		List<String> data = requiredAuthorizations.split(';');
		if (!data.isEmpty()) {
			for (String temp : data) {
				
				if (temp.equals(HOA_REQUIRED)) {
					result = true;
					break;
				}
			}
		}
		
		return result;
	}
		
	public class IllegalIdException extends Exception {}
	
}