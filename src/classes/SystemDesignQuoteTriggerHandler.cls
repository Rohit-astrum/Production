/* FILE: SystemDesignQuoteTriggerHandler.cls
 * AUTHOR: Mike Katulka
 * DATE: 2014-07-21
 * PURPOSE: Common trigger handler for System Design Quote
 * MODIFICATION HISTORY: 
 *    11/17/14  DK  Added systemDesignQuoteProposalRules() to "before update" execution as part of SDQ validation
 *    06/19/15  DK  If the Minimum_System_Size__c field on Promotion is greater than the SDQ's size in kW, then exclude that Promotion
 *    07/08/15  PB  cpq-607
 */
public class SystemDesignQuoteTriggerHandler {
    
    public static boolean isSystemDesignQuoteTriggerRunning = false;
    public static boolean skipSystemDesignQuoteTrigger = false;

    private boolean m_isExecuting = false;

    //Variables used in pricing functions, cuts down on SOQL queries
    private System_Design_Quote__c sdqLoaded;
    private System_Design_Quote__c sdqForUpdate;
    private set<id> sdpIDs;
    private set<id> utilityCompanyIDs;
    private set<string> utilityCompanySectors;
    
    public SystemDesignQuoteTriggerHandler (boolean isExecuting){
        m_isExecuting = isExecuting;

    }

    public void OnBeforeInsert(System_Design_Quote__c[] newSDQs){
        // EXECUTE BEFORE INSERT LOGIC        
        
        if(newSDQs.size() > 1){
            for(System_Design_Quote__c sdq : newSDQs){
                sdq.adderror('Inserting/Updating SDQs are limited to batches of 1.  Please try updating with a smaller set.  If using data loader, set the batch size to 20 in the settings.');
            }
            return;
        }

        
        setDefaultFieldValues(newSDQs[0]);
        getCommunityProgramOffers(newSDQs);
        getSRECMarket(newSDQs[0]);
        calculateUtilityServiceValues(newSDQs[0]);

        m_isExecuting = false;
    }

    public void OnBeforeUpdate(System_Design_Quote__c[] updatedSDQs, Map<Id,System_Design_Quote__c> SDQMap, Map<Id,System_Design_Quote__c> oldSDQMap){
        // BEFORE UPDATE LOGIC  
        
        if(updatedSDQs.size() > 1){
            for(System_Design_Quote__c sdq : updatedSDQs){
                sdq.adderror('Inserting/Updating SDQs are limited to batches of 1.  Please try updating with a smaller set.  If using data loader, set the batch size to 20 in the settings.');
            }
            return;
        }
        
        getCommunityProgramOffers(updatedSDQs);
        getSRECMarket(updatedSDQs[0]);
        calculateUtilityServiceValues(updatedSDQs[0]);
        systemDesignQuoteProposalRules(updatedSDQs[0]);
       
        m_isExecuting = false;
    }

    public void OnAfterInsert(System_Design_Quote__c[] insertedSDQs, map<id, System_Design_Quote__c> insertedSDQsMap){
        // EXECUTE AFTER INSERT LOGIC        
        
        if(insertedSDQs.size() > 1){
            for(System_Design_Quote__c sdq : insertedSDQs){
                sdq.adderror('Inserting/Updating SDQs are limited to batches of 1.  Please try updating with a smaller set.  If using data loader, set the batch size to 20 in the settings.');
            }
            return;
        }

        //requestNRGQuote(insertedSDQs); // LLH 12/7/14 - no longer using NRG

        //PRICING related functions
        initSDQLoaded(insertedSDQs);        
        getPromotionsAndEntitlementOffers(sdqLoaded, null);
        getIncentiveOffers(sdqLoaded);
        getSRECContractOffers(sdqLoaded);

        //Set other fields. (Turn this into a method once it's big enough).
        if (sdqLoaded.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Annual_Utility_Rate_Escalator__c != null){
            sdqForUpdate.Utility_Annual_Increase__c = sdqLoaded.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Annual_Utility_Rate_Escalator__c;
        } else {
            sdqForUpdate.Utility_Annual_Increase__c = Utility_Company_Settings__c.getOrgDefaults().Default_Annual_Utility_Rate_Escalator__c;
        }   //CPQ-801

        //Save any changes to sdq
        saveSDQUpdates();

        //Call Pricing
        getPricing(sdqLoaded);
        
        
        m_isExecuting = false;
    }

    public void OnAfterUpdate(System_Design_Quote__c[] updatedSDQs, Map<Id,System_Design_Quote__c> SDQMap, Map<Id,System_Design_Quote__c> oldSDQMap){
        //  EXECUTE AFTER UPDATE LOGIC
        
        if(updatedSDQs.size() > 1){
            for(System_Design_Quote__c sdq : updatedSDQs){
                sdq.adderror('Inserting/Updating SDQs are limited to batches of 1.  Please try updating with a smaller set.  If using data loader, set the batch size to 20 in the settings.');
            }
            return;
        }

        updateOppOnSDQChange(SDQMap);

        //PRICING related functions
        initSDQLoaded(updatedSDQs);
        getPromotionsAndEntitlementOffers(sdqLoaded, oldSDQMap.get(sdqLoaded.ID));
        getIncentiveOffers(sdqLoaded);
        getSRECContractOffers(sdqLoaded);

        //Save any changes to sdq
        saveSDQUpdates();

        //Call Pricing
        //if (sdqLoaded.Current__c && sdqLoaded.Valid__c)   //The pricing engine will only run if the Current__c and Valid__c flags on the SDQ are set to true
        getPricing(sdqLoaded);
        
        m_isExecuting = false;
    }

    
    /*
    public void OnBeforeDelete(Object[] ObjectsToDelete, Map<Id,Lead> MapObjectMap){
        // BEFORE DELETE LOGIC
    }

    public void OnAfterDelete(Object[] deletedObjects, Map<Id,Lead> MapObjectMap){
        // AFTER DELETE LOGIC
    }

    public void OnUndelete(Object[] restoredObjects){
        // AFTER UNDELETE LOGIC
    }
    */
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }

    //MK - 2014-09-02
    private void initSDQLoaded(List<System_Design_Quote__c> updatedSDQs){
        //system.debug('initSDQLoaded');
        //This method was created to save on the # of SOQL.  In one SOQL we can get the SDQ fields and all child records needed to synchronize with.
        
        sdqLoaded = updatedSDQs[0];
    
        system.debug('get SDQ and child records');
        //SOQL for a list of SDQs with the needed related parent information, child records
        sdqLoaded = [Select System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Annual_Utility_Rate_Escalator__c, 
                     Community_Program_Offer__c, 
                     Pricing_Locked__c,                         
                     System_Design__r.Property__r.Property_County__c, 
                     System_Design__r.Property__r.QAS_Property_County__c,
                     System_Design__r.Property__r.Property_State__c, 
                     System_Design__r.Total_System_Size_kW__c, 
                     System_Design__r.Total_System_Size_AC_Rating_kW__c, 
                     System_Design__r.Total_System_Size_PTC_rating_kW__c, 
                     System_Design__r.Average_Azimuth__c, 
                     System_Design__r.Average_Tilt__c, 
                     System_Design__r.Overall_TSRF__c, 
                     Annual_Electricity_Consumption_kWh__c,
                     Forecasted_Add_Ann_Consumption_kW__c,
                     Current__c, Valid__c, Pricing_Date__c, 
                     Scenario_1_Lease_Fund__c, Scenario_1_Lease_Option__c, Scenario_1_Financing_Type__c, Scenario_1_Term_Loan__c, 
                     Scenario_2_Lease_Fund__c, Scenario_2_Lease_Option__c, Scenario_2_Financing_Type__c, Scenario_2_Term_Loan__c, 
                     Scenario_3_Lease_Fund__c, Scenario_3_Lease_Option__c, Scenario_3_Financing_Type__c, Scenario_3_Term_Loan__c, 
                     Scenario_4_Lease_Fund__c, Scenario_4_Lease_Option__c, Scenario_4_Financing_Type__c, Scenario_4_Term_Loan__c, 
                     
                     Scenario_1_Financing_Option__c, Scenario_1_Set_Standard_Adjustment_Amoun__c, Scenario_1_Apply_Standard_Adjustment__c, Scenario_1_Set_Standard_Adjustment_Type__c,
                     Scenario_2_Financing_Option__c, Scenario_2_Set_Standard_Adjustment_Amoun__c, Scenario_2_Apply_Standard_Adjustment__c, Scenario_2_Set_Standard_Adjustment_Type__c,
                     Scenario_3_Financing_Option__c, Scenario_3_Set_Standard_Adjustment_Amoun__c, Scenario_3_Apply_Standard_Adjustment__c, Scenario_3_Set_Standard_Adjustment_Type__c,
                     Scenario_4_Financing_Option__c, Scenario_4_Set_Standard_Adjustment_Amoun__c, Scenario_4_Apply_Standard_Adjustment__c, Scenario_4_Set_Standard_Adjustment_Type__c,

                     Scenario_1_Total_Projected_Annual_Output__c, Scenario_1_VP_Sales_Adjustments__c, 
                     Scenario_2_Total_Projected_Annual_Output__c, Scenario_2_VP_Sales_Adjustments__c, 
                     Scenario_3_Total_Projected_Annual_Output__c, Scenario_3_VP_Sales_Adjustments__c, 
                     Scenario_4_Total_Projected_Annual_Output__c, Scenario_4_VP_Sales_Adjustments__c, 

                     Previously_Received_State_Rebate__c, Previously_Received_State_Tax_Credit__c, Previously_Received_County_Tax_Credit__c,
                     Previously_Received_Utility_Rebate__c, Property_in_Revocable_Trust__c, Property_in_Historic_Trust__c, Primary_Residence__c,

                     Quoted_SREC_Market__c, Community_Program_Offer_Early_Adopter__c, 

                     //GET EXISTING PRICE ADJUSTMENTS
                     (Select Name, RecordType.DeveloperName, RecordTypeID, System_Design_Quote__c, Applicable_Scenario__c, Amount__c, 
                                Amount_per_Watt__c, Financing_Option__c, Financing_Type__c, Lease_Fund__c, Leasing_Option__c, Percent__c, 
                                Promotion__c, Entitlement_Offer__c, Type__c, Opt_Out_of_Adjustment__c, Channel_Partner_Adjustment__c, Adjustment_Applied__c
                        from Price_Adjustments__r where Type__c in ('Standard', 'Program', 'Line Item', 'VP Override')),
                    
                    //GET EXISTING AVAILABLE INCENTIVE OFFERS
                     (Select Name, RecordType.DeveloperName, RecordTypeID, System_Design_Quote__c, Applicable_Scenario__c, 
                            Incentive_Applied__c, Incentive_Offer__c,Opted_Out_Manually__c
                        from Available_Incentive_Offers__r),

                    //GET EXISTING AVAILABLE SREC CONTRACT OFFERS
                    (SELECT id, Name, RecordType.DeveloperName, RecordTypeId, System_Design_Quote__c, Applicable_Scenario__c,
                            Contract_Offer_Applied__c, SREC_Contract_Offer__c
                        FROM Available_SREC_Contract_Offers__r)

                 From System_Design_Quote__c Where Id = :sdqLoaded.id];

        sdqForUpdate = new System_Design_Quote__c(id = sdqLoaded.id);

        //SOQL for list of SDIs to get information about each SDP
        //system.debug('get SDIs and product ids');
        // Get the list of all System Design Items Where Quantiy > 0
        sdpIDs = new set<id>();
        //for(System_Design_Item__c sdi : [Select System_Design_Product__c
        //                                         From System_Design_Item__c
        //                                        Where System_Design_Array__r.System_Design__c = :sdqLoaded.System_Design__c
        //                                          AND System_Design_Product__c <> null
        //                                          AND RecordType.DeveloperName IN ('Panel','Inverter','Mounting','Special_Part', 'Trenching', 'Entitlement')
        //                                          AND Quantity__c > 0]){
        //    sdpIDs.add(sdi.System_Design_Product__c);
        //}     //Commented out by DK on 4-16-15. Merged this SDI query into the following SDA query.

        system.debug('get utility companies that are linked to this system designs arrays');
        utilityCompanyIDs = new set<id>();
        utilityCompanySectors = new set<string>();
        //Loop through Arrays and for each array, add the utility companies to needed lists
        for (System_Design_Array__c sda : [SELECT CB_Panel__r.Utility_Service__r.Utility_Company_Master__c, CB_Panel__r.Utility_Service__r.Utility_Rate_Code_Before_Solar__r.Sector__c, 
                                                (SELECT System_Design_Product__c FROM System_Design_Items__r WHERE System_Design_Product__c <> null AND RecordType.DeveloperName IN ('Panel', 'Inverter', 
                                                'Mounting', 'Special_Part', 'Trenching', 'Entitlement') AND Quantity__c > 0) 
                                            FROM System_Design_Array__c 
                                            WHERE CB_Panel__r.Utility_Service__r.Utility_Company_Master__c != null AND System_Design__c = :sdqLoaded.System_Design__c AND Panel_Count__c > 0]){
            
            utilityCompanyIDs.add(sda.CB_Panel__r.Utility_Service__r.Utility_Company_Master__c);
            if (sda.CB_Panel__r.Utility_Service__r.Utility_Rate_Code_Before_Solar__r.Sector__c != null && sda.CB_Panel__r.Utility_Service__r.Utility_Rate_Code_Before_Solar__r.Sector__c != '')
                utilityCompanySectors.add(sda.CB_Panel__r.Utility_Service__r.Utility_Rate_Code_Before_Solar__r.Sector__c.tolowercase());
            
            for (System_Design_Item__c sdi : sda.System_Design_Items__r){
                sdpIDs.add(sdi.System_Design_Product__c);
            }
        }
        System.debug('utilityCompanySectors ' + utilityCompanySectors);
       
    }

    //MK - 2014-10-01 - This method is used for the case where we have to plan an update to the SDQ in an after trigger.
    private void saveSDQUpdates(){
        system.debug('saveSDQUpdates');
        update sdqForUpdate; //Prevent recursive is built in.
    }

    //MK - 2014-08-28: New method used to fill in values for pricing calculations
    private void calculateUtilityServiceValues(System_Design_Quote__c sdq){
        //For each Array with a panel count > 0, Need to locate all Utility Service records.  For each unique Utility Service need to add the numeric values.
        
        //reset the values to 0
        sdq.Annual_Electricity_Consumption_kWh__c = 0;
        sdq.Forecasted_Add_Ann_Consumption_kW__c = 0;
        
        //Get the unique values so we can sum later
        AggregateResult[] groupedResults = [SELECT System_Design__c, CB_Panel__r.Utility_Service__c utilityServiceID
                                                    , AVG(CB_Panel__r.Utility_Service__r.Annual_Electricity_Consumption_kWh_frm__c) annualElecConsumption
                                                    , AVG(CB_Panel__r.Utility_Service__r.Forecasted_Add_Annual_Consumption_kWh__c) forecastedAddAnnCons 
                                            FROM System_Design_Array__c
                                            WHERE System_Design__c =: sdq.System_Design__c
                                            AND Panel_Count__c > 0
                                            GROUP BY System_Design__c, CB_Panel__r.Utility_Service__c];
        
        for (AggregateResult ar : groupedResults)  {
            //For each system design, add up the unique values (cannot be done fully within the SOQL because if 2 arrays use the same utility service, they will be duplicates and added incorrectly)
            decimal annElec = (decimal)ar.get('annualElecConsumption');            
            if(annElec != null) sdq.Annual_Electricity_Consumption_kWh__c += annElec;

            decimal forecastedAnn = (decimal)ar.get('forecastedAddAnnCons');
            if(forecastedAnn != null) sdq.Forecasted_Add_Ann_Consumption_kW__c += forecastedAnn;
        }

    }

    //MK - 2014-08-21
    private void setDefaultFieldValues(System_Design_Quote__c sdq){
        //system.debug('=======================setDefaultFieldValues');

        //Check for custom setting and return if this is disabled.
        //system.debug('Get custom settings');
        System_Design_Quote_Settings__c settings = System_Design_Quote_Settings__c.getInstance(UserInfo.getUserId());
        if (settings == null){
            system.debug('Missing required custom settings in System_Design_Quote_Settings__c.');
            return;
        }        

        system.debug('***Get custom settings and preload the default scenarios/SDQ values on insert, only if the values are blank');        
        if(sdq.Scenario_1_Lease_Fund__c == null && settings.Default_Scenario_1_Lease_Fund_ID__c != null) sdq.Scenario_1_Lease_Fund__c = settings.Default_Scenario_1_Lease_Fund_ID__c;
        if(sdq.Scenario_2_Lease_Fund__c == null && settings.Default_Scenario_2_Lease_Fund_ID__c != null) sdq.Scenario_2_Lease_Fund__c = settings.Default_Scenario_2_Lease_Fund_ID__c;
        if(sdq.Scenario_3_Lease_Fund__c == null && settings.Default_Scenario_3_Lease_Fund_ID__c != null) sdq.Scenario_3_Lease_Fund__c = settings.Default_Scenario_3_Lease_Fund_ID__c;
        if(sdq.Scenario_4_Lease_Fund__c == null && settings.Default_Scenario_4_Lease_Fund_ID__c != null) sdq.Scenario_4_Lease_Fund__c = settings.Default_Scenario_4_Lease_Fund_ID__c;

        if(sdq.Scenario_1_Financing_Type__c == null && settings.Default_Scenario_1_Financing_Type__c != null) sdq.Scenario_1_Financing_Type__c = settings.Default_Scenario_1_Financing_Type__c;
        if(sdq.Scenario_2_Financing_Type__c == null && settings.Default_Scenario_2_Financing_Type__c != null) sdq.Scenario_2_Financing_Type__c = settings.Default_Scenario_2_Financing_Type__c;
        if(sdq.Scenario_3_Financing_Type__c == null && settings.Default_Scenario_3_Financing_Type__c != null) sdq.Scenario_3_Financing_Type__c = settings.Default_Scenario_3_Financing_Type__c;
        if(sdq.Scenario_4_Financing_Type__c == null && settings.Default_Scenario_4_Financing_Type__c != null) sdq.Scenario_4_Financing_Type__c = settings.Default_Scenario_4_Financing_Type__c;

        if(sdq.Scenario_1_Proposal_Term_Months__c == null && settings.Scenario_1_Proposal_Term_Months__c != null) sdq.Scenario_1_Proposal_Term_Months__c = settings.Scenario_1_Proposal_Term_Months__c;
        if(sdq.Scenario_2_Proposal_Term_Months__c == null && settings.Scenario_2_Proposal_Term_Months__c != null) sdq.Scenario_2_Proposal_Term_Months__c = settings.Scenario_2_Proposal_Term_Months__c;
        if(sdq.Scenario_3_Proposal_Term_Months__c == null && settings.Scenario_3_Proposal_Term_Months__c != null) sdq.Scenario_3_Proposal_Term_Months__c = settings.Scenario_3_Proposal_Term_Months__c;
        if(sdq.Scenario_4_Proposal_Term_Months__c == null && settings.Scenario_4_Proposal_Term_Months__c != null) sdq.Scenario_4_Proposal_Term_Months__c = settings.Scenario_4_Proposal_Term_Months__c;
        
        sdq.Primary_Residence__c = true;
    }


    //MK - 2014-09-25
    //Method to retrieve the correct lookup value besfor insert/update of the record. Then the After triggers can run with this value as a reference
    private void getSRECMarket(System_Design_Quote__c sdq){
        system.debug('=======================getSRECMarket');

        if(sdq.Pricing_Locked__c){
            system.debug('Pricing is locked, exit this function.');
            return;
        }

        //Check for the state value. 
        if(sdq.Property_State__c == null){
          system.debug('Property State is blank.');
          return;   
        }

        //Check for if this is filled in (in case the user picked on insert)
        if(sdq.Quoted_SREC_Market__c != null){
          system.debug('Quoted SREC Market is already picked.');
          return;
        }

        //Find the matching srec market
        id marketID;
        for(SREC_Market__c srecMarket : [SELECT id FROM SREC_Market__c Where Primary_States__c includes(:sdq.Property_State__c) limit 1]){
            marketID = srecMarket.id;
        }

        //Store this value in the SDQ.
        system.debug('Setting the SREC Market to: ' + marketID);
        sdq.Quoted_SREC_Market__c = marketID;
    }


    //MK - 2014-08-21
    private void getCommunityProgramOffers(list<System_Design_Quote__c> SDQs){
        system.debug('=======================getCommunityProgramOffers');

        //Check for custom setting and return if this is disabled.
        system.debug('Get custom settings');
        System_Design_Quote_Settings__c settings = System_Design_Quote_Settings__c.getInstance(UserInfo.getUserId());
        if (settings == null){            
            system.debug('Missing required custom settings in System_Design_Quote_Settings__c.');
            return;
        }
        if(!settings.Run_CPO_matching_on_SDQs__c){
            system.debug('Matching the Community Program Offers is disabled in custom settings.');
            return;        
        }

        //This method is bulkified if it's needed.  If other methods are limited to 1, the adderror will stop execution and rollback these changes

        //Call common class to 
        CommunityProgramOfferUtility.matchCommunityProgramOffer(SDQs);
    }

    
    //MK - 2014-07-21: Merged triggers into one handler, came from UpdateOppOnSDQChange.trigger
    private void updateOppOnSDQChange(Map<Id,System_Design_Quote__c> SDQMap){
        //Map<Id, System_Design_Quote__c> sdqNewMap = Trigger.newMap;
        List<Opportunity> oppsToUpdate = new List<Opportunity>([Select id From Opportunity Where System_Design_Quote__c IN :SDQMap.keySet()]);        
        update(oppsToUpdate);
    }
    // RJ Comment 05/05/2015
    //MK - 2014-07-21: Merged triggers into one handler, came from SDQRequestNRGQuote_AI.trigger
    /*
    private void requestNRGQuote(List<System_Design_Quote__c> insertedSDQs){
        //for(System_Design_Quote__c sdq: insertedSDQs){
        //    if (sdq.NRG_Calculator_Valid_SDQ__c || Test.isRunningTest()){
        //        NRGRequestQuoteFromSDQ.RequestNRGQuote(sdq.Id, sdq.System_design__c,sdq.NRG_Installation_State__c, sdq.NRG_Calculator_System_Size_kW__c,sdq.NRG_Calculator_Projected_Annual_Output__c,sdq.NRG_Down_Payment__c,sdq.NRG_Prepaid_Down_Payment__c,sdq.NRG_Calculator_Lease_Escalator__c,sdq.NRG_Calculator_State_Grant__c,sdq.NRG_Calculator_Sales_Tax__c,sdq.NRG_EPC_Price__c,sdq.NRG_Prepaid_EPC_Price__c, sdq.NRG_Calculator_Utility__c,sdq.NRG_Calculator_Avoided_Cost__c );
        //    }         
        //    //CPFIntegrationProcessor.createCPFProposal(sdq.Id);
        //}
    }
    */
    

    //MK - 2014-08-23
    private void getPromotionsAndEntitlementOffers(System_Design_Quote__c sdq, System_Design_Quote__c oldSDQ){
        system.debug('======================getPromotionsAndEntitlementOffers');

        //Check for custom setting and return if this is disabled.
        //system.debug('Get custom settings');
        System_Design_Quote_Settings__c settings = System_Design_Quote_Settings__c.getInstance(UserInfo.getUserId());
        if (settings == null){            
            system.debug('Missing required custom settings in System_Design_Quote_Settings__c.');
            return;
        }
        if(!settings.Run_Promotions_Sync__c){
            system.debug('Syncing promotions/entitlement offers is disabled in custom settings.');
            return;        
        }
        
        if(sdq.Pricing_Locked__c){
            system.debug('Pricing is locked, exit this function.');
            return;
        }
        
        if (oldSDQ == null)
            oldSDQ = sdq;

        //===================
        //Run a sync of promotions every time since there could be a new promotion in the system, or one that is back-dated etc.

        //Get price adjustments record types        
        map<string, Schema.RecordTypeInfo> priceAdjustmentRecordTypeNameMap;
        Schema.DescribeSObjectResult dsra = Price_Adjustment__c.SObjectType.getDescribe();
        priceAdjustmentRecordTypeNameMap = dsra.getRecordTypeInfosByName();
        
        List<Price_Adjustment__c> priceAdjListToUpsert = sdq.Price_Adjustments__r;
        for (Price_Adjustment__c pa : priceAdjListToUpsert){
            //Reset all to false to begin with, except for the manually entered VP Overrides
            //if (pa.Type__c != 'VP Override' || (pa.Type__c == 'VP Override' && pa.Channel_Partner_Adjustment__c)){
                pa.Adjustment_Applied__c = false;
            //}
        }
        
        Map<String,Price_Adjustment__c> vpOverridePriceAdjMap = new Map<String,Price_Adjustment__c>();
        for(Price_Adjustment__c pa : priceAdjListToUpsert){
            if (pa.Type__c == 'VP Override')
                vpOverridePriceAdjMap.put(pa.Applicable_Scenario__c, pa);   //Create Price Adjustment for VP Override
        }

        if(sdq.Scenario_1_VP_Sales_Adjustments__c != null && sdq.Scenario_1_VP_Sales_Adjustments__c != 0){
            //Create price adjustment for vp override scenario 1
            if(vpOverridePriceAdjMap.keySet().contains('1')){
                createOrUpdatePriceAdjVPOverride(sdq,priceAdjListToUpsert,vpOverridePriceAdjMap.get('1'),priceAdjustmentRecordTypeNameMap, 1, sdq.Scenario_1_VP_Sales_Adjustments__c);                            
            }else{
                createOrUpdatePriceAdjVPOverride(sdq,priceAdjListToUpsert,null,priceAdjustmentRecordTypeNameMap, 1, sdq.Scenario_1_VP_Sales_Adjustments__c);                
            }
        }
        if(sdq.Scenario_2_VP_Sales_Adjustments__c != null && sdq.Scenario_2_VP_Sales_Adjustments__c != 0){
            //Create price adjustment for vp override scenario 2
            if(vpOverridePriceAdjMap.keySet().contains('2')){
                createOrUpdatePriceAdjVPOverride(sdq,priceAdjListToUpsert,vpOverridePriceAdjMap.get('2'),priceAdjustmentRecordTypeNameMap, 2, sdq.Scenario_2_VP_Sales_Adjustments__c);                            
            }else{
                createOrUpdatePriceAdjVPOverride(sdq,priceAdjListToUpsert,null,priceAdjustmentRecordTypeNameMap, 2, sdq.Scenario_2_VP_Sales_Adjustments__c);                
            }
        }
        if(sdq.Scenario_3_VP_Sales_Adjustments__c != null && sdq.Scenario_3_VP_Sales_Adjustments__c != 0){
            //Create price adjustment for vp override scenario 3
            if(vpOverridePriceAdjMap.keySet().contains('3')){
                createOrUpdatePriceAdjVPOverride(sdq,priceAdjListToUpsert,vpOverridePriceAdjMap.get('3'),priceAdjustmentRecordTypeNameMap, 3, sdq.Scenario_3_VP_Sales_Adjustments__c);                            
            }else{
                createOrUpdatePriceAdjVPOverride(sdq,priceAdjListToUpsert,null,priceAdjustmentRecordTypeNameMap, 3, sdq.Scenario_3_VP_Sales_Adjustments__c);                
            }
        }  
        if(sdq.Scenario_4_VP_Sales_Adjustments__c != null && sdq.Scenario_4_VP_Sales_Adjustments__c != 0){
            //Create price adjustment for vp override scenario 4
            if(vpOverridePriceAdjMap.keySet().contains('4')){
                createOrUpdatePriceAdjVPOverride(sdq,priceAdjListToUpsert,vpOverridePriceAdjMap.get('4'),priceAdjustmentRecordTypeNameMap, 4, sdq.Scenario_4_VP_Sales_Adjustments__c);                            
            }else{
                createOrUpdatePriceAdjVPOverride(sdq,priceAdjListToUpsert,null,priceAdjustmentRecordTypeNameMap, 4, sdq.Scenario_4_VP_Sales_Adjustments__c);                
            }
        }  

        Date pricingDate = Date.today();    //Default
        if (sdq.Pricing_Date__c != null)
            pricingDate = Date.newInstance(sdq.Pricing_Date__c.year(), sdq.Pricing_Date__c.month(), sdq.Pricing_Date__c.day());

        system.debug('Get promotion records.');
        //SOQL to get all promotion records for date range, This table is managed by marketing and will not contain more than a handful of concurrent promotions company-wide
        //For each Promotion    
        String promoQueryStr = '';
        promoQueryStr+= ' SELECT Name, State__c, System_Design_Product__c, Leasing_Option__c, Include_by_Default__c,';
        promoQueryStr+= ' Lease_Fund__c, Financing_Type__c, Financing_Option__c, Early_Adopter_Promo__c, Minimum_System_Size__c, ';
        promoQueryStr+= ' Community_Program_Offer__c, Promo_Amount__c, Promo_Amount_W__c, Promo_Amount_Percent__c,RecordType.Name, Apply_As_Net_Adjustment__c, '; 
        promoQueryStr+= ' Cash_Only__c, Required_Promotion__c, County__r.Name';
        promoQueryStr+= ' FROM Promotion__c ';
        promoQueryStr+= ' WHERE Start_Date__c <= :pricingDate';
        promoQueryStr+= ' AND (End_Date__c = null OR End_Date__c >= :pricingDate)';
        promoQueryStr+= ' AND (State__c = null OR (State__c <> null AND State__c includes(';
        promoQueryStr+= '\'' + sdq.System_Design__r.Property__r.Property_State__c + '\'';
        promoQueryStr+= ')))';

        if(sdq.Community_Program_Offer__c != null){
            promoQueryStr+= ' AND Community_Program_Offer__c <> null AND Community_Program_Offer__c =';
            promoQueryStr+= '\'' +sdq.Community_Program_Offer__c + '\'';        
        }else{
            promoQueryStr+= ' AND Community_Program_Offer__c = null';        
        }                                                            
                            
        for(Promotion__c promo : Database.Query(promoQueryStr)){

            system.debug('Promo: ' + promo.id);
            checkScenarioPromoEnt(1, promo, sdq, priceAdjListToUpsert, sdpIDs, priceAdjustmentRecordTypeNameMap);
            checkScenarioPromoEnt(2, promo, sdq, priceAdjListToUpsert, sdpIDs, priceAdjustmentRecordTypeNameMap);
            checkScenarioPromoEnt(3, promo, sdq, priceAdjListToUpsert, sdpIDs, priceAdjustmentRecordTypeNameMap);
            checkScenarioPromoEnt(4, promo, sdq, priceAdjListToUpsert, sdpIDs, priceAdjustmentRecordTypeNameMap);
        }


        system.debug('Get entitlement offer records.');
        //SOQL to get all entitlement offer records for date range, This table is managed by marketing and will not contain more than a handful of concurrent promotions company-wide
        //For each entitlement
        //
        
        String queryStr = '';
        queryStr+= 'SELECT Name, State__c, System_Design_Product__c, Leasing_Option__c,Lease_Fund__c';
        queryStr+= ', Financing_Type__c, Financing_Option__c, Community_Program_Offer__c, Amount__c';
        queryStr+= ', Amount_W__c, Amount_Percent__c, Apply_As_Net_Adjustment__c, Opt_Out_Allowed__c, Production_Guarantee__c, Guaranteed_Rate__c '; 
        queryStr+= ' FROM Entitlement_Offer__c';
        queryStr+= ' WHERE Start_Date__c <= :pricingDate';
        queryStr+= ' AND (End_Date__c = null OR End_Date__c >= :pricingDate)';
        queryStr+= ' AND (State__c = null OR (State__c <> null AND State__c includes(';
        queryStr+= '\'' + sdq.System_Design__r.Property__r.Property_State__c + '\'';
        queryStr+= ')))';

        if(sdq.Community_Program_Offer__c != null){
            queryStr+= ' AND Community_Program_Offer__c <> null AND Community_Program_Offer__c =';
            queryStr+= '\'' +sdq.Community_Program_Offer__c + '\'';        
        }else{
            queryStr+= ' AND Community_Program_Offer__c = null';        
        }                                                            
                            
        for(Entitlement_Offer__c entitlement : Database.Query(queryStr)){

            system.debug('entitlement: ' + entitlement.id);
            checkScenarioPromoEnt(1, entitlement, sdq, priceAdjListToUpsert, sdpIDs, priceAdjustmentRecordTypeNameMap);
            checkScenarioPromoEnt(2, entitlement, sdq, priceAdjListToUpsert, sdpIDs, priceAdjustmentRecordTypeNameMap);
            checkScenarioPromoEnt(3, entitlement, sdq, priceAdjListToUpsert, sdpIDs, priceAdjustmentRecordTypeNameMap);
            checkScenarioPromoEnt(4, entitlement, sdq, priceAdjListToUpsert, sdpIDs, priceAdjustmentRecordTypeNameMap);
        }

        for(Price_Adjustment__c pa : priceAdjListToUpsert){           
            if(pa.Type__c == 'Line Item' && pa.Adjustment_Applied__c == false ){
                pa.opt_out_of_Adjustment__c = true;
            }
            else if (pa.Type__c == 'Line Item' && pa.Adjustment_Applied__c == true)
            {
                pa.opt_out_of_Adjustment__c = false;   
            }
        }
        
       /////////////////////////////
       /*
        for(Entitlement_Offer__c entitlement : [Select id, Name, State__c, System_Design_Product__c, Leasing_Option__c,
                                            Lease_Fund__c, Financing_Type__c, Financing_Option__c,
                                            Community_Program_Offer__c, Amount__c, Amount_W__c, Amount_Percent__c,
                                            Apply_As_Net_Adjustment__c, Opt_Out_Allowed__c
                            From Entitlement_Offer__c
                            Where Start_Date__c <= TODAY 
                            AND (End_Date__c = null OR End_Date__c >= TODAY)
                            
                            //Is this a country-wide entitlement, or is this state specific and matching this state?
                            AND (State__c = null OR (State__c <> null AND State__c includes(:sdq.System_Design__r.Property__r.Property_State__c)))
                            
                            //Is this a non-community based offer? Or is it a matching Community offer?
                            AND (Community_Program_Offer__c = null OR (Community_Program_Offer__c <> null AND Community_Program_Offer__c =: sdq.Community_Program_Offer__c))
                            ]){

            system.debug('entitlement: ' + entitlement.id);
            checkScenarioPromoEnt(1, entitlement, sdq, priceAdjListToUpsert, sdpIDs, priceAdjustmentRecordTypeNameMap);
            checkScenarioPromoEnt(2, entitlement, sdq, priceAdjListToUpsert, sdpIDs, priceAdjustmentRecordTypeNameMap);
            checkScenarioPromoEnt(3, entitlement, sdq, priceAdjListToUpsert, sdpIDs, priceAdjustmentRecordTypeNameMap);
            checkScenarioPromoEnt(4, entitlement, sdq, priceAdjListToUpsert, sdpIDs, priceAdjustmentRecordTypeNameMap);
        }
        */
        ////////////////////////////////

        //Need to end up with one of these outcomes:
            // - Found a matching Price Adjustment already connected... make sure it's active and update the pricing
            // - Did not find a matching Price Adjustment... Insert a new record as active
            
        //All of these situations will be stored in the same list

        if(!priceAdjListToUpsert.isEmpty()) upsert priceAdjListToUpsert; //Linked by the pa.id field for upsert
        

    }

    
    //MK - 2014-08-23
    private void checkScenarioPromoEnt(Integer scenarioN, sObject lookupRec, System_Design_Quote__c sdq, List<Price_Adjustment__c> priceAdjListToUpsert, set<id> sdpIDs, map<string, Schema.RecordTypeInfo> priceAdjustmentRecordTypeNameMap){
        
        //SET SDQ VARIABLES
        system.debug('********************check scenario ' + scenarioN + ' promo matching');
        String finType = (string)sdq.get('Scenario_' + scenarioN + '_Financing_Type__c');        
        String finOption = (string)sdq.get('Scenario_' + scenarioN + '_Financing_Option__c');
        id leaseFund = (string)sdq.get('Scenario_' + scenarioN + '_Lease_Fund__c') != null ? (string)sdq.get('Scenario_' + scenarioN + '_Lease_Fund__c') : (string)sdq.get('Scenario_' + scenarioN + '_Term_Loan__c');
        String leaseOption = (string)sdq.get('Scenario_' + scenarioN + '_Lease_Option__c');
        Decimal setStandardAdjAmount = (decimal)sdq.get('Scenario_' + scenarioN + '_Set_Standard_Adjustment_Amoun__c');        
        String adjType = (string)sdq.get('Scenario_' + scenarioN + '_Set_Standard_Adjustment_Type__c');
        Boolean applyStandardAdj = (boolean)sdq.get('Scenario_' + scenarioN + '_Apply_Standard_Adjustment__c');
        String state = sdq.System_Design__r.Property__r.Property_State__c;
        String county = sdq.System_Design__r.Property__r.QAS_Property_County__c != null ? sdq.System_Design__r.Property__r.QAS_Property_County__c : SalesRegionHelper.removeState(sdq.System_Design__r.Property__r.Property_County__c);

        //Create variables for promo/entitlement        
        id lookupRecordId;
        id lookupSdpId;
        string lookupRecordTypeName; //Standard, Program, or Line Item
        string lookupRecordName;
        string lookupFinType;
        string lookupFinOption;
        string lookupLeaseFund;
        string lookupLeaseOption;
        decimal lookupAmount;
        decimal lookupAmountRate;
        decimal lookupAmountPercent;
        boolean lookupApplyAsNetAdjustment;
        Decimal lookupMinimumSystemSize;
        Boolean lookupCashOnly = false;//cpq-607
        String lookupCountyName;    //CPQ-706

        //Check to see what type of object this is for
        schema.sObjectType sourceType = lookupRec.getsObjectType();
        if(sourceType == Promotion__c.sObjectType){
            //system.debug('This is a Promotion record');
            Promotion__c promo = (Promotion__c)lookupRec;
            //SET PROMO VARIABLES
            lookupRecordId = promo.id;
            lookupSdpId = promo.System_Design_Product__c;
            lookupRecordTypeName = promo.RecordType.Name; //Standard, Program
            lookupRecordName = promo.Name;
            lookupFinType = promo.Financing_Type__c;
            lookupFinOption = promo.Financing_Option__c;
            lookupLeaseFund = promo.Lease_Fund__c;
            lookupLeaseOption = promo.Leasing_Option__c;
            lookupAmount = promo.Promo_Amount__c;
            lookupAmountRate = promo.Promo_Amount_W__c;
            lookupAmountPercent = promo.Promo_Amount_Percent__c;
            lookupApplyAsNetAdjustment = promo.Apply_As_Net_Adjustment__c;
            lookupMinimumSystemSize = promo.Minimum_System_Size__c;     //CPQ-297
            lookupCashOnly = promo.Cash_Only__c; //cpq-607
            lookupCountyName = promo.County__r.Name;    //Will be in the format of "County Name, State"

        }else if(sourceType == Entitlement_Offer__c.sObjectType){
            //system.debug('This is a Entitlement Offer record');
            Entitlement_Offer__c entitlement = (Entitlement_Offer__c)lookupRec;
            //SET entitlement VARIABLES
            lookupRecordId = entitlement.id;
            lookupSdpId = entitlement.System_Design_Product__c;
            lookupRecordTypeName = 'Line Item'; //No record types on entitlement
            lookupRecordName = entitlement.Name;
            lookupFinType = entitlement.Financing_Type__c;
            lookupFinOption = entitlement.Financing_Option__c;
            lookupLeaseFund = entitlement.Lease_Fund__c;
            lookupLeaseOption = entitlement.Leasing_Option__c;
            lookupAmount = entitlement.Amount__c;
            lookupAmountRate = entitlement.Amount_W__c;
            lookupAmountPercent = entitlement.Amount_Percent__c;
            lookupApplyAsNetAdjustment = entitlement.Apply_As_Net_Adjustment__c;            

        }else{
            system.debug('***ERROR: Invalid object type for this method!!!! Need to add logic to this method to handle this new object');
            return;
        }

        String promoCounty = '';
        String promoState = '';
        if (lookupCountyName != null){
            promoCounty = lookupCountyName.substringBeforeLast(',').removeEndIgnoreCase('County').trim();
            promoState = lookupCountyName.substringAfterLast(',').trim();
        }
        
        //SET ENTITLEMENT OFFER VARIABLES

        //The following logic allows matching based on if a Promo has criteria filled in, the SDQ would need to meet all of that criteria
        //If non-Product promotion
        //OR If Product promotion && ProductIDs set contains this Promo.Product        
        system.debug('System_Design_Product__c: ' + lookupSdpId);
        
        system.debug('--------------------------');
        system.debug('Financing_Type__c: ' + lookupFinType);
        system.debug('scenario.finType: ' + finType);
        
        system.debug('--------------------------');
        system.debug('Financing_Option__c: ' + lookupFinOption);
        system.debug('scenario.finOption: ' + finOption);
        
        system.debug('--------------------------');
        system.debug('Lease_Fund__c: ' + lookupLeaseFund);
        system.debug('scenario.leaseFund: ' + leaseFund);
        
        system.debug('--------------------------');
        system.debug('Leasing_Option__c: ' + lookupLeaseOption);
        system.debug('scenario.leaseOption: ' + leaseOption);
        
        system.debug('--------------------------');
        system.debug('Promo_Amount__c: ' + lookupAmount);
        system.debug('Promo_Amount_W__c: ' + lookupAmountRate);
        system.debug('Promo_Amount_Percent__c: ' + lookupAmountPercent);

        //Performing IF statements here since it's per scenario, and so we can SOQL just 1 time to pre-filter on non-scenario specific criteria.
        if(
            //Is this a non-product promo/entitlement OR if it is a product promo/entitlement, does it match a product in this SD?
            (lookupSdpId == null || sdpIDs.contains(lookupSdpId))
            &&             
            //Is this a non-Financing Type specific promo/entitlement, or is this a Financing Type specific offer that matches?
            (lookupFinType == null || (lookupFinType != null && lookupFinType == finType))
            && 
            //Is this a non-Financing Option specific promo/entitlement, or is this a Financing Option specific offer that matches?
            (lookupFinOption == null || (lookupFinOption != null && lookupFinOption == finOption))
            && 
            //Is this a non-Lease Fund specific promo/entitlement, or is this a Lease Fund specific offer that matches?
            (lookupLeaseFund == null || (lookupLeaseFund != null && lookupLeaseFund == leaseFund))
            && 
            //Is this a non-Leasing Option specific promo/entitlement, or is this a Leasing Option specific offer that matches?
            (lookupLeaseOption == null || (lookupLeaseOption != null && lookupLeaseOption == leaseOption))
            && !(lookupRecordTypeName == 'Line Item' && finType == 'Purchase' && leaseFund != null && lookupFinType == finType && lookupLeaseFund == null)
            &&
            //Filter by county, if there is one (CPQ-706)
            (lookupCountyName == null || (lookupCountyName != null && promoCounty == county && promoState == state))

            //&& !(lookupRecordTypeName == 'Program' && finType == 'Purchase' && leaseFund != null && lookupFinType == finType && lookupCashOnly)// cpq-607
            && (!lookupCashOnly || (lookupCashOnly && lookupRecordTypeName == 'Program' && finType == 'Purchase' && leaseFund == null)) //CPQ-607 revised
            //&& 
            //Is this a Program OR 
            //Is this a Standard Adjustment and a Scenario Financing type of 'Purchase'              
            //( //Commented out per CB and will be driven by the Promotion finance type for standard adjustments from now on.
                //promo.RecordType.Name == 'Program' 
                //|| 
                //(
                //    promo.RecordType.Name == 'Standard'
                //    && finType != null
                //    && finType == 'Purchase'
                //)
            //)
        ){
            if (lookupRecordTypeName == 'Program' && (lookupMinimumSystemSize != null && sdq.System_Design__r.Total_System_Size_kW__c < lookupMinimumSystemSize))
                return;     //DK  06/19/15  Exclude promotions according to minimum system size as per CPQ-297

            system.debug('This is a POTENTIAL matching promotion/Entitlement offer');

            if(lookupRecordTypeName == 'Program' || lookupRecordTypeName == 'Line Item'){
                system.debug('This is a matching ' + (lookupRecordTypeName == 'Program' ? 'Program Promotion' : 'Entitlement Offer') + '!');
                
                //*** This PROGRAM logic operates like this:
                //If the scenario general settings (finance type, state etc) match a promotion
                    //Then check to see what types of adjustments this promotion has.  Create a Price Adjustment record for each type of adjustment it has.

                //Check for dollar amount
                if(lookupAmount != null){
                    //Create a separate price adjustment for this amount
                    id recordTypeID = priceAdjustmentRecordTypeNameMap.get('Dollar Amount').getRecordTypeID();
                    createProgramPriceAdjustment(scenarioN, lookupRec, sdq, priceAdjListToUpsert, recordTypeID, lookupAmount, null, null);
                }


                //Check for rate amount
                if(lookupAmountRate != null){
                    //Create a separate price adjustment for this amount
                    id recordTypeID = priceAdjustmentRecordTypeNameMap.get('Rate').getRecordTypeID();
                    createProgramPriceAdjustment(scenarioN, lookupRec, sdq, priceAdjListToUpsert, recordTypeID, null, lookupAmountRate, null);
                }


                //Check for percent amount
                if(lookupAmountPercent != null){
                    //Create a separate price adjustment for this amount
                    id recordTypeID = priceAdjustmentRecordTypeNameMap.get('Percentage').getRecordTypeID();
                    createProgramPriceAdjustment(scenarioN, lookupRec, sdq, priceAdjListToUpsert, recordTypeID, null, null, lookupAmountPercent);
                }



            }else if(lookupRecordTypeName == 'Standard'){
                system.debug('This is a Standard promotion, need to check to see which values match.');


                //*** This STANDARD logic operates like this:
                //If the scenario general settings (finance type, state etc) match a promotion
                //AND the standard adjustment currently stored in this scenario matches a Promotion
                    //Then create just 1 price entry for this matching connection

                system.debug('--------------------------');
                system.debug('scenario.setStandardAdjType: ' + adjType);
                system.debug('scenario.setStandardAdjAmount: ' + setStandardAdjAmount);
                system.debug('scenario.applyStandardAdj: ' + applyStandardAdj);
                
                Price_Adjustment__c tempPA = new Price_Adjustment__c();
                
                boolean createPriceAdjustment = false;
                
                //Does the specified Standard Adjustment Amount match?
                //Field values for Scenario_N_Set_Standard_Adjustment_Type__c: $, $/W, %
                //Mapping:
                //$ - Promotion.Promo_Amount__c
                //$/W - Promotion.Promo_Amount_W__c
                //% - Promotion.Promo_Amount_Percent__c                
                
                //Find out if this Promo matches exactly to the set Scenario adjustment
                if(adjType == null){
                    system.debug('The Standard Adjustment type is blank, unable to match the adjustment amount.');
                    return;
                }
                if(setStandardAdjAmount == null){
                    system.debug('The Standard Adjustment type is blank, unable to match the adjustment amount.');
                    return;
                }

                //Make sure the amount is in negatives for matching purposes
                if(setStandardAdjAmount > 0) setStandardAdjAmount *= -1;

                //Only one of the following will match, so standard adjustments can only match/spawn one price adjustment at a time.
                //===============

                //Set the extra values to null because we need to overwrite a matching pa if one exists
                tempPA.Amount__c = null;
                tempPA.Amount_per_Watt__c = null; 
                tempPA.Percent__c = null;

                //Check for dollar amount
                if(adjType == 'Dollar Amount'){
                    if (lookupAmount != null && lookupAmount == setStandardAdjAmount){                        
                        createPriceAdjustment = true;
                        tempPA.RecordTypeID = priceAdjustmentRecordTypeNameMap.get('Dollar Amount').getRecordTypeID();
                        tempPA.Amount__c = setStandardAdjAmount; //Set to the scenario amount, because we need to match the Promo on this
                    }

                }else if(adjType == 'Dollar per Watt'){ //Check for dollar per watt rate                    
                    if (lookupAmountRate != null && lookupAmountRate == setStandardAdjAmount){
                        createPriceAdjustment = true;                        
                        tempPA.RecordTypeID = priceAdjustmentRecordTypeNameMap.get('Rate').getRecordTypeID();
                        tempPA.Amount_per_Watt__c = setStandardAdjAmount;
                    }

                }else if(adjType == 'Percentage'){  //Check for percentage
                    if (lookupAmountPercent != null && lookupAmountPercent == setStandardAdjAmount){
                        createPriceAdjustment = true;
                        tempPA.RecordTypeID = priceAdjustmentRecordTypeNameMap.get('Percentage').getRecordTypeID();
                        tempPA.Percent__c = setStandardAdjAmount;
                    }

                }

                if(createPriceAdjustment){
                    system.debug('***Found matching Standard Promo***');
                    Price_Adjustment__c pa = new Price_Adjustment__c();
                    
                    //Try to set tempPA to the matching existing Price Adjustment record
                    for(Price_Adjustment__c p : priceAdjListToUpsert){
                        if(p.Promotion__c == lookupRecordId
                                && p.Type__c == lookupRecordTypeName
                                && p.RecordTypeID == tempPA.RecordTypeID //Make sure the adjustment type match ie dollar to dollar
                                && p.Applicable_Scenario__c != null && p.Applicable_Scenario__c == string.valueof(ScenarioN)){
                            pa = p; //This will link by id and update the existing record below
                            system.debug('Found existing Price Adjustment record: ' + pa.id);
                            break; //exit the for loop
                        }
                    }
                    
                    //Populate the updated information in this price adjustment
                    if(applyStandardAdj) pa.Adjustment_Applied__c = true;
                    pa.Name = lookupRecordName;
                    pa.Promotion__c = lookupRecordId; //Just fill in the promo lookup, this is definitely a promo
                    pa.Applicable_Scenario__c = string.valueof(ScenarioN);
                    pa.Type__c = lookupRecordTypeName; //Standard
                    pa.Apply_As_Net_Adjustment__c = lookupApplyAsNetAdjustment;
                    
                    //Copy from the tempPA
                    pa.RecordTypeID = tempPA.RecordTypeID;
                    pa.Amount__c = tempPA.Amount__c;
                    pa.Amount_per_Watt__c = tempPA.Amount_per_Watt__c; 
                    pa.Percent__c = tempPA.Percent__c;

                    if(pa.id == null){
                        system.debug('Did not find existing Price Adjustment record, inserting this new record.');
                        pa.System_Design_Quote__c = sdq.id;
                        priceAdjListToUpsert.add(pa);
                    }
                }
                
            }
            
        }
    }

    //MK - 2014-08-23
    private void createProgramPriceAdjustment(Integer scenarioN, sObject lookupRec, System_Design_Quote__c sdq, List<Price_Adjustment__c> priceAdjListToUpsert, id recordTypeID, decimal dollarAmt, decimal rateAmt, decimal percentAmt){
        //Create variables for promo/entitlement        
        id lookupRecordId;
        id lookupSdpId;
        id lookupCommProgram;
        string lookupRecordTypeName; //Standard, Program, or Line Item
        string lookupRecordName;
        String lookupFinType;
        decimal lookupAmount;
        decimal lookupAmountRate;
        decimal lookupAmountPercent;
        decimal guaranteedRate;
        boolean prodGuar;
        boolean lookupEarlyAdopterPromo;
        boolean lookupApplyAsNetAdjustment;
        boolean lookupOptOutAllowed = true;
        Boolean isRequired;
        Boolean includeByDefault;
        Boolean isCashOnly;

        //Check to see what type of object this is for
        schema.sObjectType sourceType = lookupRec.getsObjectType();
        if(sourceType == Promotion__c.sObjectType){
            //system.debug('This is a Promotion record');
            Promotion__c promo = (Promotion__c)lookupRec;
            //SET PROMO VARIABLES
            lookupRecordId = promo.id;
            lookupSdpId = promo.System_Design_Product__c;
            lookupCommProgram = promo.Community_Program_Offer__c;
            lookupRecordTypeName = promo.RecordType.Name; //Standard, Program
            lookupRecordName = promo.Name;
            lookupFinType = promo.Financing_Type__c;
            lookupAmount = promo.Promo_Amount__c;
            lookupAmountRate = promo.Promo_Amount_W__c;
            lookupAmountPercent = promo.Promo_Amount_Percent__c;
            lookupEarlyAdopterPromo = promo.Early_Adopter_Promo__c;
            lookupApplyAsNetAdjustment = promo.Apply_As_Net_Adjustment__c;
            isRequired = promo.Required_Promotion__c;   //CPQ-640
            includeByDefault = promo.Include_by_Default__c;     //CPQ-640
            isCashOnly = promo.Cash_Only__c;    //CPQ-685

        }else if(sourceType == Entitlement_Offer__c.sObjectType){
            //system.debug('This is a Entitlement Offer record');
            Entitlement_Offer__c entitlement = (Entitlement_Offer__c)lookupRec;
            //SET entitlement VARIABLES
            lookupRecordId = entitlement.id;
            lookupSdpId = entitlement.System_Design_Product__c;
            lookupRecordTypeName = 'Line Item'; //No record types on entitlement
            lookupRecordName = entitlement.Name;
            lookupFinType = entitlement.Financing_Type__c;
            lookupAmount = entitlement.Amount__c;
            lookupAmountRate = entitlement.Amount_W__c;
            lookupAmountPercent = entitlement.Amount_Percent__c;
            lookupApplyAsNetAdjustment = entitlement.Apply_As_Net_Adjustment__c;
            lookupOptOutAllowed = entitlement.Opt_Out_Allowed__c; 
            guaranteedRate = entitlement.Guaranteed_Rate__c;    
            prodGuar =   entitlement.Production_Guarantee__c;           

        }else{
            system.debug('***ERROR: Invalid object type for this method!!!! Need to add logic to this method to handle this new object');
            return;
        }

        Price_Adjustment__c pa = new Price_Adjustment__c();

        //Try to set pa to the matching existing Price Adjustment record
        for(Price_Adjustment__c oldPa : priceAdjListToUpsert){
            if( 
                (
                    (lookupRecordTypeName == 'Line Item' && oldPa.Entitlement_Offer__c == lookupRecordId)
                    ||
                    (lookupRecordTypeName == 'Program' && oldPa.Promotion__c == lookupRecordId)
                )                
                && oldPa.Type__c == lookupRecordTypeName
                && oldPa.Applicable_Scenario__c != null && oldPa.Applicable_Scenario__c == string.valueof(ScenarioN)
                && (dollarAmt == null || oldPa.RecordType.DeveloperName == 'Dollar_Amount') //if $ is filled in, find a matching price adjustment
                && (rateAmt == null || oldPa.RecordType.DeveloperName == 'Rate')
                && (percentAmt == null || oldPa.RecordType.DeveloperName == 'Percentage')
            ){
                pa = oldPa; //This will link by id and update the existing record below         
                system.debug('Found existing Price Adjustment record: ' + pa.id);
                break; //exit the for loop
            }
        }
        
        //Fill in the correct lookup field
        if(lookupRecordTypeName == 'Line Item'){
            pa.Entitlement_Offer__c = lookupRecordId;
            pa.Promotion__c = null;
            if(prodGuar)
            {
                pa.Guaranteed_Rate__c = guaranteedRate;
                pa.Production_Guarantee__c = prodGuar;
            }
        }else{
            pa.Promotion__c = lookupRecordId;
            pa.Entitlement_Offer__c = null;
        }

        //Fill in field values
        pa.Name = lookupRecordName;
        pa.Applicable_Scenario__c = string.valueof(ScenarioN);
        pa.Type__c = lookupRecordTypeName; //Program or Line Item
        pa.Apply_As_Net_Adjustment__c = lookupApplyAsNetAdjustment;

        //Set the record type
        pa.RecordTypeID = recordTypeID;

        //Set the amounts
        pa.Amount__c = dollarAmt;
        pa.Amount_per_Watt__c = rateAmt;
        pa.Percent__c = percentAmt;

        //If this is a Promotion and this is an early adopter promo but the SDQ is not set as the same, remove the adjustment
        if (lookupRecordTypeName == 'Program' && lookupEarlyAdopterPromo && lookupCommProgram != null  && !sdq.Community_Program_Offer_Early_Adopter__c){
            pa.Adjustment_Applied__c = false;
        }

        //If this price adjustment record is set for opt out, disable applied checkbox.
        if(pa.id != null && pa.Opt_Out_of_Adjustment__c){
            pa.Adjustment_Applied__c = false;
        }

        //Check to see if this adjustment should be applied
        if(sourceType == Promotion__c.sObjectType && (isRequired || (includeByDefault && !pa.Opt_Out_of_Adjustment__c) || (Trigger.isUpdate && !pa.Opt_Out_of_Adjustment__c)) ){      //Modified on 10/06/15
           pa.Adjustment_Applied__c = true;
           pa.Opt_Out_of_Adjustment__c = false;
        }

        if(pa.id == null && sourceType == Entitlement_Offer__c.sObjectType && lookupOptOutAllowed ){
            pa.Opt_Out_of_Adjustment__c = true;
        }      
        
        if((sourceType == Entitlement_Offer__c.sObjectType) && (!lookupOptOutAllowed  || !pa.Opt_Out_of_Adjustment__c )){
            pa.Adjustment_Applied__c = true;
        }

        if(pa.id == null && sourceType == Promotion__c.sObjectType && !pa.Opt_Out_of_Adjustment__c){
            pa.Adjustment_Applied__c = includeByDefault ? true : false;
        }

   /*      
        
        if(pa.id != null){
            if(pa.Opt_Out_of_Adjustment__c){
                pa.Adjustment_Applied__c = false;
            }else{
                pa.Adjustment_Applied__c = true;
                pa.Opt_Out_of_Adjustment__c = false;                
            }
        }
        
        if(pa.id == null){
            if((sourceType == Entitlement_Offer__c.sObjectType) && lookupOptOutAllowed){
                pa.Adjustment_Applied__c = false;
                pa.Opt_Out_of_Adjustment__c = true;
            }else{
                pa.Adjustment_Applied__c = true;
                pa.Opt_Out_of_Adjustment__c = false;
            }
            
        }        
        
        //If this is a Promotion and 
            //this is an early adopter promo but the sdq is not set as the same, remove the adjustment
        if(lookupRecordTypeName == 'Program' && lookupEarlyAdopterPromo
            && lookupCommProgram != null 
            && !sdq.Community_Program_Offer_Early_Adopter__c
        ){
            pa.Adjustment_Applied__c = false;
        }
        
*/
        //If this is a new insert of price adjustment, link it to the SDQ and add it to the list for upsert
        if(pa.id == null){
            system.debug('Did not find existing Price Adjustment record, inserting this new record.');
            pa.System_Design_Quote__c = sdq.id;
            priceAdjListToUpsert.add(pa);
        }
    }

    //PB - 2015-03-12   
    private void createOrUpdatePriceAdjVPOverride(System_Design_Quote__c sdq,List<Price_Adjustment__c> priceAdjs, Price_Adjustment__c priceAdj, map<string, Schema.RecordTypeInfo> priceAdjustmentRecordTypeNameMap, Integer ScenarioN, Decimal amount){
        Price_Adjustment__c vpPriceAdj;

        

        if(priceAdj != null){
            id recordTypeID = priceAdjustmentRecordTypeNameMap.get('Dollar Amount').getRecordTypeID();
            priceAdj.RecordTypeID = recordTypeID;
            priceAdj.Amount__c = amount;
            priceAdj.Effective_Dollar_Amount__c = amount;
            
            priceAdj.Name = 'VP Override Price Adjustment';
            priceAdj.Adjustment_Applied__c = true;
            priceAdj.Opt_Out_of_Adjustment__c = false;
            
            if (priceAdj.Channel_Partner_Adjustment__c == true){
                 priceAdj.Amount__c = 0;
                 priceAdj.Channel_Partner_Adjustment__c = false;
            }
        }
        else{
            vpPriceAdj = new Price_Adjustment__c();
            vpPriceAdj.Name = 'VP Override Price Adjustment';
            vpPriceAdj.Type__c = 'VP Override';
            id recordTypeID = priceAdjustmentRecordTypeNameMap.get('Dollar Amount').getRecordTypeID();
            vpPriceAdj.RecordTypeID = recordTypeID;
            vpPriceAdj.Amount__c = amount;
            vpPriceAdj.Effective_Dollar_Amount__c = amount;
            vpPriceAdj.Applicable_Scenario__c = String.valueOf(ScenarioN);
            vpPriceAdj.System_Design_Quote__c = sdq.Id;
            vpPriceAdj.Adjustment_Applied__c = true;
            vpPriceAdj.Opt_Out_of_Adjustment__c = false;
            vpPriceAdj.Channel_Partner_Adjustment__c = false;
            priceAdjs.add(vpPriceAdj);            
        } 
    }
    
    //MK - 2014-09-02
    private void getIncentiveOffers(System_Design_Quote__c sdq){
        system.debug('=======================getIncentiveOffers');

        //Check for custom setting and return if this is disabled.
        system.debug('Get custom settings');
        System_Design_Quote_Settings__c settings = System_Design_Quote_Settings__c.getInstance(UserInfo.getUserId());
        if (settings == null){            
            system.debug('Missing required custom settings in System_Design_Quote_Settings__c.');
            return;
        }
        if(!settings.Run_Incentives_Sync__c){
            system.debug('Syncing incentive offers is disabled in custom settings.');
            return;        
        }
   
        //SDQ is set by the method initSDQLoaded before getting to this point. This is a pre-requisite.
        if(sdq.Pricing_Locked__c){
            system.debug('Pricing is locked, exit this function.');
            return;
        }
        
        //===================
        //Run a sync of incentives every time since there could be a new Incentive in the system, or one that is back-dated etc.

        //Get Available Incentive Offer record types        
        map<string, Schema.RecordTypeInfo> availableIncentiveOfferRecordTypeNameMap;
        Schema.DescribeSObjectResult dsra = Available_Incentive_Offer__c.SObjectType.getDescribe();
        availableIncentiveOfferRecordTypeNameMap = dsra.getRecordTypeInfosByName();
        
        system.debug('Reset the Adjustment Applied flag to false');
        List<Available_Incentive_Offer__c> availableIncentiveOfferListToUpsert = sdq.Available_Incentive_Offers__r;
        for(Available_Incentive_Offer__c aio : availableIncentiveOfferListToUpsert){
            //Reset all to false to begin with
            aio.Incentive_Applied__c = false;
            aio.Current_Matching_Incentive__c = false;
            //Store the default message, this will get overwritten with the matching logic as needed.
            aio.Not_Matched_Reason__c = '[No longer matches but did apply in the past.  Kept for historic purposes.]';
        }

        //Reset the sdq requirements
        sdqForUpdate.Previously_Received_State_Rebate_Req__c = false;
        sdqForUpdate.Previously_Received_State_Tax_Credit_Req__c = false;
        sdqForUpdate.Previously_Received_County_Tax_Req__c = false;
        sdqForUpdate.Previously_Received_Utility_Rebate_Req__c = false;
        sdqForUpdate.Property_in_Revocable_Trust_Req__c = false;
        sdqForUpdate.Property_in_Historic_Trust_Req__c = false;
        sdqForUpdate.Primary_Residence_Req__c = false;

        Date pricingDate = Date.today();
        if (sdq.Pricing_Date__c != null)
            pricingDate = Date.newInstance(sdq.Pricing_Date__c.year(), sdq.Pricing_Date__c.month(), sdq.Pricing_Date__c.day());

        system.debug('Get Incentive records.');
        //SOQL to get all Incentive records for date range
        //For each Incentive
        for(Incentive_Offer__c incentive : [SELECT Agency_Retains_RECs__c, American_Made_Adder_W__c, American_Made_Cap_kW__c, 
                                                Consumption_Adjustment_Type__c, Consumption_Calculation_Adj_Permitted__c, 
                                                Credit_Capped_by_Annual_Tax_Obligation__c, Customer_Receives_RECs_Revenue__c, 
                                                Depreciation_Basis_Rate__c, Depreciation_Year_1__c, Depreciation_Year_2__c, 
                                                Depreciation_Year_3__c, Depreciation_Year_4__c, Depreciation_Year_5__c, Depreciation_Year_6__c, 
                                                Description__c, Eligible_Cost_Basis__c, Eligible_County__c, Eligible_Financing_Type__c, 
                                                Eligible_Sector__c, Eligible_State__c, End_Date__c, Flat_Rebate_Amount__c, 
                                                Historic_Trust_Exclusion__c, Implementing_Sector__c, Name, Incentive_Recipient__c, 
                                                Maximum_Allowable_Tax_Credit__c, Maximum_Azimuth__c, Maximum_Eligible_System_Size_kW__c, 
                                                Maximum_Proportion_of_Consumption__c, Maximum_Proportion_of_Total_Cost__c, Maximum_Tilt__c, 
                                                Minimum_Azimuth__c, Minimum_Eligible_System_Size_kW__c, Minimum_Standard_TSRF__c, 
                                                Minimum_Tilt__c, Mod_Home_Value_Mod_Income_Adder_W__c, Mod_Home_Value_Mod_Income_Cap_kW__c, 
                                                Natural_Disaster_Adder_W__c, Natural_Disaster_Cap_kW__c, Number_of_Utility_Companies__c, 
                                                PBI_Amount__c, Previous_Receipt_Exclusion__c, Primary_Residence_Requirement__c, 
                                                RecordTypeId, RecordType.Name, RecordType.DeveloperName, Revocable_Trust_Exclusion__c, Size_Panel_Capped__c, 
                                                Start_Date__c, System_Size_Units__c, TSRF_Adjustment_Type__c, Tax_Credit_Rate__c, 
                                                Tier_1_Incentive_Rate_W__c, Tier_1_Maximum_System_Size_kW__c, Tier_2_Incentive_Rate_W__c, 
                                                Tier_2_Maximum_System_Size_kW__c, Tier_Pricing_Type__c, Utility_Company_Matching_Required__c,

                                                (SELECT Utility_Company_Master__c FROM Incentive_Utility_Junctions__r)

                                            FROM Incentive_Offer__c                            
                                            WHERE Start_Date__c <= :pricingDate AND (End_Date__c = null OR End_Date__c >= :pricingDate)
                                
                                                //Is this a country-wide incentive, or is this state specific and matching this state?
                                                AND (Eligible_State__c = null OR (Eligible_State__c <> null AND Eligible_State__c includes(:sdq.System_Design__r.Property__r.Property_State__c)))
                                        ]){

            system.debug('checking incentive: ' + incentive.id + ' '+incentive.Name +' '+incentive.Eligible_Sector__c.tolowercase());

            //Filter out SDQ - wide parameters            

            //Only sync sectors that match the system design

            if(!utilityCompanySectors.contains(incentive.Eligible_Sector__c.tolowercase())){
                system.debug('Skip because the sector does not match');
                continue;
            }

            //Is this an incentive that requires a matching utility company?
            if(incentive.Utility_Company_Matching_Required__c){

                //Check to see if there are matching utility companies
                boolean isMatch = false;          
                for(Incentive_Utility_Junction__c utilityIncentiveJunction : incentive.Incentive_Utility_Junctions__r){
                    if(utilityCompanyIDs.contains(utilityIncentiveJunction.Utility_Company_Master__c)){
                        //This is a match!
                        isMatch = true;
                    }
                }
                if(!isMatch){
                    system.debug('Skip because the utility company is not eligible');
                    continue; //Skip to the next incentive because nothing matched
                }
            }

            //Check to see if the county matches
            string county = (sdq.System_Design__r.Property__r.QAS_Property_County__c != null ? sdq.System_Design__r.Property__r.QAS_Property_County__c : SalesRegionHelper.removeState(sdq.System_Design__r.Property__r.Property_County__c));
            string countyState;
            if(county != null && sdq.System_Design__r.Property__r.Property_State__c != null){                
                countyState = county.trim().tolowercase() + ', ' + sdq.System_Design__r.Property__r.Property_State__c.trim().tolowercase();
            }        
            system.debug('countyState: ' + countyState);
            if(incentive.Eligible_County__c != null && incentive.Eligible_County__c != ''){                
                if(countyState == null){
                    system.debug('Skip because this county and/or state is blank');
                    continue; //Skip because there is not a county and/or state for this property
                }
                
                //Split the semi-colon space delimited text into a searchable set
                //Split returns a list, that we can put in the constructor of the set
                //Split into set insead of string.contains search because these can get mixed up: "west goshen, pa"... where searching for "goshen, pa" 
                        //will return true using string.contains
                set<string> valSet = new set<string>(incentive.Eligible_County__c.tolowercase().replace('; ', ';').replace(' ;', ';').split(';'));
                
                if(!valSet.contains(countyState)){
                    system.debug('Skip because this county is not eligible');
                    continue; //Skip because this county is not eligible
                }
            }
            
            //If we get this far, then the SDQ-wide filters pass and this incentive is a potential match.

            //Check each scenario:
            checkScenarioIncentive(1, incentive, sdq, availableIncentiveOfferListToUpsert, availableIncentiveOfferRecordTypeNameMap);
            checkScenarioIncentive(2, incentive, sdq, availableIncentiveOfferListToUpsert, availableIncentiveOfferRecordTypeNameMap);
            checkScenarioIncentive(3, incentive, sdq, availableIncentiveOfferListToUpsert, availableIncentiveOfferRecordTypeNameMap);
            checkScenarioIncentive(4, incentive, sdq, availableIncentiveOfferListToUpsert, availableIncentiveOfferRecordTypeNameMap);
        }

        //Need to end up with one of these outcomes:
            // - Found a matching Available Incentive Offer already connected... make sure it's active
            // - Did not find a matching Available Incentive Offer... Insert a new record as active
            
        //All of these situations will be stored in the same list

        if(!availableIncentiveOfferListToUpsert.isEmpty()) upsert availableIncentiveOfferListToUpsert; //Linked by the aio.id field for upsert
        
    }


    
    //MK - 2014-09-05
    private void checkScenarioIncentive(Integer scenarioN, Incentive_Offer__c incentive, System_Design_Quote__c sdq, List<Available_Incentive_Offer__c> incentiveOfferListToUpsert, map<string, Schema.RecordTypeInfo> availableIncentiveOfferRecordTypeNameMap){
        
        //SET SDQ VARIABLES
        system.debug('********************check scenario ' + scenarioN + ' incentive matching');
        system.debug('Incentive Implementing Sector: ' + incentive.Implementing_Sector__c);
        system.debug('Incentive Recordtype: ' + incentive.RecordType.DeveloperName);

        String finType = (string)sdq.get('Scenario_' + scenarioN + '_Financing_Type__c');
        decimal totalProjectedAnnualOutput = (decimal)sdq.get('Scenario_' + scenarioN + '_Total_Projected_Annual_Output__c');

        //Initialize variables used in syncing
        //Set these to 0 if they are null for easier calculations.
        decimal annualCons = sdq.Annual_Electricity_Consumption_kWh__c == null || sdq.Annual_Electricity_Consumption_kWh__c == 0 ? 0.0000001 : sdq.Annual_Electricity_Consumption_kWh__c;
        decimal additionalCons = sdq.Forecasted_Add_Ann_Consumption_kW__c == null ? 0.0000001 : sdq.Forecasted_Add_Ann_Consumption_kW__c;
        
        //The following logic allows matching based on if a incentive has criteria filled in, the SDQ would need to meet all of that criteria
        system.debug('--------------------------');
        system.debug('Eligible_Financing_Type__c: ' + incentive.Eligible_Financing_Type__c);
        system.debug('scenario.finType: ' + finType);
        system.debug('scenario.total projected annual output kwh: ' + totalProjectedAnnualOutput);
        system.debug('system design.annual Consumption: ' + annualCons);
        system.debug('system design.additional annual Consumption: ' + additionalCons);
        decimal maxProportionOfConsumption = incentive.Maximum_Proportion_of_Consumption__c == null ? incentive.Maximum_Proportion_of_Consumption__c : incentive.Maximum_Proportion_of_Consumption__c/100;
        system.debug('max proportion of consumption: ' + maxProportionOfConsumption);


        //Is this a Financing Type specific offer that does not match?
        if(incentive.Eligible_Financing_Type__c != null){
            if(incentive.Eligible_Financing_Type__c != finType){
                system.debug('Finance type does not match for this scenario');
                return;
            }
            //else, we have a match and continue on
        }
        //else, this is not filtered by finance type
        
        boolean createIncentive = true; //Start out true, and rule out the match

        //Rule out potential incentives if any of the following criteria are true:
        decimal properSystemSize;
        
        //set the system size value to the Incentive system size unit
        if(incentive.System_Size_Units__c != null){
            if(incentive.System_Size_Units__c == 'DC'){
                properSystemSize = sdq.System_Design__r.Total_System_Size_kW__c;
            }else if(incentive.System_Size_Units__c == 'AC'){
                properSystemSize = sdq.System_Design__r.Total_System_Size_AC_Rating_kW__c;
            }if(incentive.System_Size_Units__c == 'PTC'){
                properSystemSize = sdq.System_Design__r.Total_System_Size_PTC_rating_kW__c;
            }                
        }else{
            system.debug('incentive.System_Size_Units__c is blank');
        }

        //1. Minimum Eligible System Size (kW) is not ?null? and is greater than system size
        if(incentive.Minimum_Eligible_System_Size_kW__c != null
                    && (properSystemSize == null || incentive.Minimum_Eligible_System_Size_kW__c > properSystemSize)){                
            system.debug('Incentive Excluded: The minimum eligible system size for this incentive');
            createIncentive = false;
        }

        //2. Maximum Eligible System Size (kW) is not ?null? and is less than system size
        if(incentive.Maximum_Eligible_System_Size_kW__c != null
                    && (properSystemSize == null || incentive.Maximum_Eligible_System_Size_kW__c < properSystemSize)){                
            system.debug('Incentive Excluded: The maximum eligible system size for this incentive');
            createIncentive = false;
        }

        //3. Minimum Azimuth is not ?null? and is greater than Average Azimuth
        if(incentive.Minimum_Azimuth__c != null
                    && (sdq.System_Design__r.Average_Azimuth__c == null || incentive.Minimum_Azimuth__c > sdq.System_Design__r.Average_Azimuth__c)){
            system.debug('Incentive Excluded: The minimum azimuth for this incentive');
            createIncentive = false;
        }

        //4. Maximum Azimuth is not ?null? and is less than Average Azimuth
        if(incentive.Maximum_Azimuth__c != null
                    && (sdq.System_Design__r.Average_Azimuth__c == null || incentive.Maximum_Azimuth__c < sdq.System_Design__r.Average_Azimuth__c)){
            system.debug('Incentive Excluded: The Maximum azimuth for this incentive');
            createIncentive = false;
        }

        //5. Minimum Tilt is not ?null? and is greater than Average Tilt
        if(incentive.Minimum_Tilt__c != null
                    && (sdq.System_Design__r.Average_Tilt__c == null || incentive.Minimum_Tilt__c > sdq.System_Design__r.Average_Tilt__c)){
            system.debug('Incentive Excluded: The minimum Tilt for this incentive');
            createIncentive = false;
        }

        //6. Maximum Tilt is not ?null? and is less than Average Tilt
        if(incentive.Maximum_Tilt__c != null
                    && (sdq.System_Design__r.Average_Tilt__c == null || incentive.Maximum_Tilt__c < sdq.System_Design__r.Average_Tilt__c)){
            system.debug('Incentive Excluded: The Maximum Tilt for this incentive');
            createIncentive = false;
        }

        //7. Consumption Calculation Adjustment Permitted <> ?TRUE? and Total Projected Annual Output/sum(Annual Electricity Consumption) > Maximum Proportion of Consumption and Consumption Adjustment Type = 'Ineligible'
        if(!incentive.Consumption_Calculation_Adj_Permitted__c 
                    && totalProjectedAnnualOutput != 0
                    && annualCons != 0
                    && maxProportionOfConsumption != null
                    && (totalProjectedAnnualOutput / annualCons) > maxProportionOfConsumption
                    && incentive.Consumption_Adjustment_Type__c == 'Ineligible'
                    ){
            system.debug('Incentive Excluded: The Consumption Calulation Adjustment where the adjustment is not permitted for this incentive');
            createIncentive = false;
        }

        //8. Consumption Calculation Adjustment Permitted = ?TRUE? and Total Projected Annual Output/(sum(Annual Electricity Consumption) + Override Consumption Estimate > Production Limit and Consumption Adjustment Type = 'Ineligible'
        if(incentive.Consumption_Calculation_Adj_Permitted__c                         
                    && totalProjectedAnnualOutput != 0
                    && annualCons != 0
                    && maxProportionOfConsumption != null
                    && (totalProjectedAnnualOutput / (annualCons + additionalCons)) > maxProportionOfConsumption
                    && incentive.Consumption_Adjustment_Type__c == 'Ineligible'
                    ){
            system.debug('Incentive Excluded: The Consumption Calulation Adjustment where the adjustment is permitted for this incentive');
            createIncentive = false;
        }

        //9. TSRF Adjustment Type = ?Ineligible? and Minimum Standard TSRF is not ?null? and is greater than Suneye TSRF            
        if(incentive.TSRF_Adjustment_Type__c == 'Ineligible'
                    && incentive.Minimum_Standard_TSRF__c != null
                    && incentive.Minimum_Standard_TSRF__c > sdq.System_Design__r.Overall_TSRF__c
                    ){                
            system.debug('Incentive Excluded: TSRF Adjustment Type is ineligble if the standard TSRF is greater than the suneye tsrf.');
            system.debug('Incentive.Minimum_Standard_TSRF__c: ' + incentive.Minimum_Standard_TSRF__c);
            system.debug('sdq.System_Design__r.Overall_TSRF__c: ' + sdq.System_Design__r.Overall_TSRF__c);
            createIncentive = false;
        }
        
        //Exit if skipping
        if(!createIncentive) return;


        system.debug('This is a POTENTIAL MATCHING Incentive offer, need to create the incentive offer and check the exclusions questions.');

        id recType = AvailableIncentiveOfferRecordTypeNameMap.get(incentive.RecordType.Name).getRecordTypeID();
        Available_Incentive_Offer__c aio = new Available_Incentive_Offer__c();

        //Try to set tempAIO to the matching existing Available Incentive Offer record
        for(Available_Incentive_Offer__c a : incentiveOfferListToUpsert){
            if (a.Incentive_Offer__c == incentive.id && a.RecordTypeID == recType && a.Applicable_Scenario__c != null && a.Applicable_Scenario__c == string.valueof(ScenarioN)){
                aio = a;    //This will link by id and update the existing record below
                system.debug('Found existing Available Incentive Offer record: ' + aio.id);
                break;  //exit the for loop
            }
        }
        
        //Populate the updated information in this Available Incentive Offer
        if(!aio.Opted_Out_Manually__c)
        {
            aio.Incentive_Applied__c = true;
        }
        aio.Not_Matched_Reason__c = '';
        aio.Current_Matching_Incentive__c = true;  //We keep this flag so that we know to show this on the current screen for manual override
        aio.Name = incentive.Name;        

        //Rule out potential incentives based on additional questions            
        //Primary Residence
        if(incentive.Primary_Residence_Requirement__c){
            sdqForUpdate.Primary_Residence_Req__c = true;
            //Is Property Not Primary Residence?
            if(!sdq.Primary_Residence__c){                
                excludeAvailableIncentiveOffer(aio, 'Not matched because this Property is not the Primary Residence.');
            }
        }
            
        //Revocable Trust
        if(incentive.Revocable_Trust_Exclusion__c){
            sdqForUpdate.Property_in_Revocable_Trust_Req__c = true;            
            //Is Property held in a Revocable Trust?
            if(sdq.Property_in_Revocable_Trust__c){
                excludeAvailableIncentiveOffer(aio, 'Not matched because this Property cannot be held in a Revocable Trust.');
            }
        }
            
        //Historic Trust
        if(incentive.Historic_Trust_Exclusion__c){
            sdqForUpdate.Property_in_Historic_Trust_Req__c = true;            
            //Is Property in an Historic Trust?
            if(sdq.Property_in_Historic_Trust__c){            
                excludeAvailableIncentiveOffer(aio, 'Not matched because this Property cannot be in a Historic Trust.');                
            }
        }

        //Does this incentive only apply when there wasn't a previous incentive applied?
        if(incentive.Previous_Receipt_Exclusion__c){

            system.debug('Incentive Implementing Sector: ' + incentive.Implementing_Sector__c);
            system.debug('Incentive Recordtype: ' + incentive.RecordType.DeveloperName);

            //Is this incentive a State Rebate or State Rebate $/w?
            if(incentive.Implementing_Sector__c == 'State' &&
                (incentive.RecordType.DeveloperName == 'Rebate' || incentive.RecordType.DeveloperName == 'Rebate_W')){
                sdqForUpdate.Previously_Received_State_Rebate_Req__c = true;
                //Has property received a state rebate before?
                if(sdq.Previously_Received_State_Rebate__c){
                    excludeAvailableIncentiveOffer(aio, 'Not matched because this incentive cannot be used for a property that has already received a State Rebate.');                    
                }
            }

            //Is this incentive a state tax credit?
            if(incentive.Implementing_Sector__c == 'State' && incentive.RecordType.DeveloperName == 'Tax_Credit'){                
                sdqForUpdate.Previously_Received_State_Tax_Credit_Req__c = true;
                //Has property received a state tax credit before?
                if(sdq.Previously_Received_State_Tax_Credit__c){
                    excludeAvailableIncentiveOffer(aio, 'Not matched because this incentive cannot be used for a property that has already received a State Tax Credit.');                    
                }
            }

            //Is this incentive a county tax credit
            if(incentive.Implementing_Sector__c == 'County' && incentive.RecordType.DeveloperName == 'Tax_Credit'){
                sdqForUpdate.Previously_Received_County_Tax_Req__c = true;
                //Has property received a county tax credit?
                if(sdq.Previously_Received_County_Tax_Credit__c){
                    excludeAvailableIncentiveOffer(aio, 'Not matched because this incentive cannot be used for a property that has already received a County Tax Credit.');                    
                }
            }

            //Is this incentive a Utility Rebate or Utility Rebate $/w?
            if(incentive.Implementing_Sector__c == 'Utility' &&
                (incentive.RecordType.DeveloperName == 'Rebate' || incentive.RecordType.DeveloperName == 'Rebate_W')){
                sdqForUpdate.Previously_Received_Utility_Rebate_Req__c = true;
                //Has property received a Utility Rebate before?
                if(sdq.Previously_Received_Utility_Rebate__c){
                    excludeAvailableIncentiveOffer(aio, 'Not matched because this incentive cannot be used for a property that has already received a Utility Rebate.');
                }
            }
        }
        
        if (aio.id == null){
            system.debug('Did not find existing Available Incentive Offer record, inserting this new record.');
            aio.Incentive_Offer__c = incentive.id;
            aio.Applicable_Scenario__c = string.valueof(ScenarioN);
            aio.RecordTypeID = recType;            
            aio.System_Design_Quote__c = sdq.id;
            //Only add to the list if it's a new insert, if aio has an ID already, then it's in this list and we are updating it by ref.
            incentiveOfferListToUpsert.add(aio); 
        }
        
    }

    //MK - 2014-09-29
    private void excludeAvailableIncentiveOffer(Available_Incentive_Offer__c aio, string msg){        
        system.debug(msg);

        //Append a new line
        if(aio.Not_Matched_Reason__c != '') aio.Not_Matched_Reason__c = aio.Not_Matched_Reason__c + '\n';
        
        //Append the message
        aio.Not_Matched_Reason__c = aio.Not_Matched_Reason__c + '[' + msg + ']';
        
        //Set to false
        aio.Incentive_Applied__c = false;
    }


    //MK - 2014-09-29
    private void getSRECContractOffers(System_Design_Quote__c sdq){
        system.debug('=======================getSRECContractOffers');

        //Check for custom setting and return if this is disabled.
        system.debug('Get custom settings');
        System_Design_Quote_Settings__c settings = System_Design_Quote_Settings__c.getInstance(UserInfo.getUserId());
        if (settings == null){            
            system.debug('Missing required custom settings in System_Design_Quote_Settings__c.');
            return;
        }
        if(!settings.Run_SRECS_Sync__c){
            system.debug('Syncing SREC Contract offers is disabled in custom settings.');
            return;        
        }
        
        //SDQ is set by the method initSingleSDQ before getting to this point. This is a pre-requisite.
        if(sdqLoaded.Pricing_Locked__c){
            system.debug('Pricing is locked, exit this function.');
            return;
        }
        
        //===================
        //Run a sync of SREC Contract Offers every time since there could be a new offer in the system, or one that is back-dated etc.

        //Get Available SREC Contract Offer record types
        map<string, Schema.RecordTypeInfo> availableSRECContractOfferRecordTypeNameMap;
        Schema.DescribeSObjectResult dsra = Available_SREC_Contract_Offer__c.SObjectType.getDescribe();
        availableSRECContractOfferRecordTypeNameMap = dsra.getRecordTypeInfosByName();
        
        system.debug('Reset the Offer Applied flag to false');
        List<Available_SREC_Contract_Offer__c> availableSRECContractOfferListToUpsert = sdqLoaded.Available_SREC_Contract_Offers__r;
        for(Available_SREC_Contract_Offer__c aco : availableSRECContractOfferListToUpsert){
            //Reset all to false to begin with
            aco.Current_Matching_SREC_Offer__c = false;
            //aco.Contract_Offer_Applied__c = false; //Upon quote insert this will be false.  That's the only time we touch this field in code.  Beyond that, the user has full control of this checkbox.
        }


        system.debug('Get SREC Contract Offer records.');
        Map<Integer, boolean> scenariosHaveDefaultPicked = new map<integer, boolean>();
        scenariosHaveDefaultPicked.put(1, false);
        scenariosHaveDefaultPicked.put(2, false);
        scenariosHaveDefaultPicked.put(3, false);
        scenariosHaveDefaultPicked.put(4, false);

        Date pricingDate = Date.today();
        if (sdq.Pricing_Date__c != null)
            pricingDate = Date.newInstance(sdq.Pricing_Date__c.year(), sdq.Pricing_Date__c.month(), sdq.Pricing_Date__c.day());

        //SOQL to get all SREC Contract Offer records for date range
        //For each SREC Contract Offer
        for(SREC_Contract_Offer__c srec : [SELECT Name, ID, Financing_Type__c, Leasing_Option__c, 
                                                    RecordTypeId, RecordType.Name, SREC_Market__c, Default_Offer__c
                                            FROM SREC_Contract_Offer__c
                                            Where Start_Date__c <= :pricingDate 
                                                AND (End_Date__c = null OR End_Date__c >= :pricingDate)
                                                //SRECS are always per state, first filter on the parent market object, then loop to find the offers
                                                AND SREC_Market__c =: sdq.Quoted_SREC_Market__c
                                                AND Eligible_States__c includes(:sdqLoaded.System_Design__r.Property__r.Property_State__c)
                                            ]){

            system.debug('checking SREC Contract Offer: ' + srec.id);
            
            //If we get this far, then the SDQ-wide filters pass and this srec is a potential match.

            //Check each scenario:
            checkScenarioSREC(1, srec, sdq, availableSRECContractOfferListToUpsert, availableSRECContractOfferRecordTypeNameMap, scenariosHaveDefaultPicked);
            checkScenarioSREC(2, srec, sdq, availableSRECContractOfferListToUpsert, availableSRECContractOfferRecordTypeNameMap, scenariosHaveDefaultPicked);
            checkScenarioSREC(3, srec, sdq, availableSRECContractOfferListToUpsert, availableSRECContractOfferRecordTypeNameMap, scenariosHaveDefaultPicked);
            checkScenarioSREC(4, srec, sdq, availableSRECContractOfferListToUpsert, availableSRECContractOfferRecordTypeNameMap, scenariosHaveDefaultPicked);
        }

        //Need to end up with one of these outcomes:
            // - Found a matching Available SREC Contract Offer already connected... make sure it's active
            // - Did not find a matching Available SREC Contract Offer... Insert a new record as active
            
        //All of these situations will be stored in the same list

        if(!availableSRECContractOfferListToUpsert.isEmpty()) upsert availableSRECContractOfferListToUpsert; //Linked by the aco.id field for upsert
        
        if(!availableSRECContractOfferListToUpsert.isEmpty() && sdqForUpdate != null){
            for(Available_SREC_Contract_Offer__c aco : availableSRECContractOfferListToUpsert){
                if(aco.Contract_Offer_Applied__c && scenariosHaveDefaultPicked.get(Integer.valueOf(aco.Applicable_Scenario__c))){
                    sdqForUpdate.put('Scenario_' + aco.Applicable_Scenario__c + '_Available_SREC_Contract_Offer__c', aco.Id);                    
                }                
            }            
        }
    }

    
    //MK - 2014-09-29
    private void checkScenarioSREC(Integer scenarioN, 
                                        SREC_Contract_Offer__c srec, 
                                        System_Design_Quote__c sdq, 
                                        List<Available_SREC_Contract_Offer__c> SRECContractOfferListToUpsert, 
                                        map<string, Schema.RecordTypeInfo> availableSRECContractOfferRecordTypeNameMap, 
                                        Map<Integer, boolean> scenariosHaveDefaultPicked){
        
        //SET SDQ VARIABLES
        system.debug('********************check scenario ' + scenarioN + ' srec matching');
        String finType = (string)sdq.get('Scenario_' + scenarioN + '_Financing_Type__c');
        String leaseOption = (string)sdq.get('Scenario_' + scenarioN + '_Lease_Option__c');
        
        //The following logic allows matching based on if a srec has criteria filled in, the SDQ would need to meet all of that criteria
        system.debug('--------------------------');
        system.debug('SREC Financing Type: ' + srec.Financing_Type__c);
        system.debug('scenario.finType: ' + finType);
        system.debug('SREC Lease Option: ' + srec.Leasing_Option__c);
        system.debug('scenario.leaseOption: ' + leaseOption);
        
        //Is this a Financing Type specific offer that does not match?
        if(srec.Financing_Type__c != null){
            if(srec.Financing_Type__c != finType){
                system.debug('Finance type does not match for this scenario');
                return;
            }
            //else, we have a match and continue on
        }
        //else, this is not filtered by finance type

        //Is this a Leasing Option specific offer that does not match?
        if(srec.Leasing_Option__c != null){
            if(srec.Leasing_Option__c != leaseOption){
                system.debug('Leasing Option does not match for this scenario');
                return;
            }
            //else, we have a match and continue on
        }
        //else, this is not filtered by Leasing Option
        
        system.debug('This is a MATCHING SREC Contract offer');

        String srecRecType = srec.RecordType.Name;
        if (srecRecType == 'Upfront Cash Back')
            srecRecType = 'Upfront';    //Facilitating CPQ-675
        id recType = AvailableSRECContractOfferRecordTypeNameMap.get(srecRecType).getRecordTypeID();
        Available_SREC_Contract_Offer__c aco = new Available_SREC_Contract_Offer__c();

        //Try to set tempACO to the matching existing Available SREC Contract Offer record
        for(Available_SREC_Contract_Offer__c a : SRECContractOfferListToUpsert){
            if(a.SREC_Contract_Offer__c == srec.id
                    && a.RecordTypeID == recType
                    && a.Applicable_Scenario__c != null && a.Applicable_Scenario__c == string.valueof(scenarioN)){

                aco = a; //This will link by id and update the existing record below
                system.debug('Found existing Available SREC Contract Offer record: ' + aco.id);
                break; //exit the for loop
            }
        }
        
        //Populate the updated information in this Available SREC Contract Offer
        if(trigger.isInsert && srec.Default_Offer__c && !scenariosHaveDefaultPicked.get(scenarioN)){
            aco.Contract_Offer_Applied__c = true;
            scenariosHaveDefaultPicked.put(scenarioN, true); //make sure that only one per scenario is picked.
            
        }//Else, the user can change this option upon update.

        aco.Name = srec.Name;
        aco.Current_Matching_SREC_Offer__c = true;
        
        if(aco.id == null){
            system.debug('Did not find existing Available SREC Contract Offer record, inserting this new record.');
            aco.SREC_Contract_Offer__c = srec.id;
            aco.Applicable_Scenario__c = string.valueof(ScenarioN);
            aco.RecordTypeID = recType;            
            aco.System_Design_Quote__c = sdq.id;
            //Only add to the list if it's a new insert, if aco has an ID already, then it's in this list and we are updating it by ref.
            SRECContractOfferListToUpsert.add(aco); 
        }            
        
    }
    

    //MK - 2014-07-21
    private void getPricing(System_Design_Quote__c sdq){
        system.debug('========================getPricing');
        
        SDQGetPricing gp;
        
        //Check for custom setting and return if this is disabled.
        system.debug('Get custom settings'); 
        System_Design_Quote_Settings__c settings = System_Design_Quote_Settings__c.getInstance(UserInfo.getUserId());
        if (settings == null){            
            system.debug('Missing required custom settings in System_Design_Quote_Settings__c.');
            return;
        }
        if(!settings.Run_Pricing_Automatically__c){
            system.debug('Running pricing automatically is disabled in custom settings.');
            return;
        }
        
        //First try to setup the constructor for this quote
        try{
            gp = new SDQGetPricing(sdq.id);
            system.debug('gp.errorLog: ' + gp.errorLog);
            //Check to see if there were any known errors
            if(gp.errorLog != null && gp.errorLog.length() > 0){
                system.debug('There was a problem calculating the price for this quote.  Please review these errors: ' + gp.errorLog);                
                return;
            }
        }catch(exception e){            
            system.debug('There was a problem initializing the pricing constructor.  Please review these errors: ' + e);            
            try{                
                System_Design_Quote__c sdqTemp = new System_Design_Quote__c(id = sdq.id);
                sdqTemp.Pricing_Error_Log__c = 'There was a problem initializing the pricing constructor.  Please review these errors: ' + e.getMessage() + '. Line: ' + e.getLineNumber() + '. ' + e.getStackTraceString();
                update sdqTemp;
            }catch(exception e2){             
                system.debug('There was a problem saving to the sdq error log. ' + e2);
            }
            return;
        }

        //Try to calculate the pricing if there were no errors
        try{
            system.debug('get pricing');
            gp.getPricing();
        }catch(exception e){                
            system.debug('There was a problem getting pricing.  Please review these errors: ' + e);

            try{
                if(gp.sdq.Pricing_Error_Log__c == null) gp.sdq.Pricing_Error_Log__c = '';
                gp.sdq.Pricing_Error_Log__c += 'There was a problem getting pricing.  Please review these errors: ' + e.getMessage() + '. Line: ' + e.getLineNumber() + '. ' + e.getStackTraceString();
                update gp.sdq;
            }catch(exception e2){             
                system.debug('There was a problem saving to the sdq error log. ' + e2);
            }
        }

    }
    
    //DK  11-17-14  Use in conjunction with SalesWorkflowValidationUtility
    public void systemDesignQuoteProposalRules(System_Design_Quote__c sdq){
        Proposal__c[] proposalList = [SELECT Closed__c, Open_Quote__c, Closed_Scenario__c FROM Proposal__c WHERE System_Design_Quote__c = :sdq.ID];
        //Set Proposal flags
        Boolean proposalOpenQuote = false;
        String proposalClosedScenario = '';    //Closed_Scenario__c field for one and only one closed Proposal
        Integer numProposalsClosed = 0;
        for (Proposal__c prop : proposalList){
            if (prop.Open_Quote__c)
                proposalOpenQuote = true;
            if (prop.Closed__c){
                numProposalsClosed++;
                if (numProposalsClosed == 1)
                    proposalClosedScenario = prop.Closed_Scenario__c;
                else
                    proposalClosedScenario = '';
            }
        }
         
        //SDQ field rules
        if (!sdq.Closed__c && proposalOpenQuote){
            sdq.Open_Quote__c = true;
        } else {
            sdq.Open_Quote__c = false;
        }
        if (numProposalsClosed == 1){
            sdq.Closed__c = true;
        } else {
            sdq.Closed__c = false;
        }
        if (proposalClosedScenario != '')
            sdq.Closed_Scenario__c = proposalClosedScenario;
        //No DML necessary because this method should be called from a "before update" context
    }
}