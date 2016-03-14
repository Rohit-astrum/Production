public with sharing class CompanyWideReportDebugController {

	public List<SelectOption> reportTypes{
		get{
			List<SelectOption> options = new List<SelectOption>();
			options.add(new SelectOption('',''));
			options.add(new SelectOption('Daily','Daily'));
			options.add(new SelectOption('Weekly','Weekly'));
			return options;
		}
	}
	public String selectedReportType {get;set;}
	public Boolean selectedManagementOnly {get;set;}
	public String numberofqueries {get;set;}
	public String numberofcallouts {get;set;}
	public Boolean showLimits {get;set;}
	public Boolean showPreview {get;set;}

	public CompanyWideReportDebugController() {
		numberofqueries = 'Queries: 0';
		numberofcallouts = 'callouts: 0';
		showPreview = false;
	}

	public PageReference view(){
		showLimits = false;
		showPreview = true;
		return null;
	}

	public PageReference process(){
		if(selectedReportType == 'Daily'){
			CompanyWideReportCalculator.processDaily();
		} else if (selectedReportType == 'Weekly'){
			Integer daysAgo = (-1 * DayOfWeek(Date.today())) - 1;
			CompanyWideReportCalculator.processWeekly(daysAgo);
		}
		numberofqueries = 'Queries: ' + String.valueOf(Limits.getQueries());
		numberofcallouts = 'Callouts: ' + String.valueOf(Limits.getCallouts());
		showLimits = true;
		showPreview = true;

		return null;
	}

	private Integer DayOfWeek(Date resolveDate){
		Date monday = Date.newInstance(1900, 1, 1);
		return Math.mod(monday.daysBetween(resolveDate), 7);
	}
}