/* FILE: DocumentBinTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: June 9, 2012
 * PURPOSE: Test class for DocumentBin page  
 * MODIFICATION HISTORY
 *
 */ 
 
@isTest
public class DocumentBinTest {
	
	static testMethod void projectWithNoDocs_addDocument_binStateSet() {
		
		createBinConfiguration();
		
		PM_Project__c project = new PM_Project__c ( Name = 'Test Project' );
		insert project;
		
		String binName = 'Grant Completion';
		
		Test.setCurrentPage(Page.DocumentBinDialog);
		DocumentBinController controller = new DocumentBinController();
		controller.binName = binName;
		controller.projectId = project.Id;
		controller.appName = DocumentConfigurationHelper.APP_ASTRUM_PM_20;
		
		System.assertEquals(null, controller.binDate);
		System.assertEquals(3, controller.binStates.size()); //3 interim states
		System.assertEquals(project.Id, controller.project.Id);
		System.assertEquals(0, controller.documents.size());
		System.assertNotEquals(null, controller.uploadFile);
		
		System.assertEquals(4, controller.categories.size());

		Test.startTest();
		
		String categoryName = 'Prepared Application';
		String keyDate = '05/05/2012';
		String fileName = 'test-image.jpg';
		String contentType = 'image/jpg';
		
		Blob content = Blob.valueOf('test image');
		ApexPages.currentPage().getParameters().put('categoryName', categoryName);
		ApexPages.currentPage().getParameters().put('keyDate', keyDate);
		controller.uploadFile.Name = fileName;
		controller.uploadFile.Body = content;
		controller.uploadFile.ContentType = contentType; 
		
		PageReference result = controller.upload();		
		controller.checkBinComplete();
		
		Test.stopTest();
		
		System.assert(result.getUrl().startsWith(Page.DocumentBinJson.getUrl()));
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
		
		createBinConfiguration();
		
		PM_Project__c project = new PM_Project__c ( Name = 'Test Project' );
		insert project;
		
		String binName = 'Grant Completion';
		
		Test.setCurrentPage(Page.DocumentBinDialog);
		DocumentBinController controller = new DocumentBinController();
		controller.binName = binName;
		controller.projectId = project.Id;
		controller.appName = DocumentConfigurationHelper.APP_ASTRUM_PM_20;
		
		Test.startTest();
		
		String categoryName = 'Signed Application';
		String keyDate = '05/15/2012';
		String noteText = 'Test Note';
		
		String noteId = DocumentBinController.addNote(project.Id, binName, categoryName, noteText);
		DocumentBinController.updateDocument(noteId, keyDate);
		controller.checkBinComplete();
	
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
		
	}
	
	static testMethod void document_changeCategory_categoryChanged() {
		
		String category1 = 'Signed Application'; 
		String category2 = 'Submitted Application'; 
		
		Astrum_Doc__c doc = new Astrum_Doc__c (
			Category__c = category1 
		);
		insert doc;
		
		doc = [SELECT Id, Category__c FROM Astrum_Doc__c WHERE Id = :doc.Id];
		System.assertEquals(category1, doc.Category__c);
		
		Test.startTest();
		
		DocumentBinController.updateCategory(doc.Id, category2);
		
		Test.stopTest();

		doc = [SELECT Id, Category__c FROM Astrum_Doc__c WHERE Id = :doc.Id];
		System.assertEquals(category2, doc.Category__c);
		
	}

	static testMethod void document_addIssue_categoryChanged() {
		
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
		
		Integer issueCount = DocumentBinController.getDocIssueCount(DocumentConfigurationHelper.APP_ASTRUM_PM_20, doc.Id); 
		System.assertEquals(1, issueCount);  // returns either 1 or 0;
		
		issues[4].Status__c = 'Closed';
		update issues[4];
		
		issueCount = DocumentBinController.getDocIssueCount(DocumentConfigurationHelper.APP_ASTRUM_PM_20, doc.Id); 
		System.assertEquals(1, issueCount);

		issues[0].Status__c = 'Fixed';
		update issues[0];
		
		issueCount = DocumentBinController.getDocIssueCount(DocumentConfigurationHelper.APP_ASTRUM_PM_20, doc.Id); 
		System.assertEquals(0, issueCount);  // returns either 1 or 0;
		
		Test.stopTest();
		
	}
	
	static testMethod void newProject_loadBin_templatesShown() {
		
		createBinConfiguration();
		createPlaceHierarchy();
		createTemplates();
		
		Account customer = new Account(Name = 'Test Customer');
		insert customer;
		Property__c property = CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');
		SCRB_SalesOrder__c salesOrder = CreateAstrumPM2ProjectTest.createSalesOrder(property.Id, null);
		
		salesOrder.Financing_Type__c = 'Lease';
		salesOrder.Leasing_Option__c = 'Constellation 0711 Prepay';
		update salesOrder;
		
		PM_Project__c project = new PM_Project__c (
			Name = 'Test Project',
			Sales_Order__c = salesOrder.Id
		);
		insert project;

		String binName = 'Grant Completion';
		String category1 = 'Signed Application'; 
		String category2 = 'Submitted Application';
		
		Astrum_Doc__c doc1 = new Astrum_Doc__c (
			PM_Project__c = project.Id,
			Bin__c = binName,
			Category__c = category1
		);
		insert doc1;

		Astrum_Doc__c doc2 = new Astrum_Doc__c (
			PM_Project__c = project.Id,
			Bin__c = binName,
			Category__c = category2
		);
		insert doc2;

		Test.startTest();
				
		Test.setCurrentPage(Page.DocumentBinDialog);
		DocumentBinController controller = new DocumentBinController();
		controller.binName = binName;
		controller.appName = DocumentConfigurationHelper.APP_ASTRUM_PM_20;
		controller.projectId = project.Id;
		
		System.assertEquals(4, controller.templates.size());
		
		String formDesignId;
		for (Astrum_Template__c template : controller.templates) {
			if (template.Name == 'County Template') {
				formDesignId = template.Form_Design__c;
			}
		}
		System.assertNotEquals(null, formDesignId);
		
		List<DocumentBinController.SubmissionDocument> documents 
			= DocumentBinController.getDocuments(project.Id, formDesignId);
			
		System.assertEquals(2, documents.size());

		Integer found = 0;		
		for (DocumentBinController.SubmissionDocument doc : documents) {
			if (doc.docName == 'Additional Doc 1') {
				System.assertEquals(category1, doc.category);
				System.assertEquals(doc1.Id, doc.document.Id);
				found++;
			} else if (doc.docName == 'Additional Doc 2') {
				System.assertEquals(category2, doc.category);
				System.assertEquals(doc2.Id, doc.document.Id);
				found++;
			} 
		}
		System.assertEquals(2, found);
		
		List<DocumentBinController.FormField> formFields 
			= DocumentBinController.getData(project.Id, formDesignId);
			
		System.assertEquals(3, formFields.size());
		
		found = 0;		
		for (DocumentBinController.FormField field : formFields) {
			if (field.fieldName == 'Form Field 1') {
				System.assertEquals(property.Name, field.value);
				System.assertEquals(true, field.required);
				found++;
			} else if (field.fieldName == 'Form Field 2') {
				System.assertEquals(property.Property_City__c, field.value);
				System.assertEquals(false, field.required);
				found++;
			} else if (field.fieldName == 'Form Field 3') {
				System.assertEquals(property.Property_State__c, field.value);
				System.assertEquals(false, field.required);
				found++;
			}
		}
		System.assertEquals(3, found);
		
		Test.stopTest();
	}
	
	static testMethod void document_verify_verified() {
		
		Astrum_Doc__c doc = new Astrum_Doc__c ();
		insert doc;
		
		Test.startTest();
		
		System.assertEquals(true, DocumentBinController.verifyDocument(doc.Id));

		doc = [SELECT Id, Verified__c FROM Astrum_Doc__c WHERE Id = :doc.Id];
		System.assertEquals(true, doc.Verified__c);

		System.assertEquals(false, DocumentBinController.verifyDocument(doc.Id));

		doc = [SELECT Id, Verified__c FROM Astrum_Doc__c WHERE Id = :doc.Id];
		System.assertEquals(false, doc.Verified__c);
		
		Test.stopTest();
		
	}

	public static void createBinConfiguration() {
		
		Astrum_Application__c app = new Astrum_Application__c (
			Name = DocumentConfigurationHelper.APP_ASTRUM_PM_20
		);
		insert app;
		
		Bin_Configuration__c bin = new Bin_Configuration__c (
			Astrum_Application__c = app.Id,
			Bin__c = 'Grant Completion',
			Bin_Order__c = 304,
			Field_Name__c = 'Grant_Completion__c'
		);
		insert bin;
		
		List<Category_Configuration__c> categories = new List<Category_Configuration__c> {
			new Category_Configuration__c (
				Astrum_Application__c = app.Id,
				Bin__c = bin.Bin__c,
				Category__c = 'Prepared Application',
				Category_Order_In_Bin__c = 1,
				Minimum_Required__c = 1,
				Document_Bin_State__c = 'Ready to Sign',
				Field_Name__c = 'Grant_Completion_Completed__c'
			),
			new Category_Configuration__c (
				Astrum_Application__c = app.Id,
				Bin__c = bin.Bin__c,
				Category__c = 'Signed Application',
				Category_Order_In_Bin__c = 2,
				Minimum_Required__c = 1,
				Document_Bin_State__c = 'Signed',
				Field_Name__c = 'Grant_Completion_Signed__c'
			),
			new Category_Configuration__c (
				Astrum_Application__c = app.Id,
				Bin__c = bin.Bin__c,
				Category__c = 'Submitted Application',
				Category_Order_In_Bin__c = 3,
				Minimum_Required__c = 1,
				Document_Bin_State__c = 'Submitted',
				Field_Name__c = 'Grant_Completion_Submitted__c'
			),
			new Category_Configuration__c (
				Astrum_Application__c = app.Id,
				Bin__c = bin.Bin__c,
				Category__c = 'Application Approved',
				Category_Order_In_Bin__c = 4,
				Minimum_Required__c = 1,
				Document_Bin_State__c = 'Approved',
				Field_Name__c = 'Grant_Completion__c'
			)
		};
		insert categories;
		
	}
	
	public static void createPlaceHierarchy() {
		
		State__c state = new State__c (
			Name = 'Pennsylvania',
			FIPS_Code__c = '00',
			State_Abbreviation__c = 'PA'
		);
		insert state;
		
		County__c county = new County__c (
			Name = 'Test County, PA',
			FIPS_Code__c = '0000',
			State__c = state.Id
		);
		insert county;
		
		Municipality__c city = new Municipality__c (
			Name = 'Test City, PA',
			FIPS_Code__c = '000000',
			County__c = county.Id 
		);
		insert city;
		
	}
	
	public static void createTemplates() {
		
		State__c state = [SELECT Id FROM State__c LIMIT 1];
		County__c county = [SELECT Id FROM County__c LIMIT 1];
		Municipality__c city = [SELECT Id FROM Municipality__c LIMIT 1];
		
		String binName = 'Grant Completion';
		String category1 = 'Signed Application'; 
		String category2 = 'Submitted Application'; 
		
		Form_Design__c formDesign = new Form_Design__c (
			Name = 'Test Form Layout'
		);
		insert formDesign;
		
		List<Form_Submission_Document__c> docs = new List<Form_Submission_Document__c> {
			new Form_Submission_Document__c (
				Name = 'Additional Doc 1',
				Form_Design__c = formDesign.Id,
				Bin__c = binName,
				Category__c = category1
			),
			new Form_Submission_Document__c (
				Name = 'Additional Doc 2',
				Form_Design__c = formDesign.Id,
				Bin__c = binName,
				Category__c = category2
			)
		};
		insert docs;
		
		List<Form_Data_Element__c> formFields = new List<Form_Data_Element__c> {
			new Form_Data_Element__c (
				Name = 'Form Field 1',
				Form_Design__c = formDesign.Id,
				SalesForce_Field__c = 'Installation_Address__c',
				Required__c = true
			),
			new Form_Data_Element__c (
				Name = 'Form Field 2',
				Form_Design__c = formDesign.Id,
				SalesForce_Field__c = 'Installation_City__c'
			),
			new Form_Data_Element__c (
				Name = 'Form Field 3',
				Form_Design__c = formDesign.Id,
				SalesForce_Field__c = 'Installation_State__c'
			)
		};
		insert formFields;
		
		List<Astrum_Template__c> templates = new List<Astrum_Template__c> {
			new Astrum_Template__c (
				Name = 'City Template',
				Bin__c = binName,
				Category__c = category1,
				Municipality__c = city.Id  
			),
			new Astrum_Template__c (
				Name = 'County Template',
				Bin__c = binName,
				Category__c = category1,
				County__c = county.Id,
				Form_Design__c = formDesign.Id  
			),
			new Astrum_Template__c (
				Name = 'State Template',
				Bin__c = binName,
				Category__c = category2,
				State__c = state.Id  
			),
			new Astrum_Template__c (
				Name = 'State Lease Template',
				Bin__c = binName,
				Category__c = category2,
				State__c = state.Id,
				Financing_Type__c = 'Lease' 
			)
		};
		insert templates;
		
	}

}