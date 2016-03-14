/*  FILE: PreviewProposalTest
    AUTHOR: Dan Kelner
    DATE: 04/13/15
    PURPOSE: Test class for PreviewProposalCtrl
    MODIFICATION HISTORY
*/
@isTest
public class PreviewProposalTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out
    
     @isTest(seeAllData = false) static void controllerTest1(){
        if(!runalltests){ return; }

        //Create our test data
        testData.setupCustomSettings();
        testdata.setupCustomConfigObjects();

        ID sdID = testData.setupSystemDesign('Residential', 'Purchase', null, false, 12000);
        System_Design__c sysDesign = new System_Design__c(ID = sdID);
        update sysDesign;

        System_Design_Quote__c sdq = new System_Design_Quote__c(System_Design__c = sysDesign.ID, Current__c = true);
        insert sdq;

        Proposal__c prop1 = new Proposal__c(System_Design_Quote__c = sdq.ID);
        Proposal__c prop2 = new Proposal__c(System_Design_Quote__c = sdq.ID);
        insert new Proposal__c[]{prop1, prop2};

        Astrum_Contract__c contr1 = new Astrum_Contract__c(Proposal__c = prop1.ID, Scenario__c = '1', Property_State__c = 'CA');
        Astrum_Contract__c contr2 = new Astrum_Contract__c(Proposal__c = prop1.ID, Scenario__c = '2', Property_State__c = 'CA');
        Astrum_Contract__c contr3 = new Astrum_Contract__c(Proposal__c = prop1.ID, Scenario__c = '3', Property_State__c = 'CA');
        Astrum_Contract__c contr4 = new Astrum_Contract__c(Proposal__c = prop1.ID, Scenario__c = '4', Property_State__c = 'CA');
        insert new Astrum_Contract__c[]{contr1, contr2, contr3, contr4};

        Test.startTest();
        Test.setCurrentPage(Page.PreviewProposal);
        PreviewProposalCtrl ctrl = new PreviewProposalCtrl(new ApexPages.StandardController(prop2));
        ApexPages.currentPage().getParameters().put('proposalID', prop1.ID);
        ctrl.switchProposal();
        ctrl.getPanelProduct();
        ctrl.getProperty();
        ApexPages.currentPage().getParameters().put('scenarioNum', '1');
        ctrl.saveContractPDF();
        ctrl.goToProposalPDF();
        ctrl.saveProposalPDF();
        Test.stopTest();
     }

     @isTest(seeAllData = false) static void controllerTest2(){
        if(!runalltests){ return; }

        System_Design_Quote__c sdq = testData.setupSystemDesignQuoteForContract('Residential', 12000);

        Proposal__c prop = new Proposal__c(System_Design_Quote__c = sdq.ID);
        insert prop;

        Astrum_Contract__c contr1 = new Astrum_Contract__c(Proposal__c = prop.ID, Scenario__c = '1', Property_State__c = 'CA');
        Astrum_Contract__c contr2 = new Astrum_Contract__c(Proposal__c = prop.ID, Scenario__c = '2', Property_State__c = 'CA');
        Astrum_Contract__c contr3 = new Astrum_Contract__c(Proposal__c = prop.ID, Scenario__c = '3', Property_State__c = 'CA');
        Astrum_Contract__c contr4 = new Astrum_Contract__c(Proposal__c = prop.ID, Scenario__c = '4', Property_State__c = 'CA');
        insert new Astrum_Contract__c[]{contr1, contr2, contr3, contr4};

        Test.startTest();
        Test.setCurrentPage(Page.PreviewProposal);
        PreviewProposalCtrl ctrl = new PreviewProposalCtrl(new ApexPages.StandardController(prop));
        ApexPages.currentPage().getParameters().put('proposalID', prop.ID);
        ctrl.makeProposalCurrent();
        Test.stopTest();
     }

     @isTest(seeAllData = false) static void controllerTest3(){
        if(!runalltests){ return; }

        System_Design_Quote__c sdq = testData.setupSystemDesignQuoteForContract('Residential', 12000);

        Proposal__c prop = new Proposal__c(System_Design_Quote__c = sdq.ID);
        insert prop;

        Astrum_Contract__c contr1 = new Astrum_Contract__c(Proposal__c = prop.ID, Scenario__c = '1', Property_State__c = 'CA');
        Astrum_Contract__c contr2 = new Astrum_Contract__c(Proposal__c = prop.ID, Scenario__c = '2', Property_State__c = 'CA');
        Astrum_Contract__c contr3 = new Astrum_Contract__c(Proposal__c = prop.ID, Scenario__c = '3', Property_State__c = 'CA');
        Astrum_Contract__c contr4 = new Astrum_Contract__c(Proposal__c = prop.ID, Scenario__c = '4', Property_State__c = 'CA');
        insert new Astrum_Contract__c[]{contr1, contr2, contr3, contr4};

        Test.startTest();
        Test.setCurrentPage(Page.PreviewProposal);
        PreviewProposalCtrl ctrl = new PreviewProposalCtrl(new ApexPages.StandardController(prop));
        ApexPages.currentPage().getParameters().put('proposalID', prop.ID);
        ctrl.getInverterProduct();
        Astrum_Contract__c c1 = ctrl.contr1;
        Astrum_Contract__c c2 = ctrl.contr2;
        Astrum_Contract__c c3 = ctrl.contr3;
        Astrum_Contract__c c4 = ctrl.contr4;

        ApexPages.currentPage().getParameters().put('scenarioNum', '2');
        ctrl.saveContractPDF();

        ApexPages.currentPage().getParameters().put('scenarioNum', '3');
        ctrl.saveContractPDF();

        ApexPages.currentPage().getParameters().put('scenarioNum', '4');
        ctrl.saveContractPDF();

        Test.stopTest();
     }

    @isTest static void sightenInitiateCreditCheck(){
        if(!runalltests){ return; }

        testdata.setupCustomSettingsPricing();
        testdata.setupCustomConfigObjectsPricing();

        //Create our test data
        SightenTestUtility.createSightenCustomSettings();
        
        //Create System Design Quote        
        Opportunity_Trigger_Utility.skipOpportunityTrigger = true;
        System_Design_Quote__c sdq = testdata.setupSystemDesignQuote('Residential', 'Purchase', null, true, 12000);
        Opportunity_Trigger_Utility.skipOpportunityTrigger = false;

        // Add values to the Sighten uuid field for the lease fund
        SightenTestUtility.AddSightenUUIDValues(sdq);

        System_Design_Quote__c sdqTermLoan = [SELECT Id, Scenario_1_Term_Loan__c, Scenario_1_Term_Loan__r.Sighten_Product_uuid__c FROM System_Design_Quote__c WHERE Id = :sdq.Id LIMIT 1];

        Proposal__c prop = new Proposal__c(System_Design_Quote__c = sdq.ID);
        insert prop;

        Test.startTest();
        Test.setCurrentPage(Page.PreviewProposal);
        Test.setMock(HttpCalloutMock.class, new SightenTestCalloutMock(200));

        PreviewProposalCtrl ctrl = new PreviewProposalCtrl(new ApexPages.StandardController(prop));
        ctrl.buttonScenario = '1';

        ctrl.initiateCreditCheck();
        
        Test.stopTest();
    }

    @isTest static void sightenInitiateCreditCheckError(){
        if(!runalltests){ return; }

        testdata.setupCustomSettingsPricing();
        testdata.setupCustomConfigObjectsPricing();

        //Create our test data
        SightenTestUtility.createSightenCustomSettings();
        
        //Create System Design Quote        
        Opportunity_Trigger_Utility.skipOpportunityTrigger = true;
        System_Design_Quote__c sdq = testdata.setupSystemDesignQuote('Residential', 'Purchase', null, true, 12000);
        Opportunity_Trigger_Utility.skipOpportunityTrigger = false;

        // Add values to the Sighten uuid field for the lease fund
        SightenTestUtility.AddSightenUUIDValues(sdq);

        System_Design_Quote__c sdqTermLoan = [SELECT Id, Scenario_1_Term_Loan__c, Scenario_1_Term_Loan__r.Sighten_Product_uuid__c FROM System_Design_Quote__c WHERE Id = :sdq.Id LIMIT 1];

        Proposal__c prop = new Proposal__c(System_Design_Quote__c = sdq.ID);
        insert prop;

        Test.startTest();
        Test.setCurrentPage(Page.PreviewProposal);
        Test.setMock(HttpCalloutMock.class, new SightenTestCalloutMock(400));

        PreviewProposalCtrl ctrl = new PreviewProposalCtrl(new ApexPages.StandardController(prop));
        ctrl.buttonScenario = '1';

        ctrl.initiateCreditCheck();
        
        Test.stopTest();
    }

    @isTest static void sightenUpdateCreditCheck(){
        if(!runalltests){ return; }

        testdata.setupCustomSettingsPricing();
        testdata.setupCustomConfigObjectsPricing();

        //Create our test data
        SightenTestUtility.createSightenCustomSettings();
        
        //Create System Design Quote        
        Opportunity_Trigger_Utility.skipOpportunityTrigger = true;
        System_Design_Quote__c sdq = testdata.setupSystemDesignQuote('Residential', 'Purchase', null, true, 12000);
        Opportunity_Trigger_Utility.skipOpportunityTrigger = false;

        // Add values to the Sighten uuid field for the lease fund
        SightenTestUtility.AddSightenUUIDValues(sdq);

        System_Design_Quote__c sdqTermLoan = [SELECT Id, Scenario_1_Term_Loan__c, Scenario_1_Term_Loan__r.Sighten_Product_uuid__c FROM System_Design_Quote__c WHERE Id = :sdq.Id LIMIT 1];

        Proposal__c prop = new Proposal__c(System_Design_Quote__c = sdq.ID, Scenario_1_Included__c = true);
        insert prop;

        Test.startTest();
        Test.setCurrentPage(Page.PreviewProposal);
        Test.setMock(HttpCalloutMock.class, new SightenTestCalloutMock(200));

        PreviewProposalCtrl ctrl = new PreviewProposalCtrl(new ApexPages.StandardController(prop));
        ctrl.buttonScenario = '1';

        ctrl.updateCreditStatus();
        
        Test.stopTest();
    }

    @isTest static void sightenUpdateCreditCheckError(){
        if(!runalltests){ return; }

        testdata.setupCustomSettingsPricing();
        testdata.setupCustomConfigObjectsPricing();

        //Create our test data
        SightenTestUtility.createSightenCustomSettings();
        
        //Create System Design Quote        
        Opportunity_Trigger_Utility.skipOpportunityTrigger = true;
        System_Design_Quote__c sdq = testdata.setupSystemDesignQuote('Residential', 'Purchase', null, true, 12000);
        Opportunity_Trigger_Utility.skipOpportunityTrigger = false;

        // Add values to the Sighten uuid field for the lease fund
        SightenTestUtility.AddSightenUUIDValues(sdq);

        System_Design_Quote__c sdqTermLoan = [SELECT Id, Scenario_1_Term_Loan__c, Scenario_1_Term_Loan__r.Sighten_Product_uuid__c FROM System_Design_Quote__c WHERE Id = :sdq.Id LIMIT 1];

        Proposal__c prop = new Proposal__c(System_Design_Quote__c = sdq.ID, Scenario_1_Included__c = true);
        insert prop;

        Test.startTest();
        Test.setCurrentPage(Page.PreviewProposal);
        Test.setMock(HttpCalloutMock.class, new SightenTestCalloutMock(400));

        PreviewProposalCtrl ctrl = new PreviewProposalCtrl(new ApexPages.StandardController(prop));
        ctrl.buttonScenario = '1';

        ctrl.updateCreditStatus();
        
        Test.stopTest();
    }
}