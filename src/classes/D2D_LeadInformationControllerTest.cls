@isTest
private class D2D_LeadInformationControllerTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out

	@testSetup static void setupData() {
		D2DTestUtility.InitializeRequiredMethods();
		D2DTestUtility.CreateCustomSettings('sales.coordinator@email.com');
		
		D2DTestUtility.CreateManagerUsers(1);
		User d2dMg = D2DTestUtility.d2dManagerUsers[0];

		D2DTestUtility.CreateSalesRepUsers(1);
		User d2dSr = D2DTestUtility.d2dSalesRepUsers[0];

		D2DTestUtility.CreatePortalReferralRequiredObjects(1, 'NY', '24 Panel');
		D2DTestUtility.CreatePortalReferralsWithLeads(1, d2dMg.Id, d2dSr.Id, 'QUALIFIED', 'Prospect New', '', '2', 'ref', 'Joe', '101 Boolean Way', 'Stony Point', 'NY', '10980', 'Rockland', false);
	}

	@isTest static void test_DropDowns() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id, D2D_System_Size__c, Email__c, D2D_Sales_Rep__c FROM Portal_Referral__c LIMIT 1];
		User d2dSr = [SELECT Id FROM User WHERE Id = :referral.D2D_Sales_Rep__c];

		PageReference pageRef = Page.D2D_LeadInformation;
		pageRef.getParameters().put('id', referral.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();

		System.runAs(d2dSr){
			D2D_LeadInformationController controller = new D2D_LeadInformationController();

			// Select a utility company master
			system.assertEquals(17, controller.states.size());
			system.assertEquals(5, controller.timelines.size());
			system.assertEquals(8, controller.salutations.size());
			system.assertEquals(5, controller.bestTimes.size());
			system.assertNotEquals(0, controller.affiliateCommunityPrograms.size());
			system.assertNotEquals(0, controller.getCampaigns().size());
			system.assertEquals(123, controller.counties.size());
			system.assertEquals(3, controller.systemSizes.size());
		}

		Test.stopTest();
	}

	@isTest static void test_EmptyReferral() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id, D2D_System_Size__c, Email__c, D2D_Sales_Rep__c FROM Portal_Referral__c LIMIT 1];
		User d2dSr = [SELECT Id FROM User WHERE Id = :referral.D2D_Sales_Rep__c];

		PageReference pageRef = Page.D2D_LeadInformation;
		pageRef.getParameters().put('id', referral.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();

		System.runAs(d2dSr){

			D2D_LeadInformationController controller = new D2D_LeadInformationController();

			controller.referral.Street__c = '';
	        controller.referral.City__c = '';
	        controller.referral.State__c = '';
	        controller.referral.Zip__c = '';
	        controller.referral.First_Name__c = '';
	        controller.referral.Last_Name__c = '';
	        controller.referral.Email__c = '';
	        controller.referral.Phone__c = '';
	        controller.referral.Work_Phone__c = '';
	        controller.referral.Mobile_Phone__c = '';
	        controller.utilityId = '';
	        controller.homeOwner = '';
	        controller.electricBill = '';
	        controller.affiliateCommunityProgram = '';
	        controller.primarySourceCampaign = '';
		    controller.timeline = '';
		    controller.salutation = '';
		    controller.bestTime = '';

			PageReference returnedRef = controller.submit();
			system.assertNotEquals('', controller.errorMessage.Message);
			system.assert(controller.errorMessage.ErrorFields.contains('Last_Name__c'));
			system.assertEquals(null, returnedRef);
		}

		Test.stopTest();
	}
	
	@isTest static void test_NewLead() {
		if(!runalltests){ return; }
		
		Portal_Referral__c srUserId = [SELECT D2D_Sales_Rep__c FROM Portal_Referral__c LIMIT 1];
		User d2dSr = [SELECT Id FROM User WHERE Id = :srUserId.D2D_Sales_Rep__c];

		PageReference pageRef = Page.D2D_LeadInformation;
		Test.setCurrentPage(pageRef);

		Test.startTest();

		System.runAs(d2dSr){

			D2D_LeadInformationController controller = new D2D_LeadInformationController();
			
			controller.referral = new Portal_Referral__c();
            controller.relatedLead = new Lead();
            
			controller.referral.First_Name__c = 'Bob';
	        controller.referral.Last_Name__c = 'Test';
		    controller.submitAndReload();
		    
			system.assert(controller.errorMessage.Message.contains('An address must be entered to create a new lead.'));
			
			controller.referral.Street__c = '79 Pine Dr';
	        controller.referral.City__c = 'Stony Point';
	        controller.referral.State__c = 'NY';
			controller.newState = 'NY';
	        controller.referral.Zip__c = '10980';
	        controller.referral.QAS_County__c = 'Rockland';
	        controller.utilityId = controller.getUtilities()[controller.getUtilities().size() - 1].getValue();
			controller.referral.D2D_System_Size__c = '24 Panel';
			controller.referral.Email__c = 'referral@email.com';
			controller.referral.Phone__c = '999-999-9999';
	        controller.referral.Work_Phone__c = '';
	        controller.referral.Mobile_Phone__c = '';
			controller.homeOwner = 'Yes';
			controller.electricBill = '350.00';
	        controller.affiliateCommunityProgram = 'D2D Orange & Rockland';
	        controller.primarySourceCampaign = controller.getCampaigns()[controller.getCampaigns().size() - 1].getValue();
	        controller.county = 'Rockland NY';
		    controller.timeline = '';
		    controller.salutation = '';
		    controller.bestTime = '';
		    controller.propertyNotes  = '';
		    controller.referral.Confirmed_Location__Latitude__s = 0;
			controller.referral.Confirmed_Location__Longitude__s = 0;
		    controller.submitAndReload();
		    
			system.assertEquals('', controller.errorMessage.Message);
		}

		Test.stopTest();
	}
	
	@isTest static void test_InvalidAndMissingData() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id, D2D_System_Size__c, Email__c, D2D_Sales_Rep__c FROM Portal_Referral__c LIMIT 1];
		User d2dSr = [SELECT Id FROM User WHERE Id = :referral.D2D_Sales_Rep__c];

		PageReference pageRef = Page.D2D_LeadInformation;
		pageRef.getParameters().put('id', referral.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();

		System.runAs(d2dSr){
			D2D_LeadInformationController controller = new D2D_LeadInformationController();

			// Select a utility company master
			controller.utilityId = controller.getUtilities()[controller.getUtilities().size() - 1].getValue();
			controller.homeOwner = 'XCV';
			controller.electricBill = 'ALPHA';
			controller.subscribe = false;
			PageReference returnedRef = controller.submit();

			system.assertNotEquals('', controller.errorMessage.Message);
			system.assert(controller.errorMessage.ErrorFields.contains('D2D_LeadInformationController.createLead'));
			system.assertEquals(null, returnedRef);

			controller.referral.Phone__c = '999-888-7777';
			controller.validate();

			system.assertNotEquals('', controller.errorMessage.Message);
			system.assert(!controller.errorMessage.ErrorFields.contains('primary'));

			controller.referral.Primary_Phone__c = '';
			controller.referral.Phone__c = '999-888-7777';
			controller.referral.Work_Phone__c = '999-888-7777';
			controller.referral.Mobile_Phone__c = '999-888-7777';
			controller.validate();

			system.assertNotEquals('', controller.errorMessage.Message);
			system.assert(controller.errorMessage.ErrorFields.contains('primary'));

			controller.referral.Primary_Phone__c = 'Home Phone';
			controller.referral.Phone__c = '';
			controller.validate();

			system.debug('**SZ: Message = ' + controller.errorMessage.Message);
			system.debug('**SZ: Fields = ' + controller.errorMessage.ErrorFields);
			system.assertNotEquals('', controller.errorMessage.Message);
			system.assert(controller.errorMessage.ErrorFields.contains('primary'));

			controller.referral.Primary_Phone__c = 'Work Phone';
			controller.referral.Phone__c = '999-888-7777';
			controller.referral.Work_Phone__c = '';
			controller.validate();

			system.assertNotEquals('', controller.errorMessage.Message);
			system.assert(controller.errorMessage.ErrorFields.contains('primary'));

			controller.referral.Primary_Phone__c = 'Mobile Phone';
			controller.referral.Work_Phone__c = '999-888-7777';
			controller.referral.Mobile_Phone__c = '';
			controller.validate();

			system.assertNotEquals('', controller.errorMessage.Message);
			system.assert(controller.errorMessage.ErrorFields.contains('primary'));
		}

		Test.stopTest();
	}
	
	@isTest static void test_SaveAndClose() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id, D2D_System_Size__c, Email__c, D2D_Sales_Rep__c FROM Portal_Referral__c LIMIT 1];
		User d2dSr = [SELECT Id FROM User WHERE Id = :referral.D2D_Sales_Rep__c];

		PageReference pageRef = Page.D2D_LeadInformation;
		pageRef.getParameters().put('id', referral.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();

		System.runAs(d2dSr){
			D2D_LeadInformationController controller = new D2D_LeadInformationController();

			// Select a utility company master
			controller.utilityId = controller.getUtilities()[controller.getUtilities().size() - 1].getValue();
			controller.referral.D2D_System_Size__c = '24 Panel';
			controller.referral.Email__c = 'referral@email.com';
			controller.referral.Phone__c = '999-999-9999';
			controller.homeOwner = 'Yes';
			controller.electricBill = '350.00';
			PageReference returnedRef = controller.submit();

			String expectRef = Page.D2D_SalesRepDashboard.getUrl().substringAfterLast('/').toLowerCase();
			String actualRef = returnedRef.getUrl().substringAfterLast('/').toLowerCase();
			system.assertEquals('', controller.errorMessage.Message);
			system.assertEquals(expectRef, actualRef);
		}

		Test.stopTest();
	}
	
	@isTest static void test_SaveAndReload() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id, D2D_System_Size__c, Email__c, D2D_Sales_Rep__c FROM Portal_Referral__c LIMIT 1];
		User d2dSr = [SELECT Id FROM User WHERE Id = :referral.D2D_Sales_Rep__c];

		PageReference pageRef = Page.D2D_LeadInformation;
		pageRef.getParameters().put('id', referral.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();

		System.runAs(d2dSr){
			D2D_LeadInformationController controller = new D2D_LeadInformationController();

			// Select a utility company master
			controller.utilityId = controller.getUtilities()[controller.getUtilities().size() - 1].getValue();
			controller.referral.D2D_System_Size__c = '24 Panel';
			controller.referral.Email__c = 'referral@email.com';
			controller.referral.Phone__c = '999-999-9999';
			controller.homeOwner = 'Yes';
			controller.electricBill = '350.00';
			PageReference returnedRef = controller.submitAndReload();

			String expectRef = Page.D2D_LeadInformation.getUrl().substringAfterLast('/').toLowerCase();
			String actualRef = returnedRef.getUrl().substringAfterLast('/').substringBeforeLast('?').toLowerCase();
			system.assertEquals('', controller.errorMessage.Message);
			system.assertEquals(expectRef, actualRef);
		}

		Test.stopTest();
	}
	
	@isTest static void test_SaveAndContinue() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id, D2D_System_Size__c, Email__c, D2D_Sales_Rep__c FROM Portal_Referral__c LIMIT 1];
		User d2dSr = [SELECT Id FROM User WHERE Id = :referral.D2D_Sales_Rep__c];

		PageReference pageRef = Page.D2D_LeadInformation;
		pageRef.getParameters().put('id', referral.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();

		System.runAs(d2dSr){
			D2D_LeadInformationController controller = new D2D_LeadInformationController();

			// Select a utility company master
			controller.utilityId = controller.getUtilities()[controller.getUtilities().size() - 1].getValue();
			controller.referral.D2D_System_Size__c = '24 Panel';
			controller.referral.Email__c = 'referral@email.com';
			controller.referral.Phone__c = '999-999-9999';
			controller.homeOwner = 'Yes';
			controller.electricBill = '350.00';
			PageReference returnedRef = controller.submitAndContinue();

			String expectRef = Page.D2D_SolarSavingsGuidePreview.getUrl().substringAfterLast('/').toLowerCase();
			String actualRef = returnedRef.getUrl().substringAfterLast('/').substringBeforeLast('?').toLowerCase();
			system.assertEquals('', controller.errorMessage.Message);
			system.assertEquals(expectRef, actualRef);
		}

		Test.stopTest();
	}
	
	@isTest static void test_SSG() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id, D2D_System_Size__c, Email__c, D2D_Sales_Rep__c FROM Portal_Referral__c LIMIT 1];
		User d2dSr = [SELECT Id FROM User WHERE Id = :referral.D2D_Sales_Rep__c];

		PageReference pageRef = Page.D2D_LeadInformation;
		pageRef.getParameters().put('id', referral.Id);
		Test.setCurrentPage(pageRef);
		
		Test.startTest();

		System.runAs(d2dSr){
			D2D_LeadInformationController controller = new D2D_LeadInformationController();

			system.assertEquals('', controller.ssgWarningText);

			// Select a utility company master
			controller.utilityId = controller.getUtilities()[controller.getUtilities().size() - 1].getValue();
			controller.referral.D2D_System_Size__c = '24 Panel';
			controller.referral.Email__c = 'referral@email.com';
			controller.referral.Phone__c = '999-999-9999';
			controller.homeOwner = 'Yes';
			controller.electricBill = '350.00';
			controller.validate();

			system.assert(controller.ssgWarningText.contains('Contact an administrator.'));
			PageReference returnedRef = controller.submitAndReload();

			String expectRef = Page.D2D_LeadInformation.getUrl().substringAfterLast('/').toLowerCase();
			String actualRef = returnedRef.getUrl().substringAfterLast('/').substringBeforeLast('?').toLowerCase();
			system.assertEquals('', controller.errorMessage.Message);
			system.assertEquals(expectRef, actualRef);

			controller = new D2D_LeadInformationController();
			system.assertEquals('', controller.ssgWarningText);

			controller.referral.D2D_Lead_Status__c = 'Test';
			system.assert(controller.ssgWarningText.contains('Save the lead to validate.'));

			controller.referral.SSG_Accepted__c = 'True';
			system.assert(controller.ssgWarningText.contains('already accepted'));

			controller.referral.SSG_Accepted__c = 'False';
			controller.relatedLead.County__c = null;
			system.assert(controller.ssgWarningText.contains('Address validation is not yet complete.'));
		}

		Test.stopTest();
	}
}