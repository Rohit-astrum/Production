/*  FILE: SalesWorkflowValidationUtilityTest.cls
    AUTHOR: Dan Kelner
    DATE: 12/12/14
    PURPOSE: Test the different methods in SalesWorkflowValidationUtility
    MODIFICATION HISTORY
    05/15/15  DK  Hid org data from all test methods.  Commented out assertions for the time being. 
*/
@isTest
public class SalesWorkflowValidationUtilityTest {
    
    @isTest(seeAllData = false) static void systemDesignQuoteTest1() {
        //Set up test SDQ, invoking the SDQ OnInsert Workflow                       
        System_Design_Quote__c sdq = testData.setupSystemDesignQuoteForContract('Residential', 12000);

        Test.startTest();

        System.assertEquals(System_Design_Quote_Settings__c.getOrgDefaults().Default_Scenario_1_Financing_Type__c, sdq.Scenario_1_Financing_Type__c);
        System.assertEquals(System_Design_Quote_Settings__c.getOrgDefaults().Scenario_4_Lease_Option__c, sdq.Scenario_4_Lease_Option__c);

        System_Design__c sd = [SELECT Trenching_Required__c, Trench_Length__c, Vent_Stack_Movement_Required__c, Includes_Outbuilding_Installation__c, Inside_Only_Conduit__c, 
                               Number_of_Locations_with_Tree_Removal__c, System_Panel__c, System_Inverter__c, Default_CB_Panel__r.Utility_Service__c,
                               (SELECT CB_Panel__r.Utility_Service__c FROM System_Design_Arrays__r) FROM System_Design__c WHERE ID = :sdq.System_Design__c LIMIT 1];
        sd.Trenching_Required__c = !sd.Trenching_Required__c;
        sd.Trench_Length__c = 2;    //Might be required
        sd.Vent_Stack_Movement_Required__c = !sd.Vent_Stack_Movement_Required__c;
        sd.Includes_Outbuilding_Installation__c = !sd.Includes_Outbuilding_Installation__c;
        sd.Inside_Only_Conduit__c = !sd.Inside_Only_Conduit__c;
        sd.Number_of_Locations_with_Tree_Removal__c = 99;
        sd.System_Panel__c = null;
        sd.System_Inverter__c = null;
        SystemDesignTriggerHandler.skipSystemDesignTrigger = true;
        update sd;
        SystemDesignTriggerHandler.skipSystemDesignTrigger = false;

        Set<ID> utilServiceIDs = new Set<ID>();
        for (System_Design_Array__c sda : sd.System_Design_Arrays__r){
            utilServiceIDs.add(sda.CB_Panel__r.Utility_Service__c);
        }
        Utility_Service__c[] utilServices = [SELECT Utility_Rate_Code_Before_Solar__c, Utility_Rate_Code_After_Solar__c, Forecasted_Add_Consumption_kWh_Jan__c, 
                                            Forecasted_Add_Consumption_kWh_Feb__c, Forecasted_Add_Consumption_kWh_Mar__c, Forecasted_Add_Consumption_kWh_Apr__c,
                                            Forecasted_Add_Consumption_kWh_May__c, Forecasted_Add_Consumption_kWh_Jun__c, Forecasted_Add_Consumption_kWh_Jul__c,
                                            Forecasted_Add_Consumption_kWh_Aug__c, Forecasted_Add_Consumption_kWh_Sep__c, Forecasted_Add_Consumption_kWh_Oct__c,
                                            Forecasted_Add_Consumption_kWh_Nov__c, Forecasted_Add_Consumption_kWh_Dec__c, Consumption_Profile__c, 
                                            Monthly_Electric_Consumption_kWh_Jan__c, Monthly_Electric_Consumption_kWh_Feb__c, Monthly_Electric_Consumption_kWh_Mar__c, 
                                            Monthly_Electric_Consumption_kWh_Apr__c, Monthly_Electric_Consumption_kWh_May__c, Monthly_Electric_Consumption_kWh_Jun__c, 
                                            Monthly_Electric_Consumption_kWh_Jul__c, Monthly_Electric_Consumption_kWh_Aug__c, Monthly_Electric_Consumption_kWh_Sep__c, 
                                            Monthly_Electric_Consumption_kWh_Oct__c, Monthly_Electric_Consumption_kWh_Nov__c, Monthly_Electric_Consumption_kWh_Dec__c 
                                            FROM Utility_Service__c WHERE ID IN :utilServiceIDs];
        for (Utility_Service__c us : utilServices){
            us.Utility_Rate_Code_Before_Solar__c = null;
            us.Utility_Rate_Code_After_Solar__c = null;
            us.Forecasted_Add_Consumption_kWh_Jan__c = 9999;
            us.Forecasted_Add_Consumption_kWh_Feb__c = 9999;
            us.Forecasted_Add_Consumption_kWh_Mar__c = 9999;
            us.Forecasted_Add_Consumption_kWh_Apr__c = 9999;
            us.Forecasted_Add_Consumption_kWh_May__c = 9999;
            us.Forecasted_Add_Consumption_kWh_Jun__c = 9999;
            us.Forecasted_Add_Consumption_kWh_Jul__c = 9999;
            us.Forecasted_Add_Consumption_kWh_Aug__c = 9999;
            us.Forecasted_Add_Consumption_kWh_Sep__c = 9999;
            us.Forecasted_Add_Consumption_kWh_Oct__c = 9999;
            us.Forecasted_Add_Consumption_kWh_Nov__c = 9999;
            us.Forecasted_Add_Consumption_kWh_Dec__c = 9999;
            us.Consumption_Profile__c = 'new value';
            us.Monthly_Electric_Consumption_kWh_Jan__c = 9999;
            us.Monthly_Electric_Consumption_kWh_Feb__c = 9999;
            us.Monthly_Electric_Consumption_kWh_Mar__c = 9999;
            us.Monthly_Electric_Consumption_kWh_Apr__c = 9999;
            us.Monthly_Electric_Consumption_kWh_May__c = 9999;
            us.Monthly_Electric_Consumption_kWh_Jun__c = 9999;
            us.Monthly_Electric_Consumption_kWh_Jul__c = 9999;
            us.Monthly_Electric_Consumption_kWh_Aug__c = 9999;
            us.Monthly_Electric_Consumption_kWh_Sep__c = 9999;
            us.Monthly_Electric_Consumption_kWh_Oct__c = 9999;
            us.Monthly_Electric_Consumption_kWh_Nov__c = 9999;
            us.Monthly_Electric_Consumption_kWh_Dec__c = 9999;
        }
        update utilServices;

        //-- SDQ OnEdit Workflow --//
        String editResult1 = SalesWorkflowValidationUtility.systemDesignQuoteWorkflowOnEdit(sdq.ID, true);   //Will fail
        Test.stopTest();
    }

    @isTest(seeAllData = false) static void systemDesignQuoteTest2() {
        //Set up test SDQ, invoking the SDQ OnInsert Workflow                       
        System_Design_Quote__c sdq = testData.setupSystemDesignQuoteForContract('Residential', 12000);

        String editResult = SalesWorkflowValidationUtility.systemDesignQuoteWorkflowOnEdit(sdq.ID, true);

        Test.startTest();

        System.assertEquals(System_Design_Quote_Settings__c.getOrgDefaults().Default_Scenario_1_Financing_Type__c, sdq.Scenario_1_Financing_Type__c);
        System.assertEquals(System_Design_Quote_Settings__c.getOrgDefaults().Scenario_4_Lease_Option__c, sdq.Scenario_4_Lease_Option__c);

        //Check that the object serialization methods did not fail
        //System.assert(sdq.System_Design_Reconstruction_Record__c != null);
        //System.assert(sdq.System_Design_Stored_State__c != null);

        //-- SDQ OnComplete Workflow --//
        sdq.Valid__c = false;
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = true;
        update sdq;
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = false;
        String[] completeResult = SalesWorkflowValidationUtility.systemDesignQuoteWorkflowOnComplete(sdq.ID);   //Won't pass yet

        sdq.Valid__c = true;
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = true;
        update sdq;
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = false;
        System_Design__c sysDesign = [SELECT Astrum_SQ_Calculation_Status__c FROM System_Design__c LIMIT 1];
        sysDesign.Astrum_SQ_Calculation_Status__c = 'Valid';
        update sysDesign;

        completeResult = SalesWorkflowValidationUtility.systemDesignQuoteWorkflowOnComplete(sdq.ID);

        sdq = [SELECT Open_Quote__c, System_Design__r.Open_Quote__c FROM System_Design_Quote__c WHERE ID = :sdq.ID LIMIT 1];

        System.assertEquals('Valid', completeResult[0]);
        String newPropID = completeResult[1];
        Proposal__c prop = [SELECT SDQ_Reconstruction_Record__c FROM Proposal__c WHERE ID = :newPropID];
        System.assertEquals(true, sdq.Open_Quote__c);
        System.assertEquals(true, sdq.System_Design__r.Open_Quote__c);
        System.assert(prop.SDQ_Reconstruction_Record__c != null);
        Test.stopTest();
    }

    @isTest(seeAllData = false) static void systemDesignQuoteTest3() {
        System_Design_Quote__c sdq = testData.setupSystemDesignQuoteForContract('Residential', 12000);

        System.assertEquals(0.05, SalesWorkflowValidationUtility.getPercent(5, 0));

        Test.startTest();
        //-- SDQ MakeCurrent Workflow --//
        String currentResult = SalesWorkflowValidationUtility.systemDesignQuoteWorkflowMakeCurrent(sdq.ID);
        System.assertEquals('Valid', currentResult);
        sdq = [SELECT Current__c, Valid__c FROM System_Design_Quote__c WHERE ID = :sdq.ID LIMIT 1];
        System.assertEquals(true, sdq.Current__c);
        Test.stopTest();
    }

    @isTest(seeAllData = false) static void systemDesignQuoteAsOfPricingTest() {
        //Test a historic value for sdq.Pricing_Date__c that will result in Pricing Region being matched from the County record instead of Utility by Zip Code                  
        System_Design_Quote__c sdq = testData.setupSystemDesignQuoteForContract('Residential', 12000);
        String editResult = SalesWorkflowValidationUtility.systemDesignQuoteWorkflowOnEdit(sdq.ID, true);

        Test.startTest();
        sdq.Valid__c = false;
        sdq.Pricing_Date__c = Date.newInstance(2015, 11, 30);   //Test CPQ-751. This is the only thing being tested in this method.
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = true;
        update sdq;
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = false;
        String[] completeResult = SalesWorkflowValidationUtility.systemDesignQuoteWorkflowOnComplete(sdq.ID);   //Doesn't matter if it passes
        Test.stopTest();
    }

    @isTest(seeAllData = false) static void proposalTest1() {
        //Create Custom Settings
        testData.setupCustomSettingsPricing();
        testData.setupCustomConfigObjectsPricing();
        
        //Create System Design Quote
        Lease_Fund__c[] funds = testData.createLeaseFunds();    //Fund[0] - SAC Loan, Fund[1] - Term Loan, Fund[2] - Lease, Fund[3] - Term & SAC                        
        System_Design_Quote__c sdq = testData.setupSystemDesignQuotePricing('Residential', funds, false, 12000);

        Test.startTest();
        //Proposal OnCreate Workflow has already been covered in the SDQ test methods. Simply create a Proposal here to begin testing.
        Proposal__c prop = new Proposal__c(System_Design_Quote__c = sdq.ID);
        SalesWorkflowValidationUtility.serializeReconstructionProposal(prop);  //Serialize the SDQ on the Proposal
        insert prop;

        sdq.Scenario_1_Included_in_Proposal__c = true;
        sdq.Scenario_2_Included_in_Proposal__c = true;
        update sdq;

        System_Design__c sysDesign = [SELECT Astrum_SQ_Calculation_Status__c FROM System_Design__c LIMIT 1];
        sysDesign.Astrum_SQ_Calculation_Status__c = 'Valid';
        update sysDesign;

        //-- Proposal OnComplete Workflow --//
        String completeResult = SalesWorkflowValidationUtility.proposalWorkflowOnComplete(prop.ID);
        System.assertEquals('Valid', completeResult);
        prop = [SELECT Current__c, Valid__c FROM Proposal__c WHERE ID = :prop.ID LIMIT 1];
        System.assertEquals(true, prop.Current__c);
        System.assertEquals(true, prop.Valid__c);

        Test.stopTest();
    }

    @isTest(seeAllData = false) static void proposalTest2() {
        //Create Custom Settings
        testData.setupCustomSettingsPricing();
        testData.setupCustomConfigObjectsPricing();
        
        //Create System Design Quote
        Lease_Fund__c[] funds = testData.createLeaseFunds();    //Fund[0] - SAC Loan, Fund[1] - Term Loan, Fund[2] - Lease, Fund[3] - Term & SAC                        
        System_Design_Quote__c sdq = testData.setupSystemDesignQuotePricing('Residential', funds, false, 12000);
        
        Test.startTest();
        Proposal__c prop = new Proposal__c(System_Design_Quote__c = sdq.ID);
        SalesWorkflowValidationUtility.serializeReconstructionProposal(prop);  //Serialize the SDQ on the Proposal
        insert prop;
        
        System_Design__c sysDesign = [SELECT Astrum_SQ_Calculation_Status__c FROM System_Design__c LIMIT 1];
        sysDesign.Astrum_SQ_Calculation_Status__c = 'Valid';
        SystemDesignTriggerHandler.skipSystemDesignTrigger = true;
        update sysDesign;
        SystemDesignTriggerHandler.skipSystemDesignTrigger = false;

        //-- Proposal MakeCurrent Workflow --//
        String currentResult = SalesWorkflowValidationUtility.proposalWorkflowMakeCurrent(prop.ID);
        //System.assertEquals('Valid', currentResult);
        prop = [SELECT Current__c, Valid__c FROM Proposal__c WHERE ID = :prop.ID LIMIT 1];
        System.assertEquals(true, prop.Current__c);
        //System.assertEquals(true, prop.Valid__c);

        Test.stopTest();
    }
    
    @isTest(seeAllData = false) static void contractTest1() {
        //Create Custom Settings
        testData.setupCustomSettingsPricing();
        testData.setupCustomConfigObjectsPricing();
        
        //Create System Design Quote
        Lease_Fund__c[] funds = testData.createLeaseFunds();    //Fund[0] - SAC Loan, Fund[1] - Term Loan, Fund[2] - Lease, Fund[3] - Term & SAC                        
        System_Design_Quote__c sdq = testData.setupSystemDesignQuotePricing('Residential', funds, false, 12000);

        System.debug('Number of queries used in this method so far: ' + Limits.getQueries());

        Test.startTest();        
        Proposal__c prop = new Proposal__c(System_Design_Quote__c = sdq.ID, Valid__c = true);
        SalesWorkflowValidationUtility.serializeReconstructionProposal(prop);
        insert prop;

        Astrum_Contract__c[] contracts = new Astrum_Contract__c[]{};
        for (Integer i = 0; i < 4; i++){
            contracts.add(new Astrum_Contract__c(Proposal__c = prop.ID, Open_Quote__c = true, Current__c = true, Closed__c = false));
        }
        insert contracts;
        Astrum_Contract__c con = contracts[0];

        //-- Contract OnComplete Workflow --//
        String completeResult = SalesWorkflowValidationUtility.contractWorkflowOnComplete(con.ID);
        System.assertEquals('Valid', completeResult);
        contracts = [SELECT Current__c FROM Astrum_Contract__c WHERE ID != :con.ID ORDER BY CreatedDate DESC LIMIT 3];
        for (Astrum_Contract__c contr : contracts){
            System.assertEquals(false, contr.Current__c);
        }
        
        Test.stopTest();
    }
        
    @isTest(seeAllData = false) static void contractTest2() {
        //Create Custom Settings
        testData.setupCustomSettingsPricing();
        testData.setupCustomConfigObjectsPricing();
        
        //Create System Design Quote
        Lease_Fund__c[] funds = testData.createLeaseFunds();    //Fund[0] - SAC Loan, Fund[1] - Term Loan, Fund[2] - Lease, Fund[3] - Term & SAC                        
        System_Design_Quote__c sdq = testData.setupSystemDesignQuotePricing('Residential', funds, false, 12000);

        Test.startTest();
        Proposal__c prop = new Proposal__c(System_Design_Quote__c = sdq.ID, Valid__c = true);
        SalesWorkflowValidationUtility.serializeReconstructionProposal(prop);
        insert prop;

        Astrum_Contract__c[] contracts = new Astrum_Contract__c[]{};
        for (Integer i = 0; i < 4; i++){
            contracts.add(new Astrum_Contract__c(Proposal__c = prop.ID, Open_Quote__c = true, Current__c = true, Closed__c = false));
        }
        insert contracts;
        Astrum_Contract__c con = contracts[0];

        //-- Contract OnAccepted Workflow --//
        String acceptedResult = SalesWorkflowValidationUtility.contractWorkflowOnAccepted(con.ID);
        System.assertEquals('Valid', acceptedResult);
        prop = [SELECT Closed__c, System_Design_Quote__r.Closed__c, System_Design_Quote__r.System_Design__r.Closed__c FROM Proposal__c WHERE ID = :prop.ID LIMIT 1];
        System.assertEquals(true, prop.Closed__c);
        System.assertEquals(true, prop.System_Design_Quote__r.Closed__c);
        System.assertEquals(true, prop.System_Design_Quote__r.System_Design__r.Closed__c);
        Test.stopTest();
    }

    @isTest(seeAllData = false) static void deserializeTest1() {
        //Create Custom Settings
        testData.setupCustomSettingsPricing();
        testData.setupCustomConfigObjectsPricing();
        
        //Create System Design Quote
        Lease_Fund__c[] funds = testData.createLeaseFunds();    //Fund[0] - SAC Loan, Fund[1] - Term Loan, Fund[2] - Lease, Fund[3] - Term & SAC                        
        System_Design_Quote__c sdq = testData.setupSystemDesignQuotePricing('Residential', funds, false, 12000);

        Test.startTest();
        
        sdq = testData.setupSDQPricingData(sdq, funds);
        update sdq;

        Proposal__c prop = new Proposal__c(System_Design_Quote__c = sdq.ID, Valid__c = true);
        SalesWorkflowValidationUtility.serializeReconstructionProposal(prop);
        insert prop;

        SalesWorkflowValidationUtility.proposalWorkflowMakeCurrent(prop.ID);
        
        Test.stopTest();
    }

    @isTest(seeAllData = false) static void deserializeTest2() {
        //Create Custom Settings
        testData.setupCustomSettingsPricing();
        testData.setupCustomConfigObjectsPricing();
        
        //Create System Design Quote
        Lease_Fund__c[] funds = testData.createLeaseFunds();    //Fund[0] - SAC Loan, Fund[1] - Term Loan, Fund[2] - Lease, Fund[3] - Term & SAC                        
        System_Design_Quote__c sdq = testData.setupSystemDesignQuotePricing('Residential', funds, false, 12000);

        Test.startTest();
        
        sdq = testData.setupSDQPricingData(sdq, funds);
        update sdq;

        Proposal__c prop = new Proposal__c(System_Design_Quote__c = sdq.ID, Valid__c = true);
        SalesWorkflowValidationUtility.serializeReconstructionProposal(prop);
        insert prop;

        //More code coverage. Thanks Salesforce!
        sdq.Channel_Partner__c = !sdq.Channel_Partner__c;
        sdq.Channel_Partner_Lease_Rate_kWh__c = 999;
        sdq.Primary_Residence__c = !sdq.Primary_Residence__c;
        sdq.Property_in_Revocable_Trust__c = !sdq.Property_in_Revocable_Trust__c;
        sdq.Natural_Disaster_Adder_Eligible__c = !sdq.Natural_Disaster_Adder_Eligible__c;
        sdq.Moderate_Home_Value_Adder_Eligible__c = !sdq.Moderate_Home_Value_Adder_Eligible__c;
        sdq.Previously_Received_County_Tax_Credit__c = !sdq.Previously_Received_County_Tax_Credit__c;
        sdq.Previously_Received_State_Rebate__c = !sdq.Previously_Received_State_Rebate__c;
        sdq.Previously_Received_State_Tax_Credit__c = !sdq.Previously_Received_State_Tax_Credit__c;
        sdq.Previously_Received_Utility_Rebate__c = !sdq.Previously_Received_Utility_Rebate__c;
        sdq.Moderate_Income_Value_Adder_Eligible__c = !sdq.Moderate_Income_Value_Adder_Eligible__c;
        sdq.Scenario_1_Financing_Type__c = 'new value';
        sdq.Scenario_2_Financing_Type__c = 'new value';
        sdq.Scenario_3_Financing_Type__c = 'new value';
        sdq.Scenario_4_Financing_Type__c = 'new value';
        sdq.Scenario_1_Lease_Fund__c = funds[2].ID;
        sdq.Scenario_2_Lease_Fund__c = funds[2].ID;
        sdq.Scenario_3_Lease_Fund__c = funds[2].ID;
        sdq.Scenario_4_Lease_Fund__c = null;
        sdq.Scenario_1_Term_Loan__c = null;
        sdq.Scenario_2_Term_Loan__c = funds[1].ID;
        sdq.Scenario_3_Term_Loan__c = null;
        sdq.Scenario_4_Term_Loan__c = funds[1].ID;
        sdq.Scenario_1_SAC_Loan__c = funds[0].ID;
        sdq.Scenario_2_SAC_Loan__c = null;
        sdq.Scenario_3_SAC_Loan__c = null;
        sdq.Scenario_4_SAC_Loan__c = funds[3].ID;
        sdq.Scenario_1_Lease_Escalator__c = '1';
        sdq.Scenario_2_Lease_Escalator__c = '1';
        sdq.Scenario_3_Lease_Escalator__c = '1';
        sdq.Scenario_4_Lease_Escalator__c = '1';
        sdq.Scenario_1_Credit_Tier__c = 'new value';
        sdq.Scenario_2_Credit_Tier__c = 'new value';
        sdq.Scenario_3_Credit_Tier__c = 'new value';
        sdq.Scenario_4_Credit_Tier__c = 'new value';
        sdq.Scenario_1_Financing_Option__c = 'new value';
        sdq.Scenario_2_Financing_Option__c = 'new value';
        sdq.Scenario_3_Financing_Option__c = 'new value';
        sdq.Scenario_4_Financing_Option__c = 'new value';
        sdq.Scenario_1_Lease_Option__c = 'new value';
        sdq.Scenario_2_Lease_Option__c = 'new value';
        sdq.Scenario_3_Lease_Option__c = 'new value';
        sdq.Scenario_4_Lease_Option__c = 'new value';
        sdq.Scenario_1_Down_Payment__c = 999;
        sdq.Scenario_2_Down_Payment__c = 999;
        sdq.Scenario_3_Down_Payment__c = 999;
        sdq.Scenario_4_Down_Payment__c = 999;
        sdq.Scenario_1_Apply_Standard_Adjustment__c = !sdq.Scenario_1_Apply_Standard_Adjustment__c;
        sdq.Scenario_2_Apply_Standard_Adjustment__c = !sdq.Scenario_2_Apply_Standard_Adjustment__c;
        sdq.Scenario_3_Apply_Standard_Adjustment__c = !sdq.Scenario_3_Apply_Standard_Adjustment__c;
        sdq.Scenario_4_Apply_Standard_Adjustment__c = !sdq.Scenario_4_Apply_Standard_Adjustment__c;
        sdq.Scenario_1_Set_Standard_Adjustment_Type__c = 'new value';
        sdq.Scenario_2_Set_Standard_Adjustment_Type__c = 'new value';
        sdq.Scenario_3_Set_Standard_Adjustment_Type__c = 'new value';
        sdq.Scenario_4_Set_Standard_Adjustment_Type__c = 'new value';
        sdq.Scenario_1_Set_Standard_Adjustment_Amoun__c = 999;
        sdq.Scenario_2_Set_Standard_Adjustment_Amoun__c = 999;
        sdq.Scenario_3_Set_Standard_Adjustment_Amoun__c = 999;
        sdq.Scenario_4_Set_Standard_Adjustment_Amoun__c = 999;
        sdq.Scenario_1_VP_Sales_Adjustments__c = 999;
        sdq.Scenario_2_VP_Sales_Adjustments__c = 999;
        sdq.Scenario_3_VP_Sales_Adjustments__c = 999;
        sdq.Scenario_4_VP_Sales_Adjustments__c = 999;
        sdq.Annual_Property_Tax_Bill__c = 999;
        sdq.Income_Corporate_Tax_Rate__c = 999;
        sdq.Utility_Annual_Increase__c = 999;

        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = true;
        update sdq;
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = false;

        SalesWorkflowValidationUtility.deserializeReconstructionProposal(prop, false);  //For code coverage
        
        Test.stopTest();
    }

    @isTest(seeAllData = false) static void deserializeTest3() {
        //Create Custom Settings
        testData.setupCustomSettingsPricing();
        testData.setupCustomConfigObjectsPricing();
        
        //Create System Design Quote
        Lease_Fund__c[] funds = testData.createLeaseFunds();    //Fund[0] - SAC Loan, Fund[1] - Term Loan, Fund[2] - Lease, Fund[3] - Term & SAC                        
        System_Design_Quote__c sdq = testData.setupSystemDesignQuotePricing('Residential', funds, false, 12000);

        Test.startTest();
        
        sdq = testData.setupSDQPricingData(sdq, funds);
        update sdq;

        Proposal__c prop = new Proposal__c(System_Design_Quote__c = sdq.ID, Valid__c = true);
        SalesWorkflowValidationUtility.serializeReconstructionProposal(prop);
        insert prop;

        //More code coverage. Thanks Salesforce!
        sdq.Channel_Partner__c = !sdq.Channel_Partner__c;
        sdq.Channel_Partner_Lease_Rate_kWh__c = 999;
        sdq.Primary_Residence__c = !sdq.Primary_Residence__c;
        sdq.Property_in_Revocable_Trust__c = !sdq.Property_in_Revocable_Trust__c;
        sdq.Natural_Disaster_Adder_Eligible__c = !sdq.Natural_Disaster_Adder_Eligible__c;
        sdq.Moderate_Home_Value_Adder_Eligible__c = !sdq.Moderate_Home_Value_Adder_Eligible__c;
        sdq.Previously_Received_County_Tax_Credit__c = !sdq.Previously_Received_County_Tax_Credit__c;
        sdq.Previously_Received_State_Rebate__c = !sdq.Previously_Received_State_Rebate__c;
        sdq.Previously_Received_State_Tax_Credit__c = !sdq.Previously_Received_State_Tax_Credit__c;
        sdq.Previously_Received_Utility_Rebate__c = !sdq.Previously_Received_Utility_Rebate__c;
        sdq.Moderate_Income_Value_Adder_Eligible__c = !sdq.Moderate_Income_Value_Adder_Eligible__c;
        sdq.Scenario_1_Financing_Type__c = 'new value';
        sdq.Scenario_2_Financing_Type__c = 'new value';
        sdq.Scenario_3_Financing_Type__c = 'new value';
        sdq.Scenario_4_Financing_Type__c = 'new value';
        sdq.Scenario_1_Lease_Fund__c = funds[2].ID;
        sdq.Scenario_2_Lease_Fund__c = funds[2].ID;
        sdq.Scenario_3_Lease_Fund__c = funds[2].ID;
        sdq.Scenario_4_Lease_Fund__c = null;
        sdq.Scenario_1_Term_Loan__c = null;
        sdq.Scenario_2_Term_Loan__c = funds[1].ID;
        sdq.Scenario_3_Term_Loan__c = null;
        sdq.Scenario_4_Term_Loan__c = funds[1].ID;
        sdq.Scenario_1_SAC_Loan__c = funds[0].ID;
        sdq.Scenario_2_SAC_Loan__c = null;
        sdq.Scenario_3_SAC_Loan__c = null;
        sdq.Scenario_4_SAC_Loan__c = funds[3].ID;
        sdq.Scenario_1_Lease_Escalator__c = '1';
        sdq.Scenario_2_Lease_Escalator__c = '1';
        sdq.Scenario_3_Lease_Escalator__c = '1';
        sdq.Scenario_4_Lease_Escalator__c = '1';
        sdq.Scenario_1_Credit_Tier__c = 'new value';
        sdq.Scenario_2_Credit_Tier__c = 'new value';
        sdq.Scenario_3_Credit_Tier__c = 'new value';
        sdq.Scenario_4_Credit_Tier__c = 'new value';
        sdq.Scenario_1_Financing_Option__c = 'new value';
        sdq.Scenario_2_Financing_Option__c = 'new value';
        sdq.Scenario_3_Financing_Option__c = 'new value';
        sdq.Scenario_4_Financing_Option__c = 'new value';
        sdq.Scenario_1_Lease_Option__c = 'new value';
        sdq.Scenario_2_Lease_Option__c = 'new value';
        sdq.Scenario_3_Lease_Option__c = 'new value';
        sdq.Scenario_4_Lease_Option__c = 'new value';
        sdq.Scenario_1_Down_Payment__c = 999;
        sdq.Scenario_2_Down_Payment__c = 999;
        sdq.Scenario_3_Down_Payment__c = 999;
        sdq.Scenario_4_Down_Payment__c = 999;
        sdq.Scenario_1_Apply_Standard_Adjustment__c = !sdq.Scenario_1_Apply_Standard_Adjustment__c;
        sdq.Scenario_2_Apply_Standard_Adjustment__c = !sdq.Scenario_2_Apply_Standard_Adjustment__c;
        sdq.Scenario_3_Apply_Standard_Adjustment__c = !sdq.Scenario_3_Apply_Standard_Adjustment__c;
        sdq.Scenario_4_Apply_Standard_Adjustment__c = !sdq.Scenario_4_Apply_Standard_Adjustment__c;
        sdq.Scenario_1_Set_Standard_Adjustment_Type__c = 'new value';
        sdq.Scenario_2_Set_Standard_Adjustment_Type__c = 'new value';
        sdq.Scenario_3_Set_Standard_Adjustment_Type__c = 'new value';
        sdq.Scenario_4_Set_Standard_Adjustment_Type__c = 'new value';
        sdq.Scenario_1_Set_Standard_Adjustment_Amoun__c = 999;
        sdq.Scenario_2_Set_Standard_Adjustment_Amoun__c = 999;
        sdq.Scenario_3_Set_Standard_Adjustment_Amoun__c = 999;
        sdq.Scenario_4_Set_Standard_Adjustment_Amoun__c = 999;
        sdq.Scenario_1_VP_Sales_Adjustments__c = 999;
        sdq.Scenario_2_VP_Sales_Adjustments__c = 999;
        sdq.Scenario_3_VP_Sales_Adjustments__c = 999;
        sdq.Scenario_4_VP_Sales_Adjustments__c = 999;
        sdq.Annual_Property_Tax_Bill__c = 999;
        sdq.Income_Corporate_Tax_Rate__c = 999;
        sdq.Utility_Annual_Increase__c = 999;

        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = true;
        update sdq;
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = false;

        SalesWorkflowValidationUtility.deserializeReconstructionProposal(prop, true);
        
        Test.stopTest();
    }

    @isTest(seeAllData = false) static void codeCoverageTest() {
        //Create Custom Settings
        testData.setupCustomSettingsPricing();
        testData.setupCustomConfigObjectsPricing();
        
        //Create System Design Quote
        Lease_Fund__c[] funds = testData.createLeaseFunds();    //Fund[0] - SAC Loan, Fund[1] - Term Loan, Fund[2] - Lease, Fund[3] - Term & SAC                        
        System_Design_Quote__c sdq = testData.setupSystemDesignQuotePricing('Residential', funds, true, 12000);

        Test.startTest();
        sdq = testData.setupSDQPricingData(sdq, funds);
        sdq.Scenario_3_Financing_Type__c = 'Lease';
        sdq.Scenario_3_Lease_Fund__c = funds[2].ID;
        sdq.Scenario_3_Lease_Option__c = 'Low-Upfront - Monthly';
        update sdq;
        
        sdq = Database.query('SELECT ' + SalesWorkflowValidationUtility.validationFieldsForSDQ + ' FROM System_Design_Quote__c WHERE ID = \'' + sdq.ID + '\' LIMIT 1');

        Proposal__c prop = new Proposal__c(System_Design_Quote__c = sdq.ID, Valid__c = true);
        insert prop;

        SalesWorkflowValidationUtility.validateSavings(sdq, funds[1], 2);

        Map<Integer, Boolean> includedScenarios = new Map<Integer, Boolean>{1 => true, 2 => false, 3 => true, 4 => false};
        SalesWorkflowValidationUtility.systemDesignQuoteValidations(sdq, false, includedScenarios);

        System_Design__c sysDesign = new System_Design__c(ID = sdq.System_Design__c);
        SalesWorkflowValidationUtility.validateSystemDesign(sysDesign, false, Date.today());
        Test.stopTest();
    }
}