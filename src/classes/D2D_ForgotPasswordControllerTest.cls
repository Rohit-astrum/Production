@isTest
private class D2D_ForgotPasswordControllerTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out
	
	@isTest static void forgotPassword() {
		if(!runalltests){ return; }

		PageReference pageRef = Page.D2D_ForgotPassword;
		Test.setCurrentPage(pageRef);

		Test.startTest();

		D2D_ForgotPasswordController controller = new D2D_ForgotPasswordController();
		controller.username = UserInfo.getUserName();

		PageReference returnedPageRef = controller.forgotPassword();
		System.assertNotEquals(null, returnedPageRef);

		Test.stopTest();
	}
}