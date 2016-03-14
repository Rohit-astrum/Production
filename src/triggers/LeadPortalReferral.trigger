/* FILE: LeadPortalReferral.trigger
 * AUTHOR: Tino Mattheou
 * DATE: July 19, 2012
 * PURPOSE: sets the opportunity on the portal referral if the lead came from the partner portal
 * MODIFICATION HISTORY
 *     10/09/2012 TCM - updates to connect referring account leads to portal
 *     10/17/2014 DK - Replaced Community_Program__c with Community_Program_Offer__c wherever applicable. Commented lines are subject to change.
 */
 
trigger LeadPortalReferral on Lead (after insert, after update, before delete, after delete) {
    //don't perform updates if bypass is on 
    if (TriggerUtility.bypassLeadTriggersForBatchProcessing) { return; }
    
    List<Lead> leadsUpdated = new List<Lead>(); 
    Set<Id> opportunityIds = new Set<Id>();
    Set<Id> referringAccountIds = new Set<Id>();
    Map<Id, Portal_Referral__c> leadReferralMap = new Map<Id, Portal_Referral__c>();
    Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
    Map<Id, Account> accountMap = new Map<Id, Account>();
    List<Portal_Referral__c> referralsToUpdate = new List<Portal_Referral__c>();

    if (Trigger.isDelete) {
        if (Trigger.isBefore) {
            PortalReferralStatus.duplicateReferrals = 
                [SELECT Id, Status__c, Lead__c
                FROM Portal_Referral__c
                WHERE Lead__c IN :Trigger.oldMap.keySet()];
        } else if (Trigger.isAfter) {
            if (PortalReferralStatus.duplicateReferrals != null && !PortalReferralStatus.duplicateReferrals.isEmpty()) {
                for (Portal_Referral__c referral : PortalReferralStatus.duplicateReferrals) {
                    referralsToUpdate.add(new Portal_Referral__c(
                        Id = referral.Id,
                        Status__c = PortalReferralStatus.DUPLICATE_STATUS
                    ));
                }
                if (!referralsToUpdate.isEmpty()) {
                    update referralsToUpdate;
                }
            }
        }
        return;
    }

    //which lead changes affect portal referrals    
    for (Lead l : Trigger.new) {
        if (Trigger.isInsert
        || l.Status != Trigger.oldMap.get(l.Id).Status
        || l.On_Hold_Until__c != Trigger.oldMap.get(l.Id).On_Hold_Until__c
        || l.Unqualified_Reason__c != Trigger.oldMap.get(l.Id).Unqualified_Reason__c
        || l.Referring_Account__c != Trigger.oldMap.get(l.Id).Referring_Account__c
        || l.Community_Program_Offer__c != Trigger.oldMap.get(l.Id).Community_Program_Offer__c
        || (l.IsConverted == true && Trigger.oldMap.get(l.Id).IsConverted == false && l.ConvertedOpportunityId != null)) {

            leadsUpdated.add(l);
            System.debug('* '+l.name);
            if (Trigger.isUpdate && l.IsConverted == true && Trigger.oldMap.get(l.Id).IsConverted == false && l.ConvertedOpportunityId != null) {
                opportunityIds.add(l.ConvertedOpportunityId);
            }
            
            if (l.Referring_Account__c != null) {
                System.debug('* '+l.Referring_Account__c);
                referringAccountIds.add(l.Referring_Account__c);
            }
            
        }
    }
    
    if (!leadsUpdated.isEmpty()) {
        
   

        //get portal referrals associated to the updated leads
        List<Portal_Referral__c> referrals = 
            [SELECT Id, Lead__c, Opportunity__c, Account__c, Status__c, Detail__c, Last_Status_Change_Date__c, Community_Program__c, Community_Program_Offer__c 
            FROM Portal_Referral__c
            WHERE Lead__c IN :leadsUpdated];
        for (Portal_Referral__c referral : referrals) {
            leadReferralMap.put(referral.Lead__c, referral);
        }
        
        //get opportunities for just converted leads
        if (!opportunityIds.isEmpty()) {
            opportunityMap = new Map<Id, Opportunity>(
                [SELECT Id, CreatedDate, StageName, On_Hold_Until__c, Date_Site_Survey_Completed__c, Closed_Reason__c, Closed_Type__c,
                    (SELECT Id, EndDateTime 
                    FROM Events
                    WHERE RecordType.DeveloperName LIKE 'Sales_Visit%' 
                    AND Completed__c = true
                    ORDER BY EndDateTime
                    LIMIT 1)
                FROM Opportunity
                WHERE Id IN :opportunityIds]
            );
        }
    
        //get referring accounts if any
        if (!referringAccountIds.isEmpty()) {
            accountMap = new Map<Id, Account>(
                [SELECT Id, Portal_Payment_Plan__c, IsCustomerPortal
                FROM Account
                WHERE Id IN :referringAccountIds]
            ); 
        }   
        
        for (Lead l : leadsUpdated) {
            Portal_Referral__c referral = leadReferralMap.get(l.Id);
            System.debug('* referral - '+referral );
            //opportunity drives referral status
            if (referral != null && referral.Opportunity__c != null) {
                continue;
            }
            if (referral == null && PortalReferralStatus.creatingLeadInPortal != true) { 
                //create referral is referring account has payment plan and is customer portal enabled
                if (l.Referring_Account__c != null) {
                    Account a = accountMap.get(l.Referring_Account__c);
                    if (a != null && a.Portal_Payment_Plan__c != null && a.IsCustomerPortal == true) {
                        referral = new Portal_Referral__c (
                            First_Name__c = l.FirstName,
                            Last_Name__c = l.LastName,
                            Email__c = l.Email,
                            Phone__c = l.Phone,
                            Account__c = a.Id,
                            Street__c = l.Street,
                            City__c = l.City,
                            State__c = l.State,
                            Zip__c = l.PostalCode,
                            Community_Program__c = l.Community_Program__c, 
                            Community_Program_Offer__c = l.Community_Program_Offer__c, 
                            Opportunity__c = l.ConvertedOpportunityId,
                            Last_Status_Change_Date__c = System.today(),
                            Portal_Payment_Plan__c = a.Portal_Payment_Plan__c,
                            Lead_Created_Date__c = l.CreatedDate.date()
                            
                        );
                    } 
                }
                else if (l.Community_Program_Offer__c != null)
                {
                     referral = new Portal_Referral__c (
                            First_Name__c = l.FirstName,
                            Last_Name__c = l.LastName,
                            Email__c = l.Email,
                            Phone__c = l.Phone,
                            Account__c = l.Referring_Account__c,
                            Street__c = l.Street,
                            City__c = l.City,
                            State__c = l.State,
                            Zip__c = l.PostalCode,
                            Community_Program__c = l.Community_Program__c, 
                            Community_Program_Offer__c = l.Community_Program_Offer__c, 
                            Opportunity__c = l.ConvertedOpportunityId,
                            Last_Status_Change_Date__c = System.today(),
                            //Portal_Payment_Plan__c = a.Portal_Payment_Plan__c,
                            Lead_Created_Date__c = l.CreatedDate.date()
                            
                        );
                
                }
            }
            if (referral != null) {
                if (l.ConvertedOpportunityId != null) {
                    if (l.IsConverted == true && Trigger.oldMap.get(l.Id).IsConverted == false) {
                        Opportunity opp = opportunityMap.get(l.ConvertedOpportunityId);
                        Event evt;
                        if (opp != null && !opp.Events.isEmpty()) {
                            evt = opp.Events[0];
                        }
                        referral.Opportunity__c = l.ConvertedOpportunityId;
                        referralsToUpdate.add(referral);
                        PortalReferralStatus.setReferralStatus(l, opp, evt, referral);
                    }
                } else {
                    referral.Lead__c = l.Id;  //can only set this for non-converted leads                
                     
                    System.debug('* 2a referral - '+referral );            
                    if (PortalReferralStatus.setReferralStatus(l, null, null, referral)) {
                        referral.Account__c = l.Referring_Account__c; 
                        referral.Community_Program__c = l.Community_Program__c ;
                        if (l.Community_Program_Offer__c != null)
                        	referral.Community_Program_Offer__c = l.Community_Program_Offer__c;
                        referralsToUpdate.add(referral);
                    }
                    else if(referral.Account__c != l.Referring_Account__c || referral.Community_Program_Offer__c != l.Community_Program_Offer__c  )
                    {
                         System.debug('* 2 referral - '+referral );
                        referral.Account__c = l.Referring_Account__c;   
                        referral.Community_Program__c = l.Community_Program__c ;
                        if (l.Community_Program_Offer__c != null)
                        	referral.Community_Program_Offer__c = l.Community_Program_Offer__c;
                        referralsToUpdate.add(referral);
                    }    
                }
            }
        }
        
        if (!referralsToUpdate.isEmpty()) {
            System.debug('* 2 referralsToUpdate- '+referralsToUpdate);
            PortalReferralStatus.processUnsoldEarnings(referralsToUpdate);  
            upsert referralsToUpdate;
        }
    }
    // Property Creation after Portal Referral Logic
    if(Trigger.isUpdate)
    {   
        Lead_Trigger_Utility ltu = new Lead_Trigger_Utility();
        ltu.handlePropertyCreation_AU(Trigger.newMap);
    }       
}