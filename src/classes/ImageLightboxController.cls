/* FILE: ImageLightboxController.cls
 * AUTHOR: Tino Mattheou
 * DATE: April 20, 2012
 * PURPOSE: Displays images in a project in a lightbox  
 * MODIFICATION HISTORY
 * 06/27/2012 TCM - zen-10 create image thumbnails when uploading
 */ 

public class ImageLightboxController {

	public String projectId { 
		get; 
		set {
			if (projectId != value && value != null) {
				projectId = value;
				loadImages();
			}
		} 
	}
	
	public List<Astrum_Doc__c> documents { get; private set; }
	
	private void loadImages() {
		
		Set<Id> imageDocumentIds = new Set<Id>();

		//find the image documents
		List<Astrum_Doc__c> allDocs = 
			[SELECT Id, 
				(SELECT Id, ContentType
				FROM Attachments
				WHERE ContentType LIKE 'image/%' 
				ORDER BY CreatedDate DESC LIMIT 1)
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
				(SELECT Id, Description__c, CreatedDate, CreatedBy.Name
				FROM PM_Project_Issues__r
				ORDER BY CreatedDate),
				(SELECT Id, Name, BodyLength, ContentType, CreatedDate, CreatedBy.Name, Description
				FROM Attachments 
				ORDER BY BodyLength ASC LIMIT 2),
				(SELECT Id, Title, Body, LastModifiedDate, LastModifiedBy.Name
				FROM Notes 
				ORDER BY CreatedDate DESC LIMIT 1),
				(SELECT CreatedDate, CreatedBy.Name, Field, OldValue, NewValue 
				FROM Histories) 
			FROM Astrum_Doc__c
			WHERE Id IN :imageDocumentIds
			ORDER BY Name];
	}

}