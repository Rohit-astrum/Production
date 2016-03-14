@isTest(SeeAllData=true)
public class PortalReferralImportTest {

    static testMethod void noPlanNoPortal_load_receiveError() {
        
        Account a = new Account ( Name = 'Test Partner' );
        insert a;
        
        ApexPages.StandardController controller = new ApexPages.StandardController(a);
        PortalReferralImportExtension extension = new PortalReferralImportExtension(controller);
        Test.setCurrentPage(Page.PortalReferralImport);
        
        Test.startTest();
        
        extension.checkValid();
        
        Test.stopTest();
        
        System.assertEquals(2, ApexPages.getMessages().size());
        
    }
    
    static testMethod void oneReferral3Leads_getLeads_2Leads() {

        Portal_Referral__c referral = LeadPortalReferralTriggerTest.createPortalReferral();
        
        referral = [SELECT Id, Account__c, Lead__c
            FROM Portal_Referral__c
            WHERE Id = :referral.Id];
            
        Account a = [SELECT Id FROM Account WHERE Id = :referral.Account__c];
            
        Lead lead1 = new Lead (
            LastName = 'One',
            FirstName = 'Lead',
            Company = 'One, Lead',
            Referring_Account__c = referral.Account__c 
        );
        insert lead1;

        Lead lead2 = new Lead (
            LastName = 'Two',
            FirstName = 'Lead',
            Company = 'Two, Lead',
            Referring_Account__c = referral.Account__c 
        );
        insert lead2;
                
        ApexPages.StandardController controller = new ApexPages.StandardController(a);
        PortalReferralImportExtension extension = new PortalReferralImportExtension(controller);
        Test.setCurrentPage(Page.PortalReferralImport);
        
        Test.startTest();
        
        List<Lead> leads = extension.getLeads();
        
        Test.stopTest();
        
        System.assertEquals(2, leads.size());
        
    }
    
    static testMethod void oneReferral2Opps_getOpps_1Opp() {

        Portal_Referral__c referral = LeadPortalReferralTriggerTest.createPortalReferral();
        
        referral = [SELECT Id, Account__c, Lead__c
            FROM Portal_Referral__c
            WHERE Id = :referral.Id];
            
        Account a = [SELECT Id FROM Account WHERE Id = :referral.Account__c];
            
        Lead lead1 = new Lead (
            LastName = 'One',
            FirstName = 'Lead',
            Company = 'One, Lead',
            Referring_Account__c = referral.Account__c, 
            Method_of_Contact__c = 'Referral', 
            LeadSource = 'Partner Referral',
            Lead_Source_Detail__c = 'Professional',
            Street = '123 Test St',
            City = 'Test City',
            State = 'PA',
            PostalCode = '19403',
            County__c = 'Chester',
            Site_Type__c = 'Residential'
            //Lead_Source_Detail_2__c = 'Channel',
            //Lead_Source_Detail_4__c = 'Astrum Solar Connect'
        );
        insert lead1;

        system.debug('**SZ: Before Lead Convert');

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(referral.Lead__c);
        lc.setConvertedStatus('Qualified');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        lc = new Database.LeadConvert();
        lc.setLeadId(lead1.Id);
        lc.setConvertedStatus('Qualified');
        lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        ApexPages.StandardController controller = new ApexPages.StandardController(a);
        PortalReferralImportExtension extension = new PortalReferralImportExtension(controller);
        Test.setCurrentPage(Page.PortalReferralImport);
        
        Test.startTest();
        
        List<Opportunity> opportunities = extension.getOpportunities();
        
        Test.stopTest();
        
        System.assertEquals(1, opportunities.size());

    }
    
    static testMethod void portalAccount2Leads2Opps_Import_ReferralsCreated() {
        
        User u = PortalToolsTest.createPortalUser();

        Account a = 
            [SELECT Id, Name, Portal_Payment_Plan__c 
            FROM Account
            WHERE Id IN (SELECT AccountId FROM Contact WHERE Id = :u.ContactId)];

        Lead[] leads = new Lead[] { 
            new Lead (
                FirstName = 'One',
                LastName = 'Lead',
                Company = 'Lead, One',
                Street = '1 Test St',
                City = 'One City',
                State = 'PA',
                PostalCode = '11111',
                County__c = 'Chester',
                Phone = '(111) 555-1212',
                Email = 'one@test.com',
                Referring_Account__c = a.Id, 
                Method_of_Contact__c = 'Referral', 
                  LeadSource = 'Partner Referral',
                Lead_Source_Detail__c = 'Professional',
                Site_Type__c = 'Residential'
            ),
            new Lead (
                FirstName = 'Two',
                LastName = 'Lead',
                Company = 'Lead, Two',
                Street = '2 Test St',
                City = 'Two City',
                State = 'MD',
                PostalCode = '22222',
                 County__c = 'Chester',
                Phone = '(222) 555-1212',
                Email = 'two@test.com',
                Referring_Account__c = a.Id, 
                Method_of_Contact__c = 'Referral', 
                  LeadSource = 'Partner Referral',
                Lead_Source_Detail__c = 'Professional',
                Site_Type__c = 'Residential'
            ),
            new Lead (
                FirstName = 'Three',
                LastName = 'Lead',
                Company = 'Lead, Three',
                Street = '3 Test St',
                City = 'Three City',
                State = 'NJ',
                PostalCode = '33333',
                 County__c = 'Chester',
                Phone = '(333) 555-1212',
                Email = 'three@test.com',
                Referring_Account__c = a.Id, 
                Method_of_Contact__c = 'Referral', 
                LeadSource = 'Partner Referral',
                Lead_Source_Detail__c = 'Professional',
                Site_Type__c = 'Residential'
                //Lead_Source_Detail_2__c = 'Channel',
                //Lead_Source_Detail_4__c = 'Astrum Solar Connect'
            ),
            new Lead (
                FirstName = 'Four',
                LastName = 'Lead',
                Company = 'Lead, Four',
                Street = '4 Test St',
                City = 'Four City',
                State = 'NY',
                 County__c = 'Chester',
                PostalCode = '44444',
                Phone = '(444) 555-1212',
                Email = 'four@test.com',
                Referring_Account__c = a.Id,
                Method_of_Contact__c = 'Referral', 
                LeadSource = 'Partner Referral',
                Lead_Source_Detail__c = 'Professional',
                Site_Type__c = 'Residential'
                //Lead_Source_Detail_2__c = 'Channel',
                //Lead_Source_Detail_4__c = 'Astrum Solar Connect'
            )
        };
        insert leads;
        
        Database.LeadConvertResult[] lcrs = new Database.LeadConvertResult[2]; 

        //convert two of the leads
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(leads[0].Id);
        lc.setConvertedStatus('Qualified');
        lcrs[0] = Database.convertLead(lc);
        System.assert(lcrs[0].isSuccess());

        lc = new Database.LeadConvert();
        lc.setLeadId(leads[1].Id);
        lc.setConvertedStatus('Qualified');
        lcrs[1] = Database.convertLead(lc);
        System.assert(lcrs[1].isSuccess());

        //set the portal payment plan       
        Portal_Payment_Plan__c plan = new Portal_Payment_Plan__c(
            Per_Referral_Fee__c = 25.00,
            Per_Sale_Fixed_Amount__c = 1200.00,
            Stop_Per_Referral_After_First_Sale__c = true
        );
        insert plan;
        
        a.Portal_Payment_Plan__c = plan.Id;
        update a;
        
        System.assertEquals(0, [SELECT count() FROM Portal_Referral__c WHERE Account__c = :a.Id]);
        
        ApexPages.StandardController controller = new ApexPages.StandardController(a);
        PortalReferralImportExtension extension = new PortalReferralImportExtension(controller);
        Test.setCurrentPage(Page.PortalReferralImport);
        
        Test.startTest();
        
        extension.doImport();
        
        Test.stopTest();
        
        System.assertEquals(false, ApexPages.hasMessages());
        
        List<Portal_Referral__c> referrals = 
            [SELECT Id, First_Name__c, Last_Name__c, Street__c, City__c, State__c, Zip__c, 
                Email__c, Account__c, Phone__c, Portal_Payment_Plan__c, Status__c, Detail__c,
                Lead__c, Opportunity__c, Referral_Earnings__c 
            FROM Portal_Referral__c
            WHERE Account__c = :a.Id
            ORDER BY Zip__c];
        
        System.assertEquals(4, referrals.size());
        
        for (Integer i = 0; i < 4; i++) {
            Lead l = leads[i];
            Portal_Referral__c referral = referrals[i];
            System.assertEquals(l.FirstName, referral.First_Name__c);
            System.assertEquals(l.LastName, referral.Last_Name__c);
            System.assertEquals(l.Street, referral.Street__c);
            System.assertEquals(l.City, referral.City__c);
            System.assertEquals(l.State, referral.State__c);
            System.assertEquals(l.PostalCode, referral.Zip__c);
            System.assertEquals(l.Phone, referral.Phone__c);
            System.assertEquals(l.Email, referral.Email__c);
            System.assertEquals(a.Id, referral.Account__c);
            System.assertEquals(plan.Id, referral.Portal_Payment_Plan__c);
            System.assertEquals(plan.Per_Referral_Fee__c, referral.Referral_Earnings__c);

            if (i < 2) {        
                System.assertEquals(PortalReferralStatus.QUALIFIED_STATUS, referral.Status__c);
                System.assertEquals('Evaluation in Progress', referral.Detail__c);
                System.assertEquals(null, referral.Lead__c);
                System.assertEquals(lcrs[i].getOpportunityId(), referral.Opportunity__c);
            } else {
                System.assertEquals(PortalReferralStatus.OPEN_STATUS, referral.Status__c);
                System.assertEquals('New', referral.Detail__c);     
                System.assertEquals(l.Id, referral.Lead__c);
                System.assertEquals(null, referral.Opportunity__c);
            }       
        }
        
    }
    
    @isTest static void nullObjectTests(){

        Portal_Referral__c referral = LeadPortalReferralTriggerTest.createPortalReferral();
        referral = [SELECT Id, Account__c, Lead__c
            FROM Portal_Referral__c
            WHERE Id = :referral.Id];

        system.assertEquals(false, PortalReferralStatus.setReferralStatus(null, null, null, null));        
        system.assertEquals(false, PortalReferralStatus.setReferralStatus(null, null, null, referral));
    }

    @isTest static void processSoldEarningsTest(){

        List<Portal_Referral__c> referrals = new List<Portal_Referral__c>();
        Portal_Referral__c referral = LeadPortalReferralTriggerTest.createPortalReferral();
        referral = [SELECT Id, Account__c, Lead__c, Portal_Payment_Plan__c, Sold_Referral_Fee__c
            FROM Portal_Referral__c
            WHERE Id = :referral.Id];

        referrals.add(referral);
        PortalReferralStatus.processSoldEarnings(referrals);
    }

    @isTest static void leadStatusTests(){

        Portal_Referral__c referral = LeadPortalReferralTriggerTest.createPortalReferral();

        Account a = [SELECT Id FROM Account WHERE Id = :referral.Account__c];
            
        Lead lead1 = new Lead (
            LastName = 'One',
            FirstName = 'Lead',
            Company = 'One, Lead',
            Referring_Account__c = referral.Account__c, 
            Method_of_Contact__c = 'Referral', 
            LeadSource = 'Partner Referral',
            Lead_Source_Detail__c = 'Professional',
            Street = '123 Test St',
            City = 'Test City',
            State = 'PA',
            PostalCode = '19403',
            County__c = 'Chester',
            Site_Type__c = 'Residential',
            Status = 'Contacted by Us'
        );
        insert lead1;
        Test.startTest();
        system.assertEquals(true, PortalReferralStatus.setReferralStatus(lead1, null, null, referral));

        lead1.Status = 'Contacted Us Back';
        update lead1;
        system.assertEquals(true, PortalReferralStatus.setReferralStatus(lead1, null, null, referral));

        lead1.Status = 'On Hold';
        lead1.On_Hold_Until__c = Date.today().addDays(5);
        update lead1;
        system.assertEquals(true, PortalReferralStatus.setReferralStatus(lead1, null, null, referral));

        lead1.Status = 'Unresponsive';
        update lead1;
        system.assertEquals(true, PortalReferralStatus.setReferralStatus(lead1, null, null, referral));

        lead1.Status = 'Unqualified';
        lead1.Unqualified_Reason__c = 'Site Quality';
        update lead1;
        system.assertEquals(true, PortalReferralStatus.setReferralStatus(lead1, null, null, referral));

        /*lead1.Unqualified_Reason__c = 'Site Quality';
        update lead1;
        system.assertEquals(true, PortalReferralStatus.setReferralStatus(lead1, null, null, referral));
        */

        lead1.Unqualified_Reason__c = 'Cost/Financial';
        update lead1;
        system.assertEquals(true, PortalReferralStatus.setReferralStatus(lead1, null, null, referral));

        lead1.Status = 'Lost – Competition';
        lead1.Reason_for_Loss__c = 'Testing';
        update lead1;
        system.assertEquals(true, PortalReferralStatus.setReferralStatus(lead1, null, null, referral));

        lead1.Status = 'Did Not Want Contact';
        update lead1;
        system.assertEquals(true, PortalReferralStatus.setReferralStatus(lead1, null, null, referral));

        lead1.Status = 'Bad Contact Information';
        update lead1;
        system.assertEquals(true, PortalReferralStatus.setReferralStatus(lead1, null, null, referral));

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(lead1.Id);
        lc.setConvertedStatus('Qualified');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        Test.stopTest();
        lead1 = [SELECT Id, Status FROM Lead WHERE Id = :lead1.Id];
        system.assertEquals(true, PortalReferralStatus.setReferralStatus(lead1, null, null, referral));
    }

    @isTest static void oppStatusTests(){

        Portal_Referral__c referral = LeadPortalReferralTriggerTest.createPortalReferral();

        Account a = [SELECT Id FROM Account WHERE Id = :referral.Account__c];
            
        Lead lead1 = new Lead (
            LastName = 'One',
            FirstName = 'Lead',
            Company = 'One, Lead',
            Referring_Account__c = referral.Account__c, 
            Method_of_Contact__c = 'Referral', 
            LeadSource = 'Partner Referral',
            Lead_Source_Detail__c = 'Professional',
            Street = '123 Test St',
            City = 'Test City',
            State = 'PA',
            PostalCode = '19403',
            County__c = 'Chester',
            Site_Type__c = 'Residential',
            Status = 'Contacted by Us'
        );
        insert lead1;

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(lead1.Id);
        lc.setConvertedStatus('Qualified');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        ApexPages.StandardController controller = new ApexPages.StandardController(a);
        PortalReferralImportExtension extension = new PortalReferralImportExtension(controller);
        Test.setCurrentPage(Page.PortalReferralImport);
        
        Test.startTest();
        
        List<Opportunity> opportunities = extension.getOpportunities();
        Opportunity opportunity = opportunities[0];

        opportunity.StageName = 'On Hold';
        opportunity.On_Hold_Until__c = Date.today().addDays(5);
        TriggerUtility.skipDlrsTriggers = true;
        update opportunity;
        system.assertEquals(true, PortalReferralStatus.setReferralStatus(null, opportunity, null, referral));

        opportunity.StageName = 'Unresponsive';
        update opportunity;
        system.assertEquals(true, PortalReferralStatus.setReferralStatus(null, opportunity, null, referral));

        opportunity.StageName = 'Sales Process Ongoing';
        opportunity.Date_Site_Survey_Completed__c = Date.today().addDays(-3);
        update opportunity;
        system.assertEquals(true, PortalReferralStatus.setReferralStatus(null, opportunity, null, referral));

        opportunity.Date_Site_Survey_Completed__c = Date.today().addDays(-100);
        update opportunity;
        system.assertEquals(true, PortalReferralStatus.setReferralStatus(null, opportunity, null, referral));

        opportunity.StageName = 'Contract Cancelled';
        update opportunity;
        system.assertEquals(true, PortalReferralStatus.setReferralStatus(null, opportunity, null, referral));

        opportunity.StageName = 'Closed - Lost';
        update opportunity;
        system.assertEquals(true, PortalReferralStatus.setReferralStatus(null, opportunity, null, referral));

        opportunity.Closed_Reason__c = 'Site Quality';
        update opportunity;
        system.assertEquals(true, PortalReferralStatus.setReferralStatus(null, opportunity, null, referral));

        opportunity.Closed_Reason__c = 'Cannot Afford/Borrow';
        update opportunity;
        system.assertEquals(true, PortalReferralStatus.setReferralStatus(null, opportunity, null, referral));

        opportunity.Closed_Reason__c = 'Spouse Veto';
        update opportunity;
        system.assertEquals(true, PortalReferralStatus.setReferralStatus(null, opportunity, null, referral));

        Test.stopTest();
    }
}