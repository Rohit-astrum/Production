/* FILE: ProjectChronologyTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: June 12, 2012
 * PURPOSE: Test class for ProjectChronology component
 *          NOTE: document field tracking history cannot be covered in unit tests 
 * MODIFICATION HISTORY
 *
 */ 
 
@isTest
public class ProjectChronologyTest {

	static testMethod void projectWithDocs_docAdded_inHistory() {
		
		DocumentBinTest.createBinConfiguration();
		
		PM_Project__c project = new PM_Project__c ( Name = 'Test Project' );
		insert project;
		
		Astrum_Doc__c doc1 = new Astrum_Doc__c (
			PM_Project__c = project.Id,
			Bin__c = 'Grant Completion',
			Category__c = 'Prepared Application'			
		);
		insert doc1;
		
		Blob content = Blob.valueOf('TEST DOC');
		Attachment attach1 = new Attachment (
			ParentId = doc1.Id,
			Name = 'image.jpg',
			ContentType = 'image/jpg',
			Body = content
		);
		insert attach1;
		
		ProjectChronologyController controller = new ProjectChronologyController();
		controller.projectId = project.Id;
		
		System.assertEquals(project.Id, controller.projectId);
		
		Test.startTest();
		
		List<ProjectChronologyController.ChronologyItem> items = controller.items;
		
		Test.stopTest();
		
		Integer found = 0;
		for (ProjectChronologyController.ChronologyItem item : items) {
			if (item.icon == 'doc') {
				found++;
				System.assertEquals(doc1.Id, item.linkId);
				System.assertEquals(attach1.Id, item.attachId);
				System.assertEquals(attach1.ContentType, item.attachType);
				System.assertEquals(attach1.Name, item.documentName);
				System.assertEquals(doc1.Bin__c, item.eventBin);
				System.assert(item.eventType.startsWith(doc1.Category__c));
				System.assertEquals(System.today(), item.eventDate.date());
				System.assertEquals(UserInfo.getName(), item.eventUser);
			} else if (item.icon == 'new') {
				found++;
				System.assertEquals('Project Created', item.eventType);
				System.assertEquals(UserInfo.getName(), item.eventUser);
				System.assertEquals(System.today(), item.eventDate.date());
			}
		}
		
		System.assertEquals(2, found);
		
	}

	static testMethod void projectWithDocs_noteAdded_inHistory() {
		
		DocumentBinTest.createBinConfiguration();
		
		PM_Project__c project = new PM_Project__c ( Name = 'Test Project' );
		insert project;
		
		Astrum_Doc__c doc1 = new Astrum_Doc__c (
			PM_Project__c = project.Id,
			Bin__c = 'Grant Completion',
			Category__c = 'Signed Application'			
		);
		insert doc1;
		
		Note note1 = new Note (
			ParentId = doc1.Id,
			Title = 'Note',
			Body = 'Test Note'
		);
		insert note1;
		
		ProjectChronologyController controller = new ProjectChronologyController();
		controller.projectId = project.Id;
		
		Test.startTest();
		
		List<ProjectChronologyController.ChronologyItem> items = controller.items;
		
		Test.stopTest();
		
		Integer found = 0;
		for (ProjectChronologyController.ChronologyItem item : items) {
			if (item.icon == 'note') {
				found++;
				System.assertEquals(doc1.Bin__c, item.eventBin);
				System.assert(item.eventType.startsWith(doc1.Category__c));
				System.assertEquals(System.today(), item.eventDate.date());
				System.assertEquals(UserInfo.getName(), item.eventUser);
				System.assertEquals(note1.Body, item.description);
			}
		}
		
		System.assertEquals(1, found);
		
	}
	
	static testMethod void projectWithDoc_docIssue_inHistory() {
		
		DocumentBinTest.createBinConfiguration();
		
		PM_Project__c project = new PM_Project__c ( Name = 'Test Project' );
		insert project;
		
		Astrum_Doc__c doc = new Astrum_Doc__c (
			PM_Project__c = project.Id,
			Bin__c = 'Grant Completion',
			Category__c = 'Signed Application'			
		);
		insert doc;
		
		Blob content = Blob.valueOf('TEST DOC');
		Attachment attach = new Attachment (
			ParentId = doc.Id,
			Name = 'image.jpg',
			ContentType = 'image/jpg',
			Body = content
		);
		insert attach;
		
		PM_Project_Issue__c issue = new PM_Project_Issue__c (
			PM_Project__c = project.Id,
			Astrum_Doc__c = doc.Id,
			Bin__c = doc.Bin__c,
			Category__c = doc.Category__c,
			To__c = DocumentConfigurationHelper.APP_ASTRUM_PM_20,
			Description__c = 'Test Issue',
			Status__c = 'Open'
		);
		insert issue;
		
		Note n = new Note(
			ParentId = issue.Id,
			Title = 'Note',
			Body = 'Test Issue Note'
		);
		insert n;
		
		Test.startTest();

		ProjectChronologyController controller = new ProjectChronologyController();
		controller.projectId = project.Id;
		
		Test.stopTest();
		
		List<ProjectChronologyController.ChronologyItem> items = controller.items;
		
		
		Integer found = 0;
		for (ProjectChronologyController.ChronologyItem item : items) {
			if (item.icon == 'alert') { //issue
				found++;
				System.assertEquals(System.today(), item.eventDate.date());
				System.assertEquals(UserInfo.getName(), item.eventUser);
				System.assert(item.eventType.startsWith(issue.Category__c));
				System.assertEquals(issue.Description__c, item.description);
				System.assertEquals(doc.Id, item.linkId);
				System.assertEquals(doc.Bin__c, item.eventBin);
				System.assertEquals(attach.Name, item.documentName);
				System.assertEquals(attach.Id, item.attachId);
				System.assertEquals(attach.ContentType, item.attachType);
			}
			if (item.icon == 'issue') { //notes
				found++;
				System.assertEquals(System.today(), item.eventDate.date());
				System.assertEquals(UserInfo.getName(), item.eventUser);
				System.assert(item.eventType.startsWith(doc.Category__c));
				System.assertEquals(attach.Name, item.documentName);
				System.assertEquals(attach.Id, item.attachId);
				System.assertEquals(attach.ContentType, item.attachType);
				System.assertEquals(doc.Bin__c, item.eventBin);
				System.assertEquals(doc.Id, item.linkId);
			}
		}
		
		System.assertEquals(2, found);
		
	}

	static testMethod void projectWithDoc_setBinDates_inHistory() {

		DocumentBinTest.createBinConfiguration();
		
		String binName = 'Grant Completion';
		Date prepareDate = Date.newInstance(2012,5,1);
		Date signDate = Date.newInstance(2012,5,3);
		Date submitDate = Date.newInstance(2012,5,5);
		Date completeDate = Date.newInstance(2012,6,14);
		
		PM_Project__c project = new PM_Project__c ( 
			Name = 'Test Project', 
			Grant_Completion_Completed__c = prepareDate,
			Grant_Completion_Signed__c = signDate,
			Grant_Completion_Submitted__c = submitDate,
			Grant_Completion__c = completeDate
		);
		insert project;
		

		List<String> filters = new List<String> { 'states:All' };	

		Test.startTest();

		ProjectChronologyController controller = new ProjectChronologyController();
		controller.projectId = project.Id;
		
		Test.stopTest();
		
		List<ProjectChronologyController.ChronologyItem> items = controller.items;
		
		
		Set<String> states = new Set<String> {
			'Ready to Sign', 'Signed', 'Submitted'
		};
		Integer found = 0;
		for (ProjectChronologyController.ChronologyItem item : items) {
			if (item.icon == 'done') { //bin complete
				found++;
				System.assertEquals(completeDate, item.eventDate.date());
				System.assert(item.eventType.startsWith(binName));
				System.assertEquals(binName, item.eventBin);
			}
			if (item.icon == 'state') { //interim states
				String binState = item.eventType.replace(binName + ' ', ''); 
				if (states.contains(binState)) {
					found++;
					states.remove(binState);
				}
				if (binState == 'Ready to Sign') {
					System.assertEquals(prepareDate, item.eventDate.date());
				} else if (binState == 'Signed') {
					System.assertEquals(signDate, item.eventDate.date());
				} else if (binState == 'Submitted') {
					System.assertEquals(submitDate, item.eventDate.date());
				}
				System.assert(item.eventType.startsWith(binName));
				System.assertEquals(binName, item.eventBin);
			}
		}
		
		System.assertEquals(4, found);
		
	}	

	static testMethod void projectWithDoc_setProjectDates_inHistory() {

		DocumentBinTest.createBinConfiguration();
		
		Datetime kickoff = DateTime.newInstance(2012,5,5,12,0,0);
		Date install = kickoff.date().addDays(90);
		Datetime inspection = DateTime.newInstance(2012,5,5,11,30,0);
		Date handoff = install.addDays(30);

		PM_Project__c project = new PM_Project__c ( 
			Name = 'Test Project',
			Kickoff__c = kickoff,
			Install__c = install,
			Inspection__c = inspection,
			Customer_Care_Handoff__c = handoff
		);			
		insert project;
		
		List<String> filters = new List<String> { 'states:All' };	

		Test.startTest();

		ProjectChronologyController controller = new ProjectChronologyController();
		controller.projectId = project.Id;
		
		Test.stopTest();
		
		List<ProjectChronologyController.ChronologyItem> items = controller.items;
		
		
		Set<String> descriptions = new Set<String> {
			'Kickoff Date', 'Install Date', 'Inspection Date', 'Customer Care Handoff Date'
		};
		Integer found = 0;
		for (ProjectChronologyController.ChronologyItem item : items) {
			if (item.eventBin == 'Project') { //project date
				String description = item.eventType; 
				if (descriptions.contains(description)) {
					found++;
					descriptions.remove(description);
				}
				if (description == 'Kickoff Date') {
					System.assertEquals(kickoff, item.eventDate);
					System.assertEquals('kickoff', item.icon);
				} else if (description == 'Install Date') {
					System.assertEquals(install, item.eventDate.date());
					System.assertEquals('install', item.icon);
				} else if (description == 'Inspection Date') {
					System.assertEquals(inspection, item.eventDate);
					System.assertEquals('inspect', item.icon);
				} else if (description == 'Customer Care Handoff Date') {
					System.assertEquals(handoff, item.eventDate.date());
					System.assertEquals('handoff', item.icon);
				}
			}
		}
		
		System.assertEquals(4, found);
		
	}	
	
}