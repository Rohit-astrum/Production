@isTest
private class D2D_ProposalPreviewControllerTest {
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

		D2DTestUtility.CreatePortalReferralRequiredObjects(1, 'NY', '24 Panel');
		D2DTestUtility.CreatePortalReferralsWithLeads(1, d2dMg.Id, d2dSr.Id, 'SOLD', 'Sold', '36 Panel', '3', 'ref', 'Joe', '10101 Boolean Way', 'Stony Point', 'NY', '10980', 'Rockland', false);
		D2DTestUtility.CreatePortalReferralsWithLeads(1, d2dMg.Id, d2dSr.Id, 'SOLD', 'Sold', '36 Panel', '3', 'ref', 'Joe', '1010 Tenth Way', 'Stony Point', 'NY', '10980', 'Rockland', false);
		D2DTestUtility.CreateOpportunityWithProposalAndContract(false, false, false, false);
	}
	
	@isTest static void test_NoOpportunity() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id FROM Portal_Referral__c WHERE Opportunity__c = null LIMIT 1];

		PageReference pageRef = Page.D2D_ProposalPreview;
		pageRef.getParameters().put('id', referral.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();

		Integer pageMessageCount = 0;
		D2D_ProposalPreviewController controller = new D2D_ProposalPreviewController();

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
	
	@isTest static void test_NoProposal() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id FROM Portal_Referral__c WHERE Opportunity__c != null LIMIT 1];

		PageReference pageRef = Page.D2D_ProposalPreview;
		pageRef.getParameters().put('id', referral.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();

		Integer pageMessageCount = 0;
		D2D_ProposalPreviewController controller = new D2D_ProposalPreviewController();

		System.assertNotEquals(pageMessageCount, ApexPages.getMessages().size());
		Boolean foundText = false;
		for(ApexPages.Message msg : ApexPages.getMessages()){
			if(msg.getSummary().contains('Proposal for Property__c')){
				system.debug('**SZ: message = ' + msg.getSummary());
				foundText = true;
				break;
			}
		}
		System.assert(foundText);

		Test.stopTest();
	}
	
	@isTest static void test_NoAttachment() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id FROM Portal_Referral__c WHERE Opportunity__c != null LIMIT 1];

		Opportunity opp = [SELECT Id, System_Design_Quote__c FROM Opportunity LIMIT 1];
    	Proposal__c proposal = new Proposal__c(System_Design_Quote__c = opp.System_Design_Quote__c, Current__c = true);
    	insert proposal;

		PageReference pageRef = Page.D2D_ProposalPreview;
		pageRef.getParameters().put('id', referral.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();

		Integer pageMessageCount = 0;
		D2D_ProposalPreviewController controller = new D2D_ProposalPreviewController();

		System.assertNotEquals(pageMessageCount, ApexPages.getMessages().size());
		Boolean foundText = false;
		for(ApexPages.Message msg : ApexPages.getMessages()){
			if(msg.getSummary().contains('No proposal pdf file')){
				system.debug('**SZ: message = ' + msg.getSummary());
				foundText = true;
				break;
			}
		}
		System.assert(foundText);

		Test.stopTest();
	}
	
	@isTest static void test_Success() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id FROM Portal_Referral__c WHERE Opportunity__c != null LIMIT 1];

		Opportunity opp = [SELECT Id, System_Design_Quote__c FROM Opportunity LIMIT 1];
    	Proposal__c proposal = new Proposal__c(System_Design_Quote__c = opp.System_Design_Quote__c, Current__c = true);
    	insert proposal;

    	D2DTestUtility.CreateProposalAttachment(proposal.Id);

		PageReference pageRef = Page.D2D_ProposalPreview;
		pageRef.getParameters().put('id', referral.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();

		Integer pageMessageCount = 0;
		D2D_ProposalPreviewController controller = new D2D_ProposalPreviewController();

		System.assertEquals(pageMessageCount, ApexPages.getMessages().size());

		System.assertEquals('false', controller.getRenderPdfAsHtml());

		Test.stopTest();
	}
}