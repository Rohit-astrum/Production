/* FILE: DocumentBinTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: June 10, 2012
 * PURPOSE: Test class for ProjectDocuments component  
 * MODIFICATION HISTORY
 *
 */ 
 
@isTest
public class ProjectDocumentsTest {
	
	static testMethod void projectWithNoDocs_addDocument_binStateSet() {
		
		DocumentBinTest.createBinConfiguration();
		
		PM_Project__c project = new PM_Project__c ( Name = 'Test Project' );
		insert project;
		
		Test.setCurrentPage(Page.PMProjectDetail);
		ProjectDocumentsController controller = new ProjectDocumentsController();
		controller.projectId = project.Id;
	
		System.assertEquals(1, ProjectDocumentsController.binConfig.size());	
		System.assertEquals(4, ProjectDocumentsController.categories.size());	
		System.assertEquals(1, ProjectDocumentsController.binGroups.size());	
		System.assertEquals(project.Id, controller.projectId);
		System.assertEquals(0, controller.documents.size());
		System.assertNotEquals(null, controller.uploadFile);
		System.assertEquals(DocumentConfigurationHelper.APP_ASTRUM_PM_20, controller.appName);
		
		Test.startTest();
		
		String binName = 'Grant Completion';
		String categoryName = 'Prepared Application';
		String keyDate = '05/05/2012';
		String fileName = 'test-image.jpg';
		String contentType = 'image/jpg';
		
		Blob content = Blob.valueOf('test image');
		ApexPages.currentPage().getParameters().put('binName', binName);
		ApexPages.currentPage().getParameters().put('categoryName', categoryName);
		ApexPages.currentPage().getParameters().put('keyDate', keyDate);
		controller.uploadFile.Name = fileName;
		controller.uploadFile.Body = content;
		controller.uploadFile.ContentType = contentType; 
		
		PageReference result = controller.upload();		
		
		Test.stopTest();
		
		System.assert(result.getUrl().startsWith(Page.ProjectDocumentsJson.getUrl()));
		Map<String, String> params = result.getParameters();
		
		System.assertEquals(fileName, params.get('fileName'));
		System.assertNotEquals(null, params.get('fileSize'));
		System.assertEquals(keyDate, params.get('keyDate'));
		System.assertEquals(contentType, params.get('contentType'));
		
		String docId = params.get('docId');
		String attId = params.get('attId');
		
		Astrum_Doc__c doc = [SELECT Id, Bin__c, Category__c, Document_Key_Date__c, PM_Project__c
			FROM Astrum_Doc__c WHERE Id = :docId];
		
		System.assertEquals(binName, doc.Bin__c);
		System.assertEquals(categoryName, doc.Category__c);
		System.assertEquals(Date.newInstance(2012,5,5), doc.Document_Key_Date__c);
		System.assertEquals(project.Id, doc.PM_Project__c);
			
		Attachment att = [SELECT Id, ParentId, BodyLength, Name, ContentType, Body
			FROM Attachment WHERE Id = :attId];
			
		System.assertEquals(doc.Id, att.ParentId);
		System.assertEquals(content.size(), att.BodyLength);
		System.assertEquals(fileName, att.Name);
		System.assertEquals(String.valueOf(content), String.valueOf(att.Body));
		
		project = [SELECT Id, Grant_Completion_Completed__c FROM PM_Project__c WHERE Id = :project.Id];
		System.assertEquals(Date.newInstance(2012,5,5), project.Grant_Completion_Completed__c);
		 
	}
	
	static testMethod void projectWithNoDocs_addNote_binStateSet() {
		
		DocumentBinTest.createBinConfiguration();
		
		PM_Project__c project = new PM_Project__c ( Name = 'Test Project' );
		insert project;
		
		Test.setCurrentPage(Page.PMProjectDetail);
		ProjectDocumentsController controller = new ProjectDocumentsController();
		controller.projectId = project.Id;
		
		Test.startTest();
		
		String binName = 'Grant Completion';
		String categoryName = 'Signed Application';
		String keyDate = '05/15/2012';
		String noteText = 'Test Note';
		
		String noteId = ProjectDocumentsController.addNote(project.Id, binName, categoryName, noteText);
		ProjectDocumentsController.updateDocument(noteId, keyDate);
		List<DocumentBinController.InterimState> binStates = ProjectDocumentsController.getAllBinStates(project.Id);
	
		Test.stopTest();	
		
		Astrum_Doc__c noteDoc = [SELECT Id, Bin__c, Category__c, IsNote__c, Document_Key_Date__c,
			(SELECT Id, Title, Body FROM Notes) FROM Astrum_Doc__c WHERE Id = :noteId];
			
		System.assertEquals(binName, noteDoc.Bin__c);
		System.assertEquals(categoryName, noteDoc.Category__c);
		System.assertEquals(true, noteDoc.IsNote__c);
		System.assertEquals(Date.newInstance(2012,5,15), noteDoc.Document_Key_Date__c);
		System.assertEquals(1, noteDoc.Notes.size());
		System.assertEquals('Note', noteDoc.Notes[0].Title);
		System.assertEquals(noteText, noteDoc.Notes[0].Body);

		project = [SELECT Id, Grant_Completion_Signed__c FROM PM_Project__c WHERE Id = :project.Id];
		System.assertEquals(Date.newInstance(2012,5,15), project.Grant_Completion_Signed__c);
		
		System.assertEquals(4, binStates.size());
		System.assertEquals(binName, binStates[1].binName);
		System.assertEquals('Signed', binStates[1].binState);
		System.assertEquals(Date.newInstance(2012,5,15), binStates[1].binDate);
		
	}
	
	static testMethod void document_changeCategory_categoryChanged() {

		DocumentBinTest.createBinConfiguration();

		PM_Project__c project = new PM_Project__c ( Name = 'Test Project' );
		insert project;
		
		String binName1 = 'Trash';
		String binName2 = 'Grant Completion';
		String category1 = 'Trash'; 
		String category2 = 'Signed Application';
		Date keyDate =  Date.newInstance(2012,5,5);
		
		Astrum_Doc__c doc = new Astrum_Doc__c (
			PM_Project__c = project.Id,
			Bin__c = binName1,
			Category__c = category1,
			Document_Key_Date__c = keyDate
		);
		insert doc;
		
		doc = [SELECT Id, Bin__c, Category__c FROM Astrum_Doc__c WHERE Id = :doc.Id];
		System.assertEquals(binName1, doc.Bin__c);
		System.assertEquals(category1, doc.Category__c);
		
		Test.startTest();
		
		ProjectDocumentsController.updateCategory(doc.Id, binName2, category2);
		
		Test.stopTest();

		doc = [SELECT Id, Bin__c, Category__c FROM Astrum_Doc__c WHERE Id = :doc.Id];
		System.assertEquals(binName2, doc.Bin__c);
		System.assertEquals(category2, doc.Category__c);

		project = [SELECT Id, Grant_Completion_Signed__c FROM PM_Project__c WHERE Id = :project.Id];
		System.assertEquals(keyDate, project.Grant_Completion_Signed__c);
		
	}

	static testMethod void document_addIssue_countChanged() {
		
		PM_Project__c project = new PM_Project__c ( Name = 'Test Project' );
		insert project;
		
		String binName = 'Grant Completion';
		String categoryName = 'Signed Application';
		
		Astrum_Doc__c doc = new Astrum_Doc__c (
			PM_Project__c = project.Id,
			Bin__c = binName,
			Category__c = categoryName 
		);
		insert doc;
		
		List<PM_Project_Issue__c> issues = new List<PM_Project_Issue__c> {
			new PM_Project_Issue__c (
				PM_Project__c = project.Id,
				Astrum_Doc__c = doc.Id,
				To__c = DocumentConfigurationHelper.APP_ASTRUM_PM_20,
				Status__c = 'Open'
			),
			new PM_Project_Issue__c (
				PM_Project__c = project.Id,
				Astrum_Doc__c = doc.Id,
				To__c = DocumentConfigurationHelper.APP_ASTRUM_PM_20,
				Status__c = 'Fixed'
			),
			new PM_Project_Issue__c (
				PM_Project__c = project.Id,
				Astrum_Doc__c = doc.Id,
				To__c = DocumentConfigurationHelper.APP_ASTRUM_PM_20,
				Status__c = 'Closed'
			),
			new PM_Project_Issue__c (
				PM_Project__c = project.Id,
				Astrum_Doc__c = doc.Id,
				To__c = DocumentConfigurationHelper.APP_ASTRUM_GRANTS,
				Status__c = 'Open'
			),
			new PM_Project_Issue__c (
				PM_Project__c = project.Id,
				Astrum_Doc__c = doc.Id,
				To__c = DocumentConfigurationHelper.APP_ASTRUM_GRANTS,
				Status__c = 'Fixed'
			),
			new PM_Project_Issue__c (
				PM_Project__c = project.Id,
				Astrum_Doc__c = doc.Id,
				To__c = DocumentConfigurationHelper.APP_ASTRUM_GRANTS,
				Status__c = 'Closed'
			)
		};
		insert issues;
		
		Test.startTest();
		
		Integer issueCount = ProjectDocumentsController.getDocIssueCount(DocumentConfigurationHelper.APP_ASTRUM_PM_20, doc.Id); 
		System.assertEquals(1, issueCount);  // returns either 1 or 0;
		
		issues[4].Status__c = 'Closed';
		update issues[4];
		
		issueCount = ProjectDocumentsController.getDocIssueCount(DocumentConfigurationHelper.APP_ASTRUM_PM_20, doc.Id); 
		System.assertEquals(1, issueCount);

		issues[0].Status__c = 'Fixed';
		update issues[0];
		
		issueCount = ProjectDocumentsController.getDocIssueCount(DocumentConfigurationHelper.APP_ASTRUM_PM_20, doc.Id); 
		System.assertEquals(0, issueCount);  // returns either 1 or 0;
		
		Test.stopTest();
	}
	
	static testMethod void document_verify_verified() {
		
		Astrum_Doc__c doc = new Astrum_Doc__c ();
		insert doc;
		
		Test.startTest();
		
		System.assertEquals(true, ProjectDocumentsController.verifyDocument(doc.Id));

		doc = [SELECT Id, Verified__c FROM Astrum_Doc__c WHERE Id = :doc.Id];
		System.assertEquals(true, doc.Verified__c);

		System.assertEquals(false, ProjectDocumentsController.verifyDocument(doc.Id));

		doc = [SELECT Id, Verified__c FROM Astrum_Doc__c WHERE Id = :doc.Id];
		System.assertEquals(false, doc.Verified__c);
		
		Test.stopTest();
		
	}
	
	static testMethod void projectWithDocs_getBinDocs_binDocsRetrieved() {
		
		PM_Project__c project = DocumentPrintTest.createProjectWithDocs();
		
		List<ProjectDocumentsController.AstrumDocument> docs
			= ProjectDocumentsController.getDocuments('PL', project.Id, 'Bin');
		
		System.assertEquals(3, docs.size());
	}
	
//TODO: add move coverage of checkBinComplete

}