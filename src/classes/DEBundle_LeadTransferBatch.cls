global class DEBundle_LeadTransferBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
	
	global final String query;
	global final DER_Bundle_Settings__c deSettings;
	global String accessToken;

	global Integer totalRecords;
	global Map<Id, String> successfulTransfersMap;
	global Map<Id, String> transfersWithoutAttachmentsMap;
	global Map<Id, String> failedTransfersMap;

	Map<Id, DEBundle_Utility.LeadResponse> leadResponsesBySOId;
	Map<Id, DEBundle_Utility.AttachmentResponse> attResponsesBySOId;
	Map<Id, Exception> exceptionLeads;

	global final Map<String, String> stateNamesByCode;

	global List<CampaignMember> campaignMembers;
	
	global DEBundle_LeadTransferBatch() {
		query = 'SELECT Id, Inspection__c, Sales_Order__c, Sales_Order__r.OpportunityId__c, Sales_Order__r.System_Design_Quote__c, Sales_Order__r.Closed_Scenario__c ' +
				'FROM PM_Project__c ' +
				'WHERE Inspection__c <> null and Inspection_Verified__c >= LAST_N_DAYS:7';
		deSettings = DER_Bundle_Settings__c.getOrgDefaults();

		leadResponsesBySOId = new Map<Id, DEBundle_Utility.LeadResponse>();
		attResponsesBySOId = new Map<Id, DEBundle_Utility.AttachmentResponse>();
		exceptionLeads = new Map<Id, Exception>();

		successfulTransfersMap = new Map<Id, String>();
		transfersWithoutAttachmentsMap = new Map<Id, String>();
		failedTransfersMap = new Map<Id, String>();
		campaignMembers = new List<CampaignMember>();

		stateNamesByCode = GetStateNamesByCode();
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		Database.QueryLocator locator = Database.getQueryLocator(query);
		if(!locator.iterator().hasNext()){
			DEBundle_Utility.LogErrorMessage('No records to process.', 0, 0, 0, 0);
		}
		return locator;
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		if(scope.size() > 0){
			accessToken = GetAccessToken();
			if(accessToken == ''){
				DEBundle_Utility.LogErrorMessage('Could not acquire the access token.', 0, 0, 0, 0);
				return;
			}
			system.debug('**SZ: accessToken = ' + accessToken);
	   		ProcessBatch(scope);
   		}
   	}
	
	global void finish(Database.BatchableContext BC) {
		String message = '';
		if(successfulTransfersMap.keySet().size() > 0){
			message += 'Successful Transfers:\r\n';
			for(Id soId : successfulTransfersMap.keySet()){
				message += 'Sales Order: ' + soId + ' - ' + successfulTransfersMap.get(soId) + '\r\n';
			}
			message += '\r\n';
		}
		if(transfersWithoutAttachmentsMap.keySet().size() > 0){
			message += 'Transfers Without Attachments:\r\n';
			for(Id soId : transfersWithoutAttachmentsMap.keySet()){
				message += 'Sales Order: ' + soId + ' - ' + transfersWithoutAttachmentsMap.get(soId) + '\r\n';
			}
			message += '\r\n';
		}
		if(failedTransfersMap.keySet().size() > 0){
			message += 'Failed Transfers:\r\n';
			for(Id soId : failedTransfersMap.keySet()){
				message += 'Sales Order: ' + soId + ' - ' + failedTransfersMap.get(soId) + '\r\n';
			}
		}
		system.debug('**SZ: message = ' + message);
		if(message != ''){
			if(campaignMembers.size() > 0){
				Set<Id> contactIds = new Set<Id>();
				for(CampaignMember cm : campaignMembers){
					contactIds.add(cm.ContactId);
				}
				List<CampaignMember> existingMembers = [SELECT Id, ContactId FROM CampaignMember WHERE CampaignId = :deSettings.DES_Solar_Advantage_Outbound_Campaign_Id__c AND ContactId IN :contactIds];

				Set<Id> existingContactIds = new Set<Id>();
				for(CampaignMember cm : existingMembers){
					existingContactIds.add(cm.ContactId);
				}

				List<CampaignMember> membersToInsert = new List<CampaignMember>();
				for(CampaignMember cm : campaignMembers){
					if(!existingContactIds.contains(cm.ContactId)){
						membersToInsert.add(cm);
					}
				}
				upsert membersToInsert;
			}
			DEBundle_Utility.LogErrorMessage(message, totalRecords, successfulTransfersMap.keySet().size(), transfersWithoutAttachmentsMap.keySet().size(), failedTransfersMap.keySet().size());
		}
	}

   	private void ProcessBatch(List<sObject> scope){
   		Map<Id, PM_Project__c> pmProjectSalesOrders = new Map<Id, PM_Project__c>();
		Map<Id, PM_Project__c> pmProjectSDQuotes = new Map<Id, PM_Project__c>();

		for(PM_Project__c project : (List<PM_Project__c>)scope){
			pmProjectSalesOrders.put(project.Sales_Order__c, project);
			pmProjectSDQuotes.put(project.Sales_Order__r.System_Design_Quote__c, project);
		}

		List<Price_Adjustment__c> priceAdjustments = [SELECT Id, System_Design_Quote__c, DE_Outbound_Referral_Offer__c, Applicable_Scenario__c
														FROM Price_Adjustment__c
														WHERE System_Design_Quote__c IN :pmProjectSDQuotes.keySet() AND Adjustment_Applied__c = true AND DE_Outbound_Referral_Offer__c = :deSettings.DES_Solar_Advantage_Outbound_Campaign_Id__c.left(15)];
		Set<Id> priceAdjustmentSDQuotes = new Set<Id>();
		for(Price_Adjustment__c pa : priceAdjustments){
			if(pmProjectSDQuotes.containsKey(pa.System_Design_Quote__c) && pa.Applicable_Scenario__c == pmProjectSDQuotes.get(pa.System_Design_Quote__c).Sales_Order__r.Closed_Scenario__c){
				priceAdjustmentSDQuotes.add(pa.System_Design_Quote__c);
			}
		}

		Map<Id, SCRB_SalesOrder__c> salesOrders = new Map<Id, SCRB_SalesOrder__c>([SELECT Id, OpportunityId__c, OpportunityId__r.AccountId FROM SCRB_SalesOrder__c WHERE System_Design_Quote__c IN :priceAdjustmentSDQuotes]);
		totalRecords = salesOrders.size();

		Map<Id, SCRB_SalesOrder__c> salesOrderOpps = new Map<Id, SCRB_SalesOrder__c>();
		for(SCRB_SalesOrder__c so : salesOrders.values()){
			salesOrderOpps.put(so.OpportunityId__c, so);
		}

		List<OpportunityContactRole> oppContactRoles = [SELECT Id, ContactId, OpportunityId, IsPrimary FROM OpportunityContactRole WHERE IsPrimary = true AND OpportunityId IN :salesOrderOpps.keySet()];
		Map<Id, Id> contactIds = new Map<Id, Id>();
		for(OpportunityContactRole ocr : oppContactRoles){
			contactIds.put(ocr.ContactId, ocr.OpportunityId);
		}
		List<Contact> contacts = [SELECT Id, First_Name_Email_Mail__c, LastName, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Phone, Email, DoNotCall FROM Contact WHERE Id IN :contactIds.keySet()];

		Map<Id, Contact> oppPrimaryContact = new Map<Id, Contact>();
		for(Contact c : contacts){
			oppPrimaryContact.put(contactIds.get(c.Id), c);
		}

		List<Attachment> attachments = [SELECT Id, ParentId, Name, Body FROM Attachment WHERE ParentId IN :salesOrders.keySet() AND Name = 'DER Solar Advantage Plan.pdf'];
		Map<Id, Attachment> salesOrderAttachments = new Map<Id, Attachment>();
		for(Attachment a : attachments){
			salesOrderAttachments.put(a.ParentId, a);
		}

		List<Lead> newLeads = new List<Lead>();
		for(SCRB_SalesOrder__c so : salesOrders.values()){
			Contact primaryContact = oppPrimaryContact.get(so.OpportunityId__c);
			Map<String, String> leadParamsMap = new Map<String, String>();
			leadParamsMap.put('Status', 'NEW');
			leadParamsMap.put('FirstName', primaryContact.First_Name_Email_Mail__c);
			leadParamsMap.put('LastName', primaryContact.LastName);
			leadParamsMap.put('Street', primaryContact.MailingStreet);
			leadParamsMap.put('City', primaryContact.MailingCity);

			leadParamsMap.put('State', stateNamesByCode.get(primaryContact.MailingState));
			leadParamsMap.put('PostalCode', primaryContact.MailingPostalCode);
			leadParamsMap.put('Country', 'United States');
			leadParamsMap.put('Phone', primaryContact.Phone);
			leadParamsMap.put('Email', primaryContact.Email);
			leadParamsMap.put('Related_Campaign__c', deSettings.DER_Solar_Advantage_Campaign_Id__c);
			leadParamsMap.put('Company', primaryContact.LastName + ', ' + primaryContact.First_Name_Email_Mail__c);
			//,Date_of_Inspection__c = pmProjectSalesOrders.get(so.Id).Inspection__c
			String leadParameters = JSON.serialize(leadParamsMap);
			system.debug('**SZ: leadParameters = ' + leadParameters);

			SendLead(so.Id, leadParameters);

			if(exceptionLeads.containsKey(so.Id)){
				Exception ex = exceptionLeads.get(so.Id);
				failedTransfersMap.put(so.Id, ex.getMessage() + ' -|- ' + ex.getStackTraceString());
				continue;
			} else {
				DEBundle_Utility.LeadResponse lr = leadResponsesBySOId.get(so.Id);
				if(lr.success == null || !lr.success || String.isNotBlank(lr.errorCode)){
					String errorMessage = '';
					if(lr.errors != null && lr.errors.size() > 0){
						errorMessage += String.join(lr.errors, ',');
						errorMessage += ' -|- ';
					}
					if(String.isNotBlank(lr.message)){
						errorMessage += lr.errorCode + ':' + lr.message;
						if(lr.fields != null){
							errorMessage += ' - ' + String.join(lr.fields, ',');
						}
						errorMessage += ' -|- ';
					}
					failedTransfersMap.put(so.Id, errorMessage);
					continue;
				}

				String newLeadId = '';
				if(lr.success && String.isNotBlank(lr.id)){
					newLeadId = lr.id;
				} else {
					failedTransfersMap.put(so.Id, 'Sales Order: ' + so.Id + ' was not successful or did not return a DE new lead id.');
					continue;
				}

				if(salesOrderAttachments.containsKey(so.Id)){
					Attachment att = salesOrderAttachments.get(so.Id);
					String attParameters = '{"ParentId":"' + newLeadId + '","Name":"' + att.Name + '","ContentType":"application/pdf","Body":"' + EncodingUtil.base64Encode(att.Body) + '"}';

					SendAttachment(so.Id, attParameters);

					if(exceptionLeads.containsKey(so.Id)){
						Exception ex = exceptionLeads.get(so.Id);
						transfersWithoutAttachmentsMap.put(so.Id, ex.getMessage() + ' -|- ' + ex.getStackTraceString());
						campaignMembers.add(CreateCampaignMember(primaryContact.Id));
						continue;
					} else {
						DEBundle_Utility.AttachmentResponse ar = attResponsesBySOId.get(so.Id);
						if(ar.success == null || !ar.success){
							String errorMessage = '';
							if(ar.errors != null && ar.errors.size() > 0){
								errorMessage += String.join(ar.errors, ',');
								errorMessage += ' -|- ';
							}
							transfersWithoutAttachmentsMap.put(so.Id, errorMessage);
							campaignMembers.add(CreateCampaignMember(primaryContact.Id));
							continue;
						}

						if(ar.success && String.isNotBlank(ar.id)){
							system.debug('**SZ: made it to success.');
							successfulTransfersMap.put(so.Id, 'Sales Order: ' + so.Id + ' successfully transfered lead and attachment to DE.');
							campaignMembers.add(CreateCampaignMember(primaryContact.Id));
						} else {
							transfersWithoutAttachmentsMap.put(so.Id, 'Sales Order: ' + so.Id + ' was not successful or did not return a DE new attachment id.');
							campaignMembers.add(CreateCampaignMember(primaryContact.Id));
							continue;
						}
					}
				} else {
					transfersWithoutAttachmentsMap.put(so.Id, 'Sales Order: ' + so.Id + ' had no attachment for DE new lead id: ' + newLeadId);
					campaignMembers.add(CreateCampaignMember(primaryContact.Id));
					continue;
				}
			}
		}
	}


	private CampaignMember CreateCampaignMember(Id primaryContactId){
		CampaignMember cm = new CampaignMember(
			CampaignId = deSettings.DES_Solar_Advantage_Outbound_Campaign_Id__c,
			ContactId = primaryContactId/*,
			CompanyOrAccount = acctId,
			Email = primaryContact.Email,
			FirstName = primaryContact.FirstName,
			LastName = primaryContact.LastName,
			Phone = primaryContact.Phone,
			State = primaryContact.MailingState,
			Street = primaryContact.MailingStreet,
			PostalCode = primaryContact.MailingPostalCode,
			DoNotCall = primaryContact.DoNotCall*/
		);
		return cm;
	}

	private Map<String, String> GetStateNamesByCode(){
		Map<String, String> states = new Map<String, String>{
			'AL' => 'Alabama',
			'AK' => 'Alaska',
			'AZ' => 'Arizona',
			'AR' => 'Arkansas',
			'CA' => 'California',
			'CO' => 'Colorado',
			'CT' => 'Connecticut',
			'DE' => 'Delaware',
			'FL' => 'Florida',
			'GA' => 'Georgia',
			'HI' => 'Hawaii',
			'ID' => 'Idaho',
			'IL' => 'Illinois',
			'IN' => 'Indiana',
			'IA' => 'Iowa',
			'KS' => 'Kansas',
			'KY' => 'Kentucky',
			'LA' => 'Louisiana',
			'ME' => 'Maine',
			'MD' => 'Maryland',
			'MA' => 'Massachusetts',
			'MI' => 'Michigan',
			'MN' => 'Minnesota',
			'MS' => 'Mississippi',
			'MO' => 'Missouri',
			'MT' => 'Montana',
			'NE' => 'Nebraska',
			'NV' => 'Nevada',
			'NH' => 'New Hampshire',
			'NJ' => 'New Jersey',
			'NM' => 'New Mexico',
			'NY' => 'New York',
			'NC' => 'North Carolina',
			'ND' => 'North Dakota',
			'OH' => 'Ohio',
			'OK' => 'Oklahoma',
			'OR' => 'Oregon',
			'PA' => 'Pennsylvania',
			'RI' => 'Rhode Island',
			'SC' => 'South Carolina',
			'SD' => 'South Dakota',
			'TN' => 'Tennessee',
			'TX' => 'Texas',
			'UT' => 'Utah',
			'VT' => 'Vermont',
			'VA' => 'Virginia',
			'WA' => 'Washington',
			'WV' => 'West Virginia',
			'WI' => 'Wisconsin',
			'WY' => 'Wyoming'
		};
		return states;
	}


	/********************/
	/***** CALLOUTS *****/
	/********************/
	private String GetAccessToken(){
		try{
			String tokenParameters = 'grant_type=password' +
	            '&client_id=' + deSettings.DER_Consumer_Key__c + // '3MVG9eYfd1zvW1E7_pP5RGVEM.iok5P0_T2SQoki2R7ZmqjtPJiJMVOvIAfNFN1Kw01hf3R4jyt3FBQXX3NRS' +
	            '&client_secret=' + deSettings.DER_Consumer_Secret__c + // '9198011436944835997' +
	            '&username=' + EncodingUtil.urlEncode(deSettings.DER_Salesforce_Username__c, 'UTF-8') + // EncodingUtil.urlEncode('szilligen@directenergysolar.com', 'UTF-8') +
	            '&password=' + EncodingUtil.urlEncode(deSettings.DER_Salesforce_Password__c, 'UTF-8'); // EncodingUtil.urlEncode('M!ch!g@n34AloY97GRj7Y29ZIaKm7dNr1MQ', 'UTF-8');

			HttpRequest request = DEBundle_Utility.prepareRequest(deSettings.DER_API_URL__c + 'oauth2/token', tokenParameters);
			HttpResponse response = DEBundle_Utility.sendRequest(request);

			DEBundle_Utility.TokenResponse tokenResponse = DEBundle_Utility.parseTokenResponse(response);
			if(response.getStatusCode() == 200){
				return tokenResponse.access_token;
			} else {
				DEBundle_Utility.LogErrorMessage(tokenResponse, 0, 0, 0, 0);
			}
		} catch(Exception ex){
            system.debug('**SZ: ex = ' + ex.getMessage() + '-|-' + ex.getStackTraceString());
			DEBundle_Utility.LogErrorMessage(ex, 0, 0, 0, 0);
		}
		return '';
	}

	private void SendLead(Id soId, String leadJson){
		try{
			system.debug('**SZ: accessToken = ' + accessToken);
			HttpRequest request = DEBundle_Utility.prepareRequest(deSettings.DER_API_URL__c + 'data/v20.0/sobjects/Lead/', leadJson);
			request.setHeader('Authorization', 'Bearer ' + accessToken);
			request.setHeader('Content-Type', 'application/json');

			HttpResponse response = DEBundle_Utility.sendRequest(request);

			DEBundle_Utility.LeadResponse leadResponse = DEBundle_Utility.parseLeadResponse(response);
			system.debug('**SZ: leadResponse = ' + leadResponse);
			leadResponse.statusCode = response.getStatusCode();
			leadResponsesBySOId.put(soId, leadResponse);
		} catch(Exception ex){
            system.debug('**SZ: ex = ' + ex.getMessage() + '-|-' + ex.getStackTraceString());
			//DEBundle_Utility.LogErrorMessage(ex, totalRecords, successfulTransfersMap.keySet().size(), transfersWithoutAttachmentsMap.keySet().size(), failedTransfersMap.keySet().size());
			exceptionLeads.put(soId, ex);
		}
	}

	private void SendAttachment(Id soId, String attachmentJson){
		try{
			HttpRequest request = DEBundle_Utility.prepareRequest(deSettings.DER_API_URL__c + 'data/v20.0/sobjects/Attachment/', attachmentJson);
			request.setHeader('Authorization', 'Bearer ' + accessToken);
			request.setHeader('Content-Type', 'application/json');

			HttpResponse response = DEBundle_Utility.sendRequest(request);
system.debug('**SZ: responseBody = ' + response.getBody());
			DEBundle_Utility.AttachmentResponse attResponse = DEBundle_Utility.parseAttachmentResponse(response);
			system.debug('**SZ: attResponse = ' + attResponse);
			attResponse.statusCode = response.getStatusCode();
			attResponsesBySOId.put(soId, attResponse);
		} catch(Exception ex){
            system.debug('**SZ: ex = ' + ex.getMessage() + '-|-' + ex.getStackTraceString());
			//DEBundle_Utility.LogErrorMessage(ex, totalRecords, successfulTransfersMap.keySet().size(), transfersWithoutAttachmentsMap.keySet().size(), failedTransfersMap.keySet().size());
			exceptionLeads.put(soId, ex);
		}
	}
}