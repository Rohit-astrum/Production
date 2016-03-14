@isTest
private class DEBundle_UnitTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out

	@testSetup static void setupData() {
        testdata.setupCustomSettingsPricing();
        testdata.setupCustomConfigObjectsPricing();

		Id campaignId = DEBundle_TestUtility.CreateCampaign();

        //Create our test data
        DEBundle_TestUtility.CreateCustomSettings(campaignId);

        //Create System Design Quote        
        Opportunity_Trigger_Utility.skipOpportunityTrigger = true;
        System_Design_Quote__c sdq = testdata.setupSystemDesignQuote('Residential', 'Purchase', null, true, 12000);
        Opportunity_Trigger_Utility.skipOpportunityTrigger = false;

        Entitlement_Offer__c eo = new Entitlement_Offer__c(Name = 'DE OB EO', DE_Outbound_Referral_Offer__c = campaignId);
        insert eo;

        Price_Adjustment__c pa = new Price_Adjustment__c(System_Design_Quote__c = sdq.Id, Adjustment_Applied__c = true, Applicable_Scenario__c = '1', Entitlement_Offer__c = eo.Id);
        insert pa;

        Proposal__c prop = new Proposal__c(System_Design_Quote__c = sdq.ID);
        insert prop;

        Astrum_Contract__c contr1 = new Astrum_Contract__c(Proposal__c = prop.ID, Closed__c = true, Scenario__c = '1');
        insert contr1;

        Opportunity opp = [SELECT Id FROM Opportunity WHERE System_Design_Quote__c = :sdq.Id LIMIT 1];

		SCRB_SalesOrder__c salesOrder = new SCRB_SalesOrder__c(System_Design_Quote__c = sdq.Id, OpportunityId__c = opp.Id, Closed_Scenario__c = '1');
		insert salesOrder;
    }

	@isTest static void testUploadFileToSalesOrder() {
		if(!runalltests){ return; }

		SCRB_SalesOrder__c salesOrder = [SELECT Id FROM SCRB_SalesOrder__c LIMIT 1];

		PageReference pageRef = Page.DEBundle_UploadDEReferral;
		pageRef.getParameters().put('id', salesOrder.Id);
		Test.setCurrentPage(pageRef);

		Test.startTest();

		Integer pageMessageCount = 0;
		DEBundle_UploadDEReferralController controller = new DEBundle_UploadDEReferralController(new ApexPages.StandardController(salesOrder));
	    controller.uploadFile = new Attachment(
	        Name = 'samplefile.pdf',
	        ContentType = 'application/pdf'
		);
		controller.upload();

		System.assertNotEquals(pageMessageCount, ApexPages.getMessages().size());
		Boolean foundText = false;
		for(ApexPages.Message msg : ApexPages.getMessages()){
			if(msg.getSummary().contains('upload file cannot be null')){
				system.debug('**SZ: message = ' + msg.getSummary());
				foundText = true;
				break;
			}
		}
		System.assert(foundText);

	    controller.uploadFile = new Attachment(
	        Name = 'samplefile.pdf',
		    Body = Blob.valueOf('Sample DER Solar Advantage Plan Attachment'),
	        ContentType = 'application/pdf'
		);
	    controller.upload();

		Test.stopTest();

		List<Attachment> attList = [SELECT Id FROM Attachment WHERE ParentId = :salesOrder.Id];

		system.assertNotEquals(0, attList.size());
	}
	
	@isTest static void testLeadTransferJob() {
		if(!runalltests){ return; }

		String CRON_EXP = '0 0 0 15 3 ? 2022';

		Test.startTest();

		String jobId = System.schedule('DEBundleLeadTransferJobTest',
			CRON_EXP, 
			new DEBundle_LeadTransferJob());
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

		System.assertEquals(CRON_EXP, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));

		Test.stopTest();

		system.debug('**SZ: stop test called.');
	}
	
	@isTest static void testLeadTransferBatch_NoRecords() {
		if(!runalltests){ return; }

        Test.startTest();

		DEBundle_LeadTransferBatch b = new DEBundle_LeadTransferBatch();
		Database.executebatch(b);
        
        Test.stopTest();

		List<DER_Bundle_Log__c> bundleLog = [SELECT Email_To_Contact__c, Timestamp__c, Error_Message__c, Total_Records__c,
			Successful_Transfers__c, Transfers_Missing_Attachment__c, Failed_Transfers__c FROM DER_Bundle_Log__c];
		system.assertEquals(1, bundleLog.size());
		system.assertEquals('No records to process.', bundleLog[0].Error_Message__c);
	}
	
	@isTest static void testLeadTransferBatch_TokenFail() {
		if(!runalltests){ return; }

		System.runAs(new User(Id = UserInfo.getUserId())){
			SCRB_SalesOrder__c salesOrder = [SELECT Id FROM SCRB_SalesOrder__c LIMIT 1];

			PM_Project__c project = new PM_Project__c(Name = 'Test Proj', Sales_Order__c = salesOrder.Id);
			insert project;

			project.Inspection__c = Datetime.now().addDays(-5);
			project.Inspection_Verified__c = Date.today().addDays(-2);
			update project;

	        Test.startTest();
	        Test.setMock(HttpCalloutMock.class, new DEBundle_CalloutMock(new Map<String, Integer>{ 'oauth2/token' => 400 }));

			DEBundle_LeadTransferBatch b = new DEBundle_LeadTransferBatch();
			Database.executebatch(b);
	        
	        Test.stopTest();

			List<DER_Bundle_Log__c> bundleLog = [SELECT Email_To_Contact__c, Timestamp__c, Error_Message__c, Total_Records__c,
				Successful_Transfers__c, Transfers_Missing_Attachment__c, Failed_Transfers__c FROM DER_Bundle_Log__c];
			system.assertEquals(2, bundleLog.size());

			Integer foundMessages = 0;
			for(DER_Bundle_Log__c dbl : bundleLog){
				system.debug('**SZ: error message = "' + dbl.Error_Message__c + '"');
				if(dbl.Error_Message__c == 'Could not acquire the access token.' || dbl.Error_Message__c == 'access token error: access token error description'){
					foundMessages++;
				}
			}
			system.assertEquals(2, foundMessages);
		}
	}
	
	@isTest static void testLeadTransferBatch_LeadFail() {
		if(!runalltests){ return; }

		System.runAs(new User(Id = UserInfo.getUserId())){
			SCRB_SalesOrder__c salesOrder = [SELECT Id FROM SCRB_SalesOrder__c LIMIT 1];

			PM_Project__c project = new PM_Project__c(Name = 'Test Proj', Sales_Order__c = salesOrder.Id);
			insert project;

			project.Inspection__c = Datetime.now().addDays(-5);
			project.Inspection_Verified__c = Date.today().addDays(-2);
			update project;

			DEBundle_TestUtility.CreateSalesOrderAttachment(salesOrder.Id);

	        Test.startTest();
	        Test.setMock(HttpCalloutMock.class, new DEBundle_CalloutMock(new Map<String, Integer>{ 'oauth2/token' => 200, 'sobjects/Lead' => 400 }));

			DEBundle_LeadTransferBatch b = new DEBundle_LeadTransferBatch();
			Database.executebatch(b);
	        
	        Test.stopTest();

			List<DER_Bundle_Log__c> bundleLog = [SELECT Email_To_Contact__c, Timestamp__c, Error_Message__c, Total_Records__c,
				Successful_Transfers__c, Transfers_Missing_Attachment__c, Failed_Transfers__c FROM DER_Bundle_Log__c];
			for(DER_Bundle_Log__c dbl : bundleLog){
				system.debug('**SZ: error message = "' + dbl.Error_Message__c + '"');
			}
			system.assertEquals(1, bundleLog.size());
			system.assertEquals(1, bundleLog[0].Failed_Transfers__c);
		}
	}
	
	@isTest static void testLeadTransferBatch_AttachFail() {
		if(!runalltests){ return; }

		System.runAs(new User(Id = UserInfo.getUserId())){
			SCRB_SalesOrder__c salesOrder = [SELECT Id FROM SCRB_SalesOrder__c LIMIT 1];

			PM_Project__c project = new PM_Project__c(Name = 'Test Proj', Sales_Order__c = salesOrder.Id);
			insert project;

			project.Inspection__c = Datetime.now().addDays(-5);
			project.Inspection_Verified__c = Date.today().addDays(-2);
			update project;

			DEBundle_TestUtility.CreateSalesOrderAttachment(salesOrder.Id);

	        Test.startTest();
	        Test.setMock(HttpCalloutMock.class, new DEBundle_CalloutMock(new Map<String, Integer>{ 'oauth2/token' => 200, 'sobjects/Lead' => 200, 'sobjects/Attachment' => 400 }));

			DEBundle_LeadTransferBatch b = new DEBundle_LeadTransferBatch();
			Database.executebatch(b);
	        
	        Test.stopTest();

			List<DER_Bundle_Log__c> bundleLog = [SELECT Email_To_Contact__c, Timestamp__c, Error_Message__c, Total_Records__c,
				Successful_Transfers__c, Transfers_Missing_Attachment__c, Failed_Transfers__c FROM DER_Bundle_Log__c];
			for(DER_Bundle_Log__c dbl : bundleLog){
				system.debug('**SZ: error message = "' + dbl.Error_Message__c + '"');
			}
			system.assertEquals(1, bundleLog.size());
			system.assertEquals(1, bundleLog[0].Transfers_Missing_Attachment__c);
		}
	}
	
	@isTest static void testLeadTransferBatch_AllPass() {
		if(!runalltests){ return; }

		System.runAs(new User(Id = UserInfo.getUserId())){
			SCRB_SalesOrder__c salesOrder = [SELECT Id FROM SCRB_SalesOrder__c LIMIT 1];

			PM_Project__c project = new PM_Project__c(Name = 'Test Proj', Sales_Order__c = salesOrder.Id);
			insert project;

			project.Inspection__c = Datetime.now().addDays(-5);
			project.Inspection_Verified__c = Date.today().addDays(-2);
			update project;

			DEBundle_TestUtility.CreateSalesOrderAttachment(salesOrder.Id);

	        Test.startTest();
	        Test.setMock(HttpCalloutMock.class, new DEBundle_CalloutMock(new Map<String, Integer>{ 'oauth2/token' => 200, 'sobjects/Lead' => 200, 'sobjects/Attachment' => 200 }));

			DEBundle_LeadTransferBatch b = new DEBundle_LeadTransferBatch();
			Database.executebatch(b);
	        
	        Test.stopTest();

			List<DER_Bundle_Log__c> bundleLog = [SELECT Email_To_Contact__c, Timestamp__c, Error_Message__c, Total_Records__c,
				Successful_Transfers__c, Transfers_Missing_Attachment__c, Failed_Transfers__c FROM DER_Bundle_Log__c];
			for(DER_Bundle_Log__c dbl : bundleLog){
				system.debug('**SZ: error message = "' + dbl.Error_Message__c + '"');
			}
			system.assertEquals(1, bundleLog.size());
			system.assertEquals(1, bundleLog[0].Successful_Transfers__c);
		}
	}
}