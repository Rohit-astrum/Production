/* FILE: AstrumContractTriggersTest.cls
 * AUTHOR: Dan Kelner
 * DATE: 12/12/14
 * PURPOSE: Common trigger test class for AstrumContract.
 * MODIFICATION HISTORY: 
 *    05/05/15  DK  Added Conga Template insertion
 */
@isTest
public class AstrumContractTriggersTest {
    
    public testmethod static void salesWorkflowRulesTest() {        
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
        
        System_Design__c sd = new System_Design__c(Property__c = prop.Id, Calculated_System_Price__c = Decimal.valueOf('100000.25'));
        insert sd;
        
        System_Design_Quote__c sdq = new System_Design_Quote__c(System_Design__c = sd.ID, Scenario_1_Financing_Type__c = 'Purchase', Scenario_2_Financing_Type__c = 'Lease');
        insert sdq;
        
        Proposal__c proposal = new Proposal__c(System_Design_Quote__c = sdq.ID, Closed__c = true, Open_Quote__c = false);
        insert proposal;
        
        APXTConga4__Conga_Template__c template = new APXTConga4__Conga_Template__c(Eligible_States__c = 'PA', Financing_Type__c = 'Purchase');
        insert template;

        Astrum_Contract__c contr1 = new Astrum_Contract__c(Proposal__c = proposal.ID, Scenario__c = '1', Property_State__c = 'PA');
        Astrum_Contract__c contr2 = new Astrum_Contract__c(Proposal__c = proposal.ID, Scenario__c = '2', Property_State__c = 'NY');
        Test.startTest();
        insert new Astrum_Contract__c[]{contr1, contr2};
        
        Astrum_Contract__c[] contracts = [SELECT Open_Quote__c FROM Astrum_Contract__c WHERE ID = :contr1.ID OR ID = :contr2.ID];
        for (Astrum_Contract__c contr : contracts ){
            System.assertEquals(false, contr.Open_Quote__c);
        }
        
        proposal.Closed__c = false;
        proposal.Open_Quote__c = true;
        update proposal;
        update contracts;    //TO DO: Implement the Contract field update in the Proposal trigger to eliminate the need for this additional DML action
        
        contracts = [SELECT Open_Quote__c FROM Astrum_Contract__c WHERE ID = :contr1.ID OR ID = :contr2.ID];
        for (Astrum_Contract__c contr : contracts ){
            System.assertEquals(true, contr.Open_Quote__c);    //The value updated to that of the Proposal's
        }
        Test.stopTest();
    }

    public testmethod static void appliedJunctionsTest(){   //Added for CPQ-818
        testdata.setupCustomSettingsPricing();
        testdata.setupCustomConfigObjectsPricing();

        System_Design_Quote__c sdq = testdata.setupSystemDesignQuote('Residential', 'Purchase', null, true, 12000);

        Test.startTest();

        sdq = testdata.setupSDQPricingData(sdq);

        Proposal__c prop = new Proposal__c(System_Design_Quote__c = sdq.ID);
        insert prop;

        Astrum_Contract__c contr = new Astrum_Contract__c(Proposal__c = prop.ID, Scenario__c = '3', Closed__c = true, Property_State__c = 'MD');
        insert contr;

        AstrumContractTriggerHandler handler = new AstrumContractTriggerHandler(false);
        System.debug(handler.IsTriggerContext);

        Test.stopTest();
    }
}