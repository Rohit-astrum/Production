/* FILE: CBPanelTrigger.trigger
 * AUTHOR: Mike Katulka
 * DATE: 2014-08-28
 * PURPOSE: Common trigger for CB Panel
 * MODIFICATION HISTORY: 
 *
 */
trigger CBPanelTrigger on CB_Panel__c (before insert, before update, after insert, after update) {
    if(CBPanelTriggerHandler.isCBPanelTriggerRunning || CBPanelTriggerHandler.skipCBPanelTrigger) return;
    CBPanelTriggerHandler.isCBPanelTriggerRunning = true;
    
	CBPanelTriggerHandler handler = new CBPanelTriggerHandler (true);
	
	//***This was created originally for syncing utility service values into the SD, but was not needed
	//since it's a master detail to the Utility Service and can't be reparented.
	//

    // Before Insert
    //if(Trigger.isInsert && Trigger.isBefore){
    //    handler.OnBeforeInsert(Trigger.new);
    //}   
	// Before Update
    //else if(Trigger.isUpdate && Trigger.isBefore){
    //    handler.OnBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap);
    //}
    // After Insert 
    //if(Trigger.isInsert && Trigger.isAfter){
    //    handler.OnAfterInsert(Trigger.new, Trigger.newMap);
    //}   
    // After Update 
    //else if(Trigger.isUpdate && Trigger.isAfter){
    //    handler.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap); 
    //}     

    CBPanelTriggerHandler.isCBPanelTriggerRunning = false;
}