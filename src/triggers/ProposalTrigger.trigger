/* FILE: ProposalTrigger.trigger
   AUTHOR: Dan Kelner
   DATE: 12/08/14
   PURPOSE: Common trigger for Proposal__c
   MODIFICATION HISTORY: 
   
*/
trigger ProposalTrigger on Proposal__c (before insert, before update, after insert, after update) {

    if (ProposalTriggerHandler.isProposalTriggerRunning || ProposalTriggerHandler.skipProposalTrigger) return;
    ProposalTriggerHandler.isProposalTriggerRunning = true;
    
    ProposalTriggerHandler handler = new ProposalTriggerHandler(true);
  
    // Before Insert
    if (Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
    }   
    // Before Update
    else if (Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap);
    }
    
    // After Insert 
    else if (Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new, Trigger.newMap);
    }   
    // After Update 
    else if (Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap); 
    }     

    ProposalTriggerHandler.isProposalTriggerRunning = false;
}