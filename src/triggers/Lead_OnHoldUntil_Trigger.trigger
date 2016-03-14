trigger Lead_OnHoldUntil_Trigger on Lead (before update) {
	//don't perform updates if bypass is on	
	if (TriggerUtility.bypassLeadTriggersForBatchProcessing) { return; }
	
	Task_Utility.processStatusForOnHold(trigger.oldMap, trigger.newMap);

}