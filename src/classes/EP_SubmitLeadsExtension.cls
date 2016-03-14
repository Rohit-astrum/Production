/* FILE: EP_SubmitLeadsExtension.cls
 * AUTHOR: Tino Mattheou
 * DATE: December 13, 2012
 * PURPOSE: Extension for EP_SubmitLeads page
 * MODIFICATION HISTORY
 * 01/07/2012 - add Primary Source Campaign for acquisition cost
 * 01/17/2012 - use extended end date to filter campaign
 * 06/30/2014 - LLH - adding Long/Lat for confirmed location
 * 10/23/2014 - DK  - Reset LeadSourceNotes upon submission
 * 05/15/2015 - RJ  - Update for Utility
 * 05/29/2015 - PB  - SFS-228 changed the query to have Utility Company Master Name 
 * 01/14/2016  RJ - MIS-200
 */
 
public without sharing class EP_SubmitLeadsExtension {

    private static final Set<String> COMPANY_NAME_SITE_TYPES = new Set<String> {
        'Commercial', 'Non-Profit'
    };

    //a campaign can be selected if this lead source is chosen
    private static final Set<String> CAMPAIGN_LEAD_SOURCES = new Set<String> {
        'Trade Show', 'Community Tabling', 'Community Seminar', 'Solar Open House', 'Canvassing', 'Retail Tabling' 
    };
    
    //Lead source Detail Unknown
    private static final Set<String> UNKNOWN_LEAD_SOURCES = new Set<String> {
        'Search Engine', 'Online Ad', 'Postcard/Mailer'
    };

    private static final Set<String> REFERRING_ACCT_LEAD_SOURCES = new Set<String> {
        'Individual Referral', 'Partner Referral'                                                 
    };

    private static final Set<String> INDV_REFERRING_ACCT_LEAD_SOURCES = new Set<String> {
        'Individual Referral'                                                 
    };
    
    //map lead source to  
    private static final Map<String, String> LEAD_SOURCE_MAP = new Map<String, String> {
        'Trade Show' => 'Event', 
        'Community Tabling' => 'Event',
        'Community Seminar' => 'Event', 
        'Solar Open House' => 'Event',   
        'Canvassing' => 'Event',
        'Retail Tabling' => 'Event',
        'Door Hanger' => 'Offline Ad', 
        'Sales Personal Networking' => 'Other Source',
        'Individual Referral' => 'Individual Referral', 
        'Partner Referral' => 'Partner Referral' ,
        'Postcard/Mailer' => 'Direct Mail',
        'Offline Ad' => 'Offline Ad',
        'Online Ad' => 'Online Ad',
        'Search Engine' => 'Search Engine'
    };
    
   
    private static final Map<String, String> NAME_RANGE_MAP = new Map<String, String> {
        'A' => 'Name < \'B\'',
        'B-Bn' => '(Name >= \'B\' AND Name < \'BO\')',
        'Bo-Bz' => '(Name >= \'BO\' AND Name < \'C\')',
        'C-Cn' => '(Name >= \'C\' AND Name < \'CO\')',
        'Co-Cz' => '(Name >= \'CO\' AND Name < \'D\')',        
        'D-Dd' => '(Name >= \'D\' AND Name < \'DD\')',
        'De-Dz' => '(Name >= \'DD\' AND Name < \'E\')',
        'E-El' => '(Name >= \'E\' AND Name < \'EM\')',
        'Em-Ez' => '(Name >= \'EM\' AND Name < \'F\')',
        'F-Fm' => '(Name >= \'F\' AND Name < \'FN\')',
        'Fn-Fz' => '(Name >= \'FN\' AND Name < \'G\')',
        'G' => '(Name >= \'G\' AND Name < \'H\')',
        'H-I' => '(Name >= \'H\' AND Name < \'J\')',
        'J-Jn' => '(Name >= \'J\' AND Name < \'JO\')',
        'Jo-Jz' => '(Name >= \'JO\' AND Name < \'K\')',
        'K' => '(Name >= \'K\' AND Name < \'L\')',
        'L' => '(Name >= \'L\' AND Name < \'M\')',
        'M-Me' => '(Name >= \'M\' AND Name < \'MF\')',
        'Mf-Mz' => '(Name >= \'MF\' AND Name < \'N\')',
        'N-O' => '(Name >= \'N\' AND Name < \'P\')',
        'P-Q' => '(Name >= \'P\' AND Name < \'R\')',
        'R-Re' => '(Name >= \'R\' AND Name < \'RF\')',
        'Rf-Rz' => '(Name >= \'RF\' AND Name < \'S\')',
        'S-Sn' => '(Name >= \'S\' AND Name < \'SO\')',
        'So-Sz' => '(Name >= \'SO\' AND Name < \'T\')',
        'T-Tn' => '(Name >= \'T\' AND Name < \'TO\')',
        'To-Tz' => '(Name >= \'TO\' AND Name < \'U\')',
        'U-V' => '(Name >= \'U\' AND Name < \'W\')',
        'W-Z' => 'Name >= \'W\'',
        'Unknown' => 'Name = \'Unknown\''
    };
    
    ///////////////////// PROPERTIES ///////////////////////

    public String salutation { get; set; }
    public String bestTime { get; set; }
    public Boolean subscribe { get; set; }
    
    public Portal_Referral__c odm { get; set; }
    public String odmSalutation { get; set; }
    
    public String homeOwner { get; set; }
    public String siteType { get; set; }
    public String electricBill { get; set; }
    public String utilityId { get; set; }
    public String propertyNotes { get; set; }
    public String leadSourceNotes { get; set; }
    public String timeline { get; set; }
    public String rating { get; set; }
    public String secondLeadSource { get; set; }
    public Boolean competitive { get; set; }
    public Boolean selfGen { get; set; }
    public Boolean assignInsideSales { get; set; }
     public Boolean assignFieldSales { get; set; }
    public String siteQuality { get; set; }

    public String errorFields { get; private set; }
    public Boolean duplicate { get; private set; }
    
    public Boolean showCompany { get; private set; }
    public String companyName { get; set; }
    public String newSiteType { get; set; }
    
    public Boolean showCampaign1 { get; private set; } 
    public Boolean showRefAcct1 { get; private set; } 
    public Boolean showRefAcct2 { get; private set; } 
    public Boolean showCampaign2 { get; private set; }
    public Boolean showLeadSourceDetail { get; private set; } 
    
    public String newLeadSource { get; set; }
    public String newLeadSource2 { get; set; }
    public String campaignId { get; set; }
    public String salesRegion { get; set; }
    public String newSalesRegion { get; set; }
    public String leadSourceDetail { get; set; }

    public String refAcct { get; set; }
    public String refAcct2 { get; set; }
    public String nameRange { get; set; } 
    public String newNameRange { get; set; }
    public String newNameRange2 { get; set; }
    
    public String newState { get; set; }
    
    public String expanderSign { get; set; } 

    private Portal_Referral__c referral;
    private ApexPages.StandardController controller;
    
    private String verifiedStreet;
    private String verifiedCity;
    private String verifiedState;

    // LLH - additions
    public transient String confirmedLatitude {get; set;}
    public transient String confirmedLongitude {get; set;}
    // end - LLH

    // Instance fields
    public String searchTerm {get; set;}
    public String selectedAccount {get; set;}

    public String userAlias {
        get { 
            if (userAlias == null) {
                User u = [SELECT Id, Alias FROM User WHERE Id = :UserInfo.getUserId()];
                userAlias = u.Alias;
            }
            return userAlias;
        }
        private set; 
    }
    
    public Boolean isSalesRep{
        get { 
            Profile p = [Select Id from Profile Where Name = 'Field Sales Employee Portal User'];
            if(p.Id == UserInfo.getProfileId() )          
                return true;
            else
                return false;    
        }
    }

    public List<SelectOption> states {
        get { return createPickList(Portal_Referral__c.State__c.getDescribe(), '-- Select State --'); }
    }
    
    public List<SelectOption> siteTypes {
        get { return createPickList(Lead.Site_Type__c.getDescribe(), '-- Select --'); }
    }
    
    public List<Selectoption> timelines {
        get { return createPickList(Lead.Customer_Timeframe__c.getDescribe(), '-- Select --'); }
    }
    
    public List<SelectOption> salutations {
        get { return createPickList(Lead.Salutation.getDescribe(), '-- None --'); }
    }

    public List<SelectOption> bestTimes {
        get { return createPickList(Lead.Best_Time_to_Call__c.getDescribe(), '-- Select --'); }
    }

    public List<SelectOption> odmSalutations {
        get { return createPickList(Lead.ODM_Salutation__c.getDescribe(), '-- None --'); }
    }

    public List<SelectOption> leadSources {
        get { return createPickList(Lead.LeadSource.getDescribe(), '-- Select --'); }
    }
    
    public List<SelectOption> nameRanges {
        get {
            List<SelectOption> result = new List<SelectOption>();
            List<String> ranges = new List<String>(NAME_RANGE_MAP.keySet());
            ranges.sort(); 
            for (String range : ranges) {
                result.add(new SelectOption(range, range));
            }
            return result;
        }
    }
    /* Commented by RJ 
    public List<SelectOption> secondLeadSources {
        get { return createPickList(Lead.Second_Lead_Source__c.getDescribe(), '-- Select --'); }
    }
    */
    public List<SelectOption> ratings {
        get { return createPickList(Lead.Rating.getDescribe(), '-- Select --'); }
    }
    
    public List<SelectOption> siteQualities {
        get { return createPickList(Lead.Site_Quality_Confirmed__c.getDescribe(), null); }
    }

    public List<SelectOption> salesRegions {
        get { return createPickList(Lead.Sales_Region__c.getDescribe(), '-- Region --'); }
    }

    public List<SelectOption> leadSourceDetails {
        get
        {
            List<SelectOption> result = new List<SelectOption>();
            result.add(new SelectOption('', '-- Select --'));
            result.add(new SelectOption('Customer', 'Customer'));
            result.add(new SelectOption('Non-Customer', 'Non-Customer'));        
           return result;
        }
    }
    
    private List<SelectOption> createPickList(Schema.DescribeFieldResult dfr, String blankLabel) {
        List<SelectOption> result = new List<SelectOption>();
        if (String.isNotBlank(blankLabel)) {
            result.add(new SelectOption('', blankLabel));
        }
        for (Schema.PicklistEntry ple : dfr.getPickListValues()) {
            result.add(new SelectOption(ple.getValue(), ple.getLabel()));
        }
        return result;
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
        result.add(new SelectOption('', '-- Campaign --'));
        if (String.isNotBlank(newSalesRegion)) {
            List<Campaign> campaigns = 
                [SELECT Id, Name
                FROM Campaign
                WHERE Sales_Region_s__c INCLUDES (:newSalesRegion)
                AND StartDate <= TODAY 
                AND Extended_End_Date__c >= TODAY
                ORDER BY Name];
            for (Campaign c : campaigns) {
                result.add(new SelectOption(c.Id, c.Name)); 
            }
        }
        return result;
    }

    /*
    public List<SelectOption> refAccountsOptions1;
    public List<SelectOption> refAccountsOptions2;
    public List<SelectOption> refAccountsOptions3;

    public List<SelectOption> getRefAccountsOptions1() {
        refAccountsOptions1 = new List<SelectOption>();
        refAccountsOptions2 = new List<SelectOption>();
        refAccountsOptions3 = new List<SelectOption>();
        getRefAccounts();
        return refAccountsOptions1;    
    }

    public List<SelectOption> getRefAccountsOptions2() {
        return refAccountsOptions2;
    }

    public List<SelectOption> getRefAccountsOptions3() {
        return refAccountsOptions3;    
    }


    public void getRefAccounts() {
        //List<List<SelectOption>> extendedResult = new List<List<SelectOption>();
        List<List<SelectOption>> extendedResult = new List<List<SelectOption>>();
        List<SelectOption> result = new List<SelectOption>();
        integer i = 1;
        result.add(new SelectOption('', '-- Ref Account --'));
        if (newNameRange != null) {
            String query = 'SELECT Id, Name, BillingCity, BillingState FROM Account ' 
                + 'WHERE ' + NAME_RANGE_MAP.get(newNameRange) + ' '
                + 'ORDER BY Name ';
               
            List<Account> accounts = Database.query(query); 
            for (Account a : accounts) {
                result.add(new SelectOption(a.Id, a.Name 
                    + (a.BillingCity != null && a.BillingState != null ? 
                        ' (' + a.BillingCity + ', ' + a.BillingState + ')' : ''))); 

                if (result.size() == 999 )
                {
                    extendedResult.add(result);
                    

                    if(i==1)
                    {
                        refAccountsOptions1.addAll(result);
                        System.debug('**op1 '+result.size());
                    }
                    if(i==2)
                    {
                        refAccountsOptions2.addAll(result);
                    }
                    if(i==3)
                    {
                        refAccountsOptions3.addAll(result);
                    }
                    result = new List<SelectOption>();
                    i = i +1;
                }
            }
            System.debug('**result '+result.size());
            extendedResult.add(result);
            if(i==1)
            {
                refAccountsOptions1.addAll(result);
            }
            if(i==2)
            {
                refAccountsOptions2.addAll(result);
            }
            if(i==3)
            {
                refAccountsOptions3.addAll(result);
            }

            System.debug('**exres '+extendedResult.size());
        }        
    }

    // JS Remoting action called when searching for a account name
    @RemoteAction
    public static List<Account> searchAccount(String searchTerm) {
        System.debug('Account Name is: '+searchTerm );
        List<Account> accounts = Database.query('Select Id, Name from Account where name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\' order by Name');
        return accounts;
    }
    */

//TODO: any referring account filters?
    /*public List<SelectOption> getRefAccounts() {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('', '-- Ref Account --'));
        if (newNameRange != null) {
            String query = 'SELECT Id, Name, BillingCity, BillingState FROM Account ' 
                + 'WHERE ' + NAME_RANGE_MAP.get(newNameRange) + ' '
                + 'ORDER BY Name '
                + 'LIMIT 999'; //should never be more than 999
            List<Account> accounts = Database.query(query); 
            for (Account a : accounts) {
                result.add(new SelectOption(a.Id, a.Name 
                    + (a.BillingCity != null && a.BillingState != null ? 
                        ' (' + a.BillingCity + ', ' + a.BillingState + ')' : ''))); 
            }
        }
        return result;
    }*/
    
     public List<SelectOption> getRefAccounts2() {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('', '-- Ref Account --'));
        if (newNameRange2 != null) {
            String query = 'SELECT Id, Name, BillingCity, BillingState FROM Account ' 
                + 'WHERE ' + NAME_RANGE_MAP.get(newNameRange2) + ' '
                + 'ORDER BY Name '
                + 'LIMIT 999'; //should never be more than 999
            List<Account> accounts = Database.query(query); 
            for (Account a : accounts) {
                result.add(new SelectOption(a.Id, a.Name 
                    + (a.BillingCity != null && a.BillingState != null ? 
                        ' (' + a.BillingCity + ', ' + a.BillingState + ')' : ''))); 
            }
        }
        return result;
    }
    
    /////////////////// METHODS ///////////////////////////////////////

    public EP_SubmitLeadsExtension (ApexPages.StandardController controller) {
        this.controller = controller;
        // resetForm(); - commented out - LLH
        List<String> ranges = new List<String>(NAME_RANGE_MAP.keySet());
        ranges.sort(); 
        newNameRange = nameRange = ranges[0];
    }
    
    public void resetForm() {
        referral = (Portal_Referral__c)controller.getRecord();
        referral.clear();   // LLH
        referral.Lead_Created_Date__c = System.today();
        odm = new Portal_Referral__c();
        subscribe = true;
        selfGen = true;
        expanderSign = '[+]';
        
        // LLH - additions
        // clear Best Time to Call
        bestTime = '-- Select --';
        // clear lat/long
        confirmedLatitude = null;
        confirmedLongitude = null;
        // clear OwnsProperty
        homeOwner = '--Select--';
        // clear Site Type
        siteType = '-- Select --';
        // clear Company Name
        companyName = null;
        // clear Monthly Bill
        electricBill = null;
        // clear Utility
        utilityId = null;
        // Property Notes
        propertyNotes = null;
        // clear Lead Source Notes
        leadSourceNotes = null;
        // end - LLH
    }
    
    
    //determine whether to show company field
    public PageReference siteTypeChanged() {
        showCompany = false;
        
        if (COMPANY_NAME_SITE_TYPES.contains(newSiteType)) {
            showCompany = true;           
           
        }
        return null;
    }
    
    //determine whether to show campaigns or referring accounts for primary lead source
    public PageReference leadSourceChanged() {
        showCampaign1 = false;
        showRefAcct1 = false;
        showLeadSourceDetail = false;
        if (CAMPAIGN_LEAD_SOURCES.contains(newLeadSource)) {
            showCampaign1 = true;
            showCampaign2 = false;
            showRefAcct2 = false;
        } else if (REFERRING_ACCT_LEAD_SOURCES.contains(newLeadSource)) {
            showRefAcct1 = true;
            if (INDV_REFERRING_ACCT_LEAD_SOURCES.contains(newLeadSource)){
                showLeadSourceDetail = true;
            }
            if (REFERRING_ACCT_LEAD_SOURCES.contains(newLeadSource2))
               showRefAcct2 = true;
            else
                showRefAcct2 = false;
        }

        return null;
    }
    
    //determine whether to show campains for secondary lead source
    public PageReference leadSource2Changed() {
        showCampaign2 = false;
        showRefAcct2 = false;
        if (showCampaign1 != true && CAMPAIGN_LEAD_SOURCES.contains(newLeadSource2)) {
            showCampaign2 = true;
        }
        else if (showRefAcct1 == true &&  REFERRING_ACCT_LEAD_SOURCES.contains(newLeadSource2)) {
            showRefAcct2 = true;
        }
        return null;
    }
    
    //forces refresh of utilities
    public PageReference stateChanged() {
        return null;
    }

    //forces refresh of referring account list when range changes
    public PageReference nameRangeChanged() {
        return null;
    }
    
    //forced refresh of campaigns
    public PageReference salesRegionChanged() {
        return null;
    }
    
    public PageReference submit() {
        Savepoint sp;
        try {
            grabPostData();
            validate();
            if (String.isNotBlank(errorFields)) {
                return null;
            }
            verifyAddress();
            duplicate = isDuplicate();
            sp = Database.setSavepoint();
            createReferral();
            if (duplicate == true) {
                return Page.EP_DuplicateLead;
            }
            try {
                //PortalReferralStatus.creatingLeadInPortal = true;
                createLead();
            } finally {
                //PortalReferralStatus.creatingLeadInPortal = false;
            }
            if (ApexPages.hasMessages()) {
                if (sp != null) {
                    Database.rollback(sp);
                }
                return null;
            }
            // LLH - changes
            /* commented out - LLH
            PageReference pr = Page.EP_SubmitLeads;
            pr.setRedirect(true); 
            return pr;
            */
            // save Lead Source
            String tmp = referral.Lead_Source__c;
            String tmp2 = referral.EP_Second_Lead_Source__c;
            resetForm();
            // add Lead Source back in
            referral.Lead_Source__c = tmp;
            referral.EP_Second_Lead_Source__c = tmp2;
            return null;
            // end - LLH
        } catch (Exception e) {

            if (e instanceof DMLException) {
                System.DMLException dmlExcp = (System.DMLException)e;
                for (String field : dmlExcp.getDmlFieldNames(0)) {
                    if (field == 'Email__c') {
                        errorFields += '[2][email]';
                    }
                    if (field == 'ODM_Email__c') {
                        errorFields += '[3][odmemail]';
                    }
                }
            }
            
            if (String.isBlank(errorFields)) {
                if (sp != null) {
                    Database.rollback(sp);
                }
                logError(e.getMessage() + ' ' + e.getStackTraceString());
                errorFields += '[unknown]';
            }
            
        }
        return null;
    }
    
    //Grabs radio button values from post data (non-visualforce inputs)
    private void grabPostData() {
        Map<String,String> params = ApexPages.currentPage().getParameters();
        siteQuality = params.get('siteQuality');
        referral.Primary_Phone__c = params.get('primaryPhone');
        odm.Primary_Phone__c = params.get('odmPrimaryPhone');
        if( String.isNotBlank(confirmedLatitude) && String.isNotBlank(confirmedLongitude) ) {
            referral.Confirmed_Location__Latitude__s = Decimal.valueOf(confirmedLatitude);
            referral.Confirmed_Location__Longitude__s = Decimal.valueOf(confirmedLongitude);
        }
    }
    
    //logs errors to the apex job queue
    @future
    public static void logError(String errorMsg) {
        System.assert(false, errorMsg);
    }

    //validate input fields    
    private void validate() {
        errorFields = '';   
        
        //home information
        if (String.isBlank(referral.Street__c)) {
            errorFields += '[1][street]';
        }
        if (String.isBlank(referral.City__c)) {
            errorFields += '[1][city]';
        }
        if (String.isBlank(referral.State__c)) {
            errorFields += '[1][state]';
        }
        if (String.isBlank(referral.Zip__c)) {
            errorFields += '[1][zip]';
        }
        if (String.isBlank(homeOwner)) {
            errorFields += '[1][homeOwner]';
        }
        if (String.isBlank(siteType)) {
            errorFields += '[1][siteType]';
        } else {
            if (COMPANY_NAME_SITE_TYPES.contains(siteType)
            && String.isBlank(companyName)) {
                errorFields += '[1][companyName]';
            }
        }
        if (String.isNotBlank(electricBill)) {
            try {
                Decimal val = Decimal.ValueOf(electricBill); 
            } catch (Exception e) {
                errorFields += '[1][electricBill]';
            }
        }
        
        //contact information
        if (String.isBlank(referral.First_Name__c)) {
            errorFields += '[2][fname]';
        }
        if (String.isBlank(referral.Last_Name__c)) {
            errorFields += '[2][lname]';
        }
        //phone OR email is required
        if (String.isBlank(referral.Email__c) && String.isBlank(referral.Phone__c) 
        && String.isBlank(referral.Work_Phone__c) && String.isBlank(referral.Mobile_Phone__c)) {
            errorFields += '[2][email]';
            errorFields += '[2][phone]';
        }
        if (String.isNotBlank(referral.Phone__c) || String.isNotBlank(referral.Work_Phone__c)
        || String.isNotBlank(referral.Mobile_Phone__c)) {
            Integer phoneCount = (String.isNotBlank(referral.Phone__c) ? 1 : 0)
                + (String.isNotBlank(referral.Mobile_Phone__c) ? 1 : 0)
                + (String.isNotBlank(referral.Work_Phone__c) ? 1 : 0);
            if (phoneCount == 1) {
                //set primary automatically to avoid validation error
                referral.Primary_Phone__c = 
                    String.isNotBlank(referral.Phone__c) ? 'Home Phone' :
                    String.isNotBlank(referral.Mobile_Phone__c) ? 'Mobile Phone' :
                    String.isNotBlank(referral.Work_Phone__c) ? 'Work Phone' : null;
            } else if (String.isNotBlank(referral.Primary_Phone__c)) {
                if (referral.Primary_Phone__c == 'Home Phone' && String.isBlank(referral.Phone__c)) {
                    errorFields += '[2][primary]';
                } else if (referral.Primary_Phone__c == 'Mobile Phone' && String.isBlank(referral.Mobile_Phone__c)) {
                    errorFields += '[2][primary]';
                } else if (referral.Primary_Phone__c == 'Work Phone' && String.isBlank(referral.Work_Phone__c)) {
                    errorFields += '[2][primary]';
                }
            } else {
                errorFields += '[2][primary]';
            }
        }
        
//TODO: format phone fields

        //other decision maker
        Boolean odmFieldHasValue = String.isNotBlank(odm.First_Name__c) || String.isNotBlank(odm.Last_Name__c) 
            || String.isNotBlank(odm.Email__c) || String.isNotBlank(odm.Phone__c) 
            || String.isNotBlank(odm.Work_Phone__c) || String.isNotBlank(odm.Mobile_Phone__c);
        if (odmFieldHasValue) {
            expanderSign = '[-]';
            if (String.isBlank(odm.Last_Name__c)) {
                errorFields += '[3][odmlname]';
            }
        }
        if (String.isNotBlank(odm.Phone__c) || String.isNotBlank(odm.Work_Phone__c)
        || String.isNotBlank(odm.Mobile_Phone__c)) {
            Integer phoneCount = (String.isNotBlank(odm.Phone__c) ? 1 : 0)
                + (String.isNotBlank(odm.Mobile_Phone__c) ? 1 : 0)
                + (String.isNotBlank(odm.Work_Phone__c) ? 1 : 0);
            if (phoneCount == 1) {
                //set primary automatically to avoid validation error
                odm.Primary_Phone__c = 
                    String.isNotBlank(odm.Phone__c) ? 'Home Phone' :
                    String.isNotBlank(odm.Mobile_Phone__c) ? 'Mobile Phone' :
                    String.isNotBlank(odm.Work_Phone__c) ? 'Work Phone' : null;
            } else if (String.isNotBlank(odm.Primary_Phone__c)) {
                if (odm.Primary_Phone__c == 'Home Phone' && String.isBlank(odm.Phone__c)) {
                    errorFields += '[3][odmPrimary]';
                } else if (odm.Primary_Phone__c == 'Mobile Phone' && String.isBlank(odm.Mobile_Phone__c)) {
                    errorFields += '[3][odmPrimary]';
                } else if (odm.Primary_Phone__c == 'Work Phone' && String.isBlank(odm.Work_Phone__c)) {
                    errorFields += '[3][odmPrimary]';
                }
            } else {
                errorFields += '[3][odmPrimary]';
            }
        }
        
        //lead source info
        if (String.isBlank(referral.Lead_Source__c)) {
            errorFields += '[4][leadSource]';
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
        User u = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        Contact c = [SELECT Id, AccountId, Account.Portal_Payment_Plan__c,Account.Related_User__r.Id FROM Contact WHERE Id = :u.ContactId];
        
        referral.OwnerId = c.Account.Related_User__r.Id;
        referral.Account__c = c.AccountId;
        referral.Referred_by__c = c.Id;
        if (duplicate == true) {
            referral.Status__c = PortalReferralStatus.DUPLICATE_STATUS;
        } else {
            referral.Status__c = PortalReferralStatus.OPEN_STATUS;
            referral.Detail__c = 'New';
        }

        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.allowFieldTruncation = true;
        referral.setOptions(dmo);
        
        insert referral;
    }
    
    //check for duplicate by address
    private Boolean isDuplicate() {
        List<Lead> duplicates = 
            [SELECT Id, OwnerId, IsConverted, ConvertedOpportunityId
            FROM Lead
            WHERE Street = :verifiedStreet
            AND City = :verifiedCity
            AND State = :verifiedState
            LIMIT 1];
        if (duplicates.size() > 0) {
            createActivityForDuplicateLead(duplicates[0]);
        }
        return duplicates.size() > 0;
    }
    
    private void createActivityForDuplicateLead(Lead firstReferral) {
        
        String utilityName;
        String campaignName;
        String refAccountName;
        
        if (String.isNotBlank(utilityId)) {
            Utility_Company_Master__c utility = [SELECT Id, Name FROM Utility_Company_Master__c WHERE Id = :utilityId];
            utilityName = utility.Name;
        }
        
        if (String.isNotBlank(campaignId)) {
            Campaign campaign = [SELECT Id, Name FROM Campaign WHERE Id = :campaignId];
            campaignName = campaign.Name;
        }
        
        if (String.isNotBlank(refAcct)) {
            Account acct = [SELECT Id, Name from Account WHERE Id = :refAcct];
            refAccountName = acct.Name;
        }
        
        String subject = 'Duplicate Lead Submitted by ' + UserInfo.getName();
        String summary = 'Property Information'
            + '\nAddress: ' + referral.Street__c
            + '\nCity: ' + referral.City__c
            + '\nState: ' + referral.State__c
            + '\nZip: ' + referral.State__c
            + '\nHome Owner: ' + homeOwner
            + '\nSite Confirmed: ' + blankValue(siteQuality) //optional
            + '\nSite Type: ' + siteType
            + (COMPANY_NAME_SITE_TYPES.contains(siteType) ? '\nCompany Name: ' + companyName : '')
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
            
            + '\n\nOther Decision Maker'
            + '\nSalutation: ' + blankValue(odmSalutation)
            + '\nFirst Name: ' + blankValue(odm.First_Name__c)
            + '\nLast Name: ' + blankValue(odm.Last_Name__c)
            + '\nEmail: ' + blankValue(odm.Email__c)
            + '\nHome Phone: ' + blankValue(odm.Phone__c)
            + '\nCell Phone: ' + blankValue(odm.Mobile_Phone__c)
            + '\nWork Phone: ' + blankValue(odm.Work_Phone__c)
            + '\nPrimary Phone: ' + blankValue(odm.Primary_Phone__c)
            
            + '\n\nLead Source Info'
            + '\nLead Date: ' + referral.Lead_Created_Date__c.format()
            + '\nSelf Gen: Yes'
            + '\nAlias: ' + userAlias
            + '\nLead Source: ' + referral.Lead_Source__c
            + (CAMPAIGN_LEAD_SOURCES.contains(referral.Lead_Source__c) ? '\nCampaign: ' + blankValue(campaignName) : '')
            + (REFERRING_ACCT_LEAD_SOURCES.contains(referral.Lead_Source__c) ? '\nReferring Account: ' + blankValue(refAccountName) : '')
            + '\nLead Source Notes: ' + blankValue(leadSourceNotes)
            + '\nSecond Lead Source: ' + blankValue(secondLeadSource)
            + (CAMPAIGN_LEAD_SOURCES.contains(secondLeadSource) ? '\nCampaign: ' + blankValue(campaignName) : '')
            + '\nCustomer Timeframe: ' + blankValue(timeline)
            + '\nCompetitive: ' + (competitive == true ? 'Yes' : '')
            + '\nRating: ' + blankValue(rating)
            + '\nInternal Sales Notes: ' + blankValue(referral.Notes__c);
        
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
    
    private String blankValue(String text) {
        return String.isBlank(text) ? '' : text;
    }

    //creates a task for a lead or opportunity and emails the task/record owner    
    @future
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
    
    //create the lead record
    private void createLead() {
        Id assignId;
        Account RefacctPN;
        if(isSalesRep == true && assignInsideSales == false)
        {
         
            assignId =  referral.OwnerId; 
            
        }    
        else if (isSalesRep == false && assignFieldSales == true) {
            Group salesCoordinatorQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SalesCoordinatorLeadQueue'];
            assignId = salesCoordinatorQueue.Id;    
        }        
        else
        {
            Group webReferralQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'WebLeadQueue'];
            assignId = webReferralQueue.Id;
        }    
        
        if (String.isNotBlank(refAcct)) {
            RefacctPN = [SELECT Partner_Type__c from Account WHERE Id = :refAcct];           
        }
            
        Lead newLead = new Lead(
            OwnerId = assignId,

            //home info
            Street = referral.Street__c,
            City = referral.City__c,
            State = referral.State__c,
            PostalCode = referral.Zip__c,
            Home_Owner__c = (homeOwner == 'Yes'),
            Site_Quality_Confirmed__c = siteQuality,
            Site_Type__c = siteType,
            Monthly_Electric_Bill__c = (String.isNotBlank(electricBill) ? Decimal.valueOf(electricBill).intValue() : null),
            Utility_Company_Master__c = utilityId,
            Property_Notes__c = propertyNotes,
            Confirmed_Location__Latitude__s = referral.Confirmed_Location__Latitude__s,
            Confirmed_Location__Longitude__s = referral.Confirmed_Location__Longitude__s,
            
            //contact info
            Salutation = salutation,
            FirstName = referral.First_Name__c,
            LastName = referral.Last_Name__c,
            Company = (showCompany == true ? companyName : (referral.Last_Name__c + ', ' + referral.First_Name__c)),
            Email = referral.Email__c,
            Phone = referral.Phone__c,
            MobilePhone = referral.Mobile_Phone__c,
            Work_Phone__c = referral.Work_Phone__c,
            Primary_Phone__c = referral.Primary_Phone__c,
            Best_Time_to_Call__c = bestTime,
            
            //other decision maker
            ODM_Salutation__c = odmSalutation,
            ODM_First_Name__c = odm.First_Name__c,
            ODM_Last_Name__c = odm.Last_Name__c,
            ODM_Email__c = odm.Email__c,
            ODM_Phone__c = odm.Phone__c,
            ODM_Mobile_Phone__c = odm.Mobile_Phone__c,
            ODM_Work_Phone__c = odm.Work_Phone__c,
            ODM_Primary_Phone__c = odm.Primary_Phone__c,

            //lead source
            Lead_Date__c = referral.Lead_Created_Date__c,
            Self_Generated__c = selfgen,
            Contact_Detail__c = userAlias,
            LeadSource = LEAD_SOURCE_MAP.get(referral.Lead_Source__c),  
            Lead_Source_Detail__c = (referral.Lead_Source__c != 'Partner Referral' ? ( referral.Lead_Source__c == 'Individual Referral' ? leadSourceDetail : (UNKNOWN_LEAD_SOURCES.contains(referral.Lead_Source__c) ? null : referral.Lead_Source__c) ):  ( RefacctPN != null ? (RefacctPN.Partner_Type__c != null ?  RefacctPN.Partner_Type__c : 'Professional') : null ) ),
            Lead_Source_Notes__c = leadSourceNotes,
            Method_of_Contact__c = 'Employee Portal',
            Second_Lead_Source__c = LEAD_SOURCE_MAP.get(referral.EP_Second_Lead_Source__c),
            Second_Lead_Source_Detail__c = (referral.EP_Second_Lead_Source__c != 'Offline Ad' ? (UNKNOWN_LEAD_SOURCES.contains(referral.EP_Second_Lead_Source__c) ? null : referral.EP_Second_Lead_Source__c) :  'Unknown'),
            Competitive__c = competitive,
            Customer_Timeframe__c = timeline,
            Rating = rating,
            Internal_Sales_Notes__c = referral.Notes__c,
            Referring_Account__c = (REFERRING_ACCT_LEAD_SOURCES.contains(referral.Lead_Source__c) ? refAcct : null),
            Primary_Source_Campaign__c = (CAMPAIGN_LEAD_SOURCES.contains(referral.Lead_Source__c)? campaignId : null),
            Secondary_Referring_Account__c = (REFERRING_ACCT_LEAD_SOURCES.contains(referral.EP_Second_Lead_Source__c) ? refAcct2 : null),
            Secondary_Source_Campaign__c = (CAMPAIGN_LEAD_SOURCES.contains(referral.EP_Second_Lead_Source__c) && !(CAMPAIGN_LEAD_SOURCES.contains(referral.Lead_Source__c))? campaignId : null)           
        );

        //allow field truncation
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.allowFieldTruncation = true;
        newLead.setOptions(dmo);
        
        insert newLead;
        
        if ((showCampaign1 == true || showCampaign2 == true) && String.isNotBlank(campaignId)) {
            CampaignMember cm = new CampaignMember (
                CampaignId = campaignId,
                LeadId = newLead.Id,
                Status = 'Responded'
            );
            insert cm;
        }
        
        referral.Lead__c = newLead.Id;
        update referral;
    }

}