public without sharing class D2D_ContractUploadController extends D2D_BaseReferralController {
    
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

    public Attachment uploadFile { get; set; }
    public Boolean wasProcessed { get; set; }
    public Boolean allowUpload { get; private set; }

	public D2D_ContractUploadController() {
        uploadFile = new Attachment();
        wasProcessed = false;
        allowUpload = true;
        if(referral.D2D_Lead_Status__c != 'Signing In Process'){
            ApexPages.addMessage(D2D_Utility.GetMessageFromString(ApexPages.Severity.WARNING, 'You have reached this page in error.  Please contact an administrator.'));
            allowUpload = false;
        }
	}

	public PageReference upload(){
        Astrum_Contract__c contract = null;
        Id contractId = null;
        wasProcessed = false;

        // Ensure relatedOpportunity and contract
        if(relatedOpportunity == null || String.isBlank(relatedOpportunity.Id) || String.isBlank(relatedOpportunity.Property__c)){
            ApexPages.addMessage(D2D_Utility.GetMessageFromString(ApexPages.Severity.WARNING, 'This record must have an opportunity before uploading a file.'));
            uploadFile = new Attachment();
            return null;
        } else {
            try{
                contract = [SELECT Id, Name FROM Astrum_Contract__c WHERE Proposal__r.System_Design_Quote__r.System_Design__r.Property__c = :relatedOpportunity.Property__c AND Proposal__r.Current__c = true LIMIT 1];
                contractId = contract.Id;
            }catch (Exception ex){
                ApexPages.addMessage(D2D_Utility.GetMessageFromString(ApexPages.Severity.FATAL, 'Contract for Property__c: ' + relatedOpportunity.Property__c + ' was not found.'));
                ApexPages.addMessages(ex);
                uploadFile = new Attachment();
                stackTrace = ex.getStackTraceString();
                return null;
            }
        }

        Savepoint sp = Database.setSavepoint();
        try {
            if(uploadFile == null){
                throw new D2D_Utility.D2DException('The upload file cannot be null.');
            }
            List<Attachment> attachmentsToCopy = new List<Attachment>(); // [SELECT Id, Name, Body FROM Attachment WHERE ParentId = :docusignStatus.Id];
            system.debug('**SZ: uploadFile = ' + uploadFile);
            attachmentsToCopy.add(uploadFile);

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
                
                ApexPages.Message returnMessage = D2D_Utility.CreateSalesOrder(referral.Opportunity__c, attachmentsToCopy);
                if(returnMessage != null){
                    ApexPages.addMessage(returnMessage);
                    uploadFile = new Attachment();
                }
            } catch (Exception ex){
                throw ex;
            }

            referral.D2D_Lead_Status__c = 'Sold';
            update referral;
        } catch (Exception ex) {
            ApexPages.addMessages(ex);
            stackTrace = ex.getStackTraceString();
            uploadFile = new Attachment();
            Database.rollback(sp);
            return null;
        }

        uploadFile = new Attachment();
        wasProcessed = true;
        return null;
	}
}