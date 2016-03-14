/* FILE: SystemDesignTrigger.trigger
 * AUTHOR: Rohit Jain
 * DATE: Mar 24, 2014
 * PURPOSE: System Design Trigger
 * MODIFICATION HISTORY
 *
 */
trigger SystemDesignTrigger on System_Design__c (before update,after update,after insert) {

    if(SystemDesignTriggerHandler.isSystemDesignTriggerRunning || SystemDesignTriggerHandler.skipSystemDesignTrigger) return;
    SystemDesignTriggerHandler.isSystemDesignTriggerRunning = true;

	SystemDesignTriggerHandler handler = new SystemDesignTriggerHandler (true);
	// Before Update
    if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.new, Trigger.oldMap, Trigger.newMap);
    }	
    // After Update 
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.new, Trigger.oldMap, Trigger.newMap);
    }    
    // After Insert
    else if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new);
    }    

    SystemDesignTriggerHandler.isSystemDesignTriggerRunning = false;
}