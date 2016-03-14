/* FILE: AstrumEventTrigger.trigger
 * AUTHOR: Mike Katulka
 * DATE: 2014-06-18
 * PURPOSE: To synchronize changes to the users calendar
 * MODIFICATION HISTORY: 
 *
 */
trigger AstrumEventTrigger on Astrum_Event__c (before insert, before update, after insert, after update) {
    if(TriggerUtility.isAstrumEventTriggerRunning || TriggerUtility.skipAstrumEventTrigger) return;
    TriggerUtility.isAstrumEventTriggerRunning = true;
    
	AstrumEventTriggerHandler handler = new AstrumEventTriggerHandler (true);
	
    //Before Insert
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
    }   
	// Before Update
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap);
    }
    // After Insert
    if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new);
    }   
    // After Update 
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap); 
    }     

    TriggerUtility.isAstrumEventTriggerRunning = false;
}