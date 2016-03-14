/* FILE: AvailableIncentiveOfferTriggerHandler.cls
   AUTHOR: Dan Kelner
   DATE: 12/31/14
   PURPOSE: Common trigger handler for Available_Incentive_Offer__c
   MODIFICATION HISTORY: 
*/
public class AvailableIncentiveOfferTriggerHandler {
    
    public static Boolean isAvailableIncentiveOfferTriggerRunning = false;
    public static boolean skipAvailableIncentiveOfferTrigger = false;

    private Boolean m_isExecuting = false;

    public AvailableIncentiveOfferTriggerHandler(Boolean isExecuting){      
        m_isExecuting = isExecuting;
    }

    public void OnBeforeInsert(Available_Incentive_Offer__c[] newAIOs){
        // EXECUTE BEFORE INSERT LOGIC 
        
        m_isExecuting = false;
    }

    public void OnBeforeUpdate(Available_Incentive_Offer__c[] updatedAIOs, Map<ID, Available_Incentive_Offer__c> AIOMap, Map<ID, Available_Incentive_Offer__c> oldAIOMap){
        // BEFORE UPDATE LOGIC  
        
        m_isExecuting = false;
    }

    public void OnAfterInsert(Available_Incentive_Offer__c[] insertedAIOs, Map<ID, Available_Incentive_Offer__c> insertedAIOMap){
        // EXECUTE AFTER INSERT LOGIC 
               
        m_isExecuting = false;
    }

    public void OnAfterUpdate(Available_Incentive_Offer__c[] updatedAIOs, Map<ID, Available_Incentive_Offer__c> AIOMap, Map<ID, Available_Incentive_Offer__c> oldAIOMap){
        //  EXECUTE AFTER UPDATE LOGIC
        
        m_isExecuting = false;
    }

    public Boolean IsTriggerContext {
        get { return m_isExecuting; }
    }
    
    //------------------------------------------------//
    
}