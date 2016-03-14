public with sharing class Change_Request_Escalation_Controller {

    private Change_Request__c cr;
    public boolean escalationDone {get; private set;}
     public boolean escalationNotAllowed {get; private set;}
    public String comments {get; set;} 
    private static final Set<String> ESCALATE_ALLOWED = new Set<String> {
        'Rejected','Submitted','Master Electrician Rejected','Accounting Rejected'
    };


  
    public Change_Request_Escalation_Controller(ApexPages.StandardController stdController) {
        cr = (Change_Request__c) stdController.getRecord();  
        Change_Request__c crequest = [Select Status__c from Change_Request__c Where Id = :cr.Id];
        if (crequest != null && crequest.Status__c == 'Submitted for Electrical Review')
            escalationDone = true;  
        if (crequest != null && !(ESCALATE_ALLOWED.contains(crequest.Status__c)))
            escalationNotAllowed = true;              
    }

   public PageReference submitEscalation() {
    
    if(comments == null || comments.trim().length() == 0)
    {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Escalation Comments are Required.'));
        return null;
    }    
    else
    {
        if (cr != null) {
             
              
               try{
                  List<ProcessInstanceWorkitem> processitems = [Select ID From ProcessInstanceWorkitem p Where p.ProcessInstance.TargetObjectId = :cr.Id and 
                                            p.ProcessInstance.Status = 'Pending'];
                  for(ProcessInstanceWorkitem processItem : processitems )
                  {
                      
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
              cr.Escalation_Comments__c = comments ;       
              cr.Status__c = 'Submitted for Electrical Review'; 
              update cr;
              
              
          // send notification email
          //Sales_Visit_Complete_Utility.sendNotificationEmail(tempEvent);            
        }
        
        
        
        //  After Save, navigate to the default view page:  
            return (new ApexPages.StandardController(cr)).view();
      }    
    }
}