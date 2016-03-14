/* FILE: SystemDesignASTRUMReCallExtension.cls
 * AUTHOR: Rohit Jain
 * DATE: Sep 24, 2013
 * PURPOSE: ASTRUM Site Quality Calucate from System Design.
 * MODIFICATION HISTORY 
 */
public class SystemDesignASTRUMReCallExtension{

    private ApexPages.StandardController controller;
    
    public SystemDesignASTRUMReCallExtension(ApexPages.StandardController controller) {
        this.controller = controller;
    }
    
    public PageReference reCallASTRUM() {
        
        System_Design__c sysDesign = (System_Design__c) controller.getRecord();  
        SystemDesignSQCalculation.calculateSQ(sysDesign,'ASTRUM');
        return controller.cancel();
    } 
    
    

}