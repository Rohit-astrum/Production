/* FILE: EventPortalReferralTriggerTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: September 6, 2012
 * PURPOSE: test class for EventPortalReferral trigger
 * MODIFICATION HISTORY
 *    12/01/14  DK  Added assertion statements to test EventTriggerHandler.setOriginalDateFields()
 */
 
@isTest(SeeAllData = true)
public class EventPortalReferralTriggerTest {

    static testMethod void opp_completeSalesVisit_statusChanged() {
                
        Portal_Referral__c referral = OpportunityPortalReferralTriggerTest.createReferralWithOpp();
        
        RecordType salesVisit = [SELECT Id FROM RecordType 
            WHERE SObjectType='Event' AND DeveloperName = 'Sales_Visit_Onsite'];
        
        Event evt = new Event(
            RecordTypeId = salesVisit.Id,
            WhatId = referral.Opportunity__c,
            StartDateTime = Datetime.now().addHours(-2),
            EndDateTime = Datetime.now().addHours(-1)
        );
        insert evt;
        
        Opportunity opp = new Opportunity (Id = referral.Opportunity__c, StageName = 'Qualified');
        update opp;
            
        referral = [SELECT Id, Lead__c, Opportunity__c, Status__c, Detail__c
            FROM Portal_Referral__c
            WHERE Id = :referral.Id];
            
        System.assertEquals(PortalReferralStatus.Qualified_STATUS, referral.Status__c);
        System.assertEquals('Evaluation in Progress', referral.Detail__c);      
        
        Test.startTest();
        
        evt.Completed__c = true;
        update evt;
        
        Test.stopTest();

        referral = [SELECT Id, Lead__c, Status__c, Detail__c
            FROM Portal_Referral__c
            WHERE Id = :referral.Id];
            
        System.assertEquals(PortalReferralStatus.QUALIFIED_STATUS, referral.Status__c);
        System.assertEquals('Sales Call Completed', referral.Detail__c);
        
        //[DK] Test EventTriggerHandler.setOriginalDateFields()
        evt = [SELECT Original_Start_Date_Time__c, Original_End_Date_Time__c, StartDateTime, EndDateTime FROM Event WHERE ID = :evt.ID];
        System.assertEquals(evt.StartDateTime, evt.Original_Start_Date_Time__c);
        System.assertEquals(evt.EndDateTime, evt.Original_End_Date_Time__c);
    }

}