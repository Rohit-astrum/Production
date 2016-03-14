/* FILE: SnapshotsController.cls
 * AUTHOR: Tino Mattheou
 * DATE: August 22, 2012
 * PURPOSE: controller for Snapshots page
 * MODIFICATION HISTORY
 *
 */
 
public class SnapshotsController {

	public String snapshotDate { get; set; }
	
	public List<SnapshotData> snapshots { get; private set; }
	
	public SnapshotsController() {
		loadSnapshots();
	}

	private void loadSnapshots() {
		
		snapshots = new List<SnapshotData>();
		
		Date lastSnapshot = Date.today().toStartOfWeek();
		Date firstSnapshot = lastSnapshot.addDays(-63); //10 weeks
		Map<Date, SnapshotData> snapshotMap = new Map<Date, SnapshotData>();
		
		for (Date d = lastSnapshot; d >= firstSnapshot; d = d.addDays(-7)) {
			SnapshotData sd = new SnapshotData();
			sd.saleEnd = d;
			sd.saleEndDate = d.format();
			snapshots.add(sd);
			snapshotMap.put(d, sd);
		}
		
		List<Sales_Snapshot__c> snaps = 
			[SELECT Id, Sales_End__c, LastModifiedDate, LastModifiedBy.Name
			FROM Sales_Snapshot__c
			WHERE Sales_End__c >= :firstSnapshot
			AND Sales_End__c <= :lastSnapshot
			ORDER BY LastModifiedDate];
			
		for (Sales_Snapshot__c snap : snaps) {
			SnapshotData sd = snapshotMap.get(snap.Sales_End__c);
			if (sd != null) {
				sd.lastModified = snap.LastModifiedDate.format('M/d/yyyy h:mma');
				sd.lastModifiedBy = snap.LastModifiedBy.Name;
			}
		}
		
	}
	
	public PageReference takeSnapshot() {
		if (snapshotDate != null) {
			Date dt = Date.parse(snapshotDate);
			SalesRegionHelper.take12WeekSnapShot(dt, null);
			loadSnapshots();
		}
		snapshotDate = null;
		return null;
	}

	public class SnapshotData {
		public Date saleEnd { get; set; }
		public String saleEndDate { get; set; }
		public String lastModified { get; set; }
		public String lastModifiedBy { get; set; }
	}

}