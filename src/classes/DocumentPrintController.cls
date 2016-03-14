/* FILE: DocumentPrintController.cls
 * AUTHOR: Tino Mattheou
 * DATE: June 6, 2012
 * PURPOSE: Controller for DocumentPrint page.  Displays only selected image files in a PDF
 * MODIFICATION HISTORY
 * 06/28/2012 TCM - zen-10 create image thumbnails when uploading 
 * 01/25/2013 TCM - zen-38 portrait images split - use landscape portrait settings
 * 01/28/2013 TCM - zen-24 print project notes with images
 */ 

public class DocumentPrintController {

	private String projectId;
	private Map<String,String> orientationMap = new Map<String,String>();  

	private List<String> selectedIds;
	private List<String> noteIds;
	
	public DocumentPrintController() {
		Map<String,String> params = ApexPages.currentPage().getParameters();
		projectId = params.get('id');
		String selection = params.get('ids');
		if (selection != null) {
			selectedIds = selection.split(' ');
		}
		String orients = params.get('orients');
		if (selection != null && orients != null) {
			List<String> orientations = orients.split(' ');
			if (selectedIds.size() == orientations.size()) {
				for (Integer i = 0; i < selectedIds.size(); i++) {
					orientationMap.put(selectedIds[i], orientations[i]);
				}
			}
		}
		String notes = params.get('noteIds');
		if (notes != null) {
			noteIds = notes.split(' ');
		}
	}
	
	public PM_Project__c getProject() {
		
		PM_Project__c result;
		
		if (projectId != null) {
			result = [SELECT Id, Name FROM PM_Project__c WHERE Id = :projectId];
		}
		
		return result; 
	}
	
	public List<Astrum_Doc__c> getDocuments() {
		
		List<Astrum_Doc__c> result;
		
		if (selectedIds != null && selectedIds.size() > 0) {
			
			Map<Id,Id> docToThumbMap = new Map<Id,Id>();
			
			Set<Id> docIds = new Set<Id>();
			List<Attachment> atts = [SELECT Id, ParentId FROM Attachment WHERE Id IN :selectedIds];
			
			for (Attachment a : atts) {
				docIds.add(a.ParentId);
				docToThumbMap.put(a.ParentId, a.Id);
			}
			
			result = [
				SELECT Id, Category__c, Bin__c,
			 		(SELECT Id, Name, Description FROM Attachments ORDER BY BodyLength DESC LIMIT 1)
			 	FROM Astrum_Doc__c
			 	WHERE Id IN :docIds
			];	
			
			for (Astrum_Doc__c doc : result) {
				for (Attachment att : doc.Attachments) {
					att.Description = orientationMap.get(docToThumbMap.get(doc.Id));
				}
			}
			
		}
		
		return result;
		
	} 
	
	public List<Astrum_Doc__c> getNotes() {
		
		List<Astrum_Doc__c> result;
		
		if (noteIds != null && noteIds.size() > 0) {

			Map<Id,Id> docToThumbMap = new Map<Id,Id>();
			
			Set<Id> docIds = new Set<Id>();
			List<Note> notes = [SELECT Id, ParentId FROM Note WHERE Id IN :noteIds];
			
			for (Note n : notes) {
				docIds.add(n.ParentId);
			}
			
			result = 
				[SELECT Id, Name, CreatedDate, CreatedBy.Name, Document_Key_Date__c, Verified__c, Category__c, Bin__c, 
					(SELECT Id, Title, Body, LastModifiedDate, LastModifiedBy.Name
			 		FROM Notes 
			 		ORDER BY CreatedDate DESC LIMIT 1) 
				FROM Astrum_Doc__c
				WHERE Id IN :docIds
				ORDER BY Bin__c, Category__c, Name];
			
		}
		
		return result;
		
	} 

}