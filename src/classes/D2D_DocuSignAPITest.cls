@isTest
private class D2D_DocuSignAPITest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out
    
    @isTest static void test_instantiateClassesForCoverage() {
        if(!runalltests){ return; }

        DocuSignAPI_30.APIServiceSoap o1 = new DocuSignAPI_30.APIServiceSoap();
        DocuSignAPI_30.SSN4InformationInput o2 = new DocuSignAPI_30.SSN4InformationInput();
        DocuSignAPI_30.EventNotification o3 = new DocuSignAPI_30.EventNotification();
        DocuSignAPI_30.Attachment o4 = new DocuSignAPI_30.Attachment();
        DocuSignAPI_30.SSN4Information o5 = new DocuSignAPI_30.SSN4Information();
        DocuSignAPI_30.IDCheckInformation o6 = new DocuSignAPI_30.IDCheckInformation();
        DocuSignAPI_30.Document o7 = new DocuSignAPI_30.Document();
        DocuSignAPI_30.RecipientStatus o8 = new DocuSignAPI_30.RecipientStatus();
        DocuSignAPI_30.Reminders o9 = new DocuSignAPI_30.Reminders();
        DocuSignAPI_30.ArrayOfCustomField o10 = new DocuSignAPI_30.ArrayOfCustomField();
        DocuSignAPI_30.FormData o11 = new DocuSignAPI_30.FormData();
        DocuSignAPI_30.ArrayOfTab o12 = new DocuSignAPI_30.ArrayOfTab();
        DocuSignAPI_30.EnvelopeEvent o13 = new DocuSignAPI_30.EnvelopeEvent();
        DocuSignAPI_30.Recipient o14 = new DocuSignAPI_30.Recipient();
        DocuSignAPI_30.FormDataXfdf o15 = new DocuSignAPI_30.FormDataXfdf();
        DocuSignAPI_30.RecipientCaptiveInfo o16 = new DocuSignAPI_30.RecipientCaptiveInfo();
        DocuSignAPI_30.ArrayOfRecipientStatus o17 = new DocuSignAPI_30.ArrayOfRecipientStatus();
        DocuSignAPI_30.AuthenticationStatus o18 = new DocuSignAPI_30.AuthenticationStatus();
        DocuSignAPI_30.ArrayOfFormDataXfdfField o19 = new DocuSignAPI_30.ArrayOfFormDataXfdfField();
        DocuSignAPI_30.RecipientPhoneAuthentication o20 = new DocuSignAPI_30.RecipientPhoneAuthentication();
        DocuSignAPI_30.ArrayOfString1 o21 = new DocuSignAPI_30.ArrayOfString1();
        DocuSignAPI_30.ArrayOfDocumentStatus o22 = new DocuSignAPI_30.ArrayOfDocumentStatus();
        DocuSignAPI_30.DOBInformationInput o23 = new DocuSignAPI_30.DOBInformationInput();
        DocuSignAPI_30.RecipientSignatureInfo o24 = new DocuSignAPI_30.RecipientSignatureInfo();
        DocuSignAPI_30.AddressInformationInput o25 = new DocuSignAPI_30.AddressInformationInput();
        DocuSignAPI_30.ArrayOfRecipient o26 = new DocuSignAPI_30.ArrayOfRecipient();
        DocuSignAPI_30.AddressInformation o27 = new DocuSignAPI_30.AddressInformation();
        DocuSignAPI_30.ArrayOfTabStatus o28 = new DocuSignAPI_30.ArrayOfTabStatus();
        DocuSignAPI_30.ArrayOfDocument o29 = new DocuSignAPI_30.ArrayOfDocument();
        DocuSignAPI_30.ArrayOfAttachment o30 = new DocuSignAPI_30.ArrayOfAttachment();
        DocuSignAPI_30.Notification o31 = new DocuSignAPI_30.Notification();
        DocuSignAPI_30.SSN9InformationInput o32 = new DocuSignAPI_30.SSN9InformationInput();
        DocuSignAPI_30.IDCheckInformationInput o33 = new DocuSignAPI_30.IDCheckInformationInput();
        DocuSignAPI_30.TabStatus o34 = new DocuSignAPI_30.TabStatus();
        DocuSignAPI_30.ArrayOfMatchBox o35 = new DocuSignAPI_30.ArrayOfMatchBox();
        DocuSignAPI_30.SSN9Information o36 = new DocuSignAPI_30.SSN9Information();
        DocuSignAPI_30.EnvelopeStatus o37 = new DocuSignAPI_30.EnvelopeStatus();
        DocuSignAPI_30.ArrayOfEnvelopeEvent o38 = new DocuSignAPI_30.ArrayOfEnvelopeEvent();
        DocuSignAPI_30.MatchBox o39 = new DocuSignAPI_30.MatchBox();
        DocuSignAPI_30.DOBInformation o40 = new DocuSignAPI_30.DOBInformation();
        DocuSignAPI_30.DocumentStatus o41 = new DocuSignAPI_30.DocumentStatus();
        DocuSignAPI_30.AnchorTab o42 = new DocuSignAPI_30.AnchorTab();
        DocuSignAPI_30.EventResult o43 = new DocuSignAPI_30.EventResult();
        DocuSignAPI_30.FormDataXfdfField o44 = new DocuSignAPI_30.FormDataXfdfField();
        DocuSignAPI_30.Tab o45 = new DocuSignAPI_30.Tab();
        DocuSignAPI_30.ArrayOfString o46 = new DocuSignAPI_30.ArrayOfString();
        DocuSignAPI_30.VaultingDetails o47 = new DocuSignAPI_30.VaultingDetails();
        DocuSignAPI_30.CustomField o48 = new DocuSignAPI_30.CustomField();
        DocuSignAPI_30.Expirations o49 = new DocuSignAPI_30.Expirations();
        DocuSignAPI_30.RecipientStatusEsignAgreementInformation o50 = new DocuSignAPI_30.RecipientStatusEsignAgreementInformation();
        DocuSignAPI_30.VaultingOptions o51 = new DocuSignAPI_30.VaultingOptions();
        DocuSignAPI_30.BCCEmailAddress o52 = new DocuSignAPI_30.BCCEmailAddress();
        DocuSignAPI_30.RecipientSMSAuthentication o53 = new DocuSignAPI_30.RecipientSMSAuthentication();
        DocuSignAPI_30.ArrayOfPositiveInteger o54 = new DocuSignAPI_30.ArrayOfPositiveInteger();
        DocuSignAPI_30.DocumentField o55 = new DocuSignAPI_30.DocumentField();
        DocuSignAPI_30.ArrayOfRecipientEvent o56 = new DocuSignAPI_30.ArrayOfRecipientEvent();
        DocuSignAPI_30.ArrayOfBCCEmailAddress o57 = new DocuSignAPI_30.ArrayOfBCCEmailAddress();
        DocuSignAPI_30.ArrayOfSAMLAttribute o58 = new DocuSignAPI_30.ArrayOfSAMLAttribute();
        DocuSignAPI_30.RecipientEvent o59 = new DocuSignAPI_30.RecipientEvent();
        DocuSignAPI_30.RecipientEmailNotification o60 = new DocuSignAPI_30.RecipientEmailNotification();
        DocuSignAPI_30.EmailSettings o61 = new DocuSignAPI_30.EmailSettings();
        DocuSignAPI_30.ArrayOfDocumentField o62 = new DocuSignAPI_30.ArrayOfDocumentField();
        DocuSignAPI_30.SAMLAttribute o63 = new DocuSignAPI_30.SAMLAttribute();
        DocuSignAPI_30.RecipientSAMLAuthentication o64 = new DocuSignAPI_30.RecipientSAMLAuthentication();
        DocuSignAPI_30.DocumentPDFs o65 = new DocuSignAPI_30.DocumentPDFs();
        DocuSignAPI_30.DocumentPDF o66 = new DocuSignAPI_30.DocumentPDF();
        DocuSignAPI_30.RequestDocumentPDFsResponse_element o67 = new DocuSignAPI_30.RequestDocumentPDFsResponse_element();
        DocuSignAPI_30.RequestDocumentPDFs_element o68 = new DocuSignAPI_30.RequestDocumentPDFs_element();

        Test.setMock(WebServiceMock.class, new D2D_DocuSignAPICalloutMock());

        DocuSignAPI_30.Envelope envelope = new DocuSignAPI_30.Envelope();
        envelope.Subject = 'Test Mock';
        envelope.EmailBlurb = 'Test Mock';
        envelope.AccountId  = D2DTestUtility.GenerateGuid();

        DocuSignAPI_30.RequestRecipientTokenAuthenticationAssertion assert = new DocuSignAPI_30.RequestRecipientTokenAuthenticationAssertion();
        assert.AssertionID = 'Your AssertionID Here';
        assert.AuthenticationInstant = system.now();
        assert.AuthenticationMethod = 'Password';
        assert.SecurityDomain = 'YourApp.com';

        DocuSignAPI_30.RequestRecipientTokenClientURLs clientURLs = new DocuSignAPI_30.RequestRecipientTokenClientURLs();
        clientURLs.OnAccessCodeFailed = 'http://salesforce.com';
        clientURLs.OnCancel = 'http://salesforce.com';
        clientURLs.OnDecline = 'http://salesforce.com';
        clientURLs.OnException = 'http://salesforce.com';
        clientURLs.OnFaxPending = 'http://salesforce.com';
        clientURLs.OnIdCheckFailed = 'http://salesforce.com';
        clientURLs.OnSessionTimeout = 'http://salesforce.com';
        clientURLs.OnSigningComplete = 'http://salesforce.com';
        clientURLs.OnTTLExpired = 'http://salesforce.com';
        clientURLs.OnViewingComplete = 'http://salesforce.com';

        o1.CreateAndSendEnvelope(envelope);
        o1.RequestRecipientToken(D2DTestUtility.GenerateGuid(), '1', 'recipient username', 'recipient email', assert, clientURLs);
        o1.RequestDocumentPDFs(D2DTestUtility.GenerateGuid());
    }
}