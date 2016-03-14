/* FILE: LeadPortalReferralTriggerTest.trigger
 * AUTHOR: Tino Mattheou
 * DATE: September 5, 2012
 * PURPOSE: test class for LeadPortalReferral trigger
 * MODIFICATION HISTORY
 * 10/09/2012 TCM - updates to connect referring account leads to portal
 *
 */
 
@isTest(SeeAllData=true)
public class LeadPortalReferralTriggerTest {

    static testMethod void referral_changeLeadToContacted_detailChanged() {
        
        Portal_Referral__c referral = createPortalReferral();
        
        referral = [SELECT Id, Lead__c, Status__c, Detail__c
            FROM Portal_Referral__c
            WHERE Id = :referral.Id];
            
        System.assertEquals(PortalReferralStatus.OPEN_STATUS, referral.Status__c);
        System.assertEquals('New', referral.Detail__c);     
        
        Test.startTest();
        
        Lead ld = new Lead(
            Id = referral.Lead__c,
            Status = 'Contacted by Us'
        );
        update ld;
        
        Test.stopTest();

        referral = [SELECT Id, Lead__c, Status__c, Detail__c
            FROM Portal_Referral__c
            WHERE Id = :referral.Id];
            
        System.assertEquals(PortalReferralStatus.OPEN_STATUS, referral.Status__c);
        System.assertEquals('Contacted By Us', referral.Detail__c);     
        
    }
    
    static testMethod void referral_convertToOpportunity_detailChanged() {
        
        Portal_Referral__c referral = createPortalReferral();
        
        referral = [SELECT Id, Lead__c, Status__c, Detail__c
            FROM Portal_Referral__c
            WHERE Id = :referral.Id];
            
        System.assertEquals(PortalReferralStatus.OPEN_STATUS, referral.Status__c);
        System.assertEquals('New', referral.Detail__c);     
        
        Test.startTest();
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(referral.Lead__c);
        lc.setConvertedStatus('Qualified');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        Test.stopTest();

        System.assert(lcr.isSuccess());

        referral = [SELECT Id, Lead__c, Status__c, Detail__c
            FROM Portal_Referral__c
            WHERE Id = :referral.Id];
            
        System.assertEquals(PortalReferralStatus.QUALIFIED_STATUS, referral.Status__c);
        System.assertEquals('Evaluation in Progress', referral.Detail__c);      
        
    }
    
    static testMethod void referralWithOpp_changeLeadToContactedUs_detailChanged() {
        
        Portal_Referral__c referral = createPortalReferral();
            
        Account customer = new Account(Name = 'Test Customer');
        insert customer;
        Property__c property = CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');
        Opportunity opp = CreateAstrumPM2ProjectTest.createOpportunity(customer.Id, 'Test Oppty');
        
        referral.Opportunity__c = opp.Id;
        update referral;        
        
        referral = [SELECT Id, Lead__c, Status__c, Detail__c
            FROM Portal_Referral__c
            WHERE Id = :referral.Id];
            
        System.assertEquals(PortalReferralStatus.OPEN_STATUS, referral.Status__c);
        System.assertEquals('New', referral.Detail__c);     
        
        Test.startTest();
        
        Lead ld = new Lead(
            Id = referral.Lead__c,
            Status = 'Contacted Us Back'
        );
        update ld;
        
        Test.stopTest();

        referral = [SELECT Id, Lead__c, Status__c, Detail__c
            FROM Portal_Referral__c
            WHERE Id = :referral.Id];
            
        System.assertEquals(PortalReferralStatus.OPEN_STATUS, referral.Status__c);
        System.assertEquals('New', referral.Detail__c);     
        
    }

    static testMethod void standaloneLead_changeLeadToContactedUs_codeCoverage() {
        
        Lead ld = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Lead, Test'
        );
        insert ld;
        
        Test.startTest();
        
        ld.Status = 'Contacted Us Back';
        update ld;
        
        Test.stopTest();

    }
    
    static testMethod void portalAccount_insertLead_referralCreated() {
        
        Portal_Payment_Plan__c plan = new Portal_Payment_Plan__c();
        insert plan;
        
        User u = PortalToolsTest.createPortalUser();

        Account a = 
            [SELECT Id, Name, Portal_Payment_Plan__c 
            FROM Account
            WHERE Id IN (SELECT AccountId FROM Contact WHERE Id = :u.ContactId)];
        
        a.Portal_Payment_Plan__c = plan.Id;
        update a;
        
        Test.startTest();
        
        Lead ld = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Lead, Test',
            Street = '123 Test St',
            City = 'Test City',
            State = 'PA',
            PostalCode = '19403',
            County__c = 'Chester',
            Phone = '(215) 555-1212',
            Email = 'test@test.com',
            LeadSource = 'Individual Referral',
            Referring_Account__c = a.Id
        );
        insert ld;
        
        Test.stopTest();
        
        Portal_Referral__c referral = 
            [SELECT Id, First_Name__c, Last_Name__c, Street__c, City__c, State__c, Zip__c, 
                Email__c, Account__c, Phone__c, Portal_Payment_Plan__c, Status__c, Detail__c
            FROM Portal_Referral__c
            WHERE Lead__c = :ld.Id];
            
        System.assertEquals(ld.FirstName, referral.First_Name__c);
        System.assertEquals(ld.LastName, referral.Last_Name__c);
        System.assertEquals(ld.Street, referral.Street__c);
        System.assertEquals(ld.City, referral.City__c);
        System.assertEquals(ld.State, referral.State__c);
        System.assertEquals(ld.PostalCode, referral.Zip__c);
        System.assertEquals(ld.Phone, referral.Phone__c);
        System.assertEquals(ld.Email, referral.Email__c);
        System.assertEquals(a.Id, referral.Account__c);
        System.assertEquals(plan.Id, referral.Portal_Payment_Plan__c);
        
        System.assertEquals(PortalReferralStatus.OPEN_STATUS, referral.Status__c);
        System.assertEquals('New', referral.Detail__c);     

    }
    
    static testMethod void portalAccount_convertLead_referralCreated() {
        
        //create portal account and set payment plan
        Portal_Payment_Plan__c plan = new Portal_Payment_Plan__c();
        insert plan;
        
        User u = PortalToolsTest.createPortalUser();

        Account a = 
            [SELECT Id, Name, Portal_Payment_Plan__c 
            FROM Account
            WHERE Id IN (SELECT AccountId FROM Contact WHERE Id = :u.ContactId)];
        
        //create a lead
        Lead ld = new Lead (
            FirstName = 'Test',
            LastName = 'Lead', 
            Site_Type__c = 'Residential', 
            Company = 'Lead, Test',
            Street = '123 Test St',
            City = 'Test City',
            State = 'PA',
            PostalCode = '19403',
            County__c = 'Chester',
            Phone = '(215) 555-1212',
            Email = 'test@test.com',
            Method_of_Contact__c = 'Referral', 
            LeadSource = 'Individual Referral',
            Lead_Source_Detail__c = 'Employee',
           //Lead_Source_Detail_2__c = 'Channel',
           // Lead_Source_Detail_4__c = 'Astrum Solar Connect',
            Referring_Account__c = a.Id
        );
        insert ld;

        //make sure there isn't a referral      
        System.assertEquals(0, [SELECT count() FROM Portal_Referral__c WHERE Lead__c = :ld.Id]);

        //set the payment plan      
        a.Portal_Payment_Plan__c = plan.Id;
        update a;
                
        Test.startTest();
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(ld.Id);
        lc.setConvertedStatus('Qualified');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        Test.stopTest();
        
        Lead ld2 = [SELECT Id, ConvertedOpportunityId FROM Lead WHERE Id = :ld.Id];

        System.assert(lcr.isSuccess());

        Portal_Referral__c referral = [SELECT Id, Lead__c, Status__c, Detail__c,
                First_Name__c, Last_Name__c, Street__c, City__c, State__c, Zip__c, 
                Email__c, Account__c, Phone__c, Portal_Payment_Plan__c
            FROM Portal_Referral__c
            WHERE Opportunity__c = :ld2.ConvertedOpportunityId];
            
        //System.assertEquals(ld.Id, referral.Lead__c);
        System.assertEquals(ld.FirstName, referral.First_Name__c);
        System.assertEquals(ld.LastName, referral.Last_Name__c);
        System.assertEquals(ld.Street, referral.Street__c);
        System.assertEquals(ld.City, referral.City__c);
        System.assertEquals(ld.State, referral.State__c);
        System.assertEquals(ld.PostalCode, referral.Zip__c);
        System.assertEquals(ld.Phone, referral.Phone__c);
        System.assertEquals(ld.Email, referral.Email__c);
        System.assertEquals(a.Id, referral.Account__c);
        System.assertEquals(plan.Id, referral.Portal_Payment_Plan__c);
            
        System.assertEquals(PortalReferralStatus.QUALIFIED_STATUS, referral.Status__c);
        System.assertEquals('Evaluation in Progress', referral.Detail__c);      
        
    }
    
    public static Portal_Referral__c createPortalReferral() {
        
        Account a = new Account(Name = 'Test');
        insert a;
        
        Contact c = new Contact(
            AccountId = a.Id,
            LastName = 'Test'
        );
        insert c;

        Portal_Referral__c referral = new Portal_Referral__c (
            First_Name__c = 'Test',
            Last_Name__c = 'Referral',
            Account__c = a.Id,
            Referred_By__c = c.Id,
            City__c = 'Test City',
            Status__c = PortalReferralStatus.OPEN_STATUS,
            Detail__c = 'New'
        );
        insert referral;
        
        Lead ld = new Lead(
            FirstName = referral.First_Name__c,
            LastName = referral.Last_Name__c,
            Company = referral.Last_Name__c + ', ' + referral.First_Name__c,
            Referring_Account__c = a.Id,
            Method_of_Contact__c = 'Referral', 
            LeadSource = 'Partner Referral',
            Lead_Source_Detail__c = 'Professional',
            Street = '123 Ocean Dr',
            City= 'Wayne',
            State = 'PA',
            PostalCode = '12345',
            County__c = 'Chester',
            Site_Type__c = 'Residential'
            //Lead_Source_Detail_2__c = 'Channel',
            //Lead_Source_Detail_4__c = 'Astrum Solar Connect'
        );
        insert ld;
        
        referral.Lead__c = ld.Id;
        update referral;
        
        return referral;
        
    } 

}