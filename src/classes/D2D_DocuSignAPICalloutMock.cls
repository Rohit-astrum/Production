@isTest
public class D2D_DocuSignAPICalloutMock implements WebServiceMock {
    public void doInvoke(
        Object stub,
        Object request,
        Map<String, Object> response,
        String endpoint,
        String soapAction,
        String requestName,
        String responseNS,
        String responseName,
        String responseType) {

        if(requestName == 'CreateAndSendEnvelope'){
            // Create a envelope response
            DocuSignAPI_30.CreateAndSendEnvelopeResponse_element envelopeResponse = new DocuSignAPI_30.CreateAndSendEnvelopeResponse_element();
            response.put('response_x', envelopeResponse);
        } else if(requestName == 'RequestRecipientToken'){
            DocuSignAPI_30.RequestRecipientTokenResponse_element tokenResponse = new DocuSignAPI_30.RequestRecipientTokenResponse_element();
            response.put('response_x', tokenResponse);
        } else if(requestName == 'RequestDocumentPDFs'){
            // Create a document response
            DocuSignAPI_30.RequestDocumentPDFsResponse_element documentResponse = new DocuSignAPI_30.RequestDocumentPDFsResponse_element();
            response.put('response_x', documentResponse);
        }
    }
}

/*
Need to Mock this...
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://www.docusign.net/API/3.0/CreateAndSendEnvelope',
              'http://www.docusign.net/API/3.0',
              'CreateAndSendEnvelope',
              'http://www.docusign.net/API/3.0',
              'CreateAndSendEnvelopeResponse',
              'DocuSignAPI.CreateAndSendEnvelopeResponse_element'}
            );
*/

/*
And this...
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://www.docusign.net/API/3.0/RequestDocumentPDFs',
              'http://www.docusign.net/API/3.0',
              'RequestDocumentPDFs',
              'http://www.docusign.net/API/3.0',
              'RequestDocumentPDFsResponse',
              'DocuSignAPI_document.RequestDocumentPDFsResponse_element'}
            );
*/