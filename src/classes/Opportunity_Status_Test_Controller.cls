public with sharing class Opportunity_Status_Test_Controller {

	public Opportunity_Status_Test_Controller(ApexPages.StandardController controller) {
		
	}
	
	public void sendEarlyStageEmail() {
		Opportunity_Status_Utility.sendEmailForEarlyStageOpportunities();
	}

	public void sendMediumStageEmail() {
		Opportunity_Status_Utility.sendEmailForMediumStageOpportunities();
	}

	public void sendLateStageEmail() {
		Opportunity_Status_Utility.sendEmailForLateStageOpportunities();
	}
	
}