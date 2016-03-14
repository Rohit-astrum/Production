public with sharing class Site_Survey_Disqualified_Controller_Ext {

    private Event theEvent;

    public Opportunity opp {get;set;}
    public String errorFields { get; private set; }

    public String parentDomain{get;set;}
    public String updateStatus{ get; set; }
    public Boolean isD2DEvent { get; private set; }
   
   
    public Site_Survey_Disqualified_Controller_Ext (ApexPages.StandardController stdController) {
        if(!Test.isRunningTest()){
            stdController.addFields(new List<String> { 'D2D_Survey_Request__c', 'WhatId' });
        }
        theEvent = (Event)stdController.getRecord();
        
        isD2DEvent = theEvent.D2D_Survey_Request__c;

        opp = [SELECT Id, Property__c, StageName, Closed_Type__c, Closed_Reason__c FROM Opportunity WHERE Id = :theEvent.WhatId LIMIT 1];
        opp.StageName = 'Closed - Lost';
        opp.Closed_Type__c = 'D2D Disqualified';

        parentDomain = ApexPages.currentPage().getHeaders().get('referer');  
    }
   
    public PageReference updateEventCompleted() {
        if(opp.Closed_Reason__c == null || opp.Closed_Reason__c == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.WARNING, 'You must select a reason.'));
            return null;
        }
        Database.SaveResult  sr = Database.update(opp, false); 
        if (!sr.isSuccess()) {
            // Operation failed, so get all errors                
            for(Database.Error err : sr.getErrors()) { 
                errorFields = 'ERROR -';                   
                errorFields += err.getMessage() +'\n\n';
            }
        }
        else
        {
            if(theEvent.D2D_Survey_Request__c == true){
                // Verify there is a contract
                try {
                    Portal_Referral__c referral = [SELECT Id, D2D_Lead_Status__c, Email__c FROM Portal_Referral__c WHERE Opportunity__c = :opp.Id LIMIT 1];
                    referral.D2D_Lead_Status__c = 'Disqualified';
                    update referral;

                    String templateName = '';
                    if(opp.Closed_Reason__c == 'TSRF'){
                        templateName = 'Notify TSRF';
                    } else {
                        templateName = 'Notify Insufficient Savings';
                    }
                    D2D_Utility.SendEmailOutsideSalesforce(templateName, referral.Email__c, referral.Id, null);
                } catch(Exception ex) {
                    // return an error
                    system.debug('**SZ: exception = ' + ex.getMessage() + '; ' + ex.getStackTraceString());
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'A error occured updating the portal referral.'));
                    return null;
                }
            }

            theEvent.Event_Status__c = 'Completed';
            theEvent.Completed__c = true;
            theEvent.run_trigger__c = true;
            theEvent.Completed_Date__c = System.now();           
            update theEvent; 

            updateStatus = 'true';
        }
        return null;
    }
}