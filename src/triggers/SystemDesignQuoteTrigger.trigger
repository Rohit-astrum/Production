/* FILE: SystemDesignQuoteTrigger.trigger
 * AUTHOR: Mike Katulka
 * DATE: 2014-07-21
 * PURPOSE: Common trigger for System Design Quote
 * MODIFICATION HISTORY: 
 *
 */
trigger SystemDesignQuoteTrigger on System_Design_Quote__c (before insert, before update, after insert, after update) {
    if(SystemDesignQuoteTriggerHandler.isSystemDesignQuoteTriggerRunning || SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger) return;
    SystemDesignQuoteTriggerHandler.isSystemDesignQuoteTriggerRunning = true;
    
	SystemDesignQuoteTriggerHandler handler = new SystemDesignQuoteTriggerHandler (true);
	
    // Before Insert
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
    }   
	// Before Update
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap);
    }
    // After Insert 
    if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new, Trigger.newMap);
    }   
    // After Update 
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap); 
    }     

    SystemDesignQuoteTriggerHandler.isSystemDesignQuoteTriggerRunning = false;
}