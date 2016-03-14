/* FILE: PMProjectReportTest.cls
 * AUTHOR: Pavitra Burla
 * DATE: Feb 11, 2016
 * PURPOSE: test class for PMProjectReport
 * MODIFICATION HISTORY
 *
 */
@isTest(SeeAllData=true)
public class PMProjectReportTest {
	static testmethod void testProjectReport(){
		
		Test.startTest();

		Test.setCurrentPage(Page.PMProjectReport);
		PMProjectReport projectReport = new PMProjectReport();

		System.assertEquals(true,PMProjectReport.getPropertyTypes().size()>1);
		projectReport.generateReport();
		projectReport.exportToExcel();
		projectReport.proofOfInspection = 'Yes';
		projectReport.generateReport();
		System.assertEquals(false,ApexPages.hasMessages());
		
		Test.stopTest();

	}
}