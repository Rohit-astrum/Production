/* FILE: AAA_PVWattsTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: October 30, 2012
 * PURPOSE: Code coverage for PVWatts class.  Added AAA prefix to get around WebServiceMock bug.  
 * MODIFICATION HISTORY
 *
 */ 

@isTest
public class AAA_PVWattsTest {
	
	static testMethod void coverPVWatts() {
		
		//instantiate classes
		
		PVWatts pvw = new PVWatts();
		
		PVWatts.PVWATTSinfo pvwi = new PVWatts.PVWATTSinfo();
		
		PVWatts.GetPVWATTS_element gpvwe = new PVWatts.GetPVWATTS_element();
		
		PVWatts.ArrayOfPVWATTSinfo aopvwi = new PVWatts.ArrayOfPVWATTSinfo();
		
		//call web services
			
		Test.setMock(WebServiceMock.class, new PVWattsMock());
		
		PVWatts.PVWATTSSoap pvwSOAP = new PVWatts.PVWATTSSoap();
			
		pvwSOAP.GetPVWATTS(null, null, null, null, null, null, null, null, null, null, null, null);
		
	}
	

	

}