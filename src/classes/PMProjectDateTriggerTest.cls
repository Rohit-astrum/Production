/* FILE: PMProjectDateTriggerTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: June 9, 2012
 * PURPOSE: Test class for PMProjectDateTrigger  
 * MODIFICATION HISTORY
 *
 */ 
 
@isTest
public class PMProjectDateTriggerTest {

	static testMethod void noKickoff_setKickoff_TimeUpdated() {

		PM_Project__c project = createProject('Test Project');
		
		//make sure dates are null
		project = [SELECT Id, Kickoff__c, Kickoff_Last_Updated__c FROM PM_Project__c WHERE Id = :project.Id];
		System.assertEquals(null, project.Kickoff__c);
		System.assertEquals(null, project.Kickoff_Last_Updated__c);
		
		Test.startTest();

		//update the kickoff date	
		Datetime startTime = System.now();
		Datetime expected = System.now().addDays(7);
		project.Kickoff__c = expected;
		update project;

		project = [SELECT Id, Kickoff__c, Kickoff_Last_Updated__c, 
			Install_Last_Updated__c, Inspection_Last_Updated__c
			FROM PM_Project__c WHERE Id = :project.Id];
		System.assertEquals(expected, project.Kickoff__c);
		//looks like triggers rounds DateTime.now(), so just comparing date 
		System.assert(project.Kickoff_Last_Updated__c.date() == startTime.date());
		System.assertEquals(null, project.Install_Last_Updated__c);
		System.assertEquals(null, project.Inspection_Last_Updated__c);
		
		Test.stopTest();
	}
	
	static testMethod void noInstall_setInstall_TimeUpdated() {

		PM_Project__c project = createProject('Test Project');
		
		//make sure dates are null
		project = [SELECT Id, Install__c, Install_Last_Updated__c FROM PM_Project__c WHERE Id = :project.Id];
		System.assertEquals(null, project.Install__c);
		System.assertEquals(null, project.Install_Last_Updated__c);
		
		Test.startTest();

		//update the install date		
		Datetime startTime = System.now();
		Date expected = System.today().addDays(90);
		project.Install__c = expected;
		update project;

		project = [SELECT Id, Install__c, Kickoff_Last_Updated__c, 
			Install_Last_Updated__c, Inspection_Last_Updated__c
			FROM PM_Project__c WHERE Id = :project.Id];
		System.assertEquals(expected, project.Install__c);
		//looks like triggers rounds DateTime.now(), so just comparing date 
		System.assert(project.Install_Last_Updated__c.date() == startTime.date());
		System.assertEquals(null, project.Kickoff_Last_Updated__c);
		System.assertEquals(null, project.Inspection_Last_Updated__c);
		
		Test.stopTest();
	}

	static testMethod void noInspection_setInspection_TimeUpdated() {

		PM_Project__c project = createProject('Test Project');
		
		//make sure dates are null
		project = [SELECT Id, Inspection__c, Inspection_Last_Updated__c FROM PM_Project__c WHERE Id = :project.Id];
		System.assertEquals(null, project.Inspection__c);
		System.assertEquals(null, project.Inspection_Last_Updated__c);
		
		Test.startTest();

		//update the inspection date		
		Datetime startTime = System.now();
		Datetime expected = System.now().addDays(7);
		project.Inspection__c = expected;
		update project;

		project = [SELECT Id, Inspection__c, Kickoff_Last_Updated__c, 
			Install_Last_Updated__c, Inspection_Last_Updated__c
			FROM PM_Project__c WHERE Id = :project.Id];
		System.assertEquals(expected, project.Inspection__c);
		//looks like triggers rounds DateTime.now(), so just comparing date 
		System.assert(project.Inspection_Last_Updated__c.date() == startTime.date());
		System.assertEquals(null, project.Kickoff_Last_Updated__c);
		System.assertEquals(null, project.Install_Last_Updated__c);
		
		Test.stopTest();
	}
	
	static testMethod void datesSet_clearAllDates_TimesUpdated() {

		Datetime startTime = System.now();
		Datetime expectedKickoff = System.now().addDays(7);
		Date expectedInstall = System.today().addDays(90);
		Datetime expectedInspection = System.now().addDays(95);
		
		PM_Project__c project = new PM_Project__c (
			Name = 'Test Project',
			Kickoff__c = expectedKickoff,
			Install__c = expectedInstall,
			Inspection__c = expectedInspection 
		);
		
		Test.startTest();
		
		insert project;
		
		//make sure dates are set on insert
		project = [SELECT Id,
			Kickoff__c, Kickoff_Last_Updated__c,
			Install__c, Install_Last_Updated__c, 
			Inspection__c, Inspection_Last_Updated__c 
			FROM PM_Project__c WHERE Id = :project.Id];
		System.assertEquals(expectedKickoff, project.Kickoff__c);
		System.assertEquals(expectedInstall, project.Install__c);
		System.assertEquals(expectedInspection, project.Inspection__c);
		System.assert(project.Kickoff_Last_Updated__c.date() == startTime.date());
		System.assert(project.Install_Last_Updated__c.date() == startTime.date());
		System.assert(project.Inspection_Last_Updated__c.date() == startTime.date());
		
		//back the last updated dates up
		project.Kickoff_Last_Updated__c = project.Kickoff_Last_Updated__c.addDays(-5);
		project.Install_Last_Updated__c = project.Install_Last_Updated__c.addDays(-10);
		project.Inspection_Last_Updated__c = project.Inspection_Last_Updated__c.addDays(-15);
		update project;

		//make sure dates 
		project = [SELECT Id,
			Kickoff__c, Kickoff_Last_Updated__c,
			Install__c, Install_Last_Updated__c, 
			Inspection__c, Inspection_Last_Updated__c 
			FROM PM_Project__c WHERE Id = :project.Id];
		System.assertEquals(expectedKickoff, project.Kickoff__c);
		System.assertEquals(expectedInstall, project.Install__c);
		System.assertEquals(expectedInspection, project.Inspection__c);
		System.assert(project.Kickoff_Last_Updated__c.date() != startTime.date());
		System.assert(project.Install_Last_Updated__c.date() != startTime.date());
		System.assert(project.Inspection_Last_Updated__c.date() != startTime.date());

		//clear the dates
		project.Kickoff__c = null;
		project.Install__c = null;
		project.Inspection__c = null;
		update project;

		project = [SELECT Id,
			Kickoff__c, Kickoff_Last_Updated__c,
			Install__c, Install_Last_Updated__c, 
			Inspection__c, Inspection_Last_Updated__c 
			FROM PM_Project__c WHERE Id = :project.Id];
		System.assertEquals(null, project.Kickoff__c);
		System.assertEquals(null, project.Install__c);
		System.assertEquals(null, project.Inspection__c);
		System.assert(project.Kickoff_Last_Updated__c.date() == startTime.date());
		System.assert(project.Install_Last_Updated__c.date() == startTime.date());
		System.assert(project.Inspection_Last_Updated__c.date() == startTime.date());
		
		Test.stopTest();
	}
	
	public static PM_Project__c createProject(String name) {
		PM_Project__c project = new PM_Project__c (
			Name = name
		);
		insert project;
		return project;
	}

}