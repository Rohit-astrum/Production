//12/19/2012 TCM - show only partner portal tools
public without sharing class PortalToolsController {

    public List<Portal_Outreach_Tool__c> getTools() {   
    
        List<Portal_Outreach_Tool__c> result =
            [SELECT Id, Name, Description__c,
                (SELECT Id, Name, BodyLength, ContentType, Description
                FROM Attachments)
            FROM Portal_Outreach_Tool__c
            WHERE Active__c = TRUE
            AND Type__c = 'Flyers (PDF)'    
             AND Partner_Type__c INCLUDES ('Professional')        
            AND Portal_Availability__c INCLUDES ('Partner Portal')];

        return result;
        
    }
    
    public List<Portal_Outreach_Tool__c> getWebTools() {   
    
        List<Portal_Outreach_Tool__c> result =
            [SELECT Id, Name, Description__c,
                (SELECT Id, Name, BodyLength, ContentType, Description
                FROM Attachments)
            FROM Portal_Outreach_Tool__c
            WHERE Active__c = TRUE
             AND Type__c = 'Web Ads (JPG)'   
             AND Partner_Type__c INCLUDES ('Professional')         
            AND Portal_Availability__c INCLUDES ('Partner Portal')];

        return result;
        
    }
    
    /* Document Stuff 
    public static final String FOLDER_NAME = 'Astrum Connect Outreach Tools';
    public List<Document> getDocuments() {
        
        List<Document> result =
            [SELECT Id, Name, Description, Type, BodyLength
            FROM Document
            WHERE Folder.Name = :FOLDER_NAME];

        return result;
    } */

    /* CRM Content stuff
    
    public static final String LIBRARY_NAME = 'Astrum Connect Outreach Tools';
    
    public List<ContentDoc> getContent() {
        
        List<ContentWorkspaceDoc> libraryDocs = 
            [SELECT Id, ContentDocumentId
            FROM ContentWorkspaceDoc
            WHERE ContentWorkspace.Name = :LIBRARY_NAME];
            
        Set<Id> docIds = new Set<Id>();
        for (ContentWorkspaceDoc cwd : libraryDocs) {
            docIds.add(cwd.ContentDocumentId);
        }
        
        List<ContentVersion> docs =
            [SELECT Id, Title, Description, VersionNumber, TagCsv, FileType, FeaturedContentDate, FeaturedContentBoost
            FROM ContentVersion
            WHERE IsLatest = true
            AND PublishStatus = 'P']; //Public

        List<ContentDoc> result = new List<ContentDoc>();
        for (ContentVersion doc : docs) {
            ContentDoc cd = new ContentDoc();
            cd.docId = doc.Id;
            cd.title = doc.Title;
            cd.description = doc.Description;
            cd.fileType = doc.FileType;
            cd.versionNumber = doc.VersionNumber;
            result.add(cd); 
        }

        return result;
    }
    
    public class ContentDoc {
        public String docId { get; set; }
        public String title { get; set; }
        public String description { get; set; }
        public String fileType { get; set; }
        public String versionNumber { get; set; }
    }
    
    CRM Content page stuff --
    
        <div>
            <h2 class="green">CRM Content</h2>
            <apex:repeat var="cv" value="{!content}">
                <a href="sfc/servlet.shepherd/version/download/{!cv.docId}" class="green"><h3>{!cv.title}</h3></a> [{!cv.FileType}]
                <p>{!cv.description}</p>
            </apex:repeat>
        </div>
        <hr />
    
     
    
    */


}