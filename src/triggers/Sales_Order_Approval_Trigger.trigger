//TCM 03/09/2012 - look to see if sales order is already approved before submitting
//MK 04/10/2014 - Added 'Re-Submitted' and 'Re-Assigned to Sales Manager' statuses
trigger Sales_Order_Approval_Trigger on SCRB_SalesOrder__c (after update) {

    Map<Id,SCRB_SalesOrder__c> salesOrdersToSubmit = new Map<Id,SCRB_SalesOrder__c>();   
    List<Id> salesOrdersConvList = new List<Id>();
    Set<Id> salesOrdersPendingApproval = new Set<Id>();
    Map<Id,String> salesOrdersStatusUpdated = new Map<Id,String>();   
    List<SCRB_SalesOrder__c> salesOrdersRootsStockList = new List<SCRB_SalesOrder__c>(); 
  

    //check if sales order should be submitted
    for (SCRB_SalesOrder__c rec : Trigger.new) {
        //SOA PB 11/4/2015 //if (rec.StatusCode__c == 'Sales Coordinator Rejected' || rec.StatusCode__c == 'Re-Submitted' || rec.StatusCode__c == 'Sales Coordinator Approved' || rec.StatusCode__c == 'Contract Administrator Rejected' || rec.StatusCode__c == 'VP Sales Rejected' || rec.StatusCode__c == 'VP Sales Approved') {
        if (rec.StatusCode__c =='Contract Administrator Rejected' || rec.StatusCode__c =='Sales ReSubmitted'    || rec.StatusCode__c == 'Sales Final Submitted' ) {
        
            System.debug('****'+rec.StatusCode__c);
            //MK - 2014-04-18 - Added logic to show user a clear error message instead of "No Approval Process Found".  So we are putting some of the approval process criteris here (checking for closed won).
            if(rec.Opportunity_Stage__c == 'Closed - Won') salesOrdersToSubmit.put(rec.Id, rec);
            else rec.adderror('In order to approve or reject this sales order, you must change the stage of the opportunity back to Closed – Won.');
        }       
        
        if (rec.StatusCode__c == 'Re-Assigned to Sales Manager' || rec.StatusCode__c == 'Controller Rejected' || rec.StatusCode__c == 'Escalated to VP Sales' || rec.StatusCode__c == 'Escalated to Regional Director' || rec.StatusCode__c == 'Director of P&A Rejected' || rec.StatusCode__c == 'Regional Director Rejected' || rec.StatusCode__c == 'Regional Director Approved') {
            System.debug('****'+rec.StatusCode__c);
            salesOrdersToSubmit.put(rec.Id, rec); 
        }

        if (rec.StatusCode__c == 'Conversion Pending' && Trigger.OldMap.get(rec.Id).StatusCode__c != 'Conversion Pending' )
        {
           sYSTEM.DEBUG('*1');           
           salesOrdersStatusUpdated.put(rec.Id, rec.StatusCode__c );                   
        }  
        if (rec.StatusCode__c == 'Conversion Approved' && Trigger.OldMap.get(rec.Id).StatusCode__c != 'Conversion Approved' )
        {
           sYSTEM.DEBUG('*2');
           salesOrdersStatusUpdated.put(rec.Id, rec.StatusCode__c );        
        }   
        if (rec.StatusCode__c == 'Conversion Processing' && Trigger.OldMap.get(rec.Id).StatusCode__c != 'Conversion Processing' )
        {
           sYSTEM.DEBUG('*2');
           salesOrdersConvList.add(rec.Id);        
        }

    } 
    if(!salesOrdersConvList.isEmpty())
    {
        List<Case> caselist = [Select Id,Sales_Order__c from Case where Sales_Order__c != null and Sales_Order__c in :salesOrdersConvList and Conversion_Status__c = 'Conversion Contract Signed' ];
       
        if(caselist !=null && !caselist.isEmpty())
        {
            for(Case cs : caselist)
            {
                salesOrdersStatusUpdated.put(cs.Sales_Order__c,'Conversion Processing');
            }    
        }       
    }
    
    // Added by RJ for Converion process
    
    if (!(salesOrdersStatusUpdated.isEmpty())) {
        List<PM_Project__c> projects;
        try {
            projects = [Select Sales_Order__c,Lease_Funding_Status__c,Change_Pending_Count__c from PM_Project__C Where Sales_Order__c in :salesOrdersStatusUpdated.keyset()];
           
        }
        catch( Exception e)
        {
            projects = new List<PM_Project__C>();
        }
        if (!(projects.isEmpty())) {
            for(PM_Project__c project : projects )
            {
                if(salesOrdersStatusUpdated.get(project.Sales_Order__c) == 'Conversion Pending')   
                {
                    project.Lease_Funding_Status__c   = 'Change Pending';
                    System.debug('**'+Trigger.OldMap.get(project.Sales_Order__c).StatusCode__c);
                    
                    if(project.Change_Pending_Count__c != null)
                    {
                        project.Change_Pending_Count__c   = project.Change_Pending_Count__c + 1;
                    }
                    else
                    {
                        project.Change_Pending_Count__c   = 1;
                    }   
                         
                } 
                else if (salesOrdersStatusUpdated.get(project.Sales_Order__c) == 'Conversion Approved')
                {
                    project.Lease_Funding_Status__c   = 'Ready to Install';
                } 
                else if (salesOrdersStatusUpdated.get(project.Sales_Order__c) == 'Conversion Processing')
                {
                    project.Lease_Funding_Status__c   = 'Ready to Prepare';
                }            
            }    
            sYSTEM.DEBUG('*2');
            update projects;    
        }    
    }
    // Added by RJ on 08/26
    
    
    System.debug('****Size salesOrdersToSubmit: '+salesOrdersToSubmit.size());
    //stop here if no sales orders need to be submitted
    if (!(salesOrdersToSubmit.isEmpty())) {
              
    
        //find pending approvals
        List<ProcessInstance> pendingApproval = 
            [SELECT TargetObjectId
            FROM ProcessInstance
            WHERE TargetObjectId IN :salesOrdersToSubmit.keyset()
            AND Status = 'Pending'];
        for (ProcessInstance pi : pendingApproval) {
            salesOrdersPendingApproval.add(pi.TargetObjectId);
        } 

        System.debug('****Size salesOrdersPendingApproval: '+salesOrdersPendingApproval.size());
    
        for (Id salesOrderId : salesOrdersToSubmit.keyset()) {
            //System.debug('****Sales Order --> ' + Trigger.newMap.get(salesOrderId));
        
            if (!salesOrdersPendingApproval.contains(salesOrderId)) {
                //Submit for Approval
                // Create an approval request for the account
                //system.debug('***Auto submitting approval process for SO with: ' + salesOrdersToSubmit.get(salesOrderId));
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments(salesOrdersToSubmit.get(salesOrderId).StatusCode__c+' - Auto-Submitted.');
                req1.setObjectId(salesOrderId);
                // Submit the approval request for the account
                Approval.ProcessResult result = Approval.process(req1);
                // Verify the result
                //System.assert(result.isSuccess());
            }
            
        }
     } 
     
    
       
}