@isTest
private class D2D_ChangePasswordControllerTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out

	@testSetup static void setupData() {
		D2DTestUtility.InitializeRequiredMethods();
		
//		D2DTestUtility.CreateManagerUsers(1);
//		User d2dMg = D2DTestUtility.d2dManagerUsers[0];
	}
	
	@isTest static void test_changePassword() {
		if(!runalltests){ return; }

		Test.startTest();

		D2D_ChangePasswordController controller = new D2D_ChangePasswordController();
		controller.oldPassword = '123456';
		controller.newPassword = 'qwerty1';
		controller.verifyNewPassword = 'qwerty1';

		System.assertEquals(null, controller.changePassword());

		Test.stopTest();
	}
}