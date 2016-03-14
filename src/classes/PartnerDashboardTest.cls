/* FILE: PartnerDashboardTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: September 12, 2012
 * PURPOSE: Test class for PartnerDashboard page and PartnerDashboardController
 * MODIFICATION HISTORY
 *
 */

@isTest 
public class PartnerDashboardTest {

    @isTest static void test_SetupData() {
        
        User u = PortalToolsTest.createPortalUser();

        System.runAs(u) {
            Test.setCurrentPage(Page.PartnerDashboard);
            PartnerDashboardController controller = new PartnerDashboardController();

            system.assertEquals(11, controller.filterOptions.size());
        }
    }

    static testMethod void referrals_viewDashboard_visible() {
        
        User u = PortalToolsTest.createPortalUser();

        Account a = [SELECT Id, Name FROM Account];
        
        Contact c = new Contact (
            LastName = 'Partner2',
            AccountId = a.Id
        );
        insert c;

        Portal_Referral__c newReferral = new Portal_Referral__c (
            Status__c = PortalReferralStatus.OPEN_STATUS,
            Detail__c = 'New',
            Account__c = a.Id,
            First_Name__c = 'New',
            Last_Name__c = 'Referral',
            City__c = 'Somewhere',
            State__c = 'PA',
            Referred_By__c = c.Id,
            Portal_Referral_Fee__c = 25,
            Lead_Created_Date__c = Date.today().addDays(-1)
        );
        insert newReferral;
         
        Portal_Referral__c soldReferral = new Portal_Referral__c (
            Status__c = PortalReferralStatus.SOLD_STATUS,
            Detail__c = '9/11/2012',
            Account__c = a.Id,
            First_Name__c = 'Sold',
            Last_Name__c = 'Referral',
            City__c = 'Somewhere',
            State__c = 'PA',
            Referred_By__c = c.Id,
            Sold_Referral_Fee__c = 1200,
            Lead_Created_Date__c = Date.today().addDays(-3)
        );
        insert soldReferral;
        
        Portal_Referral_Payment__c payment = new Portal_Referral_Payment__c (
            Account__c = a.Id,
            Payment_Date__c = System.today(),
            Payment_Amount__c = 1200
        );
        insert payment;
        
        System.runAs(u) {
            
            Test.setCurrentPage(Page.PartnerDashboard);
            PartnerDashboardController controller = new PartnerDashboardController();
            
            System.assertEquals(1, controller.totalOpen);
            System.assertEquals(0, controller.totalQualified);
            System.assertEquals(1, controller.totalSold);
            System.assertEquals(1225, controller.earnings);

            System.assertEquals('Lead_Created_Date__c', controller.sortExpression);
            System.assertEquals('DESC', controller.sortDirection);
            //System.assertEquals('Status__c', controller.sortExpression);
            
            List<Portal_Referral__c> referrals = controller.referrals;
            System.assertEquals(2, referrals.size());
            System.assertEquals(newReferral.Id, referrals[0].Id);
            System.assertEquals(soldReferral.Id, referrals[1].Id);

            List<PartnerDashboardController.PortalPayment> payments = controller.payments; 
            System.assertEquals(1, payments.size());
            
            //change sort direction
            controller.sortExpression = 'Lead_Created_Date__c';
            controller.refresh();
            referrals = controller.referrals;
            System.assertEquals(newReferral.Id, referrals[1].Id);
            System.assertEquals(soldReferral.Id, referrals[0].Id);

            controller.filterOption = 'YESTERDAY';
            controller.refresh();
            referrals = controller.referrals;
            System.assertEquals(1, referrals.size());
        }
    }
    
    static testMethod void Strategic_viewDashboard_visible() {
        
        User u = PortalToolsTest.createStrategicPortalUser();

        Account a = [SELECT Id, Name, Partner_Type__c FROM Account];

        Community_Program_Offer__c cpo = new Community_Program_Offer__c();
        cpo.Account__c = a.id;
        cpo.Baseline_Site_Quality__c = 2000;
        cpo.Current_Tier__c = '1';
        cpo.Early_Adopter_Promotion__c = 100;
        cpo.Early_Adopter_Promotion_Available__c = true;
        cpo.Start_Date__c = Date.today().toStartOfMonth();
        cpo.Extension_End_Date__c = Date.today().addMonths(1).addDays(15);
        cpo.Initial_End_Date__c = Date.today().addMonths(1);
        cpo.Eligibility_Criterion__c = 'ZIP';
        cpo.Eligible_Values__c = '20701';
        insert cpo;

        a.Partner_Type__c = 'Strategic';
        a.Community_Program_Offer__c = cpo.Id;
        update a;

        Contact c = new Contact (
            LastName = 'Partner2',
            AccountId = a.Id
        );
        insert c;


        Portal_Referral__c newReferral = new Portal_Referral__c (
            Status__c = PortalReferralStatus.OPEN_STATUS,
            Detail__c = 'New',
            Account__c = a.Id,
            First_Name__c = 'New',
            Last_Name__c = 'Referral',
            City__c = 'Somewhere',
            State__c = 'PA',
            Referred_By__c = c.Id,
            Portal_Referral_Fee__c = 25,
            Community_Program__c = 'Solarize Bridgeport',
            Community_Program_Offer__c = cpo.Id,
            Lead_Created_Date__c = Date.today().addDays(-1)
        );
        insert newReferral;
         
        Portal_Referral__c soldReferral = new Portal_Referral__c (
            Status__c = PortalReferralStatus.SOLD_STATUS,
            Detail__c = '9/11/2012',
            Account__c = a.Id,
            First_Name__c = 'Sold',
            Last_Name__c = 'Referral',
            City__c = 'Somewhere',
            State__c = 'PA',
            Referred_By__c = c.Id,
            Sold_Referral_Fee__c = 1200,
            Community_Program__c = 'Solarize Bridgeport',
            Community_Program_Offer__c = cpo.Id,
            Lead_Created_Date__c = Date.today().addDays(-3)
        );
        insert soldReferral;
        
        Portal_Referral_Payment__c payment = new Portal_Referral_Payment__c (
            Account__c = a.Id,
            Payment_Date__c = System.today(),
            Payment_Amount__c = 1200
        );
        insert payment;
        
        System.runAs(u) {
            
            Test.setCurrentPage(Page.PartnerDashboard);
            PartnerDashboardController controller = new PartnerDashboardController();
            
            System.assertEquals(1, controller.totalOpen);
            System.assertEquals(0, controller.totalQualified);
            System.assertEquals(1, controller.totalSold);
            //System.assertEquals(1225, controller.earnings);            
            
            //System.assertEquals('Status__c', controller.sortExpression);
            
            List<Portal_Referral__c> referrals = controller.referrals;
            System.assertEquals(2, referrals.size());
            System.assertEquals(newReferral.Id, referrals[0].Id);
            System.assertEquals(soldReferral.Id, referrals[1].Id);
            
            List<PartnerDashboardController.PortalPayment> payments = controller.payments; 
            System.assertEquals(1, payments.size());
            
            //change sort direction
            controller.sortExpression = 'Status__c';
            controller.refresh();
            
            referrals = controller.referrals;
            //System.assertEquals(soldReferral.Id, referrals[0].Id);
            //System.assertEquals(newReferral.Id, referrals[1].Id);
            
        }
        
    }


}