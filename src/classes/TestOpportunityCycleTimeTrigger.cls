/* FILE: TestOpportunityCycleTimeTrigger.cls
 * AUTHOR: Sam Kandasamy
 * DATE: Jan 2, 2015
 * PURPOSE: Test class for OpportunityCycleTimeTrigger 
 * MODIFICATION HISTORY
 *
 */ 
 
@isTest(seeAllData=true)
public class TestOpportunityCycleTimeTrigger {
    
    static testMethod void OpportunityEventCycleTimeInsertTest() {
    
    // Opportunity opp = createTestOpportunity(); 
        Account acct = new Account(Name = 'Test Customer', BillingStreet = '244 Torrey Pine', BillingState = 'PA' , BillingPostalCode = '19380', BillingCountry = 'USA' ,BillingCity = 'West Chester');
        insert acct;
        Opportunity opp = new Opportunity(
                Name = 'Test Opp',
                AccountId = acct.Id,
                StageName = 'Test',
                CloseDate = System.today().addDays(-8),
                Financing_Type__c = 'Purchase',
                Financing_Option__c = 'No Financing',
                Leasing_Option__c = null
            );
        insert opp;
        System.Debug('OpportunityId: ' + opp.id);
        Event evnt = new Event(whatId = opp.Id,
                                  Type = 'Sales Visit Onsite',
                                  
                                   StartDateTime = system.today().addDays(+2),
                                   EndDateTime = system.today().addDays(+4),
                                   DurationInMinutes = 2880, // one day
                                   Completed_Date__c = System.today().addDays(+2)  // To check Completed_Date__c not null condition
                                  );
        Test.startTest();          
        insert evnt;
        Test.stopTest();
        List<Opportunity> oppList = [SELECT CreatedDate FROM Opportunity WHERE id = :opp.id];
        System.assert(oppList.size() > 0);
        List<Event> updatedEvents = new List<Event>();
        List<Event> eventList = [SELECT Id, StartDateTime, EndDateTime, Original_start_Date_Time__c, CycleTimeActualScheduled__c, CycleTimeOriginalScheduled__c, CompleteTime__c FROM Event WHERE Id = :evnt.Id];
        System.Debug('EventList '+eventList);
        for( Event ev : eventList) {
            System.Debug('StartDateTime '+ev.StartDateTime);
            System.Debug('EndDateTime '+ev.EndDateTime);
            System.assert(ev.CycleTimeActualScheduled__c > 0 );  
            System.assert(ev.CycleTimeOriginalScheduled__c > 0 );

            System.Debug('CycleTimeActual '+ev.CycleTimeActualScheduled__c);
            System.Debug('CycleTimeOriginal '+ev.CycleTimeOriginalScheduled__c);
            
        
        }
        
    
    }
    static testMethod void OpportunityEventCycleTimeUpdateTest() {
    
    // Opportunity opp = createTestOpportunity(); 
        Account acct = new Account(Name = 'Test Customer', BillingStreet = '244 Torrey Pine', BillingState = 'PA' , BillingPostalCode = '19380', BillingCountry = 'USA' ,BillingCity = 'West Chester');
        insert acct;
        Opportunity opp = new Opportunity(
                Name = 'Test Opp',
                AccountId = acct.Id,
                StageName = 'Test',
                CloseDate = System.today().addDays(-8),
                Financing_Type__c = 'Purchase',
                Financing_Option__c = 'No Financing',
                Leasing_Option__c = null
            );
        insert opp;
        System.Debug('OpportunityId: ' + opp.id);
        Event evnt = new Event(whatId = opp.Id,
                                  Type = 'Sales Visit Onsite',
                                  
                                   StartDateTime = system.today().addDays(+2),
                                   EndDateTime = system.today().addDays(+4),
                                   DurationInMinutes = 2880, // one day
                                   Completed_Date__c = System.today().addDays(+2)  // To check Completed_Date__c not null condition
                                  );
                     
        insert evnt;
        List<Opportunity> oppList = [SELECT CreatedDate FROM Opportunity WHERE id = :opp.id];
        System.assert(oppList.size() > 0);
        List<Event> updatedEvents = new List<Event>();
        List<Event> eventList = [SELECT Id, StartDateTime, EndDateTime, Original_start_Date_Time__c, CycleTimeActualScheduled__c, CycleTimeOriginalScheduled__c, CompleteTime__c FROM Event WHERE Id = :evnt.Id];
        System.Debug('EventList '+eventList);
        for( Event ev : eventList) {
            System.Debug('StartDateTime '+ev.StartDateTime);
            System.Debug('EndDateTime '+ev.EndDateTime);
            ev.Completed_Date__c = System.today().addDays(+3);
            ev.StartDateTime = null;
            ev.Original_start_Date_Time__c = null;
            updatedEvents.add(ev);
        
        }
        Test.startTest();
        update updatedEvents;
        Test.stopTest();
        eventList = [SELECT StartDateTime, EndDateTime, Original_start_Date_Time__c, CycleTimeActualScheduled__c, CycleTimeOriginalScheduled__c, CompleteTime__c FROM Event WHERE Id = :evnt.Id];
        for( Event ev : eventList) {
            System.Debug('completeTime After Update '+ev.CompleteTime__c);
            System.assert(ev.CompleteTime__c > 0);
            System.assertEquals(null, ev.CycleTimeOriginalScheduled__c);
            System.assertEquals(null, ev.CycleTimeActualScheduled__c);
        }
    
    }
 
    static testMethod void OpportunityNullEventCycleTimesTest() {
    
    // Opportunity opp = createTestOpportunity(); 
        Account acct = new Account(Name = 'Test Customer', BillingStreet = '244 Torrey Pine', BillingState = 'PA' , BillingPostalCode = '19380', BillingCountry = 'USA' ,BillingCity = 'West Chester');
        insert acct;
        Opportunity opp = new Opportunity(
                Name = 'Test Opp',
                AccountId = acct.Id,
                StageName = 'Test',
                CloseDate = System.today().addDays(-8),
                Financing_Type__c = 'Purchase',
                Financing_Option__c = 'No Financing',
                Leasing_Option__c = null
            );
        insert opp;
        System.Debug('OpportunityId: ' + opp.id);
        Event evnt = new Event(whatId = opp.Id,
                                  Type = 'Sales Visit Onsite',
                                  
                                   StartDateTime = system.today().addDays(+2),
                                   EndDateTime = system.today().addDays(+4),
                                   DurationInMinutes = 2880, // one day
                                   Completed_Date__c = System.today().addDays(+2)  // To check Completed_Date__c not null condition
                                  );
                     
        insert evnt;
        List<Opportunity> oppList = [SELECT CreatedDate FROM Opportunity WHERE id = :opp.id];
        System.assert(oppList.size() > 0);
        List<Event> updatedEvents = new List<Event>();
        List<Event> eventList = [SELECT Id, StartDateTime, EndDateTime, Original_start_Date_Time__c, CycleTimeActualScheduled__c, CycleTimeOriginalScheduled__c, CompleteTime__c FROM Event WHERE Id = :evnt.Id];
        System.Debug('EventList '+eventList);
        for( Event ev : eventList) {
            System.Debug('StartDateTime '+ev.StartDateTime);
            System.Debug('EndDateTime '+ev.EndDateTime);
           
            ev.StartDateTime = null;
            ev.Original_start_Date_Time__c = null;
             ev.Completed_Date__c = null;
            updatedEvents.add(ev);
        
        }
        Test.startTest();
        update updatedEvents;
        Test.stopTest();
        eventList = [SELECT StartDateTime, EndDateTime, Original_start_Date_Time__c, CycleTimeActualScheduled__c, CycleTimeOriginalScheduled__c, CompleteTime__c FROM Event WHERE Id = :evnt.Id];
        for( Event ev : eventList) {
            System.Debug('completeTime After Update '+ev.CompleteTime__c);
            
            System.assertEquals(null, ev.CycleTimeOriginalScheduled__c);
            System.assertEquals(null, ev.CycleTimeActualScheduled__c);
            System.assertEquals(null, ev.CompleteTime__c);
        }
    
    }
 

}