/* FILE: PhotoAppTest.cls
 * AUTHOR: Rohit Jain
 * DATE: June 4, 2013
 * PURPOSE: Test class for CustomerSurvey Process
 * MODIFICATION HISTORY:
 *
 */

@isTest(seeAllData=true)
public class PhotoAppTest{
    
  static testMethod void PhotoAppFullUploadTest() {
    
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
        System.runAs(createPMPortalUser('Full')) {              
            Test.setCurrentPage(Page.PhotoAppPage);       
            AstrumPhotoAppController controller = new AstrumPhotoAppController();            
           
            
            System.assertNotEquals(0, controller.Statuses.size());
            System.assertNotEquals(0, controller.Offices.size());
            System.assertNotEquals(0, controller.States.size());
            System.assertNotEquals(0, controller.getBins().size());
            System.assertNotEquals(0, controller.getCategories().size());
            System.assertNotEquals(0, controller.getProjectLeads().size());      
            
            List<String> projectfilters = new List<String>();
            projectfilters.add('status:All');
            projectfilters.add('state:All');
            
            AstrumPhotoAppController.setDefaultFilter(projectfilters);
            
            List<String> defaultFilter = controller.getdefaultFilter();
            
            List<PM_Project__c> projects = AstrumPhotoAppController.getFilteredProjects(projectfilters); 
            System.assertNotEquals(0, projects.size()); 
            
            controller.selectedBin =   'Kickoff Photos';
            controller.newBinSelected =   'Kickoff Photos';
            
            System.assertNotEquals(0, controller.getCategories().size());
            
            controller.selectedCategory =   'Property Photo';
            String fileName = 'test-image.jpg';
            String contentType = 'image/jpg';
        
            Blob content = Blob.valueOf('test image upload');        
            controller.uploadFile.Name = fileName;
            controller.uploadFile.Body = content;            
            controller.uploadFile.ContentType = contentType; 
            controller.categoryDateRequiredMap.put('Property Photo',false);
            ApexPages.currentPage().getParameters().put('CustomerName', projectId );
            
            Pagereference pr = controller.upload();
        
        }  
        
    Test.stopTest(); 
  }
  
  static testMethod void PhotoAppRestrictedUploadTest() {
    
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
        System.runAs(createPMPortalUser('Restricted')) {    
             
            Test.setCurrentPage(Page.PhotoAppPage);       
            AstrumPhotoAppController controller = new AstrumPhotoAppController();
        
        
            
            System.assertNotEquals(0, controller.Statuses.size());
            System.assertNotEquals(0, controller.Offices.size());
            System.assertNotEquals(0, controller.States.size());
            System.assertNotEquals(0, controller.getBins().size());
            System.assertNotEquals(0, controller.getCategories().size());
            System.assertNotEquals(0, controller.getProjectLeads().size());      
            
            List<String> projectfilters = new List<String>();
            projectfilters.add('status:Active');
            projectfilters.add('state:MD');
            projectfilters.add('office:All');
            projectfilters.add('lead:All');
            
            AstrumPhotoAppController.setDefaultFilter(projectfilters);
            
            List<String> defaultFilter = controller.getdefaultFilter();
            
            List<PM_Project__c> projects = AstrumPhotoAppController.getFilteredProjects(projectfilters); 
            //System.assertNotEquals(0, projects.size());   Commented out by DK on 05/06/15
            controller.categoryDateRequiredMap.put('Property Photo',false);
            Pagereference pr = controller.upload();
            
            controller.selectedBin =   'Kickoff Photos';
            System.assertNotEquals(0, controller.getCategories().size());
            controller.newBinSelected =   'Kickoff Photos';
            
            pr = controller.upload();
            controller.selectedCategory =   'Property Photo';
            pr = controller.upload();
            
            String fileName = 'test-image.jpg';
            String contentType = 'image/jpg';
        
            Blob content = Blob.valueOf('test image');        
            controller.uploadFile.Name = fileName;
            controller.uploadFile.Body = content;
            controller.uploadFile.ContentType = contentType; 
            
            ApexPages.currentPage().getParameters().put('CustomerName', projectId );
            ApexPages.currentPage().getParameters().put('keyDate', '10/01/2013');
            
            pr = controller.upload();
        
        }  
        
    Test.stopTest(); 
  }
  
  
  //create employee portal user
   public static User createPMPortalUser(String accessType) {
        
        Profile portalProfile;
        if(accessType == 'Full')    
        {   
            portalProfile = [SELECT Id FROM Profile WHERE Name = 'PM Mobile Full Access Site User'];
        }    
        else
        {
            portalProfile = [SELECT Id FROM Profile WHERE Name = 'PM Mobile Restricted Site User'];    
        }    
        
        User accountOwner = 
            [SELECT Id FROM User 
            WHERE UserRoleId <> NULL
            AND Profile.UserType = 'Standard' 
            AND IsActive = TRUE 
            LIMIT 1];
        
        Account a = new Account (
            OwnerId = accountOwner.Id,
            Name = 'Test Employee',
            Related_User__c = accountOwner.Id
        );
        insert a;
        
        Contact c = new Contact (
            LastName = 'Employee',
            AccountId = a.Id
        );
        insert c; 
        
        User newUser = new User (
            FirstName = 'Portal',
            LastName = 'Test',
            Email = 'pmportal.test12abcxyz@test.com',
            UserName = 'pmportal.test12abcxyz@test.com',
            ContactId = c.Id,
            Alias = 'pmpart', 
            ProfileId = portalProfile.Id, 
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'UTF-8'
        );
        insert newUser;
        
        return newUser;
    }
  
}