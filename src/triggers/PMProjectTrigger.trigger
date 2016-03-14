/* FILE: PMPRojectTrigger.trigger
 * AUTHOR: Lawrence Hovind
 * DATE: June 16, 2014
 * PURPOSE: PM Project Trigger
 * MODIFICATION HISTORY
 *
 */
trigger PMProjectTrigger on PM_Project__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if(TriggerUtility.skipPMProjectTriggers){
        return;
    }
    
    PMProjectTriggerHandler handler = new PMProjectTriggerHandler (true);

    
    // Before Insert 
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
    }
    // Before Update
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.new, Trigger.oldMap);
    }
    /* Before Delete 
    else if(Trigger.isDelete && Trigger.isBefore){
        handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
    }
    // After Insert 
    else if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new);
    }
    */
    // After Update 
    // else if(Trigger.isUpdate && Trigger.isAfter){
    if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
    }
    /*
    // After Delete 
    else if(Trigger.isDelete && Trigger.isAfter){
        handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
    }
    // After Undelete 
    else if(Trigger.isUnDelete){
        handler.OnUndelete(Trigger.new);
    }
    */
}