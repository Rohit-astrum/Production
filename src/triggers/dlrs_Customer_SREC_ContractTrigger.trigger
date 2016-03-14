/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_Customer_SREC_ContractTrigger on Customer_SREC_Contract__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
	if(TriggerUtility.skipDlrsTriggers){
		return;
	}
    dlrs.RollupService.triggerHandler();
}