/*  FILE: YTD_OppClosesLeaderboardController.cls
    AUTHOR: Dan Kelner
    DATE: 10/29/2014
    PURPOSE: Controller for YTD_OppClosesLeaderboard VF component.
    MODIFICATION HISTORY
        02/09/15  DK  Added year selection input
*/
public class YTD_OppClosesLeaderboardController {
    
    public ChartData[] revenueData {get; set;}
    public String year {get; set;}
    
    public YTD_OppClosesLeaderboardController (){
        revenueData = populateChartData();
    }
    
    private ChartData[] populateChartData(){
        if (String.isBlank(year))
            year = String.valueOf(Date.today().year());
        Integer theYear = Integer.valueOf(year);
        AggregateResult[] closedSalesOrders = [SELECT COUNT(ID), Owner_User__r.Name ownername FROM SCRB_SalesOrder__c 
                                               WHERE CALENDAR_YEAR(convertTimezone(Time_Original_Submit_Sales_Rep__c)) = :theYear 
                                               AND StatusCode__c != 'Canceled' AND Owner_User__r.Name != null 
                                               GROUP BY Owner_User__r.Name];
                                               
        AggregateResult[] canceledSalesOrders = [SELECT COUNT(ID), Owner_User__r.Name ownername FROM SCRB_SalesOrder__c 
                                                 WHERE CALENDAR_YEAR(convertTimezone(Time_Original_Submit_Sales_Rep__c)) = :theYear 
                                                 AND StatusCode__c = 'Canceled' AND Owner_User__r.Name != null 
                                                 GROUP BY Owner_User__r.Name];
                                                 
        Map<String, Integer> closedMap = new Map<String, Integer>();    //Owner Name --> Count (closed)
        Map<String, Integer> canceledMap = new Map<String, Integer>();    //Owner Name --> Count (canceled)
        Set<String> users = new Set<String>();    //Sales Order Users from both queries
        
        for (AggregateResult ar : closedSalesOrders){
            closedMap.put((String)ar.get('ownername'), (Integer)ar.get('expr0'));
            users.add((String)ar.get('ownername'));
        }
        
        for (AggregateResult ar : canceledSalesOrders){
            canceledMap.put((String)ar.get('ownername'), (Integer)ar.get('expr0'));
            users.add((String)ar.get('ownername'));
        }
        
        //Populate the array for the chart
        String[] userList = new List<String>(users);
        ChartData[] datapoints = new ChartData[]{};
        for (String name : userList){
            Integer closedOrdersTotal = closedMap.containsKey(name) ? closedMap.get(name) : 0;
            Integer canceledOrdersTotal = canceledMap.containsKey(name) ? canceledMap.get(name) : 0;
            datapoints.add(new ChartData(name, closedOrdersTotal, canceledOrdersTotal));
        }
        datapoints = selectionSort(datapoints);
        return datapoints;
    }
    
    private ChartData[] selectionSort(ChartData[] arr){
        for (Integer i = 0; i < arr.size() - 1; i++){
            Integer index = i;
            for (Integer j = i + 1; j < arr.size(); j++)
                if (arr[j].closedCount > arr[index].closedCount) 
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
        public Integer closedCount {get; set;}
        public Integer canceledCount {get; set;}
        public Double annualGoal {get; set;}
        public Double annualStretch {get; set;}
        
        public ChartData(String ownerName, Integer closedNum, Integer canceledNum){
            salesOrderOwner = ownerName;
            closedCount = closedNum;
            canceledCount = canceledNum;
            annualGoal = 0;
            annualStretch = 0;
            try {
                annualGoal = Monthly_Sales_Goals__c.getOrgDefaults().Monthly_Opportunity_Close_Goal__c * 12;
                annualStretch = Monthly_Sales_Goals__c.getOrgDefaults().Monthly_Opportunity_Close_Stretch__c * 12;
            } catch (NullPointerException e){
                System.debug('Error in YTD_OppClosesLeaderboardController on line ' + e.getLineNumber());
            }
        }
    }
}