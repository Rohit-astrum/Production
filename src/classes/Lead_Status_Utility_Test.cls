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
private class Lead_Status_Utility_Test {

	public static testMethod void testCustomSettings() {
		// check status
		Pipeline_Status_Settings__c settings = Pipeline_Status_Settings__c.getOrgDefaults();

		System.assertNotEquals(settings, null);					
	}
	
    public static testMethod void testSendEmailForEarlyStageLeads() {
    	
		Lead_Status_Utility.sendEmailForEarlyStageLeads();
    }

    public static testMethod void testSendEmailForMediumStageLeads() {
    	
		Lead_Status_Utility.sendEmailForMediumStageLeads();
    }

    public static testMethod void testSendEmailForLateStageLeads() {
    	
		Lead_Status_Utility.sendEmailForLateStageLeads();
    }

	private static Task createCompletedTask(Id leadId) {
		Task temp = createCompletedTask(leadId, Date.today());
		
		return temp;		
	}

	private static Task createCompletedTask(Id leadId, Date activityDate) {
		Task temp = new Task();
		temp.whoId = leadId;  // give the id of the Lead
		temp.activityDate = activityDate;
		temp.description = 'Test creation';
		temp.priority = 'Normal';
		temp.status = 'Completed';
		temp.subject = 'Call';

		return temp;		
	}
	
	private static List<Lead> keepTestLeads(Lead tempLead, List<Lead> allLeads) {
		List<Lead> testLeads = new List<Lead>();
		
		// keep only test lead
		for (Lead aLead : allLeads) {
			if (aLead.id == tempLead.id) {
				testLeads.add(aLead);
			}	
		}

		return testLeads;		
	}
	
    public static testMethod void getLeadsToContact_WithOldLeadCreatedDate() {
		BusinessHours theBusinessHours = [select id from BusinessHours where IsDefault=true limit 1];

		Lead tempLead = new Lead();
		tempLead.LastName = 'Airy';
		tempLead.FirstName = 'David';
		tempLead.Company = tempLead.LastName + ', ' + tempLead.FirstName;
		tempLead.Status = Lead_Status_Utility.OPEN_NEW_STATUS;		
		insert tempLead;

		tempLead.Lead_Created_Date__c = Datetime.parse('12/17/2010 9:00 AM');
		update tempLead;
						
		List<Lead> allLeads = Lead_Status_Utility.getOpenNewLeadsToContact();
		
		List<Lead> testLeads = keepTestLeads(tempLead, allLeads);
		
		System.debug('new testLeads.size = ' + testLeads.size());
		
		Integer expectedSize = 1;

		Integer actualSize = testLeads.size();
		
		System.assertEquals(expectedSize, actualSize);
    }

    public static testMethod void getLeadsToContact_NewLead_WithRecentCreatedDate_RecentActivityHistory() {
		BusinessHours theBusinessHours = [select id from BusinessHours where IsDefault=true limit 1];

		Lead tempLead = new Lead();
		tempLead.LastName = 'Airy';
		tempLead.FirstName = 'David';
		tempLead.Company = tempLead.LastName + ', ' + tempLead.FirstName;
		tempLead.Status = Lead_Status_Utility.OPEN_NEW_STATUS;		
		insert tempLead;

		Task tempTask = createCompletedTask(tempLead.id);
		insert tempTask;
						
		List<Lead> allLeads = Lead_Status_Utility.getOpenNewLeadsToContact();
		
		List<Lead> testLeads = keepTestLeads(tempLead, allLeads);
		
		System.debug('new testLeads.size = ' + testLeads.size());
				
		Integer expectedSize = 0;

		Integer actualSize = testLeads.size();
		
		System.assertEquals(expectedSize, actualSize);
    }

    public static testMethod void getLeadsToContact_NewLead_WithRecentCreatedDate_NoActivityHistory() {
		BusinessHours theBusinessHours = [select id from BusinessHours where IsDefault=true limit 1];

		Lead tempLead = new Lead();
		tempLead.LastName = 'Airy';
		tempLead.FirstName = 'David';
		tempLead.Company = tempLead.LastName + ', ' + tempLead.FirstName;
		tempLead.Status = Lead_Status_Utility.OPEN_NEW_STATUS;		
		insert tempLead;

		List<Lead> allLeads = Lead_Status_Utility.getOpenNewLeadsToContact();
		
		List<Lead> testLeads = keepTestLeads(tempLead, allLeads);
		
		System.debug('new testLeads.size = ' + testLeads.size());
		
		Integer expectedSize = 1;

		Integer actualSize = testLeads.size();
		
		System.assertEquals(expectedSize, actualSize);
    }


    public static testMethod void getLeadsToContact_NewLead_WithOldCreatedDate_MultipleActivityHistory() {
		BusinessHours theBusinessHours = [select id from BusinessHours where IsDefault=true limit 1];

		Lead tempLead = new Lead();
		tempLead.LastName = 'Airy';
		tempLead.FirstName = 'David';
		tempLead.Company = tempLead.LastName + ', ' + tempLead.FirstName;
		tempLead.Status = Lead_Status_Utility.OPEN_NEW_STATUS;		
		insert tempLead;

		tempLead.Lead_Created_Date__c = Datetime.parse('10/13/2011 3:23 PM');
		update tempLead;

		// insert tasks
		Task tempTask = createCompletedTask(tempLead.id, Date.parse('10/13/2011'));
		insert tempTask;
		
		List<Lead> allLeads = Lead_Status_Utility.getOpenNewLeadsToContact();
		
		List<Lead> testLeads = keepTestLeads(tempLead, allLeads);
		
		System.debug('new testLeads.size = ' + testLeads.size());
				
		Integer expectedSize = 0;

		Integer actualSize = testLeads.size();
		
		// System.assertEquals(expectedSize, actualSize);
    }

	
}