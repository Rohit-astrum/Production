/* FILE: InstallLocationTrigger.trigger
 * AUTHOR: Rohit Jain
 * DATE: Apr 24, 2014
 * PURPOSE: Install Location Trigger
 * MODIFICATION HISTORY
 *           MK - 2014-04-30 - enabled After Delete, see InstallLocationHandler
 *
 */
trigger InstallLocationTrigger on Install_Location__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

    if(TriggerUtility.bypassInstallLocationTriggersForBatchProcessing) return;
    
	InstallLocationTriggerHandler handler = new InstallLocationTriggerHandler (true);

    /* Before Insert */
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
    }
    // After Update 
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.new);
    }
    
    // After Insert 
    //else if(Trigger.isInsert && Trigger.isAfter){
        //handler.OnAfterInsert(Trigger.new);
    //}
    //Before Update
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.new);
    }
    /*
    // Before Delete 
    else if(Trigger.isDelete && Trigger.isBefore){
        handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
    }
    */
    // After Delete 
    else if(Trigger.isDelete && Trigger.isAfter){
        handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
    }
    /*
    // After Undelete 
    else if(Trigger.isUnDelete){
        handler.OnUndelete(Trigger.new);
    }
    */

}