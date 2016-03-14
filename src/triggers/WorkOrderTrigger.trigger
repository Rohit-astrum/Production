/* FILE: WorkOrderTrigger.trigger
 * AUTHOR: Lawrence Hovind
 * DATE: June 11, 2014
 * PURPOSE: Work Order Trigger
 * MODIFICATION HISTORY
 *
 */
trigger WorkOrderTrigger on rstk__wocst__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

    WorkOrderTriggerHandler handler = new WorkOrderTriggerHandler (true);

    /* Before Insert */
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
    }
    /*
    // After Update 
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
    }
    */
    // After Insert 
    else if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new);
    }
    /*
    // Before Update
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
    }
    */
    /*
    // Before Delete 
    else if(Trigger.isDelete && Trigger.isBefore){
        handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
    }
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