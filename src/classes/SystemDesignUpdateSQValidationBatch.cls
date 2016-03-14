global class SystemDesignUpdateSQValidationBatch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts{
    
    public String errors = '';
    private Integer batchNumber = 0;
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        String query ='';
        query+= 'SELECT Id FROM System_Design__c' ;
        query+= ' WHERE Astrum_SQ_Calculation_Status__c = \'Invalid\' AND LastModifiedDate = TODAY';
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        
        List<System_Design__c> sysDesigns = new List<System_Design__c>();
        
        for(SObject s: scope){
            System_Design__c sysDes = (System_Design__c)s;
            sysDesigns.add(sysDes);
        }        
        
        for(System_Design__c sysDesign:sysDesigns){
            try{
                System.debug('Calculating SiteQuality for SystemDesignId:' + sysDesign.Id );    
                SystemDesignSQCalculation.calculateSQ(sysDesign,'ASTRUM');                
                System.debug('Validating System Design for SystemDesignId:' + sysDesign.Id );     
                SalesWorkflowValidationUtility.validateSystemDesign(sysDesign, true, Date.today());     //Added date parameter for CPQ-751               
                System.debug('End of Validations for SystemDesignId:' + sysDesign.Id);                
            }catch(Exception e){
                errors += 'SystemDesign Id:' + sysDesign.Id + ' ' + e.getMessage() + ' ' + e.getStackTraceString();            
            }                
        }
    }
    
    global void finish(Database.BatchableContext bc){
        String[] toAddresses = new String[]{'pavitra.burla@directenergysolar.com','rohit.jain@directenergysolar.com'};
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        
        if (!String.isBlank(errors)) {            
            mail.setSubject('System Design SQ Validations completed with Errors');
            mail.setPlainTextBody(errors);                 
        }
        else{
            mail.setSubject('System design SQ Validations completed successfully without errors');
            mail.setPlainTextBody('System design SQ Validations completed successfully without errors');            
        }
        
        mail.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.Email[] { mail }, false);
        
    }

}