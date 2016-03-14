/* FILE: LeadTriggerBITest.cls
 * MODIFICATION HISTORY
 * 12/12/2014 PB - Added test method for lead Status change based on number of dials
 */

@isTest
private class LeadTriggerBITest {
    
    @isTest static void webToLeadReferringAcctTest() {
        
        Account refAcct = new Account();
        refAcct.Name = 'Ref Acct';
        String refid = refAcct.Id;
        insert refAcct;

        Lead newLead = new Lead();
        newLead.LastName = 'TestLeasd';
        newLead.LeadSource = 'Partner Referral';
        newLead.LeadSource = 'Strategic';
        newLead.Method_of_Contact__c = 'Astrum Web Form';
        newLead.Web_To_Lead_Referral_Account_Id__c = refid;
        newLead.Company = 'TestLeasd';
        insert newLead;
        System.debug(newLead.Referring_Account__c+'   '+refid );
        System.assertEquals(newLead.Referring_Account__c,refid);

    }
    
    @isTest static void leadStatusChangeTest(){
                
        Lead_Status_Change_Setting__c cs = new Lead_Status_Change_Setting__c();        
        cs.Number_Of_Dials__c = 6;        
        insert cs;

        Lead l = new Lead();
        l.Lead_Date__c = date.Today();
        l.LastName = 'Test Lead';
        l.Site_Type__c = 'Residential';
        l.Company = 'Test Company';
        l.Status = 'Open – New';
        l.LeadSource = 'Online Ad';
        l.Lead_Source_Detail__c = 'Professional';
        l.Method_Of_Contact__c = 'Other';
        l.qbdialer__Dials__c = 5;        
        insert l;
        
        Test.startTest();

        l.qbdialer__Dials__c = 6;        
        update l;        
        
        Test.stopTest(); 

        l = [SELECT Status FROM Lead WHERE Id =: l.Id];
        System.assertEquals('Unresponsive', l.Status);

    }
    
}