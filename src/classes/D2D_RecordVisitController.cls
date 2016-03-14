public without sharing class D2D_RecordVisitController extends D2D_BaseReferralController {

    public override List<String> getPortalReferralFields(){
        return new List<String> {
            'D2D_Lead_Status__c',
            'First_Visit_Datetime__c',
            'First_Visit_Notes__c',
            'Full_Name__c',
            'Id',
            'Lead__c',
            'Opportunity__c',
            'Second_Visit_Datetime__c',
            'Second_Visit_Notes__c',
            'Third_Visit_Datetime__c',
            'Third_Visit_Notes__c'
        };
    }

    public override List<String> getLeadFields(){
        return new List<String> {
            'Id',
            'Status'
        };
    }

    public String newVisitNote {get;set;}

    public List<VisitWrapper> visits {
        get {
            if(visits == null) {
                visits = getListFromReferral(referral);
            }
            return visits;
        }
        set;
    }

	public D2D_RecordVisitController() {
		newVisitNote = '';
	}

    public PageReference submitVisit() {
        try{
            if(visits.size() == 0) {
                referral.First_Visit_Datetime__c = Datetime.now();
                referral.First_Visit_Notes__c = newVisitNote;
                if(referral.D2D_Lead_Status__c == 'Prospect New'){
                    referral.D2D_Lead_Status__c = 'NA Visit 1';
                }
            } else if (visits.size() == 1) {
                referral.Second_Visit_Datetime__c = Datetime.now();
                referral.Second_Visit_Notes__c = newVisitNote;
                if(referral.D2D_Lead_Status__c == 'NA Visit 1'){
                    referral.D2D_Lead_Status__c = 'NA Visit 2';
                }
            } else {
                referral.Third_Visit_Datetime__c = Datetime.now();
                referral.Third_Visit_Notes__c = newVisitNote;
                if(referral.D2D_Lead_Status__c == 'NA Visit 2'){
                    referral.D2D_Lead_Status__c = 'Door Hanger';
                }

                // Update the lead to reassign to Inside Sales
                Group insideSalesQueue = [SELECT Id, Name FROM Group WHERE DeveloperName = 'InsideSalesQueue' LIMIT 1];
                relatedLead.OwnerId = insideSalesQueue.Id;
                relatedLead.Status = 'Prospect Unresponsive';
                update relatedLead;
            }
            update referral;
        } catch (Exception ex){
            ApexPages.addMessages(ex);
            stackTrace = ex.getStackTraceString();
        }

        visits = null;
        newVisitNote = '';
        return null;
    }

    /// WRAPPER CLASSES ///
    public class VisitWrapper {
        public String VisitDatetime {get;set;}
        public String VisitType {get;set;}
        public String VisitNotes {get;set;}

        public VisitWrapper(Datetime dt, String type, String notes) {
            this.VisitDatetime = dt.format();
            this.VisitType = type;
            this.VisitNotes = notes;
        }
    }

    private List<VisitWrapper> getListFromReferral(Portal_Referral__c referral) {
        List<VisitWrapper> visits = new List<VisitWrapper>();
        if(referral.First_Visit_Datetime__C != null) {
            visits.add(new VisitWrapper(referral.First_Visit_Datetime__C, 'NA Visit 1', referral.First_Visit_Notes__c));
        }
        if(referral.Second_Visit_Datetime__C != null) {
            visits.add(new VisitWrapper(referral.Second_Visit_Datetime__C, 'NA Visit 2', referral.Second_Visit_Notes__c));
        }
        if(referral.Third_Visit_Datetime__C != null) {
            visits.add(new VisitWrapper(referral.Third_Visit_Datetime__C, 'Door Hanger', referral.Third_Visit_Notes__c));
        }
        return visits;
    }
}