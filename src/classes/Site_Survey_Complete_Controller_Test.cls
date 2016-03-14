/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Site_Survey_Complete_Controller_Test {

    static testMethod void testSiteSurveyComplete_EventComplete() {
		// setup    
    	// create event
		Opportunity opp = Milestone1_Test_Utility.CreateTestOpp();
		Event theEvent = createEvent(opp);    	
    	
    	// execute
		ApexPages.Standardcontroller standController = new ApexPages.Standardcontroller(theEvent);
		Site_Survey_Complete_Controller_Ext controller = new Site_Survey_Complete_Controller_Ext(standController);
    	controller.updateEvent();
    	
    	// assert
    	
    	// confirm event is completed
    	Boolean expected = true;

    	Event tempEvent = [select Completed__c from Event where id =:theEvent.id limit 1];
    	Boolean actual = tempEvent.Completed__c;
    	
    	System.assertEquals(expected, actual);
    }

    static testMethod void testSiteSurveyComplete_OpportunitySiteSurveyCompletedDate() {
		// setup    
    	// create event
		Opportunity opp = Milestone1_Test_Utility.CreateTestOpp();
		Event theEvent = createEvent(opp);    	
    	
    	// execute
		ApexPages.Standardcontroller standController = new ApexPages.Standardcontroller(theEvent);
		Site_Survey_Complete_Controller_Ext controller = new Site_Survey_Complete_Controller_Ext(standController);
    	controller.updateEvent();
    	
    	// assert    	
    	// confirm Opportunity.Date_Site_Survey_Completed__c is set
		opp = [Select Date_Site_Survey_Completed__c
							  From Opportunity o 
							  where id = :theEvent.WhatId 
							  limit 1];

    	Datetime expected = null;
    	Datetime actual = opp.Date_Site_Survey_Completed__c;

		System.assertNotEquals(expected, actual);    	
    }

    @isTest static void test_D2DEventCompleteNoContract() {
		// setup    
    	// create event
		Opportunity opp = Milestone1_Test_Utility.CreateTestOpp();
		Event theEvent = createEvent(opp, true);

		// Create the contract, and re-complete
    	Test.startTest();

    	// execute
    	Integer pageMessageCount = ApexPages.getMessages().size();

		ApexPages.Standardcontroller standController = new ApexPages.Standardcontroller(theEvent);
		Site_Survey_Complete_Controller_Ext controller = new Site_Survey_Complete_Controller_Ext(standController);
    	controller.updateEvent();
    	
    	// assert, no contract, so page message
    	system.assertNotEquals(pageMessageCount, ApexPages.getMessages().size());

    	Test.stopTest();
    } 

    @isTest static void test_D2DEventCompleteWithContract() {
		// setup
		D2DTestUtility.InitializeRequiredMethods();

		D2DTestUtility.CreateManagerUsers(1);
		User d2dMg = D2DTestUtility.d2dManagerUsers[0];

		D2DTestUtility.CreateSalesRepUsers(1);
		User d2dSr = D2DTestUtility.d2dSalesRepUsers[0];

    	// create event
		Opportunity opp = Milestone1_Test_Utility.CreateTestOpp();
		Event theEvent = createEvent(opp, true);

		// Create the contract, and re-complete
    	Test.startTest();

    	// Create proposal and contract
    	Portal_Referral__c referral = new Portal_Referral__c(
    		Last_Name__c = 'Test',
			D2D_Lead_Status__c = 'Visit Scheduled',
			D2D_Sales_Rep__c = d2dSr.Id,
			Opportunity__c = opp.Id
		);
		insert referral;

    	Proposal__c proposal = new Proposal__c(System_Design_Quote__c = opp.System_Design_Quote__c, Current__c = true);
    	insert proposal;

        Astrum_Contract__c contract = new Astrum_Contract__c(Proposal__c = proposal.Id, Scenario__c = '1', Closed__c = true, Property_State__c = 'NY');
    	//Astrum_Contract__c contract = new Astrum_Contract__c(Proposal__c = proposal.Id);
    	insert contract;

    	// execute
    	Integer pageMessageCount = ApexPages.getMessages().size();

		ApexPages.Standardcontroller standController = new ApexPages.Standardcontroller(theEvent);
		Site_Survey_Complete_Controller_Ext controller = new Site_Survey_Complete_Controller_Ext(standController);
    	controller.updateEvent();
    	
    	// assert, no contract, so page message
    	system.assertEquals(pageMessageCount, ApexPages.getMessages().size());

    	Test.stopTest();
    } 
  
    
	private static Event createEvent(Opportunity opp) {
		return createEvent(opp, false);
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