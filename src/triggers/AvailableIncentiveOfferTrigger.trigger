/* FILE: AvailableIncentiveOfferTrigger.trigger
   AUTHOR: Dan Kelner
   DATE: 12/31/14
   PURPOSE: Common trigger for Available_Incentive_Offer__c
   MODIFICATION HISTORY: 
   
*/
trigger AvailableIncentiveOfferTrigger on Available_Incentive_Offer__c (before insert, before update, after insert, after update) {

    if (AvailableIncentiveOfferTriggerHandler.isAvailableIncentiveOfferTriggerRunning || AvailableIncentiveOfferTriggerHandler.skipAvailableIncentiveOfferTrigger) return;
    AvailableIncentiveOfferTriggerHandler.isAvailableIncentiveOfferTriggerRunning = true;
    
    AvailableIncentiveOfferTriggerHandler handler = new AvailableIncentiveOfferTriggerHandler(true);
  
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

    AvailableIncentiveOfferTriggerHandler.isAvailableIncentiveOfferTriggerRunning = false;
}