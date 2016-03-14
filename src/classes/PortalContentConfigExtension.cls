/* FILE: PortalContentConfigExtension.cls
 * AUTHOR: Rohit
 * DATE: April 10, 2013
 * PURPOSE: Configure portal content for customers
 * MODIFICATION HISTORY
 */

public class PortalContentConfigExtension {

    public String logoFileName { get; set; }
    public String logoContentType { get; set; }
    public Blob logoContent { get; set; }
    public Attachment logoAttachment { get; private set; }
    public Long timestamp { get; private set; }  
    public String newAccountId { get; set; }    
   

    private ApexPages.StandardController controller;
    
    public PortalContentConfigExtension (ApexPages.StandardController controller) {
        this.controller = controller;
        getAttachments();
        Portal_Content__c plp = (Portal_Content__c)controller.getRecord();        
        newAccountId = plp.Portal_Account__c; 
       
    }   
    
    public PageReference savePage() {

        Savepoint sp = Database.setSavepoint();
    
        try {
            Portal_Content__c plp = (Portal_Content__c)controller.getRecord(); 

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