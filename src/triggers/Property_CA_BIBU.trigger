trigger Property_CA_BIBU on Property__c (before insert,before update) {
QAS_NA.RecordStatusSetter.InvokeRecordStatusSetterConstrained(trigger.new,trigger.old,trigger.IsInsert,2);
}