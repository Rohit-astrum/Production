/* FILE: NRGAPIOAuth2Helper.cls
 * AUTHOR: Rohit Jain
 * DATE: Jan 13, 2014
 * PURPOSE: Manage NRG OAuth 2.0 authorizations
 *          Refresh tokens are good until revoked
 *          Can use the access token
 *          Refresh token is stored in NRG_API__c.OAuth2_Refresh_Token__c 
 *          custom setting at the user level  
 * 
 * MODIFICATION HISTORY
 * //Commented by RJ on 05/5/2015
 */ 

public class NRGAPIOAuth2Helper {
  //Commented by RJ
  /*
  public static final String UTF8 = 'UTF-8';
  public static final Integer OAUTH_TIMEOUT = 30000; //30 seconds 


  private String clientId;
  private String clientSecret;
  private String redirectUri;
  private String endPoint;

  public String accessToken { get; private set; }
  private DateTime accessTokenExpires;
  private String refreshToken;
  
  public NRGAPIOAuth2Helper() {

    //get the user's refresh token, if stored    
    NRG_Lease_Fund__c setting = NRG_Lease_Fund__c.getValues('NRG Lease Fund');
    if (setting != null) {
      refreshToken = setting.OAuth2_Refresh_Token__c;
      clientid = setting.Client_Id__c;
      clientSecret = setting.Client_Secret__c;
      endPoint = setting.NRG_REST_API_End_Point__c;
    }    
  }   
    
  //turn an auth token into a refresh token (permanent until revoked)
  public void getNewAccessToken() {
    String requestBody = 
      'client_id=' + EncodingUtil.urlEncode(clientid, UTF8)
      + '&client_secret=' + EncodingUtil.urlEncode(clientSecret, UTF8)
      + '&refresh_token=' + EncodingUtil.urlEncode(refreshToken, UTF8)
      + '&grant_type=refresh_token';

    HttpRequest req = new HttpRequest();
    req.setTimeout(120000);
    req.setMethod('POST');
    req.setEndpoint(endPoint+'/services/oauth2/token');   
    req.setHeader('Accept-Encoding','compress, gzip');
    req.setHeader('Content-Type','application/x-www-form-urlencoded');
    req.setBody(requestBody);
    //req.setTimeout(OAUTH_TIMEOUT);
    
    Http http = new Http();
    HttpResponse response;
    if(!Test.isRunningTest())
    {
      response = http.send(req);  
    }
    else
    {
      response = new HttpResponse ();
      response.setStatusCode(200);
      response.setBody('{"id":"https://test.salesforce.com/id/00DK00000092PVnMAM/005K0000001bW2IIAU","issued_at":"1389980032336","scope":"full api refresh_token","instance_url":"https://cs9.salesforce.com","signature":"1SYg7Ydg3wEupBtjwdTVtT0kQaRyCrordqi126FmEso=","access_token":"00DK00000092PVn!ASAAQL.VR.n6O9ltVhVMcjn94C1b0KGCJHL3DuR91REurSPj_1aLzvsTHx_bD3qZb4rgVHfrkvDyBxz7xJulYoMv4aU05OMd"}'); 
    }    
    System.debug('*****response.getStatusCode() - '+response.getStatusCode());
    System.debug('*****response.getBody() - '+response.getBody());
    if (response.getStatusCode() != 200) {
      throw new NRGOAuth2Exception(parseError(response.getBody()));
    }    
    parseOAuthTokenResponse(response.getBody());

  }

  public String sendToNRG(String jSonRequest) {    
    getNewAccessToken();    
    HttpRequest req = new HttpRequest();
    req.setTimeout(120000);
    req.setMethod('POST');
    req.setEndpoint(endPoint+'/services/apexrest/SystemUpload');   
    req.setHeader('Accept-Encoding','compress, gzip');    
    req.setHeader('Content-Type','application/json');
    req.setHeader('Authorization','Bearer '+accessToken);

    req.setBody(jSonRequest);    
    
    Http http = new Http();
    HttpResponse response;
    if(!Test.isRunningTest())
    {
      response = http.send(req);  
    }
    else
    {
      response = new HttpResponse ();
      response.setStatusCode(200);
      response.setBody('{"Y9UtilitySavings":null,"Y8UtilitySavings":null,"Y7UtilitySavings":null,"Y6UtilitySavings":null,"Y5UtilitySavings":null,"Y4UtilitySavings":null,"Y3UtilitySavings":null,"Y2UtilitySavings":null,"Y20WithoutCost":null,"Y20WithoutConsumption":null,"Y20UtilitySavings":null,"Y20UtilityCost":null,"Y20UtilityConsumption":null,"Y20SolarProduction":null,"Y20SolarCost":null,"Y1UtilitySavings":null,"Y1UtilityCostPreSep":null,"Y1UtilityCostPreOct":null,"Y1UtilityCostPreNov":null,"Y1UtilityCostPreMay":null,"Y1UtilityCostPreMar":null,"Y1UtilityCostPreJun":null,"Y1UtilityCostPreJul":null,"Y1UtilityCostPreJan":null,"Y1UtilityCostPreFeb":null,"Y1UtilityCostPreDec":null,"Y1UtilityCostPreAug":null,"Y1UtilityCostPreApr":null,"Y1UtilityCostPostSep":null,"Y1UtilityCostPostOct":null,"Y1UtilityCostPostNov":null,"Y1UtilityCostPostMay":null,"Y1UtilityCostPostMar":null,"Y1UtilityCostPostJun":null,"Y1UtilityCostPostJul":null,"Y1UtilityCostPostJan":null,"Y1UtilityCostPostFeb":null,"Y1UtilityCostPostDec":null,"Y1UtilityCostPostAug":null,"Y1UtilityCostPostApr":null,"Y1SolarProdSep":null,"Y1SolarProdOct":null,"Y1SolarProdNov":null,"Y1SolarProdMay":null,"Y1SolarProdMar":null,"Y1SolarProdJun":null,"Y1SolarProdJul":null,"Y1SolarProdJan":null,"Y1SolarProdFeb":null,"Y1SolarProdDec":null,"Y1SolarProdAug":null,"Y1SolarProdApr":null,"Y1SolarProd":0.00,"Y1SolarCostSep":null,"Y1SolarCostOct":null,"Y1SolarCostNov":null,"Y1SolarCostMay":null,"Y1SolarCostMar":null,"Y1SolarCostJun":null,"Y1SolarCostJul":null,"Y1SolarCostJan":null,"Y1SolarCostFeb":null,"Y1SolarCostDec":null,"Y1SolarCostAug":null,"Y1SolarCostApr":null,"Y1SolarCost":null,"Y1SavingsSep":null,"Y1SavingsOct":null,"Y1SavingsNov":null,"Y1SavingsMay":null,"Y1SavingsMar":null,"Y1SavingsJun":null,"Y1SavingsJul":null,"Y1SavingsJan":null,"Y1SavingsFeb":null,"Y1SavingsDec":null,"Y1SavingsAug":null,"Y1SavingsApr":null,"Y19WithoutCost":null,"Y19WithoutConsumption":null,"Y19UtilitySavings":null,"Y19UtilityCost":null,"Y19UtilityConsumption":null,"Y19SolarProduction":null,"Y19SolarCost":null,"Y18WithoutCost":null,"Y18WithoutConsumption":null,"Y18UtilitySavings":null,"Y18UtilityCost":null,"Y18UtilityConsumption":null,"Y18SolarProduction":null,"Y18SolarCost":null,"Y17WithoutCost":null,"Y17WithoutConsumption":null,"Y17UtilitySavings":null,"Y17UtilityCost":null,"Y17UtilityConsumption":null,"Y17SolarProduction":null,"Y17SolarCost":null,"Y16WithoutCost":null,"Y16WithoutConsumption":null,"Y16UtilitySavings":null,"Y16UtilityCost":null,"Y16UtilityConsumption":null,"Y16SolarProduction":null,"Y16SolarCost":null,"Y15WithoutCost":null,"Y15WithoutConsumption":null,"Y15UtilitySavings":null,"Y15UtilityCost":null,"Y15UtilityConsumption":null,"Y15SolarProduction":null,"Y15SolarCost":null,"Y14WithoutCost":null,"Y14WithoutConsumption":null,"Y14UtilitySavings":null,"Y14UtilityCost":null,"Y14UtilityConsumption":null,"Y14SolarProduction":null,"Y14SolarCost":null,"Y13WithoutCost":null,"Y13WithoutConsumption":null,"Y13UtilitySavings":null,"Y13UtilityCost":null,"Y13UtilityConsumption":null,"Y13SolarProduction":null,"Y13SolarCost":null,"Y12WithoutCost":null,"Y12WithoutConsumption":null,"Y12UtilitySavings":null,"Y12UtilityCost":null,"Y12UtilityConsumption":null,"Y12SolarProduction":null,"Y12SolarCost":null,"Y11WithoutCost":null,"Y11WithoutConsumption":null,"Y11UtilitySavings":null,"Y11UtilityCost":null,"Y11UtilityConsumption":null,"Y11SolarProduction":null,"Y11SolarCost":null,"Y10WithoutCost":null,"Y10WithoutConsumption":null,"Y10UtilitySavings":null,"Y10UtilityCost":null,"Y10UtilityConsumption":null,"Y10SolarProduction":null,"Y10SolarCost":null,"Y09WithoutCost":null,"Y09WithoutConsumption":null,"Y09UtilityCost":null,"Y09UtilityConsumption":null,"Y09SolarProduction":null,"Y09SolarCost":null,"Y08WithoutCost":null,"Y08WithoutConsumption":null,"Y08UtilityCost":null,"Y08UtilityConsumption":null,"Y08SolarProduction":null,"Y08SolarCost":null,"Y07WithoutCost":null,"Y07WithoutConsumption":null,"Y07UtilityCost":null,"Y07UtilityConsumption":null,"Y07SolarProduction":null,"Y07SolarCost":null,"Y06WithoutCost":null,"Y06WithoutConsumption":null,"Y06UtilityCost":null,"Y06UtilityConsumption":null,"Y06SolarProduction":null,"Y06SolarCost":null,"Y05WithoutCost":null,"Y05WithoutConsumption":null,"Y05UtilityCost":null,"Y05UtilityConsumption":null,"Y05SolarProduction":null,"Y05SolarCost":null,"Y04WithoutCost":null,"Y04WithoutConsumption":null,"Y04UtilityCost":null,"Y04UtilityConsumption":null,"Y04SolarProduction":null,"Y04SolarCost":null,"Y03WithoutCost":null,"Y03WithoutConsumption":null,"Y03UtilityCost":null,"Y03UtilityConsumption":null,"Y03SolarProduction":null,"Y03SolarCost":null,"Y02WithoutCost":null,"Y02WithoutConsumption":null,"Y02UtilityCost":null,"Y02UtilityConsumption":null,"Y02SolarProduction":null,"Y02SolarCost":null,"Y01WithoutCost":null,"Y01WithoutConsumption":null,"Y01UtilityCost":null,"Y01UtilityConsumption":null,"Utility_Name":null,"TotalMonthlyPayment":null,"Tariff_Name":null,"SystemModstamp":null,"SecNRGLeadID":null,"Quote":null,"ProposalLink":null,"preTotalRate":null,"preTotalKWh":null,"preTotalCost":null,"PrePayAmount":23428.57,"postTotalRate":null,"postTotalKWh":null,"postTotalCost":null,"postMasterTariffId":null,"Post_Tariff_Code":null,"NRGSolarId":"00QK00000050HZbMAM","NRGQuoteId":"00QK00000050HZbMAM","NRGLeadID":"00QK00000050HZbMAM","MonthlyPaymentInclTax":100.68,"MonthlyPayment":95.88,"Minimum_Down":0.0,"Message":"200: OK","FirstYearDollarPerKWH":0.08}'); 
    }    
    System.debug('*****response.getStatusCode() - '+response.getStatusCode());
    if (response.getStatusCode() != 200) {
      throw new NRGOAuth2Exception(parseError(response.getBody()));
    }    

    return response.getBody();
    //parseOAuthTokenResponse(response.getBody());
  }

  public String sendQuoteToNRG(String jSonRequest) {    
    getNewAccessToken();    
    HttpRequest req = new HttpRequest();
    req.setTimeout(120000);
    req.setMethod('POST');
    req.setEndpoint(endPoint+'/services/apexrest/AcceptedQuote');   
    req.setHeader('Accept-Encoding','compress, gzip');    
    req.setHeader('Content-Type','application/json');
    req.setHeader('Authorization','Bearer '+accessToken);

    req.setBody(jSonRequest);    
    
    Http http = new Http();
    HttpResponse response;
    if(!Test.isRunningTest())
    {
      response = http.send(req);  
    }
    else
    {
      response = new HttpResponse ();
      response.setStatusCode(200);
      response.setBody('{"Message":"200: OK"}'); 
    }    
    System.debug('*****response.getStatusCode() - '+response.getStatusCode());
    if (response.getStatusCode() != 200) {
      throw new NRGOAuth2Exception(parseError(response.getBody()));
    }    

    return response.getBody();
    //parseOAuthTokenResponse(response.getBody());
  }

  public String getEquipmentList(String jSonRequest) {    
    getNewAccessToken();    
    HttpRequest req = new HttpRequest();
    req.setTimeout(120000);
    req.setMethod('POST');
    req.setEndpoint(endPoint+'/services/apexrest/GetNRGEquipmentList');   
    req.setHeader('Accept-Encoding','compress, gzip');    
    req.setHeader('Content-Type','application/json');
    req.setHeader('Authorization','Bearer '+accessToken);

    req.setBody(jSonRequest);    
    
    Http http = new Http();
    HttpResponse response;
    if(!Test.isRunningTest())
    {
      response = http.send(req);  
    }
    else
    {
      response = new HttpResponse ();
      response.setStatusCode(200);
      response.setBody('{"Message":"200: OK"}'); 
    }    
    System.debug('*****response.getStatusCode() - '+response.getStatusCode());
    if (response.getStatusCode() != 200) {
      throw new NRGOAuth2Exception(parseError(response.getBody()));
    }    
    System.debug(response.getBody());
    return response.getBody();
    //parseOAuthTokenResponse(response.getBody());
  }


  
  //parse the JSON result returned 
  private void parseOAuthTokenResponse(String responseText) {
  
    JSONParser parser = JSON.createParser(responseText);
    
    while (parser.nextToken() != null) {
      if (parser.getCurrentToken() == JSONToken.VALUE_STRING) {
        if (parser.getCurrentName() == 'refresh_token') {
          refreshToken = parser.getText();
          System.debug('**refreshToken  - '+refreshToken );
          //saveRefreshToken();
        } else if (parser.getCurrentName() == 'access_token') {
          accessToken = parser.getText();
          System.debug('**accessToken - '+accessToken );
        }
      } else if (parser.getCurrentToken() == JSONToken.VALUE_NUMBER_INT) {
        if (parser.getCurrentName() == 'expires_in') {
          Integer expiresIn = parser.getIntegerValue();
          accessTokenExpires = DateTime.now().addSeconds(expiresIn);
          System.debug('**accessTokenExpires - '+accessTokenExpires );
        }
      }
    }
  }
  */
  //Commented by RJ
  /* ERROR RESPONSE
    { "error": { "errors": [ { "domain": "global", "reason": "authError", 
    "message": "Invalid Credentials", "locationType": "header", "location": "Authorization" } ], "code": 401, "message": "Invalid Credentials" } }
  */
  //Commented by RJ
  /*
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
  
  public class NRGOAuth2Exception extends Exception {  }
  */ 
  //Commented by RJ

}