/* FILE: SystemDesignQuoteConfigExtension.cls
 * AUTHOR: Rohit Jain
 * DATE: 02/10/2015
 * PURPOSE: Controller for the system design quote creation/edit page.
 * MODIFICATION HISTORY:   
 *   05/28/15  DK  Updated makeNewSdq() to invoke SalesWorkflowValidationUtility.systemDesignQuoteWorkflowOnCreate() so that proper serialization occurs
 *   05/29/15  PB  JIRA-158 Added RecallSQ functionality on saving Utility Service
 *   06/03/15  DK  Implemented support for commission adders. CPQ-222.
 *   06/05/15  PB  CPQ-220 Display error messages in a popup
 *   06/16/15  DK  Default value of SDQ.Scenario_N_Down_Payment__c is now 0 instead of null. CPQ-445.
 *   06/21/15  DK  "Current Utility Bill" graph now shows cumulative month value of Before Tier N Cost (i.e. Tier 2 = Tier 1 + Tier 2).
                   "New Utility Bill" graph now shows cumulative Net Method 1 Tier Cost.  See CPQ-207 and CPQ-287.
 *   06/25/15  PB  JIRA-429 Run utility pricing before creating new quote.
 *   06/29/15  PB  CPQ-586 Throw custom exception when there is no contact associated with quote.
 *   06/29/15  PB  CPQ-345 Total amount of discount cannot exceed $0.50/w.(validation is done when user tries to generate proposal.)
 *   07/01/15  PB  CPQ-590 Assign System Makeup value to new SDQ
 *   07/06/15  PB  CPQ-234 Provide VP Override Permissions
 *   07/06/15  PB  CPQ-460 New Scenarios to Set Up Default SREC 
 *   07/08/15  DK  Prevent index out of bounds error as reported in CPQ-569.
 *   07/14/15  DK  New Proposal Expiration Date logic as defined in CPQ-416.
 *   09/28/15  DK  Updated pricing output lines. CPQ-663.
 */
public with sharing class SystemDesignQuoteConfigExtension {

    public Property__c prop{get;set;}

    private System_Design_Quote__c sysDesignQuote;        
    private System_Design_Quote__c oldSDQ;    
    private ApexPages.StandardController controller;
    private Date pricingDate { get {    //CPQ-717. Make this variable global to reduce redundant code.
                                    if (pricingDate == null){
                                        pricingDate = Date.today();
                                        if (sysDesignQuote.Pricing_Date__c != null)
                                            pricingDate = Date.newInstance(sysDesignQuote.Pricing_Date__c.year(), sysDesignQuote.Pricing_Date__c.month(), sysDesignQuote.Pricing_Date__c.day());
                                        return pricingDate;
                                    } else {
                                        return pricingDate;
                                    }
                                } set; }

    public boolean isSdqInsert  { get{ if(isSdqInsert == null){isSdqInsert = false;} return isSdqInsert; } set; }
    public System_Design_Quote__c currentQuote  { get;set;}
    public Utility_Service__c utilityService{ get;set;}
    public List<ContactInfo> contactInfos {get; set;}
    public String primaryContactId{get;set;}
    public String selectedStdPromotion{ get;set;}
    public String selectedStdPromotion1{ get;set;}
    public String selectedStdPromotion2{ get;set;}
    public String selectedStdPromotion3{ get;set;}
    public String selectedStdPromotion4{ get;set;}
    public List<Price_Adjustment__c> entitlementPriceAdjustments1 { get;set;}
    public List<Price_Adjustment__c> entitlementPriceAdjustments2 { get;set;}
    public List<Price_Adjustment__c> entitlementPriceAdjustments3 { get;set;}
    public List<Price_Adjustment__c> entitlementPriceAdjustments4 { get;set;}
    public List<Price_Adjustment__c> vpOverridePriceAdjustments1 { get;set;}
    public List<Price_Adjustment__c> vpOverridePriceAdjustments2 { get;set;}
    public List<Price_Adjustment__c> vpOverridePriceAdjustments3 { get;set;}
    public List<Price_Adjustment__c> vpOverridePriceAdjustments4 { get;set;}
    public List<Available_Incentive_Offer__c> incentiveOffers1{ get;set;}
    public List<Available_Incentive_Offer__c> incentiveOffers2{ get;set;}
    public List<Available_Incentive_Offer__c> incentiveOffers3{ get;set;}
    public List<Available_Incentive_Offer__c> incentiveOffers4{ get;set;}
    public List<Available_SREC_Contract_Offer__c> srecOffers1{ get;set;}
    public List<Available_SREC_Contract_Offer__c> srecOffers2{ get;set;}
    public List<Available_SREC_Contract_Offer__c> srecOffers3{ get;set;}
    public List<Available_SREC_Contract_Offer__c> srecOffers4{ get;set;}    
    
    public String level {get; set;}
    public String message {get; set;}

    public Boolean isMakeCurrentValid { get{ if(isMakeCurrentValid == null){isMakeCurrentValid = true;} return isMakeCurrentValid; } set; }

    public Boolean includeScenario1 { get{ if(includeScenario1 == null){includeScenario1 = false;} return includeScenario1; } set; }
    public Boolean includeScenario2 { get{ if(includeScenario2 == null){includeScenario2 = false;} return includeScenario2; } set; }
    public Boolean includeScenario3 { get{ if(includeScenario3 == null){includeScenario3 = false;} return includeScenario3; } set; }
    public Boolean includeScenario4 { get{ if(includeScenario4 == null){includeScenario4 = false;} return includeScenario4; } set; }

    public String selectedTerritory{ get;set;} 
    public String selectedAllElectric{ get;set;}   
    public String selectedSRECOffer1{ get;set;}
    public String selectedSRECOffer2{ get;set;}
    public String selectedSRECOffer3{ get;set;}
    public String selectedSRECOffer4{ get;set;}
    public boolean displayPopup {get; set;}
    public boolean displayPopup2 {get; set;}
    public boolean displayCustPopup {get; set;}
    public String utilityServErrors {get;set;}
    //06/05/2015 PB CPQ-220 Display error messages in a popup
    public Boolean hasErrors{get{hasErrors = ApexPages.hasMessages(); return hasErrors;} private set;}
    public PageReference closeErrorPopUp() {return null;}

    private LIST<String> sdqFields = new LIST<String>{ 'System_Design_Stored_State__c', 'System_Design_Stored_State_Mismatch__c', 'System_Design_Reconstruction_Record__c',  
                                        'Sys_Design_Reconstruct_Record_Mismatch__c', 'Current__c', 'Valid__c', 'System_Design__c', 'Pricing_Date__c', 'All_Electric_Service__c', 'Validation_Errors__c', 
                                        'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_Before_Solar__r.All_Electric_Service__c', 'System_Design__r.Property__r.Property_Owner__c', 
                                        'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_After_Solar__r.All_Electric_Service__c',
                                        'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Name',  'As_Of_Pricing_Date__c', 
                                        'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_After_Solar__r.Default_Rate_Code__c',
                                        'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Has_Service_Territories__c', 'Utility_Annual_Increase__c', 
                                        'System_Design__r.Default_CB_Panel__r.Name', 'System_Design__r.System_Inverter__r.Make__c', 'System_Design__r.Property__r.RecordType.DeveloperName',
                                        'System_Design__r.System_Inverter__r.RecordType.DeveloperName', 'Disqualifying_Validation_Errors__c', 'Annual_Electricity_Consumption_kWh__c' ,
                                        'System_Design__r.Astrum_SQ_Calculation_Status__c','System_Design__r.Property__c', 'System_Design__r.Property__r.Property_State__c', 'System_Size_kW__c', 'Scenario_1_Down_Payment__c', 'Scenario_2_Down_Payment__c' ,
                                        'Scenario_3_Down_Payment__c', 'Scenario_4_Down_Payment__c', 'Scenario_1_Financing_Rate_Year_1_kWh__c', 'Scenario_2_Financing_Rate_Year_1_kWh__c' ,
                                        'Scenario_3_Financing_Rate_Year_1_kWh__c', 'Scenario_4_Financing_Rate_Year_1_kWh__c', 'Scenario_1_Avoided_Utility_Rate__c',
                                        'Scenario_2_Avoided_Utility_Rate__c', 'Scenario_3_Avoided_Utility_Rate__c', 'Scenario_4_Avoided_Utility_Rate__c', 'Scenario_1_Lease_Escalator__c' ,
                                        'Scenario_2_Lease_Escalator__c', 'Scenario_3_Lease_Escalator__c', 'Scenario_4_Lease_Escalator__c', 'Scenario_1_Total_Projected_Annual_Output__c' ,
                                        'Scenario_2_Total_Projected_Annual_Output__c', 'Scenario_3_Total_Projected_Annual_Output__c', 'Scenario_4_Total_Projected_Annual_Output__c',
                                        'Community_Program_Offer__c','Community_Program_Offer__r.Account__r.Name','Community_Program_Offer__r.Current_Tier__c','Community_Program_Offer__r.Early_Adopter_Promotion_Available__c' ,
                                        'Community_Program_Offer__r.Name', 'Scenario_1_Design_Override_Price__c', 'Scenario_1_Net_Initial_Outlay__c',
                                        'Scenario_1_Financing_Type__c','Scenario_2_Financing_Type__c','Scenario_3_Financing_Type__c','Scenario_4_Financing_Type__c',
                                        'Scenario_1_Lease_Fund__c','Scenario_2_Lease_Fund__c','Scenario_3_Lease_Fund__c','Scenario_4_Lease_Fund__c',
                                        'Scenario_1_Lease_Option__c','Scenario_2_Lease_Option__c','Scenario_3_Lease_Option__c','Scenario_4_Lease_Option__c', 
                                        'Scenario_1_Error_Log__c' , 'Scenario_2_Error_Log__c', 'Scenario_3_Error_Log__c', 'Scenario_4_Error_Log__c',
                                        'Scenario_1_Available_SREC_Contract_Offer__c','Scenario_2_Available_SREC_Contract_Offer__c','Scenario_3_Available_SREC_Contract_Offer__c','Scenario_4_Available_SREC_Contract_Offer__c',
                                        'Scenario_1_Final_EPC_Price__c', 'Scenario_2_Final_EPC_Price__c','Scenario_3_Final_EPC_Price__c','Scenario_4_Final_EPC_Price__c',
                                        'Scenario_1_Installer_Paid_Incentive_Amt__c','Scenario_2_Installer_Paid_Incentive_Amt__c' ,'Scenario_3_Installer_Paid_Incentive_Amt__c','Scenario_4_Installer_Paid_Incentive_Amt__c',
                                        'Scenario_1_Prepaid_Financing_Amount__c','Scenario_2_Prepaid_Financing_Amount__c','Scenario_3_Prepaid_Financing_Amount__c','Scenario_4_Prepaid_Financing_Amount__c', 
                                        'Scenario_1_Base_Commission_Percent__c', 'Scenario_2_Base_Commission_Percent__c', 'Scenario_3_Base_Commission_Percent__c', 'Scenario_4_Base_Commission_Percent__c',
                                        'Scenario_1_Included_in_Proposal__c', 'Scenario_2_Included_in_Proposal__c', 'Scenario_3_Included_in_Proposal__c', 'Scenario_4_Included_in_Proposal__c',
                                        'Quoted_SREC_Market__c','Scenario_1_Available_SREC_Contract_Offer__r.SREC_Contract_Offer__c','Scenario_2_Available_SREC_Contract_Offer__r.SREC_Contract_Offer__c',
                                        'Scenario_3_Available_SREC_Contract_Offer__r.SREC_Contract_Offer__c','Scenario_4_Available_SREC_Contract_Offer__r.SREC_Contract_Offer__c',
                                        'Scenario_1_SAC_Loan__r.Fixed_Finance_Amount__c', 'Scenario_2_SAC_Loan__r.Fixed_Finance_Amount__c', 'Scenario_3_SAC_Loan__r.Fixed_Finance_Amount__c', 'Scenario_4_SAC_Loan__r.Fixed_Finance_Amount__c', 
                                        'Scenario_1_SREC_Cash_Back__c', 'Scenario_2_SREC_Cash_Back__c', 'Scenario_3_SREC_Cash_Back__c', 'Scenario_4_SREC_Cash_Back__c', 
                                        'Scenario_1_SREC_Contract_Discount__c', 'Scenario_2_SREC_Contract_Discount__c', 'Scenario_3_SREC_Contract_Discount__c', 'Scenario_4_SREC_Contract_Discount__c', 
                                        'Scenario_1_Available_Portfolio_Tiers__c', 'Scenario_2_Available_Portfolio_Tiers__c', 'Scenario_3_Available_Portfolio_Tiers__c', 'Scenario_4_Available_Portfolio_Tiers__c', 
                                        'Scenario_1_Portfolio_Tier_Selected__c', 'Scenario_2_Portfolio_Tier_Selected__c', 'Scenario_3_Portfolio_Tier_Selected__c', 'Scenario_4_Portfolio_Tier_Selected__c', 
                                        'Scenario_1_Set_Standard_Adjustment_Type__c', 'Scenario_2_Set_Standard_Adjustment_Type__c', 'Scenario_3_Set_Standard_Adjustment_Type__c', 'Scenario_4_Set_Standard_Adjustment_Type__c', 
                                        'Scenario_1_Term_Loan__r.Sighten_Product_uuid__c', 'Scenario_2_Term_Loan__r.Sighten_Product_uuid__c', 'Scenario_3_Term_Loan__r.Sighten_Product_uuid__c', 'Scenario_4_Term_Loan__r.Sighten_Product_uuid__c',
                                        'Scenario_1_Refuse_ACH__c','Scenario_2_Refuse_ACH__c','Scenario_3_Refuse_ACH__c','Scenario_4_Refuse_ACH__c',
                                        'Scenario_1_Term_Loan__r.APR__c','Scenario_1_Term_Loan__r.Monthly_Interest_Rate__c','Scenario_1_Term_Loan__r.Non_ACH_APR__c','Scenario_1_Term_Loan__r.Non_ACH_Monthly_Interest_Rate__c',
                                        'Scenario_2_Term_Loan__r.APR__c','Scenario_2_Term_Loan__r.Monthly_Interest_Rate__c','Scenario_2_Term_Loan__r.Non_ACH_APR__c','Scenario_2_Term_Loan__r.Non_ACH_Monthly_Interest_Rate__c',
                                        'Scenario_3_Term_Loan__r.APR__c','Scenario_3_Term_Loan__r.Monthly_Interest_Rate__c','Scenario_3_Term_Loan__r.Non_ACH_APR__c','Scenario_3_Term_Loan__r.Non_ACH_Monthly_Interest_Rate__c',
                                        'Scenario_4_Term_Loan__r.APR__c','Scenario_4_Term_Loan__r.Monthly_Interest_Rate__c','Scenario_4_Term_Loan__r.Non_ACH_APR__c','Scenario_4_Term_Loan__r.Non_ACH_Monthly_Interest_Rate__c'
                                    };

    public List<SelectOption> getStandardPromotions1() { return getStandardPromotions('1',selectedStdPromotion1);}
    
    public List<SelectOption> getStandardPromotions2() { return getStandardPromotions('2',selectedStdPromotion2);}

    public List<SelectOption> getStandardPromotions3() { return getStandardPromotions('3',selectedStdPromotion3);}

    public List<SelectOption> getStandardPromotions4() { return getStandardPromotions('4',selectedStdPromotion4);}    

    private List<SelectOption> getStandardPromotions(String scenarioN, String selectedPromotion) {
        List<Promotion__c> stdPromotions;        
        String finType = (string)sysDesignQuote.get('Scenario_' + scenarioN + '_Financing_Type__c');
        String leaseFund = (string)sysDesignQuote.get('Scenario_' + scenarioN + '_Lease_Fund__c');
        String leaseOption = (string)sysDesignQuote.get('Scenario_' + scenarioN + '_Lease_Option__c');
        String state = sysDesignQuote.System_Design__r.Property__r.Property_State__c;

        String stdSoql = 'Select Promo_Amount__c,Promo_Amount_Percent__c,Promo_Amount_W__c From Promotion__c ';
        stdSoql +=  'Where RecordType.DeveloperName = \'Standard\'  AND Start_Date__c <= :pricingDate AND (End_Date__c >= :pricingDate or End_Date__c = null) ';
        stdSoql +=  'AND (Financing_Type__c = null OR (Financing_Type__c <> null AND Financing_Type__c = :finType)) ';                          
        stdSoql +=  'AND (State__c = null OR (State__c <> null AND State__c includes(:state))) ';                          
        stdSoql +=  'AND (Lease_Fund__c = null OR (Lease_Fund__c <> null AND Lease_Fund__c =:leaseFund)) ';                          
        stdSoql +=  'AND (Leasing_Option__c = null OR (Leasing_Option__c <> null AND Leasing_Option__c =:leaseOption)) ';                          
        if(sysDesignQuote.Community_Program_Offer__c != null)
        {           
            //stdSoql += 'AND Community_Program_Offer__c = :sysDesignQuote.Community_Program_Offer__c';
            System.debug(stdSoql);
            stdPromotions = Database.query(stdSoql + 'AND Community_Program_Offer__c = :sysDesignQuote.Community_Program_Offer__c');
        }// Get Standard Promotions only
                
        System.debug('1**stdPromotions '+stdPromotions);

        if (stdPromotions == null || stdPromotions.isEmpty() )
        {
            stdSoql += 'AND Community_Program_Offer__c = null ';
            stdPromotions = Database.query(stdSoql);    
        }   
        System.debug('3**stdPromotions '+stdPromotions);    
        if(stdPromotions != null && !stdPromotions.isEmpty() )
        {
            stdPromotions.sort();
        }
        List<SelectOption> options = new List<SelectOption>();
        for(Promotion__c promo: stdPromotions)
        {
            if(selectedPromotion == 'Dollar Amount' && promo.Promo_Amount__c != null)
            {
                options.add(new SelectOption(String.valueOf(promo.Promo_Amount__c),String.valueOf(promo.Promo_Amount__c)));            
            }
            if(selectedPromotion == 'Percentage' && promo.Promo_Amount_Percent__c != null)
            {
                options.add(new SelectOption(String.valueOf(promo.Promo_Amount_Percent__c),String.valueOf(promo.Promo_Amount_Percent__c)));            
            }
            if(selectedPromotion == 'Dollar per Watt' && promo.Promo_Amount_W__c != null)
            {
                options.add(new SelectOption(String.valueOf(promo.Promo_Amount_W__c),String.valueOf(promo.Promo_Amount_W__c)));            
            }
        }
        return options;
    }
    /* cpq-460 commented old code
    public List<SelectOption> getAvailableSRECOffers1() { return getAvailableSRECOffer('1');}
    
    public List<SelectOption> getAvailableSRECOffers2() { return getAvailableSRECOffer('2');}
    
    public List<SelectOption> getAvailableSRECOffers3() { return getAvailableSRECOffer('3');}
    
    public List<SelectOption> getAvailableSRECOffers4() { return getAvailableSRECOffer('4');}

    private List<SelectOption> getAvailableSRECOffer(String scenarioN) {
        List<Available_SREC_Contract_Offer__c> avblOffers = 
            [Select Id, SREC_Contract_Offer__r.Name 
             From Available_SREC_Contract_Offer__c 
             Where Applicable_Scenario__c = :scenarioN 
             AND System_Design_Quote__c = :sysDesignQuote.Id];        
        
        List<SelectOption> options = new List<SelectOption>();        
        
        for(Available_SREC_Contract_Offer__c offer: avblOffers)
        {
            options.add(new SelectOption(offer.Id,Offer.SREC_Contract_Offer__r.Name ));          
            
        }
        return options;
    }
    */
    
    public List<Available_SREC_Contract_Offer__c> getAllSRECOffers1() { return getAllSRECOffers('1');}
    
    public List<Available_SREC_Contract_Offer__c> getAllSRECOffers2() { return getAllSRECOffers('2');}
    
    public List<Available_SREC_Contract_Offer__c> getAllSRECOffers3() { return getAllSRECOffers('3');}
    
    public List<Available_SREC_Contract_Offer__c> getAllSRECOffers4() { return getAllSRECOffers('4');}
    
    public List<SelectOption> getRateCodes() {
            List<Utility_Company__c> rateCodes = [SELECT Name, Utility_Service_Territory__c
                                                 FROM Utility_Company__c
                                                 WHERE Utility_Company_Master__c = :utilityService.Utility_Company_Master__c
                                                   AND Utility_Service_Territory__c = :selectedTerritory
                                                   AND All_Electric_Service__c = :selectedAllElectric 
                                                   AND (RecordType.Name != 'Custom' OR ID = :utilityService.Utility_Rate_Code_Before_Solar__c OR ID = :utilityService.Utility_Rate_Code_After_Solar__c)
                                                   ORDER BY default_Rate_Code__c DESC];

            List<SelectOption> options = new List<SelectOption>();
            for(Utility_Company__c rateCode: rateCodes)
            {
                options.add(new SelectOption(rateCode.Id,rateCode.Name));
            }
            return options;            
    }

    public List<SelectOption> getTerritorries() {
            List<Utility_Company__c> territorries = [Select Utility_Service_Territory__c
                                                 From Utility_Company__c
                                                 Where Utility_Company_Master__c = :utilityService.Utility_Company_Master__c 
                                                 order by Utility_Service_Territory__c];

            Set<String> terr = new Set<String>();
            List<SelectOption> options = new List<SelectOption>();
        
            for(Utility_Company__c rateCode: territorries)
            {
                terr.add(rateCode.Utility_Service_Territory__c);
                //options.add(new SelectOption(rateCode.Id,rateCode.Name));
            }
            for(String st : terr)
            {
                if (st != null)
                {
                   options.add(new SelectOption(st,st));   
                }
                
            }
            return options;            
    }

    public List<SelectOption> getAllElectrics() {
        List<SelectOption> result = new List<SelectOption>();
         result.add(new SelectOption('', 'None'));
        for (Schema.PicklistEntry ple : Utility_Company__c.All_Electric_Service__c.getDescribe().getPickListValues()) {
            result.add(new SelectOption(ple.getValue(), ple.getLabel()));
        }
        return result;
    }
    
    private List<Available_SREC_Contract_Offer__c> getAllSRECOffers(String scenario) {
        
        List<Available_SREC_Contract_Offer__c> ablOffers = 
            [Select Upfront_Effective_Dollar_Amount__c,Contract_Offer_Applied__c,SREC_Contract_Offer__r.Name 
             from Available_SREC_Contract_Offer__c 
             Where Applicable_Scenario__c = :scenario 
             AND System_Design_Quote__c = :sysDesignQuote.Id];
        
        return ablOffers;
    }

    public SelectOption[] getPortfolioRateTiers1() { return getPortfolioRateTiers('1'); }
    public SelectOption[] getPortfolioRateTiers2() { return getPortfolioRateTiers('2'); }
    public SelectOption[] getPortfolioRateTiers3() { return getPortfolioRateTiers('3'); }
    public SelectOption[] getPortfolioRateTiers4() { return getPortfolioRateTiers('4'); }

    private SelectOption[] getPortfolioRateTiers(String scenario){    //DK  CPQ-745
        SelectOption[] opts = new SelectOption[]{new SelectOption('', '-- None --')};
        String tierVals = (String)sysDesignQuote.get('Scenario_' + scenario + '_Available_Portfolio_Tiers__c');
        if (tierVals != null){
            for (String str : tierVals.split(';', 0)){
                opts.add(new SelectOption(str, str));
            }
        }
        return opts;
    }

    //CPQ-460 PB
    public String selectedSRECContOffer1 {get; set;}
    public String selectedSRECContOffer2 {get; set;}
    public String selectedSRECContOffer3 {get; set;}
    public String selectedSRECContOffer4 {get; set;}

    public List<SelectOption> getSRECContOffers1 (){ return getSRECContOffers('1',selectedSRECContOffer1, srecOffers1);}
    public List<SelectOption> getSRECContOffers2 (){ return getSRECContOffers('2',selectedSRECContOffer2, srecOffers2);}
    public List<SelectOption> getSRECContOffers3 (){ return getSRECContOffers('3',selectedSRECContOffer3, srecOffers3);}
    public List<SelectOption> getSRECContOffers4 (){ return getSRECContOffers('4',selectedSRECContOffer4, srecOffers4);}

    public Map<Id,SREC_Contract_Offer__c> mapSREC;

    @TestVisible private List<SelectOption> getSRECContOffers(String scenarioN, String selectedOffer, List<Available_SREC_Contract_Offer__c> srecContOffers) {
        
        if(mapSREC == null){
            mapSREC = new Map<Id,SREC_Contract_Offer__c>();
        }
        String finType = (String)sysDesignQuote.get('Scenario_' + scenarioN + '_Financing_Type__c');
        String leaseOption = (String)sysDesignQuote.get('Scenario_' + scenarioN + '_Lease_Option__c');
        String termLoan = (String)sysDesignQuote.get('Scenario_' + scenarioN + '_Term_Loan__c');    //DK  09/01/15  CPQ-657. Filter by currently selected Term Loan.
        String defaultOfferStr = '';
        List<SelectOption> SRECOffers = new List<SelectOption>();
        
        List<SREC_Contract_Offer__c> offers = new List<SREC_Contract_Offer__c>();
        offers = [SELECT Name, Financing_Type__c, Leasing_Option__c, RecordTypeId, RecordType.Name, SREC_Market__c, Default_Offer__c 
                    FROM SREC_Contract_Offer__c 
                    WHERE Start_Date__c <= :pricingDate 
                    AND (End_Date__c = null OR End_Date__c >= :pricingDate) 
                    //SRECS are always per state, first filter on the parent market object, then loop to find the offers 
                    AND SREC_Market__c =: sysDesignQuote.Quoted_SREC_Market__c 
                    AND Eligible_States__c includes(:sysDesignQuote.System_Design__r.Property__r.Property_State__c)
                    AND Financing_Type__c = :finType
                    AND Leasing_Option__c = :leaseOption 
                    AND Lease_Fund__c = :termLoan
                    ORDER BY Default_Offer__c DESC];

        for(SREC_Contract_Offer__c offer: offers){
            if(offer.Default_Offer__c){
                defaultOfferStr = offer.Id;
            }

            SRECOffers.add(new SelectOption(offer.Id,offer.Name));
            mapSREC.put(offer.Id, offer);
        }

        // Commented out the lines below to prevent resetting the SREC to default when --None-- was selected
        //if(String.isBlank((String)sysDesignQuote.get('Scenario_' + scenarioN + '_Available_SREC_Contract_Offer__c')) 
        //    && srecContOffers.isEmpty() && String.isBlank(selectedOffer) && String.isNotBlank(defaultOfferStr)){            
        //        setSelectedOffer(defaultOfferStr,scenarioN);            
        //}
                   
        return SRECOffers;
    }

    @TestVisible private void setSelectedOffer(String defaultOfferStr,String scenarioN){
        if(scenarioN.equals('1')){
            selectedSRECContOffer1 = defaultOfferStr;
        }else if(scenarioN.equals('2')){
            selectedSRECContOffer2 = defaultOfferStr;
        }else if(scenarioN.equals('3')){
            selectedSRECContOffer3 = defaultOfferStr;
        }else if(scenarioN.equals('4')){
            selectedSRECContOffer4 = defaultOfferStr;
        }
    }
    
    public List<SelectOption> getLeaseOptions1(){ return getLeaseOptions((String)sysDesignQuote.Scenario_1_Lease_Fund__c);}
    
    public List<SelectOption> getLeaseOptions2(){ return getLeaseOptions((String)sysDesignQuote.Scenario_2_Lease_Fund__c);}
    
    public List<SelectOption> getLeaseOptions3(){ return getLeaseOptions((String)sysDesignQuote.Scenario_3_Lease_Fund__c);}
    
    public List<SelectOption> getLeaseOptions4(){ return getLeaseOptions((String)sysDesignQuote.Scenario_4_Lease_Fund__c);}    

    //CPQ-640
    public List<Price_Adjustment__c> standardPriceAdjustments1 {
        get {
            if (standardPriceAdjustments1 == null)
                standardPriceAdjustments1 = getStandardPriceAdjustments('1', sysDesignQuote.ID);
            return standardPriceAdjustments1;
        } set; 
    }
    public List<Price_Adjustment__c> standardPriceAdjustments2 {
        get {
            if (standardPriceAdjustments2 == null)
                standardPriceAdjustments2 = getStandardPriceAdjustments('2', sysDesignQuote.ID);
            return standardPriceAdjustments2;
        } set; 
    }
    public List<Price_Adjustment__c> standardPriceAdjustments3 {
        get {
            if (standardPriceAdjustments3 == null)
                standardPriceAdjustments3 = getStandardPriceAdjustments('3', sysDesignQuote.ID);
            return standardPriceAdjustments3;
        } set; 
    }
    public List<Price_Adjustment__c> standardPriceAdjustments4 {
        get {
            if (standardPriceAdjustments4 == null)
                standardPriceAdjustments4 = getStandardPriceAdjustments('4', sysDesignQuote.ID);
            return standardPriceAdjustments4;
        } set; 
    }

    public SelectOption[] financingTypeOptions {    //DK  09/01/15  CPQ-657
        get {
            if (financingTypeOptions == null){
                financingTypeOptions = new SelectOption[]{new SelectOption('', '--None--'), new SelectOption('Purchase', 'Purchase')};
                Set<String> finTypes = new Set<String>();
                for (Lease_Fund__c lf : [SELECT RecordType.Name FROM Lease_Fund__c 
                                         WHERE Eligible_States__c INCLUDES (:sysDesignQuote.System_Design__r.Property__r.Property_State__c)
                                         AND (RecordTypeDeveloperName__c = 'PPA' OR RecordTypeDeveloperName__c = 'Lease')
                                         AND (Fund_Open_Date__c = null OR Fund_Open_Date__c <= :pricingDate) AND (Fund_Closed_Date__c = null OR Fund_Closed_Date__c >= :pricingDate)]){
                    if (!finTypes.contains(lf.RecordType.Name)){
                        finTypes.add(lf.RecordType.Name);
                        financingTypeOptions.add(new SelectOption(lf.RecordType.Name, lf.RecordType.Name));
                    }
                }
            }
            return financingTypeOptions;    //Filter financing types by state availability
        } set;
    }
    
    public List<Price_Adjustment__c> getVPPriceAdjustments1(){ return getVPPriceAdjustments('1');}
    
    public List<Price_Adjustment__c> getVPPriceAdjustments2(){ return getVPPriceAdjustments('2');}
    
    public List<Price_Adjustment__c> getVPPriceAdjustments3(){ return getVPPriceAdjustments('3');}
    
    public List<Price_Adjustment__c> getVPPriceAdjustments4(){ return getVPPriceAdjustments('4');}
    
    public List<Available_Incentive_Offer__c> getAllIncentives1() { return getAllIncentives('1');}
    
    public List<Available_Incentive_Offer__c> getAllIncentives2() { return getAllIncentives('2');}
    
    public List<Available_Incentive_Offer__c> getAllIncentives3() { return getAllIncentives('3');}
    
    public List<Available_Incentive_Offer__c> getAllIncentives4() { return getAllIncentives('4');}
    
    public List<Price_Adjustment__c> getAllEntitlementPriceAdjustments1() { return getAllEntitlementPriceAdjustments('1');}
    
    public List<Price_Adjustment__c> getAllEntitlementPriceAdjustments2() { return getAllEntitlementPriceAdjustments('2');}
    
    public List<Price_Adjustment__c> getAllEntitlementPriceAdjustments3() { return getAllEntitlementPriceAdjustments('3');}
    
    public List<Price_Adjustment__c> getAllEntitlementPriceAdjustments4() { return getAllEntitlementPriceAdjustments('4');}
    
    public List<SelectOption> getTermLoans(){
        List<SelectOption> selectTermLoans = new List<SelectOption>();
        selectTermLoans.add(new SelectOption('','--None--')); 
        List<Lease_Fund__c> termLoans = 
            [SELECT Name,RecordTypeDeveloperName__c 
             FROM Lease_Fund__c 
             WHERE RecordTypeDeveloperName__c ='Term_Loan' 
             AND Eligible_States__c INCLUDES (:sysDesignQuote.System_Design__r.Property__r.Property_State__c)
             AND (Fund_Open_Date__c = null OR Fund_Open_Date__c <= :pricingDate) AND (Fund_Closed_Date__c = null OR Fund_Closed_Date__c >= :pricingDate)];   //DK  09/01/15  CPQ-657. Filter by state.
        
        for(Lease_Fund__c termLoan: termLoans){
            selectTermLoans.add(new SelectOption(termLoan.Id, termLoan.Name));
        }    
        
        return selectTermLoans;
    }
    
    public List<SelectOption> getSACLoans1(){ return getSACLoans(sysDesignQuote.Scenario_1_Term_Loan__c);}
    
    public List<SelectOption> getSACLoans2(){ return getSACLoans(sysDesignQuote.Scenario_2_Term_Loan__c);}
    
    public List<SelectOption> getSACLoans3(){ return getSACLoans(sysDesignQuote.Scenario_3_Term_Loan__c);}
    
    public List<SelectOption> getSACLoans4(){ return getSACLoans(sysDesignQuote.Scenario_4_Term_Loan__c);}
    
    public List<SelectOption> getSACLoans(Id termLoan){
        List<SelectOption> selectSACLoans = new List<SelectOption>();
        selectSACLoans.add(new SelectOption('','--None--'));
        List<Lease_Fund__c> SACLoans;
        
        //If Hudson Term Loan Selected
        if(String.isNotBlank(termLoan)){
            SACLoans = 
            [SELECT Name, RecordTypeDeveloperName__c 
             FROM Lease_Fund__c 
             WHERE RecordTypeDeveloperName__c = 'SAC_Loan' 
             AND Eligible_States__c INCLUDES (:sysDesignQuote.System_Design__r.Property__r.Property_State__c)
             AND (Fund_Open_Date__c = null OR Fund_Open_Date__c <= :pricingDate) AND (Fund_Closed_Date__c = null OR Fund_Closed_Date__c >= :pricingDate)
             AND Related_Finance_Record__c = :termLoan];
        } else {
            SACLoans = 
            [SELECT Name, RecordTypeDeveloperName__c 
             FROM Lease_Fund__c 
             WHERE RecordTypeDeveloperName__c = 'SAC_Loan'
             AND Eligible_States__c INCLUDES (:sysDesignQuote.System_Design__r.Property__r.Property_State__c) 
             AND (Fund_Open_Date__c = null OR Fund_Open_Date__c <= :pricingDate) AND (Fund_Closed_Date__c = null OR Fund_Closed_Date__c >= :pricingDate)
             AND Related_Finance_Record__c = null];
        }
        
        for(Lease_Fund__c SACLoan: SACLoans){
            selectSACLoans.add(new SelectOption(SACLoan.Id, SACLoan.Name));
        }    
        
        return selectSACLoans;  //DK  09/01/15  CPQ-657. Filter by state.
    }
    
    public Decimal getMaxSACAllowed1(){
        
        Decimal maxSACAllowed = 0;
        if(sysDesignQuote.Scenario_1_SAC_Loan__c != null){
            Lease_Fund__c fund = [SELECT Max_Finance_Percent_of_Price__c 
                    FROM Lease_Fund__c 
                    WHERE Id = :sysDesignQuote.Scenario_1_SAC_Loan__c];                    
            if(fund != null && fund.Max_Finance_Percent_of_Price__c != null && sysDesignQuote.Scenario_1_Final_EPC_Price__c!= null && sysDesignQuote.Scenario_1_Installer_Paid_Incentive_Amt__c != null)
                maxSACAllowed = (sysDesignQuote.Scenario_1_Final_EPC_Price__c - sysDesignQuote.Scenario_1_Installer_Paid_Incentive_Amt__c) * (fund.Max_Finance_Percent_of_Price__c)/100;        
        }        
        return maxSACAllowed;
        
    }
    
    public Decimal getMaxSACAllowed2(){
        
        Decimal maxSACAllowed = 0;
        if(sysDesignQuote.Scenario_2_SAC_Loan__c != null){
            Lease_Fund__c fund = [SELECT Max_Finance_Percent_of_Price__c 
                    FROM Lease_Fund__c 
                    WHERE Id = :sysDesignQuote.Scenario_2_SAC_Loan__c];                    
            if(fund != null && fund.Max_Finance_Percent_of_Price__c != null && sysDesignQuote.Scenario_2_Final_EPC_Price__c!= null && sysDesignQuote.Scenario_2_Installer_Paid_Incentive_Amt__c != null)
                maxSACAllowed = (sysDesignQuote.Scenario_2_Final_EPC_Price__c - sysDesignQuote.Scenario_2_Installer_Paid_Incentive_Amt__c) * (fund.Max_Finance_Percent_of_Price__c)/100;        
        }        
        return maxSACAllowed;
        
    }
    
    public Decimal getMaxSACAllowed3(){
        
        Decimal maxSACAllowed = 0;
        if(sysDesignQuote.Scenario_3_SAC_Loan__c != null){
            Lease_Fund__c fund = [SELECT Max_Finance_Percent_of_Price__c 
                    FROM Lease_Fund__c 
                    WHERE Id = :sysDesignQuote.Scenario_3_SAC_Loan__c];                    
            if(fund != null && fund.Max_Finance_Percent_of_Price__c != null && sysDesignQuote.Scenario_3_Final_EPC_Price__c != null && sysDesignQuote.Scenario_3_Installer_Paid_Incentive_Amt__c !=null)
                maxSACAllowed = (sysDesignQuote.Scenario_3_Final_EPC_Price__c - sysDesignQuote.Scenario_3_Installer_Paid_Incentive_Amt__c) * (fund.Max_Finance_Percent_of_Price__c)/100;        
        }        
        return maxSACAllowed;
        
    }
    
    public Decimal getMaxSACAllowed4(){
        
        Decimal maxSACAllowed = 0;
        if(sysDesignQuote.Scenario_4_SAC_Loan__c != null){
            Lease_Fund__c fund = [SELECT Max_Finance_Percent_of_Price__c 
                    FROM Lease_Fund__c 
                    WHERE Id = :sysDesignQuote.Scenario_4_SAC_Loan__c];                    
            if(fund != null && fund.Max_Finance_Percent_of_Price__c != null && sysDesignQuote.Scenario_4_Final_EPC_Price__c != null && sysDesignQuote.Scenario_4_Installer_Paid_Incentive_Amt__c !=null)
                maxSACAllowed = (sysDesignQuote.Scenario_4_Final_EPC_Price__c - sysDesignQuote.Scenario_4_Installer_Paid_Incentive_Amt__c) * (fund.Max_Finance_Percent_of_Price__c)/100;        
        }        
        return maxSACAllowed;
        
    }
    
    public User thisUser {      //DK 7/31/15
        get{
            if (thisUser == null){
                thisUser = [SELECT Profile.Name, VP_Override_Permission__c, Alias FROM User WHERE ID = :UserInfo.getUserID() LIMIT 1];
                return thisUser;
            } else{
                return thisUser;
            }
        } 
        private set;
    }

    //CPQ-234 PB
    public Boolean isVPOverride{
        get{
            if(isVPOverride == null){
                //isVPOverride = [SELECT VP_Override_Permission__c 
                //                  FROM User 
                //                  WHERE Id =: UserInfo.getUserId()].VP_Override_Permission__c;
                isVPOverride = thisUser.VP_Override_Permission__c;   //DK 7/31/15
                return isVPOverride;
            }else{
                return isVPOverride;
            }
        } 
        private set;
    }

    public Boolean getDisplayChannelPartner(){
        //String profileName = [SELECT Profile.name 
        //                      FROM User 
        //                      WHERE Id =: UserInfo.getUserId()].Profile.name;
        String profileName = thisUser.Profile.Name;     //DK 7/31/15
        if(profileName.equalsIgnoreCase('System Administrator') || profileName.equalsIgnoreCase('Channel Sales Consultant')){
            return true;
        }
        return false;
    } 

    //public Decimal getMinSysSizeForCashRebate(){    //CPQ-543
    //    return System_Design_Quote_Settings__c.getOrgDefaults().Min_System_Size_Elig_for_Cash_Rebate__c != null ? System_Design_Quote_Settings__c.getOrgDefaults().Min_System_Size_Elig_for_Cash_Rebate__c : 5;
    //}
    
    public PageReference resetFinanceOptions1(){return resetFinanceOptionsN('1');}
    
    public PageReference resetFinanceOptions2(){return resetFinanceOptionsN('2');}
    
    public PageReference resetFinanceOptions3(){return resetFinanceOptionsN('3');}
    
    public PageReference resetFinanceOptions4(){return resetFinanceOptionsN('4');}
    
    public PageReference resetFinanceOptionsN(String ScenarioN){
        
        if(sysDesignQuote.get('Scenario_' + ScenarioN + '_Financing_Type__c') == 'Lease' || sysDesignQuote.get('Scenario_' + ScenarioN + '_Financing_Type__c') == 'PPA') {            
            sysDesignQuote.put('Scenario_' + ScenarioN + '_Lease_Fund__c', null);
            sysDesignQuote.put('Scenario_' + ScenarioN + '_Lease_Option__c', null);
            sysDesignQuote.put('Scenario_' + ScenarioN + '_Lease_Escalator__c', null);
            sysDesignQuote.put('Scenario_' + ScenarioN + '_Down_Payment__c', 0);            
        }
        return null;
    }
    
    public PageReference resetSACOptions1(){
        Lease_Fund__c lf = [SELECT Id, APR__c, Non_ACH_APR__c, Monthly_Interest_Rate__c, Non_ACH_Monthly_Interest_Rate__c FROM Lease_Fund__c WHERE Id = :sysDesignQuote.Scenario_1_Term_Loan__c LIMIT 1];
        scenario1ACHOption = (lf.APR__c != null && lf.Non_ACH_APR__c != null) 
            || (lf.Monthly_Interest_Rate__c != null && lf.Non_ACH_Monthly_Interest_Rate__c != null);
        
        sysDesignQuote.Scenario_1_SAC_Loan__c = null;
        return null;
    }
    
    public PageReference resetSACOptions2(){
        Lease_Fund__c lf = [SELECT Id, APR__c, Non_ACH_APR__c, Monthly_Interest_Rate__c, Non_ACH_Monthly_Interest_Rate__c FROM Lease_Fund__c WHERE Id = :sysDesignQuote.Scenario_2_Term_Loan__c LIMIT 1];
        scenario2ACHOption = (lf.APR__c != null && lf.Non_ACH_APR__c != null) 
            || (lf.Monthly_Interest_Rate__c != null && lf.Non_ACH_Monthly_Interest_Rate__c != null);
        
        sysDesignQuote.Scenario_2_SAC_Loan__c = null;
        return null;
    }
    
    public PageReference resetSACOptions3(){
        Lease_Fund__c lf = [SELECT Id, APR__c, Non_ACH_APR__c, Monthly_Interest_Rate__c, Non_ACH_Monthly_Interest_Rate__c FROM Lease_Fund__c WHERE Id = :sysDesignQuote.Scenario_3_Term_Loan__c LIMIT 1];
        scenario3ACHOption = (lf.APR__c != null && lf.Non_ACH_APR__c != null) 
            || (lf.Monthly_Interest_Rate__c != null && lf.Non_ACH_Monthly_Interest_Rate__c != null);
        
        sysDesignQuote.Scenario_3_SAC_Loan__c = null;
        return null;
    }
    
    public PageReference resetSACOptions4(){
        Lease_Fund__c lf = [SELECT Id, APR__c, Non_ACH_APR__c, Monthly_Interest_Rate__c, Non_ACH_Monthly_Interest_Rate__c FROM Lease_Fund__c WHERE Id = :sysDesignQuote.Scenario_4_Term_Loan__c LIMIT 1];
        scenario4ACHOption = (lf.APR__c != null && lf.Non_ACH_APR__c != null) 
            || (lf.Monthly_Interest_Rate__c != null && lf.Non_ACH_Monthly_Interest_Rate__c != null);
        
        sysDesignQuote.Scenario_4_SAC_Loan__c = null;
        return null;
    }
    
    public SelectOption[] getEscalatorPPA1(){ return getEscalatorPPA('1'); }
    public SelectOption[] getEscalatorPPA2(){ return getEscalatorPPA('2'); }
    public SelectOption[] getEscalatorPPA3(){ return getEscalatorPPA('3'); }
    public SelectOption[] getEscalatorPPA4(){ return getEscalatorPPA('4'); }

    public SelectOption[] getEscalatorPPA(String scenario){     //Allow escalator values for the fixed-rate PPA option. 10/15/15 DK.
        SelectOption[] leaseOpts = new SelectOption[]{};
        leaseOpts.add(new SelectOption('0', '0'));
        if (sysDesignQuote.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Name.containsIgnoreCase('Public Service Elec & Gas Co Long Island'))
            leaseOpts.add(new SelectOption('1.5', '1.5'));
        leaseOpts.add(new SelectOption('2.9', '2.9'));
        return leaseOpts;
    }

    public List<SelectOption> getFunds1(){return getFundsN('1');}
    
    public List<SelectOption> getFunds2(){return getFundsN('2');}
    
    public List<SelectOption> getFunds3(){return getFundsN('3');}
    
    public List<SelectOption> getFunds4(){return getFundsN('4');}
    
    public List<SelectOption> getFundsN(String ScenarioN){
        
        String financeTypeOp = (String)sysDesignQuote.get('Scenario_' + ScenarioN + '_Financing_Type__c');        
        
        List<SelectOption> selectFunds = new List<SelectOption>();
        selectFunds.add(new SelectOption('','--None--')); 
        List<Lease_Fund__c> leaseFunds = 
            [SELECT Name,RecordTypeDeveloperName__c 
             FROM Lease_Fund__c 
             WHERE RecordTypeDeveloperName__c =:financeTypeOp 
             AND Eligible_States__c INCLUDES (:sysDesignQuote.System_Design__r.Property__r.Property_State__c)
             AND (Fund_Open_Date__c = null OR (Fund_Open_Date__c = null OR Fund_Open_Date__c <= :pricingDate)) AND (Fund_Closed_Date__c = null OR Fund_Closed_Date__c >= :pricingDate)];
        
        for(Lease_Fund__c leaseFund: leaseFunds){
            selectFunds.add(new SelectOption(leaseFund.Id, leaseFund.Name));
        }        
        
        return selectFunds;
        
    }
    
    public List<SelectOption> getLeaseOptions(String selectedFund){
        
        List<SelectOption> selectLeaseOptions = new List<SelectOption>();
        selectLeaseOptions.add(new SelectOption('', '--None--')); 
        
        if(String.isNotBlank(selectedFund)){
            Lease_Fund__c[] leaseFund = [SELECT Eligible_Leasing_Options__c FROM Lease_Fund__c WHERE ID = :selectedFund 
                                         AND (Fund_Open_Date__c = null OR Fund_Open_Date__c <= :pricingDate) AND (Fund_Closed_Date__c = null OR Fund_Closed_Date__c >= :pricingDate)];
            
            if (!leaseFund.isEmpty()){
                List<String> options = leaseFund[0].Eligible_Leasing_Options__c.removeStart('[').removeEnd(']').split(';');
                
                for(String option: options){
                    selectLeaseOptions.add(new SelectOption(option,option));            
                }
            }          
        } 
        return selectLeaseOptions;
        
    }

    //PB CPQ-345 - Made this method static
    private static List<Price_Adjustment__c> getStandardPriceAdjustments(String scenario, Id sdqId) {
        
        List<Price_Adjustment__c> finalStdPromotions =  new List<Price_Adjustment__c>();

        List<Price_Adjustment__c> ablStdPromotions = 
            [SELECT Adjustment_Applied__c, Amount__c, Amount_per_Watt__c, Applicable_Scenario__c, Promotion__r.Required_Promotion__c, 
                Effective_Dollar_Amount__c, Percent__c, RecordTypeDeveloperName__c, Type__c, Promotion__r.Cash_Only__c, 
                Promotion__r.Name, Promotion_Type__c, Promotion__r.Exclude_from_Promotions_Validation__c, Promotion__r.Financing_Type__c
                ,Promotion__r.Lease_Fund__c,
                System_Design_Quote__r.Scenario_1_Financing_Type__c, System_Design_Quote__r.Scenario_2_Financing_Type__c, 
                System_Design_Quote__r.Scenario_3_Financing_Type__c, System_Design_Quote__r.Scenario_4_Financing_Type__c, 
                System_Design_Quote__r.Scenario_1_Term_Loan__c, System_Design_Quote__r.Scenario_2_Term_Loan__c, 
                System_Design_Quote__r.Scenario_3_Term_Loan__c, System_Design_Quote__r.Scenario_4_Term_Loan__c, 
                System_Design_Quote__r.Scenario_1_Lease_Fund__c, System_Design_Quote__r.Scenario_2_Lease_Fund__c, 
                System_Design_Quote__r.Scenario_3_Lease_Fund__c, System_Design_Quote__r.Scenario_4_Lease_Fund__c 
             FROM Price_Adjustment__c 
             WHERE Type__c IN ('Standard','Program') 
             AND System_Design_Quote__c = :sdqID AND Applicable_Scenario__c = :scenario];

         if (!ablStdPromotions.isEmpty()){
            String financingType = (String)ablStdPromotions[0].getSObject('System_Design_Quote__r').get('Scenario_' + scenario + '_Financing_Type__c');
            String termLoan = (String)ablStdPromotions[0].getSObject('System_Design_Quote__r').get('Scenario_' + scenario + '_Term_Loan__c');
            String leaseFund = (String)ablStdPromotions[0].getSObject('System_Design_Quote__r').get('Scenario_' + scenario + '_Lease_Fund__c');
            System.debug(' Scenario ' + scenario + ' : ' + ' :: '+ financingType + ' '+termLoan + ' '+ leaseFund );
            
            for (Integer i = 0; i < ablStdPromotions.size(); i++){                
                if (ablStdPromotions[i].Promotion__c != null && 
                        (
                            (ablStdPromotions[i].Promotion__r.Financing_Type__c != null &&  ablStdPromotions[i].Promotion__r.Financing_Type__c != financingType )
                         || ( 
                                (ablStdPromotions[i].Promotion__r.Financing_Type__c != null &&  ablStdPromotions[i].Promotion__r.Financing_Type__c == financingType ) && (ablStdPromotions[i].Promotion__r.Lease_Fund__c != null && leaseFund != null &&  ablStdPromotions[i].Promotion__r.Lease_Fund__c != leaseFund ) 
                            )
                         || ( 
                                (ablStdPromotions[i].Promotion__r.Financing_Type__c != null &&  ablStdPromotions[i].Promotion__r.Financing_Type__c == financingType ) && (ablStdPromotions[i].Promotion__r.Lease_Fund__c != null && termLoan != null &&  ablStdPromotions[i].Promotion__r.Lease_Fund__c != termLoan ) 
                            )
                          )
                        ||
                         (ablStdPromotions[i].Promotion__r.Cash_Only__c && (financingType != 'Purchase' || termLoan != null))
                    )
                {                    
                    System.debug(' Scenario ' + scenario + ' : ' + ' : Remove : '+  ablStdPromotions[i].Promotion__r.Name);
                }
                else
                {
                    finalStdPromotions.add(ablStdPromotions[i]);
                }

            }
        }
        //CPQ-685. Prevent "Cash Only" promotions from showing up in non-applicable contexts.
        /*
        if (!ablStdPromotions.isEmpty()){
            String financingType = (String)ablStdPromotions[0].getSObject('System_Design_Quote__r').get('Scenario_' + scenario + '_Financing_Type__c');
            String termLoan = (String)ablStdPromotions[0].getSObject('System_Design_Quote__r').get('Scenario_' + scenario + '_Term_Loan__c');
            for (Integer i = 0; i < ablStdPromotions.size(); i++){
                if (ablStdPromotions[i].Promotion__c != null && ablStdPromotions[i].Promotion__r.Cash_Only__c && (financingType != 'Purchase' || termLoan != null))
                    ablStdPromotions.remove(i);
            }
        }
        */
        return finalStdPromotions;
    }
    
    private List<Price_Adjustment__c> getVPPriceAdjustments(String scenario) {
        
        List<Price_Adjustment__c> vpPromotions = 
            [Select Adjustment_Applied__c,Amount__c,Amount_per_Watt__c,Applicable_Scenario__c
             ,Effective_Dollar_Amount__c,Percent__c,RecordTypeDeveloperName__c 
             ,Promotion__r.Name,Promotion_Type__c, Type__c 
             From Price_Adjustment__c 
             Where Type__c ='VP Override' 
             AND System_Design_Quote__c = :sysDesignQuote.Id 
             AND Applicable_Scenario__c = :scenario ];
        return vpPromotions;
    }

    private List<Available_Incentive_Offer__c> getAllIncentives(String scenario) {
                
        List<Available_Incentive_Offer__c> ablIncentives = 
            [Select id,Effective_Dollar_Amount__c,Incentive_Applied__c,Opted_Out_Manually__c 
             ,Incentive_Offer__r.Name , Not_Matched_Reason__c 
             from Available_Incentive_Offer__c 
             Where Applicable_Scenario__c = :scenario
             AND Current_Matching_Incentive__c = true
             AND System_Design_Quote__c = :sysDesignQuote.Id];        
        
        return ablIncentives;
    }

    private List<Price_Adjustment__c> getAllEntitlementPriceAdjustments(String scenario) {
        
        String financeType = (String)sysDesignQuote.get('Scenario_' + scenario + '_Financing_Type__c');
        String leaseFund = '' ;
        List<Price_Adjustment__c> entlPriceAdjustments = new List<Price_Adjustment__c>();
        if(String.isNotBlank(financeType)){
            if(financeType.equalsIgnoreCase('Purchase')){
                String termLoan = ((String)sysDesignQuote.get('Scenario_' + scenario + '_Term_Loan__c'));
                leaseFund = String.isNotBlank(termLoan)?termLoan:'';                
            }else if(financeType.equalsIgnoreCase('Lease') || financeType.equalsIgnoreCase('PPA')){
                String lease = (String)sysDesignQuote.get('Scenario_' + scenario + '_Lease_Fund__c');
                leaseFund = String.isNotBlank(lease)?lease:'';               
            }           
        }else{
            return entlPriceAdjustments;
        }
        
        entlPriceAdjustments = 
            [SELECT Name, Adjustment_Applied__c, Amount__c, Amount_per_Watt__c, Applicable_Scenario__c, Effective_Dollar_Amount__c, Percent__c, RecordTypeDeveloperName__c, Entitlement_Offer__r.Name, 
                Opt_Out_of_Adjustment__c, Entitlement_Offer__r.Financing_Type__c, Entitlement_Offer__r.Lease_Fund__c, Entitlement_Offer__r.Opt_Out_Allowed__c, Entitlement_Offer__r.Commission_Impact__c, 
                Entitlement_Offer__r.Commission_Impact_Percent__c, Entitlement_Offer__r.Commission_Impact_W__c, Entitlement_Offer__r.Commission_Impact_Sliding_Scale_Applied__c 
             FROM Price_Adjustment__c 
             WHERE Type__c = 'Line Item' AND Entitlement_Offer__r.Financing_Type__c = :financeType
             AND Entitlement_Offer__r.Lease_Fund__c = :leaseFund AND System_Design_Quote__c = :sysDesignQuote.Id AND Applicable_Scenario__c = :scenario];
        
        return entlPriceAdjustments;
    }
        
    public List<pricingCalc> getPricingCalcsN(String ScenarioN) {                
                  
        String query = 'Select Scenario_'+ ScenarioN +'_Financing_Type__c,Scenario_'+ ScenarioN +'_Design_Override_Price__c, Scenario_'+ ScenarioN +'_Net_Initial_Outlay__c';
        query+= ',Scenario_'+ ScenarioN +'_First_Month_Payment__c, Scenario_'+ ScenarioN +'_Financing_Rate_Year_1_kWh__c, Scenario_' + ScenarioN + '_SREC_Contract_Discount__c';
        query+= ', Scenario_'+ ScenarioN +'_Installer_Paid_Incentive_Amt__c, Scenario_'+ ScenarioN +'_Down_Payment__c, Scenario_' + ScenarioN + '_Line_Item_Top_Line_Adjustment__c';
        query+= ', Scenario_'+ ScenarioN +'_Term_Loan__r.Financing_Term_Months__c, Scenario_'+ ScenarioN +'_Term_Loan_Amount__c, Scenario_' + ScenarioN + '_SREC_Cash_Back__c';
        query+= ', Scenario_'+ ScenarioN +'_Final_EPC_Price__c, Scenario_'+ ScenarioN +'_Term_Loan__c, Scenario_'+ ScenarioN +'_SAC_Loan__c';
        query+= ', Scenario_'+ ScenarioN +'_SAC_Loan_Amount__c,Scenario_'+ ScenarioN +'_Prepaid_Financing_Amount__c, Scenario_'+ ScenarioN +'_Lease_Option__c';
        query+= ', Scenario_'+ ScenarioN +'_Final_EPC_Price_NUM__c, Scenario_' + ScenarioN + '_PPA_Adder_Reduction__c, Scenario_'+ ScenarioN +'_Total_Net_Adjustment__c';
        query+= ' From System_Design_Quote__c Where Id = ';
        query+= '\'' + sysDesignQuote.Id + '\' LIMIT 1';
        System_Design_Quote__c sdq = (System_Design_Quote__c) Database.query(query);
        
        List<pricingCalc> pricingCalcs = new List<pricingCalc>();
        if((String)sdq.get('Scenario_' + ScenarioN + '_Financing_Type__c') == 'Purchase')
        {            
            if((String)sdq.get('Scenario_' + ScenarioN + '_Term_Loan__c') != null && (String)sdq.get('Scenario_' + ScenarioN + '_SAC_Loan__c') != null ){
                //Term and SAC
                pricingCalcs.add(new pricingCalc('Purchase Price',(Decimal)sdq.get('Scenario_' + ScenarioN + '_Final_EPC_Price__c'), 'currency'));
                pricingCalcs.add(new pricingCalc('Grant Paid Directly to Direct Energy Solar',(Decimal)sdq.get('Scenario_' + ScenarioN + '_Installer_Paid_Incentive_Amt__c'), 'currency'));
                if (sdq.get('Scenario_' + ScenarioN + '_SREC_Contract_Discount__c') != null && sdq.get('Scenario_' + ScenarioN + '_SREC_Contract_Discount__c') != 0)
                    pricingCalcs.add(new pricingCalc('SREC Contract Discount',(Decimal)sdq.get('Scenario_' + ScenarioN + '_SREC_Contract_Discount__c'), 'currency'));
                pricingCalcs.add(new pricingCalc('SAC Loan Amount',(Decimal)sdq.get('Scenario_' + ScenarioN + '_SAC_Loan_Amount__c'), 'currency'));
                pricingCalcs.add(new pricingCalc('Down Payment',(Decimal)sdq.get('Scenario_' + ScenarioN + '_Down_Payment__c'), 'currency'));
                pricingCalcs.add(new pricingCalc('Term Loan Amount',(Decimal)sdq.get('Scenario_' + ScenarioN + '_Term_Loan_Amount__c'), 'currency'));            
                pricingCalcs.add(new pricingCalc('Term Loan Monthly Payment',(Decimal)sdq.get('Scenario_' + ScenarioN + '_First_Month_Payment__c'), 'currency'));
                pricingCalcs.add(new pricingCalc('Term Length',(Decimal)sdq.getSobject('Scenario_' + ScenarioN + '_Term_Loan__r').get('Financing_Term_Months__c'), 'Text' ));
                if (sdq.get('Scenario_' + ScenarioN + '_SREC_Cash_Back__c') != null && sdq.get('Scenario_' + ScenarioN + '_SREC_Cash_Back__c') != 0)
                    pricingCalcs.add(new pricingCalc('SREC Cash Back',(Decimal)sdq.get('Scenario_' + ScenarioN + '_SREC_Cash_Back__c'), 'currency'));
                
            }else if((String)sdq.get('Scenario_' + ScenarioN + '_Term_Loan__c') != null){
                //Term Only
                pricingCalcs.add(new pricingCalc('Purchase Price',(Decimal)sdq.get('Scenario_' + ScenarioN + '_Final_EPC_Price__c'), 'currency'));
                pricingCalcs.add(new pricingCalc('Grant Paid Directly to Direct Energy Solar',(Decimal)sdq.get('Scenario_' + ScenarioN + '_Installer_Paid_Incentive_Amt__c'), 'currency'));
                if (sdq.get('Scenario_' + ScenarioN + '_SREC_Contract_Discount__c') != null && sdq.get('Scenario_' + ScenarioN + '_SREC_Contract_Discount__c') != 0)
                    pricingCalcs.add(new pricingCalc('SREC Contract Discount',(Decimal)sdq.get('Scenario_' + ScenarioN + '_SREC_Contract_Discount__c'), 'currency'));
                pricingCalcs.add(new pricingCalc('Down Payment',(Decimal)sdq.get('Scenario_' + ScenarioN + '_Down_Payment__c'), 'currency'));
                pricingCalcs.add(new pricingCalc('Term Loan Amount',(Decimal)sdq.get('Scenario_' + ScenarioN + '_Term_Loan_Amount__c'), 'currency'));            
                pricingCalcs.add(new pricingCalc('Term Loan Monthly Payment',(Decimal)sdq.get('Scenario_' + ScenarioN + '_First_Month_Payment__c'), 'currency'));
                pricingCalcs.add(new pricingCalc('Term Length',(Decimal)sdq.getSobject('Scenario_' + ScenarioN + '_Term_Loan__r').get('Financing_Term_Months__c'), 'Text' ));
                if (sdq.get('Scenario_' + ScenarioN + '_SREC_Cash_Back__c') != null && sdq.get('Scenario_' + ScenarioN + '_SREC_Cash_Back__c') != 0)
                    pricingCalcs.add(new pricingCalc('SREC Cash Back',(Decimal)sdq.get('Scenario_' + ScenarioN + '_SREC_Cash_Back__c'), 'currency'));
                
            }else if((String)sdq.get('Scenario_' + ScenarioN + '_SAC_Loan__c') != null){
                //SAC Loan Only
                pricingCalcs.add(new pricingCalc('Purchase Price',(Decimal)sdq.get('Scenario_' + ScenarioN + '_Final_EPC_Price__c'), 'currency'));
                pricingCalcs.add(new pricingCalc('Grant Paid Directly to Direct Energy Solar',(Decimal)sdq.get('Scenario_' + ScenarioN + '_Installer_Paid_Incentive_Amt__c'), 'currency'));
                pricingCalcs.add(new pricingCalc('SAC Loan Amount',(Decimal)sdq.get('Scenario_' + ScenarioN + '_SAC_Loan_Amount__c'), 'currency'));
                pricingCalcs.add(new pricingCalc('Purchase Balance Remaining',((Decimal)sdq.get('Scenario_' + ScenarioN + '_Final_EPC_Price__c') - (Decimal)sdq.get('Scenario_' + ScenarioN + '_SAC_Loan_Amount__c')), 'currency'));
                
            }else{
                //Default
                Decimal designPrice = sdq.get('Scenario_' + ScenarioN + '_Design_Override_Price__c') != null ? (Decimal)sdq.get('Scenario_' + ScenarioN + '_Design_Override_Price__c') : 0;
                Decimal lineItmAdj = sdq.get('Scenario_' + ScenarioN + '_Line_Item_Top_Line_Adjustment__c') != null ? (Decimal)sdq.get('Scenario_' + ScenarioN + '_Line_Item_Top_Line_Adjustment__c') : 0;
                pricingCalcs.add(new pricingCalc('Design Price', designPrice + lineItmAdj, 'currency'));
                pricingCalcs.add(new pricingCalc('Purchase Price', (Decimal)sdq.get('Scenario_' + ScenarioN + '_Final_EPC_Price_NUM__c'), 'currency'));
                pricingCalcs.add(new pricingCalc('Net Purchase Price',(Decimal)sdq.get('Scenario_' + ScenarioN + '_Net_Initial_Outlay__c'), 'currency'));
                
            }
        }
        else if((String)sdq.get('Scenario_' + ScenarioN + '_Financing_Type__c') == 'Lease' || (String)sdq.get('Scenario_' + ScenarioN + '_Financing_Type__c') ==  'PPA')
        {
            if ((String)sdq.get('Scenario_' + ScenarioN + '_Lease_Option__c') != 'Portfolio PPA')
                pricingCalcs.add(new pricingCalc('Down Payment', (Decimal)sdq.get('Scenario_' + ScenarioN + '_Down_Payment__c'), 'currency'));

            if ((String)sdq.get('Scenario_' + ScenarioN + '_Lease_Option__c') != null && 
                (((String)sdq.get('Scenario_' + ScenarioN + '_Lease_Option__c')).contains('Month') || 
                (String)sdq.get('Scenario_' + ScenarioN + '_Lease_Option__c') == 'Fixed-Rate PPA') || (String)sdq.get('Scenario_' + ScenarioN + '_Lease_Option__c') == 'Portfolio PPA')
            {
                String monthlyLabel = (String)sdq.get('Scenario_' + ScenarioN + '_Financing_Type__c') == 'Lease' ? 'Monthly Payment' : 'Estimated Monthly Payment';
                String electricRateLabel = (String)sdq.get('Scenario_' + ScenarioN + '_Financing_Type__c') == 'Lease' ? 'Lease Electric Rate' : 'PPA Solar Electric Rate';
                pricingCalcs.add(new pricingCalc(monthlyLabel, (Decimal)sdq.get('Scenario_' + ScenarioN + '_First_Month_Payment__c'), 'currency'));
                pricingCalcs.add(new pricingCalc(electricRateLabel, (Decimal)sdq.get('Scenario_' + ScenarioN + '_Financing_Rate_Year_1_kWh__c'), 'currency-4'));
                if (sdq.get('Scenario_' + ScenarioN + '_PPA_Adder_Reduction__c') != null && sdq.get('Scenario_' + ScenarioN + '_PPA_Adder_Reduction__c') != 0)
                    pricingCalcs.add(new pricingCalc('Adder Reduction Required', (Decimal)sdq.get('Scenario_' + ScenarioN + '_PPA_Adder_Reduction__c'), 'currency-4'));
            }
            else
            {
                pricingCalcs.add(new pricingCalc('Prepaid Price (inc. tax)',(Decimal)sdq.get('Scenario_' + ScenarioN + '_Prepaid_Financing_Amount__c'), 'currency'));
            }

            //if (sdq.get('Scenario_' + ScenarioN + '_Total_Net_Adjustment__c') != null && sdq.get('Scenario_' + ScenarioN + '_Total_Net_Adjustment__c') != 0)
            //    pricingCalcs.add(new pricingCalc('Cash Rebate', (Decimal)sdq.get('Scenario_' + ScenarioN + '_Total_Net_Adjustment__c'), 'currency'));   //CPQ-543
        }
        return pricingCalcs;
        
    }
    
    public List<pricingCalc> getPricingCalcs1(){return getPricingCalcsN('1');}
    
    public List<pricingCalc> getPricingCalcs2(){return getPricingCalcsN('2');}
    
    public List<pricingCalc> getPricingCalcs3(){return getPricingCalcsN('3');}
    
    public List<pricingCalc> getPricingCalcs4(){return getPricingCalcsN('4');}
    
    public List<ContactInfo> getSDQContactInfos(){
        Account acc;
        try {
            acc = 
            [SELECT Name, 
                (SELECT Email,Phone,MailingCity,MailingPostalCode,MailingState,MailingStreet,FirstName,LastName,Name FROM Contacts) 
             FROM Account 
             WHERE Id = :sysDesignQuote.System_Design__r.Property__r.Property_Owner__c];
        } catch (QueryException qe){
            throw new CustomException('No related Account found. Please create an Account and relate it to the Property record.');        
        }

        Opportunity[] opps = [SELECT Id, (SELECT ContactId, IsPrimary, Role, OpportunityId FROM OpportunityContactRoles) FROM Opportunity WHERE Property__c = :sysDesignQuote.System_Design__r.Property__c ORDER BY CreatedDate Desc LIMIT 1];
        if (opps == null || opps.isEmpty()){    //See CPQ-569
            throw new CustomException('No related Opportunity found. Please create an Opportunity and relate it to the Property record.');
        }
        Opportunity op = opps[0];
               
        List<ContactInfo> dispContactInfos = new List<ContactInfo>();
        Map<Id,OpportunityContactRole> oppMap = new Map<Id,OpportunityContactRole>();
        
        for (OpportunityContactRole opConRole: op.OpportunityContactRoles){
            oppMap.put(opConRole.ContactId, opConRole);            
        }
        
        //PB  Throw custom exception when there is no contact associated with quote.
        if(acc.contacts.isEmpty()){
            throw new CustomException('There is no Contact associated with the Account of this System Design Quote. Please search for Contact record and edit the Account Name.');
        }
        for (Contact con: acc.contacts){
            if (oppMap.containsKey(con.Id)){
                ContactInfo ci = new ContactInfo(con, oppMap.get(con.Id).Id, oppMap.get(con.Id).Role, oppMap.get(con.Id).IsPrimary, op.Id);
                if (ci.isPrimary && !dispContactInfos.isEmpty())
                    dispContactInfos.add(0, ci);    //First in the list
                else
                    dispContactInfos.add(ci);
            } else {
                dispContactInfos.add(new ContactInfo(con, null, null, false, op.Id));                
            }
        }
        contactInfos = dispContactInfos;
        return contactInfos;
    }

    //CPQ-702
    public void addNewContact(){
        if (!contactInfos.isEmpty()){
            Contact newCon = new Contact(AccountID = sysDesignQuote.System_Design__r.Property__r.Property_Owner__c, MailingCity = contactInfos[0].con.MailingCity, 
                                         MailingPostalCode = contactInfos[0].con.MailingPostalCode, MailingState = contactInfos[0].con.MailingState, MailingStreet = contactInfos[0].con.MailingStreet);
            contactInfos.add(new ContactInfo(newCon, null, null, false, contactInfos[0].oppID));
        }
    }
    public void resetContactInfo(){
        contactInfos = getSDQContactInfos();
    }
    
    public Class ContactInfo{
        public Contact con {get;set;}
        public Id contactRoleId {get;set;}
        public String role {get;set;}
        public Boolean isPrimary {get;set;}
        public Id oppId {get;set;}
        public ContactInfo(Contact con, Id contactRoleId, String role, Boolean isPrimary, Id oppId){
                this.con = con;
                this.contactRoleId = contactRoleId;
                this.role = role;
                this.isPrimary = isPrimary;
                this.oppId = oppId;                
        }        
    }
    
    public static List<SelectOption> getRoles(){
        List<Schema.PicklistEntry> picklistroles= OpportunityContactRole.Role.getDescribe().getPicklistValues();
        List<SelectOption> roles = new List<SelectOption>();
        roles.add(new Selectoption('','--None--'));
        for(Schema.PicklistEntry role:picklistroles){
            roles.add(new Selectoption(role.getValue(),role.getLabel()));
        }
        
        return roles;
    }
    
    public List<SelectOption> getUsageTypes(){
        
        List<Schema.PicklistEntry> picklistUsageTypes = Utility_Service__c.Current_Usage_Type__c.getDescribe().getPicklistValues();
        List<SelectOption> usageTypes = new List<SelectOption>();
        usageTypes.add(new SelectOption('','--None--'));
        for(Schema.PicklistEntry usageType: picklistUsageTypes){
            if(sysDesignQuote.System_Design__r.Property__r.Property_State__c == 'CA'){
                if(usageType.getValue() == 'Monthly'){
                    usageTypes.add(new SelectOption(usageType.getValue(), usageType.getLabel()));                        
                }                
            }else{
                usageTypes.add(new SelectOption(usageType.getValue(), usageType.getLabel()));                               
            }            
        }
        
        return usageTypes;
    }
 
    
    public Property__c getPropertyInfo(){
        
        Property__c  prop = 
            [SELECT Name, Property_Address_2__c
             , Property_City__c, Property_State__c
             , Property_ZIP__c 
             FROM Property__c 
             WHERE Id = :sysDesignQuote.System_Design__r.Property__c];
        
        return prop;
        
    }
    
    public System_Design__c getSystemDesignInfo(){
        
        System_Design__c sysDesign = 
            [SELECT Total_System_Size_kW__c, Overall_TSRF__c, Panel_Count__c
             , System_Panel__r.Make__c, System_Panel__r.Model__c, Validation_Errors__c
             , System_Inverter__r.Make__c, System_Inverter__r.Model__c
             , Overall_Site_Quality__c, Sunnova_Overall_Site_Quality__c, Notes__c
             , Total_Projected_Annual_Output_kWh_y__c
             FROM System_Design__c 
             WHERE Id = :sysDesignQuote.System_Design__c];
        
        return sysDesign;
        
    }
    
    public List<DisplaySysDesignArray> getSysDesignArrays(){
        
        List<DisplaySysDesignArray> disSysDesignArrays = new List<DisplaySysDesignArray>();
        List<System_Design_Array__c> sysDesignArrays = 
            [SELECT Panel_Count__c, Original_Surface_Tilt__c, Mounting_Type__c
             , Original_Surface_Azimuth__c, Total_Trenching_Length_ft__c
             , (SELECT System_Design_Product__r.Description__c
                , System_Design_Product__r.RecordType.DeveloperName 
                FROM System_Design_Items__r 
                WHERE (System_Design_Product__r.RecordType.DeveloperName = 'Mounting' 
                       OR 
                       System_Design_Product__r.RecordType.DeveloperName = 'Trenching'))             
             FROM System_Design_Array__c 
             WHERE System_Design__c = :sysDesignQuote.System_Design__c];
        
        //Determine Mounting Type and Wire Material
        for(System_Design_Array__c sysArray: sysDesignArrays){
            DisplaySysDesignArray disSysDesignArray = new DisplaySysDesignArray();
            disSysDesignArray.sysDesignArray = sysArray;
            for(Integer i=0; i<sysArray.System_Design_Items__r.size(); i++){
                if( sysArray.System_Design_Items__r[i].System_Design_Product__r.RecordType.DeveloperName == 'Mounting' ) {
                    disSysDesignArray.Mounting_Type = sysArray.System_Design_Items__r[i].System_Design_Product__r.Description__c;
                }
               if( sysArray.System_Design_Items__r[i].System_Design_Product__r.RecordType.DeveloperName == 'Trenching' ) {
                   disSysDesignArray.Wire_Material = sysArray.System_Design_Items__r[i].System_Design_Product__r.Description__c;
               } 
            }
            disSysDesignArrays.add(disSysDesignArray);
        }
           
        return disSysDesignArrays;
    }
    
    public class DisplaySysDesignArray {
        
        public System_Design_Array__c sysDesignArray {get;private set;}
        public String Mounting_Type {get;private set;}
        public String Wire_Material {get;private set;}
        
        public DisplaySysDesignArray(){            
        }
        
    }
    
    public List<System_Design_Item__c> getSpecialParts() {
        
        List<System_Design_Item__c> specialPartSysDesignItems = 
            [SELECT Id, Name, System_Design_Product__r.Description__c, Quantity__c 
             FROM System_Design_Item__c 
             WHERE System_Design_Array__r.System_Design__c = :sysDesignQuote.System_Design__c 
             AND RecordType.DeveloperName = 'Special_Part' 
             AND Quantity__c > 0];
        
        return specialPartSysDesignItems;
    }
    
    public List<Proposal__c> getProposals(){
        List<Proposal__c> proposals = 
            [SELECT Id, Name, Current__c, Scenario_1_Financing_Plan__c
             ,Scenario_2_Financing_Plan__c,Scenario_3_Financing_Plan__c
             , Scenario_4_Financing_Plan__c, Proposal_Expiration_Date__c 
             FROM Proposal__c 
             WHERE System_Design_Quote__c = : sysDesignQuote.Id];
        return proposals;
    }
    
    public PageReference closePopup2() {
        displayPopup2 = false;
        Id sdqid = [SELECT Id FROM System_Design_Quote__c WHERE System_Design__r.Id = :sysDesignQuote.System_Design__r.Id AND Current__c = true][0].Id;
        if(sysDesignQuote.Id != sdqid){
            PageReference pageref = new PageReference('/apex/SystemDesignQuoteConfig?id='+ sdqid);
            pageref.setRedirect(true);
            return pageref;            
        }        
        return null;
    }
    
    public void showPopup2() {        
        displayPopup2 = true;
    }

    public SystemDesignQuoteConfigExtension(ApexPages.StandardController stdController) {
        if (!Test.isRunningTest())
            stdController.addFields(sdqFields);

        buttonScenario = '';
        Id sdqId = stdController.getId();
        displaySightenPopup = false;

        if(sdqId != null){
            Map<Integer, List<Object>> sightenScenarios = SightenAPIIntegrator.GetSightenScenariosAndPayments(sdqId);
            scenario1IsSighten = Boolean.valueOf(sightenScenarios.get(1)[0]);
            scenario2IsSighten = Boolean.valueOf(sightenScenarios.get(2)[0]);
            scenario3IsSighten = Boolean.valueOf(sightenScenarios.get(3)[0]);
            scenario4IsSighten = Boolean.valueOf(sightenScenarios.get(4)[0]);
        }
        
        oldSDQ = new System_Design_Quote__c();
        if (!Test.isRunningTest()){
            this.sysDesignQuote = (System_Design_Quote__c)stdController.getRecord();
        } else {    //If test context, query the necessary fields (because the standard controller won't set relationship fields)
            String sdqFieldsStr = String.join(sdqFields, ',');
            this.sysDesignQuote = Database.query('SELECT ' + sdqFieldsStr + ' FROM System_Design_Quote__c WHERE ID = \'' + sdqId + '\' LIMIT 1');
        }

        oldSDQ.Scenario_1_Financing_Type__c = sysDesignQuote.Scenario_1_Financing_Type__c;
        oldSDQ.Scenario_2_Financing_Type__c = sysDesignQuote.Scenario_2_Financing_Type__c;
        oldSDQ.Scenario_3_Financing_Type__c = sysDesignQuote.Scenario_3_Financing_Type__c;
        oldSDQ.Scenario_4_Financing_Type__c = sysDesignQuote.Scenario_4_Financing_Type__c;

        controller = stdController;
        system.debug(loggingLevel.ERROR,'***sysDesignQuote.id: ' + sysDesignQuote.id); 

        scenario1ACHOption = (sysDesignQuote.Scenario_1_Term_Loan__r.APR__c != null && sysDesignQuote.Scenario_1_Term_Loan__r.Non_ACH_APR__c != null) 
            || (sysDesignQuote.Scenario_1_Term_Loan__r.Monthly_Interest_Rate__c != null && sysDesignQuote.Scenario_1_Term_Loan__r.Non_ACH_Monthly_Interest_Rate__c != null);
        scenario2ACHOption = (sysDesignQuote.Scenario_2_Term_Loan__r.APR__c != null && sysDesignQuote.Scenario_2_Term_Loan__r.Non_ACH_APR__c != null) 
            || (sysDesignQuote.Scenario_2_Term_Loan__r.Monthly_Interest_Rate__c != null && sysDesignQuote.Scenario_2_Term_Loan__r.Non_ACH_Monthly_Interest_Rate__c != null);
        scenario3ACHOption = (sysDesignQuote.Scenario_3_Term_Loan__r.APR__c != null && sysDesignQuote.Scenario_3_Term_Loan__r.Non_ACH_APR__c != null) 
            || (sysDesignQuote.Scenario_3_Term_Loan__r.Monthly_Interest_Rate__c != null && sysDesignQuote.Scenario_3_Term_Loan__r.Non_ACH_Monthly_Interest_Rate__c != null);
        scenario4ACHOption = (sysDesignQuote.Scenario_4_Term_Loan__r.APR__c != null && sysDesignQuote.Scenario_4_Term_Loan__r.Non_ACH_APR__c != null) 
            || (sysDesignQuote.Scenario_4_Term_Loan__r.Monthly_Interest_Rate__c != null && sysDesignQuote.Scenario_4_Term_Loan__r.Non_ACH_Monthly_Interest_Rate__c != null);
       
        if(sysDesignQuote.id == null){
            isSdqInsert = true; 
            //Get the existing currrent Quote
            List<System_Design_Quote__c> currentQuotes = [Select Id,Name,System_Design__c from System_Design_Quote__c
                              Where System_Design__c = :sysDesignQuote.System_Design__c and Current__c = true Limit 1 ];

            if(currentQuotes != null && currentQuotes.size() > 0)
            {
                currentQuote = currentQuotes[0];
            }
            else
            {
                System.debug('No Current Quote');                
            }
        }
        //JIRA-429 Commented the else, since we need to run utility pricing before creating quote, when there is no current quote
        //else {

            /*sysDesignQuote = [Select Community_Program_Offer__c,System_Design__r,System_Design__r.Property__r,System_Design__r.Property__r.Property_State__c
                                                ,Scenario_1_Design_Override_Price__c, Scenario_1_Net_Initial_Outlay__c
                               from System_Design_Quote__c 
                              Where Id = :sysDesignQuote.id];*/ 
            String sysDes = (currentQuote!=null)? currentQuote.System_Design__c:sysDesignQuote.System_Design__c;                        
            Id utilityServiceId;
            for(System_Design_Array__c sda : [SELECT id, CB_Panel__r.Utility_Service__c
                                            FROM System_Design_Array__c                                                                                       
                                            WHERE CB_Panel__r.Utility_Service__c != null AND System_Design__c = :sysDes ]){
                                            //JIRA-429
                                            //WHERE CB_Panel__r.Utility_Service__c != null AND System_Design__c = :sysDesignQuote.System_Design__c ]){
                                             
                                            
                                                            
                utilityServiceId = sda.CB_Panel__r.Utility_Service__c;
          }  
            System.debug(loggingLevel.DEBUG,'Utilityservice** Id:' + utilityServiceId);
            if(utilityServiceId != null)
            {
                utilityService = [Select Utility_Rate_Code_Before_Solar__r.RecordType.Name,Utility_Rate_Code_After_Solar__c,Utility_Company_Master__r.Has_Service_Territories__c
                                        ,Utility_Company_Master__c,Utility_Company_Master__r.Name ,Consumption_Profile__c,Electric_Vehicle__c, Service_Territory__c 
                                        ,Utility_Rate_Code_Before_Solar__r.All_Electric_Service__c,Custom_Utility_Rate_Set_By__c,Utility_Company__r.RecordType.Name,Custom_Utility_Rate_Applied__c 
                                        ,Monthly_Electric_Consumption_KWH_Jan__c,Monthly_Electric_Consumption_KWH_feb__c,Monthly_Electric_Consumption_KWH_mar__c
                                        ,Monthly_Electric_Consumption_KWH_Apr__c,Monthly_Electric_Consumption_KWH_may__c,Monthly_Electric_Consumption_KWH_Jun__c
                                        ,Monthly_Electric_Consumption_KWH_jul__c,Monthly_Electric_Consumption_KWH_Aug__c,Monthly_Electric_Consumption_KWH_Sep__c
                                        ,Monthly_Electric_Consumption_KWH_Oct__c,Monthly_Electric_Consumption_KWH_Nov__c,Monthly_Electric_Consumption_KWH_dec__c
                                        ,Total_Forecasted_Consumption_kWh__c,Before_First_Year_Avg_Price__c,Current_Usage_Type__c,Annual_Electricity_Consumption_kWh__c
                                   From Utility_Service__c
                                Where id = :utilityServiceId];
            }

            //JIRA-429
            if(sysDesignQuote.id != null){
                selectedTerritory = utilityService.Service_Territory__c;
                selectedAllElectric = utilityService.Utility_Rate_Code_Before_Solar__r.All_Electric_Service__c;

                selectedStdPromotion1 = sysDesignQuote.Scenario_1_Set_Standard_Adjustment_Type__c;
                selectedStdPromotion2 = sysDesignQuote.Scenario_2_Set_Standard_Adjustment_Type__c;
                selectedStdPromotion3 = sysDesignQuote.Scenario_3_Set_Standard_Adjustment_Type__c;
                selectedStdPromotion4 = sysDesignQuote.Scenario_4_Set_Standard_Adjustment_Type__c;
                
                incentiveOffers1 = getAllIncentives1(); 
                entitlementPriceAdjustments1 = getAllEntitlementPriceAdjustments1();
                srecOffers1 = getAllSRECOffers1();
                vpOverridePriceAdjustments1 = getVPPriceAdjustments1();
                incentiveOffers2 = getAllIncentives2();
                entitlementPriceAdjustments2 = getAllEntitlementPriceAdjustments2();
                srecOffers2 = getAllSRECOffers2();            
                vpOverridePriceAdjustments2 = getVPPriceAdjustments2();
                incentiveOffers3 = getAllIncentives3();
                entitlementPriceAdjustments3 = getAllEntitlementPriceAdjustments3();
                srecOffers3 = getAllSRECOffers3();
                vpOverridePriceAdjustments3 = getVPPriceAdjustments3();
                incentiveOffers4 = getAllIncentives4();
                entitlementPriceAdjustments4 = getAllEntitlementPriceAdjustments4();
                srecOffers4 = getAllSRECOffers4();
                vpOverridePriceAdjustments4 = getVPPriceAdjustments4();
                
                contactInfos = getSDQContactInfos();

                //cpq-460                
                if(sysDesignQuote.Scenario_1_Available_SREC_Contract_Offer__c != null){
                    selectedSRECContOffer1 = sysDesignQuote.Scenario_1_Available_SREC_Contract_Offer__r.SREC_Contract_Offer__c;
                }else{
                    selectedSRECContOffer1 = '';
                }

                if(sysDesignQuote.Scenario_2_Available_SREC_Contract_Offer__c != null){
                    selectedSRECContOffer2 = sysDesignQuote.Scenario_2_Available_SREC_Contract_Offer__r.SREC_Contract_Offer__c;
                }else{
                    selectedSRECContOffer2 = '';
                }

                if(sysDesignQuote.Scenario_3_Available_SREC_Contract_Offer__c != null){
                    selectedSRECContOffer3 = sysDesignQuote.Scenario_3_Available_SREC_Contract_Offer__r.SREC_Contract_Offer__c;
                }else{
                    selectedSRECContOffer3 = '';
                }

                if(sysDesignQuote.Scenario_4_Available_SREC_Contract_Offer__c != null){
                    selectedSRECContOffer4 = sysDesignQuote.Scenario_4_Available_SREC_Contract_Offer__r.SREC_Contract_Offer__c;
                }else{
                    selectedSRECContOffer4 = '';
                }

            }

    }

    //forced refresh 
    public PageReference offerChanged() {
        return null;
    }
    
    public PageReference compMasterChanged(){
        
        selectedAllElectric = '';   
        selectedTerritory = '';
        return null;
    }
    
    public PageReference resetLeaseOp1(){
        sysDesignQuote.Scenario_1_Lease_Option__c = null;
        sysDesignQuote.Scenario_1_Lease_Escalator__c = null;        
        return null;
    }
    
    public PageReference resetLeaseOp2(){
        sysDesignQuote.Scenario_2_Lease_Option__c = null;
        sysDesignQuote.Scenario_2_Lease_Escalator__c = null;        
        return null;
    }
    
    public PageReference resetLeaseOp3(){
        sysDesignQuote.Scenario_3_Lease_Option__c = null;
        sysDesignQuote.Scenario_3_Lease_Escalator__c = null;        
        return null;
    }
    
    public PageReference resetLeaseOp4(){
        sysDesignQuote.Scenario_4_Lease_Option__c = null;
        sysDesignQuote.Scenario_4_Lease_Escalator__c = null;        
        return null;
    }

    //SD MODE INIT
    public pageReference initSDQEditMode(){
        system.debug('***initSDQEditMode');       
        return null;
    }
    
    public pageReference makeNewQuote(){

        //JIRA-429
        UtilityPricingProcessor upp = new UtilityPricingProcessor(sysDesignQuote.System_Design__c,'Method_1');
        String utilityErrors = upp.getUtilityServiceMonthlyProduction(utilityService.Utility_Rate_Code_Before_Solar__c);
        
        if(utilityErrors != 'OK')
        {
            if (displayPopup3)
                customRateResultMsg = 'ENCOUNTERED ERROR IN UTILITY PRICING:\n' + utilityErrors;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Make New Quote Error: '+utilityErrors));
            return null;
        }        
        
        System_Design_Quote__c sdq = SalesWorkflowValidationUtility.systemDesignQuoteWorkflowOnCreate(sysDesignQuote.System_Design__c , true);
        PageReference pg = new PageReference('/apex/SystemDesignQuoteConfig?id=' + sdq.Id);
        pg.setRedirect(true);        
        return pg;
    }

    /* RJ 06/18/2015 : Commented  Not Used anywhere

    public PageReference saveUtilityService(){
        
        // 1. Save Utility Service Changes 
        System.debug(utilityService);
        
        if(utilityService.Current_Usage_Type__c == 'Annual' 
           && utilityService.Annual_Electricity_Consumption_kWh__c != null 
           && utilityService.Annual_Electricity_Consumption_kWh__c > 0){
            
            Integer avgMonthConsumption = (utilityService.Annual_Electricity_Consumption_kWh__c/12).intValue();
            //update all monthly elec
            utilityService.Monthly_Electric_Consumption_KWH_Apr__c = avgMonthConsumption;
            utilityService.Monthly_Electric_Consumption_KWH_Aug__c = avgMonthConsumption;
            utilityService.Monthly_Electric_Consumption_KWH_Dec__c = avgMonthConsumption;
            utilityService.Monthly_Electric_Consumption_KWH_Feb__c = avgMonthConsumption;
            utilityService.Monthly_Electric_Consumption_KWH_Jan__c = avgMonthConsumption;
            utilityService.Monthly_Electric_Consumption_KWH_Jul__c = avgMonthConsumption;
            utilityService.Monthly_Electric_Consumption_KWH_Jun__c = avgMonthConsumption;
            utilityService.Monthly_Electric_Consumption_KWH_Mar__c = avgMonthConsumption;
            utilityService.Monthly_Electric_Consumption_KWH_May__c = avgMonthConsumption;
            utilityService.Monthly_Electric_Consumption_KWH_Nov__c = avgMonthConsumption;
            utilityService.Monthly_Electric_Consumption_KWH_Oct__c = avgMonthConsumption;
            utilityService.Monthly_Electric_Consumption_KWH_Sep__c = avgMonthConsumption;
        }
        
        update utilityService;
        
        // 2. Run Utility Pricing Processor
        UtilityPricingProcessor upp = new UtilityPricingProcessor(sysDesignQuote.System_Design__c,'Method_1');
        String utilityErrors = upp.getUtilityServiceMonthlyProduction(utilityService.Utility_Rate_Code_Before_Solar__c);
        
        if(utilityErrors != 'OK')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Utility Pricing Error: '+utilityErrors));
            return null;
        }        
        
        //3. Make new Quote Now
        
        System_Design_Quote__c sdq = SalesWorkflowValidationUtility.systemDesignQuoteWorkflowOnCreate(sysDesignQuote.System_Design__c , true);
        displayPopup = false;
        PageReference sdqPage = new PageReference('/apex/SystemDesignQuoteConfig?id='+sdq.Id);
        System.debug(loggingLevel.ERROR,'nEW sYSQUOTE** iD:' + sdq.Id);
        sdqPage.setRedirect(true);
        return sdqPage;
        
    }
    */

    /* 05/29/2015 PB JIRA-158 to add RecallSQ functionality on saving Utility Service, need to separate the transactions to 
    *  save utility,recall sitequality and create new quote.
    */
    public PageReference saveUtility(){
        utilityServErrors = '';
        // 1. Save Utility Service Changes 
        System.debug(utilityService);
        
        if(utilityService.Current_Usage_Type__c == 'Annual' 
           && utilityService.Annual_Electricity_Consumption_kWh__c != null 
           && utilityService.Annual_Electricity_Consumption_kWh__c > 0){
            
            Integer avgMonthConsumption = (utilityService.Annual_Electricity_Consumption_kWh__c/12).intValue();
            //update all monthly elec
            utilityService.Monthly_Electric_Consumption_KWH_Apr__c = avgMonthConsumption;
            utilityService.Monthly_Electric_Consumption_KWH_Aug__c = avgMonthConsumption;
            utilityService.Monthly_Electric_Consumption_KWH_Dec__c = avgMonthConsumption;
            utilityService.Monthly_Electric_Consumption_KWH_Feb__c = avgMonthConsumption;
            utilityService.Monthly_Electric_Consumption_KWH_Jan__c = avgMonthConsumption;
            utilityService.Monthly_Electric_Consumption_KWH_Jul__c = avgMonthConsumption;
            utilityService.Monthly_Electric_Consumption_KWH_Jun__c = avgMonthConsumption;
            utilityService.Monthly_Electric_Consumption_KWH_Mar__c = avgMonthConsumption;
            utilityService.Monthly_Electric_Consumption_KWH_May__c = avgMonthConsumption;
            utilityService.Monthly_Electric_Consumption_KWH_Nov__c = avgMonthConsumption;
            utilityService.Monthly_Electric_Consumption_KWH_Oct__c = avgMonthConsumption;
            utilityService.Monthly_Electric_Consumption_KWH_Sep__c = avgMonthConsumption;
        }
        
        update utilityService;
        
        // 2. Run Utility Pricing Processor
        UtilityPricingProcessor upp = new UtilityPricingProcessor(sysDesignQuote.System_Design__c,'Method_1');
        String utilityErrors = upp.getUtilityServiceMonthlyProduction(utilityService.Utility_Rate_Code_Before_Solar__c);
        
        if(utilityErrors != 'OK')
        {
            displayPopup = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Utility Pricing Error: '+utilityErrors));
            utilityServErrors = utilityErrors;
        }        
        return null;
        
    }

    /* 05/29/2015 PB JIRA-158 to add RecallSQ functionality on saving Utility Service, need to separate the transactions to 
    *  save utility,recall sitequality and create new quote.
    */
    public PageReference calcSQ(){
        System.debug(loggingLevel.ERROR,'In calcSQ');
        if(String.isNotBlank(utilityServErrors)){
            System.debug(loggingLevel.ERROR, 'Errors encountered');
            displayPopup = false;
            return null;
        }
        
        //Recall Astrum Site Quality
        System_Design__c sysDesign = [SELECT Astrum_Invalid_SQ_Error_Message__c,Astrum_SQ_Calculation_Status__c
                                        FROM System_Design__c 
                                       WHERE Id =:sysDesignQuote.System_Design__c]; 

        // RJ : Call SQ only if SQ became invalid
        if (sysDesign.Astrum_SQ_Calculation_Status__c == 'Invalid')
            SystemDesignSQCalculation.calculateSQ(sysDesign,'ASTRUM');
        
        //Validate system design
        System_Design__c validatedDesign = SalesWorkflowValidationUtility.runSystemDesignValidations(sysDesign, Date.today());

        sysDesign = [SELECT Valid__c,Validation_Errors__c,Astrum_SQ_Calculation_Status__c,Astrum_Invalid_SQ_Error_Message__c FROM System_Design__c WHERE Id =:sysDesignQuote.System_Design__c];
        System.debug(loggingLevel.ERROR,'ASTRUM SQStatus2:' + sysDesign.Astrum_SQ_Calculation_Status__c) ;
        if(sysDesign.Astrum_SQ_Calculation_Status__c == 'Invalid'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, sysDesign.Astrum_Invalid_SQ_Error_Message__c));
            displayPopup = false;
            return null;            
        }        

        if(validatedDesign.valid__c)
        {
            System_Design_Quote__c sdq = SalesWorkflowValidationUtility.systemDesignQuoteWorkflowOnCreate(sysDesignQuote.System_Design__c , true);
            PageReference sdqPage = new PageReference('/apex/SystemDesignQuoteConfig?id='+sdq.Id);
            sdqPage.setRedirect(true);
            displayPopup = false;
            return sdqPage;
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, validatedDesign.Validation_Errors__c));
            displayPopup = false;
            return null;
        }
    }    

    public PageReference saveCustomerInfo(){
        
        List<Contact> contactsToUpdate = new List<Contact>();
        List<OpportunityContactRole> contactRoles = new List<OpportunityContactRole>();
        for(ContactInfo contactInfo : contactInfos){
            contactsToUpdate.add(contactInfo.con);
            System.debug(loggingLevel.ERROR, 'primaryContactId:' + primaryContactId + ':contactInfo.contactRoleId:' + contactInfo.contactRoleId);
            if(String.isNotBlank(primaryContactId)){
                if(primaryContactId == contactInfo.con.Id){
                    contactInfo.isPrimary = true;
                }else{
                    contactInfo.isPrimary = false;
                }
            }
        }
        upsert contactsToUpdate;    //Changed update into upsert for CPQ-702

        for(ContactInfo contactInfo: contactInfos){
            contactRoles.add(new OpportunityContactRole(
                Id = contactInfo.contactRoleId, Role = contactInfo.role, IsPrimary = contactInfo.isPrimary, ContactId = contactInfo.con.Id, OpportunityId = contactInfo.oppId ));
        }
        upsert contactRoles;

        displayCustPopup = false;
        contactInfos = getSDQContactInfos();
        return null;
    }

    public pageReference saveAndConfig(){

        if(currentQuote != null)
        {
            //JIRA-429
            UtilityPricingProcessor upp = new UtilityPricingProcessor(currentQuote.System_Design__c,'Method_1');
            String utilityErrors = upp.getUtilityServiceMonthlyProduction(utilityService.Utility_Rate_Code_Before_Solar__c);
            
            if(utilityErrors != 'OK')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error in creating new quote: '+utilityErrors));
                return null;
            } 
            
            this.sysDesignQuote = makeNewSDQ(currentQuote.Id);          
            isSdqInsert = false; 
        }
        else
        {
            //JIRA-429
            UtilityPricingProcessor upp = new UtilityPricingProcessor(sysDesignQuote.System_Design__c,'Method_1');
            String utilityErrors = upp.getUtilityServiceMonthlyProduction(utilityService.Utility_Rate_Code_Before_Solar__c);
            
            if(utilityErrors != 'OK')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error in creating new quote: '+utilityErrors));
                return null;
            }
            
            System_Design__c sysDesign = new System_Design__c(id = sysDesignQuote.System_Design__c);
            String validSD = SalesWorkflowValidationUtility.validateSystemDesign(sysDesign, true, Date.today());    //Added date parameter for CPQ-751
            if(validSD == 'Valid')
            {
                this.sysDesignQuote = [Select id from System_Design_Quote__c where system_design__c = :sysDesign.Id and Current__c = true];    
            }  
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'System Design is Not Valid. Please correct the following errors - '+'\n'+validSD));
                return null;
            }          
            isSdqInsert = false; 
        }
        PageReference sdqPage = new PageReference('/apex/SystemDesignQuoteConfig?id='+sysDesignQuote.Id);
        sdqPage.setRedirect(true);
        return sdqPage;
    }
    
    private void resetLeaseN(String ScenarioN){
        sysDesignQuote.put('Scenario_' + ScenarioN + '_Lease_Fund__c', null);
        sysDesignQuote.put('Scenario_' + ScenarioN + '_Lease_Option__c', null);
        sysDesignQuote.put('Scenario_' + ScenarioN + '_Lease_Escalator__c', null);
        if(String.isBlank((String)sysDesignQuote.get('Scenario_' + ScenarioN + '_Term_Loan__c'))){
            sysDesignQuote.put('Scenario_' + ScenarioN + '_Down_Payment__c', 0);
            //sysDesignQuote.Scenario_1_Proposal_Term_Months__c = sysDesignQuote.Scenario_1_Term_Loan__r.Financing_Term_Months__c ;
        }else if(String.isBlank((String)sysDesignQuote.get('Scenario_' + ScenarioN + '_SAC_Loan__c'))){                 
            sysDesignQuote.put('Scenario_' + ScenarioN + '_SAC_Loan_Adjustment__c',null);
        }

        //Added on 10/16/15 to prevent previous SREC Contract Offers from applying to new financing types
        if (ScenarioN == '1'){
            getSRECContOffers('1', selectedSRECContOffer1, new Available_SREC_Contract_Offer__c[]{});
        } else if (ScenarioN == '2'){
            getSRECContOffers('2', selectedSRECContOffer2, new Available_SREC_Contract_Offer__c[]{});
        } else if (ScenarioN == '3'){
            getSRECContOffers('3', selectedSRECContOffer3, new Available_SREC_Contract_Offer__c[]{});
        } else if (ScenarioN == '4'){
            getSRECContOffers('4', selectedSRECContOffer4, new Available_SREC_Contract_Offer__c[]{});
        }

        //sysDesignQuote.put('Scenario_' + ScenarioN + '_Promotion_Cash_Rebate_Amount__c', 0);    //CPQ-543. No cash rebates allowed for Purchase options.
    }
    
    private void resetPurchaseN(String ScenarioN){
        
        sysDesignQuote.put('Scenario_' + ScenarioN + '_Term_Loan__c', null);
        sysDesignQuote.put('Scenario_' + ScenarioN + '_SAC_Loan__c', null);
        sysDesignQuote.put('Scenario_' + ScenarioN + '_SAC_Loan_Adjustment__c', null);
        sysDesignQuote.put('Scenario_' + ScenarioN + '_Available_SREC_Contract_Offer__c', null);

        //Added on 10/16/15 to prevent previous SREC Contract Offers from applying to new financing types
        if (ScenarioN == '1'){
            selectedSRECContOffer1 = null;
        } else if (ScenarioN == '2'){
            selectedSRECContOffer2 = null;
        } else if (ScenarioN == '3'){
            selectedSRECContOffer3 = null;
        } else if (ScenarioN == '4'){
            selectedSRECContOffer4 = null;
        }
              
        if (sysDesignQuote.get('Scenario_' + ScenarioN + '_Down_Payment__c') == null)
            sysDesignQuote.put('Scenario_' + ScenarioN + '_Down_Payment__c', 0);    //DK  06/16/15  CPQ-445

        if (sysDesignQuote.get('Scenario_' + ScenarioN + '_Lease_Option__c') == 'Portfolio PPA'){   //CPQ-745. Reset "Promotional Offer to Apply".
            sysDesignQuote.put('Scenario_' + ScenarioN + '_Set_Standard_Adjustment_Type__c', null);
            sysDesignQuote.put('Scenario_' + ScenarioN + '_Set_Standard_Adjustment_Amoun__c', null);
        }
    }
    
    public pageReference saveAndReturnPrice(){
        Map<ID, Price_Adjustment__c> programPriceAdjustments = new Map<ID, Price_Adjustment__c>();  //DK  8/13/15  CPQ-640
        for (Price_Adjustment__c pa : standardPriceAdjustments1){
            if (pa.Type__c == 'Program')
                programPriceAdjustments.put(pa.ID, pa);
        }
        for (Price_Adjustment__c pa : standardPriceAdjustments2){
            if (pa.Type__c == 'Program')
                programPriceAdjustments.put(pa.ID, pa);
        }
        for (Price_Adjustment__c pa : standardPriceAdjustments3){
            if (pa.Type__c == 'Program')
                programPriceAdjustments.put(pa.ID, pa);
        }
        for (Price_Adjustment__c pa : standardPriceAdjustments4){
            if (pa.Type__c == 'Program')
                programPriceAdjustments.put(pa.ID, pa);
        }
        Price_Adjustment__c[] programPriceAdjustmentsList = updateOptOutAdjustment(programPriceAdjustments.values());   //DK 10/06/15
        update programPriceAdjustmentsList;  //Update the Adjustment_Applied__c field on the Program Price Adjustments (Promotions)

        if(sysDesignQuote.Utility_Annual_Increase__c > 4){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Utility Rate Escalator cannot exceed 4%.'));
            return null;
        }else if(sysDesignQuote.Utility_Annual_Increase__c < 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Utility Rate Escalator cannot be below 0%.'));
            return null;            
        }
        
        //If Financing Type is Purchase Reset Lease and vice versa
        if(sysDesignQuote.Scenario_1_Financing_Type__c == 'Purchase'){
            resetLeaseN(String.valueOf(1));            
        }else if(sysDesignQuote.Scenario_1_Financing_Type__c == 'Lease' || sysDesignQuote.Scenario_1_Financing_Type__c == 'PPA'){
            resetPurchaseN(String.valueOf(1));    
        }
        if(sysDesignQuote.Scenario_2_Financing_Type__c == 'Purchase'){
            resetLeaseN(String.valueOf(2));            
        }else if(sysDesignQuote.Scenario_2_Financing_Type__c == 'Lease' || sysDesignQuote.Scenario_2_Financing_Type__c == 'PPA'){
            resetPurchaseN(String.valueOf(2));    
        }
        if(sysDesignQuote.Scenario_3_Financing_Type__c == 'Purchase'){
            resetLeaseN(String.valueOf(3));            
        }else if(sysDesignQuote.Scenario_3_Financing_Type__c == 'Lease' || sysDesignQuote.Scenario_3_Financing_Type__c == 'PPA'){
            resetPurchaseN(String.valueOf(3));    
        }
        if(sysDesignQuote.Scenario_4_Financing_Type__c == 'Purchase'){
            resetLeaseN(String.valueOf(4));            
        }else if(sysDesignQuote.Scenario_4_Financing_Type__c == 'Lease' || sysDesignQuote.Scenario_4_Financing_Type__c == 'PPA'){
            resetPurchaseN(String.valueOf(4));    
        }
        

        //Reset vpOverride Price Adjustments if Fin Type Changing - CPQ- 728
        if(oldSDQ != null  && oldSDQ.Scenario_1_Financing_Type__c != null && oldSDQ.Scenario_1_Financing_Type__c != sysDesignQuote.Scenario_1_Financing_Type__c ){
            sysDesignQuote.Scenario_1_VP_Sales_Adjustments__c = null ;
        }
        if(oldSDQ != null  && oldSDQ.Scenario_2_Financing_Type__c != null && oldSDQ.Scenario_2_Financing_Type__c != sysDesignQuote.Scenario_2_Financing_Type__c ){
            sysDesignQuote.Scenario_2_VP_Sales_Adjustments__c = null ;
        }
        if(oldSDQ != null  && oldSDQ.Scenario_3_Financing_Type__c != null && oldSDQ.Scenario_3_Financing_Type__c != sysDesignQuote.Scenario_3_Financing_Type__c ){
            sysDesignQuote.Scenario_3_VP_Sales_Adjustments__c = null ;
        }
        if(oldSDQ != null  && oldSDQ.Scenario_4_Financing_Type__c != null && oldSDQ.Scenario_4_Financing_Type__c != sysDesignQuote.Scenario_4_Financing_Type__c ){
            sysDesignQuote.Scenario_4_VP_Sales_Adjustments__c = null ;
        }

        //Reset vpOverride Price Adjustments
        if((vpOverridePriceAdjustments1.size() > 0 ) && (sysDesignQuote.Scenario_1_VP_Sales_Adjustments__c == null || (sysDesignQuote.Scenario_1_VP_Sales_Adjustments__c == 0))){
            vpOverridePriceAdjustments1[0].Adjustment_Applied__c = false;
        }
        if((vpOverridePriceAdjustments2.size() > 0 ) && (sysDesignQuote.Scenario_2_VP_Sales_Adjustments__c == null || (sysDesignQuote.Scenario_2_VP_Sales_Adjustments__c == 0))){
            vpOverridePriceAdjustments2[0].Adjustment_Applied__c = false;
        }
        if((vpOverridePriceAdjustments3.size() > 0 ) && (sysDesignQuote.Scenario_3_VP_Sales_Adjustments__c == null || (sysDesignQuote.Scenario_3_VP_Sales_Adjustments__c == 0))){
            vpOverridePriceAdjustments3[0].Adjustment_Applied__c = false;
        }
        if((vpOverridePriceAdjustments4.size() > 0 ) && (sysDesignQuote.Scenario_4_VP_Sales_Adjustments__c == null || (sysDesignQuote.Scenario_4_VP_Sales_Adjustments__c == 0))){
            vpOverridePriceAdjustments4[0].Adjustment_Applied__c = false;
        }
        
        // If the Site Quality is invalid submit it again.
        if(sysDesignQuote.System_Design__r.Astrum_SQ_Calculation_Status__c == 'Invalid')
        {
            System_Design__c sysDesign = new System_Design__c(id=sysDesignQuote.System_Design__c);
            SystemDesignSQCalculation.calculateSQ(sysDesign,'ASTRUM');
            
        }
        
        String sdValidationErrors = SalesWorkflowValidationUtility.systemDesignQuoteWorkflowOnEdit(sysDesignQuote, true);

        if(sdValidationErrors != 'Valid')
        {   
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'SD ValidationError: '+sdValidationErrors));
            return null;
        }


       //Apply Standard Adjustments
        if(sysDesignQuote.Scenario_1_Set_Standard_Adjustment_Type__c != '' && sysDesignQuote.Scenario_1_Set_Standard_Adjustment_Amoun__c != null)
        {
                sysDesignQuote.scenario_1_Apply_Standard_Adjustment__c = true;  
        }
        if(sysDesignQuote.Scenario_2_Set_Standard_Adjustment_Type__c != '' && sysDesignQuote.Scenario_2_Set_Standard_Adjustment_Amoun__c != null)
        {
                sysDesignQuote.scenario_2_Apply_Standard_Adjustment__c = true;  
        }
        if(sysDesignQuote.Scenario_3_Set_Standard_Adjustment_Type__c != '' && sysDesignQuote.Scenario_3_Set_Standard_Adjustment_Amoun__c != null)
        {
                sysDesignQuote.scenario_3_Apply_Standard_Adjustment__c = true;  
        }
        if(sysDesignQuote.Scenario_4_Set_Standard_Adjustment_Type__c != '' && sysDesignQuote.Scenario_4_Set_Standard_Adjustment_Amoun__c != null)
        {
                sysDesignQuote.scenario_4_Apply_Standard_Adjustment__c = true;  
        }

        //Price Adjustments
        List<Price_Adjustment__c> priceAdjustments = new List<Price_Adjustment__c>();

        //Update which price adjustments are opt-out
        List<Price_Adjustment__c> updatedEntitlements1 = updateOptOutAdjustment(entitlementPriceAdjustments1);
        List<Price_Adjustment__c> updatedEntitlements2 = updateOptOutAdjustment(entitlementPriceAdjustments2);
        List<Price_Adjustment__c> updatedEntitlements3 = updateOptOutAdjustment(entitlementPriceAdjustments3);
        List<Price_Adjustment__c> updatedEntitlements4 = updateOptOutAdjustment(entitlementPriceAdjustments4);

        //This fied is a projection of entitlement impacts to consultant's commission rate; subject to change upon Proposal, Contract and Sales Order creation
        sysDesignQuote.Scenario_1_Adder_Commission_Value__c = getAdderCommissionValue(updatedEntitlements1, 1);
        sysDesignQuote.Scenario_2_Adder_Commission_Value__c = getAdderCommissionValue(updatedEntitlements2, 2);
        sysDesignQuote.Scenario_3_Adder_Commission_Value__c = getAdderCommissionValue(updatedEntitlements3, 3);
        sysDesignQuote.Scenario_4_Adder_Commission_Value__c = getAdderCommissionValue(updatedEntitlements4, 4);

        priceAdjustments.addAll(updatedEntitlements1);
        priceAdjustments.addAll(updatedEntitlements2);
        priceAdjustments.addAll(updatedEntitlements3);
        priceAdjustments.addAll(updatedEntitlements4);
        priceAdjustments.addAll(updateOptOutAdjustment(vpOverridePriceAdjustments1));
        priceAdjustments.addAll(updateOptOutAdjustment(vpOverridePriceAdjustments2));
        priceAdjustments.addAll(updateOptOutAdjustment(vpOverridePriceAdjustments3));
        priceAdjustments.addAll(updateOptOutAdjustment(vpOverridePriceAdjustments4));        
        update priceAdjustments;

        //Incentives
        List<Available_Incentive_Offer__c> incentiveOffers = new List<Available_Incentive_Offer__c>();
        incentiveOffers.addAll(updateOptOutIncManually(incentiveOffers1));
        incentiveOffers.addAll(updateOptOutIncManually(incentiveOffers2));
        incentiveOffers.addAll(updateOptOutIncManually(incentiveOffers3));
        incentiveOffers.addAll(updateOptOutIncManually(incentiveOffers4));        
        update incentiveOffers;

        /*CPQ-460--- commented SREC
        List<Available_SREC_Contract_Offer__c> srecOffers = new List<Available_SREC_Contract_Offer__c>();
        srecOffers.addAll(updateSelectedSREC(srecOffers1,sysDesignQuote.Scenario_1_Available_SREC_Contract_Offer__c));
        srecOffers.addAll(updateSelectedSREC(srecOffers2,sysDesignQuote.Scenario_2_Available_SREC_Contract_Offer__c));
        srecOffers.addAll(updateSelectedSREC(srecOffers3,sysDesignQuote.Scenario_3_Available_SREC_Contract_Offer__c));
        srecOffers.addAll(updateSelectedSREC(srecOffers4,sysDesignQuote.Scenario_4_Available_SREC_Contract_Offer__c));        
        update srecOffers; */

        //CPQ-460
        //SREC
        List<Available_SREC_Contract_Offer__c> srecOffers = new List<Available_SREC_Contract_Offer__c>();
        updateAvlSREC(srecOffers, srecOffers1, selectedSRECContOffer1, '1');
        updateAvlSREC(srecOffers, srecOffers2, selectedSRECContOffer2, '2');
        updateAvlSREC(srecOffers, srecOffers3, selectedSRECContOffer3, '3');
        updateAvlSREC(srecOffers, srecOffers4, selectedSRECContOffer4, '4');
        
        update srecOffers;
        
        if (sysDesignQuote.As_Of_Pricing_Date__c != null){
            sysDesignQuote.Pricing_Date__c = sysDesignQuote.As_Of_Pricing_Date__c;
        } else {
            sysDesignQuote.Pricing_Date__c = System.now();
        }

        // 5. Save SDQ Changes and as a result Run pricing
        update sysDesignQuote;
        
        Map<Integer, List<Object>> sightenScenarios = SightenAPIIntegrator.GetSightenScenariosAndPayments(sysDesignQuote.Id);
        scenario1IsSighten = Boolean.valueOf(sightenScenarios.get(1)[0]);
        scenario2IsSighten = Boolean.valueOf(sightenScenarios.get(2)[0]);
        scenario3IsSighten = Boolean.valueOf(sightenScenarios.get(3)[0]);
        scenario4IsSighten = Boolean.valueOf(sightenScenarios.get(4)[0]);

        scenario1ACHOption = (sysDesignQuote.Scenario_1_Term_Loan__r.APR__c != null && sysDesignQuote.Scenario_1_Term_Loan__r.Non_ACH_APR__c != null) 
            || (sysDesignQuote.Scenario_1_Term_Loan__r.Monthly_Interest_Rate__c != null && sysDesignQuote.Scenario_1_Term_Loan__r.Non_ACH_Monthly_Interest_Rate__c != null);
        scenario2ACHOption = (sysDesignQuote.Scenario_2_Term_Loan__r.APR__c != null && sysDesignQuote.Scenario_2_Term_Loan__r.Non_ACH_APR__c != null) 
            || (sysDesignQuote.Scenario_2_Term_Loan__r.Monthly_Interest_Rate__c != null && sysDesignQuote.Scenario_2_Term_Loan__r.Non_ACH_Monthly_Interest_Rate__c != null);
        scenario3ACHOption = (sysDesignQuote.Scenario_3_Term_Loan__r.APR__c != null && sysDesignQuote.Scenario_3_Term_Loan__r.Non_ACH_APR__c != null) 
            || (sysDesignQuote.Scenario_3_Term_Loan__r.Monthly_Interest_Rate__c != null && sysDesignQuote.Scenario_3_Term_Loan__r.Non_ACH_Monthly_Interest_Rate__c != null);
        scenario4ACHOption = (sysDesignQuote.Scenario_4_Term_Loan__r.APR__c != null && sysDesignQuote.Scenario_4_Term_Loan__r.Non_ACH_APR__c != null) 
            || (sysDesignQuote.Scenario_4_Term_Loan__r.Monthly_Interest_Rate__c != null && sysDesignQuote.Scenario_4_Term_Loan__r.Non_ACH_Monthly_Interest_Rate__c != null);

        PageReference sdqPage = new PageReference('/apex/SystemDesignQuoteConfig?id='+sysDesignQuote.Id);
        sdqPage.setRedirect(true);

        return sdqPage;
    }

    //cpq-460
    private void updateAvlSREC(List<Available_SREC_Contract_Offer__c> srecsToUpdate, List<Available_SREC_Contract_Offer__c> srecOffers, String selectedSRECContOffer, String scenarioN ){
        if(srecOffers != null && srecOffers.size() > 0){
            srecsToUpdate.addAll(updateSelectedSRECOffer(srecOffers,selectedSRECContOffer,scenarioN));
            if(String.isBlank(selectedSRECContOffer)){
                sysDesignQuote.put('Scenario_' + scenarioN + '_Available_SREC_Contract_Offer__c', null);
            }
        }else if(String.isNotBlank(selectedSRECContOffer)){
            sysDesignQuote.put('Scenario_' + scenarioN + '_Available_SREC_Contract_Offer__c', (createAvailableSREC(selectedSRECContOffer,scenarioN)).Id);
        }

    }

    //cpq-460
    public Available_SREC_Contract_Offer__c createAvailableSREC(Id srecId, String scenarioN){

        SREC_Contract_Offer__c srec = mapSREC.get(srecId);
        Map<String, Schema.RecordTypeInfo> srecOfferRTMap = Schema.SObjectType.Available_SREC_Contract_Offer__c.getRecordTypeInfosByName();
        Available_SREC_Contract_Offer__c aco = new Available_SREC_Contract_Offer__c();
        aco.Contract_Offer_Applied__c = true;
        aco.Name = srec.Name;
        aco.Current_Matching_SREC_Offer__c = true;
        aco.SREC_Contract_Offer__c = srecId;
        aco.Applicable_Scenario__c = string.valueof(scenarioN);
        String srecRecType = srec.RecordType.Name == 'Upfront Cash Back' ? 'Upfront' : srec.RecordType.Name;
        aco.RecordTypeID = srecOfferRTMap.get(srecRecType).getRecordTypeID();            
        aco.System_Design_Quote__c = sysDesignQuote.id;
        insert aco;
        return aco;
    }

    //cpq-460
    public List<Available_SREC_Contract_Offer__c> updateSelectedSRECOffer(List<Available_SREC_Contract_Offer__c> availOffers , String selectedOffer, String scenarioN){
        
        for(Available_SREC_Contract_Offer__c offer : availOffers)
        {
                if(String.isNotBlank(selectedOffer) && offer.SREC_Contract_Offer__c == selectedOffer )
                {
                        offer.Contract_Offer_Applied__c = true;
                        sysDesignQuote.put('Scenario_' + scenarioN + '_Available_SREC_Contract_Offer__c', offer.Id);
                
                }
                else
                {
                        offer.Contract_Offer_Applied__c = false;
                }
        }
        
        return availOffers;
        
    }

    public List<Price_Adjustment__c> updateOptOutAdjustment(List<Price_Adjustment__c> priceAdjustments){
        
        for(Price_Adjustment__c pa : priceAdjustments)
        {
                if(!pa.Adjustment_Applied__c)
                {
                        pa.Opt_Out_of_Adjustment__c = true;
                }
                else
                {
                        pa.Opt_Out_of_Adjustment__c = false;    
                }
        }
        
        return priceAdjustments;
        
    }
    
    public List<Available_Incentive_Offer__c> updateOptOutIncManually(List<Available_Incentive_Offer__c> availIncentives){
        
        for(Available_Incentive_Offer__c io : availIncentives)
        {
                if(!io.Incentive_Applied__c)
                {
                        io.Opted_Out_Manually__c = true;
                }
                else
                {
                        io.Opted_Out_Manually__c = false;
                }
        }
        
        return availIncentives;
        
    }
    /* cpq-460 commented
    public List<Available_SREC_Contract_Offer__c> updateSelectedSREC(List<Available_SREC_Contract_Offer__c> availOffers , Id selectedOffer){
        
        for(Available_SREC_Contract_Offer__c io : availOffers)
        {
                if(selectedOffer != null && io.id == selectedOffer )
                {
                        io.Contract_Offer_Applied__c = true;
                }
                else
                {
                        io.Contract_Offer_Applied__c = false;
                }
        }
        
        return availOffers;
        
    }*/    

    public Decimal getAdderCommissionValue(List<Price_Adjustment__c> entitlementOffers, Integer scenario){      //DK  06/03/15  CPQ-222
        Decimal sum = 0;    //Sum the entitlements according to which of its fields are not null
        for (Price_Adjustment__c pa : entitlementOffers){
            Decimal effectiveDollarAmount = pa.Effective_Dollar_Amount__c != null ? pa.Effective_Dollar_Amount__c : 0;  //Being extra safe
            if (pa.Entitlement_Offer__r.Commission_Impact__c != null){
                sum += pa.Entitlement_Offer__r.Commission_Impact__c;
            } else if (pa.Entitlement_Offer__r.Commission_Impact_Percent__c != null){
                sum += (pa.Entitlement_Offer__r.Commission_Impact_Percent__c / 100) * effectiveDollarAmount;
            } else if (pa.Entitlement_Offer__r.Commission_Impact_W__c != null){
                sum += pa.Entitlement_Offer__r.Commission_Impact_W__c * (sysDesignQuote.System_Size_kW__c * 1000);
            } else if (pa.Entitlement_Offer__r.Commission_Impact_Sliding_Scale_Applied__c == true){
                Decimal baseCommissionPercent = sysDesignQuote.get('Scenario_' + scenario + '_Base_Commission_Percent__c') != null ? (Decimal)sysDesignQuote.get('Scenario_' + scenario + '_Base_Commission_Percent__c') : 0;
                sum += (baseCommissionPercent / 100) * effectiveDollarAmount;    //Scenario N Base Commission (%) is a formula, and therefore never null
            }
        }
        return sum;
    }

    public PageReference makeCurrent( ) {        
        
        String makeCurrentError = SalesWorkflowValidationUtility.systemDesignQuoteWorkflowMakeCurrent(sysDesignQuote);
        if(makeCurrentError != 'Valid')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Stored State of this System Design has been altered, and therefore cannot be made Current.'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Make Current Error: '+makeCurrentError));
            isMakeCurrentValid = false;
            return null;
        }
        //JIRA-429
        UtilityPricingProcessor upp = new UtilityPricingProcessor(sysDesignQuote.System_Design__c,'Method_1');
        String utilityErrors = upp.getUtilityServiceMonthlyProduction(utilityService.Utility_Rate_Code_Before_Solar__c);
        
        if(utilityErrors != 'OK')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Make Current Error: '+utilityErrors));
            return null;
        } 
        PageReference sdqPage = new PageReference('/apex/SystemDesignQuoteConfig?id='+sysDesignQuote.Id);
        sdqPage.setRedirect(true);
        return sdqPage;
        
    }
    

    public System_Design_Quote__c makeNewSDQ(String sdqId){     //Takes an SDQ as a parameter, and creates a new SDQ based off of it
        System_Design_Quote__c baseSDQ;
        baseSDQ = [SELECT System_Design__c,All_Electric_Service__c, Annual_Property_Tax_Bill__c, Electric_Vehicle__c, Income_Corporate_Tax_Rate__c,
                           Primary_Residence__c, Primary_Residence_Req__c, Property_in_Revocable_Trust__c, Property_in_Revocable_Trust_Req__c, Utility_Annual_Increase__c, 
                           Property_in_Historic_Trust__c, Property_in_Historic_Trust_Req__c, Previously_Received_State_Rebate__c, Previously_Received_State_Rebate_Req__c,
                           Previously_Received_State_Tax_Credit__c, Previously_Received_State_Tax_Credit_Req__c, Previously_Received_Utility_Rebate__c, Previously_Received_Utility_Rebate_Req__c,
                           Previously_Received_County_Tax_Req__c, Previously_Received_County_Tax_Credit__c,Community_Program_Offer__c, System_Design__r.System_Makeup__c
                      FROM System_Design_Quote__c 
                     WHERE Id = :sdqId LIMIT 1];

        System_Design_Quote__c newSdq = SalesWorkflowValidationUtility.systemDesignQuoteWorkflowOnCreate(baseSDQ.System_Design__c, false);

        newSdq.All_Electric_Service__c = baseSDQ.All_Electric_Service__c;
        newSdq.Annual_Property_Tax_Bill__c = baseSDQ.Annual_Property_Tax_Bill__c;
        newSdq.Electric_Vehicle__c = baseSDQ.Electric_Vehicle__c;
        newSdq.Income_Corporate_Tax_Rate__c = baseSDQ.Income_Corporate_Tax_Rate__c;
        newSdq.Primary_Residence__c = baseSDQ.Primary_Residence__c;
        newSdq.Primary_Residence_Req__c = baseSDQ.Primary_Residence_Req__c;
        newSdq.Property_in_Revocable_Trust__c = baseSDQ.Property_in_Revocable_Trust__c;
        newSdq.Property_in_Revocable_Trust_Req__c = baseSDQ.Property_in_Revocable_Trust_Req__c;
        newSdq.Utility_Annual_Increase__c = baseSDQ.Utility_Annual_Increase__c;
        newSdq.Property_in_Historic_Trust__c = baseSDQ.Property_in_Historic_Trust__c;
        newSdq.Property_in_Historic_Trust_Req__c = baseSDQ.Property_in_Historic_Trust_Req__c;
        newSdq.Previously_Received_State_Rebate__c = baseSDQ.Previously_Received_State_Rebate__c;
        newSdq.Previously_Received_State_Rebate_Req__c = baseSDQ.Previously_Received_State_Rebate_Req__c;
        newSdq.Previously_Received_State_Tax_Credit__c = baseSDQ.Previously_Received_State_Tax_Credit__c;
        newSdq.Previously_Received_State_Tax_Credit_Req__c = baseSDQ.Previously_Received_State_Tax_Credit_Req__c;
        newSdq.Previously_Received_Utility_Rebate__c = baseSDQ.Previously_Received_Utility_Rebate__c;
        newSdq.Previously_Received_Utility_Rebate_Req__c = baseSDQ.Previously_Received_Utility_Rebate_Req__c;
        newSdq.Previously_Received_County_Tax_Req__c = baseSDQ.Previously_Received_County_Tax_Req__c;
        newSdq.Previously_Received_County_Tax_Credit__c = baseSDQ.Previously_Received_County_Tax_Credit__c;
        newSdq.Community_Program_Offer__c = baseSDQ.Community_Program_Offer__c;
        //CPQ-590
        newSdq.System_Makeup__c = baseSDQ.System_Design__r.System_Makeup__c;

        
        try {
            insert newSdq;
        } catch (Exception ex) {
            system.debug(LoggingLevel.DEBUG, 'Error in makeNewSDQ(): ' + ex.getStackTraceString());
            return null;
        }
        return newSdq;
    }

    public class pricingCalc
    {
        public String pricingLabel {get; set;}
        public Decimal pricingValue {get; set;}
        public String valType {get; set;}
        public pricingCalc(String l , Decimal v, String valType)
        {
            pricingLabel = l;
            pricingValue = v;
            this.valType = valType;
        }

    }    
    
    public void closePopup() {        
        displayPopup = false;    
    }
    
    public void showPopup() {        
        displayPopup = true;    
    }
    
    public void closeCustPopup() {        
        displayCustPopup = false;    
    }
    
    public void showCustPopup() { 
        //contactInfos = getSDQContactInfos();
        displayCustPopup = true;    
    }

    public void showPageMessage() {
      if(level == 'WARNING') {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, message));
      }
      if(level == 'ERROR') {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
      }
    }
    
    @RemoteAction
    public static Boolean insertAttachment(String imgData, String imgName, String parentID){
        System.debug('Insert Attachement');
        Boolean imgInserted = false;
        if (imgData.length() > 0) {
            Attachment imgFile = new Attachment();

            // break string into parts
            Integer pos1 = imgData.indexOf(':');
            Integer pos2 = imgData.indexOf(';', pos1);
            Integer pos3 = imgData.indexOf(',', pos2);

            // decode the base64 encoded image
            imgFile.Body = EncodingUtil.base64Decode(imgData.substring(pos3+1));

            imgFile.ContentType = imgData.substring((pos1+1), pos2);
            imgFile.Name = imgName;
            imgFile.ParentId = parentID;

            Attachment[] existingAttchs = new Attachment[]{};       //[SELECT ID FROM Attachment WHERE ParentID = :parentID AND Name = :imgName LIMIT 1];
            if (existingAttchs.isEmpty()){
                try {
                    insert imgFile;
                    imgInserted = true;
                } catch (Exception e) {
                    System.debug('Error in insertAttachment(): ' + e.getStackTraceString());
                }
            }
        }
        return imgInserted;
    }

    //----------- Custom Utility Rate [CPQ-224] -----------//
    private Rate_Period__c[] ratePeriods;
    private Utility_Company__c[] beforeSolarRateCode;
    public Boolean displayPopup3 {get; set;}
    public String[] customRates { 
        get {
            if (customRates == null)
                customRates = new String[]{'', '', '', '', ''};    //Initialize with five empty strings; one for each tier
            return customRates;
        } set;
    }
    public String customRateResultMsg {get; set;}

    public void showPopup3(){
        closePopup();   //Exit the "Utility Service and Usage" popup that this was opened from
        customRateResultMsg = '';
        ratePeriods = [SELECT Tier_1_Rate_kWh__c, Tier_2_Rate_kWh__c, Tier_3_Rate_kWh__c, Tier_4_Rate_kWh__c, Tier_5_Rate_kWh__c, 
                       Period_Type__c, Rate__c, Rate_Period__c FROM Rate_Period__c WHERE Utility_Company__c = :utilityService.Utility_Rate_Code_Before_Solar__c];
        beforeSolarRateCode = [SELECT Tier_1_Cap__c, Tier_2_Cap__c, Tier_3_Cap__c, Tier_4_Cap__c, Tier_5_Cap__c, Baseline_Consumption_kWh_day__c, Baseline_Consumption_kWh_month__c 
                               FROM Utility_Company__c WHERE ID = :utilityService.Utility_Rate_Code_Before_Solar__c LIMIT 1];
        displayPopup3 = true;
    }

    public void closePopup3(){
        customRateResultMsg = '';
        displayPopup3 = false;
    }

    public String getCurrentTierRate(Integer tierNum, Rate_Period__c[] ratePeriodArray){
        Decimal tierSum = 0;
        Integer numValues = 0;
        for (Rate_Period__c rp : ratePeriodArray){
            if (rp.get('Tier_' + tierNum + '_Rate_kWh__c') != null){
                tierSum += (Decimal)rp.get('Tier_' + tierNum + '_Rate_kWh__c');
                numValues++;
            }
        }
        String returnVal = '';
        if (numValues != 0){
            Decimal avgTierRate = tierSum / Decimal.valueOf(numValues);
            returnVal = String.valueOf(avgTierRate.setScale(4));
        }
        return returnVal;
    }
    public String getCurrentTier1Rate(){
        return getCurrentTierRate(1, ratePeriods);
    }
    public String getCurrentTier2Rate(){
        return getCurrentTierRate(2, ratePeriods);
    }
    public String getCurrentTier3Rate(){
        return getCurrentTierRate(3, ratePeriods);
    }
    public String getCurrentTier4Rate(){
        return getCurrentTierRate(4, ratePeriods);
    }
    public String getCurrentTier5Rate(){
        return getCurrentTierRate(5, ratePeriods);
    }

    public String getTierRateCap(Integer tierNum){
        String returnVal = '';
        if (!beforeSolarRateCode.isEmpty()){
            Utility_Company__c urc = beforeSolarRateCode[0];
            String dataStr;
            if (urc.Baseline_Consumption_kWh_day__c != 'NA' && urc.Baseline_Consumption_kWh_day__c != 'N/A' && String.isNotBlank(urc.Baseline_Consumption_kWh_day__c)){
                dataStr = urc.Baseline_Consumption_kWh_day__c;
            } else if (urc.Baseline_Consumption_kWh_month__c != 'NA' && urc.Baseline_Consumption_kWh_month__c != 'N/A' && String.isNotBlank(urc.Baseline_Consumption_kWh_month__c)){
                dataStr = urc.Baseline_Consumption_kWh_month__c;
            }
            if (dataStr != null){
                Decimal totalConsumption = 0;
                Integer numValues = 0;
                for (String str : dataStr.split('; ', 0)){
                    try {
                        totalConsumption += String.isNotBlank(str) ? Decimal.valueOf(str) : 0;
                        numValues++;
                    } catch (Exception e){ System.debug('Baseline Consumption error: ' + e.getStackTraceString()); }
                }
                //URC.Tier N Cap * Avg(URC.Baseline_Consumption_kWh_Day OR URC.Baseline_Consumption_kWh_Month) where Baseline value is not 'N/A'
                if (numValues != 0 && urc.get('Tier_' + tierNum + '_Cap__c') != null){
                    Decimal avgConsumption = totalConsumption / Decimal.valueOf(numValues);
                    returnVal = String.valueOf(((Decimal)urc.get('Tier_' + tierNum + '_Cap__c') * avgConsumption).setScale(0)) + ' kWh';
                }
            }
        }
        return returnVal;
    }
    public String getTier1RateCap(){
        return getTierRateCap(1);
    }
    public String getTier2RateCap(){
        return getTierRateCap(2);
    }
    public String getTier3RateCap(){
        return getTierRateCap(3);
    }
    public String getTier4RateCap(){
        return getTierRateCap(4);
    }
    public String getTier5RateCap(){
        return getTierRateCap(5);
    }

    public PageReference createCustomRateCode(){
        customRateResultMsg = '';   //Reset

        //First, find the Rate Periods for the existing STANDARD Rate Code
        Rate_Period__c[] ratePeriodArray;
        if (utilityService.Utility_Rate_Code_Before_Solar__r.RecordType.Name == 'Standard'){
            ratePeriodArray = ratePeriods;  //We have already queried the pertinent records
        } else if (utilityService.Utility_Company__r.RecordType.Name == 'Standard'){
            ratePeriodArray = [SELECT Tier_1_Rate_kWh__c, Tier_2_Rate_kWh__c, Tier_3_Rate_kWh__c, Tier_4_Rate_kWh__c, Tier_5_Rate_kWh__c FROM Rate_Period__c WHERE Utility_Company__c = :utilityService.Utility_Company__c];
        } else {
            ratePeriodArray = ratePeriods;  //Worst case scenario
        }

        Decimal[] customRatesNumeric = new Decimal[]{};
        for (Integer i = 1; i <= customRates.size(); i++){
            String newTierRate = customRates[i-1];
            if (getCurrentTierRate(i, ratePeriodArray) != '' && String.isEmpty(newTierRate)){
                customRateResultMsg = 'Please enter a Custom Rate for Tier ' + i + '.';
                return null; 
            }
            if (getCurrentTierRate(i, ratePeriodArray) == '' && String.isNotEmpty(newTierRate)){
                customRateResultMsg = 'The current Standard Rate has no Tier ' + i + ' value, and therefore the Custom Rate must not either.';
                return null; 
            }
            if (newTierRate.contains('-')){
                customRateResultMsg = 'Tier ' + i + ' cannot have a negative value.';
                return null; 
            }
            if (newTierRate.countMatches('.') > 1){
                customRateResultMsg = 'The value in Tier ' + i + ' is an improperly formatted decimal.';
                return null; 
            }
            
            if (String.isNotEmpty(newTierRate)){
                if (!newTierRate.remove('.').isNumeric()){
                    customRateResultMsg = 'The value in Tier ' + i + ' is not numeric.';
                    return null;
                }
                customRatesNumeric.add(Decimal.valueOf(newTierRate).setScale(4));
            }
        }

        //Perform validation rules
        Custom_Utility_Rate_Settings__c rateSetting = Custom_Utility_Rate_Settings__c.getOrgDefaults();
        if (!Test.isRunningTest()){     //This is to circumvent an enigmatic "System.UnexpectedException: Illegal arguments" error that might possibly be a Salesforce platform bug
            for (Integer i = 1; i <= customRatesNumeric.size(); i++){
                Decimal newRate = customRatesNumeric[i-1];
                if (newRate < rateSetting.Minimum_Tier_Rate__c)
                    customRateResultMsg += 'Minimum Custom Tier Rate must be at least ' + rateSetting.Minimum_Tier_Rate__c + '. Please adjust Tier ' + i + '.<br/>';
                if (newRate > rateSetting.Maximum_Tier_Rate__c)
                    customRateResultMsg += 'Maximum Custom Tier Rate must not exceed ' + rateSetting.Maximum_Tier_Rate__c + '. Please adjust Tier ' + i + '.<br/>';
                
                Decimal currentRate = Decimal.valueOf(getCurrentTierRate(i, ratePeriodArray));   //Will not be blank due to previous validation
                if (currentRate + rateSetting.Maximum_Tier_Rate_Increase__c < newRate)
                    customRateResultMsg += 'Maximum Tier Rate increase must not exceed ' + rateSetting.Maximum_Tier_Rate_Increase__c + '. Please adjust Tier ' + i + '. (The old Tier value is ' + currentRate + ').<br/>';
                if (currentRate - rateSetting.Maximum_Tier_Rate_Decrease__c > newRate)
                    customRateResultMsg += 'Maximum Tier Rate decrease must not exceed ' + rateSetting.Maximum_Tier_Rate_Decrease__c + '. Please adjust Tier ' + i + '. (The old Tier value is ' + currentRate + ').<br/>';
            }
        }
        if (customRateResultMsg != '')
            return null;

        String almostAllRateCodeFields = 'All_Electric_Service__c, Average_Consumption_Profile__c, Baseline_Consumption_kWh_day__c, Baseline_Consumption_kWh_month__c, CPF_Rate_Code_Id__c, ' + 
                                'Daily_Fixed_Charge__c, Daily_Minimum_Bill__c, Day_Shifted_Consumption_Profile__c, Default_Rate_Code__c, Description__c, ' + 
                                'Electric_Vehicle_Discount_kWh__c, Externally_Available__c, Externally_Available_Master__c, Monthly_Fixed_Charge__c, Monthly_Minimum_Bill__c, ' + 
                                'Night_Shifted_Consumption_Profile__c, Over_Production_Credit__c, Over_Production_Credit_Rate__c, Period_1__c, Period_2__c, Period_3__c, ' + 
                                'Period_4__c, Period_5__c, Rate__c, Rate_Code__c, Sector__c, Service_Amp_Reliability_Charge_100A__c, Service_Amp_Reliability_Charge_400A__c, ' + 
                                'Service_Amp_Reliability_Charge_101_200A__c, Service_Amp_Reliability_Charge_201_400A__c, State_Serviced__c, State_Serviced_Master__c, States_Serviced__c, ' + 
                                'Tier_1_Cap__c, Tier_2_Cap__c, Tier_3_Cap__c, Tier_4_Cap__c, Tier_5_Cap__c, Utility_Company_Master__c, Utility_Rate_Code__c, Utility_Service_Territory__c, ' + 
                                'Value_of_Solar_Tariiff__c, Weekday_Schedule__c, Weekend_Schedule__c, RecordType.Name';
        Utility_Company__c oldBeforeRateCode = Database.query('SELECT ' + almostAllRateCodeFields + ' FROM Utility_Company__c WHERE ID = \'' + utilityService.Utility_Rate_Code_Before_Solar__c + '\' LIMIT 1');
        Utility_Company__c newCustomRateCode = oldBeforeRateCode.clone(false, true, false, false);  //Base the custom rate code off of the existing "before rate code"
        newCustomRateCode.Name = 'CUSTOM-RATE-' + thisUser.Alias + '-' + getPropertyInfo().Name;
        newCustomRateCode.Default_Rate_Code__c = false;
        RecordType customRateCodeRecType = [SELECT ID FROM RecordType WHERE sObjectType = 'Utility_Company__c' AND Name = 'Custom' LIMIT 1];
        newCustomRateCode.RecordTypeID = customRateCodeRecType.ID;

        insert newCustomRateCode;

        //Update the Utility Service
        utilityService.Custom_Utility_Rate_Set_By__c = thisUser.ID;
        utilityService.Utility_Rate_Code_Before_Solar__c = newCustomRateCode.ID;
        utilityService.Utility_Rate_Code_After_Solar__c = newCustomRateCode.ID;
        if (oldBeforeRateCode.RecordType.Name == 'Standard')
            utilityService.Utility_Company__c = oldBeforeRateCode.ID;   //Set up an audit trail so that we know what the original Rate Code was        

        UtilityServiceTriggerHandler.skipUtilityServiceTriggerSDValidation = true; // this will skip the SQ to become invalid
        update utilityService;
        UtilityServiceTriggerHandler.skipUtilityServiceTriggerSDValidation = false; 

        //Insert new Rate Period(s) for the Custom Rate Code using user input
        Rate_Period__c[] newRatePeriods = new Rate_Period__c[]{};
        for (Rate_Period__c rp : ratePeriods){
            Rate_Period__c cloned_rp = rp.clone(false, true, false, false);
            cloned_rp.Name = 'User Defined Rate Period';
            cloned_rp.Utility_Company__c = newCustomRateCode.ID;
            //Reset all tier rate fields before we repopulate the ones we have values for
            cloned_rp.Tier_1_Rate_kWh__c = null;
            cloned_rp.Tier_2_Rate_kWh__c = null;
            cloned_rp.Tier_3_Rate_kWh__c = null;
            cloned_rp.Tier_4_Rate_kWh__c = null;
            cloned_rp.Tier_5_Rate_kWh__c = null;
            for (Integer i = 1; i <= customRatesNumeric.size(); i++){
                cloned_rp.put('Tier_' + i + '_Rate_kWh__c', customRatesNumeric[i-1]);
            }
            newRatePeriods.add(cloned_rp);
        }
        insert newRatePeriods;

        //Run Utility Pricing and create new SDQ
        PageReference pg = makeNewQuote();
        if (pg != null)
            displayPopup3 = false;
        return pg;
    }
    //-------------------------------------------//

    @RemoteAction
    public static String[] generatePreviewProposal(String sdqID, String sdID, String utilServiceID, Boolean includeScenario1, Boolean includeScenario2, Boolean includeScenario3, Boolean includeScenario4, String propExpireDays){  
        //Validate the Proposal's expiration date
        Integer defaultDaysValid;
        try {
            defaultDaysValid = Integer.valueOf(System_Design_Quote_Settings__c.getOrgDefaults().Days_Proposal_Valid__c);
        } catch (Exception e){}
        if (defaultDaysValid == null)
            defaultDaysValid = 21;
        
        String[] appliedScenarios = new String[]{};
        if (includeScenario1) appliedScenarios.add('1');
        if (includeScenario2) appliedScenarios.add('2');
        if (includeScenario3) appliedScenarios.add('3');
        if (includeScenario4) appliedScenarios.add('4');

        Price_Adjustment__c[] programDiscounts = [SELECT Amount__c, Promotion__r.Start_Date__c, Promotion__r.End_Date__c FROM Price_Adjustment__c WHERE Type__c = 'Program' AND 
                                                  System_Design_Quote__c = :sdqID AND Adjustment_Applied__c = true AND Promotion__r.End_Date__c >= TODAY AND 
                                                  Applicable_Scenario__c IN :appliedScenarios ORDER BY Promotion__r.End_Date__c ASC];
        Integer maxExpirationDays = defaultDaysValid;
        if (programDiscounts != null && !programDiscounts.isEmpty())
            maxExpirationDays = Date.today().daysBetween(programDiscounts[0].Promotion__r.End_Date__c);     //Automatically set to the earliest Program Discount end date
        
        if (String.isBlank(propExpireDays))     //Replace a null value with a default value
            propExpireDays = String.valueOf(Math.min(defaultDaysValid, maxExpirationDays));
        
        Integer expirationDays;
        try {
            expirationDays = Integer.valueOf(propExpireDays);
        } catch (Exception e){
            return new String[]{'Invalid number entered for `Days Until Proposal Expires`.', ''};
        }

        if (expirationDays < 0 || expirationDays > Math.min(defaultDaysValid, maxExpirationDays)){
            if (Math.min(defaultDaysValid, maxExpirationDays) == 0){
                return new String[]{'A Program Discount is expiring today, so the Proposal must be set to expire today as well. Please enter a value of 0 for the Proposal expiration days.', ''};
            } else {
                return new String[]{'Due to an upcoming Program Discount expiration date or the default setting for Proposals, the Proposal expiration date must be ' + 
                                    'between 0 and ' + Math.min(defaultDaysValid, maxExpirationDays) + ' days from today. (Leave blank for autocompletion).', ''}; 
            }
        }

        if (programDiscounts != null && !programDiscounts.isEmpty()){   //See JIRA ticket CPQ-416
            Date propExpirationDate = Date.today().addDays(expirationDays);
            if (propExpirationDate > programDiscounts[0].Promotion__r.End_Date__c){     //Proposal Expiration Date is later than the earliest Program Discount end date
                Boolean withinDateRange = false;
                Decimal discountAmount = programDiscounts[0].Amount__c;     //Taken from the Program Discount with the earliest end date
                for (Price_Adjustment__c pa : programDiscounts){
                    if (pa.Amount__c == discountAmount && propExpirationDate >= pa.Promotion__r.Start_Date__c && propExpirationDate <= pa.Promotion__r.End_Date__c){
                        withinDateRange = true;
                        break;
                    }
                }
                if (!withinDateRange)
                    return new String[]{'The Proposal Expiration Date cannot be later than the Program Discount end date of ' + 
                                        programDiscounts[0].Promotion__r.End_Date__c.format() + ' unless another Program Discount of $' + 
                                        discountAmount + ' is set to expire at a later or equal date as the Proposal.', ''};
            }
        }

        //Get fields for chart data
        System_Design__c sd = [SELECT Method_1_Jan_Peak_kWh__c,Method_1_Feb_Peak_kWh__c,Method_1_Mar_Peak_kWh__c,Method_1_Apr_Peak_kWh__c,Method_1_May_Peak_kWh__c,Method_1_Jun_Peak_kWh__c,Method_1_Jul_Peak_kWh__c,
                    Method_1_Aug_Peak_kWh__c,Method_1_Sep_Peak_kWh__c,Method_1_Oct_Peak_kWh__c,Method_1_Nov_Peak_kWh__c,Method_1_Dec_Peak_kWh__c,Method_1_Jan_Part_Peak_kWh__c,Method_1_Feb_Part_Peak_kWh__c,
                    Method_1_Mar_Part_Peak_kWh__c,Method_1_Apr_Part_Peak_kWh__c,Method_1_May_Part_Peak_kWh__c,Method_1_Jun_Part_Peak_kWh__c,Method_1_Jul_Part_Peak_kWh__c,Method_1_Aug_Part_Peak_kWh__c,
                    Method_1_Sep_Part_Peak_kWh__c,Method_1_Oct_Part_Peak_kWh__c,Method_1_Nov_Part_Peak_kWh__c,Method_1_Dec_Part_Peak_kWh__c,Method_1_Jan_Off_Peak_kWh__c,Method_1_Feb_Off_Peak_kWh__c,
                    Method_1_Mar_Off_Peak_kWh__c,Method_1_Apr_Off_Peak_kWh__c,Method_1_May_Off_Peak_kWh__c,Method_1_Jun_Off_Peak_kWh__c,Method_1_Jul_Off_Peak_kWh__c,Method_1_Aug_Off_Peak_kWh__c,Method_1_Sep_Off_Peak_kWh__c, 
                    Method_1_Oct_Off_Peak_kWh__c,Method_1_Nov_Off_Peak_kWh__c,Method_1_Dec_Off_Peak_kWh__c,Method_1_Jan_Flat_kWh__c,Method_1_Feb_Flat_kWh__c,Method_1_Mar_Flat_kWh__c,Method_1_Apr_Flat_kWh__c, 
                    Method_1_May_Flat_kWh__c,Method_1_Jun_Flat_kWh__c,Method_1_Jul_Flat_kWh__c,Method_1_Aug_Flat_kWh__c,Method_1_Sep_Flat_kWh__c,Method_1_Oct_Flat_kWh__c,Method_1_Nov_Flat_kWh__c,Method_1_Dec_Flat_kWh__c,
                    Total_System_Size_kW__c, 
                        (SELECT ID FROM System_Design_Quotes__r WHERE ID = :sdqID LIMIT 1) 
                    FROM System_Design__c WHERE ID = :sdID LIMIT 1];

        //Sum up the discounts for each scenario, and ensure that they do not exceed $0.50/w. See CPQ-345.
        List<Boolean> scenarios = new List<Boolean>{includeScenario1,includeScenario2,includeScenario3,includeScenario4};
        String errStr = '';
        ContractSettings__c contractSettings = ContractSettings__c.getOrgDefaults();
        Decimal discountLimit = contractSettings.Maximum_Promotion__c != null ? contractSettings.Maximum_Promotion__c : 0.5;
        for (Integer i = 1; i < 5; i++){
            if (scenarios[i-1]){
                Decimal scenarioDiscount = 0;
                for (Price_Adjustment__c pa : getStandardPriceAdjustments(String.valueOf(i),(Id)sdqID)){
                    if (pa.Adjustment_Applied__c && pa.Effective_Dollar_Amount__c != null && !pa.Promotion__r.Exclude_from_Promotions_Validation__c){
                        System.debug('**dollar amount:' + pa.Effective_Dollar_Amount__c);
                        scenarioDiscount += pa.Effective_Dollar_Amount__c;
                    }
                }
                Decimal dollarPerWattDiscount = Math.abs(scenarioDiscount / (sd.Total_System_Size_kW__c * 1000));
                if (dollarPerWattDiscount > discountLimit)
                    errStr += 'The total discount given for scenario ' + i  + ' is $' + dollarPerWattDiscount.setScale(3) + '/w, but the allowable maximum is $' + 
                                discountLimit + '/w. Please review the applied Promotions for scenario ' + i + '.' + '\n\n';
            }
        }
        
        if (errStr.length() > 0)
            return new String[]{errStr, ''};

        /* SIGHTEN VALIDATION */

        Map<Integer, List<Object>> sightenScenarios = SightenAPIIntegrator.GetSightenScenariosAndPayments(sdqId);
        Boolean scenario1IsSighten = Boolean.valueOf(sightenScenarios.get(1)[0]);
        Boolean scenario2IsSighten = Boolean.valueOf(sightenScenarios.get(2)[0]);
        Boolean scenario3IsSighten = Boolean.valueOf(sightenScenarios.get(3)[0]);
        Boolean scenario4IsSighten = Boolean.valueOf(sightenScenarios.get(4)[0]);

        if(includeScenario1){
            if(scenario1IsSighten && (sightenScenarios.get(1)[1] == null || sightenScenarios.get(1)[1] == 0)){
                errStr += 'Scenario 1 does not have a monthly payment.  Click the Get Monthly Payment button before creating the proposal.';
            }
        }
        if(includeScenario2){
            if(scenario2IsSighten && (sightenScenarios.get(2)[1] == null || sightenScenarios.get(2)[1] == 0)){
                errStr += 'Scenario 2 does not have a monthly payment.  Click the Get Monthly Payment button before creating the proposal.';
            }
        }
        if(includeScenario3){
            if(scenario3IsSighten && (sightenScenarios.get(3)[1] == null || sightenScenarios.get(3)[1] == 0)){
                errStr += 'Scenario 3 does not have a monthly payment.  Click the Get Monthly Payment button before creating the proposal.';
            }
        }
        if(includeScenario4){
            if(scenario4IsSighten && (sightenScenarios.get(4)[1] == null || sightenScenarios.get(4)[1] == 0)){
                errStr += 'Scenario 4 does not have a monthly payment.  Click the Get Monthly Payment button before creating the proposal.';
            }
        }
        if (errStr.length() > 0)
            return new String[]{errStr, ''};

        Map<Integer, Boolean> includedSightenScenarios = new Map<Integer, Boolean>();
        Boolean makeCallouts = false;
        includedSightenScenarios.put(1, false);
        includedSightenScenarios.put(2, false);
        includedSightenScenarios.put(3, false);
        includedSightenScenarios.put(4, false);
        if(scenario1IsSighten && includeScenario1){
            includedSightenScenarios.put(1, true);
            makeCallouts = true;
        }
        if(scenario2IsSighten && includeScenario2){
            includedSightenScenarios.put(2, true);
            makeCallouts = true;
        }
        if(scenario3IsSighten && includeScenario3){
            includedSightenScenarios.put(3, true);
            makeCallouts = true;
        }
        if(scenario4IsSighten && includeScenario4){
            includedSightenScenarios.put(4, true);
            makeCallouts = true;
        }

        // Create the Quotes in Sighten
        // This makes callouts so no DML or Savepoints can happen before this line!!!
        Map<Integer, SightenAPIHelper.SightenAPIHelperResponse> apiCalloutResponsesMap = null;
        if(makeCallouts){
            apiCalloutResponsesMap = MakeAllSightenCallouts(sdqId, includedSightenScenarios);
        }

        Savepoint sp = Database.setSavepoint();
        Map<String, String> apiCalloutResultMap = null;
        if(apiCalloutResponsesMap != null){
            apiCalloutResultMap = ProcessAllSightenCallouts(sdqId, apiCalloutResponsesMap);

            // need to be able to create a return here of bad things happening
            for(String key : apiCalloutResultMap.keySet()){
                if(key.contains('ERROR')){
                    errStr += apiCalloutResultMap.get(key);
                }
            }
            if (errStr.length() > 0){
                Database.rollback(sp);
                return new String[]{errStr, ''};
            }
        }

        /* /SIGHTEN VALIDATION */

        String[] validationResult;
        if (includeScenario1 || includeScenario2 || includeScenario3 || includeScenario4){
            //Validate SD, Validate SDQ, Create Proposal Record
            validationResult = SalesWorkflowValidationUtility.systemDesignQuoteWorkflowOnComplete(sdqID, includeScenario1, includeScenario2, includeScenario3, includeScenario4, expirationDays);
        } else {
            Database.rollback(sp);
            return new String[]{'Please select at least one Scenario to include in Proposal', ''};
        }

        String[] fullResult = validationResult;     //Index 0: 'Valid' or error message. Index 1: Proposal ID or blank string.
        if(fullResult[0] != 'Valid'){
            Database.rollback(sp);
        }
system.debug('**SZ: made it through the API with no errors!');

        //System_Design_Quote__c sdq = sd.System_Design_Quotes__r[0];
        //for (Integer i = 1; i < 5; i++){    //CPQ-543 validation rule
        //    if (scenarios[i-1]){
        //        Decimal eligiblePromotions = sdq.get('Scenario_' + i + '_Eligible_Promo_Cash_Rebate__c') != null ? (Decimal)sdq.get('Scenario_' + i + '_Eligible_Promo_Cash_Rebate__c') : 0;
        //        Decimal cashRebateAmount = sdq.get('Scenario_' + i + '_Promotion_Cash_Rebate_Amount__c') != null ? (Decimal)sdq.get('Scenario_' + i + '_Promotion_Cash_Rebate_Amount__c') : 0;
        //        if (Math.abs(cashRebateAmount) > Math.abs(eligiblePromotions))
        //            errStr += 'Scenario ' + i + ' Cash Rebate ($' + Math.abs(cashRebateAmount) + ') may not be set to more than its Eligible Promotions amount ($' + Math.abs(eligiblePromotions) + ').';
        //    }
        //}
        
        Utility_Service__c utilService = [SELECT Utility_Rate_Code_Before_Solar__c, Utility_Rate_Code_After_Solar__c, Method_1_Total_Bill__c, After_Fixed_Costs__c, 
                                        Monthly_Electric_Consumption_KWH_Jan__c,Monthly_Electric_Consumption_KWH_feb__c,Monthly_Electric_Consumption_KWH_mar__c, 
                                        Monthly_Electric_Consumption_KWH_Apr__c,Monthly_Electric_Consumption_KWH_may__c,Monthly_Electric_Consumption_KWH_Jun__c, 
                                        Monthly_Electric_Consumption_KWH_Jul__c,Monthly_Electric_Consumption_KWH_Aug__c,Monthly_Electric_Consumption_KWH_Sep__c, 
                                        Monthly_Electric_Consumption_KWH_Oct__c,Monthly_Electric_Consumption_KWH_Nov__c,Monthly_Electric_Consumption_KWH_dec__c, 
                                        Total_Forecasted_Consumption_kWh_Jan__c,Total_Forecasted_Consumption_kWh_Feb__c,Total_Forecasted_Consumption_kWh_Mar__c,
                                        Total_Forecasted_Consumption_kWh_Apr__c,Total_Forecasted_Consumption_kWh_May__c,Total_Forecasted_Consumption_kWh_Jun__c,
                                        Total_Forecasted_Consumption_kWh_Jul__c,Total_Forecasted_Consumption_kWh_Aug__c,Total_Forecasted_Consumption_kWh_Sep__c,
                                        Total_Forecasted_Consumption_kWh_Oct__c,Total_Forecasted_Consumption_kWh_Nov__c,Total_Forecasted_Consumption_kWh_Dec__c,
                                        Before_Tier_1_Cost__c, Before_Tier_2_Cost__c, Before_Tier_3_Cost__c, Before_Tier_4_Cost__c, Before_Tier_5_Cost__c, 
                                        Before_Fixed_Costs__c, Net_Method_1_Tier_Cost__c, Utility_Value_of_Solar_Tariff__c, Before_Total_Bill__c, 
                                        Before_First_Year_Avg_Price__c, Utility_Rate_Code_Before_Solar__r.Utility_Company_Master__r.Name 
                                        FROM Utility_Service__c WHERE ID = :utilServiceID LIMIT 1];
        ID newRateCode = utilService.Utility_Value_of_Solar_Tariff__c != null ? utilService.Utility_Value_of_Solar_Tariff__c : utilService.Utility_Rate_Code_After_Solar__c;
        //Rate_Period__c currentRatePeriod;
        //Rate_Period__c newRatePeriod;
        //for (Rate_Period__c rp : [SELECT Utility_Company__c, Tier_1_Rate_kWh__c, Tier_2_Rate_kWh__c, Tier_3_Rate_kWh__c, Tier_4_Rate_kWh__c, Tier_5_Rate_kWh__c FROM Rate_Period__c 
        //                            WHERE (Utility_Company__c = :utilService.Utility_Rate_Code_Before_Solar__c OR Utility_Company__c = :newRateCode) 
        //                            AND Tier_1_Rate_kWh__c != null ORDER BY CreatedDate DESC LIMIT 50]){
        //    if (rp.Utility_Company__c == utilService.Utility_Rate_Code_Before_Solar__c)
        //        currentRatePeriod = rp;
        //    if (rp.Utility_Company__c == newRateCode)
        //        newRatePeriod = rp;

        //    if (currentRatePeriod != null && newRatePeriod != null)
        //        break;
        //}
        String[] months = new String[]{'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};
        Decimal[] solarProd = new Decimal[]{};
        Decimal[] homeConsumption = new Decimal[]{};
        for (Integer i = 0; i < 12; i++){
            Decimal peakProd = sd.get('Method_1_'+months[i]+'_Peak_kWh__c') != null ? (Decimal)sd.get('Method_1_'+months[i]+'_Peak_kWh__c') : 0;
            Decimal partPeakProd = sd.get('Method_1_'+months[i]+'_Part_Peak_kWh__c') != null ? (Decimal)sd.get('Method_1_'+months[i]+'_Part_Peak_kWh__c') : 0;
            Decimal offPeakProd = sd.get('Method_1_'+months[i]+'_Off_Peak_kWh__c') != null ? (Decimal)sd.get('Method_1_'+months[i]+'_Off_Peak_kWh__c') : 0;
            Decimal flatProd = sd.get('Method_1_'+months[i]+'_Flat_kWh__c') != null ? (Decimal)sd.get('Method_1_'+months[i]+'_Flat_kWh__c') : 0;
            solarProd.add(peakProd + partPeakProd + offPeakProd + flatProd);    //Sum the production measures for each month

            Decimal forecastedConsumtion = utilService.get('Total_Forecasted_Consumption_kWh_'+months[i]+'__c') != null ? (Decimal)utilService.get('Total_Forecasted_Consumption_kWh_'+months[i]+'__c') : 0;
            homeConsumption.add(forecastedConsumtion);
        }
        String prodVsUsageJSON = JSON.serialize(new List<List<Decimal>>{solarProd, homeConsumption});
        fullResult.add(prodVsUsageJSON);    //Index 2

        Decimal[] currentRateCodeLabels = new Decimal[]{};
        Decimal[] newRateCodeLabels = new Decimal[]{};
        Decimal[] beforeTierSums = new Decimal[]{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};   //The first month in a tier cost is the sum of the first month values in the preceding tiers
        List<List<Decimal>> currentTiers = new List<List<Decimal>>();
        List<List<Decimal>> newTiers = new List<List<Decimal>>();
        for (Integer i = 1; i <6 ; i++){
            //if (currentRatePeriod.get('Tier_' + i + '_Rate_kWh__c') != null)
            //    currentRateCodeLabels.add((Decimal)currentRatePeriod.get('Tier_' + i + '_Rate_kWh__c'));
            //if (newRatePeriod.get('Tier_' + i + '_Rate_kWh__c') != null)
            //    newRateCodeLabels.add((Decimal)newRatePeriod.get('Tier_' + i + '_Rate_kWh__c'));

            if (utilService.get('Before_Tier_' + i + '_Cost__c') != null){
                String tierStr = (String)utilService.get('Before_Tier_' + i + '_Cost__c');
                Decimal[] tierArr = new Decimal[]{};
                String[] costsByMonth = tierStr.split(';', -1);
                for (Integer n = 0; n < costsByMonth.size(); n++){  //Traverse the monthly values in this tier
                    Decimal monthCost = String.isNotBlank(costsByMonth[n]) ? Decimal.valueOf(costsByMonth[n]) : 0;
                    Decimal cumulativeMonthCost = monthCost;
                    if (beforeTierSums.size() >= n + 1)     //Essentially guaranteed
                        cumulativeMonthCost = monthCost + beforeTierSums[n];
                    tierArr.add(cumulativeMonthCost);
                }
                if (tierArr.size() == 13)
                    tierArr.remove(12);
                currentTiers.add(tierArr);
                beforeTierSums = tierArr;
            }
        }

        if (String.isNotBlank(utilService.Net_Method_1_Tier_Cost__c)){
            String allTiers = utilService.Net_Method_1_Tier_Cost__c;

            String tierOne = allTiers.substringBetween('T1:', 'T2:');
            String[] tierOneArr = tierOne.trim().split(';', 0);
            Decimal[] tierOneFinal = new Decimal[]{};
            for (Integer i = 0; i < tierOneArr.size(); i++){
                tierOneFinal.add(String.isNotBlank(tierOneArr[i]) ? Decimal.valueOf(tierOneArr[i]) : 0);
            }
            newTiers.add(tierOneFinal);

            String tierTwo = allTiers.substringBetween('T2:', 'T3:');
            String[] tierTwoArr = tierTwo.trim().split(';', 0);
            Decimal[] tierTwoFinal = new Decimal[]{};
            for (Integer i = 0; i < tierTwoArr.size(); i++){
                Decimal monthCost = String.isNotBlank(tierTwoArr[i]) ? Decimal.valueOf(tierTwoArr[i]) : 0;
                Decimal cumulativeMonthCost = monthCost;
                if (tierOneFinal.size() >= i + 1)
                    cumulativeMonthCost = monthCost + tierOneFinal[i];
                tierTwoFinal.add(cumulativeMonthCost);
            }
            newTiers.add(tierTwoFinal);

            String tierThree = allTiers.substringBetween('T3:', 'T4:');
            String[] tierThreeArr = tierThree.trim().split(';', 0);
            Decimal[] tierThreeFinal = new Decimal[]{};
            for (Integer i = 0; i < tierThreeArr.size(); i++){
                Decimal monthCost = String.isNotBlank(tierThreeArr[i]) ? Decimal.valueOf(tierThreeArr[i]) : 0;
                Decimal cumulativeMonthCost = monthCost;
                if (tierTwoFinal.size() >= i + 1)
                    cumulativeMonthCost = monthCost + tierTwoFinal[i];
                tierThreeFinal.add(cumulativeMonthCost);
            }
            newTiers.add(tierThreeFinal);

            String tierFour = allTiers.substringBetween('T4:', 'T5:');
            String[] tierFourArr = tierFour.trim().split(';', 0);
            Decimal[] tierFourFinal = new Decimal[]{};
            for (Integer i = 0; i < tierFourArr.size(); i++){
                Decimal monthCost = String.isNotBlank(tierFourArr[i]) ? Decimal.valueOf(tierFourArr[i]) : 0;
                Decimal cumulativeMonthCost = monthCost;
                if (tierThreeFinal.size() >= i + 1)
                    cumulativeMonthCost = monthCost + tierThreeFinal[i];
                tierFourFinal.add(cumulativeMonthCost);
            }
            newTiers.add(tierFourFinal);

            String tierFive = allTiers.substringAfterLast('T5:');
            String[] tierFiveArr = tierFive.trim().split(';', 0);
            Decimal[] tierFiveFinal = new Decimal[]{};
            for (Integer i = 0; i < tierFiveArr.size(); i++){
                Decimal monthCost = String.isNotBlank(tierFiveArr[i]) ? Decimal.valueOf(tierFiveArr[i]) : 0;
                Decimal cumulativeMonthCost = monthCost;
                if (tierFourFinal.size() >= i + 1)
                    cumulativeMonthCost = monthCost + tierFourFinal[i];
                tierFiveFinal.add(cumulativeMonthCost);
            }
            newTiers.add(tierFiveFinal);
        }

        Decimal[] currentFixedCharges = new Decimal[]{};
        Decimal[] newFixedCharges = new Decimal[]{};
        if (utilService.Before_Fixed_Costs__c != null){
            for (String str : utilService.Before_Fixed_Costs__c.split(';', -1))
                currentFixedCharges.add(String.isNotBlank(str) ? Decimal.valueOf(str) : 0);
        }
        if (utilService.After_Fixed_Costs__c != null){
            for (String str : utilService.After_Fixed_Costs__c.split(';', -1))
                newFixedCharges.add(String.isNotBlank(str) ? Decimal.valueOf(str) : 0);
        }
        Decimal[] currentNetCharge = new Decimal[]{};
        Decimal[] newNetCharge = new Decimal[]{};
        if (utilService.Before_Total_Bill__c != null){
            for (String str : utilService.Before_Total_Bill__c.split(';', -1))
                currentNetCharge.add(String.isNotBlank(str) ? Decimal.valueOf(str) : 0);
        }
        if (utilService.Method_1_Total_Bill__c != null){
            for (String str : utilService.Method_1_Total_Bill__c.split(';', -1))
                newNetCharge.add(String.isNotBlank(str) ? Decimal.valueOf(str) : 0);
        }
        
        String currentBillPart1JSON = JSON.serialize(new List<List<Decimal>>{currentRateCodeLabels, currentFixedCharges, currentNetCharge});
        fullResult.add(currentBillPart1JSON);    //Index 3
        String currentBillPart2JSON = JSON.serialize(currentTiers);
        fullResult.add(currentBillPart2JSON);    //Index 4

        String newBillPart1JSON = JSON.serialize(new List<List<Decimal>>{newRateCodeLabels, newFixedCharges, newNetCharge});
        fullResult.add(newBillPart1JSON);    //Index 5
        String newBillPart2JSON = JSON.serialize(newTiers);
        fullResult.add(newBillPart2JSON);    //Index 6

        if (fullResult[0] == 'Valid'){  //Build the arrays for the "Comparative Rates by Year" chart
            String proposalID = fullResult[1];

            /* SIGHTEN UPDATE */
            
            if(apiCalloutResultMap != null){
                Proposal__c updateProp = new Proposal__c(Id = proposalID);
                if(apiCalloutResultMap.containsKey('VALID1')) { updateProp.Sighten_Scenario_1_Quote_uuid__c = apiCalloutResultMap.get('VALID1'); }
                if(apiCalloutResultMap.containsKey('VALID2')) { updateProp.Sighten_Scenario_2_Quote_uuid__c = apiCalloutResultMap.get('VALID2'); }
                if(apiCalloutResultMap.containsKey('VALID3')) { updateProp.Sighten_Scenario_3_Quote_uuid__c = apiCalloutResultMap.get('VALID3'); }
                if(apiCalloutResultMap.containsKey('VALID4')) { updateProp.Sighten_Scenario_4_Quote_uuid__c = apiCalloutResultMap.get('VALID4'); }
                update updateProp;
            }

            /* /SIGHTEN UPDATE */

            Proposal__c prop = [SELECT Annual_Power_Price_Escalator__c, Scenario_1_Solar_Electric_Rate__c, Scenario_2_Solar_Electric_Rate__c, 
                                Scenario_3_Solar_Electric_Rate__c, Scenario_4_Solar_Electric_Rate__c, Scenario_1_Financing_Plan__c, 
                                Scenario_2_Financing_Plan__c, Scenario_3_Financing_Plan__c, Scenario_4_Financing_Plan__c, Scenario_1_Estimated_Operational_Start_D__c, 
                                Scenario_2_Estimated_Operational_Start_D__c, Scenario_3_Estimated_Operational_Start_D__c, Scenario_4_Estimated_Operational_Start_D__c, 
                                System_Design_Quote__r.Pricing_Date__c, System_Design_Quote__r.Scenario_1_Lease_Escalator__c, System_Design_Quote__r.Scenario_2_Lease_Escalator__c, 
                                System_Design_Quote__r.Scenario_3_Lease_Escalator__c, System_Design_Quote__r.Scenario_4_Lease_Escalator__c 
                                FROM Proposal__c WHERE ID = :proposalID LIMIT 1];

            Decimal[] nonsolarElectricRate = new Decimal[]{};
            String[] years = new String[]{};
            Decimal beforeAvgPrice = utilService.Before_First_Year_Avg_Price__c != null ? utilService.Before_First_Year_Avg_Price__c : 0;
            Double esc = prop.Annual_Power_Price_Escalator__c / 100;
            Integer startYear = Date.valueOf(prop.System_Design_Quote__r.Pricing_Date__c).addDays(90).year();
            for (Integer year = 0; year < 20; year++){
                Decimal elecRate = beforeAvgPrice * Math.pow(1 + esc, (Double)year);
                nonsolarElectricRate.add(elecRate.setScale(4));
                years.add(String.valueOf(startYear + year));
            }

            List<List<Decimal>> allElectricRates = new List<List<Decimal>>();
            allElectricRates.add(nonsolarElectricRate);
            //String[] keyLabels = new String[]{};
            //keyLabels.add(utilService.Utility_Rate_Code_Before_Solar__r.Utility_Company_Master__r.Name);    //Nonsolar label
            for (Integer i = 1; i < 5; i++){
                if (prop.get('Scenario_' + i + '_Financing_Plan__c') == null)
                    continue;
                
                //keyLabels.add((String)prop.get('Scenario_' + i + '_Financing_Plan__c'));
                Decimal[] scenarioElectricRate = new Decimal[]{};
                Decimal baseRate = prop.get('Scenario_' + i + '_Solar_Electric_Rate__c') != null ? (Decimal)prop.get('Scenario_' + i + '_Solar_Electric_Rate__c') : 0;
                String leaseEscStr = prop.getSObject('System_Design_Quote__r').get('Scenario_' + i + '_Lease_Escalator__c') != null ? (String)prop.getSObject('System_Design_Quote__r').get('Scenario_' + i + '_Lease_Escalator__c') : '0';
                if (String.isBlank(leaseEscStr) || leaseEscStr == 'null')
                    leaseEscStr = '0';
                Double leaseEsc = Double.valueOf(leaseEscStr) / 100;
                for (Integer year = 0; year < 20; year++){
                    Decimal elecRate = baseRate * Math.pow(1 + leaseEsc, (Double)year);
                    scenarioElectricRate.add(elecRate.setScale(4));
                }
                allElectricRates.add(scenarioElectricRate);
            }

            String comparativeRatesPart1JSON = JSON.serialize(new List<List<String>>{years/*, keyLabels*/});
            fullResult.add(comparativeRatesPart1JSON);    //Index 7

            String comparativeRatesPart2JSON = JSON.serialize(allElectricRates);    //[0]: Nonsolar electrcity rate, [N]: Scenario N electricity rate
            fullResult.add(comparativeRatesPart2JSON);    //Index 8
        }
system.debug('**SZ: fullResult - ' + fullResult);
        return fullResult;
    }


    /*************************************/
    /* SIGHTEN METHODS                    /
    /*************************************/

    public Boolean displaySightenPopup {get;set;}

    public Boolean scenario1IsSighten {get;set;}
    public Boolean scenario2IsSighten {get;set;}
    public Boolean scenario3IsSighten {get;set;}
    public Boolean scenario4IsSighten {get;set;}

    public Boolean scenario1ACHOption {get;set;}
    public Boolean scenario2ACHOption {get;set;}
    public Boolean scenario3ACHOption {get;set;}
    public Boolean scenario4ACHOption {get;set;}

    public String scenario1TermLoan {get;set;}
    public String scenario2TermLoan {get;set;}
    public String scenario3TermLoan {get;set;}
    public String scenario4TermLoan {get;set;}

    public String buttonScenario {get;set;}
    public PageReference getSightenMonthlyPayment(){
        MakeSightenCallout(Integer.valueOf(buttonScenario), false);
        return null;
    }

    private void MakeSightenCallout(Integer scenario, Boolean saveToSighten){
        SightenAPIHelper.SightenAPIHelperResponse sightenResponse = SightenAPIIntegrator.GetPricingFromSDQ(sysDesignQuote.Id, scenario, saveToSighten);

        SightenAPIHelper helper = new SightenAPIHelper();
        if(sightenResponse.responseStatusCode == 200){
            SightenAPIQuote apiQuote = (SightenAPIQuote)helper.parseResponseBody(sightenResponse.responseBody, SightenAPIQuote.class);
            System_Design_Quote__c sdqToUpdate = new System_Design_Quote__c(
                Id = sysDesignQuote.Id
            );
            sdqToUpdate.put('Scenario_' + scenario + '_First_Month_Payment__c', apiQuote.data.avg_monthly_solar_bill);

            SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = true;
            update sdqToUpdate;
            SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = false;
            //writeMessage('apiQuote = ' + apiQuote);
        } else {
            SightenAPIEntity.SightenAPIErrorHelper errorHelper = (SightenAPIEntity.SightenAPIErrorHelper)helper.parseResponseBodyToError(sightenResponse.responseBody);
            if(errorHelper.errorResponse != null){
                String errorMessage = 'Scenario ' + scenario + '<br/>Sighten API Error: ' + errorHelper.errorResponse.messages.error[0].message;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
                showSightenPopup();
            } else if(errorHelper.errorResponseList != null){
                String errorMessage = 'Scenario ' + scenario + '<br/>Sighten API Error: ' + errorHelper.errorResponseList.messages.error[0].message + '<br/>' + errorHelper.errorResponseList.data[0][0].rule.name + ', min: ' + errorHelper.errorResponseList.data[0][0].rule.min_bound + ', max: ' + errorHelper.errorResponseList.data[0][0].rule.max_bound + '<br/>Value(s): ' + errorHelper.errorResponseList.data[0][0].values;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
                showSightenPopup();
            }
        }
    }

    private static Map<Integer, SightenAPIHelper.SightenAPIHelperResponse> MakeAllSightenCallouts(Id sdqId, Map<Integer, Boolean> scenarios){
         return SightenAPIIntegrator.GetPricingFromSDQ(sdqId, scenarios, true);
    }

    private static Map<String, String> ProcessAllSightenCallouts(Id sdqId, Map<Integer, SightenAPIHelper.SightenAPIHelperResponse> sightenResponses){
        Map<String, String> results = new Map<String, String>();
        SightenAPIHelper helper = new SightenAPIHelper();
        for(Integer scenario : sightenResponses.keySet()){
            SightenAPIHelper.SightenAPIHelperResponse sightenResponse = sightenResponses.get(scenario);
            if(sightenResponse.responseStatusCode == 200){
                SightenAPIQuote apiQuote = (SightenAPIQuote)helper.parseResponseBody(sightenResponse.responseBody, SightenAPIQuote.class);

                // Use the detail to update all the uuid records
                for(String key : sightenResponse.responseDetail.uuidUpdates.keySet()){
                    if(key.contains('System_Design_Quote__c')){
                        System_Design_Quote__c sdq = new System_Design_Quote__c(Id = sdqId);
                        sdq.Sighten_System_uuid__c = sightenResponse.responseDetail.uuidUpdates.get(key);

                        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = true;
                        update sdq;
                        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = false;
                    } else if(key.contains('Property__c')){
                        String[] ids = sightenResponse.responseDetail.uuidUpdates.get(key).split('=');
                        Property__c prop = new Property__c(Id = ids[0]);
                        prop.Sighten_Site_uuid__c = ids[1];
                        update prop;
                    } else if(key.contains('Contact')){
                        String[] ids = sightenResponse.responseDetail.uuidUpdates.get(key).split('=');
                        Contact contact = new Contact(Id = ids[0]);
                        contact.Sighten_Contact_uuid__c = ids[1];
                        update contact;
                    }
                }

                // add to the map
                results.put('VALID' + scenario, apiQuote.data.uuid);
            } else {
                SightenAPIEntity.SightenAPIErrorHelper errorHelper = (SightenAPIEntity.SightenAPIErrorHelper)helper.parseResponseBodyToError(sightenResponse.responseBody);
                if(errorHelper.errorResponse != null){
                    String errorMessage = 'Scenario ' + scenario + '<br/>Sighten API Error: ' + errorHelper.errorResponse.messages.error[0].message;
                    results.put('ERROR' + scenario, errorMessage);
                } else if(errorHelper.errorResponseList != null){
                    String errorMessage = 'Scenario ' + scenario + '<br/>Sighten API Error: ' + errorHelper.errorResponseList.messages.error[0].message + '<br/>' + errorHelper.errorResponseList.data[0][0].rule.name + ', min: ' + errorHelper.errorResponseList.data[0][0].rule.min_bound + ', max: ' + errorHelper.errorResponseList.data[0][0].rule.max_bound + '<br/>Value(s): ' + errorHelper.errorResponseList.data[0][0].values;
                    results.put('ERROR' + scenario, errorMessage);
                }
            }
        }
system.debug('**SZ: results = ' + results);
        return results;
    }

    public void showSightenPopup(){        
        displaySightenPopup = true;
    }

    public void closeSightenPopup(){
        displaySightenPopup = false;
    }


    public class CustomException extends Exception{ }
}