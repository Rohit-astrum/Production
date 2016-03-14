/* FILE: InstallProjectSetSalesOrderTriggerTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: July 5, 2012
 * PURPOSE: Test class for InstallProjectSetSalesOrder trigger (zen-26 AstrumTime update)
 * MODIFICATION History 
 * 07/30/2012 TCM - zen-41 - prevent having more than one install project for an Astrum PM 2.0 project
 */
 
@isTest
private class InstallProjectSetSalesOrderTriggerTest {

    static testMethod void installProjectWithPM2Proj_insert_salesOrderSet() {
    	
    	Account customer = new Account(Name = 'Test Customer');
		insert customer;
		Property__c property = CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');
		SCRB_SalesOrder__c salesOrder = CreateAstrumPM2ProjectTest.createSalesOrder(property.Id, null);
		PM_Project__c project = new PM_Project__c ( Name = 'Test Project 1', Sales_Order__c = salesOrder.Id );
		insert project;
		
		Test.startTest();
		
		Install_Project__c installProject = new Install_Project__c(
			PM_Project__c = project.Id,
			Drive_Time_Office_To_Site__c = 1.5,
			Electrician_Drive_Time_To_Site__c = 1.2
		);
		insert installProject;
		
		Test.stopTest();
		
		installProject = [SELECT Id, PM_Project__c, Sales_Order__c FROM Install_Project__c WHERE Id = :installProject.Id];
		
		System.assertEquals(project.Id, installProject.PM_Project__c);
		System.assertEquals(salesOrder.Id, installProject.Sales_Order__c);
		
    }
    
    static testMethod void installProject_changeProject_salesOrderUpdated() {
    	
    	Account customer = new Account(Name = 'Test Customer');
		insert customer;
		Property__c property1 = CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');
		Property__c property2 = CreateAstrumPM2ProjectTest.createProperty(customer.Id, '456 Test St');
		SCRB_SalesOrder__c salesOrder1 = CreateAstrumPM2ProjectTest.createSalesOrder(property1.Id, null);
		SCRB_SalesOrder__c salesOrder2 = CreateAstrumPM2ProjectTest.createSalesOrder(property2.Id, null);
		PM_Project__c project1 = new PM_Project__c ( Name = 'Test Project 1', Sales_Order__c = salesOrder1.Id );
		insert project1;
		PM_Project__c project2 = new PM_Project__c ( Name = 'Test Project 2', Sales_Order__c = salesOrder2.Id );
		insert project2;

		Install_Project__c installProject = new Install_Project__c(
			PM_Project__c = project1.Id,
			Drive_Time_Office_To_Site__c = 1.5,
			Electrician_Drive_Time_To_Site__c = 1.2
		);
		insert installProject;

		installProject = [SELECT Id, PM_Project__c, Sales_Order__c FROM Install_Project__c WHERE Id = :installProject.Id];
		System.assertEquals(project1.Id, installProject.PM_Project__c);
		System.assertEquals(salesOrder1.Id, installProject.Sales_Order__c);
		
		Test.startTest();

		installProject.PM_Project__c = project2.Id;
		update installProject;
		
		Test.stopTest();
		
		installProject = [SELECT Id, PM_Project__c, Sales_Order__c FROM Install_Project__c WHERE Id = :installProject.Id];
		
		System.assertEquals(project2.Id, installProject.PM_Project__c);
		System.assertEquals(salesOrder2.Id, installProject.Sales_Order__c);
		
    }
    
	static testMethod void installProjectNoProject_insert_SalesOrderNull() {

		Install_Project__c installProject = new Install_Project__c (
			Drive_Time_Office_To_Site__c = 1.5,
			Electrician_Drive_Time_To_Site__c = 1.2
		);

		Test.startTest();

		insert installProject;
		
		Test.stopTest();
		
		installProject = [SELECT Id, PM_Project__c, Sales_Order__c FROM Install_Project__c WHERE Id = :installProject.Id];
		
		System.assertEquals(null, installProject.PM_Project__c);
		System.assertEquals(null, installProject.Sales_Order__c);
    
	}
	
	static testMethod void installProjectWithPM2Proj_insertDuplicate_Exception() {
    	
    	Account customer = new Account(Name = 'Test Customer');
		insert customer;
		Property__c property = CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');
		SCRB_SalesOrder__c salesOrder = CreateAstrumPM2ProjectTest.createSalesOrder(property.Id, null);
		PM_Project__c project = new PM_Project__c ( Name = 'Test Project 1', Sales_Order__c = salesOrder.Id );
		insert project;
		
		Test.startTest();
		
		Install_Project__c installProject = new Install_Project__c(
			PM_Project__c = project.Id,
			Drive_Time_Office_To_Site__c = 1.5,
			Electrician_Drive_Time_To_Site__c = 1.2
		);
		insert installProject;
		
		installProject = new Install_Project__c(
			PM_Project__c = project.Id,
			Drive_Time_Office_To_Site__c = 1.5,
			Electrician_Drive_Time_To_Site__c = 1.2
		);
		
		try {
			
			insert installProject;
			
			System.assert(false, 'Duplicate exception not thrown');
			
		} catch (DmlException e) {
			
			System.assertEquals('DUPLICATE_VALUE' , e.getDmlStatusCode(0));
			
		}
		
		Test.stopTest();
		
    }

    static testMethod void installProject_changeToExistingProject_Exception() {
    	
    	Account customer = new Account(Name = 'Test Customer');
		insert customer;
		Property__c property1 = CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');
		Property__c property2 = CreateAstrumPM2ProjectTest.createProperty(customer.Id, '456 Test St');
		SCRB_SalesOrder__c salesOrder1 = CreateAstrumPM2ProjectTest.createSalesOrder(property1.Id, null);
		SCRB_SalesOrder__c salesOrder2 = CreateAstrumPM2ProjectTest.createSalesOrder(property2.Id, null);
		PM_Project__c project1 = new PM_Project__c ( Name = 'Test Project 1', Sales_Order__c = salesOrder1.Id );
		insert project1;
		PM_Project__c project2 = new PM_Project__c ( Name = 'Test Project 2', Sales_Order__c = salesOrder2.Id );
		insert project2;

		Install_Project__c installProject = new Install_Project__c(
			PM_Project__c = project1.Id,
			Drive_Time_Office_To_Site__c = 1.5,
			Electrician_Drive_Time_To_Site__c = 1.2
		);
		insert installProject;
		installProject = new Install_Project__c(
			PM_Project__c = project2.Id,
			Drive_Time_Office_To_Site__c = 1.5,
			Electrician_Drive_Time_To_Site__c = 1.2
		);
		insert installProject;

		Test.startTest();
		
		installProject = new Install_Project__c (Id = installProject.Id, PM_Project__c = project1.Id);

		try {
			
			update installProject;
			
			System.assert(false, 'Duplicate exception not thrown');
			
		} catch (DmlException e) {
			
			System.assertEquals('DUPLICATE_VALUE' , e.getDmlStatusCode(0));
			
		}

    }
	    
}