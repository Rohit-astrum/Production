/*
* MODIFICATION HISTORY:
*  07/18/2015 - SPRINT4- Turned off pricing while running test methods
*/
@isTest
private class AvailableIncentiveOfferTriggerTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out

	@isTest static void AIOTriggerTest() {
		if(!runalltests){ return; }

        //Create Custom Settings
        //testdata.setupCustomSettings();
        //testdata.setupCustomConfigObjects();
        testdata.setupCustomSettingsPricing();
        testdata.setupCustomConfigObjectsPricing();
        
        //Create System Design Quote        
        // setupSystemDesignQuote method creates 5 AIO
        System_Design_Quote__c sdq = testdata.setupSystemDesignQuote('Residential', 'Purchase', null, false, 12000);
        // setupAvailableIncentiveOffer method creates 1 AIO
        Available_Incentive_Offer__c aio = testdata.setupAvailableIncentiveOffer(sdq.Id, 'State', 'Residential', 'MD', 'Purchase');

        test.startTest();

        AvailableIncentiveOfferTriggerHandler aioTH = new AvailableIncentiveOfferTriggerHandler(false);
        system.assertEquals(false, aioTH.IsTriggerContext);
        aioTH = new AvailableIncentiveOfferTriggerHandler(true);
        system.assertEquals(true, aioTH.IsTriggerContext);

        insert aio;

        // add asserts
        List<Available_Incentive_Offer__c> aioList = [SELECT Id FROM Available_Incentive_Offer__c];
        system.assertEquals(6, aioList.size());

        // make a change to an aio property
        system.assertEquals('1', aio.Applicable_Scenario__c);
        aio.Applicable_Scenario__c = '2';
        update aio;

        // add asserts
        aioList = [SELECT Id, Applicable_Scenario__c FROM Available_Incentive_Offer__c WHERE Id = :aio.Id];
        system.assertEquals(1, aioList.size());
        system.assertEquals('2', aioList[0].Applicable_Scenario__c);

        test.stopTest();
	}	
}