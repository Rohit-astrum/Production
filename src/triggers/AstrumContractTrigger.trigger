/* FILE: AstrumContractTrigger.trigger
   AUTHOR: Dan Kelner
   DATE: 12/12/14
   PURPOSE: Common trigger for Astrum_Contract__c
   MODIFICATION HISTORY: 
   
*/
trigger AstrumContractTrigger on Astrum_Contract__c (before insert, before update, after insert, after update) {

    if (AstrumContractTriggerHandler.isAstrumContractTriggerRunning || AstrumContractTriggerHandler.skipAstrumContractTrigger) return;
    AstrumContractTriggerHandler.isAstrumContractTriggerRunning = true;
    
    AstrumContractTriggerHandler handler = new AstrumContractTriggerHandler(true);
  
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

    AstrumContractTriggerHandler.isAstrumContractTriggerRunning = false;
}