/* FILE: UtilityServiceTrigger.trigger
 * AUTHOR: Mike Katulka
 * DATE: 2014-08-28
 * PURPOSE: Common trigger for Utility Service
 * MODIFICATION HISTORY: 
 * 08/04/15  RJ  Added skipUtilityServiceTriggerSDValidation for CPQ-224.
 */
trigger UtilityServiceTrigger on Utility_Service__c (before insert, before update, after insert, after update) {
    if(UtilityServiceTriggerHandler.isUtilityServiceTriggerRunning || UtilityServiceTriggerHandler.skipUtilityServiceTrigger) return;
    UtilityServiceTriggerHandler.isUtilityServiceTriggerRunning = true;
    Boolean runValidation = UtilityServiceTriggerHandler.skipUtilityServiceTriggerSDValidation;
    UtilityServiceTriggerHandler handler = new UtilityServiceTriggerHandler (true);
    
    // Before Insert
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
    }   
    // Before Update
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap);
    }
    // After Insert 
    //if(Trigger.isInsert && Trigger.isAfter){
    //    handler.OnAfterInsert(Trigger.new, Trigger.newMap);
    //}   
    // After Update 
    if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap,runValidation); 
    }     

    UtilityServiceTriggerHandler.isUtilityServiceTriggerRunning = false;
}