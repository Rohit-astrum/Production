/*  FILE: Trailing12WeekOppClosedRegionController.cls
    AUTHOR: Dan Kelner
    DATE: 10/30/2014
    PURPOSE: Controller for Trailing12WeekOppClosedRegion VF component.
    MODIFICATION HISTORY
*/
public class Trailing12WeekOppClosedRegionController {
    
    public ChartData[] revenueData {get; set;}
    
    public Trailing12WeekOppClosedRegionController (){
        revenueData = populateChartData();
    }
    
    private ChartData[] populateChartData(){
        AggregateResult[] closedOpps = [SELECT COUNT(ID), Sales_Region__c FROM Opportunity 
                                        WHERE CloseDate = LAST_N_DAYS:84 
                                        AND StageName IN ('Closed - Won', 'Cancel Pending') AND Sales_Region__c != null 
                                        GROUP BY Sales_Region__c];
        
        AggregateResult[] totalOpps = [SELECT COUNT(ID), Sales_Region__c FROM Opportunity 
                                       WHERE (CreatedDate = LAST_N_DAYS:84 OR 
                                       (CloseDate = LAST_N_DAYS:84 AND StageName IN ('Closed - Won', 'Cancel Pending'))) 
                                       AND Sales_Region__c != null 
                                       GROUP BY Sales_Region__c];
                                                 
        Map<String, Integer> closedMap = new Map<String, Integer>();    //Region Name --> Count (closed)
        Map<String, Integer> totalMap = new Map<String, Integer>();    //Region Name --> Count (total)
        Set<String> regions = new Set<String>();    //Opportunity regions from both queries
        
        for (AggregateResult ar : closedOpps){
            closedMap.put((String)ar.get('Sales_Region__c'), (Integer)ar.get('expr0'));
            regions.add((String)ar.get('Sales_Region__c'));
        }
        
        for (AggregateResult ar : totalOpps){
            totalMap.put((String)ar.get('Sales_Region__c'), (Integer)ar.get('expr0'));
            regions.add((String)ar.get('Sales_Region__c'));
        }
        
        //Populate the array for the chart
        String[] regionList = new List<String>(regions);
        ChartData[] datapoints = new ChartData[]{};
        for (String name : regionList){
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