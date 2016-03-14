public class PortalReferralImportExtension {

	public Boolean valid { get; private set; }
	
	private Account partner;
	
	public PortalReferralImportExtension(ApexPages.StandardController controller) {
		partner = (Account)controller.getRecord();
	}
	
	public PageReference checkValid() {

		valid = true;
				
		Account a = [SELECT Id, IsCustomerPortal, Portal_Payment_Plan__c FROM Account WHERE Id = :partner.Id];
		
		if (a.IsCustomerPortal != true) {
			partner.addError('This account is not enabled for the Partner Portal.');
			valid = false;
		}
		
		if (a.Portal_Payment_Plan__c == null) {
			partner.addError('There is no Portal Payment Plan associated with this account.');
			valid = false;
		}
		
		return null;
	}
	
	public List<Lead> getLeads() {
		
		return [SELECT Id, Name, Lead_Date__c 
				FROM Lead
				WHERE Referring_Account__c = :partner.Id
				AND IsConverted <> true
				AND Id NOT IN
					(SELECT Lead__c 
						FROM Portal_Referral__c 
						WHERE Lead__r.Referring_Account__c = :partner.Id 
						AND Lead__r.IsConverted <> true)];
					//(SELECT Lead__c
					//FROM Portal_Referral__c)];
		
	}
	
	public List<Opportunity> getOpportunities() {
		
		return [SELECT Id, Name, CloseDate, StageName, AccountId
				FROM Opportunity
				WHERE Referring_Account__c = :partner.Id
				AND Id NOT IN
				(SELECT Opportunity__c					 
					FROM Portal_Referral__c
					WHERE Opportunity__r.Referring_Account__c = :partner.Id)];
				//(SELECT Opportunity__c
				//FROM Portal_Referral__c)];
	}
	
	public PageReference doImport() {
		try {
			importOpportunities();
			importLeads();
		} catch (Exception e) {
			partner.addError(e);
		}
		return null;
	}
	
	private void importOpportunities() {

		Map<Id, Lead> oppLeadMap = new Map<Id, Lead>();
		Map<Id, Event> salesEventMap = new Map<Id, Event>();
		List<Portal_Referral__c> referralsToCreate = new List<Portal_Referral__c>();
		List<Portal_Referral__c> soldReferrals = new List<Portal_Referral__c>();
		
		List<Opportunity> opportunitiesToImport = 
			[SELECT Id, Name, CreatedDate, StageName, On_Hold_Until__c, Date_Site_Survey_Completed__c, 
				CloseDate, Closed_Reason__c, Closed_Type__c,
				(SELECT Id, EndDateTime 
				FROM Events
				WHERE RecordType.DeveloperName LIKE 'Sales_Visit%' 
				AND Completed__c = true
				ORDER BY EndDateTime
				LIMIT 1)
			FROM Opportunity
			WHERE Referring_Account__c = :partner.Id
			AND Id NOT IN
				(SELECT Opportunity__c					 
					FROM Portal_Referral__c
					WHERE Opportunity__r.Referring_Account__c = :partner.Id)];
				//(SELECT Opportunity__c
				//FROM Portal_Referral__c)];
				
		if (opportunitiesToImport.isEmpty()) {
			return;
		}
				
		Account referringAccount = 
			[SELECT Id, Portal_Payment_Plan__c, IsCustomerPortal
				FROM Account
				WHERE Id = :partner.Id];

		for (Opportunity opp : opportunitiesToImport) {
			if (opp.Events.size() > 0) {
				salesEventMap.put(opp.Id, opp.Events[0]);
			}
		}
	
	
		//get leads related to updated opportunities
		List<Lead> relatedLeads = 
			[SELECT Id, FirstName, LastName, Email, Phone, CreatedDate,
				Street, City, State, PostalCode, ConvertedOpportunityId
			FROM Lead
			WHERE ConvertedOpportunityId IN :opportunitiesToImport];
			
		for (Lead l : relatedLeads) {
			oppleadMap.put(l.ConvertedOpportunityId, l);
		}
	
		for (Opportunity opp : opportunitiesToImport) {
			
			Portal_Referral__c referral = new Portal_Referral__c (
				Account__c = referringAccount.Id,
				Opportunity__c = opp.Id,
				Last_Status_Change_Date__c = System.today(),
				Portal_Payment_Plan__c = referringAccount.Portal_Payment_Plan__c
			);
			
			Lead l = oppLeadMap.get(opp.Id);
			if (l != null) {
				referral.First_Name__c = l.FirstName;
				referral.Last_Name__c = l.LastName;
				referral.Email__c = l.Email;
				referral.Phone__c = l.Phone;
				referral.Street__c = l.Street;
				referral.City__c = l.City;
				referral.State__c = l.State;
				referral.Zip__c = l.PostalCode;
				referral.Lead_Created_Date__c = l.CreatedDate.date();
			}
			
			if (PortalReferralStatus.setReferralStatus(null, opp, salesEventMap.get(opp.Id), referral)) {
				if (referral.Status__c == PortalReferralStatus.SOLD_STATUS) {
					soldReferrals.add(referral);
				} else {
					referralsToCreate.add(referral);
				}
			}
			
		}

		if (!soldReferrals.isEmpty()) {
			PortalReferralStatus.processSoldEarnings(soldReferrals);
			insert soldReferrals;
		}
	
		if (!referralsToCreate.isEmpty()) {
			PortalReferralStatus.processUnsoldEarnings(referralsToCreate);	
			insert referralsToCreate;
		}	
		
	}
	
	private void importLeads() {
		
		List<Lead> leadsToImport = 	
			[SELECT Id, Status, On_Hold_Until__c, Unqualified_Reason__c, ConvertedOpportunityId, 
				FirstName, LastName, Email, Phone, Street, City, State, PostalCode, CreatedDate
			FROM Lead
			WHERE Referring_Account__c = :partner.Id
			AND IsConverted <> true
			AND Id NOT IN
				(SELECT Lead__c 
					FROM Portal_Referral__c 
					WHERE Lead__r.Referring_Account__c = :partner.Id 
					AND Lead__r.IsConverted <> true)];
				//(SELECT Lead__c
				//FROM Portal_Referral__c)];
				
		if (leadsToImport.isEmpty()) {
			return;
		}
				
		Account referringAccount = 
			[SELECT Id, Portal_Payment_Plan__c, IsCustomerPortal
				FROM Account
				WHERE Id = :partner.Id];
	
		List<Portal_Referral__c> referralsToCreate = new List<Portal_Referral__c>();

	
		for (Lead l : leadsToImport) {

			Portal_Referral__c referral = new Portal_Referral__c (
				Lead__c = l.Id,
				First_Name__c = l.FirstName,
				Last_Name__c = l.LastName,
				Email__c = l.Email,
				Phone__c = l.Phone,
				Account__c = referringAccount.Id,
				Street__c = l.Street,
				City__c = l.City,
				State__c = l.State,
				Zip__c = l.PostalCode,
				Opportunity__c = l.ConvertedOpportunityId,
				Last_Status_Change_Date__c = System.today(),
				Portal_Payment_Plan__c = referringAccount.Portal_Payment_Plan__c,
				Lead_Created_Date__c = l.CreatedDate.date()
			);
				
			if (PortalReferralStatus.setReferralStatus(l, null, null, referral)) {
				referralsToCreate.add(referral);
			} 
		}
		
		if (!referralsToCreate.isEmpty()) {
			PortalReferralStatus.processUnsoldEarnings(referralsToCreate);	
			insert referralsToCreate;
		}
	}
	
}