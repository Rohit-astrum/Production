/* FILE: CreditReportLogTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: January 4, 2013
 * PURPOSE: Test for CreditReportLogEdit page and CreditReportLogExtension
 * MODIFICATION HISTORY:
 *
 */
 
 @isTest (SeeAllData = true)
 public class CreditReportLogTest {
 
     static testMethod void accountWithOpp_addCRL_opSelected() {
     
         Account customer = new Account(Name = 'Test Customer');
         insert customer;
         
         Opportunity opp = new Opportunity (
             AccountId = customer.Id,
             CloseDate = Date.today(),
             StageName = 'Qualified'
         );
         insert opp;
         
         Credit_Report_Log__c crl = new Credit_Report_Log__c (
             Account__c = customer.Id
         );
         
         Test.setCurrentPage(Page.CreditReportLogEdit);
         ApexPages.StandardController controller = new ApexPages.StandardController(crl);
         CreditReportLogExtension extension = new CreditReportLogExtension(controller);
         
         System.assertEquals(1, extension.opportunities.size());
         
         Test.startTest();
         
         extension.opportunityId = opp.Id;
         System.assertNotEquals(null, extension.savePage());
         
         Test.stopTest();
         
         crl = [SELECT Id, Related_Opportunity__c FROM Credit_Report_Log__c WHERE Account__c = :customer.Id];
         
         System.assertEquals(opp.Id, crl.Related_Opportunity__c);
     
     }
     
	static testMethod void accountWith2Opps_addCRL_selectOpp() {
     
         Account customer = new Account(Name = 'Test Customer');
         insert customer;
         
         Opportunity opp1 = new Opportunity (
             AccountId = customer.Id,
             CloseDate = Date.today(),
             StageName = 'Qualified'
         );
         insert opp1;

         Opportunity opp2 = new Opportunity (
             AccountId = customer.Id,
             CloseDate = Date.today(),
             StageName = 'Qualified'
         );
         insert opp2;
         
         Credit_Report_Log__c crl = new Credit_Report_Log__c (
             Account__c = customer.Id
         );
         
         Test.setCurrentPage(Page.CreditReportLogEdit);
         ApexPages.StandardController controller = new ApexPages.StandardController(crl);
         CreditReportLogExtension extension = new CreditReportLogExtension(controller);
         
         System.assertEquals(3, extension.opportunities.size());
         
         Test.startTest();
         
         extension.opportunityId = opp2.Id;
         System.assertNotEquals(null, extension.savePage());
         
         Test.stopTest();
         
         crl = [SELECT Id, Related_Opportunity__c FROM Credit_Report_Log__c WHERE Account__c = :customer.Id];
         
         System.assertEquals(opp2.Id, crl.Related_Opportunity__c);
     
     }
 
 }