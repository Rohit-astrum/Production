/* FILE: CreateAstrumPM2ProjectTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: June 8, 2012
 * PURPOSE: Test class for CreateAstrumPM2Project page  
 * MODIFICATION HISTORY
 * 08/16/2012 TCM - fix test due to changing BingMaps trigger to not perform callouts under test
 */ 
 
@isTest(seeAllData=true)
public class CreateAstrumPM2ProjectTest {
    
    static testMethod void noProjectNoRequestedDate_createNewProject_projectCreated() {
        
        Account customer = new Account(Name = 'Test Customer', BillingStreet = '244 Torrey Pine', BillingState = 'PA' , BillingPostalCode = '19380', BillingCountry = 'USA' ,BillingCity = 'West Chester');
        insert customer;
        Property__c property = createNewProperty(customer.Id, '123 Test St');
        Opportunity opp = createOpportunity(customer.Id, 'Test Oppty');     
        SCRB_SalesOrder__c salesOrder = createSalesOrder(property.Id, opp.Id);
        salesOrder.AccountId__c = customer.Id;
        salesOrder.StatusCode__c = 'Final/Accounting Approved';
        salesOrder.Opportunity_Close_Date__c = System.today().addDays(-8);
        update salesOrder;
        
        salesOrder = 
            [SELECT Id, AccountId__c, AccountId__r.Name, RequestedShipmentOn__c 
            FROM SCRB_SalesOrder__c 
            WHERE Id = :salesOrder.Id];
        
        Test.setCurrentPage(Page.CreateAstrumPM2Project);
        ApexPages.StandardController controller = new ApexPages.StandardController(salesOrder);
        CreateAstrumPM2ProjectExtension extension = new CreateAstrumPM2ProjectExtension(controller);

        Test.startTest();
        
        PageReference result = extension.createProject();
        
        Test.stopTest();

        System.assertEquals(false, ApexPages.hasMessages());
        System.assertNotEquals(null, result);
        
        String projectId = result.getUrl().substring(1);
        PM_Project__c project = 
            [SELECT Id, Name, Sales_Order__c, Salesperson__c, Kickoff__c, Install__c, Sale_Date__c 
            FROM PM_Project__c 
            WHERE Id = :projectId];
        
        System.assertEquals(customer.Name, project.Name);
        System.assertEquals(salesOrder.Id, project.Sales_Order__c);
        System.assertEquals(UserInfo.getUserId(), project.Salesperson__c);
        System.assertEquals(opp.CloseDate, project.Sale_Date__c);
        System.assertNotEquals(null, project.Kickoff__c);
        System.assertNotEquals(null, project.Install__c);
    }
    
    static testMethod void noProjectWithRequestedDate_createNewProject_projectCreated() {

        Account customer = new Account(Name = 'Test Customer', BillingStreet = '244 Torrey Pine', BillingState = 'PA' , BillingPostalCode = '19380', BillingCountry = 'USA' ,BillingCity = 'West Chester');
        insert customer;
        Property__c property = createNewProperty(customer.Id, '123 Test St');
        Opportunity opp = createOpportunity(customer.Id, 'Test Oppty');     
        SCRB_SalesOrder__c salesOrder = createSalesOrder(property.Id, opp.Id);
        salesOrder.AccountId__c = customer.Id;
        salesOrder.RequestedShipmentOn__c = System.today().toStartOfWeek(); //sunday
        salesOrder.StatusCode__c = 'Final/Accounting Approved';
        salesOrder.Opportunity_Close_Date__c = System.today().addDays(-8);
        update salesOrder;
       
        
        Test.setCurrentPage(Page.CreateAstrumPM2Project);
        ApexPages.StandardController controller = new ApexPages.StandardController(salesOrder);
        CreateAstrumPM2ProjectExtension extension = new CreateAstrumPM2ProjectExtension(controller);

        Test.startTest();
        
        PageReference result = extension.createProject();
        
        Test.stopTest();

        System.assertEquals(false, ApexPages.hasMessages());
        System.assertNotEquals(null, result);

        String projectId = result.getUrl().substring(1);
        PM_Project__c project = 
            [SELECT Id, Name, Sales_Order__c, Salesperson__c, Kickoff__c, Install__c 
            FROM PM_Project__c 
            WHERE Id = :projectId];

        //next business day
        System.assertEquals(System.today().toStartOfWeek().addDays(1), project.Install__c);     
    }
 /* SOA - PB - Project creation is not dependent on the status of salesorder
    static testMethod void projectExists_createNewProject_ErrorMessage() {

        Account customer = new Account(Name = 'Test Customer');
        insert customer;
        Property__c property = createNewProperty(customer.Id, '123 Test St');
        Opportunity opp = createOpportunity(customer.Id, 'Test Oppty');     
        SCRB_SalesOrder__c salesOrder = createSalesOrder(property.Id, opp.Id);
        PM_Project__c project = new PM_Project__c(
            Name = 'Test Project',
            Sales_Order__c = salesOrder.Id
        );
        insert project;
        
        Test.setCurrentPage(Page.CreateAstrumPM2Project);
        ApexPages.StandardController controller = new ApexPages.StandardController(salesOrder);
        CreateAstrumPM2ProjectExtension extension = new CreateAstrumPM2ProjectExtension(controller);

        Test.startTest();
        
        PageReference result = extension.createProject();
        
        Test.stopTest();

        System.assertEquals(true, ApexPages.hasMessages());
        System.assertEquals(null, result);
        
        ApexPages.Message error = ApexPages.getMessages()[0];
        System.assertEquals('Sales Order should be Final/Accounting Approved in order to create PM 2.0 Project.', error.getSummary());
        System.assertEquals(ApexPages.Severity.ERROR, error.getSeverity());
    }
*/    
    
    public static Property__c createProperty(Id ownerId, String name) {
        Property__c property = new Property__c(
            Name = name,
            Property_Owner__c = ownerId,
            Property_City__c = 'Test City',
            Property_State__c = 'PA',
            Property_Zip__c = '19403',
            Property_County__c = 'Test County'            
        );
        insert property;
        return property;
    }
    
    public static Property__c createNewProperty(Id ownerId, String name) {
        Property__c property = new Property__c(
            Name = name,
            Property_Owner__c = ownerId,
            Property_City__c = 'Test City',
            Property_State__c = 'PA',
            Property_Zip__c = '19403',
            Property_County__c = 'Test County',
            Astrum_Office__c = 'Norristown, PA',
            Hours_From_Nearest_Office__c = 1
        );
        insert property;
        return property;
    }
    
    
    
    public static Opportunity createOpportunity(Id accountId, String name) {
        Opportunity opp = new Opportunity(
            Name = name,
            AccountId = accountId,
            StageName = 'Test',
            CloseDate = System.today().addDays(-8),
            Financing_Type__c = 'Purchase',
            Financing_Option__c = 'No Financing',
            Leasing_Option__c = null
        );
        insert opp;
        return opp;     
    }

    public static SCRB_SalesOrder__c createSalesOrder(Id propertyId, Id opportunityId) { 
        SCRB_SalesOrder__c salesOrder = new SCRB_SalesOrder__c(
            Property__c = propertyId, 
            OpportunityId__c = opportunityId,
            Requires_Tree_Removal__c = 'No',
            Has_Field_Survey_Been__c = 'No',
            Job_Id__c = 'P-343123232'
        );
        insert salesOrder;
        return salesOrder;
    }

}