/*
    07/30/15  DK  Allowed profile types "Senior Project Compliance Associate", "Lease Administrator", and "Director, Pricing & Analysis" to cancel the Change Request. See MIS-170.
*/
public with sharing class Change_Request_Cancellation_Controller {

    private Change_Request__c cr;
    public boolean cancelDone {get; private set;}
    public boolean accessNotAllowed {get; private set;}
    public String comments {get; set;}    
  
    public Change_Request_Cancellation_Controller(ApexPages.StandardController stdController) {
        if (!Test.isRunningTest())
            stdController.addFields(new String[]{'Status__c', 'CreatedById'});
        cr = (Change_Request__c) stdController.getRecord();  
        //Change_Request__c crequest = [Select Status__c, CreatedById from Change_Request__c Where Id = :cr.Id];

        if (cr == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'No Change Request found.'));
            return;
        }

        User currentUser = [SELECT Profile.Name FROM User WHERE ID = :UserInfo.getUserId() LIMIT 1];
        Set<String> allowedProfiles = new Set<String>{'Senior Project Compliance Associate', 'Lease Administrator', 'Director, Pricing & Analysis'};
        if (cr.CreatedById != currentUser.ID && !allowedProfiles.contains(currentUser.Profile.Name)){
            accessNotAllowed = true;    
        }

        if (cr.Status__c == 'Cancelled'){
            cancelDone = true;          
        }    
    }

   public PageReference submitCancellation() {
    
    if(comments == null || comments.trim().length() == 0)
    {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Comments are Required to Cancel the Change Request.'));
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
        
              cr.Completion_Comments__c = comments ;       
              cr.Status__c = 'Cancelled'; 
              update cr;
                 
        }
            return (new ApexPages.StandardController(cr)).view();
      }    
    }
}