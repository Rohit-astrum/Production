trigger Leads_CA_BIBU on Lead (before insert,before update) {
	//don't perform updates if bypass is on	
	if (TriggerUtility.bypassLeadTriggersForBatchProcessing) { return; }
    QAS_NA.RecordStatusSetter.InvokeRecordStatusSetterConstrained(trigger.new,trigger.old,trigger.IsInsert,2);
}