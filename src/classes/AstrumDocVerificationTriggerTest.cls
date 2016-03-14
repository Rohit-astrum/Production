/* FILE: AstrumDocVerificationTriggerTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: December 11, 2012
 * PURPOSE: Test classs for AstrumDocVerification trigger
 *  
 */

@isTest
public class AstrumDocVerificationTriggerTest {

	static testMethod void verifiedDoc_modifyKeyDate_ErrorRaised() {
		
		PM_Project__c project = new PM_Project__c();
		insert project;
		
		Astrum_Doc__c doc = new Astrum_Doc__c (
			PM_Project__c = project.Id,
			Bin__c = 'Test Bin',
			Category__c = 'Test Category',
			Verified__c = true
		);
		insert doc;
		
		doc.Bin__c = 'Test Bin 2';
		
		Test.startTest();
		
		try {
			update doc;
			System.assert(false, 'Error not thrown');
		} catch (DmlException e) {
			System.assert(e.getMessage().contains('You cannot modify a verified document.'));			
		}
		
		Test.stopTest();
		
	}

	static testMethod void inspectionDoc_verify_inspectionVerifiedSet() {
		
		PM_Project__c project = new PM_Project__c();
		insert project;
		
		Date keyDate = System.today();
		Astrum_Doc__c doc = new Astrum_Doc__c (
			PM_Project__c = project.Id,
			Bin__c = 'Proof of Inspection',
			Category__c = 'Proof of Inspection',
			Document_Key_Date__c = keyDate
		);
		insert doc;
		
		Test.startTest();
		
		doc.Verified__c = true;
		update doc;

		project = [SELECT Id, Inspection_Verified__c FROM PM_Project__c WHERE Id = :project.Id];
		System.assertEquals(keyDate, project.Inspection_Verified__c);
		
		Test.stopTest();
		
	}

}