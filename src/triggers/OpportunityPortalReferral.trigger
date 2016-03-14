/* FILE: OpportunityPortalReferral.trigger
 * AUTHOR: Tino Mattheou
 * DATE: July 19, 2012
 * PURPOSE: updates the portal referral status if the opportunity is related to a portal referral
 * MODIFICATION HISTORY
 *     10/09/2012 TCM - updates to connect referring account leads to portal
 *     09/12/2013 RJ - updates to create Referral record for Communit Program
 *     10/17/2014 DK - Replaced Community_Program__c with Community_Program_Offer__c wherever applicable
 */
 
trigger OpportunityPortalReferral on Opportunity (after update) {

    //MK - 2014-08-25 - prevent recursive firing of triggers, saves unecessary processing
    if(Opportunity_Trigger_Utility.isOpportunityTriggerRunning || Opportunity_Trigger_Utility.skipOpportunityTrigger) return;
    Opportunity_Trigger_Utility.isOpportunityTriggerRunning = true;
    
    List<Opportunity> opportunitiesUpdated = new List<Opportunity>();
    Set<Id> referringAccountIds = new Set<Id>();
    Map<Id, Portal_Referral__c> oppReferralMap = new Map<Id, Portal_Referral__c>();
    Map<Id, Lead> oppLeadMap = new Map<Id, Lead>();
    Map<Id, Event> salesEventMap = new Map<Id, Event>();
    Map<Id, Account> accountMap = new Map<Id, Account>();
    List<Portal_Referral__c> referralsToUpdate = new List<Portal_Referral__c>();
    List<Portal_Referral__c> newlySoldReferrals = new List<Portal_Referral__c>();
    
    //see which opportunities changed anything related to portal status
    for (Opportunity opp : Trigger.new) {
        if (opp.StageName != Trigger.oldMap.get(opp.Id).StageName
        || opp.Date_Site_Survey_Completed__c != Trigger.oldMap.get(opp.Id).Date_Site_Survey_Completed__c
        || opp.Closed_Reason__c != Trigger.oldMap.get(opp.Id).Closed_Reason__c
        || opp.Referring_Account__c != Trigger.oldMap.get(opp.Id).Referring_Account__c
        || opp.Community_Program_Offer__c != Trigger.oldMap.get(opp.Id).Community_Program_Offer__c) {
            opportunitiesUpdated.add(opp);
            
            if (opp.Referring_Account__c != null) {
                referringAccountIds.add(opp.Referring_Account__c);
            }
        }
    }
    
    if (opportunitiesUpdated.isEmpty()) {
        //MK - 2014-08-25 - prevent recursive firing of triggers, saves unecessary processing
        Opportunity_Trigger_Utility.isOpportunityTriggerRunning = false;
        return;
    }

    //get the related referrals
    List<Portal_Referral__c> referrals = 
        [SELECT Id, Lead__c, Opportunity__c, Status__c, Detail__c, Account__c, Portal_Payment_Plan__c, Sold_Referral_Fee__c, Community_Program__c, 
                Community_Program_Offer__c, Last_Status_Change_Date__c, Referral_Earnings__c 
        FROM Portal_Referral__c
        WHERE Opportunity__c IN :opportunitiesUpdated];
    for (Portal_Referral__c referral : referrals) {
        oppReferralMap.put(referral.Opportunity__c, referral);
    }

    //get first completed sales visit event per opportunity 
    List<Opportunity> oppEvents = 
        [SELECT Id, 
            (SELECT Id, EndDateTime 
            FROM Events
            WHERE RecordType.DeveloperName LIKE 'Sales_Visit%' 
            AND Completed__c = true
            ORDER BY EndDateTime
            LIMIT 1)
        FROM Opportunity
        WHERE Id IN :opportunitiesUpdated];
    for (Opportunity opp : oppEvents) {
        if (opp.Events.size() > 0) {
            salesEventMap.put(opp.Id, opp.Events[0]);
        }
    }
    
    //get referring accounts if any
    if (!referringAccountIds.isEmpty()) {
        accountMap = new Map<Id, Account>(
            [SELECT Id, Portal_Payment_Plan__c, IsCustomerPortal
            FROM Account
            WHERE Id IN :referringAccountIds]
        );        
    }
    if(!opportunitiesUpdated.isEmpty())
    {
        //get leads related to updated opportunities
        List<Lead> leads = 
            [SELECT Id, FirstName, LastName, Email, Phone, CreatedDate, Community_Program__c, Community_Program_Offer__c, 
                Street, City, State, PostalCode, ConvertedOpportunityId,Referring_Account__c
            FROM Lead
            WHERE ConvertedOpportunityId IN :opportunitiesUpdated];
        for (Lead l : leads) {
            oppleadMap.put(l.ConvertedOpportunityId, l);
        }
    
    }
    
    System.debug('**oppleadMap '+oppleadMap);
    for (Opportunity opp : opportunitiesUpdated) {
        Portal_Referral__c referral = oppReferralMap.get(opp.Id);
        if (referral == null && opp.Referring_Account__c != null) {
            Account a = accountMap.get(opp.Referring_Account__c);
            if (a != null && a.Portal_Payment_Plan__c != null && a.IsCustomerPortal == true) {
                referral = new Portal_Referral__c (
                    Account__c = a.Id,
                    Opportunity__c = opp.Id,
                    Last_Status_Change_Date__c = System.today(),
                    Portal_Payment_Plan__c = a.Portal_Payment_Plan__c
                );
                Lead l = oppLeadMap.get(opp.Id);
                if (l != null) {
                    referral.First_Name__c = l.FirstName;
                    referral.Last_Name__c = l.LastName;
                    referral.Email__c = l.Email;
                    referral.Phone__c = l.Phone;
                    referral.Street__c = l.Street;
                    referral.City__c = l.City;
                    referral.State__c = l.State;
                    referral.Zip__c = l.PostalCode;
                    referral.Lead_Created_Date__c = l.CreatedDate.date();
                    referral.Community_Program__c = l.Community_Program__c;
                    referral.Community_Program_Offer__c = opp.Community_Program_Offer__c;    //Change to Lead instead of Opp once it's confirmed to work through the portal
                }
            }
        }
        else if (referral == null && opp.Community_Program_Offer__c != null)
        {
            System.debug('**opp.Community_Program_Offer_c '+opp.Community_Program_Offer__c); 
            referral = new Portal_Referral__c (               
                Opportunity__c = opp.Id,
                Last_Status_Change_Date__c = System.today(),
                Community_Program__c = opp.Community_Program__c, 
                Community_Program_Offer__c = opp.Community_Program_Offer__c
            );
            Lead l = oppLeadMap.get(opp.Id);
            System.debug('**l '+l);
            if (l != null) {
                referral.First_Name__c = l.FirstName;
                referral.Last_Name__c = l.LastName;
                referral.Email__c = l.Email;
                referral.Phone__c = l.Phone;
                referral.Street__c = l.Street;
                referral.City__c = l.City;
                referral.State__c = l.State;
                referral.Zip__c = l.PostalCode;
                referral.Lead_Created_Date__c = l.CreatedDate.date(); 
                referral.Account__c = l.Referring_Account__c;    
                referral.Lead_Created_Date__c = l.CreatedDate.date();             
            }
            System.debug('**referral '+referral);
        }         
            
        if (referral != null) {
            if (PortalReferralStatus.setReferralStatus(null, opp, salesEventMap.get(opp.Id), referral)) {
                if (referral.Status__c == PortalReferralStatus.SOLD_STATUS
                && referral.Account__c != null
                && referral.Portal_Payment_Plan__c != null) {
                    referral.Account__c =    opp.Referring_Account__c;
                    referral.Community_Program__c = opp.Community_Program__c;
                    referral.Community_Program_Offer__c = opp.Community_Program_Offer__c;
                    newlySoldReferrals.add(referral);
                } else {
                    referral.Account__c =    opp.Referring_Account__c;
                    referral.Community_Program__c = opp.Community_Program__c;
                    referral.Community_Program_Offer__c = opp.Community_Program_Offer__c;
                    referralsToUpdate.add(referral);
                }
            } else if (opp.Referring_Account__c != referral.Account__c || referral.Community_Program__c != opp.Community_Program__c )
            {
                 referral.Account__c =    opp.Referring_Account__c;
                 referral.Community_Program__c = opp.Community_Program__c;
                 referral.Community_Program_Offer__c = opp.Community_Program_Offer__c;
                 referralsToUpdate.add(referral);
            }
        }
    }

    if (!newlySoldReferrals.isEmpty()) {
        PortalReferralStatus.processSoldEarnings(newlySoldReferrals);
        upsert newlySoldReferrals;
    }

    if (!referralsToUpdate.isEmpty()) {
        PortalReferralStatus.processUnsoldEarnings(referralsToUpdate);
        try {  
            upsert referralsToUpdate;
        } catch (Exception e){
            System.debug('Trigger Error: ' + e.getStackTraceString());  //DK  8/7/15  Patching a "Required Field Missing" error that arose in a deployment attempt
        }
    }   

    //MK - 2014-08-25 - prevent recursive firing of triggers, saves unecessary processing
    Opportunity_Trigger_Utility.isOpportunityTriggerRunning = false;

}