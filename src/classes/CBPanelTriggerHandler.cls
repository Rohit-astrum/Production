/* FILE: CBPanelTriggerHandler.cls
 * AUTHOR: Mike Katulka
 * DATE: 2014-08-28
 * PURPOSE: Common trigger handler for CB Panel
 * MODIFICATION HISTORY: 
 *
 */
public class CBPanelTriggerHandler {
	
	public static boolean isCBPanelTriggerRunning = false;
    public static boolean skipCBPanelTrigger = false;

    private boolean m_isExecuting = false;

    public CBPanelTriggerHandler (boolean isExecuting){    	
        m_isExecuting = isExecuting;

    }



    //***This was created originally for syncing utility service values into the SD, but was not needed
	//since it's a master detail to the Utility Service and can't be reparented.
	//

	

    //public void OnBeforeInsert(CB_Panel__c[] newCBPanels){
    //    // EXECUTE BEFORE INSERT LOGIC        
        
    //    m_isExecuting = false;
    //}

    //public void OnBeforeUpdate(CB_Panel__c[] updatedCBPanels, Map<Id,CB_Panel__c> CBPanelMap, Map<Id,CB_Panel__c> oldCBPanelMap){
    //    // BEFORE UPDATE LOGIC  
		
    //    m_isExecuting = false;
    //}

    //public void OnAfterInsert(CB_Panel__c[] insertedCBPanels, map<id, CB_Panel__c> insertedCBPanelsMap){
    //    // EXECUTE AFTER INSERT LOGIC        
        
    //    m_isExecuting = false;
    //}

    //public void OnAfterUpdate(CB_Panel__c[] updatedCBPanels, Map<Id,CB_Panel__c> CBPanelMap, Map<Id,CB_Panel__c> oldCBPanelMap){
    //    //  EXECUTE AFTER UPDATE LOGIC
        
    //    m_isExecuting = false;
    //}

    
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