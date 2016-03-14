/* FILE: OpportunityInactivityUpdateBatch.cls
 * AUTHOR: Rohit Jain
 * DATE: Nov 5, 2013
 * PURPOSE: 1. If Opportunity.Stage <> ‘On Hold’, ‘Closed-Won’, ‘Closed-Lost’, ‘Contract Cancelled’ AND all Tasks of 
 *             Record Type = ‘Inactivity Notice’ have Task.Status = ‘Completed’ AND (Today() – Start Date of last Activity)
 *             > 30 then create a Task of Record Type = ‘Inactivity Notice’ with Task.Due Date = Today() and 
 *             Task.Subject = ‘Follow-up – Inactive’
 *   to invoke: OpportunityInactivityUpdateBatch batch = new OpportunityInactivityUpdateBatch();
 *              Id batchId = Database.executeBatch(batch, 150); 
 * MODIFICATION HISTORY 
 */
global class OpportunityInactivityUpdateBatch implements Database.Batchable<sObject>,Schedulable,Database.Stateful{
    public String query;
    public String batchErrors = '';
    private Integer batchNumber = 0;
    
    public static final String TASK_STATUS = 'Not Started';
    public static final String TASK_PRIORITY = 'Normal';
    public static final String TASK_SUBJECT = 'Follow-Up - Inactivity';
    public static final String TASK_DESCRIPTION = 'This Opportunity is Inactive from past 30 days. Please follow up.';

    global Database.QueryLocator start(Database.BatchableContext BC){
       
        query = 'SELECT  o.Property__r.Property_ZIP__c, o.Property__r.Property_State__c, o.Property__r.Property_City__c, o.Property__r.Name, o.Property__c, '
               + ' o.Owner.isActive , o.Owner.Email, o.Owner.FirstName, o.Owner.LastName, o.Owner.Manager.Email, o.OwnerId, o.Name, o.StageName, o.On_Hold_Until__c   '      
               + '  FROM Opportunity o WHERE StageName NOT IN (\'Unresponsive\', \'On Hold\',\'Closed - Won\',\'Closed - Lost\',\'Contract Cancelled\'  ) and LastModifiedDate != LAST_N_DAYS:30 ';
        
        if(Test.isRunningTest())
        {
            query = query + ' Limit 10';    
        }
        System.debug('**'+query);      
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Opportunity> oppsTaskCheckList = new List<Opportunity>();  
        List<Opportunity> oppsTaskList = new List<Opportunity>();           
        for(sObject s : scope)
        {
          Opportunity opp = (Opportunity)s;
          System.debug('###'+opp.Owner.FirstName + ' ' + opp.Owner.LastName+' : '+opp.Owner.isActive);          
          if(!Test.isRunningTest() && !opp.Owner.isActive)
          {
            batchErrors += opp.Id + ':'+opp.Name + ':' + opp.Owner.FirstName + ' ' + opp.Owner.LastName + ': ' + 'Opportunity assigned to Inactive User.'  +'\n\n';
          } 
          else
          { 
            oppsTaskCheckList.add(opp);             
          }         
        }  
        
        if(!oppsTaskCheckList.isEmpty())
        {
            oppsTaskList = checkTasksForOpps(oppsTaskCheckList);
        } 
        
        if(!oppsTaskList.isEmpty())
        {
            createInactivityTasksForOpps(oppsTaskList);    
        }     
    }
    
    public List<Opportunity> checkTasksForOpps(List<Opportunity> oppslist) {       
        
        List<Opportunity> opsTasks = new List<Opportunity>();     
        Set<Id> oppSet = new Set<Id>();  
        List<Task> tasksList = [Select WhatId,Id,Status From Task Where RecordType.Name= 'Inactivity Notice' and Status != 'Completed' and WhatId in :oppslist];
        
        if(tasksList != null)
        {
            for(Task tk : tasksList)
            {
              oppSet.add(tk.WhatId);     
            }        
        }
        
        for (Opportunity opp: oppslist) {
            if(!oppSet.contains(opp.Id))
            {
                opsTasks.add(opp);
            }    
        }
       
        return opsTasks;
    }
    
    public void createInactivityTasksForOpps(List<Opportunity> oppslist) {       
        
        List<Task> tasksToAdd = new List<Task>(); 
        Database.SaveResult[] srList;                
        RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Task' and DeveloperName = 'Inactivity_Notice'];
        for (Opportunity opp: oppslist) {
            Task tempTask = createTask(opp.id,RecType.Id,opp.OwnerId);
            tasksToAdd.add(tempTask);
        }

        if (!tasksToAdd.isEmpty()) {
            System.debug('*tasksToAdd*'+tasksToAdd);
            Database.DMLOptions dmlo = new Database.DMLOptions(); 
            dmlo.EmailHeader.triggerUserEmail = true; 
            srList = database.insert(tasksToAdd , dmlo); 
            
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        batchErrors += sr.getId() + ':'+err.getFields() + ':' + err.getStatusCode() + ': ' + err.getMessage() +'\n\n';
                    }
                }
            }
        } 
    }
    
    public Task createTask(Id theId, Id recId, Id OwnerId) {

        Task tempTask = new Task();
        tempTask.whatId = theId;  
        tempTask.activityDate = System.today();
        tempTask.ownerId = OwnerId;
        tempTask.description = TASK_DESCRIPTION;
        tempTask.priority = TASK_PRIORITY;
        tempTask.status = TASK_STATUS;
        tempTask.subject = TASK_SUBJECT;
        tempTask.RecordTypeId = recId;
        
        
        
        return tempTask;        
    }
    
    global void execute(SchedulableContext SC) {
      OpportunityInactivityUpdateBatch batch = new OpportunityInactivityUpdateBatch();
      Id batchId = Database.executeBatch(batch, 150);
    }
    
    global void finish(Database.BatchableContext bc) {
        
        if (batchErrors != '') {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(UserInfo.getUserId());
            mail.setSubject('Opportunity Inactivity Update Batch  Errors');
            mail.setPlainTextBody(batchErrors);
            mail.setSaveAsActivity(false);
            Messaging.sendEmail(new Messaging.Email[] { mail }, false);     
        }        
        if (batchNumber > 0) {
            //EnphaseBatchHelper.runNextPull(lastEnphaseId);
        }
    } 
}