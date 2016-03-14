/* FILE: PMProjectFactSheetTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: June 11, 2012
 * PURPOSE: Test class for PMProjectFactSheet page  
 * MODIFICATION HISTORY
 *
 */ 

@isTest
public class PMProjectFactSheetTest {
	
	static testMethod void project_getFactSheet_dataFound() {
		
		Account customer = new Account(Name = 'Test Customer');
		insert customer;

		Account partner = new Account(Name = 'Fund Partner');
		insert partner;
	
		Lease_Fund__c leasefund = new Lease_Fund__c(
			Name = 'NRG Residential Solar Solutions, LLC',
			Fund_Partner__c = partner.id,
			Fund_Open_Date__c = date.today(),
			Eligible_States__c = 'CA;CT;DC;DE;KY;MA;MD;MI;NJ;NY;OH;PA;VA;WV',
			Eligible_Leasing_Options__c = 'One-Pay - Keep SRECs'
		);
		insert(leasefund);	
		
		Lease_Fund__c leasefund2 = new Lease_Fund__c(
			Name = 'Sunnova Energy Corporation',
			Fund_Partner__c = partner.id,
			Fund_Open_Date__c = date.today(),
			Eligible_States__c = 'CA;CT;DC;DE;KY;MA;MD;MI;NJ;NY;OH;PA;VA;WV',
			Eligible_Leasing_Options__c = 'One-Pay - Keep SRECs'
		);					
		insert(leasefund2);

		Contact contact1 = new Contact ( AccountId = customer.Id, LastName = 'Customer 1');
		insert contact1; 
		
		Property__c property = CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');
		SCRB_SalesOrder__c salesOrder = CreateAstrumPM2ProjectTest.createSalesOrder(property.Id, null);
		salesOrder.AccountId__c = customer.Id;
		update salesOrder;
		
		Utility_Company__c utility = new Utility_Company__c (
			State_Serviced__c = 'PA'
		);
		insert utility;
		
		Utility_Service__c service = new Utility_Service__c (
			Property__c = property.Id,
			Service_Account_Number__c = 'ABC',
			Utility_Company__c = utility.Id
		);
		insert service;	
	
		PM_Project__c project = new PM_Project__c (
			Name = 'Test Project',
			Sales_Order__c = salesOrder.Id
		);
		insert project;
		
		project = [SELECT Id, Name, Project_Lead__c, Kickoff__c, Install__c, Inspection__c,
			Sales_Order__r.AccountId__c,
			Sales_Order__r.Property__c,
			Sales_Order__r.System_Design_Quote__r.System_Design__c
			FROM PM_Project__c 
			WHERE Id = :project.Id];

		Test.setCurrentPage(Page.PMProjectFactSheet);
		ApexPages.StandardController controller = new ApexPages.StandardController(project);


		Test.startTest();

		PMProjectFactSheetExtension extension = new PMProjectFactSheetExtension(controller);
		
		System.assertEquals(1, extension.contacts.size());
		System.assertEquals(contact1.LastName, extension.contacts[0].LastName);

		System.assertEquals(1, extension.utilityServices.size());

		System.assertEquals(0, extension.installLocations.size());
		System.assertEquals(0, extension.cbPanels.size());
		System.assertEquals(0, extension.systemDesignArrays.size());
		System.assertEquals(0, extension.systemDesignItems.size());
		
		Test.stopTest();

	}

}