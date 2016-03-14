/* FILE: TimeSheetEntryTrigger.trigger
   AUTHOR: Steve Zilligen
   DATE: 2015-03-26
   PURPOSE: Common trigger for Time Sheet Entry
*/
trigger TimeSheetEntryTrigger on Time_Sheet_Entry__c (before insert, before update, before delete, after insert, after update, after delete) {
    TimeSheetEntryTriggerHandler handler = new TimeSheetEntryTriggerHandler(true);

	if(Trigger.isBefore) {
		if(Trigger.isInsert) {
			handler.OnBeforeInsert(Trigger.new);
		} else if(Trigger.isUpdate) {
			handler.OnBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap);
		} else if(Trigger.isDelete){
			handler.OnBeforeDelete(Trigger.oldMap);
		}
	} else if (Trigger.isAfter) {
		if(Trigger.isInsert) {
			// not used
		} else if(Trigger.isUpdate) {
			handler.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap);
		} else if(Trigger.isDelete){
			// not used
		}
	}
}