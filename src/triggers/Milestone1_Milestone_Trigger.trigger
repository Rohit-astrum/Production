trigger Milestone1_Milestone_Trigger on Milestone1_Milestone__c (before insert, before update, before delete,
                                 after insert, after update, after delete) {
  
	System.debug('Milestone1_Milestone_Trigger:  TriggerUtility.taskTriggerHasNotRun_Before = ' + TriggerUtility.taskTriggerHasNotRun_Before);
	System.debug('Milestone1_Milestone_Trigger:  TriggerUtility.taskTriggerHasNotRun_After = ' + TriggerUtility.taskTriggerHasNotRun_After);
	System.debug('Milestone1_Milestone_Trigger:  TriggerUtility.milestoneTriggerHasNotRun = ' + TriggerUtility.milestoneTriggerHasNotRun);
  
    if(TriggerUtility.isMilestoneUpdate == null || TriggerUtility.isMilestoneUpdate == false) {
			
		    if(Trigger.isbefore){
		      if(Trigger.isDelete){
		        Milestone1_Milestone_Trigger_Utility.handleMilestoneDeleteTrigger(trigger.oldMap);
		      } 
		      else if(Trigger.isUpdate){
				//prevent manual reparenting of Milestones
				Milestone1_Milestone_Trigger_Utility.checkMilestoneManualReparent(trigger.oldMap, trigger.newMap);

				/*				            
				if (TriggerUtility.milestoneTriggerHasNotRun) {								
					TriggerUtility.milestoneTriggerHasNotRun = false;
				    Milestone1_Milestone_Trigger_Utility.changeTaskOwnerShip(trigger.oldMap, trigger.newMap);    
				} 
				*/
		      }
		      else {
		        //insert
		        Milestone1_Milestone_Trigger_Utility.handleMilestoneBeforeTrigger(trigger.new, trigger.newMap);
		      }
		    } 
		    else {
		      if(Trigger.isDelete){
		        Milestone1_Milestone_Trigger_Utility.handleMilestoneAfterTrigger(trigger.oldMap);
		      } 
		      else {
		        Milestone1_Milestone_Trigger_Utility.handleMilestoneAfterTrigger(trigger.newMap);

				if (Trigger.isUpdate && TriggerUtility.milestoneTriggerHasNotRun) {								
					TriggerUtility.milestoneTriggerHasNotRun = false;
				    Milestone1_Milestone_Trigger_Utility.changeTaskOwnerShip(trigger.oldMap, trigger.newMap);    
				} 

		      }
		    }
    }  
}