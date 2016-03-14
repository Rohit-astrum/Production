@isTest
private class D2D_ManagerDashboardControllerTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out

	@testSetup static void setupData() {
		D2DTestUtility.InitializeRequiredMethods();
		
		D2DTestUtility.CreateAdminUsers(1);

		D2DTestUtility.CreateManagerUsers(1);
		User d2dMg = D2DTestUtility.d2dManagerUsers[0];

		D2DTestUtility.CreateManagerUsers(1, 'Company B');

		D2DTestUtility.CreateSalesRepUsers(1);
		D2DTestUtility.CreateSalesRepUsers(1, 'Company B');

		D2DTestUtility.CreatePortalReferralRequiredObjects(1, 'NY', '24 Panel');
		D2DTestUtility.CreatePortalReferralsWithLeads(3, d2dMg.Id, null, 'OPEN', 'Prospect New', '24 Panel', '1', 'ref', 'Joe', '101 Boolean Way', 'Stony Point', 'NY', '10980', 'Rockland', false);
		D2DTestUtility.CreatePortalReferralsWithLeads(1, d2dMg.Id, null, 'QUALIFIED', 'Prospect New', '24 Panel', '2', 'ref', 'Joe', '1010 Boolean Way', 'Stony Point', 'NY', '10980', 'Rockland', false);
		D2DTestUtility.CreatePortalReferralsWithLeads(1, d2dMg.Id, null, 'SOLD', 'Sold', '36 Panel', '3', 'ref', 'Joe', '10101 Boolean Way', 'Stony Point', 'NY', '10980', 'Rockland', false);
	}

	@isTest static void testLoadAndFilterAndSort() {
		if(!runalltests){ return; }

		List<Portal_Referral__c> referrals = [SELECT Id, Segment_Priority__c, Carrier_Route__c FROM Portal_Referral__c];
		for(Portal_Referral__c referral : referrals){
			system.debug('**SZ: street = ' + referral.Segment_Priority__c);
			if(referral.Segment_Priority__c == '1'){
				referral.Carrier_Route__c = 'A';
			} else {
				referral.Carrier_Route__c = 'B';
			}
			system.debug('**SZ: carrier route = ' + referral.Carrier_Route__c);
		}
		update referrals;

		Portal_Referral__c managerUserId = [SELECT D2D_Manager__c FROM Portal_Referral__c LIMIT 1];
		User managerUser = [SELECT Id FROM User WHERE Id = :managerUserId.D2D_Manager__c AND CompanyName = 'Test Company' LIMIT 1];
		System.runAs(managerUser){
			PageReference pageRef = Page.D2D_ManagerDashboard;
			Test.setCurrentPage(pageRef);

			Test.startTest();

			D2D_ManagerDashboardController controller = new D2D_ManagerDashboardController();
			System.assertEquals(10, controller.dateFilterOptions.size());
			System.assertEquals(4, controller.segmentFilterOptions.size());
			System.assertEquals(52, controller.stateFilterOptions.size());
			System.assertEquals(18, controller.statusFilterOptions.size());
			System.assertEquals(4, controller.systemSizeFilterOptions.size());
			System.assertEquals(2, controller.assignedSalesRepOptions.size());
			System.assertEquals(2, controller.managerFilterOptions.size());
			System.assertEquals(4, controller.rowLimitOptions.size());
			controller.refresh();

			controller.dateFilterOption = 'YESTERDAY';
			controller.filter();
			System.assertEquals(0, controller.referrals.size());
			controller.dateFilterOption = 'TODAY';
			controller.filter();
			System.assertEquals(5, controller.referrals.size());

			controller.segmentFilterOption = '2';
			controller.filter();
			System.assertEquals(1, controller.referrals.size());
			controller.segmentFilterOption = '3';
			controller.filter();
			System.assertEquals(1, controller.referrals.size());
			controller.segmentFilterOption = '1';
			controller.filter();
			System.assertEquals(3, controller.referrals.size());
			controller.segmentFilterOption = 'entire';
			controller.filter();
			System.assertEquals(5, controller.referrals.size());

			controller.stateFilterOption = 'CA';
			controller.filter();
			System.assertEquals(0, controller.referrals.size());
			controller.stateFilterOption = 'NY';
			controller.filter();
			System.assertEquals(5, controller.referrals.size());

			controller.statusFilterOption = 'Prospect New';
			controller.filter();
			System.assertEquals(4, controller.referrals.size());
			controller.statusFilterOption = 'Sold';
			controller.filter();
			System.assertEquals(1, controller.referrals.size());
			controller.statusFilterOption = 'entire';
			controller.filter();
			System.assertEquals(5, controller.referrals.size());

			controller.systemSizeFilterOption = '36 Panel';
			controller.filter();
			System.assertEquals(1, controller.referrals.size());
			controller.systemSizeFilterOption = '24 Panel';
			controller.filter();
			System.assertEquals(4, controller.referrals.size());
			controller.systemSizeFilterOption = 'entire';
			controller.filter();
			System.assertEquals(5, controller.referrals.size());

			controller.streetArg = 'asdfgh';
			controller.filter();
			System.assertEquals(0, controller.referrals.size());
			controller.streetArg = 'Boolean';
			controller.filter();
			System.assertEquals(5, controller.referrals.size());
			controller.streetArg = '';
			controller.filter();

			controller.cityArg = 'asdfgh';
			controller.filter();
			System.assertEquals(0, controller.referrals.size());
			controller.cityArg = 'Stony';
			controller.filter();
			System.assertEquals(5, controller.referrals.size());
			controller.cityArg = '';
			controller.filter();

			controller.zipArg = 'asdfgh';
			controller.filter();
			System.assertEquals(0, controller.referrals.size());
			controller.zipArg = '10980';
			controller.filter();
			System.assertEquals(5, controller.referrals.size());
			controller.zipArg = '';
			controller.filter();

			controller.searchArg = 'Nick';
			controller.filter();
			System.assertEquals(0, controller.referrals.size());
			controller.searchArg = 'Joe';
			controller.filter();
			System.assertEquals(5, controller.referrals.size());

			controller.carrierRouteFilterOption = 'C';
			controller.filter();
			System.assertEquals(0, controller.referrals.size());
			controller.carrierRouteFilterOption = 'A';
			controller.filter();
			System.assertEquals(3, controller.referrals.size());

			controller.sortExpression = 'Full_Name__c';
			controller.filter();
			System.assertEquals('ASC', controller.sortDirection);
			controller.rowLimit = 3;
			controller.sortExpression = 'Full_Name__c';
			controller.filter();
			System.assertEquals('DESC', controller.sortDirection);

			controller.isLastPage = false;
			controller.next();
			controller.prev();
			controller.filter();
			controller.saveUserFilters();

			controller = new D2D_ManagerDashboardController();
			System.assertNotEquals(null, controller.userSessionFilter);
			controller.saveUserFilters();


			Test.stopTest();
		}
	}

	@isTest static void testFilterAsAdmin() {
		if(!runalltests){ return; }

		User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'D2D Admin' AND CompanyName = 'Test Company' LIMIT 1];
		System.runAs(adminUser){
			PageReference pageRef = Page.D2D_ManagerDashboard;
			Test.setCurrentPage(pageRef);

			Test.startTest();

			D2D_ManagerDashboardController controller = new D2D_ManagerDashboardController();
			System.assertEquals(10, controller.dateFilterOptions.size());
			System.assertEquals(4, controller.segmentFilterOptions.size());
			System.assertEquals(52, controller.stateFilterOptions.size());
			System.assertEquals(18, controller.statusFilterOptions.size());
			System.assertEquals(4, controller.systemSizeFilterOptions.size());

			List<User> reps = [SELECT Id FROM User WHERE Profile.Name = 'D2D Sales Rep'];
			System.assertEquals(reps.size() + 1, controller.assignedSalesRepOptions.size());

			List<User> mgrs = [SELECT Id, FirstName, LastName, Email FROM User WHERE Profile.Name = 'D2D Admin' OR Profile.Name = 'D2D Manager'];
			System.assertEquals(mgrs.size() + 1, controller.managerFilterOptions.size());
			System.assertEquals(mgrs.size() + 1, controller.assignedManagerOptions.size());
			controller.refresh();

			controller.managerFilterOption = controller.managerFilterOptions[1].getValue();
			controller.filter();
			System.assertEquals(0, controller.referrals.size());
			controller.managerFilterOption = 'entire';
			controller.filter();
			System.assertEquals(5, controller.referrals.size());

			Test.stopTest();
		}
	}
	
	@isTest static void testAssign() {
		if(!runalltests){ return; }

		Portal_Referral__c managerUserId = [SELECT D2D_Manager__c FROM Portal_Referral__c LIMIT 1];
		User managerUser = [SELECT Id FROM User WHERE Id = :managerUserId.D2D_Manager__c AND CompanyName = 'Test Company' LIMIT 1];
		System.runAs(managerUser){
			PageReference pageRef = Page.D2D_ManagerDashboard;
			Test.setCurrentPage(pageRef);

			Test.startTest();

			D2D_ManagerDashboardController controller = new D2D_ManagerDashboardController();
			System.assertEquals(2, controller.assignedSalesRepOptions.size());

			ApexPages.Message[] pageMessages = ApexPages.getMessages();
			Integer pageMessagesCount = pageMessages.size();

			// Testing for no manager selected
			controller.assign();
			pageMessages = ApexPages.getMessages();
			system.assertNotEquals(pageMessagesCount, pageMessages.size());

			pageMessagesCount = pageMessages.size();
			controller.assignedSalesRepOption = controller.assignedSalesRepOptions[1].getValue();
			controller.assign();
			pageMessages = ApexPages.getMessages();
			system.assertNotEquals(pageMessagesCount, pageMessages.size());

			pageMessagesCount = pageMessages.size();
			Integer count = 0;
			for(D2D_ManagerDashboardController.PortalReferralWrapper prw : controller.referrals){
				if(Math.mod(count, 2) == 0){
					prw.Selected = true;
				}
			}
			controller.processSelected();
			controller.assign();
			pageMessages = ApexPages.getMessages();
			for(ApexPages.Message msg : pageMessages){
				System.debug('**SZ: message = ' + msg);
			}
			system.assertEquals(pageMessagesCount, pageMessages.size());

			Test.stopTest();
		}
	}
	
	@isTest static void testTransfer() {
		if(!runalltests){ return; }

		User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'D2D Admin' AND CompanyName = 'Test Company' LIMIT 1];
		System.runAs(adminUser){
			PageReference pageRef = Page.D2D_ManagerDashboard;
			Test.setCurrentPage(pageRef);

			Test.startTest();

			D2D_ManagerDashboardController controller = new D2D_ManagerDashboardController();

			List<User> reps = [SELECT Id FROM User WHERE Profile.Name = 'D2D Sales Rep'];
			System.assertEquals(reps.size() + 1, controller.assignedSalesRepOptions.size());

			List<User> mgrs = [SELECT Id, FirstName, LastName, Email FROM User WHERE Profile.Name = 'D2D Admin' OR Profile.Name = 'D2D Manager'];
			System.assertEquals(mgrs.size() + 1, controller.assignedManagerOptions.size());

			ApexPages.Message[] pageMessages = ApexPages.getMessages();
			Integer pageMessagesCount = pageMessages.size();

			// Testing for no manager selected
			controller.transfer();
			pageMessages = ApexPages.getMessages();
			system.assertNotEquals(pageMessagesCount, pageMessages.size());

			pageMessagesCount = pageMessages.size();
			controller.assignedManagerOption = controller.assignedManagerOptions[2].getValue();
			controller.transfer();
			pageMessages = ApexPages.getMessages();
			system.assertNotEquals(pageMessagesCount, pageMessages.size());

			pageMessagesCount = pageMessages.size();
			Integer count = 0;
			for(D2D_ManagerDashboardController.PortalReferralWrapper prw : controller.referrals){
				if(Math.mod(count, 2) == 0){
					prw.Selected = true;
				}
			}
			controller.processSelected();
			controller.transfer();
			pageMessages = ApexPages.getMessages();
			for(ApexPages.Message msg : pageMessages){
				System.debug('**SZ: message = ' + msg);
			}
			system.assertEquals(pageMessagesCount, pageMessages.size());

			Test.stopTest();
		}
	}
}