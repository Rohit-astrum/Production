/* FILE: SalesRegionHelper.cls
 * AUTHOR: Tino Mattheou
 * DATE: August 15, 2012
 * PURPOSE: helper utilities for Sales Region processing
 * MODIFICATION HISTORY
 *
 */
public class SalesRegionHelper {
	
	//prevents opportunity trigger from synching from property during an update
	public static Boolean propertyOpportunityTriggerFiring = false;
	
	//prevents sales region triggers from working
	public static Boolean bypassSalesRegionTriggers = false;
	
	//allows an update to force sales region triggers to update the sales region 
	//based on configuration changes
	public static Boolean reprocessSalesRegions = false;

	//remove state from county picklist value and remove apostrophes
	public static String removeState(String county) {
		if (county != null && county.length() > 5 && county.lastIndexOf(' W VA') == county.length() - 5) { // e.g., Putnam W VA
			return county.substring(0, county.length() - 5).replace('\'', '');
		} else if (county != null && county.length() > 3 && county.lastIndexOf(' ') == county.length() - 3) { // e.g., Monmouth NJ
			return county.substring(0, county.length() - 3).replace('\'', '');
		} else if (county != null && county.length() > 5 && county.lastIndexOf('(') == county.length() - 4) { // e.g., Van Buren (MI)
			return county.substring(0, county.length() - 5).replace('\'', '');
		} 
		return county;
	}

	public static void take12WeekSnapShot(Date salesEnd, Date leadEnd) {

		if (salesEnd == null) {
			salesEnd = Date.today().toStartOfWeek(); //sunday date
		}
		
		if (leadEnd == null) {
			leadEnd = salesEnd.addDays(-4); //wednesday of prior week
		}

		//get any existing records to update		
		List<Sales_Snapshot__c> snapshots = 
			[SELECT Id, Lead_End__c, Leads_Last_12_Weeks__c, Sales_End__c, Sales_Last_12_Weeks__c, Sales_Region__c, Sales_This_Week__c
			FROM Sales_Snapshot__c
			WHERE Sales_End__c = :salesEnd
			FOR UPDATE];
		
		//create a map of records
		Map<String, Sales_Snapshot__c> snapshotMap = new Map<String, Sales_Snapshot__c>();
		for (Sales_Snapshot__c snapshot : snapshots) {
			snapshot.Leads_Last_12_Weeks__c = 0;
			snapshot.Sales_Last_12_Weeks__c = 0;
			snapshot.Sales_This_Week__c = 0;
			snapshot.Opportunities_Last_12_Weeks__c = 0;
			snapshotMap.put(snapshot.Sales_Region__c, snapshot);
		}
		
		//calculate date ranges
		Date salesStart = salesEnd.addDays(-84);
		Date leadStart = leadEnd.addDays(-84);
		
//System.debug('sales - ' + salesStart + ' thru ' + salesEnd);
//System.debug('leads - ' + leadStart + ' thru ' + leadEnd);

		//get total opps - last 12 weeks		
		List<AggregateResult> opps = 
			[SELECT Sales_Region__c region, count(Id) total
			FROM Opportunity
			WHERE DAY_ONLY(CreatedDate) > :leadStart
			AND DAY_ONLY(CreatedDate) <= :leadEnd
			GROUP BY Sales_Region__c];
		
		for (AggregateResult opp : opps) {
			String salesRegion = (String)opp.get('region');
			if (salesRegion == null) {
				salesRegion = 'Unknown';
			}
			Sales_Snapshot__c snapshot = snapshotMap.get(salesRegion);
			if (snapshot == null) {
				snapshot = newSnapshot(salesRegion, leadEnd, salesEnd);
				snapshotMap.put(salesRegion, snapshot);
			}
			snapshot.Sales_End__c = salesEnd;
			snapshot.Opportunities_Last_12_Weeks__c = (Decimal)opp.get('total');
		} 

		//get sale counts - last 12 weeks		
		List<AggregateResult> sales = 
			[SELECT Sales_Region__c region, count(Id) total
			FROM Opportunity
			WHERE CloseDate <> NULL 
			AND CloseDate > :salesStart
			AND CloseDate <= :salesEnd
			AND StageName IN ('Closed - Won', 'Contract Cancelled')
			GROUP BY Sales_Region__c];
		
		for (AggregateResult sale : sales) {
			String salesRegion = (String)sale.get('region');
			if (salesRegion == null) {
				salesRegion = 'Unknown';
			}
			Sales_Snapshot__c snapshot = snapshotMap.get(salesRegion);
			if (snapshot == null) {
				snapshot = newSnapshot(salesRegion, leadEnd, salesEnd);
				snapshotMap.put(salesRegion, snapshot);
			}
			snapshot.Sales_End__c = salesEnd;
			snapshot.Sales_Last_12_Weeks__c = (Decimal)sale.get('total');
		} 

		//get sale counts - last week		
		sales = 
			[SELECT Sales_Region__c region, count(Id) total
			FROM Opportunity
			WHERE CloseDate <> NULL 
			AND CloseDate > :salesEnd.addDays(-7)
			AND CloseDate <= :salesEnd
			AND StageName IN ('Closed - Won', 'Contract Cancelled')
			GROUP BY Sales_Region__c];
		
		for (AggregateResult sale : sales) {
			String salesRegion = (String)sale.get('region');
			if (salesRegion == null) {
				salesRegion = 'Unknown';
			}
			Sales_Snapshot__c snapshot = snapshotMap.get(salesRegion);
			if (snapshot == null) {
				snapshot = newSnapshot(salesRegion, leadEnd, salesEnd);
				snapshotMap.put(salesRegion, snapshot);
			}
			snapshot.Sales_End__c = salesEnd;
			snapshot.Sales_This_Week__c = (Decimal)sale.get('total');
		} 
		
		//get lead counts		
		List<AggregateResult> leads = 
			[SELECT Sales_Region__c region, count(Id) total
			FROM Lead_Sales_Region__c
			WHERE Lead_Created_Date__c > :leadStart
			AND Lead_Created_Date__c <= :leadEnd
			GROUP BY Sales_Region__c];
		
		for (AggregateResult lead : leads) {
			String salesRegion = (String)lead.get('region');
			if (salesRegion == null) {
				salesRegion = 'Unknown';
			}
			Sales_Snapshot__c snapshot = snapshotMap.get(salesRegion);
			if (snapshot == null) {
				snapshot = newSnapshot(salesRegion, leadEnd, salesEnd);
				snapshotMap.put(salesRegion, snapshot);
			}
			snapshot.Lead_End__c = leadEnd;
			snapshot.Leads_Last_12_Weeks__c = (Decimal)lead.get('total');
		}
		
		upsert snapshotMap.values(); 
		
	}
	
	private static Sales_Snapshot__c newSnapshot(String salesRegion, Date leadEnd, Date salesEnd) {
		return new Sales_Snapshot__c (
			Sales_Region__c = salesRegion,
			Lead_End__c = leadEnd,
			Leads_Last_12_Weeks__c = 0,
			Sales_End__c = salesEnd,
			Sales_Last_12_Weeks__c = 0,
			Sales_This_Week__c = 0
		);
	}

}