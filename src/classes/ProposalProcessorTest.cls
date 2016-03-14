/*  FILE: ProposalProcessorTest.cls
    AUTHOR: Dan Kelner
    DATE: 04/20/15
    PURPOSE: Test class for ProposalProcessor
    MODIFICATION HISTORY
        07/22/15  DK  Updates to getNthYearCost(), getTotalOverYears(), and getNetSavings() as per CPQ-573.
*/
@isTest
public class ProposalProcessorTest {

    @isTest(seeAllData = true) static void testProposalCreation1(){
        //Create our test data
        ID sdID = testData.setupSystemDesign('Residential', 'Purchase', null, false, 12000);
        System_Design__c sysDesign = new System_Design__c(ID = sdID);
        update sysDesign;
        System_Design_Quote__c sdq = SalesWorkflowValidationUtility.systemDesignQuoteWorkflowOnCreate(sysDesign);

        sysDesign = [SELECT Default_CB_Panel__r.Utility_Service__r.Method_1_Net_Savings__c FROM System_Design__c WHERE ID = :sysDesign.ID LIMIT 1];
        sdq = [SELECT Scenario_1_First_Month_Payment__c, Scenario_1_Net_Initial_Outlay__c, Scenario_1_Lease_Escalator__c, Scenario_1_Avoided_Utility_Rate__c FROM System_Design_Quote__c WHERE ID = :sdq.ID LIMIT 1];

        Test.startTest();
        //First, create the Proposal and run the included calculations
        ProposalProcessor pp = new ProposalProcessor();
        String propID = pp.createProposal(sdq, true);

        Proposal__c prop = [SELECT Annual_Power_Price_Escalator__c, Scenario_1_Annual_Degradation_Factor__c, Scenario_1_Estimated_Operational_Start_D__c, Scenario_1_Proposal_Term_months__c 
                            FROM Proposal__c WHERE ID = :propID LIMIT 1];

        //Now run through the methods that were not called in the createProposal() procedure
        System.assertEquals(2, pp.getAverageFromSemicolonDelimitedList('1;2;3'));
        System.assertEquals(15, pp.getSumFromSemicolonDelimitedList('4;5;6'));

        Decimal totalBill = 2688.46;    //'266.50;232.50;266.22;232.30;398.54;163.80;170.98;163.80;163.80;163.80;233.46;232.76;';
        System.assertEquals(5664.18, pp.getNthYearCost(totalBill, (Double)prop.Annual_Power_Price_Escalator__c, 20));
        
        pp.getNetSystemPrice(sdq, 1);
        System.assert(pp.getTotalOverYears(totalBill, (Double)prop.Annual_Power_Price_Escalator__c, 20) > 0);

        //Double totalConsumption = sysDesign.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh__c;
        //Double avgPrice = sysDesign.Default_CB_Panel__r.Utility_Service__r.Before_First_Year_Avg_Price__c;
        //Double avoidedRate = sysDesign.Default_CB_Panel__r.Utility_Service__r.Method_1_Avoided_Utility_Rate__c;
        //Double annualProduction = sysDesign.Total_Projected_Annual_Output_kWh_y__c;       
        //Decimal[] netSavings = pp.getNetSavings(totalConsumption, avgPrice, annualProduction, avoidedRate, prop, 20, 1);

        Double method1NetSavings = sysDesign.Default_CB_Panel__r.Utility_Service__r.Method_1_Net_Savings__c;
        Double utilityRateEsc = prop.Annual_Power_Price_Escalator__c / 100.0;
        if (prop.Scenario_1_Annual_Degradation_Factor__c == null)
            prop.Scenario_1_Annual_Degradation_Factor__c = 0.5;
        Double degradeRate = prop.Scenario_1_Annual_Degradation_Factor__c / 100.0;
        Decimal[] netSavings = pp.getNetSavings(method1NetSavings, utilityRateEsc, degradeRate, 20);

        pp.getYearlyCashFlowYearOne(netSavings, prop, sdq, 1);
        pp.getCumulativeCashFlows(netSavings, 20, prop, sdq, 1, 0);
        pp.getAnnualFinancingPayments(prop, sdq, 1, 20);
        pp.getMonthlyAvoidedUtilityRate(prop, sdq, 1, 20);
        pp.getSolarPortionOfElectricity(10, 9);

        Test.stopTest();
    }

    @isTest(seeAllData = false) static void testProposalCreation2(){
        testdata.setupCustomSettingsPricing();
        testdata.setupCustomConfigObjectsPricing();
        
        //Create System Design Quote        
        System_Design_Quote__c sdq = testdata.setupSystemDesignQuote('Residential', 'Purchase', null, false, 12000);

        Test.startTest();
        ProposalProcessor pp = new ProposalProcessor();
        String propID = pp.createProposal(sdq.ID);
        Test.stopTest();
    }

    @isTest(seeAllData = false) static void testProposalSREC(){
        testdata.setupCustomSettingsPricing();
        testdata.setupCustomConfigObjectsPricing();
        
        //Create System Design Quote        
        System_Design_Quote__c sdq = testdata.setupSystemDesignQuote('Residential', 'Purchase', null, false, 12000);
        SREC_Contract_Offer__c srec = testdata.createSRECOffer('Purchase');
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = true;
        sdq.Scenario_1_Lease_Option__c = null;
        sdq.Scenario_1_Term_Loan__c = null;
        sdq.Quoted_SREC_Market__c = srec.SREC_Market__c;
        update sdq;
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = false;

        Test.startTest();
        Test.setCurrentPage(Page.SystemDesignQuoteConfig);
        ApexPages.StandardController standController = new ApexPages.StandardController(sdq);
        SystemDesignQuoteConfigExtension extn = new SystemDesignQuoteConfigExtension(standController);
        //extn.getSRECContOffers('1', null, new List<Available_SREC_Contract_Offer__c>());
        extn.mapSREC = new Map<Id,SREC_Contract_Offer__c>();
        for (SREC_Contract_Offer__c sco : [SELECT Name, Financing_Type__c, Leasing_Option__c, RecordTypeID, 
                                           RecordType.Name, SREC_Market__c, Default_Offer__c FROM SREC_Contract_Offer__c]){
            extn.mapSREC.put(sco.ID, sco);
        }
        extn.createAvailableSREC(srec.ID, '1');

        ProposalProcessor pp = new ProposalProcessor();
        String propID = pp.createProposal(sdq, true);

        Proposal__c prop = [SELECT Annual_Power_Price_Escalator__c, Scenario_1_Annual_Degradation_Factor__c, Scenario_1_Estimated_Operational_Start_D__c, Scenario_1_Proposal_Term_months__c 
                            FROM Proposal__c WHERE ID = :propID LIMIT 1];
        sdq = [SELECT Scenario_1_First_Month_Payment__c, Scenario_1_Net_Initial_Outlay__c, Scenario_1_Lease_Escalator__c, Scenario_1_Avoided_Utility_Rate__c FROM System_Design_Quote__c WHERE ID = :sdq.ID LIMIT 1];

        Double method1NetSavings = 750;     //Doesn't matter
        Double utilityRateEsc = prop.Annual_Power_Price_Escalator__c / 100.0;
        if (prop.Scenario_1_Annual_Degradation_Factor__c == null)
            prop.Scenario_1_Annual_Degradation_Factor__c = 0.5;
        Double degradeRate = prop.Scenario_1_Annual_Degradation_Factor__c / 100.0;
        Decimal[] netSavings = pp.getNetSavings(method1NetSavings, utilityRateEsc, degradeRate, 20);

        pp.getYearlyCashFlowYearOne(netSavings, prop, sdq, 1);  //A lot of code coverage here
        Test.stopTest();
    }
}