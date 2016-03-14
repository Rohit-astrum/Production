global class D2D_InitialLeadPortalReferralBatch implements Database.Batchable<sObject>, Database.Stateful {
	
	global final String query;
	global List<Portal_Referral__c> toInsert;

	global final Set<String> affiliateCommunityPrograms;
	global final Map<String, Id> cityToManager;
	global final Set<String> cities;
	
	global D2D_InitialLeadPortalReferralBatch(String queryToRun, Map<String, Id> citiesToManagers) {
		affiliateCommunityPrograms = new Set<String>();
        List<Schema.PicklistEntry> ple = Lead.Affiliate_Community_Program__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry f : ple)
        {
        	if(f.getValue().contains('D2D')){
	            affiliateCommunityPrograms.add(f.getValue());
        	}
        }

		cityToManager = citiesToManagers;

		cities = cityToManager.keySet();

		query = queryToRun;

		toInsert = new List<Portal_Referral__c>();
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		toInsert = new List<Portal_Referral__c>();
		for(Lead lead : (List<Lead>)scope){
			toInsert.add(new Portal_Referral__c(
				Lead__c = lead.Id, D2D_System_Size__c = lead.D2D_System_Size__c, D2D_Lead_Status__c = 'Prospect New', Last_Name__c = lead.LastName, First_Name__c = lead.FirstName,
				Street__c = lead.Street, City__c = lead.City, State__c = lead.State, Zip__c = lead.PostalCode, Lead_Created_Date__c = Date.today(),
				D2D_Manager__c = cityToManager.get(lead.City.toLowerCase())
			));
		}
		insert toInsert;
	}
	
	global void finish(Database.BatchableContext BC) { }
}