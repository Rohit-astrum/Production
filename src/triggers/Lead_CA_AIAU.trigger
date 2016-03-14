//TCM 09/11/2012 - only make async callout if not running test
trigger Lead_CA_AIAU on Lead (after insert, after update) {
	//don't perform updates if bypass is on	
	if (TriggerUtility.bypassLeadTriggersForBatchProcessing) { return; }
	 
	if (!Test.isRunningTest()) {
    	QAS_NA.CAAddressCorrection.ExecuteCAAsyncForTriggerConfigurationsOnly(trigger.new);
	} 
}