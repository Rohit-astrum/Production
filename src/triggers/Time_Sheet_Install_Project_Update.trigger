// DEPRECATED: This file can be deleted
// Steve Zilligen: This trigger has been commented out and refactored into the TimeSheetTrigger/TimeSheetTriggerHandler classes
trigger Time_Sheet_Install_Project_Update on Time_Sheet__c (after insert, after update, after delete) {
    if (Trigger.isInsert || Trigger.isUpdate) {
        Time_Sheet_Trigger_Utility.computeHoursAndPay(trigger.newMap, null);       // Added new Parameter by RJ for Zen - 84 bug Fix  
    }
    else if(Trigger.isDelete){
        Time_Sheet_Trigger_Utility.computeHoursAndPay(trigger.oldMap, null);      
    }
}