/* FILE: CompanyWideReportDailyProcessor.cls
 * AUTHOR: Steve Zilligen
 * DATE: June 25, 2015
 * PURPOSE: Class to populate the reporting object for the daily Company Wide Report
 */
global class CompanyWideReportDailyProcessor implements Schedulable {
	global void execute(SchedulableContext sc) {
		CompanyWideReportCalculator.processDaily();
	}
}