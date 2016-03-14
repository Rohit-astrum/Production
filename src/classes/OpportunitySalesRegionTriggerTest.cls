/* FILE: OpportunitySalesRegionTriggerTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: August 16, 2012
 * PURPOSE: Test class for OpportunitySalesRegion trigger
 * MODIFICATION HISTORY
 *
 */
 
@isTest(seeAllData=true)
public class OpportunitySalesRegionTriggerTest {
	
	static testMethod void newOpp_insert_SalesRegionSet() {
		
		Account customer = new Account(Name = 'Test Customer');
		insert customer;
		Property__c property =  CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');
		property.Sales_Region__c = 'TEST Region';
		update property;
		
		Test.startTest();

		Opportunity opp = new Opportunity(
			Name = 'ABC123',
			AccountId = customer.Id,
			StageName = 'Test',
			CloseDate = System.today().addDays(-8),
			Financing_Type__c = 'Lease',
			Property__c = property.Id
		);
		
		insert opp;
		
		Test.stopTest();
		
		opp = [SELECT Id, Sales_Region__c FROM Opportunity WHERE Id = :opp.Id];
		System.assertEquals(property.Sales_region__c, opp.Sales_Region__c);
		
	}
	
	static testMethod void bypassTriggers_insert_SalesRegionNotSet() {
		
		Account customer = new Account(Name = 'Test Customer');
		insert customer;
		Property__c property =  CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');
		property.Sales_Region__c = 'TEST Region';
		update property;
		
		Test.startTest();

		SalesRegionHelper.bypassSalesRegionTriggers = true;
		
		Opportunity opp = new Opportunity(
			Name = 'ABC123',
			AccountId = customer.Id,
			StageName = 'Test',
			CloseDate = System.today().addDays(-8),
			Financing_Type__c = 'Lease',
			Property__c = property.Id
		);
		
		insert opp;
		
		Test.stopTest();
		
		opp = [SELECT Id, Sales_Region__c FROM Opportunity WHERE Id = :opp.Id];
		System.assertEquals(null, opp.Sales_Region__c);
		
	}
	
	static testMethod void reprocess_updates_SalesRegionSet() {
		
		Account customer = new Account(Name = 'Test Customer');
		insert customer;
		Property__c property =  CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');
		property.Sales_Region__c = 'TEST Region';
		update property;
		
		SalesRegionHelper.bypassSalesRegionTriggers = true;
		
		Opportunity opp = new Opportunity(
			Name = 'ABC123',
			AccountId = customer.Id,
			StageName = 'Test',
			CloseDate = System.today().addDays(-8),
			Financing_Type__c = 'Lease',
			Property__c = property.Id,
			Sales_Region__c = 'ABC Test'
		);
		
		insert opp;

		SalesRegionHelper.bypassSalesRegionTriggers = false;

		opp = [SELECT Id, Sales_Region__c FROM Opportunity WHERE Id = :opp.Id];
		System.assertEquals('ABC Test', opp.Sales_Region__c);

		Test.startTest();

		SalesRegionHelper.reprocessSalesRegions = true;
		Opportunity opp2 = new Opportunity(Id = opp.Id);
		update opp2;
		
		Test.stopTest();
		
		opp = [SELECT Id, Sales_Region__c FROM Opportunity WHERE Id = :opp.Id];
		System.assertEquals('TEST Region', opp.Sales_Region__c);
		
	}
	
}