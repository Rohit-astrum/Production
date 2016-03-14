@isTest
private class D2D_LeadScheduledVisitsControllerTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out

	@testSetup static void setupData() {
		D2DTestUtility.InitializeRequiredMethods();
		D2DTestUtility.CreateCustomSettings(false, 'd2d.tester@email.com');

		D2DTestUtility.CreateManagerUsers(1);
		User d2dMg = D2DTestUtility.d2dManagerUsers[0];

		D2DTestUtility.CreateSalesRepUsers(1);
		User d2dSr = D2DTestUtility.d2dSalesRepUsers[0];

		D2DTestUtility.CreatePortalReferralRequiredObjects(1, 'NY', '24 Panel');
		D2DTestUtility.CreatePortalReferralsWithLeads(1, d2dMg.Id, d2dSr.Id, 'SOLD', 'Sold', '24 Panel', '2', 'ref', 'Joe', '1010 Boolean Way', 'Stony Point', 'NY', '10980', 'Rockland', false);
		D2DTestUtility.CreatePortalReferralsWithLeads(1, d2dMg.Id, d2dSr.Id, 'OPEN', 'Prospect New', '24 Panel', '2', 'ref', 'Bob', '1010 Tens Ave', 'Stony Point', 'NY', '10980', 'Rockland', false);
		D2DTestUtility.CreatePortalReferralsWithConvertedLeads(1, d2dMg.Id, d2dSr.Id, 'OPEN', 'Prospect New', '36 Panel', '3', 'ref', 'Joe', '1010 Tenth St', 'Stony Point', 'NY', '10980', 'Rockland', true);
	}
	
	@isTest static void test_Filters() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id, D2D_Lead_Status__c, D2D_Scheduled_Visit_Datetime__c, D2D_Sales_Rep__c FROM Portal_Referral__c WHERE Street__c LIKE '1010 Tent%' LIMIT 1];
		User repUser = [SELECT Id FROM User WHERE Id = :referral.D2D_Sales_Rep__c];

		System.runAs(repUser){
			PageReference pageRef = Page.D2D_LeadScheduledVisits;
			pageRef.getParameters().put('id', referral.Id);
			Test.setCurrentPage(pageRef);

			Test.startTest();

			D2D_LeadScheduledVisitsController controller = new D2D_LeadScheduledVisitsController();
			System.assertEquals(12, controller.dateFilterOptions.size());
			System.assertEquals(52, controller.stateFilterOptions.size());
			controller.refresh();

			controller.onlyScheduledVisits = false;
			controller.dateFilterOption = 'YESTERDAY';
			System.assertEquals(0, controller.referrals.size());
			controller.dateFilterOption = 'TODAY';
			System.assertEquals(3, controller.referrals.size());

			controller.onlyScheduledVisits = true;
			controller.dateFilterOption = 'TOMORROW';
			System.assertEquals(1, controller.referrals.size());
			controller.dateFilterOption = 'TODAY';
			System.assertEquals(0, controller.referrals.size());
			controller.dateFilterOption = 'entire';
			System.assertEquals(1, controller.referrals.size());

			controller.onlyScheduledVisits = false;
			controller.stateFilterOption = 'CA';
			System.assertEquals(0, controller.referrals.size());
			controller.stateFilterOption = 'NY';
			System.assertEquals(3, controller.referrals.size());

			controller.sortExpression = 'Full_Name__c';
			System.assertEquals('ASC', controller.sortDirection);
			controller.rowLimit = 3;
			controller.sortExpression = 'Full_Name__c';
			System.assertEquals('DESC', controller.sortDirection);
			System.assertEquals(3, controller.referrals.size());

			Test.stopTest();
		}
	}
	
	@isTest static void test_Schedule() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id, D2D_Lead_Status__c, D2D_Scheduled_Visit_Datetime__c, D2D_Sales_Rep__c FROM Portal_Referral__c WHERE Street__c LIKE '1010 Tent%' LIMIT 1];
		User repUser = [SELECT Id FROM User WHERE Id = :referral.D2D_Sales_Rep__c];

		System.runAs(repUser){
			PageReference pageRef = Page.D2D_LeadScheduledVisits;
			pageRef.getParameters().put('id', referral.Id);
	        pageRef.getParameters().put('dateText', '11-01-2015');
	        pageRef.getParameters().put('selectHour', '1');
	        pageRef.getParameters().put('selectMinute', '30');
	        pageRef.getParameters().put('selectAmPm', 'PM');
			Test.setCurrentPage(pageRef);

			Test.startTest();

			D2D_LeadScheduledVisitsController controller = new D2D_LeadScheduledVisitsController();

			controller.schedule();

			controller.refresh();

			Test.stopTest();
		}

		referral = [SELECT Id, D2D_Lead_Status__c, D2D_Scheduled_Visit_Datetime__c FROM Portal_Referral__c WHERE Id = :referral.Id LIMIT 1];
		system.assertEquals('Visit Scheduled', referral.D2D_Lead_Status__c);
		system.assertNotEquals(null, referral.D2D_Scheduled_Visit_Datetime__c);
	}
}