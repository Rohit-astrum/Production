/* FILE: SDQGetPricing.cls
 * AUTHOR: Mike Katulka
 * DATE: March 31, 2014
 * PURPOSE: Class for getting pricing on SDQ
 * MODIFICATION HISTORY:
 *            MK - 03/27/2014 - Added Trenching calculation and Purchase calculation.  Merged methods for lease/purchase.
 *            MK - 03/31/2014 - Moved core logic here into common class so that we can more easily get to work on a trigger.
 *            MK - 04/02/2014 - Added error logging into text fields
 *            MK - 07/21/2014 - Phase 2 changes
 *            DK - 03/05/2015 - Added setTermLoanPricing()
 *            SZ - 04/15/2015 - Added code to calculate Scenario_N_Commission_Impact_Promotions
 *            PB - 06/01/2015 - CPQ-161
 *            DK - 07/13/2015 - Updated error messages as per CPQ-612
 *            DK - 08/04/2015 - Added Lease fields validation as specified in CPQ-649. See setScenarioDesignPrice().
 *            DK - 12/09/2015 - Implemented OneRoof Portfolio PPA pricing for CPQ-745.
 *            DK - 02/15/2016 - Refactored Portfolio PPA pricing to allow discretionary discounts for when the top threshold is exceeded by adders [CPQ-819].
 */

public without sharing class SDQGetPricing {
    public System_Design_Quote__c sdq; //FOR DML
    map<id, Price_Adjustment__c> priceAdjustmentsToUpdateMap; //FOR DML
    map<id, Available_SREC_Contract_Offer__c> upfrontSRECsToUpdateMap; //FOR DML
    map<id, Available_Incentive_Offer__c> availableIncentiveOffersToUpdateMap;  //FOR DML
    Set<ID> panelSdpIds = new Set<ID>();
    Set<ID> nonPanelSdpIds = new Set<ID>();
    Set<String> sdpQtySet = new Set<String>();    
    List<System_Design_Item__c> panelItems = new List<System_Design_Item__c>();
    List<System_Design_Item__c> nonPanelItems = new List<System_Design_Item__c>();
    List<System_Design_Item__c> trenchingItems = new List<System_Design_Item__c>();
    List<Financing_Product_Pricing__c> financingProductPricingMatches;
    String salesRegion;
    id pricingRegion;
    String commProg;
    String commProgTier; 
    integer commProgBaselineSQ;
    string propState;
    decimal systemSizeKW;
    decimal systemSizeW;
    decimal totalPanels;
    decimal overallTSRF;    
    map<string, Schema.RecordTypeInfo> priceAdjustmentRecordTypeNameMap;
    map<id, Schema.RecordTypeInfo> priceAdjustmentRecordTypeIDMap;
    public String errorLog = '';
    boolean isError = false;

    public SDQGetPricing(ID sdqId) {

        //******* When using this constructor, be sure to check the errorLog value after instantiating it.

        system.debug('***Constructor for SDQGetPricing');
        isError = false;

        system.debug('Get custom settings'); 
        System_Design_Quote_Settings__c settings = System_Design_Quote_Settings__c.getInstance(UserInfo.getUserId());
        if (settings == null){            
            errorLog += '- Error: Missing required custom settings in System_Design_Quote_Settings__c.';
        }else{

            system.debug('SOQL for all SDQ fields');            
            sdq = [Select Pricing_Date__c, Community_Program_Offer__r.Baseline_Site_Quality__c, Community_Program_Offer__r.Current_Tier__c, Community_Program_Offer__r.Base_PPA_Rate__c, 
                    Community_Program_Offer__r.Size_Threshold__c, Community_Program_Offer__r.Size_Adder__c, Community_Program_Offer__r.High_PPA_Rate_Threshold__c, 
                    Community_Program_Offer__r.High_PPA_Rate_Adder__c, Community_Program_Offer__r.Ineligibility_Threshold__c, Community_Program_Offer__r.RecordType.DeveloperName, 

                    Income_Corporate_Tax_Rate__c, Annual_Property_Tax_Bill__c, Channel_Partner__c, Channel_Partner_Lease_Rate_kWh__c,
                    Previously_Received_State_Rebate__c, Previously_Received_State_Tax_Credit__c, Previously_Received_County_Tax_Credit__c, 
                    Previously_Received_Utility_Rebate__c, Moderate_Income_Value_Adder_Eligible__c, Moderate_Home_Value_Adder_Eligible__c, 
                    Natural_Disaster_Adder_Eligible__c, Property_in_Revocable_Trust__c, Property_in_Historic_Trust__c, Primary_Residence__c,
                    
                    System_Design__r.Property__r.Sales_Region__c, System_Design__r.Property__r.Property_ZIP__c, System_Design__r.System_Panel__c, 
                    System_Design__r.Avoided_Utility_Rate__c,
                    System_Design__r.NRG_Avoided_Utility_Rate__c,System_Design__r.Sunnova_Avoided_Utility_Rate__c,
                    System_Design__r.Property__r.RecordType.DeveloperName,Pricing_Locked__c, System_Design__r.Total_System_Size_kW__c,
                    System_Design__r.Total_System_Size_PTC_rating_kW__c, System_Design__r.Total_System_Size_AC_Rating_kW__c,
                    System_Design__r.Property__r.Property_State__c, System_Design__r.Property__r.Property_County__c, System_Design__r.Property__r.QAS_Property_County__c,
                    System_Design__r.Panel_Count__c,System_Design__r.Overall_Site_Quality__c,System_Design__r.Sunnova_Overall_Site_Quality__c,
                    System_Design__r.NRG_Overall_Site_Quality__c,
                    //System_Design__r.Property__r.Property_Owner__r.RecordType.DeveloperName //Could not reference because Record types are not enabled in Account yet.  ,
                    System_Design__r.Total_Projected_Annual_Output_kWh_y__c,
                    System_Design__r.NRG_Projected_Annual_Output_kWh_y__c, System_Design__r.Sunnova_Projected_Annual_Output_kWh_y__c,
                    System_Design__r.Overall_TSRF__c, System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__c, 
                    System_Design__r.Default_CB_Panel__r.Utility_Service__r.Before_Total_Bill__c, System_Design__r.Default_CB_Panel__r.Utility_Service__r.Method_1_Net_Bill__c, 
                    System_Design__r.Default_CB_Panel__r.Utility_Service__r.Method_1_Production_kWh__c, 
                    System_Design__r.Default_CB_Panel__r.Utility_Service__r.Before_First_Year_Avg_Price__c, 
                    System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Jan__c, System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Feb__c, 
                    System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Mar__c, System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Apr__c, 
                    System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_May__c, System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Jun__c, 
                    System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Jul__c, System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Aug__c, 
                    System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Sep__c, System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Oct__c, 
                    System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Nov__c, System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Dec__c, 

                    Scenario_1_SAC_Loan_Adjustment__c, Scenario_1_FIT_Annual_Earnings_After_Tax__c, Scenario_1_FIT_Term_Length_Months__c, Scenario_1_Portfolio_Tier_Selected__c, Scenario_1_PPA_Adder_Reduction__c, 
                    Scenario_2_SAC_Loan_Adjustment__c, Scenario_2_FIT_Annual_Earnings_After_Tax__c, Scenario_2_FIT_Term_Length_Months__c, Scenario_2_Portfolio_Tier_Selected__c, Scenario_2_PPA_Adder_Reduction__c, 
                    Scenario_3_SAC_Loan_Adjustment__c, Scenario_3_FIT_Annual_Earnings_After_Tax__c, Scenario_3_FIT_Term_Length_Months__c, Scenario_3_Portfolio_Tier_Selected__c, Scenario_3_PPA_Adder_Reduction__c, 
                    Scenario_4_SAC_Loan_Adjustment__c, Scenario_4_FIT_Annual_Earnings_After_Tax__c, Scenario_4_FIT_Term_Length_Months__c, Scenario_4_Portfolio_Tier_Selected__c, Scenario_4_PPA_Adder_Reduction__c, 
                   
                    Scenario_1_Design_Price__c, Scenario_1_Lease_Escalator__c, Scenario_1_Lease_Fund__r.Finance_Pricing_Algorithm__c, Scenario_1_Lease_Fund__r.Name, Scenario_1_Avoided_Utility_Rate__c, Scenario_1_Financing_Type__c,
                    Scenario_2_Design_Price__c, Scenario_2_Lease_Escalator__c, Scenario_2_Lease_Fund__r.Finance_Pricing_Algorithm__c, Scenario_2_Lease_Fund__r.Name, Scenario_2_Avoided_Utility_Rate__c, Scenario_2_Financing_Type__c,
                    Scenario_3_Design_Price__c, Scenario_3_Lease_Escalator__c, Scenario_3_Lease_Fund__r.Finance_Pricing_Algorithm__c, Scenario_3_Lease_Fund__r.Name, Scenario_3_Avoided_Utility_Rate__c, Scenario_3_Financing_Type__c,
                    Scenario_4_Design_Price__c, Scenario_4_Lease_Escalator__c, Scenario_4_Lease_Fund__r.Finance_Pricing_Algorithm__c, Scenario_4_Lease_Fund__r.Name, Scenario_4_Avoided_Utility_Rate__c, Scenario_4_Financing_Type__c,

                    Scenario_1_Site_Quality__c, Scenario_1_Down_Payment__c, Scenario_1_Total_Projected_Annual_Output__c, Scenario_1_Promotion_Cash_Rebate_Amount__c, Scenario_1_Available_Portfolio_Tiers__c, 
                    Scenario_2_Site_Quality__c, Scenario_2_Down_Payment__c, Scenario_2_Total_Projected_Annual_Output__c, Scenario_2_Promotion_Cash_Rebate_Amount__c, Scenario_2_Available_Portfolio_Tiers__c, 
                    Scenario_3_Site_Quality__c, Scenario_3_Down_Payment__c, Scenario_3_Total_Projected_Annual_Output__c, Scenario_3_Promotion_Cash_Rebate_Amount__c, Scenario_3_Available_Portfolio_Tiers__c, 
                    Scenario_4_Site_Quality__c, Scenario_4_Down_Payment__c, Scenario_4_Total_Projected_Annual_Output__c, Scenario_4_Promotion_Cash_Rebate_Amount__c, Scenario_4_Available_Portfolio_Tiers__c, 

                    Scenario_1_Credit_Tier__c, Scenario_1_Proposal_Term_months__c, Scenario_1_SREC_Cash_Back__c, Scenario_1_VP_Sales_Adjustments__c, Scenario_1_Portfolio_Default_Tier__c, 
                    Scenario_2_Credit_Tier__c, Scenario_2_Proposal_Term_months__c, Scenario_2_SREC_Cash_Back__c, Scenario_2_VP_Sales_Adjustments__c, Scenario_2_Portfolio_Default_Tier__c, 
                    Scenario_3_Credit_Tier__c, Scenario_3_Proposal_Term_months__c, Scenario_3_SREC_Cash_Back__c, Scenario_3_VP_Sales_Adjustments__c, Scenario_3_Portfolio_Default_Tier__c, 
                    Scenario_4_Credit_Tier__c, Scenario_4_Proposal_Term_months__c, Scenario_4_SREC_Cash_Back__c, Scenario_4_VP_Sales_Adjustments__c, Scenario_4_Portfolio_Default_Tier__c, 

                    Scenario_1_Lease_Option__c, Scenario_1_Term_Loan__r.Financing_Term_Months__c, Scenario_1_Term_Loan_Amount__c, Scenario_1_Term_Loan__r.Customer_Fees__c, 
                    Scenario_2_Lease_Option__c, Scenario_2_Term_Loan__r.Financing_Term_Months__c, Scenario_2_Term_Loan_Amount__c, Scenario_2_Term_Loan__r.Customer_Fees__c, 
                    Scenario_3_Lease_Option__c, Scenario_3_Term_Loan__r.Financing_Term_Months__c, Scenario_3_Term_Loan_Amount__c, Scenario_3_Term_Loan__r.Customer_Fees__c, 
                    Scenario_4_Lease_Option__c, Scenario_4_Term_Loan__r.Financing_Term_Months__c, Scenario_4_Term_Loan_Amount__c, Scenario_4_Term_Loan__r.Customer_Fees__c, 

                    Scenario_1_Refuse_ACH__c, Scenario_1_Term_Loan__r.APR__c, Scenario_1_Term_Loan__r.Monthly_Interest_Rate__c, Scenario_1_Term_Loan__r.Non_ACH_APR__c, Scenario_1_Term_Loan__r.Non_ACH_Monthly_Interest_Rate__c,
                    Scenario_2_Refuse_ACH__c, Scenario_2_Term_Loan__r.APR__c, Scenario_2_Term_Loan__r.Monthly_Interest_Rate__c, Scenario_2_Term_Loan__r.Non_ACH_APR__c, Scenario_2_Term_Loan__r.Non_ACH_Monthly_Interest_Rate__c,
                    Scenario_3_Refuse_ACH__c, Scenario_3_Term_Loan__r.APR__c, Scenario_3_Term_Loan__r.Monthly_Interest_Rate__c, Scenario_3_Term_Loan__r.Non_ACH_APR__c, Scenario_3_Term_Loan__r.Non_ACH_Monthly_Interest_Rate__c,
                    Scenario_4_Refuse_ACH__c, Scenario_4_Term_Loan__r.APR__c, Scenario_4_Term_Loan__r.Monthly_Interest_Rate__c, Scenario_4_Term_Loan__r.Non_ACH_APR__c, Scenario_4_Term_Loan__r.Non_ACH_Monthly_Interest_Rate__c,

                    Scenario_1_Term_Loan__r.Assumed_Utility_Rate_Annual_Escalator__c, Scenario_1_Term_Loan__r.Required_Utility_Savings_term__c, 
                    Scenario_2_Term_Loan__r.Assumed_Utility_Rate_Annual_Escalator__c, Scenario_2_Term_Loan__r.Required_Utility_Savings_term__c, 
                    Scenario_3_Term_Loan__r.Assumed_Utility_Rate_Annual_Escalator__c, Scenario_3_Term_Loan__r.Required_Utility_Savings_term__c, 
                    Scenario_4_Term_Loan__r.Assumed_Utility_Rate_Annual_Escalator__c, Scenario_4_Term_Loan__r.Required_Utility_Savings_term__c, 

                    Scenario_1_Term_Loan__r.Required_Utility_Savings__c, Scenario_1_Term_Loan__r.RecordTypeDeveloperName__c, Scenario_1_Term_Loan__r.Requires_SAC_Loan__c, 
                    Scenario_2_Term_Loan__r.Required_Utility_Savings__c, Scenario_2_Term_Loan__r.RecordTypeDeveloperName__c, Scenario_2_Term_Loan__r.Requires_SAC_Loan__c, 
                    Scenario_3_Term_Loan__r.Required_Utility_Savings__c, Scenario_3_Term_Loan__r.RecordTypeDeveloperName__c, Scenario_3_Term_Loan__r.Requires_SAC_Loan__c, 
                    Scenario_4_Term_Loan__r.Required_Utility_Savings__c, Scenario_4_Term_Loan__r.RecordTypeDeveloperName__c, Scenario_4_Term_Loan__r.Requires_SAC_Loan__c, 

                    Scenario_1_Term_Loan__r.Fund_Open_Date__c, Scenario_1_Term_Loan__r.Fund_Closed_Date__c, Scenario_1_SAC_Loan__r.Fund_Open_Date__c, Scenario_1_SAC_Loan__r.Fund_Closed_Date__c, Scenario_1_Lease_Fund__r.Fund_Open_Date__c, Scenario_1_Lease_Fund__r.Fund_Closed_Date__c, 
                    Scenario_2_Term_Loan__r.Fund_Open_Date__c, Scenario_2_Term_Loan__r.Fund_Closed_Date__c, Scenario_2_SAC_Loan__r.Fund_Open_Date__c, Scenario_2_SAC_Loan__r.Fund_Closed_Date__c, Scenario_2_Lease_Fund__r.Fund_Open_Date__c, Scenario_2_Lease_Fund__r.Fund_Closed_Date__c, 
                    Scenario_3_Term_Loan__r.Fund_Open_Date__c, Scenario_3_Term_Loan__r.Fund_Closed_Date__c, Scenario_3_SAC_Loan__r.Fund_Open_Date__c, Scenario_3_SAC_Loan__r.Fund_Closed_Date__c, Scenario_3_Lease_Fund__r.Fund_Open_Date__c, Scenario_3_Lease_Fund__r.Fund_Closed_Date__c, 
                    Scenario_4_Term_Loan__r.Fund_Open_Date__c, Scenario_4_Term_Loan__r.Fund_Closed_Date__c, Scenario_4_SAC_Loan__r.Fund_Open_Date__c, Scenario_4_SAC_Loan__r.Fund_Closed_Date__c, Scenario_4_Lease_Fund__r.Fund_Open_Date__c, Scenario_4_Lease_Fund__r.Fund_Closed_Date__c, 

                    Scenario_1_SAC_Loan__r.Maximum_Financed_Amount__c, Scenario_2_SAC_Loan__r.Maximum_Financed_Amount__c, Scenario_3_SAC_Loan__r.Maximum_Financed_Amount__c, Scenario_4_SAC_Loan__r.Maximum_Financed_Amount__c,
                    Scenario_1_Adjusted_Price_NUM__c, Scenario_2_Adjusted_Price_NUM__c, Scenario_3_Adjusted_Price_NUM__c, Scenario_4_Adjusted_Price_NUM__c, 
                    Scenario_1_SREC_Contract_Discount__c, Scenario_2_SREC_Contract_Discount__c, Scenario_3_SREC_Contract_Discount__c, Scenario_4_SREC_Contract_Discount__c, 

                    //PRICE ADJUSTMENTS
                    (SELECT Name, RecordType.DeveloperName, RecordTypeID, Applicable_Scenario__c, Amount__c, Amount_per_Watt__c, Effective_Dollar_Amount__c, 
                            Percent__c, Type__c, Apply_As_Net_Adjustment__c, Channel_Partner_Adjustment__c, Adjustment_Applied__c, Opt_Out_of_Adjustment__c, Promotion__r.Eligible_as_Cash_Back__c 
                    FROM Price_Adjustments__r),

                    //AVAILABLE INCENTIVE OFFERS
                    (SELECT Name, RecordTypeId, RecordType.DeveloperName, Agency_Retains_RECs__c, American_Made_Adder_W__c, American_Made_Cap_kW__c, Applicable_Scenario__c, 
                        Consumption_Adjustment_Type__c, Consumption_Calculation_Adj_Permitted__c, Credit_Capped_by_Annual_Tax_Obligation__c, 
                        Customer_Receives_RECs_Revenue__c, Depreciation_Basis_Rate__c, SAC_Eligible__c, Incentive_Offer__r.Term_Months__c, 
                        Depreciation_Year_1__c, Depreciation_Year_2__c, Depreciation_Year_3__c, Depreciation_Year_4__c, Depreciation_Year_5__c, Depreciation_Year_6__c, 
                        Eligible_Cost_Basis__c, Eligible_Estimated_Consumption__c, Eligible_Financing_Type__c, Eligible_Sector__c, 
                        Flat_Rebate_Amount__c, Historic_Trust_Exclusion__c, Implementing_Sector__c, Incentive_Applied__c, Applied_Manually__c, 
                        Opted_Out_Manually__c, Incentive_Recipient__c, Maximum_Allowable_Tax_Credit__c, Maximum_Azimuth__c, 
                        Maximum_Eligible_Estimated_Consumption__c, Maximum_Eligible_System_Size_kW__c, Maximum_Proportion_of_Consumption__c, 
                        Maximum_Proportion_of_Total_Cost__c, Maximum_Tilt__c, Minimum_Azimuth__c, Minimum_Eligible_System_Size_kW__c, Minimum_Standard_TSRF__c, 
                        Minimum_Tilt__c, Mod_Home_Value_Mod_Income_Adder_W__c, Mod_Home_Value_Mod_Income_Cap_kW__c, Natural_Disaster_Adder_W__c, 
                        Natural_Disaster_Cap_kW__c, PBI_Amount__c, Previous_Receipt_Exclusion__c, Primary_Residence_Requirement__c,
                        Revocable_Trust_Exclusion__c, Size_Panel_Capped__c, System_Size_Units__c, TSRF_Adjustment_Type__c, Tax_Credit_Rate__c, Tier_Pricing_Type__c,
                        Tier_1_Incentive_Rate_W__c, Tier_1_Maximum_System_Size_kW__c, Tier_2_Incentive_Rate_W__c, Tier_2_Maximum_System_Size_kW__c, 
                        Incentive_Offer__r.FIT_Tier_1_Max_Sys_Size_kW__c, Incentive_Offer__r.FIT_Tier_1_Amount__c, 
                        Incentive_Offer__r.FIT_Tier_2_Max_Sys_Size_kW__c, Incentive_Offer__r.FIT_Tier_2_Amount__c 
                    FROM Available_Incentive_Offers__r
                    WHERE Current_Matching_Incentive__c = true),
                                                                            //WHERE (Incentive_Applied__c = true OR Applied_Manually__c = true) AND Opted_Out_Manually__c = false)
                                                                            //not filtering on Incentive_Active__c because it could be post-dated design. Might need more logic surrounding this.

                    //GET EXISTING UPFRONT APPLIED AVAILABLE SREC CONTRACT OFFERS
                    (SELECT RecordType.DeveloperName, RecordTypeId, Applicable_Scenario__c, SREC_Contract_Offer__r.SREC_Earnings_Based_on_KW__c, 
                            SREC_Contract_Offer__r.Cash_Payout_Limit__c, SREC_Contract_Offer__r.RecordType.DeveloperName, Upfront_Effective_Dollar_Amount__c, Upfront_Amount__c, Contract_Offer_Applied__c 
                        FROM Available_SREC_Contract_Offers__r
                        WHERE RecordType.DeveloperName = 'Upfront')

             From System_Design_Quote__c Where Id = :sdqID];
            
            

            if(sdq.Pricing_Locked__c){
                errorLog += '\n- Error: Pricing is locked for this Quote.';
            }else{

                //Clear values for fields that normally get updated.
                resetPricingFields();

                if (sdq.System_Design__r.Property__c == null){
                    errorLog += '\n- Error: Property not linked to System Design';
                } else {

                    propState = sdq.System_Design__r.Property__r.Property_State__c;
                    Date pricingDate = Date.today();
                    if (sdq.Pricing_Date__c != null)
                        pricingDate = Date.newInstance(sdq.Pricing_Date__c.year(), sdq.Pricing_Date__c.month(), sdq.Pricing_Date__c.day());

                    Date cutoffDate = System_Design_Quote_Settings__c.getOrgDefaults().County_Pricing_Region_Cutoff_Date__c;
                    if (cutoffDate != null && pricingDate < cutoffDate){
                        system.debug('***Query for County');    //Need to try to set the pricing region ID
                                            
                        string county = sdq.System_Design__r.Property__r.Property_County__c;
                        string qasCounty = sdq.System_Design__r.Property__r.QAS_Property_County__c;

                        if (propState != null && (propState == 'DC' || county != null || qasCounty != null)){
                            String crit = '(State_Abbreviation__c = \'' + String.escapeSingleQuotes(propState) + '\'';
                            if (propState != 'DC')
                                crit += ' AND Name LIKE \'' + String.escapeSingleQuotes(qasCounty != null ? qasCounty : SalesRegionHelper.removeState(county)) + '%\'';
                            
                            crit += ')';    
                            string query = 'SELECT id, Name, Pricing_Region__c FROM County__c ';
                            query+= ' WHERE ' + crit + ' limit 1';
                            list<County__c> counties = database.query(query);
                            if (counties.isempty()){
                                errorLog += '\n- Error: County record not found for Property.';
                            } else {                    
                                if (counties[0].Pricing_Region__c == null){
                                    errorLog += '\n- Error: Pricing Region is not set in the County: ' + counties[0].Name + '';    
                                } else {
                                    pricingRegion = counties[0].Pricing_Region__c;
                                }
                            }
                        } else {
                            errorLog += '\n- Error: Missing State/County information in Property. Cannot lookup the county.';
                        }

                    } else if (cutoffDate != null && sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__c != null){    //CPQ-751
                        String zip = sdq.System_Design__r.Property__r.Property_ZIP__c.substring(0,5);
                        ID utilCompanyID = sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__c;
                        Utility_by_Zip_Code__c[] utilByZips = [SELECT Pricing_Region__c FROM Utility_by_Zip_Code__c WHERE Utility_Zip_Code__c = :zip AND Utility_Company_Master__c = :utilCompanyID 
                                                                AND Start_Date__c <= :pricingDate AND (End_Date__c = null OR End_Date__c >= :pricingDate)];
                        if (utilByZips.isEmpty()){
                            errorLog += '\n- Error: Could not find any "Utility by Zip Code" records with a zip code of ' + zip + ', utility company matching the System Design\'s, ' + 
                                        'and a start/end date range containing ' + pricingDate.format() + '.';
                        } else if (utilByZips.size() > 1){
                            errorLog += '\n- Error: Found more than one "Utility by Zip Code" record with a zip code of ' + zip + ', utility company matching the System Design\'s, ' + 
                                        'and a start/end date range containing ' + pricingDate.format() + '.';
                        } else {
                            pricingRegion = utilByZips[0].Pricing_Region__c;
                        }
                    } else if (cutoffDate != null){
                        errorLog += '\n- Error: Utility Company Master must be set on the Utility Service record in order to obtain Pricing Region.';
                    } else {
                        errorLog += '\n- Error: County Pricing Region Cutoff Date must be set in the System Design Quote Settings.';
                    }
                }
            }
        }

        if(errorLog != null && errorLog.length() > 0){
            if(sdq.Pricing_Error_Log__c == null) sdq.Pricing_Error_Log__c = '';
            sdq.Pricing_Error_Log__c = errorLog;
            system.debug('***ERROR: ' + errorLog);            
        }
         
        update sdq; //update sdq to reset the pricing fields & update the error log, cleared or with an error
    } 



    public void getPricing(){
        system.debug('getPricing method starting');
        errorLog = '';

        //Get price adjustments record types        
        Schema.DescribeSObjectResult dsra = Price_Adjustment__c.SObjectType.getDescribe();
        priceAdjustmentRecordTypeNameMap = dsra.getRecordTypeInfosByName();
        priceAdjustmentRecordTypeIDMap = dsra.getRecordTypeInfosByID();

        //Run some initial validations
        if(sdq.System_Design__r.Panel_Count__c == null || sdq.System_Design__r.Panel_Count__c < 4){
            system.debug('Minimum of 4 panels is required in order to run pricing calculations.');
            errorLog += '\n- Error: Minimum of 4 panels is required in order to run pricing calculations.';
        }

        if(sdq.Pricing_Locked__c){
            system.debug('pricing locked');
            errorLog += '\n- Error: Pricing is locked, cannot recalculate pricing.';            
        }

        if(errorLog != ''){
            if(sdq.Pricing_Error_Log__c == null) sdq.Pricing_Error_Log__c = '';
            sdq.Pricing_Error_Log__c += errorLog;
            update sdq;
        }

        //Set local variables
        priceAdjustmentsToUpdateMap = new map<id, Price_Adjustment__c>();
        upfrontSRECsToUpdateMap = new map<id, Available_SREC_Contract_Offer__c>();
        availableIncentiveOffersToUpdateMap = new map<id, Available_Incentive_Offer__c>();
        salesRegion = sdq.System_Design__r.Property__r.Sales_Region__c;
        systemSizeKW = sdq.System_Design__r.Total_System_Size_kW__c;
        totalPanels = sdq.System_Design__r.Panel_Count__c;
        systemSizeW = systemSizeKW * 1000;
        overallTSRF = sdq.System_Design__r.Overall_TSRF__c/100;
        commProg = sdq.Community_Program_Offer__c;
        if(commProg != null){
            commProgTier = sdq.Community_Program_Offer__r.Current_Tier__c;
            commProgBaselineSQ = (Integer)sdq.Community_Program_Offer__r.Baseline_Site_Quality__c;
        }

        system.debug('get SDIs');
        // Get the list of all System Design Items Where Quantiy > 0
        list<System_Design_Item__c> sditems = [Select s.System_Design_Product__r.Description__c, s.System_Design_Product__r.RecordType.DeveloperName, s.System_Design_Product__r.Name, s.System_Design_Array__r.System_Design__c
                                                    , s.System_Design_Array__c, s.Rated_Output_kW__c, s.Quantity__c, s.Id
                                                    , s.RecordType.DeveloperName, s.System_Design_Array__r.Array_Size_kW__c, s.System_Design_Array__r.Panel_Count__c
                                                    , s.System_Design_Array__r.Total_Trenching_Length_ft__c, s.System_Design_Product__r.Wire_Type__c
                                                 From System_Design_Item__c s 
                                                Where s.System_Design_Array__r.System_Design__c = :sdq.System_Design__c
                                                  AND s.RecordType.DeveloperName IN ('Panel','Inverter','Mounting','Special_Part', 'Trenching', 'Entitlement')];
        
        //Error on missing sditems
        if(sditems.isempty()){ 
            system.debug('no items');
            errorLog += '\n- Error: No System Design Items';
        }else{
            system.debug('Found items');

            //Split the SDI's into different lists which will be calculated in groups
            for(System_Design_Item__c sdi : sditems){
                system.debug('Item: ' + sdi.id);
                // Get the list of Panel and Non-Panel Ids
                if(sdi.RecordType.DeveloperName == 'Panel'){
                    if(sdi.Quantity__c > 0){
                        panelSdpIds.add(sdi.System_Design_Product__c);  
                        panelItems.add(sdi);
                        //sdpQtySet.add('Count_' + sdi.Quantity__c + '_Root_Price__c');
                    }

                }else{               

                    if(sdi.RecordType.DeveloperName == 'Trenching' && sdi.System_Design_Product__r.RecordType.DeveloperName == 'Trenching'){
                        //Get the Trenching items. Only 1 should exist per array and this will be enforced.
                        if(sdi.Quantity__c > 0){
                            trenchingItems.add(sdi);saveDetail('', false, 1, 'trenching ids:--------' + sdi.System_Design_Product__c);
                        }
                    }else{          
                        //Get non-panel items
                        //Trenching Items would be included here if there was a community program offer
                        if(sdi.Quantity__c > 0){
                            nonPanelSdpIds.add(sdi.System_Design_Product__c);
                            nonPanelItems.add(sdi); saveDetail('', false, 1, 'non panel ids:--------' + sdi.System_Design_Product__c);
                        }
                    }
                }   
                
            }
            
            system.debug('Check the Lock Flag and Property Record Type - Run the logic for Residential Property');
            if(sdq.System_Design__r.Property__r.RecordType.DeveloperName == 'Residential'){
                system.debug('This is Residential, and pricing is not locked.');
                
                //Set quote level generic values that can be used during pricing calculations
                if (sdq.Pricing_Date__c == null)    //Allows a pricing date to be set in the SDQ input page to generate "as of" pricing results. See CPQ-559.
                    sdq.Pricing_Date__c = Datetime.now();
                sdq.Property_Record_Type__c = sdq.System_Design__r.Property__r.RecordType.DeveloperName;
                sdq.Total_System_Size_kW__c = systemSizeKW;
                sdq.Sales_Region__c = salesRegion;
                sdq.Pricing_Region__c = pricingRegion;
                //sdq.Community_Program_Offer__c = commProg; This now gets filled in with before trigger
                sdq.Panel_Count__c = sdq.System_Design__r.Panel_Count__c;
                sdq.Community_Program_Offer_Current_Tier__c = commProgTier;
                sdq.Community_Program_Offer_Baseline_SQ__c = commProgBaselineSQ;
                sdq.state__c = propState;
                sdq.Avoided_Utility_Rate__c = sdq.System_Design__r.Avoided_Utility_Rate__c;
                sdq.NRG_Avoided_Utility_Rate__c = sdq.System_Design__r.NRG_Avoided_Utility_Rate__c;
                sdq.Sunnova_Avoided_Utility_Rate__c = sdq.System_Design__r.Sunnova_Avoided_Utility_Rate__c;
                sdq.Astrum_Overall_Site_Quality__c = sdq.System_Design__r.Overall_Site_Quality__c;
                sdq.Sunnova_Overall_Site_Quality__c = sdq.System_Design__r.Sunnova_Overall_Site_Quality__c;
                sdq.NRG_Overall_Site_Quality__c = sdq.System_Design__r.NRG_Overall_Site_Quality__c;
                //Could not reference because Record types are not enabled in Account yet.
                //sdq.Account_Record_Type__c = sdq.System_Design__r.Property__r.Property_Owner__r.RecordType.DeveloperName;
                sdq.Total_Projected_Annual_Output__c = sdq.System_Design__r.Total_Projected_Annual_Output_kWh_y__c;
                sdq.NRG_Projected_Annual_Output__c = sdq.System_Design__r.NRG_Projected_Annual_Output_kWh_y__c;
                sdq.Sunnova_Projected_Annual_Output__c = sdq.System_Design__r.Sunnova_Projected_Annual_Output_kWh_y__c;
                sdq.Suneye_TSRF__c = sdq.System_Design__r.Overall_TSRF__c;

                //Set scenario specific values
                setScenarioDesignPrice(1);
                setScenarioDesignPrice(2);
                setScenarioDesignPrice(3);
                setScenarioDesignPrice(4);

                saveDetail('', false, 1, 'priceAdjustmentsToUpdateMap: ' + priceAdjustmentsToUpdateMap.size());

                if(!priceAdjustmentsToUpdateMap.isempty()) update priceAdjustmentsToUpdateMap.values();
                if(!upfrontSRECsToUpdateMap.isempty()) update upfrontSRECsToUpdateMap.values();  
                if(!availableIncentiveOffersToUpdateMap.isempty()) update availableIncentiveOffersToUpdateMap.values();

                saveDetail('', false, 1, ' Updated priceAdjustmentsToUpdateMap: ' );

            }else if(sdq.System_Design__r.Property__r.RecordType.DeveloperName == 'Commercial'){
             
                system.debug('This is Commercial, and pricing is not locked.');

            }else{
             
                errorLog += '\n- Error: No matching Record Type for pricing: ' + sdq.System_Design__r.Property__r.RecordType.DeveloperName;
            }

        }

        if(errorLog != null && errorLog.length() > 0){
            if(sdq.Pricing_Error_Log__c == null) sdq.Pricing_Error_Log__c = '';
            sdq.Pricing_Error_Log__c += errorLog;
            system.debug('***ERROR: ' + errorLog);
        }

        update sdq;
    }


    //MK - 3-28-2014 - Made method dynamic based on the scenario number, returns nothing and sets the field values dynamically.
    public void setScenarioDesignPrice(integer scenarioN){
        isError = false;
        saveDetail('', false, scenarioN, 'Set Scenario Design Price');
        sdq.put('Scenario_' + scenarioN + '_SREC_Cash_Back__c', null);  //Reset
        sdq.put('Scenario_' + scenarioN + '_FIT_Term_Length_Months__c', null);
        if (sdq.get('Scenario_' + scenarioN + '_Lease_Option__c') != 'Portfolio PPA'){      //CPQ-745
            sdq.put('Scenario_' + scenarioN + '_Portfolio_Default_Tier__c', null);
            sdq.put('Scenario_' + scenarioN + '_Available_Portfolio_Tiers__c', null);
            sdq.put('Scenario_' + scenarioN + '_PPA_Adder_Reduction__c', null);     //CPQ-819
        }

        //Get dynamic field values
        String finType = (string)sdq.get('Scenario_' + scenarioN + '_Financing_Type__c');
        String leaseFundID = (string)sdq.get('Scenario_' + scenarioN + '_Lease_Fund__c');
        double siteQuality = (double)sdq.get('Scenario_' + scenarioN + '_Site_Quality__c');
        sObject leaseFund = sdq.getSObject('Scenario_' + scenarioN + '_Lease_Fund__r');
        sObject termLoan = sdq.getSObject('Scenario_' + scenarioN + '_Term_Loan__r');
        sObject sacLoan = sdq.getSObject('Scenario_' + scenarioN + '_SAC_Loan__r');

        //Validation:
        if(finType == null || finType == '' || ( (finType == 'Lease' || finType == 'PPA' ) && leaseFundID == null)){ saveDetail('', true, scenarioN, 'Error: No Financing Option Selected'); isError = true;}
        if(siteQuality == null || siteQuality == 0){ saveDetail('', true, scenarioN, 'Error: Invalid Site Quality'); isError = true;}
        if (finType == 'Lease' && leaseFundID != null && (String)leaseFund.get('Name') == 'Kilowatt Systems, LLC (CPQ)' && sdq.get('Scenario_' + scenarioN + '_Lease_Option__c') == null){
            saveDetail('', true, scenarioN, 'Error: Please choose a Lease Option for Scenario ' + scenarioN);
            isError = true;
        }
        if (finType == 'Lease' && leaseFundID != null && (String)leaseFund.get('Name') == 'Kilowatt Systems, LLC (CPQ)' 
            && (String)sdq.get('Scenario_' + scenarioN + '_Lease_Option__c') == 'Low-Upfront - Monthly' && sdq.get('Scenario_' + scenarioN + '_Lease_Escalator__c') == null){
            saveDetail('', true, scenarioN, 'Error: Please choose a Lease Rate Escalator for Scenario ' + scenarioN);
            isError = true;
        }
        //CPQ-717 validation for Lease Fund records
        Date pricingDate = Date.newInstance(sdq.Pricing_Date__c.year(), sdq.Pricing_Date__c.month(), sdq.Pricing_Date__c.day());
        if (leaseFund != null && ((leaseFund.get('Fund_Open_Date__c') != null && (Date)leaseFund.get('Fund_Open_Date__c') > pricingDate) || 
                                    (leaseFund.get('Fund_Closed_Date__c') != null && (Date)leaseFund.get('Fund_Closed_Date__c') < pricingDate))){
            saveDetail('', true, scenarioN, 'Error: The Lease Fund has ' + 
                        (leaseFund.get('Fund_Open_Date__c') != null ? 'a start date of ' + Date.valueOf(leaseFund.get('Fund_Open_Date__c')).format() + ' and ' : '') + 
                        (leaseFund.get('Fund_Closed_Date__c') != null ? 'an end date of ' + Date.valueOf(leaseFund.get('Fund_Closed_Date__c')).format() + ' and ' : '') + 
                        'does not contain the SDQ pricing date of ' + pricingDate.format());
            isError = true;
        }
        if (termLoan != null && ((termLoan.get('Fund_Open_Date__c') != null && (Date)termLoan.get('Fund_Open_Date__c') > pricingDate) || 
                                    (termLoan.get('Fund_Closed_Date__c') != null && (Date)termLoan.get('Fund_Closed_Date__c') < pricingDate))){
            saveDetail('', true, scenarioN, 'Error: The Term Loan has ' + 
                        (termLoan.get('Fund_Open_Date__c') != null ? 'a start date of ' + Date.valueOf(termLoan.get('Fund_Open_Date__c')).format() + ' and ' : '') + 
                        (termLoan.get('Fund_Closed_Date__c') != null ? 'an end date of ' + Date.valueOf(termLoan.get('Fund_Closed_Date__c')).format() + ' and ' : '') + 
                        'does not contain the SDQ pricing date of ' + pricingDate.format());
            isError = true;
        }
        if (sacLoan != null && ((sacLoan.get('Fund_Open_Date__c') != null && (Date)sacLoan.get('Fund_Open_Date__c') > pricingDate) || 
                                    (sacLoan.get('Fund_Closed_Date__c') != null && (Date)sacLoan.get('Fund_Closed_Date__c') < pricingDate))){
            saveDetail('', true, scenarioN, 'Error: The SAC Loan has ' + 
                        (sacLoan.get('Fund_Open_Date__c') != null ? 'a start date of ' + Date.valueOf(sacLoan.get('Fund_Open_Date__c')).format() + ' and ' : '') + 
                        (sacLoan.get('Fund_Closed_Date__c') != null ? 'an end date of ' + Date.valueOf(sacLoan.get('Fund_Closed_Date__c')).format() + ' and ' : '') + 
                        'does not contain the SDQ pricing date of ' + pricingDate.format());
            isError = true;
        }

        if(isError) return;
        
        //Initialize the calculation variables
        double designPrice = 0;
        double leaseAdjustmentValue = 0;
                
        //Call item level calculation methods
        //CPQ-559 made it so system pricing tables are queried by SDQ.Pricing_Date__c
        double panelDesignPrice = getPanelDesignPrice(finType, leaseFundID, scenarioN);
        double nonPanelDesignPrice = getNonPanelDesignPrice(finType, leaseFundID, scenarioN);
        double trenchingTableValue = getTrenchingTableValue(scenarioN);
        
        //Get Lease and Utility adjustment values
        if((finType == 'Lease' || finType == 'PPA') && leaseFundID != null)
        {    
            leaseAdjustmentValue = getLeaseAdjustmentTableValue(leaseFundID, siteQuality, scenarioN);        
        }

        saveDetail('\n', false, scenarioN, '-----------------------------------');
        saveDetail('', false, scenarioN, 'Core Pricing Totals');
        saveDetail('', false, scenarioN, '-----------------------------------');
        saveDetail('', false, scenarioN, '$$ panelDesignPrice: ' + panelDesignPrice);
        saveDetail('', false, scenarioN, '$$ nonPanelDesignPrice: ' + nonPanelDesignPrice);
        saveDetail('', false, scenarioN, '$$ trenchingTableValue: ' + trenchingTableValue);
        saveDetail('', false, scenarioN, '$$ leaseAdjustmentValue: ' + leaseAdjustmentValue);
        
        saveDetail('', false, scenarioN, 'Sum All Values');
        //designPrice = panelDesignPrice + nonPanelDesignPrice + trenchingTableValue + leaseAdjustmentValueSiteQuality + leaseAdjustmentValueUtility + leaseAdjustmentValueTSRF;
        designPrice = panelDesignPrice + nonPanelDesignPrice + trenchingTableValue + leaseAdjustmentValue;
        saveDetail('', false, scenarioN, '$$$ designPrice: ' + designPrice);
        
        //Dynamically fill in the debugging field values based on which scenario this is
        if(!isError)
        {
            sdq.put('Scenario_' + scenarioN + '_Panel_Design_Price__c', panelDesignPrice);
            sdq.put('Scenario_' + scenarioN + '_Non_Panel_Design_Price__c', nonPanelDesignPrice);
            sdq.put('Scenario_' + scenarioN + '_Trenching_Table_Value_Total__c', trenchingTableValue);
            sdq.put('Scenario_' + scenarioN + '_Lease_Adjustment_Value__c', leaseAdjustmentValue);
        }

        //Multiply in the ratio for community baseline site quality / actual site quality if this is a lease.                
        saveDetail('', false, scenarioN, 'Check if this is a Lease and Comm Progam');
        if((finType == 'Lease' || finType == 'PPA') && commProg != null && commProgBaselineSQ != null){
            saveDetail('', false, scenarioN, 'This is a lease and there is a Community program, multiply in the ratio for community baseline site quality / actual site quality.');
            saveDetail('', false, scenarioN, 'Community baseline site quality: ' + commProgBaselineSQ);
            designPrice *= (commProgBaselineSQ / siteQuality);            
        }

        saveDetail('', false, scenarioN, '$$$$ Final designPrice: ' + designPrice);

        //Fill in the design price ***********
        if(!isError)
        {
            sdq.put('Scenario_' + scenarioN + '_Design_Price__c', designPrice);

            //Calculate the Upfront SREC amount
            setUpfrontSRECValue(scenarioN);

            //Calculate the price adjustments
            //This will return the same as what the formula field "Scenario N Adjusted Price" 
            //should return so that we can use it in the Incentives calculations
            setPriceAdjustmentValue(scenarioN);
            
            //Calculate Incentives, and pass the adjusted price as variable
            setIncentiveValue(scenarioN);

            Decimal channelPartnerLeaseRate = sdq.Channel_Partner_Lease_Rate_kWh__c;
            //Fixed Rate PPA support. CPQ-704.
            if (finType == 'PPA' && sdq.Community_Program_Offer__r.RecordType.DeveloperName == 'Door_to_Door' && sdq.get('Scenario_' + scenarioN + '_Lease_Option__c') == 'Fixed-Rate PPA' 
                && sdq.Total_System_Size_kW__c > 0 && (String)leaseFund.get('Finance_Pricing_Algorithm__c') != 'OneRoof'){
                
                    Decimal ppaRate = getFixedRatePPA(sdq.Total_System_Size_kW__c, nonPanelDesignPrice, trenchingTableValue, sdq.Community_Program_Offer__r.Ineligibility_Threshold__c, 
                                                        sdq.Community_Program_Offer__r.Size_Threshold__c, sdq.Community_Program_Offer__r.Size_Adder__c, sdq.Community_Program_Offer__r.High_PPA_Rate_Threshold__c, 
                                                        sdq.Community_Program_Offer__r.High_PPA_Rate_Adder__c, sdq.Community_Program_Offer__r.Base_PPA_Rate__c, scenarioN);
                    if (ppaRate != null){
                        channelPartnerLeaseRate = ppaRate;   //Run this value through Channel Partner Pricing in setFinancingProductPricing()
                        sdq.Channel_Partner__c = true;
                    }
            }

            //Calculate the finance product pricing like the Kilowatt pricing
            if (finType == 'Lease' || finType == 'PPA'  )
                setFinancingProductPricing(channelPartnerLeaseRate, scenarioN);

            //if(!SightenAPIIntegrator.IsSightenScenario(sdq.Id, scenarioN)){
                //Calculate pricing for Term Loan, like Hudson
                Decimal termLoanAmount = 0;
                if (finType == 'Purchase' && termLoan != null){
                    termLoanAmount = setTermLoanPricing(scenarioN, 0);
                    if ((String)termLoan.get('RecordTypeDeveloperName__c') == 'Term_Loan' && (Boolean)termLoan.get('Requires_SAC_Loan__c') == true && sdq.get('Scenario_' + scenarioN + '_SAC_Loan__c') == null)
                        saveDetail('', true, scenarioN, 'Term Loan in scenario ' + scenarioN + ' requires a SAC Loan.');    //CPQ-782
                }

                //if (finType == 'Purchase' && termLoan == null)
                //    sdq.put('Commission_Design_Price__c', designPrice);   //Commented out for CPQ-790
                //Fill in pricing dependant fields which we decided not to use formulas for so that this class can access these numbers without needing to DML the SDQ first.

                //SREC Buy Down (CPQ-675)
                if (finType == 'Purchase' && termLoan != null){
                    Decimal[] buyDownResults = srecBuyDown(scenarioN, termLoanAmount);
                    system.debug('**SZ: buydownresults = ' + buyDownResults);
                    if (buyDownResults != null){
                        Decimal savingsValidationAdjustment = buyDownResults[0];
                        Decimal termLoanReduction = buyDownResults[1];
                        saveDetail('', false, scenarioN, 'Term Loan Reduction (for SREC Buydown): ' + termLoanReduction.setScale(2));
                        Decimal upfrontSrecValue = sdq.get('Scenario_' + scenarioN + '_Upfront_SREC_Amount__c') != null ? (Decimal)sdq.get('Scenario_' + scenarioN + '_Upfront_SREC_Amount__c') : 0;
                        Decimal customerCashPayout = sdq.get('Scenario_' + scenarioN + '_SREC_Cash_Back__c') != null ? (Decimal)sdq.get('Scenario_' + scenarioN + '_SREC_Cash_Back__c') : 0;
                        Decimal remainingBuydown = Math.max(upfrontSrecValue - savingsValidationAdjustment - customerCashPayout, 0);
                        Decimal buydown = savingsValidationAdjustment + remainingBuydown;
                        termLoanAmount = setTermLoanPricing(scenarioN, buyDown);  //Recalculate
                    }
                }

                saveDetail('', false, scenarioN, '------- PRICING COMPLETE -------');
            //}
            //else
            //{
            //    saveDetail('', false, scenarioN, '------- PRICING COMPLETED SCENARIO IS SIGHTEN -------');
            //}
        }
        else
        {
            saveDetail('', false, scenarioN, '------- PRICING COMPLETED WITH ERRORS -------');
        }
        //CORE PRICING FOR THIS SCENARIO IS COMPLETE
        
    }  
           

    public double getPanelDesignPrice(String finType, String leaseFund, integer scenarioN)
    {
        saveDetail('\n', false, scenarioN, '-----------------------------------');
        saveDetail('', false, scenarioN, 'Get Panel Design Price');
        saveDetail('', false, scenarioN, '-----------------------------------');
        double panelDesignPrice = 0;
        
        saveDetail('', false, scenarioN, 'Number of unique Panel System Design Product IDs: ' + panelSdpIds.size());
        if(panelSdpIds.size() > 0)
        {
            string leaseFilter = '';
            if(finType == 'Lease' || finType == 'PPA'){
                leaseFilter = ' AND Lease_Fund__c = :leaseFund ';
                leaseFilter += getScenarioEscalatorFilter(scenarioN, 'Escalator__c');
            }

            Date pricingDate = Date.newInstance(sdq.Pricing_Date__c.year(), sdq.Pricing_Date__c.month(), sdq.Pricing_Date__c.day());
            //** Get the total panel count of ENTIRE SYSTEM, and the price for EACH TYPE OF PANEL at that qty.            
            string pricing_soql = 'Select Panel_Type__r.Description__c, Count_' + sdq.System_Design__r.Panel_Count__c + '_Root_Price__c '
                                      + ' From System_Pricing_Table__c Where Panel_Type__c IN :panelSdpIds '
                                      + ' AND Financing_Type__c = :finType '
                                      + leaseFilter
                                      + ' AND Pricing_Region__c = :pricingRegion  '
                                      + ' AND Community_Program_Offer__c = :commProg'
                                      + ' AND Community_Program_Tier__c = :commProgTier '
                                      + ' AND Start_Date__c <= :pricingDate AND (End_Date__c = null OR End_Date__c >= :pricingDate) ';
            
            System.debug('***' + pricing_soql); 
            
            //saveDetail('', false, scenarioN, 'Query the System Pricing Table: ' + pricing_soql);            
            List<System_Pricing_Table__c> pricingTable = Database.query(pricing_soql);
            saveDetail('', false, scenarioN, 'System Pricing Table, number of records: ' + pricingTable.size());
            if(pricingTable == null || pricingTable.size() == 0){
                String[] sdpDescriptions = new String[]{};
                for (System_Design_Product__c sdp : [SELECT Description__c FROM System_Design_Product__c WHERE ID IN :panelSdpIds]){
                    sdpDescriptions.add(sdp.Description__c);    //CPQ-612
                }
                saveDetail('', true, scenarioN, 'Error: Could not find matching System Pricing Table entries for the following System Design Products: ' + sdpDescriptions);
            }else{
                Map<Id,System_Pricing_Table__c> sdpPricingMap = new Map<Id,System_Pricing_Table__c>();
                for(System_Pricing_Table__c spt : pricingTable){
                    if(sdpPricingMap.containsKey(spt.Panel_Type__c)){
                        saveDetail('', true, scenarioN, 'Error: Found more than 1 matching System Pricing Table record for System Design Product: ' + spt.Panel_Type__r.Description__c);
                        saveDetail('', true, scenarioN, 'Error: First matching System Pricing Table record: ' + sdpPricingMap.get(spt.Panel_Type__c).id);
                        saveDetail('', true, scenarioN, 'Error: This extra matching System Pricing Table record: ' + spt.id);
                    }else{
                        sdpPricingMap.put(spt.Panel_Type__c,spt);
                    }
                }
                for(System_Design_Item__c sdi : panelItems){
                    saveDetail('\n', false, scenarioN, 'Calculating price for SDI: ' + sdi.id);
                    saveDetail('', false, scenarioN, 'SDI RecordType: ' + sdi.RecordType.DeveloperName);
                    saveDetail('', false, scenarioN, 'SDI Item QTY: ' + sdi.Quantity__c);                                                
                    saveDetail('', false, scenarioN, 'SDP Name: ' + sdi.System_Design_Product__r.Name);                        
                    saveDetail('', false, scenarioN, 'SDP RecordType: ' + sdi.System_Design_Product__r.RecordType.DeveloperName);
                    
                    //Get the matching price entry from the map
                    System_Pricing_Table__c systemPriceTable = sdpPricingMap.get(sdi.System_Design_Product__c);
                    if (systemPriceTable == null){
                        saveDetail('', true, scenarioN, 'Error: Could not find matching System Pricing Table entry for: ' + sdi.System_Design_Product__r.Description__c);
                    }else{                            
                        saveDetail('', false, scenarioN, 'System Pricing Table Matched ID: ' + systemPriceTable.id);
                        saveDetail('', false, scenarioN, 'SD Total Panel QTY: ' + sdq.System_Design__r.Panel_Count__c);
                        //Get the panel root price
                        double panelRootPrice = (double)systemPriceTable.get('Count_' + sdq.System_Design__r.Panel_Count__c + '_Root_Price__c');
                        saveDetail('', false, scenarioN, 'Qty Root Price for this panel type: ' + panelRootPrice);
                        
                        //Calculate the price of this SDI Panel
                        if (systemPriceTable.get('Count_' + sdq.System_Design__r.Panel_Count__c + '_Root_Price__c') != null){                
                            panelDesignPrice += (double)systemPriceTable.get('Count_' + sdq.System_Design__r.Panel_Count__c + '_Root_Price__c') * sdi.Quantity__c/sdq.System_Design__r.Panel_Count__c;
                            saveDetail('', false, scenarioN, 'panelDesignPrice: ' + panelDesignPrice);
                        } else {    //DK  10/07/15
                            saveDetail('', true, scenarioN, 'Error: Could not find a root price for this System Design of ' + sdq.System_Design__r.Panel_Count__c + ' panels.');
                        }
                    }                    
                }
            }    
        }

        return panelDesignPrice;
    }

    public void resetPricingFields(){
        sdq.Pricing_Error_Log__c = null;

        resetPricingFieldsN(1);
        resetPricingFieldsN(2);
        resetPricingFieldsN(3);
        resetPricingFieldsN(4);
    }

    public void resetPricingFieldsN(integer scenarioN){        

        //Reset error field for this scenario
        sdq.put('Scenario_' + scenarioN + '_Error_Log__c', null);
        sdq.put('Scenario_' + scenarioN + '_Detail_Log__c', null);

        //Reset values
        sdq.put('Scenario_' + scenarioN + '_Panel_Design_Price__c', null);
        sdq.put('Scenario_' + scenarioN + '_Non_Panel_Design_Price__c', null);
        sdq.put('Scenario_' + scenarioN + '_Trenching_Table_Value_Total__c', null);
        sdq.put('Scenario_' + scenarioN + '_Lease_Adjustment_Value__c', null);        
        sdq.put('Scenario_' + scenarioN + '_Design_Price__c', null);
        sdq.put('Scenario_' + scenarioN + '_Escalator_Adjustment__c', null);
        sdq.put('Scenario_' + scenarioN + '_Down_Payment_Adjustment__c', null);        
        sdq.put('Scenario_' + scenarioN + '_SAC_Incentives__c', null); 
        sdq.put('Scenario_' + scenarioN + '_Prepaid_Financing_Amount__c', null);
        sdq.put('Scenario_' + scenarioN + '_First_Month_Payment__c', null);

        sdq.put('Scenario_' + scenarioN + '_First_Month_Payment__c', null);
        
        //double vpOverride = sdq.get('Scenario_' + scenarioN + '_VP_Sales_Adjustments__c') != null ? (double)sdq.get('Scenario_' + scenarioN + '_VP_Sales_Adjustments__c') : 0 ;
       // double adjustedPrice = sdq.get('Scenario_' + scenarioN + '_Adjusted_Price_NUM__c') != null ? (double)sdq.get('Scenario_' + scenarioN + '_Adjusted_Price_NUM__c') : 0; 

        //sdq.put('Scenario_' + scenarioN + '_Adjusted_Price_NUM__c', adjustedPrice - vpOverride); // cpq-704
        //sdq.put('Scenario_' + scenarioN + '_VP_Sales_Adjustments__c', null); // cpq-704

        //sdq.put('Scenario_' + scenarioN + '_Proposal_Term_Months__c', null); 
        //Begin the log for this scenario
        saveDetail('', false, scenarioN, 'Cleared Pricing Output Fields');
    }


    public double getNonPanelDesignPrice(String finType, String leaseFund, integer scenarioN)
    {
        saveDetail('\n', false, scenarioN, '-----------------------------------');
        saveDetail('', false, scenarioN, 'Get Non Panel Design Price');
        saveDetail('', false, scenarioN, '-----------------------------------');
        double nonPanelDesignPrice = 0;

        saveDetail('', false, scenarioN, 'Number of unique Non Panel System Design Product IDs: ' + nonPanelSdpIds.size());
        if(nonPanelSdpIds.size() > 0)
        {   
            string leaseFilter = '';            
            if(finType == 'Lease' || finType == 'PPA'){
                leaseFilter = ' AND s.Lease_Fund__c = :leaseFund ';
            }

            Date pricingDate = Date.newInstance(sdq.Pricing_Date__c.year(), sdq.Pricing_Date__c.month(), sdq.Pricing_Date__c.day());
            string propRecordTypeName = sdq.System_Design__r.Property__r.RecordType.DeveloperName;
            string pricing_soql = 'Select s.System_Design_Product__c, s.Adder_ea__c, s.Adder_W__c, s.Size_Base__c, s.Adder_Per_Panel__c '
                                      + ' From SDP_Price_Entry__c s '
                                      + ' Where s.System_Design_Product__c In :nonPanelSdpIds '
                                      + ' AND s.Property_Record_Type__c =: propRecordTypeName '
                                      + ' AND s.Financing_Type__c = :finType '
                                      + leaseFilter
                                      + ' AND s.Minimum_Size_kW__c <= :systemSizeKW '
                                      + ' AND s.Maximum_Size_kW__c > :systemSizeKW '
                                      + ' AND s.Community_Program_Offer__c = :commProg ' //If there is a community program offer, then Trenching table value will included in this list.
                                      + ' AND s.Start_Date__c <= :pricingDate AND (s.End_Date__c = null OR s.End_Date__c >= :pricingDate) ';
            
            //saveDetail('', false, scenarioN, 'Query the SDP Price Entry table: ' + pricing_soql);
            saveDetail('', false, scenarioN, 'Query the SDP Price Entry table');
            System.debug('***' + pricing_soql);
            List<SDP_Price_Entry__c> priceEntryTable = Database.query(pricing_soql);
            
            if(priceEntryTable == null || priceEntryTable.size() == 0){
                saveDetail('', true, scenarioN, 'Error: Could not find matching SDP Price Entry for any of the Non-Panels in System Design.');
            }else{
                
                //create map of Price entries keyed on the product ID
                Map<Id,SDP_Price_Entry__c> sdpPriceEntryMap = new Map<Id,SDP_Price_Entry__c>();                
                for(SDP_Price_Entry__c spe : priceEntryTable){
                    if(sdpPriceEntryMap.containsKey(spe.System_Design_Product__c)){
                        saveDetail('', true, scenarioN, 'Error: Found more than 1 matching SDP Price Entry record for System Design Product: ' + spe.System_Design_Product__c);
                        saveDetail('', true, scenarioN, 'Error: First matching SDP Price Entry record: ' + sdpPriceEntryMap.get(spe.System_Design_Product__c).id);
                        saveDetail('', true, scenarioN, 'Error: This extra matching SDP Price Entry record: ' + spe.id);
                    }else{
                        sdpPriceEntryMap.put(spe.System_Design_Product__c,spe);
                    }
                    //sdpPriceEntryMap.put(spe.System_Design_Product__c,spe);                    
                }

                
                //Calculate and add price to full nonpanel price
                for(System_Design_Item__c sdi : nonPanelItems){
                    SDP_Price_Entry__c priceEntry = sdpPriceEntryMap.get(sdi.System_Design_Product__c);
                    saveDetail('\n', false, scenarioN, 'Calculating price for SDI: ' + sdi.id);
                    saveDetail('', false, scenarioN, 'SDI RecordType: ' + sdi.RecordType.DeveloperName);
                    saveDetail('', false, scenarioN, 'SDI Item QTY: ' + sdi.Quantity__c);                        
                    saveDetail('', false, scenarioN, 'SDP Name: ' + sdi.System_Design_Product__r.Name);
                    saveDetail('', false, scenarioN, 'SDP RecordType: ' + sdi.System_Design_Product__r.RecordType.DeveloperName);

                    if(priceEntry == null){
                        saveDetail('', true, scenarioN, 'Error: Could not find matching SDP Price Entry for: ' + sdi.System_Design_Product__r.Description__c);
                    }else{
                        saveDetail('', false, scenarioN, 'SDP Price Entry Matched ID: ' + priceEntry.id);

                        if(priceEntry.Adder_ea__c == null) priceEntry.Adder_ea__c = 0;
                        if(priceEntry.Adder_W__c == null) priceEntry.Adder_W__c = 0;
                        if(priceEntry.Adder_Per_Panel__c == null) priceEntry.Adder_Per_Panel__c = 0;
                        if(priceEntry.Size_Base__c == null) priceEntry.Size_Base__c = 0;                        

                        double itemPrice = 0;
                        if(sdi.RecordType.DeveloperName == 'Inverter' //ITEM RECORDTYPE
                                || sdi.RecordType.DeveloperName == 'Mounting' //ITEM RECORDTYPE                               
                                || sdi.System_Design_Product__r.RecordType.DeveloperName == 'Entitlement'){ //PRODUCT RECORDTYPE
                            
                            double perWatt = (double)priceEntry.Adder_W__c * sdi.System_Design_Array__r.Array_Size_kW__c * 1000;
                            double perEach = (double)priceEntry.Adder_ea__c * sdi.Quantity__c * (priceEntry.Size_Base__c > 0 ? systemSizeKW/priceEntry.Size_Base__c : 1);
                            double perPanel = (double)priceEntry.Adder_Per_Panel__c * sdi.System_Design_Array__r.Panel_Count__c;
                            itemPrice = perWatt + perEach + perPanel;

                            saveDetail('', false, scenarioN, '$ per Watt: ' + perWatt);
                            saveDetail('', false, scenarioN, '$ per Each: ' + perEach);
                            saveDetail('', false, scenarioN, '$ per Panel: ' + perPanel);                                                        

                        }

                        if(sdi.System_Design_Product__r.RecordType.DeveloperName == 'Special_Part' //PRODUCT RECORDTYPE
                               ){ //PRODUCT RECORDTYPE
                            
                            double perWatt = (double)priceEntry.Adder_W__c * systemSizeW;
                            double perEach = (double)priceEntry.Adder_ea__c * sdi.Quantity__c * (priceEntry.Size_Base__c > 0 ? systemSizeKW/priceEntry.Size_Base__c : 1);
                            double perPanel = (double)priceEntry.Adder_Per_Panel__c * totalPanels;
                            itemPrice = perWatt + perEach + perPanel;

                            saveDetail('', false, scenarioN, '$ per Watt: ' + perWatt);
                            saveDetail('', false, scenarioN, '$ per Each: ' + perEach);
                            saveDetail('', false, scenarioN, '$ per Panel: ' + perPanel);                                                        

                        }
                        
                        //Add itemPrice to total tally for all non-panels
                        saveDetail('', false, scenarioN, '$ Item Total: ' + itemPrice);
                        nonPanelDesignPrice += itemPrice;
                    }
                }
            }
        }
        return nonPanelDesignPrice;
    }

    
    private string getScenarioEscalatorFilter(integer scenarioN, string apiName){
        string escalatorFilter = '';
        decimal escalator = 0; 
        
        string e = (string)sdq.get('Scenario_' + scenarioN + '_Lease_Escalator__c');
        
        if(e == null || e == '') e = '0';        
        escalator = decimal.valueof(e).setScale(5);

        //If 0, then also check for null
        if(escalator == 0){
            escalatorFilter += ' AND (' + apiName + ' = Null OR ' + apiName + ' = 0) ';
        }else{
            //Convert the number to percent
            escalator = escalator / 100;
            escalatorFilter += ' AND ' + apiName + ' = ' + escalator + ' ';
        }
        saveDetail('', false, scenarioN, 'This scenario Escalator: ' + escalator);

        return escalatorFilter;
    }

    //MK - 2014-07-21 - Created methods for lease adj
    public double getLeaseAdjustmentTableValue(String leaseFund, double siteQuality, integer scenarioN)
    {   
        saveDetail('\n', false, scenarioN, '-----------------------------------');
        saveDetail('', false, scenarioN, 'Get Lease Adjustment Table Entry');
        saveDetail('', false, scenarioN, '-----------------------------------');
        double leaseAdjustmentValue = 0;        
        
        saveDetail('', false, scenarioN, 'Query the Lease Adjustment Table');
        saveDetail('', false, scenarioN, 'Scenario Site Quality: ' + siteQuality);
        saveDetail('', false, scenarioN, 'System Size (kW): ' + systemSizeKW);
        
        Date pricingDate = Date.newInstance(sdq.Pricing_Date__c.year(), sdq.Pricing_Date__c.month(), sdq.Pricing_Date__c.day());
        string pricing_soql = 'Select l.id, l.SQ_Threshold_2__c, l.SQ_Threshold_2_Adjustment__c '
                                + ', l.SQ_Threshold_1__c, l.SQ_Threshold_1_Adjustment__c '
                                + ', l.SQ_Adjustment_Type__c '
                                + ', l.Utility_Multiplier__c, l.Utility_Threshold__c, l.Utility_Adder__c '
                                + ', l.TSRF_Adjustment__c, l.TSRF_Adjustment_Threshold__c '
                                + ', l.TSRF_Lower_Bound__c, l.TSRF_Lower_Bound_Adjustment__c '
                                + ', l.Escalator_Adjustment__c, l.Down_Payment_Mutiplier__c '
                                + 'From Lease_Adjustment_Table__c l '
                                + 'Where l.Community_Program_Offer__c = :commProg '                                
                                + 'AND l.Lease_Fund__c = :leaseFund '
                                + getScenarioEscalatorFilter(scenarioN, 'Escalator_Value__c')                                
                                + 'AND l.state__c = :propState '
                                + 'AND l.Pricing_Region__c = :pricingRegion '
                                + 'AND l.Minimum_Size__c <= :systemSizeKW '
                                + 'AND l.Maximum_Size__c > :systemSizeKW '
                                + 'AND Start_Date__c <= :pricingDate AND (End_Date__c = null OR End_Date__c >= :pricingDate)';

        System.debug('***' + pricing_soql);
        
        List<Lease_Adjustment_Table__c> leaseAdjustmentTable = database.query(pricing_soql);

        if(leaseAdjustmentTable == null || leaseAdjustmentTable.isEmpty()){
            saveDetail('', false, scenarioN, 'Error: No Matching Lease Adjustment Table record.');
        }else{
            Lease_Adjustment_Table__c lat = leaseAdjustmentTable[0];
            
            //Error logging if there is more than 1 matching record.
            if(leaseAdjustmentTable.size() > 1){
                saveDetail('', true, scenarioN, 'Error: "Get Lease Adjustment Table Value Site Quality" - Found multiple Lease Adjustment Table Records, qty = ' + leaseAdjustmentTable.size() + '');
                for(Lease_Adjustment_Table__c l : leaseAdjustmentTable){
                    saveDetail('', false, scenarioN, '*Multiple* Matching Lease Adjustment Table record: ' + l.id);
                }
                saveDetail('', false, scenarioN, '*Choosing* the first Lease Adjustment Table record: ' + lat.id);
            }else{
                saveDetail('', false, scenarioN, 'Matching Lease Adjustment Table record: ' + lat.id);
            }


            //Calculate Site Quality Adjustment
            //========================================
            double leaseAdjustmentValueSiteQuality = 0;        
            saveDetail('\n', false, scenarioN, '------');
            saveDetail('', false, scenarioN, 'Calculate Site Quality Adjustment');
            saveDetail('', false, scenarioN, '------');
            saveDetail('', false, scenarioN, 'SQ Adjustment Type: ' + lat.SQ_Adjustment_Type__c);

            if(lat.SQ_Adjustment_Type__c != null){                
                lat.SQ_Threshold_1_Adjustment__c = (lat.SQ_Threshold_1_Adjustment__c == null ? 1 : lat.SQ_Threshold_1_Adjustment__c);
                lat.SQ_Threshold_2_Adjustment__c = (lat.SQ_Threshold_2_Adjustment__c == null ? 1 : lat.SQ_Threshold_2_Adjustment__c);
                saveDetail('', false, scenarioN, 'SQ Threshold 1: ' + lat.SQ_Threshold_1__c);
                saveDetail('', false, scenarioN, 'SQ Threshold 1 Adjustment: ' + lat.SQ_Threshold_1_Adjustment__c);

                if(lat.SQ_Threshold_1__c < siteQuality){

                    if(lat.SQ_Adjustment_Type__c == '1' && lat.SQ_Threshold_1__c != null){                
                                        
                        leaseAdjustmentValueSiteQuality = systemSizeW * (lat.SQ_Threshold_1_Adjustment__c * (siteQuality - lat.SQ_Threshold_1__c));
                    
                    }else if(lat.SQ_Adjustment_Type__c == '2'){
                        
                        saveDetail('', false, scenarioN, 'SQ Threshold 2 Adjustment: ' + lat.SQ_Threshold_2_Adjustment__c);
                        saveDetail('', false, scenarioN, 'SQ Threshold 2: ' + lat.SQ_Threshold_2__c);
                        leaseAdjustmentValueSiteQuality = systemSizeW 
                                            * (
                                                  (lat.SQ_Threshold_1__c != null ? (lat.SQ_Threshold_1_Adjustment__c * (siteQuality - lat.SQ_Threshold_1__c)) : 0)
                                                +  (lat.SQ_Threshold_2__c != null ? (lat.SQ_Threshold_2_Adjustment__c * (siteQuality - lat.SQ_Threshold_2__c)) : 0)
                                            );                

                    }else if(lat.SQ_Adjustment_Type__c == '3'){

                        if(lat.SQ_Threshold_2__c != null && siteQuality < lat.SQ_Threshold_2__c){
                            if(lat.SQ_Threshold_1__c != null){
                                leaseAdjustmentValueSiteQuality = systemSizeW * (lat.SQ_Threshold_1_Adjustment__c * (siteQuality - lat.SQ_Threshold_1__c));
                            }
                        }else{
                            saveDetail('', false, scenarioN, 'SQ Threshold 2 Adjustment: ' + lat.SQ_Threshold_2_Adjustment__c);
                            saveDetail('', false, scenarioN, 'SQ Threshold 2: ' + lat.SQ_Threshold_2__c);
                            leaseAdjustmentValueSiteQuality = systemSizeW
                                            * (
                                                  (lat.SQ_Threshold_1__c != null ? (lat.SQ_Threshold_1_Adjustment__c * (siteQuality - lat.SQ_Threshold_1__c)) : 0)
                                                +  (lat.SQ_Threshold_2__c != null ? (lat.SQ_Threshold_2_Adjustment__c * (siteQuality - lat.SQ_Threshold_2__c)) : 0)
                                            );
                        }
                    }
                }
            }
            saveDetail('', false, scenarioN, '$ Total: ' + leaseAdjustmentValueSiteQuality);


            //Calculate Utility Adjustment
            //========================================
            double leaseAdjustmentValueUtility = 0;        
            saveDetail('\n', false, scenarioN, '------');
            saveDetail('', false, scenarioN, 'Calculate Utility Adjustment');
            saveDetail('', false, scenarioN, '------');
            saveDetail('', false, scenarioN, 'Utiliy Threshold: ' + lat.Utility_Threshold__c);
            saveDetail('', false, scenarioN, 'Utiliy Multiplier: ' + lat.Utility_Multiplier__c);
            saveDetail('', false, scenarioN, 'Utiliy Adder: ' + lat.Utility_Adder__c);

            //Get the right Avoided Utility Rate from the system design based on the lease fund
            decimal avoidedUtilityRate = (decimal)sdq.get('Scenario_' + scenarioN + '_Avoided_Utility_Rate__c');
            saveDetail('', false, scenarioN, 'Scenario Avoided Utility Rate: ' + avoidedUtilityRate);

            //Calculate Utility
            lat.Utility_Multiplier__c = (lat.Utility_Multiplier__c == null ? 1 : lat.Utility_Multiplier__c);

            //Calculate Utility Multiplier
            if(avoidedUtilityRate != null && lat.Utility_Threshold__c != null){
                leaseAdjustmentValueUtility += systemSizeW * (lat.Utility_Multiplier__c*(avoidedUtilityRate - lat.Utility_Threshold__c));
            }

            //Calculate Utility Adder
            if(lat.Utility_Adder__c != null){
                leaseAdjustmentValueUtility += systemSizeW * lat.Utility_Adder__c;
            }
            saveDetail('', false, scenarioN, '$ Total: ' + leaseAdjustmentValueUtility);


            //Calculate TSRF Adjustment
            //========================================
            double leaseAdjustmentValueTSRF = 0;
            saveDetail('\n', false, scenarioN, '------');
            saveDetail('', false, scenarioN, 'Calculate TSRF Adjustment');
            saveDetail('', false, scenarioN, '------');
            saveDetail('', false, scenarioN, 'TSRF Adjustment Threshold: ' + (lat.TSRF_Adjustment_Threshold__c == null ? 0 : lat.TSRF_Adjustment_Threshold__c)/100);
            saveDetail('', false, scenarioN, 'TSRF Adjustment: ' + lat.TSRF_Adjustment__c);
            saveDetail('', false, scenarioN, 'TSRF Lower Bound Adjustment: ' + lat.TSRF_Lower_Bound_Adjustment__c);
            saveDetail('', false, scenarioN, 'TSRF Lower Bound: ' + (lat.TSRF_Lower_Bound__c == null ? 0 : lat.TSRF_Lower_Bound__c)/100);
            saveDetail('', false, scenarioN, 'System Design.Overall TSRF: ' + overallTSRF);

            double thresholdComponent = 0;
            if(lat.TSRF_Adjustment_Threshold__c != null){
                lat.TSRF_Adjustment__c = lat.TSRF_Adjustment__c == null ? 1 : lat.TSRF_Adjustment__c;
                saveDetail('', false, scenarioN, 'Calculate Threshold Component: systemSizeW * ((overallTSRF - TSRF_Adjustment_Threshold) * TSRF_Adjustment)');
                thresholdComponent = systemSizeW 
                                        * ((overallTSRF - (lat.TSRF_Adjustment_Threshold__c/100)) * lat.TSRF_Adjustment__c);
            }

            double lowerBoundComponent = 0;
            if(lat.TSRF_Lower_Bound__c != null && lat.TSRF_Lower_Bound_Adjustment__c != null){
                saveDetail('', false, scenarioN, 'Calculate Lower Bound Component: systemSizeW * (TSRF_Lower_Bound > overallTSRF ? TSRF_Lower_Bound_Adjustment : 0)');
                lowerBoundComponent = systemSizeW 
                                        * ((lat.TSRF_Lower_Bound__c/100) > overallTSRF ? lat.TSRF_Lower_Bound_Adjustment__c : 0);
            }
            
            saveDetail('', false, scenarioN, '$ Threshold Component: ' + thresholdComponent);
            saveDetail('', false, scenarioN, '$ Lower Bound Component: ' + lowerBoundComponent);
            leaseAdjustmentValueTSRF = thresholdComponent + lowerBoundComponent;
            saveDetail('', false, scenarioN, '$ Total: ' + leaseAdjustmentValueTSRF);


            //Calculate Escalator Adjustment
            //========================================
            double leaseAdjustmentValueEscalator = 0;
            saveDetail('\n', false, scenarioN, '------');
            saveDetail('', false, scenarioN, 'Calculate Escalator Adjustment');
            saveDetail('', false, scenarioN, '------');            
            saveDetail('', false, scenarioN,  'Escalator Adjustment: ' + lat.Escalator_Adjustment__c);

            if(lat.Escalator_Adjustment__c != null){                
                leaseAdjustmentValueEscalator = (lat.Escalator_Adjustment__c * systemSizeW);                                                     
            }
            
            saveDetail('', false, scenarioN, '$ Total: ' + leaseAdjustmentValueEscalator);


            //Calculate Down Payment Adjustment
            //========================================
            double leaseAdjustmentValueDownPayment = 0;
            saveDetail('\n', false, scenarioN, '------');
            saveDetail('', false, scenarioN, 'Calculate Down Payment Adjustment');
            saveDetail('', false, scenarioN, '------');             
            saveDetail('', false, scenarioN, 'Down Payment Multiplier: ' + lat.Down_Payment_Mutiplier__c);
            decimal downPayment = (decimal)sdq.get('Scenario_' + scenarioN + '_Down_Payment__c');
            saveDetail('', false, scenarioN, 'Scenario Down Payment: ' + downPayment);

            if(lat.Down_Payment_Mutiplier__c != null && downPayment != null){
                leaseAdjustmentValueDownPayment = (lat.Down_Payment_Mutiplier__c * downPayment);                                                    
            }            
            saveDetail('', false, scenarioN, '$ Total: ' + leaseAdjustmentValueDownPayment);


            //Total all of the different lease adjustments
            leaseAdjustmentValue = leaseAdjustmentValueSiteQuality + leaseAdjustmentValueUtility + leaseAdjustmentValueTSRF + leaseAdjustmentValueEscalator + leaseAdjustmentValueDownPayment;
            saveDetail('\n', false, scenarioN, '$ Total Lease Adjustments: ' + leaseAdjustmentValue);

        }
        
        return leaseAdjustmentValue;
    }

    
    //MK - 2014-03-21
    public double getTrenchingTableValue(integer scenarioN){
        saveDetail('\n', false, scenarioN, '-----------------------------------');
        saveDetail('', false, scenarioN, 'Get Trenching Table Value');
        saveDetail('', false, scenarioN, '-----------------------------------');
        
        double trenchingTablePrice = 0;        
        
        saveDetail('', false, scenarioN, 'Number of trenching items: ' + trenchingItems.size());
        Date pricingDate = Date.newInstance(sdq.Pricing_Date__c.year(), sdq.Pricing_Date__c.month(), sdq.Pricing_Date__c.day());

        for(System_Design_Item__c sdi : trenchingItems){
            saveDetail('', false, scenarioN, 'Calculating price for SDI: ' + sdi.id);
            saveDetail('', false, scenarioN, 'Trench Length: ' + sdi.System_Design_Array__r.Total_Trenching_Length_ft__c);
            saveDetail('', false, scenarioN, 'QTY: ' + sdi.Quantity__c);
            saveDetail('', false, scenarioN, 'Query the Trenching Table');
            //SOQL here within for loop is the best way.  It's the only way to get around SOQL'ing all 3,000+ table records and looping to find a match which would be slow.
            List<Trenching_Table__c> trenchingTable = [Select id, Adder__c, Adder_W__c, Adder_Ft__c
                                                         From Trenching_Table__c 
                                                        where Community_Program_Offer__c = :commProg
                                                          AND Wire_Type__c =: sdi.System_Design_Product__r.Wire_Type__c                                                          
                                                          AND Minimum_Trench_Length__c <: (sdi.System_Design_Array__r.Total_Trenching_Length_ft__c / sdi.Quantity__c) 
                                                          AND Maximum_Trench_Length__c >=: (sdi.System_Design_Array__r.Total_Trenching_Length_ft__c / sdi.Quantity__c)
                                                          AND Minimum_Size__c <: sdi.System_Design_Array__r.Array_Size_kW__c                                                              
                                                          AND Maximum_Size__c >=: sdi.System_Design_Array__r.Array_Size_kW__c
                                                          AND Start_Date__c <= :pricingDate 
                                                          AND (End_Date__c = null OR End_Date__c >= :pricingDate)
                                                        limit 1];
            
            if(trenchingTable == null || trenchingTable.isEmpty()){
                saveDetail('', true, scenarioN, 'Error: No Trenching Table Records found for any of the Trenching Items in System Design');
            }else{
                Trenching_Table__c trenchRec = trenchingTable[0];

                //Error logging if there is more than 1 matching record.
                if(trenchingTable.size() > 1){
                    saveDetail('', true, scenarioN, 'Error: "Get Trenching Table Value" - Found multiple Trenching Table Records for SDI: ' + sdi.id + '');
                    for(Trenching_Table__c t : trenchingTable){
                        saveDetail('', false, scenarioN, '*Multiple* Matching Trenching Table record: ' + t.id);
                    }
                    saveDetail('', false, scenarioN, '*Choosing* the first Trenching Table record: ' + trenchRec.id);
                }else{
                    saveDetail('', false, scenarioN, 'Matching Trenching Table record: ' + trenchRec.id);
                }                
                //Add the $ adder to the running trench total $
                if(commProg == null){
                    saveDetail('', false, scenarioN, 'No Community Program, use flat rate $ Adder: ' + trenchRec.Adder__c);
                    if(trenchRec.Adder__c == null) saveDetail('', true, scenarioN, 'Error: Non-Community Program Trenching table record is missing a $ Adder value.');
                    else trenchingTablePrice += trenchRec.Adder__c;
                }else{
                    //Check to see which of the adders is filled in
                    if(trenchRec.Adder_W__c != null){
                        saveDetail('', false, scenarioN, 'Use Adder ($/W): ' + trenchRec.Adder_W__c);
                        trenchingTablePrice += trenchRec.Adder_W__c * sdi.System_Design_Array__r.Array_Size_kW__c;
                    }
                    else if(trenchRec.Adder__c != null){
                        saveDetail('', false, scenarioN, 'Use Adder ($): ' + trenchRec.Adder_W__c);
                        trenchingTablePrice += trenchRec.Adder__c;
                    }
                    else if(trenchRec.Adder_Ft__c != null){//   6/1/2015 PB CPQ-161
                        saveDetail('', false, scenarioN, 'Use Adder (Ft): ' + trenchRec.Adder_Ft__c);
                        trenchingTablePrice += trenchRec.Adder_Ft__c * sdi.System_Design_Array__r.Total_Trenching_Length_ft__c;
                    }
                    else if(trenchRec.Adder__c == null && trenchRec.Adder_W__c == null && trenchRec.Adder_Ft__c == null){                    
                        saveDetail('', true, scenarioN, 'Error: The Adder ($) , the Adder ($/W) and the Adder (Ft) are *blank* for this trenching table record: ' + trenchRec.id);
                    }
                }
            }    
        }//End for        

        saveDetail('', false, scenarioN, '$ Total: ' + trenchingTablePrice);
        return trenchingTablePrice;
        
    }


    //MK - 2014-03-21
    public void setPriceAdjustmentValue(integer scenarioN){
        saveDetail('\n', false, scenarioN, '-----------------------------------');
        saveDetail('', false, scenarioN, 'Get Price Adjustment Value');
        saveDetail('', false, scenarioN, '-----------------------------------');
                
        double priceAdjustmentProgramTopLine = 0;
        double priceAdjustmentProgramNet = 0;
        
        double priceAdjustmentStandardTopLine = 0;
        double priceAdjustmentStandardNet = 0;

        double priceAdjustmentVPTopLine = 0;
        double priceAdjustmentVPNet = 0;

        double priceAdjustmentLineItemTopLine = 0;
        double priceAdjustmentLineItemNet = 0;

        double designPrice = (double)sdq.get('Scenario_' + scenarioN + '_Design_Price__c');
        
        saveDetail('', false, scenarioN, 'Number of Applied Price Adjustments across all scenarios: ' + sdq.Price_Adjustments__r.size());
        //Decimal eligiblePromotionsCashRebate = 0;

        for(Price_Adjustment__c p : sdq.Price_Adjustments__r){
            if(!p.Adjustment_Applied__c) continue;
            if(p.Applicable_Scenario__c == null || p.Applicable_Scenario__c != string.valueof(scenarioN)) continue; //Not a matching scenario adjustment

            //if ((p.Type__c == 'Standard' || p.Type__c == 'Program') && p.Effective_Dollar_Amount__c != null && p.Promotion__c != null && p.Promotion__r.Eligible_as_Cash_Back__c)
            //    eligiblePromotionsCashRebate += p.Effective_Dollar_Amount__c;

            saveDetail('\n', false, scenarioN, 'Price Adjustment matching this scenario: ' + p.id);
            saveDetail('', false, scenarioN, 'Price Adjustment.Type: ' + p.Type__c);
            saveDetail('', false, scenarioN, 'Price Adjustment.Record Type: ' + p.RecordType.DeveloperName);
            saveDetail('', false, scenarioN, 'Price Adjustment.Apply As Net Adjustment: ' + p.Apply_As_Net_Adjustment__c);
            double price = 0;

            //Calculate the price based on the Record Type (Amount, Rate per watt, percent of design price)
            if(p.RecordType.DeveloperName == 'Dollar_Amount'){
                saveDetail('', false, scenarioN, '$ Amount: ' + p.Amount__c);
                if(p.Amount__c != null) price = p.Amount__c;

            }else if(p.RecordType.DeveloperName == 'Percentage'){
                if(p.Percent__c == null) p.Percent__c = 0;
                saveDetail('', false, scenarioN, 'Adjustment Percent: ' + (p.Percent__c/100));
                saveDetail('', false, scenarioN, 'Design price: ' + designPrice);
                if(designPrice != null) price = (p.Percent__c/100) * designPrice;
            
            }else if(p.RecordType.DeveloperName == 'Rate'){ 
                saveDetail('', false, scenarioN, '$ Amount per Watt: ' + p.Amount_per_Watt__c);
                saveDetail('', false, scenarioN, 'System Size in watts: ' + systemSizeW);
                if(p.Amount_per_Watt__c != null) price = p.Amount_per_Watt__c * (systemSizeW);
            
            }else{
                saveDetail('', true, scenarioN, 'Error: Price Adjustment(' + p.id + ') has an invalid Record Type: ' + p.RecordType.DeveloperName);
            }

            //Store the effective dollar amount
            priceAdjustmentsToUpdateMap.put(p.id, new Price_Adjustment__c(id = p.id, Effective_Dollar_Amount__c = price));

            //Apply this price adjustment to the right category
            if(p.Type__c != null && p.Type__c == 'Program'){
                if(p.Apply_As_Net_Adjustment__c) priceAdjustmentProgramNet += price;
                else priceAdjustmentProgramTopLine += price;
            }else if(p.Type__c != null && p.Type__c == 'Standard'){
                if(p.Apply_As_Net_Adjustment__c) priceAdjustmentStandardNet += price;
                else priceAdjustmentStandardTopLine += price;
            }else if(p.Type__c != null && p.Type__c == 'VP Override'){
                if(p.Apply_As_Net_Adjustment__c) priceAdjustmentVPNet += price;
                else priceAdjustmentVPTopLine += price;
            }else if(p.Type__c != null && p.Type__c == 'Line Item'){
                if(p.Apply_As_Net_Adjustment__c) priceAdjustmentLineItemNet += price;
                else priceAdjustmentLineItemTopLine += price;
            }else{
                saveDetail('', true, scenarioN, 'Error: Price Adjustment(' + p.id + ') has an invalid Promotion Type: ' + p.Type__c);
                continue; //Next record in loop
            }
        }

        ////CPQ-543
        //sdq.put('Scenario_' + scenarioN + '_Eligible_Promo_Cash_Rebate__c', eligiblePromotionsCashRebate);
        //if (eligiblePromotionsCashRebate == 0)
        //    sdq.put('Scenario_' + scenarioN + '_Promotion_Cash_Rebate_Amount__c', 0);   //Clear this field so it doesn't trip a validation rule

        // SZ: Add code for Scenario_N_Commission_Impact_Promotions
        system.debug('Total Program Adjustments: ' + priceAdjustmentStandardTopLine);
        system.debug('Standard Net Adjustments: ' + priceAdjustmentStandardNet);
        system.debug('System Size W: ' + systemSizeW);
        Decimal commissionImpactPromotions = (-1 * (priceAdjustmentStandardTopLine + priceAdjustmentStandardNet)) / systemSizeW;
        //system.debug('Commission Impact Promotions: ' + commissionImpactPromotions);

        //Set individual adjustment fields
        sdq.put('Scenario_' + scenarioN + '_Total_Program_Adjustments__c', priceAdjustmentProgramTopLine);
        sdq.put('Scenario_' + scenarioN + '_Program_Net_Adjustment__c', priceAdjustmentProgramNet);
        saveDetail('\n', false, scenarioN, '$ Program Top Line Adjustments: ' + priceAdjustmentProgramTopLine);
        saveDetail('', false, scenarioN, '$ Program Net Adjustments: ' + priceAdjustmentProgramNet);
        
        sdq.put('Scenario_' + scenarioN + '_Total_Standard_Adjustments__c', priceAdjustmentStandardTopLine);
        sdq.put('Scenario_' + scenarioN + '_Standard_Net_Adjustment__c', priceAdjustmentStandardNet);
        if (sdq.get('Scenario_' + scenarioN + '_Lease_Option__c') != 'Portfolio PPA')
            sdq.put('Scenario_' + scenarioN + '_Commission_Impact_Promotions__c', commissionImpactPromotions);
        saveDetail('', false, scenarioN, '$ Standard Top Line Adjustments: ' + priceAdjustmentStandardTopLine);
        saveDetail('', false, scenarioN, '$ Standard Net Adjustments: ' + priceAdjustmentStandardNet);
        if (sdq.get('Scenario_' + scenarioN + '_Lease_Option__c') != 'Portfolio PPA')
            saveDetail('', false, scenarioN, '$/W commission Impact Promotions: ' + commissionImpactPromotions);

        sdq.put('Scenario_' + scenarioN + '_VP_Sales_Adjustments__c', priceAdjustmentVPTopLine);
        sdq.put('Scenario_' + scenarioN + '_VP_Override_Net_Adjustment__c', priceAdjustmentVPNet);
        saveDetail('', false, scenarioN, '$ VP Top Line Adjustments: ' + priceAdjustmentVPTopLine);
        saveDetail('', false, scenarioN, '$ VP Net Adjustments: ' + priceAdjustmentVPNet);

        sdq.put('Scenario_' + scenarioN + '_Line_Item_Top_Line_Adjustment__c', priceAdjustmentLineItemTopLine);
        sdq.put('Scenario_' + scenarioN + '_Line_Item_Net_Adjustment__c', priceAdjustmentLineItemNet);
        saveDetail('', false, scenarioN, '$ Line Item Top Line Adjustments: ' + priceAdjustmentLineItemTopLine);
        saveDetail('', false, scenarioN, '$ Line Item Net Adjustments: ' + priceAdjustmentLineItemNet);
        
        
        //Set the new price fields
        double adjustedPrice = (designPrice + priceAdjustmentVPTopLine + priceAdjustmentProgramTopLine + priceAdjustmentStandardTopLine + priceAdjustmentLineItemTopLine);
        sdq.put('Scenario_' + scenarioN + '_Adjusted_Price_NUM__c', adjustedPrice);
        saveDetail('\n', false, scenarioN, '$$ Adjusted Price: ' + adjustedPrice);

        Double srecAmount = (Double)sdq.get('Scenario_' + scenarioN + '_Upfront_SREC_Amount__c');
        Decimal cashPayoutLimit;
        String financingType = (String)sdq.get('Scenario_' + scenarioN + '_Financing_Type__c');
        //Check if SREC Buydown is in effect
        if (financingType == 'Purchase' && sdq.getSObject('Scenario_' + scenarioN + '_Term_Loan__r') != null){
            for (Available_SREC_Contract_Offer__c srec : sdq.Available_SREC_Contract_Offers__r){    //Check for the proper SREC Contract Offer type         
                if (srec.Applicable_Scenario__c == String.valueof(scenarioN) && srec.SREC_Contract_Offer__r.RecordType.DeveloperName == 'Upfront_Cash_Back' && srec.Contract_Offer_Applied__c){
                    cashPayoutLimit = srec.SREC_Contract_Offer__r.Cash_Payout_Limit__c != null ? srec.SREC_Contract_Offer__r.Cash_Payout_Limit__c : 0;
                    break;
                }
            }
            if (cashPayoutLimit != null)
                srecAmount = 0;  //Matching SREC Contract Offer was found
        }

        double finalEPCPrice = designPrice + priceAdjustmentVPTopLine + priceAdjustmentProgramTopLine + priceAdjustmentStandardTopLine + priceAdjustmentLineItemTopLine - srecAmount;
        //if ((financingType == 'Lease' || financingType == 'PPA') && sdq.get('Scenario_' + scenarioN + '_Promotion_Cash_Rebate_Amount__c') != null)
        //    finalEPCPrice = finalEPCPrice - (Decimal)sdq.get('Scenario_' + scenarioN + '_Promotion_Cash_Rebate_Amount__c');     //CPQ-543
        sdq.put('Scenario_' + scenarioN + '_Final_EPC_Price_NUM__c', finalEPCPrice);
        saveDetail('', false, scenarioN, '$$ Final EPC Price: ' + finalEPCPrice);

        return;
    }

    //MK - 2014-09-16
    //This method was created for the setKilowattValue method since it will add/remove vp top line adjustments.
    public double recalcVPOverrideTopLineAdjustment(integer scenarioN, list<Price_Adjustment__c> vpTopLinePriceAdjustmentsThisScenario){
        saveDetail('\n', false, scenarioN, '-----------------------------------');
        saveDetail('', false, scenarioN, 'Recalculate VP Override Top Line Adjustment');
        saveDetail('', false, scenarioN, '-----------------------------------');
                
        double priceAdjustmentVPTopLine = 0;
        
        double designPrice = (double)sdq.get('Scenario_' + scenarioN + '_Design_Price__c');
        
        saveDetail('', false, scenarioN, 'Number of Applied VP Override Top Line Price Adjustments across all scenarios: ' + vpTopLinePriceAdjustmentsThisScenario.size());

        for(Price_Adjustment__c p : vpTopLinePriceAdjustmentsThisScenario){
            if(!p.Adjustment_Applied__c) continue;

            if(p.Type__c != null && p.Type__c == 'VP Override' && !p.Apply_As_Net_Adjustment__c){

                saveDetail('\n', false, scenarioN, 'VP Override Top Line Adjustment matching this scenario: ' + p.id);                
                double price = 0;

                //Calculate the price based on the Record Type (Amount, Rate per watt, percent of design price)
                //**Using describe method instead to get recordtype name because the VP Override record might be new and thus
                //does not have a reference to the develpername through relationship. This saves us scenarion N# soql by not having to 
                //query to get the new price adjustment records
                string recordTypeName = priceAdjustmentRecordTypeIDMap.get(p.RecordTypeID).getName(); 
                if(recordTypeName == 'Dollar Amount'){
                    saveDetail('', false, scenarioN, '$ Amount: ' + p.Amount__c);
                    if(p.Amount__c != null) price = p.Amount__c;

                }else if(recordTypeName == 'Percentage'){
                    if(p.Percent__c == null) p.Percent__c = 0;
                    saveDetail('', false, scenarioN, 'Adjustment Percent: ' + (p.Percent__c/100));
                    saveDetail('', false, scenarioN, 'Design price: ' + designPrice);
                    if(designPrice != null) price = (p.Percent__c/100) * designPrice;
                
                }else if(recordTypeName == 'Rate'){ 
                    saveDetail('', false, scenarioN, '$ Amount per Watt: ' + p.Amount_per_Watt__c);
                    saveDetail('', false, scenarioN, 'System Size in watts: ' + systemSizeW);
                    if(p.Amount_per_Watt__c != null) price = p.Amount_per_Watt__c * (systemSizeW);
                
                }else{
                    saveDetail('', true, scenarioN, 'Error: Price Adjustment(' + p.id + ') has an invalid Record Type: ' + recordTypeName);
                }
                
                //Store the effective dollar amount
                priceAdjustmentsToUpdateMap.put(p.id, new Price_Adjustment__c(id = p.id, Effective_Dollar_Amount__c = price));

                priceAdjustmentVPTopLine += price;
            }

        }

        //Get individual adjustment fields, but not the vp top line
        double priceAdjustmentProgramTopLine = (double)sdq.get('Scenario_' + scenarioN + '_Total_Program_Adjustments__c');
        double priceAdjustmentProgramNet = (double)sdq.get('Scenario_' + scenarioN + '_Program_Net_Adjustment__c');
        double priceAdjustmentStandardTopLine = (double)sdq.get('Scenario_' + scenarioN + '_Total_Standard_Adjustments__c');
        double priceAdjustmentStandardNet = (double)sdq.get('Scenario_' + scenarioN + '_Standard_Net_Adjustment__c');
        double priceAdjustmentVPNet = (double)sdq.get('Scenario_' + scenarioN + '_VP_Override_Net_Adjustment__c');
        double priceAdjustmentLineItemTopLine = (double)sdq.get('Scenario_' + scenarioN + '_Line_Item_Top_Line_Adjustment__c');
        double priceAdjustmentLineItemNet = (double)sdq.get('Scenario_' + scenarioN + '_Line_Item_Net_Adjustment__c');                
        
        //Set the new price fields        
        sdq.put('Scenario_' + scenarioN + '_VP_Sales_Adjustments__c', priceAdjustmentVPTopLine);

        double adjustedPrice = (designPrice + priceAdjustmentVPTopLine + priceAdjustmentProgramTopLine + priceAdjustmentStandardTopLine + priceAdjustmentLineItemTopLine);
        sdq.put('Scenario_' + scenarioN + '_Adjusted_Price_NUM__c', adjustedPrice);
        saveDetail('\n', false, scenarioN, '$$ Adjusted Price: ' + adjustedPrice);

        double srecAmount = (double)sdq.get('Scenario_' + scenarioN + '_Upfront_SREC_Amount__c');

        //String financingType = (String)sdq.get('Scenario_' + scenarioN + '_Financing_Type__c');
        double finalEPCPrice = (designPrice + priceAdjustmentVPTopLine + priceAdjustmentProgramTopLine + priceAdjustmentStandardTopLine + priceAdjustmentLineItemTopLine - srecAmount);
        //if ((financingType == 'Lease' || financingType == 'PPA') && sdq.get('Scenario_' + scenarioN + '_Promotion_Cash_Rebate_Amount__c') != null)
        //    finalEPCPrice = finalEPCPrice - (Decimal)sdq.get('Scenario_' + scenarioN + '_Promotion_Cash_Rebate_Amount__c');     //CPQ-543
        sdq.put('Scenario_' + scenarioN + '_Final_EPC_Price_NUM__c', finalEPCPrice);
        saveDetail('', false, scenarioN, '$$ Final EPC Price: ' + finalEPCPrice);

        return adjustedPrice;
    }


    //MK - 2014-09-05
    public void setIncentiveValue(integer scenarioN){
        saveDetail('\n', false, scenarioN, '-----------------------------------');
        saveDetail('', false, scenarioN, 'Get Available Incentive Offer Values');
        saveDetail('', false, scenarioN, '-----------------------------------');
        
        saveDetail('', false, scenarioN, 'Number of Applied Available Incentive Offers across all scenarios: ' + sdq.Available_Incentive_Offers__r.size());

        //Initialize values
        decimal depreciationBasis = 0.000;
        double depreciationAmount = 0.00;
        double countyTaxCredit = 0.00;
        double federalTaxCredit = 0.00;
        double stateTaxCredit = 0.00;
        double utilityRebate = 0.00;
        double stateRebate = 0.00;
        double installerPaidIncentiveTotalAmount = 0.00;
        Double feedInTariffAnnualEarnings = null;   //CPQ-731

        //Pull values that are persisted as non-formula, ok to grab like this
        double epcPrice = (double)sdq.get('Scenario_' + scenarioN + '_Final_EPC_Price_NUM__c');
        double totalLeasePayments = (double)sdq.get('Scenario_' + scenarioN + '_Total_Lease_Payments__c');
        double downPayment = (double)sdq.get('Scenario_' + scenarioN + '_Down_Payment__c');
        decimal totalProjectedAnnualOutput = (decimal)sdq.get('Scenario_' + scenarioN + '_Total_Projected_Annual_Output__c');
        double adjustedPrice = (double)sdq.get('Scenario_' + scenarioN + '_Adjusted_Price_NUM__c');
        double siteQuality = (double)sdq.get('Scenario_' + scenarioN + '_Site_Quality__c');

        //Initialize to 0 to operate mathematics on them.
        sdq.Annual_Property_Tax_Bill__c = sdq.Annual_Property_Tax_Bill__c == null ? 0 : sdq.Annual_Property_Tax_Bill__c;
        decimal incomeCorpTaxRate = sdq.Income_Corporate_Tax_Rate__c == null ? 0 : sdq.Income_Corporate_Tax_Rate__c / 100;
        totalLeasePayments = totalLeasePayments == null ? 0 : totalLeasePayments;
        downPayment = downPayment == null ? 0 : downPayment;

        list<Available_Incentive_Offer__c> incentivesForStep2 = new list<Available_Incentive_Offer__c>();
        Decimal effectiveDollarSum = 0;
        Boolean step2 = false;
        //STEP 1:
        saveDetail('\n', false, scenarioN, '-- Step 1 calculations --');
        for(Available_Incentive_Offer__c incentive : sdq.Available_Incentive_Offers__r){
            if(incentive.Applicable_Scenario__c == null || incentive.Applicable_Scenario__c != string.valueof(scenarioN)) continue; //Not a matching scenario adjustment

            boolean applyEffectivePrice;
            if((incentive.Incentive_Applied__c == true || incentive.Applied_Manually__c == true) && incentive.Opted_Out_Manually__c == false){
                applyEffectivePrice = true;
            }else{
                applyEffectivePrice = false;
            }

            step2 = false;

            //Clear the effective dollar amount by filling up this set with 0 initially
            availableIncentiveOffersToUpdateMap.put(incentive.id, new Available_Incentive_Offer__c(id = incentive.id, Effective_Dollar_Amount__c = 0));

            saveDetail('\n', false, scenarioN, 'Available Incentive ID: ' + incentive.id);            
            saveDetail('', false, scenarioN, incentive.RecordType.DeveloperName + ' - ' + incentive.Implementing_Sector__c);
            //saveDetail('', false, scenarioN, 'Incentive Active: ' + incentive.Incentive_Active__c);
            saveDetail('', false, scenarioN, 'Flag: Incentive Applied Automatically: ' + incentive.Incentive_Applied__c);
            saveDetail('', false, scenarioN, 'Flag: Incentive Applied Manually: ' + incentive.Applied_Manually__c);
            saveDetail('', false, scenarioN, 'Flag: Incentive Opted Out Manually: ' + incentive.Opted_Out_Manually__c);
            saveDetail('', false, scenarioN, 'Flag Outcome, Apply the effective price?: ' + applyEffectivePrice);

            decimal taxCreditRate = incentive.Tax_Credit_Rate__c == null ? 0 : incentive.Tax_Credit_Rate__c / 100;
            double maxAllowedTaxCredit = incentive.Maximum_Allowable_Tax_Credit__c == null ? 0 : incentive.Maximum_Allowable_Tax_Credit__c;
            decimal maxProportionOfTotalCost = (incentive.Maximum_Proportion_of_Total_Cost__c == null || incentive.Maximum_Proportion_of_Total_Cost__c == 0) ? 1 : incentive.Maximum_Proportion_of_Total_Cost__c / 100;
            

            decimal properSystemSize = 0;
            decimal panelRatingkW = 0.00;
            decimal properPanelRating= 0.00;
            //set the system size value to the Incentive system size unit
            saveDetail('', false, scenarioN, 'Available Incentive Offer.System Size Units: ' + incentive.System_Size_Units__c);
            if(incentive.System_Size_Units__c != null){
                if(incentive.System_Size_Units__c == 'DC'){
                    properSystemSize = systemSizeKW;
                }else if(incentive.System_Size_Units__c == 'AC'){
                    properSystemSize = sdq.System_Design__r.Total_System_Size_AC_Rating_kW__c;
                }if(incentive.System_Size_Units__c == 'PTC'){
                    properSystemSize = sdq.System_Design__r.Total_System_Size_PTC_rating_kW__c;
                }
                panelRatingkW = (systemSizeKW) / sdq.Panel_Count__c;
                properPanelRating = (properSystemSize) / sdq.Panel_Count__c;
                saveDetail('', false, scenarioN, 'System Design Panel Rating (kW) Value: ' + panelRatingkW);
                if(panelRatingkW == null || panelRatingkW == 0){
                    saveDetail('', true, scenarioN, 'Error: Failure to calculate Incentive: ' + incentive.id + ' because the Panel Rating value for this system design is blank. This is the intended rating needed for this incentive: ' + incentive.System_Size_Units__c);
                }
            }

            //Calculate the incentive values based on the Record Type
            double thisIncentiveNonFederalAmount;
            
            //DEPRECIATION
            if(incentive.RecordType.DeveloperName == 'Depreciation'){
                //Postpone to step 2, need the total Installer paid incentive amount
                incentivesForStep2.add(incentive);   
                step2 = true;            
                saveDetail('', false, scenarioN, '*Calculate in step 2');

            //TAX CREDIT - FEDERAL
            }else if(incentive.RecordType.DeveloperName == 'Tax_Credit' && incentive.Implementing_Sector__c == 'Federal'){
                //Postpone to step 2, need the total Installer paid incentive amount
                incentivesForStep2.add(incentive);  
                step2 = true;                
                saveDetail('', false, scenarioN, '*Calculate in step 2');
            
            //TAX CREDIT - STATE
            }else if(incentive.RecordType.DeveloperName == 'Tax_Credit' && incentive.Implementing_Sector__c == 'State'){
                saveDetail('', false, scenarioN, '% Tax Credit Rate: ' + taxCreditRate);
                saveDetail('', false, scenarioN, 'Eligible Cost Basis: ' + incentive.Eligible_Cost_Basis__c);

                //If Eligible Cost Basis = ‘Total Lease Payments’
                if(incentive.Eligible_Cost_Basis__c == 'Total Lease Payments'){
                    saveDetail('', false, scenarioN, 'Total Lease Payments: ' + totalLeasePayments);
                    //Scenario N State Tax Credit Amount = min((Scenario N Total Lease Payments) * Tax Credit Rate, Maximum Allowable Tax Credit)
                    thisIncentiveNonFederalAmount = Math.min((totalLeasePayments * taxCreditRate), maxAllowedTaxCredit);
                    if(applyEffectivePrice) stateTaxCredit += thisIncentiveNonFederalAmount;
                    
                
                //If Eligible Cost Basis = ‘Net of State Rebate’
                }else if(incentive.Eligible_Cost_Basis__c == 'Net of State Rebate'){
                    //Postpone to STEP 2, need to get State Rebate amounts first
                    incentivesForStep2.add(incentive);       
                    step2 = true;                
                    saveDetail('', false, scenarioN, '*Calculate in step 2');
                
                //If Eligible Cost Basis = ‘Net of Federal Tax Credit’
                }else if(incentive.Eligible_Cost_Basis__c == 'Net of Federal Tax Credit'){
                    //Postpone to STEP 2, need to get Federal Tax Credit amounts first
                    incentivesForStep2.add(incentive); 
                    step2 = true;                      
                    saveDetail('', false, scenarioN, '*Calculate in step 2');
                }
            
            //TAX CREDIT - COUNTY
            }else if(incentive.RecordType.DeveloperName == 'Tax_Credit' && incentive.Implementing_Sector__c == 'County'){
                saveDetail('', false, scenarioN, 'Eligible Cost Basis: ' + incentive.Eligible_Cost_Basis__c);

                //If Eligible Cost Basis = ‘Total Lease Down Payment'
                if(incentive.Eligible_Cost_Basis__c == 'Total Lease Down Payment'){
                    //If Credit Capped by Annual Tax Obligation = 'TRUE'
                    if(incentive.Credit_Capped_by_Annual_Tax_Obligation__c){
                        //Scenario N County Tax Credit Amount = min(Scenario N Down Payment * Tax Credit Rate, Maximum Allowable Tax Credit, Annual Property Tax Bill)
                        thisIncentiveNonFederalAmount = Math.min(Math.min(downPayment * taxCreditRate, maxAllowedTaxCredit), sdq.Annual_Property_Tax_Bill__c);
                        if(applyEffectivePrice) countyTaxCredit += thisIncentiveNonFederalAmount;
                        
                    //If Credit Capped by Annual Tax Obligation = 'FALSE'
                    }else{
                        //Scenario N County Tax Credit Amount = min(Scenario N Down Payment * Tax Credit Rate, Maximum Allowable Tax Credit)
                        thisIncentiveNonFederalAmount = Math.min(downPayment * taxCreditRate, maxAllowedTaxCredit);
                        if(applyEffectivePrice) countyTaxCredit += thisIncentiveNonFederalAmount;
                        
                    }
                
                //If Eligible Cost Basis = ‘Total System Cost’
                }else if(incentive.Eligible_Cost_Basis__c == 'Total System Cost'){
                    //If Credit Capped by Annual Tax Obligation = 'TRUE'
                    if(incentive.Credit_Capped_by_Annual_Tax_Obligation__c){
                        //Scenario N County Tax Credit Amount = min(Scenario N Adjusted Price * Tax Credit Rate, Maximum Allowable Tax Credit, Annual Property Tax Bill)
                        thisIncentiveNonFederalAmount = Math.min(Math.min(adjustedPrice * taxCreditRate, maxAllowedTaxCredit), sdq.Annual_Property_Tax_Bill__c);
                        if(applyEffectivePrice) countyTaxCredit += thisIncentiveNonFederalAmount;
                        
                    //If Credit Capped by Annual Tax Obligation = 'FALSE'
                    }else{
                        //Scenario N County Tax Credit Amount = min(Scenario N Adjusted Price * Tax Credit Rate, Maximum Allowable Tax Credit)
                        thisIncentiveNonFederalAmount = Math.min(adjustedPrice * taxCreditRate, maxAllowedTaxCredit);
                        if(applyEffectivePrice) countyTaxCredit += thisIncentiveNonFederalAmount;
                    }
                
                //If Eligible Cost Basis = ‘Net of State Rebate’
                }else if(incentive.Eligible_Cost_Basis__c == 'Net of State Rebate'){
                    //Postpone to STEP 2, need to get State Rebate amounts first
                    incentivesForStep2.add(incentive);
                    step2 = true;   
                    saveDetail('', false, scenarioN, '*Calculate in step 2');
                
                
                //If Eligible Cost Basis = ‘None’
                }else if(incentive.Eligible_Cost_Basis__c == null || incentive.Eligible_Cost_Basis__c == 'None'){
                    //If Credit Capped by Annual Tax Obligation = 'TRUE'
                    if(incentive.Credit_Capped_by_Annual_Tax_Obligation__c){
                        //Scenario N County Tax Credit Amount = min(Maximum Allowable Tax Credit, Annual Property Tax Bill)                        
                        thisIncentiveNonFederalAmount = Math.min(maxAllowedTaxCredit, sdq.Annual_Property_Tax_Bill__c);
                        if(applyEffectivePrice) countyTaxCredit += thisIncentiveNonFederalAmount;                        
                    
                    //If Credit Capped by Annual Tax Obligation = 'FALSE'
                    }else{
                        //Scenario N County Tax Credit Amount = Maximum Allowable Tax Credit
                        thisIncentiveNonFederalAmount = maxAllowedTaxCredit;
                        if(applyEffectivePrice) countyTaxCredit += thisIncentiveNonFederalAmount;                        
                    }
                }
            
            //REBATE - STATE
            }else if(incentive.RecordType.DeveloperName == 'Rebate' && incentive.Implementing_Sector__c == 'State'){
            
                //Scenario N State Rebate Amount = min(Rebate Amount ($), Scenario N Adjusted Price * Maximum Proportion of Total Cost)
                saveDetail('', false, scenarioN, 'Flat Rebate Amount: ' + incentive.Flat_Rebate_Amount__c);
                saveDetail('', false, scenarioN, 'Adjusted Price * Maximum_Proportion_of_Total_Cost__c: ' + adjustedPrice * maxProportionOfTotalCost);
                thisIncentiveNonFederalAmount = Math.min(incentive.Flat_Rebate_Amount__c, adjustedPrice * maxProportionOfTotalCost);
                if(applyEffectivePrice) stateRebate += thisIncentiveNonFederalAmount;
            
            //REBATE $/W - STATE
            //REBATE $/W - UTILITY
            }else if(incentive.RecordType.DeveloperName == 'Rebate_W' && (incentive.Implementing_Sector__c == 'State' || incentive.Implementing_Sector__c == 'Utility')){
                
                //Variables for calculating
                
                saveDetail('', false, scenarioN, '-- Calculation Variables --');

                saveDetail('', false, scenarioN, 'incentive.Maximum_Eligible_Estimated_Consumption__c --'+incentive.Maximum_Eligible_Estimated_Consumption__c);
                saveDetail('', false, scenarioN, 'incentive.Eligible_Estimated_Consumption__c --'+incentive.Eligible_Estimated_Consumption__c);
                saveDetail('', false, scenarioN, 'incentive.Maximum_Proportion_of_Consumption__c --'+incentive.Maximum_Proportion_of_Consumption__c);
                saveDetail('', false, scenarioN, 'totalProjectedAnnualOutput-'+totalProjectedAnnualOutput);
                saveDetail('', false, scenarioN, 'properSystemSize-'+properSystemSize);
                
                
                //--s1-- = Tier 1 Maximum System Size
                decimal s1;
                //If Maximum Eligible Estimated Consumption is 'null', greater than, or equal to Total Projected Annual Output, then
                if(incentive.Maximum_Eligible_Estimated_Consumption__c == null 
                    || incentive.Maximum_Eligible_Estimated_Consumption__c >= totalProjectedAnnualOutput){
                    //S1 = min(Tier 1 Maximum System Size (kW), system size (kW))
                    decimal s1a = incentive.Tier_1_Maximum_System_Size_kW__c;
                    decimal s1b = properSystemSize;                    
                    saveDetail('', false, scenarioN, 's1 = min(' + s1a + ', ' + s1b + ')');
                    s1 = Math.min(s1a, s1b);
                //If Maximum Eligible Estimated Consumption is less than Total Projected Annual Output, then
                }else{
                    //If Size Panel Capped = 'TRUE'
                    if(incentive.Size_Panel_Capped__c){
                        //S1 = min(
                                //Tier 1 Maximum System Size (kW), 
                                //system size (kW), 
                                //rounddown(Maximum Eligible Estimated Consumption (kWh/year)/Scenario N Site Quality (kWh/kW/year)/panel rating (W)) * panel rating (W)
                            //)
                        decimal s1a = incentive.Tier_1_Maximum_System_Size_kW__c;
                        decimal s1b = properSystemSize;
                        decimal s1c = (incentive.Maximum_Eligible_Estimated_Consumption__c / siteQuality ) * (properPanelRating/panelRatingkW) ;
                        saveDetail('', false, scenarioN, 's1 = min(' + s1a + ', ' + s1b + ', ' + s1c + ')');
                        s1 = Math.min(
                                s1a,
                                Math.min(
                                    s1b, 
                                    s1c
                                )
                            );
                    //If Size Panel Capped <> 'TRUE'
                    }else{
                        //S1 = min(
                                //Tier 1 Maximum System Size (kW), 
                                //system size (kW), 
                                //Maximum Eligible Estimated Consumption (kWh/year)/Scenario N Site Quality (kWh/kW/year))
                        decimal s1a = incentive.Tier_1_Maximum_System_Size_kW__c;
                        decimal s1b = properSystemSize;
                        decimal s1c = incentive.Maximum_Eligible_Estimated_Consumption__c / siteQuality;
                        saveDetail('', false, scenarioN, 's1 = min(' + s1a + ', ' + s1b + ', ' + s1c + ')');
                        s1 = Math.min(
                                    incentive.Tier_1_Maximum_System_Size_kW__c, 
                                    Math.min(
                                        properSystemSize, 
                                        incentive.Maximum_Eligible_Estimated_Consumption__c / siteQuality
                                    )
                                );
                    }
                }
                saveDetail('', false, scenarioN, 's1: ' + s1);

                //--s2--
                decimal s2;
                //If Maximum Eligible Estimated Consumption is ‘null’, greater than, or equal to Total Projected Annual Output, then
                if(incentive.Maximum_Eligible_Estimated_Consumption__c == null 
                    || incentive.Maximum_Eligible_Estimated_Consumption__c >= totalProjectedAnnualOutput){
                    //If Size Panel Capped = ‘TRUE’
                    if(incentive.Size_Panel_Capped__c){
                        //s2 = min(rounddown(Tier 2 Maximum System Size/panel rating) * panel rating, system size)
                        decimal s2a = incentive.Tier_2_Maximum_System_Size_kW__c ;
                        decimal s2b = properSystemSize;                        
                        saveDetail('', false, scenarioN, 's2 = min(' + s2a + ', ' + s2b + ')');
                        s2 = Math.min(s2a, s2b);
                    
                    //If Size Panel Capped <> ‘TRUE’
                    }else{
                        //s2 = min(Tier 2 Maximum System Size, system size)
                        decimal s2a = incentive.Tier_2_Maximum_System_Size_kW__c;
                        decimal s2b = properSystemSize;                        
                        saveDetail('', false, scenarioN, 's2 = min(' + s2a + ', ' + s2b + ')');
                        s2 = Math.min(s2a, s2b);
                    }
                
                //If Maximum Eligible Estimated Consumption is less than Total Projected Annual Output, then
                }else{
                    //If Size Panel Capped = ‘TRUE’
                    if(incentive.Size_Panel_Capped__c){
                        //S2 = min(
                                //rounddown(Tier 2 Maximum System Size (kW)/panel rating (W)) * panel rating (W), 
                                //rounddown(Maximum Eligible Estimated Consumption (kWh/year)/(Scenario N Site Quality (kWh/kW/year)/panel rating (W))) * panel rating (W), 
                                //system size (kW)
                            //)
                        decimal s2a = incentive.Tier_2_Maximum_System_Size_kW__c;
                        decimal s2b = properSystemSize;                        
                        decimal s2c = (incentive.Maximum_Eligible_Estimated_Consumption__c / siteQuality ) * (properPanelRating/panelRatingkW) ;

                        if(s2c > incentive.Tier_1_Maximum_System_Size_kW__c)
                        {
                            saveDetail('', false, scenarioN, 's2 = min(' + s2a + ', ' + s2b + ', ' + s2c + ')');
                            s2 = Math.min(
                                    s2a,
                                    Math.min(
                                            s2b,
                                            s2c
                                    )
                                   );
                        }
                        else
                        {
                            saveDetail('', false, scenarioN, 's2 = min(' + s2a + ', ' + s2b  + ')');
                            s2 = Math.min(
                                    s2a,s2b
                                   );    
                        }        
                    //If Size Panel Capped <> ‘TRUE’
                    }else{
                        //S2 = min(
                                //rounddown(Tier 2 Maximum System Size (kW), 
                                //Maximum Eligible Estimated Consumption (kWh/year)/Scenario N Site Quality (kWh/kW/year), 
                                //system size (kW)
                            //)
                        decimal s2a = Math.floor(incentive.Tier_2_Maximum_System_Size_kW__c);
                        decimal s2b = properSystemSize;
                        decimal s2c = (incentive.Maximum_Eligible_Estimated_Consumption__c / siteQuality) * (properPanelRating/panelRatingkW);

                        if(s2c > incentive.Tier_1_Maximum_System_Size_kW__c)
                        {
                            saveDetail('', false, scenarioN, 's2 = min(' + s2a + ', ' + s2b + ', ' + s2c + ')');
                            s2 = Math.min(
                                    s2a,
                                    Math.min(
                                            s2b,
                                            s2c
                                    )
                                );
                        }
                        else
                        {
                            saveDetail('', false, scenarioN, 's2 = min(' + s2a + ', ' + s2b  + ')');
                            s2 = Math.min(
                                    s2a,s2b
                                   );     
                        }
                    }

                }
                saveDetail('', false, scenarioN, 's2: ' + s2);
                
                
                //--i2--
                decimal i2;
                //If Tier 1 Maximum System Size is ‘null’, greater than, or equal to s2
                if(incentive.Tier_1_Maximum_System_Size_kW__c == null 
                        || incentive.Tier_1_Maximum_System_Size_kW__c >= s2){
                    if(incentive.Maximum_Eligible_Estimated_Consumption__c != null && s2 < (incentive.Maximum_Eligible_Estimated_Consumption__c / siteQuality) ) 
                    {
                        i2 = 0;
                    }
                    else
                    {
                         i2 = (incentive.Tier_2_Incentive_Rate_W__c == null ? 0 : incentive.Tier_2_Incentive_Rate_W__c);   
                    }
                   // i2 = 0;
                
                //If Tier 1 Maximum System Size is less than ES
                }else{
                    //i2 = Tier 2 Incentive Rate ($/W)
                    i2 = (incentive.Tier_2_Incentive_Rate_W__c == null ? 0 : incentive.Tier_2_Incentive_Rate_W__c);
                }
                saveDetail('', false, scenarioN, 'i2: ' + i2);
                
                //--i1-- = Tier 1 Incentive Rate ($/W)
                decimal i1 = (incentive.Tier_1_Incentive_Rate_W__c == null ? 0 : incentive.Tier_1_Incentive_Rate_W__c);
                saveDetail('', false, scenarioN, 'i1: ' + i1);

                //--di-- = Natural disaster Adder ($/W)
                decimal di;
                if(sdq.Natural_Disaster_Adder_Eligible__c) di = incentive.Natural_Disaster_Adder_W__c;
                else di = 0;
                saveDetail('', false, scenarioN, 'di: ' + di);

                //--ds-- =  min(System Size, Natural Disaster Cap (kW))
                decimal ds = Math.min(incentive.Natural_Disaster_Cap_kW__c, systemSizeKW);
                saveDetail('', false, scenarioN, 'ds: ' + ds);

                //--mi-- = Mod Home Value/Mod Income Adder ($/W)
                decimal mi;
                if(sdq.Moderate_Home_Value_Adder_Eligible__c || sdq.Moderate_Income_Value_Adder_Eligible__c) mi = incentive.Mod_Home_Value_Mod_Income_Adder_W__c;
                else mi = 0;
                saveDetail('', false, scenarioN, 'mi: ' + mi);

                //--ms-- = min(System Size, Mod Home Value/Mod Income Cap (kW))
                decimal ms = Math.min(incentive.Mod_Home_Value_Mod_Income_Cap_kW__c, systemSizeKW);
                saveDetail('', false, scenarioN, 'ms: ' + ms);

                //--t--
                decimal t;
                if(incentive.Minimum_Standard_TSRF__c == null || incentive.Minimum_Standard_TSRF__c <= sdq.Suneye_TSRF__c) t = 1;
                else t = sdq.Suneye_TSRF__c / 100;
                saveDetail('', false, scenarioN, 't: ' + t);

                //--ci--
                decimal ci = Incentive.American_Made_Adder_W__c;
                saveDetail('', false, scenarioN, 'ci: ' + ci);

                //--cs-- min(System Size, American Made Cap (kW))
                decimal cs = Math.min(systemSizeKW, Incentive.American_Made_Cap_kW__c);
                saveDetail('', false, scenarioN, 'cs: ' + cs);

                //CALCULATION

                //Comparing of values in kw is done, convert any kw into w
                //s2 = s2 * 1000;
                //s1 = s1 * 1000;
                //ds = ds * 1000;
                //ms = ms * 1000;
                //cs = cs * 1000;


                //Scenario N State Rebate Amount & Scenario N Utility Rebate Amount 
                // = [{if (S2 < S1, 0, (S2 – S1)) * 1000 * I2 + (S1 * 1000 * I1)} + (DI * 1000 * DS) + (MI * 1000 * MS) * (CI * 1000 * CS)] * t
                
                decimal w = ((S2 < S1 ? 0 : (S2 - S1)) * 1000 * I2 + (S1 * 1000 * I1));
                decimal x = (DI * 1000 * DS);
                decimal y = (MI * 1000 * MS);
                decimal z = (CI * 1000 * CS);
                saveDetail('', false, scenarioN, '[w] = ((S2 < S1 ? 0 : (S2 - S1)) * 1000 * I2 + (S1 * 1000 * I1)) = ' + w);
                saveDetail('', false, scenarioN, '[x] = (DI * 1000 * DS) = ' + x);
                saveDetail('', false, scenarioN, '[y] = (MI * 1000 * MS) = ' + y);
                saveDetail('', false, scenarioN, '[z] = (CI * 1000 * CS) = ' + z);
                saveDetail('', false, scenarioN, '[t] = ' + t);

                thisIncentiveNonFederalAmount = ( w + x + y + z ) * t;

                saveDetail('', false, scenarioN, '[Total] = ( w + x + y + z ) * t = ' + thisIncentiveNonFederalAmount);

                //We've got the rebate amount, store it in the proper field.
                if(applyEffectivePrice){
                    if(incentive.Implementing_Sector__c == 'State') stateRebate += thisIncentiveNonFederalAmount;
                    else if(incentive.Implementing_Sector__c == 'Utility') utilityRebate += thisIncentiveNonFederalAmount;
                }

             //FEED IN TARIFF - UTILITY
            } else if (incentive.RecordType.DeveloperName == 'Feed_In_Tariff' && incentive.Implementing_Sector__c == 'Utility'){
                incentivesForStep2.add(incentive);  
                step2 = true;
                saveDetail('', false, scenarioN, '*Calculate in step 2');

            //ELSE DEFAULT
            }else{
                saveDetail('', true, scenarioN, 'Error: Available Incentive Offer(' + incentive.id + ') has an undefined type/sector combination: ' + incentive.RecordType.DeveloperName + ' - Implementing Sector: ' + incentive.Implementing_Sector__c);
            }
            
            //Logging the total for non federal
            if(Incentive.Implementing_Sector__c != 'Federal' && incentive.RecordType.DeveloperName != 'Depreciation'){                
                saveDetail('', false, scenarioN, '-- $ Total: ' + thisIncentiveNonFederalAmount);
                //Store the effective dollar amount
                availableIncentiveOffersToUpdateMap.put(incentive.id, new Available_Incentive_Offer__c(id = incentive.id, Effective_Dollar_Amount__c = thisIncentiveNonFederalAmount));
               
            }

            //Now that we have calculated the proper value for this incentive and placed the value into the proper field, 
            //check to see if this also needs to be stored as an Installer Paid Incentive.
            if(incentive.Implementing_Sector__c != 'Federal' && incentive.Incentive_Recipient__c != null && incentive.Incentive_Recipient__c == 'Installer'){
                if(thisIncentiveNonFederalAmount != null && applyEffectivePrice) installerPaidIncentiveTotalAmount += thisIncentiveNonFederalAmount;                
            }

            if (applyEffectivePrice && incentive.SAC_Eligible__c && String.isNotBlank((string)sdq.get('Scenario' + '_' + scenarioN + '_SAC_Loan__c')) && !step2 )
                effectiveDollarSum += availableIncentiveOffersToUpdateMap.get(incentive.id).Effective_Dollar_Amount__c;
        }


        //STEP 2:        
        saveDetail('\n', false, scenarioN, '-- Step 2 calculations --');
        
        Boolean foundFIT = false;
        //This is after the rebates and other step 1 calculations are done. Then we need to calculate credits that are based on the net amounts.
        for(Available_Incentive_Offer__c incentive : incentivesForStep2){

            boolean applyEffectivePrice;
            if ((incentive.Incentive_Applied__c == true || incentive.Applied_Manually__c == true) && incentive.Opted_Out_Manually__c == false){
                applyEffectivePrice = true;
            } else {
                applyEffectivePrice = false;
            }

            saveDetail('\n', false, scenarioN, 'Available Incentive ID: ' + incentive.id);
            saveDetail('', false, scenarioN, incentive.RecordType.DeveloperName + ' - ' + incentive.Implementing_Sector__c);
            //saveDetail('', false, scenarioN, 'Incentive Active: ' + incentive.Incentive_Active__c);
            saveDetail('', false, scenarioN, 'Flag: Incentive Applied Automatically: ' + incentive.Incentive_Applied__c);
            saveDetail('', false, scenarioN, 'Flag: Incentive Applied Manually: ' + incentive.Applied_Manually__c);
            saveDetail('', false, scenarioN, 'Flag: Incentive Opted Out Manually: ' + incentive.Opted_Out_Manually__c);
            saveDetail('', false, scenarioN, 'Flag Outcome, Apply the effective price?: ' + applyEffectivePrice);

            double maxAllowedTaxCredit = incentive.Maximum_Allowable_Tax_Credit__c == null ? 0 : incentive.Maximum_Allowable_Tax_Credit__c;
            decimal taxCreditRate = incentive.Tax_Credit_Rate__c == null ? 0 : incentive.Tax_Credit_Rate__c / 100;
            //DEPRECIATION
            if(incentive.RecordType.DeveloperName == 'Depreciation'){
                //Scenario N Depreciation Basis = (Scenario N Final/EPC Price - Scenario N Paid Installer Incentive Amt) * Depreciation Basis Rate
                
                //Calculate the basis
                decimal deprectiationRate = incentive.Depreciation_Basis_Rate__c / 100;
                saveDetail('', false, scenarioN, '$ EPC Price: ' + epcPrice);                
                saveDetail('', false, scenarioN, '$ Installer Paid Incentive Amount: ' + installerPaidIncentiveTotalAmount);                
                saveDetail('', false, scenarioN, '% Depreciation Basis Rate: ' + deprectiationRate);                
                decimal basisVal = (epcPrice  - installerPaidIncentiveTotalAmount) * deprectiationRate;
                saveDetail('', false, scenarioN, '-- % Depreciation Basis: ' + basisVal);
                
                //Calculate the amount
                saveDetail('', false, scenarioN, '% Income/Corporate Tax Rate: ' + incomeCorpTaxRate);
                double amountVal = basisVal * incomeCorpTaxRate;
                saveDetail('', false, scenarioN, '-- $ Depreciation Amount: ' + amountVal);

                //Sum across all incentives
                if(applyEffectivePrice){
                    depreciationBasis += basisVal;
                    depreciationAmount += amountVal;
                }
                
                //Store the effective dollar amount
                availableIncentiveOffersToUpdateMap.put(incentive.id, new Available_Incentive_Offer__c(id = incentive.id, Effective_Dollar_Amount__c = amountVal));                
            
            //TAX CREDIT - FEDERAL
            }else if(incentive.RecordType.DeveloperName == 'Tax_Credit' && incentive.Implementing_Sector__c == 'Federal'){
                saveDetail('', false, scenarioN, '% Tax Credit Rate: ' + taxCreditRate);

                //If Incentive Recipient <> 'Installer' for all Available Incentives
                    //Scenario N Federal Tax Credit Amount = Scenario N Adjusted Price * Tax Credit Rate                    
                //If Incentive Recipient = 'Installer' for any Available Incentives                
                    //Scenario N Federal Tax Credit Amount = (Scenario N Adjusted Price – sum(Incentive Amount where Recipient = 'Installer') * Tax Credit Rate
                
                //installerPaidIncentiveTotalAmount is only populated when Incentive Recipient = 'Installer', otherwise it's 0
                decimal val = (adjustedPrice - installerPaidIncentiveTotalAmount) * taxCreditRate;
                if(applyEffectivePrice) federalTaxCredit += val;
                saveDetail('', false, scenarioN, '-- $ Total: ' + val);

                //Store the effective dollar amount
                availableIncentiveOffersToUpdateMap.put(incentive.id, new Available_Incentive_Offer__c(id = incentive.id, Effective_Dollar_Amount__c = val));
                            
            //TAX CREDIT - STATE
            }else if(incentive.RecordType.DeveloperName == 'Tax_Credit' && incentive.Implementing_Sector__c == 'State'){
                saveDetail('', false, scenarioN, '% Tax Credit Rate: ' + taxCreditRate);
                saveDetail('', false, scenarioN, 'Eligible Cost Basis: ' + incentive.Eligible_Cost_Basis__c);

                //If Eligible Cost Basis = ‘Net of State Rebate’
                if(incentive.Eligible_Cost_Basis__c == 'Net of State Rebate'){
                    //Scenario N State Tax Credit Amount = min((Scenario N Adjusted Price – Scenario N State Rebate Amount) * Tax Credit Rate, Maximum Allowable Tax Credit)    
                    decimal val = Math.min((adjustedPrice - stateRebate) * taxCreditRate, maxAllowedTaxCredit);
                    if(applyEffectivePrice) stateTaxCredit += val;
                    saveDetail('', false, scenarioN, '-- $ Total: ' + val);
                    //Store the effective dollar amount
                    availableIncentiveOffersToUpdateMap.put(incentive.id, new Available_Incentive_Offer__c(id = incentive.id, Effective_Dollar_Amount__c = val));

                //Eligible Cost Basis = ‘Net of Federal Tax Credit’
                }else if(incentive.Eligible_Cost_Basis__c == 'Net of Federal Tax Credit'){
                    //Scenario N State Tax Credit Amount = min(( Scenario N Adjusted Price – Scenario N Federal Tax Credit Amount) * Tax Credit Rate, Maximum Allowable Tax Credit)
                    decimal val = Math.min((adjustedPrice - federalTaxCredit) * taxCreditRate, maxAllowedTaxCredit);
                    if(applyEffectivePrice) stateTaxCredit += val;
                    saveDetail('', false, scenarioN, '-- $ Total: ' + val);
                    //Store the effective dollar amount
                    availableIncentiveOffersToUpdateMap.put(incentive.id, new Available_Incentive_Offer__c(id = incentive.id, Effective_Dollar_Amount__c = val));

                //ELSE DEFAULT
                }else{
                    saveDetail('', true, scenarioN, 'Error: Available Incentive Offer(' + incentive.id + ') has an undefined STEP 2 State Tax Credit "Eligible Cost Basis" - ' + incentive.Eligible_Cost_Basis__c);
                }

            //TAX CREDIT - COUNTY
            }else if(incentive.RecordType.DeveloperName == 'Tax_Credit' && incentive.Implementing_Sector__c == 'County'){
                saveDetail('', false, scenarioN, 'Eligible Cost Basis: ' + incentive.Eligible_Cost_Basis__c);

                //If Eligible Cost Basis = ‘Net of State Rebate’
                if(incentive.Eligible_Cost_Basis__c == 'Net of State Rebate'){                    
                    //If Credit Capped by Annual Tax Obligation = 'TRUE'
                    if(incentive.Credit_Capped_by_Annual_Tax_Obligation__c){
                        //Scenario N County Tax Credit Amount = min((Scenario N Adjusted Price – Scenario N State Rebate Amount) * Tax Credit Rate, Maximum Allowable Tax Credit, Annual Property Tax Bill)
                        decimal val = Math.min(Math.min((adjustedPrice - stateRebate) * taxCreditRate, maxAllowedTaxCredit), sdq.Annual_Property_Tax_Bill__c);
                        if(applyEffectivePrice) countyTaxCredit += val;
                        saveDetail('', false, scenarioN, '-- $ Total: ' + val);
                        //Store the effective dollar amount
                        availableIncentiveOffersToUpdateMap.put(incentive.id, new Available_Incentive_Offer__c(id = incentive.id, Effective_Dollar_Amount__c = val));
                    
                    //If Credit Capped by Annual Tax Obligation = 'FALSE'
                    }else{
                        //Scenario N County Tax Credit Amount = min((Scenario N Adjusted Price – Scenario N State Rebate Amount) * Tax Credit Rate, Maximum Allowable Tax Credit)
                        decimal val = Math.min((adjustedPrice - stateRebate) * taxCreditRate, maxAllowedTaxCredit);
                        if(applyEffectivePrice) countyTaxCredit += val;
                        saveDetail('', false, scenarioN, '-- $ Total: ' + val);
                        //Store the effective dollar amount
                        availableIncentiveOffersToUpdateMap.put(incentive.id, new Available_Incentive_Offer__c(id = incentive.id, Effective_Dollar_Amount__c = val));
                    }
                //ELSE DEFAULT
                }else{
                    saveDetail('', true, scenarioN, 'Error: Available Incentive Offer(' + incentive.id + ') has an undefined STEP 2 County Tax Credit "Eligible Cost Basis" - ' + incentive.Eligible_Cost_Basis__c);
                }
            
            //FEED IN TARIFF - UTILITY
            } else if (incentive.RecordType.DeveloperName == 'Feed_In_Tariff' && incentive.Implementing_Sector__c == 'Utility'){

                if (incentive.System_Size_Units__c == 'DC' && incentive.Incentive_Offer__c != null && incentive.Incentive_Offer__r.FIT_Tier_1_Max_Sys_Size_kW__c != null && 
                    incentive.Incentive_Offer__r.FIT_Tier_2_Max_Sys_Size_kW__c != null && incentive.Incentive_Offer__r.FIT_Tier_1_Amount__c != null && 
                    incentive.Incentive_Offer__r.FIT_Tier_2_Amount__c != null && sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Method_1_Production_kWh__c != null){

                    Double[] feedInTariffMonthlyValues = new Double[]{};
                    Double[] method1productionMonths = new Double[]{};
                    for (String str : sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Method_1_Production_kWh__c.split(';', 0))
                        method1productionMonths.add(Double.valueOf(str));

                    //Feed In Tariff Monthly Values
                    if (systemSizeKW <= incentive.Incentive_Offer__r.FIT_Tier_1_Max_Sys_Size_kW__c){
                        for (Double month : method1productionMonths)
                            feedInTariffMonthlyValues.add(incentive.Incentive_Offer__r.FIT_Tier_1_Amount__c * month);
                    } else if (incentive.Incentive_Offer__r.FIT_Tier_1_Max_Sys_Size_kW__c < systemSizeKW && incentive.Incentive_Offer__r.FIT_Tier_2_Max_Sys_Size_kW__c >= systemSizeKW){
                        for (Double month : method1productionMonths)
                            feedInTariffMonthlyValues.add(incentive.Incentive_Offer__r.FIT_Tier_2_Amount__c * month);
                    } else {
                        for (Double month : method1productionMonths)
                            feedInTariffMonthlyValues.add(0);
                    }
                    String feedInTariffMonthlyValuesStr = '';
                    for (Double d : feedInTariffMonthlyValues)
                        feedInTariffMonthlyValuesStr = feedInTariffMonthlyValuesStr + Decimal.valueOf(d).setScale(2) + ';';

                    saveDetail('', false, scenarioN, 'Feed In Tariff Monthly Values: ' + feedInTariffMonthlyValuesStr);

                    //Feed In Tariff Bill Credit
                    Double[] feedInTariffBillCredit = new Double[]{};
                    String[] months = new String[]{'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};
                    if (sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Before_First_Year_Avg_Price__c != null && method1productionMonths.size() == 12){
                        Utility_Service__c us = sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r;
                        for (Integer i = 0; i < 12; i++){
                            Double monthlyForecastedConsumption = us.get('Total_Forecasted_Consumption_kWh_'+months[i]+'__c') != null ? (Double)us.get('Total_Forecasted_Consumption_kWh_'+months[i]+'__c') : 0;
                            feedInTariffBillCredit.add(Math.min(method1productionMonths[i], monthlyForecastedConsumption) * sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Before_First_Year_Avg_Price__c);
                        }
                        String feedInTariffBillCreditStr = '';
                        for (Double d : feedInTariffBillCredit)
                            feedInTariffBillCreditStr = feedInTariffBillCreditStr + Decimal.valueOf(d).setScale(2) + ';';

                        saveDetail('', false, scenarioN, 'Feed In Tariff Bill Credit: ' + feedInTariffBillCreditStr);

                        //Feed In Tariff Taxable Income
                        Double[] feedInTariffTaxableIncome = new Double[]{};
                        for (Integer i = 0; i < 12; i++)
                            feedInTariffTaxableIncome.add(feedInTariffMonthlyValues[i] - feedInTariffBillCredit[i]);

                        String feedInTariffTaxableIncomeStr = '';
                        for (Double d : feedInTariffTaxableIncome)
                            feedInTariffTaxableIncomeStr = feedInTariffTaxableIncomeStr + Decimal.valueOf(d).setScale(2) + ';';

                        saveDetail('', false, scenarioN, 'Feed In Tariff Taxable Income: ' + feedInTariffTaxableIncomeStr);

                        //Feed In Tariff Tax Paid
                        Double[] feedInTariffTaxPaid = new Double[]{};
                        if (System_Design_Quote_Settings__c.getOrgDefaults().Calc_Taxable_Income_on_PBI_Incentives__c){
                            for (Double d : feedInTariffTaxableIncome)
                                feedInTariffTaxPaid.add(d * (sdq.Income_Corporate_Tax_Rate__c != null ? sdq.Income_Corporate_Tax_Rate__c : 0.25));
                        } else {    //false
                            for (Double d : feedInTariffTaxableIncome)
                                feedInTariffTaxPaid.add(0);
                        }

                        String feedInTariffTaxPaidStr = '';
                        for (Double d : feedInTariffTaxPaid)
                            feedInTariffTaxPaidStr = feedInTariffTaxPaidStr + Decimal.valueOf(d).setScale(2) + ';';

                        saveDetail('', false, scenarioN, 'Feed In Tariff Tax Paid: ' + feedInTariffTaxPaidStr);

                        //Feed In Tariff Income After Tax
                        Double[] feedInTariffIncomeAfterTax = new Double[]{};
                        for (Integer i = 0; i < 12; i++)
                            feedInTariffIncomeAfterTax.add(feedInTariffMonthlyValues[i] - feedInTariffTaxPaid[i]);

                        String feedInTariffIncomeAfterTaxStr = '';
                        Double fitSum = 0;
                        for (Double d : feedInTariffIncomeAfterTax){
                            feedInTariffIncomeAfterTaxStr = feedInTariffIncomeAfterTaxStr + Decimal.valueOf(d).setScale(2) + ';';
                            fitSum += d;
                        }

                        saveDetail('', false, scenarioN, 'Feed In Tariff Income After Tax: ' + feedInTariffIncomeAfterTaxStr);
                        if (applyEffectivePrice){
                            if (foundFIT){
                                saveDetail('', true, scenarioN, 'No more than one Feed In Tariff incentive offer may be applied to a scenario.');
                                sdq.put('Scenario_' + scenarioN + '_FIT_Term_Length_Months__c', null);
                                feedInTariffAnnualEarnings = null;
                                continue;
                            }
                            foundFIT = true;
                            feedInTariffAnnualEarnings = fitSum;
                            sdq.put('Scenario_' + scenarioN + '_FIT_Term_Length_Months__c', incentive.Incentive_Offer__r.Term_Months__c);
                        }

                        availableIncentiveOffersToUpdateMap.put(incentive.id, new Available_Incentive_Offer__c(id = incentive.id, Term_Months__c = incentive.Incentive_Offer__r.Term_Months__c, 
                                                            Feed_In_Tariff_Annual_Earnings_After_Tax__c = feedInTariffAnnualEarnings, Effective_Dollar_Amount__c = null));
                    }
                }

            //ELSE DEFAULT
            }else{
                saveDetail('', true, scenarioN, 'Error: Available Incentive Offer(' + incentive.id + ') has an undefined STEP 2 type/sector combination: ' + incentive.RecordType.DeveloperName + ' - Implementing Sector: ' + incentive.Implementing_Sector__c);
            }
            
            if (applyEffectivePrice && incentive.SAC_Eligible__c && String.isNotBlank((string)sdq.get('Scenario' + '_' + scenarioN + '_SAC_Loan__c')))
                effectiveDollarSum += availableIncentiveOffersToUpdateMap.get(incentive.id).Effective_Dollar_Amount__c;
        }
        
        
        //Store values back in the SDQ scenario:
        sdq.put('Scenario_' + scenarioN + '_Depreciation_Basis__c', depreciationBasis);
        sdq.put('Scenario_' + scenarioN + '_Total_Depreciation_Amount__c', depreciationAmount);        
        sdq.put('Scenario_' + scenarioN + '_County_Tax_Credit_Amount__c', countyTaxCredit);
        sdq.put('Scenario_' + scenarioN + '_Federal_Tax_Credit_Amount__c', federalTaxCredit);
        sdq.put('Scenario_' + scenarioN + '_State_Tax_Credit_Amount__c', stateTaxCredit);
        sdq.put('Scenario_' + scenarioN + '_Utility_Rebate_Amount__c', utilityRebate);
        sdq.put('Scenario_' + scenarioN + '_State_Rebate_Amount__c', stateRebate);
        sdq.put('Scenario_' + scenarioN + '_Installer_Paid_Incentive_Amt__c', installerPaidIncentiveTotalAmount); //This is more of a helper field and is not summed for the total incentive amount
        sdq.put('Scenario_' + scenarioN + '_SAC_Incentives__c', effectiveDollarSum);
        sdq.put('Scenario_' + scenarioN + '_FIT_Annual_Earnings_After_Tax__c', feedInTariffAnnualEarnings);
        
        saveDetail('\n', false, scenarioN, '% Depreciation Basis: ' + depreciationBasis);
        saveDetail('\n', false, scenarioN, '$ Depreciation Amount: ' + depreciationAmount);
        saveDetail('', false, scenarioN, '$ County Tax Credit Amount: ' + countyTaxCredit);
        saveDetail('', false, scenarioN, '$ Federal Tax Credit Amount: ' + federalTaxCredit);
        saveDetail('', false, scenarioN, '$ State Tax Credit Amount: ' + stateTaxCredit);
        saveDetail('', false, scenarioN, '$ Utility Rebate Amount: ' + utilityRebate);
        saveDetail('', false, scenarioN, '$ State Rebate Amount: ' + stateRebate);
        saveDetail('', false, scenarioN, '$ SAC Incentives: ' + effectiveDollarSum);
        saveDetail('', false, scenarioN, '$ Feed In Tariff Annual Earnings After Tax: ' + feedInTariffAnnualEarnings);  //CPQ-731

        return;        
    }

    //MK - 2014-09-15
    public void setFinancingProductPricing(Decimal channelPartnerLeaseRate, Integer scenarioN){
        saveDetail('\n', false, scenarioN, '-----------------------------------');
        saveDetail('', false, scenarioN, 'Get Financing Product Pricing');
        saveDetail('', false, scenarioN, '-----------------------------------');

        //Reset values to 0 from any previous runs
        sdq.put('Scenario_' + scenarioN + '_First_Month_Payment__c', 0);
        sdq.put('Scenario_' + scenarioN + '_Total_Monthly_Payments__c', 0);
        sdq.put('Scenario_' + scenarioN + '_Total_Lease_Payments__c', 0 );
        sdq.put('Scenario_' + scenarioN + '_Financing_Rate_Year_1_kWh__c', 0);
        sdq.put('Scenario_' + scenarioN + '_Prepaid_Financing_Amount__c', 0);


        String finType = (string)sdq.get('Scenario_' + scenarioN + '_Financing_Type__c');
        string leaseFund = (string)sdq.get('Scenario_' + scenarioN + '_Lease_Fund__c');        
        string leaseOption = (string)sdq.get('Scenario_' + scenarioN + '_Lease_Option__c');
        double adjustedPrice = (double)sdq.get('Scenario_' + scenarioN + '_Adjusted_Price_NUM__c');
        decimal downPayment = (decimal)sdq.get('Scenario_' + scenarioN + '_Down_Payment__c');
        if (downPayment == null)
        {
            downPayment = 0;
        }
        double stateRebate = (double)sdq.get('Scenario_' + scenarioN + '_State_Rebate_Amount__c');
        double siteQuality = (double)sdq.get('Scenario_' + scenarioN + '_Site_Quality__c');

        string creditTier = (string)sdq.get('Scenario_' + scenarioN + '_Credit_Tier__c');
        //decimal channelPartnerLeaseRate = sdq.Channel_Partner_Lease_Rate_kWh__c;      //Commented out for CPQ-704
        boolean channelPartner = sdq.Channel_Partner__c;

        string escalatorString = (string)sdq.get('Scenario_' + scenarioN + '_Lease_Escalator__c');
        if(escalatorString == null || escalatorString == '') escalatorString = '0';
        saveDetail('', false, scenarioN, 'Scenario escalator: ' + escalatorString);

        decimal financingRate = 0.0000;
        decimal prepaidFinancingAmount = 0.00;
        boolean createVPOverrideTopLineAdjustment = false;
        decimal channelPartnerEPC;

        ID utilCompanyID = sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__c;
        Decimal vpOverrideAmount = sdq.get('Scenario_' + scenarioN + '_VP_Sales_Adjustments__c') != null ? (Decimal)sdq.get('Scenario_' + scenarioN + '_VP_Sales_Adjustments__c') : 0;

        if(financingProductPricingMatches == null){
            //Set this on the first scenario
            financingProductPricingMatches = [SELECT Alpha__c, Beta__c, Credit_Tier__c, Delta__c, Epsilon__c, Escalator__c, Name, Gamma__c, Pricing_Region__c, Panel_Type__c, 
                                                    Lease_Fund__c, Lease_Fund__r.Name, Lease_Fund__r.Finance_Pricing_Algorithm__c, Payment_Type__c, Product_Type__c, 
                                                    SREC_Sold_to_Third_Party__c, State__c, Ineligibility_Threshold__c, Size_Threshold__c, Size_Adder__c, High_PPA_Rate_Threshold__c, 
                                                    High_PPA_Rate_Adder__c, Base_PPA_Rate__c, Utility_Company__c, Community_Program_Offer__c, PPA_Rate_EPC__c, Tier_1_PPA_Rate__c, 
                                                    Tier_2_PPA_Rate__c, Tier_3_PPA_Rate__c, Tier_4_PPA_Rate__c, Tier_5_PPA_Rate__c, Tier_6_PPA_Rate__c, Starting_Rate_Tier__c, 
                                                    Tier_1_Threshold__c, Tier_2_Threshold__c, Tier_3_Threshold__c, Tier_4_Threshold__c, Tier_5_Threshold__c, Tier_6_Threshold__c, Tier_1_EPC__c, 
                                                    Tier_2_EPC__c, Tier_3_EPC__c, Tier_4_EPC__c, Tier_5_EPC__c, Tier_6_EPC__c, Minimum_System_Size_kW__c, Maximum_System_Size_kW__c, 
                                                    Start_Date__c, End_Date__c 
                                              FROM Financing_Product_Pricing__c 
                                              WHERE State__r.State_Abbreviation__c =: propState
                                              ORDER BY Product_Type__c]; //This will sort the Leases first since in one state there are both
                                                                        //a lease and PPA... we want to put Lease first.
        }
        
        Financing_Product_Pricing__c fpp;
        for(Financing_Product_Pricing__c f : financingProductPricingMatches){
            saveDetail('', false, scenarioN, 'Check for match on: ' + f.id);
            boolean isMatch = true;

            //Match on escalator
            f.Escalator__c = (f.Escalator__c == null || f.Escalator__c == '') ? '0' : f.Escalator__c;
            if(f.Escalator__c != escalatorString){                
                saveDetail('', false, scenarioN, 'Escalator value does not match');
                isMatch = false;
            }

            //Match the lease fund
            if(leaseFund == null || f.Lease_Fund__c != leaseFund){
                saveDetail('', false, scenarioN, 'Lease Fund does not match');
                isMatch = false;   
            }            

            //If FPP Credit Tier = ‘null’
            if(f.Credit_Tier__c == null){ 
                // Skip this check, when it's null it's valid and does not need to be compared with scenario credit tier
            //If Scenario N Credit Tier = ‘null’
            }else if(creditTier == null){                
                //Financing Product Pricing.Credit Tier = 2
                if(f.Credit_Tier__c != '2'){
                    saveDetail('', false, scenarioN, 'Scenario Credit Tier blank, this is not the default credit tier of 2.');
                    isMatch = false;
                }
                //else, it's still a match
            
            //If Scenario N Credit Tier <> ‘null’
            }else{
                //Scenario N Credit Tier = Financing Product Pricing.Credit Tier
                if(f.Credit_Tier__c == null || creditTier != f.Credit_Tier__c){
                    saveDetail('', false, scenarioN, 'Credit Tiers do not match.');
                    isMatch = false;
                }
                //else, it's still a match
            }

            if (f.Lease_Fund__r.Finance_Pricing_Algorithm__c == 'OneRoof' || f.Lease_Fund__r.Finance_Pricing_Algorithm__c == 'Portfolio PPA'){     //CPQ-738
                if (f.Utility_Company__c != utilCompanyID){
                    saveDetail('', false, scenarioN, 'OneRoof requires that the Utility Company be matched.');
                    isMatch = false;
                }
                if (f.Community_Program_Offer__c != commProg){
                    saveDetail('', false, scenarioN, 'OneRoof requires that the Community Program Offer be matched.');
                    isMatch = false;   
                }
            }
            
            //Scenario N Lease Option to Finance Product Pricing.Product Type & Financing Product Pricing.Payment Type mapping is true
            if(leaseOption != null //&& f.Product_Type__c != null && finType != null && finType == f.Product_Type__c
                &&(
                    (leaseOption == 'Low-Upfront - Monthly' && f.Payment_Type__c == 'Monthly')
                    ||
                    (leaseOption == 'One-Pay' && f.Payment_Type__c == 'Prepaid')
                    ||
                    (leaseOption == f.Payment_Type__c)
                )
            ){
                //We have a match
            }else{
                saveDetail('', false, scenarioN, 'Lease Options do not match.');
                isMatch = false;
            }

            if (isMatch && f.Lease_Fund__r.Finance_Pricing_Algorithm__c == 'Portfolio PPA'){    //CPQ-745
                if (f.Pricing_Region__c != sdq.Pricing_Region__c){
                    saveDetail('', false, scenarioN, 'Portfolio Pricing requires that the SDQ\'s pricing region matches that of the FPP (' + f.Pricing_Region__c + ').');
                    continue;
                }
                if (finType != f.Product_Type__c){
                    saveDetail('', false, scenarioN, 'Portfolio Pricing requires that the scenario\'s financing type matches the FPP\'s product type (' + f.Product_Type__c + ').');
                    continue;
                }
                if (f.Panel_Type__c != sdq.System_Design__r.System_Panel__c){
                    saveDetail('', false, scenarioN, 'Portfolio Pricing requires that the system panel matches the FPP\'s panel type (' + f.Panel_Type__c + ').');
                    continue;
                }
                if (f.Minimum_System_Size_kW__c > systemSizeKW || f.Maximum_System_Size_kW__c <= systemSizeKW){
                    saveDetail('', false, scenarioN, 'Portfolio Pricing requires that the system size be greater than or equal to the FPP\'s minimum system size (' + f.Minimum_System_Size_kW__c +
                                ' kW) and less than the FPP\'s maximum system size (' + f.Maximum_System_Size_kW__c + ' kW).');
                    continue;
                }
                Date pricingDate = Date.newInstance(sdq.Pricing_Date__c.year(), sdq.Pricing_Date__c.month(), sdq.Pricing_Date__c.day());
                if (f.Start_Date__c > pricingDate || f.End_Date__c < pricingDate){
                    saveDetail('', false, scenarioN, 'Portfolio Pricing requires that the SDQ\'s pricing date be greater than or equal to the FPP\'s start date (' + f.Start_Date__c + 
                            ') and less than or equal to the FPP\'s end date (' + f.End_Date__c + ').');
                    continue;
                }
            }

            if(isMatch){
                saveDetail('', false, scenarioN, 'This is a matching record.');
                fpp = f;
                break; //Get out of loop in case there are other matches, we want to pick the Lease first.
            }
        
        }//end for

        if(fpp != null){
            saveDetail('', false, scenarioN, 'Lease fund: ' + fpp.Lease_Fund__r.Name);
            saveDetail('', false, scenarioN, 'Lease fund Finance Pricing Algorithm: ' + fpp.Lease_Fund__r.Finance_Pricing_Algorithm__c);            
            
            if(fpp.Lease_Fund__r.Finance_Pricing_Algorithm__c != null && (fpp.Lease_Fund__r.Finance_Pricing_Algorithm__c == 'Kilowatt' || fpp.Lease_Fund__r.Finance_Pricing_Algorithm__c == 'OneRoof')){
                
                //decimal financeVal = getKilowattFinanceVal(scenarioN, fpp, adjustedPrice, downPayment, stateRebate, siteQuality);

                if(fpp.Payment_Type__c == 'Monthly' || fpp.Payment_Type__c == 'Fixed-Rate PPA'){
                    //Scenario N Financing Rate equals 
                        //(
                        //    (
                        //        (
                        //            Scenario N Adjusted Price / System Size
                        //            - Alpha 
                        //            - ( Beta * Scenario N Down Payment / ( System Size * 1000 ) ) 
                        //            - ( Gamma * Scenario N State Rebate Amount / ( System Size * 1000 ) ) / ( Scenario N Site Quality * System Size )
                        //        ) 
                        //        - Delta
                        //    )
                        //    / Epsilon
                        //)
                    
                    if (fpp.Lease_Fund__r.Finance_Pricing_Algorithm__c == 'Kilowatt'){
                        financingRate = getKilowattFinanceMonthly(scenarioN, fpp, adjustedPrice, downPayment, stateRebate, siteQuality);
                    }
                    else if (fpp.Lease_Fund__r.Finance_Pricing_Algorithm__c == 'OneRoof'){
                        financingRate = getFixedRatePPA(sdq.Total_System_Size_kW__c, (Decimal)sdq.get('Scenario_' + scenarioN + '_Non_Panel_Design_Price__c'), 
                                                        (Decimal)sdq.get('Scenario_' + scenarioN + '_Trenching_Table_Value_Total__c'), fpp.Ineligibility_Threshold__c, 
                                                        fpp.Size_Threshold__c, fpp.Size_Adder__c, fpp.High_PPA_Rate_Threshold__c, 
                                                        fpp.High_PPA_Rate_Adder__c, fpp.Base_PPA_Rate__c, scenarioN);
                        if (financingRate == null)
                            saveDetail('', true, scenarioN, 'Error: Failed to derive a financing rate based off fixed-rate PPA rules for OneRoof.');    //TO DO: Remove/replace
                    }

                    if(channelPartner || fpp.Lease_Fund__r.Finance_Pricing_Algorithm__c == 'OneRoof'){
                        saveDetail('\n', false, scenarioN, 'This is a channel partner (or OneRoof) scenario');
                        //Channel Partner EPC(temporary variable) = 
                            //(
                            //    System Size
                            //    * ( 
                            //        Alpha 
                            //        + ( 
                            //            Beta * Scenario N Down Payment / ( System Size * 1000 ) 
                            //        ) 
                            //        + (
                            //            Gamma * (Scenario N Rebate Amount / ( System Size * 1000 ) ) 
                            //            + (
                            //                ( Scenario N Site Quality * System Size ) 
                            //                * (
                            //                    Delta + ( Epsilon * Channel Partner Lease Rate )
                            //                )
                            //            )
                            //        )
                            //    )
                            //)
                        
                        if (fpp.Lease_Fund__r.Finance_Pricing_Algorithm__c == 'Kilowatt'){
                            saveDetail('', false, scenarioN, '-- Calculation Variables --');
                            decimal s = systemSizeW;
                            decimal a2 = fpp.Alpha__c;
                            decimal b2 = fpp.Beta__c * downPayment / systemSizeW;
                            decimal g2 = fpp.Gamma__c * stateRebate / systemSizeW;
                            decimal sq = siteQuality / 1000;
                            decimal de = (fpp.Delta__c + ( fpp.Epsilon__c * channelPartnerLeaseRate ));
                            saveDetail('', false, scenarioN, '[s] = systemSizeW = ' + s);
                            saveDetail('', false, scenarioN, '[a2] = fpp.Alpha__c = ' + a2);
                            saveDetail('', false, scenarioN, '[b2] = fpp.Beta__c * downPayment / systemSizeW = ' + b2);
                            saveDetail('', false, scenarioN, '[g2] = fpp.Gamma__c * stateRebate / systemSizeW = ' + g2);
                            saveDetail('', false, scenarioN, '[sq] = siteQuality / 1000 = ' + sq);
                            saveDetail('', false, scenarioN, '[de] = (fpp.Delta__c + ( fpp.Epsilon__c * channelPartnerLeaseRate )) = ' + de);

                            channelPartnerEPC = ( s * ( a2 + b2 + g2 + sq * de ) );

                            saveDetail('', false, scenarioN, '[Channel Partner EPC Total] = ( s * ( a2 + b2 + g2 + sq * de ) ) = ' + channelPartnerEPC);
                        }
                        else if (fpp.Lease_Fund__r.Finance_Pricing_Algorithm__c == 'OneRoof'){      //CPQ-738
                            try {
                                String rateKeys = fpp.PPA_Rate_EPC__c;   //Semicolon delimited pairings like 0.1550, 3.4; 0.1602, 3.5; 0.1710, 3.6;
                                String epcRate = rateKeys.substringBetween(String.valueOf(financingRate.setScale(4)) + ',', ';');
                                if (epcRate == null)
                                    epcRate = rateKeys.substringBetween(String.valueOf(financingRate.setScale(4)).substringAfter('0') + ',', ';');  //Try matching .5 instead of 0.5
                                epcRate = epcRate.trim();
                                Decimal epcRateNum = Decimal.valueOf(epcRate);
                                channelPartnerEPC = epcRateNum * systemSizeW;
                                createVPOverrideTopLineAdjustment = true;
                                saveDetail('', false, scenarioN, 'PPA Rate of ' + financingRate.setScale(4) + ' corresponds to a $/W EPC Rate of ' + epcRateNum +'. ' + 
                                            'Channel Parter EPC = System Size (W) * $/W EPC Rate = ' + systemSizeW + ' * ' + epcRateNum + ' = ' + channelPartnerEPC);
                            } catch (Exception e){
                                saveDetail('', true, scenarioN, 'Error: Unable to find $/W EPC Rate related to calculated PPA Rate of ' + financingRate.setScale(4) + '.');
                            }
                        }

                        //saveDetail('', false, scenarioN, 'SystemSize: ' + systemSizeKW);
                        if (fpp.Lease_Fund__r.Finance_Pricing_Algorithm__c == 'Kilowatt'){
                            if(systemSizeKW >= 6){
                                //If Channel Partner EPC >= Scenario N Adjusted Price * 0.25
                                if(channelPartnerEPC / (systemSizeKW*1000) >= (adjustedPrice * 0.25) / (systemSizeKW*1000)){   //Changed for CPQ-704 to widen the passing margin
                                    createVPOverrideTopLineAdjustment = true;                                
                                }
                                //If Channel Partner EPC < Scenario N Adjusted Price * 0.25                            
                                    //No Adjustment

                            //If System Size < 6
                            }else{
                                //If Channel Partner EPC >= Scenario N Adjusted Price * 0.25
                                if(channelPartnerEPC/(systemSizeKW*1000) >= (adjustedPrice * 0.25) / (systemSizeKW*1000)){   //Changed for CPQ-704 to widen the passing margin
                                    createVPOverrideTopLineAdjustment = true;
                                }
                                //If Channel Partner EPC < Scenario N Adjusted Price * 0.25
                                    //No Adjustment                                
                            }
                        }
                    }

                //If Payment Type = ‘Prepaid’
                }else{
                    //Scenario N Prepaid Financing Amount equals
                        //(
                        //    (
                        //        (
                        //            Scenario N Adjusted Price / System Size
                        //            - Alpha 
                        //            - ( Beta * Scenario N Down Payment / ( System Size * 1000 ) ) 
                        //            - ( Gamma * Scenario N State Rebate Amount / ( System Size * 1000 ) ) / ( Scenario N Site Quality * System Size )
                        //        ) 
                        //        - Delta
                        //    )
                        //    / Epsilon
                        //)
                    prepaidFinancingAmount = getKilowattFinancePrepaid(scenarioN, fpp, adjustedPrice, downPayment, stateRebate, siteQuality);
                }
            }

            if (fpp.Lease_Fund__r.Finance_Pricing_Algorithm__c == 'Portfolio PPA'){     //CPQ-745
                saveDetail('\n', false, scenarioN, '-- Running Portfolio PPA Pricing --');
                Integer rateTier = -1;  //Default value is the error condition
                String availableTiers = '';
                Decimal variableReduction = 0;  //Used to determine commission impact promotions. Will change if the user updates rate tiers.
                Decimal adderReduction = 0;     //Equal to adders - max threshold where adders > max threshold. Will not change if the user updates rate tiers.
                Decimal maxPromo = ContractSettings__c.getOrgDefaults().Maximum_Promotion__c != null ? ContractSettings__c.getOrgDefaults().Maximum_Promotion__c : 0.5;
                
                //Start the Portfolio calculations
                Decimal nonPanelDesignPrice = sdq.get('Scenario_' + scenarioN + '_Non_Panel_Design_Price__c') != null ? (Decimal)sdq.get('Scenario_' + scenarioN + '_Non_Panel_Design_Price__c') : 0;
                Decimal trenchingTableValue = sdq.get('Scenario_' + scenarioN + '_Trenching_Table_Value_Total__c') != null ? (Decimal)sdq.get('Scenario_' + scenarioN + '_Trenching_Table_Value_Total__c') : 0;
                Decimal adder = (nonPanelDesignPrice + trenchingTableValue) / (systemSizeKW * 1000);
                saveDetail('', false, scenarioN, 'Adder = (nonPanelDesignPrice + trenchingTableValue) / (systemSizeKW * 1000) = (' + nonPanelDesignPrice + ' + ' + 
                                                    trenchingTableValue + ') / (' + systemSizeKW + ' * 1000) = ' + adder.setScale(2));
                Decimal startingRateTier = fpp.Starting_Rate_Tier__c;
                if (startingRateTier == null || startingRateTier < 1 || startingRateTier > 6)
                    saveDetail('', true, scenarioN, 'Error: Invalid Portfolio PPA starting rate tier for scenario ' + scenarioN + '.');
                
                Integer defaultTier = sdq.get('Scenario_' + scenarioN + '_Portfolio_Default_Tier__c') != null ? Integer.valueOf(sdq.get('Scenario_' + scenarioN + '_Portfolio_Default_Tier__c')) : null;
                Integer selectedTier = sdq.get('Scenario_' + scenarioN + '_Portfolio_Tier_Selected__c') != null ? Integer.valueOf(sdq.get('Scenario_' + scenarioN + '_Portfolio_Tier_Selected__c')) : null;

                Integer highestTierWithThresholdData = 1;
                for (Integer i = 1; i <= 6; i++){
                    if (fpp.get('Tier_' + i + '_Threshold__c') != null)
                        highestTierWithThresholdData = i;
                }
                Decimal maxThreshold = 0;   //Relative max
                Integer maxTier = highestTierWithThresholdData;    //Default value is the probable result unless the user has selected a lower tier after already receiving an adder reduction

                for (Integer i = 1; i <= highestTierWithThresholdData; i++){
                    if ((selectedTier == null || i <= selectedTier) && fpp.get('Tier_' + i + '_Threshold__c') != null && (Decimal)fpp.get('Tier_' + i + '_Threshold__c') > maxThreshold){
                        maxThreshold = (Decimal)fpp.get('Tier_' + i + '_Threshold__c');
                        maxTier = i;
                    }
                    if (i >= startingRateTier){
                        if (adder <= (fpp.get('Tier_' + i + '_Threshold__c') != null ? (Decimal)fpp.get('Tier_' + i + '_Threshold__c') : 0)){
                            rateTier = i;
                            break;
                        }
                    }
                }
                Integer trueMaxTier = rateTier != -1 ? rateTier : highestTierWithThresholdData;     //Save this value before we possibly overwrite it

                if (rateTier == -1){     //Indicates that the adders are too high to fall within a tier threshold range
                    if (commProg == null && adder > maxThreshold && adder - maxPromo <= maxThreshold){
                        variableReduction = adder - maxThreshold;
                        rateTier = maxTier;
                        if (fpp.get('Tier_' + highestTierWithThresholdData + '_Threshold__c') != null)
                            adderReduction = adder - (Decimal)fpp.get('Tier_' + highestTierWithThresholdData + '_Threshold__c');
                    } else {
                        saveDetail('', true, scenarioN, 'Error: Scenario ' + scenarioN + ' may not be priced for Portfolio PPA because the value of the adders ($' + adder.setScale(2) + ') exceeds the maximum threshold ($' + maxThreshold + ').');
                    }
                }

                if (commProg != null){
                    availableTiers = trueMaxTier > 0 ? String.valueOf(trueMaxTier) : '';
                } else {
                    maxPromo = maxPromo - variableReduction;
                    for (Integer i = trueMaxTier; i >= 1; i--){
                        if (fpp.get('Tier_' + i + '_PPA_Rate__c') != null && fpp.get('Tier_' + rateTier + '_EPC__c') != null && fpp.get('Tier_' + i + '_EPC__c') != null && 
                            (Decimal)fpp.get('Tier_' + rateTier + '_EPC__c') - (Decimal)fpp.get('Tier_' + i + '_EPC__c') <= maxPromo)
                            availableTiers = availableTiers + i + ';';
                    }
                }
                sdq.put('Scenario_' + scenarioN + '_Commission_Impact_Promotions__c', variableReduction);
                sdq.put('Scenario_' + scenarioN + '_PPA_Adder_Reduction__c', adderReduction);
                if (defaultTier == null || (selectedTier != null && !availableTiers.contains('' + selectedTier))){
                    sdq.put('Scenario_' + scenarioN + '_Portfolio_Default_Tier__c', rateTier != -1 ? rateTier : null);  //The "starting tier"
                    sdq.put('Scenario_' + scenarioN + '_Portfolio_Tier_Selected__c', rateTier != -1 ? rateTier : null);
                }
                sdq.put('Scenario_' + scenarioN + '_Available_Portfolio_Tiers__c', availableTiers != '' ? availableTiers : null);     //Populating a picklist in the input page

                if (defaultTier != null) {
                    Decimal prevTier = defaultTier;
                    rateTier = selectedTier != null ? selectedTier : Integer.valueOf(prevTier);
                    if (fpp.get('Tier_' + prevTier + '_EPC__c') != null && fpp.get('Tier_' + rateTier + '_EPC__c') != null && prevTier > rateTier){
                        sdq.put('Scenario_' + scenarioN + '_Commission_Impact_Promotions__c', (Decimal)fpp.get('Tier_' + prevTier + '_EPC__c') - (Decimal)fpp.get('Tier_' + rateTier + '_EPC__c') + adderReduction);
                        saveDetail('', false, scenarioN, 'Commission Impact Promotions = FPP.Tier ' + prevTier + ' EPC - FPP.Tier ' + rateTier + ' EPC + Adder Reduction = ' + 
                                    fpp.get('Tier_' + prevTier + '_EPC__c') + ' - ' + fpp.get('Tier_' + rateTier + '_EPC__c') + ' + ' + adderReduction + ' = ' + sdq.get('Scenario_' + scenarioN + '_Commission_Impact_Promotions__c'));
                    }
                }
                if (rateTier >= 1 && rateTier <= 6){
                    financingRate = fpp.get('Tier_' + rateTier + '_PPA_Rate__c') != null ? (Decimal)fpp.get('Tier_' + rateTier + '_PPA_Rate__c') : 0;
                    createVPOverrideTopLineAdjustment = true;
                    channelPartnerEPC = (fpp.get('Tier_' + rateTier + '_EPC__c') != null ? (Decimal)fpp.get('Tier_' + rateTier + '_EPC__c') : 0) * systemSizeW;
                }
            }
        }//end if(fpp != null)
        else
        {
            if(finType == 'Lease' || finType == 'PPA')
            {
                saveDetail('', true, scenarioN, 'Error : Financing Product Pricing not found for this Lease Fund,Escalator,Leasing Option Combination.');
            }    
        }


        //Store values back in the SDQ scenario:        
        sdq.put('Scenario_' + scenarioN + '_Financing_Rate_Year_1_kWh__c', financingRate);
        sdq.put('Scenario_' + scenarioN + '_Prepaid_Financing_Amount__c', prepaidFinancingAmount);
        
        saveDetail('\n', false, scenarioN, 'Financing Rate Year 1 ($/kWh): ' + financingRate);
        saveDetail('', false, scenarioN, 'Prepaid Financing Amount ($): ' + prepaidFinancingAmount);
        

        //CREATE VP OVERRIDE ADJUSTMENT
        if(createVPOverrideTopLineAdjustment){
            saveDetail('\n', false, scenarioN, 'Creating VP Override Top Line Adjustment');

            //Search the database to see if the VP Override Top Line Adjustment already exists for this
            
            //This list will be used to send into the recalc method at the end
            list<Price_Adjustment__c> vpTopLinePriceAdjustmentsThisScenario = new list<Price_Adjustment__c>();
            
            //This list is used just to update and insert records as needed
            list<Price_Adjustment__c> priceAdjustmentsToUpsert = new list<Price_Adjustment__c>();

            Price_Adjustment__c channelPartnerAdjustment; //This will be populated only if there is an existing record in the database for this
            
            for(Price_Adjustment__c p : sdq.Price_Adjustments__r){
                if(p.Applicable_Scenario__c == null || p.Applicable_Scenario__c != string.valueof(scenarioN)) continue; //Not a matching scenario adjustment

                if(p.Type__c != null && p.Type__c == 'VP Override' && !p.Apply_As_Net_Adjustment__c){                
                    //This is a VP Top Line Adjustment, need to add it to the vpTopLine list
                    //vpTopLinePriceAdjustmentsThisScenario.add(p);

                    //Check to see if this one is the Channel partner one that we need to work with

                    //We found the matching record already in the database.                    
                    channelPartnerAdjustment = p; //by ref
                    priceAdjustmentsToUpsert.add(p); //by ref
                }
            }
            
            //Create VP Override Top Line Adjustment = Scenario N Adjusted Price – Channel Partner EPC
            if(channelPartnerAdjustment != null){
                //This is an existing record
                //Make sure these are blank
              
                channelPartnerAdjustment.Percent__c = null;
                channelPartnerAdjustment.Amount_per_Watt__c = null;
            }else{
              
                channelPartnerAdjustment = new Price_Adjustment__c();
                channelPartnerAdjustment.System_Design_Quote__c = sdq.id;
                channelPartnerAdjustment.Type__c = 'VP Override';
                channelPartnerAdjustment.Channel_Partner_Adjustment__c = true;
                channelPartnerAdjustment.Applicable_Scenario__c = string.valueof(scenarioN);
            }
            saveDetail('', false, scenarioN, '(adjusted price: ' + adjustedPrice + ', channel partner epc: '+channelPartnerEPC + ', vp override amount: '+ vpOverrideAmount + ')');
            //Make sure the recordtype is correct, overwrite values
            channelPartnerAdjustment.RecordTypeID = priceAdjustmentRecordTypeNameMap.get('Dollar Amount').getRecordTypeID();
            channelPartnerAdjustment.Name = 'Channel Partner Adjustment';
            channelPartnerAdjustment.Amount__c = channelPartnerEPC - (adjustedPrice - vpOverrideAmount) ; //CPQ-704. Prevent the new VP Override from negating the previous.
            channelPartnerAdjustment.Adjustment_Applied__c = true;
            channelPartnerAdjustment.Opt_Out_of_Adjustment__c = false;
            channelPartnerAdjustment.Channel_Partner_Adjustment__c = true;

            //If this is a brand new record, then add it to both lists.
            if(channelPartnerAdjustment.id == null){
                priceAdjustmentsToUpsert.add(channelPartnerAdjustment);
               // vpTopLinePriceAdjustmentsThisScenario.add(channelPartnerAdjustment);
            }

            vpTopLinePriceAdjustmentsThisScenario.add(channelPartnerAdjustment);

            //Perform DML if needed
            if(!priceAdjustmentsToUpsert.isempty()) upsert priceAdjustmentsToUpsert;

            //Recalculate the total VP Override Top Line Adjustment amount and adjusted prices etc.
            adjustedPrice = recalcVPOverrideTopLineAdjustment(scenarioN, vpTopLinePriceAdjustmentsThisScenario);

            if (fpp.Lease_Fund__r.Finance_Pricing_Algorithm__c != 'OneRoof' && fpp.Lease_Fund__r.Finance_Pricing_Algorithm__c != 'Portfolio PPA'){
                //Recalculate the financing rate using the same FPP, store the value, then calculate monthly payments and incentives.
                saveDetail('\n', false, scenarioN, '-----------------------------------');
                saveDetail('', false, scenarioN, '(RECALCULATE FINANCING RATE)');
                saveDetail('', false, scenarioN, '-----------------------------------');
                
                //decimal financeVal = getKilowattFinanceVal(scenarioN, fpp, adjustedPrice, downPayment, stateRebate, siteQuality);
            
                if(fpp.Payment_Type__c == 'Monthly' || fpp.Payment_Type__c == 'Fixed-Rate PPA'){        
                    financingRate = getKilowattFinanceMonthly(scenarioN, fpp, adjustedPrice, downPayment, stateRebate, siteQuality);      
                }else{
                    prepaidFinancingAmount = getKilowattFinancePrepaid(scenarioN, fpp, adjustedPrice, downPayment, stateRebate, siteQuality);
                }
                
                //Store values back in the SDQ scenario:        
                sdq.put('Scenario_' + scenarioN + '_Financing_Rate_Year_1_kWh__c', financingRate);
                sdq.put('Scenario_' + scenarioN + '_Prepaid_Financing_Amount__c', prepaidFinancingAmount);
                
                saveDetail('\n', false, scenarioN, 'Financing Rate Year 1 ($/kWh): ' + financingRate);
                saveDetail('', false, scenarioN, 'Prepaid Financing Amount ($): ' + prepaidFinancingAmount);
            }
        }        

        //Check to see if we need to calculate the monthly payments
        saveDetail('', false, scenarioN, 'Run more calculations if we have a financing rate.');        
        if(financingRate != 0){
            setLeasePaymentValues(scenarioN);
            
            //Then recalculate the incentives
            saveDetail('\n', false, scenarioN, '-----------------------------------');
            saveDetail('', false, scenarioN, '(RECALCULATE INCENTIVES)');
            saveDetail('', false, scenarioN, '-----------------------------------');
            setIncentiveValue(scenarioN); 
        }
                
        return;
    }

    private Decimal setTermLoanPricing(Integer scenarioN, Decimal buyDown){
        saveDetail('', false, scenarioN, 'Inside Get Loan Pricing');
        //Reset values to 0 from any previous runs
        sdq.put('Scenario_' + scenarioN + '_First_Month_Payment__c', 0);
        sdq.put('Scenario_' + scenarioN + '_Total_Monthly_Payments__c', 0);
        sdq.put('Scenario_' + scenarioN + '_Total_Lease_Payments__c', 0 );
        sdq.put('Scenario_' + scenarioN + '_Financing_Rate_Year_1_kWh__c', 0);
        sdq.put('Scenario_' + scenarioN + '_Prepaid_Financing_Amount__c', 0);

        double epcPrice = (double)sdq.get('Scenario_' + scenarioN + '_Final_EPC_Price_NUM__c'); //Price Net of Upfront SREC
        double downPayment = (double)sdq.get('Scenario_' + scenarioN + '_Down_Payment__c') != null ? (double)sdq.get('Scenario_' + scenarioN + '_Down_Payment__c') : 0;
        double sacLoan = (double)sdq.get('Scenario_' + scenarioN + '_SAC_Incentives__c') != null ? (double)sdq.get('Scenario_' + scenarioN + '_SAC_Incentives__c') :0 ;
        double sacLoanAdj = (double)sdq.get('Scenario_' + scenarioN + '_SAC_Loan_Adjustment__c') != null ? (double)sdq.get('Scenario_' + scenarioN + '_SAC_Loan_Adjustment__c') :0 ;
        double adjPrice = (double)sdq.get('Scenario_' + scenarioN + '_Adjusted_Price_NUM__c') != null ? (double)sdq.get('Scenario_' + scenarioN + '_Adjusted_Price_NUM__c') : 0;
        double srecDiscounts = (double)sdq.get('Scenario_' + scenarioN + '_SREC_Contract_Discount__c') != null ? (double)sdq.get('Scenario_' + scenarioN + '_SREC_Contract_Discount__c') : 0;
        Double installerPaidInc = sdq.get('Scenario_' + scenarioN + '_Installer_Paid_Incentive_Amt__c') != null ? (Double)sdq.get('Scenario_' + scenarioN + '_Installer_Paid_Incentive_Amt__c') : 0;
        double maxSACAmtPerc = (sdq.getSObject('Scenario_' + scenarioN + '_SAC_Loan__r') == null || sdq.getSObject('Scenario_' + scenarioN + '_SAC_Loan__r').get('Maximum_Financed_Amount__c') == null) ? 0 : (double)sdq.getSObject('Scenario_' + scenarioN + '_SAC_Loan__r').get('Maximum_Financed_Amount__c');
        double sacLoanAmt = 0;
        if(maxSACAmtPerc == 0){
            sacLoanAmt = sacLoan + sacLoanAdj;
        } else {
            double sacLoanAmt1 = sacLoan + sacLoanAdj;
            double sacLoanAmt2 = (maxSACAmtPerc / 100) * (adjPrice - downPayment - installerPaidInc - srecDiscounts);
            sacLoanAmt = Math.min(sacLoanAmt1, sacLoanAmt2);
        }

        Double customerFees = sdq.getSObject('Scenario_' + scenarioN + '_Term_Loan__r').get('Customer_Fees__c') != null ? (Double)sdq.getSObject('Scenario_' + scenarioN + '_Term_Loan__r').get('Customer_Fees__c') : 0;
        //saveDetail('', false, scenarioN, 'Term Loan Amount Formula:' + epcPrice + ' - ' + downPayment + ' - ' + sacLoan + ' + ' + sacLoanAdj + ' - ' +  installerPaidInc + ' + ' + customerFees + ' - ' + buyDown);
        Decimal termLoanAmount = epcPrice - downPayment - sacLoanAmt - installerPaidInc + customerFees - buyDown;     //Modified on 8/28/15 for CPQ-685, and again on 9/16 for CPQ-675
system.debug('**SZ: amounts...');
system.debug('**SZ: epcPrice = ' + epcPrice);
system.debug('**SZ: downPayment = ' + downPayment);
system.debug('**SZ: sacLoan = ' + sacLoan);
system.debug('**SZ: sacLoanAdj = ' + sacLoanAdj);
system.debug('**SZ: adjPrice = ' + adjPrice);
system.debug('**SZ: srecDiscounts = ' + srecDiscounts);
system.debug('**SZ: installerPaidInc = ' + installerPaidInc);
system.debug('**SZ: maxSACAmtPerc = ' + maxSACAmtPerc);

system.debug('**SZ: sacLoanAmt = ' + sacLoanAmt);
system.debug('**SZ: termLoanAmount = ' + termLoanAmount);
             
        if (sdq.get('Scenario_' + scenarioN + '_Term_Loan_Amount__c') != null && sdq.getSObject('Scenario_' + scenarioN + '_Term_Loan__r').get('Financing_Term_Months__c') != null){
            saveDetail('\n', false, scenarioN, '-----------------------------------');
            saveDetail('', false, scenarioN, 'Get Loan Pricing');
            saveDetail('', false, scenarioN, '-----------------------------------');
            saveDetail('', false, scenarioN, 'Term Loan Amount = ' + termLoanAmount );

            Boolean refuseACH = (Boolean)sdq.get('Scenario_' + scenarioN + '_Refuse_ACH__c'); // default is true, only visible to sighten scenarios, so should always be true for non-sighten
            saveDetail('', false, scenarioN, 'Refuse ACH Rate = ' + refuseACH );

            Decimal apr = 0.05;
            Decimal monthlyAPR = 0.05 / 12;

            if(refuseACH){
                apr = sdq.getSObject('Scenario_' + scenarioN + '_Term_Loan__r').get('Non_ACH_APR__c') != null ? (Decimal)sdq.getSObject('Scenario_' + scenarioN + '_Term_Loan__r').get('Non_ACH_APR__c') / 100 : 0.05;
                monthlyAPR = sdq.getSObject('Scenario_' + scenarioN + '_Term_Loan__r').get('Non_ACH_Monthly_Interest_Rate__c') != null ? (Decimal)sdq.getSObject('Scenario_' + scenarioN + '_Term_Loan__r').get('Non_ACH_Monthly_Interest_Rate__c') / 100 : apr / 12.0;
            } else {
                apr = sdq.getSObject('Scenario_' + scenarioN + '_Term_Loan__r').get('APR__c') != null ? (Decimal)sdq.getSObject('Scenario_' + scenarioN + '_Term_Loan__r').get('APR__c') / 100 : 0.05;
                monthlyAPR = sdq.getSObject('Scenario_' + scenarioN + '_Term_Loan__r').get('Monthly_Interest_Rate__c') != null ? (Decimal)sdq.getSObject('Scenario_' + scenarioN + '_Term_Loan__r').get('Monthly_Interest_Rate__c') / 100 : apr / 12.0;
            }

            saveDetail('', false, scenarioN, 'Term Loan APR = ' + apr + ', Monthly Term Loan APR = ' + monthlyAPR);     //Monthly_Interest_Rate__c was introduced in CPQ-696
            Decimal financingTermMonths = (Decimal)sdq.getSObject('Scenario_' + scenarioN + '_Term_Loan__r').get('Financing_Term_Months__c');

            if(!SightenAPIIntegrator.IsSightenScenario(sdq.Id, scenarioN)){
                Decimal denominator = 1 - Math.pow(Double.valueOf(1 + monthlyAPR), Double.valueOf(-1 * financingTermMonths));
                if (denominator != 0){
                    Decimal monthlyPayment = (termLoanAmount * monthlyAPR) / denominator;
                    sdq.put('Scenario_' + scenarioN + '_First_Month_Payment__c', monthlyPayment);
                    saveDetail('', false, scenarioN, 'Term Loan Monthly Payment = ' + monthlyPayment);
                } else {
                    saveDetail('', false, scenarioN, 'Failed to calculate Term Loan Monthly Payment due to division by zero.');
                }
            } else {
                saveDetail('', false, scenarioN, 'Monthly Payment not calculated for this term loan.');
            }
        }
        return termLoanAmount;  //Added for CPQ-675
    }

    private decimal getKilowattFinanceMonthly(integer scenarioN, Financing_Product_Pricing__c fpp, double adjustedPrice, decimal downPayment, double stateRebate, double siteQuality){

        saveDetail('\n', false, scenarioN, 'Get Kilowatt Finance Monthly');

        saveDetail('\n', false, scenarioN, '-- Calculation Variables --');
        decimal q = adjustedPrice / systemSizeW;
        decimal a = fpp.Alpha__c;
        decimal b = ( fpp.Beta__c * downPayment / ( systemSizeW ) ) ;
        decimal g = ( fpp.Gamma__c * stateRebate / ( systemSizeW ) );
        decimal r = ( siteQuality / 1000 );
        decimal d = fpp.Delta__c;
        decimal e = fpp.Epsilon__c;
        saveDetail('', false, scenarioN, '[q] = adjustedPrice / systemSizeW = ' + q);
        saveDetail('', false, scenarioN, '[a] = fpp.Alpha__c = ' + a);
        saveDetail('', false, scenarioN, '[b] = ( fpp.Beta__c * downPayment / ( systemSizeW ) ) = ' + b);
        saveDetail('', false, scenarioN, '[g] = ( fpp.Gamma__c * stateRebate / ( systemSizeW ) ) = ' + g);
        saveDetail('', false, scenarioN, '[r] = ( siteQuality / 1000 ) = ' + r);
        saveDetail('', false, scenarioN, '[d] = fpp.Delta__c = ' + d);
        saveDetail('', false, scenarioN, '[e] = fpp.Epsilon__c = ' + e);

        decimal financeVal = ( ( q - a - b - g ) / r - d ) / e ;
        saveDetail('', false, scenarioN, '[Total Finance Monthly Amount] = ( ( q - a - b - g ) / r - d ) / e = ' + financeVal);

        return financeVal;
    }

    private decimal getKilowattFinancePrepaid(integer scenarioN, Financing_Product_Pricing__c fpp, double adjustedPrice, decimal downPayment, double stateRebate, double siteQuality){

        saveDetail('\n', false, scenarioN, 'Get Kilowatt Finance Prepaid');

        saveDetail('\n', false, scenarioN, '-- Calculation Variables --');
        decimal q = adjustedPrice / systemSizeW;
        decimal a = fpp.Alpha__c;
        decimal b = fpp.Beta__c;
        decimal g = ( fpp.Gamma__c * stateRebate / ( systemSizeW ) );
        decimal r = ( siteQuality / 1000 );
        decimal d = fpp.Delta__c;
        decimal e = fpp.Epsilon__c;
        decimal s = systemSizeW;
        saveDetail('', false, scenarioN, '[q] = adjustedPrice / systemSizeW = ' + q);
        saveDetail('', false, scenarioN, '[a] = fpp.Alpha__c = ' + a);
        saveDetail('', false, scenarioN, '[b] = fpp.Beta__c = ' + b);
        saveDetail('', false, scenarioN, '[g] = ( fpp.Gamma__c * stateRebate / ( systemSizeW ) ) = ' + g);
        saveDetail('', false, scenarioN, '[r] = ( siteQuality / 1000 ) = ' + r);
        saveDetail('', false, scenarioN, '[d] = fpp.Delta__c = ' + d);
        saveDetail('', false, scenarioN, '[e] = fpp.Epsilon__c = ' + e);
        saveDetail('', false, scenarioN, '[s] = systemSizeW = ' + s);
        
        decimal financeVal = ( ( q - a - g - r * ( d + e * 0 ) ) / b ) * s;
        saveDetail('', false, scenarioN, '[Total Finance Prepaid Amount] = ( ( q - a - g - r * ( d + e * 0 ) ) / b ) * s' + financeVal);

        return financeVal;
    }

    public void setLeasePaymentValues(integer scenarioN){
        saveDetail('\n', false, scenarioN, '-----------------------------------');
        saveDetail('', false, scenarioN, 'Calculate the Total Lease Payment Amount');
        saveDetail('', false, scenarioN, '-----------------------------------');

        decimal financingRate = (decimal)sdq.get('Scenario_' + scenarioN + '_Financing_Rate_Year_1_kWh__c');
        double siteQuality = (double)sdq.get('Scenario_' + scenarioN + '_Site_Quality__c');

        saveDetail('\n', false, scenarioN, '--- Calculate the Year 1 Monthly Amount first --- Financing Rate * Site Quality * System Size / 12');
        saveDetail('', false, scenarioN, 'Financing Rate Year 1 ($/kWh): ' + financingRate);
        saveDetail('', false, scenarioN, 'Site Quality: ' + siteQuality);
        saveDetail('', false, scenarioN, 'System Size: ' + systemSizeKW);

        if(siteQuality == null) siteQuality = 0;
        
        double y1MonthlyPayment = financingRate * siteQuality * systemSizeKW / 12;
        saveDetail('', false, scenarioN, 'Total Year 1 Monthly Payment: ' + y1MonthlyPayment);

        saveDetail('\n', false, scenarioN, '--- Calculate the Total Lease Payment ---');
        
        //Get the lease escalator value
        String leaseEscStr = sdq.get('Scenario_' + scenarioN + '_Lease_Escalator__c') != null ? (String)sdq.get('Scenario_' + scenarioN + '_Lease_Escalator__c') : '0';
        if (String.isBlank(leaseEscStr) || leaseEscStr == 'null')
            leaseEscStr = '0';
        Decimal escalator = Decimal.valueOf(leaseEscStr) / 100;
        
        // Get the month of Estimated Operational Start Date
        //decimal proposalTerm = 240;
        Decimal proposalTerm = (Decimal)sdq.get('Scenario_' + scenarioN + '_Proposal_Term_months__c');
        integer month = 0;            
        double thisMonthPayment = 0;
        double totalPaymentValue = 0;
        Decimal esclatorValue = (1 + escalator);
        
        saveDetail('', false, scenarioN, 'Total Year 1 Monthly Payment: ' + y1MonthlyPayment);
        saveDetail('', false, scenarioN, 'Escalator: ' + escalator);
        saveDetail('', false, scenarioN, 'Proposal Term: ' + proposalTerm);
        saveDetail('', false, scenarioN, 'Estimated Start Month: ' + month);

        for(integer i=1; i <= proposalTerm ; i++ )
        {
            System.debug('month ' + month);
            decimal powEscalatorVal = esclatorValue.pow(Math.round(i/12));
            system.debug('Pow Escalator Val: ' + powEscalatorVal);
            thisMonthPayment = y1MonthlyPayment * powEscalatorVal;
            system.debug('This month payment: ' + thisMonthPayment);
            totalPaymentValue += thisMonthPayment;
            month = month + 1;
            if(month == 12) month = 0;
        }

        //Store values back in the SDQ scenario:
        sdq.put('Scenario_' + scenarioN + '_First_Month_Payment__c', y1MonthlyPayment);       
        sdq.put('Scenario_' + scenarioN + '_Total_Monthly_Payments__c', totalPaymentValue);
                
        double downPayment = (double)sdq.get('Scenario_' + scenarioN + '_Down_Payment__c');
        downPayment = downPayment == null ? 0 : downPayment;
        double totalLeasePayments = totalPaymentValue + downPayment;
        
        sdq.put('Scenario_' + scenarioN + '_Total_Lease_Payments__c', totalLeasePayments );

        saveDetail('', false, scenarioN, 'Total Monthly Payments: ' + totalPaymentValue );
        saveDetail('', false, scenarioN, 'Down Payment: ' + downPayment );
        saveDetail('', false, scenarioN, 'Total Lease Payments: ' + totalLeasePayments );
        
    }

    //MK - 2014-03-21
    public void setUpfrontSRECValue(integer scenarioN){
        saveDetail('\n', false, scenarioN, '-----------------------------------');
        saveDetail('', false, scenarioN, 'Get Upfront SREC Value');
        saveDetail('', false, scenarioN, '-----------------------------------');
                
        double upfrontSRECValue = 0;
             
        decimal totalProjectedAnnualOutput = (decimal)sdq.get('Scenario_' + scenarioN + '_Total_Projected_Annual_Output__c');
        Decimal systemSize = (Decimal)sdq.getSObject('System_Design__r').get('Total_System_Size_kW__c');
        
        saveDetail('', false, scenarioN, 'Number of Applied Upfront SRECs across all scenarios: ' + sdq.Available_SREC_Contract_Offers__r.size());

        for(Available_SREC_Contract_Offer__c srec : sdq.Available_SREC_Contract_Offers__r){            
            if(srec.Applicable_Scenario__c == null || srec.Applicable_Scenario__c != string.valueof(scenarioN)) continue; //Not a matching scenario adjustment

            saveDetail('\n', false, scenarioN, 'Upfront SREC matching this scenario: ' + srec.id);
            saveDetail('', false, scenarioN, 'Upfront SREC.Upfront_Amount__c: ' + srec.Upfront_Amount__c);            
            saveDetail('', false, scenarioN, 'This Scenario Total Projected Annual Output (W): ' + totalProjectedAnnualOutput);
            double price = 0;

            //Populate Available SREC Offer.Upfront Effective Dollar Amount equal to Available SREC Offer.Upfront Amount * Scenario N Total Projected Annual Output/1000
            if (srec.Upfront_Amount__c != null){
                if (srec.SREC_Contract_Offer__r.SREC_Earnings_Based_on_KW__c){
                    price = srec.Upfront_Amount__c * systemSize;
                } else {
                    price = srec.Upfront_Amount__c * (totalProjectedAnnualOutput / 1000);
                }
            }

            //Store the effective dollar amount
            upfrontSRECsToUpdateMap.put(srec.id, new Available_SREC_Contract_Offer__c(id = srec.id, Upfront_Effective_Dollar_Amount__c = price));

            //Apply this Upfront SREC to the right category
            if(srec.Contract_Offer_Applied__c) upfrontSRECValue += price;

        }

        //Set individual adjustment fields
        sdq.put('Scenario_' + scenarioN + '_Upfront_SREC_Amount__c', upfrontSRECValue);
        saveDetail('\n', false, scenarioN, '$ Upfront SREC Amount: ' + upfrontSRECValue);
        
        return;
    }

    public Decimal[] srecBuyDown(Integer n, Decimal currentTermLoanAmount){
        Decimal cashPayoutLimit;
        for (Available_SREC_Contract_Offer__c srec : sdq.Available_SREC_Contract_Offers__r){    //Check for the proper SREC Contract Offer type         
            if (srec.Applicable_Scenario__c == String.valueof(n) && srec.SREC_Contract_Offer__r.RecordType.DeveloperName == 'Upfront_Cash_Back' && srec.Contract_Offer_Applied__c){
                cashPayoutLimit = srec.SREC_Contract_Offer__r.Cash_Payout_Limit__c != null ? srec.SREC_Contract_Offer__r.Cash_Payout_Limit__c : 0;
                break;
            }
        }
        if (cashPayoutLimit == null)    //No matching SREC Contract Offer was found
            return null;

        sObject termLoan = sdq.getSObject('Scenario_' + n + '_Term_Loan__r');

        Double assumedEscalator = termLoan.get('Assumed_Utility_Rate_Annual_Escalator__c') != null ? (Double)termLoan.get('Assumed_Utility_Rate_Annual_Escalator__c')/100 : 0.0399;
        Integer savingYears = termLoan.get('Required_Utility_Savings_term__c') != null ? Integer.valueOf((Double)termLoan.get('Required_Utility_Savings_term__c')) : 5;
        Double degradation = 0.005;

        ProposalProcessor pp = new ProposalProcessor();
        
        Decimal beforeTotalCost = 0;
        Decimal beforeBillSum = pp.getSumFromSemicolonDelimitedList(sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Before_Total_Bill__c);
        beforeTotalCost = pp.getTotalOverYears(beforeBillSum, assumedEscalator, savingYears);

        Double totalNetBill = sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Method_1_Net_Bill__c != null ? sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Method_1_Net_Bill__c : 0;


        Decimal nonSolarCost = 0;
        for (Integer y = 0; y < 5; y++){
            nonSolarCost += totalNetBill * (Decimal.valueOf(Math.pow(1 + assumedEscalator, (Double)y))) * (Decimal.valueOf(Math.pow(1 + degradation, (Double)y)));
        }

        Double financingTerm = (Double)sdq.get('Scenario_' + n + '_Proposal_Term_Months__c');

        Boolean refuseACH = (Boolean)sdq.get('Scenario_' + n + '_Refuse_ACH__c'); // default is true, only visible to sighten scenarios, so should always be true for non-sighten
        Double apr = 0.00;
        Double aprPerPeriod = 0.00;

        if(refuseACH){
            apr = termLoan.get('Non_ACH_APR__c') != null ? (Decimal)termLoan.get('Non_ACH_APR__c') / 100 : 0.05;  //CPQ-696
            aprPerPeriod = termLoan.get('Non_ACH_Monthly_Interest_Rate__c') != null ? (Decimal)termLoan.get('Non_ACH_Monthly_Interest_Rate__c') / 100 : apr / 12.0;  //CPQ-696
        } else {
            apr = termLoan.get('APR__c') != null ? (Double)termLoan.get('APR__c') / 100 : 0.05;  //CPQ-696
            aprPerPeriod = termLoan.get('Monthly_Interest_Rate__c') != null ? (Decimal)termLoan.get('Monthly_Interest_Rate__c') / 100 : apr / 12.0;  //CPQ-696
        }

        Decimal requiredUtilitySavings = termLoan.get('Required_Utility_Savings__c') != null ? (Decimal)termLoan.get('Required_Utility_Savings__c') / 100 : 0.05;
        Decimal requiredTotalPayment = ((requiredUtilitySavings * beforeTotalCost) - beforeTotalCost) * -1; //The maximum amount of money one could spend in 5 years to have saved 5% against the BeforeTotalCost.
        Decimal totalMonthlyPayment = requiredTotalPayment - nonSolarCost;  //How much of the previous figure is left to spend on loan payments over 5 years.
        Decimal requiredMonthlyPayment = totalMonthlyPayment / (savingYears * 12);
        Decimal requiredTermLoanAmount = (requiredMonthlyPayment * (1 - Math.pow(1 + aprPerPeriod, -1 * financingTerm))) / aprPerPeriod;    //Maximum principal one could have to pass the savings validations.
        Decimal requiredBuyDown = currentTermLoanAmount - requiredTermLoanAmount;   //The actual principal needs to be reduced by this amount in order to pass the savings validations.
system.debug('**SZ: upfront srec - requiredUtilitySavings = ' + requiredUtilitySavings);
system.debug('**SZ: upfront srec - requiredTotalPayment = ' + requiredTotalPayment);
system.debug('**SZ: upfront srec - totalMonthlyPayment = ' + totalMonthlyPayment);
system.debug('**SZ: upfront srec - requiredMonthlyPayment = ' + requiredMonthlyPayment);
system.debug('**SZ: upfront srec - requiredTermLoanAmount = ' + requiredTermLoanAmount);
system.debug('**SZ: upfront srec - requiredBuyDown = ' + requiredBuyDown);
        //Disbursement of Upfront SREC Value
        Decimal upfrontSrecValue = sdq.get('Scenario_' + n + '_Upfront_SREC_Amount__c') != null ? (Decimal)sdq.get('Scenario_' + n + '_Upfront_SREC_Amount__c') : 0;
        Decimal savingsValidationAdjustment = Math.max(Math.min(upfrontSrecValue, requiredBuyDown), 0);  //Reduce Term Loan amount so it passes savings requirements
        Decimal customerCashPayout = Math.max(Math.min(upfrontSrecValue - savingsValidationAdjustment, cashPayoutLimit), 0);   //Give the customer a check
        sdq.put('Scenario_' + n + '_SREC_Cash_Back__c', customerCashPayout);
        Decimal remainingTermLoanAdjustment = Math.max(upfrontSrecValue - savingsValidationAdjustment - customerCashPayout, 0);  //Put the rest of the money towards reducing the Term Loan
system.debug('**SZ: upfront srec - upfrontSrecValue = ' + upfrontSrecValue);
system.debug('**SZ: upfront srec - savingsValidationAdjustment = ' + savingsValidationAdjustment);
system.debug('**SZ: upfront srec - customerCashPayout = ' + customerCashPayout);
system.debug('**SZ: upfront srec - remainingTermLoanAdjustment = ' + remainingTermLoanAdjustment);

        Decimal totalReductionOfTermLoan = savingsValidationAdjustment + remainingTermLoanAdjustment;
system.debug('**SZ: upfront srec - totalReductionOfTermLoan = ' + totalReductionOfTermLoan);

        return new Decimal[]{savingsValidationAdjustment, totalReductionOfTermLoan};
    }

    public Decimal getFixedRatePPA(Decimal systemSizekW, Decimal nonPanelDesignPrice, Decimal trenchingTableValue, Decimal ineligibilityThreshold, Decimal sizeThreshold, 
                                    Decimal sizeAdder, Decimal highPPA_rateThreshold, Decimal highPPA_rateAdder, Decimal basePPA_rate, Integer scenarioN){
        saveDetail('\n', false, scenarioN, '-----------------------------------');
        saveDetail('', false, scenarioN, 'Fixed-Rate PPA');
        saveDetail('', false, scenarioN, '-----------------------------------');
        Decimal systemSizeW = systemSizekW * 1000;
        Decimal costOfSelectedAdders = (nonPanelDesignPrice + trenchingTableValue) / systemSizeW;
        saveDetail('', false, scenarioN, 'Cost of Selected Adders: (Non-panel Design Price + Trenching Table Value) / System Size (W) = (' + 
                    nonPanelDesignPrice + ' + ' + trenchingTableValue + ') / ' + systemSizeW + ' = ' + costOfSelectedAdders.setScale(2));

        if (ineligibilityThreshold != null && costOfSelectedAdders > ineligibilityThreshold){
            saveDetail('', false, scenarioN, 'Error: This system is ineligible for a Fixed-Rate PPA due to required special parts, mounting, or trenching. Please refer the customer to our sales team to learn about other financing options.');
            return null;
        } else {
            sizeThreshold = sizeThreshold != null ? sizeThreshold : 0;
            highPPA_rateThreshold = highPPA_rateThreshold != null ? highPPA_rateThreshold : 0;
            
            sizeAdder = sizeAdder != null ? sizeAdder : 0;
            if (systemSizekW <= sizeThreshold)
                sizeAdder = 0;
        
            highPPA_rateAdder = highPPA_rateAdder != null ? highPPA_rateAdder : 0;
            if (costOfSelectedAdders <= highPPA_rateThreshold)
                highPPA_rateAdder = 0;

            basePPA_rate = basePPA_rate != null ? basePPA_rate : 0;
            Decimal calcPPA_rate = basePPA_rate + sizeAdder + highPPA_rateAdder;

            saveDetail('', false, scenarioN, 'Calculated PPA Rate: Base PPA Rate + Size Adder + High PPA Rate Adder = ' + 
                        basePPA_rate + ' + ' + sizeAdder + ' + ' + highPPA_rateAdder + ' = ' + calcPPA_rate);
                        
            return calcPPA_rate;
        }
    }

    //MK - 2014-07-23
    //Method to track the detail of pricing for each scenario
    public void saveDetail(string prefix, boolean isSDQError, integer scenarioN, string message){
        
        //Add indentation to line for readability
        message = prefix + '- ' + message;

        if(isSDQError){
            isError = true;
            //Write to error log
            String logErr = (string)sdq.get('Scenario_' + scenarioN + '_Error_Log__c');
            if(logErr == null) logErr = message;
            else logErr = logErr + '\n' + message;
            sdq.put('Scenario_' + scenarioN + '_Error_Log__c', logErr);
            system.debug('***Scenario ' + scenarioN + ' ERROR: ' + message);
        }else{
            system.debug('***Scenario ' + scenarioN + ': ' + message);
        }

        //Pull the current log
        String logStr = (string)sdq.get('Scenario_' + scenarioN + '_Detail_Log__c');
    
        //Set beginning of log
        if(logStr == null || logStr == '') logStr = 'Detail Log: Begin';
        else if(logStr.length() > 30000) return; //Log too big, return
        
        //Add the message to the log
        logStr = logStr + '\n' + message;
        
        //Truncate the log if it's too long
        if(logStr.length() > 30000) logStr = logStr.left(30000) + '\n\n\n|TRUNCATING LOG, Close to exceeding field length....';

        //Save the detail
        sdq.put('Scenario_' + scenarioN + '_Detail_Log__c', logStr);
    }
    
}