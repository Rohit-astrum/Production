/*  FILE: YTD_RevenueByRegionController.cls
    AUTHOR: Dan Kelner
    DATE: 10/27/2014
    PURPOSE: Controller for YTD_RevenueByRegion VF component.
    MODIFICATION HISTORY
        02/06/15  DK  Added year selection input
*/
public class YTD_RevenueByRegionController {
    
    public ChartData[] revenueData {get; set;}
    public static Map<String, Integer> regionRepCounts;
    public String year {get; set;}
    
    public YTD_RevenueByRegionController(){
        regionRepCounts = new Map<String, Integer>();    //Region name --> Number of sales reps
        for (AggregateResult ar : [SELECT COUNT_DISTINCT(Employee__c), County__r.Sales_Region__c salesregion FROM County_Schedule_Availability__c GROUP BY County__r.Sales_Region__c LIMIT 10000]){
            regionRepCounts.put((String)ar.get('salesregion'), (Integer)ar.get('expr0'));
        }
        revenueData = populateChartData();
    }
    
    private ChartData[] populateChartData(){
        if (String.isBlank(year))
            year = String.valueOf(Date.today().year());
        Integer theYear = Integer.valueOf(year);
        AggregateResult[] closedSalesOrders = [SELECT SUM(Amount__c), Sales_Region__c FROM SCRB_SalesOrder__c 
                                               WHERE CALENDAR_YEAR(convertTimezone(Time_Original_Submit_Sales_Rep__c)) = :theYear 
                                               AND StatusCode__c != 'Canceled' AND Sales_Region__c != null 
                                               GROUP BY Sales_Region__c];
                                               
        AggregateResult[] canceledSalesOrders = [SELECT SUM(Amount__c), Sales_Region__c FROM SCRB_SalesOrder__c 
                                                 WHERE CALENDAR_YEAR(convertTimezone(Time_Original_Submit_Sales_Rep__c)) = :theYear 
                                                 AND StatusCode__c = 'Canceled' AND Sales_Region__c != null 
                                                 GROUP BY Sales_Region__c];
                                                 
        Map<String, Double> closedMap = new Map<String, Double>();    //Region Name --> Aggregate Amount (closed)
        Map<String, Double> canceledMap = new Map<String, Double>();    //Region Name --> Aggregate Amount (canceled)
        Set<String> regions = new Set<String>();    //Sales Order regions from both queries
        
        for (AggregateResult ar : closedSalesOrders){
            closedMap.put((String)ar.get('Sales_Region__c'), (Double)ar.get('expr0'));
            regions.add((String)ar.get('Sales_Region__c'));
        }
        
        for (AggregateResult ar : canceledSalesOrders){
            canceledMap.put((String)ar.get('Sales_Region__c'), (Double)ar.get('expr0'));
            regions.add((String)ar.get('Sales_Region__c'));
        }
        
        //Populate the array for the chart
        String[] regionList = new List<String>(regions);
        ChartData[] datapoints = new ChartData[]{};
        for (String reg : regionList){
            Double closedOrdersTotal = closedMap.containsKey(reg) ? closedMap.get(reg) : 0;
            Double canceledOrdersTotal = canceledMap.containsKey(reg) ? canceledMap.get(reg) : 0;
            datapoints.add(new ChartData(reg, closedOrdersTotal, canceledOrdersTotal));
        }
        datapoints = selectionSort(datapoints);
        return datapoints;
    }
    
    private ChartData[] selectionSort(ChartData[] arr){
        for (Integer i = 0; i < arr.size() - 1; i++){
            Integer index = i;
            for (Integer j = i + 1; j < arr.size(); j++)
                if (arr[j].closedAmount > arr[index].closedAmount) 
                    index = j;
      
            ChartData larger = arr[index];  
            arr[index] = arr[i];
            arr[i] = larger;
        }
        return arr;
    }
    
    public SelectOption[] getYearOptions(){
        SelectOption[] opts = new SelectOption[]{};
        opts.add(new SelectOption(String.valueOf(Date.today().year() - 1), String.valueOf(Date.today().year() - 1)));
        opts.add(new SelectOption(String.valueOf(Date.today().year()), String.valueOf(Date.today().year())));
        return opts;
    }
    
    class ChartData {
        public String salesOrderRegion {get; set;}
        public Double closedAmount {get; set;}
        public Double canceledAmount {get; set;}
        public Double annualGoal {get; set;}
        public Double annualStretch {get; set;}
        
        public ChartData(String regionName, Double closedTotal, Double canceledTotal){
            salesOrderRegion = regionName;
            closedAmount = closedTotal;
            canceledAmount = canceledTotal;
            annualGoal = 0;
            annualStretch = 0;
            try {
                annualGoal = Monthly_Sales_Goals__c.getOrgDefaults().Monthly_Sales_Revenue_Goal__c * 12 * YTD_RevenueByRegionController.regionRepCounts.get(salesOrderRegion);
                annualStretch = Monthly_Sales_Goals__c.getOrgDefaults().Monthly_Sales_Revenue_Stretch__c * 12 * YTD_RevenueByRegionController.regionRepCounts.get(salesOrderRegion);
            } catch (NullPointerException e){
                System.debug('Error in YTD_RevenueByRegionController on line ' + e.getLineNumber());
            }
        }
    }
}