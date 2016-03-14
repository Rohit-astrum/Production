public without sharing class D2D_LeadInformationController extends D2D_BaseReferralController {

  public override Boolean getIdRequired() {
    return !D2D_Utility.d2dSettings.Allow_Lead_Creation__c;
  }

    public D2D_Utility.ErrorMessage errorMessage { get; private set; }
    public Boolean duplicate { get; private set; }

    public String newState { get; set; }
    public String county { get; set; }
    public String qasCounty { get; set; }
    public String homeOwner { get; set; }
    public String electricBill { get; set; }
    public String utilityId { get; set; }
    public String propertyNotes { get; set; }
    public String timeline { get; set; }
    public String salutation { get; set; }
    public String bestTime { get; set; }
    public Boolean subscribe { get; set; }
    public String affiliateCommunityProgram { get; set; }
    public String primarySourceCampaign { get; set; }

    private String verifiedStreet;
    private String verifiedCity;
    private String verifiedState;

    // LLH - additions
    public transient String confirmedLatitude {get; set;}
    public transient String confirmedLongitude {get; set;}
    // end - LLH

    private static final Map<String, Set<String>> STATE_SITEQUALITY_MAP = new Map<String, Set<String>> {
        'CA' => new Set<String> { '1400', '1500', '1600' }, 
        'NY' => new Set<String> { '1050', '1150', '1250' },
        'XX' => new Set<String> { '1050', '1150', '1250', '1400', '1500', '1600' }
    };

    private static final Map<String, Set<String>> STATE_SYSTEMSIZE_MAP = new Map<String, Set<String>> {
        'CA' => new Set<String> { '16 Panel', '24 Panel' }, 
        'CT' => new Set<String> { '24 Panel', '36 Panel' },
        'MA' => new Set<String> { '24 Panel', '36 Panel' },
        'NJ' => new Set<String> { '24 Panel', '36 Panel' },
        'NY' => new Set<String> { '24 Panel', '36 Panel' },
        'XX' => new Set<String> { '16 Panel', '24 Panel', '36 Panel' }
    };

    public List<SelectOption> states {
        get { return D2D_Utility.GetPicklistOptions(Portal_Referral__c.State__c.getDescribe(), true, '-- Select State --'); }
    }
    
    public List<Selectoption> timelines {
        get { return D2D_Utility.GetPicklistOptions(Lead.Customer_Timeframe__c.getDescribe(), true, '-- Select --'); }
    }
    
    public List<SelectOption> salutations {
        get { return D2D_Utility.GetPicklistOptions(Lead.Salutation.getDescribe(), true, '--'); }
    }

    public List<SelectOption> bestTimes {
        get { return D2D_Utility.GetPicklistOptions(Lead.Best_Time_to_Call__c.getDescribe(), true, '-- Select --'); }
    }

    public List<SelectOption> affiliateCommunityPrograms {
        get {
            if(affiliateCommunityPrograms == null){
                List<SelectOption> allOptions = D2D_Utility.GetPicklistOptions(Lead.Affiliate_Community_Program__c.getDescribe(), true, '-- Select --');
                affiliateCommunityPrograms = new List<SelectOption>();
                for(SelectOption so : allOptions){
                    if(so.getValue() == '0' || so.getLabel().contains('D2D')){
                        affiliateCommunityPrograms.add(so);
                    }
                }
            }
            return affiliateCommunityPrograms;
        }
        set;
    }

    private List<Selectoption> allCounties {
        get {
            if(allCounties == null){
                allCounties = D2D_Utility.GetPicklistOptions(Lead.County__c.getDescribe(), true, '-- Select --');
            }
            return allCounties;
        }
        set;
    }
    public List<SelectOption> counties {
        get {
            List<SelectOption> filteredCounties = new List<SelectOption>();
            String stateTemp = '|';
            if(referral.Id != null){
                stateTemp = (newState == 'WV') ? 'w va' : newState.toLowerCase();
            }
            for(SelectOption so : allCounties){
                String val = so.getValue().toLowerCase();
                if(val == '0' || val.endsWith('(' + stateTemp + ')') || val.endsWith(stateTemp)){
                    filteredCounties.add(so);
                }
            }
            return filteredCounties;
        }
    }
/*
    public List<SelectOption> siteQualities {
        get { 
            List<SelectOption> result = new List<SelectOption>();
            result.add(new SelectOption('', '-- Select --'));
            if(newState != null && STATE_SITEQUALITY_MAP.containsKey(newState)) {
                for(String sq : STATE_SITEQUALITY_MAP.get(newState)) {
                    result.add(new SelectOption(sq, sq));
                }
            } else {
                for(String sq : STATE_SITEQUALITY_MAP.get('XX')) {
                    result.add(new SelectOption(sq, sq));
                }
            }
            return result;
        }
    }
*/    
    public List<SelectOption> systemSizes {
        get { 
            List<SelectOption> result = new List<SelectOption>();
            result.add(new SelectOption('', '-- Select --'));
            if(newState != null && STATE_SYSTEMSIZE_MAP.containsKey(newState)) {
                for(String ss : STATE_SYSTEMSIZE_MAP.get(newState)) {
                    result.add(new SelectOption(ss, ss));
                }
            } else {
                for(String ss : STATE_SYSTEMSIZE_MAP.get('XX')) {
                    result.add(new SelectOption(ss, ss));
                }
            }
            return result;
        }
    }

    //05/29/2015 - PB  - SFS-228 changed the query to have Utility Company Master Name 
    public List<SelectOption> getUtilities() {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('', '-- Select --'));
        if (newState != null) {
            List<Utility_Company_Master__c> utilities = 
                [SELECT Id, Name, State_Serviced__c
                FROM Utility_Company_Master__c
                WHERE State_Serviced__c = :newState
                AND Externally_Available__c = true
                ORDER BY Name];
            for (Utility_Company_Master__c u : utilities) {
                result.add(new SelectOption(u.Id, u.Name));                 
            }
        }
        return result;
    }

    public List<SelectOption> getCampaigns() {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('', '-- Select --'));
        if (newState != null) {
            List<Campaign> campaigns = 
                [SELECT Id, Name, State__c
                FROM Campaign
                WHERE State__c = :newState AND Name LIKE '%D2D%'
                ORDER BY Name];
            for (Campaign c : campaigns) {
                result.add(new SelectOption(c.Id, c.Name));                 
            }
        }
        return result;
    }

    public D2D_Proposal__c ssg {
        get {
            if(ssg == null){
                if(referral.D2D_System_Size__c != null && relatedLead.Utility_Company_Master__c != null){
                    Decimal numberOfPanels = Decimal.valueOf(referral.D2D_System_Size__c.replace(' Panel', ''));
                    List<D2D_Proposal__c> ssgList = [SELECT Id, Total_of_Payments_Without_Solar__c, Total_of_Payments_With_Solar__c, Payments_Without_Solar__c, Payments_With_Solar__c 
                                                        FROM D2D_Proposal__c WHERE Utility_Company_Master__c = :relatedLead.Utility_Company_Master__c AND Number_of_Panels__c = :numberOfPanels LIMIT 1];
                    if(ssgList.size() == 1) {
                        ssg = ssgList[0];
                    } else {
                        // should never get to this condition
                        errorMessage = new D2D_Utility.ErrorMessage('More than one Solar Savings Guide for the rate code-panels-site quality was found.','[0][other]');
                    }
                }
            }
            return ssg;
        }
        set;
    }

    public Boolean readyForSSG {
        get {
             return (ssg != null && (relatedLead.QAS_County__c != null || relatedLead.County__c != null));
        }
    }
    
    public Boolean readyToContinue {
        get {
            Boolean valid = isValid();
            if(valid){
              return true;
            }
            return false;
        }
    }
    
    //check if input is valid
    public Boolean isValid() {
        validate(true);
        if (String.isNotBlank(errorMessage.Message)) {
                return false;
            }
        return true;
    }

    public String ssgWarningText {
        get {
            if(ApexPages.hasMessages() || (errorMessage != null && String.isNotBlank(errorMessage.Message))){
                return '';
            } else if(readyForSSG && referral.SSG_Accepted__c == 'True'){
                return 'This lead has already accepted the Solar Savings Guide.';
            } else if(readyForSSG && referral.D2D_Lead_Status__c != 'Passed Validation'){
                return 'This lead has not been validated.  Save the lead to validate.';
            } else if(!readyForSSG && readyToContinue && relatedLead.QAS_County__c == null && relatedLead.County__c == null){
                return 'Address validation is not yet complete.  Please wait a moment and re-save the lead to update address verification.';
            } else if(!readyForSSG && String.isNotBlank(utilityId) && String.isNotBlank(referral.D2D_System_Size__c)){
                return 'A Solar Savings Guide could not be located for that utility company and system size.  Contact an administrator.';
            } else {
                return '';
            }
        }
    }


  public D2D_LeadInformationController() {
        try{
            errorMessage = new D2D_Utility.ErrorMessage('','');
            if(referral == null) {
                referral = new Portal_Referral__c();
                relatedLead = new Lead();
                homeOwner = 'No';
            } else {
                if(relatedLead != null){
                    qasCounty = relatedLead.QAS_County__c;
                    county = relatedLead.County__c;
                    salutation = relatedLead.Salutation;
                    homeOwner = relatedLead.Home_Owner__c ? 'Yes' : 'No';
                    electricBill = String.valueOf(relatedLead.Monthly_Electric_Bill__c);
                    bestTime = relatedLead.Best_Time_to_Call__c;
                    timeline = relatedLead.Customer_Timeframe__c;
                    propertyNotes = relatedLead.Property_Notes__c;
                    utilityId = relatedLead.Utility_Company_Master__c;
                    affiliateCommunityProgram = relatedLead.Affiliate_Community_Program__c;
                    primarySourceCampaign = relatedLead.Primary_Source_Campaign__c;
                } else {
                    relatedLead = new Lead();
                }
                newState = referral.State__c;
                
                confirmedLatitude = String.valueOf(referral.Confirmed_Location__Latitude__s);
                confirmedLongitude = String.valueOf(referral.Confirmed_Location__Longitude__s);
            }
        } catch (Exception ex){
            ApexPages.addMessages(ex);
            stackTrace = ex.getStackTraceString();
        }
  }

    public PageReference submit() {
        try{
            if(submit(false) == 0){
                //system.debug('**SZ: is blank = ' + String.isBlank(dashboardUrl));
                PageReference pr = new PageReference(dashboardUrl); // new PageReference('/d2d/D2D_SalesRepDashboard');
                pr.setRedirect(true);
                return pr;
            } else {
                return null;
            }
        } catch (Exception ex){
            ApexPages.addMessages(ex);
            stackTrace = ex.getStackTraceString();
            return null;
        }
    }

    public PageReference submitAndReload() {
        try{
            if(submit(false) == 0){
                PageReference pr = Page.D2D_LeadInformation; // new PageReference('/d2d/D2D_LeadInformation?id=' + referral.Id);
                pr.getParameters().put('id', referral.Id);
                pr.setRedirect(true);
                return pr;
            } else {
                return null;
            }
        } catch (Exception ex){
            ApexPages.addMessages(ex);
            stackTrace = ex.getStackTraceString();
            return null;
        }
    }

    public PageReference submitAndContinue() {
        try{
            if(submit(true) == 0){
                PageReference pr = Page.D2D_SolarSavingsGuidePreview;
                pr.getParameters().put('id', referral.Id);
                pr.setRedirect(true);
                return pr;
            } else {
                return null;
            }
        } catch (Exception ex){
            ApexPages.addMessages(ex);
            stackTrace = ex.getStackTraceString();
            return null;
        }
    }

    public Integer submit(Boolean forSSG) {
        Savepoint sp;
        try {
        	
            boolean isInsert = String.isBlank(referral.Id);
            grabPostData();
            validate(forSSG);
            /*if (String.isNotBlank(errorMessage.Message)) {
                return -1;
            }*/
            
        	//If address has not been entered, display error message.
            if (isInsert && 
            (String.isBlank(referral.Street__c) || 
            String.isBlank(referral.City__c) || 
            String.isBlank(referral.State__c) || referral.State__c == '0' || 
            String.isBlank(referral.Zip__c))) {
            	errorMessage = new D2D_Utility.ErrorMessage('An address must be entered to create a new lead.','');
            	
            	if(String.isBlank(referral.Street__c)) {
		            errorMessage.ErrorFields += '[1][street]';
		        }
		        if(String.isBlank(referral.City__c)) {
		            errorMessage.ErrorFields += '[1][city]';
		        }
		        if(String.isBlank(referral.State__c) || referral.State__c == '0') {
		            errorMessage.ErrorFields += '[1][state]';
		        }
		        if(String.isBlank(referral.Zip__c)) {
		            errorMessage.ErrorFields += '[1][zip]';
		        }
                return -1;
            }
            verifyAddress();
            duplicate = isDuplicate();
            sp = Database.setSavepoint();
            createReferral();
            if (!duplicate) {
                try {
                    createLead();
                } finally {
                }
                if (ApexPages.hasMessages()) {
                    if (sp != null) {
                        Database.rollback(sp);
                    }
                    return -1;
                }
            }
            else if(isInsert) {
            	errorMessage = new D2D_Utility.ErrorMessage('A lead with this address already exists. Contact Help Desk to have this lead moved to the portal.','[0][other]');
            	return -1;
            }
            // end - LLH
        } catch (Exception e) {
            //system.debug('**SZ: got in here');
            if (e instanceof DMLException) {
                System.DMLException dmlExcp = (System.DMLException)e;
                errorMessage = new D2D_Utility.ErrorMessage('Please make sure all required fields are filled out and formatted correctly.','');
                for (String field : dmlExcp.getDmlFieldNames(0)) {
                    errorMessage.ErrorFields += '[' + field + ']';
                }
                return -1;
            } else {
                errorMessage = new D2D_Utility.ErrorMessage('ERROR: Could not save information. ' + e.getMessage(), e.getStackTraceString());
                return -1;
            }
        }
        return 0;
    }
    
    //Grabs radio button values from post data (non-visualforce inputs)
    private void grabPostData() {
        if(!Test.isRunningTest()){
            Map<String,String> params = ApexPages.currentPage().getParameters();
            referral.Primary_Phone__c = params.get('primaryPhone');
            homeOwner = params.get('homeOwnerSwitch');
            if( String.isNotBlank(confirmedLatitude) && String.isNotBlank(confirmedLongitude) ) {
                referral.Confirmed_Location__Latitude__s = Decimal.valueOf(confirmedLatitude);
                referral.Confirmed_Location__Longitude__s = Decimal.valueOf(confirmedLongitude);
            }
        }
    }
    
    //logs errors to the apex job queue
    @future
    public static void logError(String errorMsg) {
        System.assert(false, errorMsg);
    }

    //validate input fields    
    public void validate() {
        if(Test.isRunningTest()){
            validate(false);
        }
    }

    private void validate(Boolean forSSG) {
        errorMessage = new D2D_Utility.ErrorMessage('','');
        
        //home information
        if(String.isBlank(referral.Street__c)) {
            errorMessage.ErrorFields += '[1][street]';
        }
        if(String.isBlank(referral.City__c)) {
            errorMessage.ErrorFields += '[1][city]';
        }
        if(String.isBlank(referral.State__c) || referral.State__c == '0') {
            errorMessage.ErrorFields += '[1][state]';
        }
        if(String.isBlank(referral.Zip__c)) {
            errorMessage.ErrorFields += '[1][zip]';
        }
/*        if(String.isBlank(qasCounty) && (String.isBlank(county) || county == '0')) {
            errorMessage.ErrorFields += '[1][county]';
        }*/
        if(String.isBlank(homeOwner)) {
            errorMessage.ErrorFields += '[1][homeOwner]';
        }
        if(String.isBlank(electricBill)) {
            errorMessage.ErrorFields += '[1][electricBill]';
        }
        if(String.isNotBlank(electricBill)) {
            try {
                Decimal val = Decimal.ValueOf(electricBill); 
            } catch (Exception e) {
                errorMessage.ErrorFields += '[1][electricBill.NaN]';
            }
        }
        if(String.isBlank(affiliateCommunityProgram) || affiliateCommunityProgram == '0') {
            errorMessage.ErrorFields += '[1][affiliateCommunityProgram]';
        }
        if(String.isBlank(primarySourceCampaign)) {
            errorMessage.ErrorFields += '[1][primarySourceCampaign]';
        }

        //contact information
        if(String.isBlank(referral.First_Name__c)) {
            errorMessage.ErrorFields += '[2][fname]';
        }
        if(String.isBlank(referral.Last_Name__c)) {
            errorMessage.ErrorFields += '[2][lname]';
        }
        if(String.isBlank(referral.Email__c)) {
            errorMessage.ErrorFields += '[2][email]';
        }
        if(String.isBlank(referral.Phone__c)) {
            errorMessage.ErrorFields += '[2][phone]';
        }
        if(String.isNotBlank(referral.Phone__c) || String.isNotBlank(referral.Work_Phone__c)
            || String.isNotBlank(referral.Mobile_Phone__c)) {
            Integer phoneCount = (String.isNotBlank(referral.Phone__c) ? 1 : 0)
                + (String.isNotBlank(referral.Mobile_Phone__c) ? 1 : 0)
                + (String.isNotBlank(referral.Work_Phone__c) ? 1 : 0);
            if(phoneCount == 1) {
                //set primary automatically to avoid validation error
                referral.Primary_Phone__c = 
                    String.isNotBlank(referral.Phone__c) ? 'Home Phone' :
                    String.isNotBlank(referral.Mobile_Phone__c) ? 'Mobile Phone' :
                    String.isNotBlank(referral.Work_Phone__c) ? 'Work Phone' : null;
            } else if (String.isNotBlank(referral.Primary_Phone__c)) {
                if (referral.Primary_Phone__c == 'Home Phone' && String.isBlank(referral.Phone__c)) {
                    errorMessage.ErrorFields += '[2][primary]';
                } else if (referral.Primary_Phone__c == 'Mobile Phone' && String.isBlank(referral.Mobile_Phone__c)) {
                    errorMessage.ErrorFields += '[2][primary]';
                } else if (referral.Primary_Phone__c == 'Work Phone' && String.isBlank(referral.Work_Phone__c)) {
                    errorMessage.ErrorFields += '[2][primary]';
                }
            } else {
                errorMessage.ErrorFields += '[2][primary]';
            }
        }

        //if (String.isBlank(utilityId) || String.isBlank(referral.D2D_Site_Quality__c) || String.isBlank(referral.D2D_System_Size__c)) {
        if (String.isBlank(utilityId) || String.isBlank(referral.D2D_System_Size__c)) {
            errorMessage.ErrorFields += '[3][utility]';
            //errorMessage.ErrorFields += '[3][sitequality]';
            errorMessage.ErrorFields += '[3][systemsize]';
        }

        if(errorMessage.ErrorFields != '') {
            errorMessage.Message = 'Please make sure all required fields are filled out and formatted correctly.';
        }
    }
    
    //standardize address for dupe search
    private void verifyAddress() {

        verifiedStreet = referral.Street__c;
        verifiedCity = referral.City__c;
        verifiedState = referral.State__c;
        
        if (Test.isRunningTest()) {
            return;
        }

        try {       
        
            StrikeIron_Settings__c settings = StrikeIron_Settings__c.getOrgDefaults();
            
            StrikeIronWS.RegisteredUser ru = new StrikeIronWS.RegisteredUser();
            ru.UserID = settings.User_Name__c;
            ru.Password = settings.Password__c;
            
            StrikeIronWS.LicenseInfo li = new StrikeIronWS.LicenseInfo();
            li.RegisteredUser = ru;
            
            StrikeIronAddressV6.NorthAmericanAddressVerificationServiceSoap si 
                = new StrikeIronAddressV6.NorthAmericanAddressVerificationServiceSoap();
            si.LicenseInfo = li;
            
            StrikeIronAddressV6.SIWsOutputOfNorthAmericanAddress result = si.NorthAmericanAddressVerification (
                referral.Street__c, //address line 1
                null,               //address line 2
                referral.Zip__c,    //city state, zip, postal code
                'US',               //country 
                null,               //firm 
                null,               //urbanization
                'PROPER'            //Lower, Upper, Proper
            );
            
            StrikeIronAddressV6.SIWsStatus status = result.ServiceStatus;
            StrikeIronAddressV6.NorthAmericanAddress naAddress = result.ServiceResult;
            StrikeIronAddressV6.USAddress address = naAddress.USAddress;
            
            if (status.StatusNbr == 200 && address.AddressStatus == 'Valid') {
                verifiedStreet = address.AddressLine1;
                if (String.isNotBlank(address.AddressLine2)) {
                    verifiedStreet += '\n' + address.AddressLine2;
                }
                verifiedCity = address.City;
                verifiedState = address.State;
            }
            
        } catch (Exception e) {
        }
    }
    
    //creates portal referral record
    private void createReferral() {
        try{
            boolean isInsert = String.isBlank(referral.Id);
            //system.debug('**SZ: isInsert = ' + isInsert);
            if(isInsert){
                
                if (duplicate == true) {
                    referral.Status__c = PortalReferralStatus.DUPLICATE_STATUS;
                    return;
                } else {
                    referral.Status__c = PortalReferralStatus.OPEN_STATUS;
                    referral.Detail__c = 'New';
                }

                //Group webLeadQueue = [SELECT Id, Name FROM Group WHERE Name = 'Web Lead Queue' LIMIT 1];
                User u = [SELECT Id, ContactId, Profile.Name, D2D_Manager__c FROM User WHERE Id = :UserInfo.getUserId()];
                Contact c = [SELECT Id, AccountId, Account.Portal_Payment_Plan__c,Account.Related_User__r.Id FROM Contact WHERE Id = :u.ContactId];
                
                if(u.Profile.Name == 'D2D Manager'){
                    referral.D2D_Manager__c = UserInfo.getUserId();
                } else if(u.Profile.Name == 'D2D Sales Rep'){
                	referral.D2D_Manager__c = u.D2D_Manager__c;
                	referral.D2D_Sales_Rep__c = UserInfo.getUserId();
                } else if(u.Profile.Name != 'D2D Admin') {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The provided username is not authorized to create a new lead.'));
                }
	            
                
                //referral.OwnerId = webLeadQueue.Id;
                referral.Account__c = c.AccountId;
                referral.Referred_by__c = c.Id;
                referral.Lead_Created_Date__c = Date.today();
            }


            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.allowFieldTruncation = true;
            referral.setOptions(dmo);
            
            if(readyToContinue && relatedLead.County__c != null || relatedLead.QAS_County__C != null){
                Lead tempLead = [SELECT Id, County__c, QAS_County__C FROM Lead WHERE Id = :relatedLead.Id LIMIT 1];
                if(tempLead.County__c != null || tempLead.QAS_County__C != null){
                    referral.D2D_Lead_Status__c = 'Passed Validation';
                }
                else if(referral.D2D_Lead_Status__c == 'Passed Validation'){
            		referral.D2D_Lead_Status__c = 'Prospect New';
           		}
            }
            else if(referral.D2D_Lead_Status__c == 'Passed Validation'){
            	referral.D2D_Lead_Status__c = 'Prospect New';
            }
            upsert referral;
        } catch (Exception ex){
            //ApexPages.addMessages(ex);
            throw ex;
            stackTrace = ex.getStackTraceString();
        }
    }
    
    //check for duplicate by address
    private Boolean isDuplicate() {
/*        if(referral.Id != null){
            return false;
        }
        return true;
*/
        List<Lead> duplicates = 
            [SELECT Id, OwnerId, IsConverted, ConvertedOpportunityId
            FROM Lead
            WHERE Street = :verifiedStreet
            AND City = :verifiedCity
            AND State = :verifiedState
            LIMIT 1];
        if (referral.Id==null && duplicates.size() > 0) {
            return true;
        }
        return false;
    }
    
/*    private void createActivityForDuplicateLead(Lead firstReferral) {
        
        String utilityName;
        if (String.isNotBlank(utilityId)) {
            Utility_Company_Master__c utility = [SELECT Id, Name FROM Utility_Company_Master__c WHERE Id = :utilityId];
            utilityName = utility.Name;
        }
        
        String subject = 'Duplicate Lead Submitted by ' + UserInfo.getName();
        String summary = 'Property Information'
            + '\nAddress: ' + referral.Street__c
            + '\nCity: ' + referral.City__c
            + '\nState: ' + referral.State__c
            + '\nZip: ' + referral.State__c
            + '\nHome Owner: ' + homeOwner
            //+ '\nSite Confirmed: ' + referral.D2D_Site_Quality__c
            + '\nSite Type: Residential'
            + '\nMo. Eletric Bill: ' + blankValue(electricBill) //optional
            + '\nUtility: ' + blankValue(utilityName) //optional
            + '\nProperty Notes: ' + blankValue(propertyNotes) //optional
            
            + '\n\nContact Information'
            + '\nSalutation: ' + blankValue(salutation)
            + '\nFirst Name: ' + referral.First_Name__c
            + '\nLast Name: ' + referral.Last_Name__c
            + '\nEmail: ' + blankValue(referral.Email__c)
            + '\nHome Phone: ' + blankValue(referral.Phone__c)
            + '\nCell Phone: ' + blankValue(referral.Mobile_Phone__c)
            + '\nWork Phone: ' + blankValue(referral.Work_Phone__c)
            + '\nPrimary Phone: ' + blankValue(referral.Primary_Phone__c)

            + '\n\nLead Source Info'
            + '\nLead Date: ' + referral.Lead_Created_Date__c.format()
            + '\nLead Source: ' + referral.Lead_Source__c
            + '\nCustomer Timeframe: ' + blankValue(timeline);
        
        //opportunity
        if (firstReferral.IsConverted == true) {
            if (firstReferral.ConvertedOpportunityId != null) {
                //send email 
                Opportunity opp = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :firstReferral.ConvertedOpportunityId];
                createTask(null, opp.Id, opp.OwnerId, subject, summary);
            }
        } else {
            //add task to lead and send email, owner must be a User object
            if (((String)firstReferral.OwnerId).startsWith('005')) {
                createTask(firstReferral.Id, null, firstReferral.OwnerId, subject, summary);
            }
        }

    }
*/
    private String blankValue(String text) {
        return String.isBlank(text) ? '' : text;
    }

    //creates a task for a lead or opportunity and emails the task/record owner    
/*    @future
    private static void createTask(String leadId, String opportunityId, String owner, String subject, String summary) {
        Task t = new Task(
            OwnerId = owner,
            Subject = subject,
            Description = summary,
            WhoId = leadId,
            WhatId = opportunityId
        );
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.EmailHeader.triggerUserEmail = true;
        Database.insert(t, dmo);
    }
*/
    //create the lead record
    private void createLead() {
        if(relatedLead.IsConverted){
            return;
        }
        
        try{
            Group webReferralQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'WebLeadQueue'];
            Id assignId = webReferralQueue.Id;
            Lead newLead = new Lead(
                OwnerId = assignId,

                //home info
                Street = referral.Street__c,
                City = referral.City__c,
                State = referral.State__c,
                D2D_State__c = referral.State__c,
                PostalCode = referral.Zip__c,
                County__c = (county == '0') ? '' : county,
                Home_Owner__c = (homeOwner == 'Yes'),
                //Site_Quality_Confirmed__c = referral.D2D_Site_Quality__c,
                Site_Type__c = 'Residential',
                Monthly_Electric_Bill__c = (String.isNotBlank(electricBill) ? Decimal.valueOf(electricBill).intValue() : null),
                Utility_Company_Master__c = utilityId,
                Property_Notes__c = propertyNotes,
                Confirmed_Location__Latitude__s = referral.Confirmed_Location__Latitude__s,
                Confirmed_Location__Longitude__s = referral.Confirmed_Location__Longitude__s,
                Affiliate_Community_Program__c = (affiliateCommunityProgram == '0') ? '' : affiliateCommunityProgram,
                Primary_Source_Campaign__c = (primarySourceCampaign == '0') ? '' : primarySourceCampaign,
                
                //contact info
                
                
                Salutation = (salutation == '0') ? '' : salutation,
                FirstName = referral.First_Name__c,
                LastName = referral.Last_Name__c,
                Company = referral.Last_Name__c + ', ' + referral.First_Name__c,
                Email = referral.Email__c,
                Phone = referral.Phone__c,
                MobilePhone = referral.Mobile_Phone__c,
                Work_Phone__c = referral.Work_Phone__c,
                Primary_Phone__c = referral.Primary_Phone__c,
                Best_Time_to_Call__c = (bestTime == '0') ? '' : bestTime,
                
                //lead source
                Lead_Date__c = (referral.Lead_Created_Date__c == null) ? Date.today() : referral.Lead_Created_Date__c,
                LeadSource = 'Canvassing',
                Lead_Source_Detail__c = 'Canvassing',
                Method_of_Contact__c = 'In-Person',
                Customer_Timeframe__c = (timeline == '0') ? '' : timeline
            );
            if(relatedLead.Id == null){
                TriggerUtility.bypassLeadTriggersForBatchProcessing = true;

                String leadStatus = '';
                List<SelectOption> leadStatuses = D2D_Utility.GetPicklistOptions(Lead.Status.getDescribe(), false);
                for(SelectOption so : leadStatuses){
                    if(so.getValue().contains('Prospect') && so.getValue().contains('New')){
                        leadStatus = so.getValue();
                    }
                }
                newLead.Status = leadStatus;

                //allow field truncation
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.allowFieldTruncation = true;
                newLead.setOptions(dmo);
                
                insert newLead;
                TriggerUtility.bypassLeadTriggersForBatchProcessing = false;
                
                referral.Lead__c = newLead.Id;
                update referral;
            } else {

                newLead.Id = relatedLead.Id;
                update newLead;
            }
        } catch(Exception ex){
            //ApexPages.addMessages(ex);
            throw ex;
            stackTrace = ex.getStackTraceString();
        }
    }
}