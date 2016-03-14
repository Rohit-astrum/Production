/* FILE: OpportunityOnholdUpdateBatch.cls
 * AUTHOR: Rohit Jain
 * DATE: Nov 5, 2013
 * PURPOSE: 1. if Opportunity.Stage = ‘On Hold’ AND Opportunity.On Hold Until = Tomorrow() 
 *              send email to Opportunity.Owner
 *          2. if Opportunity.Stage = ‘On Hold’ AND Opportunity.On Hold Until <= Today() 
 *             AND all Tasks of Record Type = ‘Inactivity Notice’ have Task.Status = ‘Completed’ 
 *             then create a Task of Record Type = ‘Inactivity Notice’ with Task.Due Date = Today() 
 *             and Task.Subject = ‘Follow-up – On Hold’. 
 *             Email notice to Opportunity Owner and Manager
 *   to invoke: OpportunityOnholdUpdateBatch batch = new OpportunityOnholdUpdateBatch();
 *              Id batchId = Database.executeBatch(batch, 150); 
 * MODIFICATION HISTORY 
 */
global class OpportunityOnholdUpdateBatch implements Database.Batchable<sObject>,Schedulable,Database.Stateful{
    public String query;
    public String batchErrors = '';
    private Integer batchNumber = 0;
    
    public static final String TASK_STATUS = 'Not Started';
    public static final String TASK_PRIORITY = 'Normal';
    public static final String TASK_SUBJECT = 'Follow-Up - On Hold';
    public static final String TASK_DESCRIPTION = 'This Opportunity is on Hold. Please follow up.';

    global Database.QueryLocator start(Database.BatchableContext BC){
       
        query = 'SELECT  o.Property__r.Property_ZIP__c, o.Property__r.Property_State__c, o.Property__r.Property_City__c, o.Property__r.Name, o.Property__c, '
               + ' o.Owner.Email, o.Owner.FirstName, o.Owner.LastName, o.Owner.Manager.Email, o.OwnerId, o.Name, o.StageName, o.On_Hold_Until__c   '      
               + '  FROM Opportunity o WHERE StageName = \'On Hold\' ' 
               + ' AND On_Hold_Until__c <= TOMORROW ';
        
        System.debug('**'+query);  
        
        if(Test.isRunningTest())
        {
            query = query + ' Limit 10' ;
        }    
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        List<Opportunity> oppsEmailList = new List<Opportunity>();  
        List<Opportunity> oppsTaskCheckList = new List<Opportunity>();  
        List<Opportunity> oppsTaskList = new List<Opportunity>();           
        for(sObject s : scope)
        {
          Opportunity opp = (Opportunity)s;
          if(opp.On_hold_Until__c == System.Today()+1 )
          {
              System.debug('*tomm*'+opp);   
              oppsEmailList.add(opp);
          }
          else
          {
              // Check that Tasks of Record Type = ‘Inactivity Notice’ have Task.Status = ‘Completed’
              System.debug('today**'+opp); 
             oppsTaskCheckList.add(opp);             
          }
        }    
        if(!oppsEmailList.isEmpty())
        {
            sendEmailForOpps(oppsEmailList);    
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
        RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Task' and DeveloperName = 'Inactivity_Notice'];
        for (Opportunity opp: oppslist) {
            Task tempTask = createTask(opp.id,RecType.Id,opp.OwnerId);
            tasksToAdd.add(tempTask);
        }

        if (!tasksToAdd.isEmpty()) {
             System.debug('*tasksToAdd*'+tasksToAdd);
            Database.DMLOptions dmlo = new Database.DMLOptions(); 
            dmlo.EmailHeader.triggerUserEmail = true; 
            database.insert(tasksToAdd , dmlo); 
            //insert tasksToAdd;
        } 
    }
    
    public Task createTask(Id theId, Id recId, Id OwnerId) {

        Task tempTask = new Task();
        tempTask.whatId = theId;  
        tempTask.ownerId = OwnerId;
        tempTask.activityDate = System.today();
        
        tempTask.description = TASK_DESCRIPTION;
        tempTask.priority = TASK_PRIORITY;
        tempTask.status = TASK_STATUS;
        tempTask.subject = TASK_SUBJECT;
        tempTask.RecordTypeId = recId;
        
        
        
        return tempTask;        
    }
    
    public void sendEmailForOpps(List<Opportunity> oppslist) {
        Server_Info__c serverInfo;
        if(!Test.isRunningTest())
        {
            serverInfo = [select Server_URL__c from Server_Info__c limit 1];        
        }
        else
        {
            serverinfo = new Server_Info__c();         
            insert serverinfo;
        }        
        List<Messaging.SingleEmailMessage> email = new List<Messaging.SingleEmailMessage>();         
        for (Opportunity opp : oppslist) {
            
          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          
          if (!Test.isRunningTest()) {
            mail.setToAddresses(new String[] {opp.owner.Email});           
          }
          else {
            User me = [Select email from user where id = :UserInfo.getUserId() limit 1];   
            mail.setToAddresses(new String[] { me.Email });
          }
            
          mail.setSubject('Opportunity '+ opp.Name + ' On Hold Expiring');
    
          String plainTextContent ='This Opportunity: ' + opp.Name +' on hold is expiring. Please follow up.';
          String htmlContent = 'This Opportunity: ' + ' <a href="' + serverInfo.Server_URL__c + opp.Id+ '">' + opp.Name + '</a>' +' on hold is expiring. Please follow up.';
            
          mail.setPlainTextBody(plainTextContent);
          mail.setHtmlBody(htmlContent );
          
          email.add(mail); 
          
          //Messaging.sendEmail(new Messaging.Singleemailmessage[] { mail });
          if (Test.isRunningTest()) {
            // only send one email
            break;
          } 
          
               
        }
        if (!Test.isRunningTest())
          Messaging.sendEmail(email);       
               
    }
    
    global void execute(SchedulableContext SC) {
      OpportunityOnholdUpdateBatch  batch = new OpportunityOnholdUpdateBatch ();
      Id batchId = Database.executeBatch(batch, 150);
    }
    
    global void finish(Database.BatchableContext bc) {
        
        if (batchErrors != '') {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(UserInfo.getUserId());
            mail.setSubject('Enphase Monthly Production Pull Batch Errors');
            mail.setPlainTextBody(batchErrors);
            mail.setSaveAsActivity(false);
            Messaging.sendEmail(new Messaging.Email[] { mail }, false);     
        }        
        if (batchNumber > 0) {
            //EnphaseBatchHelper.runNextPull(lastEnphaseId);
        }
    } 
}