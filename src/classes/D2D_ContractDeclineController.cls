public without sharing class D2D_ContractDeclineController extends D2D_BaseReferralController {

    public override List<String> getPortalReferralFields(){
        return new List<String> {
            'D2D_Lead_Status__c',
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
            'Id'
        };
    }

    public override List<String> getOpportunityFields(){
    	return new List<String> {
    		'Id',
    		'StageName',
    		'Closed_Reason__c',
            'Closed_Reason_Detail__c'
    	};
    }

    public String closedNotes {get;set;}
    public String selectedClosedReason {get;set;}
    public List<SelectOption> closedReasons {
        get { return D2D_Utility.GetPicklistOptions(Opportunity.Closed_Reason__c.getDescribe(), true, '-- Select Reason --'); }
    }


	public D2D_ContractDeclineController(){
        try{
            if(relatedOpportunity.Closed_Reason__c != null)
            {
                selectedClosedReason = relatedOpportunity.Closed_Reason__c;
            }
            if(relatedOpportunity.Closed_Reason_Detail__c != null)
            {
                closedNotes = relatedOpportunity.Closed_Reason_Detail__c;
            }
        } catch (Exception ex){
            ApexPages.addMessages(ex);
            stackTrace = ex.getStackTraceString();
        }
	}


	public PageReference decline(){
        Savepoint sp = Database.setSavepoint();
        try{
            if(closedNotes == ''){
                ApexPages.addMessage(D2D_Utility.GetMessageFromString(ApexPages.Severity.ERROR, 'Notes were not provided.'));
                Database.rollback(sp);
                return null;
            }

            referral.D2D_Lead_Status__c = 'Contract Declined';
            update referral;
            
            relatedOpportunity.StageName = 'Closed - Lost';
            relatedOpportunity.Closed_Reason__c = selectedClosedReason;
            relatedOpportunity.Closed_Reason_Detail__c = closedNotes;
            update relatedOpportunity;
        } catch (Exception ex){
            ApexPages.addMessages(ex);
            stackTrace = ex.getStackTraceString();
            Database.rollback(sp);
            return null;
        }

		PageReference pr = Page.D2D_LeadMenu;
        pr.getParameters().put('id', referral.Id);
        pr.setRedirect(true);
        return pr;
	}
}