@isTest
private class D2D_ContractUploadControllerTest {
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

	@isTest static void test_InvalidStatus() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id FROM Portal_Referral__c WHERE Opportunity__c = null LIMIT 1];

		Test.startTest();

		PageReference pageRef = Page.D2D_ContractUpload;
		pageRef.getParameters().put('id', referral.Id);
		Test.setCurrentPage(pageRef);

		// Missing Parameters
		D2D_ContractUploadController controller = new D2D_ContractUploadController();
		System.assertNotEquals(0, ApexPages.getMessages().size());
		Boolean foundText = false;
		for(ApexPages.Message msg : ApexPages.getMessages()){
			if(msg.getSummary().contains('You have reached this page in error')){
				system.debug('**SZ: message = ' + msg.getSummary());
				foundText = true;
				break;
			}
		}
		System.assert(foundText);

		Test.stopTest();
	}

	@isTest static void test_InvalidOpportunity() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id, Opportunity__c, Email__c, D2D_Lead_Status__c FROM Portal_Referral__c WHERE Opportunity__c = null LIMIT 1];
		referral.Email__c = 'test@email.com';
		referral.D2D_Lead_Status__c = 'Signing In Process';
		update referral;

		Test.startTest();

		PageReference pageRef = Page.D2D_ContractUpload;
		pageRef.getParameters().put('id', referral.Id);
		Test.setCurrentPage(pageRef);

		// Missing Parameters
		D2D_ContractUploadController controller = new D2D_ContractUploadController();
		controller.upload();
		System.assertNotEquals(0, ApexPages.getMessages().size());
		Boolean foundText = false;
		for(ApexPages.Message msg : ApexPages.getMessages()){
			if(msg.getSummary().contains('This record must have an opportunity before uploading a file')){
				system.debug('**SZ: message = ' + msg.getSummary());
				foundText = true;
				break;
			}
		}
		System.assert(foundText);

		Test.stopTest();
	}

	@isTest static void test_InvalidContract() {
		if(!runalltests){ return; }

		Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
		Portal_Referral__c referral = [SELECT Id, Opportunity__c, Email__c, D2D_Lead_Status__c FROM Portal_Referral__c WHERE Opportunity__c = null LIMIT 1];
		referral.Opportunity__c = opp.Id;
		referral.Email__c = 'test@email.com';
		referral.D2D_Lead_Status__c = 'Signing In Process';
		update referral;

		Test.startTest();

		PageReference pageRef = Page.D2D_ContractUpload;
		pageRef.getParameters().put('id', referral.Id);
		Test.setCurrentPage(pageRef);

		// Missing Parameters
		D2D_ContractUploadController controller = new D2D_ContractUploadController();
		controller.upload();
		System.assertNotEquals(0, ApexPages.getMessages().size());
		Boolean foundText = false;
		for(ApexPages.Message msg : ApexPages.getMessages()){
			if(msg.getSummary().contains('Contract for Property__c:')){
				system.debug('**SZ: message = ' + msg.getSummary());
				foundText = true;
				break;
			}
		}
		System.assert(foundText);

		Test.stopTest();
	}

	@isTest static void test_InvalidUploadFile() {
		if(!runalltests){ return; }

		Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
		Portal_Referral__c referral = [SELECT Id, Opportunity__c, Email__c, D2D_Lead_Status__c FROM Portal_Referral__c WHERE Opportunity__c = null LIMIT 1];
		referral.Opportunity__c = opp.Id;
		referral.Email__c = 'test@email.com';
		referral.D2D_Lead_Status__c = 'Signing In Process';
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

		PageReference pageRef = Page.D2D_ContractUpload;
		pageRef.getParameters().put('id', referral.Id);
		Test.setCurrentPage(pageRef);

		// Missing Parameters
		D2D_ContractUploadController controller = new D2D_ContractUploadController();
		controller.uploadFile = null;
		controller.upload();
		System.assertNotEquals(0, ApexPages.getMessages().size());
		Boolean foundText = false;
		for(ApexPages.Message msg : ApexPages.getMessages()){
			if(msg.getSummary().contains('The upload file cannot be null')){
				system.debug('**SZ: message = ' + msg.getSummary());
				foundText = true;
				break;
			}
		}
		System.assert(foundText);

		Test.stopTest();
	}

	@isTest static void test_UploadAndClose() {
		if(!runalltests){ return; }

		Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
		Portal_Referral__c referral = [SELECT Id, Opportunity__c, Email__c, D2D_Lead_Status__c FROM Portal_Referral__c WHERE Opportunity__c = null LIMIT 1];
		referral.Opportunity__c = opp.Id;
		referral.Email__c = 'test@email.com';
		referral.D2D_Lead_Status__c = 'Signing In Process';
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

		PageReference pageRef = Page.D2D_ContractUpload;
		pageRef.getParameters().put('id', referral.Id);
		Test.setCurrentPage(pageRef);

		// Missing Parameters
		Integer pageMessageCount = 0;
		D2D_ContractUploadController controller = new D2D_ContractUploadController();
		controller.uploadFile.Body = Blob.valueOf('Sample Attachment');
		controller.upload();

		System.assertEquals(pageMessageCount, ApexPages.getMessages().size());

		List<SCRB_SalesOrder__c> salesOrders = [SELECT Id FROM SCRB_SalesOrder__c WHERE OpportunityId__c = :referral.Opportunity__c LIMIT 1];
		System.assertEquals(1, salesOrders.size());

		Test.stopTest();
	}
}