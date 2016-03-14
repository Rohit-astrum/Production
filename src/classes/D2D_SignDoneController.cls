public without sharing class D2D_SignDoneController extends D2D_BaseReferralController {

    public override List<String> getPortalReferralFields(){
        return new List<String> {
            'Id',
            'Lead__c',
            'Opportunity__c',
            'D2D_Lead_Status__c',
            'Email__c'
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
            'StageName',
            'Property__c'
        };
    }

    public override Boolean getUseForUpdate() {
        return false;
    }

	private String contractId {get;set;}
	private String docusignEvent {get;set;}
	private String envelopeId {get;set;}

    public String auth {get;set;}
    public String pdfBytes {get;set;}
    //===== Strings to modify =====
    private String accountId = D2D_Utility.d2dSettings.DocuSign_Account_Id__c; // '819ebe84-9679-4224-bee5-05c444fcb771'; // TODO: Put DocuSign API Account ID Here
    private String userId = D2D_Utility.d2dSettings.DocuSign_User_Id__c; // '1a49f662-d561-4fb0-8e47-e6f4a1ca6c0e'; // TODO: Put your DocuSign member email here
    private String password = D2D_Utility.d2dSettings.DocuSign_Password__c; // 'Astrum2107$$'; // TODO: Put your DocuSign member password here
    private String integratorsKey = D2D_Utility.d2dSettings.DocuSign_Integrators_Key__c; // 'DDIN-ed44ee9b-2e5f-4637-a2ba-19b0a0475b8e'; // TODO: Put your DocuSign API Integrators Key here
    private String devHost = D2D_Utility.d2dSettings.DocuSign_Host__c; // 'https://cs7.salesforce.com/'; // TODO: Salesforce host URL
    private String webServiceUrl = D2D_Utility.d2dSettings.DocuSign_Service_Url__c; // 'https://demo.docusign.net/api/3.0/dsapi.asmx';
    //=============================

	public D2D_SignDoneController() {
		contractId = D2D_Utility.GetValueFromParam('cid');
	    docusignEvent = D2D_Utility.GetValueFromParam('event');
	    envelopeId = D2D_Utility.GetValueFromParam('envelopeId').toUpperCase();
	}

	public PageReference attachAndRedirect(){
        PageReference pr = null;
        pr = Page.D2D_LeadMenu;
        pr.getParameters().put('id', referralId);
        pr.setRedirect(true);

        Savepoint sp = null;
        try{
            if(String.isBlank(contractId) || String.isBlank(referralId) || String.isBlank(envelopeId) || String.isBlank(docusignEvent)){
                throw new D2D_Utility.D2DException('One of the expected parameters was not included.  Contact an administrator for assistance.');
            }

            if(docusignEvent != 'OnSigningComplete'){
                return pr;
            }

            // Retrieve the document from the API

            //Set Authentication
            auth = '<DocuSignCredentials><Username>'+ userId 
                +'</Username><Password>' + password 
                + '</Password><IntegratorKey>' + integratorsKey 
                + '</IntegratorKey></DocuSignCredentials>';
            System.debug('Setting authentication to: ' + auth);

            DocuSignAPI_30.ApiServiceSOAP apiService = dsapi_document();
            DocuSignAPI_30.DocumentPDFs docPdfs = null;
            if(!Test.isRunningTest()){
                docPdfs = apiService.RequestDocumentPDFs(envelopeId);
            } else {
                docPdfs = D2DTestUtility.MockDocuSignPdfs();
            }

            sp = Database.setSavepoint();
            referral.D2D_Lead_Status__c = 'Sold';
            update referral;

            List<Attachment> attachmentsToCopy = new List<Attachment>(); // [SELECT Id, Name, Body FROM Attachment WHERE ParentId = :docusignStatus.Id];
            List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
            for(DocuSignAPI_30.DocumentPDF doc : docPdfs.DocumentPDF){
                if(doc.Name != 'Summary'){
                    Attachment att = new Attachment();
                    att.Name = doc.Name + '.pdf';
                    att.Body = EncodingUtil.base64Decode(doc.PDFBytes);
                    att.ContentType = 'application/pdf';
                    attachmentsToCopy.add(att);

                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName(att.Name);
                    efa.setBody(att.Body);
                    emailAttachments.add(efa);
                }
            }

            if(attachmentsToCopy.size() == 0){
                Database.rollback(sp);
                throw new D2D_Utility.D2DException('A signed contract was not retrieved from DocuSign.  Contact an administrator for assistance.');
            }

            // Send the contract to the customer
            try{
               SendEmail(referral.Email__c, emailAttachments);
            } catch (Exception ex){
                throw ex;
            }

            // Sell the contract
            try{
                D2D_Utility.SellContract(contractId);
            } catch (Exception ex){
                throw ex;
            }

            // Win the opportunity
            try{
                D2D_Utility.CloseOpportunity(contractId, referral.Opportunity__c);
            } catch (Exception ex){
                throw ex;
            }

            // Create the sales order
            try{
                // Get the Utility Bill files from the Property
                attachmentsToCopy.addAll([SELECT Name, Body, ContentType FROM Attachment WHERE ParentId = :relatedOpportunity.Property__c AND Name LIKE '%Utility Bill%']);
                
                D2D_Utility.CreateSalesOrder(referral.Opportunity__c, attachmentsToCopy);
            } catch (Exception ex){
                throw ex;
            }
        } catch (Exception ex){
            ApexPages.addMessages(ex);
            stackTrace = ex.getStackTraceString();
            if(sp != null) {
                Database.rollback(sp);
            }
            return null;
        }

        return pr;
	}
    
    // Get the proxy for the dsapi-document wsdl
    private DocuSignAPI_30.APIServiceSoap dsapi_document() {
        // Get DSapi and authenticate
        DocuSignAPI_30.APIServiceSoap dsApiDoc = new DocuSignAPI_30.APIServiceSoap();
        dsApiDoc.endpoint_x = webServiceUrl;
        dsApiDoc.inputHttpHeaders_x = new Map<String, String>();
        dsApiDoc.inputHttpHeaders_x.put('X-DocuSign-Authentication', auth);
        dsApiDoc.timeout_x = 120000;
        return dsApiDoc;
    }

    private void SendEmail(String signerEmail, List<Messaging.EmailFileAttachment> emailAttachments){
        ApexPages.Message message = D2D_Utility.SendEmailOutsideSalesforce('Notify Signer', signerEmail, null, emailAttachments);
        if(message != null){
            ApexPages.addMessage(D2D_Utility.GetMessageFromString(ApexPages.Severity.FATAL, 'The email template could not be found.'));
        }
    }
}