@isTest
private class SDQConfigExtensionSightenTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out

    @testSetup static void setupData() {
        testdata.setupCustomSettingsPricing();
        testdata.setupCustomConfigObjectsPricing();
        SightenTestUtility.createSightenCustomSettings();
    }

    @isTest static void SDQTestPricingSighten(){
        if(!runalltests){ return; }

        Opportunity_Trigger_Utility.skipOpportunityTrigger = true;
        System_Design_Quote__c sdq = testdata.setupSystemDesignQuote('Residential', 'Purchase', null, true, 12000);
        Opportunity_Trigger_Utility.skipOpportunityTrigger = true;

        SightenTestUtility.AddSightenUUIDValues(sdq);
        
        test.startTest();

        test.setCurrentPage(Page.SystemDesignQuoteConfig);
        ApexPages.StandardController standController = new ApexPages.StandardController(sdq);
        SystemDesignQuoteConfigExtension extn = new SystemDesignQuoteConfigExtension(standController);
        
        extn.initSDQEditMode();
        extn.saveAndReturnPrice();   

        Utility_Service__c utilService = [SELECT Net_Method_1_Tier_Cost__c FROM Utility_Service__c WHERE ID = :extn.utilityService.ID LIMIT 1];
        if (utilService.Net_Method_1_Tier_Cost__c == null)
            utilService.Net_Method_1_Tier_Cost__c = 'T1:3.12;-2.29;-7.70;-38.17;-19.29;-38.93;-52.05;-40.11;16.59;8.12;10.67;8.88;' + 
                                                    + 'T2:0;0;0;0;0;0;0;0;0;0;0;0;'
                                                    + 'T3:0;0;0;0;0;0;0;0;0;0;0;0;'
                                                    + 'T4:0;0;0;0;0;0;0;0;0;0;0;0;'
                                                    + 'T5:0;0;0;0;0;0;0;0;0;0;0;0;';    //Set a value to this field to assist code coverage
        update utilService;     
              
        extn.getPricingCalcs1();

        Test.setMock(HttpCalloutMock.class, new SightenTestCalloutMock(200));
        test.stopTest();

        // make callout to get monthly payment.
        extn.buttonScenario = '1';
        extn.getSightenMonthlyPayment();

        for(ApexPages.Message msg : ApexPages.getMessages()){
            system.debug('**SZ: message = ' + msg.getSummary());
        }

        sdq = [SELECT Id, Scenario_1_First_Month_Payment__c FROM System_Design_Quote__c WHERE Id = :sdq.Id LIMIT 1];
        system.assertEquals(197.46820636000578, sdq.Scenario_1_First_Month_Payment__c);
    }

    @isTest static void SDQTestProposalSighten(){
        if(!runalltests){ return; }
        
        Opportunity_Trigger_Utility.skipOpportunityTrigger = true;
        System_Design_Quote__c sdq = testdata.setupSystemDesignQuote('Residential', 'Purchase', null, true, 12000);

        SightenTestUtility.AddSightenUUIDValues(sdq);
        Opportunity_Trigger_Utility.skipOpportunityTrigger = true;

        test.startTest();
        
        test.setCurrentPage(Page.SystemDesignQuoteConfig);
        ApexPages.StandardController standController = new ApexPages.StandardController(sdq);
        SystemDesignQuoteConfigExtension extn = new SystemDesignQuoteConfigExtension(standController);
        
        //extn.initSDQEditMode();
        //extn.saveAndReturnPrice();   

        //Utility_Service__c utilService = [SELECT Net_Method_1_Tier_Cost__c FROM Utility_Service__c WHERE ID = :extn.utilityService.ID LIMIT 1];
        //if (utilService.Net_Method_1_Tier_Cost__c == null)
        //    utilService.Net_Method_1_Tier_Cost__c = 'T1:3.12;-2.29;-7.70;-38.17;-19.29;-38.93;-52.05;-40.11;16.59;8.12;10.67;8.88;' + 
        //                                            + 'T2:0;0;0;0;0;0;0;0;0;0;0;0;'
        //                                            + 'T3:0;0;0;0;0;0;0;0;0;0;0;0;'
        //                                            + 'T4:0;0;0;0;0;0;0;0;0;0;0;0;'
        //                                            + 'T5:0;0;0;0;0;0;0;0;0;0;0;0;';    //Set a value to this field to assist code coverage
        //update utilService;     
              
        //extn.getPricingCalcs1();

        Test.setMock(HttpCalloutMock.class, new SightenTestCalloutMock(200));

        SystemDesignQuoteConfigExtension.generatePreviewProposal(sdq.Id, sdq.System_Design__c, extn.utilityService.Id, true, false, false, false,null);
        SystemDesignQuoteConfigExtension.insertAttachment('Test: Image;Data,Test', 'Test Image', sdq.Id);

        test.stopTest();

        for(ApexPages.Message msg : ApexPages.getMessages()){
            system.debug('**SZ: message = ' + msg.getSummary());
        }
        system.assertEquals(0, ApexPages.getMessages().size());
    }
}