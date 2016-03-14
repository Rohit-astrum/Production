/* FILE: SDQGetPricingController.cls
 * AUTHOR: Rohit Jain
 * DATE: July 13, 2013
 * PURPOSE: Controller for getting Price on SDQ
 * MODIFICATION HISTORY: 
 *                    MK - 2014-4-2 - Moved code into a separate class so that it can be called from a trigger.
 * RJ Commented the code 05/05/2015
 */

public without sharing class SDQGetPricingController{
    /*
    System_Design_Quote__c sdq;
    SDQGetPricing gp;

    public SDQGetPricingController(ApexPages.StandardController stdController) {        
        sdq =  (System_Design_Quote__c)stdController.getRecord();
        gp = new SDQGetPricing(sdq.id); 

    }
    
    public PageReference getPricing() {                                      
        if(gp.errorLog != null && gp.errorLog.length() > 0){         
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was a problem calculating the price for this quote.  Please review these errors: ' + gp.errorLog));
        }else{
            gp.getPricing();
        }
        return (new ApexPages.StandardController(sdq)).view();
    } 
    */ 

}