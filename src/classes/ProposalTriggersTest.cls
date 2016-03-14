/* FILE: ProposalTriggersTest.cls
 * AUTHOR: Dan Kelner
 * DATE: 12/11/14
 * PURPOSE: Common trigger test class for Proposal.
 * MODIFICATION HISTORY: 
 *    
 */
@isTest
public class ProposalTriggersTest {
    
    //@isTest(SeeAllData=true)
    //static void testWithAllDataAccess() {
        // Can query all data in the organization.      
    //}
    
    @isTest static void salesWorkflowRulesTest() {
        insert new System_Design_Quote_Settings__c(Days_Proposal_Valid__c = 14);
        
        Account acct = new Account(Name='TestAcct');      
        insert acct;
        
        Property__c prop = new Property__c();
        prop.Name = '123 Main St';
        prop.Property_Owner__c = acct.Id;       
        prop.Optimal_Site_Quality_kWh_y_kW__c = double.valueOf('1250');
        prop.Property_State__c = 'MD';
        prop.Property_City__c = 'Annapolis Junction';        
        prop.Property_ZIP__c = '20701';
        prop.Property_County__c = 'Howard';    
        insert prop;
        
        System_Design__c sd = new System_Design__c(Property__c = prop.Id, Calculated_System_Price__c = decimal.valueOf('100000.25'));
        insert sd;
        
        System_Design_Quote__c sdq = new System_Design_Quote__c(System_Design__c = sd.ID);
        insert sdq;
        
        Proposal__c proposal = new Proposal__c(Closed__c = false, System_Design_Quote__c = sdq.ID);
        Test.startTest();
        insert proposal;
        
        proposal = [SELECT Days_Proposal_Valid__c, Proposal_Expiration_Date__c, Open_Quote__c FROM Proposal__c WHERE ID = :proposal.ID];
        System.assertEquals(true, proposal.Open_Quote__c);
        //System.assertEquals(14, proposal.Days_Proposal_Valid__c);
        //System.assertEquals(Date.today().addDays(14), proposal.Proposal_Expiration_Date__c);
        
        Astrum_Contract__c contr1 = new Astrum_Contract__c(Proposal__c = proposal.ID, Scenario__c = 'Test 1', Closed__c = true);
        Astrum_Contract__c contr2 = new Astrum_Contract__c(Proposal__c = proposal.ID, Scenario__c = 'Test 2', Closed__c = true);
        insert new Astrum_Contract__c[]{contr1, contr2};
        update proposal;
        
        //If two contracts are Closed = true, then the Proposal will remain Closed = false. See closedProposalRules().
        proposal = [SELECT Closed__c, Current__c FROM Proposal__c WHERE ID = :proposal.ID];
        System.assertEquals(false, proposal.Closed__c);
        
        contr2.Closed__c = false;
        update contr2;
        
        update proposal;
        //If only one contract is Closed = true, then the Proposal will be set to Closed = true
        proposal = [SELECT Closed__c, Closed_Scenario__c FROM Proposal__c WHERE ID = :proposal.ID];
        System.assertEquals(true, proposal.Closed__c);
        System.assertEquals('Test 1', proposal.Closed_Scenario__c);
        
        Test.stopTest();
    }
}