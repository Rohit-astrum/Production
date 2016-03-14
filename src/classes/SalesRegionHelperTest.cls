/* FILE: SalesRegionHelperTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: August 16, 2012
 * PURPOSE: Test class for SalesRegionHelper class
 * MODIFICATION HISTORY
 *		08/31/15  DK  Removed seeAllData=true and expanded leadsOppsSales_takeSnapshot_taken()
 */
 
@isTest(seeAllData=false)
public class SalesRegionHelperTest {

	static testMethod void testStateRemoval() {
		
		System.assertEquals('Putnam', SalesRegionHelper.removeState('Putnam W VA'));
		System.assertEquals('Monmouth', SalesRegionHelper.removeState('Monmouth NJ'));
		System.assertEquals('Van Buren', SalesRegionHelper.removeState('Van Buren (MI)'));
		System.assertEquals('Queen Annes', SalesRegionHelper.removeState('Queen Anne\'s MD'));
		System.assertEquals('New York', SalesRegionHelper.removeState('New York'));
		
	}
	
	static testMethod void leadsOppsSales_takeSnapshot_taken() {
		Test.startTest();
		Account acct = new Account(Name = 'TestAcct');
        insert acct;

		Opportunity opp = new Opportunity(AccountID = acct.ID, Name = 'Test Opportunity', StageName = 'Submit Pending', CloseDate = Date.today().addDays(-7), Sales_Region__c = 'PA Region');
		Opportunity_Trigger_Utility.skipOpportunityTrigger = true;
		insert opp;
		Opportunity_Trigger_Utility.skipOpportunityTrigger = false;

		State__c state = new State__c(Name = 'Pennsylvania', FIPS_Code__c = '00', State_Abbreviation__c = 'PA');
        insert state;
        
        County__c county1 = new County__c(Name = 'Test1 County, PA', FIPS_Code__c = '00000', State__c = state.ID, Sales_Region__c = 'PA Region');
        insert county1;

        Lead lead1 = new Lead(LastName = 'Test1', Company = 'Testco1', County__c = 'Test1 County', Street = 'Test', State = 'PA');
        insert lead1;

        Lead_Sales_Region__c lsr1 = new Lead_Sales_Region__c(Sales_Region__c = county1.Sales_Region__c, Lead_ID_Unique__c = lead1.ID, Lead_Created_Date__c = Date.today());
        Database.insert(lsr1, Lead_Sales_Region__c.Lead_ID_Unique__c);

        Test.stopTest();

		Sales_Snapshot__c snap1 = new Sales_Snapshot__c (
				Sales_End__c = Date.today().addDays(-7), //Date.today().toStartOfWeek(),
				Lead_End__c = Date.today().toStartOfWeek().addDays(-4),
				Sales_This_Week__c = 10,
				Sales_Last_12_Weeks__c = 100,
				Leads_Last_12_weeks__c = 600,
				Sales_Region__c = 'Unknown'
		);
		insert snap1;
		
		SalesRegionHelper.take12WeekSnapShot(Date.today().addDays(-7), Date.today());
	}
}