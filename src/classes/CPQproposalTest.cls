/*  FILE: CPQproposalTest.cls
    AUTHOR: Dan Kelner
    DATE: 04/22/15
    PURPOSE: Test class for CPQproposalController
    MODIFICATION HISTORY
*/
@isTest
public class CPQproposalTest {

    @isTest(seeAllData = false) static void testProposalGeneration1(){
        //Create Custom Settings
        testData.setupCustomSettingsPricing();
        testData.setupCustomConfigObjectsPricing();
        
        //Create System Design Quote
        Lease_Fund__c[] funds = testData.createLeaseFunds();    //Fund[0] - SAC Loan, Fund[1] - Term Loan, Fund[2] - Lease, Fund[3] - Term & SAC                        
        System_Design_Quote__c sdq = testData.setupSystemDesignQuotePricing('Residential', funds, false, 12000);
        if (Limits.getQueries() + 1 <= Limits.getLimitQueries())
            testData.createFPP(funds[2].ID);    //Only do it if we can afford the SOQL

        Test.startTest();
        sdq = testData.setupSDQPricingData(sdq, funds);
        update sdq;
        testData.setupLeaseAdjustmentTabel(null, funds[2].ID);
        
        ProposalProcessor pp = new ProposalProcessor();
        //String propID = pp.createProposal(sdq, false, true, true, true, true);
        String propID = pp.createProposal(sdq, false, true, false, false, false, null);
        
        Test.setCurrentPage(Page.CPQproposal);
        ApexPages.currentPage().getParameters().put('id', propID);
        System.assert(propID != null);
        CPQproposalController ctrl = new CPQproposalController();

        ctrl.getPanelProduct();
        ctrl.getLatestSketchUpID();
        ctrl.getNewUtilityBillChartID();
        ctrl.getSolarPortionOfElectricity();
        ctrl.getUtilityRateSavings();
        ctrl.getUtilityRateBefore();
        ctrl.getEstimatedAnnualProduction();
        ctrl.getMonthlyAvgBill_Current();
        ctrl.getMonthlyAvgBill_New();
        ctrl.getMonthlyAvgBill_Savings();
        ctrl.getFirstYearCost_Current();
        ctrl.getFirstYearCost_New();
        ctrl.getFirstYearCost_Savings();
        ctrl.getThe20thYearCost_Current();
        ctrl.getThe20thYearCost_New();
        ctrl.getThe20thYearCost_Savings();
        ctrl.getThe20YearTotal_Current();
        ctrl.getThe20YearTotal_New();
        ctrl.getThe20YearTotal_Savings();
        ctrl.getSolarOffset();
        ctrl.getUtilityRateAfter();
        ctrl.getProductionFactor();

        Test.stopTest();
    }

    @isTest(seeAllData = false) static void testProposalGeneration2(){
        //Create Custom Settings
        testData.setupCustomSettingsPricing();
        testData.setupCustomConfigObjectsPricing();
        
        //Create System Design Quote
        Lease_Fund__c[] funds = testData.createLeaseFunds();    //Fund[0] - SAC Loan, Fund[1] - Term Loan, Fund[2] - Lease, Fund[3] - Term & SAC                        
        System_Design_Quote__c sdq = testData.setupSystemDesignQuotePricing('Residential', funds, false, 12000);
        if (Limits.getQueries() + 1 <= Limits.getLimitQueries())
            testData.createFPP(funds[2].ID);    //Only do it if we can afford the SOQL

        Test.startTest();
        sdq = testData.setupSDQPricingData(sdq, funds);
        update sdq;
        testData.setupLeaseAdjustmentTabel(null, funds[2].ID);
        
        ProposalProcessor pp = new ProposalProcessor();
        String propID = pp.createProposal(sdq, false, false, true, false, false, null);
        
        Test.setCurrentPage(Page.CPQproposal);
        ApexPages.currentPage().getParameters().put('id', propID);
        System.assert(propID != null);
        CPQproposalController ctrl = new CPQproposalController();
        ctrl.getCurrentUtilityBillChartID();
        ctrl.getProductionVsUsageChartID();
        ctrl.getComparativeRatesChartID();
        ctrl.getInverterProduct();
        ctrl.getMountingProduct();
        Test.stopTest();
    }

    @isTest(seeAllData = false) static void testProposalGeneration3(){
        //Create Custom Settings
        testData.setupCustomSettingsPricing();
        testData.setupCustomConfigObjectsPricing();
        
        //Create System Design Quote
        Lease_Fund__c[] funds = testData.createLeaseFunds();    //Fund[0] - SAC Loan, Fund[1] - Term Loan, Fund[2] - Lease, Fund[3] - Term & SAC                        
        System_Design_Quote__c sdq = testData.setupSystemDesignQuotePricing('Residential', funds, false, 12000);
        if (Limits.getQueries() + 1 <= Limits.getLimitQueries())
            testData.createFPP(funds[2].ID);    //Only do it if we can afford the SOQL

        Test.startTest();
        sdq = testData.setupSDQPricingData(sdq, funds);
        update sdq;
        testData.setupLeaseAdjustmentTabel(null, funds[2].ID);
        
        ProposalProcessor pp = new ProposalProcessor();
        String propID = pp.createProposal(sdq, false, false, false, true, true, null);
        
        Test.setCurrentPage(Page.CPQproposal);
        ApexPages.currentPage().getParameters().put('id', propID);
        System.assert(propID != null);
        CPQproposalController ctrl = new CPQproposalController();
        Test.stopTest();
    }

    @isTest(seeAllData = false) static void testProposalGeneration4(){
        //Create Custom Settings
        testData.setupCustomSettingsPricing();
        testData.setupCustomConfigObjectsPricing();
        
        //Create System Design Quote
        Lease_Fund__c[] funds = testData.createLeaseFunds();    //Fund[0] - SAC Loan, Fund[1] - Term Loan, Fund[2] - Lease, Fund[3] - Term & SAC                        
        System_Design_Quote__c sdq = testData.setupSystemDesignQuotePricing('Residential', funds, false, 12000);
        if (Limits.getQueries() + 1 <= Limits.getLimitQueries())
            testData.createFPP(funds[2].ID);    //Only do it if we can afford the SOQL

        Test.startTest();
        sdq = testData.setupSDQPricingData(sdq, funds);
        sdq.Scenario_4_Lease_Option__c = 'One-Pay';
        update sdq;
        testData.setupLeaseAdjustmentTabel(null, funds[2].ID);
        
        ProposalProcessor pp = new ProposalProcessor();
        String propID = pp.createProposal(sdq, false, false, false, false, true, null);
        
        Test.setCurrentPage(Page.CPQproposal);
        ApexPages.currentPage().getParameters().put('id', propID);
        System.assert(propID != null);
        CPQproposalController ctrl = new CPQproposalController();
        Test.stopTest();
    }
}