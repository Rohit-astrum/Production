public class CaseServiceCloudExtension {

	private Case scCase;

	public CaseServiceCloudExtension(ApexPages.StandardController controller) {
		scCase = (Case)controller.getRecord();
	}
	
	public List<Property__c> properties {
		get {
			if (properties == null) {
				if (scCase.AccountId == null) {
					properties = new List<Property__c>();
				} else {
					properties = [SELECT Id, Name FROM Property__c WHERE Property_Owner__c = :scCase.AccountId];
				}
			}
			return properties;
		}
		private set;
	} 

	public List<SCRB_SalesOrder__c> salesOrders {
		get {
			if (salesOrders == null) {
				if (scCase.AccountId == null) {
					salesOrders = new List<SCRB_SalesOrder__c>();
				} else {
					salesOrders = [SELECT Id, Name, System_Design_Quote__r.System_Design__c FROM SCRB_SalesOrder__c WHERE AccountId__c = :scCase.AccountId];
				}
			}
			return salesOrders;
		}
		private set;
	}

	public List<PM_Project__c> pmProjects {
		get {
			if (pmProjects == null) {
				if (scCase.AccountId == null || salesOrders.isEmpty()) {
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
				if (scCase.AccountId == null) {
					installedSystems = new List<Installed_System__c>();
				} else {
					installedSystems = [SELECT Id, Name, Enphase_ID__c, PJM_ID__c FROM Installed_System__c WHERE Account__c = :scCase.AccountId];
				}
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
	
	public List<EmailMessage> lastEmailMessage {
		get {
			if (lastEmailMessage == null) {
				if (scCase.AccountId == null) {
					lastEmailMessage = new List<EmailMessage>();
				} else {
					lastEmailMessage = 
						[SELECT Id, Subject, Incoming FROM EmailMessage 
						WHERE ParentId = :scCase.Id
						AND Incoming = true 
						ORDER BY CreatedDate DESC 
						LIMIT 1];
					lastEmailMessage.addAll( 
						[SELECT Id, Subject, Incoming FROM EmailMessage 
						WHERE ParentId = :scCase.Id
						AND Incoming <> true 
						ORDER BY CreatedDate DESC 
						LIMIT 1]);
				}
			}
			return lastEmailMessage;
		}
		private set;
	}

}