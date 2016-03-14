public with sharing class SightenAPICreditCheck extends SightenAPIEntity {

	public SightenAPICreditCheckRequest request {get;set;}

	public SightenAPICreditCheck(){
		request = new SightenAPICreditCheckRequest();
	}

	public override String buildRequestBody(){
		return request.toJsonString();
	}

	public static String getApiName(){
		return 'ops/qualification/all/initiate';
	}

	public class SightenAPICreditCheckRequest extends SightenAPIEntity.SightenAPIEntityRequest {

		public SightenAPICreditCheckRequest(){}
	}
}