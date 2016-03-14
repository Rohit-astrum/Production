trigger Contracts_CA_BIBU on Contract(before insert,before update) {
    QAS_NA.RecordStatusSetter.InvokeRecordStatusSetterConstrained(trigger.new,trigger.old,trigger.IsInsert,2);
}