/* FILE: AstrumDailyReportTests.cls
 * AUTHOR: Rohit Jain
 * DATE: August 21, 2014
 * PURPOSE: Test Methods for AstrumDailyReportProcessor and  AstrumDailyReportSettingsController
 */
@isTest
private class AstrumDailyReportTests {
	
	@isTest static void testProcessReport() {
		
		Astrum_Daily_Report__c adr = new Astrum_Daily_Report__c();
		adr.RecordTypeid = [select id from RecordType where sObjectType = 'Astrum_Daily_Report__c' and DeveloperName = 'Goal'].id;
		adr.daily_Goal_Leads_Num__c = 1;
		adr.monthly_Goal_Leads_Num__c = 1;
		insert adr;

		Test.startTest();

		AstrumDailyReportProcessor apr = new AstrumDailyReportProcessor();
		apr.processReport();

		Test.stopTest();

		List<Astrum_Daily_Report__c> actual = [Select id from Astrum_Daily_Report__c where RecordType.DeveloperName = 'Actual'];
		System.assertEquals(1,actual.size());
	}
	
	@isTest static void testSettings() {
		Astrum_Daily_Report__c adr = new Astrum_Daily_Report__c();
		adr.RecordTypeid = [select id from RecordType where sObjectType = 'Astrum_Daily_Report__c' and DeveloperName = 'Goal'].id;
		adr.daily_Goal_Leads_Num__c = 1;
		adr.monthly_Goal_Leads_Num__c = 1;
		insert adr;

		Test.startTest();

		Test.setCurrentPage(Page.AstrumDailyReportSettings);
		AstrumDailyReportSettingsController cr = new AstrumDailyReportSettingsController();
		cr.adr.yearly_Goal_Leads_Num__c = 1;
		cr.save();

		Test.stopTest();
		
		Astrum_Daily_Report__c goal = [Select id,yearly_Goal_Leads_Num__c from Astrum_Daily_Report__c where RecordType.DeveloperName = 'Goal'];

		System.assertEquals(1,goal.yearly_Goal_Leads_Num__c);

		cr.edit();
		cr.cancel();  
	}
	
}