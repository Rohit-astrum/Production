@isTest
private class D2D_LoginControllerTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out
	
	@isTest static void testLoginWithoutCookies() {
		if(!runalltests){ return; }

		PageReference pageRef = Page.D2D_Home;
		Test.setCurrentPage(pageRef);

		Test.startTest();

		D2D_LoginController controller = new D2D_LoginController();
		controller.username = 'test@example.com';
		controller.password = 'password';
		controller.rememberMe = true;

		PageReference returnedPageRef = controller.login();
		System.assertNotEquals(null, returnedPageRef);
		System.assertEquals(1, returnedPageRef.getCookies().size());

		Test.stopTest();
	}

	@isTest static void testLoginWithCookies() {
		if(!runalltests){ return; }

		String username = 'test@example.com';

		PageReference pageRef = Page.D2D_Home;
		Test.setCurrentPage(pageRef);
        Cookie userNameCookie = new Cookie('username', username, null, 60 * 60 * 24 * 60, false); //save cookie for 60 days
        ApexPages.currentPage().getCookies().put('username', userNameCookie);

		Test.startTest();

		D2D_LoginController controller = new D2D_LoginController();
		controller.rememberMe = false;

		PageReference returnedPageRef = controller.login();
		System.assertNotEquals(null, returnedPageRef);
		Integer nonNullCookieCount = 0;
		for(Cookie cookie : returnedPageRef.getCookies().values()){
			System.debug('**SZ: cookie value = ' + cookie.getValue());
			if(cookie.getValue() != null){
				nonNullCookieCount++;
			}
		}
		System.assertEquals(0, nonNullCookieCount);

		Test.stopTest();
	}
}