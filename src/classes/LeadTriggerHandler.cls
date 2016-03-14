/* FILE: LeadTriggerHandler.cls
 * AUTHOR: Mike Katulka
 * DATE: 2014-08-21
 * PURPOSE: Common trigger handler for Lead
 * MODIFICATION HISTORY: 
 *
 */
public class LeadTriggerHandler {
    
    //Prevent unwanted recursion issues
    public static boolean isLeadTriggerRunning = false;
    public static boolean skipLeadTrigger = false;  

    private boolean m_isExecuting = false;

    public LeadTriggerHandler(boolean isExecuting){     
        m_isExecuting = isExecuting;
    }

    public void OnBeforeInsert(Lead[] newLeads){
        // EXECUTE BEFORE INSERT LOGIC
        
        //Match up the community program offers and fill these fields in
        getCommunityProgramOffers(newLeads);

        m_isExecuting = false;
    }

    public void OnBeforeUpdate(Lead[] updatedLeads, Map<Id,Lead> LeadMap, Map<Id,Lead> oldLeadMap){
        // BEFORE UPDATE LOGIC      
        
        //Match up the community program offers and fill these fields in
        getCommunityProgramOffers(updatedLeads);
        
        m_isExecuting = false;
    }

    public void OnAfterInsert(Lead[] insertedLeads, map<id, Lead> insertedLeadsMap){
        // EXECUTE AFTER INSERT LOGIC
        m_isExecuting = false;
    }

    public void OnAfterUpdate(Lead[] updatedLeads, Map<Id,Lead> LeadMap, Map<Id,Lead> oldLeadMap){
        //  EXECUTE AFTER UPDATE LOGIC     
        m_isExecuting = false;
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

    private void getCommunityProgramOffers(list<Lead> Leads){
        system.debug('getCommunityProgramOffers');

        //Call common class to 
        CommunityProgramOfferUtility.matchCommunityProgramOffer(Leads);
    }
}