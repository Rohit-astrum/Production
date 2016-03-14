/* FILE: TimeSheetTrigger.trigger
   AUTHOR: Steve Zilligen
   DATE: 2015-03-26
   PURPOSE: Common trigger for Time Sheet
*/
trigger TimeSheetTrigger on Time_Sheet__c (before insert, before update, before delete, after insert, after update, after delete) {
    TimeSheetTriggerHandler handler = new TimeSheetTriggerHandler(true);

	if(Trigger.isBefore) {
		if(Trigger.isInsert) {
			// not used
		} else if(Trigger.isUpdate) {
			// not used
		} else if(Trigger.isDelete){
			handler.OnBeforeDelete(Trigger.oldMap);
		}
	} else if (Trigger.isAfter) {
		if(Trigger.isInsert) {
			handler.OnAfterInsert(Trigger.new, Trigger.newMap);
		} else if(Trigger.isUpdate) {
			handler.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap);
		} else if(Trigger.isDelete){
			handler.OnAfterDelete(Trigger.oldMap);
		}
	}
}