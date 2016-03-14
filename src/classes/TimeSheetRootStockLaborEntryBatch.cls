/* FILE: TimeSheetRootStockLaborEntryBatch.cls
 * AUTHOR: Pavitra Burla
 * DATE: Jan 22, 2015
 * PURPOSE: Upload Labor Entries to RootStock
 * MODIFICATION HISTORY
 */
global class TimeSheetRootStockLaborEntryBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful{
            
    public String query;
    public String batchErrors = '';
    private Integer batchNumber = 0;   
    
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        query = 'SELECT Status__c, Source_Program__c, Transaction_Type__c';
        query+= ', Work_Order__r.Id, Work_Order_Operation__r.Id, Transaction_Qty__c, Rate_Factor__c';
        query+= ', Labor_Booking_Hours__c, Booking_User__r.Id, Posted__c';
        query+= ' FROM TimeSheet_Labor_Entry__c';
        query+= ' WHERE Status__c = \'New\'';
         
        return Database.getQueryLocator(query);        
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        
        List<TimeSheet_Labor_Entry__c> laborEntries = new List<TimeSheet_Labor_Entry__c>();
        
        for(sObject s : scope){            
            TimeSheet_Labor_Entry__c laborEntry = (TimeSheet_Labor_Entry__c)s;
            laborEntries.add(laborEntry);            
        }
        
        List<rstk__sydata__c> sysdataTimes = new List<rstk__sydata__c>();
        
        for(TimeSheet_Labor_Entry__c laborEntry: laborEntries){            
            rstk__sydata__c sysdata = new rstk__sydata__c();
            sysdata.rstk__sydata_sourcepgm__c = laborEntry.Source_Program__c;
            sysdata.rstk__sydata_txntype__c = laborEntry.Transaction_Type__c;
            sysdata.rstk__sydata_wocst__c = laborEntry.Work_Order__r.Id;
            sysdata.rstk__sydata_woordopn__c = laborEntry.Work_Order_Operation__r.Id;            
			sysdata.rstk__sydata_ratefactor__c = laborEntry.Rate_Factor__c;
            sysdata.rstk__sydata_hours__c = laborEntry.Labor_Booking_Hours__c;
            sysdata.rstk__sydata_bksyusr__c = laborEntry.Booking_User__r.Id;
			sysdata.rstk__sydata_txnqty__c = laborEntry.Transaction_Qty__c;            
            sysdataTimes.add(sysdata);
        }
        
        Database.UpsertResult result;
        
        //Insert Time to Rootstock- Currently only one record can be inserted at a time, due to limitation in Rootstock
        for(Integer i=0;i<sysdataTimes.size();i++){
           result = Database.upsert(sysdataTimes[i], false);
            if (!result.isSuccess()) {
                // Operation failed, so get all errors                
                for(Database.Error err : result.getErrors()) {
                    batchErrors += result.getId() + ':'+err.getFields() + ':' + err.getStatusCode() + ': ' + err.getMessage() +'\n\n';
                    laborEntries[i].Error_Message__c = err.getMessage();
                }
            }else{
                //Update to Posted
                String err = [SELECT rstk__sydata_message__c FROM rstk__sydata__c WHERE Id =:result.getId()].rstk__sydata_message__c;
                if(String.isBlank(err)){
                    laborEntries[i].Posted__c = true;
                    laborEntries[i].Status__c = 'Processed';
                    laborEntries[i].Error_Message__c = null;                    
                }else{
                    if(Test.isRunningTest())
                    {
                        batchErrors += result.getId() + err;  
                    }
                    laborEntries[i].Error_Message__c = err;
                    laborEntries[i].Status__c = 'Error';
                }                 
            }
        }
        
        update laborEntries;
        
    }
    
    global void execute(SchedulableContext sc){
        
        TimeSheetRootStockLaborEntryBatch batch = new TimeSheetRootStockLaborEntryBatch();
        Id batchId = Database.executeBatch(batch, 1);
        
    }
    
    global void finish(Database.BatchableContext bc){
        
        if (batchErrors != '') {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(UserInfo.getUserId());
            mail.setSubject('Time Sheet Labor Entry Batch Errors');
            mail.setPlainTextBody(batchErrors);
            mail.setSaveAsActivity(false);
            Messaging.sendEmail(new Messaging.Email[] { mail }, false);     
        }
        
    }    
}