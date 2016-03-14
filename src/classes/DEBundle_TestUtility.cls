@isTest
public class DEBundle_TestUtility {

	public static void CreateCustomSettings(Id campaignId){
		DER_Bundle_Settings__c settings = new DER_Bundle_Settings__c();
		settings.Name = 'DER Settings';
		settings.DER_API_URL__c = 'http://test.com';
		settings.DER_Consumer_Key__c = 'test_consumer_key';
		settings.DER_Consumer_Secret__c = 'test_consumer_secret';
		settings.DER_Request_Timeout__c = 30000;
		settings.DER_Salesforce_Email__c = 'steven.zilligen@directenergysolar.com';
		settings.DER_Salesforce_Password__c = 'api@email.com';
		settings.DER_Salesforce_Username__c = 'password';
		settings.DER_Solar_Advantage_Campaign_Id__c = '12345';
		settings.DES_Solar_Advantage_Outbound_Campaign_Id__c = campaignId;
		insert settings;
	}

	public static Id CreateCampaign(){
		RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'DER_Outbound_Referral' AND SobjectType = 'Campaign' LIMIT 1];
		Campaign campaign = new Campaign(RecordTypeId = rt.Id, Name = 'Test Campaign', StartDate = Date.today().addDays(-2), EndDate = Date.today().addDays(2));
		insert campaign;
		if(campaign == null){
			return null;
		} else {
			return campaign.Id;
		}
	}

	public static Attachment CreateSalesOrderAttachment(Id salesorderId){
	    Attachment att = new Attachment(
	        Name = 'DER Solar Advantage Plan.pdf',
	        Body = Blob.valueOf('Sample DER Solar Advantage Plan Attachment'),
	        ContentType = 'application/pdf',
	        ParentId = salesorderId
		);
	    insert att;
	    return att;
	}
}