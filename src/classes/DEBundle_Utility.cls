public without sharing class DEBundle_Utility {

    public class DEBundleException extends Exception {} 

	public class TokenResponse {
		public String access_token {get;set;}
		public String instance_url {get;set;}
		public String id {get;set;}
		public String token_type {get;set;}
		public String issued_at {get;set;}
		public String signature {get;set;}

		public String error {get;set;}
		public String error_description {get;set;}

		public TokenResponse(){}
	}

	public virtual class sObjectResponse {
		public Integer statusCode {get;set;}
		public String id {get;set;}
		public Boolean success {get;set;}
		public List<String> errors {get;set;}

		public String message {get;set;}
		public String errorCode {get;set;}
		public List<String> fields {get;set;}
	}

	public class LeadResponse extends sObjectResponse {
		public LeadResponse(){
			this.errors = new List<String>();
			this.fields = new List<String>();
		}
	}

	public class AttachmentResponse extends sObjectResponse {
		public AttachmentResponse(){
			this.errors = new List<String>();
			this.fields = new List<String>();
		}
	}

	public static TokenResponse parseTokenResponse(HttpResponse response){
		JSONParser parser = JSON.createParser(response.getBody());
		while(parser.nextToken() != null){
			if(parser.getCurrentToken() == JSONToken.START_OBJECT){
				return (TokenResponse)parser.readValueAs(TokenResponse.class);
			}
		}
		return null;
	}

	public static LeadResponse parseLeadResponse(HttpResponse response){
		JSONParser parser = JSON.createParser(response.getBody());
		while(parser.nextToken() != null){
			if(parser.getCurrentToken() == JSONToken.START_OBJECT){
				return (LeadResponse)parser.readValueAs(LeadResponse.class);
			}
		}
		return null;
	}

	public static AttachmentResponse parseAttachmentResponse(HttpResponse response){
		JSONParser parser = JSON.createParser(response.getBody());
		while(parser.nextToken() != null){
			if(parser.getCurrentToken() == JSONToken.START_OBJECT){
				return (AttachmentResponse)parser.readValueAs(AttachmentResponse.class);
			}
		}
		return null;
	}

	public static HttpRequest prepareRequest(String endpoint, String body){
		HttpRequest request = prepareRequest(endpoint);
		request.setBody(body);

		return request;
	}

	public static HttpRequest prepareRequest(String endpoint){
		DER_Bundle_Settings__c deSettings = DER_Bundle_Settings__c.getOrgDefaults();

		HttpRequest request = new HttpRequest();
		request.setTimeout(Integer.valueOf(deSettings.DER_Request_Timeout__c));
		request.setMethod('POST');
		request.setEndpoint(endpoint);

		return request;
	}

	public static HttpResponse sendRequest(HttpRequest request){
		Http http = new Http();
		HttpResponse response;

		response = http.send(request);

		return response;
	}

	public static void LogErrorMessage(TokenResponse response, Integer total, Integer success, Integer noAttach, Integer failed){
		LogErrorMessage(response.error + ': ' + response.error_description, total, success, noAttach, failed);
	}

	public static void LogErrorMessage(LeadResponse response, Integer total, Integer success, Integer noAttach, Integer failed){
		LogErrorMessage(response.message + ': ' + response.errorCode + ' | ' + String.join(response.fields, ','), total, success, noAttach, failed);
	}

	public static void LogErrorMessage(Exception ex, Integer total, Integer success, Integer noAttach, Integer failed){
		LogErrorMessage(ex.getMessage() + ': ' + ex.getStackTraceString(), total, success, noAttach, failed);
	}

	public static void LogErrorMessage(String errorMessage, Integer total, Integer success, Integer noAttach, Integer failed){
		DER_Bundle_Settings__c deSettings = DER_Bundle_Settings__c.getOrgDefaults();

		DER_Bundle_Log__c bundleLog = new DER_Bundle_Log__c(
			Email_To_Contact__c = deSettings.DER_Salesforce_Email__c,
			Timestamp__c = Datetime.now(),
			Error_Message__c = errorMessage,
			Total_Records__c = total,
			Successful_Transfers__c = success,
			Transfers_Missing_Attachment__c = noAttach,
			Failed_Transfers__c = failed
		);
		insert bundleLog;
		
	}
}