/*  FILE: MonthlyOppCloseLeaderboardController.cls
    AUTHOR: Dan Kelner
    DATE: 10/29/2014
    PURPOSE: Controller for MonthlyOppCloseLeaderboard VF component.
    MODIFICATION HISTORY
        02/09/15  DK  Added year selection input
*/
public class MonthlyOppCloseLeaderboardController {
    
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

    private String[] monthList = new String[]{'January', 'February', 'March', 'April', 'May', 'June', 'July', 
                                              'August', 'September', 'October', 'November', 'December'};
                                              
    public MonthlyOppCloseLeaderboardController(){
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
        AggregateResult[] closedSalesOrders = [SELECT COUNT(ID), Owner_User__r.Name ownername FROM SCRB_SalesOrder__c 
                                               WHERE CALENDAR_MONTH(convertTimezone(Time_Original_Submit_Sales_Rep__c)) = :monthParam 
                                               AND CALENDAR_YEAR(convertTimezone(Time_Original_Submit_Sales_Rep__c)) = :theYear 
                                               AND StatusCode__c != 'Canceled' AND Owner_User__r.Name != null 
                                               GROUP BY Owner_User__r.Name];
                                               
        AggregateResult[] canceledSalesOrders = [SELECT COUNT(ID), Owner_User__r.Name ownername FROM SCRB_SalesOrder__c 
                                                 WHERE CALENDAR_MONTH(convertTimezone(Time_Original_Submit_Sales_Rep__c)) = :monthParam 
                                                 AND CALENDAR_YEAR(convertTimezone(Time_Original_Submit_Sales_Rep__c)) = :theYear 
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
        public String salesOrderOwner {get; set;}
        public Integer closedCount {get; set;}
        public Integer canceledCount {get; set;}
        public Double monthlyGoal {get; set;}
        public Double monthlyStretch {get; set;}
        
        public ChartData(String ownerName, Integer closedNum, Integer canceledNum){
            salesOrderOwner = ownerName;
            closedCount = closedNum;
            canceledCount = canceledNum;
            monthlyGoal = 0;
            monthlyStretch = 0;
            try {
                monthlyGoal = Monthly_Sales_Goals__c.getOrgDefaults().Monthly_Opportunity_Close_Goal__c;
                monthlyStretch = Monthly_Sales_Goals__c.getOrgDefaults().Monthly_Opportunity_Close_Stretch__c;
            } catch (NullPointerException e){
                System.debug('Error in MonthlyOppCloseLeaderboardController on line ' + e.getLineNumber());
            }
        }
    }
}