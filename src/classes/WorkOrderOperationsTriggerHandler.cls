/* FILE: WorkOrderOperationsTriggerHandler.cls
 * AUTHOR: Lawrence Hovind
 * DATE: July 09, 2014
 * PURPOSE: Work Order Operations Trigger Handler
 * MODIFICATION HISTORY
 *
 */
public class WorkOrderOperationsTriggerHandler {

   private boolean m_isExecuting = false;

	public WorkOrderOperationsTriggerHandler(boolean isExecuting) {
		m_isExecuting = isExecuting;
	}

    public void OnBeforeInsert(rstk__woordop__c[] newWorkOrderOperations){
        // EXECUTE BEFORE INSERT LOGIC
        
        // LLH - additions

        //List<Id> workOrderIds = new List<Id>();
        // copy the Electrician/Installer Bonus Hrs from the Install Project to the appropriate Run Std Hrs
        RootstockAutomation.updateWOOpsFromInstallProjs( newWorkOrderOperations, null, null, false);

        // end - LLH
    }
    /*
    public void OnAfterUpdate(rstk__woordop__c[] updatedWorkOrderOperations, Map<Id,rstk__woordop__c> WorkOrderOperationsMap){
        //  EXECUTE AFTER UPDATE LOGIC       
    }

    public void OnAfterInsert(rstk__woordop__c[] newWorkOrderOperations){
        // EXECUTE AFTER INSERT LOGIC
    }
	
    public void OnBeforeUpdate(rstk__woordop__c[] oldObjects, rstk__woordop__c[] updatedObjects, Map<Id,rstk__woordop__c> oldMap){
        // BEFORE UPDATE LOGIC
    }
    */
    /*
    public void OnBeforeDelete(Object[] ObjectsToDelete, Map<Id,Lead> MapObjectMap){
        // BEFORE DELETE LOGIC
    }

    public void OnAfterDelete(Object[] deletedObjects, Map<Id,Lead> MapObjectMap){
        // AFTER DELETE LOGIC
    }

    public void OnUndelete(Object[] restoredObjects){
        // AFTER UNDELETE LOGIC
    }
    */
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }

}