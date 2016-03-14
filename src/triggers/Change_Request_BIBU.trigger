/* FILE: Change_Request_BIBU.trigger
 * AUTHOR: Rohit Jain
 * DATE: Jul 07, 2013
 * PURPOSE: Derive the PM Project and Rootstock information based on Sales Order in Change Request
 * MODIFICATION HISTORY
 *
 */
trigger Change_Request_BIBU on Change_Request__c (before insert,before update) {
    
    List<Id> soList = new List<Id>();  
    List<String> soJobList = new List<String>();
    List<String> soNameList = new List<String>(); 
    List<SCRB_SalesOrder__c> salesOrders = new List<SCRB_SalesOrder__c>(); 
    Map<Id, PM_Project__c> soToProjectMap  = new Map<Id, PM_Project__c>();   
     
    Map<String, Id> soToWorkOrderMap = new Map<String, Id>();  
    Map<Id, String> soToRootStockProjectMap  = new Map<Id, String>();
    
    Map<String, Id> soToRstkOrderMap = new Map<String, Id>();  
    Map<Id, String> soToRootStockSONameMap  = new Map<Id, String>(); 
    
    
    for (Change_Request__c rec : Trigger.new) {
     if(rec.Sales_Order__C != null)
     {
         if((Trigger.isInsert ) || (Trigger.isUpdate && rec.Sales_Order__C != Trigger.oldMap.get(rec.Id).Sales_Order__c) )
         {
             soList.add(rec.Sales_Order__C);    
         }
     }
     else
     {
         rec.PM_Project__c = null;
     }    
    }
    if (!soList.isEmpty())  
    {
        List<PM_Project__c> pmprjList = [Select Id, Sales_Order__c From PM_Project__c Where Sales_Order__c in :soList ];       
        salesOrders =  [Select Id, Name,JOb_Id__c,AccountId__r.Name from SCRB_SalesOrder__c where Id in :soList];
        
        if (!pmprjList.isEmpty()) 
        {
            for(PM_Project__c prj : pmprjList  )
            {
                 soToProjectMap.put(prj.Sales_order__c, prj);    
            }
        }        
        if (!soToProjectMap.isEmpty()) {
            for (Change_Request__c rec : Trigger.new) {
                if(rec.Sales_Order__C != null)
                {
                 rec.PM_Project__c = soToProjectMap.get(rec.Sales_Order__C).Id;           
                }
            }
        } 
       
    }
    
    if (!salesOrders.isEmpty())  
    {
        
        for(SCRB_SalesOrder__c so : salesOrders)
        {             
            soJobList.add(so.Job_id__c+' ('+so.AccountId__r.Name+')');
            soNameList.add(so.Name);
            soToRootStockProjectMap.put(so.Id,so.Job_id__c+' ('+so.AccountId__r.Name+')');
            soToRootStockSONameMap.put(so.Id,so.Name);           
        }       
        List<rstk__wocst__c>  workorders = [Select r.Id,r.rstk__wocst_proj__r.Name From rstk__wocst__c r Where  r.rstk__wocst_proj__r.Name in :soJobList  ]; 
        
        if (!workorders.isEmpty()) 
        {
            for(rstk__wocst__c wo: workorders)
            {
                 soToWorkOrderMap.put(wo.rstk__wocst_proj__r.Name, wo.Id);                   
            }
        }
        
        if (!soToWorkOrderMap.isEmpty()) {
            for (Change_Request__c rec : Trigger.new) {
                if(rec.Sales_Order__C != null)
                {                
                  rec.Work_Order__c = soToWorkOrderMap.get(soToRootStockProjectMap.get(rec.Sales_Order__C));           
                }
            }
        }   
        
        List<rstk__sohdr__c>  rstk_orders = [Select r.Id,r.Name From rstk__sohdr__c r Where  r.Name in :soNameList  ];     
        
        if (!rstk_orders.isEmpty()) 
        {
            for(rstk__sohdr__c rso: rstk_orders )
            {
                 soToRstkOrderMap.put(rso.Name, rso.Id);    
            }
        }
        
        if (!soToRstkOrderMap.isEmpty()) {
            for (Change_Request__c rec : Trigger.new) {
                if(rec.Sales_Order__C != null)
                {
                 rec.Rootstock_SO__c = soToRstkOrderMap.get(soToRootStockSONameMap.get(rec.Sales_Order__C));           
                }
            }
        }    
        
         
    }
    
    if(Trigger.isUpdate)
    {
        Map<Id, Change_Request__c> crToCapture  = new Map<Id, Change_Request__c>(); 
           
        //check if need to capture approval comments
        for (Change_Request__c rec : Trigger.new) {
            if (rec.Status__C != Trigger.oldMap.get(rec.Id).Status__c ) {           
                crToCapture.put(rec.Id, rec);            
            }            
           
            rec.Approval_Flag__c = false;
            if (rec.Approval_Comment_Check__C == 'Requested') {
                System.debug('** Requested ');           
                rec.Approval_Comment_Check__C = null;
                
            }
    
        }        
        
        if (!crToCapture.isEmpty())  
        {
            
             
            for (Change_Request__c pi : [SELECT Id , 
                  (  
                     SELECT Id, StepStatus, Comments 
                     FROM ProcessSteps Where StepStatus in ('Approved', 'Rejected') order by SystemModstamp desc Limit 1) from  Change_Request__c where Id in
                     :crToCapture.keySet() 
                   ORDER BY CreatedDate DESC
                  ])                      
             {
                
                
                if (pi.ProcessSteps.Size()> 0 )
                {   
    
                    if (!(pi.ProcessSteps[0].Comments == null || 
                               pi.ProcessSteps[0].Comments.trim().length() == 0))
                    {
                       crToCapture.get(pi.Id).Approval_Rejection_Comments__c = pi.ProcessSteps[0].Comments;
                    }
                } 
                
            }     
        }
    }    
}