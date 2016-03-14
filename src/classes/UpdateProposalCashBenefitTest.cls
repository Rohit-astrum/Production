//Test the batch class for CPQ-747
@isTest
public class UpdateProposalCashBenefitTest {
    
    static testMethod void updateProposals(){
        testData.setupCustomSettingsPricing();
        testData.setupCustomConfigObjectsPricing();
        Lease_Fund__c[] funds = testData.createLeaseFunds();
        System_Design_Quote__c sdq = TestData.setupSystemDesignQuotePricing('Residential', funds, false, 12000);

        sdq.Scenario_1_Included_in_Proposal__c = true;
        sdq.Total_System_Size_kW__c = sdq.System_Size_kW__c != null ? sdq.System_Size_kW__c : 7.5;
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = true;
        update sdq;
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = false;
        
        ProposalProcessor pp = new ProposalProcessor();
        ID propID = pp.createProposal(sdq, false, true, false, false, false, null);
        
        Test.startTest();
        UpdateProposalCashBenefit updateProps = new UpdateProposalCashBenefit(propID);
        ID batchID = Database.executeBatch(updateProps);
        Test.stopTest();
        
    }
}