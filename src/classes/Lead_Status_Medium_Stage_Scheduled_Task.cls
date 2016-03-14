global class Lead_Status_Medium_Stage_Scheduled_Task  implements Schedulable {

	global void execute(SchedulableContext context) {

		Pipeline_Status_Settings__c settings = Pipeline_Status_Settings__c.getOrgDefaults();
		
		if (settings.lead_medium_stage_emails_enabled__c) {
			Lead_Status_Utility.sendEmailForMediumStageLeads();
		}
	}

}