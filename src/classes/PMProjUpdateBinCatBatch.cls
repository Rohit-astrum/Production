/*
 *  PMProjUpdateBinCatBatch projBatch = new PMProjUpdateBinCatBatch();
 *  Id batchId = Database.executeBatch(projBatch, 250);
 *  TODO: Bin complete check. If the bindate is null check for if bin is complate and update bin date.
 *  
 */
global class PMProjUpdateBinCatBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    public String errors = '';
    private Integer batchNumber = 0;    
    
    global PMProjUpdateBinCatBatch(){}
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        String query ='';
        query+= 'SELECT Id, Bin__c, PM_Project__c, Category__c ';
        query+= ' FROM Astrum_Doc__c';
        query+= ' WHERE PM_Project__c <> null AND Bin__c <> null AND Category__c <> null';
        query+= ' AND Bin__c IN(\'Drivers Licenses\',\'Kickoff Photos\', \'HOA Submitted Documents\',\'Utility Bill\'';
        query+= '   , \'Install Prep Sheet\', \'Signed Conduit Run and Layout\', \'Permit Design\'';
        query+= '   , \'Building Permit\', \'Electrical Permit\')';
        System.debug('*Query '+query);
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){

        List<Astrum_Doc__c> docsToUpdate = new List<Astrum_Doc__c>();
        
        for(SObject s: scope)
        {
            Astrum_Doc__c doc = (Astrum_Doc__c)s;
            docsToUpdate.add(doc);
        }

        //Reset Bin/Cat to new values
        for(Astrum_Doc__c doc: docsToUpdate){
            if(doc.Bin__c.equalsIgnoreCase('Drivers Licenses') &&  doc.Category__c.equalsIgnoreCase('Drivers License')){
                doc.Bin__c = 'Kickoff Documents';
            }
            if(doc.Bin__c.equalsIgnoreCase('Kickoff Photos') &&  doc.Category__c.equalsIgnoreCase('Property Photo')){
                doc.Bin__c = 'Kickoff Documents';
            }
            if(doc.Bin__c.equalsIgnoreCase('HOA Submitted Documents') &&  (doc.Category__c.equalsIgnoreCase('HOA Document') || doc.Category__c.equalsIgnoreCase('Historical Document'))){
                doc.Bin__c = 'Kickoff Documents';
            }            
            if(doc.Bin__c.equalsIgnoreCase('Utility Bill') &&  doc.Category__c.equalsIgnoreCase('Utility Bill')){
                doc.Bin__c = 'Kickoff Documents';
            }
            if(doc.Bin__c.equalsIgnoreCase('Install Prep Sheet') &&  doc.Category__c.equalsIgnoreCase('Install Prep Sheet')){
                doc.Bin__c = 'Kickoff Documents';
            }

            if(doc.Bin__c.equalsIgnoreCase('Signed Conduit Run and Layout') &&  doc.Category__c.equalsIgnoreCase('Conduit Run and Layout - Customer Signed')){
                doc.Bin__c = 'Approval Final Documents';
            }
            if(doc.Bin__c.equalsIgnoreCase('Permit Design') &&  doc.Category__c.equalsIgnoreCase('Structural Engineer Review')){
                doc.Bin__c = 'Structural Engineering';
            }
            if(doc.Bin__c.equalsIgnoreCase('Building Permit') &&  (doc.Category__c.equalsIgnoreCase('Building Permit Package') || doc.Category__c.equalsIgnoreCase('Approved Building Permit'))){
                doc.Bin__c = 'Permitting';
            }
            if(doc.Bin__c.equalsIgnoreCase('Electrical Permit') &&  (doc.Category__c.equalsIgnoreCase('Electrical Permit Package') || doc.Category__c.equalsIgnoreCase('Approved Electrical Permit'))){
                doc.Bin__c = 'Permitting';
            }
            // additional steps added later
            if(doc.Bin__c.equalsIgnoreCase('Permit Design') &&  (doc.Category__c.equalsIgnoreCase('System Design Plan'))){
                doc.Bin__c = 'Final Permit Documents';
                doc.Category__c = 'Final PDP';
            }
            if(doc.Bin__c.equalsIgnoreCase('Permit Design') &&  (doc.Category__c.equalsIgnoreCase('Structural Drawings'))){
                doc.Bin__c = 'Final Permit Documents';
                doc.Category__c = 'Structural Engineering Review';
            }             
        }
        TriggerUtility.skipAstrumDocVerificationTrigger = true;
        Database.SaveResult[] results;
        if(!docsToUpdate.isEmpty()){
            results = Database.update(docsToUpdate,false);
            for (Database.SaveResult result : results) {
                if (!result.isSuccess()) {
                    // Operation failed, so get all errors                
                    for(Database.Error err : result.getErrors()) {
                        errors += result.getId() + ':'+err.getFields() + ':' + err.getStatusCode() + ': ' + err.getMessage() +'\n\n';
                    }
                }
            } 
        }
        TriggerUtility.skipAstrumDocVerificationTrigger = false;

    }
    
    global void finish(Database.BatchableContext bc){
        String[] toAddresses = new String[]{'pavitra.burla@directenergysolar.com'};
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        
        if (!String.isBlank(errors)) {            
            mail.setSubject('PM Project Bin/Categories Update completed with Errors');
            mail.setPlainTextBody(errors);                 
        }
        else{
            mail.setSubject('M Project Bin/Categories Update completed successfully without errors');
            mail.setPlainTextBody(errors);            
        }        
        mail.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.Email[] { mail }, false);
        
    }

}