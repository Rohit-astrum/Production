/* FILE: PMProjUpdateBinCompleteBatch.cls
 * AUTHOR: Pavitra Burla
 * DATE: Dec 15, 2015
 * PURPOSE: To back fill Bin Complete Date for historic projects.
 * USAGE:
 *  PMProjUpdateBinCompleteBatch projBatch = new PMProjUpdateBinCompleteBatch();
 *  Id batchId = Database.executeBatch(projBatch, 10);
 *  
 */
global class PMProjUpdateBinCompleteBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    public String errors = '';
    public Integer queryNumber = 0;	    
    
    global PMProjUpdateBinCompleteBatch(){}
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        String query ='';
        query+= 'SELECT Status__c,Installation_Photos__c FROM PM_Project__c';
        if(Test.isRunningTest()){
            query+= ' LIMIT 1';
        }
        System.debug('*Query '+query);
        return Database.getQueryLocator(query);        
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        
        List<PM_Project__c> projsToUpdate = new List<PM_Project__c>();
        
        for(SObject s: scope)
        {
            PM_Project__c proj = (PM_Project__c)s;
            projsToUpdate.add(proj);
        }

        //Update Complete date
        for(PM_Project__c proj:projsToUpdate){
            System.debug('**Project' + proj.Id);
            for(Bin_Configuration__c binConfig:binConfigs){
                System.debug('**Bin' + binConfig.Bin__c);
                proj = updateBinComplete(proj, binConfig.Bin__c);        
            }
            System.debug('******proj:' + proj.Kickoff_Documents__c + proj.Approval_Final_Documents__c + proj.Structural_Engineering__c + proj.Permitting__c); 
        }

        
        
        Database.SaveResult[] results;
        if(!projsToUpdate.isEmpty()){
            results = Database.update(projsToUpdate,false);
            for (Database.SaveResult result : results) {
                if (!result.isSuccess()) {
                    // Operation failed, so get all errors                
                    for(Database.Error err : result.getErrors()) {
                        errors += result.getId() + ':'+err.getFields() + ':' + err.getStatusCode() + ': ' + err.getMessage() +'\n\n';
                    }
                }
            } 
        }
        queryNumber+= Limits.getQueries();
        System.debug('**queryNumber' + queryNumber);       

    }
    
    global void finish(Database.BatchableContext bc){
        String[] toAddresses = new String[]{'pavitra.burla@directenergysolar.com'};
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        
        if (!String.isBlank(errors)) {            
            mail.setSubject('PM Project BinComplete Update completed with Errors' );
            mail.setPlainTextBody(errors);                 
        }
        else{
            mail.setSubject('PM Project BinComplete Update completed successfully without errors' );
            mail.setPlainTextBody(errors);            
        }        
        mail.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.Email[] { mail }, false);
        
    }

    public static PM_Project__c updateBinComplete(PM_Project__c project, String binName) {
        //Back fill Bin date for historic projects
        String projectId = project.Id;
        List<date> binDatelist= new List<date>();   
        Integer totalRequiredCategories = 0;
        Integer completedRequiredCategories = 0;

        //count docs and get dates
        Map<String, AggregateResult> categoryMap = new Map<String, AggregateResult>();
        List<AggregateResult> summary = 
            [SELECT Category__c, COUNT(Id) total, MAX(Document_Key_Date__c) keyDate, MAX(CreatedDate) modDate  
             FROM Astrum_Doc__c
             WHERE PM_Project__c = :project.Id
             AND Bin__c = :binName 
             GROUP BY Category__c];
        for (AggregateResult result: summary) {
            categoryMap.put((String)result.get('Category__c'), result);
        }

        //find the field name for the date when bin completed
        String binDateField;

        for (Bin_Configuration__c bc : binConfigs) {
            if (bc.Bin__c == binName) {
                binDateField = bc.Field_Name__c;
                break;
            }
        }

        //nothing to update
        if (binDateField == null) {
            return null;
        }

        //get the current project dates and reset the project object dates
        String query = 'SELECT Id';
        if (binDateField != null) {
            query += ', ' + binDateField + ' ';
            //clear the bin date
            project.put(binDateField, null);
        }

        query += ' FROM PM_Project__c WHERE Id = :projectId';
        PM_Project__c existing = Database.query(query);

        //determine the bin complete date
        Date categoryBinDate;
        Boolean categoryDateRequired;
        for (Category_Configuration__c cat : categories) {
            if (cat.Bin__c == binName && cat.Minimum_Required__c != null && cat.Minimum_Required__c >= 1) {
                System.debug('1*'+cat.Bin__c);
                totalRequiredCategories++;                
                AggregateResult result = categoryMap.get(cat.Category__c);
                if (result == null) {
                    continue;
                }
                //check if the total number of required is there
                Integer total = (Integer)result.get('total');
                if (total != null) {
                    if(total >= cat.Minimum_Required__c){
                        completedRequiredCategories++;
                    }
                    if(total >= cat.Minimum_Required__c ||(project.Installation_Photos__c != null) || 'Final Complete'.equalsIgnoreCase(project.Status__c) || 'PL Complete'.equalsIgnoreCase(project.Status__c)){
                        Date possibleBinDate = (Date)result.get('keyDate');
                        if (possibleBinDate == null) {
                            possibleBinDate = ((Datetime)result.get('modDate')).date();
                        }
                        if (possibleBinDate != null) {
                            binDatelist.add(possibleBinDate);
                        }                        
                    }           
                }
            } 
        }

        //bin is complete if the number of completed categories equals the number of required categories and there is at least one document     
        if ((summary.size() > 0) && (binDatelist.size()>0)) {
            if((totalRequiredCategories == completedRequiredCategories) || (project.Installation_Photos__c != null) || 'Final Complete'.equalsIgnoreCase(project.Status__c) || 'PL Complete'.equalsIgnoreCase(project.Status__c)){
                binDatelist.sort();
                System.debug('**********bin date is:' + binDatelist.get(binDatelist.size() -1));      
                project.put(binDateField, binDatelist.get(binDatelist.size() -1));
                
            }
        }
        return project;
    }

    public static List<Bin_Configuration__c> binConfigs { 
        get { 
            if (binConfigs == null) {
                binConfigs = [SELECT Id, Bin__c, Bin_Grouping_Name__c, Field_Name__c, Bin_Column_Width__c
                                FROM Bin_Configuration__c
                                WHERE Astrum_Application__r.Name = :DocumentConfigurationHelper.APP_ASTRUM_PM_20
                                AND Bin__c IN('Kickoff Documents','Approval Final Documents','Structural Engineering','Permitting')     
                                ORDER BY Bin_Order__c, Bin__c];
                
            }
            return binConfigs;
        }
        private set;
    }
    
    public static List<Category_Configuration__c> categories { 
        get { 
            if (categories == null) {
                categories = DocumentConfigurationHelper.getAllCategories(DocumentConfigurationHelper.APP_ASTRUM_PM_20);
            }
            return categories;
        }
        private set;
    }

}