/* FILE: SalesOrderSalesRegionTriggerTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: August 16, 2012
 * PURPOSE: Test class for SalesOrderSalesRegion trigger
 * MODIFICATION HISTORY
 *
 */
 
@isTest
public class SalesOrderSalesRegionTriggerTest {
	
	static testMethod void newSO_insert_SalesRegionSet() {
		
		Account customer = new Account(Name = 'Test Customer');
		insert customer;
		Property__c property =  CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');
		property.Sales_Region__c = 'TEST Region';
		update property;
		
		Test.startTest();

		SCRB_SalesOrder__c so = new SCRB_SalesOrder__c(
			Name = 'ABC123',
			Property__c = property.Id
		);
		
		insert so;
		
		Test.stopTest();
		
		so = [SELECT Id, Sales_Region__c FROM SCRB_SalesOrder__c WHERE Id = :so.Id];
		System.assertEquals('TEST Region', so.Sales_Region__c);
		
	}
	
	static testMethod void bypassTriggers_insert_SalesRegionNotSet() {
		
		Account customer = new Account(Name = 'Test Customer');
		insert customer;
		Property__c property =  CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');
		property.Sales_Region__c = 'TEST Region';
		update property;
		
		Test.startTest();

		SalesRegionHelper.bypassSalesRegionTriggers = true;
		
		SCRB_SalesOrder__c so = new SCRB_SalesOrder__c(
			Name = 'ABC123',
			Property__c = property.Id
		);
		
		insert so;
		
		Test.stopTest();
		
		so = [SELECT Id, Sales_Region__c FROM SCRB_SalesOrder__c WHERE Id = :so.Id];
		System.assertEquals(null, so.Sales_Region__c);
		
	}
	
	static testMethod void reprocess_update_SalesRegionSet() {
		
		Account customer = new Account(Name = 'Test Customer');
		insert customer;
		Property__c property =  CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');
		property.Sales_Region__c = 'TEST Region';
		update property;
		
		SalesRegionHelper.bypassSalesRegionTriggers = true;
		
		SCRB_SalesOrder__c so = new SCRB_SalesOrder__c(
			Name = 'ABC123',
			Property__c = property.Id,
			Sales_Region__c = 'ABC Region'
		);
		insert so;
		
		

		so = [SELECT Id, Sales_Region__c FROM SCRB_SalesOrder__c WHERE Id = :so.Id];
		System.assertEquals('ABC Region', so.Sales_Region__c);

		SalesRegionHelper.bypassSalesRegionTriggers = false;
		
		Test.startTest();
		
		SalesRegionHelper.reprocessSalesRegions = true;
		SalesOrderTriggerHandler.isSalesOrderTriggerRunning = false;
		SCRB_SalesOrder__c so2 = new SCRB_SalesOrder__c (Id = so.Id);
		update so2;
		
		Test.stopTest();
		
		so = [SELECT Id, Sales_Region__c FROM SCRB_SalesOrder__c WHERE Id = :so.Id];
		System.assertEquals('TEST Region', so.Sales_Region__c);
		
	}
	
}