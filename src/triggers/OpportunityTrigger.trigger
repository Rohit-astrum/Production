//TCM 08/23/2012 - prevent 
trigger OpportunityTrigger on Opportunity (after insert, after update, before insert, before update) {
	
	//don't perform updates if property opportunity trigger is updating the opportunity or bypass is on
	if (SalesRegionHelper.propertyOpportunityTriggerFiring) return;

	//MK - 2014-08-25 - prevent recursive firing of triggers, saves unecessary processing
	if(Opportunity_Trigger_Utility.isOpportunityTriggerRunning || Opportunity_Trigger_Utility.skipOpportunityTrigger) return;
	Opportunity_Trigger_Utility.isOpportunityTriggerRunning = true;
	
	Opportunity_Trigger_Utility otu = new Opportunity_Trigger_Utility();
	
	if(Trigger.isBefore){
		if(Trigger.isInsert){
			//has new 
			otu.handleBeforeInsertTrigger(Trigger.new);
		}
		if(Trigger.isUpdate){
			//has new, newMap, old, oldMap
			otu.handleBeforeUpdateTrigger(Trigger.oldMap, Trigger.newMap);
		}		
	}
	if(Trigger.isAfter){
		if(Trigger.isInsert){
			//has new, newMap
			otu.handleAfterInsertTrigger(Trigger.newMap);
		}
		if(Trigger.isUpdate){
			//has new, newMap, old, oldMap
			otu.handleAfterUpdateTrigger(Trigger.newMap);
			otu.handleAfterUpdateTriggerForTasks(Trigger.oldMap, Trigger.newMap);
		}				
	}

	//MK - 2014-08-25 - prevent recursive firing of triggers, saves unecessary processing
	Opportunity_Trigger_Utility.isOpportunityTriggerRunning = false;
}


/*


new    --> Returns a list of the new versions of the sObject records.
Note that this sObject list is only available in insert and update triggers, and the records
can only be modified in before triggers.

newMap --> A map of IDs to the new versions of the sObject records.
Note that this map is only available in before update, after insert, and after
update triggers.

old --> Returns a list of the old versions of the sObject records.
Note that this sObject list is only available in update and delete triggers.

oldMap --> A map of IDs to the old versions of the sObject records.
Note that this map is only available in update and delete triggers

*/