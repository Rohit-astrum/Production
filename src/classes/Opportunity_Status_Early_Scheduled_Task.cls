global class Opportunity_Status_Early_Scheduled_Task implements Schedulable {

	global void execute(SchedulableContext context) {

		Pipeline_Status_Settings__c settings = Pipeline_Status_Settings__c.getOrgDefaults();
		
		if (settings.opportunity_early_stage_emails_enabled__c) {
			Opportunity_Status_Utility.sendEmailForEarlyStageOpportunities();
		}
	}

}