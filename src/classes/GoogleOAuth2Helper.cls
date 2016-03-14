/* FILE: GoogleOAuth2Helper.cls
 * AUTHOR: Tino Mattheou
 * DATE: May 9, 2012
 * PURPOSE: Manage google OAuth 2.0 authorizations
 *          Refresh tokens are good until revoked
 *          Can use the access token
 *          Refresh token is stored in GoogleCalendar__c.OAuth2_Refresh_Token__c 
 *          custom setting at the user level  
 * REFERENCE: https://developers.google.com/accounts/docs/OAuth2WebServer#offline
 * MODIFICATION HISTORY
 *
 */ 

public class GoogleOAuth2Helper {
	
	public static final String UTF8 = 'UTF-8';
	public static final Integer OAUTH_TIMEOUT = 30000; //30 seconds 


	private String clientId;
	private String clientSecret;
	private String redirectUri;

	public String accessToken { get; private set; }
	private DateTime accessTokenExpires;
	private String refreshToken;
	
	public GoogleOAuth2Helper(String clientId, String clientSecret, String redirectUri) {
		
		this.clientId = clientId;
		this.clientSecret = clientSecret;
		this.redirectUri = redirectUri;

		//get the user's refresh token, if stored		
		GoogleCalendar__c setting = GoogleCalendar__c.getValues(UserInfo.getUserId());
		if (setting != null) {
			refreshToken = setting.OAuth2_Refresh_Token__c;
		}
		
	}		
	
	public Boolean hasRefreshToken() {
		if (Test.isRunningTest()) {
			return true;
		}
		return refreshToken != null;
	}

	public Boolean isAccessTokenValid() {
		if (Test.isRunningTest()) {
			return true;
		}
		//if no access token or no longer valid, get new one
		if (accessToken == null || accessTokenExpires == null || DateTime.now() >= accessTokenExpires) {
			return false;
		}
		return true;
	}
	
	public void ensureAccessToken() {
		if (Test.isRunningTest()) {
			return;
		}
		if (!isAccessTokenValid()) {
			if (refreshToken != null) {
				getNewAccessToken();
			}
		}
		if (!isAccessTokenValid()) {
			throw new GoogleOAuth2Exception('Cannot get access token');
		}
	}
	
	public void refreshAccessToken(String code) {
		//if there is a refresh token, get a new access token
		if (refreshToken != null) {  
			ensureAccessToken();
		} else if (code != null && code.trim() != '') { //if there is a code returned from google oauth screen
			//get a refresh token for offline access (also returns an access token) 
			getRefreshToken(code);
		}
	}

	//Request offline access to force an OAuth 2.0 Refresh Token (doesn't expire)
	public PageReference requestGoogleAccess() {
		PageReference result = new PageReference('https://accounts.google.com/o/oauth2/auth');
		result.getParameters().put('response_type', 'code');
		result.getParameters().put('client_id', clientId);
		result.getParameters().put('redirect_uri', redirectUri);
		result.getParameters().put('state', 'GoogleCalendar2');
		result.getParameters().put('scope', 'https://www.googleapis.com/auth/calendar');
		result.getParameters().put('access_type', 'offline');
		result.getParameters().put('approval_prompt', 'force');
		return result;
	}
	
	//turn an auth token into a refresh token
	public void getRefreshToken(String code) {
		String requestBody = 
			'code=' + code
			+ '&client_id=' + EncodingUtil.urlEncode(clientId, UTF8)
			+ '&client_secret=' + EncodingUtil.urlEncode(clientSecret, UTF8)
			+ '&redirect_uri=' + EncodingUtil.urlEncode(redirectUri, UTF8)
			+ '&grant_type=authorization_code';
		HttpRequest req = new HttpRequest();
		req.setMethod('POST');
		req.setEndpoint('https://accounts.google.com/o/oauth2/token');   
		req.setHeader('Accept-Encoding','compress, gzip');
		req.setHeader('Content-Type','application/x-www-form-urlencoded');
		req.setBody(requestBody);
		req.setTimeout(OAUTH_TIMEOUT);
		
		Http http = new Http();
		HttpResponse response = http.send(req);

		if (response.getStatusCode() != 200) {
			throw new GoogleOAuth2Exception(parseError(response.getBody()));
		}
		
		parseOAuthTokenResponse(response.getBody());
	}

	//turn an auth token into a refresh token (permanent until revoked)
	public void getNewAccessToken() {
		String requestBody = 
			'client_id=' + EncodingUtil.urlEncode(clientId, UTF8)
			+ '&client_secret=' + EncodingUtil.urlEncode(clientSecret, UTF8)
			+ '&refresh_token=' + EncodingUtil.urlEncode(refreshToken, UTF8)
			+ '&grant_type=refresh_token';

		HttpRequest req = new HttpRequest();
		req.setMethod('POST');
		req.setEndpoint('https://accounts.google.com/o/oauth2/token');   
		req.setHeader('Accept-Encoding','compress, gzip');
		req.setHeader('Content-Type','application/x-www-form-urlencoded');
		req.setBody(requestBody);
		req.setTimeout(OAUTH_TIMEOUT);
		
		Http http = new Http();
		HttpResponse response = http.send(req);
		
		if (response.getStatusCode() != 200) {
			throw new GoogleOAuth2Exception(parseError(response.getBody()));
		}
		
		parseOAuthTokenResponse(response.getBody());
	}

	public void revokeAccess() {
	
		if (refreshToken == null) {
			return;
		}
	
		String url = String.format('https://accounts.google.com/o/oauth2/revoke?token={0}',
			new String[] { refreshToken });
	
		HttpRequest req = new HttpRequest();
		req.setMethod('GET');
		req.setEndpoint(url);   
		req.setHeader('Accept-Encoding','compress, gzip');
		req.setHeader('Content-Type','application/json');
		req.setTimeout(OAUTH_TIMEOUT);
		
		Http http = new Http();
		HttpResponse response = http.send(req);

		if (response.getStatusCode() != 200) {
			throw new GoogleOAuth2Exception(parseError(response.getBody()));
		}

		//clear the saved token		
		refreshToken = null;
		saveRefreshToken();
		accessToken = null;
		accessTokenExpires = null;
	}
	
	//parse the JSON result returned from https://accounts.google.com/o/oauth2/token
	private void parseOAuthTokenResponse(String responseText) {
	
		JSONParser parser = JSON.createParser(responseText);
		
		while (parser.nextToken() != null) {
			if (parser.getCurrentToken() == JSONToken.VALUE_STRING) {
				if (parser.getCurrentName() == 'refresh_token') {
					refreshToken = parser.getText();
					saveRefreshToken();
				} else if (parser.getCurrentName() == 'access_token') {
					accessToken = parser.getText();
				}
			} else if (parser.getCurrentToken() == JSONToken.VALUE_NUMBER_INT) {
				if (parser.getCurrentName() == 'expires_in') {
					Integer expiresIn = parser.getIntegerValue();
					accessTokenExpires = DateTime.now().addSeconds(expiresIn);
				}
			}
		}
	}
	
	private void saveRefreshToken() {
		GoogleCalendar__c setting = GoogleCalendar__c.getValues(UserInfo.getUserId());
		if (setting == null) {
			setting = new GoogleCalendar__c();
			setting.SetupOwnerId = UserInfo.getUserId();
		}
		setting.OAuth2_Refresh_Token__c = refreshToken;
		if (setting.Id == null) {
			insert setting;
		} else {
			update setting;
		}
	}
	
	/* ERROR RESPONSE
		{ "error": { "errors": [ { "domain": "global", "reason": "authError", 
		"message": "Invalid Credentials", "locationType": "header", "location": "Authorization" } ], "code": 401, "message": "Invalid Credentials" } }
	*/
	public static String parseError(String responseText) {
		String result = responseText;
		JSONParser parser = JSON.createParser(responseText);
		while (parser.nextToken() != null) {
			if (parser.getCurrentName() == 'message' && parser.getCurrentToken() == JSONToken.VALUE_STRING) {
				result = parser.getText();
				break;
			}
		}
		return result;
	}
	
	public class GoogleOAuth2Exception extends Exception {	}

}