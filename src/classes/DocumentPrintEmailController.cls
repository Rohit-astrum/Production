/* FILE: DocumentPrintEmailController.cls
 * AUTHOR: Tino Mattheou
 * DATE: June 5, 2012
 * PURPOSE: Controller for DocumentPrintEmail page.  Displays only non-trash image files in project
 * MODIFICATION HISTORY
 * 06/28/2012 TCM - zen-10 create image thumbnails when uploading 
 * 01/28/2013 TCM - zen-24 print project notes with images
 */ 

public class DocumentPrintEmailController {

	public List<Astrum_Doc__c> documents { get; private set; }
	public List<Astrum_Doc__c> notes { get; private set; }
	
	private String projectId;  
	
	public DocumentPrintEmailController() {
		projectId = ApexPages.currentPage().getParameters().get('id');
		if (projectId != null) {
			loadImages();
			loadNotes();
		}
	}
	
	private void loadImages() {
		
		Set<Id> imageDocumentIds = new Set<Id>();

		//find the image documents
		List<Astrum_Doc__c> allDocs = 
			[SELECT Id, 
				(SELECT Id, ContentType
				FROM Attachments
				WHERE ContentType LIKE 'image/%' 
				ORDER BY BodyLength ASC LIMIT 1)
			FROM Astrum_Doc__c
			WHERE PM_Project__c = :projectId
			AND Category__c <> 'Trash'];
			
		for (Astrum_Doc__c doc : allDocs) {
			if (doc.Attachments.size() > 0) {
				imageDocumentIds.add(doc.Id);
			}
		}
		
		documents = 
			[SELECT Id, Name, CreatedDate, CreatedBy.Name, Document_Key_Date__c, Verified__c, Category__c, Bin__c, 
				(SELECT Id, Name
				FROM Attachments 
				ORDER BY BodyLength ASC LIMIT 1)
			FROM Astrum_Doc__c
			WHERE Id IN :imageDocumentIds
			ORDER BY Bin__c, Category__c, Name];
		
		for (Astrum_Doc__c doc : documents) {
			for (Attachment a : doc.Attachments) {
				a.Name = a.Name.replaceFirst('thumbnail-', '');
			}
		}	
	}
	
	private void loadNotes() {
		
		notes = 
			[SELECT Id, Name, CreatedDate, CreatedBy.Name, Document_Key_Date__c, Verified__c, Category__c, Bin__c, 
				(SELECT Id, Title, Body, LastModifiedDate, LastModifiedBy.Name
		 		FROM Notes 
		 		ORDER BY CreatedDate DESC LIMIT 1) 
			FROM Astrum_Doc__c
			WHERE IsNote__c = true
			AND PM_Project__c = :projectId
			AND Category__c <> 'Trash'
			ORDER BY Bin__c, Category__c, Name];
		
	}

}