@isTest
public class DEBundle_CalloutMock implements HttpCalloutMock {

    protected Map<String, Integer> endpointsAndCodes;

    public DEBundle_CalloutMock(Map<String, Integer> endpointsAndCodes) {
        this.endpointsAndCodes = endpointsAndCodes;
    }

    public HTTPResponse respond(HTTPRequest req) {
system.debug('**SZ: CalloutMock responding...');
        HttpResponse res = new HttpResponse();
        String endpoint = req.getEndpoint();

        if(endpoint.contains('oauth2/token')){
            res.setStatusCode(this.endpointsAndCodes.get('oauth2/token'));
            if(this.endpointsAndCodes.get('oauth2/token') == 200){
                res.setBody(DEBUNDLE_GETACCESSTOKEN_SUCCESS);
            } else {
                res.setBody(DEBUNDLE_GETACCESSTOKEN_FAILURE);
            }
        } else if(endpoint.contains('sobjects/Lead')){
            res.setStatusCode(this.endpointsAndCodes.get('sobjects/Lead'));
            if(this.endpointsAndCodes.get('sobjects/Lead') == 200){
                res.setBody(DEBUNDLE_CREATELEAD_SUCCESS);
            } else {
                res.setBody(DEBUNDLE_CREATELEAD_FAILURE);
            }
        } else if(endpoint.contains('sobjects/Attachment')){
            res.setStatusCode(this.endpointsAndCodes.get('sobjects/Attachment'));
            if(this.endpointsAndCodes.get('sobjects/Attachment') == 200){
                res.setBody(DEBUNDLE_CREATEATTACHMENT_SUCCESS);
            } else {
                res.setBody(DEBUNDLE_CREATEATTACHMENT_FAILURE);
            }
        }

        return res;
    }


    public static String DEBUNDLE_GETACCESSTOKEN_SUCCESS = '{"access_token":"1234567890","instance_url":"https://testurl.com","id":"https://testurl.com/id/00D1b000000CoXqEAK/0051b000000EzxaAAC","token_type":"Bearer","issued_at":"1456101357302","signature":"oARmI3DqF4otWbPE5i1KoCz9edSeOK3COuxmtsctnXI="}';
    public static String DEBUNDLE_CREATELEAD_SUCCESS = '{"id":"13579","success":true,"errors":[]}';
    public static String DEBUNDLE_CREATEATTACHMENT_SUCCESS = '{"id":"13579","success":true,"errors":[]}';

    public static String DEBUNDLE_GETACCESSTOKEN_FAILURE = '{"error":"access token error","error_description":"access token error description"}';
    public static String DEBUNDLE_CREATELEAD_FAILURE = '{"message":"lead create error","errorCode":"24680","fields":[]}';
    public static String DEBUNDLE_CREATEATTACHMENT_FAILURE = '{"message":"attachment create error","errorCode":"24680","fields":[]}';
}