/* FILE: SalesDashboardTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: August 22, 2012
 * PURPOSE: Test class for SalesDashboard page and SalesDashboardController
 * MODIFICATION HISTORY
 *
 */

@isTest
public class SalesDashboardTest {

    static testMethod void snapshot_getSalesVsClose_3Weeks() {
        
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
        
        List<SalesDashboardController.SalesData> result = SalesDashboardController.getSalesVsClose();
        
        System.assertEquals(3, result.size());
        
        System.assertEquals(15, result[0].sales);
        System.assertEquals(.13, result[0].closeRate);
        
        System.assertEquals(23, result[1].sales);
        System.assertEquals(.12, result[1].closeRate);
        
        System.assertEquals(25, result[2].sales);
        System.assertEquals(.15, result[2].closeRate);
        
        Test.stopTest();
    }

    static testMethod void snapshot_regionalCloseRate_3Weeks() {
        
        Schema.DescribeFieldResult regions = Sales_Snapshot__c.Sales_Region__c.getDescribe();
        List<Schema.PickListEntry> regionEntries = regions.getPicklistValues();
        Integer regionCount = regionEntries.size()-1;
        String region1 = regionEntries[0].getLabel();
        String region2 = regionEntries[1].getLabel();
        
        Sales_Snapshot__c[] snapshots = new Sales_Snapshot__c[] {
            new Sales_Snapshot__c(
                Sales_End__c = Date.today().toStartOfWeek(),
                Lead_End__c = Date.today().toStartOfWeek().addDays(-4),
                Sales_Last_12_Weeks__c = 100,
                Leads_Last_12_weeks__c = 800,
                Sales_Region__c = region1
            ),
            new Sales_Snapshot__c(
                Sales_End__c = Date.today().toStartOfWeek(),
                Lead_End__c = Date.today().toStartOfWeek().addDays(-4),
                Sales_Last_12_Weeks__c = 50,
                Leads_Last_12_weeks__c = 400,
                Sales_Region__c = region2
            ),
            new Sales_Snapshot__c(
                Sales_End__c = Date.today().toStartOfWeek().addDays(-7),
                Lead_End__c = Date.today().toStartOfWeek().addDays(-11),
                Sales_Last_12_Weeks__c = 49,
                Leads_Last_12_weeks__c = 490,
                Sales_Region__c = region1
            ),
            new Sales_Snapshot__c(
                Sales_End__c = Date.today().toStartOfWeek().addDays(-7),
                Lead_End__c = Date.today().toStartOfWeek().addDays(-11),
                Sales_Last_12_Weeks__c = 17,
                Leads_Last_12_weeks__c = 510,
                Sales_Region__c = region2
            ),
            new Sales_Snapshot__c(
                Sales_End__c = Date.today().toStartOfWeek().addDays(-14),
                Lead_End__c = Date.today().toStartOfWeek().addDays(-18),
                Sales_Last_12_Weeks__c = 30,
                Leads_Last_12_weeks__c = 480,
                Sales_Region__c = region1
            ),
            new Sales_Snapshot__c(
                Sales_End__c = Date.today().toStartOfWeek().addDays(-14),
                Lead_End__c = Date.today().toStartOfWeek().addDays(-18),
                Sales_Last_12_Weeks__c = 40,
                Leads_Last_12_weeks__c = 320,
                Sales_Region__c = region2
            )
        };
        insert snapshots;
        
        Test.startTest();
        
        SalesDashboardController.RegionResult result = SalesDashboardController.getRegionalCloseRate();
        
        System.assertEquals(regionEntries.size(), result.regions.size()+1);

        System.assertEquals(3, result.regionData.size());

        System.assertEquals(.0625, result.regionData[0].closeRate[0]); //region 1
        System.assertEquals(.125, result.regionData[0].closeRate[1]); //region2
        System.assertEquals(.0875, result.regionData[0].closeRate[regionCount]); //overall

        System.assertEquals(.1, result.regionData[1].closeRate[0]);
        System.assertEquals(17/510.0, result.regionData[1].closeRate[1]);
        System.assertEquals(.066, result.regionData[1].closeRate[regionCount]);
        
        System.assertEquals(.125, result.regionData[2].closeRate[0]);
        System.assertEquals(.125, result.regionData[2].closeRate[1]);
        System.assertEquals(.125, result.regionData[2].closeRate[regionCount]);
        
        Test.stopTest();
    }
    
    static testMethod void snapshot_oppCloseRate_3Weeks() {
        
        Schema.DescribeFieldResult regions = Sales_Snapshot__c.Sales_Region__c.getDescribe();
        List<Schema.PickListEntry> regionEntries = regions.getPicklistValues();
        Integer regionCount = regionEntries.size();
        String region1 = regionEntries[0].getLabel();
        String region2 = regionEntries[1].getLabel();
        
        Sales_Snapshot__c[] snapshots = new Sales_Snapshot__c[] {
            new Sales_Snapshot__c(
                Sales_End__c = Date.today().toStartOfWeek(),
                Lead_End__c = Date.today().toStartOfWeek().addDays(-4),
                Sales_Last_12_Weeks__c = 100,
                Opportunities_Last_12_weeks__c = 800,
                Leads_Last_12_weeks__c = 1600,
                Sales_Region__c = region1
            ),
            new Sales_Snapshot__c(
                Sales_End__c = Date.today().toStartOfWeek(),
                Lead_End__c = Date.today().toStartOfWeek().addDays(-4),
                Sales_Last_12_Weeks__c = 50,
                Opportunities_Last_12_weeks__c = 400,
                Leads_Last_12_weeks__c = 800,
                Sales_Region__c = region2
            ),
            new Sales_Snapshot__c(
                Sales_End__c = Date.today().toStartOfWeek().addDays(-7),
                Lead_End__c = Date.today().toStartOfWeek().addDays(-11),
                Sales_Last_12_Weeks__c = 49,
                Opportunities_Last_12_weeks__c = 490,
                Leads_Last_12_weeks__c = 980,
                Sales_Region__c = region1
            ),
            new Sales_Snapshot__c(
                Sales_End__c = Date.today().toStartOfWeek().addDays(-7),
                Lead_End__c = Date.today().toStartOfWeek().addDays(-11),
                Sales_Last_12_Weeks__c = 17,
                Opportunities_Last_12_weeks__c = 510,
                Leads_Last_12_weeks__c = 1020,
                Sales_Region__c = region2
            ),
            new Sales_Snapshot__c(
                Sales_End__c = Date.today().toStartOfWeek().addDays(-14),
                Lead_End__c = Date.today().toStartOfWeek().addDays(-18),
                Sales_Last_12_Weeks__c = 30,
                Opportunities_Last_12_weeks__c = 480,
                Leads_Last_12_weeks__c = 960,
                Sales_Region__c = region1
            ),
            new Sales_Snapshot__c(
                Sales_End__c = Date.today().toStartOfWeek().addDays(-14),
                Lead_End__c = Date.today().toStartOfWeek().addDays(-18),
                Sales_Last_12_Weeks__c = 40,
                Opportunities_Last_12_weeks__c = 320,
                Leads_Last_12_weeks__c = 640,
                Sales_Region__c = region2
            )
        };
        insert snapshots;
        
        Test.startTest();
        
        SalesDashboardController.RegionResult result = SalesDashboardController.getOpptyCloseRate();
        
        System.assertEquals(regionEntries.size(), result.regions.size()+1);

        System.assertEquals(3, result.regionData.size());

        System.assertEquals(.0625, result.regionData[0].closeRate[0]); //region 1
        System.assertEquals(.125, result.regionData[0].closeRate[1]); //region2
        System.assertEquals(.0875, result.regionData[0].oppCloseRate); //overall
        System.assertEquals(2, result.regionData[0].oppLeadRatio); 

        System.assertEquals(.1, result.regionData[1].closeRate[0]);
        System.assertEquals(17/510.0, result.regionData[1].closeRate[1]);
        System.assertEquals(.066, result.regionData[1].oppCloseRate);
        System.assertEquals(2, result.regionData[0].oppLeadRatio); 
        
        System.assertEquals(.125, result.regionData[2].closeRate[0]);
        System.assertEquals(.125, result.regionData[2].closeRate[1]);
        System.assertEquals(.125, result.regionData[2].oppCloseRate);
        System.assertEquals(2, result.regionData[0].oppLeadRatio); 
        
        Test.stopTest();
    }   
    

}