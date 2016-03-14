/* FILE: PMProjectDateTrigger.trigger
 * AUTHOR: Tino Mattheou
 * DATE: May 21, 2012
 * PURPOSE: Sets the Kickoff, Install, and Inspection last updated fields  
 * MODIFICATION HISTORY
 *
 */ 
trigger PMProjectDateTrigger on PM_Project__c (before insert, before update) {
    Map<Id, PM_Project__c> projectsToCapture  = new Map<Id,PM_Project__c>();   
    for (PM_Project__c project : Trigger.new) {
    
        if ((Trigger.isInsert && project.Kickoff__c != null)
        || ((Trigger.isUpdate && project.Kickoff__c != Trigger.oldMap.get(project.Id).Kickoff__c))) {
            project.Kickoff_Last_Updated__c = DateTime.now();
        }

        if ((Trigger.isInsert && project.Install__c != null)
        || ((Trigger.isUpdate && project.Install__c != Trigger.oldMap.get(project.Id).Install__c))) {
            project.Install_Last_Updated__c = DateTime.now();
        }

        if ((Trigger.isInsert && project.Inspection__c != null)
        || ((Trigger.isUpdate && project.Inspection__c != Trigger.oldMap.get(project.Id).Inspection__c))) {
            project.Inspection_Last_Updated__c = DateTime.now();
        }
        System.debug('** project.Approval_Comment_Check__C '+project.Approval_Comment_Check__C);
        if (project.Approval_Comment_Check__C == 'Required') {
            System.debug('** Required');
            projectsToCapture .put(project.Id, project );
            project.Approval_Comment_Check__C = null;
        }
        
        
    }
    
    if (!projectsToCapture.isEmpty())  
    {  
        Id oldTargetId;
        for (PM_Project__c pi : [SELECT Id , 
                              (  
                                 SELECT Id, StepStatus, Comments 
                                 FROM ProcessSteps Where StepStatus in ('Approved', 'Rejected') order by SystemModstamp desc Limit 1) from  PM_Project__c where Id in
                                 :projectsToCapture.keySet() 
                               ORDER BY CreatedDate DESC
                              ])                      
        {
                      
            System.debug('**Comm- size '+pi.ProcessSteps.Size());
            if (pi.ProcessSteps.Size()> 0 )
            {   
                System.debug('**Comm-'+pi.ProcessSteps[0].Comments);
                if ((pi.ProcessSteps[0].Comments == null || 
           pi.ProcessSteps[0].Comments.trim().length() == 0))
                {
               //    projectsToCapture.get(pi.Id).addError(
          //'Operation Cancelled: Please provide a reason for Approval/Rejection !'); 
                    System.debug('**No Comments');  
                }
                else
                {
                    System.debug('**Comm-'+pi.ProcessSteps[0].Comments);                   
                    projectsToCapture.get(pi.Id).HAndoff_Customer_Care_Comments__C = pi.ProcessSteps[0].Comments;
                } 
               
            } 
            
        }     
    }

}