global class EnphaseAlertsController {
	
	private String installedSystemId;
	
	public EnphaseAlertsController() {
		installedSystemId = ApexPages.currentPage().getParameters().get('id');
	}

	public List<EnphaseInfo> getAlerts() {

		List<EnphaseInfo> result = new List<EnphaseInfo>();
		Map<Id, EnphaseInfo> propertyInfoMap = new Map<Id, EnphaseInfo>();
		Map<Id, EnphaseInfo> accountInfoMap = new Map<Id, EnphaseInfo>();
		
		//TODO: limit to last 90 days of acknowledged alerts
		
		String query =  
			'SELECT Id, Alert_Name__c, Installed_System__c, Installed_System__r.Name,'
			+ ' Installed_System__r.Property__c, Installed_System__r.Property__r.Name,'
			+ ' Installed_System__r.Property__r.Property_City__c, Installed_System__r.Property__r.Property_State__c,'
			+ ' Installed_System__r.Property__r.Astrum_Office__c,'
			+ ' Installed_System__r.Account__c, Installed_System__r.Account__r.Name,'
			+ ' Alert_Start__c, Impact__c, View_in_Enlighten__c, Number_of_Devices__c, Alert_Level__c, Acknowledged__c'
			+ ' FROM Enphase_Alert__c'
			+ ' WHERE (Acknowledged__c <> true'
			+ ' OR (Acknowledged__c = true AND Alert_Start__c = LAST_90_DAYS))';

		if (installedSystemId != null && installedSystemId.trim() != '') {
			query += ' AND Installed_System__c = :installedSystemId';
		}

		query += ' ORDER BY Installed_System__c, Acknowledged__c DESC, Alert_Start__c DESC';
		
		List<Enphase_Alert__c> alerts = Database.query(query);
			
		EnphaseInfo ei = new EnphaseInfo();
		
		for (Enphase_Alert__c alert : alerts) {
			
			if (alert.Installed_System__c != ei.installedSystemId) {
				if (ei.installedSystemId != null && !ei.activeAlerts.isEmpty()) {
					result.add(ei);
				}
				ei = new EnphaseInfo();
                ei.alert1 = alert; //first alert
                if (ei.propertyId != null) {
					propertyInfoMap.put(ei.propertyId, ei);
                }
                if (ei.accountId != null) {
                	accountInfoMap.put(ei.accountId, ei);
                }
			}
			
			if (alert.Acknowledged__c != true) {
				if (ei.latestStart == null || ei.latestStart < alert.Alert_Start__c) {
					ei.latestStart = alert.Alert_Start__c;
				}
				ei.activeAlerts.add(alert);
			} else {
				ei.inactiveAlerts.add(alert);
			}
			
		} 

		if (ei.installedSystemId != null && !ei.activeAlerts.isEmpty()) {
			result.add(ei);
		}
		
		result.sort();
		
		if (result.isEmpty()) {
			return result;
		}
		
		List<Case> recentCases = 
			[SELECT Id, CreatedDate, CaseNumber, Status, Subject, Type, Sub_Type__c, Property__c, AccountId
			FROM Case 
			WHERE (Property__c IN :propertyInfoMap.keySet()
			OR AccountId IN :accountInfoMap.keySet()) 
			//AND (CreatedDate = LAST_90_DAYS
			//OR CreatedDate = TODAY)
			ORDER By CreatedDate DESC];
			
		for (Case c : recentCases) {
			ei = propertyInfoMap.get(c.Property__c);
			if (ei != null && ei.recentCases.size() < 10) {
				ei.recentCases.add(c);
			} else {
				ei = accountInfoMap.get(c.AccountId);
				if (ei != null && ei.recentCases.size() < 10) {
					ei.recentCases.add(c);
				}
			}
		}

		return result;
		
	}
	
	//TODO: add highest severity
	//TODO: add office, city, state
	//TODO: add comparable
	
	global class EnphaseInfo implements Comparable {
		public EnphaseInfo() {
			activeAlerts = new List<Enphase_Alert__c>();
			inactiveAlerts = new List<Enphase_Alert__c>();
			recentCases = new List<Case>();
		}
        public Enphase_Alert__c alert1 { get; set; }
		public Id installedSystemId { get { return alert1 == null ? null : alert1.Installed_System__c; } }
		public String systemName { get { return alert1 == null ? null : alert1.Installed_System__r.Name; } }
		public Id propertyId { get { return alert1 == null ? null : alert1.Installed_System__r.Property__c; } }
		public String propertyName { get { return alert1 == null ? null : alert1.Installed_System__r.Property__r.Name; } }
		public Id accountId { get { return alert1 == null ? null : alert1.Installed_System__r.Account__c; } }
		public String accountName { get { return alert1 == null ? null : alert1.Installed_System__r.Account__r.Name; } }
		public DateTime latestStart;
		public String latest { get {
			if (latestStart == null) return null;
			return latestStart.format('M/d/yyyy hh:mma');
		}}
		public List<Enphase_Alert__c> activeAlerts { get; set; }
		public List<Enphase_Alert__c> inactiveAlerts { get; set; }
		public List<Case> recentCases { get; set; }
        public Integer compareTo(Object sys) {
			EnphaseInfo ei2 = (EnphaseInfo)sys;
			if (ei2 == null) {
				return -1;
			}
			if (latestStart == null && ei2.latestStart == null) {
				return 0;
			}
			if (latestStart == null && ei2.latestStart != null) {
				return 1;
			}
			if (ei2.latestStart == null) {
				return -1;
			}
			if (latestStart > ei2.latestStart) {
				return -1;
			} else if (latestStart < ei2.latestStart) {
				return 1;
			}
			return 0;
		}
	}

}