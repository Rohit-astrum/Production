@isTest
private class D2D_InitialPortalReferralTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out

	@testSetup static void setupData() {
		D2DTestUtility.InitializeRequiredMethods();
		D2DTestUtility.CreateCustomSettings('sales.coordinator@email.com');
		D2DTestUtility.CreateSalesCoordinatorUser();
		
		D2DTestUtility.CreateManagerUsers(1);
		User d2dMg = D2DTestUtility.d2dManagerUsers[0];

		D2DTestUtility.CreateSalesRepUsers(1);
		User d2dSr = D2DTestUtility.d2dSalesRepUsers[0];

		D2DTestUtility.CreatePortalReferralRequiredObjects(1, 'CA', '24 Panel');
		D2DTestUtility.CreatePortalReferralsWithLeads(1, d2dMg.Id, d2dSr.Id, 'QUALIFIED', 'Prospect New', '', '2', 'ref', 'Joe', '10101 Boolean Way', 'Stony Point', 'CA', '10980', 'Rockland', false);
		D2DTestUtility.CreatePortalReferralsWithConvertedLeads(1, d2dMg.Id, d2dSr.Id, 'QUALIFIED', 'Prospect New', '24 Panel', '2', 'ref', 'Joe', '101 Boolean Way', 'Stony Point', 'CA', '10980', 'Rockland', false);

		List<Portal_Referral__c> referrals = [SELECT Id FROM Portal_Referral__c];
		delete referrals;

		List<Event> events = new List<Event>();
		for(Opportunity opp : [SELECT Id FROM Opportunity]){
			Event event = new Event(
				StartDateTime = Datetime.now(),
				WhatId = opp.Id,
				DurationInMinutes = 60
			);
			events.add(event);
		}
		insert events;
	}
	
	@isTest static void test_Leads() {
		if(!runalltests){ return; }

        Set<String> managerNames = new Set<String>();
        managerNames.add('D2DMG_0');

        List<User> managers = [SELECT Id, Name FROM User WHERE Profile.Name = 'D2D Manager' AND Name IN :managerNames];
        Map<String, Id> managersByName = new Map<String, Id>();
        for(User u : managers){
        	managersByName.put(u.Name, u.Id);
        }

		Map<String, Id> cityToManager = new Map<String, Id>();
		cityToManager.put('lake forest', managersByName.get('D2DMG_0'));
		cityToManager.put('san bernardino', managersByName.get('D2DMG_0'));
		cityToManager.put('san juan capistrano', managersByName.get('D2DMG_0'));
		cityToManager.put('foothill ranch', managersByName.get('D2DMG_0'));
		cityToManager.put('trabuco canyon', managersByName.get('D2DMG_0'));
		cityToManager.put('ontario', managersByName.get('D2DMG_0'));
		cityToManager.put('rialto', managersByName.get('D2DMG_0'));
		cityToManager.put('fontana', managersByName.get('D2DMG_0'));

		Test.startTest();

		String query = 'SELECT Id, D2D_System_Size__c, FirstName, LastName, Street, City, State, PostalCode FROM Lead' +
			' WHERE IsConverted = false AND State = \'CA\' AND Global_Opt_Out__c = false AND Do_Not_Solicit__c = false' +
			' AND Affiliate_Community_Program__c IN :affiliateCommunityPrograms';
		//	' AND City IN :cityToManager.keySet()';
system.debug('**SZ: query = ' + query);
		D2D_InitialLeadPortalReferralBatch batchCalculator = new D2D_InitialLeadPortalReferralBatch(query, cityToManager);
		Database.executeBatch(batchCalculator, 200);

		Test.stopTest();

		List<Portal_Referral__c> referrals = [SELECT Id FROM Portal_Referral__c WHERE Lead__c != null LIMIT 2];
		system.assertEquals(1, referrals.size());
	}
	
	@isTest static void test_Opportunities() {
		if(!runalltests){ return; }

		Map<Id, Opportunity> opps = new Map<Id, Opportunity>([SELECT Id FROM Opportunity]);

        Set<String> managerNames = new Set<String>();
        managerNames.add('D2DMG_0');

        List<User> managers = [SELECT Id, Name FROM User WHERE Profile.Name = 'D2D Manager' AND Name IN :managerNames];
        Map<String, Id> managersByName = new Map<String, Id>();
        for(User u : managers){
        	managersByName.put(u.Name, u.Id);
        }

		Map<Id, Id> oppIdToManagerId = new Map<Id, Id>();
		for(Id oppId : opps.keySet()){
			oppIdToManagerId.put(oppId, managersByName.get('D2DMG_0'));
		}

        Set<String> repNames = new Set<String>();
        repNames.add('D2DSR_1');
        List<User> reps = [SELECT Id, Name FROM User WHERE Profile.Name = 'D2D Sales Rep' AND Name IN :repNames];
        Map<String, Id> repsByName = new Map<String, Id>();
        for(User u : reps){
        	repsByName.put(u.Name, u.Id);
        }

        Map<Id, Id> oppIdToRepId = new Map<Id, Id>();
		for(Id oppId : opps.keySet()){
			oppIdToRepId.put(oppId, repsByName.get('D2DSR_1'));
		}

		Test.startTest();

		D2D_InitialOppPortalReferralBatch batchCalculator = new D2D_InitialOppPortalReferralBatch(oppIdToManagerId, oppIdToRepId);
		Database.executeBatch(batchCalculator, 200);

		Test.stopTest();

		List<Portal_Referral__c> referrals = [SELECT Id FROM Portal_Referral__c WHERE Opportunity__c != null LIMIT 2];
		system.assertEquals(1, referrals.size());
	}
}