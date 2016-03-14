/*
	08/07/15  DK  Created test_method_two() to cover new code additions. CPQ-573.
*/
@isTest
private class UtilityPricingProcessorTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out

	@isTest static void test_method_one() {
		if(!runalltests){ return; }

        //Create Custom Settings
        testdata.setupCustomSettings();
        testdata.setupCustomConfigObjects();
        
        //Create System Design
        Id systemDesignID = testData.setupSystemDesign('Residential', 'Purchase', null, true, 12000);
        Utility_Company__c urc = [SELECT Id FROM Utility_Company__c WHERE Name = 'BG&E'];

        // Create Rate Periods
        List<Rate_Period__c> rps = new List<Rate_Period__c>();
		//for(Integer i = 1; i <= 12; i++) {
		for(Integer i = 1; i <= 6; i++) {
	        Rate_period__c rp = new Rate_period__c();
	        if (math.mod(12, i) == 0) {
		        rp.Period_Type__c = 'Peak';
	        } else if(math.mod(12, i) == 1) {
		        rp.Period_Type__c = 'Part_Peak';
	        } else {
		        rp.Period_Type__c = 'Off_Peak';
	        }
	        rp.Name = 'Period ' + i;
	        rp.Utility_Company__c = urc.id;
	        rp.Rate_Period__c = i;
	        rp.Tier_1_Rate_kWh__c = 0.14485;
	        rp.Tier_2_Rate_kWh__c = 0.14713;
	        rp.Tier_3_Rate_kWh__c = 0.16435;
	        rp.Tier_4_Rate_kWh__c = 1.1;
	        rp.Tier_5_Rate_kWh__c = 1.2;
	        rps.add(rp);
		}
        insert rps;

        test.startTest();

        UtilityPricingProcessor upp = new UtilityPricingProcessor(systemDesignID,'Method_1');
        upp.getUtilityServiceMonthlyProduction(urc.Id);

        urc.Baseline_Consumption_kWh_day__c = 'NA';
        urc.Baseline_Consumption_kWh_month__c = '341.00;310.80;341.00;330.00;341.00;465.00;480.50;480.50;465.00;341.00;330.00;341.00';
        update urc;

        upp.getUtilityServiceMonthlyProduction(urc.Id);

        test.stopTest();
	}

	@isTest static void test_method_two() {
		if(!runalltests){ return; }

		Opportunity_Trigger_Utility.skipOpportunityTrigger = true;	//Conserve SOQL

        //Create Custom Settings
        testdata.setupCustomSettings();
        testdata.setupCustomConfigObjects();
        
        //Create System Design
        System_Design_Quote__c sdq = testData.setupSystemDesignQuote('Residential', 'Purchase', null, true, 12000);
        Utility_Company__c urc = [SELECT Id FROM Utility_Company__c WHERE Name = 'R1'];

        // Create Rate Periods
        List<Rate_Period__c> rps = new List<Rate_Period__c>();
		for(Integer i = 1; i <= 6; i++) {
	        Rate_period__c rp = new Rate_period__c();
	        if (math.mod(12, i) == 0) {
		        rp.Period_Type__c = 'Peak';
	        } else if(math.mod(12, i) == 1) {
		        rp.Period_Type__c = 'Part_Peak';
	        } else {
		        rp.Period_Type__c = 'Off_Peak';
	        }
	        rp.Name = 'Period ' + i;
	        rp.Utility_Company__c = urc.id;
	        rp.Rate_Period__c = i;
	        rp.Tier_1_Rate_kWh__c = 0.22795;
	        rp.Tier_2_Rate_kWh__c = 0.23077;
	        rp.Tier_3_Rate_kWh__c = 0.25733;
	        rp.Tier_4_Rate_kWh__c = 0.27998;
	        rp.Tier_5_Rate_kWh__c = 0.31779;
	        rps.add(rp);
		}
        insert rps;

        test.startTest();

        UtilityPricingProcessor upp = new UtilityPricingProcessor(sdq.System_Design__c, 'Method_1');
        upp.getUtilityServiceMonthlyProduction(urc.Id);

        urc.Baseline_Consumption_kWh_day__c = 'NA';
        urc.Baseline_Consumption_kWh_month__c = '341.00;310.80;341.00;330.00;341.00;465.00;480.50;480.50;465.00;341.00;330.00;341.00';
        update urc;

        upp.getUtilityServiceMonthlyProduction(urc.Id);

        test.stopTest();

        Opportunity_Trigger_Utility.skipOpportunityTrigger = false;
	}
}