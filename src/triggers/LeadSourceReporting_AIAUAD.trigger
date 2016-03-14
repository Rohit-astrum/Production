/* FILE: LeadSourceReporting_AIAUAD.trigger
 * AUTHOR: Rohit
 * DATE: May 31, 2013
 * PURPOSE: create or delete the Lead_Source_Reporting object based on the lead sales region
 * MODIFICATION HISTORY 
 *
 */
 
trigger LeadSourceReporting_AIAUAD on Lead (after insert, after update,after delete) {
    //don't perform updates if bypass is on	
	if (TriggerUtility.bypassLeadTriggersForBatchProcessing) { return; }
	
    //if insert , Create the the LeadSourceReporting Record
    if (Trigger.isInsert) {            
        List<Lead_Reporting__c> lsrsToInsert = new List<Lead_Reporting__c>();            
        for (Lead l : Trigger.new ) {        
           lsrsToInsert.add(new Lead_Reporting__c(                    
                     Lead__c = l.Id                                
               ));             
        }
        
         if (!lsrsToInsert.isEmpty()) {
            insert lsrsToInsert ;
        }
    }  
    //if insert , Create the the LeadSourceReporting Record
    if (Trigger.isUpdate) {
        List<Lead_Reporting__c> lsrsForMap = [Select Id,Lead__c,Opportunity__c from Lead_Reporting__C where Lead__c in :Trigger.newMap.keySet()]; 
        List<Lead_Reporting__c> lsrsToUpdate = new List<Lead_Reporting__c>();    
        Map<Id,Lead_Reporting__c> lsrsMap = new Map<Id,Lead_Reporting__c>();  
        for(Lead_Reporting__c lsr : lsrsForMap )
        {
            lsrsMap.put(lsr.Lead__c,lsr);     
        }
       
        for (Lead l : Trigger.new) {
           if(l.isConverted)
           { 
               Lead_Reporting__c lsr = lsrsMap.get(l.Id);
               if(lsr != null)
               {
                   lsr.Opportunity__C = l.ConvertedOpportunityId;
                   lsrsToUpdate.add(lsr);
               } 
               
           }        
        }
        
        if (!lsrsToUpdate.isEmpty()) {
            update lsrsToUpdate;
        }
    } 
      
    if (Trigger.isDelete) {
        
        List<Lead_Reporting__c> lsrsToDelete =
            [SELECT Id 
            FROM Lead_Reporting__c
            WHERE Lead__c IN :Trigger.oldMap.keySet()];

        if (!lsrsToDelete.isEmpty()) {
            Database.delete(lsrsToDelete, false);
        }
        
    }
   
}