trigger LeaseFundStatusCheck_BIBU on Case (Before Insert, Before Update) {        
    List<Id> salesOrderIds = new List<Id>();
    List<SCRB_SalesORder__c> salesOrders;
    for(Case cs : Trigger.new)
    {
        if (cs.Sales_Order__c != null 
            && cs.Conversion_Status__c == 'Conversion Contract Signed' 
            && (Trigger.IsInsert || (Trigger.IsUpdate && Trigger.OldMap.get(cs.Id).Conversion_Status__c != 'Conversion Processing')) )
        {                       
            salesOrderIds.add(cs.Sales_Order__c);  
        }
    }
    if(!salesOrderIds.isEmpty())
    {
        salesOrders = [Select Id,StatusCode__c from SCRB_SalesOrder__c Where ID in :salesOrderIds and StatusCode__c = 'Conversion Processing'];                
    }
    if(salesOrders !=null && !salesOrders.isEmpty())        
    {
                   
        List<PM_Project__c> projects;
        try {
            projects = [Select Sales_Order__c,Lease_Funding_Status__c from PM_Project__C Where Sales_Order__c in :salesOrders];
           
        }
        catch( Exception e)
        {
            projects = new List<PM_Project__C>();
        }
        if (!(projects.isEmpty())) {
            for(PM_Project__c project : projects )
            {
                
                project.Lease_Funding_Status__c   = 'Ready to Prepare';
                          
            }    
            sYSTEM.DEBUG('*2');
            update projects;    
        }    
    }
}