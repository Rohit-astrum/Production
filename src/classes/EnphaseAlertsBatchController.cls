public class EnphaseAlertsBatchController {
	
	private Integer lastProcessed = -1;

	public List<ProcessStatus> statuses { get; private set; }
	public Boolean completed { get; private set; }
	public Boolean paused { get; private set; }

	public String startTime { get; private set; }
	public String completeTime { get; private set; }
	public Integer total { get; private set; }
	public Integer processed { get; private set; }
	public Integer errors { get; private set; }
	
	public EnphaseAlertsBatchController() {
		completed = false;
		paused = false;
		loadSystems();
	}
	
	private void loadSystems() {
		
		statuses = new List<ProcessStatus>();
		
		List<Installed_System__c> systems = 
			[SELECT Id, Enphase_ID__c, PJM_Id__c, Generation_Start_Date__c,
				Quoted_System_Design__r.System_Design__r.Total_System_Size_kW__c,
				Quoted_System_Design__r.System_Design__r.Total_Projected_Annual_Output_kWh_y__c,
				Property__r.Snow_De_Rate_kWh_y_kW__c
			FROM Installed_System__c
			WHERE Enphase_ID__c <> NULL
			AND Id NOT IN 
				(SELECT Installed_System__c 
				FROM Enphase_Alert__c 
				WHERE CreatedDate = THIS_WEEK)];
				
		for (Installed_System__c sys : systems) {
			ProcessStatus ps = new ProcessStatus();
			ps.sys = sys;
			ps.processed = false;
			ps.status = 'Pending';
			statuses.add(ps);
		}
		
		total = statuses.size();
		if (total == 0) {
			completed = true;
		}
		processed = 0;
		errors = 0;
		
	}

	public PageReference updateState() {
		
		if (lastProcessed < statuses.size() - 1) {
			
			ProcessStatus ps = statuses[++lastProcessed];
			ps.Status = processSystem(ps.sys);
			ps.processed = true;
			ps.processedTime = System.now();
			processed++;

			if (startTime == null) {
				startTime = ps.processDateTime;
			}
			if (ps.Status != 'Success') {
				errors++;
			}
			if (lastProcessed == statuses.size() - 1) {
				completed = true;
				completeTime = ps.processDateTime;
			}	 
		}
		
		return null;
	}
	
	public PageReference pause() {
		paused = true;
		return null;
	}
	
	public PageReference resume() {
		paused = false;
		return null;
	}
	
	public String processSystem(Installed_System__c sys) {
		
		try {
			
			EnphaseAPI api = new EnphaseAPI();
			List<Enphase_Alert__c> alerts = new List<Enphase_Alert__c>();
		
			//get alerts from enphase
			List<EnphaseAPI.EnphaseAlert> e_alerts = api.alerts(Integer.valueOf(sys.Enphase_ID__c), 'low');
					
			List<Enphase_Alert__c> s_alerts = 
				[SELECT Id, Alert_Level__c, Alert_Name__c, Alert_Start__c, Number_of_Devices__c, Acknowledged__c 
				FROM Enphase_Alert__c
				WHERE Installed_System__c = :sys.Id];
	
			Set<Id> foundIds = new Set<Id>();
					
			for (EnphaseAPI.EnphaseAlert e_alert : e_alerts) {
				Boolean found = false;
				for (Enphase_Alert__c s_alert : s_alerts) {
					//if the number of inverters or level changes, unacknowledge and update
					if (s_alert.Alert_Start__c == e_alert.alert_start 
					&& s_alert.Alert_Name__c == e_alert.alert_name) {
						if (s_alert.Alert_Level__c != e_alert.level
						|| s_alert.Number_of_Devices__c != e_alert.num_devices) {
							s_alert.Acknowledged__c = false;
							s_alert.Alert_Level__c = e_alert.level;
							s_alert.Number_of_Devices__c = e_alert.num_devices;
							alerts.add(s_alert);
						}
						foundIds.add(s_alert.Id);
						found = true;
						break;
					}
				}
				if (found != true) {
					alerts.add(new Enphase_Alert__c (
						Installed_System__c = sys.Id,
						Alert_Start__c = e_alert.alert_start,
						Alert_Name__c = e_alert.alert_name,
						Alert_Level__c = e_alert.level,
						Number_of_Devices__c = e_alert.num_devices
					));
				}
			}
				
			//look for ones that no longer appear, auto-acknowledge
			for (Enphase_Alert__c s_alert : s_alerts) {
				if (!foundIds.contains(s_alert.Id) && s_alert.Acknowledged__c != true) {
					s_alert.Acknowledged__c = true;
					alerts.add(s_alert);
				}
			}

			if (!alerts.isEmpty()) {
				upsert alerts;				
			}
				
		} catch (Exception e) {
			return e.getMessage() + ' \n' + e.getStackTraceString();
		}

		return 'Success';		
		
	}
	
	public class ProcessStatus {
		public Installed_System__c sys { get; set; }
		public Boolean processed { get; set; }
		public DateTime processedTime;
		public String processDateTime { get { return processedTime != null ? processedTime.format('h:mm:ss a') : null; } } 
		public String status { get; set; }
	}

}