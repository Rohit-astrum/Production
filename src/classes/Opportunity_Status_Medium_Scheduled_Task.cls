global class Opportunity_Status_Medium_Scheduled_Task implements Schedulable {

	global void execute(SchedulableContext context) {

		Pipeline_Status_Settings__c settings = Pipeline_Status_Settings__c.getOrgDefaults();
		
		if (settings.opportunity_medium_stage_emails_enabled__c) {
			Opportunity_Status_Utility.sendEmailForMediumStageOpportunities();
		}
	
	}
}