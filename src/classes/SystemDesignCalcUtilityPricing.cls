/*
    12/15/14  DK  Send the Utility Service's rate code to getUtilityServiceMonthlyProduction() instead of the Property's
*/
public with sharing class SystemDesignCalcUtilityPricing {
	
	private ApexPages.StandardController controller;
    
    public SystemDesignCalcUtilityPricing(ApexPages.StandardController controller) {
        this.controller = controller;
    }
    
    public PageReference getUtilityPricing() {
        
        System_Design__c sysDesign = (System_Design__c) controller.getRecord();
        sysDesign = [SELECT Property__c FROM System_Design__c WHERE ID = :sysDesign.ID LIMIT 1];  
        Utility_Service__c utilService = [SELECT Utility_Rate_Code_Before_Solar__c 
                                          FROM Utility_Service__c WHERE Property__c = :sysDesign.Property__c LIMIT 1];
        UtilityPricingProcessor upp = new UtilityPricingProcessor(sysDesign.ID,'Method_1');
		upp.getUtilityServiceMonthlyProduction(utilService.Utility_Rate_Code_Before_Solar__c);
        //SystemDesignSQCalculation.calculateSQ(sysDesign,'ASTRUM');
        return controller.cancel();
    } 
    
    
}