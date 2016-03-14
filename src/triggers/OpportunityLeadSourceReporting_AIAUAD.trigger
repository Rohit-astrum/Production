/* FILE: OpportunityLeadSourceReporting_AIAUAD.trigger
 * AUTHOR: Rohit
 * DATE: May 31, 2013
 * PURPOSE: create or delete the Lead_Reporting object based on the Opportunity
 * MODIFICATION HISTORY 
 *
 */
 
trigger OpportunityLeadSourceReporting_AIAUAD on Opportunity (after insert, after update,after delete) {

    //MK - 2014-08-25 - prevent recursive firing of triggers, saves unecessary processing
    if(Opportunity_Trigger_Utility.isOpportunityTriggerRunning || Opportunity_Trigger_Utility.skipOpportunityTrigger) return;
    Opportunity_Trigger_Utility.isOpportunityTriggerRunning = true;

    //if insert , Create the the LeadSourceReporting Record
    if (Trigger.isInsert) {            
        List<Lead_Reporting__c> lsrsToInsert = new List<Lead_Reporting__c>();            
        for (Opportunity opp : Trigger.new ) { 
           if(!opp.Lead_Exists__c)        
           {
               lsrsToInsert.add(new Lead_Reporting__c(                    
                         Opportunity__c = opp.Id                                
                   ));             
           }        
        }
        
        if (!lsrsToInsert.isEmpty()) {
            insert lsrsToInsert ;
        }
    }  
      
    if (Trigger.isDelete) {
        
        List<Lead_Reporting__c> lsrsToDelete =
            [SELECT Id 
            FROM Lead_Reporting__c
            WHERE Opportunity__c IN :Trigger.oldMap.keySet()];

        if (!lsrsToDelete.isEmpty()) {
            Database.delete(lsrsToDelete, false);
        }
        
    }

    //MK - 2014-08-25 - prevent recursive firing of triggers, saves unecessary processing
    Opportunity_Trigger_Utility.isOpportunityTriggerRunning = false;
    
}