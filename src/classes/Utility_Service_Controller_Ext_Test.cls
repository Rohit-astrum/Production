/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Utility_Service_Controller_Ext_Test {

    public static testMethod void testMyController() {
//      PageReference pageRef = Page.success;
//      Test.setCurrentPage(pageRef);
//      thecontroller controller = new Utility_Service_Controller_Ext();
//      String nextPage = controller.save().getUrl();
        // Verify that page fails without parameters
//      System.assertEquals('/apex/failure?error=noParam', nextPage);
        // Add parameters to page URL
//      ApexPages.currentPage().getParameters().put('CF00N30000005wCWx_lkid', 'a0G30000005usYr');
        // Instantiate a new controller with all parameters in the page
//      ApexPages.StandardController stdController = new Apexpages.Standardcontroller(new Utility_Service__c());
        
//      Utility_Service_Controller_Ext controller = new Utility_Service_Controller_Ext(stdController);
//      controller.getUtilityCompanies();

        
            /* Construct the standard controller for quote. */
            
            Utility_Company__c uc = new Utility_Company__c();
            uc.Name = 'BG&E';
            uc.States_Serviced__c = 'MD';
            Database.Saveresult ucDBResult = Database.Insert(uc,false);
            Id ucId = ucDBResult.getId();
            if(ucId == null){
                System.debug('ucDBResult Insert Errors --> ' + ucDBResult.getErrors());
            }
            System.debug('Added Utility Company with Id --> ' + ucId);
        
                    
            Account acct = new Account();
            acct.Name = 'test account';
            Database.Saveresult acctDBResult = Database.Insert(acct,false);
            Id acctId = acctDBResult.getId();
            if(acctId == null){
                System.debug('acctDBResult Insert Errors --> ' + acctDBResult.getErrors());
            }
            System.debug('Added Account with Id --> ' + acctId);
            
            
            
     
            
            Property__c prop = new Property__c();
            prop.Name = '8955 Henkels Lane';
            prop.Property_Owner__c = acctId;
            prop.Optimal_Site_Quality_kWh_y_kW__c = double.valueOf('1250');
            prop.Property_State__c = 'MD';
            prop.Property_City__c = 'Annapolis Junction';
            prop.Property_ZIP__c = '20701';
            prop.Permit_Jurisdiction__c = 'Howard';
            prop.Property_County__c = 'Howard';
            prop.Astrum_Office__c = testdata.defaultOffLocationName;// FPO Phase4 //'Annapolis Junction, MD';
            
            Database.Saveresult propDBResult = Database.Insert(prop,false);
            Id propId = propDBResult.getId();
            if(propId == null){
                System.debug('propDBResult Insert Errors --> ' + propDBResult.getErrors());
            }        

            Survey__c surv = new Survey__c();
            surv.Property__c = propId;
            surv.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'Survey__c' and r.Name = 'Field Survey'].id;
            
            insert surv;            
                        
            //Utility_Service__c us = [select id,property__c, name from Utility_Service__c where id = 'a0M30000003Inu3'];
            
            
            
            Utility_Service__c utilService = new Utility_Service__c();
            utilService.Amperage__c = double.valueOf('200');
            utilService.Utility_Company__c = ucId;
            utilService.Property__c = propId;
            utilService.Service_Account_Number__c = 'abc123';
            Database.Saveresult utilServiceDBResult = Database.Insert(utilService,false);
            Id utilServiceId = utilServiceDBResult.getId();
            if(utilServiceId == null){
                System.debug('utilServiceDBResult Insert Errors --> ' + utilServiceDBResult.getErrors());
            }        
            System.debug('Added Utility_Service__c with Id --> ' + utilServiceId);
            
            ApexPages.StandardController con = new ApexPages.StandardController(utilService);
     
            /* Switch to runtime context */ 
            Test.startTest();
    
            /* Construct the quoteExt class */
            Utility_Service_Controller_Ext ext = new Utility_Service_Controller_Ext(con);
     
//          ApexPages.currentPage().getParameters().put('CF00N30000005wCWx_lkid', 'a0G30000005uhyy');
//          List<SelectOption> propList = ext.getUtilityCompanies();
            
            
        
//          ext.setCompany(ucId);       
     
            /* Call save on the ext */
            PageReference result = ext.save();
            
     
            /* Switch back to test context */
            Test.stopTest();
     
    }
    
}