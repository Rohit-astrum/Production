/* FILE: CPFAPIOAuthHelper.cls
 * AUTHOR: Rohit Jain
 * DATE: Mar 27, 2014
 * PURPOSE: Manage CPF OAuth 2.0 authorizations *          
 * MODIFICATION HISTORY
 * // Commented by RJ 05/5/2015
 */
public with sharing class CPFAPIOAuthHelper {
    /*
	public static final String UTF8 = 'UTF-8';
	public static final Integer OAUTH_TIMEOUT = 120000; //30 seconds 

	public String apiusername;
	public String apikey;
    public String templateId;	
	public String endPoint;
    public String currentUserEmail;
    public String authorizedSigner;
    public String prepaidTemplateId;

	public CPFAPIOAuthHelper() {
		//get the user's refresh token, if stored    
	    CPF_Lease_Fund__c setting = CPF_Lease_Fund__c.getValues('CPF Lease Fund');
	    if (setting != null) {
	      apiusername = setting.Api_Username__c;
	      apikey = setting.Api_key__c;	      
	      endPoint = setting.EndPoint__c;
          templateId = setting.Quick_Template_Id__c;
          prepaidTemplateId = setting.Prepaid_Template_Id__c;
          authorizedSigner = setting.Authorized_Signer__c; 
	    }   
        currentUserEmail = UserInfo.getUserEmail(); 		
	}

	public String submitWebRequest(String xmlRequest,String apiName) {    
	   
	    HttpRequest req = new HttpRequest();
	    req.setTimeout(OAUTH_TIMEOUT);
	    req.setMethod('POST');
	    req.setEndpoint(endPoint+apiName);   
	    req.setHeader('Accept-Encoding','compress, gzip');    
	    req.setHeader('Content-Type','application/xml');	    

	    req.setBody(xmlRequest);    
	    
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
	      response.setBody('<Response><Status>success</Status><Message>The Job was successfully created</Message><ProposalId>33829492-df7b-11e3-8898-bc764e1176ae</ProposalId><Job><Customer><CustomerId>e12fc8da-df76-11e3-8898-bc764e1176ae</CustomerId></Customer><Proposal><Quotes><PVQuote> <YearOneProduction>10552.3735625</YearOneProduction></PVQuote></Quotes><FinancingMethods><FinancingMethod><Type>ppa</Type><ProductName>KW PPA Monthly I</ProductName><Term>20</Term><MonthlyPayment>128.38721167708</MonthlyPayment><DownPayment>1000.00</DownPayment><AnnualIncrease>2.900</AnnualIncrease><PricePerWatt>3.9</PricePerWatt><YearZeroCumulativeCashFlow>26050</YearZeroCumulativeCashFlow><Errors><Error><ErrorMessage>Test</ErrorMessage></Error><Error><ErrorMessage>Test2</ErrorMessage></Error></Errors></FinancingMethod></FinancingMethods></Proposal></Job></Response>'); 
	    }    
	    System.debug('*****response.getStatusCode() - '+response.getStatusCode());
	    //if (response.getStatusCode() != 200) {
	      //throw new CPFOAuthException('Error');
	    //}    

	    return response.getBody();
	    //parseOAuthTokenResponse(response.getBody());
    }

    public class Customer
    {
    	Public String CustomerId;
    	Public String ExternalCustomer;
    	Public String CFirstname;
    	Public String CLastname;
    	Public String CPhone1;
    	Public String CPhone2;
    	Public String CPhone3;
    	Public String CEmail;
    	Public String CAddress1;
    	Public String CCity;
    	Public String CState;
    	Public String CZip;
    	Public String CCompany;
    	Public String CTitle;
    	Public String Probability;
    	Public String InterestLevel;
    	Public Double CBudget;
    	Public String CType;
        Public String CSecondaryFirstname;
        Public String CSecondaryLastname;
        Public String CSecondaryPhone;        
        Public String CSecondaryEmail;
    	Public String NewBuild;
    	Public Double FederalTaxRate;
    	Public Double StateTaxRate;
    	Public String UtilityName;
    	Public String CurrentRateSchedule;
    	Public String CurrentRateCode;	
    	Public String CurrentRateScheduleId;
    	Public String ProposedRateScheduleId;
        Public String QuickTemplateId;
        Public String PrepaidQuickTemplateId;
    	public Double AverageElectricityBill;
        public Double AverageElectricityKWH;
        public Double JanElectricityBill;
        public Double FebElectricityBill;
        public Double MarElectricityBill;
        public Double AprElectricityBill;
        public Double MayElectricityBill;
        public Double JunElectricityBill;
        public Double JulElectricityBill;
        public Double AugElectricityBill;
        public Double SepElectricityBill;
        public Double OctElectricityBill;
        public Double NovElectricityBill;
        public Double DecElectricityBill;
        public Double JanElectricityKWH;
        public Double FebElectricityKWH;
        public Double MarElectricityKWH;
        public Double AprElectricityKWH;
        public Double MayElectricityKWH;
        public Double JunElectricityKWH;
        public Double JulElectricityKWH;
        public Double AugElectricityKWH;
        public Double SepElectricityKWH;
        public Double OctElectricityKWH;
        public Double NovElectricityKWH;
        public Double DecElectricityKWH;
        public Boolean averageKWH;
        public Boolean averageBill;
        public Boolean monthlyKWH;
        public Boolean monthlyBill;
    }

    public class Proposal
    {
        Public Double DownPayment;
        Public Double AnnualIncrease;
        Public String PricePerWatt;
        Public String Name;
        Public String ExternalProposalId;       
    }

    public class PvArray
    {
    	Public String ModuleId;
    	Public String ModuleQuantity;
    	Public String InverterIndex;
    	Public String Shade;
    	Public String Tilt;
    	Public String Azimuth;
    }

    public class Inverter
    {
    	Public String InverterId;
    	Public String InverterQuantity;
    	Public String Index;   
    }

    public class CPFOAuthException extends Exception {  }
    */
}