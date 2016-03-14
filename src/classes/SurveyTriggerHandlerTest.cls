@isTest
private class SurveyTriggerHandlerTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out
	
	@isTest static void test_method_one() {
		if(!runalltests){ return; }
        
        Test.startTest();

        SurveyTriggerHandler surveyTH = new SurveyTriggerHandler(false);
        system.assertEquals(false, surveyTH.IsTriggerContext);
        surveyTH = new SurveyTriggerHandler(true);
        system.assertEquals(true, surveyTH.IsTriggerContext);

        Test.stopTest();
	}	
	
	@isTest static void test_method_two() {
		if(!runalltests){ return; }

        //Create Custom Settings
        testdata.setupCustomSettings();
        testdata.setupCustomConfigObjects();

        Account acct = new Account();
        acct.name='TestAcct';        
        insert acct;

        Property__c prop = new Property__c();
        prop.Name = '123 Main St';
        prop.RecordTypeid = [Select id from RecordType where sobjecttype = 'Property__c' and Name = 'Residential' limit 1].id;
        prop.Property_Owner__c = acct.Id;       
        prop.Optimal_Site_Quality_kWh_y_kW__c = double.valueOf('1250');
        prop.Property_State__c = 'MD';
        prop.Property_City__c = 'Annapolis Junction';        
        prop.Property_ZIP__c = '20701';
        prop.Property_County__c = 'Howard';
        prop.Astrum_Office__c = testdata.defaultOffLocationName;// FPO Phase4 //'Annapolis Junction, MD';        
        prop.Sales_Region__c = [select id from Astrum_Sales_Region__c where name='MD Region'].id;  
        prop.QAS_Property_County__c = 'Howard County, MD';    //DK 12-23-14
        insert prop;
		
        Survey__c surv = new Survey__c();
        surv.Property__c = prop.Id;
        surv.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'Survey__c' and r.Name = 'Field Survey'].id;
        insert surv;

        Test.startTest();

        Survey__c survey = [SELECT Id, Name, Tree_Removal__c FROM Survey__c LIMIT 1];
        survey.Tree_Removal__c = true;
        update survey;

        Test.stopTest();
	}
	
}