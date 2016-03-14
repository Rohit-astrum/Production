public with sharing class Sales_Order_Escalation_Controller {

    private SCRB_SalesOrder__c so;
    public boolean escalationDone {get; private set;}
    public String comments {get; set;} 
  
    public Sales_Order_Escalation_Controller(ApexPages.StandardController stdController) {
        so= (SCRB_SalesOrder__c) stdController.getRecord();  
        SCRB_SalesOrder__c sorder = [Select StatusCode__c from SCRB_SalesOrder__c Where Id = :so.Id];
        if (sorder != null && sorder.StatusCode__c == 'Escalated to Regional Director')
            escalationDone = true;          
    }

   public PageReference submitEscalation() {
    
    if(so.Escalation_Comments__c == null || so.Escalation_Comments__c.trim().length() == 0)
    {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Escalation Comments are Required.'));
        return null;
    }    
    else
    {
        if (so != null) {
              
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
                   
              so.StatusCode__c = 'Escalated to Regional Director'; 
              update so;
              
              
          // send notification email
          //Sales_Visit_Complete_Utility.sendNotificationEmail(tempEvent);            
        }
        
        
        
        //  After Save, navigate to the default view page:  
            return (new ApexPages.StandardController(so)).view();
      }    
    }
}