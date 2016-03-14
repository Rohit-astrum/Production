/* FILE: InstallProjectTriggerHandler.cls
 * AUTHOR: Lawrence Hovind
 * DATE: July 15, 2014
 * PURPOSE: Install Project Trigger Handler
 * MODIFICATION HISTORY
 *
 */
public class InstallProjectTriggerHandler {

   private boolean m_isExecuting = false;

	public InstallProjectTriggerHandler(boolean isExecuting) {
		m_isExecuting = isExecuting;
	}

    public void OnBeforeInsert(Install_Project__c[] newInstallProject){
        // EXECUTE BEFORE INSERT LOGIC
        
    }

    public void OnAfterUpdate(Install_Project__c[] updatedInstallProjects, Map<Id,Install_Project__c> InstallProjectsMap){
        //  EXECUTE AFTER UPDATE LOGIC       
        
        // LLH - additions

        // check Electrician/Installer Bonus Hrs match Work Order Operations (20,10) Run Std Hrs - change if necessary
        // loop through the list to see which ones need updating
    
        Map<Id, Install_Project__c> installProjsMap = new Map<Id, Install_Project__c>();
        List<Id> workOrderIds = new List<Id>();
        		
        for( Install_Project__c proj : updatedInstallProjects ) {
	        	// collect Work Order Ids
	        	workOrderIds.add( proj.Work_Order__c);
	        	// put the Install Projects in a Map<> indexed by Work Order
	        	installProjsMap.put(proj.Work_Order__c, proj);
        }
    	RootstockAutomation.updateWOOpsFromInstallProjs( null, installProjsMap, workOrderIds);
        // end - LLH
        
    }

    public void OnAfterInsert(Install_Project__c[] newInstallProjects){
        // EXECUTE AFTER INSERT LOGIC
    }
	
    public void OnBeforeUpdate(Install_Project__c[] oldObjects, Install_Project__c[] updatedObjects, Map<Id,Install_Project__c> oldMap){
        // BEFORE UPDATE LOGIC
    }

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