@isTest
public class SDQGetPricingTest {
    static testmethod void SDQPricingTest(){
        
        //Create Custom Settings
        testdata.setupCustomSettingsPricing();
        testdata.setupCustomConfigObjectsPricing();
        
        //Create System Design Quote
        List<Lease_Fund__c> funds = testdata.createLeaseFunds();//Fund[0] - SAC Loan, Fund[1] - Term Loan, Fund[2] - Lease, Fund[3] - Term & SAC                        
        System_Design_Quote__c sdq = testdata.setupSystemDesignQuotePricing('Residential', funds, true, 12000);//
        
        Test.startTest();//Calling Starttest before testdata creation is complete to avoid soql limit exception
        testdata.createFPP(funds[2].Id);        
        
        sdq = testdata.setupSDQPricingData(sdq, funds);
        sdq.Channel_Partner__c = true;
        sdq.Channel_Partner_Lease_Rate_kWh__c = 1;

        ID market = [SELECT ID FROM SREC_Market__c WHERE Compliance_State__c = 'MD' LIMIT 1].ID;
        Map<String, Schema.RecordTypeInfo> srecOfferRTMap = Schema.SObjectType.SREC_Contract_Offer__c.getRecordTypeInfosByName();
        SREC_Contract_Offer__c offer = new SREC_Contract_Offer__c();
        offer.Name = 'Test Upfront Cash Back SREC Offer';
        offer.SREC_Market__c = market;
        offer.Financing_Type__c = 'Purchase';
        offer.Upfront_Amount__c = 100.00;
        offer.Eligible_States__c = 'MD';
        offer.Start_Date__c = Date.today();
        offer.Default_Offer__c = true;
        offer.RecordTypeId = srecOfferRTMap.get('Upfront Cash Back').getRecordTypeId();
        insert offer;
        
        update sdq;
        
        sdq = testdata.getSDQFields(sdq);
        
        List<Price_Adjustment__c> priceAdjToUpdate = new List<Price_Adjustment__c>();
        for(Price_Adjustment__c p : sdq.Price_Adjustments__r){
            p.Adjustment_Applied__c = true;
            System.debug(loggingLevel.ERROR,'p.id:' + p.id + 'Type__c:' + p.Type__c+ 'RecordType.DeveloperName:' + p.RecordType.DeveloperName+ 'Apply_As_Net_Adjustment__c:' + p.Apply_As_Net_Adjustment__c+ 'Adjustment_Applied__c:' + p.Adjustment_Applied__c+ 'Applicable_Scenario__c:' + p.Applicable_Scenario__c );
            priceAdjToUpdate.add(p);
        }
        update priceAdjToUpdate;
        
        testdata.setupLeaseAdjustmentTabel(sdq.Community_Program_Offer__c, funds[2].Id);
        
        SDQGetPricing sdqPricing = new SDQGetPricing(sdq.Id);
        sdqPricing.getPricing();
        
        sdqPricing.recalcVPOverrideTopLineAdjustment(1, sdq.Price_Adjustments__r);        
        sdqPricing.resetPricingFieldsN(1);
       
        Test.stopTest();
    }
    
    static testmethod void SDQTestPrepaidFPPPricingCal(){
        
        //Create Custom Settings
        testdata.setupCustomSettingsPricing();
        testdata.setupCustomConfigObjectsPricing();
        
        //Create System Design Quote
        List<Lease_Fund__c> funds = testdata.createLeaseFunds();//Fund[0]: SAC Loan, Fund[1]: Term Loan, Fund[2]: Lease, Fund[3]: Term & SAC, Fund[4]: Kilowatt PPA, Fund[5]: OneRoof PPA                     
        System_Design_Quote__c sdq = testdata.setupSystemDesignQuotePricing('Residential', funds, true, 12000);

        Test.startTest();
        
        System_Pricing_Table__c otherSPT = [SELECT Panel_Type__c, Sales_Region__c, Pricing_Region__c, Community_Program_Offer__c FROM System_Pricing_Table__c WHERE Financing_Type__c = 'Lease' LIMIT 1];
        //Get a system pricing table that we just created. We'll base a PPA one off of this.
        System_Pricing_Table__c spt = new System_Pricing_Table__c();   //For CPQ-704
        spt.Panel_Type__c = otherSPT.Panel_Type__c;
        spt.Sales_Region__c = otherSPT.Sales_Region__c;
        spt.Pricing_Region__c = otherSPT.Pricing_Region__c;     
        spt.Financing_Type__c = 'PPA';        
        spt.Lease_Fund__c = funds[4].Id; 
        spt.Community_Program_Offer__c = otherSPT.Community_Program_Offer__c;
        spt.Community_Program_Tier__c = '1';
        spt.Start_Date__c = date.today().addDays(-1);
        spt.End_Date__c = date.today().addDays(2);
        spt.count_10_root_price__c = 2500;
        spt.count_20_root_price__c = 2470;
        spt.count_30_root_price__c = 2450;
        spt.Unique_ID__c = 'ThisFieldIsRequiredSoWeMustSetIt10101';
        insert spt;

        
        SDP_Price_Entry__c inverterSDP;
        SDP_Price_Entry__c trenchingSDP;
        SDP_Price_Entry__c specialSDP;
        SDP_Price_Entry__c mountingSDP;
        for (SDP_Price_Entry__c sdp : [SELECT RecordTypeID, System_Design_Product__c, Start_Date__c, End_Date__c, Property_Record_Type__c, Financing_Type__c, 
                                        Lease_Fund__c, Community_Program_Offer__c, Adder_W__c, Unique_ID__c, Maximum_Size_kW__c, Minimum_Size_kW__c, RecordType.Name 
                                        FROM SDP_Price_Entry__c WHERE RecordType.Name IN ('Inverter', 'Trenching', 'Special Part', 'Mounting')]){
            if (sdp.RecordType.Name == 'Inverter' && inverterSDP == null){
                inverterSDP = sdp.clone(false, true, true, false);
                inverterSDP.Financing_Type__c = 'PPA';
                inverterSDP.Lease_Fund__c = funds[4].ID;
                inverterSDP.Unique_ID__c = 'RequireFieldForPPAInverter';
            } else if (sdp.RecordType.Name == 'Trenching' && trenchingSDP == null){
                trenchingSDP = sdp.clone(false, true, true, false);
                trenchingSDP.Financing_Type__c = 'PPA';
                trenchingSDP.Lease_Fund__c = funds[4].ID;
                trenchingSDP.Unique_ID__c = 'RequireFieldForPPATrenching';
            } else if (sdp.RecordType.Name == 'Special Part' && specialSDP == null){
                specialSDP = sdp.clone(false, true, true, false);
                specialSDP.Financing_Type__c = 'PPA';
                specialSDP.Lease_Fund__c = funds[4].ID;
                specialSDP.Unique_ID__c = 'RequireFieldForPPASpecialPart';
            } else if (sdp.RecordType.Name == 'Mounting' && mountingSDP == null){
                mountingSDP = sdp.clone(false, true, true, false);
                mountingSDP.Financing_Type__c = 'PPA';
                mountingSDP.Lease_Fund__c = funds[4].ID;
                mountingSDP.Unique_ID__c = 'RequireFieldForPPAMounting';
            }
            if (inverterSDP != null && trenchingSDP != null && specialSDP != null && mountingSDP != null)
                break;
        }
        insert new SDP_Price_Entry__c[]{inverterSDP, trenchingSDP, specialSDP, mountingSDP};    //For CPQ-704
        
        State__c marylandState = [SELECT ID FROM State__c WHERE Name = 'Maryland'];
        testdata.createFPP(funds[2].ID, marylandState);
        testdata.createFPP(funds[4].ID, marylandState);

        //Make CPO Door-to-Door to test fixed-rate PPA [CPQ-704]
        Community_Program_Offer__c cpo = [SELECT RecordTypeID, Ineligibility_Threshold__c, Size_Threshold__c, High_PPA_Rate_Threshold__c, Size_Adder__c, 
                                          High_PPA_Rate_Adder__c, Base_PPA_Rate__c FROM Community_Program_Offer__c WHERE ID = :sdq.Community_Program_Offer__c LIMIT 1];
        Map<String, Schema.RecordTypeInfo> cpoRTMap = Schema.SObjectType.Community_Program_Offer__c.getRecordTypeInfosByName();
        cpo.RecordTypeID = cpoRTMap.get('Door to Door').getRecordTypeID();
        cpo.Ineligibility_Threshold__c = 2.0;   //Make this number large in order to pass the validation
        cpo.Size_Threshold__c = 5;
        cpo.High_PPA_Rate_Threshold__c = 0.2;
        cpo.Size_Adder__c = -0.01;
        cpo.High_PPA_Rate_Adder__c = 0.01;
        cpo.Base_PPA_Rate__c = 0.18;
        update cpo;

        sdq = testdata.setupSDQPricingData(sdq, funds);
        sdq.Channel_Partner__c = true;
        sdq.Channel_Partner_Lease_Rate_kWh__c = 1;
        sdq.Scenario_3_Financing_Type__c = 'PPA';
        sdq.Scenario_3_Lease_Fund__c = funds[4].ID;
        sdq.Scenario_3_Lease_Option__c = 'Fixed-Rate PPA';
        sdq.Scenario_4_Lease_Option__c = 'One-Pay';
        update sdq;

        sdq = testdata.getSDQFields(sdq);
        
        testdata.setupLeaseAdjustmentTabel(sdq.Community_Program_Offer__c, funds[2].Id);
        testdata.setupLeaseAdjustmentTabel(sdq.Community_Program_Offer__c, funds[4].Id);
        
        SDQGetPricing sdqPricing = new SDQGetPricing(sdq.Id);
        sdqPricing.getPricing();
        
        Test.stopTest();
    }

    static testmethod void SDQTestOneRoofPPA(){     //Created for CPQ-738
        
        //Create Custom Settings
        testdata.setupCustomSettingsPricing();
        testdata.setupCustomConfigObjectsPricing();
        
        //Create System Design Quote
        List<Lease_Fund__c> funds = testdata.createLeaseFunds();//Fund[0]: SAC Loan, Fund[1]: Term Loan, Fund[2]: Lease, Fund[3]: Term & SAC, Fund[4]: Kilowatt PPA, Fund[5]: OneRoof PPA                     
        System_Design_Quote__c sdq = testdata.setupSystemDesignQuotePricing('Residential', funds, true, 12000);

        Test.startTest();
        
        System_Pricing_Table__c otherSPT = [SELECT Panel_Type__c, Sales_Region__c, Pricing_Region__c, Community_Program_Offer__c FROM System_Pricing_Table__c WHERE Financing_Type__c = 'Lease' LIMIT 1];
        //Get a system pricing table that we just created. We'll base a PPA one off of this.
        System_Pricing_Table__c spt = new System_Pricing_Table__c();
        spt.Panel_Type__c = otherSPT.Panel_Type__c;
        spt.Sales_Region__c = otherSPT.Sales_Region__c;
        spt.Pricing_Region__c = otherSPT.Pricing_Region__c;     
        spt.Financing_Type__c = 'PPA';        
        spt.Lease_Fund__c = funds[5].Id; 
        spt.Community_Program_Offer__c = otherSPT.Community_Program_Offer__c;
        spt.Community_Program_Tier__c = '1';
        spt.Start_Date__c = date.today().addDays(-1);
        spt.End_Date__c = date.today().addDays(2);
        spt.count_10_root_price__c = 2500;
        spt.count_20_root_price__c = 2470;
        spt.count_30_root_price__c = 2450;
        spt.Unique_ID__c = 'ThisFieldIsRequiredSoWeMustSetIt1010101';
        insert spt;

        
        SDP_Price_Entry__c inverterSDP;
        SDP_Price_Entry__c trenchingSDP;
        SDP_Price_Entry__c specialSDP;
        SDP_Price_Entry__c mountingSDP;
        for (SDP_Price_Entry__c sdp : [SELECT RecordTypeID, System_Design_Product__c, Start_Date__c, End_Date__c, Property_Record_Type__c, Financing_Type__c, 
                                        Lease_Fund__c, Community_Program_Offer__c, Adder_W__c, Unique_ID__c, Maximum_Size_kW__c, Minimum_Size_kW__c, RecordType.Name 
                                        FROM SDP_Price_Entry__c WHERE RecordType.Name IN ('Inverter', 'Trenching', 'Special Part', 'Mounting')]){
            if (sdp.RecordType.Name == 'Inverter' && inverterSDP == null){
                inverterSDP = sdp.clone(false, true, true, false);
                inverterSDP.Financing_Type__c = 'PPA';
                inverterSDP.Lease_Fund__c = funds[5].ID;
                inverterSDP.Unique_ID__c = 'RequireFieldForOneRoofPPAInverter';
            } else if (sdp.RecordType.Name == 'Trenching' && trenchingSDP == null){
                trenchingSDP = sdp.clone(false, true, true, false);
                trenchingSDP.Financing_Type__c = 'PPA';
                trenchingSDP.Lease_Fund__c = funds[5].ID;
                trenchingSDP.Unique_ID__c = 'RequireFieldForOneRoofPPATrenching';
            } else if (sdp.RecordType.Name == 'Special Part' && specialSDP == null){
                specialSDP = sdp.clone(false, true, true, false);
                specialSDP.Financing_Type__c = 'PPA';
                specialSDP.Lease_Fund__c = funds[5].ID;
                specialSDP.Unique_ID__c = 'RequireFieldForOneRoofPPASpecialPart';
            } else if (sdp.RecordType.Name == 'Mounting' && mountingSDP == null){
                mountingSDP = sdp.clone(false, true, true, false);
                mountingSDP.Financing_Type__c = 'PPA';
                mountingSDP.Lease_Fund__c = funds[5].ID;
                mountingSDP.Unique_ID__c = 'RequireFieldForOneRoofPPAMounting';
            }
            if (inverterSDP != null && trenchingSDP != null && specialSDP != null && mountingSDP != null)
                break;
        }
        insert new SDP_Price_Entry__c[]{inverterSDP, trenchingSDP, specialSDP, mountingSDP};    //For CPQ-704
        
        State__c marylandState = [SELECT ID FROM State__c WHERE Name = 'Maryland'];
        testdata.createFPP(funds[2].ID, marylandState);
        
        Financing_Product_Pricing__c fppPPA = new Financing_Product_Pricing__c();
        fppPPA.Lease_Fund__c = funds[5].ID;
        fppPPA.Payment_Type__c = 'Fixed-Rate PPA';
        fppPPA.Escalator__c = '0';
        fppPPA.Product_Type__c = 'PPA';
        fppPPA.State__c = marylandState.ID;
        fppPPA.Ineligibility_Threshold__c = 500.0;   //Make this number large in order to pass the validation
        fppPPA.Size_Threshold__c = 5;
        fppPPA.High_PPA_Rate_Threshold__c = 0.2;
        fppPPA.Size_Adder__c = -0.01;
        fppPPA.High_PPA_Rate_Adder__c = 0.01;
        fppPPA.Base_PPA_Rate__c = 0.17;
        fppPPA.PPA_Rate_EPC__c = '0.1550, 3.40; 0.1590, 3.50; 0.1650, 3.60; 0.1700, 3.70;';
        fppPPA.Utility_Company__c = sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__c;
        fppPPA.Community_Program_Offer__c = spt.Community_Program_Offer__c;
        insert fppPPA;

        sdq = testdata.setupSDQPricingData(sdq, funds);
        sdq.Scenario_3_Financing_Type__c = 'PPA';
        sdq.Scenario_3_Lease_Fund__c = funds[5].ID;
        sdq.Scenario_3_Lease_Option__c = 'Fixed-Rate PPA';
        update sdq;

        sdq = testdata.getSDQFields(sdq);
        
        testdata.setupLeaseAdjustmentTabel(sdq.Community_Program_Offer__c, funds[2].Id);
        testdata.setupLeaseAdjustmentTabel(sdq.Community_Program_Offer__c, funds[5].Id);
        
        SDQGetPricing sdqPricing = new SDQGetPricing(sdq.Id);
        sdqPricing.getPricing();
        
        Test.stopTest();
    }

    static testmethod void SDQTestFeedInTariff(){
        //Create Custom Settings
        testdata.setupCustomSettingsPricing();
        testdata.setupCustomConfigObjectsPricing();
        
        //Create System Design Quote
        List<Lease_Fund__c> funds = testdata.createLeaseFunds();
        System_Design_Quote__c sdq = testdata.setupSystemDesignQuotePricing('Residential', funds, true, 12000);

        Test.startTest();
        State__c marylandState = [SELECT ID FROM State__c WHERE Name = 'Maryland'];
        testdata.createFPP(funds[2].ID, marylandState);

        Map<String, Schema.RecordTypeInfo> incentiveOfferRTMap = Schema.SObjectType.Incentive_Offer__c.getRecordTypeInfosByName();
        Incentive_Offer__c io = new Incentive_Offer__c();
        io.RecordTypeId = incentiveOfferRTMap.get('Feed In Tariff').getRecordTypeID();
        io.Name = 'Feed In Tariff Offer';
        io.Implementing_Sector__c = 'Utility';
        io.Eligible_Sector__c = 'Residential';
        io.Eligible_State__c = 'MD';
        io.Customer_Description__c = 'FIT Description';
        io.System_Size_Units__c = 'DC';
        io.FIT_Tier_1_Max_Sys_Size_kW__c = 6;
        io.FIT_Tier_2_Max_Sys_Size_kW__c = 18;
        io.FIT_Tier_1_Amount__c = 0.4;
        io.FIT_Tier_2_Amount__c = 0.3;
        io.Start_Date__c = date.today().addDays(-2);
        insert io;

        sdq = testdata.setupSDQPricingData(sdq, funds);
        update sdq;

        sdq = testdata.getSDQFields(sdq);
        Utility_Service__c us = new Utility_Service__c(ID = sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__c);
        us.Method_1_Production_kWh__c = '580.000;798.000;796.000;625.000;743.000;634.000;643.000;667.000;572.000;674.000;518.000;552.000;';     //Just can't be null
        us.Before_First_Year_Avg_Price__c = 0.17;
        update us;
        
        testdata.setupLeaseAdjustmentTabel(sdq.Community_Program_Offer__c, funds[2].Id);
        
        SDQGetPricing sdqPricing = new SDQGetPricing(sdq.Id);
        sdqPricing.getPricing();
        
        Test.stopTest();
    }

    static testmethod void SDQTestPortfolioPPA1(){     //Created for CPQ-745
        //Create Custom Settings
        testdata.setupCustomSettingsPricing();
        testdata.setupCustomConfigObjectsPricing();
        
        //Create System Design Quote
        List<Lease_Fund__c> funds = testdata.createLeaseFunds();//Fund[0]: SAC Loan, Fund[1]: Term Loan, Fund[2]: Lease, Fund[3]: Term & SAC, Fund[4]: Kilowatt PPA, Fund[5]: OneRoof PPA, Fund[6]: Portfolio PPA  
        System_Design_Quote__c sdq = testdata.setupSystemDesignQuotePricing('Residential', funds, true, 12000);

        Test.startTest();
        
        System_Pricing_Table__c otherSPT = [SELECT Panel_Type__c, Sales_Region__c, Pricing_Region__c, Community_Program_Offer__c FROM System_Pricing_Table__c WHERE Financing_Type__c = 'Lease' LIMIT 1];
        //Get a system pricing table that we just created. We'll base a Portfolio PPA one off of this.
        System_Pricing_Table__c spt = new System_Pricing_Table__c();
        spt.Panel_Type__c = otherSPT.Panel_Type__c;
        spt.Sales_Region__c = otherSPT.Sales_Region__c;
        spt.Pricing_Region__c = otherSPT.Pricing_Region__c;     
        spt.Financing_Type__c = 'PPA';        
        spt.Lease_Fund__c = funds[6].Id; 
        spt.Community_Program_Offer__c = otherSPT.Community_Program_Offer__c;
        spt.Community_Program_Tier__c = '1';
        spt.Start_Date__c = date.today().addDays(-1);
        spt.End_Date__c = date.today().addDays(2);
        spt.count_10_root_price__c = 2500;
        spt.count_20_root_price__c = 2470;
        spt.count_30_root_price__c = 2450;
        spt.Unique_ID__c = 'ThisFieldIsRequiredSoWeHaveToSetIt12345';
        insert spt;
        
        SDP_Price_Entry__c inverterSDP;
        SDP_Price_Entry__c trenchingSDP;
        SDP_Price_Entry__c specialSDP;
        SDP_Price_Entry__c mountingSDP;
        for (SDP_Price_Entry__c sdp : [SELECT RecordTypeID, System_Design_Product__c, Start_Date__c, End_Date__c, Property_Record_Type__c, Financing_Type__c, 
                                        Lease_Fund__c, Community_Program_Offer__c, Adder_W__c, Unique_ID__c, Maximum_Size_kW__c, Minimum_Size_kW__c, RecordType.Name 
                                        FROM SDP_Price_Entry__c WHERE RecordType.Name IN ('Inverter', 'Trenching', 'Special Part', 'Mounting')]){
            if (sdp.RecordType.Name == 'Inverter' && inverterSDP == null){
                inverterSDP = sdp.clone(false, true, true, false);
                inverterSDP.Financing_Type__c = 'PPA';
                inverterSDP.Lease_Fund__c = funds[6].ID;
                inverterSDP.Unique_ID__c = 'RequireFieldForPortfolioPPAInverter';
            } else if (sdp.RecordType.Name == 'Trenching' && trenchingSDP == null){
                trenchingSDP = sdp.clone(false, true, true, false);
                trenchingSDP.Financing_Type__c = 'PPA';
                trenchingSDP.Lease_Fund__c = funds[6].ID;
                trenchingSDP.Unique_ID__c = 'RequireFieldForPortfolioPPATrenching';
            } else if (sdp.RecordType.Name == 'Special Part' && specialSDP == null){
                specialSDP = sdp.clone(false, true, true, false);
                specialSDP.Financing_Type__c = 'PPA';
                specialSDP.Lease_Fund__c = funds[6].ID;
                specialSDP.Unique_ID__c = 'RequireFieldForPortfolioPPASpecialPart';
            } else if (sdp.RecordType.Name == 'Mounting' && mountingSDP == null){
                mountingSDP = sdp.clone(false, true, true, false);
                mountingSDP.Financing_Type__c = 'PPA';
                mountingSDP.Lease_Fund__c = funds[6].ID;
                mountingSDP.Unique_ID__c = 'RequireFieldForPortfolioPPAMounting';
            }
            if (inverterSDP != null && trenchingSDP != null && specialSDP != null && mountingSDP != null)
                break;
        }
        insert new SDP_Price_Entry__c[]{inverterSDP, trenchingSDP, specialSDP, mountingSDP};    //For CPQ-704
        
        State__c marylandState = [SELECT ID FROM State__c WHERE Name = 'Maryland'];
        testdata.createFPP(funds[2].ID, marylandState);
        
        Financing_Product_Pricing__c fppPortfolio = new Financing_Product_Pricing__c();
        fppPortfolio.Lease_Fund__c = funds[6].ID;
        fppPortfolio.Payment_Type__c = 'Portfolio PPA';
        fppPortfolio.Escalator__c = '0';
        fppPortfolio.Product_Type__c = 'PPA';
        fppPortfolio.State__c = marylandState.ID;
        
        fppPortfolio.Utility_Company__c = sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__c;
        fppPortfolio.Community_Program_Offer__c = spt.Community_Program_Offer__c;
        fppPortfolio.Pricing_Region__c = otherSPT.Pricing_Region__c;
        fppPortfolio.Panel_Type__c = sdq.System_Design__r.System_Panel__c;
        fppPortfolio.Starting_Rate_Tier__c = 1;
        fppPortfolio.Tier_1_PPA_Rate__c = 0.12;
        fppPortfolio.Tier_2_PPA_Rate__c = 0.125;
        fppPortfolio.Tier_3_PPA_Rate__c = 0.13;
        fppPortfolio.Tier_4_PPA_Rate__c = 0.135;
        fppPortfolio.Tier_5_PPA_Rate__c = 0.145;
        fppPortfolio.Tier_6_PPA_Rate__c = 0.155;
        fppPortfolio.Tier_1_EPC__c = 3.4;
        fppPortfolio.Tier_2_EPC__c = 3.5;
        fppPortfolio.Tier_3_EPC__c = 3.55;
        fppPortfolio.Tier_4_EPC__c = 3.6;
        fppPortfolio.Tier_5_EPC__c = 3.7;
        fppPortfolio.Tier_6_EPC__c = 3.85;
        fppPortfolio.Tier_1_Threshold__c = 0.125;
        fppPortfolio.Tier_2_Threshold__c = 0.225;
        fppPortfolio.Tier_3_Threshold__c = 0.325;
        fppPortfolio.Tier_4_Threshold__c = 0.425;
        fppPortfolio.Tier_5_Threshold__c = 0.55;
        fppPortfolio.Tier_6_Threshold__c = 0.65;        
        insert fppPortfolio;

        sdq = testdata.setupSDQPricingData(sdq, funds);
        sdq.Scenario_3_Financing_Type__c = 'PPA';
        sdq.Scenario_3_Lease_Fund__c = funds[6].ID;
        sdq.Scenario_3_Lease_Option__c = 'Portfolio PPA';
        update sdq;

        sdq = testdata.getSDQFields(sdq);
        
        testdata.setupLeaseAdjustmentTabel(sdq.Community_Program_Offer__c, funds[2].Id);
        testdata.setupLeaseAdjustmentTabel(sdq.Community_Program_Offer__c, funds[6].Id);
        
        SDQGetPricing sdqPricing = new SDQGetPricing(sdq.Id);
        sdqPricing.getPricing();
        
        Test.stopTest();
    }

    static testmethod void SDQTestPortfolioPPA2(){     //Starting_Rate_Tier__c = 2
        //Create Custom Settings
        testdata.setupCustomSettingsPricing();
        testdata.setupCustomConfigObjectsPricing();
        
        //Create System Design Quote
        List<Lease_Fund__c> funds = testdata.createLeaseFunds();//Fund[0]: SAC Loan, Fund[1]: Term Loan, Fund[2]: Lease, Fund[3]: Term & SAC, Fund[4]: Kilowatt PPA, Fund[5]: OneRoof PPA, Fund[6]: Portfolio PPA  
        System_Design_Quote__c sdq = testdata.setupSystemDesignQuotePricing('Residential', funds, true, 12000);

        Test.startTest();
        
        System_Pricing_Table__c otherSPT = [SELECT Panel_Type__c, Sales_Region__c, Pricing_Region__c, Community_Program_Offer__c FROM System_Pricing_Table__c WHERE Financing_Type__c = 'Lease' LIMIT 1];
        //Get a system pricing table that we just created. We'll base a Portfolio PPA one off of this.
        System_Pricing_Table__c spt = new System_Pricing_Table__c();
        spt.Panel_Type__c = otherSPT.Panel_Type__c;
        spt.Sales_Region__c = otherSPT.Sales_Region__c;
        spt.Pricing_Region__c = otherSPT.Pricing_Region__c;     
        spt.Financing_Type__c = 'PPA';        
        spt.Lease_Fund__c = funds[6].Id; 
        spt.Community_Program_Offer__c = otherSPT.Community_Program_Offer__c;
        spt.Community_Program_Tier__c = '1';
        spt.Start_Date__c = date.today().addDays(-1);
        spt.End_Date__c = date.today().addDays(2);
        spt.count_10_root_price__c = 2500;
        spt.count_20_root_price__c = 2470;
        spt.count_30_root_price__c = 2450;
        spt.Unique_ID__c = 'ThisFieldIsRequiredSoWeHaveToSetIt12345';
        insert spt;
        
        SDP_Price_Entry__c inverterSDP;
        SDP_Price_Entry__c trenchingSDP;
        SDP_Price_Entry__c specialSDP;
        SDP_Price_Entry__c mountingSDP;
        for (SDP_Price_Entry__c sdp : [SELECT RecordTypeID, System_Design_Product__c, Start_Date__c, End_Date__c, Property_Record_Type__c, Financing_Type__c, 
                                        Lease_Fund__c, Community_Program_Offer__c, Adder_W__c, Unique_ID__c, Maximum_Size_kW__c, Minimum_Size_kW__c, RecordType.Name 
                                        FROM SDP_Price_Entry__c WHERE RecordType.Name IN ('Inverter', 'Trenching', 'Special Part', 'Mounting')]){
            if (sdp.RecordType.Name == 'Inverter' && inverterSDP == null){
                inverterSDP = sdp.clone(false, true, true, false);
                inverterSDP.Financing_Type__c = 'PPA';
                inverterSDP.Lease_Fund__c = funds[6].ID;
                inverterSDP.Unique_ID__c = 'RequireFieldForPortfolioPPAInverter';
            } else if (sdp.RecordType.Name == 'Trenching' && trenchingSDP == null){
                trenchingSDP = sdp.clone(false, true, true, false);
                trenchingSDP.Financing_Type__c = 'PPA';
                trenchingSDP.Lease_Fund__c = funds[6].ID;
                trenchingSDP.Unique_ID__c = 'RequireFieldForPortfolioPPATrenching';
            } else if (sdp.RecordType.Name == 'Special Part' && specialSDP == null){
                specialSDP = sdp.clone(false, true, true, false);
                specialSDP.Financing_Type__c = 'PPA';
                specialSDP.Lease_Fund__c = funds[6].ID;
                specialSDP.Unique_ID__c = 'RequireFieldForPortfolioPPASpecialPart';
            } else if (sdp.RecordType.Name == 'Mounting' && mountingSDP == null){
                mountingSDP = sdp.clone(false, true, true, false);
                mountingSDP.Financing_Type__c = 'PPA';
                mountingSDP.Lease_Fund__c = funds[6].ID;
                mountingSDP.Unique_ID__c = 'RequireFieldForPortfolioPPAMounting';
            }
            if (inverterSDP != null && trenchingSDP != null && specialSDP != null && mountingSDP != null)
                break;
        }
        insert new SDP_Price_Entry__c[]{inverterSDP, trenchingSDP, specialSDP, mountingSDP};    //For CPQ-704
        
        State__c marylandState = [SELECT ID FROM State__c WHERE Name = 'Maryland'];
        testdata.createFPP(funds[2].ID, marylandState);
        
        Financing_Product_Pricing__c fppPortfolio = new Financing_Product_Pricing__c();
        fppPortfolio.Lease_Fund__c = funds[6].ID;
        fppPortfolio.Payment_Type__c = 'Portfolio PPA';
        fppPortfolio.Escalator__c = '0';
        fppPortfolio.Product_Type__c = 'PPA';
        fppPortfolio.State__c = marylandState.ID;
        
        fppPortfolio.Utility_Company__c = sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__c;
        fppPortfolio.Community_Program_Offer__c = spt.Community_Program_Offer__c;
        fppPortfolio.Pricing_Region__c = otherSPT.Pricing_Region__c;
        fppPortfolio.Panel_Type__c = sdq.System_Design__r.System_Panel__c;
        fppPortfolio.Starting_Rate_Tier__c = 2;
        fppPortfolio.Tier_2_PPA_Rate__c = 0.125;
        fppPortfolio.Tier_3_PPA_Rate__c = 0.13;
        fppPortfolio.Tier_4_PPA_Rate__c = 0.135;
        fppPortfolio.Tier_5_PPA_Rate__c = 0.145;
        fppPortfolio.Tier_6_PPA_Rate__c = 0.155;
        fppPortfolio.Tier_2_EPC__c = 3.5;
        fppPortfolio.Tier_3_EPC__c = 3.55;
        fppPortfolio.Tier_4_EPC__c = 3.6;
        fppPortfolio.Tier_5_EPC__c = 3.7;
        fppPortfolio.Tier_6_EPC__c = 3.85;
        fppPortfolio.Tier_2_Threshold__c = 0.225;
        fppPortfolio.Tier_3_Threshold__c = 0.325;
        fppPortfolio.Tier_4_Threshold__c = 0.425;
        fppPortfolio.Tier_5_Threshold__c = 0.55;
        fppPortfolio.Tier_6_Threshold__c = 0.65;        
        insert fppPortfolio;

        sdq = testdata.setupSDQPricingData(sdq, funds);
        sdq.Scenario_3_Financing_Type__c = 'PPA';
        sdq.Scenario_3_Lease_Fund__c = funds[6].ID;
        sdq.Scenario_3_Lease_Option__c = 'Portfolio PPA';
        update sdq;

        sdq = testdata.getSDQFields(sdq);
        
        testdata.setupLeaseAdjustmentTabel(sdq.Community_Program_Offer__c, funds[2].Id);
        testdata.setupLeaseAdjustmentTabel(sdq.Community_Program_Offer__c, funds[6].Id);
        
        SDQGetPricing sdqPricing = new SDQGetPricing(sdq.Id);
        sdqPricing.getPricing();
        
        Test.stopTest();
    }

    static testmethod void SDQTestPortfolioPPA3(){     //Starting_Rate_Tier__c = 3
        //Create Custom Settings
        testdata.setupCustomSettingsPricing();
        testdata.setupCustomConfigObjectsPricing();
        
        //Create System Design Quote
        List<Lease_Fund__c> funds = testdata.createLeaseFunds();//Fund[0]: SAC Loan, Fund[1]: Term Loan, Fund[2]: Lease, Fund[3]: Term & SAC, Fund[4]: Kilowatt PPA, Fund[5]: OneRoof PPA, Fund[6]: Portfolio PPA  
        System_Design_Quote__c sdq = testdata.setupSystemDesignQuotePricing('Residential', funds, true, 12000);

        Test.startTest();
        
        System_Pricing_Table__c otherSPT = [SELECT Panel_Type__c, Sales_Region__c, Pricing_Region__c, Community_Program_Offer__c FROM System_Pricing_Table__c WHERE Financing_Type__c = 'Lease' LIMIT 1];
        //Get a system pricing table that we just created. We'll base a Portfolio PPA one off of this.
        System_Pricing_Table__c spt = new System_Pricing_Table__c();
        spt.Panel_Type__c = otherSPT.Panel_Type__c;
        spt.Sales_Region__c = otherSPT.Sales_Region__c;
        spt.Pricing_Region__c = otherSPT.Pricing_Region__c;     
        spt.Financing_Type__c = 'PPA';        
        spt.Lease_Fund__c = funds[6].Id; 
        spt.Community_Program_Offer__c = otherSPT.Community_Program_Offer__c;
        spt.Community_Program_Tier__c = '1';
        spt.Start_Date__c = date.today().addDays(-1);
        spt.End_Date__c = date.today().addDays(2);
        spt.count_10_root_price__c = 2500;
        spt.count_20_root_price__c = 2470;
        spt.count_30_root_price__c = 2450;
        spt.Unique_ID__c = 'ThisFieldIsRequiredSoWeHaveToSetIt12345';
        insert spt;
        
        SDP_Price_Entry__c inverterSDP;
        SDP_Price_Entry__c trenchingSDP;
        SDP_Price_Entry__c specialSDP;
        SDP_Price_Entry__c mountingSDP;
        for (SDP_Price_Entry__c sdp : [SELECT RecordTypeID, System_Design_Product__c, Start_Date__c, End_Date__c, Property_Record_Type__c, Financing_Type__c, 
                                        Lease_Fund__c, Community_Program_Offer__c, Adder_W__c, Unique_ID__c, Maximum_Size_kW__c, Minimum_Size_kW__c, RecordType.Name 
                                        FROM SDP_Price_Entry__c WHERE RecordType.Name IN ('Inverter', 'Trenching', 'Special Part', 'Mounting')]){
            if (sdp.RecordType.Name == 'Inverter' && inverterSDP == null){
                inverterSDP = sdp.clone(false, true, true, false);
                inverterSDP.Financing_Type__c = 'PPA';
                inverterSDP.Lease_Fund__c = funds[6].ID;
                inverterSDP.Unique_ID__c = 'RequireFieldForPortfolioPPAInverter';
            } else if (sdp.RecordType.Name == 'Trenching' && trenchingSDP == null){
                trenchingSDP = sdp.clone(false, true, true, false);
                trenchingSDP.Financing_Type__c = 'PPA';
                trenchingSDP.Lease_Fund__c = funds[6].ID;
                trenchingSDP.Unique_ID__c = 'RequireFieldForPortfolioPPATrenching';
            } else if (sdp.RecordType.Name == 'Special Part' && specialSDP == null){
                specialSDP = sdp.clone(false, true, true, false);
                specialSDP.Financing_Type__c = 'PPA';
                specialSDP.Lease_Fund__c = funds[6].ID;
                specialSDP.Unique_ID__c = 'RequireFieldForPortfolioPPASpecialPart';
            } else if (sdp.RecordType.Name == 'Mounting' && mountingSDP == null){
                mountingSDP = sdp.clone(false, true, true, false);
                mountingSDP.Financing_Type__c = 'PPA';
                mountingSDP.Lease_Fund__c = funds[6].ID;
                mountingSDP.Unique_ID__c = 'RequireFieldForPortfolioPPAMounting';
            }
            if (inverterSDP != null && trenchingSDP != null && specialSDP != null && mountingSDP != null)
                break;
        }
        insert new SDP_Price_Entry__c[]{inverterSDP, trenchingSDP, specialSDP, mountingSDP};    //For CPQ-704
        
        State__c marylandState = [SELECT ID FROM State__c WHERE Name = 'Maryland'];
        testdata.createFPP(funds[2].ID, marylandState);
        
        Financing_Product_Pricing__c fppPortfolio = new Financing_Product_Pricing__c();
        fppPortfolio.Lease_Fund__c = funds[6].ID;
        fppPortfolio.Payment_Type__c = 'Portfolio PPA';
        fppPortfolio.Escalator__c = '0';
        fppPortfolio.Product_Type__c = 'PPA';
        fppPortfolio.State__c = marylandState.ID;
        
        fppPortfolio.Utility_Company__c = sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__c;
        fppPortfolio.Community_Program_Offer__c = spt.Community_Program_Offer__c;
        fppPortfolio.Pricing_Region__c = otherSPT.Pricing_Region__c;
        fppPortfolio.Panel_Type__c = sdq.System_Design__r.System_Panel__c;
        fppPortfolio.Starting_Rate_Tier__c = 3;
        fppPortfolio.Tier_3_PPA_Rate__c = 0.13;
        fppPortfolio.Tier_4_PPA_Rate__c = 0.135;
        fppPortfolio.Tier_5_PPA_Rate__c = 0.145;
        fppPortfolio.Tier_6_PPA_Rate__c = 0.155;
        fppPortfolio.Tier_3_EPC__c = 3.55;
        fppPortfolio.Tier_4_EPC__c = 3.6;
        fppPortfolio.Tier_5_EPC__c = 3.7;
        fppPortfolio.Tier_6_EPC__c = 3.85;
        fppPortfolio.Tier_3_Threshold__c = 0.325;
        fppPortfolio.Tier_4_Threshold__c = 0.425;
        fppPortfolio.Tier_5_Threshold__c = 0.55;
        fppPortfolio.Tier_6_Threshold__c = 0.65;        
        insert fppPortfolio;

        sdq = testdata.setupSDQPricingData(sdq, funds);
        sdq.Scenario_3_Financing_Type__c = 'PPA';
        sdq.Scenario_3_Lease_Fund__c = funds[6].ID;
        sdq.Scenario_3_Lease_Option__c = 'Portfolio PPA';
        update sdq;

        sdq = testdata.getSDQFields(sdq);
        
        testdata.setupLeaseAdjustmentTabel(sdq.Community_Program_Offer__c, funds[2].Id);
        testdata.setupLeaseAdjustmentTabel(sdq.Community_Program_Offer__c, funds[6].Id);
        
        SDQGetPricing sdqPricing = new SDQGetPricing(sdq.Id);
        sdqPricing.getPricing();
        
        Test.stopTest();
    }

    static testmethod void SDQTestPortfolioPPA4(){     //Starting_Rate_Tier__c = 4
        //Create Custom Settings
        testdata.setupCustomSettingsPricing();
        testdata.setupCustomConfigObjectsPricing();
        
        //Create System Design Quote
        List<Lease_Fund__c> funds = testdata.createLeaseFunds();//Fund[0]: SAC Loan, Fund[1]: Term Loan, Fund[2]: Lease, Fund[3]: Term & SAC, Fund[4]: Kilowatt PPA, Fund[5]: OneRoof PPA, Fund[6]: Portfolio PPA  
        System_Design_Quote__c sdq = testdata.setupSystemDesignQuotePricing('Residential', funds, true, 12000);

        Test.startTest();
        
        System_Pricing_Table__c otherSPT = [SELECT Panel_Type__c, Sales_Region__c, Pricing_Region__c, Community_Program_Offer__c FROM System_Pricing_Table__c WHERE Financing_Type__c = 'Lease' LIMIT 1];
        //Get a system pricing table that we just created. We'll base a Portfolio PPA one off of this.
        System_Pricing_Table__c spt = new System_Pricing_Table__c();
        spt.Panel_Type__c = otherSPT.Panel_Type__c;
        spt.Sales_Region__c = otherSPT.Sales_Region__c;
        spt.Pricing_Region__c = otherSPT.Pricing_Region__c;     
        spt.Financing_Type__c = 'PPA';        
        spt.Lease_Fund__c = funds[6].Id; 
        spt.Community_Program_Offer__c = otherSPT.Community_Program_Offer__c;
        spt.Community_Program_Tier__c = '1';
        spt.Start_Date__c = date.today().addDays(-1);
        spt.End_Date__c = date.today().addDays(2);
        spt.count_10_root_price__c = 2500;
        spt.count_20_root_price__c = 2470;
        spt.count_30_root_price__c = 2450;
        spt.Unique_ID__c = 'ThisFieldIsRequiredSoWeHaveToSetIt12345';
        insert spt;
        
        SDP_Price_Entry__c inverterSDP;
        SDP_Price_Entry__c trenchingSDP;
        SDP_Price_Entry__c specialSDP;
        SDP_Price_Entry__c mountingSDP;
        for (SDP_Price_Entry__c sdp : [SELECT RecordTypeID, System_Design_Product__c, Start_Date__c, End_Date__c, Property_Record_Type__c, Financing_Type__c, 
                                        Lease_Fund__c, Community_Program_Offer__c, Adder_W__c, Unique_ID__c, Maximum_Size_kW__c, Minimum_Size_kW__c, RecordType.Name 
                                        FROM SDP_Price_Entry__c WHERE RecordType.Name IN ('Inverter', 'Trenching', 'Special Part', 'Mounting')]){
            if (sdp.RecordType.Name == 'Inverter' && inverterSDP == null){
                inverterSDP = sdp.clone(false, true, true, false);
                inverterSDP.Financing_Type__c = 'PPA';
                inverterSDP.Lease_Fund__c = funds[6].ID;
                inverterSDP.Unique_ID__c = 'RequireFieldForPortfolioPPAInverter';
            } else if (sdp.RecordType.Name == 'Trenching' && trenchingSDP == null){
                trenchingSDP = sdp.clone(false, true, true, false);
                trenchingSDP.Financing_Type__c = 'PPA';
                trenchingSDP.Lease_Fund__c = funds[6].ID;
                trenchingSDP.Unique_ID__c = 'RequireFieldForPortfolioPPATrenching';
            } else if (sdp.RecordType.Name == 'Special Part' && specialSDP == null){
                specialSDP = sdp.clone(false, true, true, false);
                specialSDP.Financing_Type__c = 'PPA';
                specialSDP.Lease_Fund__c = funds[6].ID;
                specialSDP.Unique_ID__c = 'RequireFieldForPortfolioPPASpecialPart';
            } else if (sdp.RecordType.Name == 'Mounting' && mountingSDP == null){
                mountingSDP = sdp.clone(false, true, true, false);
                mountingSDP.Financing_Type__c = 'PPA';
                mountingSDP.Lease_Fund__c = funds[6].ID;
                mountingSDP.Unique_ID__c = 'RequireFieldForPortfolioPPAMounting';
            }
            if (inverterSDP != null && trenchingSDP != null && specialSDP != null && mountingSDP != null)
                break;
        }
        insert new SDP_Price_Entry__c[]{inverterSDP, trenchingSDP, specialSDP, mountingSDP};    //For CPQ-704
        
        State__c marylandState = [SELECT ID FROM State__c WHERE Name = 'Maryland'];
        testdata.createFPP(funds[2].ID, marylandState);
        
        Financing_Product_Pricing__c fppPortfolio = new Financing_Product_Pricing__c();
        fppPortfolio.Lease_Fund__c = funds[6].ID;
        fppPortfolio.Payment_Type__c = 'Portfolio PPA';
        fppPortfolio.Escalator__c = '0';
        fppPortfolio.Product_Type__c = 'PPA';
        fppPortfolio.State__c = marylandState.ID;
        
        fppPortfolio.Utility_Company__c = sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__c;
        fppPortfolio.Community_Program_Offer__c = spt.Community_Program_Offer__c;
        fppPortfolio.Pricing_Region__c = otherSPT.Pricing_Region__c;
        fppPortfolio.Panel_Type__c = sdq.System_Design__r.System_Panel__c;
        fppPortfolio.Starting_Rate_Tier__c = 4;
        fppPortfolio.Tier_4_PPA_Rate__c = 0.135;
        fppPortfolio.Tier_5_PPA_Rate__c = 0.145;
        fppPortfolio.Tier_6_PPA_Rate__c = 0.155;
        fppPortfolio.Tier_4_EPC__c = 3.6;
        fppPortfolio.Tier_5_EPC__c = 3.7;
        fppPortfolio.Tier_6_EPC__c = 3.85;
        fppPortfolio.Tier_4_Threshold__c = 0.425;
        fppPortfolio.Tier_5_Threshold__c = 0.55;
        fppPortfolio.Tier_6_Threshold__c = 0.65;        
        insert fppPortfolio;

        sdq = testdata.setupSDQPricingData(sdq, funds);
        sdq.Scenario_3_Financing_Type__c = 'PPA';
        sdq.Scenario_3_Lease_Fund__c = funds[6].ID;
        sdq.Scenario_3_Lease_Option__c = 'Portfolio PPA';
        update sdq;

        sdq = testdata.getSDQFields(sdq);
        
        testdata.setupLeaseAdjustmentTabel(sdq.Community_Program_Offer__c, funds[2].Id);
        testdata.setupLeaseAdjustmentTabel(sdq.Community_Program_Offer__c, funds[6].Id);
        
        SDQGetPricing sdqPricing = new SDQGetPricing(sdq.Id);
        sdqPricing.getPricing();
        
        Test.stopTest();
    }

    static testmethod void SDQTestPortfolioPPA5(){     //Starting_Rate_Tier__c = 5
        //Create Custom Settings
        testdata.setupCustomSettingsPricing();
        testdata.setupCustomConfigObjectsPricing();
        
        //Create System Design Quote
        List<Lease_Fund__c> funds = testdata.createLeaseFunds();//Fund[0]: SAC Loan, Fund[1]: Term Loan, Fund[2]: Lease, Fund[3]: Term & SAC, Fund[4]: Kilowatt PPA, Fund[5]: OneRoof PPA, Fund[6]: Portfolio PPA  
        System_Design_Quote__c sdq = testdata.setupSystemDesignQuotePricing('Residential', funds, true, 12000);

        Test.startTest();
        
        System_Pricing_Table__c otherSPT = [SELECT Panel_Type__c, Sales_Region__c, Pricing_Region__c, Community_Program_Offer__c FROM System_Pricing_Table__c WHERE Financing_Type__c = 'Lease' LIMIT 1];
        //Get a system pricing table that we just created. We'll base a Portfolio PPA one off of this.
        System_Pricing_Table__c spt = new System_Pricing_Table__c();
        spt.Panel_Type__c = otherSPT.Panel_Type__c;
        spt.Sales_Region__c = otherSPT.Sales_Region__c;
        spt.Pricing_Region__c = otherSPT.Pricing_Region__c;     
        spt.Financing_Type__c = 'PPA';        
        spt.Lease_Fund__c = funds[6].Id; 
        spt.Community_Program_Offer__c = otherSPT.Community_Program_Offer__c;
        spt.Community_Program_Tier__c = '1';
        spt.Start_Date__c = date.today().addDays(-1);
        spt.End_Date__c = date.today().addDays(2);
        spt.count_10_root_price__c = 2500;
        spt.count_20_root_price__c = 2470;
        spt.count_30_root_price__c = 2450;
        spt.Unique_ID__c = 'ThisFieldIsRequiredSoWeHaveToSetIt12345';
        insert spt;
        
        SDP_Price_Entry__c inverterSDP;
        SDP_Price_Entry__c trenchingSDP;
        SDP_Price_Entry__c specialSDP;
        SDP_Price_Entry__c mountingSDP;
        for (SDP_Price_Entry__c sdp : [SELECT RecordTypeID, System_Design_Product__c, Start_Date__c, End_Date__c, Property_Record_Type__c, Financing_Type__c, 
                                        Lease_Fund__c, Community_Program_Offer__c, Adder_W__c, Unique_ID__c, Maximum_Size_kW__c, Minimum_Size_kW__c, RecordType.Name 
                                        FROM SDP_Price_Entry__c WHERE RecordType.Name IN ('Inverter', 'Trenching', 'Special Part', 'Mounting')]){
            if (sdp.RecordType.Name == 'Inverter' && inverterSDP == null){
                inverterSDP = sdp.clone(false, true, true, false);
                inverterSDP.Financing_Type__c = 'PPA';
                inverterSDP.Lease_Fund__c = funds[6].ID;
                inverterSDP.Unique_ID__c = 'RequireFieldForPortfolioPPAInverter';
            } else if (sdp.RecordType.Name == 'Trenching' && trenchingSDP == null){
                trenchingSDP = sdp.clone(false, true, true, false);
                trenchingSDP.Financing_Type__c = 'PPA';
                trenchingSDP.Lease_Fund__c = funds[6].ID;
                trenchingSDP.Unique_ID__c = 'RequireFieldForPortfolioPPATrenching';
            } else if (sdp.RecordType.Name == 'Special Part' && specialSDP == null){
                specialSDP = sdp.clone(false, true, true, false);
                specialSDP.Financing_Type__c = 'PPA';
                specialSDP.Lease_Fund__c = funds[6].ID;
                specialSDP.Unique_ID__c = 'RequireFieldForPortfolioPPASpecialPart';
            } else if (sdp.RecordType.Name == 'Mounting' && mountingSDP == null){
                mountingSDP = sdp.clone(false, true, true, false);
                mountingSDP.Financing_Type__c = 'PPA';
                mountingSDP.Lease_Fund__c = funds[6].ID;
                mountingSDP.Unique_ID__c = 'RequireFieldForPortfolioPPAMounting';
            }
            if (inverterSDP != null && trenchingSDP != null && specialSDP != null && mountingSDP != null)
                break;
        }
        insert new SDP_Price_Entry__c[]{inverterSDP, trenchingSDP, specialSDP, mountingSDP};    //For CPQ-704
        
        State__c marylandState = [SELECT ID FROM State__c WHERE Name = 'Maryland'];
        testdata.createFPP(funds[2].ID, marylandState);
        
        Financing_Product_Pricing__c fppPortfolio = new Financing_Product_Pricing__c();
        fppPortfolio.Lease_Fund__c = funds[6].ID;
        fppPortfolio.Payment_Type__c = 'Portfolio PPA';
        fppPortfolio.Escalator__c = '0';
        fppPortfolio.Product_Type__c = 'PPA';
        fppPortfolio.State__c = marylandState.ID;
        
        fppPortfolio.Utility_Company__c = sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__c;
        fppPortfolio.Community_Program_Offer__c = spt.Community_Program_Offer__c;
        fppPortfolio.Pricing_Region__c = otherSPT.Pricing_Region__c;
        fppPortfolio.Panel_Type__c = sdq.System_Design__r.System_Panel__c;
        fppPortfolio.Starting_Rate_Tier__c = 5;
        fppPortfolio.Tier_5_PPA_Rate__c = 0.145;
        fppPortfolio.Tier_6_PPA_Rate__c = 0.155;
        fppPortfolio.Tier_5_EPC__c = 3.7;
        fppPortfolio.Tier_6_EPC__c = 3.85;
        fppPortfolio.Tier_5_Threshold__c = 0.55;
        fppPortfolio.Tier_6_Threshold__c = 0.65;        
        insert fppPortfolio;

        sdq = testdata.setupSDQPricingData(sdq, funds);
        sdq.Scenario_3_Financing_Type__c = 'PPA';
        sdq.Scenario_3_Lease_Fund__c = funds[6].ID;
        sdq.Scenario_3_Lease_Option__c = 'Portfolio PPA';
        update sdq;

        sdq = testdata.getSDQFields(sdq);
        
        testdata.setupLeaseAdjustmentTabel(sdq.Community_Program_Offer__c, funds[2].Id);
        testdata.setupLeaseAdjustmentTabel(sdq.Community_Program_Offer__c, funds[6].Id);
        
        SDQGetPricing sdqPricing = new SDQGetPricing(sdq.Id);
        sdqPricing.getPricing();
        
        Test.stopTest();
    }

    static testmethod void SDQTestPortfolioPPA6(){     //Starting_Rate_Tier__c = 6
        //Create Custom Settings
        testdata.setupCustomSettingsPricing();
        testdata.setupCustomConfigObjectsPricing();
        
        //Create System Design Quote
        List<Lease_Fund__c> funds = testdata.createLeaseFunds();//Fund[0]: SAC Loan, Fund[1]: Term Loan, Fund[2]: Lease, Fund[3]: Term & SAC, Fund[4]: Kilowatt PPA, Fund[5]: OneRoof PPA, Fund[6]: Portfolio PPA  
        System_Design_Quote__c sdq = testdata.setupSystemDesignQuotePricing('Residential', funds, true, 12000);

        Test.startTest();
        
        System_Pricing_Table__c otherSPT = [SELECT Panel_Type__c, Sales_Region__c, Pricing_Region__c, Community_Program_Offer__c FROM System_Pricing_Table__c WHERE Financing_Type__c = 'Lease' LIMIT 1];
        //Get a system pricing table that we just created. We'll base a Portfolio PPA one off of this.
        System_Pricing_Table__c spt = new System_Pricing_Table__c();
        spt.Panel_Type__c = otherSPT.Panel_Type__c;
        spt.Sales_Region__c = otherSPT.Sales_Region__c;
        spt.Pricing_Region__c = otherSPT.Pricing_Region__c;     
        spt.Financing_Type__c = 'PPA';        
        spt.Lease_Fund__c = funds[6].Id; 
        spt.Community_Program_Offer__c = otherSPT.Community_Program_Offer__c;
        spt.Community_Program_Tier__c = '1';
        spt.Start_Date__c = date.today().addDays(-1);
        spt.End_Date__c = date.today().addDays(2);
        spt.count_10_root_price__c = 2500;
        spt.count_20_root_price__c = 2470;
        spt.count_30_root_price__c = 2450;
        spt.Unique_ID__c = 'ThisFieldIsRequiredSoWeHaveToSetIt12345';
        insert spt;
        
        SDP_Price_Entry__c inverterSDP;
        SDP_Price_Entry__c trenchingSDP;
        SDP_Price_Entry__c specialSDP;
        SDP_Price_Entry__c mountingSDP;
        for (SDP_Price_Entry__c sdp : [SELECT RecordTypeID, System_Design_Product__c, Start_Date__c, End_Date__c, Property_Record_Type__c, Financing_Type__c, 
                                        Lease_Fund__c, Community_Program_Offer__c, Adder_W__c, Unique_ID__c, Maximum_Size_kW__c, Minimum_Size_kW__c, RecordType.Name 
                                        FROM SDP_Price_Entry__c WHERE RecordType.Name IN ('Inverter', 'Trenching', 'Special Part', 'Mounting')]){
            if (sdp.RecordType.Name == 'Inverter' && inverterSDP == null){
                inverterSDP = sdp.clone(false, true, true, false);
                inverterSDP.Financing_Type__c = 'PPA';
                inverterSDP.Lease_Fund__c = funds[6].ID;
                inverterSDP.Unique_ID__c = 'RequireFieldForPortfolioPPAInverter';
            } else if (sdp.RecordType.Name == 'Trenching' && trenchingSDP == null){
                trenchingSDP = sdp.clone(false, true, true, false);
                trenchingSDP.Financing_Type__c = 'PPA';
                trenchingSDP.Lease_Fund__c = funds[6].ID;
                trenchingSDP.Unique_ID__c = 'RequireFieldForPortfolioPPATrenching';
            } else if (sdp.RecordType.Name == 'Special Part' && specialSDP == null){
                specialSDP = sdp.clone(false, true, true, false);
                specialSDP.Financing_Type__c = 'PPA';
                specialSDP.Lease_Fund__c = funds[6].ID;
                specialSDP.Unique_ID__c = 'RequireFieldForPortfolioPPASpecialPart';
            } else if (sdp.RecordType.Name == 'Mounting' && mountingSDP == null){
                mountingSDP = sdp.clone(false, true, true, false);
                mountingSDP.Financing_Type__c = 'PPA';
                mountingSDP.Lease_Fund__c = funds[6].ID;
                mountingSDP.Unique_ID__c = 'RequireFieldForPortfolioPPAMounting';
            }
            if (inverterSDP != null && trenchingSDP != null && specialSDP != null && mountingSDP != null)
                break;
        }
        insert new SDP_Price_Entry__c[]{inverterSDP, trenchingSDP, specialSDP, mountingSDP};    //For CPQ-704
        
        State__c marylandState = [SELECT ID FROM State__c WHERE Name = 'Maryland'];
        testdata.createFPP(funds[2].ID, marylandState);
        
        Financing_Product_Pricing__c fppPortfolio = new Financing_Product_Pricing__c();
        fppPortfolio.Lease_Fund__c = funds[6].ID;
        fppPortfolio.Payment_Type__c = 'Portfolio PPA';
        fppPortfolio.Escalator__c = '0';
        fppPortfolio.Product_Type__c = 'PPA';
        fppPortfolio.State__c = marylandState.ID;
        
        fppPortfolio.Utility_Company__c = sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__c;
        fppPortfolio.Community_Program_Offer__c = spt.Community_Program_Offer__c;
        fppPortfolio.Pricing_Region__c = otherSPT.Pricing_Region__c;
        fppPortfolio.Panel_Type__c = sdq.System_Design__r.System_Panel__c;
        fppPortfolio.Starting_Rate_Tier__c = 6;
        fppPortfolio.Tier_6_PPA_Rate__c = 0.155;
        fppPortfolio.Tier_6_EPC__c = 3.85;
        fppPortfolio.Tier_6_Threshold__c = 0.65;
        insert fppPortfolio;

        sdq = testdata.setupSDQPricingData(sdq, funds);
        sdq.Scenario_3_Financing_Type__c = 'PPA';
        sdq.Scenario_3_Lease_Fund__c = funds[6].ID;
        sdq.Scenario_3_Lease_Option__c = 'Portfolio PPA';
        update sdq;

        sdq = testdata.getSDQFields(sdq);
        
        testdata.setupLeaseAdjustmentTabel(sdq.Community_Program_Offer__c, funds[2].Id);
        testdata.setupLeaseAdjustmentTabel(sdq.Community_Program_Offer__c, funds[6].Id);
        
        SDQGetPricing sdqPricing = new SDQGetPricing(sdq.Id);
        sdqPricing.getPricing();
        
        Test.stopTest();
    }
}