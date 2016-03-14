@isTest
private class D2D_SolarSavingsGuidePreviewCtrlrTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out

	@testSetup static void setupData() {
		D2DTestUtility.InitializeRequiredMethods();
		D2DTestUtility.CreateCustomSettings('sales.coordinator@email.com');
		
		D2DTestUtility.CreateManagerUsers(1);
		User d2dMg = D2DTestUtility.d2dManagerUsers[0];

		D2DTestUtility.CreateSalesRepUsers(1);
		User d2dSr = D2DTestUtility.d2dSalesRepUsers[0];

		D2DTestUtility.CreatePortalReferralRequiredObjects(1, 'NY', '24 Panel');
		D2DTestUtility.CreatePortalReferralsWithLeads(1, d2dMg.Id, d2dSr.Id, 'QUALIFIED', 'Prospect New', '24 Panel', '2', 'ref', 'Joe', '101 Boolean Way', 'Stony Point', 'NY', '10980', '', false);
	}

	@isTest static void test_InvalidData() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id, D2D_Sales_Rep__c, Lead__c, D2D_System_Size__c, Email__c FROM Portal_Referral__c LIMIT 1];
		Lead lead = [SELECT Id, Utility_Company_Master__c, County__c FROM Lead WHERE Id = :referral.Lead__c];
		Utility_Company_Master__c ucm = [SELECT Id FROM Utility_Company_Master__c LIMIT 1];
		User d2dSr = [SELECT Id FROM User WHERE Id = :referral.D2D_Sales_Rep__c];

		PageReference pageRef = Page.D2D_SolarSavingsGuidePreview;
		pageRef.getParameters().put('id', referral.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();

		Boolean hasExpectedMessage = false;
		System.runAs(d2dSr){
			D2D_SolarSavingsGuidePreviewController controller = new D2D_SolarSavingsGuidePreviewController();

			ApexPages.Message[] pageMessages = ApexPages.getMessages();
			for(ApexPages.Message message : pageMessages){
				system.debug('**SZ: message = ' + message.getSeverity() + '; ' + message.getSummary());
				if(message.getSummary().contains('county specified')){
					hasExpectedMessage = true;
					break;
				}
			}
			system.assert(hasExpectedMessage);
		}

		hasExpectedMessage = false;
		lead.County__c = 'Rockland NY';
		update lead;

		System.runAs(d2dSr){
			pageRef = null;
			pageRef = Page.D2D_SolarSavingsGuidePreview;
			pageRef.getParameters().put('id', referral.Id);
			Test.setCurrentPage(pageRef);

			D2D_SolarSavingsGuidePreviewController controller = new D2D_SolarSavingsGuidePreviewController();

			ApexPages.Message[] pageMessages = ApexPages.getMessages();
			for(ApexPages.Message message : pageMessages){
				system.debug('**SZ: message = ' + message.getSeverity() + '; ' + message.getSummary());
				if(message.getSummary().contains('Guide was not found')){
					hasExpectedMessage = true;
					break;
				}
			}
			system.assert(hasExpectedMessage);
		}

		hasExpectedMessage = false;
		lead.Utility_Company_Master__c = ucm.Id;
		update lead;

		System.runAs(d2dSr){
			pageRef = null;
			pageRef = Page.D2D_SolarSavingsGuidePreview;
			pageRef.getParameters().put('id', referral.Id);
			Test.setCurrentPage(pageRef);

			D2D_SolarSavingsGuidePreviewController controller = new D2D_SolarSavingsGuidePreviewController();

			ApexPages.Message[] pageMessages = ApexPages.getMessages();
			for(ApexPages.Message message : pageMessages){
				system.debug('**SZ: message = ' + message.getSeverity() + '; ' + message.getSummary());
				if(message.getSummary().contains('did not contain an attachment')){
					hasExpectedMessage = true;
					break;
				}
			}
			system.assert(hasExpectedMessage);
		}

		Test.stopTest();
	}

	@isTest static void test_AcceptSSG() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id, D2D_Sales_Rep__c, Lead__c, D2D_System_Size__c, Email__c FROM Portal_Referral__c LIMIT 1];
		Lead lead = [SELECT Id, Utility_Company_Master__c, County__C FROM Lead WHERE Id = :referral.Lead__c];
		User d2dSr = [SELECT Id FROM User WHERE Id = :referral.D2D_Sales_Rep__c];
		Utility_Company_Master__c utilityCompanyMaster = [SELECT Id FROM Utility_Company_Master__c LIMIT 1];
		D2D_Proposal__c d2dProposal = [SELECT Id FROM D2D_Proposal__c LIMIT 1];
		System_Designers_Assignment__c assignment = [SELECT USer__c FROM System_Designers_Assignment__c LIMIT 1];

		lead.County__c = 'Rockland NY';
		lead.Utility_Company_Master__c = utilityCompanyMaster.Id;
		update lead;

        Attachment att = new Attachment(
	        Name = 'sampleSSG.pdf',
	        Body = Blob.valueOf('Sample SSG Attachment'),
	        ContentType = 'application/pdf',
	        ParentId = d2dProposal.Id
    	);
        insert att;

		PageReference pageRef = Page.D2D_SolarSavingsGuidePreview;
		pageRef.getParameters().put('id', referral.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();

		System.runAs(d2dSr){
			D2D_SolarSavingsGuidePreviewController controller = new D2D_SolarSavingsGuidePreviewController();
			PageReference pr = controller.ssgAccepted();
			system.debug('**SZ: pr = ' + pr);
			ApexPages.Message[] pageMessages = ApexPages.getMessages();
			for(ApexPages.Message message : pageMessages){
				system.debug('**SZ: message = ' + message.getSeverity() + '; ' + message.getSummary());
			}
		}

		Test.stopTest();

		referral = [SELECT Id, Lead__c, Opportunity__c, SSG_Accepted__c, D2D_Lead_Status__c FROM Portal_Referral__c LIMIT 1];
		lead = [SELECT Id, Status, IsConverted FROM Lead WHERE Id = :referral.Lead__c LIMIT 1];
		Opportunity opp = [SELECT Id, Property__c FROM Opportunity LIMIT 1];
		Property__c prop = [SELECT Id FROM Property__c WHERE Id = :opp.Property__c LIMIT 1];
		Event ssEvent = [SELECT Id, OwnerId FROM Event WHERE WhatId = :opp.Id LIMIT 1];
		system.debug('**SZ: referral = ' + referral);
		system.debug('**SZ: lead = ' + lead);
		system.debug('**SZ: opp = ' + opp);
		system.debug('**SZ: prop = ' + prop);
		system.debug('**SZ: ssEvent = ' + ssEvent);

		system.assertEquals('True', referral.SSG_Accepted__c);
		system.assertEquals('Customer Opt-In', referral.D2D_Lead_Status__c);

		system.assert(lead.IsConverted);
		system.assert(lead.Status.contains('Qualified'));

		system.assertNotEquals(null, opp);
		system.assertNotEquals(null, prop);
		system.assertNotEquals(null, ssEvent);
		system.assertEquals(assignment.USer__c, ssEvent.OwnerId);
	}
}