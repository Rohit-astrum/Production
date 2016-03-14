/*  
    AUTHOR: Dan Kelner
    DATE: 03/04/16
    PURPOSE: Batch class to update Proposals for CPQ-747
    MODIFICATION HISTORY
*/
global class UpdateProposalCashBenefit implements Database.Batchable<sObject>{
    global String[] specificIDs;
    global String query = 'SELECT System_Design_Quote__r.System_Design__c, Annual_Power_Price_Escalator__c, Scenario_1_Financing_Plan__c, Scenario_2_Financing_Plan__c, Scenario_3_Financing_Plan__c, Scenario_4_Financing_Plan__c, ' + 
                            'Scenario_1_Annual_Degradation_Factor__c, Scenario_2_Annual_Degradation_Factor__c, Scenario_3_Annual_Degradation_Factor__c, Scenario_4_Annual_Degradation_Factor__c, ' + 
                            'Scenario_1_FIT_Annual_Earnings_After_Tax__c, Scenario_2_FIT_Annual_Earnings_After_Tax__c, Scenario_3_FIT_Annual_Earnings_After_Tax__c, Scenario_4_FIT_Annual_Earnings_After_Tax__c, ' + 
                            'Scenario_1_FIT_Term_Length_Months__c, Scenario_2_FIT_Term_Length_Months__c, Scenario_3_FIT_Term_Length_Months__c, Scenario_4_FIT_Term_Length_Months__c, ' + 
                            'Scenario_1_Estimated_Operational_Start_D__c, Scenario_2_Estimated_Operational_Start_D__c, Scenario_3_Estimated_Operational_Start_D__c, Scenario_4_Estimated_Operational_Start_D__c, ' + 
                            'Scenario_1_Proposal_Term_months__c, Scenario_2_Proposal_Term_months__c, Scenario_3_Proposal_Term_months__c, Scenario_4_Proposal_Term_months__c ' + 
                            'FROM Proposal__c';

    global UpdateProposalCashBenefit(String commaSeparatedIDs){
        if (String.isNotBlank(commaSeparatedIDs)){
            specificIDs = commaSeparatedIDs.split(',');
            query += ' WHERE ID IN :specificIDs';
        }
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<sObject> scope){
        Proposal__c[] props = new Proposal__c[]{};
        Map<ID, ID> propsToQuotes = new Map<ID, ID>();
        Map<ID, ID> propsToSysDesigns = new Map<ID, ID>();
        for (sObject s : scope){
            Proposal__c prop = (Proposal__c)s;
            propsToQuotes.put(prop.ID, prop.System_Design_Quote__c);
            propsToSysDesigns.put(prop.ID, prop.System_Design_Quote__r.System_Design__c);
            props.add(prop);
        }
        
        Map<ID, System_Design_Quote__c> sdqs = new Map<ID, System_Design_Quote__c>(
                                        [SELECT Pricing_Date__c, System_Design__c, Scenario_1_SREC_Cash_Back__c, Scenario_2_SREC_Cash_Back__c, Scenario_3_SREC_Cash_Back__c, Scenario_4_SREC_Cash_Back__c, 
                                         Scenario_1_Total_Net_Adjustment__c, Scenario_2_Total_Net_Adjustment__c, Scenario_3_Total_Net_Adjustment__c, Scenario_4_Total_Net_Adjustment__c, 
                                         Scenario_1_Net_Initial_Outlay__c, Scenario_2_Net_Initial_Outlay__c, Scenario_3_Net_Initial_Outlay__c, Scenario_4_Net_Initial_Outlay__c, 
                                         Scenario_1_Term_Loan__r.Financing_Term_Months__c, Scenario_2_Term_Loan__r.Financing_Term_Months__c, Scenario_3_Term_Loan__r.Financing_Term_Months__c, Scenario_4_Term_Loan__r.Financing_Term_Months__c, 
                                         Scenario_1_First_Month_Payment__c, Scenario_2_First_Month_Payment__c, Scenario_3_First_Month_Payment__c, Scenario_4_First_Month_Payment__c, 
                                         Scenario_1_Lease_Escalator__c, Scenario_2_Lease_Escalator__c, Scenario_3_Lease_Escalator__c, Scenario_4_Lease_Escalator__c 
                                         FROM System_Design_Quote__c WHERE ID IN :propsToQuotes.values()]);
        Map<ID, System_Design__c> sds = new Map<ID, System_Design__c>(
                                        [SELECT Default_CB_Panel__r.Utility_Service__r.Method_1_Net_Savings__c FROM System_Design__c WHERE ID IN :propsToSysDesigns.values()]);
        
        ProposalProcessor pp = new ProposalProcessor();
        for (Proposal__c prop : props){
            for (Integer i = 1; i <= 4; i++){
                if (prop.get('Scenario_' + i + '_Proposal_Term_months__c') != null){
                    System_Design_Quote__c sdq = sdqs.get(propsToQuotes.get(prop.ID));
                    System_Design__c sd = sds.get(propsToSysDesigns.get(prop.ID));
                    prop.put('Scenario_' + i + '_Cumulative_Cash_Benefit__c', pp.calcCumulativeCashBenefit(prop, sdq, sd, i, Integer.valueOf(prop.get('Scenario_' + i + '_Proposal_Term_months__c')) ));
                }
            }
        }
        
        update props;
    }

    global void finish(Database.BatchableContext bc){}
}