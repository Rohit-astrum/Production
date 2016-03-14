public with sharing class SightenAPIContact extends SightenAPIEntity {

	public SightenAPIContactData data {get;set;}
	public SightenAPIContactRequest request {get;set;}
	
	public SightenAPIContact(){
		data = new SightenAPIContactData();
		request = new SightenAPIContactRequest();
	}

	public override String buildRequestBody(){
		return request.toJsonString();
	}

	public static String getApiName(){
		return 'solar/quotegen/contact';
	}


	public class SightenAPIContactData extends SightenAPIEntity.SightenAPIEntityData {
		public String email {get;set;}
		public String first_name {get;set;}
		public String last_name {get;set;}
		public String phone_number {get;set;}
		public SightenAPIRelation site {get;set;}

		public SightenAPIContactData(){}
	}

	public class SightenAPIContactRequest extends SightenAPIEntity.SightenAPIEntityRequest {
		public SightenAPIContactRequest(){}
	}

	public with sharing class SightenAPIContactList extends SightenAPIEntity {
		public List<SightenAPIContactData> data {get;set;}
		
		public SightenAPIContactList(){
			data = new List<SightenAPIContactData>();
		}
	}
}