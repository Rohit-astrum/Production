public with sharing class EmployeePINGenerator {
	
    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    Employee__c emp;
    private ApexPages.StandardController controller;

    public EmployeePINGenerator(ApexPages.StandardController stdController) {    
        this.controller = stdController;
        emp = (Employee__c)stdController.getRecord();
    }

    public PageReference getRandomInt()
    {
        emp.Employee_PIN__c =  String.valueOf(Math.round(Math.random() * (9999 - 1099)) + 1099);
        update emp;
        return controller.cancel();
    }
}