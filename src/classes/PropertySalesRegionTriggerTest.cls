/* FILE: PropertySalesRegionTriggerTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: August 16, 2012
 * PURPOSE: Test class for PropertySalesRegion trigger
 * MODIFICATION HISTORY
 *
 */

@isTest
public class PropertySalesRegionTriggerTest {

	static testMethod void counties_insertProperties_RegionSet () {
		
		LeadSalesRegionTriggerTest.createCounties();
		
		Account acct1 = new Account(Name = 'Test1');
		Account acct2 = new Account(Name = 'Test2'); 
		Account acct3 = new Account(Name = 'Test3');
		insert new Account[] { acct1, acct2, acct3 }; 

		Test.startTest();
		
		Property__c prop1 = new Property__c (
			Name = 'Test1',
			Property_Owner__c = acct1.Id,
			Property_County__c = 'Test1 County',
			Property_City__c = 'Test1 City',
			Property_Zip__c = '00001',
			Property_State__c = 'PA' 
		);
		insert prop1;
		Property__c prop2 = new Property__c (
			Name = 'Test2',
			Property_Owner__c = acct2.Id,
			Property_County__c = 'Some County',
			QAS_Property_County__c = 'test2 county',
			Property_City__c = 'Test2 City',
			Property_Zip__c = '00002',
			Property_State__c = 'PA' 
		);
		insert prop2;
		Property__c prop3 = new Property__c (
			Name = 'Test3',
			Property_Owner__c = acct3.Id,
			Property_County__c = 'Another County',
			QAS_Property_County__c = 'Washington DC',
			Property_City__c = 'Test3 City',
			Property_Zip__c = '00003',
			Property_State__c = 'DC' 
		);
		insert prop3;

		Test.stopTest();
		
		prop1 = [SELECT Id, Sales_Region__c FROM Property__c WHERE Id = :prop1.Id];
		prop2 = [SELECT Id, Sales_Region__c FROM Property__c WHERE Id = :prop2.Id];
		prop3 = [SELECT Id, Sales_Region__c FROM Property__c WHERE Id = :prop3.Id];

		System.assertEquals('TEST1 Region', prop1.Sales_Region__c);		
		System.assertEquals('TEST2 Region', prop2.Sales_Region__c);		
		System.assertEquals('DC Region', prop3.Sales_Region__c);		
		
	} 
	
	static testMethod void bypassTriggers_insert_SalesRegionNotSet() {

		LeadSalesRegionTriggerTest.createCounties();
		
		Account acct1 = new Account(Name = 'Test1');
		
		Test.startTest();
		
		SalesRegionHelper.bypassSalesRegionTriggers = true;
		
		Property__c prop1 = new Property__c (
			Name = 'Test1',
			Property_Owner__c = acct1.Id,
			Property_County__c = 'Test1 County',
			Property_City__c = 'Test1 City',
			Property_Zip__c = '00001',
			Property_State__c = 'PA' 
		);
		insert prop1;

		Test.stopTest();
		
		prop1 = [SELECT Id, Sales_Region__c FROM Property__c WHERE Id = :prop1.Id];
		System.assertEquals(null, prop1.Sales_Region__c);		
		
	}
	
	static testMethod void reprocess_insert_SalesRegionNotSet() {

		LeadSalesRegionTriggerTest.createCounties();
		
		Account acct1 = new Account(Name = 'Test1');
		
		SalesRegionHelper.bypassSalesRegionTriggers = true;
		
		Property__c prop1 = new Property__c (
			Name = 'Test1',
			Property_Owner__c = acct1.Id,
			Property_County__c = 'Test1 County',
			Property_City__c = 'Test1 City',
			Property_Zip__c = '00001',
			Property_State__c = 'PA',
			Sales_Region__c = 'ABC Region' 
		);
		insert prop1;

		SalesRegionHelper.bypassSalesRegionTriggers = false;
		
		prop1 = [SELECT Id, Sales_Region__c FROM Property__c WHERE Id = :prop1.Id];
		System.assertEquals('ABC Region', prop1.Sales_Region__c);		

		Test.startTest();
		
		SalesRegionHelper.reprocessSalesRegions = true;
		Property__c prop2 = new Property__c(Id = prop1.Id);
		update prop2;

		Test.stopTest();
		
		prop1 = [SELECT Id, Sales_Region__c FROM Property__c WHERE Id = :prop1.Id];
		System.assertEquals('TEST1 Region', prop1.Sales_Region__c);		
		
	}

}