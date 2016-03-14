/* FILE: PartnerVerificationTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: September 11, 2012
 * PURPOSE: Test class for PortalOutreachTool pages and PortalOutreachToolExtension
 * MODIFICATION HISTORY
 *
 */

@isTest
public class PortalOutreachToolTest {

	static testMethod void load_createTool_created() {
		
		Portal_Outreach_Tool__c tool = new Portal_Outreach_Tool__c();
		ApexPages.StandardController controller = new ApexPages.StandardController(tool);
		PortalOutreachToolExtension extension = new PortalOutreachToolExtension(controller);
		
		Test.setCurrentPage(Page.PortalOutreachTool);
		
		String docName = 'Test Tool'; 
		tool.Name = docName;
		String description = 'Test Description';
		tool.Description__c = description;
		Blob pdf = Blob.valueOf('PDF DATA');
		String docFileName = 'test.pdf';
		extension.documentFileName = docFileName;
		String docContentType = 'application/pdf';
		extension.documentContentType = docContentType;
		extension.documentContent = pdf;
		String thumbFileName = 'test.jpg';
		extension.thumbFileName = thumbFileName;
		String thumbContentType = 'image/jpg';
		extension.thumbContentType = thumbContentType;
		Blob jpg = Blob.valueOf('JPEG DATA');
		extension.thumbContent = jpg;
		
		System.assertEquals(true, tool.Active__c);
		
		Test.startTest();
		
		PageReference pr = extension.doSave();
		
		Test.stopTest();
		
		System.assertEquals(0, ApexPages.getMessages().size(), String.valueOf(ApexPages.getMessages()));
		
		Portal_Outreach_Tool__c tool2 = 
			[SELECT Id, Name, Description__c, Active__c,
				(SELECT Id, Name, Description, BodyLength, ContentType
				FROM Attachments 
				ORDER BY Description)
			FROM Portal_Outreach_Tool__c];

		System.assertEquals('/' + ((String)tool2.Id).substring(0,15), pr.getUrl());
		
		System.assertEquals(docName, tool2.Name);
		System.assertEquals(description, tool2.Description__c);
		System.assertEquals(true, tool2.Active__c);
		
		System.assertEquals(2, tool2.Attachments.size());
		
		Attachment docAtt = tool2.Attachments[0];
		System.assertEquals(docFileName, docAtt.Name);
		System.assertEquals(docContentType, docAtt.ContentType);
		System.assertEquals('Document', docAtt.Description);
		System.assertEquals(pdf.size(), docAtt.BodyLength);

		Attachment thumbAtt = tool2.Attachments[1];
		System.assertEquals(thumbFileName, thumbAtt.Name);
		System.assertEquals(thumbContentType, thumbAtt.ContentType);
		System.assertEquals('Thumbnail', thumbAtt.Description);
		System.assertEquals(jpg.size(), thumbAtt.BodyLength);
		
	}
	
	static testMethod void editTool_changeThumb_updated() {
		
		Portal_Outreach_Tool__c tool = new Portal_Outreach_Tool__c (
			Name = 'Test Tool',
			Description__c = 'Test Description',
			Active__c = true
		);
		insert tool;
		
		Attachment doc = new Attachment (
			ParentId = tool.Id, 
			Name = 'test.pdf',
			ContentType = 'application/pdf',
			Description = 'Document',
			Body = Blob.valueOf('PDF DATA')
		);
		insert doc;	

		Attachment thumb = new Attachment (
			ParentId = tool.Id, 
			Name = 'test.jpg',
			ContentType = 'image/jpg',
			Description = 'Thumbnail',
			Body = Blob.valueOf('JPEG DATA')
		);
		insert thumb;	

		PageReference editPage = Page.PortalOutreachTool;
		editPage.getParameters().put('id', tool.Id); 
		Test.setCurrentPage(editPage);
		
		ApexPages.StandardController controller = new ApexPages.StandardController(tool);
		PortalOutreachToolExtension extension = new PortalOutreachToolExtension(controller);
		
		System.assertEquals(doc.Id, extension.documentAttachment.Id);
		System.assertEquals(thumb.Id, extension.thumbAttachment.Id);
		
		String thumbFileName = 'test2.gif';
		extension.thumbFileName = thumbFileName;
		String thumbContentType = 'image/gif';
		extension.thumbContentType = thumbContentType;
		Blob gif = Blob.valueOf('GIF89 DATA');
		extension.thumbContent = gif;
		
		Test.startTest();
		
		PageReference pr = extension.doSave();
		
		Test.stopTest();
		
		System.assertEquals(0, ApexPages.getMessages().size(), String.valueOf(ApexPages.getMessages()));
		
		Portal_Outreach_Tool__c tool2 = 
			[SELECT Id, Name, Description__c, Active__c,
				(SELECT Id, Name, Description, BodyLength, ContentType 
				FROM Attachments 
				ORDER BY Description)
			FROM Portal_Outreach_Tool__c];

		System.assertEquals('/' + ((String)tool2.Id).substring(0,15), pr.getUrl());
		
		System.assertEquals(2, tool2.Attachments.size());
		
		Attachment docAtt = tool2.Attachments[0];
		System.assertEquals(doc.Id, docAtt.Id);

		Attachment thumbAtt = tool2.Attachments[1];
		System.assertEquals(thumb.Id, thumbAtt.Id);
		System.assertEquals(thumbFileName, thumbAtt.Name);
		System.assertEquals(thumbContentType, thumbAtt.ContentType);
		System.assertEquals('Thumbnail', thumbAtt.Description);
		System.assertEquals(gif.size(), thumbAtt.BodyLength);
		
	}
	
	static testMethod void noDocNoThumb_save_errors() {
		
		Portal_Outreach_Tool__c tool = new Portal_Outreach_Tool__c();
		ApexPages.StandardController controller = new ApexPages.StandardController(tool);
		PortalOutreachToolExtension extension = new PortalOutreachToolExtension(controller);
		
		Test.setCurrentPage(Page.PortalOutreachTool);
		
		tool.Name = 'Test Tool';
		tool.Description__c = 'Test Description';
		
		System.assertEquals(true, tool.Active__c);
		
		Test.startTest();
		
		PageReference pr = extension.doSave();
		
		Test.stopTest();
		
		System.assertEquals(2, ApexPages.getMessages().size(), String.valueOf(ApexPages.getMessages()));

	}
	

}