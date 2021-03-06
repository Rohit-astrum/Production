/* FILE: PhysicalSurfaceTrigger.trigger
 * AUTHOR: Rohit Jain
 * DATE: Apr 24, 2014
 * PURPOSE: Physical Surface Trigger
 * MODIFICATION HISTORY
 *
 */
trigger PhysicalSurfaceTrigger on Physical_Surface__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    if(TriggerUtility.bypassPhysicalSurfaceTriggersForBatchProcessing) return;
    
    PhysicalSurfaceTriggerHandler handler = new PhysicalSurfaceTriggerHandler (true);

    /* Before Insert */
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
    }
    // After Update 
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.new);
    }
    /*
    // After Insert 
    else if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new);
    }
    // Before Update
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
    }
    
    // Before Delete 
    else if(Trigger.isDelete && Trigger.isBefore){
        handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
    }
    */
    // After Delete 
    else if(Trigger.isDelete && Trigger.isAfter){
        handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
    }
    
    // After Undelete 
    //else if(Trigger.isUnDelete){
    //    handler.OnUndelete(Trigger.new);
    //}
    
}