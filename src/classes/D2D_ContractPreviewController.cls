public without sharing class D2D_ContractPreviewController extends D2D_BaseReferralController {
    
    public override List<String> getPortalReferralFields(){
        return new List<String> {
            'Credit_Approved__c',
            'D2D_Lead_Status__c',
            'Id',
            'Lead__c',
            'Opportunity__c',
            'Full_Name__c',
            'Email__c',
            'Last_Name__c'
        };
    }

    public override List<String> getLeadFields(){
        return new List<String> {
            'Id'
        };
    }

    public override List<String> getOpportunityFields(){
        return new List<String> {
            'Id',
            'Closed_Reason__c',
            'StageName',
            'Property__c',
            'System_Design_Quote__c'
        };
    }

    public Astrum_Contract__c contract {get; private set;}
    public Attachment documentToSign {get; private set;}
    public String embeddedUrl {get;set;}
    public String contractId {get; private set;}
    public ID contractPdfID {get; private set;}
    
    public String envelopeId {get;set;}
    public String auth {get;set;}
    //===== Strings to modify =====
    private String accountId = D2D_Utility.d2dSettings.DocuSign_Account_Id__c; // '819ebe84-9679-4224-bee5-05c444fcb771'; // TODO: Put DocuSign API Account ID Here
    private String userId = D2D_Utility.d2dSettings.DocuSign_User_Id__c; // '1a49f662-d561-4fb0-8e47-e6f4a1ca6c0e'; // TODO: Put your DocuSign member email here
    private String password = D2D_Utility.d2dSettings.DocuSign_Password__c; // 'Astrum2107$$'; // TODO: Put your DocuSign member password here
    private String integratorsKey = D2D_Utility.d2dSettings.DocuSign_Integrators_Key__c; // 'DDIN-ed44ee9b-2e5f-4637-a2ba-19b0a0475b8e'; // TODO: Put your DocuSign API Integrators Key here
    private String devHost = D2D_Utility.d2dSettings.DocuSign_Host__c; // 'https://cs7.salesforce.com/'; // TODO: Salesforce host URL
    private String webServiceUrl = D2D_Utility.d2dSettings.DocuSign_Service_Url__c; // 'https://demo.docusign.net/api/3.0/dsapi.asmx';
    //=============================

    public String pdfUrl {get; private set;}
    public Boolean readyToSign {get; private set;}
    public Boolean creditApprovalRequired {get; private set;}
    public Boolean shouldEmailContract {get;set;}

	public D2D_ContractPreviewController() {
        if (relatedOpportunity == null){
            ApexPages.addMessage(D2D_Utility.GetMessageFromString(ApexPages.Severity.FATAL, 'This referral does not have a related opportunity.'));
            return;
        }

        if(referral.D2D_Lead_Status__c != 'Sold'){
            try{
                contract = [SELECT Id, Name FROM Astrum_Contract__c WHERE Proposal__r.System_Design_Quote__r.System_Design__r.Property__c = :relatedOpportunity.Property__c AND Proposal__r.Current__c = true LIMIT 1];
                contractId = contract.Id;
            }catch (Exception ex){
                ApexPages.addMessage(D2D_Utility.GetMessageFromString(ApexPages.Severity.FATAL, 'Contract for Property__c: ' + relatedOpportunity.Property__c + ' was not found.'));
                ApexPages.addMessages(ex);
                stackTrace = ex.getStackTraceString();
                return;
            }

            Attachment[] existingAttchs = [SELECT Id, Body FROM Attachment WHERE ParentID = :contractId AND ContentType = 'application/pdf' AND (NOT Name LIKE '%Signed Contract%') LIMIT 1];
            if (existingAttchs.isEmpty()){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error: No contract pdf file exists.'));
                return;
            } else {
                documentToSign = existingAttchs[0];
                contractPdfID = existingAttchs[0].ID;
                pdfUrl = D2D_Utility.GetPDFUrl(contractPdfID);
            }

            // disable for now so signing can be tested more easily
            readyToSign = (referral.D2D_Lead_Status__c == 'Signing In Process')
                            || (D2D_Utility.d2dSettings.Credit_Approval_Required__c && String.isNotBlank(referral.Credit_Approved__c) && referral.Credit_Approved__c != 'No') 
                            || (!D2D_Utility.d2dSettings.Credit_Approval_Required__c && referral.D2D_Lead_Status__c == 'Contract Generated');
            /*
            readyToSign = true;
            */
            
            creditApprovalRequired = D2D_Utility.d2dSettings.Credit_Approval_Required__c;
        } else {
            String salesOrderId = '';
            try{
                SCRB_SalesOrder__c salesOrder = [SELECT Id FROM SCRB_SalesOrder__c WHERE OpportunityId__c = :relatedOpportunity.Id LIMIT 1];
                salesOrderId = salesOrder.Id;
            }catch (Exception ex){
                ApexPages.addMessage(D2D_Utility.GetMessageFromString(ApexPages.Severity.ERROR, 'Sales Order for Opportunity: ' + relatedOpportunity.Id + ' was not found.'));
                ApexPages.addMessages(ex);
                stackTrace = ex.getStackTraceString();
                return;
            }

            Attachment[] existingAttchs = [SELECT Id FROM Attachment WHERE ParentID = :salesOrderId AND ContentType = 'application/pdf' AND Name LIKE '%Signed Contract%' LIMIT 1];
            if (existingAttchs.isEmpty()){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error: No signed contract pdf file exists.'));
                return;
            } else {
                contractPdfID = existingAttchs[0].ID;
                pdfUrl = D2D_Utility.GetPDFUrl(contractPdfID);
            }

            readyToSign = false;
            creditApprovalRequired = false;
        }
	}
    
    public String getRenderPdfAsHtml() {
        return String.valueOf(D2D_Utility.isiPad());
    }

    public PageReference DoSign(){
        shouldEmailContract = false;
        return SendNow();
    }

    public PageReference DoSignAndEmail(){
        shouldEmailContract = true;
        return SendNow();
    }

    public PageReference SendNow() {
        embeddedUrl = GetTokenUrl();
        if(embeddedUrl != ''){
            referral.D2D_Lead_Status__c = 'Signing In Process';
            update referral;
        }
        return null;
    }

    private String GetTokenUrl(){
        envelopeId = '';
        String token = '';

        //Set Authentication
        auth = '<DocuSignCredentials><Username>'+ userId 
            +'</Username><Password>' + password 
            + '</Password><IntegratorKey>' + integratorsKey 
            + '</IntegratorKey></DocuSignCredentials>';
        System.debug('Setting authentication to: ' + auth);

        DocuSignAPI_30.ApiServiceSOAP dsApiSend = dsapi_send();
         
        // create envelope info
        DocuSignAPI_30.Envelope envelope = new DocuSignAPI_30.Envelope();
        envelope.Subject = 'Door-2-Door Contract Signed with DocuSign';
        envelope.EmailBlurb = 'This form can be signed using DocuSign right here in the browser.  A copy will be emailed to you upon completion.';
        envelope.AccountId  = accountId; 

        // Recipient
        DocuSignAPI_30.Recipient recipient = new DocuSignAPI_30.Recipient();
        recipient.ID = 1;
        recipient.Type_x = 'Signer';
        recipient.RoutingOrder = 1;
        recipient.Email = referral.Email__c;
        recipient.UserName = referral.Full_Name__c;
        recipient.RoleName = 'Signer';
        recipient.RequireIDLookup = false;
            
        // make recipient captive for embedded experience
        recipient.CaptiveInfo = new DocuSignAPI_30.RecipientCaptiveInfo();
        recipient.CaptiveInfo.ClientUserId = '1';
        // only do line below on request; D2D-99
        if(shouldEmailContract){
            recipient.CaptiveInfo.EmbeddedRecipientStartURL = 'SIGN_AT_DOCUSIGN';
        }

        DocuSignAPI_30.Recipient recipientCopy = new DocuSignAPI_30.Recipient();
        recipientCopy.ID = 2;
        recipientCopy.Type_x = 'CarbonCopy';
        recipientCopy.Email = UserInfo.getUserEmail();
        recipientCopy.UserName = UserInfo.getName();
        recipientCopy.RequireIDLookup = false;

        envelope.Recipients = new DocuSignAPI_30.ArrayOfRecipient();
        envelope.Recipients.Recipient = new DocuSignAPI_30.Recipient[2];
        envelope.Recipients.Recipient[0] = recipient;
        envelope.Recipients.Recipient[1] = recipientCopy;

        // Render the contract
        System.debug('Rendering the document');
        PageReference pageRef = new PageReference('/d2d/servlet/servlet.FileDownload');
        pageRef.getParameters().put('file',contractPdfID);
        Blob pdfBlob = (Test.isRunningTest()) ? documentToSign.Body : pageRef.getContent();

        // Document
        DocuSignAPI_30.Document document = new DocuSignAPI_30.Document();
        document.ID = 1;
        document.pdfBytes = EncodingUtil.base64Encode(pdfBlob);
        document.Name = referral.Last_Name__c + ' - Signed Contract';
        document.FileExtension = 'pdf';
        envelope.Documents = new DocuSignAPI_30.ArrayOfDocument();
        envelope.Documents.Document = new DocuSignAPI_30.Document[1];
        envelope.Documents.Document[0] = document;

        // Tab
        DocuSignAPI_30.Tab tab1 = new DocuSignAPI_30.Tab();
        tab1.Type_x = 'SignHere';
        tab1.RecipientID = 1;
        tab1.DocumentID = 1;
        //tab1.PageNumber = 15;
        //tab1.YPosition = 400;
        //tab1.XPosition = 90;
        tab1.AnchorTabItem = new DocuSignAPI_30.AnchorTab();
        tab1.AnchorTabItem.AnchorTabString = 'Please Sign Here';
        //tab1.AnchorTabItem.YOffset = 20;
        //tab1.AnchorTabItem.Unit = 'Pixels';
        tab1.AnchorTabItem.IgnoreIfNotPresent = true;
        
        DocuSignAPI_30.Tab tab2 = new DocuSignAPI_30.Tab();
        tab2.Type_x = 'DateSigned';
        tab2.RecipientID = 1;
        tab2.DocumentID = 1;
        //tab2.PageNumber = 15;
        //tab2.YPosition = 400;
        //tab2.XPosition = 90;
        tab2.AnchorTabItem = new DocuSignAPI_30.AnchorTab();
        tab2.AnchorTabItem.AnchorTabString = 'Date Here';
        //tab2.AnchorTabItem.XOffset = 20;
        //tab2.AnchorTabItem.Unit = 'Pixels';
        tab2.AnchorTabItem.IgnoreIfNotPresent = true;

        // Tab
        DocuSignAPI_30.Tab tab3 = new DocuSignAPI_30.Tab();
        tab3.Type_x = 'SignHereOptional';
        tab3.RecipientID = 1;
        tab3.DocumentID = 1;
        //tab1.PageNumber = 15;
        //tab1.YPosition = 400;
        //tab1.XPosition = 90;
        tab3.AnchorTabItem = new DocuSignAPI_30.AnchorTab();
        tab3.AnchorTabItem.AnchorTabString = 'Optional Sign Here';
        //tab1.AnchorTabItem.YOffset = 20;
        //tab1.AnchorTabItem.Unit = 'Pixels';
        tab3.AnchorTabItem.IgnoreIfNotPresent = true;

        // Tab
        DocuSignAPI_30.Tab tab4 = new DocuSignAPI_30.Tab();
        tab4.Type_x = 'InitialHere';
        tab4.RecipientID = 1;
        tab4.DocumentID = 1;
        //tab1.PageNumber = 15;
        //tab1.YPosition = 400;
        //tab1.XPosition = 90;
        tab4.AnchorTabItem = new DocuSignAPI_30.AnchorTab();
        tab4.AnchorTabItem.AnchorTabString = 'Please Initial Here';
        //tab1.AnchorTabItem.YOffset = 20;
        //tab1.AnchorTabItem.Unit = 'Pixels';
        tab4.AnchorTabItem.IgnoreIfNotPresent = true;
        
        envelope.Tabs = new DocuSignAPI_30.ArrayOfTab();
        envelope.Tabs.Tab = new DocuSignAPI_30.Tab[4];
        envelope.Tabs.Tab[0] = tab1;
        envelope.Tabs.Tab[1] = tab2;
        envelope.Tabs.Tab[2] = tab3;
        envelope.Tabs.Tab[3] = tab4;

        System.debug('Calling the API');
        try {
            if(!Test.isRunningTest()){
                DocuSignAPI_30.EnvelopeStatus es = dsApiSend.CreateAndSendEnvelope(envelope);
                envelopeId = es.EnvelopeID;
            } else {
                envelopeId = D2DTestUtility.GenerateGuid();
            }
        } catch ( CalloutException e) {
            System.debug('Exception - ' + e );
            envelopeId = 'Exception - ' + e;
            return '';
        }
        
        DocuSignAPI_30.RequestRecipientTokenAuthenticationAssertion assert = new DocuSignAPI_30.RequestRecipientTokenAuthenticationAssertion();
        assert.AssertionID = 'Your AssertionID Here';
        assert.AuthenticationInstant = system.now();
        assert.AuthenticationMethod = 'Password';
        assert.SecurityDomain = 'YourApp.com';
        
        DocuSignAPI_30.RequestRecipientTokenClientURLs clientURLs = new DocuSignAPI_30.RequestRecipientTokenClientURLs();
        
        system.debug('**SZ: popUrl = ' + getPopURL());
        clientURLs.OnAccessCodeFailed = getPopURL() + '?id=' + referral.Id + '&cid=' + contractId + '&event=OnAccessCodeFailed&envelopeid=' + envelopeID;
        clientURLs.OnCancel = getPopURL() + '?id=' + referral.Id + '&cid=' + contractId + '&event=OnCancel&envelopeid=' + envelopeID;
        clientURLs.OnDecline = getPopURL() + '?id=' + referral.Id + '&cid=' + contractId + '&event=OnDecline&envelopeid=' + envelopeID;
        clientURLs.OnException = getPopURL() + '?id=' + referral.Id + '&cid=' + contractId + '&event=OnException&envelopeid=' + envelopeID;
        clientURLs.OnFaxPending = getPopURL() + '?id=' + referral.Id + '&cid=' + contractId + '&event=OnFaxPending&envelopeid=' + envelopeID;
        clientURLs.OnIdCheckFailed = getPopURL() + '?id=' + referral.Id + '&cid=' + contractId + '&event=OnIdCheckFailed&envelopeid=' + envelopeID;
        clientURLs.OnSessionTimeout = getPopURL() + '?id=' + referral.Id + '&cid=' + contractId + '&event=OnSessionTimeout&envelopeid=' + envelopeID;
        clientURLs.OnSigningComplete = getPopURL() + '?id=' + referral.Id + '&cid=' + contractId + '&event=OnSigningComplete&envelopeid=' + envelopeID;
        clientURLs.OnTTLExpired = getPopURL() + '?id=' + referral.Id + '&cid=' + contractId + '&event=OnTTLExpired&envelopeid=' + envelopeID;
        clientURLs.OnViewingComplete = getPopURL() + '?id=' + referral.Id + '&cid=' + contractId + '&event=OnViewingComplete&envelopeid=' + envelopeID;
        
        // assumes apiService = preconfigured api proxy
        try {
            if(!Test.isRunningTest()){
                token = dsApiSend.RequestRecipientToken(envelopeId, recipient.captiveinfo.ClientUserId, recipient.UserName, recipient.Email, assert,clientURLs);
            } else {
                token = 'http://mock.docusign.token/response/url';
            }
        }  catch ( CalloutException e) {
            System.debug('Exception - ' + e );
            envelopeId = 'Exception - ' + e;
            return '';
        }
        return token;
    }

    // Get the proxy for the dsapi-send wsdl
    private DocuSignAPI_30.APIServiceSoap dsapi_send() {
        // Get DSapi and authenticate
        DocuSignAPI_30.APIServiceSoap dsApiSend = new DocuSignAPI_30.APIServiceSoap();
        dsApiSend.endpoint_x = webServiceUrl;
        dsApiSend.inputHttpHeaders_x = new Map<String, String>();
        dsApiSend.inputHttpHeaders_x.put('X-DocuSign-Authentication', auth);
        dsApiSend.timeout_x = 120000;
        return dsApiSend;
    }
    
    // returns URL of POP page that redirects callbacks to correct URL
    // Strips off end of path and replaces with ndaPOP
    private String getPopURL() {
        String popURL = Site.getBaseUrl();
        if (popURL == null) {
            popURL = devHost + 'apex/';
        } 
        //return popURL + '/ndaPop';
        return popURL + '/D2D_FramePop';
    }
}