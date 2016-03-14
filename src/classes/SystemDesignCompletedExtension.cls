/* FILE: SystemDesignCompletedExtension.cls
 * AUTHOR: Rohit Jain
 * DATE: Oct 8, 2014
 * PURPOSE: Extension for System Design Completed Button
 * MODIFICATION HISTORY 
 * RJ: If there is existing Current SDQ - Do not create a new SDQ on SD Complete Action
 */
public with sharing class SystemDesignCompletedExtension { 

	private ApexPages.StandardController controller;

    public SystemDesignCompletedExtension(ApexPages.StandardController controller) {
        this.controller = controller;
    }

    public PageReference designCompleted() {
        System_Design__c sysDesign = (System_Design__c) controller.getRecord();  
        List<System_Design_Quote__c> quotesList = [Select Pricing_Date__c from System_Design_Quote__c Where System_Design__c = :sysDesign.id And Current__c = true];
        if(quotesList != null && quotesList.size() > 0)
        {
          System_Design_Quote__c sdq = quotesList[0];
          Date pricingDate = Date.today();
          if (sdq.Pricing_Date__c != null)
              pricingDate = Date.newInstance(sdq.Pricing_Date__c.year(), sdq.Pricing_Date__c.month(), sdq.Pricing_Date__c.day());   //CPQ-751
        	SalesWorkflowValidationUtility.validateSystemDesign(sysDesign, false, pricingDate);
       	}
       	else
       	{
       		SalesWorkflowValidationUtility.validateSystemDesign(sysDesign, true, Date.today());	
       	}
        return controller.cancel();
    }
}