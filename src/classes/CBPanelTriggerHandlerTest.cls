@isTest
private class CBPanelTriggerHandlerTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out
	
	@isTest static void test_method_one() {
		if(!runalltests){ return; }
        
        Test.startTest();

        CBPanelTriggerHandler cbpTH = new CBPanelTriggerHandler(false);
        system.assertEquals(false, cbpTH.IsTriggerContext);
        cbpTH = new CBPanelTriggerHandler(true);
        system.assertEquals(true, cbpTH.IsTriggerContext);

        Test.stopTest();
	}	
}