public with sharing class Task_Completer_Controller_Extension {

    private final Milestone1_Milestone__c milestone;
    public List<Milestone1_Task__c> milestoneTasks {get; set;}

         
    public Task_Completer_Controller_Extension (ApexPages.StandardController stdController) {
        milestone = (Milestone1_Milestone__c)stdController.getRecord();
        loadData();
    }
    
    private void loadData(){
       milestoneTasks = [SELECT id, Name, Complete__c, Complete_Date__c, Blocked__c, Assigned_To__r.Name, Days_Late__c, Due_Date__c, Description__c, Blocked_Reason__c, Overall_Status__c, Not_Applicable__c
                     FROM Milestone1_Task__c
                     WHERE Project_Milestone__c=:this.milestone.id AND Requires_Documentation__c=false order by Due_Date__c];
    }
    
    public PageReference doTaskSave(){
        try {
            update milestoneTasks;
        } 
        catch (DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
        
        loadData();
        
        //return new PageReference('/'+ApexPages.currentPage().getParameters().get('id'));    
        return null;    
    }
    
}