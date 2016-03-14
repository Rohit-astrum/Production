/* FILE: EP_MyDashboardTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: January 2, 2013
 * PURPOSE: Tests for EP_MyDashboard page, EP_MyDashboardController
 * MODIFICATION HISTORY
 * 
 */

@isTest
public class EP_MyDashboardTest {

	static testMethod void referrals_viewDashboard_visible() {
		
		User u = EP_SubmitLeadsTest.createPortalUser();

		Account a = [SELECT Id, Name FROM Account];
		
		Contact c = new Contact (
			LastName = 'Partner2',
			AccountId = a.Id
		);
		insert c;

    	Portal_Referral__c newReferral = new Portal_Referral__c (
    		Lead_Created_Date__c = Date.newInstance(2013,1,15),
    		Status__c = PortalReferralStatus.OPEN_STATUS,
    		Detail__c = 'New',
    		Account__c = a.Id,
    		First_Name__c = 'New',
    		Last_Name__c = 'Referral',
    		City__c = 'Somewhere',
    		State__c = 'PA',
    		Referred_By__c = c.Id
    	);
    	insert newReferral;
		 
    	Portal_Referral__c soldReferral = new Portal_Referral__c (
    		Lead_Created_Date__c = Date.newInstance(2013,1,12),
    		Status__c = PortalReferralStatus.SOLD_STATUS,
    		Detail__c = '9/11/2012',
    		Account__c = a.Id,
    		First_Name__c = 'Sold',
    		Last_Name__c = 'Referral',
    		City__c = 'Somewhere',
    		State__c = 'PA',
    		Referred_By__c = c.Id
    	);
    	insert soldReferral;
    	
    	System.runAs(u) {
    		
    		Test.setCurrentPage(Page.EP_MyDashboard);
    		EP_MyDashboardController controller = new EP_MyDashboardController();
    		
    		System.assertEquals(2, controller.totalReferrals);
    		System.assertEquals(1, controller.totalOpen);
    		System.assertEquals(1, controller.totalSold);
    		
    		System.assertEquals('DESC', controller.sortDirection);
    		System.assertEquals('Lead_Created_Date__c', controller.sortExpression);
    		
    		List<Portal_Referral__c> referrals = controller.referrals;
    		System.assertEquals(2, referrals.size());
    		System.assertEquals(newReferral.Id, referrals[0].Id);
    		System.assertEquals(soldReferral.Id, referrals[1].Id);
    		
			//change sort direction
    		controller.sortExpression = 'Lead_Created_Date__c';
    		controller.refresh();
    		
    		referrals = controller.referrals;
    		System.assertEquals(soldReferral.Id, referrals[0].Id);
    		System.assertEquals(newReferral.Id, referrals[1].Id);
    		
    	}
    	
	}


}