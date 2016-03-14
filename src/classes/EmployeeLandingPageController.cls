/* FILE: EmployeeLandingPageController.cls
 * AUTHOR: Rohit Jain
 * DATE: Feb 12, 2013
 * PURPOSE: Supports custom landing pages for employee
 * MODIFICATION HISTORY
 * 
 */

public without sharing class EmployeeLandingPageController {

    public static String landingPageId; 

    public ApexPages.PageReference template { get; private set; }
    public String partnerName { get; private set; }
    public String pageContent { get; private set; }
    public String errorInfo { get; private set; }
    public String partnerLogoId { get; private set; }
    
    public String contactName { get; private set; }
    public String contactPhone { get; private set; }
    public String contactEmail { get; private set; }
    
    public String pageHeadline { get; private set; }
    public String promoText { get; private set; }
    public String logoTagline { get; private set; }
    public String marketingContent { get; private set; }
    public Boolean showReferredBy { get; private set; }

    public String programDisclaimer { get; private set; }
    public String promoDisclaimer { get; private set; }
    public String disclaimerContent { get; private set; }
    public String contractNumbers { get; private set; }

    public Portal_Referral__c referral { get; set; }
    public Boolean submitted { get; private set; }
    public String errorFields { get; private set; }
    
    public String newState { get; set; }
    public String communityProgram;
    private Boolean duplicate = false;
    
    private String m_landingPageId; 
    private String templateId;
    private String userAlias;
    private String siteUrl;
    private String userRole;
    private String userId;
    private String assignId;
    private String templateName = '';
    
    private transient String verifiedStreet;
    private transient String verifiedCity;
    private transient String verifiedState;
    
    private String updates;
    
    private Id partnerAccount;
    
    private String utm_campaign;
    private String utm_source;
    private String utm_medium;
    private String utm_term;
    private String utm_content;
    private String gclid;
    
    //map lead source to  
    private static final Map<String, String> LEAD_SOURCE_MAP = new Map<String, String> {
        'Referral by Customer/Employee' => 'Individual Referral', 
        'Referral by Astrum Partner' => 'Partner Referral',
        'Postcard/Mailer' => 'Direct Mail', 
        'Search Engine' => 'Search Engine',   
        'Online Ad' => 'Online Ad',
        'Radio Ad' => 'Offline Ad',       
        'Event' => 'Event',
        'Door Hanger' => 'Offline Ad',
        'News Article/Broadcast' => 'Other Source', 
        'Astrum Solar Vehicle' => 'Offline Ad' ,        
        'Other' => 'Other Source'     ,
        'Yard Sign/Banner' => 'Offline Ad'
    };
    
    //map lead source to  
    private static final Map<String, String> LEAD_SOURCE_DETAIL_MAP = new Map<String, String> {      
        'Referral by Astrum Partner' => 'Employee Landing Page',
        'Radio Ad' => 'Radio',       
        'Event' => 'Unknown',
        'Door Hanger' => 'Door Hanger',
        'News Article/Broadcast' => 'Public Relations', 
        'Astrum Solar Vehicle' => 'Vehicle' ,        
        'Other' => 'Unknown',
        'Yard Sign/Banner' => 'Outdoor'         
    };
    
    private static final Set<String> SOLARIZE_TEMPLATES = new Set<String> {
        'Solarize Bridgeport', 'Solarize Frederick'                                                 
    };

    //the URL Rewriter will pass in the Landing Page Id for this page in templateId
    public EmployeeLandingPageController() {
        
        submitted = false;
        referral = new Portal_Referral__c();
        
        try {
            m_landingPageId = ApexPages.currentPage().getParameters().get('templateId');
            landingPageId = m_landingPageId;
            if (String.isBlank(m_landingPageId)) {
                //use the default site template it nothing specified
                template = Site.getTemplate();
            } else {
                List<Partner_Landing_Page__c> pages = 
                    [SELECT Id, Partner_Account__c, Page_Template__c, Page_Template__r.VisualForce_Page__c,
                        Partner_Display_Name__c, Page_Content__c, Contact__r.Name,
                        Contact__r.Phone, Contact__r.Email, Logo_Tagline__c,Marketing_Content__c,Disclaimer_Content__c, 
                        Program_Disclaimer__c, Promo_Disclaimer__c, Contract_Numbers__c,Show_Referred_By__c,
                        Promo_Text__c, Page_Template__r.Logo_Tagline__c,Page_Template__r.Marketing_Content__c,Page_Template__r.Disclaimer_Content__c, 
                        Page_Template__r.Program_Disclaimer__c, Page_Template__r.Promo_Disclaimer__c, Page_Template__r.Contract_Numbers__c,
                        Page_Template__r.Promo_Text__c,page_Headline__c, Page_Template__r.page_headline__c, Partner_Account__r.Related_User__r.alias,
                        Partner_Account__r.Related_User__r.UserRoleId ,Complete_Url__c,Page_Template__r.Name,
                        (SELECT Id FROM Attachments WHERE Description = 'Logo' LIMIT 1)
                    FROM Partner_Landing_Page__c
                    WHERE Id = :m_landingPageId];
                if (pages.size() >= 1) {
                    partnerAccount = pages[0].Partner_Account__c;
                    partnerName = pages[0].Partner_Display_Name__c;
                    pageContent = pages[0].Page_Content__c;
                    contactName = pages[0].Contact__r.Name;
                    contactPhone = pages[0].Contact__r.Phone;
                    contactEmail = pages[0].Contact__r.Email;
                    showReferredBy    =  pages[0].Show_Referred_By__c;
                    pageHeadline      =  (pages[0].Page_Headline__c != NULL ? pages[0].Page_Headline__c : pages[0].Page_Template__r.Page_Headline__c ); 
                    disclaimerContent =  (pages[0].Disclaimer_Content__c != NULL ? pages[0].Disclaimer_Content__c : pages[0].Page_Template__r.Disclaimer_Content__c);
                    programDisclaimer =  (pages[0].Program_Disclaimer__c != NULL ? pages[0].Program_Disclaimer__c : pages[0].Page_Template__r.Program_Disclaimer__c);
                    promoDisclaimer   =  (pages[0].Promo_Disclaimer__c != NULL ? pages[0].Promo_Disclaimer__c : pages[0].Page_Template__r.Promo_Disclaimer__c);
                    contractNumbers   =  (pages[0].Contract_Numbers__c != NULL ? pages[0].Contract_Numbers__c : pages[0].Page_Template__r.Contract_Numbers__c );
                    promoText         =  (pages[0].Promo_Text__c != NULL ? pages[0].Promo_Text__c : pages[0].Page_Template__r.Promo_Text__c );
                    logoTagline       =  (pages[0].Logo_Tagline__c != NULL ? pages[0].Logo_Tagline__c : pages[0].Page_Template__r.Logo_Tagline__c );
                    marketingContent  =  (pages[0].Marketing_Content__c != NULL ? pages[0].Marketing_Content__c : pages[0].Page_Template__r.Marketing_Content__c );
                    userAlias         =  pages[0].Partner_Account__r.Related_User__r.alias;
                    siteURL           =  pages[0].Complete_Url__c;                    
                    userRole       =  pages[0]. Partner_Account__r.Related_User__r.UserRoleId;
                    userId            =  pages[0].Partner_Account__r.Related_User__c; 
                    templateName      =  pages[0].Page_Template__r.Name;
                    templateId = pages[0].Page_Template__c;
                    template = new PageReference('/' + pages[0].Page_Template__r.VisualForce_Page__c);
                    if (pages[0].attachments.size() >= 1) {
                        partnerLogoId = pages[0].attachments[0].Id;
                    }
                }
            }
        } catch (Exception e) {
            errorInfo = e.getMessage() + e.getStackTraceString();
        }
    }
    
    public List<SelectOption> states {
        get {
            List<SelectOption> result = new List<SelectOption>();
            result.add(new SelectOption('', 'State'));
            Schema.DescribeFieldResult referralState = Portal_Referral__c.State__c.getDescribe();
            for (Schema.PicklistEntry ple : referralState.getPickListValues()) {
                result.add(new SelectOption(ple.getValue(), ple.getLabel()));
            }
            return result;
        }
    }
    
    // Special for Solarize Bridgeport CT Page
    public List<SelectOption> ctstates {
        get {
            List<SelectOption> result = new List<SelectOption>();
            result.add(new SelectOption('CT', 'CT'));
            Schema.DescribeFieldResult referralState = Portal_Referral__c.State__c.getDescribe();
            for (Schema.PicklistEntry ple : referralState.getPickListValues()) {
                if(ple.getLabel() != 'CT')
                    result.add(new SelectOption(ple.getValue(), ple.getLabel()));
            }
            return result;
        }
    }
    
    // Special for Solarize Frederick MD Page
    public List<SelectOption> mdstates {
        get {
            List<SelectOption> result = new List<SelectOption>();
            result.add(new SelectOption('MD', 'MD'));
            Schema.DescribeFieldResult referralState = Portal_Referral__c.State__c.getDescribe();
            for (Schema.PicklistEntry ple : referralState.getPickListValues()) {
                if(ple.getLabel() != 'MD')
                    result.add(new SelectOption(ple.getValue(), ple.getLabel()));
            }
            return result;
        }
    }
    
     // Special for Solarize Concord Solar MA Page
    public List<SelectOption> mastates {
        get {
            List<SelectOption> result = new List<SelectOption>();
            result.add(new SelectOption('MA', 'MA'));
            Schema.DescribeFieldResult referralState = Portal_Referral__c.State__c.getDescribe();
            for (Schema.PicklistEntry ple : referralState.getPickListValues()) {
                if(ple.getLabel() != 'MA')
                    result.add(new SelectOption(ple.getValue(), ple.getLabel()));
            }
            return result;
        }
    }

     // Special for Solarize Concord Solar NY Page
    public List<SelectOption> nystates {
        get {
            List<SelectOption> result = new List<SelectOption>();
            result.add(new SelectOption('NY', 'NY'));
            Schema.DescribeFieldResult referralState = Portal_Referral__c.State__c.getDescribe();
            for (Schema.PicklistEntry ple : referralState.getPickListValues()) {
                if(ple.getLabel() != 'NY')
                    result.add(new SelectOption(ple.getValue(), ple.getLabel()));
            }
            return result;
        }
    }

     // Special for Solarize Concord Solar NJ Page
    public List<SelectOption> njstates {
        get {
            List<SelectOption> result = new List<SelectOption>();
            result.add(new SelectOption('NJ', 'NJ'));
            Schema.DescribeFieldResult referralState = Portal_Referral__c.State__c.getDescribe();
            for (Schema.PicklistEntry ple : referralState.getPickListValues()) {
                if(ple.getLabel() != 'NJ')
                    result.add(new SelectOption(ple.getValue(), ple.getLabel()));
            }
            return result;
        }
    }

    // Special for Solarize Concord Solar NJ Page
    public List<SelectOption> dcstates {
        get {
            List<SelectOption> result = new List<SelectOption>();
            result.add(new SelectOption('DC', 'DC'));
            Schema.DescribeFieldResult referralState = Portal_Referral__c.State__c.getDescribe();
            for (Schema.PicklistEntry ple : referralState.getPickListValues()) {
                if(ple.getLabel() != 'DC')
                    result.add(new SelectOption(ple.getValue(), ple.getLabel()));
            }
            return result;
        }
    }

    // Special for Solarize Concord Solar NJ Page
    public List<SelectOption> castates {
        get {
            List<SelectOption> result = new List<SelectOption>();
            result.add(new SelectOption('CA', 'CA'));
            Schema.DescribeFieldResult referralState = Portal_Referral__c.State__c.getDescribe();
            for (Schema.PicklistEntry ple : referralState.getPickListValues()) {
                if(ple.getLabel() != 'CA')
                    result.add(new SelectOption(ple.getValue(), ple.getLabel()));
            }
            return result;
        }
    }
    
    // Special for Solarize Bridgeport
    public List<SelectOption> ctleadSources{
        get {
            List<SelectOption> result = new List<SelectOption>();
            
            Schema.DescribeFieldResult referralSource = Portal_Referral__c.Portal_Hear_About_Us__c.getDescribe();
            for (Schema.PicklistEntry ple : referralSource.getPickListValues()) {
                if(ple.getLabel() != 'Radio Ad' && ple.getLabel() != 'Referral by Astrum Partner' )
                {
                    if(ple.getLabel() == 'Other' )
                        result.add(new SelectOption('Yard Sign/Banner', 'Yard Sign/Banner'));
                    
                    result.add(new SelectOption(ple.getValue(), ple.getLabel()));                    
                }    
            }
         
            return result;
        }
    }
    
   
    public List<SelectOption> leadSources{
        get {
            List<SelectOption> result = new List<SelectOption>();
            
            Schema.DescribeFieldResult referralSource = Portal_Referral__c.Portal_Hear_About_Us__c.getDescribe();
            for (Schema.PicklistEntry ple : referralSource.getPickListValues()) {
                result.add(new SelectOption(ple.getValue(), ple.getLabel()));
            }
            return result;
        }
    }
    
    

    private void grabPostData() {
        Map<String,String> params = ApexPages.currentPage().getParameters();
        referral.First_Name__c = params.get('fname');
        referral.Last_Name__c = params.get('lname');
        referral.Email__c = params.get('email');
        referral.Phone__c = params.get('phone');
        referral.Street__c = params.get('street');
        referral.City__c = params.get('city');
        referral.State__c = params.get('state');
        referral.Zip__c = params.get('zip');
        referral.Notes__c = params.get('heard_detail');
        referral.Portal_Hear_About_Us__c = params.get('heard');
        updates = params.get('updates');
        communityProgram = params.get('communityprogram');
        
        Cookie utm_campaign_ck = ApexPages.currentPage().getCookies().get('astrum_utm_campaign');
        if(utm_campaign_ck != null)
        {
            utm_campaign = utm_campaign_ck.getValue();
        }
        
        Cookie utm_source_ck = ApexPages.currentPage().getCookies().get('astrum_utm_source');
        if(utm_source_ck != null)
        {
            utm_source = utm_source_ck.getValue();
        }
        
        Cookie utm_medium_ck = ApexPages.currentPage().getCookies().get('astrum_utm_medium');
        if(utm_medium_ck != null)
        {
            utm_medium = utm_medium_ck.getValue();
        }
        
        Cookie utm_term_ck = ApexPages.currentPage().getCookies().get('astrum_utm_term');
        if(utm_term_ck != null)
        {
            utm_term = utm_term_ck.getValue();
        }
        
        Cookie utm_content_ck = ApexPages.currentPage().getCookies().get('astrum_utm_content');
        if(utm_content_ck != null)
        {
            utm_content = utm_content_ck.getValue();
        }
        
        Cookie gclid_ck = ApexPages.currentPage().getCookies().get('gclid');
        if(gclid_ck != null)
        {
            gclid = gclid_ck.getValue();
        }
       
       
    }
    
    public PageReference submit() {
        grabPostData();
        landingPageId = m_landingPageId;
        Savepoint sp;
        try {
            verifyAddress();
            duplicate = isDuplicate();
            sp = Database.setSavepoint();
            createReferral();
            if (duplicate == true) {
                submitted = true;
                return null;
            }
            try {
                PortalReferralStatus.creatingLeadInPortal = true;
                createLead();
            } finally {
                PortalReferralStatus.creatingLeadInPortal = false;
            }
            if (ApexPages.hasMessages()) {
                Database.rollback(sp);
                return null;
            }
            submitted = true;
            return null;
        } catch (Exception e) {
            
            if (sp != null) {
                Database.rollback(sp);
            }
            logError('landingPage=' + landingPageId + ' : ' + e.getMessage() + ' : ' + e.getStackTraceString());
            errorFields += '[unknown]';
            
        }
        return null;
    }
    
    @future
    public static void logError(String errorMsg) {
        System.assert(false, errorMsg);
    }
    
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
                if (address.AddressLine2 != null && address.AddressLine2.trim() != '') {
                    verifiedStreet += '\n' + address.AddressLine2;
                }
                verifiedCity = address.City;
                verifiedState = address.State;
            }
            
        } catch (Exception e) {
            
        }
        
    }
    
    private void createReferral() {
        Account partner = [SELECT Id, Portal_Payment_Plan__c FROM Account WHERE Id = :partnerAccount];
        Decimal perReferralFee;
        if (partner.Portal_Payment_Plan__c != null) {
            perReferralFee = calculateReferralFee(partner.Id, partner.Portal_Payment_Plan__c);
        } 

        referral.Account__c = partner.Id;
        referral.Lead_Created_Date__c = System.today();
        referral.Landing_Page_Template__c = templateId; 
        referral.Community_Program__c = communityProgram; 
        if (duplicate == true) {
            referral.Status__c = PortalReferralStatus.DUPLICATE_STATUS;
        } else {
            referral.Status__c = PortalReferralStatus.OPEN_STATUS;
            referral.Detail__c = 'New';
            referral.Portal_Payment_Plan__c = partner.Portal_Payment_Plan__c;
            referral.Portal_Referral_Fee__c = perReferralFee;
            
        }
        insert referral;
    }
    
    //check for duplicate by address
    private Boolean isDuplicate() {
        List<Lead> duplicates = 
            [SELECT Id
            FROM Lead
            WHERE Street = :verifiedStreet
            AND City = :verifiedCity
            AND State = :verifiedState
            LIMIT 1];
        return duplicates.size() > 0;
    }
    
    private void createLead() {
        System.debug('*Create Lead Role '+userRole );
        Boolean salesRepFlag = false;
        List<String> roleRelatedGroupIds = new List<String>();
        if (userRole != null)
        {
            for (Group g : [SELECT id, RelatedId, Type FROM Group where RelatedId= :userRole ]){
               roleRelatedGroupIds.add(g.id);
            }
            System.debug('*Create Lead Related Id -'+roleRelatedGroupIds);
            if (roleRelatedGroupIds.size() > 0 )
            {
                
                try{
                    List<GroupMember> gm = [Select g.UserOrGroupId From GroupMember g Where g.Group.DeveloperName = 'Sales_Team' and UserOrGroupId in :roleRelatedGroupIds];
                    System.debug('*Create Lead Size '+ gm.size() );
                    if (gm.size() > 0)
                        salesRepFlag = true;
                }
                catch(Exception e)
                {
                  salesRepFlag = false;  
                }    
            }
        }  
        
        if(salesRepFlag && !(SOLARIZE_TEMPLATES.contains(templateName)) )
        {
          assignId = userId;            
        }  
        else{
          Group webReferralQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'WebLeadQueue'];
          assignId = webReferralQueue.Id;            
        }
        
        Account unknownAcct;
        Id unknownAccntId;
        Campaign unknownCamp;
        Id unknownCampId;
        try {
            if(referral.Portal_Hear_About_Us__c == 'Referral by Customer/Employee' || referral.Portal_Hear_About_Us__c == 'Referral by Astrum Partner'  )
            {
                unknownAcct = [Select Id from Account Where Name = 'Unknown' limit 1];  
                unknownAccntId = unknownAcct.Id;
            }    
            if(referral.Portal_Hear_About_Us__c == 'Event') {
                unknownCamp = [Select Id from Campaign Where Name = 'Unknown' limit 1];  
                unknownCampId = unknownCamp.Id;
            }    
        }
        catch(Exception e)
        {
            System.debug('Unknown Account and Campaign not being setup');
        }        
        Lead newLead = new Lead(
            OwnerId = assignId,
            FirstName = referral.First_Name__c,
            LastName = referral.Last_Name__c,
            Company = referral.Last_Name__c + ', ' + referral.First_Name__c,
            Phone = referral.Phone__c,
            Email = referral.Email__c,
            Street = referral.Street__c,
            City = referral.City__c,
            State = referral.State__c,
            PostalCode = referral.Zip__c,
            Lead_Date__c = System.today(),            
            Lead_Source_Notes__c = referral.Notes__c,
            LeadSource = LEAD_SOURCE_MAP.get(referral.Portal_Hear_About_Us__c),  
            Lead_Source_Detail__c = LEAD_SOURCE_DETAIL_MAP.get(referral.Portal_Hear_About_Us__c),  
           // Lead_Source_Detail_2__c = 'Channel',
           // Lead_Source_Detail_4__c = 'Partner Landing Page',            
            Referring_Account__c = unknownAccntId,
            Primary_Source_Campaign__c = unknownCampId ,
            //Utility_Company__c = (String.isNotBlank(utility) ? utility : null),
            Email_Marketing_Opt_In__c = (String.isNotBlank(updates) ? true : false),
            //Monthly_Electric_Bill__c = (String.isNotBlank(bill) ? Decimal.valueOf(bill).intValue() : null),            
            // Specific to Employee Landing Pages
            Self_Generated__c = (communityProgram != null ? false : true),
            Lead_Form_URL__c = siteURL,
            Contact_Detail__C = (communityProgram != null ? null: userAlias),
            Method_of_Contact__c = 'Astrum Web Form',
            Community_Program__c = (String.isNotBlank(communityProgram ) ? communityProgram : null),
            UTM_Campaign__c = UTM_Campaign,
            UTM_Content__c = UTM_Content,
            UTM_Medium__c = UTM_Medium,
            UTM_Source__c = UTM_Source,
            UTM_Term__c = UTM_Term,
            GCLID__c = gclid            
        );
        insert newLead;
        
        referral.Lead__c = newLead.Id;
        update referral;
    }

    private Decimal calculateReferralFee(Id accountId, Id paymentPlan) {

        //get the plan information for per referral fees
        Portal_Payment_Plan__c plan = 
            [SELECT Id, Per_Referral_Fee__c, Per_Referral_Maximum_Number__c, Stop_Per_Referral_After_First_Sale__c
            FROM Portal_Payment_Plan__c
            WHERE Id = :paymentPlan];
        
        //see if there is a sale, and no per referral fee after first sale
        if (plan.Stop_Per_Referral_After_First_Sale__c == true) {
            List<Portal_Referral__c> sold = 
                [SELECT Id 
                FROM Portal_Referral__c 
                WHERE Account__c = :accountId
                AND Portal_Payment_Plan__c = :paymentPlan 
                AND Status__c = :PortalReferralStatus.SOLD_STATUS 
                LIMIT 1];
            if (sold.size() > 0) {
                return null;
            }
        }
        
        //see how many referrals there are submitted under this plan, if there is a per referral fee
        if (plan.Per_Referral_Maximum_Number__c != null && plan.Per_Referral_Fee__c != null && plan.Per_Referral_Fee__c > 0) {
            Integer total = 
                [SELECT count() 
                FROM Portal_Referral__c 
                WHERE Account__c = :accountId
                AND Portal_Payment_Plan__c = :paymentPlan 
                AND Status__c <> 'Duplicate'];
            if (total < plan.Per_Referral_Maximum_Number__c) {
                return plan.Per_Referral_Fee__c;
            } else {
                return null;
            }
        }
        
        if (plan.Per_Referral_Fee__c != null && plan.Per_Referral_Fee__c > 0) {
            return plan.Per_Referral_Fee__c; 
        }
        
        return null;
    }   

}