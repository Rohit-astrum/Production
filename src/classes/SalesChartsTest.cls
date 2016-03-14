/*  FILE: SalesChartsTest.cls
    AUTHOR: Dan Kelner
    DATE: 11/05/2014
    PURPOSE: Test class for YTD_RevenueLeaderboardController, YTD_RevenueByRegionController, MonthlyRevenueLeaderboardsController, MonthlyRevenueByRegionController, 
             YTD_OppClosesLeaderboardController, YTD_OppClosesByRegionController, MonthlyOppCloseLeaderboardController, MonthlyOppCloseByRegionController, 
             Trailing12WeekOppClosedController, and Trailing12WeekOppClosedRegionController
    MODIFICATION HISTORY
*/
@isTest (seeAllData = true)
public class SalesChartsTest {
    
    public static testmethod void YTD_RevenueLeaderboardController_Test(){
        YTD_RevenueLeaderboardController con = new YTD_RevenueLeaderboardController();
        System.assert(con.revenueData.size() != null);
    }
    
    public static testmethod void YTD_RevenueByRegionController_Test(){
        YTD_RevenueByRegionController con = new YTD_RevenueByRegionController();
        System.assert(con.revenueData.size() != null);
    }
    
    public static testmethod void MonthlyRevenueLeaderboardsController_Test(){
        MonthlyRevenueLeaderboardsController con = new MonthlyRevenueLeaderboardsController();
        con.allowMonthChange = true;
        con.defaultMonth = 'January';
        System.assertEquals('January', con.monthLabel);
        System.assertEquals(12, con.getMonthPicklist().size());
        
        System.assert(con.getRevenueData().size() != null);
        con.selectedMonth = 'February';
        System.assert(con.getRevenueData().size() != null);
        System.assertEquals('February', con.monthLabel);
    }
    
    public static testmethod void MonthlyRevenueByRegionController_Test(){
        MonthlyRevenueByRegionController con = new MonthlyRevenueByRegionController();
        con.allowMonthChange = true;
        con.defaultMonth = 'January';
        System.assertEquals('January', con.monthLabel);
        System.assertEquals(12, con.getMonthPicklist().size());
        
        System.assert(con.getRevenueData().size() != null);
        con.selectedMonth = 'February';
        System.assert(con.getRevenueData().size() != null);
        System.assertEquals('February', con.monthLabel);
    }
    
    public static testmethod void YTD_OppClosesLeaderboardController_Test(){
        YTD_OppClosesLeaderboardController con = new YTD_OppClosesLeaderboardController();
        System.assert(con.revenueData.size() != null);
    }
    
    public static testmethod void YTD_OppClosesByRegionController_Test(){
        YTD_OppClosesByRegionController con = new YTD_OppClosesByRegionController();
        System.assert(con.revenueData.size() != null);
    }
    
    public static testmethod void MonthlyOppCloseLeaderboardController_Test(){
        MonthlyOppCloseLeaderboardController con = new MonthlyOppCloseLeaderboardController();
        con.allowMonthChange = true;
        con.defaultMonth = 'January';
        System.assertEquals('January', con.monthLabel);
        System.assertEquals(12, con.getMonthPicklist().size());
        
        System.assert(con.getRevenueData().size() != null);
        con.selectedMonth = 'February';
        System.assert(con.getRevenueData().size() != null);
        System.assertEquals('February', con.monthLabel);
    }
    
    public static testmethod void MonthlyOppCloseByRegionController_Test(){
        MonthlyOppCloseByRegionController con = new MonthlyOppCloseByRegionController();
        con.allowMonthChange = true;
        con.defaultMonth = 'January';
        System.assertEquals('January', con.monthLabel);
        System.assertEquals(12, con.getMonthPicklist().size());
        
        System.assert(con.getRevenueData().size() != null);
        con.selectedMonth = 'February';
        System.assert(con.getRevenueData().size() != null);
        System.assertEquals('February', con.monthLabel);
    }
    
    public static testmethod void Trailing12WeekOppClosedController_Test(){
        Trailing12WeekOppClosedController con = new Trailing12WeekOppClosedController();
        System.assert(con.revenueData.size() != null);
    }
    
    public static testmethod void Trailing12WeekOppClosedRegionController_Test(){
        Trailing12WeekOppClosedRegionController con = new Trailing12WeekOppClosedRegionController();
        System.assert(con.revenueData.size() != null);
    }
}