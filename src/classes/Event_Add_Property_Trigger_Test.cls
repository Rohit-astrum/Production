@isTest
private class Event_Add_Property_Trigger_Test {

    public static testMethod void testAddEvent_Property_Match() {

        // setup
        Opportunity opp = Milestone1_Test_Utility.CreateTestOpp();
        
        ApexPages.Standardcontroller standController = new ApexPages.Standardcontroller(opp);
        Request_Site_Survey_Controller_Extension controller = new Request_Site_Survey_Controller_Extension(standController);
        controller.submit();
        
        // execute
        Event tempEvent = createEvent(opp);
            
        // assert
        System.assertEquals(tempEvent.Related_Property_Name__c, opp.Property__r.Name);
    }
    
    public static testMethod void testDeleteEvent_Permission() {

        // setup
        Opportunity opp = Milestone1_Test_Utility.CreateTestOpp();
        
        // execute
        Event tempEvent = createEvent(opp);
        
        Delete tempEvent;
            
        // assert
        //System.assertEquals(tempEvent.Related_Property_Name__c, opp.Property__r.Name);
    }
    
    private static Event createEvent(Opportunity opp) {
        
        RecordType siteSurveyRecordType = [SELECT Id FROM RecordType WHERE (Name = 'Site Survey Onsite' or  Name = 'Site Survey Remote') AND SobjectType = 'Event' limit 1];
        Event tempEvent = new Event();
        tempEvent.OwnerId = UserInfo.getUserId();
        tempEvent.RecordTypeId = siteSurveyRecordType.Id;  
        tempEvent.Subject = 'Test';
        tempEvent.StartDateTime = Datetime.now();
        tempEvent.EndDateTime = Datetime.now().addDays(14);
        tempEvent.WhatId = opp.Id;
                
        insert tempEvent;           
    
        return tempEvent;
    }
    
    
    

}