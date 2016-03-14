public with sharing class Milestone1_Project_Controller_Extension {

    public static final String OPEN_COLOR = '#4ABEDE';
    public static final String LATE_BLOCKED_COLOR = '#EF4839';
    public static final String COMPLETE_COLOR = '#FEFEFE';

    public List<TaskDetailHolder> taskDetailHolders {get; private set;}
    public String openColor {get; private set;}
    public String lateBlockedColor {get; private set;}
    public String completeColor {get; private set;}
     
    public Milestone1_Project_Controller_Extension(ApexPages.StandardController stdController) {
        Milestone1_Project__c project = (Milestone1_Project__c) stdController.getRecord();
        
        openColor = OPEN_COLOR;
        lateBlockedColor = LATE_BLOCKED_COLOR;
        completeColor = COMPLETE_COLOR;
        
        loadData(project.id);        
    }

    private void loadData(String projectId) {
        // get all milestones
        List<Milestone1_Milestone__c> milestones = loadMilestones(projectId);
        
        List<Id> milestoneIds = getMilestoneIds(milestones);
        
        List<Milestone1_Task__c> tasks = getTasks(milestoneIds);
        
        Map<Id, List<Milestone1_Task__c>> tasksByMilestoneId = groupTasksByMilestoneId(tasks);
        
        // taskDetailHolders = buildMap(tasks);
        taskDetailHolders = buildMap(milestoneIds, tasksByMilestoneId);
    }
    
    private Map<Id, List<Milestone1_Task__c>> groupTasksByMilestoneId(List<Milestone1_Task__c> theTasks) {
        Map<Id, List<Milestone1_Task__c>> tasksByMilestoneId = new Map<Id, List<Milestone1_Task__c>>();

        for (Milestone1_Task__c tempTask : theTasks) {
            
            Id milestoneId = tempTask.Project_Milestone__c;
            
            List<Milestone1_Task__c> tasksForMilestone = null;
            
            if (tasksByMilestoneId.containsKey(milestoneId)) {
                tasksForMilestone = tasksByMilestoneId.get(milestoneId);
            }
            else {
                tasksForMilestone = new List<Milestone1_Task__c>();
                tasksByMilestoneId.put(milestoneId, tasksForMilestone);                 
            }
            
            tasksForMilestone.add(tempTask);    
        }
        
        return tasksByMilestoneId;  
    }

    private List<TaskDetailHolder> buildMap(List<Id> milestoneIds, Map<Id, List<Milestone1_Task__c>> tasksByMilestoneId) {
        List<TaskDetailHolder> taskDetailHolders = new List<TaskDetailHolder>();

        for (Id tempId : milestoneIds) {        
            List<Milestone1_Task__c> theTasks = tasksByMilestoneId.get(tempId);

            if (theTasks != null) {
                Boolean firstEntry = true;          
                for (Milestone1_Task__c tempTask : theTasks) {
                    String milestoneId = tempTask.Project_Milestone__r.id;
                    String milestoneName = null;
                    
                    if (firstEntry) {
                        milestoneName = tempTask.Project_Milestone__r.name;
                        firstEntry = false;
                    }
                    else {
                        milestoneName = null;                   
                    }
                    
                    String milestoneColor = computeMilestoneColor(tempTask);
                    String taskColor = computeTaskColor(tempTask);
                    
                    TaskDetailHolder tempTaskDetailHolder = new TaskDetailHolder(milestoneName, milestoneColor, tempTask, taskColor);
                    taskDetailHolders.add(tempTaskDetailHolder);                
                }
            }           
        }
        
        return taskDetailHolders;
    }
        
    private String computeMilestoneColor(Milestone1_Task__c theTask) {
        String color = null;
        
        if (theTask.Project_Milestone__r.Complete__c) {
            color = COMPLETE_COLOR;
        }
        else if (theTask.Project_Milestone__r.Blocked_Tasks_in_Tasks__c > 0 || theTask.Project_Milestone__r.Late_Tasks_in_Tasks__c > 0 || theTask.Project_Milestone__r.Deadline__c < Date.today()) {
            color = LATE_BLOCKED_COLOR;
        }
        else {
            color = OPEN_COLOR; 
        }
        
        return color;   
    }

    private String computeTaskColor(Milestone1_Task__c theTask) {
        String color = null;
        
        if (theTask.Complete__c) {
            color = COMPLETE_COLOR;
        }
        else if (theTask.Blocked__c || theTask.Due_Date__c < Date.today()) {
            color = LATE_BLOCKED_COLOR;
        }
        else {
            color = OPEN_COLOR; 
        }
        
        return color;   
    }
    
    private List<Milestone1_Milestone__c> loadMilestones(String projectId) {
        List<Milestone1_Milestone__c> theMilestones = [SELECT Id,
                                                           Name,
                                                           Deadline__c
                                                    FROM Milestone1_Milestone__c
                                                    WHERE Project__c = :projectId
                                                    ORDER BY Deadline__c
                                                   ];       
        return theMilestones;
    }
    
    private List<Milestone1_Task__c> getTasks(List<Id> milestoneIds) {
        List<Milestone1_Task__c> tasks = [SELECT Id,
                                                 Name,
                                                 Assigned_To__r.name,
                                                 Project_Milestone__r.id,
                                                 Project_Milestone__r.name,
                                                 Project_Milestone__r.Complete__c,
                                                 Project_Milestone__r.Late_Tasks_in_Tasks__c,
                                                 Project_Milestone__r.Blocked_Tasks_in_Tasks__c,
                                                 Project_Milestone__r.Deadline__c,
                                                 Complete__c,
                                                 Complete_Date__c,
                                                 Requires_Documentation__c,
                                                 Days_Late__c,
                                                 Blocked__c,
                                                 Due_Date__c
                                           FROM Milestone1_Task__c
                                           WHERE Project_Milestone__c IN :milestoneIds
                                           ORDER BY Due_Date__c
                                           ];   
        
        return tasks;
    }
    
    private List<Id> getMilestoneIds(List<Milestone1_Milestone__c> theMilestones) {
        List<Id> theIds = new List<Id>();
        
        for (Milestone1_Milestone__c tempProj : theMilestones) {
            theIds.add(tempProj.id);    
        }
        
        return theIds;          
    }
            
}