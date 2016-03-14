/*  FILE: CloseContractTest
    AUTHOR: Dan Kelner
    DATE: 04/14/15
    PURPOSE: Test class for CloseContractCtrl
    MODIFICATION HISTORY
*/
@isTest
public class CloseContractTest {
    
    @isTest(seeAllData = true) static void controllerTest1(){
        ID sdID = testData.setupSystemDesign('Residential', 'Purchase', null, false, 12000);
        System_Design__c sysDesign = new System_Design__c(ID = sdID);
        update sysDesign;

        Account acct = [SELECT ID FROM Account WHERE Name = 'TestAcct' ORDER BY CreatedDate DESC LIMIT 1];
        Property__c property = [SELECT ID FROM Property__c WHERE Name = '123 Main St' ORDER BY CreatedDate DESC LIMIT 1];

        Opportunity opp = new Opportunity(Name = 'Test Opp', AccountID = acct.ID, CloseDate = Date.today().addDays(30), StageName = 'Qualified', Property__c = property.ID);
        insert opp;

        System_Design_Quote__c sdq = new System_Design_Quote__c(System_Design__c = sysDesign.ID, Current__c = true);
        insert sdq;

        Proposal__c prop = new Proposal__c(System_Design_Quote__c = sdq.ID);
        insert prop;

        Astrum_Contract__c contr = new Astrum_Contract__c(Proposal__c = prop.ID, Scenario__c = '1', Closed__c = true, Property_State__c = 'CA');
        insert contr;

        Test.startTest();
        Test.setCurrentPage(Page.CloseContract);
        ApexPages.currentPage().getParameters().put('id', contr.ID);
        CloseContractCtrl ctrl = new CloseContractCtrl();
        ctrl.reset();
        System.assertEquals(1, ctrl.getRelatedOppsSize());
        ApexPages.currentPage().getParameters().put('opportunityID', opp.ID);
        ctrl.selectOpportunity();
        System.assertEquals(opp.ID, ctrl.selectedOpp.ID);
        ctrl.closeOpportunity();

        System.assertEquals('Closed - Won', ctrl.selectedOpp.StageName);
        System.assertEquals(sdq.ID, ctrl.selectedOpp.System_Design_Quote__c);
        System.assertEquals(prop.ID, ctrl.selectedOpp.Proposal__c);
        System.assertEquals(contr.ID, ctrl.selectedOpp.Astrum_Contract__c);

        CloseContractCtrl.lockAllRelatedRecords(property.ID, ctrl.contr.ID); //Should lock all records in the system design hierarchy
        Test.stopTest();	//Wait for async method to finish

        sdq = [SELECT Locked__c, Closed__c FROM System_Design_Quote__c WHERE ID = :sdq.ID LIMIT 1];
        System.assertEquals(true, sdq.Locked__c);
        System.assertEquals(true, sdq.Closed__c);

        prop = [SELECT Locked__c, Closed__c FROM Proposal__c WHERE ID = :prop.ID LIMIT 1];
        System.assertEquals(true, prop.Locked__c);
        System.assertEquals(true, prop.Closed__c);
    }

    @isTest(seeAllData = false) static void controllerTest2(){
        System_Design_Quote__c sdq = testData.setupSystemDesignQuoteForContract('Residential', 12000);

        Test.startTest();

        Proposal__c prop = new Proposal__c(System_Design_Quote__c = sdq.ID);
        insert prop;

        Astrum_Contract__c contr = new Astrum_Contract__c(Proposal__c = prop.ID, Scenario__c = '1', Closed__c = true, Property_State__c = 'CA');
        insert contr;

        Test.setCurrentPage(Page.CloseContract);
        ApexPages.currentPage().getParameters().put('id', contr.ID);
        CloseContractCtrl ctrl = new CloseContractCtrl();
        ctrl.backToContractPreview();
        ctrl.closeOpportunity();

        Test.stopTest();
    }
}