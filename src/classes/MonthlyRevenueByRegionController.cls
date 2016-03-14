/*  FILE: MonthlyRevenueByRegionController.cls
    AUTHOR: Dan Kelner
    DATE: 10/29/2014
    PURPOSE: Controller for MonthlyRevenueByRegion VF component.
    MODIFICATION HISTORY
        02/06/15  DK  Added year selection input
*/
public class MonthlyRevenueByRegionController {
    
    public String defaultMonth {get { if (defaultMonth == null)
                                          return monthList.get(Date.today().month() - 1);
                                      else
                                          return defaultMonth; } set;}    //VF Component attribute
    public String selectedMonth {get; set;}    //Chosen picklist value
    public String monthLabel {get { if (monthLabel == null)
                                        return defaultMonth;
                                    else
                                        return monthLabel; } set;}    //Month name to be displayed over the chart
    public Boolean allowMonthChange {get; set;}
    public String year {get; set;}
    public static Map<String, Integer> regionRepCounts {get { regionRepCounts = new Map<String, Integer>();    //Region name --> Number of sales reps
                                                              for (AggregateResult ar : [SELECT COUNT_DISTINCT(Employee__c), County__r.Sales_Region__c salesregion 
                                                                                         FROM County_Schedule_Availability__c GROUP BY County__r.Sales_Region__c LIMIT 10000]){
                                                                  regionRepCounts.put((String)ar.get('salesregion'), (Integer)ar.get('expr0'));
                                                              }
                                                              return regionRepCounts; } set;}
    
    private String[] monthList = new String[]{'January', 'February', 'March', 'April', 'May', 'June', 'July', 
                                              'August', 'September', 'October', 'November', 'December'};
    
    public MonthlyRevenueByRegionController(){
        year = String.valueOf(Date.today().year());
    }
    
    public SelectOption[] getMonthPicklist(){
        if (String.isBlank(selectedMonth))
            selectedMonth = defaultMonth;    //Set the default picklist value
        SelectOption[] months = new SelectOption[]{};
        for (String m : monthList)
            months.add(new SelectOption(m, m));
        return months;
    }
    
    public ChartData[] getRevenueData(){
        if (String.isBlank(year))
            year = String.valueOf(Date.today().year());
        if (String.isNotBlank(selectedMonth) && allowMonthChange != false)
            monthLabel = selectedMonth;    //User override
        Integer monthParam = getMonthNum(monthLabel);
        Integer theYear = Integer.valueOf(year);
        AggregateResult[] closedSalesOrders = [SELECT SUM(Amount__c), Sales_Region__c FROM SCRB_SalesOrder__c 
                                               WHERE CALENDAR_MONTH(convertTimezone(Time_Original_Submit_Sales_Rep__c)) = :monthParam 
                                               AND CALENDAR_YEAR(convertTimezone(Time_Original_Submit_Sales_Rep__c)) = :theYear 
                                               AND StatusCode__c != 'Canceled' AND Sales_Region__c != null 
                                               GROUP BY Sales_Region__c];
                                               
        AggregateResult[] canceledSalesOrders = [SELECT SUM(Amount__c), Sales_Region__c FROM SCRB_SalesOrder__c 
                                                 WHERE CALENDAR_MONTH(convertTimezone(Time_Original_Submit_Sales_Rep__c)) = :monthParam 
                                                 AND CALENDAR_YEAR(convertTimezone(Time_Original_Submit_Sales_Rep__c)) = :theYear 
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
        for (String name : regionList){
            Double closedOrdersTotal = closedMap.containsKey(name) ? closedMap.get(name) : 0;
            Double canceledOrdersTotal = canceledMap.containsKey(name) ? canceledMap.get(name) : 0;
            datapoints.add(new ChartData(name, closedOrdersTotal, canceledOrdersTotal));
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

    private Integer getMonthNum(String monthStr){
        Integer monthNum = 0;
        if (monthStr == 'January'){
            monthNum = 1;
        } else if (monthStr == 'February'){
            monthNum = 2;
        } else if (monthStr == 'March'){
            monthNum = 3;
        } else if (monthStr == 'April'){
            monthNum = 4;
        } else if (monthStr == 'May'){
            monthNum = 5;
        } else if (monthStr == 'June'){
            monthNum = 6;
        } else if (monthStr == 'July'){
            monthNum = 7;
        } else if (monthStr == 'August'){
            monthNum = 8;
        } else if (monthStr == 'September'){
            monthNum = 9;
        } else if (monthStr == 'October'){
            monthNum = 10;
        } else if (monthStr == 'November'){
            monthNum = 11;
        } else if (monthStr == 'December'){
            monthNum = 12;
        }
        return monthNum;
    }
    
    class ChartData {
        public String salesOrderRegion {get; set;}
        public Double closedAmount {get; set;}
        public Double canceledAmount {get; set;}
        public Double monthlyGoal {get; set;}
        public Double monthlyStretch {get; set;}
        
        public ChartData(String regionName, Double closedTotal, Double canceledTotal){
            salesOrderRegion = regionName;
            closedAmount = closedTotal;
            canceledAmount = canceledTotal;
            monthlyGoal = 0;
            monthlyStretch = 0;
            try {
                monthlyGoal = Monthly_Sales_Goals__c.getOrgDefaults().Monthly_Sales_Revenue_Goal__c * MonthlyRevenueByRegionController.regionRepCounts.get(salesOrderRegion);
                monthlyStretch = Monthly_Sales_Goals__c.getOrgDefaults().Monthly_Sales_Revenue_Stretch__c * MonthlyRevenueByRegionController.regionRepCounts.get(salesOrderRegion);
            } catch (NullPointerException e){
                System.debug('Error in MonthlyRevenueByRegionController on line ' + e.getLineNumber() + ': ' + e.getMessage());
            }
        }
    }
}