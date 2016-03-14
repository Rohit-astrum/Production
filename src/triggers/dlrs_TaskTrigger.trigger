/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)test
 **/
trigger dlrs_TaskTrigger on Task
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
	if(TriggerUtility.skipDlrsTriggers){
		return;
	}
    dlrs.RollupService.triggerHandler();
}