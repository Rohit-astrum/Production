global class SystemDesignUpdateBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    public String errors = '';
    private Integer batchNumber = 0;
    public Map<String,Id> productsMap;
    public Map<String,String> prodDescCalcToSFMap;
    
    global SystemDesignUpdateBatch(){
        
        productsMap =  new Map<String,Id>();
        
        ID recId = Schema.Sobjecttype.System_Design_Product__c.getRecordTypeInfosByName().get('Mounting').getRecordTypeId();
        List<System_Design_Product__c> sysProducts= [SELECT Id, Description__c 
                                                      FROM System_Design_Product__c 
                                                      WHERE RecordTypeId =:recId];
        for(System_Design_Product__c prod: sysProducts){
            productsMap.put(prod.Description__c, prod.Id);
            System.debug('Adding sdp to Map:' + prod.Id + '' + prod.Description__c);
        }
        
        prodDescCalcToSFMap = new Map<String,String>();
        prodDescCalcToSFMap.put('Attached Through Metal Panel Roof','Flush mounted on tilted roof with penetrations');
        prodDescCalcToSFMap.put('Ballasted System','Flush mounted on flat roof no penetrations');
        prodDescCalcToSFMap.put('Clamped on Metal Seam','Clamped on metal seams, flat or tilted');
        prodDescCalcToSFMap.put('Flush Mounted on curved concrete tile, penetrations','Curved Concrete Tile');
        prodDescCalcToSFMap.put('Flush Mounted on flat concrete tile, penetrations','Flat Concrete Tile');
        prodDescCalcToSFMap.put('Flush Mounted on flat roof, no penetrations','Flush mounted on flat roof no penetrations');
        prodDescCalcToSFMap.put('Flush Mounted on flat roof, penetrating','Flush or tilted off of flat roof with penetrations');
        prodDescCalcToSFMap.put('Flush Mounted on pitched roof, penetrating','Flush mounted on tilted roof with penetrations');
        prodDescCalcToSFMap.put('Flush Mounted on Slate Shingle, penetrating','Clay/LightWeight Tile (requires comp shingle re-roof)');
        prodDescCalcToSFMap.put('Flush Mounted on tile roof, requires comp shingle re-roof, penetrations','Clay/LightWeight Tile (requires comp shingle re-roof)');
        prodDescCalcToSFMap.put('Ground Mount','Ground Mount - Portrait MPM');
        prodDescCalcToSFMap.put('I-Beam','I-Beam Installation');
        prodDescCalcToSFMap.put('RapidRac','Tilted off of flat roof with no penetrations');
        prodDescCalcToSFMap.put('Tilted off flat roof, no penetrations','Tilted off of flat roof with no penetrations');
        prodDescCalcToSFMap.put('Tilted off flat roof, penetrations','Flush or tilted off of flat roof with penetrations');
        
        for(String prodCalcDesc: prodDescCalcToSFMap.keySet()){
            productsMap.put(prodCalcDesc,productsMap.get(prodDescCalcToSFMap.get(prodCalcDesc)));
        }

        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        String query ='';
        query+= 'Select Property__c from Opportunity Where StageName Not in (\'Closed - Won\', \'Closed - Lost\', \'Contract Cancelled\' ) And Property__c != null';
        System.debug('*Query '+query);
        return Database.getQueryLocator(query);
        /*
        query+= 'SELECT Id, (SELECT Default_Mounting_Type__c,Mounting_Type__c, CB_Panel__r.Utility_Service__c';
        query+= '         FROM System_Design_Arrays__r';
        query+= '         WHERE Default_Mounting_Type__c = null AND Mounting_Type__c != null)';
        query+= 'FROM System_Design__c WHERE Id IN (SELECT System_Design__c FROM System_Design_Array__c)';
        return Database.getQueryLocator(query);
        */
        
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        
        
        Opportunity_Trigger_Utility.skipOpportunityTrigger = true;
        SystemDesignTriggerHandler.skipSystemDesignTrigger = true;
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = true;
        SalesOrderTriggerHandler.skipSalesOrderTrigger = true;


        List<Opportunity> opps = new List<Opportunity>();
        Set<Id> propIds = new Set<Id>();
        for(SObject s: scope)
        {
            Opportunity opp = (Opportunity)s;
            System.debug('**opp - '+ opp.Id);
            if(opp.Property__c != null)
            {
                propIds.add(opp.Property__c);
            }
        }
        System.debug('**propIds '+ propIds.size());


        List<System_Design__c> sysDesigns = [SELECT Id, (SELECT Default_Mounting_Type__c,Mounting_Type__c, CB_Panel__r.Utility_Service__c
                                                FROM System_Design_Arrays__r WHERE Default_Mounting_Type__c = null AND Mounting_Type__c != null) 
                                                FROM System_Design__c WHERE Property__c in :propIds];
        
        
        System.debug('**sysDesigns '+ sysDesigns.size());
        /*
        for(SObject s: scope){
            System_Design__c sysDes = (System_Design__c)s;
            sysDesigns.add(sysDes);
        }
        */
        
        List<System_Design_Array__c> arraysToUpdate = new List<System_Design_Array__c>();
        List<Utility_Service__c> utilityServicesToUpdate = new List<Utility_Service__c>();
        Set<Id> utilityServicesSet = new Set<Id>();
        
        try{
            for(System_Design__c sysDes: sysDesigns){
                System.debug('**sysDes - '+ sysDes.Id);
                if(sysDes.System_Design_Arrays__r != null){
                    System.debug('**System_Design_Arrays__r '+ sysDes.System_Design_Arrays__r.size());
                    for(System_Design_Array__c arr: sysDes.System_Design_Arrays__r){
                        if(productsMap.containsKey(arr.Mounting_Type__c)){
                            arr.Default_Mounting_Type__c = productsMap.get(arr.Mounting_Type__c);
                            arraysToUpdate.add(arr);
                            utilityServicesSet.add(arr.CB_Panel__r.Utility_Service__c);
                            System.debug('Updating Systemdesign:' + arr.System_Design__c + ' ' + 'sdarray:' + arr.Id);            
                        }        
                    }                    
                }                    
            }
            
            utilityServicesToUpdate = [SELECT Id, Utility_Company__c, Utility_Company__r.Utility_Company_Master__c 
                                                                FROM Utility_Service__c 
                                                                WHERE Id IN:utilityServicesSet];
            for(Integer i = 0; i< utilityServicesToUpdate.size() ;i++){
                if(utilityServicesToUpdate[i].Utility_Company__c != null)
                {
                    System.debug('Updating utility service:' + utilityServicesToUpdate[i].Id);
                    utilityServicesToUpdate[i].Utility_Rate_Code_Before_Solar__c = utilityServicesToUpdate[i].Utility_Company__c;
                    utilityServicesToUpdate[i].Utility_Rate_Code_After_Solar__c = utilityServicesToUpdate[i].Utility_Company__c;
                    utilityServicesToUpdate[i].Utility_Company_Master__c = utilityServicesToUpdate[i].Utility_Company__r.Utility_Company_Master__c;     
                }
            }
            
        }catch(Exception e){
            errors += 'SystemDesign Id:' + sysDesigns[0].Id + ' ' + e.getMessage() + ' ' + e.getStackTraceString();            
        }
        
        
        if(String.isBlank(errors)){
            Database.SaveResult[] results;
            if(!arraysToUpdate.isEmpty()){
                results = Database.update(arraysToUpdate,false);
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()) {
                        // Operation failed, so get all errors                
                        for(Database.Error err : result.getErrors()) {
                            errors += result.getId() + ':'+err.getFields() + ':' + err.getStatusCode() + ': ' + err.getMessage() +'\n\n';
                        }
                    }
                } 
            }
            
            if(!utilityServicesToUpdate.isEmpty()){
                results = Database.update(utilityServicesToUpdate,false);
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()) {
                        // Operation failed, so get all errors                
                        for(Database.Error err : result.getErrors()) {
                            errors += result.getId() + ':'+err.getFields() + ':' + err.getStatusCode() + ': ' + err.getMessage() +'\n\n';
                        }
                    }
                } 
            }
            System.debug('Updated SDAs and UtilityServices');            
        }

        Opportunity_Trigger_Utility.skipOpportunityTrigger = false;
        SystemDesignTriggerHandler.skipSystemDesignTrigger = false;
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = false;
        SalesOrderTriggerHandler.skipSalesOrderTrigger = false;

    }
    
    global void finish(Database.BatchableContext bc){
        String[] toAddresses = new String[]{'rohit.jain@directenergysolar.com'};
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //mail.setTargetObjectId(UserInfo.getUserId());
        mail.setToAddresses(toAddresses);
        
        if (!String.isBlank(errors)) {
            
            mail.setSubject('System Design Update completed with Errors');
            mail.setPlainTextBody(errors);
                 
        }
        else{
            mail.setSubject('System design update completed successfully without errors');
            mail.setPlainTextBody(errors);
            
        }
        
        mail.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.Email[] { mail }, false);
        
    }

}