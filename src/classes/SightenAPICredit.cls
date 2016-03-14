public with sharing class SightenAPICredit extends SightenAPIEntity {

	public SightenAPICreditData data {get;set;}
	
	public SightenAPICredit(){
		data = new SightenAPICreditData();
	}

	public static String getApiName(){
		return 'ops/qualification';
	}


	public class SightenAPICreditData extends SightenAPIEntity.SightenAPIEntityData {
		public SightenAPISite.SightenAPISiteData site {get;set;}
		public List<SightenAPITitleQualification> title_qualifications {get;set;}
		public String status {get;set;}
		public Boolean expired {get;set;}
		public List<SightenAPICreditQualification> credit_qualifications {get;set;}
		public List<SightenAPIQualification> property_qualifications {get;set;}
		public SightenAPIQualification qualification_definition {get;set;}

		public SightenAPICreditData(){}
	}

	public with sharing class SightenAPICreditList extends SightenAPIEntity {
		public List<SightenAPICreditData> data {get;set;}
		
		public SightenAPICreditList(){
			data = new List<SightenAPICreditData>();
		}
	}
}