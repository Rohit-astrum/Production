@isTest
private class D2D_OptOutControllerTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out

	@testSetup static void setupData() {
		D2DTestUtility.InitializeRequiredMethods();
		D2DTestUtility.CreateCustomSettings('sales.coordinator@email.com');
		
		D2DTestUtility.CreateManagerUsers(1);
		User d2dMg = D2DTestUtility.d2dManagerUsers[0];

		D2DTestUtility.CreateSalesRepUsers(1);
		User d2dSr = D2DTestUtility.d2dSalesRepUsers[0];

		D2DTestUtility.CreatePortalReferralRequiredObjects(1, 'NY', '24 Panel');
		D2DTestUtility.CreatePortalReferralsWithLeads(1, d2dMg.Id, d2dSr.Id, 'QUALIFIED', 'Prospect New', '24 Panel', '2', 'ref', 'Joe', '101 Boolean Way', 'Stony Point', 'NY', '10980', 'Rockland', false);
	}
	
	@isTest static void test_OptOut_NoSelection() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id, D2D_Sales_Rep__c FROM Portal_Referral__c LIMIT 1];
		User d2dSr = [SELECT Id FROM User WHERE Id = :referral.D2D_Sales_Rep__c];

		PageReference pageRef = Page.D2D_OptOut;
		pageRef.getParameters().put('id', referral.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();

		System.runAs(d2dSr){
			D2D_OptOutController controller = new D2D_OptOutController();
			controller.optOutSubmit();
		}

		Test.stopTest();

		system.assertNotEquals(0, ApexPages.getMessages().size());
	}
	
	@isTest static void test_OptOut_NI() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id, D2D_Sales_Rep__c FROM Portal_Referral__c LIMIT 1];
		User d2dSr = [SELECT Id FROM User WHERE Id = :referral.D2D_Sales_Rep__c];

		PageReference pageRef = Page.D2D_OptOut;
		pageRef.getParameters().put('id', referral.Id);
		pageRef.getParameters().put('optOutReason', 'NI');
		Test.setCurrentPage(pageRef);

		Test.startTest();

		System.runAs(d2dSr){
			D2D_OptOutController controller = new D2D_OptOutController();
			controller.optOutSubmit();
		}

		Test.stopTest();

		referral = [SELECT D2D_Lead_Status__c, D2D_Opt_Out_Detail__c, D2D_Lead_Status_At_Opt_Out__c FROM Portal_Referral__c LIMIT 1];
		Lead lead = [SELECT Id, OwnerId, Status, Unqualified_Reason__c, DoNotCall, HasOptedOutOfEmail, HasOptedOutOfFax, Global_Opt_Out__c, Do_Not_Solicit__c, Do_Not_Mail__c, Do_Not_Text__c FROM Lead LIMIT 1];

		system.assertEquals('Prospect New', referral.D2D_Lead_Status_At_Opt_Out__c);
		system.assertEquals('Customer Opt-Out', referral.D2D_Lead_Status__c);
		system.assertEquals('NI', referral.D2D_Opt_Out_Detail__c);

		system.assertEquals('Prospect Unqualified', lead.Status);
		system.assertEquals('Not Interested in solar', lead.Unqualified_Reason__c);
	}
	
	@isTest static void test_OptOut_NN_NP() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id, D2D_Sales_Rep__c FROM Portal_Referral__c LIMIT 1];
		User d2dSr = [SELECT Id FROM User WHERE Id = :referral.D2D_Sales_Rep__c];
		Group insideSalesQueue = [SELECT Id, Name FROM Group WHERE DeveloperName = 'InsideSalesQueue' LIMIT 1];

		PageReference pageRef = Page.D2D_OptOut;
		pageRef.getParameters().put('id', referral.Id);
		pageRef.getParameters().put('optOutReason', 'NN');
		Test.setCurrentPage(pageRef);

		Test.startTest();

		System.runAs(d2dSr){
			D2D_OptOutController controller = new D2D_OptOutController();
			controller.optOutSubmit();
		}

		Test.stopTest();

		referral = [SELECT D2D_Lead_Status__c, D2D_Opt_Out_Detail__c, D2D_Lead_Status_At_Opt_Out__c FROM Portal_Referral__c LIMIT 1];
		Lead lead = [SELECT Id, OwnerId, Status, Unqualified_Reason__c, DoNotCall, HasOptedOutOfEmail, HasOptedOutOfFax, Global_Opt_Out__c, Do_Not_Solicit__c, Do_Not_Mail__c, Do_Not_Text__c FROM Lead LIMIT 1];

		system.assertEquals('Prospect New', referral.D2D_Lead_Status_At_Opt_Out__c);
		system.assertEquals('Customer Opt-Out', referral.D2D_Lead_Status__c);
		system.assertEquals('NN', referral.D2D_Opt_Out_Detail__c);

		system.assertEquals('Prospect Contacted', lead.Status);
		system.assertEquals(insideSalesQueue.Id, lead.OwnerId);
	}
	
	@isTest static void test_OptOut_NS() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id, D2D_Sales_Rep__c FROM Portal_Referral__c LIMIT 1];
		User d2dSr = [SELECT Id FROM User WHERE Id = :referral.D2D_Sales_Rep__c];

		PageReference pageRef = Page.D2D_OptOut;
		pageRef.getParameters().put('id', referral.Id);
		pageRef.getParameters().put('optOutReason', 'NS');
		Test.setCurrentPage(pageRef);

		Test.startTest();

		System.runAs(d2dSr){
			D2D_OptOutController controller = new D2D_OptOutController();
			controller.optOutSubmit();
		}

		Test.stopTest();

		referral = [SELECT D2D_Lead_Status__c, D2D_Opt_Out_Detail__c, D2D_Lead_Status_At_Opt_Out__c FROM Portal_Referral__c LIMIT 1];
		Lead lead = [SELECT Id, OwnerId, Status, Unqualified_Reason__c, DoNotCall, HasOptedOutOfEmail, HasOptedOutOfFax, Global_Opt_Out__c, Do_Not_Solicit__c, Do_Not_Mail__c, Do_Not_Text__c FROM Lead LIMIT 1];

		system.assertEquals('Prospect New', referral.D2D_Lead_Status_At_Opt_Out__c);
		system.assertEquals('Customer Opt-Out', referral.D2D_Lead_Status__c);
		system.assertEquals('NS', referral.D2D_Opt_Out_Detail__c);

		system.assertEquals('Prospect Contacted', lead.Status);
		system.assert(lead.Do_Not_Solicit__c);
	}
	
	@isTest static void test_OptOut_GO() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id, D2D_Sales_Rep__c FROM Portal_Referral__c LIMIT 1];
		User d2dSr = [SELECT Id FROM User WHERE Id = :referral.D2D_Sales_Rep__c];
		Group insideSalesQueue = [SELECT Id, Name FROM Group WHERE DeveloperName = 'InsideSalesQueue' LIMIT 1];

		PageReference pageRef = Page.D2D_OptOut;
		pageRef.getParameters().put('id', referral.Id);
		pageRef.getParameters().put('optOutReason', 'GO');
		Test.setCurrentPage(pageRef);

		Test.startTest();

		System.runAs(d2dSr){
			D2D_OptOutController controller = new D2D_OptOutController();
			controller.optOutSubmit();
		}

		Test.stopTest();

		referral = [SELECT D2D_Lead_Status__c, D2D_Opt_Out_Detail__c, D2D_Lead_Status_At_Opt_Out__c FROM Portal_Referral__c LIMIT 1];
		Lead lead = [SELECT Id, OwnerId, Status, Unqualified_Reason__c, DoNotCall, HasOptedOutOfEmail, HasOptedOutOfFax, Global_Opt_Out__c, Do_Not_Solicit__c, Do_Not_Mail__c, Do_Not_Text__c FROM Lead LIMIT 1];

		system.assertEquals('Prospect New', referral.D2D_Lead_Status_At_Opt_Out__c);
		system.assertEquals('Customer Opt-Out', referral.D2D_Lead_Status__c);
		system.assertEquals('GO', referral.D2D_Opt_Out_Detail__c);

		system.assertEquals('Prospect Unqualified', lead.Status);
		system.assertEquals('Not Interested in solar', lead.Unqualified_Reason__c);
		system.assert(lead.Global_Opt_Out__c);
	}
	
	@isTest static void test_OptOut_IN() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id, D2D_Sales_Rep__c, D2D_Lead_Status__c, D2D_Opt_Out_Detail__c, D2D_Lead_Status_At_Opt_Out__c FROM Portal_Referral__c LIMIT 1];
		User d2dSr = [SELECT Id FROM User WHERE Id = :referral.D2D_Sales_Rep__c];
        Group webLeadQueue = [SELECT Id, Name FROM Group WHERE DeveloperName = 'WebLeadQueue' LIMIT 1];
		Group insideSalesQueue = [SELECT Id, Name FROM Group WHERE DeveloperName = 'InsideSalesQueue' LIMIT 1];

		referral.D2D_Lead_Status__c = 'Customer Opt-Out';
		referral.D2D_Lead_Status_At_Opt_Out__c = 'Prospect New';
		referral.D2D_Opt_Out_Detail__c = 'GO';
		update referral;

		Lead lead = [SELECT Id, OwnerId, Status, Unqualified_Reason__c, DoNotCall, HasOptedOutOfEmail, HasOptedOutOfFax, Global_Opt_Out__c, Do_Not_Solicit__c, Do_Not_Mail__c, Do_Not_Text__c FROM Lead LIMIT 1];
		lead.OwnerId = insideSalesQueue.Id;
		lead.Global_Opt_Out__c = true;
		lead.Status = 'Prospect Unqualified';
		lead.Unqualified_Reason__c = 'Not Interested in solar';
		update lead;

		PageReference pageRef = Page.D2D_OptOut;
		pageRef.getParameters().put('id', referral.Id);
		pageRef.getParameters().put('optOutReason', 'IN');
		Test.setCurrentPage(pageRef);

		Test.startTest();

		System.runAs(d2dSr){
			D2D_OptOutController controller = new D2D_OptOutController();
			controller.optOutSubmit();
		}

		Test.stopTest();

		referral = [SELECT D2D_Lead_Status__c, D2D_Opt_Out_Detail__c, D2D_Lead_Status_At_Opt_Out__c FROM Portal_Referral__c LIMIT 1];
		lead = [SELECT Id, OwnerId, Status, Unqualified_Reason__c, DoNotCall, HasOptedOutOfEmail, HasOptedOutOfFax, Global_Opt_Out__c, Do_Not_Solicit__c, Do_Not_Mail__c, Do_Not_Text__c FROM Lead LIMIT 1];

		system.assertEquals('Prospect New', referral.D2D_Lead_Status_At_Opt_Out__c);
		system.assertEquals('Prospect New', referral.D2D_Lead_Status__c);
		system.assertEquals(null, referral.D2D_Opt_Out_Detail__c);

		system.assertEquals('Prospect Contacted', lead.Status);
		system.assertEquals(webLeadQueue.Id, lead.OwnerId);
		system.assertEquals(null, lead.Unqualified_Reason__c);
		system.assert(!lead.Global_Opt_Out__c);
        system.assert(!lead.Do_Not_Solicit__c);
        system.assert(!lead.DoNotCall);
        system.assert(!lead.HasOptedOutOfEmail);
        system.assert(!lead.HasOptedOutOfFax);
        system.assert(!lead.Do_Not_Mail__c);
        system.assert(!lead.Do_Not_Text__c);
	}
}