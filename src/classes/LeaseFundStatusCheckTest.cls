/* FILE: LeaseFundStatusCheckTest.cls
 * AUTHOR: Rohit Jain
 * DATE: Aug 30, 2013
 * PURPOSE: Test class for LeaseFundStatusCheck_BIBU trigger on Case
 * MODIFICATION HISTORY:
 *
 */

@isTest(seeAllData=true)
public class LeaseFundStatusCheckTest{
    
    static testMethod void LeaseFundStatusCheck_Insert_Test() {
        
        Account customer = new Account(Name = 'Test Customer');
        insert customer;
        Property__c property = CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');
        Opportunity opp = CreateAstrumPM2ProjectTest.createOpportunity(customer.Id, 'Test Oppty');    
        SCRB_SalesOrder__c salesOrder = CreateAstrumPM2ProjectTest.createSalesOrder(property.Id, opp.Id);
        salesOrder.AccountId__c = customer.Id;
        salesOrder.StatusCode__c = 'Conversion Processing';
        update salesOrder;
        RootstockAutomation amr = new RootstockAutomation();
        String projectId = amr.createProject(salesOrder );
        
        Test.startTest();
               
        Case cs = new Case();
        
        cs.Sales_Order__c = salesOrder.Id;
        cs.Conversion_Status__c = 'Conversion Contract Signed';   
        cs.Origin = 'Customer Care';  
        
        insert cs;
        
        Test.stopTest();   
    
        PM_Project__c project =  
          [SELECT Id, Lease_Funding_Status__c
          FROM PM_Project__c 
          WHERE Id = :projectid];
    
    
        System.assertEquals(project.Lease_Funding_Status__c, 'Ready to Prepare'); 
    }    
    
    static testMethod void LeaseFundStatusCheck_Update_Test() {
        
        Account customer = new Account(Name = 'Test Customer');
        insert customer;
        Property__c property = CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');
        Opportunity opp = CreateAstrumPM2ProjectTest.createOpportunity(customer.Id, 'Test Oppty');    
        SCRB_SalesOrder__c salesOrder = CreateAstrumPM2ProjectTest.createSalesOrder(property.Id, opp.Id);
        salesOrder.AccountId__c = customer.Id;
        salesOrder.StatusCode__c = 'Conversion Processing';
        update salesOrder;
        RootstockAutomation amr = new RootstockAutomation();
        String projectId = amr.createProject(salesOrder );
        
        Case cs = new Case();        
        cs.Sales_Order__c = salesOrder.Id;
        cs.Conversion_Status__c = 'Conversion Contract Presented';   
        cs.Origin = 'Customer Care';          
        insert cs;
        
        Test.startTest();
        cs.Conversion_Status__c = 'Conversion Contract Signed'; 
        update cs;
        Test.stopTest();   
    
        PM_Project__c project =  
          [SELECT Id, Lease_Funding_Status__c
          FROM PM_Project__c 
          WHERE Id = :projectid];
    
    
        System.assertEquals(project.Lease_Funding_Status__c, 'Ready to Prepare'); 
    } 
    
    static testMethod void Sales_ORder_Approval_Trigger_Test() {
        
        Account customer = new Account(Name = 'Test Customer');
        insert customer;
        Property__c property = CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');
        Opportunity opp = CreateAstrumPM2ProjectTest.createOpportunity(customer.Id, 'Test Oppty');    
        SCRB_SalesOrder__c salesOrder = CreateAstrumPM2ProjectTest.createSalesOrder(property.Id, opp.Id);
        salesOrder.AccountId__c = customer.Id;
        salesOrder.StatusCode__c = 'Conversion Going';
        update salesOrder;
        RootstockAutomation amr = new RootstockAutomation();
        String projectId = amr.createProject(salesOrder );
        
        Case cs = new Case();        
        cs.Sales_Order__c = salesOrder.Id;
        cs.Conversion_Status__c = 'Conversion Contract Signed';   
        cs.Origin = 'Customer Care';          
        insert cs;
        
        Test.startTest();
        salesOrder.StatusCode__c = 'Conversion Processing';
        update salesOrder;
        Test.stopTest();   
    
        PM_Project__c project =  
          [SELECT Id, Lease_Funding_Status__c
          FROM PM_Project__c 
          WHERE Id = :projectid];
    
    
        System.assertEquals(project.Lease_Funding_Status__c, 'Ready to Prepare'); 
    }                       
}