/* FILE: SnapshotsTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: August 24, 2012
 * PURPOSE: Test class for Snapshots page and SnapshotsController
 * MODIFICATION HISTORY
 *
 */

@isTest
public class SnapshotsTest {

	static testMethod void snapshots_loadPage_3Weeks() {
		
		Sales_Snapshot__c[] snapshots = new Sales_Snapshot__c[] {
			new Sales_Snapshot__c(
				Sales_End__c = Date.today().toStartOfWeek(),
				Lead_End__c = Date.today().toStartOfWeek().addDays(-4),
				Sales_This_Week__c = 10,
				Sales_Last_12_Weeks__c = 100,
				Leads_Last_12_weeks__c = 600,
				Sales_Region__c = 'A'
			),
			new Sales_Snapshot__c(
				Sales_End__c = Date.today().toStartOfWeek(),
				Lead_End__c = Date.today().toStartOfWeek().addDays(-4),
				Sales_This_Week__c = 15,
				Sales_Last_12_Weeks__c = 50,
				Leads_Last_12_weeks__c = 400,
				Sales_Region__c = 'B'
			),
			new Sales_Snapshot__c(
				Sales_End__c = Date.today().toStartOfWeek().addDays(-7),
				Lead_End__c = Date.today().toStartOfWeek().addDays(-11),
				Sales_This_Week__c = 23,
				Sales_Last_12_Weeks__c = 120,
				Leads_Last_12_weeks__c = 1000
			),
			new Sales_Snapshot__c(
				Sales_End__c = Date.today().toStartOfWeek().addDays(-14),
				Lead_End__c = Date.today().toStartOfWeek().addDays(-18),
				Sales_This_Week__c = 15,
				Sales_Last_12_Weeks__c = 130,
				Leads_Last_12_weeks__c = 1000
			)
		};
		insert snapshots;
		
		Test.startTest();
		
		Test.setCurrentPage(Page.Snapshots);
		SnapshotsController controller = new SnapshotsController();
		
		List<SnapshotsController.SnapshotData> result = controller.snapshots;

		System.assertEquals(10, result.size());

		//recent three weeks have data
		for (Integer i = 0; i < 3; i++) {		
			System.assertNotEquals(null, result[i].lastModified);
		}
		
		//recent previous sevent weeks don't have data
		for (Integer i = 3; i < 10; i++) {
			System.assertEquals(null, result[i].lastModified);
		}
		
		Date lastWeek = Date.today().toStartOfWeek().addDays(-7);
		controller.snapshotDate = lastWeek.format();
		
		System.assertEquals(null, controller.takeSnapshot());
		
		Sales_Snapshot__c snap = 
			[SELECT Id, Sales_This_Week__c, Sales_Last_12_Weeks__c, Leads_Last_12_Weeks__c
			FROM Sales_Snapshot__c
			WHERE Sales_End__c = :lastWeek];
			
		System.assertEquals(0, snap.Sales_This_Week__c);
		System.assertEquals(0, snap.Sales_Last_12_Weeks__c);
		System.assertEquals(0, snap.Leads_Last_12_Weeks__c);

		Test.stopTest();
		
	}

}