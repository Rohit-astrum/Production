@isTest
private class LeadsAssignmentControllerTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out

	@testSetup static void setupData() {
		D2DTestUtility.InitializeRequiredMethods();
		D2DTestUtility.CreateManagerUsers(1);

		D2DTestUtility.CreatePortalReferralRequiredObjects(1, 'NY', '24 Panel');
		D2DTestUtility.CreatePortalReferralsWithLeads(1, null, null, 'Prospect New', 'Prospect New', '24 Panel', '1', 'ref1', 'Joe', '125 Fifth Avenue', 'New York', 'NY', '10980', 'Rockland', false);
		D2DTestUtility.CreatePortalReferralsWithLeads(1, null, null, 'Prospect New', 'Prospect New', '24 Panel', '2', 'ref2', 'Joe', '129 Fifth Avenue', 'New York', 'NY', '10980', 'Rockland', false);
		D2DTestUtility.CreatePortalReferralsWithLeads(1, null, null, 'Prospect New', 'Prospect New', '24 Panel', '3', 'ref3', 'Joe', '133 Wacker Drive', 'Chicago', 'IL', '60016', 'Rockland', false);
	}
	
	@isTest static void test_filtersAndCancel() {
		if(!runalltests){ return; }

		PageReference pageRef = Page.LeadsAssignment;
		Test.setCurrentPage(pageRef);

		Campaign campaign = [SELECT Id FROM Campaign WHERE Name LIKE '%D2D%' LIMIT 1];

		Test.startTest();

		LeadsAssignmentController controller = new LeadsAssignmentController();
		system.assertEquals(3, controller.filteredReferrals.size());

		controller.selectedSegment = '1';
		controller.filterChanged();
		system.assertEquals(1, controller.filteredReferrals.size());
		system.assertEquals('ref10', controller.filteredReferrals[0].portalReferral.Last_Name__c);

		controller.selectedSegment = '2';
		controller.filterChanged();
		system.assertEquals(1, controller.filteredReferrals.size());
		system.assertEquals('ref20', controller.filteredReferrals[0].portalReferral.Last_Name__c);

		controller.selectedSegment = '3';
		controller.filterChanged();
		system.assertEquals(1, controller.filteredReferrals.size());
		system.assertEquals('ref30', controller.filteredReferrals[0].portalReferral.Last_Name__c);

		controller.cancel();
		system.assertEquals(3, controller.filteredReferrals.size());

		controller.selectedAffiliateCommunityProgram = 'XYZ';
		controller.filterChanged();
		system.assertEquals(0, controller.filteredReferrals.size());
		controller.selectedAffiliateCommunityProgram = 'D2D Long Island';
		controller.filterChanged();
		system.assertEquals(3, controller.filteredReferrals.size());

		controller.cancel();
		system.assertEquals(3, controller.filteredReferrals.size());

		controller.selectedPrimarySourceCampaign = campaign.Id;
		controller.filterChanged();
		system.assertEquals(3, controller.filteredReferrals.size());

		controller.cancel();
		system.assertEquals(3, controller.filteredReferrals.size());

		controller.selectedState = 'NY';
		controller.filterChanged();
		system.assertEquals(2, controller.filteredReferrals.size());
		for(LeadsAssignmentController.PortalReferralWrapper prw : controller.filteredReferrals){
			system.assertNotEquals('ref30', prw.portalReferral.Last_Name__c);
		}

		controller.selectedState = 'IL';
		controller.filterChanged();
		system.assertEquals(1, controller.filteredReferrals.size());
		system.assertEquals('ref30', controller.filteredReferrals[0].portalReferral.Last_Name__c);

		controller.selectedState = 'DE';
		controller.filterChanged();
		system.assertEquals(0, controller.filteredReferrals.size());

		Test.stopTest();
	}
	
	@isTest static void test_assignAndSave() {
		if(!runalltests){ return; }

		User d2dManager = [SELECT Id FROM User WHERE Profile.Name = 'D2D Manager' LIMIT 1];

		PageReference pageRef = Page.LeadsAssignment;
		Test.setCurrentPage(pageRef);

		Test.startTest();

		LeadsAssignmentController controller = new LeadsAssignmentController();
		system.assertEquals(3, controller.filteredReferrals.size());

		ApexPages.Message[] pageMessages = ApexPages.getMessages();
		Integer pageMessagesCount = pageMessages.size();

		// Testing for no manager selected
		controller.save();
		pageMessages = ApexPages.getMessages();
		system.assertNotEquals(pageMessagesCount, pageMessages.size());

		// testing for no rows selected
		pageMessagesCount = pageMessages.size();
		controller.selectedManager = d2dManager.Id;
		controller.save();
		pageMessages = ApexPages.getMessages();
		system.assertNotEquals(pageMessagesCount, pageMessages.size());

		pageMessagesCount = pageMessages.size();
		for(LeadsAssignmentController.PortalReferralWrapper prw : controller.filteredReferrals){
			if(prw.portalReferral.State__c == 'NY'){
				prw.selected = true;
			}
		}
		controller.save();
		pageMessages = ApexPages.getMessages();
		system.assertEquals(pageMessagesCount, pageMessages.size());

		List<Portal_Referral__c> prList = [SELECT Id, Last_Name__c, State__c FROM Portal_Referral__c WHERE D2D_Manager__c = null];
		system.assertEquals(1, prList.size());
		system.assertEquals('ref30', prList[0].Last_Name__c);
		system.assertEquals('IL', prList[0].State__c);

		Test.stopTest();
	}

/*	private static void CreateTestData(){
		// User w/ D2D Manager Profile
		UserRole role = [SELECT Id FROM UserRole WHERE Name LIKE '%Project Lead' LIMIT 1];
		Profile prof = [SELECT Id FROM Profile WHERE Name = 'Operations User'];
		User acctOwner = new User(
			Email = 'acctOwner@email.com',
			UserName = 'acctOwner@email.com',
			LastName = 'D2D',
			Alias = 'd2d.man',
			CommunityNickName = 'Acct Owner Test',
			TimeZoneSidKey = 'America/New_York',
			LocaleSidKey = 'en_US',
			LanguageLocaleKey = 'en_US',
			EmailEncodingKey = 'UTF-8',
			ProfileId = prof.Id,
			UserRoleId = role.Id
		);
		System.runAs(new User(Id = UserInfo.getUserId())){
			insert acctOwner;
		}

		Account acct = new Account(Name = 'D2D Mgr Test Acct', OwnerId = acctOwner.Id);
		insert acct;
		Contact cntc = new Contact(AccountId = acct.Id, FirstName = 'D2D', LastName = 'Mgr Test');
		insert cntc;

		prof = [SELECT Id FROM Profile WHERE Name = 'D2D Manager'];
		User d2dManager = new User(
			Email = 'tester@email.com',
			UserName = 'tester@email.com',
			LastName = 'D2D',
			Alias = 'd2d.man',
			CommunityNickName = 'D2D Manager Test',
			TimeZoneSidKey = 'America/New_York',
			LocaleSidKey = 'en_US',
			LanguageLocaleKey = 'en_US',
			EmailEncodingKey = 'UTF-8',
			ProfileId = prof.Id,
			ContactId = cntc.Id
		);
		insert d2dManager;

		List<Portal_Referral__c> prList = new List<Portal_Referral__c>();
		prList.add(new Portal_Referral__c(
			Segment_Priority__c = '1', D2D_Lead_Status__c = 'Prospect New', Last_Name__c = 'test1', First_Name__c = 'yo',
			Street__c = '125 Fifth Avenue', City__c = 'New York', State__c = 'NY', Zip__c = '10980', Lead_Created_Date__c = Date.today()
		));
		prList.add(new Portal_Referral__c(
			Segment_Priority__c = '2', D2D_Lead_Status__c = 'Prospect New', Last_Name__c = 'test2', First_Name__c = 'yo',
			Street__c = '128 Fifth Avenue', City__c = 'New York', State__c = 'NY', Zip__c = '10980', Lead_Created_Date__c = Date.today()
		));
		prList.add(new Portal_Referral__c(
			Segment_Priority__c = '3', D2D_Lead_Status__c = 'Prospect New', Last_Name__c = 'test3', First_Name__c = 'yo',
			Street__c = '133 Wacker Drive', City__c = 'Chicago', State__c = 'IL', Zip__c = '60016', Lead_Created_Date__c = Date.today()
		));
		insert prList;

		List<Document> docs = new List<Document>();
		docs.add(new Document(Name='DESLogo', FolderId=UserInfo.getUserId()));
		insert docs;
	}*/
}