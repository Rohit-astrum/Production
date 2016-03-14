/* FILE: CompanyWideReportWeeklyProcessor.cls
 * AUTHOR: Steve Zilligen
 * DATE: June 25, 2015
 * PURPOSE: Class to populate the reporting object for the weekly Company Wide Report
 */
global class CompanyWideReportWeeklyProcessor implements Schedulable {
	
	private Date runDate {get; private set;}

	global CompanyWideReportWeeklyProcessor(){
	}
	
	global CompanyWideReportWeeklyProcessor(Date providedRunDate){
		runDate = providedRunDate;
	}
	
	global void execute(SchedulableContext sc) {
		if(runDate != null){
			processReport(runDate);
		} else {
			processReport(Date.today());
		}
	}

	private void processReport(Date providedDate){
		if(DayOfWeek(providedDate) == 0){
			Integer daysAgo = (-1 * providedDate.daysBetween(Date.today())) - 1;
			system.debug('**SZ: runDate = ' + runDate);
			system.debug('**SZ: daysAgo = ' + daysAgo);
			CompanyWideReportCalculator.processWeekly(daysAgo);
		}
	}

	private Integer DayOfWeek(Date resolveDate){
		Date monday = Date.newInstance(1900, 1, 1);
		return Math.mod(monday.daysBetween(resolveDate), 7);
	}
}