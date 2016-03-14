/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_c2godaInvoiceTrigger on c2g__codaInvoice__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
	if(TriggerUtility.skipDlrsTriggers){
		return;
	}
    dlrs.RollupService.triggerHandler();
}