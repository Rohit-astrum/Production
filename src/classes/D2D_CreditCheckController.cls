public without sharing class D2D_CreditCheckController extends D2D_BaseReferralController {

    public override List<String> getPortalReferralFields(){
        return new List<String> {
            'D2D_Lead_Status__c',
            'Id',
            'Lead__c',
            'Opportunity__c',
            'Credit_Approved__c',
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
    		'Closed_Reason__c'
    	};
    }

    public String creditCheckUrl {
    	get { return D2D_Utility.d2dSettings.Credit_Check_Url__c; }
    }

    public List<SelectOption> creditApproved {
        get { return D2D_Utility.GetPicklistOptions(Portal_Referral__c.Credit_Approved__c.getDescribe(), true, '-- Select --'); }
    }

	public D2D_CreditCheckController() {
		
	}

	public PageReference submit(){
		PageReference pr = null;
		try{
			Map<String,String> params = ApexPages.currentPage().getParameters();
	        String creditApprovedSelection = params.get('creditApprovedRadioBtn');
	        
	        if(creditApprovedSelection == 'Yes'){
	        	referral.Credit_Approved__c = 'Yes';
				referral.D2D_Lead_Status__c = 'Credit Approved';
	            pr = new PageReference('/d2d/D2D_ContractPreview?id=' + referralId);
				pr.setRedirect(true);
			} else if(creditApprovedSelection == 'No') {
				referral.Credit_Approved__c = 'No';
				referral.D2D_Lead_Status__c = 'Closed - Lost';
				relatedOpportunity.StageName = 'Closed - Lost';
	            pr = new PageReference('/d2d/D2D_LeadMenu?id=' + referralId);
				pr.setRedirect(true);
				relatedOpportunity.Closed_Reason__c = 'Denied Credit';
			} else if(creditApprovedSelection == 'Pending') {
				referral.Credit_Approved__c = 'Pending';
	            pr = new PageReference('/d2d/D2D_LeadMenu?id=' + referralId);
				pr.setRedirect(true);
			} else {

			}

			update referral;
			update relatedOpportunity;
		} catch (Exception ex){
			ApexPages.addMessages(ex);
			stackTrace = ex.getStackTraceString();
		}
		
        return pr;
	}
}