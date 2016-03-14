global class D2D_InitialOppPortalReferralBatch implements Database.Batchable<sObject>, Database.Stateful {
	
	global final String query;
	global final Set<Id> oppIds;
	global final List<Lead> leads;
	global final Map<Id, Lead> oppIdToLead;
	global final Map<Id, Id> oppIdToManagerId;
	global final Map<Id, Id> oppIdToRepId;
	
	global List<Portal_Referral__c> toInsert;

	global D2D_InitialOppPortalReferralBatch(Map<Id, Id> passedManagerMap, Map<Id, Id> passedRepMap) {
        oppIdToManagerId = passedManagerMap;
        oppIdToRepId = passedRepMap;

		leads = [SELECT Id, ConvertedOpportunityId, D2D_System_Size__c, LastName, FirstName, Street, City, State, PostalCode FROM Lead WHERE ConvertedOpportunityId IN :oppIdToManagerId.keySet()];
		oppIdToLead = new Map<Id, Lead>();
		for(Lead lead : leads){
			oppIdToLead.put(lead.ConvertedOpportunityId, lead);
		}

		oppIds = oppIdToManagerId.keySet();
		query = 'SELECT Id, WhatId, StartDateTime FROM Event WHERE WhatId IN :oppIds';

		toInsert = new List<Portal_Referral__c>();
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		for(Event e : (List<Event>)scope){
			toInsert.add(new Portal_Referral__c(
				Opportunity__c = e.WhatId, D2D_Scheduled_Visit_Datetime__c = e.StartDateTime, D2D_System_Size__c = oppIdToLead.get(e.WhatId).D2D_System_Size__c, 
				D2D_Lead_Status__c = 'Prospect New', Last_Name__c = oppIdToLead.get(e.WhatId).LastName, First_Name__c = oppIdToLead.get(e.WhatId).FirstName, Lead_Created_Date__c = Date.today(),
				Street__c = oppIdToLead.get(e.WhatId).Street, City__c = oppIdToLead.get(e.WhatId).City, State__c = oppIdToLead.get(e.WhatId).State, Zip__c = oppIdToLead.get(e.WhatId).PostalCode, 
				D2D_Manager__c = oppIdToManagerId.get(e.WhatId), D2D_Sales_Rep__c = oppIdToRepId.get(e.WhatId)
			));
		}
		insert toInsert;
	}
	
	global void finish(Database.BatchableContext BC) { }
}


/*
Opportunity ID	Rep	Vendor Mgr	Account Name	Owner Name	Start Date/Time	Action for IT	Assigned to	Closer 
0061A000011TNPB	Keenan L	Jesse W	NUNO, HECTOR	Janine Fields	11/04/2015 15:30	To be transferred	Janine Fields	Dragan Spasoski 
0061A000011TAmU	Chris W	Jesse W	BLAKELY, DARLENE	Daisy Chan	11/07/2015 12:00	To be transferred	Daisy Chan	Jesse W
0061A000011TMs7	Robert H	Jesse W	SANTOS ZAMORA	Janine Fields	11/9/2015 9:30 AM	To be transferred	Janine Fields	Jesse W
0061A000011SrTo	Darwin Y	Jesse W	FORSTER, SUSAN	Justin Coghill	11/09/2015 18:30	Leave for now	Justin Coghill	TBD 
0061A000011SCDH	Chris W	Jesse W	JOULAIN, IVAN	Justin Coghill	11/10/2015 21:30	Leave for now	Justin Coghill	TBD
0061A000011TbAi	Linda T	Jesse W	BLOOMGREN, DONALD	James Williams	11/11/2015 12:00	To be transferred	James Williams	Linda Tipton
0061A000011SCQ1	Linda T	Jesse W	SARUWATARI, KEN	Justin Coghill	11/11/2015 18:30	Leave for now	Justin Coghill	TBD
0061A000011SrSF	Robert H	Jesse W	SAVOLSKIS, AMY	Justin Coghill	11/11/2015 21:30	Leave for now	Justin Coghill	TBD
0061A000011TNIF	Linda T	Jesse W	ANDERSON, ROBERT	Janine Fields	11/14/2015 12:30 PM	To be transferred	Janine Fields	Linda Tipton
0061A000011TAvW	Linda T	Jesse W	SPARKS, JERRY	Lucas Brown	11/14/2015 2:30 PM	To be transferred	Lucas Brown	Linda Tipton
*/