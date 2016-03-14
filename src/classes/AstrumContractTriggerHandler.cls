/* FILE: AstrumContractTriggerHandler.cls
   AUTHOR: Dan Kelner
   DATE: 12/12/14
   PURPOSE: Common trigger handler for Astrum_Contract__c
   MODIFICATION HISTORY: 
        03/30/15  DK  Added determineCongaTemplateURLs()
        04/03/15  DK  Added nameContractPDF()
        01/20/16  DK  Added start/end date support to Conga Templates for CPQ-717
*/
public class AstrumContractTriggerHandler {
    
    public static Boolean isAstrumContractTriggerRunning = false;
    public static boolean skipAstrumContractTrigger = false;

    //Reduce SOQl queries with these variables
    private Map<String, System_Design_Quote__c> sdqMap;     //Name --> SDQ

    private Boolean m_isExecuting = false;
    //TO DO: A private variable to flag whether the current context is "before" or "after" so that methods know whether or not to use DML?

    public AstrumContractTriggerHandler(Boolean isExecuting){      
        m_isExecuting = isExecuting;
    }

    public void OnBeforeInsert(Astrum_Contract__c[] newContracts){
        // EXECUTE BEFORE INSERT LOGIC 
        setOpenQuote(newContracts);
        m_isExecuting = false;
    }

    public void OnBeforeUpdate(Astrum_Contract__c[] updatedContracts, Map<ID, Astrum_Contract__c> contractMap, Map<ID, Astrum_Contract__c> oldContractMap){
        // BEFORE UPDATE LOGIC  
        setOpenQuote(updatedContracts);
        m_isExecuting = false;
    }

    public void OnAfterInsert(Astrum_Contract__c[] insertedContracts, Map<ID, Astrum_Contract__c> insertedContractsMap){
        // EXECUTE AFTER INSERT LOGIC
        initGlobals(insertedContracts);

        determineCongaTemplateURLs(insertedContracts);
        nameContractPDF(insertedContracts);
        continueCalculations(insertedContracts);
        setupAppliedJunctions(insertedContracts);
        m_isExecuting = false;
    }

    public void OnAfterUpdate(Astrum_Contract__c[] updatedContracts, Map<ID, Astrum_Contract__c> contractMap, Map<ID, Astrum_Contract__c> oldContractMap){
        //  EXECUTE AFTER UPDATE LOGIC
        m_isExecuting = false;
    }

    public Boolean IsTriggerContext {
        get { return m_isExecuting; }
    }

    private void initGlobals(Astrum_Contract__c[] updatedContracts){
        Set<String> sdqNames = new Set<String>();
        for (Astrum_Contract__c contr : updatedContracts)
            sdqNames.add(contr.System_Design_Quote_Name__c);    //Use the formula lookup to the unique SDQ name to build a keyset (without having to do a query!)
        sdqMap = new Map<String, System_Design_Quote__c>();
        for (System_Design_Quote__c sdq : [SELECT Name, Pricing_Date__c, System_Design__r.Tree_Removal__c, Community_Program_Offer__r.Conga_Template__c, 

                                            (SELECT Promotion__r.Conga_Template__c, Entitlement_Offer__r.Conga_Template__c, Applicable_Scenario__c, 
                                                Amount__c, Amount_per_Watt__c, Apply_as_Net_Adjustment__c, Channel_Partner_Adjustment__c, Name, Effective_Dollar_Amount__c, 
                                                Guaranteed_Rate__c, Percent__c, Production_Guarantee__c, RecordType.Name, Type__c 
                                                FROM Price_Adjustments__r WHERE Adjustment_Applied__c = true AND (Promotion__c != null OR Entitlement_Offer__c != null)),

                                            (SELECT Applicable_Scenario__c, Name, RecordType.Name, Effective_Dollar_Amount__c, Eligible_Sector__c, Estimated_Date_of_First_Payment__c, 
                                                Estimated_Days_to_Payment__c, Estimated_Payment_Month__c, Estimated_Payment_Year_Offset__c, Feed_In_Tariff_Annual_Earnings_After_Tax__c, 
                                                Flat_Rebate_Amount__c, Implementing_Sector__c, Incentive_Applied__c, Incentive_Offer__c, Incentive_Recipient__c, PBI_Amount__c, SAC_Eligible__c, 
                                                Tax_Credit_Rate__c, Term_Months__c, Tier_1_Incentive_Rate_W__c, Tier_1_Maximum_System_Size_kW__c, Tier_2_Incentive_Rate_W__c, 
                                                Tier_2_Maximum_System_Size_kW__c, Tier_Pricing_Type__c, TSRF_Adjustment_Type__c, Utility_Company_Matching_Required__c 
                                                FROM Available_Incentive_Offers__r WHERE Incentive_Offer__c != null AND Incentive_Applied__c = true), 

                                            (SELECT SREC_Contract_Offer__r.Conga_Template__c, Applicable_Scenario__c, Name, RecordType.Name, Contract_Length_months__c, 
                                                Default_Offer__c, SREC_Contract_Offer__c, Upfront_Amount__c, Upfront_Effective_Dollar_Amount__c, Yearly_Amount_SREC__c, Yearly_Amount_of_ACP__c 
                                                FROM Available_SREC_Contract_Offers__r WHERE SREC_Contract_Offer__c != null AND Contract_Offer_Applied__c = true) 
                                        FROM System_Design_Quote__c WHERE Name IN :sdqNames]){
            sdqMap.put(sdq.Name, sdq);
        }
    }
    
    //------------------------------------------------//
    
    public void setOpenQuote(Astrum_Contract__c[] contracts){    //The "Open Quote" field is controlled by the parent Proposal
        Set<ID> propIDs = new Set<ID>();
        for (Astrum_Contract__c contr : contracts)
            propIDs.add(contr.Proposal__c);

        if (propIDs.size() == 0)
            return;

        Map<ID, Proposal__c> proposalMap = new Map<ID, Proposal__c>([SELECT Open_Quote__c FROM Proposal__c WHERE ID IN :propIDs]);
        
        for (Astrum_Contract__c contr : contracts){
            Proposal__c prop = proposalMap.get(contr.Proposal__c);
            if (prop != null){
                if (prop.Open_Quote__c == true){
                    contr.Open_Quote__c = true;
                } else {
                    contr.Open_Quote__c = false;
                }
            }
        }
        //No DML necessary as long as this method is called from a "before" context
    }

    //The ID strings will have to be updated depending on the Salesforce environment (read: org)
    public void determineCongaTemplateURLs(Astrum_Contract__c[] insertedContracts){
        Astrum_Contract__c[] contractsToUpdate = new Astrum_Contract__c[]{};
        Map<ID, APXTConga4__Conga_Template__c> templates = new Map<ID, APXTConga4__Conga_Template__c>(
                                                    [SELECT Name, Eligible_States__c, Financing_Type__c, Lease_Fund__r.Name, Lease_Option__c, 
                                                     SAC_Loan__r.Name, Term_Loan__r.Name, Start_Date__c, End_Date__c FROM APXTConga4__Conga_Template__c]);

        for (Astrum_Contract__c contr : insertedContracts){
            String congaIDs = '';
            System_Design_Quote__c sdq = sdqMap.get(contr.System_Design_Quote_Name__c);
            
            Date pricingDate = Date.today();
            if (sdq.Pricing_Date__c != null)
                pricingDate = Date.newInstance(sdq.Pricing_Date__c.year(), sdq.Pricing_Date__c.month(), sdq.Pricing_Date__c.day());

            for (APXTConga4__Conga_Template__c ct : templates.values()){
                String termLoanName = ct.Term_Loan__c != null ? ct.Term_Loan__r.Name : null;
                String sacLoanName = ct.SAC_Loan__c != null ? ct.SAC_Loan__r.Name : null;
                String leaseFundName = ct.Lease_Fund__c != null ? ct.Lease_Fund__r.Name : null;
                String propState = contr.Property_State__c != null ? contr.Property_State__c : '';

                if ((ct.Start_Date__c == null || ct.Start_Date__c <= pricingDate) && (ct.End_Date__c == null || ct.End_Date__c >= pricingDate)){    //CPQ-717
                    if (ct.Financing_Type__c == contr.Financing_Type__c && termLoanName == contr.Term_Loan__c && sacLoanName == contr.SAC_Loan__c && 
                        leaseFundName == contr.Lease_Fund__c && ct.Lease_Option__c == contr.Lease_Option__c && ct.Eligible_States__c != null && ct.Eligible_States__c.contains(propState)){
                        congaIDs += ct.ID + ',';    //Add this template if the financing fields match
                    } else if (ct.Name == 'CPQ Tree Removal Addendum' && sdq.System_Design__r.Tree_Removal__c == true){
                        congaIDs += ct.ID + ',';
                    }
                }
            }

            for (Price_Adjustment__c pa : sdq.Price_Adjustments__r){
                if (pa.Applicable_Scenario__c == contr.Scenario__c){
                    if (pa.Promotion__c != null && pa.Promotion__r.Conga_Template__c != null){
                        APXTConga4__Conga_Template__c ct = templates.get(pa.Promotion__r.Conga_Template__c);
                        if ((ct.Start_Date__c == null || ct.Start_Date__c <= pricingDate) && (ct.End_Date__c == null || ct.End_Date__c >= pricingDate))
                            congaIDs += pa.Promotion__r.Conga_Template__c + ',';
                    }
                    
                    if (pa.Entitlement_Offer__c != null && pa.Entitlement_Offer__r.Conga_Template__c != null){
                        APXTConga4__Conga_Template__c ct = templates.get(pa.Entitlement_Offer__r.Conga_Template__c);
                        if ((ct.Start_Date__c == null || ct.Start_Date__c <= pricingDate) && (ct.End_Date__c == null || ct.End_Date__c >= pricingDate))
                            congaIDs += pa.Entitlement_Offer__r.Conga_Template__c + ',';
                    }
                }
            }

            for (Available_SREC_Contract_Offer__c offer : sdq.Available_SREC_Contract_Offers__r){
                if (offer.Applicable_Scenario__c == contr.Scenario__c && offer.SREC_Contract_Offer__r.Conga_Template__c != null){
                    APXTConga4__Conga_Template__c ct = templates.get(offer.SREC_Contract_Offer__r.Conga_Template__c);
                    if ((ct.Start_Date__c == null || ct.Start_Date__c <= pricingDate) && (ct.End_Date__c == null || ct.End_Date__c >= pricingDate))
                        congaIDs += offer.SREC_Contract_Offer__r.Conga_Template__c + ',';
                }
            }

            if (sdq.Community_Program_Offer__c != null && sdq.Community_Program_Offer__r.Conga_Template__c != null){
                APXTConga4__Conga_Template__c ct = templates.get(sdq.Community_Program_Offer__r.Conga_Template__c);
                if ((ct.Start_Date__c == null || ct.Start_Date__c <= pricingDate) && (ct.End_Date__c == null || ct.End_Date__c >= pricingDate))
                    congaIDs += sdq.Community_Program_Offer__r.Conga_Template__c + ',';
            }

            if (contr.Cash_Rebate_Amount__c != null && Math.abs(contr.Cash_Rebate_Amount__c) > 0 && ContractSettings__c.getOrgDefaults().Cash_Rebate_Disclosure__c != null){
                APXTConga4__Conga_Template__c ct = templates.get(ID.valueOf(ContractSettings__c.getOrgDefaults().Cash_Rebate_Disclosure__c));
                if ((ct.Start_Date__c == null || ct.Start_Date__c <= pricingDate) && (ct.End_Date__c == null || ct.End_Date__c >= pricingDate))
                    congaIDs += ContractSettings__c.getOrgDefaults().Cash_Rebate_Disclosure__c + ',';     //CPQ-543, CPQ-792
            }

            congaIDs = congaIDs.remove('null,');
            if (congaIDs.endsWith(','))
                congaIDs = congaIDs.substringBeforeLast(',');

            Astrum_Contract__c contract = new Astrum_Contract__c(ID = contr.ID, Contract_Template_IDs__c = congaIDs);   //New sObject instance, because the existing ones are read-only
            if (contract.Contract_Template_IDs__c != '')
                contractsToUpdate.add(contract);
        }
        update contractsToUpdate;
    }

    public void nameContractPDF(Astrum_Contract__c[] insertedContracts){
        Astrum_Contract__c[] contractsToUpdate = new Astrum_Contract__c[]{};
        for (Astrum_Contract__c contr : insertedContracts){
            String pdfName = '';
            if (String.isBlank(contr.Term_Loan__c) && String.isBlank(contr.SAC_Loan__c) && String.isBlank(contr.Lease_Fund__c)){
                pdfName = contr.Signatory_1__c + ' - Purchase - ' + contr.Name;
                
            } else if (String.isNotBlank(contr.Term_Loan__c) && String.isBlank(contr.SAC_Loan__c) && String.isBlank(contr.Lease_Fund__c)){
                pdfName = contr.Signatory_1__c + ' - ' + contr.Term_Loan__c + ' - ' + contr.Name;
                
            } else if (String.isNotBlank(contr.Term_Loan__c) && String.isNotBlank(contr.SAC_Loan__c) && String.isBlank(contr.Lease_Fund__c)){
                pdfName = contr.Signatory_1__c + ' - ' + contr.Term_Loan__c + '; ' + contr.SAC_Loan__c + ' - ' + contr.Name;
                
            } else if (String.isBlank(contr.Term_Loan__c) && String.isNotBlank(contr.SAC_Loan__c) && String.isBlank(contr.Lease_Fund__c)){
                pdfName = contr.Signatory_1__c + ' - ' + contr.SAC_Loan__c + ' - ' + contr.Name;
                
            } else if (String.isBlank(contr.Term_Loan__c) && String.isBlank(contr.SAC_Loan__c) && String.isNotBlank(contr.Lease_Fund__c)){
                pdfName = contr.Signatory_1__c + ' - ' + contr.Lease_Fund__c + ' - ' + contr.Name;
                
            }
            Astrum_Contract__c contract = new Astrum_Contract__c(ID = contr.ID, Contract_PDF_Name__c = pdfName);   //New sObject instance, because the existing ones are read-only
            if (contract.Contract_PDF_Name__c != '')
                contractsToUpdate.add(contract);
        }
        update contractsToUpdate;
    }

    public void continueCalculations(Astrum_Contract__c[] insertedContracts){   //Peform the work that AstrumContractCalculations was unable to do, now that formula fields are initialized
        Astrum_Contract__c[] contractsToUpdate = new Astrum_Contract__c[]{};
        for (Astrum_Contract__c c : insertedContracts){
            Astrum_Contract__c contr = c.clone(true, true, true, true);   //New sObject instance, because the existing ones are read-only

            Decimal countyLeaseTaxRate = contr.County_Lease_Tax_Rate__c != null ? contr.County_Lease_Tax_Rate__c : 0;
            Decimal leaseEscalator = contr.Lease_Escalator__c != null ? contr.Lease_Escalator__c : 0;
            contr.First_Month_Payment_Post_Tax__c = c.First_Month_Payment_Pre_Tax__c * (1.0 + (countyLeaseTaxRate / 100));

            contr.Monthly_Payment_Year_1__c = contr.First_Month_Payment_Post_Tax__c;
            contr.Monthly_Payment_Year_2__c = c.First_Month_Payment_Pre_Tax__c * Math.pow((Double)(1 + leaseEscalator), Double.valueOf(1.0)) * (1.0 + (countyLeaseTaxRate / 100));
            contr.Monthly_Payment_Year_3__c = c.First_Month_Payment_Pre_Tax__c * Math.pow((Double)(1 + leaseEscalator), Double.valueOf(2.0)) * (1.0 + (countyLeaseTaxRate / 100));
            contr.Monthly_Payment_Year_4__c = c.First_Month_Payment_Pre_Tax__c * Math.pow((Double)(1 + leaseEscalator), Double.valueOf(3.0)) * (1.0 + (countyLeaseTaxRate / 100));
            contr.Monthly_Payment_Year_5__c = c.First_Month_Payment_Pre_Tax__c * Math.pow((Double)(1 + leaseEscalator), Double.valueOf(4.0)) * (1.0 + (countyLeaseTaxRate / 100));
            contr.Monthly_Payment_Year_6__c = c.First_Month_Payment_Pre_Tax__c * Math.pow((Double)(1 + leaseEscalator), Double.valueOf(5.0)) * (1.0 + (countyLeaseTaxRate / 100));
            contr.Monthly_Payment_Year_7__c = c.First_Month_Payment_Pre_Tax__c * Math.pow((Double)(1 + leaseEscalator), Double.valueOf(6.0)) * (1.0 + (countyLeaseTaxRate / 100));
            contr.Monthly_Payment_Year_8__c = c.First_Month_Payment_Pre_Tax__c * Math.pow((Double)(1 + leaseEscalator), Double.valueOf(7.0)) * (1.0 + (countyLeaseTaxRate / 100));
            contr.Monthly_Payment_Year_9__c = c.First_Month_Payment_Pre_Tax__c * Math.pow((Double)(1 + leaseEscalator), Double.valueOf(8.0)) * (1.0 + (countyLeaseTaxRate / 100));
            contr.Monthly_Payment_Year_10__c = c.First_Month_Payment_Pre_Tax__c * Math.pow((Double)(1 + leaseEscalator), Double.valueOf(9.0)) * (1.0 + (countyLeaseTaxRate / 100));
            contr.Monthly_Payment_Year_11__c = c.First_Month_Payment_Pre_Tax__c * Math.pow((Double)(1 + leaseEscalator), Double.valueOf(10.0)) * (1.0 + (countyLeaseTaxRate / 100));
            contr.Monthly_Payment_Year_12__c = c.First_Month_Payment_Pre_Tax__c * Math.pow((Double)(1 + leaseEscalator), Double.valueOf(11.0)) * (1.0 + (countyLeaseTaxRate / 100));
            contr.Monthly_Payment_Year_13__c = c.First_Month_Payment_Pre_Tax__c * Math.pow((Double)(1 + leaseEscalator), Double.valueOf(12.0)) * (1.0 + (countyLeaseTaxRate / 100));
            contr.Monthly_Payment_Year_14__c = c.First_Month_Payment_Pre_Tax__c * Math.pow((Double)(1 + leaseEscalator), Double.valueOf(13.0)) * (1.0 + (countyLeaseTaxRate / 100));
            contr.Monthly_Payment_Year_15__c = c.First_Month_Payment_Pre_Tax__c * Math.pow((Double)(1 + leaseEscalator), Double.valueOf(14.0)) * (1.0 + (countyLeaseTaxRate / 100));
            contr.Monthly_Payment_Year_16__c = c.First_Month_Payment_Pre_Tax__c * Math.pow((Double)(1 + leaseEscalator), Double.valueOf(15.0)) * (1.0 + (countyLeaseTaxRate / 100));
            contr.Monthly_Payment_Year_17__c = c.First_Month_Payment_Pre_Tax__c * Math.pow((Double)(1 + leaseEscalator), Double.valueOf(16.0)) * (1.0 + (countyLeaseTaxRate / 100));
            contr.Monthly_Payment_Year_18__c = c.First_Month_Payment_Pre_Tax__c * Math.pow((Double)(1 + leaseEscalator), Double.valueOf(17.0)) * (1.0 + (countyLeaseTaxRate / 100));
            contr.Monthly_Payment_Year_19__c = c.First_Month_Payment_Pre_Tax__c * Math.pow((Double)(1 + leaseEscalator), Double.valueOf(18.0)) * (1.0 + (countyLeaseTaxRate / 100));
            contr.Monthly_Payment_Year_20__c = c.First_Month_Payment_Pre_Tax__c * Math.pow((Double)(1 + leaseEscalator), Double.valueOf(19.0)) * (1.0 + (countyLeaseTaxRate / 100));

            Decimal termLoanTotalPayments = (12 * contr.Monthly_Payment_Year_1__c) + (12 * contr.Monthly_Payment_Year_2__c) + (12 * contr.Monthly_Payment_Year_3__c) + 
                                            (12 * contr.Monthly_Payment_Year_4__c) + (12 * contr.Monthly_Payment_Year_5__c) + (12 * contr.Monthly_Payment_Year_6__c) + 
                                            (12 * contr.Monthly_Payment_Year_7__c) + (12 * contr.Monthly_Payment_Year_8__c) + (12 * contr.Monthly_Payment_Year_9__c) + 
                                            (12 * contr.Monthly_Payment_Year_10__c) + (12 * contr.Monthly_Payment_Year_11__c) + (12 * contr.Monthly_Payment_Year_12__c) + 
                                            (12 * contr.Monthly_Payment_Year_13__c) + (12 * contr.Monthly_Payment_Year_14__c) + (12 * contr.Monthly_Payment_Year_15__c) + 
                                            (12 * contr.Monthly_Payment_Year_16__c) + (12 * contr.Monthly_Payment_Year_17__c) + (12 * contr.Monthly_Payment_Year_18__c) + 
                                            (12 * contr.Monthly_Payment_Year_19__c) + (12 * contr.Monthly_Payment_Year_20__c);

            Decimal preTaxTotal = 0;
            //Total of Monthly Payment Pre Tax = Sum(1-Y) (First Month Payment Pre Tax * ((1+AC.Lease_Escalator)^Y-1))
            for (Integer year = 1; year <= 20; year++){
                preTaxTotal += c.First_Month_Payment_Pre_Tax__c * Math.pow((Double)(1 + leaseEscalator), Double.valueOf(year - 1));
            }
            contr.Total_of_Monthly_Payments_Pre_Tax__c = preTaxTotal;

            contr.Total_of_Monthly_Payments_Post_Tax__c = termLoanTotalPayments;    //(Decimal)sdq.get('Scenario_' + scenario + '_Total_Monthly_Payments__c');
            Decimal downPayment = contr.Down_Payment__c != null ? contr.Down_Payment__c : 0;
            contr.Total_of_All_Payments__c = downPayment + termLoanTotalPayments;
            contr.Total_Tax_Paid__c = contr.Total_of_Monthly_Payments_Post_Tax__c - contr.Total_of_Monthly_Payments_Pre_Tax__c;

            contr.Term_Loan_Total_Payments__c = termLoanTotalPayments;
            Decimal termLoanFinancedAmount = contr.Term_Loan_Financed_Amount__c != null ? contr.Term_Loan_Financed_Amount__c : 0;
            contr.Term_Loan_Finance_Charge__c = contr.Term_Loan_Total_Payments__c - termLoanFinancedAmount;
            contr.Term_Loan_Monthly_Payment__c =  contr.First_Month_Payment_Post_Tax__c;

            contractsToUpdate.add(contr);
        }
        update contractsToUpdate;
    }

    public void setupAppliedJunctions(Astrum_Contract__c[] insertedContracts){
        Astrum_Contract__c[] contractsToUpdate = new Astrum_Contract__c[]{};
        Applied_Price_Adjustment__c[] appliedPriceAdjInsertions = new Applied_Price_Adjustment__c[]{};
        Applied_Incentive_Offer__c[] appliedIncOfferInsertions = new Applied_Incentive_Offer__c[]{};
        Applied_SREC_Contract_Offer__c[] appliedSrecOfferInsertions = new Applied_SREC_Contract_Offer__c[]{};
        for (Astrum_Contract__c c : insertedContracts){
            System_Design_Quote__c sdq = sdqMap.get(c.System_Design_Quote_Name__c);

            for (Price_Adjustment__c pa : sdq.Price_Adjustments__r){
                if (pa.Applicable_Scenario__c == c.Scenario__c){
                    Applied_Price_Adjustment__c appliedPriceAdj = new Applied_Price_Adjustment__c();
                    appliedPriceAdj.Astrum_Contract__c = c.ID;
                    appliedPriceAdj.Amount__c = pa.Amount__c;
                    appliedPriceAdj.Amount_per_Watt__c = pa.Amount_per_Watt__c;
                    appliedPriceAdj.Apply_as_Net_Adjustment__c = pa.Apply_as_Net_Adjustment__c;
                    appliedPriceAdj.Channel_Partner_Adjustment__c = pa.Channel_Partner_Adjustment__c;
                    appliedPriceAdj.Name = pa.Name;
                    appliedPriceAdj.Effective_Dollar_Amount__c = pa.Effective_Dollar_Amount__c;
                    appliedPriceAdj.Entitlement_Offer__c = pa.Entitlement_Offer__c;
                    appliedPriceAdj.Guaranteed_Rate__c = pa.Guaranteed_Rate__c;
                    appliedPriceAdj.Percent__c = pa.Percent__c;
                    appliedPriceAdj.Production_Guarantee__c = pa.Production_Guarantee__c;
                    appliedPriceAdj.Promotion__c = pa.Promotion__c;
                    appliedPriceAdj.Type__c = pa.Type__c;
                    try {
                        appliedPriceAdj.RecordTypeID = Schema.SObjectType.Applied_Price_Adjustment__c.getRecordTypeInfosByName().get(pa.RecordType.Name).getRecordTypeId();
                    } catch (Exception e){ System.debug('Failed to assign record type: ' + e.getStackTraceString()); }
                    appliedPriceAdjInsertions.add(appliedPriceAdj);
                }
            }

            for (Available_Incentive_Offer__c aio : sdq.Available_Incentive_Offers__r){
                if (aio.Applicable_Scenario__c == c.Scenario__c){
                    Applied_Incentive_Offer__c appliedIncOffer = new Applied_Incentive_Offer__c();
                    appliedIncOffer.Astrum_Contract__c = c.ID;
                    appliedIncOffer.Name = aio.Name;
                    appliedIncOffer.Effective_Dollar_Amount__c = aio.Effective_Dollar_Amount__c;
                    appliedIncOffer.Eligible_Sector__c = aio.Eligible_Sector__c;
                    appliedIncOffer.Estimated_Date_of_First_Payment__c = aio.Estimated_Date_of_First_Payment__c;
                    appliedIncOffer.Estimated_Days_to_Payment__c = aio.Estimated_Days_to_Payment__c;
                    appliedIncOffer.Estimated_Payment_Month__c = aio.Estimated_Payment_Month__c;
                    appliedIncOffer.Estimated_Payment_Year_Offset__c = aio.Estimated_Payment_Year_Offset__c;
                    appliedIncOffer.Feed_In_Tariff_Earnings_After_Tax__c = aio.Feed_In_Tariff_Annual_Earnings_After_Tax__c;
                    appliedIncOffer.Flat_Rebate_Amount__c = aio.Flat_Rebate_Amount__c;
                    appliedIncOffer.Implementing_Sector__c = aio.Implementing_Sector__c;
                    appliedIncOffer.Incentive_Automatically_Applied__c = aio.Incentive_Applied__c;
                    appliedIncOffer.Incentive_Offer__c = aio.Incentive_Offer__c;
                    appliedIncOffer.Incentive_Recipient__c = aio.Incentive_Recipient__c;
                    appliedIncOffer.PBI_Amount__c = aio.PBI_Amount__c;
                    appliedIncOffer.SAC_Eligible__c = aio.SAC_Eligible__c;
                    appliedIncOffer.Tax_Credit_Rate__c = aio.Tax_Credit_Rate__c;
                    appliedIncOffer.Term_Months__c = aio.Term_Months__c;
                    appliedIncOffer.Tier_1_Incentive_Rate__c = aio.Tier_1_Incentive_Rate_W__c;
                    appliedIncOffer.Tier_1_Maximum_System_Size_kW__c = aio.Tier_1_Maximum_System_Size_kW__c;
                    appliedIncOffer.Tier_2_Incentive_Rate__c = aio.Tier_2_Incentive_Rate_W__c;
                    appliedIncOffer.Tier_2_Maximum_System_Size_kW__c = aio.Tier_2_Maximum_System_Size_kW__c;
                    appliedIncOffer.Tier_Pricing_Type__c = aio.Tier_Pricing_Type__c;
                    appliedIncOffer.TSRF_Adjustment_Type__c = aio.TSRF_Adjustment_Type__c;
                    appliedIncOffer.Utility_Company_Matching_Required__c = aio.Utility_Company_Matching_Required__c;
                    try {
                        appliedIncOffer.RecordTypeID = Schema.SObjectType.Applied_Incentive_Offer__c.getRecordTypeInfosByName().get(aio.RecordType.Name).getRecordTypeId();
                    } catch (Exception e){ System.debug('Failed to assign record type: ' + e.getStackTraceString()); }
                    appliedIncOfferInsertions.add(appliedIncOffer);
                }
            }

            for (Available_SREC_Contract_Offer__c asco : sdq.Available_SREC_Contract_Offers__r){
                if (asco.Applicable_Scenario__c == c.Scenario__c){
                    Applied_SREC_Contract_Offer__c appliedSrecOffer = new Applied_SREC_Contract_Offer__c();
                    appliedSrecOffer.Astrum_Contract__c = c.ID;
                    appliedSrecOffer.Name = asco.Name;
                    appliedSrecOffer.Contract_Length_Months__c = asco.Contract_Length_Months__c;
                    appliedSrecOffer.Default_Offer__c = asco.Default_Offer__c;
                    appliedSrecOffer.SREC_Contract_Offer__c = asco.SREC_Contract_Offer__c;
                    appliedSrecOffer.Upfront_Amount__c = asco.Upfront_Amount__c;
                    appliedSrecOffer.Upfront_Effective_Dollar_Amount__c = asco.Upfront_Effective_Dollar_Amount__c;
                    appliedSrecOffer.Yearly_Amount_SREC__c = asco.Yearly_Amount_SREC__c;
                    appliedSrecOffer.Yearly_Amount_of_ACP__c = asco.Yearly_Amount_of_ACP__c;
                    try {
                        appliedSrecOffer.RecordTypeID = Schema.SObjectType.Applied_SREC_Contract_Offer__c.getRecordTypeInfosByName().get(asco.RecordType.Name).getRecordTypeId();
                    } catch (Exception e){ System.debug('Failed to assign record type: ' + e.getStackTraceString()); }
                    appliedSrecOfferInsertions.add(appliedSrecOffer);
                }
            }
        }
        insert appliedPriceAdjInsertions;
        insert appliedIncOfferInsertions;
        insert appliedSrecOfferInsertions;
    }
}