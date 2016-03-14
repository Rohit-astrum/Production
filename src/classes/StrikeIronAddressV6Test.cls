/* FILE: StrikeIronAddressV6Test.cls
 * AUTHOR: Tino Mattheou
 * DATE: October 25, 2012
 * PURPOSE: Code coverage for StrikeIronAddressV6 class  
 * MODIFICATION HISTORY
 *
 */ 
 
@isTest
global class StrikeIronAddressV6Test {

	static testMethod void coverStrikeIron() {
		
		//FORCES CODE COVERAGE TO WORK
		StrikeIronAddressV6 si = new StrikeIronAddressV6();
		
		//instantiate classes
		StrikeIronAddressV6.NorthAmericanAddressVerificationResponse_element naVerifyEl =
			new StrikeIronAddressV6.NorthAmericanAddressVerificationResponse_element();
		StrikeIronAddressV6.GetStatusCodes_element statusCodesEl =
			new StrikeIronAddressV6.GetStatusCodes_element();
		StrikeIronAddressV6.SIWsStatus siwStatus =
			new StrikeIronAddressV6.SIWsStatus();
		StrikeIronAddressV6.SIWsOutputOfSIWsResultArrayOfAddressDistanceResultWithStatus siwDistances =
			new StrikeIronAddressV6.SIWsOutputOfSIWsResultArrayOfAddressDistanceResultWithStatus();
		StrikeIronAddressV6.ArrayOfAddressDistanceResultWithStatus addressDistances =
			new StrikeIronAddressV6.ArrayOfAddressDistanceResultWithStatus();
		StrikeIronAddressV6.AddressDistanceResultWithStatus addressStatuses =
			new StrikeIronAddressV6.AddressDistanceResultWithStatus();
		StrikeIronAddressV6.GetStatusCodesResponse_element statusCodes =
			new StrikeIronAddressV6.GetStatusCodesResponse_element();


		StrikeIronAddressV6.ArrayOfSIWsStatus swiStatuses =
			new StrikeIronAddressV6.ArrayOfSIWsStatus();
		StrikeIronAddressV6.GetStatusCodesForMethodResponse_element statusMethods =
			new StrikeIronAddressV6.GetStatusCodesForMethodResponse_element();
		StrikeIronAddressV6.NorthAmericanAddressWithStatus naWithStatus =
			new StrikeIronAddressV6.NorthAmericanAddressWithStatus();
		StrikeIronAddressV6.NorthAmericanAddressVerificationBatchResponse_element naBatchVerify =
			new StrikeIronAddressV6.NorthAmericanAddressVerificationBatchResponse_element();
		StrikeIronAddressV6.NorthAmericanAddressVerification_element naVerify =
			new StrikeIronAddressV6.NorthAmericanAddressVerification_element();
			
		StrikeIronAddressV6.AddressDistanceCalculatorBatchResponse_element  distanceBatch =
			new StrikeIronAddressV6.AddressDistanceCalculatorBatchResponse_element ();
		StrikeIronAddressV6.AddressDistanceResult distantResult =
			new StrikeIronAddressV6.AddressDistanceResult ();
		StrikeIronAddressV6.ArrayOfMethodStatusRecord statusArray =
			new StrikeIronAddressV6.ArrayOfMethodStatusRecord ();
		StrikeIronAddressV6.USGeocode usGeo =
			new StrikeIronAddressV6.USGeocode ();
		StrikeIronAddressV6.SIWsOutputOfAddressDistanceResult siwDistance =
			new StrikeIronAddressV6.SIWsOutputOfAddressDistanceResult ();

		StrikeIronAddressV6.SIWsResultArrayOfMethodStatusRecord siwArray =
			new StrikeIronAddressV6.SIWsResultArrayOfMethodStatusRecord ();
		StrikeIronAddressV6.Geocode geo =
			new StrikeIronAddressV6.Geocode ();
		StrikeIronAddressV6.ArrayOfServiceInfoRecord addressService =
			new StrikeIronAddressV6.ArrayOfServiceInfoRecord ();
		StrikeIronAddressV6.GetServiceInfoResponse_element serviceInfo =
			new StrikeIronAddressV6.GetServiceInfoResponse_element ();
			
		StrikeIronAddressV6.MethodStatusRecord msr =
			new StrikeIronAddressV6.MethodStatusRecord  ();
		StrikeIronAddressV6.SIWsOutputOfSIWsResultArrayOfMethodStatusRecord soosraaomsr =
			new StrikeIronAddressV6.SIWsOutputOfSIWsResultArrayOfMethodStatusRecord ();
		StrikeIronAddressV6.ServiceInfoRecord sir =
			new StrikeIronAddressV6.ServiceInfoRecord ();
		StrikeIronAddressV6.AddressInput ai =
			new StrikeIronAddressV6.AddressInput();
		StrikeIronAddressV6.SIWsOutputOfNorthAmericanAddress soonaa =
			new StrikeIronAddressV6.SIWsOutputOfNorthAmericanAddress();
		StrikeIronAddressV6.SIWsOutputOfSIWsResultArrayOfNorthAmericanAddressWithStatus soosraonaaws =
			new StrikeIronAddressV6.SIWsOutputOfSIWsResultArrayOfNorthAmericanAddressWithStatus();
		StrikeIronAddressV6.SIWsResultWithStatus srws =
			new StrikeIronAddressV6.SIWsResultWithStatus();
		StrikeIronAddressV6.ArrayOfNorthAmericanAddressWithStatus anaaws =
			new StrikeIronAddressV6.ArrayOfNorthAmericanAddressWithStatus();
		StrikeIronAddressV6.USAddress usa =
			new StrikeIronAddressV6.USAddress();
		StrikeIronAddressV6.SIWsResultArrayOfAddressDistanceResultWithStatus sraoadrws =
			new StrikeIronAddressV6.SIWsResultArrayOfAddressDistanceResultWithStatus();
		StrikeIronAddressV6.AddressDistanceAddress ada =
			new StrikeIronAddressV6.AddressDistanceAddress();
		StrikeIronAddressV6.ArrayOfNorthAmericanBatchAddress aonaba =
			new StrikeIronAddressV6.ArrayOfNorthAmericanBatchAddress();
		StrikeIronAddressV6.SIWsOutputOfMethodStatusRecord soomsr =
			new StrikeIronAddressV6.SIWsOutputOfMethodStatusRecord  ();

		StrikeIronAddressV6.NorthAmericanBatchAddress naba =
			new StrikeIronAddressV6.NorthAmericanBatchAddress();
		StrikeIronAddressV6.SIWsResultArrayOfSIWsStatus sraoss =
			new StrikeIronAddressV6.SIWsResultArrayOfSIWsStatus();
		StrikeIronAddressV6.CanadaAddress ca =
			new StrikeIronAddressV6.CanadaAddress();
		StrikeIronAddressV6.ArrayOfAddressDistanceAddress aoada =
			new StrikeIronAddressV6.ArrayOfAddressDistanceAddress();
		StrikeIronAddressV6.SIWsResultArrayOfServiceInfoRecord sraosir =
			new StrikeIronAddressV6.SIWsResultArrayOfServiceInfoRecord();
			
		StrikeIronAddressV6.SIWsResultArrayOfNorthAmericanAddressWithStatus sraonaaws =
			new StrikeIronAddressV6.SIWsResultArrayOfNorthAmericanAddressWithStatus();
		StrikeIronAddressV6.NorthAmericanAddress naa =
			new StrikeIronAddressV6.NorthAmericanAddress();
		StrikeIronAddressV6.SIWsOutputOfSIWsResultArrayOfServiceInfoRecord soosraosir =
			new StrikeIronAddressV6.SIWsOutputOfSIWsResultArrayOfServiceInfoRecord ();
			
		testAddress addr = new testAddress();
			
		//call web services
			
		Test.setMock(WebServiceMock.class, new StrikeIronAddressMock());
		
		StrikeIronAddressV6.NorthAmericanAddressVerificationServiceSoap naSOAP =
			new StrikeIronAddressV6.NorthAmericanAddressVerificationServiceSoap();
			
		//naSOAP.AddressDistanceCalculatorBatch(null);
		
		//naSOAP.GetStatusCodesForMethod(null);
		
		//naSOAP.GetServiceInfo();
			
		//naSOAP.GetRemainingHits();
		
		//naSOAP.AddressDistanceCalculator(null, null, null);
		
		//naSOAP.GetStatusCodes();
		
		//naSOAP.NorthAmericanAddressVerificationBatch(null, null);
		
		//naSOAP.NorthAmericanAddressVerification(null, null, null, null, null, null, null);
		
	}
	
	static testMethod void covertStrikeIronWS() {
		
		StrikeIronWS siws = new StrikeIronWS();
		
		StrikeIronWS.RegisteredUser ru = new StrikeIronWS.RegisteredUser();
		
		StrikeIronWS.GetRemainingHits_element grhe = new StrikeIronWS.GetRemainingHits_element();
		
		StrikeIronWS.GetRemainingHitsResponse_element grhre = new StrikeIronWS.GetRemainingHitsResponse_element();
		
		StrikeIronWS.LicenseInfo li = new StrikeIronWS.LicenseInfo();
		
		StrikeIronWS.SubscriptionInfo si = new StrikeIronWS.SubscriptionInfo();
		
	}
	
	public class testAddress extends StrikeIronAddressV6.Address { }
	
}