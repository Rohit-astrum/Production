/* FILE: PipelineManagementControllerTest.cls
 * AUTHOR: Rohit Jain
 * DATE: Dec 02 , 2013
 * PURPOSE: Test class for Event Sales Visit Update Batches
 * MODIFICATION HISTORY 
 */ 

@isTest(SeeAllData=true)
public class PipelineManagementControllerTest{
     /*
     public static testMethod void PipelineManagementTest() {
        
        Opportunity opp = Milestone1_Test_Utility.CreateTestOpp();
        opp.Sales_Region__c = 'MD Region';
        opp.StageName = 'Qualified';
        update opp;
        //Event theEvent2 = createEvent(opp,'Missed'); 
        //Event theEvent3 = createEvent(opp,'Completed'); 
        Event theEvent4 = createEvent(opp,'Disqualified'); 
        Event theEvent5 = createEvent(opp,'Scheduled');
        //Event theEvent6 = createEvent(opp,'Rescheduled'); 
        //Event theEvent7 = createEvent(opp,'Canceled by Customer');   
        //Event theEvent8 = createEvent(opp,'Disqualified-Approved');   
        
        String ownId = 'MD:Active:'+Userinfo.getUserId();
        Test.startTest();  
               
       PipelineManagementController.getAEOpportunities(ownId ,System.Today().format(),System.Today().format(),'>','50');
        PipelineManagementController  controller = new PipelineManagementController();
        List<SelectOption> probsigns = controller.ProbabilitySigns;
        controller.EndDateT = System.Today().format();
        controller.StartDateT = (System.Today()).format();  
        controller.probabilitySign = '>';
        controller.probabilityValue = 50;   
        controller.populateSummary();             
        
        Test.stopTest();
    }
    
    public static testMethod void PipelineManagementSRTest() {
        
        Opportunity opp = Milestone1_Test_Utility.CreateTestOpp();
        opp.Sales_Region__c = 'MD Region';
        opp.StageName = 'Qualified';
        update opp;
        Event theEvent2 = createEvent(opp,'Missed'); 
        Event theEvent3 = createEvent(opp,'Completed'); 
        //Event theEvent4 = createEvent(opp,'Disqualified'); 
        //Event theEvent5 = createEvent(opp,'Scheduled');
        //Event theEvent6 = createEvent(opp,'Rescheduled'); 
       // Event theEvent7 = createEvent(opp,'Canceled by Customer');   
        //Event theEvent8 = createEvent(opp,'Disqualified-Approved');     
        Test.startTest(); 
         PipelineManagementController  controller = new PipelineManagementController();
        controller.EndDateT = System.Today().format();
        controller.StartDateT = (System.Today()-1).format();
          controller.probabilitySign = '>';
        controller.probabilityValue = 50;   
        controller.populateSalesRegionSummary();
        
        Test.stopTest();
    }
    
    private static Event createEvent(Opportunity opp, String Status) {
        
        RecordType salesVisitRecordType = [SELECT Id FROM RecordType WHERE (Name = 'Sales Visit Onsite' or  Name = 'Sales Visit Remote') AND SobjectType = 'Event' limit 1];
        Event tempEvent = new Event();
        tempEvent.OwnerId = UserInfo.getUserId();
        tempEvent.RecordTypeId = salesVisitRecordType.Id;  
        tempEvent.Subject = 'Test';
        tempEvent.Event_Status__c = Status;
        tempEvent.StartDateTime = Datetime.now();
        tempEvent.EndDateTime = Datetime.now().addDays(14);
        tempEvent.WhatId = opp.Id;
                
        insert tempEvent;           
    
        return tempEvent;
    }
    */
}