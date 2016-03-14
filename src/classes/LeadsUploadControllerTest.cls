@isTest
private class LeadsUploadControllerTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out

	@testSetup static void setupData() {
		D2DTestUtility.InitializeRequiredMethods();
		D2DTestUtility.CreateCustomSettings('d2d.tester@email.com');
		D2DTestUtility.CreateSalesCoordinatorUser();
		D2DTestUtility.CreatePrimarySourceCampaigns(1);
	}

	@isTest static void test_uploadAndCancel() {
		if(!runalltests){ return; }

		PageReference pageRef = Page.LeadsUpload;
		Test.setCurrentPage(pageRef);

		// Create a sample file
		Blob sampleContent = Blob.valueOf('Full Address,First Name,Last Name,Street,City,State,Zip,Segment Name,System Size,Rep Area,Status,Visit Status,Reason Notes,ACP,PSC,County\r\n"66 Filors Ln Stony Point, NY 10980",WISLER,NARCISSE,66 Filors Ln,Stony Point,NY,10980,Good,24,,,,,D2D Orange & Rockland,701C0000000VQVk,Rockland');

		Test.startTest();

		LeadsUploadController controller = new LeadsUploadController();

		controller.contentFile = sampleContent;
		controller.fileNameUploaded = 'test.doc';
		controller.parseUploadFile();
		system.assertEquals(true, controller.validationError);

		controller.fileNameUploaded = 'test.csv';
		controller.parseUploadFile();
		system.assertEquals(false, controller.validationError);
		system.assertEquals(true, controller.fileIsParsed);
		system.assertEquals(true, controller.fileIsValid);

		controller.cancel();
		system.assertEquals(false, controller.validationError);
		system.assertEquals(false, controller.fileIsParsed);
		system.assertEquals(false, controller.fileIsValid);
		system.assertEquals(null, controller.contentFile);
		system.assertEquals(null, controller.fileNameUploaded);

		Test.stopTest();
	}
	
	@isTest static void test_uploadAndSave() {
		if(!runalltests){ return; }

		PageReference pageRef = Page.LeadsUpload;
		Test.setCurrentPage(pageRef);

		// Retrieve Campaign Id
		Campaign campaign = [SELECT Id FROM Campaign WHERE Canvass_Area_Name__c = 'D2D Stony Point' LIMIT 1];

		// Create a sample file
		Blob sampleContent = Blob.valueOf('Full Address,First Name,Last Name,Street,City,State,Zip,Segment Name,System Size,Rep Area,Status,Visit Status,Reason Notes,ACP,PSC,County\r\n"66 Filors Ln Stony Point, NY 10980",WISLER,NARCISSE,66 Filors Ln,Stony Point,NY,10980,Good,24,,,,,D2D Orange & Rockland,' + campaign.Id + ',Rockland');

		Test.startTest();

		LeadsUploadController controller = new LeadsUploadController();

		controller.contentFile = sampleContent;
		controller.fileNameUploaded = 'test.doc';
		controller.parseUploadFile();
		system.assertEquals(true, controller.validationError);

		controller.fileNameUploaded = 'test.csv';
		controller.parseUploadFile();
		system.assertEquals(false, controller.validationError);
		system.assertEquals(true, controller.fileIsParsed);
		system.assertEquals(true, controller.fileIsValid);

		List<Lead> leads = [SELECT Id FROM Lead];
		List<Portal_Referral__c> prList = [SELECT Id FROM Portal_Referral__c];
		system.assertEquals(0, leads.size());
		system.assertEquals(0, prList.size());

		ApexPages.Message[] pageMessages = ApexPages.getMessages();
		Integer pageMessagesCount = pageMessages.size();

		controller.save();
		pageMessages = ApexPages.getMessages();
		for(ApexPages.Message message : pageMessages){
			system.debug('**SZ: message = ' + message.getSeverity() + '; ' + message.getSummary());
		}
		leads = [SELECT Id FROM Lead];
		prList = [SELECT Id FROM Portal_Referral__c];

		system.assertEquals(pageMessagesCount, pageMessages.size());
		system.assertEquals(false, controller.validationError);
		system.assertEquals(false, controller.fileIsParsed);
		system.assertEquals(false, controller.fileIsValid);
		system.assertEquals(null, controller.contentFile);
		system.assertEquals(null, controller.fileNameUploaded);
		system.assertEquals(1, leads.size());
		system.assertEquals(1, prList.size());

		Test.stopTest();
	}

	@isTest static void test_uploadWithInvalidsAndDuplicates() {
		if(!runalltests){ return; }

		PageReference pageRef = Page.LeadsUpload;
		Test.setCurrentPage(pageRef);

		// Retrieve Campaign Id
		Campaign campaign = [SELECT Id FROM Campaign WHERE Canvass_Area_Name__c = 'D2D Stony Point' LIMIT 1];

		// Create a sample file
		Blob sampleContent1 = Blob.valueOf('Full Address,First Name,Last Name,Street,City,State,Zip,Segment Name,System Size,Rep Area,Status,Visit Status,Reason Notes,ACP,PSC,County\r\n"66 Filors Ln Stony Point, NY 10980",WISLER,NARCISSE,66 Filors Ln,Stony Point,NY,10980,Good,24,,,,,D2D Orange & Rockland,' + campaign.Id + ',Rockland');
		Blob sampleContent2 = Blob.valueOf('Full Address,First Name,Last Name,Street,City,State,Zip,Segment Name,System Size,Rep Area,Status,Visit Status,Reason Notes,ACP,PSC,County\r\n"66 Filors Ln Stony Point, NY 10980",WISLER,NARCISSE,66 Filors Ln,Stony Point,NY,10980,Good,24,,,,,D2D Orange & Rockland,' + campaign.Id + ',Rockland\r\n"7 Brooks Ct Stony Point, NY 10980",GARY,DE VITA,7 Brooks Ct,Stony Point,NY,10980,Good,,,,,,,' + campaign.Id + ',');
		Blob sampleContent3 = Blob.valueOf('Full Address,First Name,Last Name,Street,City,State,Zip,Segment Name,System Size,Rep Area,Status,Visit Status,Reason Notes,ACP,PSC,County\r\n"66 Filors Ln Stony Point, NY 10980",WISLER,NARCISSE,66 Filors Ln,Stony Point,NY,10980,Good,24,,,,,D2D Orange & Rockland,' + campaign.Id + ',Rockland');

		Test.startTest();

		LeadsUploadController controller = new LeadsUploadController();

		controller.contentFile = sampleContent1;
		controller.fileNameUploaded = 'test1.csv';
		controller.parseUploadFile();
		system.assertEquals(false, controller.validationError);
		system.assertEquals(true, controller.fileIsParsed);
		system.assertEquals(true, controller.fileIsValid);

		ApexPages.Message[] pageMessages = ApexPages.getMessages();
		Integer pageMessagesCount = pageMessages.size();

		controller.save();
		pageMessages = ApexPages.getMessages();
		List<Lead> leads = [SELECT Id FROM Lead];
		List<Portal_Referral__c> prList = [SELECT Id FROM Portal_Referral__c];

		system.assertEquals(pageMessagesCount, pageMessages.size());
		system.assertEquals(false, controller.validationError);
		system.assertEquals(false, controller.fileIsParsed);
		system.assertEquals(false, controller.fileIsValid);
		system.assertEquals(null, controller.contentFile);
		system.assertEquals(null, controller.fileNameUploaded);
		system.assertEquals(1, leads.size());
		system.assertEquals(1, prList.size());

		// file with duplicates and invalids
		controller.contentFile = sampleContent2;
		controller.fileNameUploaded = 'test2.csv';
		controller.parseUploadFile();
		system.assertEquals(true, controller.validationError);
		system.assertEquals(true, controller.fileIsParsed);
		system.assertEquals(false, controller.fileIsValid);
		system.assertEquals(1, controller.invalidRowCount);
		system.assertEquals(1, controller.duplicateRowCount);

		controller.contentFile = sampleContent3;
		controller.fileNameUploaded = 'test3.csv';
		controller.parseUploadFile();
		system.assertEquals(false, controller.validationError);
		system.assertEquals(true, controller.fileIsParsed);
		system.assertEquals(true, controller.fileIsValid);
		system.assertEquals(1, controller.duplicateRowCount);

		pageMessages = ApexPages.getMessages();
		pageMessagesCount = pageMessages.size();

		controller.save();
		pageMessages = ApexPages.getMessages();
		leads = [SELECT Id FROM Lead];
		prList = [SELECT Id FROM Portal_Referral__c];

		system.assertEquals(pageMessagesCount, pageMessages.size());
		system.assertEquals(false, controller.validationError);
		system.assertEquals(false, controller.fileIsParsed);
		system.assertEquals(false, controller.fileIsValid);
		system.assertEquals(null, controller.contentFile);
		system.assertEquals(null, controller.fileNameUploaded);
		system.assertEquals(1, leads.size());
		system.assertEquals(2, prList.size());

		Test.stopTest();
	}

/*	private static void CreateTestData(){
		// Create the sales coordinator
		D2DSettings__c d2dSettings = new D2DSettings__c(
			Sales_Coordinator__c = 'tester@email.com'
		);
		insert d2dSettings;

		System.runAs(new User(Id = UserInfo.getUserId())){
			UserRole role = [SELECT Id FROM UserRole WHERE Name LIKE '%Project Lead' LIMIT 1];
			Profile prof = [SELECT Id FROM Profile WHERE Name = 'Operations User'];
			User salesCoordinator = new User(
				Email = d2dSettings.Sales_Coordinator__c,
				UserName = 'tester@email.com',
				LastName = 'D2D',
				Alias = 'd2d.sc',
				CommunityNickName = 'Sales Coordinator Test',
				TimeZoneSidKey = 'America/New_York',
				LocaleSidKey = 'en_US',
				LanguageLocaleKey = 'en_US',
				EmailEncodingKey = 'UTF-8',
				ProfileId = prof.Id,
				UserRoleId = role.Id
			);
			insert salesCoordinator;
		}

		List<Document> docs = new List<Document>();
		docs.add(new Document(Name='DESLogo', FolderId=UserInfo.getUserId()));
		insert docs;

		Campaign campaign = new Campaign();
		campaign.Type = 'Canvassing';
		campaign.Event_Type_Detail__c = 'Not Sure – Was Just In the Area';
		campaign.IsActive = true;
		campaign.City__c = 'Stony Point';
		campaign.State__c = 'NY';
		campaign.StartDate = Date.today();
		campaign.EndDate = Date.today().addDays(3);
		campaign.Customer_Host_NA__c = true;
		campaign.Canvass_Area_Name__c = 'D2D Stony Point';
		campaign.Canvass_Zip_Codes__c = '10980';
		campaign.Sales_Region_s__c = 'WNY Region';
		campaign.Estimated_Event_Fees_Expenses__c = '1000';
		insert campaign;
	}*/
}