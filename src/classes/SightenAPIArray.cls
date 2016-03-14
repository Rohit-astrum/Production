public with sharing class SightenAPIArray extends SightenAPIEntity {

	public SightenAPIArrayData data {get;set;}
	public SightenAPIArrayRequest request {get;set;}

	public SightenAPIArray(){
		data = new SightenAPIArrayData();
		request = new SightenAPIArrayRequest();
	}

	public override String buildRequestBody(){
		return request.toJsonString();
	}

	public static String getApiName(){
		return 'solar/quotegen/array';
	}


	public class SightenAPIArrayData {
		public Double azimuth {get;set;}
		public Double capacity {get;set;}
		public Integer gen_ac_1 {get;set;}
		public Integer gen_ac_10 {get;set;}
		public Integer gen_ac_11 {get;set;}
		public Integer gen_ac_12 {get;set;}
		public Integer gen_ac_2 {get;set;}
		public Integer gen_ac_3 {get;set;}
		public Integer gen_ac_4 {get;set;}
		public Integer gen_ac_5 {get;set;}
		public Integer gen_ac_6 {get;set;}
		public Integer gen_ac_7 {get;set;}
		public Integer gen_ac_8 {get;set;}
		public Integer gen_ac_9 {get;set;}
		public Integer gen_ac_total {get;set;}
		public Integer gen_dc_total {get;set;}
		public Double generation {get;set;}
		public Integer n_inverters {get;set;}
		public Integer n_modules_series {get;set;}
		public Integer n_series_parallel {get;set;}
		public Double productivity {get;set;}
		public Double shade_pct_1 {get;set;}
		public Double shade_pct_10 {get;set;}
		public Double shade_pct_11 {get;set;}
		public Double shade_pct_12 {get;set;}
		public Double shade_pct_2 {get;set;}
		public Double shade_pct_3 {get;set;}
		public Double shade_pct_4 {get;set;}
		public Double shade_pct_5 {get;set;}
		public Double shade_pct_6 {get;set;}
		public Double shade_pct_7 {get;set;}
		public Double shade_pct_8 {get;set;}
		public Double shade_pct_9 {get;set;}
		public SightenAPIRelation x_system {get;set;}
		public Integer tilt {get;set;}

		public SightenAPIArrayData(){}
	}

	public class SightenAPIArrayRequest extends SightenAPIEntity.SightenAPIEntityRequest {
		//public SightenAPIEquipment.SightenAPIEquipmentRequest module_model {get;set;}
		//public SightenAPIEquipment.SightenAPIEquipmentRequest inverter_model {get;set;}
		public String module_model {get;set;}
		public String inverter_model {get;set;}

		public SightenAPIArrayRequest(){}

		public override Object toJsonObject(){
			//this.addPostParameter('module_model', module_model.toJsonObject());
			//this.addPostParameter('inverter_model', inverter_model.toJsonObject());
			if(String.isNotBlank(module_model)){
				this.addPostParameter('module_model', module_model);
			}
			if(String.isNotBlank(inverter_model)){
				this.addPostParameter('inverter_model', inverter_model);
			}
			return postParameters;
		}
	}

	public with sharing class SightenAPIArrayList extends SightenAPIEntity {
		public List<SightenAPIArrayData> data {get;set;}
		
		public SightenAPIArrayList(){
			data = new List<SightenAPIArrayData>();
		}
	}
}