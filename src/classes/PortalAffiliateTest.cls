/* FILE: PortalAffiliateTest.cls
 * AUTHOR: Rohit Jain
 * DATE: September 12, 2012
 * PURPOSE: Test class for PortalAffiliate Home page and PortalAffiliateHomeController
 * MODIFICATION HISTORY
 *
 */

@isTest 
public class PortalAffiliateTest {

    static testMethod void referrals_viewHome() {
        
        User u = PortalToolsTest.createAffiliatePortalUser();

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
            Portal_Referral_Fee__c = 25
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
            Sold_Referral_Fee__c = 1200
        );
        insert soldReferral;
        
        Portal_Referral_Payment__c payment = new Portal_Referral_Payment__c (
            Account__c = a.Id,
            Payment_Date__c = System.today(),
            Payment_Amount__c = 1200
        );
        insert payment;
        
        System.runAs(u) {
            
            Test.setCurrentPage(Page.PortalAffiliateHomePage);
            PortalAffiliateHomeController controller = new PortalAffiliateHomeController();
            
            
            System.assertEquals(2, controller.totalReferrals );
            System.assertEquals(1, controller.totalSold);   
            
        }
        
    }

}