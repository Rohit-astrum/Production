public with sharing class SightenAPISystem extends SightenAPIEntity {

	public SightenAPISystemData data {get;set;}
	public SightenAPISystemRequest request {get;set;}

	public SightenAPISystem(){
		data = new SightenAPISystemData();
		request = new SightenAPISystemRequest();
	}

	public override String buildRequestBody(){
		return request.toJsonString();
	}

	public static String getApiName(){
		return 'solar/quotegen/system';
	}


	public class SightenAPISystemData extends SightenAPIEntity.SightenAPIEntityData {
		public Integer n_modules {get;set;}
		public SightenAPIUtilityTier utility_tier_offset {get;set;}
		public Double capacity {get;set;}
		public String primary_module_mfr {get;set;}
		public Double productivity {get;set;}
		public SightenAPIRelation site {get;set;}
		public SightenAPIRelation arrays {get;set;}
		public String primary_inverter_mfr {get;set;}
		public SightenAPIUtilityTier monthly_generation {get;set;}
		public Double generation {get;set;}
		public String name {get;set;}
		public SightenAPIUtilityTier utility_tier_usage {get;set;}
		public Double consumption_offset {get;set;}

		public SightenAPISystemData(){}
	}

	public class SightenAPISystemRequest extends SightenAPIEntity.SightenAPIEntityRequest {
		public SightenAPISite.SightenAPISiteRequest x_site {get;set;}
		public List<SightenAPIArray.SightenAPIArrayRequest> x_arrays {get;set;}

		public SightenAPISystemRequest(){
			x_site = new SightenAPISite.SightenAPISiteRequest();
			x_arrays = new List<SightenAPIArray.SightenAPIArrayRequest>();
		}

		public override Object toJsonObject(){
			if(!this.postParameters.containsKey('site')){
				this.addPostParameter('site', x_site.toJsonObject());
			}
			List<Object> arrays = new List<Object>();
			for(SightenAPIArray.SightenAPIArrayRequest x_array : x_arrays){
				arrays.add(x_array.toJsonObject());
			}
			this.addPostParameter('arrays', arrays);
			return postParameters;
		}
	}

	public with sharing class SightenAPISystemList extends SightenAPIEntity {
		public List<SightenAPISystemData> data {get;set;}
		
		public SightenAPISystemList(){
			data = new List<SightenAPISystemData>();
		}
	}
}