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
 * MODIFICATION HISTORY: 
 * 07/16/2015 PB FPO Phase2- Set active field on Office Location
 */
@isTest
private class AstrumTime_Employee_Trigger_Utility_Test {

    public static testMethod void checkForDuplicateEmployeeName_addTwoUniqueEmployees() {

        Office_Location__c coronaOffice = new Office_Location__c(Name='Corona, CA', Street__c='123 Test St', City__c='Corona', State__c='CA', Zip_Code__c='10101', Active__c = true);
        insert coronaOffice;

		Employee__c firstEmployee = new Employee__c(name = 'John Doe', Home_Office_Location__c = coronaOffice.Id);
		insert firstEmployee;
		
		try {
			Employee__c secondEmployee = new Employee__c(name = 'Mary Public', Home_Office_Location__c = coronaOffice.Id);
			insert secondEmployee;
			
			System.assert(true);
		}
		catch (Exception exc) {				
			System.assert(false);			
		}
    }

    public static testMethod void checkForDuplicateEmployeeName_addTwoDuplicateEmployees() {

        Office_Location__c coronaOffice = new Office_Location__c(Name='Corona, CA', Street__c='123 Test St', City__c='Corona', State__c='CA', Zip_Code__c='10101', Active__c = true);
        insert coronaOffice;

		String empName = 'John Doe';
		Employee__c firstEmployee = new Employee__c(name = empName, Home_Office_Location__c = coronaOffice.Id);
		insert firstEmployee;
		
		try {
			Employee__c secondEmployee = new Employee__c(name = empName, Home_Office_Location__c = coronaOffice.Id);
			insert secondEmployee;
			
			System.assert(false);
		}
		catch (Exception exc) {				
			System.assert(true);			
		}
		
    }

    public static testMethod void checkForDuplicateEmployeeName_updateEmployeeAndChangeName() {

        Office_Location__c coronaOffice = new Office_Location__c(Name='Corona, CA', Street__c='123 Test St', City__c='Corona', State__c='CA', Zip_Code__c='10101', Active__c = true);
        insert coronaOffice;

		String empName = 'John Doe';
		Employee__c firstEmployee = new Employee__c(name = empName, Home_Office_Location__c = coronaOffice.Id);
		insert firstEmployee;

		Employee__c secondEmployee = new Employee__c(name = 'Chris Coiner', Home_Office_Location__c = coronaOffice.Id);
		insert secondEmployee;
		
		try {

			firstEmployee.Name = 'Bill Preston';
			update firstEmployee;
						
			System.assert(true);
		}
		catch (Exception exc) {				
			System.assert(false);			
		}
		
    }

    public static testMethod void checkForDuplicateEmployeeName_updateEmployeeAndKeepSameName() {

        Office_Location__c coronaOffice = new Office_Location__c(Name='Corona, CA', Street__c='123 Test St', City__c='Corona', State__c='CA', Zip_Code__c='10101', Active__c = true);
        insert coronaOffice;

		String empName = 'John Doe';
		Employee__c firstEmployee = new Employee__c(name = empName, Home_Office_Location__c = coronaOffice.Id);
		insert firstEmployee;

		Employee__c secondEmployee = new Employee__c(name = 'Chris Coiner', Home_Office_Location__c = coronaOffice.Id);
		insert secondEmployee;
		
		try {

			firstEmployee.Name = empName;
			update firstEmployee;
						
			System.assert(true);
		}
		catch (Exception exc) {				
			System.assert(false);			
		}
		
    }

    public static testMethod void checkForDuplicateEmployeeName_updateEmployeeAndChangeNameToAnotherEmployeesName() {

        Office_Location__c coronaOffice = new Office_Location__c(Name='Corona, CA', Street__c='123 Test St', City__c='Corona', State__c='CA', Zip_Code__c='10101', Active__c = true);
        insert coronaOffice;

		String empName = 'John Doe';
		Employee__c firstEmployee = new Employee__c(name = empName, Home_Office_Location__c = coronaOffice.Id);
		insert firstEmployee;

		String secondName = 'Chris Coiner';
		Employee__c secondEmployee = new Employee__c(name = secondName, Home_Office_Location__c = coronaOffice.Id);
		insert secondEmployee;
		
		try {

			firstEmployee.Name = secondName;
			update firstEmployee;
						
			System.assert(false);
		}
		catch (Exception exc) {				
			System.assert(true);			
		}
		
    }

    public static testMethod void testCopyHourlyRate_insertAndUpdate() {

        Office_Location__c coronaOffice = new Office_Location__c(Name='Corona, CA', Street__c='123 Test St', City__c='Corona', State__c='CA', Zip_Code__c='10101', Active__c = true);
        insert coronaOffice;

		Double expected = 20.00;
		
		String empName = 'John Doe';
		Employee__c firstEmployee = new Employee__c(name = empName, hourly_rate__c = expected, Home_Office_Location__c = coronaOffice.Id);
		insert firstEmployee;

		Employee__c actualEmployee = [SELECT hourly_rate_string__c, overtime_hourly_rate_string__c from Employee__c where id = :firstEmployee.id limit 1];	
		
		System.assertEquals(expected, Double.valueOf(actualEmployee.Hourly_Rate_String__c));	
		System.assertEquals(expected * 1.5, Double.valueOf(actualEmployee.Overtime_Hourly_Rate_String__c));	
    }

}