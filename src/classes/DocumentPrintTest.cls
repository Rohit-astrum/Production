/* FILE: DocumentPrintTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: June 9, 2012
 * PURPOSE: Test class for DocumentPrintEmail and DocumentPrint pages and the ImageLightbox component  
 * MODIFICATION HISTORY
 *
 */ 

@isTest
public class DocumentPrintTest {

    static testMethod void projectWithDocs_loadPrintEmail_showsImagesNotTrash() {
        
        PM_Project__c project = createProjectWithDocs();
        
        Test.setCurrentPage(Page.DocumentPrintEmail);
        ApexPages.currentPage().getParameters().put('id', project.Id);
        
        Test.startTest();
        
        DocumentPrintEmailController controller = new DocumentPrintEmailController();
        
        Test.stopTest();
        
        System.assertEquals(2, controller.documents.size());
    }
    
    static testMethod void projectWithDocs_twoSelected_rendersSelected() {
        
        PM_Project__c project = createProjectWithDocs();
        
        Test.setCurrentPage(Page.DocumentPrintEmail);
        ApexPages.currentPage().getParameters().put('id', project.Id);
        
        DocumentPrintEmailController controller = new DocumentPrintEmailController();
        System.assertEquals(2, controller.documents.size());
        
        String ids = '';
        Set<Id> docIds = new Set<Id>();
        for (Astrum_Doc__c doc : controller.documents) {
            docIds.add(doc.Id);
            for (Attachment att : doc.Attachments) {
                ids += att.Id + ' ';
            }
        }
        
        Test.setCurrentPage(Page.DocumentPrint);
        ApexPages.currentPage().getParameters().put('id', project.Id);
        ApexPages.currentPage().getParameters().put('ids', ids.trim());
        
        Test.startTest();
        
        DocumentPrintController controller2 = new DocumentPrintController();
        List<Astrum_Doc__c> docs = controller2.getDocuments();
        PM_Project__c controllerProject = controller2.getProject();     
        
        Test.stopTest();

        //System.assertEquals(2, controller2.selectedIds.size());
        System.assertEquals(2, docs.size());
        
        for (Astrum_Doc__c doc : docs) {
            System.assert(docIds.contains(doc.Id));
        }
        
        System.assertEquals(project.Id, controllerProject.Id);
    }
    
    static testMethod void projectWithDocs_lightbox_showsImagesNotTrash() {
        
        PM_Project__c project = createProjectWithDocs();
        
        Test.startTest();
        
        ImageLightboxController controller = new ImageLightboxController();
        controller.projectId = project.Id;
        
        Test.stopTest();
        
        System.assertEquals(2, controller.documents.size());
    }
    
    public static PM_Project__c createProjectWithDocs() {

        PM_Project__c project = new PM_Project__c ( Name = 'Test Project' );
        insert project;
        
        List<Astrum_Doc__c> docs = new List<Astrum_Doc__c> {
            new Astrum_Doc__c (
                PM_Project__c = project.Id,
                Bin__c = 'Bin',
                Category__c = 'Image 1'
            ),
            new Astrum_Doc__c (
                PM_Project__c = project.Id,
                Bin__c = 'Bin',
                Category__c = 'PDF 1'
            ),
            new Astrum_Doc__c (
                PM_Project__c = project.Id,
                Bin__c = 'Bin',
                Category__c = 'Image 2'
            ),
            new Astrum_Doc__c (
                PM_Project__c = project.Id,
                Bin__c = 'Trash',
                Category__c = 'Trash'
            )
        };
        insert docs;
        
        Blob content = Blob.valueOf('TEST DOC');
        List<Attachment> atts = new List<Attachment> {
            new Attachment (
                ParentId = docs[0].Id,
                Name = 'image #1',
                ContentType = 'image/jpg',
                Body = content
            ),
            new Attachment (
                ParentId = docs[1].Id,
                Name = 'pdf',
                ContentType = 'application/pdf',
                Body = content
            ),
            new Attachment (
                ParentId = docs[2].Id,
                Name = 'image #2',
                ContentType = 'image/gif',
                Body = content
            ),
            new Attachment (
                ParentId = docs[3].Id,
                Name = 'image #3',
                ContentType = 'image/jpg',
                Body = content
            )
        };
        insert atts;

        return project;     
    }


}