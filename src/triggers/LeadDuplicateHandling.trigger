/* FILE: LeadDuplicateHandling.trigger
 * AUTHOR: Rohit Jain
 * DATE: Apr 18, 2013
 * PURPOSE: New Leads that come in with the same address should be marked as Status "Not a Lead - DUPLICATE"
 * MODIFICATION HISTORY
 * 
 */
 
trigger LeadDuplicateHandling on Lead (before insert, before update) {
    //don't perform updates if bypass is on	
	if (TriggerUtility.bypassLeadTriggersForBatchProcessing) { return; }
	
    Map<String, Lead> leadMap = new Map<String, Lead>();
    List<Lead> leadsTask = new List<Lead>();
    Map<Lead , Lead> leadsDupMap = new Map<Lead , Lead>(); 
    Map<Id , Lead> OppIdLeadMap = new Map<Id, Lead>(); 
    Lead_Trigger_Utility ltu ;
    
    String addressKey;
    
    for (Lead l : Trigger.new) {
        if ( Trigger.isInsert
            || l.Street != Trigger.oldMap.get(l.Id).Street
            || l.City != Trigger.oldMap.get(l.Id).City
            || l.State != Trigger.oldMap.get(l.Id).state
            || l.PostalCode != Trigger.oldMap.get(l.Id).PostalCode
            )
         {
            addressKey = '';
            if(l.Street != null)
                addressKey = addressKey + l.Street.toUpperCase();
            if(l.City != null)                    
                addressKey = addressKey + l.City.toUpperCase();
            if(l.State != null)                        
                addressKey = addressKey + l.State.toUpperCase();
            if(l.PostalCode != null)                            
                addressKey = addressKey + l.PostalCode.toUpperCase() ;            
            
            System.debug('*DupTest '+addressKey );
            
            if(addressKey != '')
            {
                if (leadMap.containsKey(addressKey )) {
                    l.Status = 'Not a Lead - DUPLICATE';               
                } else {
                    leadMap.put(addressKey , l);
                }
            }        
        }
    }
    
    for (Lead oldlead : [SELECT Name, Id, Address_Key__c , Status , Owner.Email,IsConverted,ConvertedOpportunityId FROM Lead
                      WHERE Address_key__c IN :leadMap.KeySet() and Status != 'Not a Lead - DUPLICATE']) {       
               
       System.debug('*DupTest 2 exist -- '+oldlead.Id);
                        
       Lead newLead = leadMap.get(oldlead.Address_key__c);
       System.debug('*DupTest 2 new -- '+newLead .Id);
       if(oldlead.Id <> newLead.Id) {
           
           if(!oldlead.IsConverted)
           {
               leadsDupMap.put(oldlead,newLead);
               leadsTask.add(oldlead );
               newLead.Status = 'Not a Lead - DUPLICATE'; 
           }
           else
           {
               OppIdLeadMap.put(oldlead.ConvertedOpportunityId , oldlead ); 
           }    
       }    
    }       
     
     if(!leadsTask.isEmpty() || !OppIdLeadMap.isEmpty() )
     {
         ltu = new Lead_Trigger_Utility();
     }
     if (!leadsTask.isEmpty()) {
            System.debug('*DupTest 2 '+leadsTask.size());            
            ltu.createTasksForLeads(leadsDupMap);
            ltu.sendEmailForLeads(leadsTask);           
     } 
     if(!OppIdLeadMap.isEmpty())
     {
          ltu.sendEmailForOpps(OppIdLeadMap,leadMap);
     }
}