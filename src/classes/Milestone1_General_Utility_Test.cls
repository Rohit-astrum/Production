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
private class Milestone1_General_Utility_Test {

	public static testMethod void testGetStateFromAstrumOfficeGivenCityAndState() {
		String expected = 'PA';
		
		String astrumOffice = 'Norristown, PA';
		String actual = Milestone1_General_Utility.getStateFromAstrumOffice(astrumOffice);
		
		System.assertEquals(expected, actual);
	}

	public static testMethod void testGetStateFromAstrumOfficeGivenStateOnly() {
		String expected = 'PA';
		
		String astrumOffice = 'PA';
		String actual = Milestone1_General_Utility.getStateFromAstrumOffice(astrumOffice);
		
		System.assertEquals(expected, actual);
	}
	
	public static testMethod void testTruncateString() {
		String expected = 'NEW DESCRIPTION 1234567890 ABCDEFGHIJKLMNOPQRSTUVWXYZ THIS IS LONG...';
        String example  = 'NEW DESCRIPTION 1234567890 ABCDEFGHIJKLMNOPQRSTUVWXYZ THIS IS LONG DESCRIPTION GREATER THAN 80 CHARACTER LIMIT FOR NAME TEST TRUNCATING';
        
        String actual = Milestone1_General_Utility.processTaskName(example);
        System.assertEquals(expected, actual);
    } 
    
    public static testMethod void testTruncateIdFrom18Digits() {
 		
 		String expected = '123456789012345';
 		String data = '123456789012345678';
 		
		String actual = Milestone1_General_Utility.truncateId(data);	 		   	
		
		System.assertEquals(expected, actual);
    }
    
    public static testMethod void testTruncateIdFrom15Digits() {
 		
 		String expected = '123456789012345';
 		String data = '123456789012345';
 		
		String actual = Milestone1_General_Utility.truncateId(data);	 		   	
		
		System.assertEquals(expected, actual);
    }

    public static testMethod void testTruncateIdWithInvalidLength() {
 		
 		String data = '12345678901234524';
 		
		String actual = Milestone1_General_Utility.truncateId(data);	 		   	
		System.assert(actual == null);
    }

    public static testMethod void testIsSysAdmin() {
 		
 		Boolean expected = true;
 		
 		Boolean actual = Milestone1_General_Utility.isSysAdmin();	 		   	
		System.assertEquals(expected, actual);
    }
    
}