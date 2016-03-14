public class ChangeRequestApprovalHistoryController {
    public String crId {get;set;}    
    public String getcomments() {
      if (crId != null) {
        Change_Request__c changerequest = [Select Id, (Select TargetObjectId, SystemModstamp, StepStatus, RemindersSent, ProcessInstanceId, OriginalActorId, IsPending, IsDeleted, Id, CreatedDate, CreatedById, Comments, Actor.Name From ProcessSteps Where StepStatus In ('Approved', 'Rejected')  order by createdDate desc Limit 1) from  Change_Request__c where Id = :crId];
        return changerequest.ProcessSteps[0].Actor.Name+': '+changerequest.ProcessSteps[0].comments;
      }
      return '';
    } 

}