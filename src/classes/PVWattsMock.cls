/* FILE: PVWattsBatchTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: October 25, 2012
 * PURPOSE: Test mock for PVWatts
 * MODIFICATION HISTORY
 *
 */ 
 
@isTest
global class PVWattsMock implements WebServiceMock {

	global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint,
		String soapAction, String requestName, String requestNS, String responseName, String responseType) {
			response.put('response_x', new PVWatts.GetPVWATTSResponse_element());
	}
		
}