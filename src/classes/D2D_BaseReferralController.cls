public virtual class D2D_BaseReferralController {

    public String referralId {get;set;}
    public Portal_Referral__c referral {get;set;}
    public Lead relatedLead {get;set;}
    public Opportunity relatedOpportunity {get;set;}
	
    public String leadInformationState {get;set;}
    public String propertyPhotosState {get;set;}
    public String creditCheckState {get;set;}
    public String ssgState {get;set;}
    public String proposalState {get;set;}
    public String contractState {get;set;}
    public String recordVisitState {get;set;}
    public String scheduledVisitsState {get;set;}
    public String optOutState {get;set;}
    public String declineContractState {get;set;}

    public virtual List<String> getPortalReferralFields(){
        return new List<String> {
        	'Account__c',
        	//'Carrier_Route__c',
            'City__c',
            'Confirmed_Location__Latitude__s',
            'Confirmed_Location__Longitude__s',
            'Credit_Approved__c',
            'D2D_Lead_Status__c',
            'D2D_Sales_Rep__c',
            'D2D_Site_Quality__c',
            'D2D_System_Size__c',
            'Detail__c',
            'Email__c',
            'First_Name__c',
            'First_Visit_Datetime__C',
            'First_Visit_Notes__c',
            'Full_Name__c',
            'Id',
            'Last_Name__c',
            'Lead__c',
            'Lead_Created_Date__c',
            'Lead_Source__c',
            'Mobile_Phone__c',
            'Opportunity__c',
            'Opt_Out_Notes__c',
            'Phone__c',
            'Primary_Phone__c',
            'Referred_by__c',
            'Second_Visit_Datetime__c',
            'Second_Visit_Notes__c',
            'SSG_Accepted__c',
            'State__c',
            'Status__c',
            'Street__c',
            'Third_Visit_Datetime__c',
            'Third_Visit_Notes__c',
            //'Walk_Sequence__c',
            'Work_Phone__c',
            'Zip__c'
        };
    }

    public virtual List<String> getLeadFields(){
        return new List<String> {
            'Affiliate_Community_Program__c',
            'Best_Time_to_Call__c',
            'County__c',
            'Customer_Timeframe__c',
            'D2D_Site_Quality__c',
            'D2D_State__c',
            'D2D_System_Size__c',
            'Home_Owner__c',
            'Id',
            'IsConverted',
            'Monthly_Electric_Bill__c',
            'Primary_Source_Campaign__c',
            'Property_Notes__c',
            'QAS_County__c',
            'Salutation',
            'Status',
            'Unqualified_Reason__c',
            'Utility_Company_Master__c',
            'Utility_Company__c'
        };
    }

    public virtual List<String> getOpportunityFields() {
        return new List<String> {
            'Id',
    		'StageName',
            'Property__c'
        };
    }


    public String stackTrace {get;set;}

    public String dashboardUrl {
        get {
            if(dashboardUrl == null || String.isBlank(dashboardUrl)){
                dashboardUrl = D2D_Utility.GetDashboardUrl(UserInfo.getProfileId());
            }
            return dashboardUrl;
        }
        set;
    }

/*    public virtual String getDashboardUrl() {
        system.debug('**SZ: base is blank = ' + String.isBlank(dashboardUrl));
        if(String.isBlank(dashboardUrl)){
            dashboardUrl = D2D_Utility.GetDashboardUrl(UserInfo.getProfileId());
        }
        return dashboardUrl;
    }

    public virtual void setDashboardUrl(String url) {
        dashboardUrl = url;
    }
*/

	public D2D_BaseReferralController() {
        try{
            referralId = D2D_Utility.GetValueFromParam('id');
            reloadBaseRecords(referralId);
            determinePageStates();
        } catch(Exception ex){
            ApexPages.addMessages(ex);
            stackTrace = ex.getStackTraceString();
        }
	}

    public virtual Boolean getIdRequired() {
        return true;
    }

    public virtual Boolean getUseForUpdate() {
    	return false;
    }

    public virtual void reloadBaseRecords(String newReferralId) {
        referralId = newReferralId;
        if(referralId == ''){
            if(getIdRequired()){
                // Error Condition
                throw new D2D_Utility.D2DException('A referral id must be provided to load this page.');
            }
        } else {
        	String forUpdate = '';
        	if(getUseForUpdate()){ forUpdate = ' FOR UPDATE'; }
            referral = Database.query('SELECT ' + String.join(getPortalReferralFields(), ',') + ' FROM Portal_Referral__c WHERE Id = \'' + String.escapeSingleQuotes(referralId) + '\' LIMIT 1' + forUpdate);

            if(String.isNotBlank(referral.Lead__c)){
                relatedLead = Database.query('SELECT ' + String.join(getLeadFields(), ',') + ' FROM Lead WHERE Id = \'' + String.escapeSingleQuotes(referral.Lead__c) + '\' LIMIT 1' + forUpdate);
            } else if(String.isNotBlank(referral.Opportunity__c)){
                // try to get the lead by the ConvertOpportunityId field
                List<Lead> convertedLeads = [SELECT Id FROM Lead WHERE ConvertedOpportunityId = :referral.Opportunity__c];
                if(convertedLeads.size() == 1){
                    relatedLead = Database.query('SELECT ' + String.join(getLeadFields(), ',') + ' FROM Lead WHERE Id = \'' + String.escapeSingleQuotes(convertedLeads[0].Id) + '\' LIMIT 1' + forUpdate);
                }
            }

            if(String.isNotBlank(referral.Opportunity__c)){
                relatedOpportunity = Database.query('SELECT ' + String.join(getOpportunityFields(), ',') + ' FROM Opportunity WHERE Id = \'' + String.escapeSingleQuotes(referral.Opportunity__c) + '\' LIMIT 1' + forUpdate);
            }
        }
    }
    
     public virtual void determinePageStates() {
     	if(getIdRequired() || referral != null){
	     	//Set initial button states
			leadInformationState = 'enabled';
			recordVisitState = 'enabled';
			optOutState = 'enabled';
			
			ssgState = 'disabled';
			scheduledVisitsState = 'disabled';
			propertyPhotosState = 'disabled';
			proposalState = 'disabled';
			contractState = 'disabled';
			creditCheckState = 'disabled';
			declineContractState = 'disabled';

			//If customer has opted out, disable all buttons except opt out 
			if(referral.D2D_Lead_Status__c=='Customer Opt-Out') {
				
				optOutState = 'enabled';
				
				recordVisitState = 'disabled';
				leadInformationState = 'disabled';
				ssgState = 'disabled';
				scheduledVisitsState = 'disabled';
				propertyPhotosState = 'disabled';
				proposalState = 'disabled';
				contractState = 'disabled';
				creditCheckState = 'disabled';
				declineContractState = 'disabled';
			}
			else if (relatedOpportunity !=null && relatedOpportunity.StageName == 'Closed - Lost'){
				
				declineContractState = 'enabled';
			
				optOutState = 'disabled';
				recordVisitState = 'disabled';
				leadInformationState = 'disabled';
				ssgState = 'disabled';
				scheduledVisitsState = 'disabled';
				propertyPhotosState = 'disabled';
				proposalState = 'disabled';
				contractState = 'disabled';
				creditCheckState = 'disabled';
			}
			else {
				
				//Set button states based on lead status
				if (referral.D2D_Lead_Status__c=='Passed Validation')
				{
					leadInformationState = 'completed';
					ssgState = 'enabled';	
				}
				else if (referral.D2D_Lead_Status__c=='Customer Opt-In')
				{
					recordVisitState = 'disabled';
					leadInformationState = 'completed';
					ssgState = 'completed';	
					scheduledVisitsState = 'enabled';
				}
				else if (referral.D2D_Lead_Status__c=='Visit Scheduled' || referral.D2D_Lead_Status__c=='Missing Utility Bill'){
					recordVisitState = 'disabled';
					leadInformationState = 'completed';
					ssgState = 'completed';	
					scheduledVisitsState = 'completed';
					propertyPhotosState = 'enabled';	
				}
				else if(referral.D2D_Lead_Status__c=='Photos Submitted'){
					recordVisitState = 'disabled';
					leadInformationState = 'completed';
					ssgState = 'completed';	
					scheduledVisitsState = 'completed';
					propertyPhotosState = 'completed';	
				}
				else if(referral.D2D_Lead_Status__c=='Contract Generated' || referral.D2D_Lead_Status__c=='Signing In Process'){
					recordVisitState = 'disabled';
					leadInformationState = 'completed';
					ssgState = 'completed';	
					scheduledVisitsState = 'completed';
					propertyPhotosState = 'completed';	
					proposalState = 'enabled';
					contractState = 'enabled';
					creditCheckState = 'enabled';
					declineContractState = 'enabled';
					optOutState = 'disabled';
				}
				else if (referral.D2D_Lead_Status__c=='Credit Approved'){
					recordVisitState = 'disabled';
					leadInformationState = 'completed';
					ssgState = 'completed';	
					scheduledVisitsState = 'completed';
					propertyPhotosState = 'completed';	
					creditCheckState = 'completed';
					proposalState = 'enabled';
					contractState = 'enabled';
					declineContractState = 'enabled';
					optOutState = 'disabled';
				}
				else if (referral.D2D_Lead_Status__c=='Sold'){
					recordVisitState = 'disabled';
					leadInformationState = 'disabled';
					ssgState = 'disabled';	
					scheduledVisitsState = 'completed';
					propertyPhotosState = 'completed';	
					creditCheckState = 'disabled';
					proposalState = 'completed';
					contractState = 'completed';
					declineContractState = 'disabled';
					optOutState = 'disabled';
				}
				
				//If credit approval is not required, hide credit check button
				if(!D2D_Utility.d2dSettings.Credit_Approval_Required__c){
					creditCheckState = 'hidden';
				}
			}
		}
     }
}