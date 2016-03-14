global class Opportunity_Status_Utility {

	public static final Long MS_IN_HOUR = 60 * 60 * 1000L;

	public static final Integer HOURS_IN_BUSINESS_DAY = 8;
	
	public static final Integer EARLY_STAGE_IDLE_DAYS = 1;
	public static final Integer EARLY_STAGE_IDLE_BUSINESS_HOURS = EARLY_STAGE_IDLE_DAYS * HOURS_IN_BUSINESS_DAY;
	public static final Integer EARLY_STAGE_CONTACTS = 1;

	public static final Integer MEDIUM_STAGE_IDLE_DAYS = 5;
	public static final Integer MEDIUM_STAGE_IDLE_BUSINESS_HOURS = MEDIUM_STAGE_IDLE_DAYS * HOURS_IN_BUSINESS_DAY;
	public static final Integer MEDIUM_STAGE_CONTACTS = 2;
	
	public static final Integer LATE_STAGE_IDLE_DAYS = 10;
	public static final Integer LATE_STAGE_IDLE_BUSINESS_HOURS = LATE_STAGE_IDLE_DAYS * HOURS_IN_BUSINESS_DAY;
	public static final Integer LATE_STAGE_CONTACTS = 3;
	
	public static final String ASSIGNED_TO_FIELD_SALES = 'Assigned to Field Sales';
	public static final String SALES_VISIT_SCHEDULED = 'Sales Visit Scheduled';
	public static final String SALES_PROCESS_ONGOING = 'Sales Process Ongoing';
	public static final String CLOSED_WON = 'Closed - Won';
	public static final String CONTRACT_CANCELLED = 'Contract Cancelled';
	public static final String CLOSED_LOST = 'Closed - Lost';
	public static final String UNQUALIFIED_SITE_QUALITY = 'Unqualified - Site Quality';
	public static final String UNRESPONSIVE = 'Unresponsive';
	public static final String ON_HOLD = 'On Hold';
	public static final String QUALIFIED = 'Qualified';
	
	private static final String DATE_FORMAT = 'M/dd/yyyy h:mm a zz';
	private static final String TIME_ZONE = 'America/New_York';
	
	public static final String SITE_SURVEY_REMOTE_RECORD_TYPE = 'Site Survey Remote';
	public static final String SITE_SURVEY_ONSITE_RECORD_TYPE = 'Site Survey Onsite';

	public static final String SALES_VISIT_REMOTE_RECORD_TYPE = 'Sales Visit Remote';
	public static final String SALES_VISIT_ONSITE_RECORD_TYPE = 'Sales Visit Onsite';
	
	public static void sendEmailForEarlyStageOpportunities() {

		sendEmailForOpportunities(EARLY_STAGE_IDLE_DAYS, EARLY_STAGE_IDLE_BUSINESS_HOURS, EARLY_STAGE_CONTACTS);
	}

	public static void sendEmailForMediumStageOpportunities() {

		sendEmailForOpportunities(MEDIUM_STAGE_IDLE_DAYS, MEDIUM_STAGE_IDLE_BUSINESS_HOURS, MEDIUM_STAGE_CONTACTS);
	}

	public static void sendEmailForLateStageOpportunities() {

		sendEmailForOpportunities(LATE_STAGE_IDLE_DAYS, LATE_STAGE_IDLE_BUSINESS_HOURS, LATE_STAGE_CONTACTS);
	}

	public static List<Opportunity_Status_Holder> getEarlyStageOpportunitiesToContact() {
		List<Opportunity_Status_Holder> oppStatusHolders = getOpportunitiesToContact(EARLY_STAGE_IDLE_BUSINESS_HOURS, EARLY_STAGE_CONTACTS);
		
		return oppStatusHolders;
	}

	public static List<Opportunity_Status_Holder> getMediumStageOpportunitiesToContact() {
		List<Opportunity_Status_Holder> oppStatusHolders = getOpportunitiesToContact(MEDIUM_STAGE_IDLE_BUSINESS_HOURS, MEDIUM_STAGE_CONTACTS);
		
		return oppStatusHolders;
	}

	public static List<Opportunity_Status_Holder> getLateStageOpportunitiesToContact() {
		List<Opportunity_Status_Holder> oppStatusHolders = getOpportunitiesToContact(LATE_STAGE_IDLE_BUSINESS_HOURS, LATE_STAGE_CONTACTS);
		
		return oppStatusHolders;
	}

	private static Set<Id> getOppIds(List<Opportunity> opps) {
		Set<Id> ids = new Set<Id>();
		
		for (Opportunity tempOpp : opps) {
			ids.add(tempOpp.id);	
		}
		
		return ids;
	}
	
	public static List<Opportunity_Status_Holder> getOpportunitiesToContact(Integer idleBusinessTimeInHours, Integer contacts) {
		
		List<Opportunity> opps = getOpportunities(idleBusinessTimeInHours, contacts, UserInfo.getUserId());

		Set<Id> oppIds = getOppIds(opps);
		
		Map<Id, Event> siteSurveyMap = getSiteSurveyMap(oppIds);		
		Map<Id, Event> salesVisitMap = getSalesVisitMap(oppIds);
		
		// testing code
		// Map<Id, Event> siteSurveyMap = new Map<Id, Event>();		
		// Map<Id, Event> salesVisitMap = new Map<Id, Event>();
		
		List<Opportunity_Status_Holder> oppStatusHolders = convert(opps, siteSurveyMap, salesVisitMap);		
		
		return oppStatusHolders;
	}

	public static List<Opportunity_Status_Holder> getAllOpportunitiesForUser() {
		
		List<Opportunity> opps = getAllOpportunitiesForUser(UserInfo.getUserId());
		
		Set<Id> oppIds = getOppIds(opps);
		
		Map<Id, Event> siteSurveyMap = getSiteSurveyMap(oppIds);		
		Map<Id, Event> salesVisitMap = getSalesVisitMap(oppIds);
		
		// testing code
		// Map<Id, Event> siteSurveyMap = new Map<Id, Event>();		
		// Map<Id, Event> salesVisitMap = new Map<Id, Event>();
		
		List<Opportunity_Status_Holder> oppStatusHolders = convert(opps, siteSurveyMap, salesVisitMap);
		
		return oppStatusHolders;
	}

	private static Map<Id, Event> createMap(List<Event> events) {
		Map<Id, Event> theMap = new Map<Id, Event>();

		// loop thru all events and only keep the first event for each opportunity id		
		if ((events != null) && !events.isEmpty()) {
			for (Event tempEvent : events) {
				
				Id key = tempEvent.WhatId;
				if ((key != null) && !theMap.containsKey(key)) {
					theMap.put(key, tempEvent);
				}	
			}
		}
		
		return theMap;				
	}
	
	private static Map<Id, Event> getSiteSurveyMap(Set<Id> oppIds) {

		List<Event> events = [Select e.WhatId, e.ActivityDateTime, Completed__c 
							  From Event e 
							  where e.WhatId in :oppIds and (e.RecordType.Name = :SITE_SURVEY_REMOTE_RECORD_TYPE or e.RecordType.Name = :SITE_SURVEY_ONSITE_RECORD_TYPE) 
							  order by activitydatetime desc
		];		
		
		Map<Id, Event> siteSurveyMap = createMap(events);
		
		return siteSurveyMap;		
	}	

	private static Map<Id, Event> getSalesVisitMap(Set<Id> oppIds) {

		List<Event> events = [Select e.WhatId, e.ActivityDateTime, Completed__c 
							  From Event e 
							  where e.WhatId in :oppIds and (e.RecordType.Name = :SALES_VISIT_REMOTE_RECORD_TYPE or e.RecordType.Name = :SALES_VISIT_ONSITE_RECORD_TYPE) 
							  order by activitydatetime desc
		];		
		
		Map<Id, Event> salesVisitMap = createMap(events);
		
		return salesVisitMap;		
	}	
		
	private static List<Opportunity_Status_Holder> convert(List<Opportunity> opps, Map<Id, Event> siteSurveyMap, Map<Id, Event> salesVisitMap ) {
		List<Opportunity_Status_Holder> holders = new List<Opportunity_Status_Holder>();
		
		Integer index = 1;
		for (Opportunity tempOpportunity : opps) {

			String lastActivityDateTimeText = '';
			if (tempOpportunity.LastActivityDate != null) {
				DateTime lastActivityDateTime = getLastActivityDateTime(tempOpportunity);
				lastActivityDateTimeText = formatDate(lastActivityDateTime);
			}
			else {
				lastActivityDateTimeText = '-';
			}
			
			String createdDateTimeText = formatDate(tempOpportunity.createdDate);
			
			Event siteSurveyEvent = siteSurveyMap.get(tempOpportunity.id);			
			String siteSurveyActivityDateTime = '-';
			Boolean siteSurveyComplete = false;
			if (siteSurveyEvent != null) {
				siteSurveyActivityDateTime = formatDate(siteSurveyEvent.ActivityDateTime);
				siteSurveyComplete = siteSurveyEvent.Completed__c;
			}
			
			Event salesVisitEvent = salesVisitMap.get(tempOpportunity.id);
			String salesVisitActivityDateTime = '-';
			Boolean salesVisitComplete = false;
			if (salesVisitEvent != null) {
				salesVisitActivityDateTime = formatDate(salesVisitEvent.ActivityDateTime);
				salesVisitComplete = salesVisitEvent.Completed__c;
			}
			
			Opportunity_Status_Holder tempHolder = new Opportunity_Status_Holder(index, tempOpportunity, lastActivityDateTimeText, createdDateTimeText, 
																				siteSurveyActivityDateTime, siteSurveyComplete, salesVisitActivityDateTime, salesVisitComplete);
			
			holders.add(tempHolder);
			
			index++;	
		}
		
		return holders;
		
	}
	
	public static void sendEmailForOpportunities(Integer idleBusinessTimeInDays, Integer idleBusinessTimeInHours, Integer contacts) {
	
		Pipeline_Status_Settings__c settings = Pipeline_Status_Settings__c.getOrgDefaults();
		Boolean testMode = settings.test_mode_enabled__c;
				
		Server_Info__c serverInfo = [select Server_URL__c from Server_Info__c limit 1];

		User me = [Select email from user where id = :UserInfo.getUserId() limit 1];
				
		Map<User, List<Opportunity>> oppsEmailMap = getOpportunities(idleBusinessTimeInHours, contacts);

		Set<User> users = oppsEmailMap.keySet();
		
		for (User salesRep : users) {

			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			
			if (!testMode) {
				mail.setToAddresses(new String[] {salesRep.Email});
				mail.setCcAddresses(new String[] {salesRep.manager.email});
			}
			else {
				mail.setToAddresses(new String[] { me.Email });
			}
							
			String daysText = getPlural('day', idleBusinessTimeInDays);
				
			mail.setSubject('Opportunities Not Contacted Within ' + idleBusinessTimeInDays + ' Business ' + daysText);

			List<Opportunity> salesRepOpps = oppsEmailMap.get(salesRep);

			String plainTextContent = getPlainTextContentForOpportunities(salesRep, salesRepOpps, serverInfo, idleBusinessTimeInDays, contacts);
			String htmlContent = getHtmlContentForOpportunities(salesRep, salesRepOpps, serverInfo, idleBusinessTimeInDays, contacts);
				
			mail.setPlainTextBody(plainTextContent);
			mail.setHtmlBody(htmlContent);
			
			Messaging.sendEmail(new Messaging.Singleemailmessage[] { mail });	
			
			if (testMode) {
				// only send one email
				break;
			}			
		}
		
	}

	public static List<Opportunity> getOpportunities(Integer idleBusinessTimeInHours, Integer contacts, Id userId) {
		BusinessHours theBusinessHours = [select id from BusinessHours where IsDefault=true limit 1];

		List<Opportunity> allOpps = getAllOpportunitiesForUser(ASSIGNED_TO_FIELD_SALES, userId);
		
		List<Opportunity> oppsToContact = getOpportunitiesToContact(allOpps, theBusinessHours, idleBusinessTimeInHours, contacts);
		
		return oppsToContact;
	}

	public static Map<User, List<Opportunity>> getOpportunities(Integer idleBusinessTimeInHours, Integer contacts) {
		BusinessHours theBusinessHours = [select id from BusinessHours where IsDefault=true limit 1];

		List<Opportunity> allOpps = getAllOpportunities(ASSIGNED_TO_FIELD_SALES);
		
		List<Opportunity> oppsToContact = getOpportunitiesToContact(allOpps, theBusinessHours, idleBusinessTimeInHours, contacts);
		
		Set<Id> ownerIds = getOwnerIds(oppsToContact);
		Map<Id, User> oppUsers = getOpportunityUsers(ownerIds);
		
		Map<User, List<Opportunity>> oppsEmailMap = getOpportunitiesEmailMap(oppUsers, oppsToContact);
		
		return oppsEmailMap;
	}

	public static List<Opportunity> getAllOpportunitiesForUser(Id theUserId) {
				
		List<Opportunity> allOpps = [SELECT StageName, OwnerId, Owner.FirstName, Owner.LastName, Name, LastActivityDate, Id, 
											Property__r.name, Property__r.property_city__c, Property__r.property_state__c, 
											Property__r.property_county__c, CreatedDate, 
											(SELECT Subject, CreatedDate from ActivityHistories order by CreatedDate desc limit 5)  
							   				 FROM Opportunity 
							   				 WHERE OwnerId = :theUserId
							   				 ORDER BY LastActivityDate asc];

		return allOpps;		
	}

	public static List<Opportunity> getAllOpportunitiesForUser(String theStageName, Id theUserId) {
				
		List<Opportunity> allOpps = [SELECT StageName, OwnerId, Owner.FirstName, Owner.LastName, Name, LastActivityDate, Id, 
											Property__r.name, Property__r.property_city__c, Property__r.property_state__c, 
											Property__r.property_county__c, CreatedDate, 
											(SELECT Subject, CreatedDate from ActivityHistories order by CreatedDate desc limit 5)  
							   				 FROM Opportunity 
							   				 WHERE stagename= :theStageName 
							   				 and OwnerId = :theUserId
							   				 ORDER BY LastActivityDate asc];

		return allOpps;		
	}

	public static List<Opportunity> getAllOpportunities(String theStageName) {
				
		List<Opportunity> allOpps = [SELECT StageName, OwnerId, Owner.FirstName, Owner.LastName, Name, LastActivityDate, Id, 
											Property__r.name, Property__r.property_city__c, Property__r.property_state__c, 
											Property__r.property_county__c, CreatedDate, 
											(SELECT Subject, CreatedDate from ActivityHistories order by CreatedDate desc limit 5)  
							   				 FROM Opportunity 
							   				 WHERE stagename= :theStageName 
							   				 ORDER BY LastActivityDate asc];

		return allOpps;		
	}

	private static String[] getEmailAddresses(User theUser) {
		String[] emails = new List<String>();
		
		emails.add(theUser.email);
		
		if (theUser.manager != null) {
			emails.add(theUser.manager.email);	
		}
		
		return emails;	
	}

	public static List<Opportunity> getOpportunitiesToContact(List<Opportunity> opps, BusinessHours theBusinessHours, Integer idleTimeInHours, Integer numOfContacts) {
		List<Opportunity> oppsToContact = new List<Opportunity>();
		
		// loop thru each lead and check if the last activity is more than X business days old
		for (Opportunity tempOpp : opps) {
			SObject[] data = tempOpp.getSObjects('ActivityHistories');			
			List<ActivityHistory> activities = convert(data);

			if (activities.size() < numOfContacts) {
				oppsToContact.add(tempOpp);					
			} 
			else {				
				boolean timeDelayExpired = hasTimeDelayExpired(activities, tempOpp, theBusinessHours, idleTimeInHours);
				
				if (timeDelayExpired) {
					oppsToContact.add(tempOpp);	
				}
			}

		}
		
		return oppsToContact;
	}

	public static String getPlural(String text, Integer count) {
		String content = text;
		
		if (count > 1) {
			content += 's';	
		}
		
		return content;
	}
	
	private static String getHtmlContentForOpportunities(User salesRep, List<Opportunity> salesRepOpps, Server_Info__c serverInfo, Integer businessDays, Integer contacts) {
		String content = '';
				
		String daysText = getPlural('day', businessDays);
		String contactsText = getPlural('call', contacts) + '/' + getPlural('email', contacts);
				
		content += 'Hi ' + salesRep.FirstName + ',<br><br>';
		content += 'Please follow up on the following opportunities. AstrumCRM shows that you have not made ' + contacts + ' ' + contactsText + ' to these opportunities within ' + businessDays + ' business ' + daysText + '.<br><br>';

		content += 	getHtmlContentForListOfOpportunities(salesRepOpps, serverInfo);
			
		return content;			
	}
	
	private static String getPlainTextContentForOpportunities(User salesRep, List<Opportunity> salesRepOpps, Server_Info__c serverInfo, Integer businessDays, Integer contacts) {
		String content = '';

		String daysText = getPlural('day', businessDays);
		String contactsText = getPlural('call', contacts) + '/' + getPlural('email', contacts);
		
		content += 'Hi ' + salesRep.FirstName + ',\n\n';
		content += 'Please follow up on the following opportunities. AstrumCRM shows that you have not made ' + contacts + ' ' + contactsText + ' to these opportunities within ' + businessDays + ' business ' + daysText + '.\n\n';

		content += 	getPlainTextContentForListOfOpportunities(salesRepOpps, serverInfo);
			
		return content;	
	}

	private static String getPlainTextContentForListOfOpportunities(List<Opportunity> salesRepOpps, Server_Info__c serverInfo) {
		String content = '';

		Integer row = 1;
		for (Opportunity tempOpp : salesRepOpps) {
			
			String text = null;
			if (tempOpp.LastActivityDate != null) {
				DateTime lastActivityDateTime = getLastActivityDateTime(tempOpp);
				text = formatDate(lastActivityDateTime);
			}
			else {
				text = '-';
			}

			String address = String_Utils.getDefaultStringWithComma(tempOpp.Property__r.name) + String_Utils.getDefaultStringWithComma(tempOpp.Property__r.property_city__c) + String_Utils.getDefaultString(tempOpp.Property__r.property_state__c);
			String county = tempOpp.Property__r.property_county__c;
						
			content += row + ':  ' + tempOpp.Name + ', ' + address + ', ' + + ', Last contacted: ' + text + ',  Link: ' + serverInfo.Server_URL__c + tempOpp.id + '\n';
			row++;
		}
			
		return content;		
	}	

	private static String getHtmlContentForListOfOpportunities(List<Opportunity> salesRepOpps, Server_Info__c serverInfo) {
		String content = '';

		Integer row = 1;
		content += '<table border=1 cellpadding=5 width=825>';
		content += '<tr>';
		content += '<th>#</th>';
		content += '<th>Name</th>';
		content += '<th>Address</th>';
		content += '<th>County</th>';
		content += '<th>Last Contacted</th>';
		content += '</tr>';

		for (Opportunity tempOpp : salesRepOpps) {				
			content += '<tr>';
			
			content += '<td>' + row + '</td>';
			content += '<td>' + createLink(serverInfo, tempOpp.id, tempOpp.Name) + '</td>';

			String address = String_Utils.getDefaultStringWithComma(tempOpp.Property__r.name) + String_Utils.getDefaultStringWithComma(tempOpp.Property__r.property_city__c) + String_Utils.getDefaultString(tempOpp.Property__r.property_state__c);
			content += '<td>' + createLink(serverInfo, tempOpp.id, address) + '</td>';
			
			content += '<td>' + createLink(serverInfo, tempOpp.id, tempOpp.Property__r.property_county__c) + '</td>';

			String text = null;
			
			if (tempOpp.LastActivityDate != null) {
				DateTime lastActivityDateTime = getLastActivityDateTime(tempOpp);
				text = createLink(serverInfo, tempOpp.id, formatDate(lastActivityDateTime));
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

	public static Map<User, List<Opportunity>> getOpportunitiesEmailMap(Map<Id, User> oppUsers, List<Opportunity> oppsToContact) {
		Map<User, List<Opportunity>> theMap = new Map<User, List<Opportunity>>();
		
		for (Opportunity currentOpp : oppsToContact) {
			Id ownerId = currentOpp.OwnerId;
			User theUser = oppUsers.get(ownerId);
			
			// exclude the user 'Web Queue Lead', this user comes up as null
			if (theUser == null) {
				continue;
			}
			
			List<Opportunity> tempOpps = null;
			
			if (theMap.containsKey(theUser)) {
				tempOpps = theMap.get(theUser);	
			}
			else {
				tempOpps = new List<Opportunity>();
				theMap.put(theUser, tempOpps);
			}
			
			tempOpps.add(currentOpp);
		}
		
		return theMap;
	}

	public static Set<Id> getOwnerIds(List<Opportunity> opps) {
		Set<Id> ownerIds = new Set<Id>();
		
		for (Opportunity temp : opps) {
			ownerIds.add(temp.ownerId);
		}
		
		return ownerIds;
	}
	
	public static Map<Id, User> getOpportunityUsers(Set<Id> ownerIds) {
		Map<Id, User> users = new Map<Id, User>([Select Id, LastName, FirstName, Email, Manager.Email From User where id in :ownerIds]);
		
		return users;
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
	
	
	public static boolean hasTimeDelayExpired(BusinessHours theBusinessHours, Datetime startDateTime, Datetime endDateTime, Integer hours) {
		boolean result = false;

		Datetime nextDateTime = BusinessHours.add(theBusinessHours.id, startDateTime, hours * MS_IN_HOUR);
		
		// Find the number of business hours milliseconds between startTime and endTime as      
		// defined by the default business hours.  Will return a negative value if endTime is      
		// before startTime, 0 if equal, positive value otherwise.  		
		Long diff = BusinessHours.diff(theBusinessHours.id, nextDateTime, endDateTime);

		result = diff > 0;
		 		
		return result;
	}

	public static Boolean hasTimeDelayExpired(List<ActivityHistory> histories, Opportunity theOpp, BusinessHours theBusinessHours, Integer idleTimeInHours) {

		DateTime createdDateTime = getLastActivityDateTime(histories, theOpp);

		Boolean result = hasTimeDelayExpired(theBusinessHours, createdDateTime, DateTime.now(), idleTimeInHours); 
				
		return result;		
	}	

	private static DateTime getLastActivityDateTime(Opportunity theOpp) {
		SObject[] data = theOpp.getSObjects('ActivityHistories');			
		List<ActivityHistory> activities = convert(data);

		return getLastActivityDateTime(activities, theOpp);
	}

	private static DateTime getLastActivityDateTime(List<ActivityHistory> histories, Opportunity theOpp) {
		
		DateTime createdDateTime = null;

		if (histories.isEmpty()) {
			createdDateTime = theOpp.CreatedDate;
		}
		else {
			// get the one item from list
			ActivityHistory mostRecent = histories.get(0);
		
			// compare mostRecent with lead created date
			createdDateTime = (DateTime) mostRecent.get('CreatedDate');
		}

		return createdDateTime;
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

	private static String createLink(Server_Info__c serverInfo, Id theId, String text) {
		String link = '<a href="' + serverInfo.Server_URL__c + theId + '">' + text + '</a>';
		
		return link;	
	}

}