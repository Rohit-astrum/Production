@isTest
private class EP_ControllersTest {
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

			EP_ForgotPasswordController controller = new EP_ForgotPasswordController();

			controller.username = plUser.username;
			controller.forgotPassword();

			Test.stopTest();
		}
	}
	
	@isTest(SeeAllData=true) static void test_LoginController() {
		if(!runalltests){ return; }
                
		Test.startTest();

		EP_LoginController controller = new EP_LoginController();

        controller.username = 'test@salesforce.com';
        controller.password = '123456'; 

		controller.rememberMe = false;
		controller.login();

		controller.rememberMe = true;
		controller.login();

		Test.stopTest();
	}
}