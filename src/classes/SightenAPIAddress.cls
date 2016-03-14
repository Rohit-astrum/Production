public with sharing class SightenAPIAddress extends SightenAPIEntity {

	public SightenAPIAddressData data {get;set;}
	public SightenAPIAddressRequest request {get;set;}

	public SightenAPIAddress(){
		data = new SightenAPIAddressData();
		request = new SightenAPIAddressRequest();
	}

	public override String buildRequestBody(){
		return request.toJsonString();
	}

	public static String getApiName(){
		return 'solar/quotegen/site';
	}


	public class SightenAPIAddressData extends SightenAPIEntity.SightenAPIEntityData {
		public String city_name {get;set;}
		public String county_name {get;set;}
		public Integer elevation {get;set;}
		public String full_address {get;set;}
		public Double latitude {get;set;}
		public Double longitude {get;set;}
		public String plus4_code {get;set;}
		public String primary_number {get;set;}
		public String secondary_designator {get;set;}
		public String secondary_number {get;set;}
		public String state_abbreviation {get;set;}
		public String street_name {get;set;}
		public String street_suffix {get;set;}
		public String zipcode {get;set;}

		public SightenAPIAddressData(){}
	}


	public class SightenAPIAddressRequest extends SightenAPIEntity.SightenAPIEntityRequest {
		public SightenAPIAddressRequest(){}
	}


	public with sharing class SightenAPIAddressList extends SightenAPIEntity {
		public List<SightenAPIAddressData> data {get;set;}
		
		public SightenAPIAddressList(){
			data = new List<SightenAPIAddressData>();
		}
	}
}