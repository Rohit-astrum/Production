global virtual class SightenAPIEntity {

	public String db_table {get;set;}
	public Integer status_code {get;set;}
	public Integer count {get;set;}
	public SightenAPIMessages messages {get;set;}

	//public HttpResponse response { get; set; }


	public SightenAPIEntity(){
		messages = new SightenAPIMessages();
	}

	public virtual String buildRequestBody(){
		return '{}';
	}


	public virtual class SightenAPIEntityData {
		public String uuid {get;set;}
		public String date_created {get;set;}
		public SightenAPIRelation created_by {get;set;}
		public String date_updated {get;set;}
		public SightenAPIRelation modified_by {get;set;}
	}

	public virtual class SightenAPIEntityRequest {
		public Map<String, Object> postParameters {get;set;}

		public SightenAPIEntityRequest(){
			postParameters = new Map<String, Object>();
		}

		public void addPostParameter(String str, Object obj){
			postParameters.put(str, obj);
		}

		public virtual Object toJsonObject(){
			return postParameters;
		}

		public virtual String toJsonString(){
			return JSON.serialize(this.toJsonObject());
		}
	}


	public class SightenAPIMessage {
		public String msg_code {get;set;}
		public String message {get;set;}
		public String timestamp {get;set;}

		public SightenAPIMessage(){}
	}

	public class SightenAPIMessages {
		public List<SightenAPIMessage> info {get;set;}
		public List<SightenAPIMessage> critical {get;set;}
		public List<SightenAPIMessage> warning {get;set;}
		public List<SightenAPIMessage> error {get;set;}

		public SightenAPIMessages(){
			info = new List<SightenAPIMessage>();
			critical = new List<SightenAPIMessage>();
			warning = new List<SightenAPIMessage>();
			error = new List<SightenAPIMessage>();
		}
	}

	public class SightenAPIRelation {
		public String uuid {get;set;}
		public String link {get;set;}
		public String natural_id {get;set;}

		public SightenAPIRelation(){}
	}

	public virtual class SightenAPIQualification extends SightenAPIEntity {
		public String date_created {get;set;}
		public String date_updated {get;set;}
		public String external_link {get;set;}
		public String name {get;set;}
		public String natural_id {get;set;}
		public String regular_ex {get;set;}
		public String required_obj {get;set;}
		public String uuid {get;set;}

		public SightenAPIQualification(){}
	}

	public class SightenAPICreditQualification extends SightenAPIQualification {
		public Double amount_approved_usd {get;set;}
		public Integer credit_score {get;set;}
		public String fraud_alerts {get;set;}
		public Boolean is_active {get;set;}
		public String status {get;set;}
		public SightenAPIRelation product {get;set;}

		public SightenAPICreditQualification(){}
	}

	public class SightenAPITitleQualification extends SightenAPIQualification {
		public Boolean is_active {get;set;}
		public String status {get;set;}
	}

	public class SightenAPIUtilityTier {
		public Double one {get;set;}
		public Double two {get;set;}
		public Double three {get;set;}
		public Double four {get;set;}
		public Double five {get;set;}
		public Double six {get;set;}
		public Double seven {get;set;}
		public Double eight {get;set;}
		public Double nine {get;set;}
		public Double ten {get;set;}
		public Double eleven {get;set;}
		public Double twelve {get;set;}

		public SightenAPIUtilityTier(){}
	}

	public class SightenAPIErrorHelper {
		public SightenAPIErrorResponse errorResponse {get;set;}
		public SightenAPIErrorResponseList errorResponseList {get;set;}

		public SightenAPIErrorHelper(){}
	}

	public class SightenAPIErrorResponse extends SightenAPIEntity {
		public SightenAPIEntityData data {get;set;}

		public SightenAPIErrorResponse(){}
	}

	public class SightenAPIErrorResponseList extends SightenAPIEntity {
		public List<List<SightenAPIErrorResponseData>> data {get;set;}

		public SightenAPIErrorResponseList(){
			data = new List<List<SightenAPIErrorResponseData>>();
		}
	}

	public class SightenAPIErrorResponseData extends SightenAPIEntityData {
		public SightenAPIRule rule {get;set;}
		public List<String> values {get;set;}

		public SightenAPIErrorResponseData(){
			values = new List<String>();
		}
	}

	public class SightenAPIRule {
		public String min_bound {get;set;}
		public String max_bound {get;set;}
		public String name {get;set;}
		public String field {get;set;}
	}
}