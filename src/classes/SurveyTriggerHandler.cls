/* FILE: SurveyTriggerHandler.cls
 * AUTHOR: Michael Katulka
 * DATE: 2014-05-13
 * PURPOSE: 
 * MODIFICATION HISTORY: 
 *
 */
public with sharing class SurveyTriggerHandler {
	private boolean m_isExecuting = false;

	public SurveyTriggerHandler(boolean isExecuting) {
		m_isExecuting = isExecuting;
	}
    
    //public void OnBeforeInsert(Survey__c[] newSurvey){
    //    // EXECUTE BEFORE INSERT LOGIC
    //    defaultUtilityCompany(newSurvey);
    //    m_isExecuting = false;
    //}

    public void OnAfterUpdate(Survey__c[] updatedSurveys, Map<Id,Survey__c> surveyMap){
        //  EXECUTE AFTER UPDATE LOGIC       
        updateInstallLocations(updatedSurveys);
        m_isExecuting = false;
    }

    /*
    public void OnAfterInsert(Survey__c[] newObjects){
        // EXECUTE AFTER INSERT LOGIC
    }

    public void OnBeforeUpdate(Survey__c[] oldObjects, Survey__c[] updatedObjects, Map<Id,Lead> MapObjectMap){
        // BEFORE UPDATE LOGIC
    }

    
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

    private void updateInstallLocations(Survey__c[] updatedSurveys)
    {        
        //After update - Need to update all SDI records.
        //Here we can simply update all child Install Location records and let that trigger fire.  The good thing here will be that if in the futre we add logic to
        //the Install Location trigger that pulls data from Survey, it will automatically run as needed. 
        List<Install_Location__c> ilsToUpdate = [Select id from Install_Location__c where Survey__c in: updatedSurveys];
        update(ilsToUpdate);
    }
}