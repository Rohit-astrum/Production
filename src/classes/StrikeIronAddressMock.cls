@isTest
global class StrikeIronAddressMock implements WebServiceMock {

    global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint,
        String soapAction, String requestName, String requestNS, String responseName, String responseType) {

        if (requestName == 'AddressDistanceCalculatorBatch') {
            response.put('response_x', new StrikeIronAddressV6.AddressDistanceCalculatorBatchResponse_element());
        } else if (requestName == 'GetStatusCodesForMethod') {
            response.put('response_x', new StrikeIronAddressV6.GetStatusCodesForMethodResponse_element());
            } else if (requestName == 'GetServiceInfo') {
                response.put('response_x', new StrikeIronAddressV6.GetServiceInfoResponse_element());
            } else if (requestName == 'AddressDistanceCalculator') {
                response.put('response_x', new StrikeIronAddressV6.AddressDistanceCalculatorResponse_element());
            } else if (requestName == 'GetStatusCodes') {
                response.put('response_x', new StrikeIronAddressV6.GetStatusCodesResponse_element());
            } else if (requestName == 'NorthAmericanAddressVerificationBatch') {
                response.put('response_x', new StrikeIronAddressV6.NorthAmericanAddressVerificationBatchResponse_element());
            } else if (requestName == 'NorthAmericanAddressVerification') {
                response.put('response_x', new StrikeIronAddressV6.NorthAmericanAddressVerificationResponse_element());
            }
            
        }
        
    }