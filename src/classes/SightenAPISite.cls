public with sharing class SightenAPISite extends SightenAPIEntity {

	public SightenAPISiteData data {get;set;}
	public SightenAPISiteRequest request {get;set;}

	public SightenAPISite(){
		data = new SightenAPISiteData();
		request = new SightenAPISiteRequest();
	}

	public override String buildRequestBody(){
		return request.toJsonString();
	}

	public static String getApiName(){
		return 'solar/quotegen/site';
	}


	public class SightenAPISiteData extends SightenAPIEntity.SightenAPIEntityData {
		public SightenAPIRelation address {get;set;}
		public Double avg_cost_of_power {get;set;}
		public Double avg_monthly_usage {get;set;}
		public Double avg_monthly_utility_bill {get;set;}
		public SightenAPIRelation contacts {get;set;}
		public String heating_source {get;set;}
		public String tmy_datatype {get;set;}
		public String tmy_station {get;set;}
		public Double usage_kwh_1 {get;set;}
		public Double usage_kwh_10 {get;set;}
		public Double usage_kwh_11 {get;set;}
		public Double usage_kwh_12 {get;set;}
		public Double usage_kwh_2 {get;set;}
		public Double usage_kwh_3 {get;set;}
		public Double usage_kwh_4 {get;set;}
		public Double usage_kwh_5 {get;set;}
		public Double usage_kwh_6 {get;set;}
		public Double usage_kwh_7 {get;set;}
		public Double usage_kwh_8 {get;set;}
		public Double usage_kwh_9 {get;set;}
		public SightenAPIRelation utility {get;set;}
		public SightenAPIRelation utility_rate_schedule {get;set;}
		public SightenAPIRelation utility_territory {get;set;}

		public SightenAPISiteData(){}
	}

	public class SightenAPISiteRequest extends SightenAPIEntity.SightenAPIEntityRequest {
		public SightenAPIAddress.SightenAPIAddressRequest x_address {get;set;}
		public List<SightenAPIContact.SightenAPIContactRequest> x_contacts {get;set;}
		public Map<String, Object> usage_months {get;set;}

		public SightenAPISiteRequest(){
			x_address = new SightenAPIAddress.SightenAPIAddressRequest();
			x_contacts = new List<SightenAPIContact.SightenAPIContactRequest>();
			usage_months = new Map<String, Object>();
		}

		public override Object toJsonObject(){
			if(usage_months.size() > 0){
				this.addPostParameter('usage_months', usage_months);
			}
			List<Object> contacts = new List<Object>();
			if(x_contacts.size() > 0){
				for(SightenAPIContact.SightenAPIContactRequest x_contact : x_contacts){
					contacts.add(x_contact.toJsonObject());
				}
				this.addPostParameter('contacts', contacts);
			}
			if(x_address != null){
				this.addPostParameter('address', x_address.toJsonObject());
			}
			return postParameters;
		}
	}

	public with sharing class SightenAPISiteList extends SightenAPIEntity {
		public List<SightenAPISiteData> data {get;set;}
		
		public SightenAPISiteList(){
			data = new List<SightenAPISiteData>();
		}
	}
}