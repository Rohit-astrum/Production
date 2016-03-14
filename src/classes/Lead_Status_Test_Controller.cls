public with sharing class Lead_Status_Test_Controller {

	public Lead_Status_Test_Controller(ApexPages.StandardController controller) {
		
	}
	
	public void sendEarlyStageEmail() {
		Lead_Status_Utility.sendEmailForEarlyStageLeads();
	}

	public void sendMediumStageEmail() {
		Lead_Status_Utility.sendEmailForMediumStageLeads();
	}

	public void sendLateStageEmail() {
		Lead_Status_Utility.sendEmailForLateStageLeads();
	}

}