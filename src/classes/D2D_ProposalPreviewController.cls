public without sharing class D2D_ProposalPreviewController extends D2D_BaseReferralController {

    public override List<String> getPortalReferralFields(){
        return new List<String> {
            'Id',
            'Lead__c',
            'opportunity__c',
            'D2D_Lead_Status__c',
            'Full_Name__c'
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
            'Property__c'
        };
    }

    public Proposal__c proposal {get; set;}
    public ID propPdfID {get; private set;}
    public String pdfUrl {get; private set;}

    public D2D_ProposalPreviewController(){
        if(relatedOpportunity == null){
            ApexPages.addMessage(D2D_Utility.GetMessageFromString(ApexPages.Severity.FATAL, 'This referral does not have a related opportunity.'));
            return;
        }

        try{
            proposal = [SELECT Id, Name FROM Proposal__c WHERE System_Design_Quote__r.System_Design__r.Property__c = :relatedOpportunity.Property__c AND Current__c = true LIMIT 1];
        }catch (Exception ex){
            ApexPages.addMessage(D2D_Utility.GetMessageFromString(ApexPages.Severity.FATAL, 'Proposal for Property__c: ' + relatedOpportunity.Property__c + ' was not found.'));
            ApexPages.addMessages(ex);
            stackTrace = ex.getStackTraceString();
            return;
        }

        Attachment[] existingAttchs = [SELECT ID FROM Attachment WHERE ParentID = :proposal.Id AND Name = 'Proposal.pdf' AND ContentType = 'application/pdf' LIMIT 1];
        if (existingAttchs.isEmpty()){
            ApexPages.addMessage(D2D_Utility.GetMessageFromString(ApexPages.Severity.FATAL, 'Error: No proposal pdf file exists.'));
            return;
        } else {
            propPdfID = existingAttchs[0].ID;
            pdfUrl = D2D_Utility.GetPDFUrl(propPdfID);
        }
    }
    
    public String getRenderPdfAsHtml() {
        return String.valueOf(D2D_Utility.isiPad());
	}	
}