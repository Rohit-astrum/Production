@isTest
private class D2D_PropertyPhotosControllerTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out

	@testSetup static void setupData() {
		D2DTestUtility.InitializeRequiredMethods();
		D2DTestUtility.CreateCustomSettings(false, 'd2d.tester@email.com');

		D2DTestUtility.CreateManagerUsers(1);
		User d2dMg = D2DTestUtility.d2dManagerUsers[0];

		D2DTestUtility.CreateSalesRepUsers(1);
		User d2dSr = D2DTestUtility.d2dSalesRepUsers[0];

		D2DTestUtility.CreatePortalReferralRequiredObjects(1, 'NY', '24 Panel');
		D2DTestUtility.CreatePortalReferralsWithLeads(1, d2dMg.Id, d2dSr.Id, 'OPEN', 'Prospect New', '24 Panel', '2', 'ref', 'Bob', '1010 Boolean Ave', 'Stony Point', 'NY', '10980', 'Rockland', false);
		D2DTestUtility.CreatePortalReferralsWithConvertedLeads(1, d2dMg.Id, d2dSr.Id, 'OPEN', 'Prospect New', '36 Panel', '3', 'ref', 'Joe', '1010 Tenth St', 'Stony Point', 'NY', '10980', 'Rockland', true);
	}

	@isTest static void test_InvalidReferral() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id, D2D_Sales_Rep__c, D2D_Lead_Status__c, D2D_Scheduled_Visit_Datetime__c FROM Portal_Referral__c WHERE Street__c LIKE '1010 Bool%' LIMIT 1];
		User repUser = [SELECT Id FROM User WHERE Id = :referral.D2D_Sales_Rep__c];

		System.runAs(repUser){
			PageReference pageRef = Page.D2D_PropertyPhotos;
			pageRef.getParameters().put('id', referral.Id);
			Test.setCurrentPage(pageRef);

			Test.startTest();

			D2D_PropertyPhotosController controller = new D2D_PropertyPhotosController();
			controller.upload();

			Test.stopTest();
		}
	}

	@isTest static void test_Upload() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id, D2D_Sales_Rep__c, D2D_Lead_Status__c, D2D_Scheduled_Visit_Datetime__c, Opportunity__c FROM Portal_Referral__c WHERE Street__c LIKE '1010 Tent%' LIMIT 1];
		User repUser = [SELECT Id FROM User WHERE Id = :referral.D2D_Sales_Rep__c];

		SCRB_SalesOrder__c salesOrder = new SCRB_SalesOrder__c(OpportunityId__c = referral.Opportunity__c);
		insert salesOrder;

		System.runAs(repUser){
			PageReference pageRef = Page.D2D_PropertyPhotos;
			pageRef.getParameters().put('id', referral.Id);
			Test.setCurrentPage(pageRef);

			Test.startTest();

			D2D_PropertyPhotosController controller = new D2D_PropertyPhotosController();
			
			system.assertEquals(0, controller.propertyAttachments.size());

			// Upload files, at least one set multiple
			controller.photoType = 'fp';
			controller.uploadFile.Body = Blob.valueOf('Sample FP Attachment 1');
			controller.upload();

			controller.photoType = 'fp';
			controller.uploadFile.Body = Blob.valueOf('Sample FP Attachment 2');
			controller.upload();

			for(Attachment att : controller.propertyAttachments){
				system.debug('**SZ: att.Name = ' + att.Name);
			}
			system.assertEquals(2, controller.getFpAttachments().size());

            controller.photoType = 'rp';
			controller.uploadFile.Body = Blob.valueOf('Sample RP Attachment');
			controller.upload();
			system.assertEquals(1, controller.getRpAttachments().size());

            controller.photoType = 's1';
			controller.uploadFile.Body = Blob.valueOf('Sample S1 Attachment');
			controller.upload();
			system.assertEquals(1, controller.getS1Attachments().size());

            controller.photoType = 's2';
			controller.uploadFile.Body = Blob.valueOf('Sample S2 Attachment');
			controller.upload();
			system.assertEquals(1, controller.getS2Attachments().size());

            controller.photoType = 'ub';
			controller.uploadFile.Body = Blob.valueOf('Sample UB Attachment');
			controller.upload();
			system.assertEquals(1, controller.getUbAttachments().size());

            controller.photoType = 'em';
			controller.uploadFile.Body = Blob.valueOf('Sample EM Attachment');
			controller.upload();
			system.assertEquals(1, controller.getEmAttachments().size());

			referral.D2D_Lead_Status__c = 'Sold';
			update referral;
			
			controller = new D2D_PropertyPhotosController();

			controller.photoType = 'vc';
			controller.uploadFile.Body = Blob.valueOf('Sample VC Attachment');
			controller.upload();
			system.assertEquals(1, controller.getVcAttachments().size());

			Test.stopTest();
		}
	}
	
	@isTest static void test_LoadAndSubmit() {
		if(!runalltests){ return; }

		Portal_Referral__c referral = [SELECT Id, D2D_Sales_Rep__c, D2D_Lead_Status__c, D2D_Scheduled_Visit_Datetime__c FROM Portal_Referral__c WHERE Street__c LIKE '1010 Tent%' LIMIT 1];
		User repUser = [SELECT Id FROM User WHERE Id = :referral.D2D_Sales_Rep__c];

		System.runAs(repUser){
			PageReference pageRef = Page.D2D_PropertyPhotos;
			pageRef.getParameters().put('id', referral.Id);
			Test.setCurrentPage(pageRef);

			Test.startTest();

			D2D_PropertyPhotosController controller = new D2D_PropertyPhotosController();
			controller.submit();

			Test.stopTest();
		}
	}
}