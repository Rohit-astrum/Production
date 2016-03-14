/* FILE: PartnerLandingConfigExtension.cls
 * AUTHOR: Tino Mattheou
 * DATE: December 5, 2012
 * PURPOSE: Configure landing pages for customers
 * MODIFICATION HISTORY
 */

public class PartnerLandingConfigExtension {

    public String logoFileName { get; set; }
    public String logoContentType { get; set; }
    public Blob logoContent { get; set; }
    public Attachment logoAttachment { get; private set; }
    public Long timestamp { get; private set; }
    
    public String contactId { get; set; }
    public String newAccountId { get; set; }
    
    public String newPortalSite { get; set; }

    private ApexPages.StandardController controller;
    
    public PartnerLandingConfigExtension(ApexPages.StandardController controller) {
        this.controller = controller;
        getAttachments();
        Partner_Landing_Page__c plp = (Partner_Landing_Page__c)controller.getRecord();
        newPortalSite = plp.Portal_Site__c;
        newAccountId = plp.Partner_Account__c; 
        contactId = plp.Contact__c;
    }
    
    public List<Partner_Page_Template__c> templates {
        get {
            if (templates == null) {
                if (String.isNotBlank(newPortalSite)) {
                    Partner_Landing_Page__c plp = (Partner_Landing_Page__c)controller.getRecord();
                    String[] parts = newPortalSite.split('\\(',2);
                    templates = 
                        [SELECT Id, Name, VisualForce_Page__c 
                        FROM Partner_Page_Template__c
                        WHERE Active__c = true
                        AND Portal__c = :parts[0].trim()
                        ORDER BY Name];
                }
            }
            return templates;
        }
        private set;
    }
    
    public String portalUrl {
        get {
            
                String[] parts = null;
                if (String.isNotBlank(newPortalSite)) {
                    System.debug('*'+newPortalSite);
                    parts = newPortalSite.split('\\(',2);    
                                        System.debug('**'+parts[0]);
                    if (((String)UserInfo.getOrganizationId()).startsWith('00D80000000dNiA')) {
                       
                        if (parts[0].trim() == 'Landing Page Site')
                            portalUrl = 'http://go.astrumsolar.com/'; 
                        else
                            portalUrl = 'http://partners.astrumsolar.com/';     
                    } else {
                        
                        //usernames in sandbox end in the sandbox name
                        String sandboxName = UserInfo.getUserName().substringAfterLast('.');
                        if (parts[0].trim() == 'Landing Page Site')
                            portalUrl = 'http://astrumsolar.' + sandboxName + '.cs14.force.com/go/';
                        else
                            portalUrl = 'http://astrumsolar.' + sandboxName + '.cs14.force.com/partner/';    
                    }
                } 
                else
                    portalUrl = '/';   
            
            return portalUrl;
        }
        private set;
    }
    
    public PageReference refreshTemplates() {
        templates = null;
        return null;
    }
    
    public List<SelectOption> contacts {
        get {
            if (contacts == null) {
                if (String.isNotBlank(newAccountId)) {
                    contacts = new List<SelectOption>();
                    contacts.add(new SelectOption('', '--None--'));
                    List<Contact> dbContacts = [SELECT Id, Name FROM Contact WHERE AccountId = :newAccountId ORDER BY Name];
                    for (Contact c : dbContacts) {
                        contacts.add(new SelectOption(c.Id, c.Name));
                    }
                }
            }
            return contacts;
        }
        private set;
    } 
    
    public PageReference savePage() {

        Savepoint sp = Database.setSavepoint();
    
        try {
            Partner_Landing_Page__c plp = (Partner_Landing_Page__c)controller.getRecord();
            if (plp.Page_Template__c == null || ((String)plp.Page_Template__c).trim() == '') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a page template by clicking on it.'));
                return null;
            }

            plp.Contact__c = (String.isNotBlank(contactId) ? contactId : null);

            controller.save();
        
            saveAttachments();
        
            return controller.view();
            
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            Database.rollback(sp);
            return null;
        }
    }
    
    private void getAttachments() {
        for (Attachment a : [SELECT Id, Name, Description FROM Attachment WHERE ParentId = :controller.getId()]) {
            if (a.Description == 'Logo') {
                logoAttachment = a;
            }
        }
    }

    private void saveAttachments() {
        if (logoContent != null) {
            if (logoAttachment == null) {
                logoAttachment = new Attachment (
                    ParentId = controller.getId(),
                    Name = logoFileName,
                    ContentType = logoContentType,
                    Body = logoContent,
                    Description = 'Logo'
                );
            } else {
                logoAttachment.Name = logoFileName;
                logoAttachment.ContentType = logoContentType;
                logoAttachment.Body = logoContent;
            }
            upsert logoAttachment;
            logoContent = null;
        }
        getAttachments();
    }
    
}