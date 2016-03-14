/* FILE: PortalRegistrationTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: August 3, 2012
 * PURPOSE: Test class for PortalRegistration page and PortalRegistrationController
 * MODIFICATION HISTORY
 * 11/16/2012 TCM - make fax not required
 * 11/16/2012 TCM - remove agree with terms and conditions
 */
 
@isTest
private class PortalRegistrationTest {

    static testMethod void emptyForm_Submit_errors() {
        
        System.runAs(PortalToolsTest.getSiteGuestUser()) {
        
            Test.setCurrentPage(Page.PortalRegistration);
            ApexPages.currentPage().getParameters().put('programType', 'Professional');
            PortalRegistrationController controller = new PortalRegistrationController();
            
            Test.startTest();
            controller.app_prof.Partner_Type__c = 'Professional';
            controller.apply();
            System.assert(controller.errorFields.contains('[1]'));
            System.assert(controller.errorFields.contains('[fname]'));
            System.assert(controller.errorFields.contains('[lname]'));
            System.assert(controller.errorFields.contains('[title]'));
            System.assert(controller.errorFields.contains('[email]'));
            System.assert(controller.errorFields.contains('[phone]'));
            System.assert(controller.errorFields.contains('[2]'));
            System.assert(controller.errorFields.contains('[cname]'));
            System.assert(controller.errorFields.contains('[addr]'));
            System.assert(controller.errorFields.contains('[city]'));
            System.assert(controller.errorFields.contains('[state]'));
            System.assert(controller.errorFields.contains('[zip]'));
            System.assert(controller.errorFields.contains('[indu]'));
            System.assert(controller.errorFields.contains('[emp]'));
    
            System.assertEquals(false, controller.done);
            
            Test.stopTest();
        
        }
    }
    
    static testMethod void completePart1_Submit_Errors() {

        System.runAs(PortalToolsTest.getSiteGuestUser()) {
        
            Test.setCurrentPage(Page.PortalRegistration);
            ApexPages.currentPage().getParameters().put('programType', 'Professional');
            PortalRegistrationController controller = new PortalRegistrationController();
            
            Test.startTest();
            controller.app_prof.Partner_Type__c = 'Professional';
            controller.app_prof.First_Name__c = 'Test';
            controller.app_prof.Last_Name__c = 'Partner';
            controller.app_prof.Title__c = 'Contractor';
            controller.app_prof.Email__c = 'test.partner@partner.com';
            controller.app_prof.Phone__c = '(215) 555-1898';
            controller.app_prof.Fax__c = '(800) 555-1212';
            
            controller.apply();
            System.assert(!controller.errorFields.contains('[1]'));
            System.assert(!controller.errorFields.contains('[fname]'));
            System.assert(!controller.errorFields.contains('[lname]'));
            System.assert(!controller.errorFields.contains('[title]'));
            System.assert(!controller.errorFields.contains('[email]'));
            System.assert(!controller.errorFields.contains('[phone]'));
            System.assert(!controller.errorFields.contains('[fax]'));
            System.assert(controller.errorFields.contains('[2]'));
            System.assert(controller.errorFields.contains('[cname]'));
            System.assert(controller.errorFields.contains('[addr]'));
            System.assert(controller.errorFields.contains('[city]'));
            System.assert(controller.errorFields.contains('[state]'));
            System.assert(controller.errorFields.contains('[zip]'));
            System.assert(controller.errorFields.contains('[indu]'));
            System.assert(controller.errorFields.contains('[emp]'));
    
            System.assertEquals(false, controller.done);
            
            Test.stopTest();

        }
                
    }

    static testMethod void completePart2_Submit_Errors() {
        
        System.runAs(PortalToolsTest.getSiteGuestUser()) {
        
            Test.setCurrentPage(Page.PortalRegistration);
            ApexPages.currentPage().getParameters().put('programType', 'Professional');
            PortalRegistrationController controller = new PortalRegistrationController();
            
            Test.startTest();
            controller.app_prof.Partner_Type__c = 'Professional';
            controller.app_prof.Company_Name__c = 'Construction Company';
            controller.app_prof.Address__c = '99 Blackwater Rd';
            controller.app_prof.City__c = 'Malvern';
            controller.app_prof.State__c = controller.getStates()[3].getValue();
            controller.app_prof.Zip_Code__c = '19403';
            controller.app_prof.Industry__c = controller.getIndustries()[2].getValue();
            controller.app_prof.Employees__c = controller.getEmployees()[1].getValue();
            
            controller.apply();
            System.assert(controller.errorFields.contains('[1]'));
            System.assert(controller.errorFields.contains('[fname]'));
            System.assert(controller.errorFields.contains('[lname]'));
            System.assert(controller.errorFields.contains('[title]'));
            System.assert(controller.errorFields.contains('[email]'));
            System.assert(controller.errorFields.contains('[phone]'));
            System.assert(!controller.errorFields.contains('[2]'));
            System.assert(!controller.errorFields.contains('[cname]'));
            System.assert(!controller.errorFields.contains('[addr]'));
            System.assert(!controller.errorFields.contains('[city]'));
            System.assert(!controller.errorFields.contains('[state]'));
            System.assert(!controller.errorFields.contains('[zip]'));
            System.assert(!controller.errorFields.contains('[indu]'));
            System.assert(!controller.errorFields.contains('[emp]'));
    
            System.assertEquals(false, controller.done);
            
            Test.stopTest();
            
        }
        
    }
    
    static testMethod void completeAll_Submit_Registered() {

        Test.setCurrentPage(Page.PortalRegistration);
           ApexPages.currentPage().getParameters().put('programType', 'Professional');
        PortalRegistrationController controller = new PortalRegistrationController();
        
        System.runAs(PortalToolsTest.getSiteGuestUser()) {
            
            Test.startTest();
            controller.app_prof.Partner_Type__c = 'Professional';
            controller.app_prof.First_Name__c = 'Test';
            controller.app_prof.Last_Name__c = 'Partner';
            controller.app_prof.Title__c = 'Contractor';
            controller.app_prof.Email__c = 'test.partner@partner.com';
            controller.app_prof.Phone__c = '(215) 555-1898';
            controller.app_prof.Fax__c = '(800) 555-1212';
            controller.app_prof.Company_Name__c = 'Construction Company';
            controller.app_prof.Website__c = 'http://www.partner.com';
            controller.app_prof.Address__c = '99 Blackwater Rd';
            controller.app_prof.City__c = 'Malvern';
            controller.app_prof.State__c = controller.getStates()[3].getValue();
            controller.app_prof.Zip_Code__c = '19403';
            controller.app_prof.Industry__c = controller.getIndustries()[2].getValue();
            controller.app_prof.Employees__c = controller.getEmployees()[1].getValue();
            controller.app_prof.Source__c = controller.getSources()[0].getValue();
            controller.app_prof.Terms_Accepted__c = true;
            System.assertEquals(null, controller.apply());
            
            Test.stopTest();
            
        }
        
        System.assertEquals('', controller.errorFields);
        System.assertEquals(true, controller.done);
        
        Partner_Application__c app = [SELECT Id, OwnerId, First_Name__c, Last_Name__c,
            Title__c, Email__c, Phone__c, Fax__c, Company_Name__c, Website__c, Address__c,
            City__c, State__c, Zip_Code__c, Industry__c, Employees__c
            FROM Partner_Application__c];
            
        Group queue = [SELECT Id, DeveloperName FROM Group WHERE Id = :app.OwnerId];
        
        System.assertEquals('Partner_Application_Queue', queue.DeveloperName); 
        System.assertEquals(controller.app_prof.First_Name__c, app.First_Name__c); 
        System.assertEquals(controller.app_prof.Last_Name__c, app.Last_Name__c); 
        System.assertEquals(controller.app_prof.Title__c, app.Title__c);
        System.assertEquals(controller.app_prof.Email__c, app.Email__c);
        System.assertEquals(controller.app_prof.Phone__c, app.Phone__c);
        System.assertEquals(controller.app_prof.Fax__c, app.Fax__c);
        System.assertEquals(controller.app_prof.Company_Name__c, app.Company_Name__c);
        System.assertEquals(controller.app_prof.Website__c, app.Website__c);
        System.assertEquals(controller.app_prof.Address__c, app.Address__c);
        System.assertEquals(controller.app_prof.City__c, app.City__c);
        System.assertEquals(controller.app_prof.State__c, app.State__c);
        System.assertEquals(controller.app_prof.Zip_Code__c, app.Zip_Code__c);
        System.assertEquals(controller.app_prof.Industry__c, app.Industry__c);
        System.assertEquals(controller.app_prof.Employees__c, app.Employees__c);
        
    }

    static testMethod void badEmail_Submit_Error() {
        
        System.runAs(PortalToolsTest.getSiteGuestUser()) {

            Test.setCurrentPage(Page.PortalRegistration);
               ApexPages.currentPage().getParameters().put('programType', 'Professional');
            PortalRegistrationController controller = new PortalRegistrationController();
            
            Test.startTest();
            
            controller.app_prof.First_Name__c = 'Test1';
            controller.app_prof.Last_Name__c = 'Partner';
            controller.app_prof.Title__c = 'Contractor';
            controller.app_prof.Email__c = 'test.partner_partner.com';
            controller.app_prof.Phone__c = '(215) 555-1898';
            controller.app_prof.Fax__c = '(800) 555-1212';
            controller.app_prof.Company_Name__c = 'Construction Company';
            controller.app_prof.Address__c = '99 Blackwater Rd';
            controller.app_prof.City__c = 'Malvern';
            controller.app_prof.State__c = controller.getStates()[3].getValue();
            controller.app_prof.Zip_Code__c = '19403';
            controller.app_prof.Industry__c = controller.getIndustries()[2].getValue();
            controller.app_prof.Employees__c = controller.getEmployees()[1].getValue();
            controller.app_prof.Terms_Accepted__c = true;
            controller.apply();
            
            System.assert(controller.errorFields.contains('[1]'));
            System.assert(controller.errorFields.contains('[email]'));
            
            Test.stopTest();
        
        }
        
    }
    
    static testMethod void dupeQueue_Submit_Error() {
        
        Test.setCurrentPage(Page.PortalRegistration);
           ApexPages.currentPage().getParameters().put('programType', 'Professional');
        PortalRegistrationController controller = new PortalRegistrationController();
        
        Group queue = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Partner_Application_Queue'];
        queue.DeveloperName = 'BLA_BLA';
        update queue;
        
        System.runAs(PortalToolsTest.getSiteGuestUser()) {
            
            Test.startTest();
            controller.app_prof.Partner_Type__c = 'Professional';
            controller.app_prof.First_Name__c = 'Test';
            controller.app_prof.Last_Name__c = 'Partner';
            controller.app_prof.Title__c = 'Contractor';
            controller.app_prof.Email__c = 'test.partner@partner.com';
            controller.app_prof.Phone__c = '(215) 555-1898';
            controller.app_prof.Fax__c = '(800) 555-1212';
            controller.app_prof.Company_Name__c = 'Construction Company';
            controller.app_prof.Address__c = '99 Blackwater Rd';
            controller.app_prof.City__c = 'Malvern';
            controller.app_prof.State__c = controller.getStates()[3].getValue();
            controller.app_prof.Zip_Code__c = '19403';
            controller.app_prof.Industry__c = controller.getIndustries()[2].getValue();
            controller.app_prof.Employees__c = controller.getEmployees()[1].getValue();
            controller.app_prof.Terms_Accepted__c = true;
            
            controller.apply();
            
            System.assert(controller.errorFields.contains('[unknown]'));
    
            Test.stopTest();
            
        }
        
    }

    @isTest static void affiliateErrorFieldsTest() {

        Test.setCurrentPage(Page.PortalRegistration);
           ApexPages.currentPage().getParameters().put('programType', 'Affiliate');
        PortalRegistrationController controller = new PortalRegistrationController();
        
        System.runAs(PortalToolsTest.getSiteGuestUser()) {
            
            Test.startTest();
            controller.aff_app.Partner_Type__c = 'Affiliate';
            controller.aff_app.First_Name__c = 'Test';
            controller.aff_app.Last_Name__c = 'Partner';
            controller.aff_app.Title__c = 'Contractor';
            controller.aff_app.Email__c = 'test.partner@partner.com';
            controller.aff_app.Phone__c = '(215) 555-1898';
            controller.aff_app.Fax__c = '(800) 555-1212';
            controller.aff_app.Company_Name__c = 'Construction Company';
            controller.aff_app.Address__c = '99 Blackwater Rd';
            controller.aff_app.City__c = 'Malvern';
            controller.aff_app.State__c = controller.getStates()[3].getValue();
            controller.aff_app.Zip_Code__c = '19403';
            controller.aff_app.Source__c = controller.getSources()[0].getValue();
            controller.aff_app.Terms_Accepted__c = true;
            System.assertEquals(null, controller.apply());

            controller.aff_app.Number_of_Members__c = controller.getMembers()[1].getValue();
            controller.aff_app.EIN_Number__c = '';
            System.assertEquals(null, controller.apply());
            
            Test.stopTest();
            
        }
        
        System.assertNotEquals('', controller.errorFields);
        System.assertEquals(false, controller.done);
    }

    @isTest static void affiliateProgramTypeTest() {

        Test.setCurrentPage(Page.PortalRegistration);
           ApexPages.currentPage().getParameters().put('programType', 'Affiliate');
        PortalRegistrationController controller = new PortalRegistrationController();
        
        System.runAs(PortalToolsTest.getSiteGuestUser()) {
            
            Test.startTest();

            controller.getPartnerTypes();
            controller.getOrgIndustries();
            controller.aff_app.Partner_Type__c = 'Affiliate';
            controller.aff_app.First_Name__c = 'Test';
            controller.aff_app.Last_Name__c = 'Partner';
            controller.aff_app.Title__c = 'Contractor';
            controller.aff_app.Email__c = 'test.partner@partner.com';
            controller.aff_app.Phone__c = '(215) 555-1898';
            controller.aff_app.Fax__c = '(800) 555-1212';
            controller.aff_app.Company_Name__c = 'Construction Company';
            controller.aff_app.Address__c = '99 Blackwater Rd';
            controller.aff_app.City__c = 'Malvern';
            controller.aff_app.State__c = controller.getStates()[3].getValue();
            controller.aff_app.Zip_Code__c = '19403';
            controller.aff_app.Industry__c = controller.getIndustries()[2].getValue();
            controller.aff_app.Source__c = controller.getSources()[0].getValue();
            controller.aff_app.Number_of_Members__c = controller.getMembers()[2].getValue();
            controller.aff_app.EIN_Number__c = '99-8887777';
            controller.aff_app.Affiliate_Organization_Type__c = controller.getOrganizations()[1].getValue();
            controller.aff_app.Terms_Accepted__c = true;
            System.assertEquals(null, controller.apply());
            
            Test.stopTest();
            
        }
        
        System.assertEquals('', controller.errorFields);
        System.assertEquals(true, controller.done);
        
        Partner_Application__c app = [SELECT Id, OwnerId, First_Name__c, Last_Name__c,
            Title__c, Email__c, Phone__c, Fax__c, Company_Name__c, Website__c, Address__c,
            City__c, State__c, Zip_Code__c, Industry__c, Employees__c, Number_of_Members__c, EIN_Number__c
            FROM Partner_Application__c];
            
        Group queue = [SELECT Id, DeveloperName FROM Group WHERE Id = :app.OwnerId];
        
        System.assertEquals('Partner_Application_Queue', queue.DeveloperName); 
        System.assertEquals(controller.aff_app.First_Name__c, app.First_Name__c); 
        System.assertEquals(controller.aff_app.Last_Name__c, app.Last_Name__c); 
        System.assertEquals(controller.aff_app.Title__c, app.Title__c);
        System.assertEquals(controller.aff_app.Email__c, app.Email__c);
        System.assertEquals(controller.aff_app.Phone__c, app.Phone__c);
        System.assertEquals(controller.aff_app.Fax__c, app.Fax__c);
        System.assertEquals(controller.aff_app.Company_Name__c, app.Company_Name__c);
        System.assertEquals(controller.aff_app.Address__c, app.Address__c);
        System.assertEquals(controller.aff_app.City__c, app.City__c);
        System.assertEquals(controller.aff_app.State__c, app.State__c);
        System.assertEquals(controller.aff_app.Zip_Code__c, app.Zip_Code__c);
        System.assertEquals(controller.aff_app.Industry__c, app.Industry__c);
        System.assertEquals(controller.aff_app.Number_of_Members__c, app.Number_of_Members__c);
        System.assertEquals(controller.aff_app.EIN_Number__c, app.EIN_Number__c);
    }    

    @isTest static void affinityErrorFieldsTest() {

        Test.setCurrentPage(Page.PortalRegistration);
           ApexPages.currentPage().getParameters().put('programType', 'Affinity');
        PortalRegistrationController controller = new PortalRegistrationController();
        
        System.runAs(PortalToolsTest.getSiteGuestUser()) {
            
            Test.startTest();
            controller.afn_app.Partner_Type__c = 'Affinity';
            controller.afn_app.First_Name__c = 'Test';
            controller.afn_app.Last_Name__c = 'Partner';
            controller.afn_app.Title__c = 'Contractor';
            controller.afn_app.Email__c = 'test.partner@partner.com';
            controller.afn_app.Phone__c = '(215) 555-1898';
            controller.afn_app.Fax__c = '(800) 555-1212';
            controller.afn_app.Company_Name__c = 'Construction Company';
            controller.afn_app.Address__c = '99 Blackwater Rd';
            controller.afn_app.City__c = 'Malvern';
            controller.afn_app.State__c = controller.getStates()[3].getValue();
            controller.afn_app.Zip_Code__c = '19403';
            controller.afn_app.Source__c = controller.getSources()[0].getValue();
            controller.afn_app.Terms_Accepted__c = true;
            System.assertEquals(null, controller.apply());

            Test.stopTest();
            
        }
        
        System.assertNotEquals('', controller.errorFields);
        System.assertEquals(false, controller.done);
    }

    @isTest static void affinityProgramTypeTest() {

        Test.setCurrentPage(Page.PortalRegistration);
           ApexPages.currentPage().getParameters().put('programType', 'Affinity');
        PortalRegistrationController controller = new PortalRegistrationController();
        
        System.runAs(PortalToolsTest.getSiteGuestUser()) {
            
            Test.startTest();
            controller.afn_app.Partner_Type__c = 'Affinity';
            controller.afn_app.First_Name__c = 'Test';
            controller.afn_app.Last_Name__c = 'Partner';
            controller.afn_app.Title__c = 'Contractor';
            controller.afn_app.Email__c = 'test.partner@partner.com';
            controller.afn_app.Phone__c = '(215) 555-1898';
            controller.afn_app.Fax__c = '(800) 555-1212';
            controller.afn_app.Company_Name__c = 'Construction Company';
            controller.afn_app.Address__c = '99 Blackwater Rd';
            controller.afn_app.City__c = 'Malvern';
            controller.afn_app.State__c = controller.getStates()[3].getValue();
            controller.afn_app.Zip_Code__c = '19403';
            controller.afn_app.Website__c = 'http://www.partner.com';
            controller.afn_app.Source__c = controller.getSources()[0].getValue();
            controller.afn_app.Number_of_Members__c = controller.getMembers()[2].getValue();
            controller.afn_app.Terms_Accepted__c = true;
            System.assertEquals(null, controller.apply());
            
            Test.stopTest();
            
        }
        
        System.assertEquals('', controller.errorFields);
        System.assertEquals(true, controller.done);
        
        Partner_Application__c app = [SELECT Id, OwnerId, First_Name__c, Last_Name__c,
            Title__c, Email__c, Phone__c, Fax__c, Company_Name__c, Website__c, Address__c,
            City__c, State__c, Zip_Code__c, Industry__c, Employees__c, Number_of_Members__c, EIN_Number__c
            FROM Partner_Application__c];
            
        Group queue = [SELECT Id, DeveloperName FROM Group WHERE Id = :app.OwnerId];
        
        System.assertEquals('Partner_Application_Queue', queue.DeveloperName); 
        System.assertEquals(controller.afn_app.First_Name__c, app.First_Name__c); 
        System.assertEquals(controller.afn_app.Last_Name__c, app.Last_Name__c); 
        System.assertEquals(controller.afn_app.Title__c, app.Title__c);
        System.assertEquals(controller.afn_app.Email__c, app.Email__c);
        System.assertEquals(controller.afn_app.Phone__c, app.Phone__c);
        System.assertEquals(controller.afn_app.Fax__c, app.Fax__c);
        System.assertEquals(controller.afn_app.Company_Name__c, app.Company_Name__c);
        System.assertEquals(controller.afn_app.Address__c, app.Address__c);
        System.assertEquals(controller.afn_app.City__c, app.City__c);
        System.assertEquals(controller.afn_app.State__c, app.State__c);
        System.assertEquals(controller.afn_app.Zip_Code__c, app.Zip_Code__c);
        System.assertEquals(controller.afn_app.Number_of_Members__c, app.Number_of_Members__c);
        System.assertEquals(controller.afn_app.Website__c, app.Website__c);
    }    
}