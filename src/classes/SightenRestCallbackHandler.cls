@RestResource(urlMapping='/sighten/*')
global with sharing class SightenRestCallbackHandler {

    @future(callout=true)
    private static void DownloadContract(Id contractId, String contractName, String sightenQuoteId){
        SightenAPIHelper.SightenAPIHelperResponse sightenResponse = SightenAPIIntegrator.DownloadContract(sightenQuoteId);

        SightenAPIHelper helper = new SightenAPIHelper();
        String signingStatus = '';
        if(sightenResponse.responseStatusCode == 200){
            Attachment att = new Attachment(
                ParentID = contractId,
                Name = contractName + '_ext_Signed.pdf',
                Body = sightenResponse.responseBlob,
                ContentType = 'application/pdf'
            );
            insert att;

            signingStatus = 'DOWNLOADED';

            att.Body = null;
            att = null;
            sightenResponse.responseBody = null;
            sightenResponse.responseBlob = null;
        } else {
            SightenAPIEntity.SightenAPIErrorHelper errorHelper = (SightenAPIEntity.SightenAPIErrorHelper)helper.parseResponseBodyToError(sightenResponse.responseBody);
            String errorMessage = '';
            if(errorHelper.errorResponse != null){
                errorMessage = 'Sighten API Error: ' + errorHelper.errorResponse.messages.error[0].message;
            } else if(errorHelper.errorResponseList != null){
                errorMessage = 'Sighten API Error: ' + errorHelper.errorResponseList.messages.error[0].message + '<br/>' + errorHelper.errorResponseList.data[0][0].rule.name + ', min: ' + errorHelper.errorResponseList.data[0][0].rule.min_bound + ', max: ' + errorHelper.errorResponseList.data[0][0].rule.max_bound + '<br/>Value(s): ' + errorHelper.errorResponseList.data[0][0].values;
            }
            SightenAPIHelper.LogErrorMessage(contractId, 'Sighten Callback: API Error on Download Contract.', errorMessage);

            signingStatus = 'ERROR';
        }

        if(signingStatus != ''){
            Astrum_Contract__c contract = new Astrum_Contract__c(
                Id = contractId,
                Sighten_Signing_Status__c = signingStatus
            );
            update contract;
        }
    }

    @httpPut
    global static void doPut(){
        if(!RestContext.request.headers.containsKey('Identification')){
            // no auth provided
            RestContext.response.statusCode = 401;
            RestContext.response.responseBody = Blob.valueOf('{\"message\":\"You are not authorized to use this service.\",\"error\":\"MISSING_IDENTIFICATION\",\"timestamp\":\"' + Datetime.now() + '\"}');
            return;
        } else {
            String token = RestContext.request.headers.get('Identification');
            if(token != SightenAPISettings__c.getOrgDefaults().Callback_Token__c){
                // invalid auth token
                RestContext.response.statusCode = 401;
                RestContext.response.responseBody = Blob.valueOf('{\"message\":\"You are not authorized to use this service.\",\"error\":\"INVALID_TOKEN\",\"timestamp\":\"' + Datetime.now() + '\"}');
                return;
            }
        }

        Boolean isValid = true;
        Boolean isCredit = false;
        Boolean isContract = false;
        SightenAPIHelper helper = new SightenAPIHelper();
        SightenAPICredit apiCredit = null;
        SightenAPICredit.SightenAPICreditData apiCreditData = null;
        //SightenAPIEntity.SightenAPICreditQualification creditQual = null;
        SightenAPIQuote apiQuote = null;
        SightenAPIQuote.SightenAPIQuoteData apiQuoteData = null;
        try{
            system.debug('**SZ: requestBody = ' + RestContext.request.requestBody.toString());
            //creditQual = (SightenAPIEntity.SightenAPICreditQualification)helper.parseResponseBody(RestContext.request.requestBody.toString(), SightenAPIEntity.SightenAPICreditQualification.class);
            //system.debug('**SZ: creditQual - ' + creditQual);
            apiCredit = (SightenAPICredit)helper.parseResponseBody(RestContext.request.requestBody.toString(), SightenAPICredit.class);
            system.debug('**SZ: apiCredit - ' + apiCredit);
            if(apiCredit != null && apiCredit.data != null && apiCredit.data.credit_qualifications != null){
                isCredit = true;
                apiCreditData = apiCredit.data;
            }
        } catch(Exception ex){system.debug('**SZ: ex = ' + ex.getMessage() + ' -|- ' + ex.getStackTraceString());}

        if(!isCredit){
            try{
                system.debug('**SZ: requestBody = ' + RestContext.request.requestBody.toString());
                //creditQual = (SightenAPIEntity.SightenAPICreditQualification)helper.parseResponseBody(RestContext.request.requestBody.toString(), SightenAPIEntity.SightenAPICreditQualification.class);
                //system.debug('**SZ: creditQual - ' + creditQual);
                apiCreditData = (SightenAPICredit.SightenAPICreditData)helper.parseResponseDataBody(RestContext.request.requestBody.toString(), SightenAPICredit.SightenAPICreditData.class);
                system.debug('**SZ: apiCreditData - ' + apiCreditData);
                if(apiCreditData.credit_qualifications != null){
                    isCredit = true;
                }
            } catch(Exception ex){}
        }

        if(!isCredit){
            try{
                system.debug('**SZ: requestBody = ' + RestContext.request.requestBody.toString());
                apiQuote = (SightenAPIQuote)helper.parseResponseBody(RestContext.request.requestBody.toString(), SightenAPIQuote.class);
                system.debug('**SZ: apiQuote - ' + apiQuote);
                if(apiQuote != null && apiQuote.data != null && apiQuote.data.uuid != null){
                    isContract = true;
                    apiQuoteData = apiQuote.data;
                }
            } catch(Exception ex){}

            if(!isContract){
                try{
                    system.debug('**SZ: requestBody = ' + RestContext.request.requestBody.toString());
                    apiQuoteData = (SightenAPIQuote.SightenAPIQuoteData)helper.parseResponseDataBody(RestContext.request.requestBody.toString(), SightenAPIQuote.SightenAPIQuoteData.class);
                    system.debug('**SZ: apiQuoteData - ' + apiQuoteData);
                    if(apiQuoteData != null && apiQuoteData.uuid != null){
                        isContract = true;
                    }
                } catch(Exception ex){
                    isValid = false;
                }
            }
        }
        
        try
        {
            if(isValid){
                if(isCredit){
                    //SightenAPICredit.SightenAPICreditData apiCreditData = apiCreditList.data[0];
                    String qual_uuid = apiCreditData.uuid;
                    //String qual_uuid = creditQual.uuid;
                    Sighten_Credit_Approval__c sca = null;

                    try{
                        List<Sighten_Credit_Approval__c> scaList = [SELECT Id, Credit_Status__c FROM Sighten_Credit_Approval__c WHERE Sighten_Qualification_uuid__c = :qual_uuid LIMIT 2];
                        if(scaList.size() == 1){
                            sca = scaList[0];
                        } else {
                            RestContext.response.statusCode = 400;
                            RestContext.response.responseBody = Blob.valueOf('{\"message\":\"Your inputs were valid, but could not be processed.\",\"error\":\"INVALID_UUID\",\"timestamp\":\"' + Datetime.now() + '\"}');
                            SightenAPIHelper.LogErrorMessage(qual_uuid, 'Sighten Callback: Not exactly one SCA with the qualification uuid found.', '');
                            return;
                        }
                    } catch(Exception ex){
                        RestContext.response.statusCode = 400;
                        RestContext.response.responseBody = Blob.valueOf('{\"message\":\"You did not provide a valid qualification uuid.\",\"error\":\"INVALID_UUID\",\"timestamp\":\"' + Datetime.now() + '\"}');
                        SightenAPIHelper.LogErrorMessage(qual_uuid, 'Sighten Callback: There was an error processing the SCA query.', ex.getMessage() + ' -|- ' + ex.getStackTraceString());
                        return;
                    }

                    Set<String> creditStatuses = new Set<String>();
                    Schema.DescribeFieldResult fieldResult = Sighten_Credit_Approval__c.Credit_Status__c.getDescribe();
                    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                    for(Schema.PicklistEntry f : ple)
                    {
                        creditStatuses.add(f.getValue());
                    }

                    // process request
                    //if(creditStatuses.contains(creditQual.status.toUpperCase())){
                    //    sca.Credit_Status__c = creditQual.status.toUpperCase();
                    if(creditStatuses.contains(apiCreditData.credit_qualifications[0].status.toUpperCase())){
                        sca.Credit_Status__c = apiCreditData.credit_qualifications[0].status.toUpperCase();
                        update sca;

                        RestContext.response.statusCode = 200;
                        RestContext.response.responseBody = Blob.valueOf('{\"message\":\"Your request was successful.\",\"timestamp\":\"' + Datetime.now() + '\"}');
                        return;
                    } else {
                        RestContext.response.statusCode = 400;
                        RestContext.response.responseBody = Blob.valueOf('{\"message\":\"You did not provide a valid status value.\",\"error\":\"INVALID_VALUE\",\"timestamp\":\"' + Datetime.now() + '\"}');
                        SightenAPIHelper.LogErrorMessage(sca.Id, 'Sighten Callback: The credit status value provided was not found in the list of possible statuses.', apiCreditData.credit_qualifications[0].status.toUpperCase());
                        //LogErrorMessage('Sighten Callback: The credit status value provided was not found in the list of possible statuses.', creditQual.status.toUpperCase());
                        return;
                    }
                } else if(isContract) {
                    system.debug('**SZ: isContract');
                    String contract_uuid = apiQuoteData.uuid;
                    Astrum_Contract__c contract = null;

                    try{
                        List<Astrum_Contract__c> acList = [SELECT Id, Name, Sighten_Signing_Status__c FROM Astrum_Contract__c WHERE Sighten_Contract_uuid__c = :contract_uuid LIMIT 2];
                        if(acList.size() == 1){
                            system.debug('**SZ: found contract');
                            contract = acList[0];
                        } else {
                            RestContext.response.statusCode = 400;
                            RestContext.response.responseBody = Blob.valueOf('{\"message\":\"Your inputs were valid, but could not be processed.\",\"error\":\"INVALID_UUID\",\"timestamp\":\"' + Datetime.now() + '\"}');
                            SightenAPIHelper.LogErrorMessage(contract_uuid, 'Sighten Callback: Not exactly one contract with the quote uuid found.', '');
                            return;
                        }
                    } catch(Exception ex){
                        system.debug('**SZ: Sighten Callback: There was an error processing the query - ' + ex.getMessage());
                        RestContext.response.statusCode = 400;
                        RestContext.response.responseBody = Blob.valueOf('{\"message\":\"You did not provide a valid qualification uuid.\",\"error\":\"INVALID_UUID\",\"timestamp\":\"' + Datetime.now() + '\"}');
                        SightenAPIHelper.LogErrorMessage(contract_uuid, 'Sighten Callback: There was an error processing the Contract query.', ex.getMessage() + ' -|- ' + ex.getStackTraceString());
                        return;
                    }

                    system.debug('**SZ: check status');
                    // process request
                    if(apiQuoteData.status.toUpperCase() == 'SIGN'){
                        contract.Sighten_Signing_Status__c = 'SIGNED';
                        update contract;

                        DownloadContract(contract.Id, contract.Name, contract_uuid);
                    }

                    RestContext.response.statusCode = 200;
                    RestContext.response.responseBody = Blob.valueOf('{\"message\":\"Your request was successful.\",\"timestamp\":\"' + Datetime.now() + '\"}');
                }
            } else {
                RestContext.response.statusCode = 400;
                RestContext.response.responseBody = Blob.valueOf('{\"message\":\"You did not provide a valid callback type.\",\"error\":\"INVALID_TYPE\",\"timestamp\":\"' + Datetime.now() + '\"}');
                SightenAPIHelper.LogErrorMessage('', 'Sighten Callback: The provided request body could be parsed into a credit or contract object.', RestContext.request.requestBody.toString());
            }
        } catch(Exception ex){
            system.debug('**SZ: Sighten Callback: There was an error processing VF - ' + ex.getMessage());
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf('{\"message\":\"There was an error processing the callback.\",\"error\":\"APEX_CODE\",\"timestamp\":\"' + Datetime.now() + '\"}');
            SightenAPIHelper.LogErrorMessage('', 'Sighten Callback: There was an error processing VF.', ex.getMessage()); //+ '-|-' + ex.getStackTraceString());
            return;
        }
    }
}