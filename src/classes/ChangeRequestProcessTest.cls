/* FILE: ChangeRequestProcessTest.cls
 * AUTHOR: Rohit Jain
 * DATE: June 4, 2013
 * PURPOSE: Test class for ChangeRequest Process
 * MODIFICATION HISTORY:
 *
 */

@isTest(seeAllData=true)
public class ChangeRequestProcessTest{

    
  static testMethod void Change_Request_BIBU_Test() {
    
    Account customer = new Account(Name = 'Test Customer');
    insert customer;
    Property__c property = CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');
    Opportunity opp = CreateAstrumPM2ProjectTest.createOpportunity(customer.Id, 'Test Oppty');    
    SCRB_SalesOrder__c salesOrder = CreateAstrumPM2ProjectTest.createSalesOrder(property.Id, opp.Id);
    salesOrder.AccountId__c = customer.Id;
    update salesOrder;
    
    Test.setCurrentPage(Page.CreateAstrumPM2Project);
    //ApexPages.StandardController controller = new ApexPages.StandardController(salesOrder);
    //CreateAstrumPM2ProjectExtension extension = new CreateAstrumPM2ProjectExtension(controller);
    //PageReference result = extension.createProject();
    //String projectId = result.getUrl().substring(1);
    RootstockAutomation amr = new RootstockAutomation();
    String projectId = amr.createProject(salesOrder );
    
    Test.startTest();
    
    Change_Request__C cr = new Change_Request__C(
        Sales_Order__c = salesOrder.Id
       ,Type_1__c = 'Panel Change'
       ,Reason_for_Change_1__c = 'Design Change'
       ,Change_From__c = 'From'
       ,Change_To__c = 'To'        
    );
    
    insert cr; 
    
    cr.Status__c = 'Rejected';
    update cr;   
    
    ApexPages.StandardController crcontroller = new ApexPages.StandardController(cr);
    Change_Request_Escalation_Controller escController = new Change_Request_Escalation_Controller(crcontroller);    
    escController.comments = 'Test Comments';
    
    PageReference escResult = escController.submitEscalation();
    
    
    //ApexPages.StandardController crcontroller = new ApexPages.StandardController(cr);
    Change_Request_Cancellation_Controller cancelController = new Change_Request_Cancellation_Controller(crcontroller);    
    cancelController.comments = 'Test Comments';
    
    PageReference cancelResult = cancelController.submitCancellation();
    
    cr.Status__c = 'Approved/Pending';
    update cr; 
    
    Change_Request_Completion_Controller compController = new Change_Request_Completion_Controller (crcontroller);    
    compController.comments = 'Test Comments';
    
    PageReference compResult = compController.submitCompletion();
    
    
    
    Test.stopTest();   
    
    cr =  
      [SELECT Id, PM_Project__c 
      FROM Change_Request__C
      WHERE Id = :cr.Id];
    
    
    System.assertEquals(cr.PM_Project__c , projectId ); 
      
  }
}