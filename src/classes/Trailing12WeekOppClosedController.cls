/*  FILE: Trailing12WeekOppClosedController.cls
    AUTHOR: Dan Kelner
    DATE: 10/29/2014
    PURPOSE: Controller for Trailing12WeekOppClosed VF component.
    MODIFICATION HISTORY
*/
public class Trailing12WeekOppClosedController {
    
    public ChartData[] revenueData {get; set;}
    
    public Trailing12WeekOppClosedController (){
        revenueData = populateChartData();
    }
    
    private ChartData[] populateChartData(){
        AggregateResult[] closedOpps = [SELECT COUNT(ID), Owner.Name ownername FROM Opportunity 
                                        WHERE CloseDate = LAST_N_DAYS:84 
                                        AND StageName IN ('Closed - Won', 'Cancel Pending') AND Owner.Name != null 
                                        GROUP BY Owner.Name];
        
        AggregateResult[] totalOpps = [SELECT COUNT(ID), Owner.Name ownername FROM Opportunity 
                                       WHERE (CreatedDate = LAST_N_DAYS:84 OR 
                                       (CloseDate = LAST_N_DAYS:84 AND StageName IN ('Closed - Won', 'Cancel Pending')))
                                       AND Owner.Name != null 
                                       GROUP BY Owner.Name];
                                                 
        Map<String, Integer> closedMap = new Map<String, Integer>();    //Owner Name --> Count (closed)
        Map<String, Integer> totalMap = new Map<String, Integer>();    //Owner Name --> Count (total)
        Set<String> users = new Set<String>();    //Opportunity owners from both queries
        
        for (AggregateResult ar : closedOpps){
            closedMap.put((String)ar.get('ownername'), (Integer)ar.get('expr0'));
            users.add((String)ar.get('ownername'));
        }
        
        for (AggregateResult ar : totalOpps){
            totalMap.put((String)ar.get('ownername'), (Integer)ar.get('expr0'));
            users.add((String)ar.get('ownername'));
        }
        
        //Populate the array for the chart
        String[] userList = new List<String>(users);
        ChartData[] datapoints = new ChartData[]{};
        for (String name : userList){
            Integer closedOppsTotal = closedMap.containsKey(name) ? closedMap.get(name) : 0;
            Integer allOppsTotal = totalMap.containsKey(name) ? totalMap.get(name) : 0;
            Decimal closedPercent = allOppsTotal != 0 ? ((Double)closedOppsTotal / (Double)allOppsTotal) * 100 : 0;
            datapoints.add(new ChartData(name, closedPercent.setScale(2)));
        }
        datapoints = selectionSort(datapoints);
        return datapoints;
    }
    
    private ChartData[] selectionSort(ChartData[] arr){
        for (Integer i = 0; i < arr.size() - 1; i++){
            Integer index = i;
            for (Integer j = i + 1; j < arr.size(); j++)
                if (arr[j].closedRate > arr[index].closedRate) 
                    index = j;
      
            ChartData larger = arr[index];  
            arr[index] = arr[i];
            arr[i] = larger;
        }
        return arr;
    }
    
    class ChartData {
        public String oppOwner {get; set;}
        public Decimal closedRate {get; set;}
        
        public ChartData(String ownerName, Decimal oppClosedRate){
            oppOwner = ownerName;
            closedRate = oppClosedRate;
        }
    }
}