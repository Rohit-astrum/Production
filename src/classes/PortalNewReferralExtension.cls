/* FILE: PortalNewReferralExtension.cls
 * AUTHOR: Tino Mattheou
 * DATE: June 14, 2012
 * PURPOSE: Extension for PortalNewReferral page and PortalMobileNewReferral page
 * MODIFICATION HISTORY
 *     09/18/2012 TCM - Add StrikeIron address verification
 *     09/25/2012 TCM - Fix StrikeIron bug zen-57
 *     10/09/2012 TCM - updates to connect referring account leads to portal
 *     10/09/2012 TCM - adding Lead Created Date
 *     10/16/2014 DK  - Populated Community_Program_Offer__c on Portal Referral
 */
 
public without sharing class PortalNewReferralExtension {

    public String errorFields { get; set; }
    public Boolean duplicate { get; private set; }   

    private Portal_Referral__c referral;
    Contact portalContact;
    private ApexPages.StandardController controller;
    
    private transient String verifiedStreet;
    private transient String verifiedCity;
    private transient String verifiedState;

    public PortalNewReferralExtension(ApexPages.StandardController controller) {
        this.controller = controller;
        referral = (Portal_Referral__c)controller.getRecord();
        User u = [SELECT Id, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()];
        if(u.ContactId != null)
            portalContact = [SELECT Id, AccountId, Account.Solarize_Program__c,Account.Community_Program_offer__c,Account.Partner_Type__c, Account.Name FROM Contact WHERE Id = :u.ContactId];
    }
    
    public List<SelectOption> states {
        get {
            List<SelectOption> result = new List<SelectOption>();
            result.add(new SelectOption('', '-- Select State --'));
            Schema.DescribeFieldResult referralState = Portal_Referral__c.State__c.getDescribe();
            for (Schema.PicklistEntry ple : referralState.getPickListValues()) {
                result.add(new SelectOption(ple.getValue(), ple.getLabel()));
            }
            return result;
        }
    }
    
    public String logId {
        get {           
            List<Portal_Content__c> contents =     [SELECT (SELECT Id FROM Attachments WHERE Description = 'Logo' LIMIT 1)
                                                        FROM Portal_Content__c Where Portal_Account__c = :portalContact.AccountId ];
           
            String logoId = null;                            
            
            if (contents.size() > 0 && contents[0].attachments.size() >= 1) {
                logoId = contents[0].attachments[0].Id;
            } 
            return logoId;                            
        }
    }
    
    public String promoText{
        get {           
            List<Portal_Content__c> contents =     [SELECT Promo_Text__c
                                                        FROM Portal_Content__c Where Portal_Account__c = :portalContact.AccountId ];
           
            String promoText;                            
            
            if (contents.size() > 0) {
                promoText = contents[0].Promo_Text__c;
            } 
            return promoText;                            
        }
    }
    
    public PageReference submit() {
        Savepoint sp;
        System.debug('* Create submit');
        try {
            validate();
            if (errorFields != null && errorFields.trim() != '') {
                return null;
            }
            verifyAddress();
            duplicate = isDuplicate();
            sp = Database.setSavepoint();
            createReferral();
            if (duplicate == true) {
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
            PageReference pr = thisPage();
            pr.setRedirect(true);
            pr.getParameters().put('submitted','1');
            return pr;
        } catch (Exception e) {
            System.debug('* Create submit Exception ');
            if (e instanceof DMLException) {
                System.DMLException dmlExcp = (System.DMLException)e;
                for (String field : dmlExcp.getDmlFieldNames(0)) {
                    if (field == 'Email__c') {
                        errorFields += '[1][email]';
                    }
                }
            }
            
            if (errorFields == null || errorFields.trim() == '') {
                Database.rollback(sp);
//TODO: log more info
                logError(String.valueOf(e));
                errorFields += '[unknown]';
            }
            
        }
        return null;
    }
    
    //determines whether mobile or regular page is returned
    private PageReference thisPage() {
        if (ApexPages.currentPage().getUrl().toLowerCase().contains('portalmobilenewreferral')) {
            return Page.PortalMobileNewReferral;
        }
        return Page.PortalNewReferral;
    }
    
    public PageReference submitAnother() {
        PageReference pr = thisPage();
        pr.setRedirect(true);
        return pr;
    }
    
    @future
    public static void logError(String errorMsg) {
        System.assert(false, errorMsg);
    }
    
//TODO: referral validation
    private void validate() {
        System.debug('* Create validate');
        errorFields = '';   
        if (referral.First_Name__c == null || referral.First_Name__c.trim() == '') {
            errorFields += '[1][fname]';
        }
        if (referral.Last_Name__c == null || referral.Last_Name__c.trim() == '') {
            errorFields += '[1][lname]';
        }
        if (referral.Street__c == null || referral.Street__c.trim() == '') {
            errorFields += '[1][street]';
        }
        if (referral.City__c == null || referral.City__c.trim() == '') {
            errorFields += '[1][city]';
        }
        if (referral.State__c == null || referral.State__c.trim() == '') {
            errorFields += '[1][state]';
        }
        if (referral.Zip__c == null || referral.Zip__c.trim() == '') {
            errorFields += '[1][zip]';
        }
        if (referral.Phone__c == null || referral.Phone__c.trim() == '') {
            errorFields += '[1][phone]';
        }
        if (referral.Email__c == null || referral.Email__c.trim() == '') {
            errorFields += '[1][email]';
        }
        System.debug('* Create validate errorFields '+errorFields );
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
        System.debug('* Create createReferral');
        User u = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        Contact c = [SELECT Id, AccountId, Account.Portal_Payment_Plan__c,Account.Partner_Type__c,Account.Community_Program_offer__c FROM Contact WHERE Id = :u.ContactId];
        Decimal perReferralFee;
        if (c.Account.Portal_Payment_Plan__c != null) {
            perReferralFee = calculateReferralFee(c.AccountId, c.Account.Portal_Payment_Plan__c);
        } 

        referral.Account__c = c.AccountId;
        if(c.Account.Community_Program_offer__c != null)
        {
            referral.Community_Program_offer__c = c.Account.Community_Program_offer__c;
        }
        referral.Partner_Type__c = c.Account.Partner_Type__c;
        referral.Referred_by__c = c.Id;
        referral.Lead_Created_Date__c = System.today();
        if (duplicate == true) {
            referral.Status__c = PortalReferralStatus.DUPLICATE_STATUS;
        } else {
            referral.Status__c = PortalReferralStatus.OPEN_STATUS;
            referral.Detail__c = 'New';
            referral.Portal_Payment_Plan__c = c.Account.Portal_Payment_Plan__c;
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
        System.debug('* Create Lead ');
        Group webReferralQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'WebLeadQueue'];
        //ID progID;
        //Community_Program_Offer__c activeProg = [SELECT ID FROM Community_Program_Offer__c WHERE Account__c = :referral.Account__c AND Active__c = true AND Start_Date__c <= TODAY ORDER BY Name LIMIT 1];
        //if (activeProg != null)
        //    progID = activeProg.ID;
        Lead newLead = new Lead(
            OwnerId = webReferralQueue.Id,
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
            Method_of_Contact__c = 'Partner Portal', 
            Lead_Source_Notes__c = referral.Notes__c,
            LeadSource = 'Partner Referral',
            Lead_Source_Detail__c = (referral.Partner_Type__c != null ?  referral.Partner_Type__c : 'Professional') ,
            Affiliate_community_program__c = ((portalContact != null && portalContact.Account.Partner_Type__c == 'Strategic') ? portalContact.Account.Name: Null) , 
            Community_Program_offer__c = ((portalContact != null && portalContact.Account.Partner_Type__c == 'Strategic') ? portalContact.Account.Community_Program_offer__c : Null) , 
            /*Community_Program_Offer__c = ((portalContact != null && portalContact.Account.Partner_Type__c == 'Strategic') ? progID : null),*/ 
            Solarize_Customer__c = ((portalContact != null && portalContact.Account.Partner_Type__c == 'Strategic') ? portalContact.Account.Solarize_Program__c  : false) ,
            //Lead_Source_Detail_2__c = 'Channel',
            //Lead_Source_Detail_4__c = 'Astrum Solar Connect',
            Referring_Account__c = referral.Account__c
        );

        insert newLead;
        referral.Lead__c = newLead.Id;
        if(referral.Community_Program_Offer__c == null)
        {
            newLead = [Select Community_Program_Offer__c from Lead where Id = :newLead.id];            
            if (referral.Community_Program_Offer__c == null)
                referral.Community_Program_Offer__c = ((portalContact != null && portalContact.Account.Partner_Type__c == 'Strategic') ? newLead.Community_Program_Offer__c : null);
        }
        
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