@isTest
private class Site_Survey_Disqualified_Controller_Test {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out
	
	@isTest static void test_D2DEventDisqualified() {
		if(!runalltests){ return; }

		testData.setupCustomSettings();
		D2DTestUtility.InitializeRequiredMethods();

		D2DTestUtility.CreateManagerUsers(1);
		User d2dMg = D2DTestUtility.d2dManagerUsers[0];

		D2DTestUtility.CreateSalesRepUsers(1);
		User d2dSr = D2DTestUtility.d2dSalesRepUsers[0];

		Opportunity opp = Milestone1_Test_Utility.CreateTestOpp();

		Test.startTest();

		Event theEvent = createEvent(opp, true);

    	Portal_Referral__c referral = new Portal_Referral__c(
    		Last_Name__c = 'Test',
			D2D_Lead_Status__c = 'Visit Scheduled',
			D2D_Sales_Rep__c = d2dSr.Id,
			Opportunity__c = opp.Id
		);
		insert referral;

    	// execute
		ApexPages.Standardcontroller standController = new ApexPages.Standardcontroller(theEvent);
		Site_Survey_Disqualified_Controller_Ext controller = new Site_Survey_Disqualified_Controller_Ext(standController);
    	
    	// populate the response: Insufficient Savings, but no referral email will trigger an error
    	Integer pageMessageCount = ApexPages.getMessages().size();
    	controller.opp.Closed_Reason__c = 'Insufficient Savings';
    	controller.updateEventCompleted();
    	system.assertNotEquals(pageMessageCount, ApexPages.getMessages().size());

    	referral.Email__c = 'referral@email.com';
    	update referral;

    	// populate the response: Insufficient Savings
    	pageMessageCount = ApexPages.getMessages().size();
    	controller.opp.Closed_Reason__c = 'Insufficient Savings';
    	controller.updateEventCompleted();
    	system.assertEquals(pageMessageCount, ApexPages.getMessages().size());

    	// populate the response: TSRF
    	pageMessageCount = ApexPages.getMessages().size();
    	controller.opp.Closed_Reason__c = 'TSRF';
    	controller.updateEventCompleted();
    	system.assertEquals(pageMessageCount, ApexPages.getMessages().size());

    	Test.stopTest();
	}
	
	@isTest static void test_NonD2DEventDisqualified() {
		if(!runalltests){ return; }

		testData.setupCustomSettings();
		D2DTestUtility.InitializeRequiredMethods();

		Opportunity opp = Milestone1_Test_Utility.CreateTestOpp();

		Test.startTest();

		Event theEvent = createEvent(opp, false);
    	
    	// execute
		ApexPages.Standardcontroller standController = new ApexPages.Standardcontroller(theEvent);
		Site_Survey_Disqualified_Controller_Ext controller = new Site_Survey_Disqualified_Controller_Ext(standController);

		// No response to closed reason
    	Integer pageMessageCount = ApexPages.getMessages().size();
    	controller.updateEventCompleted();
    	system.assertNotEquals(pageMessageCount, ApexPages.getMessages().size());

    	Test.stopTest();
	}

	private static Event createEvent(Opportunity opp, Boolean isD2D) {

		Event tempEvent = new Event();
		tempEvent.OwnerId = UserInfo.getUserId();
		  
		tempEvent.Subject = 'Test';
		tempEvent.StartDateTime = Datetime.now();
		tempEvent.EndDateTime = Datetime.now().addDays(14);
		tempEvent.WhatId = opp.Id;
		tempEvent.D2D_Survey_Request__c = isD2D;

		insert tempEvent;			
	
		return tempEvent;
	}
}