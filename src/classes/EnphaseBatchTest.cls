/* FILE: EnphaseBatchTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: October 25, 2012
 * PURPOSE: Test class for EnphaseBatchController
 * MODIFICATION HISTORY:
 *
 */

@isTest
public class EnphaseBatchTest {

	static testMethod void runBatch() {
		
		Account customer = new Account ( Name = 'Test Customer' );
		insert customer;
		
		Installed_System__c sys = new Installed_System__c (
			Account__c = customer.Id,
			Enphase_ID__c = '12345'
		);
		insert sys;
		
		Test.startTest();
		
		Test.setCurrentPage(Page.EnphaseBatch);
		EnphaseBatchController controller = new EnphaseBatchController();

		System.assertNotEquals(true, controller.completed);		
		System.assertNotEquals(true, controller.paused);
		System.assertEquals(null, controller.startTime);	
		System.assertEquals(null, controller.completeTime);	
		System.assertEquals(1, controller.total);	
		System.assertEquals(0, controller.processed);	
		System.assertEquals(0, controller.errors);	
		
		List<EnphaseBatchController.ProcessStatus> systems = controller.statuses;
		System.assertEquals(1, systems.size());

		controller.pause();
		System.assertEquals(true, controller.paused);		

		controller.resume();
		System.assertNotEquals(true, controller.paused);
		
		controller.updateState();
		System.assertEquals(true, controller.completed);		
		System.assertNotEquals(true, controller.paused);
		System.assertNotEquals(null, controller.startTime);	
		System.assertNotEquals(null, controller.completeTime);	
		System.assertEquals(1, controller.total);	
		System.assertEquals(1, controller.processed);
		System.assertEquals(1, controller.errors);
		System.assertEquals('No Production Data', controller.statuses[0].status);	
		
		Test.stopTest();
		
	}

	static testMethod void runAlertsBatch() {
		
		Account customer = new Account ( Name = 'Test Customer' );
		insert customer;
		
		Installed_System__c sys = new Installed_System__c (
			Account__c = customer.Id,
			Enphase_ID__c = '12345'
		);
		insert sys;
		
		Test.startTest();
		
		Test.setCurrentPage(Page.EnphaseBatch);
		EnphaseAlertsBatchController controller = new EnphaseAlertsBatchController();

		System.assertNotEquals(true, controller.completed);		
		System.assertNotEquals(true, controller.paused);
		System.assertEquals(null, controller.startTime);	
		System.assertEquals(null, controller.completeTime);	
		System.assertEquals(1, controller.total);	
		System.assertEquals(0, controller.processed);	
		System.assertEquals(0, controller.errors);	
		
		List<EnphaseAlertsBatchController.ProcessStatus> systems = controller.statuses;
		System.assertEquals(1, systems.size());

		controller.pause();
		System.assertEquals(true, controller.paused);		

		controller.resume();
		System.assertNotEquals(true, controller.paused);
		
		controller.updateState();
		System.assertEquals(true, controller.completed);		
		System.assertNotEquals(true, controller.paused);
		System.assertNotEquals(null, controller.startTime);	
		System.assertNotEquals(null, controller.completeTime);	
		System.assertEquals(1, controller.total);	
		System.assertEquals(1, controller.processed);
		System.assertEquals(0, controller.errors);
		System.assertEquals('Success', controller.statuses[0].status);	
		
		Test.stopTest();
		
	}
}