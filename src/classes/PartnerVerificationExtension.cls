/* FILE: PartnerVerificationExtension.cls
 * AUTHOR: Tino Mattheou
 * DATE: June 19, 2012
 * PURPOSE: Controller for PartnerVerification page.  Allows users to review and enable partners in the partner portal
 * MODIFICATION HISTORY
 *
 */
 
public class PartnerVerificationExtension {
    
//TODO: check for duplicate username in portal
    
    public List<Account> accounts { get; private set; }
    public List<Contact> contacts { get; private set; }
    
    public String accountNameSearch { get; set; }
    public String firstNameSearch { get; set; }
    public String lastNameSearch { get; set; }
    public String contactCompanyNameSearch { get; set; }
    
    public String duplicateId { get; set; }
    public String selectedAccountId { get; set; }
    
    public Account paymentPlanAccount { get; set; }

    private Partner_Application__c app;
    private Account newAccount; 
    private Contact newContact;
    
    public PartnerVerificationExtension(ApexPages.StandardController controller) {
        app = (Partner_Application__c)controller.getRecord();
        paymentPlanAccount = new Account();
        accountNameSearch = app.Company_Name__c;
        findAccounts();
        firstNameSearch = app.First_Name__c;
        lastNameSearch = app.Last_Name__c;
        findContacts();
    }
    
    public PageReference approve() {
        Savepoint sp = Database.setSavepoint();
        try {
            createAccount();
            createContact();
            createUser();
            updateApp('Approved', newContact.Id);
            return new PageReference('/' + newContact.Id);
        } catch (Exception e) {
            showError(e);
            Database.rollback(sp);
        }
        return null;
    }
    
    private void createAccount() {
        //user must be in a role, default to drew
        PartnerPortalSettings__c mc = PartnerPortalSettings__c.getValues('Portal Contact');

        List<User> drews = 
            [SELECT Id FROM User 
            WHERE UserName = :mc.Portal_Contact__c
            AND UserType = 'Standard' 
            AND IsActive = TRUE];
        if (selectedAccountId != null && selectedAccountId.trim() != '') {
            newAccount = [SELECT Id, OwnerId, Owner.UserRoleId, Portal_Payment_Plan__c FROM Account WHERE Id = :selectedAccountId];
            if (drews.size() > 0 && newAccount.Owner.UserRoleId == null) {
                newAccount.OwnerId = drews[0].Id;
                newAccount.Portal_Payment_Plan__c = paymentPlanAccount.Portal_Payment_Plan__c;
                update newAccount; 
            } else if (paymentPlanAccount.Portal_Payment_Plan__c != null && newAccount.Portal_Payment_Plan__c != paymentPlanAccount.Portal_Payment_Plan__c) {
                newAccount.Portal_Payment_Plan__c = paymentPlanAccount.Portal_Payment_Plan__c;
                update newAccount; 
            }
        } else {
            newAccount = new Account (
                OwnerId = drews.size() > 0 ? drews[0].Id : UserInfo.getUserId(),
                Name = app.Company_Name__c,
                BillingStreet = app.Address__c,
                BillingCity = app.City__c,
                BillingState = app.State__c,
                BillingPostalCode = app.Zip_Code__c,
                Website = app.Website__c,
                Portal_Payment_Plan__c = paymentPlanAccount.Portal_Payment_Plan__c,
                Partner_Type__C = app.Partner_Type__c
            );
            insert newAccount;
        }
    }
    
    private void createContact() {
        newContact = new Contact (
            AccountId = newAccount.Id,
            FirstName = app.First_Name__c,
            LastName = app.Last_Name__c,
            Title = app.Title__c,
            Email = app.Email__c,
            Phone = app.Phone__c,
            Fax = app.Fax__c
        ); 
        insert newContact;
    }
    
    private void createUser() {
        PartnerVerificationExtension.createUser(
            app.First_Name__c,
            app.Last_Name__c,
            app.Email__c,
            app.Phone__c,
            app.Company_Name__c,
            newContact.Id,
            app.partner_type__c
        );
    }
    
    private void updateApp(String newStatus, String contactId) {
        Partner_Application__c app2 = new Partner_Application__c (
            Id = app.Id,
            Status__c = newStatus,
            Contact__c = contactId
        );
        update app2;
    }
    
    @future
    private static void createUser(String firstName, String lastName, String email, String phone, String companyName, String contactId, String partnerType) {
        try {
            Profile portalProfile;
            if(partnerType != null) {
                if(partnerType == 'Professional')
                    portalProfile = [SELECT Id FROM Profile WHERE Name = 'Partner Portal - Full User'];
                else if(partnerType == 'Affinity')
                    portalProfile = [SELECT Id FROM Profile WHERE Name = 'Affinity Partner Portal - Full User'];    
                else if(partnerType == 'Affiliate')
                    portalProfile = [SELECT Id FROM Profile WHERE Name = 'Affiliate Partner Portal - Full User'];    
            }
            else
                portalProfile = [SELECT Id FROM Profile WHERE Name = 'Partner Portal - Full User'];
                    
            User newUser = new User (
                FirstName = firstName,
                LastName = lastName,
                Email = email,
                UserName = email,
                ContactId = contactId,
                Alias = 'partner', 
                ProfileId = portalProfile.Id, 
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'UTF-8'
            );
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.emailHeader.triggerUserEmail = true;
            Database.insert(newUser, dmo);  
        } catch (Exception e) {
            system.assert(false, e.getMessage() + ' ' 
                + firstName + ' ' + lastName + ' ' + email); 
        }
    }
    
    public PageReference selectAccount() {
        if (selectedAccountId != null && paymentPlanAccount.Portal_Payment_Plan__c == null) {
            Account a = [SELECT Id, Portal_Payment_Plan__c FROM Account WHERE Id = :selectedAccountId];
            paymentPlanAccount.Portal_Payment_Plan__c = a.Portal_Payment_Plan__c; 
        }
        return null;
    }
    
    public PageReference duplicate() {
        updateApp('Duplicate', duplicateId);
        return new PageReference('/' + app.Id);
    }
    
    public PageReference decline() {
        updateApp('Declined', null);
        return new PageReference('/' + app.Id);
    }

    public PageReference searchAccounts() {
        findAccounts();
        return null;
    }

    private void findAccounts() {
        String searchName = '%';
        if (accountNameSearch != null && accountNameSearch.trim() != '') {
            searchName = accountNameSearch.replace('*','%');
        }
        accounts = 
            [SELECT Id, Name, Type, Phone, BillingStreet, BillingCity, BillingState, Website
            FROM Account 
            WHERE Name LIKE :searchName
            LIMIT 25];
    }

    public PageReference searchContacts() {
        findContacts();
        return null;
    }

    private void findContacts() {
        String searchFirst = '%';
        String searchLast = '%';
        String searchCompany = '%';
        if (firstNameSearch != null && firstNameSearch.trim() != '') {
            searchFirst = firstNameSearch.replace('*','%');
        }
        if (lastNameSearch != null && lastNameSearch.trim() != '') {
            searchLast = lastNameSearch.replace('*','%');
        }
        if (contactCompanyNameSearch != null && contactCompanyNameSearch.trim() != '') {
            searchCompany = contactCompanyNameSearch.replace('*','%');
        }
        contacts = 
            [SELECT Id, Name, Title, Phone, Fax, Email, Account.Name
            FROM Contact 
            WHERE FirstName LIKE :searchFirst
            AND LastName LIKE :searchLast
            AND Account.Name LIKE :searchCompany
            LIMIT 25];
    }
    
    public List<SelectOption> getPaymentPlans() {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('', '--None--'));
        for (Portal_Payment_Plan__c plan : [SELECT Id, Name FROM Portal_Payment_Plan__c ORDER BY Name]) {
            result.add(new SelectOption(plan.Id, plan.Name));
        }
        return result;
    }
    
    private void showError(Exception e) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
    }

}