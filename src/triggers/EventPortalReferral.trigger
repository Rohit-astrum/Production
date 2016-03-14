/* FILE: EventPortalReferral.trigger
 * AUTHOR: Tino Mattheou
 * DATE: September 4, 2012
 * PURPOSE: updates portal referral if sales visit event is completed
 * MODIFICATION HISTORY
 *
 */
 
trigger EventPortalReferral on Event (after insert, after update) {
 /*   
    Set<Id> salesVisitRecordTypes = new Set<Id>();
    Schema.DescribeSObjectResult dsr = Event.SObjectType.getDescribe();
    for (Schema.RecordTypeInfo rti : dsr.getRecordTypeInfos()) {
        if (rti.getName().startsWith('Sales Visit')) {
            salesVisitRecordTypes.add(rti.getRecordTypeId());
        }
    }

    Set<Id> opportunityIds = new Set<Id>();

    for (Event evt : Trigger.new) {
        String whatId = evt.WhatId;
        if (salesVisitRecordTypes.contains(evt.RecordTypeId)
        && evt.WhatId != null && whatId.startsWith('006') //opportunity
        && evt.Completed__c == true
        && (Trigger.isInsert 
        || evt.Completed__c != Trigger.oldMap.get(evt.Id).Completed__c
        || evt.WhatId != Trigger.oldMap.get(evt.Id).WhatId
        || evt.RecordTypeId != Trigger.oldMap.get(evt.Id).RecordTypeId
        || evt.EndDateTime != Trigger.oldMap.get(evt.Id).EndDateTime)) {
            opportunityIds.add(whatId);
        }
    }
    
    if (opportunityIds.isEmpty()) {
        return;
    }
    
    //get the related referrals
    List<Portal_Referral__c> referrals = 
        [SELECT Id, Lead__c, Opportunity__c, Status__c, Detail__c
        FROM Portal_Referral__c
        WHERE Opportunity__c IN :opportunityIds];

    if (referrals.isEmpty()) {
        return;
    }

    //get first completed sales visit event per opportunity 
    Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>( 
        [SELECT Id, StageName, Date_Site_Survey_Completed__c, Closed_Reason__c, CreatedDate,CloseDate,
            (SELECT Id, EndDateTime 
            FROM Events
            WHERE RecordType.DeveloperName LIKE 'Sales_Visit%' 
            AND Completed__c = true
            ORDER BY EndDateTime
            LIMIT 1)
        FROM Opportunity
        WHERE Id IN :opportunityIds
    ]);

    List<Portal_Referral__c> referralsToUpdate = new List<Portal_Referral__c>(); 
        
    for (Portal_Referral__c referral : referrals) {
        Opportunity opp = oppMap.get(referral.Opportunity__c);
        if (opp != null) {
            if (PortalReferralStatus.setReferralStatus(null, opp, opp.Events[0], referral)) {
                referralsToUpdate.add(referral);
            }
        }
    }
    
    if (!referralsToUpdate.isEmpty()) {
        update referralsToUpdate;
    }   

    */
    
}