public without sharing class D2D_SolarSavingsGuidePreviewController extends D2D_BaseReferralController {

    public override List<String> getPortalReferralFields(){
        return new List<String> {
            'D2D_Lead_Status__c',
            'D2D_Site_Quality__c',
            'D2D_System_Size__c',
            'Full_Name__c',
            'Id',
            'Lead__c',
            'Opportunity__c',
            'SSG_Accepted__c'
        };
    }

    public override List<String> getLeadFields(){
        return new List<String> {
            'Id',
            'Utility_Company_Master__c',
            'County__c',
            'QAS_County__c'
        };
    }

    public D2D_Proposal__c d2dProposal {get; set;}
    public Attachment ssgAtt {get;set;}
    public String pdfUrl {get; private set;}
    public Boolean canBeAccepted {get;set;}

	public D2D_SolarSavingsGuidePreviewController() {
        Decimal numberOfPanels = Decimal.valueOf(referral.D2D_System_Size__c.replace(' Panel', ''));
        try{
            canBeAccepted = true;

            if(relatedLead.QAS_County__c == null && relatedLead.County__c == null){
                canBeAccepted = false;
                ApexPages.addMessage(D2D_Utility.GetMessageFromString(ApexPages.Severity.FATAL, 'This lead does not have a county specified.  Please go back to the lead information page and save the lead to initiate the address verification.  You may also select a county manually from there.'));
                return;
            }

            List<D2D_Proposal__c> d2dProposalList = [SELECT Id, Name, Utility_Company_Master__r.Name, Number_of_Panels__c FROM D2D_Proposal__c WHERE Utility_Company_Master__c = :relatedLead.Utility_Company_Master__c AND Number_of_Panels__c = :numberOfPanels LIMIT 1];
            if(d2dProposalList.size() == 1){
                d2dProposal = d2dProposalList[0];

                List<Attachment> ssgAttList = [SELECT Id FROM Attachment WHERE ParentId = :d2dProposal.Id LIMIT 1];
                if(ssgAttList.size() == 1){
                    ssgAtt = ssgAttList[0];

                    pdfUrl = D2D_Utility.GetPDFUrl(ssgAtt.Id);
                } else {
                    canBeAccepted = false;
                    if(ssgAttList.size() == 0){
                        ApexPages.addMessage(D2D_Utility.GetMessageFromString(ApexPages.Severity.FATAL, 'A Solar Savings Guide was found but did not contain an attachment.'));
                    } else {
                        ApexPages.addMessage(D2D_Utility.GetMessageFromString(ApexPages.Severity.FATAL, 'A Solar Savings Guide was found but contained multiple attachments.'));
                    }
                }
            } else {
                canBeAccepted = false;
                if(d2dProposalList.size() == 0){
                    ApexPages.addMessage(D2D_Utility.GetMessageFromString(ApexPages.Severity.FATAL, 'A Solar Savings Guide was not found for the provided utility company and system size.'));
                } else {
                    ApexPages.addMessage(D2D_Utility.GetMessageFromString(ApexPages.Severity.FATAL, 'Multiple Solar Savings Guides were found for the provided utility company and system size.'));
                }
            }
        } catch (Exception ex){
            ApexPages.addMessages(ex);
            stackTrace = ex.getStackTraceString();
        }
    }
    
    public String getRenderPdfAsHtml() {
        return String.valueOf(D2D_Utility.isiPad());
	}	
    
    public PageReference ssgAccepted() {
        Savepoint sp = Database.setSavepoint();
        try{
            referral.SSG_Accepted__c = 'True';
            referral.D2D_Lead_Status__c = 'Customer Opt-In';
            update referral;

            String leadStatus = '';
            List<SelectOption> leadStatuses = D2D_Utility.GetPicklistOptions(Lead.Status.getDescribe(), false);
            for(SelectOption so : leadStatuses){
                if(so.getValue().contains('Open') && so.getValue().contains('New')){
                    leadStatus = so.getValue();
                }
            }
            relatedLead.Status = leadStatus;
            update relatedLead;
        } catch (Exception ex){
            ApexPages.addMessages(ex);
            stackTrace = ex.getStackTraceString();
            Database.rollback(sp);
            return null;
        }

        // Lead Conversion on Opt-In
        D2D_Utility.ErrorMessage errorMessage = new D2D_Utility.ErrorMessage('', '');
        try{
            errorMessage = D2D_Utility.ConvertLead(relatedLead.Id, d2dProposal);
        } catch (Exception ex){
            ApexPages.addMessages(ex);
            stackTrace = ex.getStackTraceString();
            Database.rollback(sp);
        }

        PageReference pr = null;
        if(errorMessage.Message == 'Success'){
            // Redirect 
            pr = Page.D2D_LeadScheduledVisits;
            pr.getParameters().put('id', referralId);
            pr.setRedirect(true);
        } else {
            system.debug('**SZ: something went wrong!');
            ApexPages.addMessage(D2D_Utility.GetMessageFromString(ApexPages.Severity.ERROR, errorMessage.Message));
            stackTrace = errorMessage.ErrorFields;
            Database.rollback(sp);
        }
        return pr;
    }
}