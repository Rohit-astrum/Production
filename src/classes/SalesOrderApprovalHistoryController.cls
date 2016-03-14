public class SalesOrderApprovalHistoryController {
    public String soId {get;set;}    
    public String getcomments() {
      if (soId != null) {
        SCRB_SalesOrder__c sorder = [Select Id, (Select TargetObjectId, SystemModstamp, StepStatus, RemindersSent, ProcessInstanceId, OriginalActorId, IsPending, IsDeleted, Id, CreatedDate, CreatedById, Comments, Actor.Name From ProcessSteps Where StepStatus In ('Approved', 'Rejected')  order by SystemModstamp desc Limit 1) from  SCRB_SalesOrder__c where Id = :soId];
        return sorder.ProcessSteps[0].Actor.Name+': '+sorder.ProcessSteps[0].comments;
      }
      return '';
    } 

}