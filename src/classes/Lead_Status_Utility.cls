global class Lead_Status_Utility {

	public static final Long MS_IN_HOUR = 60 * 60 * 1000L;
	public static final Integer EARLY_STAGE_LEAD_IDLE_TIME_IN_HOURS = 4;

	public static final Integer MEDIUM_STAGE_IDLE_BUSINESS_HOURS = 24;
	public static final Integer MEDIUM_STAGE_CONTACTS = 3;
	
	public static final Integer LATE_STAGE_IDLE_BUSINESS_HOURS = 40;
	public static final Integer LATE_STAGE_CONTACTS = 4;
	
	public static final String OPEN_NEW_STATUS = 'Open – New';
	public static final String CONTACT_BY_US_STATUS = 'Contacted by Us';
	public static final String CONTACT_US_BACK_STATUS = 'Contacted Us Back';
	public static final String QUALIFIED_STATUS = 'Qualified';
	public static final String ON_HOLD_STATUS = 'On Hold';
	public static final String UNQUALIFIED_STATUS = 'Unqualified';
	public static final String UNRESPONSIVE_STATUS = 'Unresponsive';
	public static final String MARKETING_INFLUENCER_STATUS = 'Marketing – Influencer';
	public static final String LOST_COMPETITION_STATUS = 'Lost – Competition';
		
	private static final String DATE_FORMAT = 'M/dd/yyyy h:mm a zz';
	private static final String TIME_ZONE = 'America/New_York';
	
	public static void sendEmailForEarlyStageLeads() {

		Pipeline_Status_Settings__c settings = Pipeline_Status_Settings__c.getOrgDefaults();
		Boolean testMode = settings.test_mode_enabled__c;

		Server_Info__c serverInfo = [select Server_URL__c from Server_Info__c limit 1];

		User me = [Select email from user where id = :UserInfo.getUserId() limit 1];
				
		Map<User, List<Lead>> leadsEmailMap = getEarlyStageLeads();

		Set<User> users = leadsEmailMap.keySet();
		
		for (User salesRep : users) {

			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			
			if (!testMode) {
				mail.setToAddresses(new String[] {salesRep.Email});
				mail.setCcAddresses(new String[] {salesRep.manager.email});				
			}
			else {
				mail.setToAddresses(new String[] { me.Email });
			}
											
			mail.setSubject('Leads Not Contacted Within 4 Business Hours');

			List<Lead> salesRepLeads = leadsEmailMap.get(salesRep);

			String plainTextContent = getPlainTextContentForEarlyStageLeads(salesRep, salesRepLeads, serverInfo);
			String htmlContent = getHtmlContentForEarlyStageLeads(salesRep, salesRepLeads, serverInfo);
				
			mail.setPlainTextBody(plainTextContent);
			mail.setHtmlBody(htmlContent);
			
			if (!Test.isRunningTest())
				Messaging.sendEmail(new Messaging.Singleemailmessage[] { mail });	
			
			//if (testMode) {
			//	// only send one email
			//	break;
			//}			
		}
		
	}

	public static void sendEmailForMediumStageLeads() {

		Pipeline_Status_Settings__c settings = Pipeline_Status_Settings__c.getOrgDefaults();
		Boolean testMode = settings.test_mode_enabled__c;

		Server_Info__c serverInfo = [select Server_URL__c from Server_Info__c limit 1];

		User me = [Select email from user where id = :UserInfo.getUserId() limit 1];
				
		Map<User, List<Lead>> leadsEmailMap = getMediumStageLeads();

		Set<User> users = leadsEmailMap.keySet();
		
		for (User salesRep : users) {

			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			
			if (!testMode) {
				mail.setToAddresses(new String[] {salesRep.Email});
				mail.setCcAddresses(new String[] {salesRep.manager.email});
			}
			else {
				mail.setToAddresses(new String[] { me.Email });
			}	
					
			mail.setSubject('Leads Not Contacted Within 3 Business Days');

			List<Lead> salesRepLeads = leadsEmailMap.get(salesRep);

			String plainTextContent = getPlainTextContentForMediumStageLeads(salesRep, salesRepLeads, serverInfo);
			String htmlContent = getHtmlContentForMediumStageLeads(salesRep, salesRepLeads, serverInfo);
				
			mail.setPlainTextBody(plainTextContent);
			mail.setHtmlBody(htmlContent);
			
			if (!Test.isRunningTest())
				Messaging.sendEmail(new Messaging.Singleemailmessage[] { mail });	
			
			//if (testMode) {
			//	// only send one email
			//	break;
			//}			
		}
	}
	
	public static void sendEmailForLateStageLeads() {

		Pipeline_Status_Settings__c settings = Pipeline_Status_Settings__c.getOrgDefaults();
		Boolean testMode = settings.test_mode_enabled__c;

		Server_Info__c serverInfo = [select Server_URL__c from Server_Info__c limit 1];

		User me = [Select email from user where id = :UserInfo.getUserId() limit 1];
				
		Map<User, List<Lead>> leadsEmailMap = getLateStageLeads();

		Set<User> users = leadsEmailMap.keySet();
		
		for (User salesRep : users) {

			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

			if (!testMode) {
				mail.setToAddresses(new String[] {salesRep.Email});
				mail.setCcAddresses(new String[] {salesRep.manager.email});
			}
			else {
				mail.setToAddresses(new String[] { me.Email });
			}	
			
			mail.setSubject('Leads Not Contacted Within First Business Week');

			List<Lead> salesRepLeads = leadsEmailMap.get(salesRep);

			String plainTextContent = getPlainTextContentForLateStageLeads(salesRep, salesRepLeads, serverInfo);
			String htmlContent = getHtmlContentForLateStageLeads(salesRep, salesRepLeads, serverInfo);
				
			mail.setPlainTextBody(plainTextContent);
			mail.setHtmlBody(htmlContent);
			
			if (!Test.isRunningTest())
				Messaging.sendEmail(new Messaging.Singleemailmessage[] { mail });	
			
			//if (testMode) {
			//	// only send one email
			//	break;
			//}			
		}
	}

	private static String[] getEmailAddresses(User theUser) {
		String[] emails = new List<String>();
		
		emails.add(theUser.email);
		
		if (theUser.manager != null) {
			emails.add(theUser.manager.email);	
		}
		
		return emails;	
	}
	
	public static String getHtmlContentForEarlyStageLeads(User salesRep, List<Lead> salesRepLeads, Server_Info__c serverInfo) {
		String content = '';
		
		content += 'Hi ' + salesRep.FirstName + ',<br><br>';
		content += 'Please follow up on the following leads. AstrumCRM shows that you have not contacted these leads within 4 business hours.<br><br>';

		content += 	getHtmlContentForLeads(salesRepLeads, serverInfo);
			
		return content;	
	}

	public static String getHtmlContentForMediumStageLeads(User salesRep, List<Lead> salesRepLeads, Server_Info__c serverInfo) {
		String content = '';
		
		content += 'Hi ' + salesRep.FirstName + ',<br><br>';
		content += 'Please follow up on the following leads. AstrumCRM shows that you have not contacted these leads at least 3 times within the first 3 business days.<br><br>';

		content += 	getHtmlContentForLeads(salesRepLeads, serverInfo);
			
		return content;	
	}

	public static String getHtmlContentForLateStageLeads(User salesRep, List<Lead> salesRepLeads, Server_Info__c serverInfo) {
		String content = '';
		
		content += 'Hi ' + salesRep.FirstName + ',<br><br>';
		content += 'Please follow up on the following leads. AstrumCRM shows that you have not contacted these leads at least 4 times within the first 5 business days.<br><br>';

		content += 	getHtmlContentForLeads(salesRepLeads, serverInfo);
			
		return content;	
	}

	private static String getHtmlContentForLeads(List<Lead> salesRepLeads, Server_Info__c serverInfo) {
		String content = '';

		Integer row = 1;
		content += '<table border=1 cellpadding=5 width=725>';
		content += '<tr>';
		content += '<th>#</th>';
		content += '<th>Full Name</th>';
		content += '<th>Address</th>';		
		content += '<th>County</th>';		
		content += '<th>Last Contacted</th>';
		content += '</tr>';

		for (Lead tempLead : salesRepLeads) {				
			content += '<tr>';
			
			content += '<td>' + row + '</td>';
			content += '<td>' + createLink(serverInfo, tempLead.id, tempLead.LastName + ', ' + tempLead.FirstName) + '</td>';

			String address = String_Utils.getDefaultStringWithComma(tempLead.Street) + String_Utils.getDefaultStringWithComma(tempLead.City) + String_Utils.getDefaultString(tempLead.State);
			content += '<td>' + createLink(serverInfo, tempLead.id, address) + '</td>';

			content += '<td>' + createLink(serverInfo, tempLead.id, tempLead.County__c) + '</td>';
			
			String text = null;
			
			if (tempLead.LastActivityDate != null) {
				text = createLink(serverInfo, tempLead.id, formatDate(tempLead.LastActivityDate));
			}
			else {
				text = '-';
			}
			
			content += '<td>' + text + '</td>';			
			content += '</tr>';
			row++;
		}		
		
		content += '</table>';
			
		return content;		
	}	
	
	private static String createLink(Server_Info__c serverInfo, Id theId, String text) {
		String link = '<a href="' + serverInfo.Server_URL__c + theId + '">' + text + '</a>';
		
		return link;	
	}
	
	public static String getPlainTextContentForEarlyStageLeads(User salesRep, List<Lead> salesRepLeads, Server_Info__c serverInfo) {
		String content = '';
		
		content += 'Hi ' + salesRep.FirstName + ',\n\n';
		content += 'Please follow up on the following leads. AstrumCRM shows that you have not contacted these leads within 4 business hours.\n\n';

		content += 	getPlainTextContentForLeads(salesRepLeads, serverInfo);
			
		return content;	
	}

	public static String getPlainTextContentForMediumStageLeads(User salesRep, List<Lead> salesRepLeads, Server_Info__c serverInfo) {
		String content = '';
		
		content += 'Hi ' + salesRep.FirstName + ',\n\n';
		content += 'Please follow up on the following leads. AstrumCRM shows that you have not contacted these leads at least 3 times within the first 3 business days.\n\n';

		content += 	getPlainTextContentForLeads(salesRepLeads, serverInfo);
			
		return content;	
	}

	public static String getPlainTextContentForLateStageLeads(User salesRep, List<Lead> salesRepLeads, Server_Info__c serverInfo) {
		String content = '';
		
		content += 'Hi ' + salesRep.FirstName + ',\n\n';
		content += 'Please follow up on the following leads. AstrumCRM shows that you have not contacted these leads at least 4 times within the first 5 business days.\n\n';

		content += 	getPlainTextContentForLeads(salesRepLeads, serverInfo);
			
		return content;	
	}

	private static String getPlainTextContentForLeads(List<Lead> salesRepLeads, Server_Info__c serverInfo) {
		String content = '';

		Integer row = 1;
		for (Lead tempLead : salesRepLeads) {
			
			String text = null;
			if (tempLead.LastActivityDate != null) {
				text = formatDate(tempLead.LastActivityDate);
			}
			else {
				text = '-';
			}

			String address = String_Utils.getDefaultStringWithComma(tempLead.Street) + String_Utils.getDefaultStringWithComma(tempLead.City) + String_Utils.getDefaultString(tempLead.State);
			
			content += row + ':  ' + tempLead.LastName + ', ' + tempLead.FirstName + ', ' + address + ', Last contacted: ' + text + ',  Link: ' + serverInfo.Server_URL__c + tempLead.id + '\n';
			row++;
		}
			
		return content;		
	}	

	
	private static String formatDate(Datetime theDate) {
		
		String result;
		
		if (theDate != null) {
			result = theDate.format(DATE_FORMAT, TIME_ZONE);			
		}
		else {
			result = '-';
		}
		
		return result;
	}


	public static List<Lead> getAllLeadsForUser(Id theOwnerId) {
		List<Lead> allLeads = [SELECT FirstName, LastName, Owner.FirstName, Owner.LastName, OwnerId, LastActivityDate, Lead_Created_Date__c, CreatedDate, Street, City, State, County__c, Status
				 FROM Lead
				 WHERE IsConverted = false
				 AND OwnerId = :theOwnerId
				 ORDER BY LastActivityDate asc];

		return allLeads;		
	}

	public static List<Lead> getOpenNewLeadsToContact(Id theOwnerId) {
		List<Lead> allLeads = [SELECT FirstName, LastName, Owner.FirstName, Owner.LastName, OwnerId, LastActivityDate, Lead_Created_Date__c, CreatedDate, Street, City, State, County__c, Status					
				 FROM Lead
				 WHERE IsConverted = false
				 AND Status = :OPEN_NEW_STATUS
				 AND OwnerId = :theOwnerId
				 AND LastActivityDate = null];

		return allLeads;		
	}

	public static List<Lead> getOpenNewLeadsToContact() {
		List<Lead> allLeads = [SELECT FirstName, LastName, Owner.FirstName, Owner.LastName, OwnerId, LastActivityDate, Lead_Created_Date__c, CreatedDate, Street, City, State, County__c, Status					
				 FROM Lead
				 WHERE IsConverted = false
				 AND Status = :OPEN_NEW_STATUS
				 AND LastActivityDate = null];

		return allLeads;		
	}

	
	public static List<Lead> getAllLeadsMultipleActivities(String theStatus) {
		List<Lead> allLeads = new List<Lead>();
		if(!Test.isRunningTest()){
			allLeads = [SELECT FirstName, LastName, Owner.FirstName, Owner.LastName, OwnerId, LastActivityDate, Lead_Created_Date__c, CreatedDate, Street, City, State, County__c, Status,
						(SELECT Subject, CreatedDate from ActivityHistories order by CreatedDate desc limit 5) 
					 FROM Lead
					 WHERE IsConverted = false
					 AND Status = :theStatus
					 ORDER BY LastActivityDate asc];
		} else {
			allLeads = [SELECT FirstName, LastName, Owner.FirstName, Owner.LastName, OwnerId, LastActivityDate, Lead_Created_Date__c, CreatedDate, Street, City, State, County__c, Status,
						(SELECT Subject, CreatedDate from ActivityHistories order by CreatedDate desc limit 5) 
					 FROM Lead
					 WHERE IsConverted = false
					 AND Status = :theStatus
					 ORDER BY LastActivityDate asc
					 LIMIT 100];
		}

		return allLeads;		
	}

	public static List<Lead> getAllLeadsMultipleActivities(String theStatus, Id theOwnerId) {
		List<Lead> allLeads = [SELECT FirstName, LastName, Owner.FirstName, Owner.LastName, OwnerId, LastActivityDate, Lead_Created_Date__c, CreatedDate, Street, City, State, County__c, Status,
					(SELECT Subject, CreatedDate from ActivityHistories order by CreatedDate desc limit 5) 
				 FROM Lead
				 WHERE IsConverted = false
				 AND Status = :theStatus
				 AND OwnerId = :theOwnerId
				 ORDER BY LastActivityDate asc];

		return allLeads;		
	}

	public static List<Lead_Status_Holder> getAllLeadsForUser() {
		List<Lead> allLeads = getAllLeadsForUser(UserInfo.getUserId());
		
		List<Lead_Status_Holder> holders = convert(allLeads);
		
		return holders;
	}

	public static List<Lead_Status_Holder> getEarlyStageLeadsToContact() {
		List<Lead> leadsToContact = getOpenNewLeadsToContact(UserInfo.getUserId());
		
		List<Lead_Status_Holder> holders = convert(leadsToContact);
		
		return holders;
	}
	
	public static List<Lead_Status_Holder> getMediumStageLeadsToContact() {
		BusinessHours theBusinessHours = [select id from BusinessHours where IsDefault=true limit 1];

		List<Lead> allLeads = getAllLeadsMultipleActivities(CONTACT_BY_US_STATUS, UserInfo.getUserId());
		
		List<Lead> leadsToContact = getLeadsToContact(allLeads, theBusinessHours, MEDIUM_STAGE_IDLE_BUSINESS_HOURS, MEDIUM_STAGE_CONTACTS);		
		
		List<Lead_Status_Holder> holders = convert(leadsToContact);
		
		return holders;
	}

	public static List<Lead_Status_Holder> getLateStageLeadsToContact() {
		BusinessHours theBusinessHours = [select id from BusinessHours where IsDefault=true limit 1];

		List<Lead> allLeads = getAllLeadsMultipleActivities(CONTACT_BY_US_STATUS, UserInfo.getUserId());
		
		List<Lead> leadsToContact = getLeadsToContact(allLeads, theBusinessHours, LATE_STAGE_IDLE_BUSINESS_HOURS, LATE_STAGE_CONTACTS);		
		
		List<Lead_Status_Holder> holders = convert(leadsToContact);
		
		return holders;
	}

	private static List<Lead_Status_Holder> convert(List<Lead> leads) {
		List<Lead_Status_Holder> holders = new List<Lead_Status_Holder>();
		
		Integer index = 1;
		for (Lead tempLead : leads) {

			String lastActivityDateTimeText = null;
			if (tempLead.LastActivityDate != null) {
				lastActivityDateTimeText = formatDate(tempLead.LastActivityDate);
			}
			else {
				lastActivityDateTimeText = '-';
			}
			
			String createdDateTimeText = formatDate(tempLead.createdDate);
			
			Lead_Status_Holder tempHolder = new Lead_Status_Holder(index, tempLead, lastActivityDateTimeText, createdDateTimeText);
			
			holders.add(tempHolder);
			
			index++;	
		}
		
		return holders;
		
	}
	
	public static Map<User, List<Lead>> getEarlyStageLeads() {
		List<Lead> leadsToContact = getOpenNewLeadsToContact();
		
		Set<Id> leadOwnerIds = getLeadOwnerIds(leadsToContact);
		Map<Id, User> leadUsers = getLeadUsers(leadOwnerIds);
		
		Map<User, List<Lead>> leadsEmailMap = getLeadsEmailMap(leadUsers, leadsToContact);
		
		return leadsEmailMap;
	}

	public static Map<User, List<Lead>> getMediumStageLeads() {
		BusinessHours theBusinessHours = [select id from BusinessHours where IsDefault=true limit 1];

		List<Lead> allLeads = getAllLeadsMultipleActivities(CONTACT_BY_US_STATUS);
		
		List<Lead> leadsToContact = getLeadsToContact(allLeads, theBusinessHours, MEDIUM_STAGE_IDLE_BUSINESS_HOURS, MEDIUM_STAGE_CONTACTS);		
		
		Set<Id> leadOwnerIds = getLeadOwnerIds(leadsToContact);
		Map<Id, User> leadUsers = getLeadUsers(leadOwnerIds);
		
		Map<User, List<Lead>> leadsEmailMap = getLeadsEmailMap(leadUsers, leadsToContact);
			
		return leadsEmailMap;
	}

	public static Map<User, List<Lead>> getLateStageLeads() {
		BusinessHours theBusinessHours = [select id from BusinessHours where IsDefault=true limit 1];

		List<Lead> allLeads = getAllLeadsMultipleActivities(CONTACT_BY_US_STATUS);
		
		List<Lead> leadsToContact = getLeadsToContact(allLeads, theBusinessHours, LATE_STAGE_IDLE_BUSINESS_HOURS, LATE_STAGE_CONTACTS);		
		
		Set<Id> leadOwnerIds = getLeadOwnerIds(leadsToContact);
		Map<Id, User> leadUsers = getLeadUsers(leadOwnerIds);
		
		Map<User, List<Lead>> leadsEmailMap = getLeadsEmailMap(leadUsers, leadsToContact);
			
		return leadsEmailMap;
	}
	
	public static Map<User, List<Lead>> getLeadsEmailMap(Map<Id, User> leadUsers, List<Lead> leadsToContact) {
		
		Map<User, List<Lead>> theMap = new Map<User, List<Lead>>();

		for (Lead currentLead : leadsToContact) {
			Id ownerId = currentLead.OwnerId;
			User theUser = leadUsers.get(ownerId);
			
			// exclude the user 'Web Queue Lead', this user comes up as null
			if (theUser == null) {
				continue;
			}
			
			List<Lead> tempLeads = null;
			
			if (theMap.containsKey(theUser)) {
				tempLeads = theMap.get(theUser);	
			}
			else {
				tempLeads = new List<Lead>();
				theMap.put(theUser, tempLeads);
			}
			
			tempLeads.add(currentLead);
		}
		
		return theMap;
	}
	
	public static Map<Id, User> getLeadUsers(Set<Id> ownerIds) {
		Map<Id, User> users = new Map<Id, User>([Select Id, LastName, FirstName, Email, Manager.Email From User where id in :ownerIds]);
		
		return users;
	}
	

	public static List<Lead> getLeadsToContact(List<Lead> leads, BusinessHours theBusinessHours, Integer idleTimeInHours, Integer numOfContacts) {
		List<Lead> leadsToContact = new List<Lead>();
		
		// loop thru each lead check if we have the number of contacts
		for (Lead tempLead : leads) {
			SObject[] data = tempLead.getSObjects('ActivityHistories');			

			if (data == null || data.size() < numOfContacts) {
				leadsToContact.add(tempLead);					
			} 

		}
		
		return leadsToContact;
	}
	
	public static Set<Id> getLeadOwnerIds(List<Lead> leads) {
		Set<Id> ownerIds = new Set<Id>();
		
		for (Lead tempLead : leads) {
			ownerIds.add(tempLead.ownerId);
		}
		
		return ownerIds;
	}
	
	private static List<ActivityHistory> convert(SObject[] data) {

		List<ActivityHistory> histories = new List<ActivityHistory>();
		
		if (data != null) {
			for (SObject tempSobj : data) {
				ActivityHistory temp = (ActivityHistory) tempSobj;
				histories.add(temp);					
			}
		}
		
		return histories;
	}
	
}