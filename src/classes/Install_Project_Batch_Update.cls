global class Install_Project_Batch_Update implements Database.Batchable<sObject>{
public String query = 'Select Id from Install_Project__c';

global Database.QueryLocator start(Database.BatchableContext BC){
    return Database.getQueryLocator(query);
}

global void execute(Database.BatchableContext BC, List<sObject> scope){
    
    Map<Id, Time_Sheet__c> timeSheetMap = new Map<Id, Time_Sheet__c>();
    Time_Sheet__c ts = [Select Id,Name from Time_Sheet__c limit 1];
    timeSheetMap.put(ts.Id,ts);
    
    List<Id> ProjIds = new List<Id>();
        
    for(sObject s : scope)
    {
      
      ProjIds.add((ID)S.Id);
             
    }
    
    Time_Sheet_Trigger_Utility.computeHoursAndPay(timeSheetMap,ProjIds);
  
}
global void finish(Database.BatchableContext BC){
    }

static testMethod void myTest() {
           Install_Project_Batch_Update ipBatch = new Install_Project_Batch_Update();  
           ipBatch.query =  'Select Id from Install_Project__c Limit 200';
           Test.startTest();
           database.executeBatch(ipBatch,200); 
           Test.stopTest();
        }     
}