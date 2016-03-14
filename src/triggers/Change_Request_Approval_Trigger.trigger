trigger Change_Request_Approval_Trigger on Change_Request__c (after update) {

    Map<Id,Change_Request__c> changeRequestToSubmit = new Map<Id,Change_Request__c>();   
    Set<Id> changeRequestPendingApproval = new Set<Id>();

    //check if sales order should be submitted
    for (Change_Request__c rec : Trigger.new) {
        System.debug('*Change Request --> ' + rec.Status__c);
        if (rec.Status__c == 'Submitted for Electrical Review' || rec.Status__c == 'Completion Approval Pending' || rec.Status__c == 'Master Electrician Rejected' || rec.Status__c == 'Accounting Rejected') {
            changeRequestToSubmit.put(rec.Id, rec);
        }       
    } 

    //stop here if no sales orders need to be submitted
    if (!(changeRequestToSubmit.isEmpty())) {
    
        //find pending approvals
        List<ProcessInstance> pendingApproval = 
            [SELECT TargetObjectId
            FROM ProcessInstance
            WHERE TargetObjectId IN :changeRequestToSubmit.keyset()
            AND Status = 'Pending'];
        for (ProcessInstance pi : pendingApproval) {
            System.debug('* Pending there - '+pi.TargetObjectId);
            changeRequestPendingApproval.add(pi.TargetObjectId);
        } 
    
        for (Id changeRequestId : changeRequestToSubmit.keyset()) {
            System.debug('Change Request --> ' + Trigger.newMap.get(changeRequestId ));
        
            if (!changeRequestPendingApproval.contains(changeRequestId)) {
                //Submit for Approval
                // Create an approval request for the account
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments(changeRequestToSubmit.get(changeRequestId).Status__c+' - Auto-Submitted.');
                req1.setObjectId(changeRequestId);
                // Submit the approval request for the account
                Approval.ProcessResult result = Approval.process(req1);
                // Verify the result
                //System.assert(result.isSuccess());
            }
            
        }
     } 
}