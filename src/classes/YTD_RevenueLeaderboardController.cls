/*  FILE: YTD_RevenueLeaderboardController.cls
    AUTHOR: Dan Kelner
    DATE: 10/24/2014
    PURPOSE: Controller for YTD_RevenueLeaderboard VF component.
    MODIFICATION HISTORY
        02/06/15  DK  Added year selection input
*/
public class YTD_RevenueLeaderboardController {
    
    public ChartData[] revenueData {get; set;}
    public String year {get; set;}
    
    public YTD_RevenueLeaderboardController(){
        revenueData = populateChartData();
    }
    
    private ChartData[] populateChartData(){
        if (String.isBlank(year))
            year = String.valueOf(Date.today().year());
        Integer theYear = Integer.valueOf(year);
        AggregateResult[] closedSalesOrders = [SELECT SUM(Amount__c), Owner_User__r.Name ownername FROM SCRB_SalesOrder__c 
                                               WHERE CALENDAR_YEAR(convertTimezone(Time_Original_Submit_Sales_Rep__c)) = :theYear 
                                               AND StatusCode__c != 'Canceled' AND Owner_User__r.Name != null 
                                               GROUP BY Owner_User__r.Name];
                                               
        AggregateResult[] canceledSalesOrders = [SELECT SUM(Amount__c), Owner_User__r.Name ownername FROM SCRB_SalesOrder__c 
                                                 WHERE CALENDAR_YEAR(convertTimezone(Time_Original_Submit_Sales_Rep__c)) = :theYear 
                                                 AND StatusCode__c = 'Canceled' AND Owner_User__r.Name != null 
                                                 GROUP BY Owner_User__r.Name];
                                                 
        Map<String, Double> closedMap = new Map<String, Double>();    //Owner Name --> Aggregate Amount (closed)
        Map<String, Double> canceledMap = new Map<String, Double>();    //Owner Name --> Aggregate Amount (canceled)
        Set<String> users = new Set<String>();    //Sales Order Users from both queries
        
        for (AggregateResult ar : closedSalesOrders){
            closedMap.put((String)ar.get('ownername'), (Double)ar.get('expr0'));
            users.add((String)ar.get('ownername'));
        }
        
        for (AggregateResult ar : canceledSalesOrders){
            canceledMap.put((String)ar.get('ownername'), (Double)ar.get('expr0'));
            users.add((String)ar.get('ownername'));
        }
        
        //Populate the array for the chart
        String[] userList = new List<String>(users);
        ChartData[] datapoints = new ChartData[]{};
        for (String name : userList){
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
    
    class ChartData {
        public String salesOrderOwner {get; set;}
        public Double closedAmount {get; set;}
        public Double canceledAmount {get; set;}
        public Double annualGoal {get; set;}
        public Double annualStretch {get; set;}
        
        public ChartData(String ownerName, Double closedTotal, Double canceledTotal){
            salesOrderOwner = ownerName;
            closedAmount = closedTotal;
            canceledAmount = canceledTotal;
            annualGoal = 0;
            annualStretch = 0;
            try {
                annualGoal = Monthly_Sales_Goals__c.getOrgDefaults().Monthly_Sales_Revenue_Goal__c * 12;
                annualStretch = Monthly_Sales_Goals__c.getOrgDefaults().Monthly_Sales_Revenue_Stretch__c * 12;
            } catch (NullPointerException e){
                System.debug('Error in YTD_RevenueLeaderboardController on line ' + e.getLineNumber());
            }
        }
    }
}