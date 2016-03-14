/*  FILE: AstrumContractCalculations.cls
    AUTHOR: Dan Kelner
    DATE: 12/13/14
    PURPOSE: Populate Contract fields
    MODIFICATION HISTORY
        06/24/15  DK  Moved some calculations to AstrumContractTriggerHandler.continueCalculations() where a formula field value is a prerequisite value.  See CPQ-516.
        07/24/15  DK  Implemented Cash_Discount_Amount__c as defined in CPQ-638.
        11/14/15  DK  New warranty years implementation for CPQ-635.
*/
public without sharing class AstrumContractCalculations {
    
    @TestVisible private static String allContractFields = 'Billing_Address_Line_1__c, Billing_Address_Line_2__c, Billing_City__c, Billing_County__c, Billing_State__c, Billing_Zip__c, Cash_Discount_Amount__c, Cash_Rebate_Amount__c, Closed__c, Community_Program_Tier__c, ' + 
                                    'Contract_Execution_Date__c, County_Lease_Tax_Rate__c, Cumulative_Guaranteed_Sys_Output__c, Current__c, Down_Payment__c, Estimated_Year_One_Price_Per_KWH__c, Est_Interconnect_Date__c, Federal_Tax_Credit__c, ' + 
                                    'First_Month_Payment_Post_Tax__c, First_Month_Payment_Pre_Tax__c, Gross_Amount_Due__c, Guaranteed_Price_Per_kWh_Year_1__c, Guaranteed_Price_Per_kWh_Year_10__c, Guaranteed_Price_Per_kWh_Year_11__c, ' + 
                                    'Guaranteed_Price_Per_kWh_Year_12__c, Guaranteed_Price_Per_kWh_Year_13__c, Guaranteed_Price_Per_kWh_Year_14__c, Guaranteed_Price_Per_kWh_Year_15__c, Guaranteed_Price_Per_kWh_Year_16__c, ' + 
                                    'Guaranteed_Price_Per_kWh_Year_17__c, Guaranteed_Price_Per_kWh_Year_18__c, Guaranteed_Price_Per_kWh_Year_19__c, Guaranteed_Price_Per_kWh_Year_2__c, ' + 
                                    'Guaranteed_Price_Per_kWh_Year_20__c, Guaranteed_Price_Per_kWh_Year_3__c, Guaranteed_Price_Per_kWh_Year_4__c, Guaranteed_Price_Per_kWh_Year_5__c, ' + 
                                    'Guaranteed_Price_Per_kWh_Year_6__c, Guaranteed_Price_Per_kWh_Year_7__c, Guaranteed_Price_Per_kWh_Year_8__c, Guaranteed_Price_Per_kWh_Year_9__c, ' + 
                                    'Guaranteed_Sys_Output_kWh_Year_1__c, Guaranteed_Sys_Output_kWh_Year_10__c, Guaranteed_Sys_Output_kWh_Year_11__c, Guaranteed_Sys_Output_kWh_Year_12__c, ' + 
                                    'Guaranteed_Sys_Output_kWh_Year_13__c, Guaranteed_Sys_Output_kWh_Year_14__c, Guaranteed_Sys_Output_kWh_Year_15__c, Guaranteed_Sys_Output_kWh_Year_16__c, ' + 
                                    'Guaranteed_Sys_Output_kWh_Year_17__c, Guaranteed_Sys_Output_kWh_Year_18__c, Guaranteed_Sys_Output_kWh_Year_19__c, Guaranteed_Sys_Output_kWh_Year_2__c, ' + 
                                    'Guaranteed_Sys_Output_kWh_Year_20__c, Guaranteed_Sys_Output_kWh_Year_3__c, Guaranteed_Sys_Output_kWh_Year_4__c, Guaranteed_Sys_Output_kWh_Year_5__c, ' + 
                                    'Guaranteed_Sys_Output_kWh_Year_6__c, Guaranteed_Sys_Output_kWh_Year_7__c, Guaranteed_Sys_Output_kWh_Year_8__c, Guaranteed_Sys_Output_kWh_Year_9__c, ' + 
                                    'Guarantee_Years_New_Roof_Num__c, Guarantee_Years_New_Roof_Text__c, Guarantee_Years_System_Moving_Num__c, Guarantee_Years_System_Moving_Text__c, ' + 
                                    'Initial_Term_Production_Estimate__c, Interconnect_Payment__c, Inverter_Count__c, Inverter_Manufacturer__c, Inverter_Type__c, Kilowatt_Other_Charges__c, ' + 
                                    'Lease_Escalator__c, Local_Tax_Credit__c, Module_Manufacturer__c, Monitoring_Device__c, Monthly_Payment_Year_1__c, Monthly_Payment_Year_10__c, ' + 
                                    'Monthly_Payment_Year_11__c, Monthly_Payment_Year_12__c, Monthly_Payment_Year_13__c, Monthly_Payment_Year_14__c, Monthly_Payment_Year_15__c, ' + 
                                    'Monthly_Payment_Year_16__c, Monthly_Payment_Year_17__c, Monthly_Payment_Year_18__c, Monthly_Payment_Year_19__c, Monthly_Payment_Year_2__c, ' + 
                                    'Monthly_Payment_Year_20__c, Monthly_Payment_Year_3__c, Monthly_Payment_Year_4__c, Monthly_Payment_Year_5__c, Monthly_Payment_Year_6__c, Monthly_Payment_Year_7__c, ' + 
                                    'Monthly_Payment_Year_8__c, Monthly_Payment_Year_9__c, Net_Proceeds__c, Office_Address__c, OID_Amount__c, Open_Quote__c, Panel_Count__c, Panel_Type__c, ' + 
                                    'PPA_Buyout_Discount_Rate__c, PPA_System_Buyout_Basis_EPC__c, ' + 
                                    'Prepaid_Lease_Upfront_Payment__c, Property_Address_Line_1__c, Property_Address_Line_2__c, Property_City__c, Property_County__c, Property_State__c, Property_Zip__c, ' + 
                                    'Proposal__c, Purchase_Price_Due_at_Signing__c, Purchase_Price_Due_Final_Inspection__c, Purchase_Price_Due_First_Day_Install__c, SAC_APR__c, SAC_Balloon_Payment__c, ' + 
                                    'SAC_Completion_Payment__c, SAC_Finance_Charge__c, SAC_Financed_Amount__c, SAC_Interconnect_Payment__c, SAC_Maturity_Date__c, SAC_Total_Payment__c, ' + 
                                    'SAC_Total_Payments__c, Scenario__c, Signatory_1__c, Signatory_1_Email__c, Signatory_1_Phone__c, Signatory_2__c, Signatory_2_Email__c, Signatory_2_Phone__c, ' + 
                                    'State_Grant_Amount__c, State_Grant_Tax_Amount__c, State_Tax_Credit__c, System_Design_Quote_Name__c, System_Design_Reconstruction_Record__c, System_Net_Cost__c, ' + 
                                    'System_Purchase_Price_After_Adjustments__c, System_Size__c, Term_Loan_APR__c, Term_Loan_Completion_Payment__c, Term_Loan_Est_Completion_Date__c, ' + 
                                    'Term_Loan_Finance_Charge__c, Term_Loan_Financed_Amount__c, Term_Loan_First_Payment_Date__c, Term_Loan_Interconnect_Payment__c, Term_Loan_Last_Payment_Date__c, ' + 
                                    'Term_Loan_Monthly_Payment__c, Term_Loan_Term__c, Term_Loan_Total_Payments__c, Total_of_All_Payments__c, Total_of_Monthly_Payments_Post_Tax__c, Total_of_Monthly_Payments_Pre_Tax__c, ' + 
                                    'Total_Prepaid_Lease_Amount__c, Total_System_Price__c, Total_Tax_Paid__c, Upfront_SREC_Amount__c, Utility_Incentive_Amount__c, Valid__c, ' + 
                                    'Warranty_Years_Inverter_Num__c, Warranty_Years_Inverter_Text__c, Warranty_Years_Limited_Production_Num__c, Warranty_Years_Limited_Production_Text__c, ' + 
                                    'Warranty_Years_Parts_Labor_Num__c, Warranty_Years_Parts_Labor_Text__c, Year_One_Production_Estimate__c ';
    
    private static Proposal__c proposal;
    private static System_Design_Quote__c sdq;
    private static Price_Adjustment__c[] priceAdjs;
    private static Integer inverterDefaultWarrantyYears;    //CPQ-635
    private static AggregateResult[] sdiAggregate;
    private static Boolean foundPremiumProductionGuarantee = false;
    //private static Boolean foundAstrumExtendedWarranty = false;
    //private static Boolean foundSolarEdgeWarranty = false;
    private static Decimal cashDiscountAmt = 0;
    private static Property__c property;
    private static Account acct;
    private static OpportunityContactRole[] oppRoles;
    
    private static void queryParentRecords(ID proposalID, Integer scenario){
        proposal = Database.query('SELECT Scenario_' + scenario + '_Payment_Due_Signing__c, Scenario_' + scenario + '_Payment_Due_Installation__c, ' + 
                                  'Scenario_' + scenario + '_Payment_Due_Final_Inspection__c, Scenario_' + scenario + '_Proposal_Term_Months__c, ' + 
                                  'Scenario_' + scenario + '_Year_1_Monthly_Solar_Payment__c, System_Design_Quote__c FROM Proposal__c WHERE ID = :proposalID LIMIT 1');
        
        sdq = Database.query('SELECT Total_System_Size_kW__c, Panel_Count__c, Scenario_' + scenario + '_Final_EPC_Price_NUM__c, Scenario_' + scenario + '_Final_EPC_Price__c, Scenario_' + scenario + '_Federal_Tax_Credit_Amount__c, ' + 
                             'Scenario_' + scenario + '_State_Rebate_Amount__c, Scenario_' + scenario + '_State_Tax_Credit_Amount__c, Scenario_' + scenario + '_Total_Net_Adjustment__c, Scenario_' + scenario + '_Upfront_SREC_Amount__c, ' + 
                             'Scenario_' + scenario + '_Utility_Rebate_Amount__c, Scenario_' + scenario + '_County_Tax_Credit_Amount__c, Scenario_' + scenario + '_Local_Tax_Credit_Amount__c, Income_Corporate_Tax_Rate__c, ' + 
                             'Scenario_' + scenario + '_Avoided_Utility_Rate__c, Scenario_' + scenario + '_Total_Projected_Annual_Output__c, Scenario_' + scenario + '_Depreciation_Basis__c, Scenario_' + scenario + '_Down_Payment__c, ' + 
                             'Scenario_' + scenario + '_Prepaid_Financing_Amount__c, Scenario_' + scenario + '_Total_Monthly_Payments__c, Scenario_' + scenario + '_Financing_Monthly_Pmt_Year_1__c, ' + 
                             'Scenario_' + scenario + '_Lease_Escalator__c, Scenario_' + scenario + '_Financing_Rate_Year_1_kWh__c, System_Design__r.Property__c, Scenario_' + scenario + '_SREC_Cash_Back__c, ' + 
                             'Scenario_' + scenario + '_First_Month_Payment__c, Scenario_' + scenario + '_Term_Loan_Amount__c, Scenario_' + scenario + '_SAC_Loan_Amount__c, System_Design__c, ' + 
                             'Scenario_' + scenario + '_Term_Loan__r.APR__c, Scenario_' + scenario + '_SAC_Loan__r.OID__c, System_Design__r.Default_CB_Panel__r.Utility_Service__r.Before_First_Year_Avg_Price__c, ' + 
                             'Scenario_' + scenario + '_Lease_Fund__r.System_Buyout_Basis_EPC__c, Scenario_' + scenario + '_Lease_Fund__r.Buyout_Discount_Rate__c, Scenario_' + scenario + '_Financing_Type__c, ' + 
                             'Scenario_' + scenario + '_Net_Initial_Outlay__c, Scenario_' + scenario + '_SREC_Contract_Discount__c, Pricing_Region__c, Community_Program_Offer__r.Current_Tier__c ' + 
                             'FROM System_Design_Quote__c WHERE ID = \'' + proposal.System_Design_Quote__c + '\' LIMIT 1');
        
        priceAdjs = [SELECT Entitlement_Offer__r.Name, Effective_Dollar_Amount__c, Promotion__r.Cash_Only__c, Entitlement_Offer__r.Inverter_Extended_Warranty_Years__c, 
                       Entitlement_Offer__r.Limited_Production_Ext_Warranty_Years__c, Entitlement_Offer__r.Parts_Labor_Extended_Warranty_Years__c, 
                       Entitlement_Offer__r.New_Roof_Extended_Guarantee_Years__c, Entitlement_Offer__r.System_Moving_Extended_Guarantee_Years__c 
                       FROM Price_Adjustment__c WHERE System_Design_Quote__c = :sdq.ID 
                       AND Adjustment_Applied__c = true AND Applicable_Scenario__c = :String.valueOf(scenario)];
        for (Price_Adjustment__c adj : priceAdjs){
            if (adj.Entitlement_Offer__c != null && adj.Entitlement_Offer__r.Name.containsIgnoreCase('Premium Production Guarantee'))
                foundPremiumProductionGuarantee = true;
            //if (adj.Entitlement_Offer__c != null && adj.Entitlement_Offer__r.Name.containsIgnoreCase('Direct Energy Solar Extended Warranty'))
            //    foundAstrumExtendedWarranty = true;
            //if (adj.Entitlement_Offer__c != null && adj.Entitlement_Offer__r.Name.containsIgnoreCase('SolarEdge Extended Warranty'))
            //    foundSolarEdgeWarranty = true;
            if (adj.Promotion__c != null && adj.Promotion__r.Cash_Only__c && adj.Effective_Dollar_Amount__c != null)  //CPQ-638
                cashDiscountAmt += adj.Effective_Dollar_Amount__c;
        }
        
        Set<ID> sdaSet = new Set<ID>();
        for (System_Design_Array__c sda : [SELECT ID, 
                                            (SELECT System_Design_Product__r.Default_Warranty_Years__c FROM System_Design_Items__r WHERE RecordType.DeveloperName = 'Inverter') 
                                           FROM System_Design_Array__c WHERE System_Design__c = :sdq.System_Design__c]){
            sdaSet.add(sda.ID);
            if (inverterDefaultWarrantyYears == null && !sda.System_Design_Items__r.isEmpty())  //CPQ-635
                inverterDefaultWarrantyYears = sda.System_Design_Items__r[0].System_Design_Product__c != null ? (Integer)sda.System_Design_Items__r[0].System_Design_Product__r.Default_Warranty_Years__c : null;
        }
        
        //Count the panels and inverters on all System Design Arrays
        sdiAggregate = [SELECT System_Design_Product__r.Description__c descr, System_Design_Product__r.Make__c make, RecordType.Name rType, COUNT(ID) 
                        FROM System_Design_Item__c WHERE System_Design_Array__c IN :sdaSet AND RecordType.Name IN ('Inverter', 'Panel') 
                        GROUP BY System_Design_Product__r.Description__c, System_Design_Product__r.Make__c, RecordType.Name];
        
        property = [SELECT Name, Property_Address_2__c, Property_City__c, Property_State__c, Property_ZIP__c, Property_County__c, 
                    Astrum_Office_New__r.Street__c, Astrum_Office_New__r.Street_2__c, Astrum_Office_New__r.City__c, Astrum_Office_New__r.State__c,
                    Astrum_Office_New__r.Zip_Code__c, 
                        (SELECT Account.BillingStreet, Account.BillingCity, Account.BillingState, 
                        Account.BillingPostalCode, Account.QAS_Billing_County__c FROM Opportunities__r ORDER BY CreatedDate DESC LIMIT 1) 
                    FROM Property__c WHERE ID = :sdq.System_Design__r.Property__c LIMIT 1];
        
        if (!property.Opportunities__r.isEmpty()){
            Opportunity opp = property.Opportunities__r[0];    //Newest Opportunity related to the Property
            acct = opp.Account;
            oppRoles = [SELECT Contact.Name, Contact.Phone, Contact.Email, IsPrimary FROM OpportunityContactRole WHERE OpportunityID = :opp.ID AND Role = 'Contract Signer'];
        }
    }
    
    
    public static Astrum_Contract__c initilizeContract(ID proposalID, Integer scenario){
        Astrum_Contract__c contr = new Astrum_Contract__c(Proposal__c = proposalID);
        try {
            queryParentRecords(proposalID, scenario);
            
            contr.Property_Address_Line_1__c = property.Name;
            contr.Property_Address_Line_2__c = property.Property_Address_2__c;
            contr.Property_City__c = property.Property_City__c;
            contr.Property_State__c = property.Property_State__c;
            contr.Property_ZIP__c = property.Property_ZIP__c;
            contr.Property_County__c = property.Property_County__c;

            contr.Office_Address__c = property.Astrum_Office_New__r.Street__c + (property.Astrum_Office_New__r.Street_2__c != null ? ' ' + property.Astrum_Office_New__r.Street_2__c : '') + ', ' + 
                                      property.Astrum_Office_New__r.City__c + ', ' + property.Astrum_Office_New__r.State__c + ' ' + property.Astrum_Office_New__r.Zip_Code__c;  //CPQ-560
            contr.Cash_Discount_Amount__c = cashDiscountAmt;
            contr.Cash_Rebate_Amount__c = sdq.get('Scenario_' + scenario + '_Total_Net_Adjustment__c') != null ? Math.abs((Decimal)sdq.get('Scenario_' + scenario + '_Total_Net_Adjustment__c')) : 0;    //CPQ-543, CPQ-792

            if (acct != null){
                if (oppRoles != null){
                    Contact primary;
                    Contact secondary;
                    for (OpportunityContactRole ocr : oppRoles){    //Traverse list of "contract signer" Opportunity Contact Roles for the Property's newest Opp
                        if (ocr.IsPrimary){
                            primary = ocr.Contact;
                        } else {
                            if (secondary == null)
                                secondary = ocr.Contact;
                        }
                        if (primary != null && secondary != null)
                            break;
                    }
                    if (primary != null){
                        contr.Signatory_1__c = primary.Name;
                        contr.Signatory_1_Phone__c = primary.Phone;
                        contr.Signatory_1_Email__c = primary.Email;
                    }
                    if (secondary != null){
                        contr.Signatory_2__c = secondary.Name;
                        contr.Signatory_2_Phone__c = secondary.Phone;
                        contr.Signatory_2_Email__c = secondary.Email;
                    }
                }
                contr.Billing_Address_Line_1__c = acct.BillingStreet;
                contr.Billing_City__c = acct.BillingCity;
                contr.Billing_State__c = acct.BillingState;
                contr.Billing_Zip__c = acct.BillingPostalCode;
                contr.Billing_County__c = acct.QAS_Billing_County__c;
            }
            contr.System_Size__c = sdq.Total_System_Size_kW__c;
            contr.Scenario__c = String.valueOf(scenario);
            contr.Community_Program_Tier__c = sdq.Community_Program_Offer__r.Current_Tier__c;
            contr.SREC_Cash_Back__c = (Decimal)sdq.get('Scenario_' + scenario + '_SREC_Cash_Back__c');
            contr.SREC_Contract_Discount__c = (Decimal)sdq.get('Scenario_' + scenario + '_SREC_Contract_Discount__c');
            
            Integer defaultWarrantyYears = inverterDefaultWarrantyYears;    //Soft default

            //Examine the SDI aggregate query to obtain panel and inverter data
            String inverterName = '';
            Integer inverterSum = 0;
            String inverterManufacturer = '';
            String panelName = '';
            Integer panelSum = 0;
            String panelManufacturer = '';
            for (AggregateResult ar : sdiAggregate){
                if ((String)ar.get('rType') == 'Inverter'){     //RecordType.Name
                    if ((Integer)ar.get('expr0') > inverterSum){    //Accounting for the (minimal) possibility of more than one Inverter type
                        inverterSum = (Integer)ar.get('expr0');     //Count
                        inverterName = (String)ar.get('descr');     //System_Design_Product__r.Description__c
                        inverterManufacturer = (String)ar.get('make');  ////System_Design_Product__r.Make__c
                    }
                } else if ((String)ar.get('rType') == 'Panel'){
                    if ((Integer)ar.get('expr0') > panelSum){   //Accounting for the (minimal) possibility of more than one Panel type
                        panelSum = (Integer)ar.get('expr0');
                        panelName = (String)ar.get('descr');
                        panelManufacturer = (String)ar.get('make');
                    }
                }
            }
            contr.Panel_Count__c = sdq.Panel_Count__c != null ? sdq.Panel_Count__c : panelSum;
            contr.Panel_Type__c = panelName;
            contr.Module_Manufacturer__c = panelManufacturer;
            contr.Inverter_Count__c = contr.Panel_Count__c;  //inverterSum;
            contr.Inverter_Type__c = inverterName;
            contr.Inverter_Manufacturer__c = inverterManufacturer;
            
            //CPQ-749
            if ((String)sdq.get('Scenario_' + scenario + '_Financing_Type__c') == 'PPA'){
                try {
                    String buyoutBasis = (String)sdq.getSObject('Scenario_' + scenario + '_Lease_Fund__r').get('System_Buyout_Basis_EPC__c');
                    String epcRate = buyoutBasis.substringBetween(contr.Property_State__c + ',', ';');  //Pairings like CA, 4.99; NY, 4.87; MA, 5.25; HI 5.5; CT, 5.00; MD, 4.32; NJ, 5.00;
                    contr.PPA_System_Buyout_Basis_EPC__c = Decimal.valueOf(epcRate.trim());
                } catch (Exception e){
                    System.debug('Failed while parsing System Buyout Basis: ' + e.getStackTraceString());
                    contr.PPA_System_Buyout_Basis_EPC__c = -1;
                }
            }

            contr.Total_System_Price__c = (Decimal)sdq.get('Scenario_' + scenario + '_Final_EPC_Price_NUM__c');
            contr.Federal_Tax_Credit__c = (Decimal)sdq.get('Scenario_' + scenario + '_Federal_Tax_Credit_Amount__c');
            contr.State_Grant_Amount__c = (Decimal)sdq.get('Scenario_' + scenario + '_State_Rebate_Amount__c');
            contr.State_Tax_Credit__c = (Decimal)sdq.get('Scenario_' + scenario + '_State_Tax_Credit_Amount__c');
            contr.Upfront_SREC_Amount__c = ignoreNull((Decimal)sdq.get('Scenario_' + scenario + '_Upfront_SREC_Amount__c'));
            contr.Utility_Incentive_Amount__c = (Decimal)sdq.get('Scenario_' + scenario + '_Utility_Rebate_Amount__c');
            
            //If State in (CT,NY) then $0, else: (Scenario_N_State_Rebate_Amount__c * SDQ.Income_Corporate_Tax_Rate__c)
            Set<String> states = new Set<String>{'CT', 'NY'};
            contr.State_Grant_Tax_Amount__c = states.contains(contr.Property_State__c) ? 0 : ignoreNull((Decimal)sdq.get('Scenario_' + scenario + '_State_Rebate_Amount__c')) * ignoreNull(sdq.Income_Corporate_Tax_Rate__c);
            
            contr.Local_Tax_Credit__c = ignoreNull((Decimal)sdq.get('Scenario_' + scenario + '_Local_Tax_Credit_Amount__c'));
            
            contr.System_Net_Cost__c = ignoreNull((Decimal)sdq.get('Scenario_' + scenario + '_Final_EPC_Price__c')) + ignoreNull((Decimal)sdq.get('Scenario_' + scenario + '_Total_Net_Adjustment__c')) - 
                                       ignoreNull((Decimal)sdq.get('Scenario_' + scenario + '_Federal_Tax_Credit_Amount__c')) - ignoreNull((Decimal)sdq.get('Scenario_' + scenario + '_State_Rebate_Amount__c')) - 
                                       ignoreNull((Decimal)sdq.get('Scenario_' + scenario + '_State_Tax_Credit_Amount__c')) - ignoreNull((Decimal)sdq.get('Scenario_' + scenario + '_Utility_Rebate_Amount__c')) - 
                                       ignoreNull((Decimal)sdq.get('Scenario_' + scenario + '_County_Tax_Credit_Amount__c')) - ignoreNull((Decimal)sdq.get('Scenario_' + scenario + '_Depreciation_Basis__c')) - 
                                       ignoreNull((Decimal)sdq.get('Scenario_' + scenario + '_Upfront_SREC_Amount__c'));

            contr.Purchase_Price_Due_at_Signing__c = (Decimal)proposal.get('Scenario_' + scenario + '_Payment_Due_Signing__c');
            contr.Purchase_Price_Due_First_Day_Install__c = (Decimal)proposal.get('Scenario_' + scenario + '_Payment_Due_Installation__c');
            contr.Purchase_Price_Due_Final_Inspection__c = (Decimal)proposal.get('Scenario_' + scenario + '_Payment_Due_Final_Inspection__c');
            //TO DO: Monitoring Device = Make field for either Enphase or SolarEdge
            
            Integer inverterWarranty = defaultWarrantyYears != null ? defaultWarrantyYears : 10;
            Integer limitedProdExtWarranty = (Integer)Warranty_Offer_Settings__c.getOrgDefaults().Default_Limited_Production_Warranty__c;
            Integer partsAndLaborWarranty = (Integer)Warranty_Offer_Settings__c.getOrgDefaults().Default_Parts_Labor_Warranty__c;
            Integer guaranteeNewRoof = (Integer)Warranty_Offer_Settings__c.getOrgDefaults().Default_New_Roof_Guarantee__c;
            Integer guaranteeSystemMoving = (Integer)Warranty_Offer_Settings__c.getOrgDefaults().Default_System_Moving_Guarantee__c;

            for (Price_Adjustment__c pa : priceAdjs){   //CPQ-635
                if (pa.Entitlement_Offer__c != null && pa.Entitlement_Offer__r.Inverter_Extended_Warranty_Years__c != null)
                    inverterWarranty = (Integer)pa.Entitlement_Offer__r.Inverter_Extended_Warranty_Years__c;
                if (pa.Entitlement_Offer__c != null && pa.Entitlement_Offer__r.Limited_Production_Ext_Warranty_Years__c != null)
                    limitedProdExtWarranty = (Integer)pa.Entitlement_Offer__r.Limited_Production_Ext_Warranty_Years__c;
                if (pa.Entitlement_Offer__c != null && pa.Entitlement_Offer__r.Parts_Labor_Extended_Warranty_Years__c != null)
                    partsAndLaborWarranty = (Integer)pa.Entitlement_Offer__r.Parts_Labor_Extended_Warranty_Years__c;
                if (pa.Entitlement_Offer__c != null && pa.Entitlement_Offer__r.New_Roof_Extended_Guarantee_Years__c != null)
                    guaranteeNewRoof = (Integer)pa.Entitlement_Offer__r.New_Roof_Extended_Guarantee_Years__c;
                if (pa.Entitlement_Offer__c != null && pa.Entitlement_Offer__r.System_Moving_Extended_Guarantee_Years__c != null)
                    guaranteeSystemMoving = (Integer)pa.Entitlement_Offer__r.System_Moving_Extended_Guarantee_Years__c;
            }

            Map<Integer, String> yearsAsText = new Map<Integer, String>{10 => 'Ten', 12 => 'Twelve', 15 => 'Fifteen', 20 => 'Twenty', 25 => 'Twenty Five'};

            contr.Warranty_Years_Inverter_Num__c = inverterWarranty;
            contr.Warranty_Years_Inverter_Text__c = yearsAsText.get(inverterWarranty);

            contr.Warranty_Years_Parts_Labor_Num__c = partsAndLaborWarranty;
            contr.Warranty_Years_Parts_Labor_Text__c =  yearsAsText.get(partsAndLaborWarranty);
            contr.Warranty_Years_Limited_Production_Num__c = limitedProdExtWarranty;
            contr.Warranty_Years_Limited_Production_Text__c = yearsAsText.get(limitedProdExtWarranty);
            contr.Guarantee_Years_System_Moving_Num__c = guaranteeSystemMoving;
            contr.Guarantee_Years_System_Moving_Text__c = yearsAsText.get(guaranteeSystemMoving);
            contr.Guarantee_Years_New_Roof_Num__c = guaranteeNewRoof;
            contr.Guarantee_Years_New_Roof_Text__c = yearsAsText.get(guaranteeNewRoof);
            
            Double esc = 1.03;     //Escalator = 3%
            Integer multiplier = foundPremiumProductionGuarantee ? 2 : 1; 
            
            //(SDQ.Scenario_N_Avoided_Utility_Rate__c * (1 + Escalator) ^ (Year - 1)) * Multiplier
            Decimal avgRate = ignoreNull(sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Before_First_Year_Avg_Price__c);
            contr.Guaranteed_Price_Per_kWh_Year_1__c = avgRate * multiplier;
            contr.Guaranteed_Price_Per_kWh_Year_2__c = contr.Guaranteed_Price_Per_kWh_Year_1__c * Math.pow(esc, Double.valueOf(1.0));
            contr.Guaranteed_Price_Per_kWh_Year_3__c = contr.Guaranteed_Price_Per_kWh_Year_1__c * Math.pow(esc, Double.valueOf(2.0));
            contr.Guaranteed_Price_Per_kWh_Year_4__c = contr.Guaranteed_Price_Per_kWh_Year_1__c * Math.pow(esc, Double.valueOf(3.0));
            contr.Guaranteed_Price_Per_kWh_Year_5__c = contr.Guaranteed_Price_Per_kWh_Year_1__c * Math.pow(esc, Double.valueOf(4.0));
            contr.Guaranteed_Price_Per_kWh_Year_6__c = contr.Guaranteed_Price_Per_kWh_Year_1__c * Math.pow(esc, Double.valueOf(5.0));
            contr.Guaranteed_Price_Per_kWh_Year_7__c = contr.Guaranteed_Price_Per_kWh_Year_1__c * Math.pow(esc, Double.valueOf(6.0));
            contr.Guaranteed_Price_Per_kWh_Year_8__c = contr.Guaranteed_Price_Per_kWh_Year_1__c * Math.pow(esc, Double.valueOf(7.0));
            contr.Guaranteed_Price_Per_kWh_Year_9__c = contr.Guaranteed_Price_Per_kWh_Year_1__c * Math.pow(esc, Double.valueOf(8.0));
            contr.Guaranteed_Price_Per_kWh_Year_10__c = contr.Guaranteed_Price_Per_kWh_Year_1__c * Math.pow(esc, Double.valueOf(9.0));
            contr.Guaranteed_Price_Per_kWh_Year_11__c = contr.Guaranteed_Price_Per_kWh_Year_1__c * Math.pow(esc, Double.valueOf(10.0));
            contr.Guaranteed_Price_Per_kWh_Year_12__c = contr.Guaranteed_Price_Per_kWh_Year_1__c * Math.pow(esc, Double.valueOf(11.0));
            contr.Guaranteed_Price_Per_kWh_Year_13__c = contr.Guaranteed_Price_Per_kWh_Year_1__c * Math.pow(esc, Double.valueOf(12.0));
            contr.Guaranteed_Price_Per_kWh_Year_14__c = contr.Guaranteed_Price_Per_kWh_Year_1__c * Math.pow(esc, Double.valueOf(13.0));
            contr.Guaranteed_Price_Per_kWh_Year_15__c = contr.Guaranteed_Price_Per_kWh_Year_1__c * Math.pow(esc, Double.valueOf(14.0));
            contr.Guaranteed_Price_Per_kWh_Year_16__c = contr.Guaranteed_Price_Per_kWh_Year_1__c * Math.pow(esc, Double.valueOf(15.0));
            contr.Guaranteed_Price_Per_kWh_Year_17__c = contr.Guaranteed_Price_Per_kWh_Year_1__c * Math.pow(esc, Double.valueOf(16.0));
            contr.Guaranteed_Price_Per_kWh_Year_18__c = contr.Guaranteed_Price_Per_kWh_Year_1__c * Math.pow(esc, Double.valueOf(17.0));
            contr.Guaranteed_Price_Per_kWh_Year_19__c = contr.Guaranteed_Price_Per_kWh_Year_1__c * Math.pow(esc, Double.valueOf(18.0));
            contr.Guaranteed_Price_Per_kWh_Year_20__c = contr.Guaranteed_Price_Per_kWh_Year_1__c * Math.pow(esc, Double.valueOf(19.0));
            
            Decimal performanceGuarantee = foundPremiumProductionGuarantee ? 0.95 : 0.90;
            Decimal performanceDegradation = 0.005; //Default = .005, NRG = 0.007, Kilowatt = 0.0075, Liberty = .005
            //On the SDQ, in the Scenario N Lease Fund and Financing Option will be the values for NRG, Kilowatt, Liberty, etc. Those 3 in particular are in the Lease Fund field.
            
            //SDQ.Scenario_N_Total_Projected_Annual_Output__c * (Performance Guarantee) * (1 - Performance Guarantee Degradation) ^ (Year - 1)
            Decimal projAnnualOutput = ignoreNull((Decimal)sdq.get('Scenario_' + scenario + '_Total_Projected_Annual_Output__c'));
            contr.Guaranteed_Sys_Output_kWh_Year_1__c = projAnnualOutput * performanceGuarantee * Math.pow((Double)(1 - performanceDegradation), Double.valueOf(0.0));
            contr.Guaranteed_Sys_Output_kWh_Year_2__c = projAnnualOutput * performanceGuarantee * Math.pow((Double)(1 - performanceDegradation), Double.valueOf(1.0));
            contr.Guaranteed_Sys_Output_kWh_Year_3__c = projAnnualOutput * performanceGuarantee * Math.pow((Double)(1 - performanceDegradation), Double.valueOf(2.0));
            contr.Guaranteed_Sys_Output_kWh_Year_4__c = projAnnualOutput * performanceGuarantee * Math.pow((Double)(1 - performanceDegradation), Double.valueOf(3.0));
            contr.Guaranteed_Sys_Output_kWh_Year_5__c = projAnnualOutput * performanceGuarantee * Math.pow((Double)(1 - performanceDegradation), Double.valueOf(4.0));
            contr.Guaranteed_Sys_Output_kWh_Year_6__c = projAnnualOutput * performanceGuarantee * Math.pow((Double)(1 - performanceDegradation), Double.valueOf(5.0));
            contr.Guaranteed_Sys_Output_kWh_Year_7__c = projAnnualOutput * performanceGuarantee * Math.pow((Double)(1 - performanceDegradation), Double.valueOf(6.0));
            contr.Guaranteed_Sys_Output_kWh_Year_8__c = projAnnualOutput * performanceGuarantee * Math.pow((Double)(1 - performanceDegradation), Double.valueOf(7.0));
            contr.Guaranteed_Sys_Output_kWh_Year_9__c = projAnnualOutput * performanceGuarantee * Math.pow((Double)(1 - performanceDegradation), Double.valueOf(8.0));
            contr.Guaranteed_Sys_Output_kWh_Year_10__c = projAnnualOutput * performanceGuarantee * Math.pow((Double)(1 - performanceDegradation), Double.valueOf(9.0));
            contr.Guaranteed_Sys_Output_kWh_Year_11__c = projAnnualOutput * performanceGuarantee * Math.pow((Double)(1 - performanceDegradation), Double.valueOf(10.0));
            contr.Guaranteed_Sys_Output_kWh_Year_12__c = projAnnualOutput * performanceGuarantee * Math.pow((Double)(1 - performanceDegradation), Double.valueOf(11.0));
            contr.Guaranteed_Sys_Output_kWh_Year_13__c = projAnnualOutput * performanceGuarantee * Math.pow((Double)(1 - performanceDegradation), Double.valueOf(12.0));
            contr.Guaranteed_Sys_Output_kWh_Year_14__c = projAnnualOutput * performanceGuarantee * Math.pow((Double)(1 - performanceDegradation), Double.valueOf(13.0));
            contr.Guaranteed_Sys_Output_kWh_Year_15__c = projAnnualOutput * performanceGuarantee * Math.pow((Double)(1 - performanceDegradation), Double.valueOf(14.0));
            contr.Guaranteed_Sys_Output_kWh_Year_16__c = projAnnualOutput * performanceGuarantee * Math.pow((Double)(1 - performanceDegradation), Double.valueOf(15.0));
            contr.Guaranteed_Sys_Output_kWh_Year_17__c = projAnnualOutput * performanceGuarantee * Math.pow((Double)(1 - performanceDegradation), Double.valueOf(16.0));
            contr.Guaranteed_Sys_Output_kWh_Year_18__c = projAnnualOutput * performanceGuarantee * Math.pow((Double)(1 - performanceDegradation), Double.valueOf(17.0));
            contr.Guaranteed_Sys_Output_kWh_Year_19__c = projAnnualOutput * performanceGuarantee * Math.pow((Double)(1 - performanceDegradation), Double.valueOf(18.0));
            contr.Guaranteed_Sys_Output_kWh_Year_20__c = projAnnualOutput * performanceGuarantee * Math.pow((Double)(1 - performanceDegradation), Double.valueOf(19.0));
            contr.Cumulative_Guaranteed_Sys_Output__c = contr.Guaranteed_Sys_Output_kWh_Year_1__c + contr.Guaranteed_Sys_Output_kWh_Year_2__c + contr.Guaranteed_Sys_Output_kWh_Year_3__c + 
                                                        contr.Guaranteed_Sys_Output_kWh_Year_4__c + contr.Guaranteed_Sys_Output_kWh_Year_5__c + contr.Guaranteed_Sys_Output_kWh_Year_6__c + 
                                                        contr.Guaranteed_Sys_Output_kWh_Year_7__c + contr.Guaranteed_Sys_Output_kWh_Year_8__c + contr.Guaranteed_Sys_Output_kWh_Year_9__c + 
                                                        contr.Guaranteed_Sys_Output_kWh_Year_10__c + contr.Guaranteed_Sys_Output_kWh_Year_11__c + contr.Guaranteed_Sys_Output_kWh_Year_12__c + 
                                                        contr.Guaranteed_Sys_Output_kWh_Year_13__c + contr.Guaranteed_Sys_Output_kWh_Year_14__c + contr.Guaranteed_Sys_Output_kWh_Year_15__c + 
                                                        contr.Guaranteed_Sys_Output_kWh_Year_16__c + contr.Guaranteed_Sys_Output_kWh_Year_17__c + contr.Guaranteed_Sys_Output_kWh_Year_18__c + 
                                                        contr.Guaranteed_Sys_Output_kWh_Year_19__c + contr.Guaranteed_Sys_Output_kWh_Year_20__c;
            
            contr.County_Lease_Tax_Rate__c = 0;
            County__c[] county = [SELECT County_Lease_Tax_Rate__c FROM County__c WHERE State__r.State_Abbreviation__c = :contr.Property_State__c AND Pricing_Region__c = :sdq.Pricing_Region__c 
                                  AND NAME LIKE :(contr.Property_County__c + '%') LIMIT 1];
            if (!county.isEmpty()){
                contr.County_Lease_Tax_Rate__c = county[0].County_Lease_Tax_Rate__c != null ? county[0].County_Lease_Tax_Rate__c : 0;
            }

            contr.Down_Payment__c = (Decimal)sdq.get('Scenario_' + scenario + '_Down_Payment__c');
            contr.Total_Prepaid_Lease_Amount__c = ignoreNull((Decimal)sdq.get('Scenario_' + scenario + '_Prepaid_Financing_Amount__c')) * (1.0 + contr.County_Lease_Tax_Rate__c);
            contr.Prepaid_Lease_Upfront_Payment__c = contr.Total_Prepaid_Lease_Amount__c * 0.3;


            String leaseEscStr = sdq.get('Scenario_' + scenario + '_Lease_Escalator__c') != null ? (String)sdq.get('Scenario_' + scenario + '_Lease_Escalator__c') : '';
            leaseEscStr = leaseEscStr.remove('.').isNumeric() ? (String)sdq.get('Scenario_' + scenario + '_Lease_Escalator__c') : '0';
            contr.Lease_Escalator__c = (Decimal)Double.valueOf(leaseEscStr) / 100;
            contr.Year_One_Production_Estimate__c = projAnnualOutput;
            
            //Sum(1-Y)(SDQ.Scenario_N_Total_Projected_Annual_Output__c * (1 - Performance Guarantee Degradation) ^ (Year - 1))
            Integer yearsInTerm = Integer.valueOf(Math.floor(Double.valueOf(ignoreNull((Double)proposal.get('Scenario_' + scenario + '_Proposal_Term_Months__c'))) / 12.0));
            Decimal sumAnnualOutput = 0.0;
            for (Integer year = 1; year <= yearsInTerm; year++){
                sumAnnualOutput += projAnnualOutput * Math.pow((Double)(1 - performanceDegradation), (Double)(year - 1));
            }
            contr.Initial_Term_Production_Estimate__c = sumAnnualOutput;
            
            contr.Estimated_Year_One_Price_Per_KWH__c = ignoreNull((Decimal)sdq.get('Scenario_' + scenario + '_Financing_Rate_Year_1_kWh__c'));
            contr.Kilowatt_Other_Charges__c = 0.0;
            if (sdq.getSObject('Scenario_' + scenario + '_SAC_Loan__r') != null)
                contr.SAC_APR__c = (Decimal)sdq.getSObject('Scenario_' + scenario + '_SAC_Loan__r').get('OID__c');
            contr.SAC_Finance_Charge__c = 0.0;
            //TO DO: SAC Financed Amount = If SAC Option = "Hudson" and State in (CT,NY), then (SDQ.Scenario_N_Utility_Rebate_Amount__c + SDQ.Scenario_N_State_Tax_Credit_Amount__c + SDQ.Scenario_N_Federal_Tax_Credit_Amount__c), 
            //       else if SAC Option = "Hudson" and State <> (CT,NY) then (SDQ.Scenario_N_Utility_Rebate_Amount__c + SDQ.Scenario_N_State_Tax_Credit_Amount__c + SDQ.Scenario_N_Federal_Tax_Credit_Amount__c + SDQ.State_Rebate_Amount__c)
            contr.SAC_Financed_Amount__c = (Decimal)sdq.get('Scenario_' + scenario + '_SAC_Loan_Amount__c');
            contr.SAC_Total_Payments__c = contr.SAC_Financed_Amount__c;
            if (sdq.getSObject('Scenario_' + scenario + '_Term_Loan__r') != null)
                contr.Term_Loan_APR__c = (Decimal)sdq.getSObject('Scenario_' + scenario + '_Term_Loan__r').get('APR__c');
            contr.Term_Loan_Financed_Amount__c = (Decimal)sdq.get('Scenario_' + scenario + '_Term_Loan_Amount__c');
            contr.Term_Loan_Term__c = Integer.valueOf((Decimal)proposal.get('Scenario_' + scenario + '_Proposal_Term_Months__c'));
            contr.Term_Loan_First_Payment_Date__c = Date.today().addDays(150);
            contr.Term_Loan_Last_Payment_Date__c = Date.today().addDays(Integer.valueOf(Math.floor(150 + (365.25 * yearsInTerm))));
            //TO DO: SAC Balloon Payment = SAC_Financed_Amount * (1-SAC_APR)
            //TO DO: SAC Maturity Date = If Finance Type = "Hudson" and SAC Term = 12 months then Today() + 423.25 days, else if SAC Term = 18 months then Today() + 605.875 days.
            contr.Term_Loan_Completion_Payment__c = ignoreNull(contr.Term_Loan_Financed_Amount__c) * 0.7;
            contr.Term_Loan_Interconnect_Payment__c = ignoreNull(contr.Term_Loan_Financed_Amount__c) * 0.3;
            contr.Term_Loan_Est_Completion_Date__c = Date.today().addDays(120);
            contr.Est_Interconnect_Date__c = Date.today().addDays(150);
            contr.SAC_Completion_Payment__c = ignoreNull(contr.SAC_Financed_Amount__c) * 0.7;
            contr.SAC_Interconnect_Payment__c = ignoreNull(contr.SAC_Financed_Amount__c) * 0.3;
            contr.Gross_Amount_Due__c = ignoreNull(contr.Term_Loan_Financed_Amount__c) + ignoreNull(contr.SAC_Financed_Amount__c);
            contr.OID_Amount__c = ignoreNull(contr.SAC_Financed_Amount__c) * (ignoreNull(contr.SAC_APR__c) / 100);
            contr.Net_Proceeds__c = ignoreNull(contr.Gross_Amount_Due__c) - ignoreNull(contr.OID_Amount__c);

            //CPQ-749
            if ((String)sdq.get('Scenario_' + scenario + '_Financing_Type__c') == 'PPA' && contr.PPA_System_Buyout_Basis_EPC__c != null && contr.System_Size__c != null){
                Decimal discountRate = 0;
                if (sdq.getSObject('Scenario_' + scenario + '_Lease_Fund__r') != null && sdq.getSObject('Scenario_' + scenario + '_Lease_Fund__r').get('Buyout_Discount_Rate__c') != null)
                    discountRate = (Decimal)sdq.getSObject('Scenario_' + scenario + '_Lease_Fund__r').get('Buyout_Discount_Rate__c') / 100;
                
                Decimal[] ppaBuyoutCosts = getOneRoofBuyoutCostsPPA(contr, discountRate);

                for (Integer i = 1; i <= ppaBuyoutCosts.size(); i++)
                    contr.put('Year_' + i + '_OneRoof_PPA_Buyout_Cost__c', ppaBuyoutCosts[i-1]);    //Year_N_OneRoof_PPA_Buyout_Cost__c
            }

        } catch (Exception e) {
            throw e;
        }
        
        return contr;
    }
    
    @TestVisible private static Decimal[] getOneRoofBuyoutCostsPPA(Astrum_Contract__c contr, Decimal discountRate){
        Decimal[] nonDegradedAnnualPaymentsPPA = new Decimal[]{};
        for (Integer i = 0; i < 20; i++)
            nonDegradedAnnualPaymentsPPA.add(contr.Year_One_Production_Estimate__c * contr.Estimated_Year_One_Price_Per_KWH__c * Math.pow((Double)(1 + contr.Lease_Escalator__c), Double.valueOf(i)));
        
        Decimal[] ppaBuyoutCosts = new Decimal[]{};
        Decimal coeff = 1;  //Will decrement by 0.2 until it reaches 0

        for (Integer i = 0; i < 20; i++){
            Decimal additionalTerm = 0;
            if (coeff > 0){
                additionalTerm = ((-1 * 0.3 * coeff * contr.System_Size__c * contr.PPA_System_Buyout_Basis_EPC__c * 1000 * 0.5 * 0.35) / 0.65) + 
                                    ((0.3 * coeff * contr.System_Size__c * contr.PPA_System_Buyout_Basis_EPC__c * 1000) / 0.65);
            }

            Decimal reverseCount = 20 - (i + 1);    //Year 1: 19, Year 2: 18, ... Year 19: 1, Year 20: 0
            additionalTerm += (contr.System_Size__c * contr.PPA_System_Buyout_Basis_EPC__c * 0.2 * 1000) / Math.pow(Double.valueOf(1.05), (Double)reverseCount);
            
            Decimal sumYearlyPayments = 0;
            Integer yearInc = i;
            for (Integer j = 0; j <= reverseCount; j++){
                sumYearlyPayments += nonDegradedAnnualPaymentsPPA[yearInc] / Math.pow(Double.valueOf(1 + discountRate), (Double)j);
                //System.debug('nonDegradedAnnualPaymentsPPA[yearInc] / Math.pow(1 + discountRate, j) = ' + nonDegradedAnnualPaymentsPPA[yearInc] + ' / ' + (1 + discountRate) + ' ^ ' + j);
                yearInc++;
            }
            Decimal cost = additionalTerm + sumYearlyPayments;
            ppaBuyoutCosts.add(cost);
            System.debug('getOneRoofBuyoutCostsPPA(): coeff = ' + coeff + ', reverseCount = ' + reverseCount + ', additionalTerm = ' + 
                            additionalTerm.setScale(2) + ', sumYearlyPayments = ' + sumYearlyPayments.setScale(2) + ', Buyout Cost for year ' + (i+1) + ' = ' + cost.setScale(2));
            coeff = coeff - 0.2;    //Doesn't matter once it's less than 0
        }
        return ppaBuyoutCosts;
    }

    private static Decimal ignoreNull(Decimal dec){
        Decimal result = dec == null ? 0 : dec;
        return result;
    }
}