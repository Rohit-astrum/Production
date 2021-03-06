@isTest
private class Milestone1_XML_Import_Utility_Test {
    static TestMethod void testSOQLQueries()
    {
        Milestone1_XML_Export_Utility m1exportutility = new Milestone1_XML_Export_Utility();
        Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('UNIT TEST PROJECT NAME ABC123XYZ UNIQUE' + System.now());
        insert testProject;
        testProject = [select Id, Name from Milestone1_Project__c where Name = :testProject.Name limit 1];
        
        Milestone1_Milestone__c testMilestone = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME ACB123XYZ UNIQUE' + System.now());
        insert testMilestone;
        testMilestone = [select Id, Name from Milestone1_Milestone__c where Name = :testMilestone.Name limit 1];
        
        Milestone1_Milestone__c testMilestone2 = Milestone1_Test_Utility.sampleMilestone(testProject.Id,null,'UNIT TEST MILESTONE NAME2 ACB123XYZ UNIQUE' + System.now());
        insert testMilestone2;
        testMilestone2 = [select Id, Name from Milestone1_Milestone__c where Name = :testMilestone2.Name limit 1];
        

        Milestone1_Milestone__c testMilestone3 = Milestone1_Test_Utility.sampleMilestone(null,testMilestone.Id,'UNIT TEST MILESTONE NAME3 ACB123XYZ UNIQUE' + System.now());
        insert testMilestone3;
        testMilestone3 = [select Id, Name from Milestone1_Milestone__c where Name = :testMilestone3.Name limit 1];
        
        Test.startTest();
        Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
        insert task1;
        
        if (Milestone1_Test_Utility.performExtensiveTests() == true){
	        Milestone1_Task__c task2 = Milestone1_Test_Utility.sampleTask(testMilestone.Id);
	        insert task2;
	        
	        Milestone1_Task__c task3 = Milestone1_Test_Utility.sampleTask(testMilestone2.Id);
	        insert task3;
	        
	        Milestone1_Task__c task4 = Milestone1_Test_Utility.sampleTask(testMilestone3.Id);
	        insert task4;
	        
	        Milestone1_Task__c task5 = Milestone1_Test_Utility.sampleTask(testMilestone3.Id);
	        insert task5;
        
        
	        String xmlString = m1exportutility.buildProjectXmlString(testProject.Id);
	        System.assertNotEquals(xmlString, null);
	        
	        Milestone1_XML_Import_Utility importXMLUtility = new Milestone1_XML_Import_Utility();
	        importXMLUtility.importProject(xmlString);
    	}

        Test.stopTest();
        
    }
}