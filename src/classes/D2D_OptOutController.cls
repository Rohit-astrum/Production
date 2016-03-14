public without sharing class D2D_OptOutController extends D2D_BaseReferralController {

    public override List<String> getPortalReferralFields(){
        return new List<String> {
            'D2D_Lead_Status__c',
            'D2D_Lead_Status_At_Opt_Out__c',
            'D2D_Opt_Out_Detail__c',
            'Id',
            'Lead__c',
            'Opportunity__c',
            'Opt_Out_Notes__c',
            'Full_Name__c'
        };
    }

    public override List<String> getLeadFields(){
        return new List<String> {
            'Id',
            'Status',
            'Unqualified_Reason__c',
            'DoNotCall',
            'HasOptedOutOfEmail',
            'HasOptedOutOfFax',
            'Global_Opt_Out__c',
            'Do_Not_Solicit__c',
            'Do_Not_Mail__c',
            'Do_Not_Text__c'
        };
    }

	public D2D_OptOutController() {
		if(referral.D2D_Lead_Status__c!='Customer Opt-Out') {
			referral.D2D_Lead_Status_At_Opt_Out__c = referral.D2D_Lead_Status__c;
		}
	}
    
    public PageReference optOutSubmit() {
        try{
            Map<String,String> params = ApexPages.currentPage().getParameters();
            String optOutReason = params.get('optOutReason');

            if(referral.Opt_Out_Notes__c == '' && optOutReason != 'IN'){
                ApexPages.addMessage(D2D_Utility.GetMessageFromString(ApexPages.Severity.ERROR, 'Opt out notes were not provided.'));
                return null;
            }
            
            referral.D2D_Lead_Status__c = 'Customer Opt-Out';
            referral.D2D_Opt_Out_Detail__c = optOutReason; 
            if(optOutReason=='NI'){ // Opt out - Not Interested
                relatedLead.Status = 'Prospect Unqualified';
                relatedLead.Unqualified_Reason__c = 'Not Interested in solar';
            }
            else if(optOutReason=='NN' || optOutReason=='NP') { // Opt out - Not Now, Opt out - Not This Product
                Group insideSalesQueue = [SELECT Id, Name FROM Group WHERE DeveloperName = 'InsideSalesQueue' LIMIT 1];
                relatedLead.Status = 'Prospect Contacted';
                relatedLead.OwnerId = insideSalesQueue.Id;
            }
            else if(optOutReason=='NS'){
                relatedLead.Status = 'Prospect Contacted';
                relatedLead.Do_Not_Solicit__c = true;
            }
            else if(optOutReason=='GO'){
                relatedLead.Status = 'Prospect Unqualified';
                relatedLead.Global_Opt_Out__c = true;
                relatedLead.Unqualified_Reason__c = 'Not Interested in solar';
            }
            else if(optOutReason=='IN') { // Opt back in
                Group webLeadQueue = [SELECT Id, Name FROM Group WHERE DeveloperName = 'WebLeadQueue' LIMIT 1];
                referral.D2D_Lead_Status__c = referral.D2D_Lead_Status_At_Opt_Out__c;
                referral.D2D_Opt_Out_Detail__c = ''; 

                relatedLead.Status = 'Prospect Contacted';
                relatedLead.OwnerId = webLeadQueue.Id;
                relatedLead.Unqualified_Reason__c = '';
                relatedLead.Global_Opt_Out__c = false;
                relatedLead.Do_Not_Solicit__c = false;
                relatedLead.DoNotCall = false;
                relatedLead.HasOptedOutOfEmail = false;
                relatedLead.HasOptedOutOfFax = false;
                relatedLead.Do_Not_Mail__c = false;
                relatedLead.Do_Not_Text__c = false;
            }
            else {
                ApexPages.addMessage(D2D_Utility.GetMessageFromString(ApexPages.Severity.ERROR, 'Opt out reason not selected'));
                return null;
            }
            update referral;
            update relatedLead;
        } catch (Exception ex){
            ApexPages.addMessages(ex);
            stackTrace = ex.getStackTraceString();
        }

        PageReference pr = Page.D2D_LeadMenu;
        pr.getParameters().put('id', referral.Id);
        pr.setRedirect(true);
        return pr;
    }
}