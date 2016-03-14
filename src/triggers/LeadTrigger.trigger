trigger LeadTrigger on Lead (before insert, before update, before delete, after insert, after update, after delete) {
    if(LeadTriggerHandler.isLeadTriggerRunning || LeadTriggerHandler.skipLeadTrigger) return;
    LeadTriggerHandler.isLeadTriggerRunning = true;
    
    LeadTriggerHandler handler = new LeadTriggerHandler (true);
    
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

    LeadTriggerHandler.isLeadTriggerRunning = false;
        
}