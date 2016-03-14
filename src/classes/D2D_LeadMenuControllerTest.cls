@isTest
private class D2D_LeadMenuControllerTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out

	@testSetup static void setupData() {
		D2DTestUtility.InitializeRequiredMethods();
		D2DTestUtility.CreateCustomSettings('sales.coordinator@email.com');
		D2DTestUtility.CreateSalesCoordinatorUser();
		
		D2DTestUtility.CreateManagerUsers(1);
		User d2dMg = D2DTestUtility.d2dManagerUsers[0];

		D2DTestUtility.CreateSalesRepUsers(1);
		User d2dSr = D2DTestUtility.d2dSalesRepUsers[0];

		D2DTestUtility.CreatePortalReferralRequiredObjects(1, 'NY', '24 Panel');
		D2DTestUtility.CreatePortalReferralsWithConvertedLeads(1, d2dMg.Id, d2dSr.Id, 'QUALIFIED', 'Prospect New', '24 Panel', '2', 'ref', 'Joe', '101 Boolean Way', 'Stony Point', 'NY', '10980', 'Rockland', false);
	}
	
	@isTest static void test_LeadMenu() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id, Third_Visit_Datetime__c, Notes__c FROM Portal_Referral__c LIMIT 1];
		referral.Third_Visit_Datetime__c = Datetime.now();
		update referral;

		PageReference pageRef = Page.D2D_LeadMenu;
		pageRef.getParameters().put('id', referral.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();

		D2D_LeadMenuController controller = new D2D_LeadMenuController();

		System.assertEquals('completed', controller.recordVisitState);

		System.assertEquals(null, referral.Notes__c);
		controller.newNotes = 'This is a test class.';
		controller.saveNotes();

		System.assertEquals('', controller.newNotes);

		controller = new D2D_LeadMenuController();
		controller.newNotes = 'This is another test class.';
		controller.saveNotes();

		Test.stopTest();

		referral = [SELECT Id, Third_Visit_Datetime__c, Notes__c FROM Portal_Referral__c LIMIT 1];

		System.assertNotEquals(null, referral.Notes__c);
		System.assertNotEquals('', controller.previousNotes);
	}
}