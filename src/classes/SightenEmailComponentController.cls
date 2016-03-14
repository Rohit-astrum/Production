public without sharing class SightenEmailComponentController {

	public String salutation {get;set;}
	public String aboutName {get;set;}
	public String aboutRecord {get;set;}
	public String status {get;set;}
	public String additionalData1 {get;set;}
	public String supportPhone {get;set;}
	public String supportEmail {get;set;}

	public String emailTemplateType {
		get;
		set{
			emailTemplateType = value.toUpperCase();
			init();
		}
	}
	public String recordId {
		get;
		set{
			recordId = value;
			init();
		}
	}

	public SightenEmailComponentController(){}
	public void init(){
		if(String.isNotBlank(emailTemplateType) && String.isNotBlank(recordId)){
			if(emailTemplateType == 'CREDIT'){
				Sighten_Credit_Approval__c sca = [SELECT Id, Property__r.Name, Property__r.Property_Owner__r.Owner.Name, Contact__r.Name, Lease_Fund__r.Name, Credit_Status__c FROM Sighten_Credit_Approval__c WHERE Id = :recordId LIMIT 1];
				salutation = sca.Property__r.Property_Owner__r.Owner.Name;
				aboutName = sca.Contact__r.Name;
				aboutRecord = sca.Property__r.Name;
				status = sca.Credit_Status__c;
				additionalData1 = sca.Lease_Fund__r.Name;

				SightenAPISettings__c sightenSettings = SightenAPISettings__c.getOrgDefaults();
				supportPhone = sightenSettings.Sighten_Credit_Support_Phone__c;
				supportEmail = sightenSettings.Sighten_Credit_Support_Email__c;
			} else if(emailTemplateType == 'SIGNING'){
				Astrum_Contract__c contract = [SELECT Id, CreatedBy.Name, Signatory_1__c, Name, Sighten_Signing_Status__c FROM Astrum_Contract__c WHERE Id = :recordId LIMIT 1];
				salutation = contract.CreatedBy.Name;
				aboutName = contract.Signatory_1__c;
				aboutRecord = contract.Name;
				status = contract.Sighten_Signing_Status__c;
			}
		}
	}
}