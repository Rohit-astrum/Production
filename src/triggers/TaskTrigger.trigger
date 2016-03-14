trigger TaskTrigger on Task (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(TriggerUtility.isTaskTriggerRunning || TriggerUtility.skipTaskTrigger) return;
    TriggerUtility.isTaskTriggerRunning = true;
    
    TaskTriggerHandler handler = new TaskTriggerHandler (true);
    
    // Before Insert
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
    }

    // Before Update
    /*
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.new, Trigger.oldMap);
    }
    
    // Before Delete 
    else if(Trigger.isDelete && Trigger.isBefore){
        handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
    }
    
    // After Update 
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
    }
    
    // After Insert 
    else if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new);
    }
    
    // After Delete 
    else if(Trigger.isDelete && Trigger.isAfter){
        handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
    }
    
    // After Undelete 
    //else if(Trigger.isUnDelete){
    //    handler.OnUndelete(Trigger.new);
    //}

	*/

    TriggerUtility.isEventTriggerRunning = false;
    
}