/*
* MODIFICATION HISTORY:
*  07/18/2015 - SPRINT4- Turned off pricing while running test methods
*/
@isTest
private class CommunityProgramOfferUtilityTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out

	@isTest static void test_method_one() {
		if(!runalltests){ return; }

        //Create Custom Settings
        //testdata.setupCustomSettings();
        //testdata.setupCustomConfigObjects();
        testdata.setupCustomSettingsPricing();
        testdata.setupCustomConfigObjectsPricing();
        testdata.setupCommunityProgramOffers();

        List<Community_Program_Offer__c> cpoList = [SELECT Eligibility_Criterion__c, Start_Date__c, Extension_End_Date__c, Initial_End_Date__c FROM Community_Program_Offer__c];

        Test.startTest();

        System_Design_Quote__c sdq = testData.setupSystemDesignQuote('Residential', 'Purchase', null, true, 12000);

        Test.stopTest();
	}

	@isTest static void test_method_two() {
		if(!runalltests){ return; }

        //Create Custom Settings
        //testdata.setupCustomSettings();
        //testdata.setupCustomConfigObjects();
        testdata.setupCustomSettingsPricing();
        testdata.setupCustomConfigObjectsPricing();
        testdata.setupCommunityProgramOffers();

        List<Community_Program_Offer__c> cpoList = [SELECT Eligibility_Criterion__c FROM Community_Program_Offer__c];
        //for(Community_Program_Offer__c cpo : cpoList){
        //	if(cpo.Eligibility_Criterion__c == 'ZIP'){
        //		cpo.Active__c = false;
        //	}
        //}
        update cpoList;

        Test.startTest();

        System_Design_Quote__c sdq = testData.setupSystemDesignQuote('Residential', 'Purchase', null, true, 12000);

        Test.stopTest();
	}

	@isTest static void test_method_three() {
		if(!runalltests){ return; }

        //Create Custom Settings
        //testdata.setupCustomSettings();
        //testdata.setupCustomConfigObjects();
        testdata.setupCustomSettingsPricing();
        testdata.setupCustomConfigObjectsPricing();
        testdata.setupCommunityProgramOffers();

        List<Community_Program_Offer__c> cpoList = [SELECT Eligibility_Criterion__c FROM Community_Program_Offer__c];
        //for(Community_Program_Offer__c cpo : cpoList){
        //	if(cpo.Eligibility_Criterion__c == 'ZIP' || cpo.Eligibility_Criterion__c == 'City'){
        //		cpo.Active__c = false;
        //	}
        //}
        update cpoList;

        Test.startTest();

        System_Design_Quote__c sdq = testData.setupSystemDesignQuote('Residential', 'Purchase', null, true, 12000);

        Test.stopTest();
	}
	
	@isTest static void test_method_four() {
		if(!runalltests){ return; }

        //Create Custom Settings
        //testdata.setupCustomSettings();
        //testdata.setupCustomConfigObjects();
        testdata.setupCustomSettingsPricing();
        testdata.setupCustomConfigObjectsPricing();
        testdata.setupCommunityProgramOffers();

        Test.startTest();

        Lead l = new Lead (
            LastName = 'Test',
            Company = 'Test',
            Street = '99 Oakmark Ave',
            City = 'Annapolis Junction',
            State = 'MD',
            QAS_County__c = 'Howard County, MD',
            PostalCode = '20701'
        );
        insert l;

        l = [SELECT Id, QAS_County__c FROM Lead WHERE LastName = 'Test'];
        l.QAS_County__c = 'XXXX, MD';
        update l;

        Test.stopTest();
	}
}