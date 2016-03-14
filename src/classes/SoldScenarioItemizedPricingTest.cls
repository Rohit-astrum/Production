/*  FILE: SoldScenarioItemizedPricingTest
    AUTHOR: Dan Kelner
    DATE: 08/26/15
    PURPOSE: Test class for SoldScenarioItemizedPricingCtrl
    MODIFICATION HISTORY
*/
@isTest
public class SoldScenarioItemizedPricingTest {

	public static testmethod void testController(){
		TestData.setupCustomSettingsPricing();
        TestData.setupCustomConfigObjectsPricing();
              
        //Create System Design Quote
        Lease_Fund__c[] funds = testData.createLeaseFunds();    //Fund[0] - SAC Loan, Fund[1] - Term Loan, Fund[2] - Lease, Fund[3] - Term & SAC                        
        System_Design_Quote__c sdq = testData.setupSystemDesignQuotePricing('Residential', funds, false, 12000);

        Test.startTest();
        //sdq = [SELECT Closed_Scenario__c, System_Design__r.Property__c, Community_Program_Offer__c FROM System_Design_Quote__c WHERE ID = :sdq.ID LIMIT 1];
        sdq.Closed_Scenario__c = '1';
        sdq.Community_Program_Offer__c = null;
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = true;
		update sdq;
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = false;
        
        sdq = testData.setupSDQPricingData(sdq, funds);
        update sdq;

        SCRB_SalesOrder__c so = new SCRB_SalesOrder__c(Name = 'Test Sales Order', Property__c = sdq.System_Design__r.Property__c, System_Design_Quote__c = sdq.ID);
        insert so;

        Test.setCurrentPage(Page.SoldScenarioItemizedPricing);
        ApexPages.StandardController stdController = new ApexPages.standardController(so);
        SoldScenarioItemizedPricingController ctrl = new SoldScenarioItemizedPricingController(stdController);

        Test.stopTest();
	}
}