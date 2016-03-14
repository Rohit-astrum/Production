@isTest
private class PhotoAppControllersTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out
	
	@isTest static void test_ForgotPasswordController() {
		if(!runalltests){ return; }

		UserRole plRole = [SELECT Id FROM UserRole WHERE Name LIKE '%Project Lead' LIMIT 1];
		Profile opsUser = [SELECT Id FROM Profile WHERE Name = 'Operations User'];
		User plUser = new User(
			UserName = 'project.lead@test.com',
			LastName = 'Lead',
			Email = 'project.lead@test.com',
			Alias = 'PLTest3',
			CommunityNickName = 'Project Lead Test',
			TimeZoneSidKey = 'America/New_York',
			LocaleSidKey = 'en_US',
			LanguageLocaleKey = 'en_US',
			EmailEncodingKey = 'UTF-8',
			ProfileId = opsUser.Id,
			UserRoleId = plRole.Id
		);
		insert plUser;
		
		System.runAs(plUser) {
			Test.startTest();

			PhotoAppForgotPasswordController controller = new PhotoAppForgotPasswordController();

			controller.username = plUser.username;
			controller.forgotPassword();

			Test.stopTest();
		}
	}
	
	@isTest(SeeAllData=true) static void test_LoginController() {
		if(!runalltests){ return; }
                
		Test.startTest();

		PhotoAppLoginController controller = new PhotoAppLoginController();

        controller.username = 'test@salesforce.com';
        controller.password = '123456'; 

		controller.rememberMe = false;
		controller.login();

		controller.rememberMe = true;
		controller.login();

		Test.stopTest();
	}

	@isTest static void test_TemplateExtensionMobile() {
		if(!runalltests){ return; }

		Account acct = new Account (
			Name = 'Test Acct'
		);
		insert acct;

		Test.startTest();

		PortalDummyController pdController = new PortalDummyController();

		PageReference pg = Page.PortalMobileNewReferral;
		pg.getHeaders().put('User-Agent', 'Mozilla/5.0 (Linux; U; Android 2.2; en-us; Nexus One Build/FRF91) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1');
		Test.setCurrentPage(pg);

		PhotoAppTemplateExtension controller = new PhotoAppTemplateExtension(pdController);
		controller.getTemplate();

		Test.stopTest();
	}

	@isTest static void test_TemplateExtensionNonMobile() {
		if(!runalltests){ return; }

		Account acct = new Account (
			Name = 'Test Acct'
		);
		insert acct;

		Test.startTest();

		ApexPages.StandardController stdController = new ApexPages.StandardController(acct);

		PageReference pg = Page.PortalMobileNewReferral;
		pg.getHeaders().put('User-Agent', '');
		Test.setCurrentPage(pg);
		
		PhotoAppTemplateExtension controller = new PhotoAppTemplateExtension(stdController);
		controller.getTemplate();

		Test.stopTest();
	}
}