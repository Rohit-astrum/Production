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
private class Opportunity_Status_Controller_Ext_Test {

    static testMethod void testEarlyStageOpportunities_NotContacted() {
		
		// setup
		Opportunity opp = Milestone1_Test_Utility.CreateTestOpp();
		opp.StageName = Opportunity_Status_Utility.ASSIGNED_TO_FIELD_SALES;
		update opp;
		
		// execute
		ApexPages.Standardcontroller standController = new ApexPages.Standardcontroller(new Opportunity());
		Opportunity_Status_Controller_Extension controller = new Opportunity_Status_Controller_Extension(standController);

		// assert data
		List<Opportunity_Status_Holder> earlyStageOpps = controller.earlyStageOpportunitiesToContact;
		List<Opportunity_Status_Holder> mediumStageOpps = controller.mediumStageOpportunitiesToContact;
		List<Opportunity_Status_Holder> lateStageOpps = controller.lateStageOpportunitiesToContact;

		// confirm this is early stage
		/*
		Boolean expectedEarlyStage = true;
		Boolean actualEarlyStage = contains(earlyStageOpps, opp.Id);
		System.assertEquals(expectedEarlyStage, actualEarlyStage);

		
		// and in the other stages
		Boolean expectedMediumStage = true;
		Boolean actualMediumStage = contains(mediumStageOpps, opp.Id);
		System.assertEquals(expectedMediumStage, actualMediumStage);
				    	
		Boolean expectedLateStage = true;
		Boolean actualLateStage = contains(lateStageOpps, opp.Id);
		System.assertEquals(expectedLateStage, actualLateStage);
		*/
    }
    
    private static boolean contains(List<Opportunity_Status_Holder> holders, Id theOppId) {
 		boolean result = false;
 		
 		for (Opportunity_Status_Holder tempHolder : holders) {
 			if (tempHolder.theOpportunity.Id == theOppId) {
 				result = true;
 				break;
 			}	
 		}
 		
 		return result;   	
    }
}