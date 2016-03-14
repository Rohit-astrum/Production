public with sharing class LeadsAssignmentController {

    public List<SelectOption> filterStates {get;private set;}
    public String selectedState {get;set;}
    public List<SelectOption> filterSegments {get;private set;}
    public String selectedSegment {get;set;}
    public List<SelectOption> filterAffiliateCommunityProgram {get;private set;}
    public String selectedAffiliateCommunityProgram {get;set;}
    public List<SelectOption> filterPrimarySourceCampaign {get;private set;}
    public String selectedPrimarySourceCampaign {get;set;}
    public List<SelectOption> managers {get;private set;}
    public String selectedManager {get;set;}

    public String referralCountMessage {get;private set;}
    public List<PortalReferralWrapper> filteredReferrals {get;private set;}

	public LeadsAssignmentController() {
        filterStates = D2D_Utility.GetPicklistOptions(Portal_Referral__c.State__c.getDescribe());
        filterSegments = D2D_Utility.GetPicklistOptions(Portal_Referral__c.Segment_Priority__c.getDescribe());
        filterAffiliateCommunityProgram = D2D_Utility.GetPicklistOptions(Lead.Affiliate_Community_Program__c.getDescribe());

        filterPrimarySourceCampaign = new List<SelectOption>();
        filterPrimarySourceCampaign.add(new SelectOption('0', '--None--'));
        Map<Id, Campaign> campaigns = new Map<Id, Campaign>([SELECT Id, Name FROM Campaign WHERE Name LIKE '%D2D%']);
        for(Campaign campaign : campaigns.values()){
            filterPrimarySourceCampaign.add(new SelectOption(campaign.Id, campaign.Name));
        }

        managers = new List<SelectOption>();
        managers.add(new SelectOption('0', '--None--'));
        for(User user : [SELECT Id, FirstName, LastName, Email FROM User WHERE Profile.Name = 'D2D Manager']){
            managers.add(new SelectOption(user.Id, user.FirstName + ' ' + user.LastName));
        }

        filterChanged();
    }

    public PageReference filterChanged(){
        filteredReferrals = GetWrapperList();
        return null;
    }

    public String selectedCity { 
        get; 
        set {
            if (selectedCity != value) {
                selectedCity = value;
            }
        } 
    }

    public String selectedCarrierRoute { 
        get; 
        set {
            if (selectedCarrierRoute != value) {
                selectedCarrierRoute = value;
            }
        } 
    }
    
    public PageReference cancel(){
    	selectedSegment = '0';
    	selectedCity = '';
    	selectedCarrierRoute = '';
    	selectedState = '0';
    	selectedManager = '0';
    	filteredReferrals = GetWrapperList();
        return null;
    }

    public PageReference save(){
    	Boolean isValid = true;
    	List<Portal_Referral__c> selectedReferrals = new List<Portal_Referral__c>();
    	if(selectedManager == null || selectedManager == '' || selectedManager == '0'){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You must select a manager to assign.'));
    		isValid = false;
    	} else {
    		for(PortalReferralWrapper prw : filteredReferrals){
    			if(prw.selected){
    				selectedReferrals.add(prw.portalReferral);
    			}
    		}
    		if(selectedReferrals.size() == 0){
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You must select at least one row to assign.'));
    			isValid = false;
    		}
    	}

    	if(isValid){
			try{
	    		for(Portal_Referral__c pr : selectedReferrals){
	    			pr.D2D_Manager__c = selectedManager;
	    		}
	    		update selectedReferrals;

				// Send email to the selectedManager
				SendEmail();
			} catch (DmlException dmlex){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, dmlex.getMessage() + '<br/>' + dmlex.getStackTraceString()));
			} catch (Exception ex){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage() + '<br/>' + ex.getStackTraceString()));
			}
    	}
        return null;
    }

/*    public PageReference save(){
        Boolean isValid = true;
        Set<Id> selectedReferrals = new Set<Id>();
        if(selectedManager == null || selectedManager == '' || selectedManager == '0'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You must select a manager to assign.'));
            isValid = false;
        } else {
            for(PortalReferralWrapper prw : filteredReferrals){
                if(prw.selected){
                    selectedReferrals.add(prw.portalReferral.Id);
                }
            }
            if(selectedReferrals.size() == 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You must select at least one row to assign.'));
                isValid = false;
            }
        }

        if(isValid){
            AssignManagerFuture(selectedReferrals, selectedManager);
        }
        return null;
    }

    @future(callout=false)
    private static void AssignManagerFuture(Set<Id> portalReferrals, Id managerId){
        try{
            List<Portal_Referral__c> referrals = new List<Portal_Referral__c>();
            for(Id prId : portalReferrals){
                referrals.add(new Portal_Referral__c(Id = prId, D2D_Manager__c = managerId));
            }
            update referrals;

            // Send email to the selectedManager
            SendEmail(managerId);
        } catch (DmlException dmlex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, dmlex.getMessage() + '<br/>' + dmlex.getStackTraceString()));
        } catch (Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage() + '<br/>' + ex.getStackTraceString()));
        }
    }
*/

    private List<PortalReferralWrapper> GetWrapperList(){
        String whereClause = 'WHERE D2D_Manager__c = null AND D2D_Lead_Status__c != \'\' AND D2D_Lead_Status__c != \'Duplicate\'';
        if(selectedSegment != null && selectedSegment != '0'){
            whereClause += ' AND Segment_Priority__c = \'' + selectedSegment + '\'';
        }
        if (selectedCity != null && selectedCity.trim() != '') {
            whereClause += ' AND City__c LIKE \'%' + String.escapeSingleQuotes(selectedCity.replace('*','%')) + '%\'';
        }
        if(selectedState != null && selectedState != '0'){
            whereClause += ' AND State__c = \'' + selectedState + '\'';
        }
        if(selectedCarrierRoute != null && selectedCarrierRoute.trim() != ''){
            whereClause += ' AND Carrier_Route__c = \'' + selectedCarrierRoute + '\'';
        }
        if(selectedAffiliateCommunityProgram != null && selectedAffiliateCommunityProgram != '0'){
            whereClause += ' AND Lead__r.Affiliate_Community_Program__c = \'' + selectedAffiliateCommunityProgram + '\'';
        }
        if(selectedPrimarySourceCampaign != null && selectedPrimarySourceCampaign != '0'){
            whereClause += ' AND Lead__r.Primary_Source_Campaign__c = \'' + selectedPrimarySourceCampaign + '\'';
        }

        String soql = 'SELECT Id, First_Name__c, Last_Name__c, D2D_Lead_Status__c, D2D_Manager__c, Street__c, City__c, State__c, Zip__c, Carrier_Route__c, Segment_Priority__c FROM Portal_Referral__c ' + whereClause + ' LIMIT 500';
        List<Portal_Referral__c> referrals = Database.query(soql);

        referralCountMessage = '';
        if(referrals.size() == 500){
            referralCountMessage = 'There were more than 500 records meeting the criteria.  Only the first 500 records will be displayed.';
        }

    	List<PortalReferralWrapper> retList = new List<PortalReferralWrapper>();
    	for(Portal_Referral__c pr : referrals){
    		retList.add(new PortalReferralWrapper(false, pr));
    	}
    	return retList;
    }

    private void SendEmail(){
        EmailTemplate templateId = [SELECT Id FROM EmailTemplate WHERE Name = 'Notify D2D Manager' LIMIT 1];
        if(templateId != null){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateID(templateId.Id); 
            email.setSaveAsActivity(false);
            email.setTargetObjectId(selectedManager);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'The email template could not be found.'));
        }
    }

/*    private static void SendEmail(Id managerId){
        EmailTemplate templateId = [SELECT Id FROM EmailTemplate WHERE Name = 'Notify D2D Manager' LIMIT 1];
        if(templateId != null){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateID(templateId.Id); 
            email.setSaveAsActivity(false);
            email.setTargetObjectId(managerId);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'The email template could not be found.'));
        }
    }
*/
    public class PortalReferralWrapper{
    	public Boolean selected {get;set;}
    	public Portal_Referral__c portalReferral {get;set;}

    	public PortalReferralWrapper(Boolean sel, Portal_Referral__c pr){
    		this.selected = sel;
    		this.portalReferral = pr;
    	}
    }
}