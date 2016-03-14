/* FILE: PartnerLandingPageTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: January 14, 2013
 * PURPOSE: Test class for PartnerLandingPageController
 * MODIFICATION HISTORY:
 *    10/27/14  DK  Added a Utility_Company_master__c insertion in order to populate Utility Rate Code's State_Serviced__c formula field.
 * 06/09/2015 PB  - SFS 303 Changed Utility to derive from Utility_Company_Master__c rather than Utility_Company__c 
 */
 
@isTest
public class PartnerLandingPageTest {


    static testMethod void landingPage_submit_added() {
        
        //create portal account and set payment plan
        Portal_Payment_Plan__c plan = new Portal_Payment_Plan__c(
            Per_Referral_Fee__c = 25,
            Per_Referral_Maximum_Number__c = 40,
            Stop_Per_Referral_After_First_Sale__c = true
        );
        insert plan;

        Account partner = new Account (
            Name = 'Test Partner',
            Portal_Payment_Plan__c = plan.Id
        );
        insert partner;
        
        Partner_Page_Template__c template = new Partner_Page_Template__c (
            Name = 'Test Template', 
            VisualForce_Page__c = 'PartnerLandingTemplate1',
            Portal__c = 'Partner Portal Site',
            Active__c = true
        );
        insert template;
        
        Partner_Landing_Page__c landingPage = new Partner_Landing_Page__c (
            Partner_Account__c = partner.Id,
            Portal_Site__c = 'Partner Portal Site (partners.astrumsolar.com)',
            Partner_Display_Name__c = 'Test Partner Inc',
            Active__c = true,
            Site_Url__c = 'some-test-link-2x9483',
            Page_Template__c = template.Id
        );
        insert landingPage;
        
        Attachment logo = new Attachment(
            ParentId = landingPage.Id,
            Name = 'test.jpg',
            ContentType = 'image/jpg',
            Body = Blob.valueOf('image file'),
            Description = 'Logo'
        );
        insert logo;
        
        Utility_Company_Master__c utilMaster = new Utility_Company_Master__c(Name = 'Test Utility Company', State_Serviced__c = 'PA', Externally_Available__c = true);
        insert utilMaster;
        
        Utility_Company__c utility = new Utility_Company__c (
            Utility_Company_Master__c = utilMaster.ID,
            Name = 'Test Utility'
            //,State_Serviced__c = 'PA',
            //Externally_Available__c = true
        );
        insert utility;
        
        User siteGuest = [SELECT Id FROM User WHERE Name = 'Partner Portal Site Site Guest User'];
        
        Test.startTest();       
        
        System.runAs(siteGuest) {
            
            PageReference pr = Page.PartnerLandingPage;
            pr.getParameters().put('templateId', landingPage.Id);
            Test.setCurrentPage(pr);
            PartnerLandingPageController controller = new PartnerLandingPageController();
            
            System.assertEquals('Test Partner Inc', controller.partnerName);
            System.assertEquals(logo.Id, controller.partnerLogoId);
            
            List<SelectOption> states = controller.states;
            
            controller.newState = 'PA';
            controller.stateChanged();
            List<SelectOption> utilities = controller.getUtilities();
            System.assertEquals(2, utilities.size());
            
            Map<String,String> params = pr.getParameters();
            params.put('fname', 'Test');
            params.put('lname', 'Customer');
            params.put('email', 'test123@test.com');
            params.put('phone', '(215) 555-1212');
            params.put('street', '1 Oak St');
            params.put('city', 'Norristown');
            params.put('state', 'PA');
            params.put('zip', '19403');
            params.put('updates', 'yes');
            params.put('bill', '98.34');
            params.put('utility', utilities[1].getValue());
            
            controller.submit();

            System.assertEquals(false, ApexPages.hasMessages(), String.valueOf(ApexPages.getMessages()));
            
            System.assertEquals(true, controller.submitted);
            
        }
        
        Test.stopTest();
        
        Portal_Referral__c referral = 
            [SELECT Id, First_Name__c, Last_Name__c,
                Email__c, Phone__c, Street__c, City__c, State__c, Zip__c, Account__c, 
                Lead__r.Email_Marketing_Opt_In__c, Lead__r.Monthly_Electric_Bill__c,
                Lead__r.Utility_Company__c, Lead__r.Referring_Account__c, Lead__r.Utility_Company_Master__c
            FROM Portal_Referral__c];
            
        System.assertEquals('Test', referral.First_Name__c);
        System.assertEquals('Customer', referral.Last_Name__c);
        System.assertEquals('test123@test.com', referral.Email__c);
        System.assertEquals('1 Oak St', referral.Street__c);
        System.assertEquals('Norristown', referral.City__c);
        System.assertEquals('PA', referral.State__c);
        System.assertEquals('19403', referral.Zip__c);
        System.assertEquals(true, referral.Lead__r.Email_Marketing_Opt_In__c);
        System.assertEquals(98, referral.Lead__r.Monthly_Electric_Bill__c);
        //System.assertEquals(utility.Id, referral.Lead__r.Utility_Company__c);
        System.assertEquals(utilMaster.Id, referral.Lead__r.Utility_Company_Master__c);
        System.assertEquals(partner.Id, referral.Account__c);
        System.assertEquals(partner.Id, referral.Lead__r.Referring_Account__c);
        
    }
}