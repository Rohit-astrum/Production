@isTest
private class D2D_SalesRepDashboardControllerTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out

	@testSetup static void setupData() {
		D2DTestUtility.InitializeRequiredMethods();
		D2DTestUtility.CreateCustomSettings(false, 'd2d.tester@email.com');

		D2DTestUtility.CreateManagerUsers(1);
		User d2dMg = D2DTestUtility.d2dManagerUsers[0];

		D2DTestUtility.CreateSalesRepUsers(1);
		User d2dSr = D2DTestUtility.d2dSalesRepUsers[0];

		D2DTestUtility.CreatePortalReferralRequiredObjects(1, 'NY', '24 Panel');
		D2DTestUtility.CreatePortalReferralsWithLeads(3, d2dMg.Id, d2dSr.Id, 'OPEN', 'Prospect New', '24 Panel', '1', 'ref', 'Joe', '101 Boolean Way', 'Stony Point', 'NY', '10980', 'Rockland', false);
		D2DTestUtility.CreatePortalReferralsWithLeads(1, d2dMg.Id, d2dSr.Id, 'QUALIFIED', 'Prospect New', '24 Panel', '2', 'ref', 'Joe', '1010 Boolean Way', 'Stony Point', 'NY', '10980', 'Rockland', false);
		D2DTestUtility.CreatePortalReferralsWithLeads(1, d2dMg.Id, d2dSr.Id, 'SOLD', 'Sold', '36 Panel', '3', 'ref', 'Joe', '10101 Boolean Way', 'Stony Point', 'NY', '10980', 'Rockland', false);
		D2DTestUtility.CreatePortalReferralsWithLeads(1, d2dMg.Id, d2dSr.Id, 'SOLD', 'Sold', '36 Panel', '3', 'ref', 'Joe', '1010 Tenth St', 'Stony Point', 'NY', '10980', 'Rockland', true);
	}
	
	@isTest static void testLoadAndFilterAndSort() {
		if(!runalltests){ return; }

		List<Portal_Referral__c> referrals = [SELECT Id, Carrier_Route__c FROM Portal_Referral__c];
		for(Portal_Referral__c referral : referrals){
			referral.Carrier_Route__c = 'C001';
		}
		update referrals;

		User repUser = [SELECT Id FROM User WHERE Profile.Name = 'D2D Sales Rep' AND CompanyName = 'Test Company' LIMIT 1];
		System.runAs(repUser){
			PageReference pageRef = Page.D2D_SalesRepDashboard;
			Test.setCurrentPage(pageRef);

			Test.startTest();

			D2D_SalesRepDashboardController controller = new D2D_SalesRepDashboardController();
			System.assertEquals(false, controller.allowLeadCreation);
			System.assertEquals(12, controller.dateFilterOptions.size());
			System.assertEquals(4, controller.segmentFilterOptions.size());
			System.assertEquals(52, controller.stateFilterOptions.size());
			System.assertEquals(18, controller.statusFilterOptions.size());
			System.assertEquals(4, controller.systemSizeFilterOptions.size());
			controller.refresh();

			controller.dateFilterOption = 'YESTERDAY';
			System.assertEquals(0, controller.referrals.size());
			controller.dateFilterOption = 'TODAY';
			System.assertEquals(6, controller.referrals.size());

			controller.onlyScheduledVisits = true;
			controller.dateFilterOption = 'TOMORROW';
			System.assertEquals(1, controller.referrals.size());
			controller.dateFilterOption = 'TODAY';
			System.assertEquals(0, controller.referrals.size());
			controller.dateFilterOption = 'entire';
			System.assertEquals(1, controller.referrals.size());

			controller.onlyScheduledVisits = false;
			controller.segmentFilterOption = '2';
			System.assertEquals(1, controller.referrals.size());
			controller.segmentFilterOption = '3';
			System.assertEquals(2, controller.referrals.size());
			controller.segmentFilterOption = '1';
			System.assertEquals(3, controller.referrals.size());
			controller.segmentFilterOption = 'entire';
			System.assertEquals(6, controller.referrals.size());

			controller.stateFilterOption = 'CA';
			System.assertEquals(0, controller.referrals.size());
			controller.stateFilterOption = 'NY';
			System.assertEquals(6, controller.referrals.size());

			controller.statusFilterOption = 'Prospect New';
			System.assertEquals(4, controller.referrals.size());
			controller.statusFilterOption = 'Sold';
			System.assertEquals(2, controller.referrals.size());
			controller.statusFilterOption = 'entire';
			System.assertEquals(6, controller.referrals.size());

			controller.systemSizeFilterOption = '36 Panel';
			System.assertEquals(2, controller.referrals.size());
			controller.systemSizeFilterOption = '24 Panel';
			System.assertEquals(4, controller.referrals.size());
			controller.systemSizeFilterOption = 'entire';
			System.assertEquals(6, controller.referrals.size());

			controller.streetArg = 'asdfgh';
			System.assertEquals(0, controller.referrals.size());
			controller.streetArg = 'Boolean';
			System.assertEquals(5, controller.referrals.size());
			controller.streetArg = '';

			controller.cityArg = 'asdfgh';
			System.assertEquals(0, controller.referrals.size());
			controller.cityArg = 'Stony';
			System.assertEquals(6, controller.referrals.size());
			controller.cityArg = '';

			controller.zipArg = 'asdfgh';
			System.assertEquals(0, controller.referrals.size());
			controller.zipArg = '10980';
			System.assertEquals(6, controller.referrals.size());
			controller.zipArg = '';

			controller.carrierRouteFilterOption = 'C002';
			System.assertEquals(0, controller.referrals.size());
			controller.carrierRouteFilterOption = 'C001';
			System.assertEquals(6, controller.referrals.size());
			controller.carrierRouteFilterOption = '';

			controller.searchArg = 'Nick';
			System.assertEquals(0, controller.referrals.size());
			controller.searchArg = 'Joe';
			System.assertEquals(6, controller.referrals.size());

			controller.sortExpression = 'Full_Name__c';
			System.assertEquals('ASC', controller.sortDirection);
			controller.rowLimit = 3;
			controller.sortExpression = 'Full_Name__c';
			System.assertEquals('DESC', controller.sortDirection);
			//System.assertEquals(3, controller.referrals.size());
			
			controller.saveUserFilters();

			controller = new D2D_SalesRepDashboardController();
			System.assertNotEquals(null, controller.userSessionFilter);
			controller.saveUserFilters();

			Test.stopTest();
		}
	}
}