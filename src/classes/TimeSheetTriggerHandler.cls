/* FILE: TimeSheetTriggerHandler.cls
   AUTHOR: Steve Zilligen
   DATE: 2015-03-26
   PURPOSE: Common trigger handler for Time Sheet
*/
public class TimeSheetTriggerHandler {
    
    private boolean m_isExecuting = false;
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }

    public TimeSheetTriggerHandler (boolean isExecuting){      
        m_isExecuting = isExecuting;
    }

	/*
    public void OnBeforeInsert(Time_Sheet__c[] newTimesheets){
        // EXECUTE BEFORE INSERT LOGIC  
        m_isExecuting = false;
    }

    public void OnBeforeUpdate(Time_Sheet__c[] updatedTimesheets, Map<Id,Time_Sheet__c> newTimesheetsMap, Map<Id,Time_Sheet__c> oldTimeSheetsMap){
        // BEFORE UPDATE LOGIC  
        m_isExecuting = false;
    }
    */
    
    public void OnBeforeDelete(Map<Id, Time_Sheet__c> oldTimeSheetsMap){
        // BEFORE DELETE LOGIC
		TimeSheetDeleteUtility.copyTimeSheetToDeletedTimeSheet(oldTimeSheetsMap);
        m_isExecuting = false;
    }

    public void OnAfterInsert(Time_Sheet__c[] insertedTimeSheets, Map<Id, Time_Sheet__c> insertedTimeSheetsMap){
        // EXECUTE AFTER INSERT LOGIC        
        Time_Sheet_Trigger_Utility.computeHoursAndPay(insertedTimeSheetsMap, null);       // Added new Parameter by RJ for Zen - 84 bug Fix  
        m_isExecuting = false;
    }

    public void OnAfterUpdate(Time_Sheet__c[] updatedTimeSheets, Map<Id,Time_Sheet__c> updatedTimeSheetsMap, Map<Id,Time_Sheet__c> oldTimeSheetsMap){
        //  EXECUTE AFTER UPDATE LOGIC
        Time_Sheet_Trigger_Utility.computeHoursAndPay(updatedTimeSheetsMap, null);       // Added new Parameter by RJ for Zen - 84 bug Fix  
        m_isExecuting = false;
    }

    public void OnAfterDelete(Map<Id, Time_Sheet__c> oldTimeSheetsMap){
        // AFTER DELETE LOGIC
    	Time_Sheet_Trigger_Utility.computeHoursAndPay(oldTimeSheetsMap, null);      
        m_isExecuting = false;
    }

    /*
    public void OnUndelete(Object[] restoredObjects){
        // AFTER UNDELETE LOGIC
    }
    */
}