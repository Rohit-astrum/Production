/*  FILE: SalesLeaderboardChartsTest
    AUTHOR: Dan Kelner
    DATE: 05/01/15
    PURPOSE: Test class for all the sales reports classes
    MODIFICATION HISTORY
*/
@isTest(seeAllData = false)
public class SalesLeaderboardChartsTest {

	private static void setUpTestData(){
		SCRB_SalesOrder__c[] salesOrders = new SCRB_SalesOrder__c[]{};
		for (Integer i = 1; i <= 12; i++){
			if (Math.mod(i, 2) == 0)
				salesOrders.add(new SCRB_SalesOrder__c(Name = 'Test Sales Order ' + i, Time_Original_Submit_Sales_Rep__c = System.now(), StatusCode__c = 'Submitted', 
													   Sales_Region__c = 'CA Region', Amount__c = 50, Owner_User__c = UserInfo.getUserId()));
			else
				salesOrders.add(new SCRB_SalesOrder__c(Name = 'Test Sales Order ' + 1, Time_Original_Submit_Sales_Rep__c = System.now(), StatusCode__c = 'Canceled', 
													   Sales_Region__c = 'MD Region', Amount__c = 50, Owner_User__c = UserInfo.getUserId()));
		}
		insert salesOrders;

		State__c[] states = new State__c[]{new State__c(Name = 'California', State_Abbreviation__c = 'CA', FIPS_Code__c = '06'), 
										   new State__c(Name = 'Maryland', State_Abbreviation__c = 'MD', FIPS_Code__c = '24')};
		insert states;

		Pricing_Region__c[] pricingRegions = new Pricing_Region__c[]{new Pricing_Region__c(Name = 'Maryland'), new Pricing_Region__c(Name = 'California')};
		insert pricingRegions;

		County__c[] counties = new County__c[]{new County__c(Name = 'Test County 1', State__c = states[0].ID, Pricing_Region__c = pricingRegions[0].ID, FIPS_Code__c = '0000'), 
											   new County__c(Name = 'Test County 2', State__c = states[1].ID, Pricing_Region__c = pricingRegions[1].ID, FIPS_Code__c = '0001')};
		insert counties;

		County_Schedule_Availability__c[] csaList = new County_Schedule_Availability__c[]{};
		csaList.add(new County_Schedule_Availability__c(County__c = counties[0].ID, Employee__c = UserInfo.getUserId()));
		csaList.add(new County_Schedule_Availability__c(County__c = counties[1].ID, Employee__c = UserInfo.getUserId()));
		insert csaList;

		Account acct = new Account(Name = 'Test Account');
		insert acct;

		Opportunity[] opps = new Opportunity[]{};
		opps.add(new Opportunity(Name = 'Test Opp 1', AccountID = acct.ID, CloseDate = Date.today().addDays(-1), StageName = 'Cancel Pending', Sales_Region__c = 'MD Region'));
		opps.add(new Opportunity(Name = 'Test Opp 2', AccountID = acct.ID, CloseDate = Date.today().addDays(-1), StageName = 'Cancel Pending', Sales_Region__c = 'CA Region'));
		Opportunity_Trigger_Utility.skipOpportunityTrigger = true;
		insert opps;
		Opportunity_Trigger_Utility.skipOpportunityTrigger = false;
	}

	public testmethod static void testMonthlyOppCloseByRegion(){
		setUpTestData();

		Test.startTest();

		MonthlyOppCloseByRegionController ctrl1 = new MonthlyOppCloseByRegionController();
		ctrl1.getRevenueData();
		ctrl1.getMonthPicklist();
		ctrl1.getYearOptions();

		MonthlyOppCloseLeaderboardController ctrl2 = new MonthlyOppCloseLeaderboardController();
		ctrl2.getRevenueData();
		ctrl2.getMonthPicklist();
		ctrl2.getYearOptions();

		MonthlyRevenueLeaderboardsController ctrl3 = new MonthlyRevenueLeaderboardsController();
		ctrl3.getRevenueData();
		ctrl3.getMonthPicklist();
		ctrl3.getYearOptions();

		YTD_OppClosesByRegionController ctrl4 = new YTD_OppClosesByRegionController();
		ctrl4.getYearOptions();

		YTD_OppClosesLeaderboardController ctrl5 = new YTD_OppClosesLeaderboardController();
		ctrl5.getYearOptions();

		YTD_RevenueByRegionController ctrl6 = new YTD_RevenueByRegionController();
		ctrl6.getYearOptions();

		YTD_RevenueLeaderboardController ctrl7 = new YTD_RevenueLeaderboardController();
		ctrl7.getYearOptions();

		Trailing12WeekOppClosedController ctrl8 = new Trailing12WeekOppClosedController();

		Trailing12WeekOppClosedRegionController ctrl9 = new Trailing12WeekOppClosedRegionController();
		Test.StopTest();
	}
}