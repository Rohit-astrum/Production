@isTest
private class D2D_ContractPreviewControllerTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out

	@testSetup static void setupData() {
		testData.setupCustomSettings();
		D2DTestUtility.InitializeRequiredMethods();
		D2DTestUtility.CreateCustomSettings('sales.coordinator@email.com');
		D2DTestUtility.CreateSalesCoordinatorUser();
		
		D2DTestUtility.CreateManagerUsers(1);
		User d2dMg = D2DTestUtility.d2dManagerUsers[0];

		D2DTestUtility.CreateSalesRepUsers(1);
		User d2dSr = D2DTestUtility.d2dSalesRepUsers[0];

		D2DTestUtility.CreatePortalReferralRequiredObjects(1, 'NY', '36 Panel');
		D2DTestUtility.CreatePortalReferralsWithLeads(1, d2dMg.Id, d2dSr.Id, 'QUALIFIED', 'Credit Approved', '36 Panel', '3', 'ref', 'Joe', '10101 Boolean Way', 'Stony Point', 'NY', '10980', 'Rockland', false);
		D2DTestUtility.CreatePortalReferralsWithLeads(1, d2dMg.Id, d2dSr.Id, 'QUALIFIED', 'Credit Approved', '36 Panel', '3', 'ref', 'Joe', '1010 Tenth Way', 'Stony Point', 'NY', '10980', 'Rockland', false);
		D2DTestUtility.CreateOpportunityWithProposalAndContract(true, false, false, false);
	}
	
	@isTest static void test_NoOpportunity() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id FROM Portal_Referral__c WHERE Opportunity__c = null LIMIT 1];

		PageReference pageRef = Page.D2D_ContractPreview;
		pageRef.getParameters().put('id', referral.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();

		// No Opportunity
		Integer pageMessageCount = 0;
		D2D_ContractPreviewController controller = new D2D_ContractPreviewController();

		System.assertNotEquals(pageMessageCount, ApexPages.getMessages().size());
		Boolean foundText = false;
		for(ApexPages.Message msg : ApexPages.getMessages()){
			if(msg.getSummary().contains('referral does not have a related opportunity')){
				system.debug('**SZ: message = ' + msg.getSummary());
				foundText = true;
				break;
			}
		}
		System.assert(foundText);

		Test.stopTest();
	}
	
	@isTest static void test_ContractExceptions() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id FROM Portal_Referral__c WHERE Opportunity__c != null LIMIT 1];

		PageReference pageRef = Page.D2D_ContractPreview;
		pageRef.getParameters().put('id', referral.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();

		// No Contract
		Integer pageMessageCount = 0;
		D2D_ContractPreviewController controller = new D2D_ContractPreviewController();

		System.assertNotEquals(pageMessageCount, ApexPages.getMessages().size());
		Boolean foundText = false;
		for(ApexPages.Message msg : ApexPages.getMessages()){
			if(msg.getSummary().contains('Contract for Property__c')){
				system.debug('**SZ: message = ' + msg.getSummary());
				foundText = true;
				break;
			}
		}
		System.assert(foundText);

		// Contract without Attachment
		Proposal__c proposal = [SELECT Id FROM Proposal__c LIMIT 1];
    	Astrum_Contract__c contract = new Astrum_Contract__c(Proposal__c = proposal.Id);
    	insert contract;

		pageMessageCount = 0;
		controller = new D2D_ContractPreviewController();

		System.assertNotEquals(pageMessageCount, ApexPages.getMessages().size());
		foundText = false;
		for(ApexPages.Message msg : ApexPages.getMessages()){
			if(msg.getSummary().contains('No contract pdf file exists')){
				system.debug('**SZ: message = ' + msg.getSummary());
				foundText = true;
				break;
			}
		}
		System.assert(foundText);

		Test.stopTest();
	}
	
	@isTest static void test_ContractWithAttachment() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id FROM Portal_Referral__c WHERE Opportunity__c != null LIMIT 1];

		PageReference pageRef = Page.D2D_ContractPreview;
		pageRef.getParameters().put('id', referral.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();

		Proposal__c proposal = [SELECT Id FROM Proposal__c LIMIT 1];
    	Astrum_Contract__c contract = new Astrum_Contract__c(Proposal__c = proposal.Id);
    	insert contract;

    	D2DTestUtility.CreateContractAttachment(contract.Id);

		Integer pageMessageCount = 0;
		D2D_ContractPreviewController controller = new D2D_ContractPreviewController();

		System.assertEquals(pageMessageCount, ApexPages.getMessages().size());

		System.assertEquals('false', controller.getRenderPdfAsHtml());

		Test.stopTest();
	}
	
	@isTest static void test_SalesOrderExceptions() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id, D2D_Lead_Status__c, Opportunity__c FROM Portal_Referral__c WHERE Opportunity__c != null LIMIT 1];
		referral.D2D_Lead_Status__c = 'Sold';
		update referral;

		Proposal__c proposal = [SELECT Id FROM Proposal__c LIMIT 1];
    	Astrum_Contract__c contract = new Astrum_Contract__c(Proposal__c = proposal.Id);
    	insert contract;

		PageReference pageRef = Page.D2D_ContractPreview;
		pageRef.getParameters().put('id', referral.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();

		// No Sales Order
		Integer pageMessageCount = 0;
		D2D_ContractPreviewController controller = new D2D_ContractPreviewController();

		System.assertNotEquals(pageMessageCount, ApexPages.getMessages().size());
		Boolean foundText = false;
		for(ApexPages.Message msg : ApexPages.getMessages()){
			if(msg.getSummary().contains('Sales Order for Opportunity')){
				system.debug('**SZ: message = ' + msg.getSummary());
				foundText = true;
				break;
			}
		}
		System.assert(foundText);

		// Sales order without attachment
		SCRB_SalesOrder__c salesOrder = new SCRB_SalesOrder__c(OpportunityId__c = referral.Opportunity__c);
		insert salesOrder;

		pageMessageCount = ApexPages.getMessages().size();
		controller = new D2D_ContractPreviewController();

		System.assertNotEquals(pageMessageCount, ApexPages.getMessages().size());
		foundText = false;
		for(ApexPages.Message msg : ApexPages.getMessages()){
			if(msg.getSummary().contains('No signed contract pdf file exists')){
				system.debug('**SZ: message = ' + msg.getSummary());
				foundText = true;
				break;
			}
		}
		System.assert(foundText);

		Test.stopTest();
	}
	
	@isTest static void test_SalesOrderWithAttachment() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id, D2D_Lead_Status__c, Opportunity__c FROM Portal_Referral__c WHERE Opportunity__c != null LIMIT 1];
		referral.D2D_Lead_Status__c = 'Sold';
		update referral;

		Proposal__c proposal = [SELECT Id FROM Proposal__c LIMIT 1];
    	Astrum_Contract__c contract = new Astrum_Contract__c(Proposal__c = proposal.Id);
    	insert contract;

		SCRB_SalesOrder__c salesOrder = new SCRB_SalesOrder__c(OpportunityId__c = referral.Opportunity__c);
		insert salesOrder;

		D2DTestUtility.CreateSalesOrderAttachment(salesorder.Id);

		PageReference pageRef = Page.D2D_ContractPreview;
		pageRef.getParameters().put('id', referral.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();

		Integer pageMessageCount = 0;
		D2D_ContractPreviewController controller = new D2D_ContractPreviewController();

		System.assertEquals(pageMessageCount, ApexPages.getMessages().size());

		Test.stopTest();
	}

	@isTest static void test_SendForSigning() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id FROM Portal_Referral__c WHERE Opportunity__c != null LIMIT 1];

		Proposal__c proposal = [SELECT Id FROM Proposal__c LIMIT 1];
    	Astrum_Contract__c contract = new Astrum_Contract__c(Proposal__c = proposal.Id);
    	insert contract;

    	D2DTestUtility.CreateContractAttachment(contract.Id);

		PageReference pageRef = Page.D2D_ContractPreview;
		pageRef.getParameters().put('id', referral.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();

		D2D_ContractPreviewController controller = new D2D_ContractPreviewController();
		controller.DoSignAndEmail();

		system.debug('**SZ: embeddedUrl = ' + controller.embeddedUrl);
		system.assertEquals('http://mock.docusign.token/response/url', controller.embeddedUrl);

		Test.stopTest();
	}
}