public class AstrumMapViewerController {
	
	private static Integer rowLimit {
		get {
			if (Test.isRunningTest()) {
				return 10;
			} else {
				return 50000;
			}
		}
	} 

	//get sales orders
	@RemoteAction
	public static List<AstrumMapItem> getSalesOrders() {
	
		List<AstrumMapItem> result = new List<AstrumMapItem>();
		
		List<SCRB_SalesOrder__c> orders = 
			[SELECT Id,
				Name,
				AccountId__r.Name, 
				Property__r.Name, 
				StatusCode__c,
				Property__r.Property_Address_2__c, 
				Property__r.Property_City__c, 
				Property__r.Property_State__c, 
				Property__r.Property_ZIP__c, 
				Property__r.Latitude__c, 
				Property__r.Longitude__c 
			FROM SCRB_SalesOrder__c
			LIMIT :rowLimit];
			//WHERE Property__r.Longitude__c > -86.2914 //IN
			//AND Property__r.Latitude__c > 36 ]; //top of NC

		for (SCRB_SalesOrder__c o : orders) {
			AstrumMapItem item = new AstrumMapItem();
			item.id = o.Id;
			item.name = o.Name;
			item.status = o.StatusCode__c;
			item.address = o.AccountId__r.Name + '\n' + o.Property__r.Name;
			if (o.Property__r.Property_Address_2__c != null) {
				item.address += '\n' + o.Property__r.Property_Address_2__c;
			}
			item.address += '\n' + o.Property__r.Property_City__c + ' ' + o.Property__r.Property_State__c + ' ' + o.Property__r.Property_ZIP__c;
			item.lat = o.Property__r.Latitude__c;
			item.lon = o.Property__r.Longitude__c;
			result.add(item);
		}
		
		return result;				
	}	 
	
	//get opportunities
	@RemoteAction
	public static List<AstrumMapItem> getOpportunities(Boolean pipelineOnly) {
	
		List<AstrumMapItem> result = new List<AstrumMapItem>();
		
		List<String> exclusions = new List<String>();
		
		if (pipelineOnly == true) {
			exclusions.add('On Hold');
			exclusions.add('Closed - Won');
			exclusions.add('Contract Cancelled');
			exclusions.add('Closed - Lost');
			exclusions.add('Unresponsive');
		}
		
		List<Opportunity> opportunities = 
			[SELECT Id,
				Name,
				StageName, 
				Account.Name,
				Property__r.Name, 
				Property__r.Property_Address_2__c, 
				Property__r.Property_City__c, 
				Property__r.Property_State__c, 
				Property__r.Property_ZIP__c, 
				Property__r.Latitude__c, 
				Property__r.Longitude__c 
			FROM Opportunity
			WHERE StageName NOT IN :exclusions
			AND Property__r.Longitude__c <> NULL
			AND Property__r.Latitude__c <> NULL
			LIMIT :rowLimit];
			//AND Property__r.Longitude__c > -86.2914 //IN
			//AND Property__r.Latitude__c > 36 ]; //top of NC

		for (Opportunity o : opportunities) {
			AstrumMapItem item = new AstrumMapItem();
			item.id = o.Id;
			item.name = o.Name;
			item.status = o.StageName;
			item.address = o.Account.Name + '\n' + o.Property__r.Name;
			if (o.Property__r.Property_Address_2__c != null) {
				item.address += '\n' + o.Property__r.Property_Address_2__c;
			}
			item.address += '\n' + o.Property__r.Property_City__c + ' ' + o.Property__r.Property_State__c + ' ' + o.Property__r.Property_ZIP__c;
			item.lat = o.Property__r.Latitude__c;
			item.lon = o.Property__r.Longitude__c;
			result.add(item);
		}
		
		return result;				
	}	 
	
	//get leads
	@RemoteAction
	public static List<AstrumMapItem> getLeads(Boolean pipelineOnly) {
	
		List<AstrumMapItem> result = new List<AstrumMapItem>();
		
		List<String> exclusions = new List<String>();
		
		if (pipelineOnly == true) {
			exclusions.add('On Hold');
			exclusions.add('Qualified');
			exclusions.add('Unqualified');
			exclusions.add('Unresponsive');
			exclusions.add('Marketing – Influencer');
			exclusions.add('Lost – Competition');
		}
		
		List<Lead> leads = 
			[SELECT Id,
				Name,
				Status, 
				Street, 
				City, 
				State, 
				PostalCode, 
				QAS_Latitude__c, 
				QAS_Longitude__c 
			FROM Lead
			WHERE Status NOT IN :exclusions
			AND IsConverted <> true
			AND QAS_Latitude__c <> NULL
			AND QAS_Longitude__c <> NULL
			LIMIT :rowLimit];

		for (Lead l : leads) {
			AstrumMapItem item = new AstrumMapItem();
			item.id = l.Id;
			item.name = l.Name;
			item.status = l.Status;
			item.address = l.Street + '\n' + l.City + ' ' + l.State + ' ' + l.PostalCode; 
			item.lat = Double.valueOf(l.QAS_Latitude__c);
			item.lon = Double.valueOf(l.QAS_Longitude__c);
			//if (item.lon > -86.2914 && item.lat > 36) {
			result.add(item);
			//}
		}
		
		return result;				
	}	 
	
	//get installed systems
	@RemoteAction
	public static List<AstrumMapItem> getProjects() {
	
		List<AstrumMapItem> result = new List<AstrumMapItem>();
		
		List<Milestone1_Project__c> projects = 
			[SELECT Id,
				Name,
				Status__c,
				Sales_Order__r.AccountId__r.Name,
				Sales_Order__r.Property__r.Name, 
				Sales_Order__r.Property__r.Property_Address_2__c, 
				Sales_Order__r.Property__r.Property_City__c, 
				Sales_Order__r.Property__r.Property_State__c, 
				Sales_Order__r.Property__r.Property_ZIP__c, 
				Sales_Order__r.Property__r.Latitude__c, 
				Sales_Order__r.Property__r.Longitude__c 
			FROM Milestone1_Project__c
			LIMIT :rowLimit];

		for (Milestone1_Project__c o : projects) {
			AstrumMapItem item = new AstrumMapItem();
			item.id = o.Id;
			item.name = o.Name;
			item.status = o.Status__c;
			item.address = o.Sales_Order__r.AccountId__r.Name + '\n' + o.Sales_Order__r.Property__r.Name;
			if (o.Sales_Order__r.Property__r.Property_Address_2__c != null) {
				item.address += '\n' + o.Sales_Order__r.Property__r.Property_Address_2__c;
			}
			item.address += '\n' + o.Sales_Order__r.Property__r.Property_City__c + ' ' + o.Sales_Order__r.Property__r.Property_State__c + ' ' 
				+ o.Sales_Order__r.Property__r.Property_ZIP__c;
			item.lat = o.Sales_Order__r.Property__r.Latitude__c;
			item.lon = o.Sales_Order__r.Property__r.Longitude__c;
			result.add(item);
		}
		
		return result;				
	}	 
	

	//get installed systems
	@RemoteAction
	public static List<AstrumMapItem> getInstalled() {
	
		List<AstrumMapItem> result = new List<AstrumMapItem>();
		
		List<Installed_System__c> installed = 
			[SELECT Id,
				Name,
				Account__r.Name,
				Property__r.Name, 
				Property__r.Property_Address_2__c, 
				Property__r.Property_City__c, 
				Property__r.Property_State__c, 
				Property__r.Property_ZIP__c, 
				Property__r.Latitude__c, 
				Property__r.Longitude__c 
			FROM Installed_System__c
			LIMIT :rowLimit];
			//WHERE Property__r.Longitude__c > -86.2914 //IN
			//AND Property__r.Latitude__c > 36 ]; //top of NC

		for (Installed_System__c o : installed) {
			AstrumMapItem item = new AstrumMapItem();
			item.id = o.Id;
			item.name = o.Name;
			item.status = 'Installed';
			item.address = o.Account__r.Name + '\n' + o.Property__r.Name;
			if (o.Property__r.Property_Address_2__c != null) {
				item.address += '\n' + o.Property__r.Property_Address_2__c;
			}
			item.address += '\n' + o.Property__r.Property_City__c + ' ' + o.Property__r.Property_State__c + ' ' + o.Property__r.Property_ZIP__c;
			item.lat = o.Property__r.Latitude__c;
			item.lon = o.Property__r.Longitude__c;
			result.add(item);
		}
		
		return result;				
	}	 
	
	public class AstrumMapItem {
		public String id;
		public String name;
		public String status;
		public String address;
		public double lat;
		public double lon;
	}

}