public with sharing class SalesOrderLeasingActionController {

    private SCRB_SalesOrder__c so;
    private PM_project__c project;
    public boolean actionDone {get; private set;}
    public String comments {get; set;} 
  
    public SalesOrderLeasingActionController(ApexPages.StandardController stdController) {
        so = (SCRB_SalesOrder__c) stdController.getRecord();         
        try
        {
        
            project = [Select Lease_Funding_Status__c from PM_Project__C where Sales_Order__c = :so.Id ];
        }  
        catch(Exception e)
        {
            project = null;
        }  
               
    }

   public PageReference submitCancellation() {    
    
        if (so != null) {
        
            so.StatusCode__C = 'Canceled';
            update so;  
            try{
              List<ProcessInstanceWorkitem> processitems = [Select ID From ProcessInstanceWorkitem p Where p.ProcessInstance.TargetObjectId = :so.Id and 
                                        p.ProcessInstance.Status = 'Pending'];
              for(ProcessInstanceWorkitem processItem : processitems )
              {
                  System.debug('*Rem-'+processitem.Id);
                  Approval.ProcessWorkitemRequest req2 = 
                    new Approval.ProcessWorkitemRequest();          
            
                  req2.setAction('Removed');     
                  // Use the ID from the newly created item to specify the item to be worked
                  req2.setWorkitemId(processitem.Id);
                  // Submit the request for approval
                  Approval.ProcessResult result2 =  Approval.process(req2);  
              }
            }
            
            catch(Exception e)
            {
              System.debug('No Pending Actions');
            }
              
            // update the event
            //so.Escalation_Comments__c = comments ;       
            project.Lease_Funding_Status__c = 'Cancelled'; 
            project.Status__c = 'Cancelled';
            update project;
              
              
          // send notification email
          //Sales_Visit_Complete_Utility.sendNotificationEmail(tempEvent);            
        }
        
        
        
        //  After Save, navigate to the default view page:  
            return (new ApexPages.StandardController(so)).view();
      }    
      
      public PageReference submitReadyToPrepare() {
              
        // update the event
        //so.Escalation_Comments__c = comments ;       
        project.Lease_Funding_Status__c = 'Ready to Prepare'; 
        update project;
         
        //  After Save, navigate to the default view page:  
        return (new ApexPages.StandardController(so)).view();
      }    
   
}