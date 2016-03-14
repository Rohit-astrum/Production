/* FILE: SalesDashboardController.cls
 * AUTHOR: Tino Mattheou
 * DATE: August 17, 2012
 * PURPOSE: controller for SalesDashboard page
 * MODIFICATION HISTORY
 * RJ : Zen-117
 * RJ : Addition on CA Region broke the Dashboard Fixed.
 */
 
public class SalesDashboardController {

    @RemoteAction
    public static List<SalesData> getSalesVsClose() {
        List<SalesData> result = new List<SalesData>();
        
        List<AggregateResult> snapshots = 
            [SELECT Sales_End__c week, SUM(Sales_This_Week__c) sales, SUM(Sales_Last_12_Weeks__c) sales12, SUM(Leads_Last_12_Weeks__c) leads12
            FROM Sales_Snapshot__c
            WHERE Sales_End__c = THIS_YEAR
            OR Sales_End__c = LAST_YEAR
            GROUP BY Sales_End__c
            ORDER BY Sales_End__c];
            
        for (AggregateResult snapshot : snapshots) {
            SalesData sd = new SalesData();
            sd.week = (Date)snapshot.get('week');
            sd.sales = (Decimal)snapshot.get('sales');
            Decimal sales12 = (Decimal)snapshot.get('sales12');
            Decimal leads12 = (Decimal)snapshot.get('leads12');
            if (sales12 != null && leads12 != null && leads12 > 0) {
                sd.closeRate = sales12 / leads12;
            }
            result.add(sd);
        }
        
        return result;
    }
    
    @RemoteAction
    public static RegionResult getRegionalCloseRate () {
        RegionResult result = new RegionResult();
        result.regions = new List<String>();

//ISSUE: can't get colors from metadata
        //get picklist metadata     
        Map<String, Integer> regionMap = new Map<String, Integer>();
        Schema.DescribeFieldResult regions = Sales_Snapshot__c.Sales_Region__c.getDescribe();
        List<Schema.PickListEntry> regionEntries = regions.getPicklistValues(); 
        for (Integer i = 0; i < regionEntries.size(); i++ ) {
            if(regionEntries[i].getLabel() != 'Unknown')
            {
                result.regions.add(regionEntries[i].getLabel());
                regionMap.put(regionEntries[i].getLabel(), i);
            }
        }
        
        result.regionData = new List<RegionData>();
        Integer regionCount = regionMap.size();
        
        List<AggregateResult> snapshots = 
            [SELECT Sales_End__c week, Sales_Region__c region, SUM(Sales_Last_12_Weeks__c) sales12, SUM(Leads_Last_12_Weeks__c) leads12
            FROM Sales_Snapshot__c
            WHERE (Sales_End__c = THIS_YEAR
            OR Sales_End__c = LAST_YEAR)
            AND Sales_End__c > 2011-03-01
            AND Sales_Region__c <> 'Unknown'
            GROUP BY Sales_End__c, Sales_Region__c
            ORDER BY Sales_End__c, Sales_Region__c];
        
        Date lastWeek = null;
        Decimal sales12Total, leads12Total;
        RegionData rd;
        for (AggregateResult snapshot : snapshots) {

            Date week = (Date)snapshot.get('week');
            if(week != lastWeek) {
                if (sales12Total != null && leads12Total != null && leads12Total > 0) {
                    rd.closeRate[regionCount] = sales12Total / leads12Total;
                }
                lastWeek = week;
                sales12Total = leads12Total = 0;
                rd = new RegionData();
                rd.week = week;
                rd.closeRate = new Decimal[regionCount + 1];
                for(Integer i = 0; i < regionCount; i++ )
                {
                  rd.closeRate[i] = 0;  
                }
                rd.closeRate[regionCount] = 0;
                result.regionData.add(rd);
                
            }
            
            String region = (String)snapshot.get('region');
            Decimal sales12 = (Decimal)snapshot.get('sales12');
            if (sales12 != null) {
                sales12Total += sales12;
            }
            Decimal leads12 = (Decimal)snapshot.get('leads12');
            if (leads12 != null) {
                leads12Total += leads12;
            }
            if (regionMap.get(region) != null) {
                if (sales12 != null && leads12 != null && leads12 > 0) {
                    rd.closeRate[regionMap.get(region)] = sales12 / leads12;
                } else {
                    rd.closeRate[regionMap.get(region)] = 0;
                }
            }
        }
        
        if (sales12Total != null && leads12Total != null && leads12Total > 0) {
            rd.closeRate[regionCount] = sales12Total / leads12Total;
        }
        
        return result;
        
    }  

    @RemoteAction
    public static RegionResult getOpptyCloseRate () {
        RegionResult result = new RegionResult();
        result.regions = new List<String>();

//ISSUE: can't get colors from metadata
        //get picklist metadata     
        Map<String, Integer> regionMap = new Map<String, Integer>();
        Schema.DescribeFieldResult regions = Sales_Snapshot__c.Sales_Region__c.getDescribe();
        List<Schema.PickListEntry> regionEntries = regions.getPicklistValues(); 
        for (Integer i = 0; i < regionEntries.size(); i++ ) {
            if(regionEntries[i].getLabel() != 'Unknown')
            {
                result.regions.add(regionEntries[i].getLabel());
                regionMap.put(regionEntries[i].getLabel(), i);
            }
        }
        
        result.regionData = new List<RegionData>();
        Integer regionCount = regionMap.size();
        
        List<AggregateResult> snapshots = 
            [SELECT Sales_End__c week, Sales_Region__c region, SUM(Opportunities_Last_12_Weeks__c) opps12, SUM(Sales_Last_12_Weeks__c) sales12, SUM(Leads_Last_12_Weeks__c) leads12
            FROM Sales_Snapshot__c
            WHERE Sales_End__c > 2012-03-01
            AND Sales_Region__c <> 'Unknown'
            GROUP BY Sales_End__c, Sales_Region__c
            ORDER BY Sales_End__c, Sales_Region__c];
        
        Date lastWeek = null;
        Decimal sales12Total, leads12Total, opps12Total;
        RegionData rd;
        for (AggregateResult snapshot : snapshots) {
            Date week = (Date)snapshot.get('week');
            if(week != lastWeek) {
                if (sales12Total != null && leads12Total != null && opps12Total != null) {
                    if (leads12Total > 0 && opps12Total > 0) {
                        rd.oppLeadRatio = (sales12Total / opps12Total ) / (sales12Total / leads12Total);
                    } else {
                        rd.oppLeadRatio = 0;
                    }
                }
                if (sales12Total != null && opps12Total != null) {
                    if (opps12Total > 0) {
                        rd.oppCloseRate = sales12Total / opps12Total;
                    } else {
                        rd.oppCloseRate = 0;
                    }
                }
                lastWeek = week;
                sales12Total = leads12Total = opps12Total = 0;
                rd = new RegionData();
                rd.week = week;
                rd.closeRate = new Decimal[regionCount];
                for(Integer i = 0; i < regionCount; i++ )
                {
                  rd.closeRate[i] = 0;  
                }
                result.regionData.add(rd);
                
            }
            if (sales12Total != null && leads12Total != null && opps12Total != null) {
                if (leads12Total > 0 && opps12Total > 0) {
                    rd.oppLeadRatio = (sales12Total / opps12Total ) / (sales12Total / leads12Total);
                } else {
                    rd.oppLeadRatio = 0;
                }
            }
            if (sales12Total != null && opps12Total != null) {
                if (opps12Total > 0) {
                    rd.oppCloseRate = sales12Total / opps12Total;
                } else {
                    rd.oppCloseRate = 0;
                }
            }
            
            String region = (String)snapshot.get('region');
            Decimal sales12 = (Decimal)snapshot.get('sales12');
            if (sales12 != null) {
                sales12Total += sales12;
            }
            Decimal leads12 = (Decimal)snapshot.get('leads12');
            if (leads12 != null) {
                leads12Total += leads12;
            }
            Decimal opps12 = (Decimal)snapshot.get('opps12');
            if (opps12 != null) {
                opps12Total += opps12;
            }
            if (sales12 != null && opps12 != null && opps12 > 0) {
                rd.closeRate[regionMap.get(region)] = sales12 / opps12;
            } else {
                rd.closeRate[regionMap.get(region)] = 0;
            }
        }
        // Added for Zen-117 Fix by RJ on 02/07/13
        if(rd != null)
        {
               if (sales12Total != null && leads12Total != null && opps12Total != null) {
                    if (leads12Total > 0 && opps12Total > 0) {
                        rd.oppLeadRatio = (sales12Total / opps12Total ) / (sales12Total / leads12Total);
                    } else {
                        rd.oppLeadRatio = 0;
                    }
                }
                if (sales12Total != null && opps12Total != null) {
                    if (opps12Total > 0) {
                        rd.oppCloseRate = sales12Total / opps12Total;
                    } else {
                        rd.oppCloseRate = 0;
                    }
                }
        
        }
        
        return result;
        
    }  

    public class SalesData {
        public Date week { get; set; }
        public Decimal sales { get; set; }
        public Decimal closeRate { get; set; }
    }
    
    public class RegionResult {
        public List<String> regions { get; set; }
        public List<RegionData> regionData { get; set; }
    }
    
    public class RegionData {
        public Date week { get; set; }
        public Decimal oppLeadRatio { get; set; }
        public Decimal oppCloseRate { get; set; }
        public Decimal[] closeRate { get; set; }
    }

}