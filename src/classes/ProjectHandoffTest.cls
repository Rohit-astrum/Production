/* FILE: ProjectHandoffTest.cls
 * AUTHOR: Rohit Jain
 * DATE: June 4, 2013
 * PURPOSE: Test class for ChangeRequest Process
 * MODIFICATION HISTORY:
 *
 */

@isTest(seeAllData=true)
public class ProjectHandoffTest{

    
  static testMethod void Project_Handoff_Verify_Test() {
    
    Account customer = new Account(Name = 'Test Customer');
    insert customer;
    Property__c property = CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');
    Opportunity opp = CreateAstrumPM2ProjectTest.createOpportunity(customer.Id, 'Test Oppty');    
    SCRB_SalesOrder__c salesOrder = CreateAstrumPM2ProjectTest.createSalesOrder(property.Id, opp.Id);
    salesOrder.AccountId__c = customer.Id;
    update salesOrder;
    
    Test.setCurrentPage(Page.CreateAstrumPM2Project);
    ApexPages.StandardController controller = new ApexPages.StandardController(salesOrder);
    //CreateAstrumPM2ProjectExtension extension = new CreateAstrumPM2ProjectExtension(controller);
    //PageReference result = extension.createProject();
    //String projectId = result.getUrl().substring(1);  
    
    RootstockAutomation amr = new RootstockAutomation();
    String projectId = amr.createProject(salesOrder );
    
    PM_Project__C pmprj = [Select p.Handoff_Type_of_Internet_Access__c, p.Handoff_System_Location__c, p.Handoff_Revenue_Grade_Meter_Type__c
    , p.Handoff_Revenue_Grade_Meter_Installed__c, p.Handoff_Other_System_Location__c, p.Handoff_Other_Revenue_Grade_Meter_Model__c
    , p.Handoff_Other_Revenue_Grade_Meter_Make__c, p.Handoff_Other_Outlet_Breaker_Location__c, p.Handoff_Other_Internet_Access_Type__c
    , p.Handoff_Other_Bridge_Install_Type__c, p.Handoff_Other_Big_Ticket_Electrical__c, p.Handoff_Is_Internet_Access__c
    , p.Handoff_Envoy_Location__c, p.Handoff_Envoy_Location_Explanation__c, p.Handoff_Enphase_ID__c, p.Handoff_Enlighten_Verification_Date__c
    , p.Handoff_Enlighten_Activated__c, p.Handoff_Email_Sent_Date__c, p.Handoff_Distance_to_Mail_Supply_ft__c, p.Handoff_Dedicated_Outlet_is_GFCI__c
    , p.Handoff_Dedicated_Outlet_for_Envoy__c, p.Handoff_Dedicate_Outlet_Breaker_Location__c, p.Handoff_Customer_Care_Comments__c
    , p.Handoff_Checklist_Verification_Date__c, p.Handoff_Checklist_Status__c, p.Handoff_Checklist_Completion_Date__c, p.Handoff_Checklist_Comments__c
    , p.Handoff_Check_list_Completed__c, p.Handoff_Bridge_Type__c, p.Handoff_Bridge_Model_Number__c, p.Handoff_Bridge_Installed__c
    , p.Handoff_Big_Ticket_Electrical_Type__c, p.Handoff_Big_Ticket_Electrical_Item__c From PM_Project__c p where id = :projectId ];
     
    Test.startTest();
    Test.setCurrentPage(Page.ProjectHandoff);
    controller = new ApexPages.StandardController(pmprj);
    ProjectHandoffExtension phe = new ProjectHandoffExtension (controller);
    
    PageReference result1 = phe.checkListCompleted(); 
     phe.pmproject.Handoff_System_Location__c = 'Other';
    result1 = phe.checkListCompleted();     
    System.assert(phe.errorfields.contains('[1]')); 
    phe.pmproject.Handoff_System_Location__c = 'Garage';
    result1 = phe.checkListCompleted();     
    System.assert(phe.errorfields.contains('[1]')); 
    phe.pmproject.Handoff_System_Location__c = 'Main House';
    result1 = phe.checkListCompleted();     
    System.assert(phe.errorfields.contains('[1]'));        

    phe.pmproject.Handoff_Is_Internet_Access__c  = 'Yes';
    result1 = phe.checkListCompleted();     
    System.assert(phe.errorfields.contains('[1]'));

    phe.pmproject.Handoff_Is_Internet_Access__c  = 'No';
    result1 = phe.checkListCompleted();     
    System.assert(phe.errorfields.contains('[1]'));
    
    
    phe.pmproject.Handoff_Bridge_Installed__c = 'Yes';
    result1 = phe.checkListCompleted();     
    System.assert(phe.errorfields.contains('[1]'));
    
    phe.pmproject.Handoff_Bridge_Installed__c = 'No';
    result1 = phe.checkListCompleted();     
    System.assert(phe.errorfields.contains('[1]'));
    
    phe.pmproject.Handoff_Envoy_Location__c = 'Immediately next to panel';
    result1 = phe.checkListCompleted();     
    System.assert(phe.errorfields.contains('[1]'));
    
    phe.pmproject.Handoff_Dedicate_Outlet_Breaker_Location__c  = 'Main Panel';
    result1 = phe.checkListCompleted();     
    System.assert(phe.errorfields.contains('[1]')); 
    
    
    phe.pmproject.Handoff_Dedicated_Outlet_for_Envoy__c  = 'Yes';
    result1 = phe.checkListCompleted();     
    System.assert(phe.errorfields.contains('[1]'));
    
    phe.pmproject.Handoff_Dedicated_Outlet_for_Envoy__c  = 'No';
    result1 = phe.checkListCompleted();     
    System.assert(phe.errorfields.contains('[1]'));
    
    phe.pmproject.Handoff_Revenue_Grade_Meter_Installed__c  = 'Yes';
    result1 = phe.checkListCompleted();     
    System.assert(phe.errorfields.contains('[1]'));
    
    phe.pmproject.Handoff_Revenue_Grade_Meter_Installed__c  = 'No';
    result1 = phe.checkListCompleted();     
    System.assert(phe.errorfields.contains('[1]'));
    
    
    phe.pmproject.Handoff_Big_Ticket_Electrical_Item__c  = 'Yes';
    result1 = phe.checkListCompleted();     
    System.assert(phe.errorfields.contains('[1]'));
    
    phe.pmproject.Handoff_Big_Ticket_Electrical_Type__c = 'Pool';
    result1 = phe.checkListCompleted();     
    System.assert(phe.errorfields.contains('[1]'));
    
    phe.pmproject.Handoff_Big_Ticket_Electrical_Item__c  = 'No';
    result1 = phe.checkListCompleted();     
    System.assert(phe.errorfields.contains('[1]'));
    phe.pmproject.Handoff_Enlighten_Activated__c =  'No';
    
    phe.pmproject.Handoff_Enlighten_Verification_Date__c = System.Today();
    phe.pmproject.Handoff_Enphase_ID__c  = '1234';
   
    
    PageReference result2 = phe.SavePage(); 
    
    PageReference result3 = phe.checkListCompleted(); 
    PageReference result4 = phe.verifyChecklist(); 
    
    String retUrl = phe.getReturnURL();
    
    ApexPages.currentPage().getParameters().put('emailsent', 'true'); 
    phe.updateProject();
    
    Test.stopTest(); 
      
  }
  
  static testMethod void Project_Handoff_NotVerify_Test() {
    
    Account customer = new Account(Name = 'Test Customer');
    insert customer;
    Property__c property = CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');
    Opportunity opp = CreateAstrumPM2ProjectTest.createOpportunity(customer.Id, 'Test Oppty');    
    SCRB_SalesOrder__c salesOrder = CreateAstrumPM2ProjectTest.createSalesOrder(property.Id, opp.Id);
    salesOrder.AccountId__c = customer.Id;
    update salesOrder;
    
    Test.setCurrentPage(Page.CreateAstrumPM2Project);
    ApexPages.StandardController controller = new ApexPages.StandardController(salesOrder);
    //CreateAstrumPM2ProjectExtension extension = new CreateAstrumPM2ProjectExtension(controller);
    //PageReference result = extension.createProject();
    //String projectId = result.getUrl().substring(1);  
    
    RootstockAutomation amr = new RootstockAutomation();
    String projectId = amr.createProject(salesOrder );
    
    PM_Project__C pmprj = [Select p.Handoff_Type_of_Internet_Access__c, p.Handoff_System_Location__c, p.Handoff_Revenue_Grade_Meter_Type__c
    , p.Handoff_Revenue_Grade_Meter_Installed__c, p.Handoff_Other_System_Location__c, p.Handoff_Other_Revenue_Grade_Meter_Model__c
    , p.Handoff_Other_Revenue_Grade_Meter_Make__c, p.Handoff_Other_Outlet_Breaker_Location__c, p.Handoff_Other_Internet_Access_Type__c
    , p.Handoff_Other_Bridge_Install_Type__c, p.Handoff_Other_Big_Ticket_Electrical__c, p.Handoff_Is_Internet_Access__c
    , p.Handoff_Envoy_Location__c, p.Handoff_Envoy_Location_Explanation__c, p.Handoff_Enphase_ID__c, p.Handoff_Enlighten_Verification_Date__c
    , p.Handoff_Enlighten_Activated__c, p.Handoff_Email_Sent_Date__c, p.Handoff_Distance_to_Mail_Supply_ft__c, p.Handoff_Dedicated_Outlet_is_GFCI__c
    , p.Handoff_Dedicated_Outlet_for_Envoy__c, p.Handoff_Dedicate_Outlet_Breaker_Location__c, p.Handoff_Customer_Care_Comments__c
    , p.Handoff_Checklist_Verification_Date__c, p.Handoff_Checklist_Status__c, p.Handoff_Checklist_Completion_Date__c, p.Handoff_Checklist_Comments__c
    , p.Handoff_Check_list_Completed__c, p.Handoff_Bridge_Type__c, p.Handoff_Bridge_Model_Number__c, p.Handoff_Bridge_Installed__c
    , p.Handoff_Big_Ticket_Electrical_Type__c, p.Handoff_Big_Ticket_Electrical_Item__c From PM_Project__c p where id = :projectId ];
     
    Test.startTest();
    Test.setCurrentPage(Page.ProjectHandoff);
    controller = new ApexPages.StandardController(pmprj);
    ProjectHandoffExtension phe = new ProjectHandoffExtension (controller);
    
         
   
    phe.pmproject.Handoff_System_Location__c = 'Main House';
    phe.pmproject.Handoff_Is_Internet_Access__c  = 'No';
    phe.pmproject.Handoff_Bridge_Installed__c = 'No';  
    phe.pmproject.Handoff_Envoy_Location__c = 'Immediately next to panel';    
    phe.pmproject.Handoff_Dedicate_Outlet_Breaker_Location__c  = 'Main Panel';
       
    phe.pmproject.Handoff_Dedicated_Outlet_for_Envoy__c  = 'No';
       
    phe.pmproject.Handoff_Revenue_Grade_Meter_Installed__c  = 'No';
       
    phe.pmproject.Handoff_Big_Ticket_Electrical_Item__c  = 'No';
   
    phe.pmproject.Handoff_Enlighten_Activated__c =  'No';
    
    phe.pmproject.Handoff_Enlighten_Verification_Date__c = System.Today();
    phe.pmproject.Handoff_Enphase_ID__c  = '1234';
   
    
    PageReference result2 = phe.SavePage(); 
    
    PageReference result3 = phe.checkListCompleted(); 
    PageReference result4 = phe.rejectChecklist(); 
    System.assert(phe.errorfields.contains('[1]'));
    phe.pmproject.Handoff_Customer_Care_Comments__c = 'Test';
    result4 = phe.rejectChecklist();
    
    Test.stopTest(); 
      
  }
}