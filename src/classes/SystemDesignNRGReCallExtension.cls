/* FILE: SystemDesignNRGReCallExtension.cls
 * AUTHOR: Rohit Jain
 * DATE: Sep 24, 2013
 * PURPOSE: NRG Site Quality Calucate from System Design.
 * MODIFICATION HISTORY 
 */
public class SystemDesignNRGReCallExtension{

    private ApexPages.StandardController controller;
    
    public SystemDesignNRGReCallExtension(ApexPages.StandardController controller) {
        this.controller = controller;
    }
    
    public PageReference reCallNRG() {
        
        System_Design__c sysDesign = (System_Design__c) controller.getRecord();  
        SystemDesignSQCalculation.calculateSQ(sysDesign,'NRG');       
        return controller.cancel();
    } 
    
    

}