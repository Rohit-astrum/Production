@isTest
public class System_Design_Clone_ControllerTest {
    @isTest static void cloneController(){
		        
        testData.setupCustomSettings();
        testdata.setupCustomConfigObjects();
        Id sdID = testData.setupSystemDesign('Residential', 'Purchase', null, true, 12000);
        System_Design__c sysDes = [SELECT Id, Property__c FROM System_Design__c WHERE Id=:sdID];
        
        Test.startTest();
        ApexPages.StandardController stdCntrl = new ApexPages.StandardController(sysDes);
        System_Design_Clone_Controller cntrl = new System_Design_Clone_Controller(stdCntrl);
        
		Test.stopTest();
        System.assertEquals(false, ApexPages.hasMessages());
        
    }
}