@isTest
public class SightenTestUtility {

	public static void createSightenCustomSettings(){
		SightenAPISettings__c sightenSettings = new SightenAPISettings__c();
		sightenSettings.API_URL__c = 'https://mock.sighten.io/api/';
		sightenSettings.Authorization_Token__c = 'd78ad1185d84513dcd64146d0f070c994cff639e';
		sightenSettings.Callback_Token__c = 'D6B5A89663685F465FA358E53665A81E853527A53693F175D127359A55A11AF79CEE2DC77E2B1B4D';
		sightenSettings.Testing_Contact_Email__c = 'test.sighten@directenergysolar.com';
		sightenSettings.Testing_Contact_Phone__c = '999-999-9999';
		insert sightenSettings;
	}

	public static void AddSightenUUIDValues(System_Design_Quote__c sdq){
        OpportunityContactRole oppAndContactId = [SELECT ContactId, OpportunityId FROM OpportunityContactRole LIMIT 1];
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = oppAndContactId.ContactId;
        ocr.IsPrimary = true;
        ocr.Role = 'Contract Signer';
        ocr.OpportunityId = oppAndContactId.OpportunityId;
        insert ocr;

        Lease_Fund__c leaseFund = new Lease_Fund__c(
            Id = sdq.Scenario_1_Term_Loan__c,
            Sighten_Product_uuid__c = 'test_uuid_product'
        );
        update leaseFund;

        Utility_Company_Master__c util = new Utility_Company_Master__c(
        	Id = sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__c,
        	Sighten_Utility_uuid__c = 'test_uuid_utility',
            Sighten_Custom_Rate_Code_uuid__c = 'test_uuid_rate_code',
            Sighten_NA_Territory_uuid__c = 'test_uuid_territory'
    	);
    	update util;

        Utility_Company__c utilRate = new Utility_Company__c(
        	Id = sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_Before_Solar__c,
        	Sighten_Rate_Schedule_uuid__c = 'test_uuid_rate_code'
    	);
    	update utilRate;

        System_Design_Array__c sda = [SELECT Id FROM System_Design_Array__c WHERE System_Design__c = :sdq.System_Design__c LIMIT 1];
        Set<Id> sdpIds = new Set<Id>();
        for(System_Design_Item__c sdItem : [SELECT Id, System_Design_Product__c FROM System_Design_Item__c WHERE System_Design_Array__c = :sda.Id]){
        	if(!sdpIds.contains(sdItem.System_Design_Product__c)){
	        	sdpIds.add(sdItem.System_Design_Product__c);
        	}
        }

        List<System_Design_Product__c> sdpList = new List<System_Design_Product__c>();
        Integer cnt = 1;
        for(System_Design_Product__c sdp : [SELECT Id, Sighten_Equipment_uuid__c FROM System_Design_Product__c WHERE Id IN :sdpIds]){
        	sdp.Sighten_Equipment_uuid__c = 'test_uuid_equipment_' + cnt;
        	sdpList.add(sdp);
        	cnt++;
        }
        update sdpList;

        System_Design_Quote__c sdqWithProperty = [SELECT Id, System_Design__r.Property__c FROM System_Design_Quote__c WHERE Id = :sdq.Id LIMIT 1];
        Sighten_Credit_Approval__c sca = new Sighten_Credit_Approval__c(
            Sighten_Qualification_uuid__c = 'test_uuid_qualification',
            Credit_Status__c = 'NEW',
            Contact__c = oppAndContactId.ContactId,
            Lease_Fund__c = leaseFund.Id,
            Property__c = sdqWithProperty.System_Design__r.Property__c
        );
        insert sca;
	}
}