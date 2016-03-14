trigger Journal_Line_Item_BIBU on c2g__codaJournalLineItem__c (Before Insert,Before Update) {

    List<SCRB_SalesOrder__c > salesOrders = new List<SCRB_SalesOrder__c >();   
    
    List<String> projectIds = new List<String>();
    List<ID> salesOrderIds = new List<ID>();
    
    Map<Id,String> projectIDmap = new Map<Id, String>();
    Map<String,Id> Somap = new Map<String,Id>();
     
    for (c2g__codaJournalLineItem__c line : Trigger.New)
    {
       
        if ( line.Sales_Order__c == null && line.RS_Project_ID__c != null)
        {
            projectIds.add(line.RS_Project_ID__c );
        
        }   
        else if ( (line.RS_Project_ID__c == null || line.RS_Project_ID__c == '') && line.Sales_Order__c != null)
        {
            salesOrderIds.add(line.Sales_Order__c);
        }
       
    }   
    if(!(projectIds.isEmpty()) && !(salesOrderIds.isEmpty()) )
    {
        salesOrders = [Select Id,Job_Id__c from SCRB_SalesOrder__c  Where Job_Id__c IN :projectIds or Id in :salesOrderIds ];          
    }
    else if ( projectIds.isEmpty() && !(salesOrderIds.isEmpty()) )
    {
        salesOrders = [Select Id,Job_Id__c from SCRB_SalesOrder__c  Where Id IN :salesOrderIds];  
    }
    else if (salesOrderIds.isEmpty() && !(projectIds.isEmpty()) )    
    {
        salesOrders = [Select Id,Job_Id__c from SCRB_SalesOrder__c  Where Job_Id__c IN :projectIds ];   
    }
    
    for ( SCRB_SalesOrder__c so : salesOrders )
    {
        projectIDmap.put(so.Id, so.Job_Id__c);
        Somap.put(so.Job_Id__c, so.Id);        
    }
    
    System.debug(' ** SomapSize '+Somap.size());
    
    for (c2g__codaJournalLineItem__c line : Trigger.New)
    {
         if ( line.Sales_Order__c == null  && line.RS_Project_ID__c != null)
        {
            line.Sales_Order__c  = Somap.get(line.RS_Project_ID__c);
            
        
        }   
        else if ((line.RS_Project_ID__c == null || line.RS_Project_ID__c == '') && line.Sales_Order__c != null)
        {
             
            line.RS_Project_ID__c = projectIDmap.get(line.Sales_Order__c);
           
        }  
        
    
    }
    

}