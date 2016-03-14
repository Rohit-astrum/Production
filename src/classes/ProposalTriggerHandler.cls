/* FILE: ProposalTriggerHandler.cls
   AUTHOR: Dan Kelner
   DATE: 12/08/14
   PURPOSE: Common trigger handler for Proposal
   MODIFICATION HISTORY: 
        07/07/15  DK  Allowed a user-defined expiration date to be set on a Proposal as per CPQ-416
*/
public class ProposalTriggerHandler {
    
    public static Boolean isProposalTriggerRunning = false;
    public static boolean skipProposalTrigger = false;

    private Boolean m_isExecuting = false;

    public ProposalTriggerHandler(Boolean isExecuting){      
        m_isExecuting = isExecuting;
    }

    public void OnBeforeInsert(Proposal__c[] newProposals){
        // EXECUTE BEFORE INSERT LOGIC 
        setProposalExpirationDate(newProposals);
        setOpenQuote(newProposals);
        m_isExecuting = false;
    }

    public void OnBeforeUpdate(Proposal__c[] updatedProposals, Map<ID, Proposal__c> proposalMap, Map<ID, Proposal__c> oldProposalMap){
        // BEFORE UPDATE LOGIC  
        closedProposalRules(proposalMap);
        //currentProposalRules(updatedProposals);
        setOpenQuote(updatedProposals);
        m_isExecuting = false;
    }

    public void OnAfterInsert(Proposal__c[] insertedProposals, Map<ID, Proposal__c> insertedProposalsMap){
        // EXECUTE AFTER INSERT LOGIC        
        m_isExecuting = false;
    }

    public void OnAfterUpdate(Proposal__c[] updatedProposals, Map<ID, Proposal__c> proposalMap, Map<ID, Proposal__c> oldProposalMap){
        //  EXECUTE AFTER UPDATE LOGIC
        
        m_isExecuting = false;
    }

    public Boolean IsTriggerContext {
        get { return m_isExecuting; }
    }
    
    //------------------------------------------------//
    
    //If one and only one child Contract is closed, than set the Proposal to closed as well
    public void closedProposalRules(Map<ID, Proposal__c> proposalMap){    //Called on "before update"
        Map<ID, Astrum_Contract__c> propClosedContracts = new Map<ID, Astrum_Contract__c>();    //Proposal ID --> Child Contract where Closed = true
        for (ID propID : proposalMap.keySet())
            propClosedContracts.put(propID, null);    //Populate Proposal ID keys
        Astrum_Contract__c[] closedContracts = [SELECT Scenario__c, Proposal__c FROM Astrum_Contract__c WHERE Closed__c = true AND Proposal__c IN :proposalMap.keySet()];
        
        for (Astrum_Contract__c contr : closedContracts){
            ID propID = contr.Proposal__c;
            if (!propClosedContracts.containsKey(propID))
                continue;    //This key has been deleted due to having more than one closed Contract
            if (propClosedContracts.get(propID) != null){
                //Another closed Contract has already been found for this Proposal. Since only one closed Contract is allowed, we will remove this key.
                propClosedContracts.remove(propID);
            } else {
                //Set this closed Contract to this Proposal key
                propClosedContracts.put(propID, contr);
            }
        }
        
        //Set the relevant fields on the Proposals
        for (ID propID : proposalMap.keySet()){
            Proposal__c prop = proposalMap.get(propID);
            if (propClosedContracts.get(propID) != null){
                //This Proposal has exactly one closed Contract
                prop.Closed__c = true;
                prop.Closed_Scenario__c = propClosedContracts.get(propID).Scenario__c;
            } else {
                //This Proposal has either zero or more than one closed Contracts
                prop.Closed__c = false;
                prop.Closed_Scenario__c = '';
            }
        }
        //No need for DML as long as this method is called from a "before" context
    }
    
    //public void currentProposalRules(Proposal__c[] updatedProposals){
    //    Set<ID> notCurrentPropIDs = new Set<ID>();
    //    for (Proposal__c prop : updatedProposals){
    //        if (prop.Current__c == false)
    //            notCurrentPropIDs.add(prop.ID);
    //    }
    //    if (notCurrentPropIDs.size() == 0)
    //        return;
        
    //    Astrum_Contract__c[] childContracts = [SELECT Current__c FROM Astrum_Contract__c WHERE Proposal__c IN :notCurrentPropIDs];
    //    for (Astrum_Contract__c contr : childContracts)
    //        contr.Current__c = false;
    //    update childContracts;
    //}
    
    public void setOpenQuote(Proposal__c[] props){
        for (Proposal__c prop : props){
            if (prop.Closed__c == false && prop.Proposal_Expiration_Date__c >= Date.today())
                prop.Open_Quote__c = true;
        }
        //No need for DML as long as this method is called from a "before" context
    }
    
    public void setProposalExpirationDate(Proposal__c[] props){
        Integer defaultDaysValid;
        try {
            defaultDaysValid = Integer.valueOf(System_Design_Quote_Settings__c.getOrgDefaults().Days_Proposal_Valid__c);
        } catch (NullPointerException e){
            System.debug('Error in ProposalTriggerHandler on line ' + e.getLineNumber());
        }
        if (defaultDaysValid == null)
            defaultDaysValid = 14;    //Fall-back value in case no custom setting is found (Useful for test classes)
        
        for (Proposal__c prop : props){
            if (prop.Proposal_Expiration_Date__c == null){   //Only set this default if no date value was specified
                prop.Days_Proposal_Valid__c = defaultDaysValid;
                prop.Proposal_Expiration_Date__c = Date.today().addDays(defaultDaysValid);
            }
        }
        //No need for DML as long as this method is called from a "before" context
    }
}