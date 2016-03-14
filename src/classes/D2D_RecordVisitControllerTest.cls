@isTest
private class D2D_RecordVisitControllerTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out

	@testSetup static void setupData() {
		D2DTestUtility.InitializeRequiredMethods();
		D2DTestUtility.CreateCustomSettings('sales.coordinator@email.com');
		
		D2DTestUtility.CreateManagerUsers(1);
		User d2dMg = D2DTestUtility.d2dManagerUsers[0];

		D2DTestUtility.CreateSalesRepUsers(1);
		User d2dSr = D2DTestUtility.d2dSalesRepUsers[0];

		D2DTestUtility.CreatePortalReferralRequiredObjects(1, 'NY', '24 Panel');
		D2DTestUtility.CreatePortalReferralsWithLeads(1, d2dMg.Id, d2dSr.Id, 'QUALIFIED', 'Prospect New', '24 Panel', '2', 'ref', 'Joe', '101 Boolean Way', 'Stony Point', 'NY', '10980', 'Rockland', false);
	}
	
	@isTest static void test_RecordVisits() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id FROM Portal_Referral__c LIMIT 1];

		PageReference pageRef = Page.D2D_RecordVisit;
		pageRef.getParameters().put('id', referral.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();

		D2D_RecordVisitController controller = new D2D_RecordVisitController();

		// Submit First Visit
		controller.newVisitNote = 'First Visit Test';
		controller.submitVisit();
		referral = [SELECT Id, D2D_Lead_Status__c FROM Portal_Referral__c LIMIT 1];
		system.assertEquals('NA Visit 1', referral.D2D_Lead_Status__c);

		// Submit Second Visit
		controller.newVisitNote = 'Second Visit Test';
		controller.submitVisit();
		referral = [SELECT Id, D2D_Lead_Status__c FROM Portal_Referral__c LIMIT 1];
		system.assertEquals('NA Visit 2', referral.D2D_Lead_Status__c);

		// Submit Third Visit
		controller.newVisitNote = 'Third Visit Test';
		controller.submitVisit();
		referral = [SELECT Id, D2D_Lead_Status__c FROM Portal_Referral__c LIMIT 1];
		system.assertEquals('Door Hanger', referral.D2D_Lead_Status__c);

		system.assertEquals(3, controller.visits.size());

		Test.stopTest();
	}
}