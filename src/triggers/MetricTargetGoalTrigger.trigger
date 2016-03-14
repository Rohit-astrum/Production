/* FILE: MetricTargetGoalTrigger.trigger
   AUTHOR: Steve Zilligen
   DATE: 2015-06-04
   PURPOSE: Common trigger for Metric Target Goal
*/
trigger MetricTargetGoalTrigger on Metric_Target_Goal__c (before insert, before update, before delete, after insert, after update, after delete) {
    MetricTargetGoalTriggerHandler handler = new MetricTargetGoalTriggerHandler(true);

    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            handler.OnBeforeInsert(Trigger.new);
        } else if(Trigger.isUpdate) {
            handler.OnBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap);
        //} else if(Trigger.isDelete){
            // not used
        }
    } else if (Trigger.isAfter) {
        if(Trigger.isInsert) {
            // not used
        } else if(Trigger.isUpdate) {
            // not used
        //} else if(Trigger.isDelete){
            // not used
        }
    }
}