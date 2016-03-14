/*  FILE: CloseContractCtrl.cls
    AUTHOR: Dan Kelner
    DATE: 03/23/15
    PURPOSE: Controller for CloseContract
    MODIFICATION HISTORY
        04/17/2015  SZ  Set the Astrum Contract Open Quote and Contract Execution Date on close.
        09/09/2015  DK  Change how Opportunity.Amount is calculated, based off CPQ-122 specs.
        01/29/2016  DK  Set new Opportunity fields for CPQ-795.
*/
public class CloseContractCtrl {

    private String contractFields = 'Name, Closed__c, Locked__c, State_Grant_Amount__c, Proposal__r.System_Design_Quote__r.System_Design__r.Property__r.Name, SAC_Loan__c, SREC_Cash_Back__c, ' + 
                                    'Proposal__r.System_Design_Quote__r.System_Design__r.Survey__c, Contract_Execution_Date__c, Scenario__c, Term_Loan__c, SREC_Contract_Discount__c, ' + 
                                    'Proposal__r.System_Design_Quote__r.Calculated_System_Price__c, ' + 
                                    'Proposal__r.System_Design_Quote__r.Total_Closed_Scenario_Adjustments__c, Proposal__r.System_Design_Quote__r.Scenario_1_Financing_Option__c, ' + 
                                    'Proposal__r.System_Design_Quote__r.Scenario_2_Financing_Option__c, Proposal__r.System_Design_Quote__r.Scenario_3_Financing_Option__c, ' + 
                                    'Proposal__r.System_Design_Quote__r.Scenario_4_Financing_Option__c, Proposal__r.System_Design_Quote__r.Scenario_1_Lease_Fund__c, ' + 
                                    'Proposal__r.System_Design_Quote__r.Scenario_2_Lease_Fund__c, Proposal__r.System_Design_Quote__r.Scenario_3_Lease_Fund__c, ' + 
                                    'Proposal__r.System_Design_Quote__r.Scenario_4_Lease_Fund__c, Financing_Type__c, Lease_Option__c, ' + 
                                    'Proposal__r.System_Design_Quote__r.Scenario_1_Financing_Rate_Year_1_kWh__c, Proposal__r.System_Design_Quote__r.Scenario_2_Financing_Rate_Year_1_kWh__c, ' + 
                                    'Proposal__r.System_Design_Quote__r.Scenario_3_Financing_Rate_Year_1_kWh__c, Proposal__r.System_Design_Quote__r.Scenario_4_Financing_Rate_Year_1_kWh__c, ' + 
                                    'Proposal__r.System_Design_Quote__r.Scenario_1_Lease_Escalator__c, Proposal__r.System_Design_Quote__r.Scenario_2_Lease_Escalator__c, ' + 
                                    'Proposal__r.System_Design_Quote__r.Scenario_3_Lease_Escalator__c, Proposal__r.System_Design_Quote__r.Scenario_4_Lease_Escalator__c, ' + 
                                    'Proposal__r.System_Design_Quote__r.Scenario_1_Available_SREC_Contract_Offer__r.RecordTypeDeveloperName__c, ' + 
                                    'Proposal__r.System_Design_Quote__r.Scenario_2_Available_SREC_Contract_Offer__r.RecordTypeDeveloperName__c, ' + 
                                    'Proposal__r.System_Design_Quote__r.Scenario_3_Available_SREC_Contract_Offer__r.RecordTypeDeveloperName__c, ' + 
                                    'Proposal__r.System_Design_Quote__r.Scenario_4_Available_SREC_Contract_Offer__r.RecordTypeDeveloperName__c, ' + 
                                    'Proposal__r.System_Design_Quote__r.Scenario_1_Available_SREC_Contract_Offer__r.Applicable_Scenario__c, ' + 
                                    'Proposal__r.System_Design_Quote__r.Scenario_2_Available_SREC_Contract_Offer__r.Applicable_Scenario__c, ' + 
                                    'Proposal__r.System_Design_Quote__r.Scenario_3_Available_SREC_Contract_Offer__r.Applicable_Scenario__c, ' + 
                                    'Proposal__r.System_Design_Quote__r.Scenario_4_Available_SREC_Contract_Offer__r.Applicable_Scenario__c, ' + 
                                    'Proposal__r.System_Design_Quote__r.Scenario_1_Available_SREC_Contract_Offer__r.Contract_Offer_Applied__c, ' + 
                                    'Proposal__r.System_Design_Quote__r.Scenario_2_Available_SREC_Contract_Offer__r.Contract_Offer_Applied__c, ' + 
                                    'Proposal__r.System_Design_Quote__r.Scenario_3_Available_SREC_Contract_Offer__r.Contract_Offer_Applied__c, ' + 
                                    'Proposal__r.System_Design_Quote__r.Scenario_4_Available_SREC_Contract_Offer__r.Contract_Offer_Applied__c, ' +
                                    'Proposal__r.System_Design_Quote__r.Scenario_1_Financing_Type__c, Proposal__r.System_Design_Quote__r.Scenario_2_Financing_Type__c, ' +
                                    'Proposal__r.System_Design_Quote__r.Scenario_3_Financing_Type__c, Proposal__r.System_Design_Quote__r.Scenario_4_Financing_Type__c, ' + 
                                    'Proposal__r.System_Design_Quote__r.Scenario_1_Adjusted_Price_NUM__c, Proposal__r.System_Design_Quote__r.Scenario_2_Adjusted_Price_NUM__c, ' + 
                                    'Proposal__r.System_Design_Quote__r.Scenario_3_Adjusted_Price_NUM__c, Proposal__r.System_Design_Quote__r.Scenario_4_Adjusted_Price_NUM__c';

    public Astrum_Contract__c contr {get; set;}
    public transient String pdfURL {get; set;}
    public Opportunity[] relatedOpps {get; set;}
    public Opportunity selectedOpp {get; set;}
    public Boolean hideAll {get; set;}
    public Boolean showUpdateExistingOppBtn {get; set;}

    public CloseContractCtrl(){
        try {
            hideAll = false;
            showUpdateExistingOppBtn = false;
            String contractID = ApexPages.currentPage().getParameters().get('id');
            if (String.isBlank(contractID)){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Contract ID is required in the URL\'s "id" parameter.'));
                return;
            }
            Astrum_Contract__c[] contractQuery = Database.query('SELECT ' + contractFields + ' FROM Astrum_Contract__c WHERE ID = \'' + String.escapeSingleQuotes(contractID) + '\' LIMIT 1');
            if (contractQuery.isEmpty()){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'No Contracts could be matched to the ID ' + contractID));
                return;
            }
            contr = contractQuery[0];
            if (!contr.Closed__c){
                hideAll = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Contract "' + contr.Name+ '" must be "sold" in the PreviewContract page before it can be closed.'));
                return;
            }
            if (contr.Locked__c){
                hideAll = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Contract "' + contr.Name+ '" has already been closed, and is locked from further action.'));
                return;
            }
            pdfURL = '';
            selectedOpp = new Opportunity();
            relatedOpps = [SELECT Name, CloseDate, StageName, AccountID, Account.Name, Amount, Financing_Type__c, Number_of_Sales_Orders__c 
                           FROM Opportunity WHERE Property__c = :contr.Proposal__r.System_Design_Quote__r.System_Design__r.Property__c LIMIT 10000];
            if (relatedOpps.size() == 1){
                selectedOpp = relatedOpps[0];
                if (selectedOpp.Number_of_Sales_Orders__c != null && selectedOpp.Number_of_Sales_Orders__c > 0)
                    showUpdateExistingOppBtn = true;
            }
        } catch (Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error: ' + e.getStackTraceString()));
        }
    }

    public void selectOpportunity(){
        String oppID = ApexPages.currentPage().getParameters().get('opportunityID');
        if (String.isBlank(oppID) || selectedOpp.ID == oppID)
            return;

        for (Opportunity o : relatedOpps){
            if (oppID == o.ID){
                selectedOpp = o;
                break;
            }
        }
        if (selectedOpp.Number_of_Sales_Orders__c != null && selectedOpp.Number_of_Sales_Orders__c > 0){
            showUpdateExistingOppBtn = true;
        } else {
            showUpdateExistingOppBtn = false;
        }
    }

    public Integer getRelatedOppsSize(){
        return relatedOpps.size();
    }

    public PageReference reset(){
        PageReference pg = new PageReference('/apex/CloseContract?id=' + contr.ID);
        pg.setRedirect(true);
        return pg;
    }

    public PageReference backToContractPreview(){
        PageReference pg = new PageReference('/apex/PreviewContract?id=' + contr.ID);
        pg.setRedirect(true);
        return pg;
    }

    public PageReference updateExistingOpportunity(){
        return closeOrUpdateOpportunity(true);
    }

    public PageReference closeOpportunity(){
        return closeOrUpdateOpportunity(false);
    }

    public PageReference closeOrUpdateOpportunity(Boolean updateExisting){
        PageReference pg;
        Attachment pdf;
        if (!Test.isRunningTest()){
            if (pdfURL.length() <= 0){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please upload the signed Contract PDF before continuing.'));
                return pg;
            }
            pdf = new Attachment(Name = contr.Name + ' Signed.pdf', ParentID = contr.ID);

            //Break string apart into parts
            Integer pos1 = pdfURL.indexOf(':');
            Integer pos2 = pdfURL.indexOf(';', pos1);
            Integer pos3 = pdfURL.indexOf(',', pos2);

            pdf.ContentType = pdfURL.substring((pos1+1), pos2);

            //Decode the base64 encoded file
            pdf.Body = EncodingUtil.base64Decode(pdfURL.substring(pos3 + 1));
            pdfURL = null;  //This is done to diminish the view state
            
            if (pdf.ContentType != 'application/pdf'){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Signed Contract must be a PDF document. Detected ContentType is ' + pdf.ContentType));
                return pg;
            }
        }

        if (selectedOpp.ID == null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select an Opportunity to close.'));
            return pg;
        }

        selectedOpp.Survey__c = contr.Proposal__r.System_Design_Quote__r.System_Design__r.Survey__c;
        selectedOpp.System_Design__c = contr.Proposal__r.System_Design_Quote__r.System_Design__c;
        selectedOpp.System_Design_Quote__c = contr.Proposal__r.System_Design_Quote__c;
        selectedOpp.Proposal__c = contr.Proposal__c;
        selectedOpp.Astrum_Contract__c = contr.ID;
        selectedOpp.CloseDate = contr.Contract_Execution_Date__c != null ? contr.Contract_Execution_Date__c : Date.today();
        Integer n = Integer.valueOf(contr.Scenario__c);
        //selectedOpp.Amount = getOppAmount(contr, n);
        selectedOpp.Financing_Type__c = contr.Financing_Type__c;
        if (contr.Financing_Type__c == 'PPA')
            selectedOpp.Financing_Type__c = 'Lease';    //CPQ-684
        if (selectedOpp.Financing_Type__c == 'Purchase' && (String.isNotBlank(contr.Term_Loan__c) || String.isNotBlank(contr.SAC_Loan__c))){
            selectedOpp.Financing_Option__c = contr.Term_Loan__c + '; ' + contr.SAC_Loan__c;
        } else if (selectedOpp.Financing_Type__c == 'Purchase' && String.isBlank(contr.Term_Loan__c) && String.isBlank(contr.SAC_Loan__c)){
            selectedOpp.Financing_Option__c = 'No Financing';
        }
        selectedOpp.Lease_PPA_Fund__c = (String)contr.Proposal__r.System_Design_Quote__r.get('Scenario_' + n + '_Lease_Fund__c');
        selectedOpp.Leasing_Option__c = contr.Lease_Option__c;
        selectedOpp.SREC__c = getSRECContract(contr, n);
        selectedOpp.State_Grant_Amount__c = contr.State_Grant_Amount__c;
        selectedOpp.SREC_Contract_Discount__c = contr.SREC_Contract_Discount__c;
        selectedOpp.SREC_Cash_Back__c = contr.SREC_Cash_Back__c;
        selectedOpp.Closed_Scenario__c = contr.Scenario__c;
        selectedOpp.Sold_Financing_Rate_Year_1_kWh__c = (Decimal)contr.Proposal__r.System_Design_Quote__r.get('Scenario_' + n + '_Financing_Rate_Year_1_kWh__c');
        String leaseEscStr = contr.Proposal__r.System_Design_Quote__r.get('Scenario_' + n + '_Lease_Escalator__c') != null ? (String)contr.Proposal__r.System_Design_Quote__r.get('Scenario_' + n + '_Lease_Escalator__c') : '0';
        if (String.isBlank(leaseEscStr) || leaseEscStr == 'null')
            leaseEscStr = '0';
        selectedOpp.Sold_Lease_Escalator__c = Decimal.valueOf(leaseEscStr);
        if (!updateExisting)
            selectedOpp.StageName = 'Closed - Won';

        //Update a System Design field
        //System_Design__c sysDesign = new System_Design__c(ID = contr.Proposal__r.System_Design_Quote__r.System_Design__c);
        //sysDesign.Calculated_System_Price__c = contr.Proposal__r.System_Design_Quote__r.Commission_Design_Price__c;

        //Update an SDQ field (Total_Closed_Scenario_Adjustments__c controls Opportunity.Amount)
        System_Design_Quote__c sdq = new System_Design_Quote__c(ID = contr.Proposal__r.System_Design_Quote__c);
        String financingType = (String)contr.getSObject('Proposal__r').getSObject('System_Design_Quote__r').get('Scenario_' + n + '_Financing_Type__c');
        Decimal adjustedPrice = (Decimal)contr.getSObject('Proposal__r').getSObject('System_Design_Quote__r').get('Scenario_' + n + '_Adjusted_Price_NUM__c');
        //Updated formula for CPQ-122
        if (financingType == 'Purchase'){
            sdq.Total_Closed_Scenario_Adjustments__c = adjustedPrice;
        } else if (financingType == 'Lease' || financingType == 'PPA'){
            sdq.Total_Closed_Scenario_Adjustments__c = 0;
        }
        
        try {
            //update sysDesign;
            update sdq;
            update selectedOpp;
            if (!Test.isRunningTest()){
                insert pdf;     //Temporarily insert the Attachment before we re-parent it to the new Sales Order
                if (!updateExisting)
                    pg = new PageReference('/apex/CreateSalesOrder?oId=' + selectedOpp.ID + '&attchID=' + pdf.ID);
                else
                    pg = new PageReference('/' + selectedOpp.ID);
                pg.setRedirect(true);
            }
            CloseContractCtrl.lockAllRelatedRecords(contr.Proposal__r.System_Design_Quote__r.System_Design__r.Property__c, contr.ID);
        } catch (Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error: ' + e.getStackTraceString()));
        }
        return pg;
    }

    public String getSRECContract(Astrum_Contract__c c, Integer scenario){
        String returnStr = 'N/A - NO SRECs';
        try {
            sObject availableSREC = c.Proposal__r.System_Design_Quote__r.getSObject('Scenario_' + scenario + '_Available_SREC_Contract_Offer__r');
            String applicableScenario = (String)availableSREC.get('Applicable_Scenario__c');
            Boolean offerApplied = (Boolean)availableSREC.get('Contract_Offer_Applied__c');
            String recType = (String)availableSREC.get('RecordTypeDeveloperName__c');
            if (applicableScenario == String.valueOf(scenario) && offerApplied && String.isNotBlank(recType))
                returnStr = recType;
        } catch (Exception e){
            System.debug(e.getStackTraceString());
        }
        return returnStr;
    }

    @future
    public static void lockAllRelatedRecords(ID propertyID, ID contractID){
    //Records to lock: System Design, System Design Quote, System Design Array, System Design Item, Price Adjustment, Available Incentive Offer,
    //                 Available SREC Contract Offer, Proposal, Contract

        Map<ID, System_Design__c> sysDesigns = new Map<ID, System_Design__c>([SELECT Locked__c, Closed__c FROM System_Design__c WHERE Property__c = :propertyID]);
        for (System_Design__c sd : sysDesigns.values()){
            sd.Locked__c = true;
            sd.Closed__c = true;
        }

        System_Design_Array__c[] sdas = [SELECT Locked__c FROM System_Design_Array__c WHERE System_Design__c IN :sysDesigns.keySet()];
        for (System_Design_Array__c sda : sdas)
            sda.Locked__c = true;

        System_Design_Item__c[] sdis = [SELECT Locked__c FROM System_Design_Item__c WHERE System_Design_Array__r.System_Design__c IN :sysDesigns.keySet()];
        for (System_Design_Item__c sdi : sdis)
            sdi.Locked__c = true;

        Astrum_Contract__c closedContract;
        Astrum_Contract__c[] contracts = [SELECT Locked__c, Closed__c, Proposal__r.System_Design_Quote__r.System_Design__c, Open_Quote__c, Contract_Execution_Date__c FROM Astrum_Contract__c 
                                          WHERE Proposal__r.System_Design_Quote__r.System_Design__c IN :sysDesigns.keySet()];
        for (Astrum_Contract__c c : contracts){
            c.Locked__c = true;
            if (c.ID == contractID){
                closedContract = c;
                c.Closed__c = true;
                c.Open_Quote__c = false;
                c.Contract_Execution_Date__c = System.today();
            }
        }

        Map<ID, System_Design_Quote__c> sdqs = new Map<ID, System_Design_Quote__c>([SELECT Locked__c, Closed__c FROM System_Design_Quote__c WHERE System_Design__c IN :sysDesigns.keySet()]);
        for (System_Design_Quote__c sdq : sdqs.values()){
            sdq.Locked__c = true;
            if (sdq.ID == closedContract.Proposal__r.System_Design_Quote__c)
                sdq.Closed__c = true;
        }

        Price_Adjustment__c[] priceAdjusts = [SELECT Locked__c FROM Price_Adjustment__c WHERE System_Design_Quote__c IN :sdqs.keySet()];
        for (Price_Adjustment__c pa : priceAdjusts)
            pa.Locked__c = true;

        Available_Incentive_Offer__c[] availIncOffers = [SELECT Locked__c FROM Available_Incentive_Offer__c WHERE System_Design_Quote__c IN :sdqs.keySet()];
        for (Available_Incentive_Offer__c aio : availIncOffers)
            aio.Locked__c = true;

        Available_SREC_Contract_Offer__c[] availSrecOffers = [SELECT Locked__c FROM Available_SREC_Contract_Offer__c WHERE System_Design_Quote__c IN :sdqs.keySet()];
        for (Available_SREC_Contract_Offer__c aso : availSrecOffers)
            aso.Locked__c = true;

        Proposal__c[] props = [SELECT Locked__c, Closed__c FROM Proposal__c WHERE System_Design_Quote__c IN :sdqs.keySet()];
        for (Proposal__c pr : props){
            pr.Locked__c = true;
            if (pr.ID == closedContract.Proposal__c)
                pr.Closed__c = true;
        }
        
        update sdis;
        update sdas;
        update sysDesigns.values();
        update priceAdjusts;
        update availIncOffers;
        update availSrecOffers;
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = true;    //Otherwise, would fail in SystemDesignQuoteTriggerHandler.getPromotionsAndEntitlementOffers()
        update sdqs.values();
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = false;
        update props;
        update contracts;
    }
}