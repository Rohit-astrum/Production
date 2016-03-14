/* FILE: CustomerSurveyTest.cls
 * AUTHOR: Rohit Jain
 * DATE: June 4, 2013
 * PURPOSE: Test class for CustomerSurvey Process
 * MODIFICATION HISTORY:
 *
 */

@isTest(seeAllData=true)
public class CustomerSurveyTest{
    
  static testMethod void Change_Request_BIBU_Test() {
    
    Account customer = new Account(Name = 'Test Customer');
    insert customer;
    Contact ct = new Contact(LastName = 'RG', Email='Test@rest.comm', AccountId = customer.Id);
    insert ct;
    Property__c property = CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');
    Opportunity opp = CreateAstrumPM2ProjectTest.createOpportunity(customer.Id, 'Test Oppty');    
    SCRB_SalesOrder__c salesOrder = CreateAstrumPM2ProjectTest.createSalesOrder(property.Id, opp.Id);
    salesOrder.AccountId__c = customer.Id;
    update salesOrder;    
    Test.setCurrentPage(Page.CreateAstrumPM2Project);    
    RootstockAutomation amr = new RootstockAutomation();
    String projectId = amr.createProject(salesOrder );
    PM_Project__c prj = [Select Id,Sales_Order__c from PM_Project__c where Id = :projectId];
    
    Test.startTest();
        ApexPages.StandardController pmcontroller = new ApexPages.StandardController(prj);
        
        CustomerSurveySendExtension surveyext = new CustomerSurveySendExtension(pmcontroller );    
        List<SelectOption> options = surveyext.getContacts();
        String ContactId = options[0].getValue();
        CustomerSurveySendExtension.sendSurvey(ContactId );
        
        Customer_Survey__c survey = [Select Id,PM_Project__c,md5Code__c from Customer_Survey__c Where PM_Project__c = :projectId];
        
        System.assertEquals(projectid,survey.Pm_Project__c);
        
        Test.setCurrentPage(Page.CustomerSurveyHome);
        ApexPages.currentPage().getParameters().put('Id', survey.md5Code__c);
        
        CustomerSurveyController cs = new CustomerSurveyController();
        cs.survey.Overall_Experience__c = 'Good';
        Pagereference pr = cs.submit();
        
        survey = [Select Id,PM_Project__c,md5Code__c,Survey_Completed__c from Customer_Survey__c Where PM_Project__c = :projectId];
                
        System.assertEquals(survey.Survey_Completed__c,TRUE);
        
    Test.stopTest(); 
  }
}