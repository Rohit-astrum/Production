/* FILE: SystemDesignCPREReCallExtension.cls
 * AUTHOR: Rohit Jain
 * DATE: July 24, 2013
 * PURPOSE: Clean Power Estimator Web Service Callout for Site Quality. Called from Button on Install Location.
 * MODIFICATION HISTORY 
 */
public class SystemDesignCPREReCallExtension{

    private ApexPages.StandardController controller;
    
    public SystemDesignCPREReCallExtension(ApexPages.StandardController controller) {
        this.controller = controller;
    }
    
    public PageReference reCallCPRE() {
        System_Design__c sysDesign = (System_Design__c) controller.getRecord();  
        SystemDesignSQCalculation.calculateSQ(sysDesign,'CPRE');       
        return controller.cancel();
    } 
    
    public class customException extends Exception {} 

}