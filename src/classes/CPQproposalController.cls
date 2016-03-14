/*
    12/17/14  DK  Initialized constructor and public Proposal, SDQ, and SD objects
    07/08/15  DK  The array size of the "Total Annual Payments" table column will now adhere to the term length of that scenario's Term Loan. See CPQ-606.
    09/23/15  DK  Relayed SREC Buy Down information to the page. CPQ-675.
    11/19/15  DK  Conditional formatting of cash flow tables for Feed In Tariff. CPQ-731.
*/
public with sharing class CPQproposalController { 
    
    public Proposal__c prop {get; set;}
    public System_Design_Quote__c sdq {get; set;}
    public System_Design__c sysDesign {get; set;}
    public System_Design_Product__c sdProd {get; set;}
    public Contact con {get; set;}
    public User usr {get; set;}  //The Sales Consultant
    public Rate_Period__c currentRatePeriod {get; set;}
    public Rate_Period__c newRatePeriod {get; set;}

    public ScenarioData[] scenarios {get; set;}     //Encapsulate scenario-specific data
    public List< List<String> > overviewTable {get; set;}     //Info columns
    public Boolean isD2D {get; set;}
    
    private String[] monthNames = new String[] {'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'};
    private Map<Integer, Integer> scenarioTermYears = new Map<Integer, Integer>();     //Scenario number --> ceiling(term months/12)
    private ProposalProcessor pp; 
    private Available_Incentive_Offer__c[] incentiveOffers;
    private Price_Adjustment__c[] priceAdjusts;
    private Available_SREC_Contract_Offer__c[] srecOffers;
    private System_Design_Item__c[] sdItems;

    public CPQproposalController(){      
                        
        String propID = ApexPages.currentPage().getParameters().get('id');
        if (String.isBlank(propID)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Proposal ID not found'));
            return;
        }
        try {
            prop = [SELECT Name, Annual_Power_Price_Escalator__c, System_Design_Quote__c, Proposal_Expiration_Date__c, Scenario_1_Year1_Avg_Mthly_SREC_Earnings__c, Scenario_2_Year1_Avg_Mthly_SREC_Earnings__c, 
                    Scenario_3_Year1_Avg_Mthly_SREC_Earnings__c, Scenario_4_Year1_Avg_Mthly_SREC_Earnings__c, Scenario_1_Year1_Total_Monthly_Earnings__c, Scenario_2_Year1_Total_Monthly_Earnings__c, 
                    Scenario_3_Year1_Total_Monthly_Earnings__c, Scenario_4_Year1_Total_Monthly_Earnings__c, Proposal_Discount_Rate__c, Scenario_1_Proposal_Term_months__c, Scenario_2_Proposal_Term_months__c, 
                    Scenario_3_Proposal_Term_months__c, Scenario_4_Proposal_Term_months__c, Estimated_Operational_Start_Date__c, Scenario_1_Estimated_Operational_Start_D__c, Scenario_2_Estimated_Operational_Start_D__c, 
                    Scenario_3_Estimated_Operational_Start_D__c, Scenario_4_Estimated_Operational_Start_D__c, Scenario_1_Year1_Mthly_Uty_Bill_Before__c, Scenario_2_Year1_Mthly_Uty_Bill_Before__c, 
                    Scenario_3_Year1_Mthly_Uty_Bill_Before__c, Scenario_4_Year1_Mthly_Uty_Bill_Before__c, Scenario_1_Year1_Mthly_Uty_Bill_After__c, Scenario_2_Year1_Mthly_Uty_Bill_After__c, 
                    Scenario_3_Year1_Mthly_Uty_Bill_After__c, Scenario_4_Year1_Mthly_Uty_Bill_After__c, Scenario_1_Year1_Mthly_Uty_Bill_Savings__c, Scenario_2_Year1_Mthly_Uty_Bill_Savings__c, 
                    Scenario_3_Year1_Mthly_Uty_Bill_Savings__c, Scenario_4_Year1_Mthly_Uty_Bill_Savings__c, Scenario_1_Year1_Annual_Uty_Bill_Before__c, Scenario_2_Year1_Annual_Uty_Bill_Before__c, 
                    Scenario_3_Year1_Annual_Uty_Bill_Before__c, Scenario_4_Year1_Annual_Uty_Bill_Before__c, Scenario_1_Year1_Annual_Uty_Bill_After__c, Scenario_2_Year1_Annual_Uty_Bill_After__c, 
                    Scenario_3_Year1_Annual_Uty_Bill_After__c, Scenario_4_Year1_Annual_Uty_Bill_After__c, Scenario_1_Annual_Degradation_Factor__c, Scenario_2_Annual_Degradation_Factor__c, 
                    Scenario_3_Annual_Degradation_Factor__c, Scenario_4_Annual_Degradation_Factor__c, Scenario_1_Production_Guarantee__c, Scenario_2_Production_Guarantee__c, Scenario_3_Production_Guarantee__c, 
                    Scenario_4_Production_Guarantee__c, Scenario_1_Cumulative_Guaranteed_Prod__c, Scenario_2_Cumulative_Guaranteed_Prod__c, Scenario_3_Cumulative_Guaranteed_Prod__c, Scenario_4_Cumulative_Guaranteed_Prod__c,
                    Scenario_1_Financing_Plan__c, Scenario_2_Financing_Plan__c, Scenario_3_Financing_Plan__c, Scenario_4_Financing_Plan__c, Scenario_1_Included__c, Scenario_2_Included__c, Scenario_3_Included__c, 
                    Scenario_4_Included__c, Scenario_1_Rate_of_Return__c, Scenario_2_Rate_of_Return__c, Scenario_3_Rate_of_Return__c, Scenario_4_Rate_of_Return__c, Scenario_1_Cash_Payback__c, Scenario_2_Cash_Payback__c, 
                    Scenario_3_Cash_Payback__c, Scenario_4_Cash_Payback__c, Scenario_1_Payment_Due_Signing__c, Scenario_2_Payment_Due_Signing__c, Scenario_3_Payment_Due_Signing__c, Scenario_4_Payment_Due_Signing__c, 
                    Scenario_1_Payment_Due_Installation__c, Scenario_2_Payment_Due_Installation__c, Scenario_3_Payment_Due_Installation__c, Scenario_4_Payment_Due_Installation__c, Scenario_1_Payment_Due_Final_Inspection__c, 
                    Scenario_2_Payment_Due_Final_Inspection__c, Scenario_3_Payment_Due_Final_Inspection__c, Scenario_4_Payment_Due_Final_Inspection__c, Scenario_1_Year_1_Monthly_Solar_Payment__c, 
                    Scenario_2_Year_1_Monthly_Solar_Payment__c, Scenario_3_Year_1_Monthly_Solar_Payment__c, Scenario_4_Year_1_Monthly_Solar_Payment__c, Scenario_1_Solar_Electric_Rate__c, Scenario_2_Solar_Electric_Rate__c, 
                    Scenario_3_Solar_Electric_Rate__c, Scenario_4_Solar_Electric_Rate__c, Scenario_1_FIT_Annual_Earnings_After_Tax__c, Scenario_2_FIT_Annual_Earnings_After_Tax__c, Scenario_3_FIT_Annual_Earnings_After_Tax__c, 
                    Scenario_4_FIT_Annual_Earnings_After_Tax__c, Scenario_1_FIT_Term_Length_Months__c, Scenario_2_FIT_Term_Length_Months__c, Scenario_3_FIT_Term_Length_Months__c, Scenario_4_FIT_Term_Length_Months__c 
                    FROM Proposal__c WHERE ID = :propID LIMIT 1];  
            
            sdq = [SELECT Name, System_Design__c, System_Size_kW__c, Panel_Count__c, Scenario_1_Financing_Rate_Year_1_kWh__c, Scenario_2_Financing_Rate_Year_1_kWh__c, Scenario_3_Financing_Rate_Year_1_kWh__c, 
                   Scenario_4_Financing_Rate_Year_1_kWh__c, Total_Projected_Annual_Output__c, Scenario_1_Lease_Escalator__c, Scenario_2_Lease_Escalator__c, Scenario_3_Lease_Escalator__c, Scenario_4_Lease_Escalator__c, 
                   Scenario_1_Financing_Monthly_Pmt_Year_1__c, Scenario_2_Financing_Monthly_Pmt_Year_1__c, Scenario_3_Financing_Monthly_Pmt_Year_1__c, Scenario_4_Financing_Monthly_Pmt_Year_1__c, 
                   Scenario_1_Design_Override_Price__c, Scenario_2_Design_Override_Price__c, Scenario_3_Design_Override_Price__c, Scenario_4_Design_Override_Price__c, Scenario_1_Financing_Type__c, 
                   Scenario_2_Financing_Type__c, Scenario_3_Financing_Type__c, Scenario_4_Financing_Type__c, Scenario_1_Final_EPC_Price_NUM__c, Scenario_2_Final_EPC_Price_NUM__c, Scenario_3_Final_EPC_Price_NUM__c, 
                   Scenario_4_Final_EPC_Price_NUM__c, Scenario_1_State_Rebate_Amount__c, Scenario_2_State_Rebate_Amount__c, Scenario_3_State_Rebate_Amount__c, Scenario_4_State_Rebate_Amount__c, Astrum_Overall_Site_Quality__c, 
                   Scenario_1_Utility_Rebate_Amount__c, Scenario_2_Utility_Rebate_Amount__c, Scenario_3_Utility_Rebate_Amount__c, Scenario_4_Utility_Rebate_Amount__c, Scenario_1_Federal_Tax_Credit_Amount__c, 
                   Scenario_2_Federal_Tax_Credit_Amount__c, Scenario_3_Federal_Tax_Credit_Amount__c, Scenario_4_Federal_Tax_Credit_Amount__c, Scenario_1_State_Tax_Credit_Amount__c, Scenario_2_State_Tax_Credit_Amount__c, 
                   Scenario_3_State_Tax_Credit_Amount__c, Scenario_4_State_Tax_Credit_Amount__c, Scenario_1_Local_Tax_Credit_Amount__c, Scenario_2_Local_Tax_Credit_Amount__c, Scenario_3_Local_Tax_Credit_Amount__c, 
                   Scenario_4_Local_Tax_Credit_Amount__c, Pricing_Date__c, Option_1_Monthly_Payment_Year_10__c, Option_1_Monthly_Payment_Year_11__c, Option_1_Monthly_Payment_Year_12__c, Option_1_Monthly_Payment_Year_13__c, 
                   Option_1_Monthly_Payment_Year_14__c, Option_1_Monthly_Payment_Year_15__c, Option_1_Monthly_Payment_Year_16__c, Option_1_Monthly_Payment_Year_17__c, Option_1_Monthly_Payment_Year_18__c, 
                   Option_1_Monthly_Payment_Year_19__c, Option_1_Monthly_Payment_Year_2__c, Option_1_Monthly_Payment_Year_20__c, Option_1_Monthly_Payment_Year_3__c, Option_1_Monthly_Payment_Year_4__c, 
                   Option_1_Monthly_Payment_Year_5__c, Option_1_Monthly_Payment_Year_6__c, Option_1_Monthly_Payment_Year_7__c, Option_1_Monthly_Payment_Year_8__c, Option_1_Monthly_Payment_Year_9__c, 
                   Scenario_1_Net_Initial_Outlay__c, Scenario_2_Net_Initial_Outlay__c, Scenario_3_Net_Initial_Outlay__c, Scenario_4_Net_Initial_Outlay__c, Option_1_Production_Guarantee_Year_1__c, 
                   Option_1_Production_Guarantee_Year_2__c, Option_1_Production_Guarantee_Year_3__c, Option_1_Production_Guarantee_Year_4__c, Option_1_Production_Guarantee_Year_5__c, Option_1_Production_Guarantee_Year_6__c, 
                   Option_1_Production_Guarantee_Year_7__c, Option_1_Production_Guarantee_Year_8__c, Option_1_Production_Guarantee_Year_9__c, Option_1_Production_Guarantee_Year_10__c, Option_1_Production_Guarantee_Year_11__c, 
                   Option_1_Production_Guarantee_Year_12__c, Option_1_Production_Guarantee_Year_13__c, Option_1_Production_Guarantee_Year_14__c, Option_1_Production_Guarantee_Year_15__c, Option_1_Production_Guarantee_Year_16__c, 
                   Option_1_Production_Guarantee_Year_17__c, Option_1_Production_Guarantee_Year_18__c, Option_1_Production_Guarantee_Year_19__c, Option_1_Production_Guarantee_Year_20__c, 
                   Scenario_1_Avoided_Utility_Rate__c, Scenario_2_Avoided_Utility_Rate__c, Scenario_3_Avoided_Utility_Rate__c, Scenario_4_Avoided_Utility_Rate__c, Scenario_1_Included_in_Proposal__c, 
                   Scenario_2_Included_in_Proposal__c, Scenario_3_Included_in_Proposal__c, Scenario_4_Included_in_Proposal__c, Scenario_1_Prepaid_Financing_Amount__c, Scenario_2_Prepaid_Financing_Amount__c, 
                   Scenario_3_Prepaid_Financing_Amount__c, Scenario_4_Prepaid_Financing_Amount__c, Scenario_1_Term_Loan__r.Financing_Term_Months__c, Scenario_2_Term_Loan__r.Financing_Term_Months__c, 
                   Scenario_3_Term_Loan__r.Financing_Term_Months__c, Scenario_4_Term_Loan__r.Financing_Term_Months__c, Scenario_1_SAC_Loan__r.Financing_Term_Months__c, Scenario_2_SAC_Loan__r.Financing_Term_Months__c, 
                   Scenario_3_SAC_Loan__r.Financing_Term_Months__c, Scenario_4_SAC_Loan__r.Financing_Term_Months__c, Scenario_1_Down_Payment__c, Scenario_2_Down_Payment__c, Scenario_3_Down_Payment__c, Scenario_4_Down_Payment__c, 
                   Scenario_1_First_Month_Payment__c, Scenario_2_First_Month_Payment__c, Scenario_3_First_Month_Payment__c, Scenario_4_First_Month_Payment__c, 
                   Scenario_1_Total_Projected_Annual_Output__c,Scenario_2_Total_Projected_Annual_Output__c,Scenario_3_Total_Projected_Annual_Output__c,Scenario_4_Total_Projected_Annual_Output__c, 
                   Scenario_1_Line_Item_Top_Line_Adjustment__c,Scenario_2_Line_Item_Top_Line_Adjustment__c,Scenario_3_Line_Item_Top_Line_Adjustment__c,Scenario_4_Line_Item_Top_Line_Adjustment__c, 
                   Scenario_1_Total_Net_Adjustment__c, Scenario_2_Total_Net_Adjustment__c, Scenario_3_Total_Net_Adjustment__c, Scenario_4_Total_Net_Adjustment__c, 
                   Scenario_1_Upfront_SREC_Amount__c, Scenario_2_Upfront_SREC_Amount__c, Scenario_3_Upfront_SREC_Amount__c, Scenario_4_Upfront_SREC_Amount__c, 
                   Scenario_1_SREC_Cash_Back__c, Scenario_2_SREC_Cash_Back__c, Scenario_3_SREC_Cash_Back__c, Scenario_4_SREC_Cash_Back__c, Scenario_1_SREC_Contract_Discount__c, Scenario_2_SREC_Contract_Discount__c, 
                   Scenario_3_SREC_Contract_Discount__c, Scenario_4_SREC_Contract_Discount__c, Community_Program_Offer__r.RecordType.DeveloperName 
                   FROM System_Design_Quote__c WHERE ID = :prop.System_Design_Quote__c LIMIT 1];
            
            sysDesign = [SELECT Property__r.Property_Owner__r.Name, Property__r.Name, Property__r.Property_City__c, Property__r.Property_State__c, Property__r.Property_ZIP__c, Property__r.Property_County__c, 
                        Property__r.RecordType.Name, Property__r.Astrum_Office_New__r.Street__c, Property__r.Astrum_Office_New__r.City__c, Property__r.Astrum_Office_New__r.State__c, Property__r.Astrum_Office_New__r.Zip_Code__c, 
                        Panel_Count__c, Total_System_Size_kW__c, Overall_Site_Quality__c, Total_Projected_Annual_Output_kWh_y__c, Default_CB_Panel__r.Utility_Service__r.Before_Total_Bill__c, 
                        Default_CB_Panel__r.Utility_Service__r.Method_1_Net_Bill__c, Default_CB_Panel__r.Utility_Service__r.Before_First_Year_Avg_Price__c, Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Name, 
                        Default_CB_Panel__r.Utility_Service__r.Net_First_Year_Avg_Price__c, Default_CB_Panel__r.Utility_Service__r.Annual_Electricity_Consumption_kWh_frm__c, 
                        Default_CB_Panel__r.Utility_Service__r.Utility_Value_of_Solar_Tariff__c, Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_After_Solar__c, Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_Before_Solar__c, 
                        Method_1_Jan_Peak_kWh__c,  Method_1_Feb_Peak_kWh__c, Method_1_Mar_Peak_kWh__c, Method_1_Apr_Peak_kWh__c, Method_1_May_Peak_kWh__c, Method_1_Jun_Peak_kWh__c, Method_1_Jul_Peak_kWh__c, 
                        Method_1_Aug_Peak_kWh__c, Method_1_Sep_Peak_kWh__c, Method_1_Oct_Peak_kWh__c, Method_1_Nov_Peak_kWh__c, Method_1_Dec_Peak_kWh__c, Method_1_Jan_Part_Peak_kWh__c, Method_1_Feb_Part_Peak_kWh__c, 
                        Method_1_Mar_Part_Peak_kWh__c, Method_1_Apr_Part_Peak_kWh__c, Method_1_May_Part_Peak_kWh__c, Method_1_Jun_Part_Peak_kWh__c, Method_1_Jul_Part_Peak_kWh__c, Method_1_Aug_Part_Peak_kWh__c, 
                        Method_1_Sep_Part_Peak_kWh__c, Method_1_Oct_Part_Peak_kWh__c, Method_1_Nov_Part_Peak_kWh__c, Method_1_Dec_Part_Peak_kWh__c, Method_1_Jan_Off_Peak_kWh__c, Method_1_Feb_Off_Peak_kWh__c, 
                        Method_1_Mar_Off_Peak_kWh__c, Method_1_Apr_Off_Peak_kWh__c, Method_1_May_Off_Peak_kWh__c, Method_1_Jun_Off_Peak_kWh__c, Method_1_Jul_Off_Peak_kWh__c, Method_1_Aug_Off_Peak_kWh__c, 
                        Method_1_Sep_Off_Peak_kWh__c, Method_1_Oct_Off_Peak_kWh__c, Method_1_Nov_Off_Peak_kWh__c, Method_1_Dec_Off_Peak_kWh__c, Method_1_Jan_Flat_kWh__c, Method_1_Feb_Flat_kWh__c, Method_1_Mar_Flat_kWh__c, 
                        Method_1_Apr_Flat_kWh__c, Method_1_May_Flat_kWh__c, Method_1_Jun_Flat_kWh__c, Method_1_Jul_Flat_kWh__c, Method_1_Aug_Flat_kWh__c, Method_1_Sep_Flat_kWh__c, Method_1_Oct_Flat_kWh__c, 
                        Method_1_Nov_Flat_kWh__c, Method_1_Dec_Flat_kWh__c ,Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh__c,Default_CB_Panel__r.Utility_Service__r.Method_1_Avoided_Utility_Rate__c, 
                        Default_CB_Panel__r.Utility_Service__r.Method_1_Net_Savings__c 
                        FROM System_Design__c WHERE ID = :sdq.System_Design__c LIMIT 1];

            isD2D = false;  //default
            if (sdq.Community_Program_Offer__c != null && sdq.Community_Program_Offer__r.RecordType.DeveloperName == 'Door_to_Door')
              isD2D = true;

            usr = [SELECT Consultant_Motto__c, ConsultantBio__c, Consultant_Landing_Page__c, FullPhotoUrl FROM User WHERE User.ID = :UserInfo.getUserId() LIMIT 1];

            //Get Available Incentive Offers
            incentiveOffers = [SELECT Customer_Description__c, Applicable_Scenario__c, Effective_Dollar_Amount__c, Payment_Date_Type__c, Estimated_Payment_Month__c, 
                               Estimated_Payment_Year_Offset__c, Estimated_Days_to_Payment__c FROM Available_Incentive_Offer__c 
                               WHERE System_Design_Quote__c = :sdq.ID AND Apply_Effective_Price__c = true AND Applicable_Scenario__c != null LIMIT 10000];
            if (incentiveOffers.isEmpty())
                incentiveOffers = new Available_Incentive_Offer__c[]{};
            
            //Get Price Adjustments
            priceAdjusts = [SELECT Entitlement_Offer__r.Name, Promotion__r.Name, Applicable_Scenario__c, Effective_Dollar_Amount__c FROM Price_Adjustment__c 
                            WHERE System_Design_Quote__c = :sdq.ID AND (Entitlement_Offer__c != null OR Promotion__c != null) AND Adjustment_Applied__c = true AND Applicable_Scenario__c != null LIMIT 10000];
            if (priceAdjusts.isEmpty())
                priceAdjusts = new Price_Adjustment__c[]{};

            //Get Available SREC Contract Offers
            srecOffers = [SELECT SREC_Contract_Offer__r.Name, Upfront_Effective_Dollar_Amount__c, Name, Applicable_Scenario__c, SREC_Contract_Offer__r.RecordTypeDeveloperName__c, SREC_Contract_Offer__r.SREC_Market__r.Payment_Month__c FROM Available_SREC_Contract_Offer__c 
                          WHERE System_Design_Quote__c = :sdq.ID AND Applicable_Scenario__c != null AND Contract_Offer_Applied__c = true LIMIT 10000];
            if (srecOffers.isEmpty())
                srecOffers = new Available_SREC_Contract_Offer__c[]{};        
            
            //Get System Design Products (through System Design Items)
            sdItems = [SELECT System_Design_Product__r.Description__c, System_Design_Product__r.Rated_Output_W__c, System_Design_Product__r.RecordType.DeveloperName, RecordType.DeveloperName 
                       FROM System_Design_Item__c WHERE System_Design_Array__r.System_Design__c = :sysDesign.ID AND Quantity__c > 0 AND System_Design_Product__c != null LIMIT 10000];
            if (sdItems.isEmpty())
                sdItems = new System_Design_Item__c[]{};

            //Get Tier Rates for the utility bill chart keys
            currentRatePeriod = new Rate_Period__c();
            newRatePeriod = new Rate_Period__c();
            ID newRateCode = sysDesign.Default_CB_Panel__r.Utility_Service__r.Utility_Value_of_Solar_Tariff__c != null ? sysDesign.Default_CB_Panel__r.Utility_Service__r.Utility_Value_of_Solar_Tariff__c : sysDesign.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_After_Solar__c;
            for (Rate_Period__c rp : [SELECT Utility_Company__c, Tier_1_Rate_kWh__c, Tier_2_Rate_kWh__c, Tier_3_Rate_kWh__c, Tier_4_Rate_kWh__c, Tier_5_Rate_kWh__c FROM Rate_Period__c 
                                      WHERE (Utility_Company__c = :sysDesign.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_Before_Solar__c OR Utility_Company__c = :newRateCode) 
                                      AND Tier_1_Rate_kWh__c != null ORDER BY CreatedDate DESC LIMIT 50]){
                if (rp.Utility_Company__c == sysDesign.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_Before_Solar__c)
                    currentRatePeriod = rp;
                if (rp.Utility_Company__c == newRateCode)
                    newRatePeriod = rp;

                if (currentRatePeriod != null && newRatePeriod != null)
                    break;
            }
            
            con = [SELECT Name FROM Contact WHERE AccountID = :sysDesign.Property__r.Property_Owner__c LIMIT 1];

            pp = new ProposalProcessor();

            scenarios = new List<ScenarioData>();
            
            List< List<String> > overviewTemp = new List< List<String> >();
            overviewTable = new List< List<String> >();
            
            String utilCompanyName = sysDesign.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Name;
            if (utilCompanyName == null)
                utilCompanyName = 'Utility Company';
            
            String[] overviewLabels = new String[]{
                '',
                '',
                'Electric Rate',
                'Annual Increase',
                'Utility Bill',
                'Monthly Solar Payment',
                'New Combined Bill',
                'Monthly Savings',
                'Upfront Payment',
                'Cash Benefit over 20 Years',
                'Rate of Return'
            };
             
            String[] noSolarCol = new String[]{'', 'No Solar'};
            noSolarCol.add(displayCash(sysDesign.Default_CB_Panel__r.Utility_Service__r.Before_First_Year_Avg_Price__c));
            noSolarCol.add(prop.Annual_Power_Price_Escalator__c != null ? prop.Annual_Power_Price_Escalator__c + '%' : 'N/A');
            //noSolarCol.add('X');
            noSolarCol.add(getMonthlyAvgBill_Current());
            noSolarCol.add('X');
            noSolarCol.add('$ -');
            noSolarCol.add('None');
            noSolarCol.add('None');
            noSolarCol.add('N/A');
            noSolarCol.add('N/A');
            
            overviewTemp.add(overviewLabels);
            overviewTemp.add(noSolarCol);
            
            for (Integer i = 1; i <= 4; i++){
                
                if (prop.get('Scenario_' + i + '_Proposal_Term_months__c') == null)
                    continue;   //Skip this scenario is there's no proposal term
                
                scenarioTermYears.put(i, Integer.valueOf(Math.ceil((Decimal)prop.get('Scenario_' + i + '_Proposal_Term_months__c')/12.0)));

                if ((Boolean)prop.get('Scenario_' + i + '_Included__c')){
                    
                    ScenarioData sd;
                    String financingPlan = (String)prop.get('Scenario_' + i + '_Financing_Plan__c');
                    String initOutlay = displayCash(-1 * Math.abs(nullDecimal(sdq.get('Scenario_' + i + '_Net_Initial_Outlay__c'), 0)));

                    Decimal afterTotalBill = sysDesign.Default_CB_Panel__r.Utility_Service__r.Method_1_Net_Bill__c != null ? sysDesign.Default_CB_Panel__r.Utility_Service__r.Method_1_Net_Bill__c : 0;
                    Decimal monthlyCashFlow = -1;
                    try {
                      monthlyCashFlow = (getNetSavingsNum(1).get(0) + pp.getAnnualSrecEarnings(prop, sdq, i, Integer.valueOf(prop.get('Scenario_' + i + '_Proposal_Term_months__c'))).get(0)) / 12.0;
                    } catch (Exception e){}
                    Decimal monthlyEarnings = -1;
                    try {
                      monthlyEarnings = getNetSavingsNum(1).get(0) / 12.0;
                    } catch (Exception e){}

                    Decimal combinedBill = 0;
                    try {
                      //System.debug(loggingLevel.ERROR,'Combinedbill:utilbill:' + (afterTotalBill / 12.0) + (Decimal)sdq.get('Scenario_' + i + '_First_Month_Payment__c'));
                      if(sdq.get('Scenario_' + i + '_First_Month_Payment__c') == null){
                          combinedBill = afterTotalBill / 12.0;
                        }else{
                          combinedBill = (Decimal)sdq.get('Scenario_' + i + '_First_Month_Payment__c') + (afterTotalBill / 12.0);
                        }                      
                    } catch (Exception e){}
                    Decimal monthlySaving = (pp.getAverageFromSemicolonDelimitedList(sysDesign.Default_CB_Panel__r.Utility_Service__r.Before_Total_Bill__c)) - combinedBill;

                    String rateOfReturn = String.valueOf(nullDecimal((Decimal)prop.get('Scenario_' + i + '_Rate_of_Return__c'), -1).setScale(1)) + '%';
                    if (rateOfReturn == '-1.0%')
                      rateOfReturn = 'N/A';

                    Decimal solarElectricRate = (Decimal)prop.get('Scenario_' + i + '_Solar_Electric_Rate__c');

                    String[] overviewCol = new String[]{''};
                    overviewCol.add(financingPlan != 'Solar Purchase Plan' ? financingPlan : 'Solar Ownership Plan');
                    overviewCol.add(solarElectricRate != null ? '$' + solarElectricRate.setScale(4) : '$-');
                    overviewCol.add(getLeaseEscalator(i) + '%');
                    overviewCol.add(getMonthlyAvgBill_New());
                    overviewCol.add(displayCash((Decimal)sdq.get('Scenario_' + i + '_First_Month_Payment__c')));
                    //overviewCol.add(displayCash(monthlyCashFlow));
                    overviewCol.add(displayCash(combinedBill));
                    overviewCol.add(displayCash(monthlySaving));                    
                    //overviewCol.add(displayCash((Decimal)prop.get('Scenario_' + i + '_Year1_Total_Monthly_Earnings__c')));
                    overviewCol.add(initOutlay);
                    overviewCol.add(displayCash(getCashBenefitOver20Years(i)));  //overviewCol.add(String.valueOf(nullDecimal((Decimal)prop.get('Scenario_' + i + '_Cash_Payback__c'), 0)));
                    overviewCol.add(rateOfReturn);
                    
                    if (financingPlan == 'Solar Purchase Plan'){
                        sd = new ScenarioData(i);
                        sd.pageTitle = 'Solar Ownership Plan';
                        sd.planType = 0;
                        
                        Decimal endCost = nullDecimal(sdq.get('Scenario_' + i + '_Design_Override_Price__c'), 0) + nullDecimal(sdq.get('Scenario_' + i + '_Line_Item_Top_Line_Adjustment__c'), 0);
                        sd.table1.add(new DataPairing('Total Cost', displayCash(endCost)));
                        for (Price_Adjustment__c pa : getPromotionsForScenario(i)){
                            Decimal dollarAmount = nullDecimal(pa.Effective_Dollar_Amount__c, 0);
                            sd.table1.add(new DataPairing(pa.Promotion__r.Name, displayCash(dollarAmount * -1 )));
                        }
                        for (Available_Incentive_Offer__c aio : getIncentiveOffersForScenario(i)){
                            Decimal dollarAmount = nullDecimal(aio.Effective_Dollar_Amount__c, 0);
                            if (dollarAmount != 0)
                              sd.table1.add(new DataPairing(aio.Customer_Description__c, displayCash(dollarAmount)));
                        }
                        

                        sd.summaryTable.add(new DataPairing(sd.pageTitle, ''));
                        for (Available_Incentive_Offer__c aio : getIncentiveOffersForScenario(i)){
                            Date d;
                            if (aio.Payment_Date_Type__c == 'Fixed'){
                                Integer year = Date.valueOf(prop.get('Scenario_' + i + '_Estimated_Operational_Start_D__c')).year() + (Integer)nullDecimal(aio.Estimated_Payment_Year_Offset__c, 0);
                                Integer month = (Integer)aio.Estimated_Payment_Month__c;
                                if (month == null || month == 0)
                                    month = 1;
                                d = Date.newInstance(year, month, 1);
                            } else if (aio.Payment_Date_Type__c == 'Floating'){
                              if (sdq.Pricing_Date__c != null){
                                d = Date.valueOf(sdq.Pricing_Date__c).addDays((Integer)nullDecimal(aio.Estimated_Days_to_Payment__c, 0));
                              }
                            }
                            String dateStr = d != null ? d.format() : 'To Be Determined';
                            sd.summaryTable.add(new DataPairing(aio.Customer_Description__c + ' Timing', dateStr));
                        }
                        for (Available_SREC_Contract_Offer__c srec : getSrecOffersForScenario(i)){
                            sd.summaryTable.add(new DataPairing('SREC Purchase Option', srec.SREC_Contract_Offer__r.RecordTypeDeveloperName__c));
                            String timing = 'Please Inquire';   //Should always be overwritten
                            if (srec.SREC_Contract_Offer__r.RecordTypeDeveloperName__c == 'Yearly'){
                                Integer month = (Integer)srec.SREC_Contract_Offer__r.SREC_Market__r.Payment_Month__c;
                                if (month != null && month >= 1 && month <= 12)
                                    timing = monthNames[month - 1];
                            } else if (srec.SREC_Contract_Offer__r.RecordTypeDeveloperName__c == 'Brokerage'){
                                timing = 'Determined by Direct Energy Solar';
                            } else if (srec.SREC_Contract_Offer__r.RecordTypeDeveloperName__c == 'Upfront' || srec.SREC_Contract_Offer__r.RecordTypeDeveloperName__c == 'Upfront_Cash_Back'){
                                timing = 'Time of Purchase';
                                // Added by RJ to Show Upfront SREC on Left Column
                                Decimal dollarAmount = nullDecimal(srec.Upfront_Effective_Dollar_Amount__c, 0);
                                sd.table1.add(new DataPairing(srec.SREC_Contract_Offer__r.Name, displayCash(dollarAmount)));
                            }
                            sd.summaryTable.add(new DataPairing('SREC Payment Schedule', timing));
                        }
                        sd.table1.add(new DataPairing('Net System Price', getNetSystemPrice(i)));
                        sd.table1TotalRows = sd.table1.size();

                        sd.summaryTable.add(new DataPairing('10% Due at Contract Signing', displayCash((Decimal)prop.get('Scenario_' + i + '_Payment_Due_Signing__c')))); 
                        sd.summaryTable.add(new DataPairing('60% Due on First Day of Installation', displayCash((Decimal)prop.get('Scenario_' + i + '_Payment_Due_Installation__c'))));
                        sd.summaryTable.add(new DataPairing('30% Due at Completed System Inspection', displayCash((Decimal)prop.get('Scenario_' + i + '_Payment_Due_Final_Inspection__c'))));
                        sd.summaryTableTotalRows = sd.summaryTable.size(); 

                        //All columns except yearly and cumulative cash flows will be prepended with an empty string in the "Initial Outlay" row.
                        String[] yearCol = new String[]{'Year', 'Initial Outlay'};
                        for (Integer year = 1; year <= scenarioTermYears.get(i); year++){
                            yearCol.add(String.valueOf(year));     //Standard is one through twenty
                        }

                        String[] feedInTariffEarnings;
                        if (nullDecimal(prop.get('Scenario_' + i + '_FIT_Annual_Earnings_After_Tax__c'), 0) > 0 && prop.get('Scenario_' + i + '_FIT_Term_Length_Months__c') != null){    //CPQ-731
                            feedInTariffEarnings = new String[]{'Feed In\nTariff\nEarnings', ''};
                            feedInTariffEarnings.addAll(getYearlyFeedInTariffEarnings(i));
                        }

                        String[] netSavings = new String[]{'Utility\nSavings', ''};
                        if (nullDecimal(prop.get('Scenario_' + i + '_FIT_Annual_Earnings_After_Tax__c'), 0) > 0 && prop.get('Scenario_' + i + '_FIT_Term_Length_Months__c') != null){
                            netSavings.addAll(getFeedInTariffUtilitySavings(i, getNetSavingsNum(i)));
                        } else {
                            netSavings.addAll(getNetSavings(i));    //Default case
                        }
                        String[] annualSrecEarnings = new String[]{};
                        String[] srecArr = getAnnualSrecEarnings(i);
                        if (!srecArr.isEmpty()){
                            annualSrecEarnings = new String[]{'SREC\nEarnings', ''};
                            annualSrecEarnings.addAll(srecArr);
                        }
                        String[] yearlyCashFlows = new String[]{'Yearly\nCash Flow', initOutlay};
                        yearlyCashFlows.addAll(getYearlyCashFlows(i, feedInTariffEarnings == null ? false : true));
                        String[] cumulativeCashFlows = new String[]{'Cumulative\nCash Flow', initOutlay};
                        cumulativeCashFlows.addAll(getCumulativeCashFlows(i, 0, feedInTariffEarnings == null ? false : true));
                        String[] annualGuaranteedProduction = new String[]{'Guaranteed\nOutput', ''};
                        annualGuaranteedProduction.addAll(getAnnualGuaranteedProduction(i));
                        String[] cumulativeGuaranteedProduction = new String[]{'Guaranteed\nCumulative\nOutput', ''};
                        cumulativeGuaranteedProduction.addAll(getCumulativeGuaranteedProduction(i));

                        //Populate the table, row by row
                        for (Integer rowNum = 0; rowNum < yearCol.size(); rowNum++){
                            String[] row = new String[]{};
                            row.add(yearCol[rowNum]);
                            if (feedInTariffEarnings != null)
                              row.add(feedInTariffEarnings.size() >= rowNum + 1 ? feedInTariffEarnings[rowNum] : '$ - ');
                            row.add(netSavings.size() >= rowNum + 1 ? netSavings[rowNum] : '$ - ');
                            if (annualSrecEarnings.size() > 0) {
                              row.add(annualSrecEarnings.size() >= rowNum + 1 ? annualSrecEarnings[rowNum] : '$ - ');
                            }
                            row.add(yearlyCashFlows.size() >= rowNum + 1 ? yearlyCashFlows[rowNum] : '$ - ');
                            row.add(cumulativeCashFlows.size() >= rowNum + 1 ? cumulativeCashFlows[rowNum] : '$ - ');
                            row.add(annualGuaranteedProduction.size() >= rowNum + 1 ? annualGuaranteedProduction[rowNum] : '$ - ');
                            row.add(cumulativeGuaranteedProduction.size() >= rowNum + 1 ? cumulativeGuaranteedProduction[rowNum] : '$ - ');
                            sd.table2.add(row);
                        }
                        
                        for (Price_Adjustment__c en : getEntitlementsForScenario(i))
                            sd.table3.add(en.Entitlement_Offer__r.Name);
                        
                    } else if (financingPlan == 'Solar Finance Plan'){
                        sd = new ScenarioData(i);
                        sd.pageTitle = 'Solar Finance Plan';
                        sd.planType = 1;
                        Decimal srecCashBack = sdq.get('Scenario_' + i + '_SREC_Cash_Back__c') != null ? (Decimal)sdq.get('Scenario_' + i + '_SREC_Cash_Back__c') : 0;
                        
                        sd.table1.add(new DataPairing('Down Payment', displayCash((Decimal)sdq.get('Scenario_' + i + '_Down_Payment__c'))));
                        for (Price_Adjustment__c pa : getPromotionsForScenario(i)){
                            Decimal dollarAmount = nullDecimal(pa.Effective_Dollar_Amount__c, 0);
                            sd.table1.add(new DataPairing(pa.Promotion__r.Name, displayCash(dollarAmount * -1 )));
                        }
                        for (Available_Incentive_Offer__c aio : getIncentiveOffersForScenario(i)){
                            Decimal dollarAmount = nullDecimal(aio.Effective_Dollar_Amount__c, 0);
                            if (dollarAmount != 0)
                              sd.table1.add(new DataPairing(aio.Customer_Description__c, displayCash(dollarAmount)));
                        }
                        if (srecCashBack != 0)
                          sd.table1.add(new DataPairing('SREC Cash Back', displayCash(srecCashBack)));
                        if (sdq.get('Scenario_' + i + '_SREC_Contract_Discount__c') != null && sdq.get('Scenario_' + i + '_SREC_Contract_Discount__c') != 0)
                          sd.table1.add(new DataPairing('SREC Contract Discount', displayCash((Decimal)sdq.get('Scenario_' + i + '_SREC_Contract_Discount__c'))));
                        sd.table1.add(new DataPairing('Monthly Payment', displayCash((Decimal)sdq.get('Scenario_' + i + '_First_Month_Payment__c'))));
                        sd.table1TotalRows = sd.table1.size();
                        
                        sd.summaryTable.add(new DataPairing(sd.pageTitle, ''));
                        Integer loanTerm = Integer.valueOf(prop.get('Scenario_' + i + '_Proposal_Term_months__c'));   //Default to be overwritten
                        if (sdq.getSObject('Scenario_' + i + '_Term_Loan__r') != null && sdq.getSObject('Scenario_' + i + '_Term_Loan__r').get('Financing_Term_Months__c') != null){
                          loanTerm = Integer.valueOf(sdq.getSObject('Scenario_' + i + '_Term_Loan__r').get('Financing_Term_Months__c'));
                          sd.summaryTable.add(new DataPairing('Loan Term', String.valueOf(loanTerm) + ' months'));
                        }
                        if (sdq.getSObject('Scenario_' + i + '_SAC_Loan__r') != null)
                          sd.summaryTable.add(new DataPairing('SAC Term', String.valueOf(sdq.getSObject('Scenario_' + i + '_SAC_Loan__r').get('Financing_Term_Months__c')) + ' months'));
                        sd.summaryTable.add(new DataPairing('Down Payment', displayCash((Decimal)sdq.get('Scenario_' + i + '_Down_Payment__c'))));
                        for (Available_SREC_Contract_Offer__c srec : getSrecOffersForScenario(i)){
                            sd.summaryTable.add(new DataPairing('SREC Credit Option', srec.Name));
                            sd.summaryTable.add(new DataPairing('SREC Credit Schedule', srec.SREC_Contract_Offer__r.RecordTypeDeveloperName__c));
                        }
                        sd.summaryTable.add(new DataPairing('Monthly Payment (Year 1)', displayCash((Decimal)prop.get('Scenario_' + i + '_Year_1_Monthly_Solar_Payment__c'))));
                        sd.summaryTableTotalRows = sd.summaryTable.size();

                        String[] yearCol = new String[]{'Year'};
                        if (srecCashBack == 0){
                          yearCol.add('Initial Outlay');  //Default
                        } else {
                          yearCol.add('Initial Outlay + Cashback');   //CPQ-675
                        }
                        for (Integer year = 1; year <= scenarioTermYears.get(i); year++){
                            yearCol.add(String.valueOf(year));     //Standard is one through twenty
                        }

                        String[] feedInTariffEarnings;
                        if (nullDecimal(prop.get('Scenario_' + i + '_FIT_Annual_Earnings_After_Tax__c'), 0) > 0 && prop.get('Scenario_' + i + '_FIT_Term_Length_Months__c') != null){    //CPQ-731
                            feedInTariffEarnings = new String[]{'Feed In\nTariff\nEarnings', ''};
                            feedInTariffEarnings.addAll(getYearlyFeedInTariffEarnings(i));
                        }

                        String[] netSavings = new String[]{'Utility\nSavings', ''};
                        if (nullDecimal(prop.get('Scenario_' + i + '_FIT_Annual_Earnings_After_Tax__c'), 0) > 0 && prop.get('Scenario_' + i + '_FIT_Term_Length_Months__c') != null){
                            netSavings.addAll(getFeedInTariffUtilitySavings(i, getNetSavingsNum(i)));
                        } else {
                            netSavings.addAll(getNetSavings(i));    //Default case
                        }
                        String[] annualFinancingPayments = new String[]{'Total\nAnnual\nPayments', ''};
                        annualFinancingPayments.addAll(getAnnualFinancingPayments(i, loanTerm));
                        String[] annualSrecEarnings = new String[]{};
                        String[] srecArr = getAnnualSrecEarnings(i);
                        if (!srecArr.isEmpty()){
                            annualSrecEarnings = new String[]{'SREC\nEarnings', ''};
                            annualSrecEarnings.addAll(srecArr);
                        }
                        Decimal initOutlayNum = -1 * Math.abs(nullDecimal(sdq.get('Scenario_' + i + '_Net_Initial_Outlay__c'), 0));
                        String[] yearlyCashFlows = new String[]{'Yearly Cash\nFlow', displayCash(initOutlayNum + srecCashBack)};
                        yearlyCashFlows.addAll(getYearlyCashFlows(i, feedInTariffEarnings == null ? false : true));
                        String[] cumulativeCashFlows = new String[]{'Cumulative\nCash Flow', displayCash(initOutlayNum + srecCashBack)};
                        cumulativeCashFlows.addAll(getCumulativeCashFlows(i, srecCashBack, feedInTariffEarnings == null ? false : true)); 
                        String[] annualGuaranteedProduction = new String[]{'Guaranteed\nOutput', ''};
                        annualGuaranteedProduction.addAll(getAnnualGuaranteedProduction(i));
                        String[] cumulativeGuaranteedProduction = new String[]{'Guaranteed\nCumulative\nOutput', ''};
                        cumulativeGuaranteedProduction.addAll(getCumulativeGuaranteedProduction(i));
                        
                        //Populate the table, row by row
                        for (Integer rowNum = 0; rowNum < yearCol.size(); rowNum++){
                            String[] row = new String[]{};
                            row.add(yearCol[rowNum]);
                            if (feedInTariffEarnings != null)
                              row.add(feedInTariffEarnings.size() >= rowNum + 1 ? feedInTariffEarnings[rowNum] : '$ - ');
                            row.add(netSavings.size() >= rowNum + 1 ? netSavings[rowNum] : '$ - ');
                            
                            if (annualSrecEarnings.size() > 0)
                              row.add(annualSrecEarnings.size() >= rowNum + 1 ? annualSrecEarnings[rowNum] : '$ - ');
                            
                            row.add(annualFinancingPayments.size() >= rowNum + 1 ? annualFinancingPayments[rowNum] : '$ - ');
                            row.add(yearlyCashFlows.size() >= rowNum + 1 ? yearlyCashFlows[rowNum] : '$ - ');
                            row.add(cumulativeCashFlows.size() >= rowNum + 1 ? cumulativeCashFlows[rowNum] : '$ - ');
                            row.add(annualGuaranteedProduction.size() >= rowNum + 1 ? annualGuaranteedProduction[rowNum] : '$ - ');
                            row.add(cumulativeGuaranteedProduction.size() >= rowNum + 1 ? cumulativeGuaranteedProduction[rowNum] : '$ - ');
                            sd.table2.add(row);
                        }
                        
                        for (Price_Adjustment__c en : getEntitlementsForScenario(i))
                            sd.table3.add(en.Entitlement_Offer__r.Name);

                    } else if (financingPlan == 'Monthly Savings Plan'){
                        sd = new ScenarioData(i);
                        sd.pageTitle = 'Monthly Savings Plan';
                        sd.planType = 2;
                        
                        sd.table1.add(new DataPairing('Down Payment', displayCash((Decimal)sdq.get('Scenario_' + i + '_Down_Payment__c'))));
                        for (Price_Adjustment__c pa : getPromotionsForScenario(i)){
                            Decimal dollarAmount = nullDecimal(pa.Effective_Dollar_Amount__c, 0);
                            sd.table1.add(new DataPairing(pa.Promotion__r.Name, displayCash(dollarAmount * -1)));
                        }
                        //for (Available_Incentive_Offer__c aio : getIncentiveOffersForScenario(i)){
                        //    Decimal dollarAmount = nullDecimal(aio.Effective_Dollar_Amount__c, 0);
                        //    sd.table1.add(new DataPairing(aio.Customer_Description__c, displayCash(dollarAmount)));
                        //}
                        Decimal netAdj = nullDecimal(sdq.get('Scenario_' + i + '_Total_Net_Adjustment__c'), 0);
                        //if (netAdj != 0)
                        //  sd.table1.add(new DataPairing('Amount of Discount Given as Cash Back', displayCash(Math.abs(netAdj)) ));
                        sd.table1.add(new DataPairing('Monthly Payment', displayCash((Decimal)sdq.get('Scenario_' + i + '_First_Month_Payment__c'))));
                        
                        String[] feedInTariffEarnings;
                        if (nullDecimal(prop.get('Scenario_' + i + '_FIT_Annual_Earnings_After_Tax__c'), 0) > 0 && prop.get('Scenario_' + i + '_FIT_Term_Length_Months__c') != null){    //CPQ-731
                            feedInTariffEarnings = new String[]{'Feed In\nTariff\nEarnings', ''};
                            feedInTariffEarnings.addAll(getYearlyFeedInTariffEarnings(i));
                        }

                        String[] cumulativeCashFlowArr = getCumulativeCashFlows(i, Math.abs(netAdj), feedInTariffEarnings == null ? false : true);  //Added netAdj for CPQ-792
                        if (isD2D){
                          sd.table1.add(new DataPairing('Percent Savings',String.valueOf(getPercentSavings(i) +'%')));
                          sd.table1.add(new DataPairing('First Year Savings', cumulativeCashFlowArr[0]));
                          sd.table1.add(new DataPairing('Savings over 20 Years', cumulativeCashFlowArr[19]));
                        }
                        
                        sd.table1TotalRows = sd.table1.size();
                        
                        if ((String)sdq.get('Scenario_' + i + '_Financing_Type__c') == 'PPA'){
                            sd.summaryTable.add(new DataPairing(sd.pageTitle, ''));
                            sd.summaryTable.add(new DataPairing('PPA Term (Months)', String.valueOf(prop.get('Scenario_' + i + '_Proposal_Term_months__c'))));
                            sd.summaryTable.add(new DataPairing('PPA Rate Escalator', String.valueOf(sdq.get('Scenario_' + i + '_Lease_Escalator__c'))));
                            sd.summaryTable.add(new DataPairing('Down Payment', displayCash((Decimal)sdq.get('Scenario_' + i + '_Down_Payment__c'))));
                            sd.summaryTable.add(new DataPairing('Est. Monthly Payment (Year 1)', displayCash((Decimal)prop.get('Scenario_' + i + '_Year_1_Monthly_Solar_Payment__c'))));
                        } else { 
                            sd.summaryTable.add(new DataPairing(sd.pageTitle, ''));
                            sd.summaryTable.add(new DataPairing('Lease Term (Months)', String.valueOf(prop.get('Scenario_' + i + '_Proposal_Term_months__c'))));
                            sd.summaryTable.add(new DataPairing('Lease Rate Escalator', String.valueOf(sdq.get('Scenario_' + i + '_Lease_Escalator__c'))));
                            sd.summaryTable.add(new DataPairing('Down Payment', displayCash((Decimal)sdq.get('Scenario_' + i + '_Down_Payment__c'))));
                            sd.summaryTable.add(new DataPairing('Monthly Payment (Year 1)', displayCash((Decimal)prop.get('Scenario_' + i + '_Year_1_Monthly_Solar_Payment__c'))));
                        }
                        
                        if (isD2D){
                            sd.summaryTable.add(new DataPairing('Percent Savings',String.valueOf(getPercentSavings(i) +'%')));
                            sd.summaryTable.add(new DataPairing('First Year Savings', cumulativeCashFlowArr[0]));
                            sd.summaryTable.add(new DataPairing('Savings over 20 Years', cumulativeCashFlowArr[19]));
                        }
                        sd.summaryTableTotalRows = sd.summaryTable.size(); 
                                    
                        String[] yearCol = new String[]{'Year'};
                        if (netAdj >= 0){
                          yearCol.add('Initial Outlay');  //Default
                          netAdj = 0;
                        } else {
                          yearCol.add('Initial Outlay + Rebate');   //CPQ-543
                          initOutlay = displayCash(-1 * Math.abs(nullDecimal(sdq.get('Scenario_' + i + '_Net_Initial_Outlay__c'), 0)) + Math.abs(netAdj));  //CPQ-792
                        }

                        for (Integer year = 1; year <= scenarioTermYears.get(i); year++){
                            yearCol.add(String.valueOf(year));     //Standard is one through twenty
                        }

                        String[] netSavings;
                        if (isD2D){
                          netSavings = new String[]{'Utility\nCost\nAvoided', ''};
                        } else {
                          netSavings = new String[]{'Utility\nSavings', ''};
                        }
                        if (nullDecimal(prop.get('Scenario_' + i + '_FIT_Annual_Earnings_After_Tax__c'), 0) > 0 && prop.get('Scenario_' + i + '_FIT_Term_Length_Months__c') != null){
                            netSavings.addAll(getFeedInTariffUtilitySavings(i, getNetSavingsNum(i)));
                        } else {
                            netSavings.addAll(getNetSavings(i));    //Default case
                        }

                        Integer loanTerm = Integer.valueOf(prop.get('Scenario_' + i + '_Proposal_Term_months__c'));   //Default to be overwritten
                        if (sdq.getSObject('Scenario_' + i + '_Term_Loan__r') != null && sdq.getSObject('Scenario_' + i + '_Term_Loan__r').get('Financing_Term_Months__c') != null)
                          loanTerm = Integer.valueOf(sdq.getSObject('Scenario_' + i + '_Term_Loan__r').get('Financing_Term_Months__c'));
                        
                        String[] annualFinancingPayments;
                        if (isD2D){
                          annualFinancingPayments = new String[]{'Your\nAnnual\nSolar\nPayments', ''};
                        } else {
                          annualFinancingPayments = new String[]{'Total\nAnnual\nPayments', ''};
                        }
                        annualFinancingPayments.addAll(getAnnualFinancingPayments(i, loanTerm));

                        String[] annualSrecEarnings = new String[]{};
                        String[] srecArr = getAnnualSrecEarnings(i);
                        if (!srecArr.isEmpty()){
                            annualSrecEarnings = new String[]{'SREC\nEarnings', ''};
                            annualSrecEarnings.addAll(srecArr);
                        }
                        
                        String[] yearlyCashFlows = new String[]{'Yearly\nCash Flow', initOutlay};
                        yearlyCashFlows.addAll(getYearlyCashFlows(i, feedInTariffEarnings == null ? false : true));
                        String[] cumulativeCashFlows = new String[]{'Cumulative\nCash Flow', initOutlay};
                        cumulativeCashFlows.addAll(cumulativeCashFlowArr);    //getCumulativeCashFlows(i, 0, feedInTariffEarnings == null ? false : true); //Commented out for CPQ-792
                        String[] annualGuaranteedProduction = new String[]{'Guaranteed\nOutput', ''};
                        annualGuaranteedProduction.addAll(getAnnualGuaranteedProduction(i));
                        String[] cumulativeGuaranteedProduction = new String[]{'Guaranteed\nCumulative\nOutput', ''};
                        cumulativeGuaranteedProduction.addAll(getCumulativeGuaranteedProduction(i));

                        for (Integer rowNum = 0; rowNum < yearCol.size(); rowNum++){
                            String[] row = new String[]{};
                            row.add(yearCol[rowNum]);
                            if (feedInTariffEarnings != null)
                              row.add(feedInTariffEarnings.size() >= rowNum + 1 ? feedInTariffEarnings[rowNum] : '$ - ');
                            row.add(netSavings.size() >= rowNum + 1 ? netSavings[rowNum] : '$ - ');
                            if (annualSrecEarnings.size() > 0)
                              row.add(annualSrecEarnings.size() >= rowNum + 1 ? annualSrecEarnings[rowNum] : '$ - ');
                            
                            row.add(annualFinancingPayments.size() >= rowNum + 1 ? annualFinancingPayments[rowNum] : '$ - ');
                            row.add(yearlyCashFlows.size() >= rowNum + 1 ? yearlyCashFlows[rowNum] : '$ - ');
                            row.add(cumulativeCashFlows.size() >= rowNum + 1 ? cumulativeCashFlows[rowNum] : '$ - ');
                            row.add(annualGuaranteedProduction.size() >= rowNum + 1 ? annualGuaranteedProduction[rowNum] : '$ - ');
                            row.add(cumulativeGuaranteedProduction.size() >= rowNum + 1 ? cumulativeGuaranteedProduction[rowNum] : '$ - ');
                            sd.table2.add(row);
                        }
                        
                        for (Price_Adjustment__c en : getEntitlementsForScenario(i))
                            sd.table3.add(en.Entitlement_Offer__r.Name);
                        
                    } else if (financingPlan == 'One Pay Plan'){
                        sd = new ScenarioData(i);
                        sd.pageTitle = 'One Pay Plan';
                        sd.planType = 3;
                        
                        Decimal endCost = nullDecimal(sdq.get('Scenario_' + i + '_Design_Override_Price__c'), 0) + nullDecimal(sdq.get('Scenario_' + i + '_Line_Item_Top_Line_Adjustment__c'), 0);
                        sd.table1.add(new DataPairing('Total Cost', displayCash(endCost)));
                        for (Price_Adjustment__c pa : getPromotionsForScenario(i)){
                            Decimal dollarAmount = nullDecimal(pa.Effective_Dollar_Amount__c, 0);
                            sd.table1.add(new DataPairing(pa.Promotion__r.Name, displayCash(dollarAmount * -1 )));
                        }
                        for (Available_Incentive_Offer__c aio : getIncentiveOffersForScenario(i)){
                            Decimal dollarAmount = nullDecimal(aio.Effective_Dollar_Amount__c, 0);
                            if (dollarAmount != 0)
                              sd.table1.add(new DataPairing(aio.Customer_Description__c, displayCash(dollarAmount)));
                        }
                        sd.table1.add(new DataPairing('Net System Price', getNetSystemPrice(i)));
                        sd.table1TotalRows = sd.table1.size();
                        
                        sd.summaryTable.add(new DataPairing(sd.pageTitle, ''));
                        sd.summaryTable.add(new DataPairing('Lease Term', String.valueOf(prop.get('Scenario_' + i + '_Proposal_Term_months__c'))));
                        sd.summaryTable.add(new DataPairing('One-time Payment', displayCash((Decimal)sdq.get('Scenario_' + i + '_Prepaid_Financing_Amount__c'))));
                        sd.summaryTableTotalRows = sd.summaryTable.size();
                        
                        //All columns except yearly and cumulative cash flows will be prepended with an empty string in the "Initial Outlay" row.
                        String[] yearCol = new String[]{'Year', 'Initial Outlay'};
                        String[] leasePayments = new String[]{'Lease\nPayments', ''};
                        for (Integer year = 1; year <= scenarioTermYears.get(i); year++){
                            yearCol.add(String.valueOf(year));     //Standard is one through twenty
                            leasePayments.add('$0');
                        }
                        String[] feedInTariffEarnings;
                        if (nullDecimal(prop.get('Scenario_' + i + '_FIT_Annual_Earnings_After_Tax__c'), 0) > 0 && prop.get('Scenario_' + i + '_FIT_Term_Length_Months__c') != null){    //CPQ-731
                            feedInTariffEarnings = new String[]{'Feed In\nTariff\nEarnings', ''};
                            feedInTariffEarnings.addAll(getYearlyFeedInTariffEarnings(i));
                        }

                        String[] netSavings = new String[]{'Utility\nSavings', ''};
                        if (nullDecimal(prop.get('Scenario_' + i + '_FIT_Annual_Earnings_After_Tax__c'), 0) > 0 && prop.get('Scenario_' + i + '_FIT_Term_Length_Months__c') != null){
                            netSavings.addAll(getFeedInTariffUtilitySavings(i, getNetSavingsNum(i)));
                        } else {
                            netSavings.addAll(getNetSavings(i));    //Default case
                        }
                        String[] annualSrecEarnings = new String[]{};
                        String[] srecArr = getAnnualSrecEarnings(i);
                        if (!srecArr.isEmpty()){
                            annualSrecEarnings = new String[]{'SREC\nEarnings', ''};
                            annualSrecEarnings.addAll(srecArr);
                        }
                        String[] yearlyCashFlows = new String[]{'Yearly\nCash Flow', initOutlay};
                        yearlyCashFlows.addAll(getYearlyCashFlows(i, feedInTariffEarnings == null ? false : true));
                        String[] cumulativeCashFlows = new String[]{'Cumulative\nCash Flow', initOutlay};
                        cumulativeCashFlows.addAll(getCumulativeCashFlows(i, 0, feedInTariffEarnings == null ? false : true));
                        String[] annualGuaranteedProduction = new String[]{'Guaranteed\nOutput', ''};
                        annualGuaranteedProduction.addAll(getAnnualGuaranteedProduction(i));
                        String[] cumulativeGuaranteedProduction = new String[]{'Guaranteed\nCumulative\nOutput', ''};
                        cumulativeGuaranteedProduction.addAll(getCumulativeGuaranteedProduction(i));

                        for (Integer rowNum = 0; rowNum < yearCol.size(); rowNum++){
                            String[] row = new String[]{};
                            row.add(yearCol[rowNum]);
                            if (feedInTariffEarnings != null)
                              row.add(feedInTariffEarnings.size() >= rowNum + 1 ? feedInTariffEarnings[rowNum] : '$ - ');
                            row.add(netSavings.size() >= rowNum + 1 ? netSavings[rowNum] : '$ - ');
                            row.add(leasePayments.size() >= rowNum + 1 ? leasePayments[rowNum] : '$0');
                            if (annualSrecEarnings.size() > 0)
                              row.add(annualSrecEarnings.size() >= rowNum + 1 ? annualSrecEarnings[rowNum] : '$ - ');
                            
                            row.add(yearlyCashFlows.size() >= rowNum + 1 ? yearlyCashFlows[rowNum] : '$ - ');
                            row.add(cumulativeCashFlows.size() >= rowNum + 1 ? cumulativeCashFlows[rowNum] : '$ - ');
                            row.add(annualGuaranteedProduction.size() >= rowNum + 1 ? annualGuaranteedProduction[rowNum] : '$ - ');
                            row.add(cumulativeGuaranteedProduction.size() >= rowNum + 1 ? cumulativeGuaranteedProduction[rowNum] : '$ - ');
                            sd.table2.add(row);
                        }
                        
                        for (Price_Adjustment__c en : getEntitlementsForScenario(i))
                            sd.table3.add(en.Entitlement_Offer__r.Name);

                    } else {
                        continue;
                    }

                    if (sd != null){
                        scenarios.add(sd);
                        overviewTemp.add(overviewCol);
                    }
                }
            } 
            
            for (Integer rowNum = 0; rowNum < overviewTemp[0].size(); rowNum++){
                String[] row = new String[]{};
                for (Integer colNum = 0; colNum < overviewTemp.size(); colNum++)
                    row.add(String.valueOf(overviewTemp[colNum][rowNum]));
                
                overviewTable.add(row);
            }
            
        } catch (Exception e){
            System.debug('Error in CPQproposalController constructor:' + e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error in CPQproposalController on line ' + e.getLineNumber() + ': ' + e));
        }
    }
    
    private Available_Incentive_Offer__c[] getIncentiveOffersForScenario(Integer n){
        Available_Incentive_Offer__c[] offers = new Available_Incentive_Offer__c[]{};
        for (Available_Incentive_Offer__c aio : incentiveOffers){
            if (aio.Applicable_Scenario__c == String.valueOf(n))
                offers.add(aio);
        }
        return offers;
    }
    
    private Price_Adjustment__c[] getPromotionsForScenario(Integer n){
        Price_Adjustment__c[] adjustments = new Price_Adjustment__c[]{};
        for (Price_Adjustment__c pa : priceAdjusts){
            if (pa.Promotion__r.Name != null && pa.Applicable_Scenario__c == String.valueOf(n))
                adjustments.add(pa);
        }
        return adjustments;
    }

    private Price_Adjustment__c[] getEntitlementsForScenario(Integer n){
        Price_Adjustment__c[] adjustments = new Price_Adjustment__c[]{};
        for (Price_Adjustment__c pa : priceAdjusts){
            if (pa.Entitlement_Offer__r.Name != null && pa.Applicable_Scenario__c == String.valueOf(n))
                adjustments.add(pa);
        }
        return adjustments;
    }

    private Available_SREC_Contract_Offer__c[] getSrecOffersForScenario(Integer n){
        Available_SREC_Contract_Offer__c[] offers = new Available_SREC_Contract_Offer__c[]{};
        for (Available_SREC_Contract_Offer__c srec : srecOffers){
            if (srec.Applicable_Scenario__c == String.valueOf(n))
                offers.add(srec);
        }
        return offers;
    }
    
    private System_Design_Product__c getSystemDesignProduct(String recordType){
        System_Design_Product__c prod = new System_Design_Product__c();     //Temp object for encapsulating data 
        for (System_Design_Item__c sdi : sdItems){
            if (sdi.RecordType.DeveloperName == recordType && sdi.System_Design_Product__r.RecordType.DeveloperName == recordType){
                prod.Description__c = sdi.System_Design_Product__r.Description__c;
                prod.Rated_Output_W__c = sdi.System_Design_Product__r.Rated_Output_W__c;    //Only necessary for the panel type, but do it for all
                break;
            }
        }
        return prod;
    }
    
    public System_Design_Product__c getPanelProduct(){
        return getSystemDesignProduct('Panel');
    }
    
    public System_Design_Product__c getInverterProduct(){
        return getSystemDesignProduct('Inverter');
    }
    
    public System_Design_Product__c getMountingProduct(){
        return getSystemDesignProduct('Mounting');
    }

    public String getLatestSketchUpID(){
        Attachment[] attch = [SELECT ID FROM Attachment WHERE ParentID = :sysDesign.ID AND ContentType = 'image/jpeg' ORDER BY CreatedDate DESC LIMIT 1];
        String attchID = '';
        if (!attch.isEmpty())
           attchID = (String)attch[0].ID;
        return attchID;
    }

    private String getChartImageID(String fileName){
        Attachment[] attch = [SELECT ID FROM Attachment WHERE ParentID = :prop.ID AND Name = :fileName AND ContentType = 'image/png' ORDER BY CreatedDate DESC LIMIT 1];
        String attchID = '';
        if (!attch.isEmpty())
           attchID = (String)attch[0].ID;
        return attchID;
    }

    public String getNewUtilityBillChartID(){
        return getChartImageID('newUtilBill.png');
    }

    public String getCurrentUtilityBillChartID(){
        return getChartImageID('currUtilBill.png');
    }

    public String getProductionVsUsageChartID(){
        return getChartImageID('productionVsUsage.png');
    }

    public String getComparativeRatesChartID(){
        return getChartImageID('comparativeRates.png');
    }

    public String getEstimatedAnnualProduction(){
      Decimal prod = nullDecimal(sysDesign.Total_Projected_Annual_Output_kWh_y__c, 0);
      return displayNum(prod); 
    }

    public String getProductionFactor(){
        Decimal factor = nullDecimal(sysDesign.Overall_Site_Quality__c, 0);
        return displayNum(factor);
    }

    //-- Calculations --//
    public String getMonthlyAvgBill_Current(){
        Decimal avgBill = pp.getAverageFromSemicolonDelimitedList(sysDesign.Default_CB_Panel__r.Utility_Service__r.Before_Total_Bill__c);   //Will be -1 if an error occurs
        return displayCash(avgBill);
    }

    public String getMonthlyAvgBill_New(){
        Decimal annualBill = sysDesign.Default_CB_Panel__r.Utility_Service__r.Method_1_Net_Bill__c != null ? sysDesign.Default_CB_Panel__r.Utility_Service__r.Method_1_Net_Bill__c : 0;
        Decimal avgBill = annualBill / 12.0;
        return displayCash(avgBill);
    }

    public String getMonthlyAvgBill_Savings(){
        Decimal before = pp.getAverageFromSemicolonDelimitedList(sysDesign.Default_CB_Panel__r.Utility_Service__r.Before_Total_Bill__c).setScale(2);
        Decimal after = nullDecimal(sysDesign.Default_CB_Panel__r.Utility_Service__r.Method_1_Net_Bill__c, 0).setScale(2);
        Decimal savings = before - after;
        return displayCash(savings);
    }

    public String getFirstYearCost_Current(){
        Decimal cost = pp.getSumFromSemicolonDelimitedList(sysDesign.Default_CB_Panel__r.Utility_Service__r.Before_Total_Bill__c);
        return displayCash(cost);
    }

    public String getFirstYearCost_New(){
        Decimal cost = sysDesign.Default_CB_Panel__r.Utility_Service__r.Method_1_Net_Bill__c;
        return displayCash(cost);
    }

    public String getFirstYearCost_Savings(){
        Decimal before = pp.getSumFromSemicolonDelimitedList(sysDesign.Default_CB_Panel__r.Utility_Service__r.Before_Total_Bill__c).setScale(2);
        Decimal after = nullDecimal(sysDesign.Default_CB_Panel__r.Utility_Service__r.Method_1_Net_Bill__c, 0).setScale(2);
        Decimal savings = before - after;
        return displayCash(savings);
    }

    public String getThe20thYearCost_Current(){
        Decimal beforeBillSum = pp.getSumFromSemicolonDelimitedList(sysDesign.Default_CB_Panel__r.Utility_Service__r.Before_Total_Bill__c);
        Decimal cost = pp.getNthYearCost(beforeBillSum, (Double)prop.Annual_Power_Price_Escalator__c, 20);
        return displayCash(cost);
    }

    public String getThe20thYearCost_New(){
        Decimal cost = pp.getNthYearCost(sysDesign.Default_CB_Panel__r.Utility_Service__r.Method_1_Net_Bill__c, (Double)prop.Annual_Power_Price_Escalator__c, 20);
        return displayCash(cost);
    }

    public String getThe20thYearCost_Savings(){
        Decimal beforeBillSum = pp.getSumFromSemicolonDelimitedList(sysDesign.Default_CB_Panel__r.Utility_Service__r.Before_Total_Bill__c);
        Decimal beforeCost = pp.getNthYearCost(beforeBillSum, (Double)prop.Annual_Power_Price_Escalator__c, 20);
        Decimal afterCost = pp.getNthYearCost(sysDesign.Default_CB_Panel__r.Utility_Service__r.Method_1_Net_Bill__c, (Double)prop.Annual_Power_Price_Escalator__c, 20);
        Decimal savings = beforeCost - afterCost;
        return displayCash(savings);
    }

    public String getUtilityRateBefore(){
        Decimal rate = nullDecimal(sysDesign.Default_CB_Panel__r.Utility_Service__r.Before_First_Year_Avg_Price__c, 0);
        return displayCash(rate);
    }

    public String getUtilityRateAfter(){
        Decimal rate = nullDecimal(sysDesign.Default_CB_Panel__r.Utility_Service__r.Net_First_Year_Avg_Price__c, 0);
        return displayCash(rate);
    }

    public String getUtilityRateSavings(){
        Decimal before = nullDecimal(sysDesign.Default_CB_Panel__r.Utility_Service__r.Before_First_Year_Avg_Price__c, 0);
        Decimal after = nullDecimal(sysDesign.Default_CB_Panel__r.Utility_Service__r.Net_First_Year_Avg_Price__c, 0);
        Decimal savings = before - after;
        return displayCash(savings);
    }

    public String getThe20YearTotal_Current(){
        double escalator = prop.Annual_Power_Price_Escalator__c != null ? (Double)prop.Annual_Power_Price_Escalator__c/100 : 0;
        Decimal beforeBillSum = pp.getSumFromSemicolonDelimitedList(sysDesign.Default_CB_Panel__r.Utility_Service__r.Before_Total_Bill__c);
        Decimal result = pp.getTotalOverYears(beforeBillSum, escalator, 20);
        return displayCash(result);
    }

    public String getThe20YearTotal_New(){
        double escalator = prop.Annual_Power_Price_Escalator__c != null ? (Double)prop.Annual_Power_Price_Escalator__c/100 : 0;
        Decimal result = pp.getTotalOverYears(sysDesign.Default_CB_Panel__r.Utility_Service__r.Method_1_Net_Bill__c, escalator, 20);
        return displayCash(result);
    }

    public String getThe20YearTotal_Savings(){
        double escalator = prop.Annual_Power_Price_Escalator__c != null ? (Double)prop.Annual_Power_Price_Escalator__c/100 : 0;
        Decimal beforeBillSum = pp.getSumFromSemicolonDelimitedList(sysDesign.Default_CB_Panel__r.Utility_Service__r.Before_Total_Bill__c);
        Decimal beforeCost = pp.getTotalOverYears(beforeBillSum, escalator, 20);
        Decimal afterCost = pp.getTotalOverYears(sysDesign.Default_CB_Panel__r.Utility_Service__r.Method_1_Net_Bill__c, escalator, 20);
        Decimal savings = beforeCost - afterCost;
        return displayCash(savings);
    }

    public String getLeaseEscalator(Integer n){
        String esc = '0';
        if ((String)sdq.get('Scenario_' + n + '_Financing_Type__c') == 'Lease' || (String)sdq.get('Scenario_' + n + '_Financing_Type__c') == 'PPA')   //CPQ-665
            esc = sdq.get('Scenario_' + n + '_Lease_Escalator__c') != null ? (String)sdq.get('Scenario_' + n + '_Lease_Escalator__c') : '0';
        return esc;
    }

    public Decimal getCashBenefitOver20Years(Integer n){  //Moved logic to ProposalProcessor for CPQ-747
        return pp.calcCumulativeCashBenefit(prop, sdq, sysDesign, n, Integer.valueOf(prop.get('Scenario_' + n + '_Proposal_Term_months__c')) );
    }

    public String getNetSystemPrice(Integer n){
        Decimal price = pp.getNetSystemPrice(sdq, n);
        if (price == null)
            price = -1;
        return displayCash(price);
    }

    public String[] getNetSavings(Integer n){        
        String[] formattedList = new String[]{};
        for (Decimal d : getNetSavingsNum(n)){
            formattedList.add(displayCash(d));        
        }
        return formattedList;
    }

    public Decimal[] getNetSavingsNum(Integer n){
        //Old Implementation: Commented out on 7/22/15 by DK for CPQ-573
        //Double totalConsumption = sysDesign.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh__c;
        //Double avgPrice = (Double)nullDecimal(sysDesign.Default_CB_Panel__r.Utility_Service__r.Before_First_Year_Avg_Price__c, 0);
        //Double remainingRate = sysDesign.Default_CB_Panel__r.Utility_Service__r.First_Year_Remaining_Rate__c;
        //Double annualProduction = sysDesign.Total_Projected_Annual_Output_kWh_y__c;       
        //Decimal[] netSavings = pp.getNetSavings(totalConsumption, avgPrice, annualProduction,remainingRate,prop, 20, n);

        Double method1NetSavings = sysDesign.Default_CB_Panel__r.Utility_Service__r.Method_1_Net_Savings__c;
        Double utilityRateEsc = nullDecimal(prop.Annual_Power_Price_Escalator__c, 4.0);
        utilityRateEsc = utilityRateEsc / 100.0;
        Double degradeRate = nullDecimal(prop.get('Scenario_' + n + '_Annual_Degradation_Factor__c'), 0.5);
        degradeRate = degradeRate / 100.0;
        Decimal[] netSavings = pp.getNetSavings(method1NetSavings, utilityRateEsc, degradeRate, 20);
        return netSavings;
    }

    public String[] getYearlyCashFlows(Integer n, Boolean includeFIT){
        String[] formattedList = new String[]{};
        Decimal[] yearlyCashFlowsArr;
        Decimal[] fitEarnings = new Decimal[]{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};  //A zero for each year in the term, by default
        if (includeFIT){
            yearlyCashFlowsArr = pp.getYearlyCashFlows(pp.getFeedInTariffUtilitySavings(prop, n, getNetSavingsNum(n)), 20, prop, sdq, n);
            fitEarnings = pp.getYearlyFeedInTariffEarnings(prop, n, 20);
        } else {
            yearlyCashFlowsArr = pp.getYearlyCashFlows(getNetSavingsNum(n), 20, prop, sdq, n);
        }
        for (Integer i = 0; i < yearlyCashFlowsArr.size(); i++){
            formattedList.add(displayCash(yearlyCashFlowsArr[i] + fitEarnings[i]));
        }

        return formattedList;
    }

    public String[] getCumulativeCashFlows(Integer n, Decimal customerCheck, Boolean includeFIT){
        String[] formattedList = new String[]{};
        for (Decimal d : pp.getCumulativeCashFlows(getNetSavingsNum(n), 20, prop, sdq, n, customerCheck, includeFIT)){
            formattedList.add(displayCash(d));
        }
        return formattedList;
    }

    public Decimal getSolarPortionOfElectricity(){
        Decimal projectedAnnualOutput = sysDesign.Total_Projected_Annual_Output_kWh_y__c;
        Decimal annualConsumption = sysDesign.Default_CB_Panel__r.Utility_Service__r.Annual_Electricity_Consumption_kWh_frm__c;
        return pp.getSolarPortionOfElectricity(projectedAnnualOutput, annualConsumption);
    }

    public String[] getAnnualSrecEarnings(Integer n){
        String[] formattedList = new String[]{};
        for (Decimal d : pp.getAnnualSrecEarnings(prop, sdq, n, Integer.valueOf(prop.get('Scenario_' + n + '_Proposal_Term_months__c')))){
            formattedList.add(displayCash(d));
        }
        return formattedList;
    }

    public String[] getAnnualGuaranteedProduction(Integer n){
        String[] formattedList = new String[]{};
        for (Decimal d : pp.getAnnualGuaranteedProduction(prop, sdq,sysDesign, n, Integer.valueOf(prop.get('Scenario_' + n + '_Proposal_Term_months__c')))){
            formattedList.add(displayNum(d));
        }
        return formattedList;
    }

    public String[] getCumulativeGuaranteedProduction(Integer n){
        String[] formattedList = new String[]{};
        for (Decimal d : pp.getCumulativeGuaranteedProduction(prop, sdq,sysDesign, n, Integer.valueOf(prop.get('Scenario_' + n + '_Proposal_Term_months__c')))){
            formattedList.add(displayNum(d));
        }
        return formattedList;
    }

    public String[] getAnnualFinancingPayments(Integer n, Integer termMonths){
        String[] formattedList = new String[]{};
        for (Decimal d : pp.getAnnualFinancingPayments(prop, sdq, n, termMonths)){
            formattedList.add(displayCash(d));
        }
        Integer propTermYears = (Integer)Math.floor(Integer.valueOf(prop.get('Scenario_' + n + '_Proposal_Term_months__c'))/12.0);
        while (formattedList.size() < propTermYears){
            formattedList.add(displayCash(0));  //Pad the array to match the standard Proposal term
        }
        return formattedList;
    }

    public Decimal getSolarOffset(){
        Decimal annualOutput = nullDecimal(sysDesign.Total_Projected_Annual_Output_kWh_y__c, 0);
        Decimal annualConsumption = nullDecimal(sysDesign.Default_CB_Panel__r.Utility_Service__r.Annual_Electricity_Consumption_kWh_frm__c, 0);
        Decimal offset = 0;
        if (annualConsumption != 0){
          offset = (annualOutput / annualConsumption) * 100.0;
          offset = offset.setScale(0);
        }
        return offset;
    }

    public String[] getYearlyFeedInTariffEarnings(Integer n){
        String[] formattedList = new String[]{};
        for (Decimal d : pp.getYearlyFeedInTariffEarnings(prop, n, 20)){
            formattedList.add(displayCash(d));        
        }
        return formattedList;
    }

    public String[] getFeedInTariffUtilitySavings(Integer n, Decimal[] netSavings){
        String[] formattedList = new String[]{};
        for (Decimal d : pp.getFeedInTariffUtilitySavings(prop, n, netSavings)){
            formattedList.add(displayCash(d));        
        }
        return formattedList;
    }

    public Decimal getPercentSavings(Integer n){
        try {
            Decimal savings = ((sysDesign.Default_CB_Panel__r.Utility_Service__r.Before_First_Year_Avg_Price__c - (Decimal)prop.get('Scenario_' + n + '_Solar_Electric_Rate__c'))/sysDesign.Default_CB_Panel__r.Utility_Service__r.Before_First_Year_Avg_Price__c)*100;
            savings = savings.setScale(0);
            return savings;
        } catch (Exception e){
            System.debug('Error: ' + e.getStackTraceString());
            return -1;
        }
    }

    private Decimal nullDecimal(Object obj, Decimal defaultVal){
        Decimal val = obj != null ? (Decimal)obj : defaultVal;
        return val;
    }

    private String displayCash(Decimal d){
        if (d == null)
            d = 0;
            
        d = d.setScale(2);
        
        String str = (d + 0.001).format();
        str = '$' + str.substring(0,str.length()-1);
        
        if (d < 0){
            d = Math.abs(d);     //Strip the minus sign
            str = (d + 0.001).format();
            str = '($' + str.substring(0,str.length()-1) + ')';
        }
        return str;
    }

    private String displayNum(Decimal d){
        if (d == null)
            d = 0;
            
        d = d.setScale(0);
        return d.format();
    }

    class ScenarioData {
        
        public Integer n {get; set;}
        public String pageTitle {get; set;}
        public Integer planType {get; set;}
        
        public List<DataPairing> table1 {get; set;}   //Cost stats
        public Integer table1TotalRows {get; set;}  //To assist Visualforce
        public Integer summaryTableTotalRows {get; set;}  //To assist Visualforce
        public List< List<String> > table2 {get; set;}     //Info columns
        public List<String> table3 {get; set;}   //Warranties and Guarantees
        public List<DataPairing> summaryTable {get; set;}   //Summary on last page of PDF
        
        public ScenarioData(Integer scenarioNum){
            n = scenarioNum;
            pageTitle = '';
            planType = -1;
            table1TotalRows = 0;
            summaryTableTotalRows = 0;
            table1 = new List<DataPairing>();
            table2 = new List< List<String> >();
            table3 = new List<String>();
            summaryTable = new List<DataPairing>();
        }

        public Integer getTable3Size(){
            return table3.size();
        }
    }
    
    class DataPairing {

        public String primary {get; set;}
        public String secondary {get; set;}

        public DataPairing(String str1, String str2){
            primary = str1;
            secondary = str2;
        }
    }
}