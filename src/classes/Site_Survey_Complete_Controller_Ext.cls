public class Site_Survey_Complete_Controller_Ext {

    private Event theEvent;
    private final static String SITE_SURVEY_TYPE_ONSITE = 'Site Survey Onsite';
    
    public Site_Survey_Complete_Controller_Ext(ApexPages.StandardController stdController) {
        if(!Test.isRunningTest()){
            stdController.addFields(new List<String> { 'D2D_Survey_Request__c', 'WhatId' });
        }
        theEvent = (Event) stdController.getRecord();
    }

   public PageReference updateEvent() {

        if (theEvent != null) {
            // Determine if this is a D2D Event
            if(theEvent.D2D_Survey_Request__c == true){
                // Verify there is a contract
                Opportunity opp = [SELECT Id, Property__c FROM Opportunity WHERE Id = :theEvent.WhatId LIMIT 1];
                try {
                    List<Astrum_Contract__c> contracts = [SELECT Id, Name FROM Astrum_Contract__c WHERE Proposal__r.System_Design_Quote__r.System_Design__r.Property__c = :opp.Property__c AND Proposal__r.Current__c = true LIMIT 1];
                    if(contracts.size() == 0){
                        // the contract doesn't exist, so return an error
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'A contract could not be found for this Opportunity.'));
                        return null;
                    } else {
                        // update the Portal Referral to Contract Generated
                        Portal_Referral__c referral = [SELECT Id, D2D_Lead_Status__c, D2D_Sales_Rep__c FROM Portal_Referral__c WHERE Opportunity__c = :opp.Id LIMIT 1];
                        referral.D2D_Lead_Status__c = 'Contract Generated';
                        update referral;

                        D2D_Utility.SendEmail('Notify Contract Generated', referral.D2D_Sales_Rep__c, referral.Id, null);
                    }
                } catch(Exception ex) {
                    // return an error
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'A contract could not be found for this Opportunity.'));
                    return null;
                }
            }

            // mark the event completed
            theEvent.Completed__c = true; 
            theEvent.Completed_Date__c = Datetime.now();    //DK 10-21-14

            update theEvent;
    
            Event tempEvent = [select OwnerId, whatId, Related_Property_Link__c from Event where id =:theEvent.id limit 1];
            
            Opportunity opp;
            try{
                opp = [Select o.id, o.Property__r.Property_ZIP__c, o.Property__r.Property_State__c, o.Property__r.Property_City__c, o.Property__r.Name, o.Property__c, 
                          o.Owner.Email, o.Owner.FirstName, o.Owner.LastName, o.OwnerId, o.Name 
                          From Opportunity o 
                          where id = :tempEvent.WhatId 
                          limit 1];

            }catch(QueryException qe){}

            if(opp!= null){
                // store the date completed                                 
                opp.Date_Site_Survey_Completed__c = Datetime.now();
                update opp;     
                    
                // send notification email
                Site_Survey_Complete_Utility.sendNotificationEmail(tempEvent, opp);
            }          
        }
        
        //  After Save, navigate to the default view page:  
        return (new ApexPages.StandardController(theEvent)).view();
    }    
}