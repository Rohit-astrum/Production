public without sharing class PortalAffiliateHomeController {
    
    public Integer totalReferrals { get; private set; }        
    public Integer totalSold { get; private set; }
    public String partnerSince { get; private set; }
    private Id accountId;
    private String partnerType;
    public List<Portal_Outreach_Tool__c> getTools() {   
    
        List<Portal_Outreach_Tool__c> result =
            [SELECT Id, Name, Description__c,
                (SELECT Id, Name, BodyLength, ContentType, Description
                FROM Attachments)
            FROM Portal_Outreach_Tool__c
            WHERE Active__c = TRUE
            AND Type__c = 'Flyers (PDF)'
            AND Partner_Type__c INCLUDES (:partnerType)
            AND Portal_Availability__c INCLUDES ('Partner Portal')];

        return result;
        
    }
    
    public List<Portal_Outreach_Tool__c> getWebTools() {   
    
        List<Portal_Outreach_Tool__c> result =
            [SELECT Id, Name, Description__c,
                (SELECT Id, Name, BodyLength, ContentType, Description
                FROM Attachments)
            FROM Portal_Outreach_Tool__c
            WHERE Active__c = TRUE
             AND Type__c = 'Web Ads (JPG)'
            AND Partner_Type__c INCLUDES (:partnerType)
            AND Portal_Availability__c INCLUDES ('Partner Portal')];

        return result;
        
    }
    
    public PortalAffiliateHomeController () {
        User u = [SELECT Id, ContactId, CreatedDate FROM User WHERE Id = :UserInfo.getUserId()];
        Contact c = [SELECT Id, AccountId, Account.Partner_Type__c FROM Contact WHERE Id = :u.ContactId];
        accountId = c.AccountId;
        partnerType= c.Account.Partner_Type__c;
        AggregateResult[] minLeadDate = 
            [SELECT MIN(Lead_Created_Date__c) sinceDate 
            FROM Portal_Referral__c
            WHERE Account__c = :accountId
            AND Lead_Created_Date__c <> NULL 
            AND Status__c <> 'Duplicate'];
        
        if (minLeadDate.size() > 0 && minLeadDate[0].get('sinceDate') != null) {
          partnerSince = DateTime.newInstance((Date)minLeadDate[0].get('sinceDate'), Time.newInstance(0, 0, 0, 0)).format('MMMM, yyyy');
        } else {
          partnerSince = u.CreatedDate.format('MMMM, yyyy');
        } 
        
        populateSummary();
    }
    
    private void populateSummary() {
        totalReferrals = 0;
        //get earnings
        AggregateResult[] sumEarnings = 
          [SELECT COUNT(Id) referrals 
          FROM Portal_Referral__c 
          WHERE Account__c = :accountId 
          AND Status__c <> 'Duplicate'];
        
        if (sumEarnings.size() > 0) {         
          Decimal total = (Decimal)sumEarnings[0].get('referrals');
          if (total != null) {
            totalReferrals = total.intValue();            
          }
        }     
        
        totalSold = 0; 
        //get earnings
        AggregateResult[] statusSummary = 
          [SELECT COUNT(Id) referrals 
          FROM Portal_Referral__c 
          WHERE Account__c = :accountId 
          AND Status__c != NULL 
          AND Status__c = 'SOLD'];
        
        if (statusSummary.size() > 0) {         
          Decimal totalsd = (Decimal)statusSummary [0].get('referrals');
          if (totalsd != null) {
            totalSold = totalsd.intValue();            
          }
        }  
       
    }
}