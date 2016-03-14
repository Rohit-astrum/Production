public with sharing class SightenAPIContract extends SightenAPIEntity {

	public SightenAPIContractData data {get;set;}
	public SightenAPIContractRequest request {get;set;}
	
	public SightenAPIContract(){
		data = new SightenAPIContractData();
		request = new SightenAPIContractRequest();
	}

	public override String buildRequestBody(){
		return request.toJsonString();
	}

	public static String getApiName(String apiType){
		if(apiType == 'send'){
			return 'solar/send_contract';
		} else if(apiType == 'download'){
			return 'solar/download_contract';
		} else {
			return '';
		}
	}

	
	public class SightenAPIContractData extends SightenAPIEntity.SightenAPIEntityData {
		public String doc_id {get;set;}
		public String download_url {get;set;}
		public String sent_to {get;set;}

		public SightenAPIContractData(){}
	}

	public class SightenAPIContractRequest extends SightenAPIEntity.SightenAPIEntityRequest {
		public String quote_id {get;set;}

		public SightenAPIContractRequest(){}

		public override Object toJsonObject(){
			if(!postParameters.containsKey('quote_id') && String.isNotBlank(quote_id)){
				this.addPostParameter('quote_id', quote_id);
			}
			return postParameters;
		}
	}

	public with sharing class SightenAPIContractList extends SightenAPIEntity {
		public List<SightenAPIContractData> data {get;set;}
		
		public SightenAPIContractList(){
			data = new List<SightenAPIContractData>();
		}
	}
}