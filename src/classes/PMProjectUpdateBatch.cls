/*
 *  PMProjectUpdateBatch projBatch = new PMProjectUpdateBatch();
 *  Id batchId = Database.executeBatch(projBatch,250);
 *  
 */
global class PMProjectUpdateBatch implements Database.Batchable<sObject>, Database.Stateful{
    public String errors = '';
    private Integer batchNumber = 0;
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        String query ='SELECT Permit_Design__c FROM PM_Project__c WHERE Permit_Design__c <> null';
        
        System.debug('*Query '+query);
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){

        List<PM_Project__c> projs = new List<PM_Project__c>();
        
        for(SObject s: scope)
        {
            PM_Project__c proj = (PM_Project__c)s;
            projs.add(proj);
        }

        if(projs != null){
            for(PM_Project__c proj:projs){
                proj.Final_Structural_Engineering_Documents__c = proj.Permit_Design__c;
            }            
        }
        
        TriggerUtility.skipPMProjectTriggers = true;
        Database.SaveResult[] results;
        if(!projs.isEmpty()){
            results = Database.update(projs,false);
            for (Database.SaveResult result : results) {
                if (!result.isSuccess()) {
                    // Operation failed, so get all errors                
                    for(Database.Error err : result.getErrors()) {
                        errors += result.getId() + ':'+err.getFields() + ':' + err.getStatusCode() + ': ' + err.getMessage() +'\n\n';
                    }
                }
            } 
        }
        TriggerUtility.skipPMProjectTriggers = false;

    }
    
    global void finish(Database.BatchableContext bc){
        String[] toAddresses = new String[]{'pavitra.burla@directenergysolar.com'};
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        
        if (!String.isBlank(errors)) {            
            mail.setSubject('PM Project  Update completed with Errors');
            mail.setPlainTextBody(errors);                 
        }
        else{
            mail.setSubject('PM Project  Update completed successfully without errors');
            mail.setPlainTextBody(errors);            
        }        
        mail.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.Email[] { mail }, false);
        
    }

}