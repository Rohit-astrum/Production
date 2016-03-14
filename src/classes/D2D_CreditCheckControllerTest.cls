@isTest
private class D2D_CreditCheckControllerTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out

	@testSetup static void setupData() {
		testData.setupCustomSettings();
		D2DTestUtility.InitializeRequiredMethods();
		D2DTestUtility.CreateCustomSettings(false, true, 'http://www.salesforce.com', '', '', '', '', '', '', '', 'sales.coordinator@email.com');
		D2DTestUtility.CreateSalesCoordinatorUser();
		
		D2DTestUtility.CreateManagerUsers(1);
		User d2dMg = D2DTestUtility.d2dManagerUsers[0];

		D2DTestUtility.CreateSalesRepUsers(1);
		User d2dSr = D2DTestUtility.d2dSalesRepUsers[0];

		D2DTestUtility.CreatePortalReferralRequiredObjects(1, 'NY', '24 Panel');
		D2DTestUtility.CreatePortalReferralsWithLeads(1, d2dMg.Id, d2dSr.Id, 'SOLD', 'Sold', '36 Panel', '3', 'ref', 'Joe', '10101 Boolean Way', 'Stony Point', 'NY', '10980', 'Rockland', false);
		D2DTestUtility.CreatePortalReferralsWithLeads(1, d2dMg.Id, d2dSr.Id, 'SOLD', 'Sold', '36 Panel', '3', 'ref', 'Joe', '1010 Tenth St', 'Stony Point', 'NY', '10980', 'Rockland', false);
		D2DTestUtility.CreateOpportunityWithProposalAndContract(true, false, true, false);
	}
	
	@isTest static void test_Exceptions() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id, Opportunity__c FROM Portal_Referral__c WHERE Opportunity__c != null LIMIT 1];

		PageReference pageRef = Page.D2D_CreditCheck;
		pageRef.getParameters().put('id', referral.Id);
		pageRef.getParameters().put('creditApprovedRadioBtn', 'Yes');
		Test.setCurrentPage(pageRef);

		Test.startTest();

		Integer pageMessageCount = 0;
		D2D_CreditCheckController controller = new D2D_CreditCheckController();

		delete referral;
		controller.submit();
		system.assertNotEquals(pageMessageCount, ApexPages.getMessages().size());

		Test.stopTest();
	}
	
	@isTest static void test_CreditCheck_Selected() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id, Opportunity__c FROM Portal_Referral__c WHERE Opportunity__c != null LIMIT 1];

		PageReference pageRef = Page.D2D_CreditCheck;
		pageRef.getParameters().put('id', referral.Id);
		pageRef.getParameters().put('creditApprovedRadioBtn', 'Yes');
		Test.setCurrentPage(pageRef);

		Test.startTest();

		Integer pageMessageCount = 0;
		D2D_CreditCheckController controller = new D2D_CreditCheckController();

		system.assertEquals('http://www.salesforce.com', controller.creditCheckUrl);
		system.assertEquals(D2D_Utility.GetPicklistOptions(Portal_Referral__c.Credit_Approved__c.getDescribe(), true, '-- Select --').size(), controller.creditApproved.size());

		controller.submit();
		system.assertEquals(pageMessageCount, ApexPages.getMessages().size());

		pageRef.getParameters().put('creditApprovedRadioBtn', 'No');
		
		pageMessageCount = ApexPages.getMessages().size();
		controller = new D2D_CreditCheckController();
		controller.submit();
		system.assertEquals(pageMessageCount, ApexPages.getMessages().size());

		pageRef.getParameters().put('creditApprovedRadioBtn', 'Pending');
		
		pageMessageCount = ApexPages.getMessages().size();
		controller = new D2D_CreditCheckController();
		controller.submit();
		system.assertEquals(pageMessageCount, ApexPages.getMessages().size());

		Test.stopTest();
	}
}