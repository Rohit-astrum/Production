/*  FILE: AstrumContractCalculationsTest
    AUTHOR: Dan Kelner
    DATE: 04/13/15
    PURPOSE: Test class for AstrumContractCalculations
    MODIFICATION HISTORY
*/
@isTest
public class AstrumContractCalculationsTest {

    @isTest(seeAllData = false) static void contractCreationTest(){
        testData.setupCustomSettingsPricing();
        testData.setupCustomConfigObjectsPricing();
        Lease_Fund__c[] funds = testData.createLeaseFunds();    //Fund[0] - SAC Loan, Fund[1] - Term Loan, Fund[2] - Lease, Fund[3] - Term & SAC 

        //Create our test data
        //ID sdID = testData.setupSystemDesign('Residential', 'Purchase', null, false, 12000);
        //System_Design__c sysDesign = new System_Design__c(ID = sdID);
        //update sysDesign;

        //System_Design_Quote__c sdq = SalesWorkflowValidationUtility.systemDesignQuoteWorkflowOnCreate(sysDesign);
        System_Design_Quote__c sdq = TestData.setupSystemDesignQuotePricing('Residential', funds, false, 12000);

        sdq.Scenario_1_Included_in_Proposal__c = true;
        sdq.Total_System_Size_kW__c = sdq.System_Size_kW__c != null ? sdq.System_Size_kW__c : 7.5;
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = true;
        update sdq;
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = false;
        
        Test.startTest();
        ProposalProcessor pp = new ProposalProcessor();
        ID propID = pp.createProposal(sdq, true, true, false, false, false, null);
        
        Astrum_Contract__c contr = AstrumContractCalculations.initilizeContract(propID, 1);
        contr.PPA_System_Buyout_Basis_EPC__c = 4.32;    //Set this manually because the financing type isn't PPA
        insert contr;

        contr = Database.query('SELECT ' + AstrumContractCalculations.allContractFields + ' FROM Astrum_Contract__c WHERE ID = \'' + contr.ID + '\'');
        AstrumContractCalculations.getOneRoofBuyoutCostsPPA(contr, 0.5);    //CPQ-749
        Test.stopTest();        
    }
}