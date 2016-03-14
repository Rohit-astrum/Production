/*  FILE: PreviewContractTest
    AUTHOR: Dan Kelner
    DATE: 04/13/15
    PURPOSE: Test class for PreviewContractCtrl
    MODIFICATION HISTORY
*/
@isTest
public class PreviewContractTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out
    
    @isTest(seeAllData = true) static void controllerTest1(){
        if(!runalltests){ return; }

        //Create our test data
        ID sdID = testData.setupSystemDesign('Residential', 'Purchase', null, false, 12000);
        System_Design__c sysDesign = new System_Design__c(ID = sdID);
        update sysDesign;

        System_Design_Quote__c sdq = new System_Design_Quote__c(System_Design__c = sysDesign.ID, Current__c = true);
        insert sdq;

        Proposal__c prop = new Proposal__c(System_Design_Quote__c = sdq.ID);
        insert prop;

        Astrum_Contract__c contr1 = new Astrum_Contract__c(Proposal__c = prop.ID, Scenario__c = '1');
        Astrum_Contract__c contr2 = new Astrum_Contract__c(Proposal__c = prop.ID, Scenario__c = '1');
        insert new Astrum_Contract__c[]{contr1, contr2};

        Test.startTest();
        Test.setCurrentPage(Page.PreviewContract);
        PreviewContractCtrl ctrl = new PreviewContractCtrl(new ApexPages.StandardController(contr1));
        ApexPages.currentPage().getParameters().put('contractID', contr2.ID);
        ctrl.switchContract();
        ctrl.goToContractPDF();
        ctrl.sellContract();
        Test.stopTest();
    }

    @isTest(seeAllData = false) static void controllerTest2(){
        if(!runalltests){ return; }

        //Create our test data
        System_Design_Quote__c sdq = testData.setupSystemDesignQuoteForContract('Residential', 12000);

        Proposal__c prop = new Proposal__c(System_Design_Quote__c = sdq.ID);
        insert prop;

        Astrum_Contract__c contr1 = new Astrum_Contract__c(Proposal__c = prop.ID, Closed__c = true, Scenario__c = '1');
        Astrum_Contract__c contr2 = new Astrum_Contract__c(Proposal__c = prop.ID, Current__c = false, Scenario__c = '1');
        insert new Astrum_Contract__c[]{contr1, contr2};

        Test.startTest();
        Test.setCurrentPage(Page.PreviewContract);
        PreviewContractCtrl ctrl = new PreviewContractCtrl(new ApexPages.StandardController(contr1));
        ApexPages.currentPage().getParameters().put('contractID', contr1.ID);
        ctrl.switchContract();

        ApexPages.currentPage().getParameters().put('contractID', contr2.ID);
        ctrl.switchContract();

        sdq.System_Design_Reconstruction_Record__c = 'wrong';
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = true;
        update sdq;
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = false;

        ctrl.sellContract();    //Will fail
        Test.stopTest();
    }

    @isTest static void generateAndSendContract(){
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

        Astrum_Contract__c contr1 = new Astrum_Contract__c(Proposal__c = prop.ID, Closed__c = true, Scenario__c = '1');
        insert contr1;

        Test.startTest();
        Test.setCurrentPage(Page.PreviewContract);
        Test.setMock(HttpCalloutMock.class, new SightenTestCalloutMock(200));

        PreviewContractCtrl ctrl = new PreviewContractCtrl(new ApexPages.StandardController(contr1));

        ctrl.generateAndSendContract();
        
        Test.stopTest();
    }

    @isTest static void downloadContract(){
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

        Astrum_Contract__c contr1 = new Astrum_Contract__c(Proposal__c = prop.ID, Closed__c = true, Scenario__c = '1');
        insert contr1;

        Test.startTest();
        Test.setCurrentPage(Page.PreviewContract);
        Test.setMock(HttpCalloutMock.class, new SightenTestCalloutMock(200));

        PreviewContractCtrl ctrl = new PreviewContractCtrl(new ApexPages.StandardController(contr1));

        ctrl.downloadContract();
        
        Test.stopTest();
    }

    @isTest static void sightenErrorGenerateAndSend(){
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

        Astrum_Contract__c contr1 = new Astrum_Contract__c(Proposal__c = prop.ID, Closed__c = true, Scenario__c = '1');
        insert contr1;

        Test.startTest();
        Test.setCurrentPage(Page.PreviewContract);
        Test.setMock(HttpCalloutMock.class, new SightenTestCalloutMock(400));

        PreviewContractCtrl ctrl = new PreviewContractCtrl(new ApexPages.StandardController(contr1));

        ctrl.generateAndSendContract();
        
        Test.stopTest();
    }

    @isTest static void sightenErrorDownload(){
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

        Astrum_Contract__c contr1 = new Astrum_Contract__c(Proposal__c = prop.ID, Closed__c = true, Scenario__c = '1');
        insert contr1;

        Test.startTest();
        Test.setCurrentPage(Page.PreviewContract);
        Test.setMock(HttpCalloutMock.class, new SightenTestCalloutMock(400));

        PreviewContractCtrl ctrl = new PreviewContractCtrl(new ApexPages.StandardController(contr1));

        ctrl.downloadContract();
        
        Test.stopTest();
    }
}