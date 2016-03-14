/* FILE: EventSalesVisitStatusUpdateBatch.cls
 * AUTHOR: Rohit Jain
 * DATE: Nov 5, 2013
 * PURPOSE: Updated the Event's status to Missed if it is passed the Scheduled Date
 *   to invoke: EventSalesVisitStatusUpdateBatch batch = new EventSalesVisitStatusUpdateBatch();
 *              Id batchId = Database.executeBatch(batch, 150); 
 * MODIFICATION HISTORY
 * 12/16/2014 PB - SALES-75 Set TriggerUtility property to bypass EventTrigger for this batch process
 */
global class EventSalesVisitStatusUpdateBatch implements Database.Batchable<sObject>,Schedulable,Database.Stateful{
    public String query;
    public String batchErrors = '';
    private Integer batchNumber = 0;

    global Database.QueryLocator start(Database.BatchableContext BC){
        DateTime dt = System.Now().addDays(-2);
        //String formatedDt = dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String formatedDt = dt.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');        
        query = 'SELECT e.StartDateTime, e.Missed_Date__c, e.Ever_Been_Missed__c, e.Id, e.Astrum_Event_ID__c, e.Event_Status__c ,StartDateTimeCopy__c '      
               + '  FROM Event e WHERE isChild=false and Event_Status__c = \'Scheduled\' ' 
               + ' and (RecordType.Name = \'Sales Visit Onsite\' Or RecordType.Name =\'Sales Visit Remote\') and StartDateTime < '+ formatedDt;
        
        
        if(Test.isRunningTest())
        {
            query = query + ' limit 10';   
        }
        System.debug('***'+query);      
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        //12/16/2014 PB - SALES-75 Bypass EventTrigger and AstrumEventTrigger
        TriggerUtility.skipEventTrigger = true;
        TriggerUtility.skipAstrumEventTrigger = true;    
        System.debug('**skipEventTrigger:'+ TriggerUtility.skipEventTrigger);
        
        Set<Id> sid = new Set<Id>();        
        for(Sobject s: scope){
          Event evt = (Event)s;  
          sid.add(evt.Astrum_Event_ID__c);        
        }
        
        Map<Id,Astrum_Event__c> mae = new Map<Id,Astrum_Event__c>();
        for(Astrum_Event__c ae: [SELECT Id, Ever_Been_Missed__c, Missed_Date__c, Status__c , StartDateTimeCopy__c  FROM Astrum_Event__c  WHERE Id IN: sid]){
            mae.put(ae.Id,ae);
        }     
        Database.SaveResult[] sraList;
        List<Astrum_Event__c> astrumeventsUpdateList = new List<Astrum_Event__c>();
        List<Event> eventsUpdateList = new List<Event>();  
        Database.SaveResult[] srList;          
        for(sObject s : scope)
        {
          
          Event evt = (Event)s;          
          evt.Event_Status__c = 'Missed';          
          evt.Missed_Date__c = System.Now();           
          evt.Ever_Been_Missed__c = true;           
          evt.StartDateTimeCopy__c = evt.StartDateTime;
          eventsUpdateList.add(evt);
          
          if(evt.Astrum_Event_ID__c != null && mae.containsKey(evt.Astrum_Event_ID__c)){
              Astrum_Event__c ae = mae.get(evt.Astrum_Event_ID__c);
              ae.Status__c = evt.Event_Status__c;
              ae.Ever_Been_Missed__c = evt.Ever_Been_Missed__c;
              ae.StartDateTimeCopy__c = evt.StartDateTimeCopy__c;
              ae.Missed_Date__c = evt.Missed_Date__c;
              astrumeventsUpdateList.add(ae);          
          }          
          
        }
        
        if(!astrumeventsUpdateList.isEmpty()){
           
           sraList = database.update(astrumeventsUpdateList,false);
           for (Database.SaveResult sr : sraList) {
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        batchErrors += sr.getId() + ':'+err.getFields() + ':' + err.getStatusCode() + ': ' + err.getMessage() +'\n\n';
                    }
                }
            }        
        }   
        
        if (!eventsUpdateList.isEmpty()) {
            
            srList = database.update(eventsUpdateList,false);
            
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
    
    global void execute(SchedulableContext SC) {
      EventSalesVisitStatusUpdateBatch  batch = new EventSalesVisitStatusUpdateBatch ();
      Id batchId = Database.executeBatch(batch, 150);
    }
    
    global void finish(Database.BatchableContext bc) {
        //12/16/2014 PB - Reset EventTrigger and AstrumEventTrigger
        TriggerUtility.skipEventTrigger = false;
        TriggerUtility.skipAstrumEventTrigger = false;
        
        System.debug('**skipEventTrigger reset to:'+ TriggerUtility.skipEventTrigger);
        if (batchErrors != '') {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(UserInfo.getUserId());
            mail.setSubject('Event Sales Visit Status Update Batch Errors');
            mail.setPlainTextBody(batchErrors);
            mail.setSaveAsActivity(false);
            Messaging.sendEmail(new Messaging.Email[] { mail }, false);     
        }        
        if (batchNumber > 0) {
            //EnphaseBatchHelper.runNextPull(lastEnphaseId);
        }
    } 
}