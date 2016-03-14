/* FILE: SightenAPIHelper.cls
 * AUTHOR: Steven Zilligen
 * DATE: 12/8/2015
 * PURPOSE: Manage Sighten API calls
 * MODIFICATION HISTORY
 */
 public with sharing class SightenAPIHelper {

	public class SightenAPIException extends Exception {}

	public class SightenAPIHelperResponse {
		public Integer responseStatusCode {get;set;}
		public String responseBody {get;set;}
		public Blob responseBlob {get;set;}
		public SightenAPIHelperResponseDetail responseDetail {get;set;}
	}

	public class SightenAPIHelperResponseDetail {
		public Integer detailStatusCode {get;set;}
		public String detailBody {get;set;}
		public Map<String, String> uuidUpdates {get;set;}

		public SightenAPIHelperResponseDetail(){
			uuidUpdates = new Map<String, String>();
		}
	}

	public static final String PARSEQUOTE = 'P101';
	public static final String PARSESITE = 'P102';
	public static final String PARSECONTACT = 'P103';
	public static final String RESOLVEFROMQUOTE = 'R101';
	public static final String RESOLVEFROMSITE = 'R102';
	public static final String UPDATEQUOTE = 'U101';
	public static final String UPDATESITE = 'U102';
	public static final String UPDATECONTACT = 'U103';

 	private static final Integer REQUEST_TIMEOUT = 120000;

 	private SightenAPISettings__c sightenSettings {get;private set;}


	public SightenAPIHelper(){
		sightenSettings = SightenAPISettings__c.getOrgDefaults();
	}


	public SightenAPIHelperResponse doGetRequest(String id, String apiName){
		return doGetRequest(id, apiName, false);
	}

	public SightenAPIHelperResponse doGetRequest(String id, String apiName, Boolean asBlob){
		HttpRequest request = prepareRequest('GET', apiName + '/' + id);
		HttpResponse response = sendRequest(request);

		SightenAPIHelperResponse helperResponse = new SightenAPIHelperResponse();
		helperResponse.responseStatusCode = response.getStatusCode();
		if(!asBlob || response.getStatusCode() != 200){
			helperResponse.responseBody = response.getBody();
		} else {
			helperResponse.responseBlob = response.getBodyAsBlob();
		}
		return helperResponse;
	}

	public SightenAPIHelperResponse doPostRequest(String jsonBody, String apiName){
		HttpRequest request = prepareRequest('POST', apiName, jsonBody);
		HttpResponse response = sendRequest(request);

		SightenAPIHelperResponse helperResponse = new SightenAPIHelperResponse();
		helperResponse.responseStatusCode = response.getStatusCode();
		helperResponse.responseBody = response.getBody();
		return helperResponse;
	}

/*	public SightenAPIHelperResponse doPutRequest(String jsonBody, String apiName){
		HttpRequest request = prepareRequest('PUT', apiName, jsonBody);
		HttpResponse response = sendRequest(request);

		SightenAPIHelperResponse helperResponse = new SightenAPIHelperResponse();
		helperResponse.responseStatusCode = response.getStatusCode();
		helperResponse.responseBody = response.getBody();
		return helperResponse;
	}*/

	public SightenAPIEntity parseResponseBody(String responseBody, System.Type entityType){
		String jsonBody = replaceReservedWords(responseBody);
		system.debug('**SZ: jsonBody = ' + jsonBody);

		Integer count = 0;
		JSONParser parser = JSON.createParser(jsonBody);
		while(parser.nextToken() != null){
			if(parser.getCurrentToken() == JSONToken.START_OBJECT){
				SightenAPIEntity tempEntity = (SightenAPIEntity)parser.readValueAs(SightenAPIEntity.class);
				count = tempEntity.count;
			}
		}

		parser = JSON.createParser(jsonBody);
		while(parser.nextToken() != null){
			if(parser.getCurrentToken() == JSONToken.START_OBJECT){
				if(entityType == SightenAPIEntity.class){
					return (SightenAPIEntity)parser.readValueAs(entityType);
				} else if((entityType == SightenAPIAddress.SightenAPIAddressList.class && count == 1) || entityType == SightenAPIAddress.class){
					return (SightenAPIAddress)parser.readValueAs(entityType);
				} else if(entityType == SightenAPIAddress.SightenAPIAddressList.class){
					return (SightenAPIAddress.SightenAPIAddressList)parser.readValueAs(entityType);
				} else if((entityType == SightenAPIArray.SightenAPIArrayList.class && count == 1) || entityType == SightenAPIArray.class){
					return (SightenAPIArray)parser.readValueAs(entityType);
				} else if(entityType == SightenAPIArray.SightenAPIArrayList.class){
					return (SightenAPIArray.SightenAPIArrayList)parser.readValueAs(entityType);
				} else if((entityType == SightenAPIContact.SightenAPIContactList.class && count == 1) || entityType == SightenAPIContact.class){
					return (SightenAPIContact)parser.readValueAs(entityType);
				} else if(entityType == SightenAPIContact.SightenAPIContactList.class){
					return (SightenAPIContact.SightenAPIContactList)parser.readValueAs(entityType);
				} else if((entityType == SightenAPIContract.SightenAPIContractList.class && count == 1) || entityType == SightenAPIContract.class){
					return (SightenAPIContract)parser.readValueAs(entityType);
				} else if(entityType == SightenAPIContract.SightenAPIContractList.class){
					return (SightenAPIContract.SightenAPIContractList)parser.readValueAs(entityType);
				} else if((entityType == SightenAPICredit.SightenAPICreditList.class && count == 1) || entityType == SightenAPICredit.class){
					return (SightenAPICredit)parser.readValueAs(entityType);
				} else if(entityType == SightenAPICredit.SightenAPICreditList.class){
					return (SightenAPICredit.SightenAPICreditList)parser.readValueAs(entityType);
//				} else if((entityType == SightenAPIInverter.SightenAPIInverterList.class && count == 1) || entityType == SightenAPIInverter.class){
//					return (SightenAPIInverter)parser.readValueAs(entityType);
//				} else if(entityType == SightenAPIInverter.SightenAPIInverterList.class){
//					return (SightenAPIInverter.SightenAPIInverterList)parser.readValueAs(entityType);
//				} else if((entityType == SightenAPIModule.SightenAPIModuleList.class && count == 1) || entityType == SightenAPIModule.class){
//					return (SightenAPIModule)parser.readValueAs(entityType);
//				} else if(entityType == SightenAPIModule.SightenAPIModuleList.class){
//					return (SightenAPIModule.SightenAPIModuleList)parser.readValueAs(entityType);
//				} else if((entityType == SightenAPIProduct.SightenAPIProductList.class && count == 1) || entityType == SightenAPIProduct.class){
//					return (SightenAPIProduct)parser.readValueAs(entityType);
//				} else if(entityType == SightenAPIProduct.SightenAPIProductList.class){
//					return (SightenAPIProduct.SightenAPIProductList)parser.readValueAs(entityType);
//				} else if((entityType == SightenAPIProposal.SightenAPIProposalList.class && count == 1) || entityType == SightenAPIProposal.class){
//					return (SightenAPIProposal)parser.readValueAs(entityType);
//				} else if(entityType == SightenAPIProposal.SightenAPIProposalList.class){
//					return (SightenAPIProposal.SightenAPIProposalList)parser.readValueAs(entityType);
				} else if((entityType == SightenAPIQuote.SightenAPIQuoteList.class && count == 1) || entityType == SightenAPIQuote.class){
					return (SightenAPIQuote)parser.readValueAs(entityType);
				} else if(entityType == SightenAPIQuote.SightenAPIQuoteList.class){
					return (SightenAPIQuote.SightenAPIQuoteList)parser.readValueAs(entityType);
				} else if((entityType == SightenAPISite.SightenAPISiteList.class && count == 1) || entityType == SightenAPISite.class){
					return (SightenAPISite)parser.readValueAs(entityType);
				} else if(entityType == SightenAPISite.SightenAPISiteList.class){
					return (SightenAPISite.SightenAPISiteList)parser.readValueAs(entityType);
				} else if((entityType == SightenAPISystem.SightenAPISystemList.class && count == 1) || entityType == SightenAPISystem.class){
					return (SightenAPISystem)parser.readValueAs(entityType);
				} else if(entityType == SightenAPISystem.SightenAPISystemList.class){
					return (SightenAPISystem.SightenAPISystemList)parser.readValueAs(entityType);
//				} else if((entityType == SightenAPIUtility.SightenAPIUtilityList.class && count == 1) || entityType == SightenAPIUtility.class){
//					return (SightenAPIUtility)parser.readValueAs(entityType);
//				} else if(entityType == SightenAPIUtility.SightenAPIUtilityList.class){
//					return (SightenAPIUtility.SightenAPIUtilityList)parser.readValueAs(entityType);
				} else if(entityType == SightenAPIEntity.SightenAPICreditQualification.class){
					return (SightenAPIEntity.SightenAPICreditQualification)parser.readValueAs(entityType);
				} else {
					return null;
				}
			}
		}
		return null;
	}

	public SightenAPIEntity.SightenAPIEntityData parseResponseDataBody(String responseBody, System.Type entityType){
		String jsonBody = replaceReservedWords(responseBody);
		system.debug('**SZ: jsonBody = ' + jsonBody);

		JSONParser parser = JSON.createParser(jsonBody);
		while(parser.nextToken() != null){
			if(parser.getCurrentToken() == JSONToken.START_OBJECT){
				if(entityType == SightenAPIEntity.SightenAPIEntityData.class){
					return (SightenAPIEntity.SightenAPIEntityData)parser.readValueAs(entityType);
				} else if(entityType == SightenAPICredit.SightenAPICreditData.class){
					return (SightenAPICredit.SightenAPICreditData)parser.readValueAs(entityType);
				} else if(entityType == SightenAPIQuote.SightenAPIQuoteData.class){
					return (SightenAPIQuote.SightenAPIQuoteData)parser.readValueAs(entityType);
				} else {
					return null;
				}
			}
		}
		return null;
	}

	public SightenAPIEntity.SightenAPIErrorHelper parseResponseBodyToError(String responseBody){
		String jsonBody = replaceReservedWords(responseBody);
		system.debug('**SZ: jsonBody = ' + jsonBody);

		SightenAPIEntity.SightenAPIErrorHelper errorHelper = new SightenAPIEntity.SightenAPIErrorHelper();
		JSONParser parser = null;
		try{
			parser = JSON.createParser(jsonBody);
			errorHelper.errorResponse = (SightenAPIEntity.SightenAPIErrorResponse)parser.readValueAs(SightenAPIEntity.SightenAPIErrorResponse.class);
		} catch(Exception ex){
			parser = JSON.createParser(jsonBody);
			errorHelper.errorResponseList = (SightenAPIEntity.SightenAPIErrorResponseList)parser.readValueAs(SightenAPIEntity.SightenAPIErrorResponseList.class);
		}
		return errorHelper;
	}

    public static void LogErrorMessage(String recordId, String errorMessage, String errorDetail){
    	String shortMessage = '';
    	if(errorMessage.length() > 255){
    		shortMessage = errorMessage.left(255);
    	} else {
    		shortMessage = errorMessage;
    	}
        Sighten_Callback_Log__c log = new Sighten_Callback_Log__c(
        	RelatedId__c = recordId,
            Error_Detail__c = errorDetail,
            Error_Message__c = shortMessage,
            Timestamp__c = Datetime.now()
        );
        insert log;
    }

    public static Sighten_Callback_Log__c GetLatestLog(String recordId){
    	List<Sighten_Callback_Log__c> latestLog = [SELECT Id, RelatedId__c, Error_Message__c, Error_Detail__c, Timestamp__c FROM Sighten_Callback_Log__c WHERE RelatedId__c = :recordId ORDER BY Timestamp__c DESC LIMIT 1];
    	if(latestLog.size() == 1){
    		return latestLog[0];
    	} else {
    		return null;
    	}
    }

    public static List<Sighten_Callback_Log__c> GetLastFiveLogs(String recordId){
    	List<Sighten_Callback_Log__c> latestLog = [SELECT Id, RelatedId__c, Error_Message__c, Error_Detail__c, Timestamp__c FROM Sighten_Callback_Log__c WHERE RelatedId__c = :recordId ORDER BY Timestamp__c DESC LIMIT 5];
    	if(latestLog.size() == 0){
    		return null;
    	} else {
    		return latestLog;
    	}
    }


	private HttpRequest prepareRequest(String method, String apiParam){
		HttpRequest request = new HttpRequest();
		request.setTimeout(REQUEST_TIMEOUT);
		request.setMethod(method);
		request.setEndpoint(sightenSettings.API_URL__c + apiParam);
	    request.setHeader('Accept-Encoding','compress, gzip');
		request.setHeader('Content-Type', 'application/json');
		request.setHeader('Authorization', 'Token ' + sightenSettings.Authorization_Token__c);

		return request;
	}

	private HttpRequest prepareRequest(String method, String apiParam, String jsonBody){
		HttpRequest request = prepareRequest(method, apiParam + '/');
		request.setBody(jsonBody);

		return request;
	}

	private HttpResponse sendRequest(HttpRequest request){
		Http http = new Http();
		HttpResponse response;

		response = http.send(request);
		return response;
	}

	private String replaceReservedWords(String jsonBody){
		jsonBody = jsonBody.replace('system', 'x_system');
		jsonBody = jsonBody.replace('\"1\"', '\"one\"');
		jsonBody = jsonBody.replace('\"2\"', '\"two\"');
		jsonBody = jsonBody.replace('\"3\"', '\"three\"');
		jsonBody = jsonBody.replace('\"4\"', '\"four\"');
		jsonBody = jsonBody.replace('\"5\"', '\"five\"');
		jsonBody = jsonBody.replace('\"6\"', '\"six\"');
		jsonBody = jsonBody.replace('\"7\"', '\"seven\"');
		jsonBody = jsonBody.replace('\"8\"', '\"eight\"');
		jsonBody = jsonBody.replace('\"9\"', '\"nine\"');
		jsonBody = jsonBody.replace('\"10\"', '\"ten\"');
		jsonBody = jsonBody.replace('\"11\"', '\"eleven\"');
		jsonBody = jsonBody.replace('\"12\"', '\"twelve\"');
		return jsonBody;
	}
}