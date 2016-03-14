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
private class Opportunity_Status_Utility_Test {

    public static testMethod void testSendEmailForEarlyStageOpportunities() {
    	
		Opportunity_Status_Utility.sendEmailForEarlyStageOpportunities();

    }

    public static testMethod void testSendEmailForMediumStageOpportunities() {
    	
		Opportunity_Status_Utility.sendEmailForMediumStageOpportunities();

    }

    public static testMethod void testSendEmailForLateStageOpportunities() {
    	
		Opportunity_Status_Utility.sendEmailForLateStageOpportunities();

    }

    public static testMethod void testGetAllOpportunites() {
    	
		Opportunity_Status_Utility.getAllOpportunities(Opportunity_Status_Utility.ASSIGNED_TO_FIELD_SALES);
    }
    
    public static testMethod void testGetPlural_Single() {
    	
    	String base = 'computer';
    	String expected = base;
    	
    	String actual = Opportunity_Status_Utility.getPlural(base, 1);
    	
    	System.assertEquals(expected, actual);
    }

    public static testMethod void testGetPlural_Multiple() {
    	
    	String base = 'computer';
    	String expected = base + 's';
    	
    	String actual = Opportunity_Status_Utility.getPlural(base, 5);
    	
    	System.assertEquals(expected, actual);
    }

}