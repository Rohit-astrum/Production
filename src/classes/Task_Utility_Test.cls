/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Task_Utility_Test {

    public static testMethod void testCreateTask() {

        Date theEndDate = Date.parse('8/11/2015');
        
        Lead tempLead = new Lead();
        tempLead.LastName = 'Airy';
        tempLead.FirstName = 'David';
        tempLead.Company = tempLead.LastName + ', ' + tempLead.FirstName;
        tempLead.Status = Task_Utility.ON_HOLD_STATUS;      
        tempLead.On_Hold_Until__c = theEndDate;
        setRequiredFields(tempLead);
        
        insert tempLead;
        
        Task actualTask = [Select t.WhoId, t.WhatId, t.Subject, t.Description, t.ActivityDate, t.Status From Task t where whoId = :tempLead.id limit 1];

        String expectedSubject = Task_Utility.TASK_SUBJECT; 
        String expectedStatus = Task_Utility.TASK_STATUS;
        Date expectedActivityDate = theEndDate;
            
        System.assertEquals(expectedSubject, actualTask.Subject);
        System.assertEquals(expectedStatus, actualTask.Status);
        System.assertEquals(expectedActivityDate, actualTask.ActivityDate);     
    }
    
    public static testMethod void testCreateTasksForLeadsInOnHoldStatus_OneLeadOnHold_OneLeadOpenNew() {

        // setup
        Date theEndDate = Date.parse('8/11/2015');

        Lead tempLead = new Lead();
        tempLead.LastName = 'Airy';
        tempLead.FirstName = 'David';
        tempLead.Company = tempLead.LastName + ', ' + tempLead.FirstName;
        tempLead.Status = Task_Utility.ON_HOLD_STATUS;      
        tempLead.On_Hold_Until__c = theEndDate;
        setRequiredFields(tempLead);        

        Lead tempLead2 = new Lead();
        tempLead2.LastName = 'Smith';
        tempLead2.FirstName = 'David';
        tempLead2.Company = tempLead2.LastName + ', ' + tempLead2.FirstName;
        tempLead2.Status = Lead_Status_Utility.OPEN_NEW_STATUS;     
        
        // execute
        insert tempLead;
        insert tempLead2;

        // assert               
        Map<Id, Lead> leadsMap = new Map<Id, Lead>();
        leadsMap.put(tempLead.id, tempLead);
        leadsMap.put(tempLead2.id, tempLead2);
        
        // should only have 1 task created
        List<Task> tasks = [Select t.WhoId, t.WhatId, t.Subject, t.Description, t.ActivityDate, t.Status From Task t where whoId IN :leadsMap.keySet()];

        Integer expectedSize = 1;
        Integer actualSize = tasks.size();
        
        System.assertEquals(expectedSize, actualSize);
    }

    public static testMethod void testCreateTasksForLeadsInOnHoldStatus_Only_OneLeadOnHold() {

        // setup
        Date theEndDate = Date.parse('8/11/2015');

        Lead tempLead = new Lead();
        tempLead.LastName = 'Airy';
        tempLead.FirstName = 'David';
        tempLead.Company = tempLead.LastName + ', ' + tempLead.FirstName;
        tempLead.Status = Task_Utility.ON_HOLD_STATUS;      
        tempLead.On_Hold_Until__c = theEndDate;
        setRequiredFields(tempLead);
        
        // execute
        insert tempLead;

        // assert
        Map<Id, Lead> leadsMap = new Map<Id, Lead>();
        leadsMap.put(tempLead.id, tempLead);
        
        // should only have 1 task created
        List<Task> tasks = [Select t.WhoId, t.WhatId, t.Subject, t.Description, t.ActivityDate, t.Status From Task t where whoId IN :leadsMap.keySet()];

        Integer expectedSize = 1;
        Integer actualSize = tasks.size();
        
        System.assertEquals(expectedSize, actualSize);
    }

    public static testMethod void testCreateTasksForLeadsInOnHoldStatus_OneLeadOpenNew() {

        // setup
        Date theEndDate = Date.parse('8/11/2015');

        Lead tempLead2 = new Lead();
        tempLead2.LastName = 'Airy';
        tempLead2.FirstName = 'David';
        tempLead2.Company = tempLead2.LastName + ', ' + tempLead2.FirstName;
        tempLead2.Status = Lead_Status_Utility.OPEN_NEW_STATUS;     

        // execute
        insert tempLead2;
        
        Map<Id, Lead> leadsMap = new Map<Id, Lead>();
        leadsMap.put(tempLead2.id, tempLead2);
        
        // assert
        // should not have any tasks created
        List<Task> tasks = [Select t.WhoId, t.WhatId, t.Subject, t.Description, t.ActivityDate, t.Status From Task t where whoId IN :leadsMap.keySet()];

        Integer expectedSize = 0;
        Integer actualSize = tasks.size();
        
        System.assertEquals(expectedSize, actualSize);
    }

    private static void setRequiredFields(Lead tempLead) {
        tempLead.Closability__c = 'High';
        tempLead.Competitive_Quote__c = 'Yes';
        // tempLead.Going_Solar_Reason__c = 'Financial ROI';
        tempLead.Competitive_Quote_Mentioned__c = 'Mentioned';
        tempLead.Competitors__c = 'Sungevity';
        tempLead.Estimated_System_Size__c = '8-20 kW';
        tempLead.Roof_Structure__c = 'Pitched';
        tempLead.Roof_Material__c = 'Asphalt';
        tempLead.Ground_Mount_Interest__c = 'No';
        tempLead.Estimated_Site_Quality__c = 'Poor/Definite Shade';
        tempLead.Estimated_Power_Use__c = '>25kWh/yr';
        tempLead.Own_vs_Lease__c = 'Prefers Own';
        tempLead.Affordability__c = 'Can Clearly Afford';
        tempLead.Financing__c = 'Needs';
        tempLead.Project_Timeline__c = 'Immediate';
        tempLead.Interest_Level__c = 'Wants to Buy';
        tempLead.Spoke_With_BGE_Home__c = 'No';
        tempLead.Viewed_Calculator__c = 'Yes';
    }    

    public static testMethod void testClearOnHoldDateForLeadsLeavingOnHoldStatus_MovingFromOnHold() {

        // setup
        Date theEndDate = Date.parse('8/11/2015');

        Lead tempLead = new Lead();
        tempLead.LastName = 'Airy';
        tempLead.FirstName = 'David';
        tempLead.Company = tempLead.LastName + ', ' + tempLead.FirstName;
        tempLead.Status = Task_Utility.ON_HOLD_STATUS;      
        tempLead.On_Hold_Until__c = theEndDate;
        setRequiredFields(tempLead);

        insert tempLead;
        
        // execute
        tempLead.Status = 'Contacted by Us';
        update tempLead;

        // assert       
        Lead actualLead = [Select FirstName, LastName, On_Hold_Until__c From Lead where id = :tempLead.id limit 1];

        // on hold until date should be null;
        Date expected = null;
        Date actual = actualLead.On_Hold_Until__c;
        
        System.assertEquals(expected, actual);
    }

    public static testMethod void testClearOnHoldDateForLeadsLeavingOnHoldStatus_MovingToOnHold() {

        // setup
        Date theEndDate = Date.parse('8/11/2015');

        Lead tempLead = new Lead();
        tempLead.LastName = 'Airy';
        tempLead.FirstName = 'David';
        tempLead.Company = tempLead.LastName + ', ' + tempLead.FirstName;
        tempLead.Status = 'Contacted by Us';
        tempLead.On_Hold_Until__c = theEndDate;
        setRequiredFields(tempLead);
        insert tempLead;
        
        // execute
        tempLead.Status = Task_Utility.ON_HOLD_STATUS;      
        update tempLead;

        // assert
        
        // on hold until date should be null;
        Lead actualLead = [Select FirstName, LastName, On_Hold_Until__c From Lead where id = :tempLead.id limit 1];

        Date expected = theEndDate;
        Date actual = actualLead.On_Hold_Until__c;
        
        System.assertEquals(expected, actual);
    }
    
}