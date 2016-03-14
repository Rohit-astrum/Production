@isTest
private class PortalContentConfigTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out
	
	@isTest static void createTemplate_save_newTemplate() {
		if(!runalltests){ return; }
		
		Account acct = new Account (
			Name = 'Test Acct'
		);
		insert acct;
        
        Contact c = new Contact (
            LastName = 'McContact',
            AccountId = acct.Id
        );
        insert c;

        Portal_Content__c pc = new Portal_Content__c(
        	Portal_Account__c = acct.Id
        	);

		Test.setCurrentPage(Page.PartnerLandingConfig);
		ApexPages.StandardController controller = new ApexPages.StandardController(pc);
		PortalContentConfigExtension extension = new PortalContentConfigExtension(controller);

		Test.startTest();

		extension.logoFileName = 'image.jpg';
		extension.logoContentType = 'image/jpg';
		Blob imageBlob = Blob.valueOf('my image file');
		extension.logoContent = imageBlob;
		
		extension.savePage();

		Test.stopTest();

		pc = 
			[SELECT Id, Portal_Account__c,
					(SELECT Id FROM Attachments)
			FROM Portal_Content__c];
		
		System.assertEquals(acct.Id, pc.Portal_Account__c);
		System.assertEquals(1, pc.Attachments.size());
		
		Attachment att = [SELECT Id, Name, ContentType, Body FROM Attachment WHERE Id = :pc.Attachments[0].Id];
		System.assertEquals('image.jpg', att.Name);
		System.assertEquals('image/jpg', att.ContentType);
		System.assertEquals(imageBlob.toString(), att.Body.toString());
	}
}