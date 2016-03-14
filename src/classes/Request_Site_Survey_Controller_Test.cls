//10/26/2012 TCM - switch notes with comments - zen-64
@isTest
private class Request_Site_Survey_Controller_Test {

    static testMethod void testDateSiteSurveyRequestedIsSet() {
		
		// setup    
		Opportunity opp = Milestone1_Test_Utility.CreateTestOpp();
    	
    	// execute
		ApexPages.Standardcontroller standController = new ApexPages.Standardcontroller(opp);
		Request_Site_Survey_Controller_Extension controller = new Request_Site_Survey_Controller_Extension(standController);
    	controller.submit();
    	
    	// assert    	
    	// confirm Opportunity.Date_Site_Survey_Requested__c is set
		opp = [Select Date_Site_Survey_Requested__c
							  From Opportunity o 
							  where id = :opp.id
							  limit 1];

    	Datetime expected = null;
    	Datetime actual = opp.Date_Site_Survey_Requested__c;

		System.assertNotEquals(expected, actual);    			
    }
}