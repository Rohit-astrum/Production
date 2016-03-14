/* FILE: PortalNewReferralTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: August 3, 2012
 * PURPOSE: Test class for PortalNewReferral page and PortalNewReferralExtension
 * MODIFICATION HISTORY
 *
 */
 
@isTest
public class PortalNewReferralTest {

    static testMethod void emptyForm_submit_Errors () {
        
        Test.setCurrentPage(Page.PortalNewReferral);
        Portal_Referral__c referral = new Portal_Referral__c();
        ApexPages.StandardController controller = new ApexPages.StandardController(referral);
        PortalNewReferralExtension extension = new PortalNewReferralExtension(controller);
        
        System.runAs(PortalToolsTest.createPortalUser()) {
            
            Test.startTest();
            
            System.assertEquals(null, extension.submit());
            
            Test.stopTest();
            
            System.assert(extension.errorFields.contains('[1]'));
            System.assert(extension.errorFields.contains('[fname]'));
            System.assert(extension.errorFields.contains('[lname]'));
            System.assert(extension.errorFields.contains('[street]'));
            System.assert(extension.errorFields.contains('[city]'));
            System.assert(extension.errorFields.contains('[state]'));
            System.assert(extension.errorFields.contains('[zip]'));
            System.assert(extension.errorFields.contains('[phone]'));
            System.assert(extension.errorFields.contains('[email]'));
            
        }
        
    }
    
    static testMethod void badEmail_submit_Errors () {
        
        Test.setCurrentPage(Page.PortalNewReferral);
        Portal_Referral__c referral = new Portal_Referral__c();
        ApexPages.StandardController controller = new ApexPages.StandardController(referral);
        PortalNewReferralExtension extension = new PortalNewReferralExtension(controller);
        
        System.runAs(PortalToolsTest.createPortalUser()) {
            
            Test.startTest();
            
            referral.First_Name__c = 'Test';
            referral.Last_Name__c = 'Referral';
            referral.Street__c = '99 Oakmark Ave';
            referral.City__c = 'Yardley';
            referral.State__c = 'PA';
            referral.Zip__c = '19394';
            referral.Phone__c = '215-555-1212';
            referral.Email__c = 'test_test.com';
            
            System.assertEquals(null, extension.submit());
            
            Test.stopTest();
            
            System.assert(extension.errorFields.contains('[1]'));
            System.assert(extension.errorFields.contains('[email]'));
            
        }
        
    }
    
    static testMethod void completeForm_submit_ReferralCreated() {
        
        User u = PortalToolsTest.createPortalUser();
        
        Portal_Payment_Plan__c plan = new Portal_Payment_Plan__c(
            Per_Referral_Fee__c = 30
        );
        insert plan;
        
        Account a = [SELECT Id, Portal_Payment_Plan__c FROM Account];
        a.Portal_Payment_Plan__c = plan.Id;
        update a;
        
        System.runAs(u) {

            Test.setCurrentPage(Page.PortalNewReferral);
            Portal_Referral__c referral = new Portal_Referral__c();
            ApexPages.StandardController controller = new ApexPages.StandardController(referral);
            PortalNewReferralExtension extension = new PortalNewReferralExtension(controller);

            List<SelectOption> states = extension.states;
            
            referral.First_Name__c = 'Test';
            referral.Last_Name__c = 'Referral';
            referral.Street__c = '99 Oakmark Ave';
            referral.City__c = 'Yardley';
            referral.State__c = 'PA';
            referral.Zip__c = '19394';
            referral.Phone__c = '215-555-1212';
            referral.Email__c = 'test@test.com';
            referral.Notes__c = 'test notes';
            
            Test.startTest();
            
            PageReference result = extension.submit();
            
            Test.stopTest();
            
            System.assert(result.getUrl().startsWith(Page.PortalNewReferral.getUrl()));

        }
        
        Portal_Referral__c referral = 
            [SELECT Id, Lead__c, Status__c, Detail__c, First_Name__c,
                    Last_Name__c, Street__c, City__c, State__c, Zip__c, Phone__c, Email__c,
                    Portal_Payment_Plan__c, Referral_Earnings__c, Portal_Referral_Fee__c 
            FROM Portal_Referral__c];
            
        System.assertEquals(PortalReferralStatus.OPEN_STATUS, referral.Status__c);
        System.assertEquals('New', referral.Detail__c);
        System.assertEquals('Test', referral.First_Name__c);
        System.assertEquals('Referral', referral.Last_Name__c);
        System.assertEquals('99 Oakmark Ave', referral.Street__c);
        System.assertEquals('Yardley', referral.City__c);
        System.assertEquals('PA', referral.State__c);
        System.assertEquals('19394', referral.Zip__c);
        System.assertEquals('215-555-1212', referral.Phone__c);
        System.assertEquals('test@test.com', referral.Email__c);
        
        System.assertEquals(plan.Id, referral.Portal_Payment_Plan__c);
        System.assertEquals(30, referral.Referral_Earnings__c);
        System.assertEquals(30, referral.Portal_Referral_Fee__c);
        
        Lead l = [SELECT Id, OwnerId, FirstName, LastName, Company, Phone,
            Email, Street, City, State, PostalCode, Lead_Date__c, 
            Method_of_Contact__c, Lead_Source_Notes__c, LeadSource,
            Lead_Source_Detail__c, Referring_Account__c
            FROM Lead];     

        Group g = [SELECT Id, DeveloperName FROM Group WHERE Id = :l.OwnerId];
    
        System.assertEquals('WebLeadQueue' , g.DeveloperName);
        System.assertEquals('Test', l.FirstName);
        System.assertEquals('Referral', l.LastName);
        System.assertEquals('Referral, Test', l.Company);
        System.assertEquals('99 Oakmark Ave', l.Street);
        System.assertEquals('Yardley', l.City);
        System.assertEquals('PA', l.State);
        System.assertEquals('19394', l.PostalCode);
        System.assertEquals(Date.today(), l.Lead_Date__c);
        System.assertEquals('Partner Portal', l.Method_of_Contact__c);
        System.assertEquals('test notes', l.Lead_Source_Notes__c);
        System.assertEquals('Partner Referral', l.LeadSource);
        System.assertEquals('Professional', l.Lead_Source_Detail__c);
        //System.assertEquals('Channel', l.Lead_Source_Detail_2__c);
        //System.assertEquals('Astrum Solar Connect', l.Lead_Source_Detail_4__c);
        System.assertEquals('215-555-1212', l.Phone);
        System.assertEquals('test@test.com', l.Email);  
    }

    static testMethod void duplicateLead_submit_duplicateError() {
        
        Lead l = new Lead (
            LastName = 'Test',
            Company = 'Test',
            Street = '99 Oakmark Ave',
            City = 'Yardley',
            State = 'PA'
        );
        insert l;

        System.runAs(PortalToolsTest.createPortalUser()) {

            Test.setCurrentPage(Page.PortalNewReferral);
            Portal_Referral__c referral = new Portal_Referral__c();
            ApexPages.StandardController controller = new ApexPages.StandardController(referral);
            PortalNewReferralExtension extension = new PortalNewReferralExtension(controller);

            List<SelectOption> states = extension.states;
            
            referral.First_Name__c = 'Test';
            referral.Last_Name__c = 'Referral';
            referral.Street__c = '99 Oakmark Ave';
            referral.City__c = 'Yardley';
            referral.State__c = 'PA';
            referral.Zip__c = '19394';
            referral.Phone__c = '215-555-1212';
            referral.Email__c = 'test@test.com';
            
            Test.startTest();
            
            System.assertEquals(null, extension.submit());
            System.assertEquals(true, extension.duplicate);

            PageReference result = extension.submitAnother();       
            System.assert(result.getUrl().startsWith(Page.PortalNewReferral.getUrl()));
            
            Test.stopTest();

        }
        
        Portal_Referral__c referral = 
            [SELECT Id, Lead__c, Status__c, First_Name__c,
                    Last_Name__c, Street__c, City__c, State__c, Zip__c, Phone__c, Email__c
            FROM Portal_Referral__c];
            
        System.assertEquals(null, referral.Lead__c);
        System.assertEquals(PortalReferralStatus.DUPLICATE_STATUS, referral.Status__c);
        System.assertEquals('Test', referral.First_Name__c);
        System.assertEquals('Referral', referral.Last_Name__c);
        System.assertEquals('99 Oakmark Ave', referral.Street__c);
        System.assertEquals('Yardley', referral.City__c);
        System.assertEquals('PA', referral.State__c);
        System.assertEquals('19394', referral.Zip__c);
        System.assertEquals('215-555-1212', referral.Phone__c);
        System.assertEquals('test@test.com', referral.Email__c);
        
    }
    
    static testMethod void soldReferral_submitNew_NoReferralFee() {
        
        User u = PortalToolsTest.createPortalUser();
        
        Portal_Payment_Plan__c plan = new Portal_Payment_Plan__c(
            Per_Referral_Fee__c = 30,
            Stop_Per_Referral_After_First_Sale__c = true
        );
        insert plan;
        
        Account a = [SELECT Id, Portal_Payment_Plan__c FROM Account];
        a.Portal_Payment_Plan__c = plan.Id;
        update a;
        
        Contact c = [SELECT Id FROM Contact];
        
        Portal_Referral__c soldReferral = new Portal_Referral__c (
            Status__c = PortalReferralStatus.SOLD_STATUS,
            Account__c = a.Id,
            First_Name__c = 'Sold',
            Last_Name__c = 'Referral',
            City__c = 'Somewhere',
            State__c = 'PA',
            Portal_Payment_Plan__c = plan.Id,
            Referred_By__c = c.Id
        );
        insert soldReferral;
        
        System.runAs(u) {

            Test.setCurrentPage(Page.PortalNewReferral);
            Portal_Referral__c referral = new Portal_Referral__c();
            ApexPages.StandardController controller = new ApexPages.StandardController(referral);
            PortalNewReferralExtension extension = new PortalNewReferralExtension(controller);

            referral.First_Name__c = 'Test';
            referral.Last_Name__c = 'Referral';
            referral.Street__c = '99 Oakmark Ave';
            referral.City__c = 'Yardley';
            referral.State__c = 'PA';
            referral.Zip__c = '19394';
            referral.Phone__c = '215-555-1212';
            referral.Email__c = 'test@test.com';
            
            Test.startTest();
            
            extension.submit();
            
            Test.stopTest();
            
        }
        
        Portal_Referral__c referral = 
            [SELECT Id, Portal_Referral_Fee__c FROM Portal_Referral__c
            WHERE Id <> :soldReferral.Id];
            
        System.assertEquals(null, referral.Portal_Referral_Fee__c);    

    }

    static testMethod void maxSubmitted_submitNew_NoReferralFee() {
        
        User u = PortalToolsTest.createPortalUser();
        
        Portal_Payment_Plan__c plan = new Portal_Payment_Plan__c(
            Per_Referral_Fee__c = 30,
            Per_Referral_Maximum_Number__c = 1
        );
        insert plan;
        
        Account a = [SELECT Id, Portal_Payment_Plan__c FROM Account];
        a.Portal_Payment_Plan__c = plan.Id;
        update a;
        
        Contact c = [SELECT Id FROM Contact];
        
        Portal_Referral__c soldReferral = new Portal_Referral__c (
            Status__c = PortalReferralStatus.OPEN_STATUS,
            Account__c = a.Id,
            First_Name__c = 'Previous',
            Last_Name__c = 'Referral',
            City__c = 'Somewhere',
            State__c = 'PA',
            Portal_Payment_Plan__c = plan.Id,
            Referred_By__c = c.Id
        );
        insert soldReferral;
        
        System.runAs(u) {

            Test.setCurrentPage(Page.PortalNewReferral);
            Portal_Referral__c referral = new Portal_Referral__c();
            ApexPages.StandardController controller = new ApexPages.StandardController(referral);
            PortalNewReferralExtension extension = new PortalNewReferralExtension(controller);

            referral.First_Name__c = 'Test';
            referral.Last_Name__c = 'Referral';
            referral.Street__c = '99 Oakmark Ave';
            referral.City__c = 'Yardley';
            referral.State__c = 'PA';
            referral.Zip__c = '19394';
            referral.Phone__c = '215-555-1212';
            referral.Email__c = 'test@test.com';
            
            Test.startTest();
            
            extension.submit();
            
            Test.stopTest();
            
        }
        
        Portal_Referral__c referral = 
            [SELECT Id, Portal_Referral_Fee__c FROM Portal_Referral__c
            WHERE Id <> :soldReferral.Id];
            
        System.assertEquals(null, referral.Portal_Referral_Fee__c);    

    }
    
    static testMethod void mobileForm_submit_ReferralCreated() {
        
        User u = PortalToolsTest.createPortalUser();
        
        Portal_Payment_Plan__c plan = new Portal_Payment_Plan__c(
            Per_Referral_Fee__c = 25,
            Per_Referral_Maximum_Number__c = 40
        );
        insert plan;
        
        Account a = [SELECT Id, Portal_Payment_Plan__c FROM Account];
        a.Portal_Payment_Plan__c = plan.Id;
        update a;
        
        System.runAs(u) {

            Test.setCurrentPage(Page.PortalMobileNewReferral);
            Portal_Referral__c referral = new Portal_Referral__c();
            ApexPages.StandardController controller = new ApexPages.StandardController(referral);
            PortalNewReferralExtension extension = new PortalNewReferralExtension(controller);

            List<SelectOption> states = extension.states;
            
            referral.First_Name__c = 'Test';
            referral.Last_Name__c = 'Referral';
            referral.Street__c = '99 Oakmark Ave';
            referral.City__c = 'Yardley';
            referral.State__c = 'PA';
            referral.Zip__c = '19394';
            referral.Phone__c = '215-555-1212';
            referral.Email__c = 'test@test.com';
            referral.Notes__c = 'test notes';
            
            Test.startTest();
            
            PageReference result = extension.submit();
            
            Test.stopTest();
            
            System.assert(result.getUrl().startsWith(Page.PortalMobileNewReferral.getUrl()));

        }
        
        Portal_Referral__c referral = [SELECT Id, Portal_Referral_Fee__c FROM Portal_Referral__c];
            
        System.assertEquals(25, referral.Portal_Referral_Fee__c);
        
    }
    
    
}