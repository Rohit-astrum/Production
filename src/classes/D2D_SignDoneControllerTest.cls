@isTest
private class D2D_SignDoneControllerTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out

	@testSetup static void setupData() {
		D2DTestUtility.InitializeRequiredMethods();
		D2DTestUtility.CreateCustomSettings('sales.coordinator@email.com');
		D2DTestUtility.CreateSalesCoordinatorUser();
		
		D2DTestUtility.CreateManagerUsers(1);
		User d2dMg = D2DTestUtility.d2dManagerUsers[0];

		D2DTestUtility.CreateSalesRepUsers(1);
		User d2dSr = D2DTestUtility.d2dSalesRepUsers[0];

		D2DTestUtility.CreatePortalReferralRequiredObjects(1, 'NY', '36 Panel');
		D2DTestUtility.CreatePortalReferralsWithLeads(1, d2dMg.Id, d2dSr.Id, 'QUALIFIED', 'Credit Approved', '36 Panel', '3', 'ref', 'Joe', '1010 Tenth Way', 'Stony Point', 'NY', '10980', 'Rockland', false);
		//D2DTestUtility.CreateOpportunityWithProposalAndContract(true, false, true, false);
        System_Design_Quote__c sdq = testData.setupSystemDesignQuoteForContract('Residential', 12000);
	}
	
	@isTest static void test_MissingParameter() {
		if(!runalltests){ return; }

		Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
		Portal_Referral__c referral = [SELECT Id, Opportunity__c, Email__c FROM Portal_Referral__c WHERE Opportunity__c = null LIMIT 1];
		referral.Opportunity__c = opp.Id;
		referral.Email__c = 'test@email.com';
		update referral;

		System_Design_Quote__c sdq = [SELECT Id FROM System_Design_Quote__c LIMIT 1];
        Proposal__c proposal = new Proposal__c(System_Design_Quote__c = sdq.Id);
        insert proposal;

        Astrum_Contract__c contract = new Astrum_Contract__c(Proposal__c = proposal.Id, Scenario__c = '1', Closed__c = true, Property_State__c = 'NY');
        insert contract;

		String envelopeId = D2DTestUtility.GenerateGuid();

		PageReference pageRef = Page.D2D_SignDone;
		pageRef.getParameters().put('id', referral.Id);
		pageRef.getParameters().put('cid', contract.Id);
		pageRef.getParameters().put('event', 'OnCancel');
		Test.setCurrentPage(pageRef);

		Test.startTest();

		// Missing Parameters
		Integer pageMessageCount = 0;
		D2D_SignDoneController controller = new D2D_SignDoneController();
		controller.attachAndRedirect();

		System.assertNotEquals(pageMessageCount, ApexPages.getMessages().size());
		Boolean foundText = false;
		for(ApexPages.Message msg : ApexPages.getMessages()){
			if(msg.getSummary().contains('One of the expected parameters was not included')){
				system.debug('**SZ: message = ' + msg.getSummary());
				foundText = true;
				break;
			}
		}
		System.assert(foundText);

		// Wrong event
		pageRef.getParameters().put('envelopeId', envelopeId);

		pageMessageCount = ApexPages.getMessages().size();
		controller = new D2D_SignDoneController();
		controller.attachAndRedirect();

		System.assertEquals(pageMessageCount, ApexPages.getMessages().size());
		System.assertEquals(null, controller.auth);

		Test.stopTest();
	}
	
	@isTest static void test_PerformSignDoneRoutine() {
		if(!runalltests){ return; }

		Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
		Portal_Referral__c referral = [SELECT Id, Opportunity__c, Email__c FROM Portal_Referral__c WHERE Opportunity__c = null LIMIT 1];
		referral.Opportunity__c = opp.Id;
		referral.Email__c = 'test@email.com';
		update referral;

		Test.startTest();

		System_Design_Quote__c sdq = [SELECT Id, Scenario_1_Financing_Type__c, Scenario_1_Commission_Impact_Promotions__c FROM System_Design_Quote__c LIMIT 1];
		sdq.Scenario_1_Commission_Impact_Promotions__c = 0.0;
		sdq.Scenario_1_Financing_Type__c = 'Purchase';
		update sdq;

        Proposal__c proposal = new Proposal__c(System_Design_Quote__c = sdq.Id);
        insert proposal;

        Astrum_Contract__c contract = new Astrum_Contract__c(Proposal__c = proposal.Id, Scenario__c = '1', Closed__c = true, Property_State__c = 'NY');
        insert contract;

		String envelopeId = D2DTestUtility.GenerateGuid();

		PageReference pageRef = Page.D2D_SignDone;
		pageRef.getParameters().put('id', referral.Id);
		pageRef.getParameters().put('cid', contract.Id);
		pageRef.getParameters().put('event', 'OnSigningComplete');
		pageRef.getParameters().put('envelopeId', envelopeId);
		Test.setCurrentPage(pageRef);

		// Missing Parameters
		Integer pageMessageCount = 0;
		D2D_SignDoneController controller = new D2D_SignDoneController();
		controller.attachAndRedirect();

		System.assertEquals(pageMessageCount, ApexPages.getMessages().size());

		List<SCRB_SalesOrder__c> salesOrders = [SELECT Id FROM SCRB_SalesOrder__c WHERE OpportunityId__c = :referral.Opportunity__c LIMIT 1];
		System.assertEquals(1, salesOrders.size());

		Test.stopTest();
	}
}