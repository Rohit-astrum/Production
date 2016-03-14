public class HandoffApprovalHistoryController {
    public String pmId {get;set;}    
    public String getcomments() {
      if (pmId != null) {
        PM_Project__c project= [Select Id, (Select TargetObjectId, SystemModstamp, StepStatus, RemindersSent, ProcessInstanceId, OriginalActorId, IsPending, IsDeleted, Id, CreatedDate, CreatedById, Comments, Actor.Name From ProcessSteps Where StepStatus In ('Approved', 'Rejected')  order by SystemModstamp desc Limit 1) from  PM_Project__c where Id = :pmId];
        return project.ProcessSteps[0].Actor.Name+': '+project.ProcessSteps[0].comments;
      }
      return '';
    } 

}