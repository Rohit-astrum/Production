public without sharing class D2D_LeadMenuController extends D2D_BaseReferralController {

    public override List<String> getPortalReferralFields(){
        return new List<String> {
            'Full_Name__c',
            'Id',
            'Lead__c',
            'Opportunity__c',
            'D2D_Lead_Status__c',
            'Third_Visit_Datetime__c',
            'Notes__C'
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
            'StageName'
        };
    }

    public String previousNotes {get;private set;}
    public String newNotes {get;set;}

	public D2D_LeadMenuController() {
		if(referral.Third_Visit_Datetime__C != null && recordVisitState=='enabled') {
			recordVisitState = 'completed';
		}
        previousNotes = '';
        if (referral.Notes__c != null){
            previousNotes = referral.Notes__c.replace('\n', '<br/>');
        }
	}

    public PageReference saveNotes(){
        if(referral.Notes__c == null){
            referral.Notes__c = Datetime.now() + ': ' + newNotes;
        } else {
            referral.Notes__c += '\n' + Datetime.now() + ': ' + newNotes;
        }
        update referral;
        previousNotes = referral.Notes__c.replace('\n', '<br/>');
        newnotes = '';

        return null;
    }
}