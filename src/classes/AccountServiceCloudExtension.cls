public class AccountServiceCloudExtension {

	private Account scAccount;

	public AccountServiceCloudExtension(ApexPages.StandardController controller) {
		scAccount = (Account)controller.getRecord();
	}
	
	public List<Property__c> properties {
		get {
			if (properties == null) {
				properties = [SELECT Id, Name FROM Property__c WHERE Property_Owner__c = :scAccount.Id];
			}
			return properties;
		}
		private set;
	} 

	public List<SCRB_SalesOrder__c> salesOrders {
		get {
			if (salesOrders == null) {
				salesOrders = [SELECT Id, Name, System_Design_Quote__r.System_Design__c FROM SCRB_SalesOrder__c WHERE AccountId__c = :scAccount.Id];
			}
			return salesOrders;
		}
		private set;
	}
	
	public List<PM_Project__c> pmProjects {
		get {
			if (pmProjects == null) {
				if (salesOrders.isEmpty()) {
					pmProjects = new List<PM_Project__c>();
				} else {
					pmProjects = [SELECT Id, Name FROM PM_Project__c WHERE Sales_Order__c IN :salesOrders];
				}
			}
			return pmProjects;
		}
		private set;
	}
	
	public List<System_Design__c> systemDesigns {
		get {
			if (systemDesigns == null) {
				Set<Id> systemDesignIds = new Set<Id>();
				for (SCRB_SalesOrder__c so : salesOrders) {
					if (so.System_Design_Quote__r.System_Design__c != null) {
						systemDesignIds.add(so.System_Design_Quote__r.System_Design__c);
					}
				}
				if (systemDesignIds.isEmpty()) {
					systemDesigns = new List<System_Design__c>();
				} else {
					systemDesigns = [SELECT Id, Name FROM System_Design__c WHERE Id IN :systemDesignIds];
				}
			}
			return systemDesigns;
		}
		private set;
	} 

	public List<Installed_System__c> installedSystems {
		get {
			if (installedSystems == null) {
				installedSystems = [SELECT Id, Name, Enphase_ID__c, PJM_ID__c FROM Installed_System__c WHERE Account__c = :scAccount.Id];
			}
			return installedSystems;
		}
		private set;
	} 
	
	public List<Installed_System__c> alerts {
		get {
			if (alerts == null) {
				alerts = new List<Installed_System__c>();
				if (installedSystems.size() > 0) {
					List<Enphase_Alert__c> enphaseAlerts = [SELECT Id FROM Enphase_Alert__c WHERE Installed_System__c IN :installedSystems LIMIT 1];
					if (enphaseAlerts.size() > 0) {
						alerts = installedSystems;
					}		
				}
			}
			return alerts;
		}
		private set;
	} 
	

	public List<Case> openCases {
		get {
			if (openCases == null) {
				openCases = [SELECT Id, CaseNumber FROM Case WHERE AccountId = :scAccount.Id AND isClosed <> true];
			}
			return openCases;
		}
		private set;
	}

}