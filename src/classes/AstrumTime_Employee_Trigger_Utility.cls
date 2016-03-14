public with sharing class AstrumTime_Employee_Trigger_Utility {
	
	public static void checkForDuplicateEmployeeName(List<Employee__c> newEmployees) {

		List<Employee__c> currentEmployees = [select id, name from Employee__c];

		for (Employee__c tempNewEmployee : newEmployees) {
			for (Employee__c tempCurrentEmployee : currentEmployees) {

				Boolean diffId = tempNewEmployee.Id != tempCurrentEmployee.Id;
				Boolean sameName = tempNewEmployee.Name == tempCurrentEmployee.Name;
				
				if (diffId && sameName) {					
					tempNewEmployee.Name.addError('Duplicate employee names are not allowed.');
				}				
			}	
		}
	}	
	
	public static void copyHourlyRates(List<Employee__c> newEmployees) {

		for (Employee__c tempNewEmployee : newEmployees) {
			// copy hourly rate
			tempNewEmployee.Hourly_Rate_String__c = getValue(tempNewEmployee.Hourly_Rate__c);
			
			// copy overtime rate
			tempNewEmployee.Overtime_Hourly_Rate_String__c = getValue(tempNewEmployee.Overtime_Rate__c);
		}		
	}	
	
	private static String getValue(Decimal theField) {
		String result = null;
		
		if (theField != null) {
			result = theField.toPlainString();
		}
		else {
			result = '0.00';
		}
		
		return result;	
	}
}