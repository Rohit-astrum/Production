public with sharing class Change_Request_Completion_Controller {

    private Change_Request__c cr;
    public boolean completionDone {get; private set;}
    public String comments {get; set;} 
    private static final Set<String> VALID_STATUS_FOR_COMPLETION = new Set<String> {
        'Approved/Pending', 'Completion Approval Rejected'
         };
  
    public Change_Request_Completion_Controller(ApexPages.StandardController stdController) {
        cr = (Change_Request__c) stdController.getRecord();  
        Change_Request__c crequest = [Select Status__c from Change_Request__c Where Id = :cr.Id];
        if (crequest != null && !(VALID_STATUS_FOR_COMPLETION.contains(crequest.Status__c)))
            completionDone = true;          
    }

   public PageReference submitCompletion() {
    
    if(comments == null || comments.trim().length() == 0)
    {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Completion Comments are Required.'));
        return null;
    }    
    else
    {
        if (cr != null) {
              cr.Completion_Comments__c = comments ;       
              cr.Status__c = 'Completion Approval Pending'; 
              update cr;
                 
        }
            return (new ApexPages.StandardController(cr)).view();
      }    
    }
}