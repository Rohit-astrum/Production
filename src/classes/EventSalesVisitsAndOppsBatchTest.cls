/* FILE: EventSalesVisitsBatchTest.cls
 * AUTHOR: Rohit Jain
 * DATE: Dec 02 , 2013
 * PURPOSE: Test class for Event Sales Visit Update Batches
 * MODIFICATION HISTORY 
 */ 

@isTest//(SeeAllData=true)
public class EventSalesVisitsAndOppsBatchTest{
    
     public static testMethod void EventSalesVisitStatusUpdateBatchTest() {
        
        testData.setupCustomSettings();
        CreatePricebookEntry();
        Opportunity opp = Milestone1_Test_Utility.CreateTestOpp();
        Event theEvent1 = createEvent(opp);
        Event theEvent2 = createEvent(opp);
        theEvent2.StartDateTime = Datetime.now().addDays(-1);
        update theEvent2;

        Test.startTest();        
        EventSalesVisitStatusUpdateBatch  batch = new EventSalesVisitStatusUpdateBatch ();
        Database.executeBatch(batch);
        
        Test.stopTest();
        
        theEvent1  = [Select Event_Status__c from Event Where Id = :theEvent1.Id];
        theEvent2  = [Select Event_Status__c from Event Where Id = :theEvent2.Id];
        
        System.assertEquals('Missed',theEvent1.Event_Status__c);
        System.assertNotEquals('Missed',theEvent2.Event_Status__c);
    }
    
    public static testMethod void OpportunityInactivityUpdateBatchTest() {
        
        testData.setupCustomSettings();
        CreatePricebookEntry();
        Opportunity opp = Milestone1_Test_Utility.CreateTestOpp();
        opp.ownerId = UserInfo.getUserId();
        update opp;
        Test.startTest();        
        OpportunityInactivityUpdateBatch batch = new OpportunityInactivityUpdateBatch();
        Database.QueryLocator ql = batch.start(null);
        batch.execute(null, new List<Opportunity> { opp});
        batch.batchErrors = 'Test Errs';
        batch.finish(null);
        batch.execute(null);
        
        Test.stopTest();
        
        List<Task> tasksList = [Select WhatId From Task Where RecordType.Name= 'Inactivity Notice' and Status != 'Completed' and WhatId = :opp.id];
        
        System.assertEquals(1 ,tasksList.size());
        
    }
    
    public static testMethod void OpportunityOnholdUpdateBatchEmailTest() {
        
        testData.setupCustomSettings();
        CreatePricebookEntry();
        Opportunity opp = Milestone1_Test_Utility.CreateTestOpp();
        opp.StageName = 'On Hold';
        opp.On_Hold_Until__c = System.today()+1;
        TriggerUtility.skipDlrsTriggers = true;
        update opp;
               
        Test.startTest();        
        OpportunityOnholdUpdateBatch batch = new OpportunityOnholdUpdateBatch();
        Database.QueryLocator ql = batch.start(null);
        batch.execute(null, new List<Opportunity> { opp});
        batch.batchErrors = 'Test Errs';
        batch.finish(null);
        batch.execute(null);
        
        Test.stopTest();
        
    }
    
    public static testMethod void OpportunityOnholdUpdateBatchTaskTest() {
        
        testData.setupCustomSettings();
        CreatePricebookEntry();
        Opportunity opp = Milestone1_Test_Utility.CreateTestOpp();
        opp.ownerId = UserInfo.getUserId();
        update opp;              
        Test.startTest();        
        OpportunityOnholdUpdateBatch batch = new OpportunityOnholdUpdateBatch();
        Database.QueryLocator ql = batch.start(null);
        batch.execute(null, new List<Opportunity> { opp});
        batch.batchErrors = 'Test Errs';
        batch.finish(null);
        batch.execute(null);
        
        Test.stopTest();
        
        List<Task> tasksList = [Select WhatId From Task Where RecordType.Name= 'Inactivity Notice' and Status != 'Completed' and WhatId = :opp.id];
        
        System.assertEquals(1 ,tasksList.size());
        
    }
   
    private static Event createEvent(Opportunity opp) {
        
        RecordType salesVisitRecordType = [SELECT Id FROM RecordType WHERE (Name = 'Sales Visit Onsite' or  Name = 'Sales Visit Remote') AND SobjectType = 'Event' limit 1];
        Event tempEvent = new Event();
        tempEvent.OwnerId = UserInfo.getUserId();
        tempEvent.RecordTypeId = salesVisitRecordType.Id;  
        tempEvent.Subject = 'Test';
        tempEvent.Event_Status__c = 'Scheduled';
        tempEvent.StartDateTime = Datetime.now()-3;
        tempEvent.EndDateTime = Datetime.now().addDays(1);
        tempEvent.WhatId = opp.Id;
                
        insert tempEvent;           
    
        return tempEvent;
    }
    
    private static void CreatePricebookEntry(){
        Product2 p = new Product2(
            Name='testProduct223',
            ProductCode = 'system'
        );
        insert p;

        Id pbookId = Test.getStandardPricebookId();
              
        PricebookEntry pricebookEntry = new PricebookEntry(
            UnitPrice = 2.32,
            Pricebook2Id = pbookId,
            UseStandardPrice = false,
            Product2ID = p.Id,
            IsActive  = true
        );
        insert pricebookEntry;
    }
}