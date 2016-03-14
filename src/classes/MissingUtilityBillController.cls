public with sharing class MissingUtilityBillController {

    public System_Design_Quote__c sdq {get;set;}
    public Portal_Referral__c referral {get;set;}
    //public String errorFields { get; private set; }


    public String notes{ get; set; }
    public String parentDomain{get;set;}
    //public String updateStatus{ get; set; }
    public Boolean isD2D {get; set;}
   
   
    public MissingUtilityBillController () {
        /*if(!Test.isRunningTest()){
            stdController.addFields(new List<String> { 'D2D_Survey_Request__c', 'WhatId' });
        }
        */
        String sdqID = ApexPages.currentPage().getParameters().get('id');
        if (String.isBlank(sdqID)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'SDQ ID not found'));
            return;
        }
        try {
            sdq = [SELECT Id, Community_Program_Offer__r.RecordType.DeveloperName, System_Design__r.Property__c FROM System_Design_Quote__c WHERE ID = :sdqID LIMIT 1];  
            
            referral = [SELECT Id, D2D_Lead_Status__c, D2D_Sales_Rep__r.Email, Notes__c FROM Portal_Referral__c WHERE Opportunity__r.Property__c = :sdq.System_Design__r.Property__c LIMIT 1];  
            
            isD2D = false;  //default
            if (sdq.Community_Program_Offer__c != null && sdq.Community_Program_Offer__r.RecordType.DeveloperName == 'Door_to_Door')
              isD2D = true;
              
            parentDomain = ApexPages.currentPage().getHeaders().get('referer'); 
              
        } catch (Exception ex){
            ApexPages.addMessages(ex);
            return;
        }
    }
   
    public PageReference updateEventCompleted() {
        
        try {
        
            referral.D2D_Lead_Status__c = 'Missing Utility Bill';
            
            if(referral.Notes__c == null){
                referral.Notes__c = Datetime.now()  + ': Utility Bill Missing. ' + notes;
            } else {
                referral.Notes__c += '\n' + Datetime.now() + ': Utility Bill Missing. ' + notes;
            }
            update referral;
            
            D2D_Utility.SendEmailOutsideSalesforce('Notify Missing Utility Bill', referral.D2D_Sales_Rep__r.Email, referral.Id, null);
            
            return null;
        
        } catch (Exception ex){
            ApexPages.addMessages(ex);
            return null;
        }
    }
}