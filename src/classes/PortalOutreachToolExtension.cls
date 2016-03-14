public class PortalOutreachToolExtension {

	private ApexPages.StandardController controller;
	private Portal_Outreach_Tool__c tool;

	public String documentFileName { get; set; }
	public String documentContentType { get; set; }
	public Blob documentContent { get; set; }
	public Attachment documentAttachment { get; private set; }
	
	public String thumbFileName { get; set; }
	public String thumbContentType { get; set; }
	public Blob thumbContent { get; set; }
	public Attachment thumbAttachment { get; private set; }
	
	public PortalOutreachToolExtension (ApexPages.StandardController controller) {
		this.controller = controller;
		tool = (Portal_Outreach_Tool__c)controller.getRecord();
		if (tool.Id != null) {
			getAttachments();
		} else {
			tool.Active__c = true;
		}
	}
	
	private void getAttachments() {
		for (Attachment a : [SELECT Id, Name, Description FROM Attachment WHERE ParentId = :tool.Id]) {
			if (a.Description == 'Document') {
				documentAttachment = a;
			} else if (a.Description == 'Thumbnail'){
				thumbAttachment = a;
			}
		}
		
	}
	
	public PageReference doSave() {
		if (!isValid()) {
			return null;
		}
		
		Savepoint sp = Database.setSavepoint();

		try {

			controller.save();
			
			tool = 
				[SELECT Id, Name, Description__c, Active__c 
				FROM Portal_Outreach_Tool__c
				WHERE Id = :controller.getId()];
			
			saveAttachments();
			
			return controller.view();
		
		} catch (Exception e) {
			showError(e);
			Database.rollback(sp);
		}
		
		return ApexPages.currentPage();
	}
	
	private Boolean isValid() {
		Boolean result = true;
		if ((tool.Id == null || documentAttachment == null) && (documentFileName == null || documentFileName.trim() == '')) {
			showError('Document is required');
			result = false;
		}
		if ((tool.Id == null || thumbAttachment == null) && (thumbFileName == null || thumbFileName.trim() == '')) {
			showError('Thumbnail is required');
			result = false;
		}
		
		return result;
	}
	
	private void saveAttachments() {
		if (documentAttachment == null) {
			documentAttachment = new Attachment (
				ParentId = tool.Id,
				Name = documentFileName,
				ContentType = documentContentType,
				Body = documentContent,
				Description = 'Document'
			);
		} else if (documentContent != null) {
			documentAttachment.Name = documentFileName;
			documentAttachment.ContentType = documentContentType;
			documentAttachment.Body = documentContent;
		}
		if (thumbAttachment == null) {
			thumbAttachment = new Attachment (
				ParentId = tool.Id,
				Name = thumbFileName,
				ContentType = thumbContentType,
				Body = thumbContent,
				Description = 'Thumbnail'
			);
		} else if (thumbContent != null) {
			thumbAttachment.Name = thumbFileName;
			thumbAttachment.ContentType = thumbContentType;
			thumbAttachment.Body = thumbContent;
		}
		upsert new Attachment[] { documentAttachment, thumbAttachment };
		documentContent = null;
		thumbContent = null;
		getAttachments();
	}
	
	private void showError(Exception e) {
		showError(e.getMessage());
	}

	private void showError(String error) {
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
	}

}