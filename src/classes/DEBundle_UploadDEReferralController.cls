public with sharing class DEBundle_UploadDEReferralController {

	private SCRB_SalesOrder__c theSalesOrder;
    public Attachment uploadFile { get; set; }

    public String parentDomain {get;set;}

	public DEBundle_UploadDEReferralController(ApexPages.StandardController stdController) {
		theSalesOrder = (SCRB_SalesOrder__c)stdController.getRecord();
        uploadFile = new Attachment();
        parentDomain = ApexPages.currentPage().getHeaders().get('referer');  
	}

	public PageReference upload(){
        Savepoint sp = Database.setSavepoint();
        try {
            if(uploadFile.Body == null){
                throw new DEBundle_Utility.DEBundleException('The upload file cannot be null.');
            }
            uploadFile.ParentId = theSalesOrder.Id;
            uploadFile.Name = 'DER Solar Advantage Plan.pdf';
            insert uploadFile;
        } catch (Exception ex) {
            ApexPages.addMessages(ex);
            uploadFile = new Attachment();
            Database.rollback(sp);
            return null;
        }

        uploadFile = new Attachment();
        return null;
	}
}