@isTest
private class CompanyWideReportTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out

    public class TestException extends Exception {}

	@isTest static void test_debugControllerDaily() {
		if(!runalltests){ return; }

		CreateMetricData();

		// Create previous reports
		Company_Wide_Report__c previousCWR = new Company_Wide_Report__c(
			Reporting_Frequency__c = 'Daily',
			End_Date__c = Date.today().addDays(-2)
		);
		insert previousCWR;

		Metric__c metric = [SELECT Id FROM Metric__c WHERE Query_Name__c = 'Lead Count'];
		Reported_Metric_Value__c previousRMV = new Reported_Metric_Value__c(
			Company_Wide_Report__c = previousCWR.Id,
			Metric__c = metric.Id,
			Reported_Value__c = 1,
			Month_To_Date__c = 3,
			Year_To_Date__c = 5
		);
		insert previousRMV;

		CompanyWideReportDebugController debugController = new CompanyWideReportDebugController();

		system.assertEquals(3, debugController.reportTypes.size());

		Test.startTest();

		debugController.selectedReportType = 'Daily';
		debugController.view();
		debugController.process();

		Test.stopTest();

		List<Company_Wide_Report__c> reports = [SELECT Id, Reporting_Frequency__c, End_Date__c FROM Company_Wide_Report__c];
		system.debug('**SZ: ' + reports);
		system.assertEquals(2, reports.size());
	}

	@isTest static void test_debugControllerWeekly() {
		if(!runalltests){ return; }

		Date thisMonday;
		if(DayOfWeek(Date.today()) == 0){
			thisMonday = Date.today();
		} else {
			thisMonday = Date.today().addDays((-1 * DayOfWeek(Date.today())));
		}
		Date prevMonday = thisMonday.addDays(-7);

		system.assertEquals(0, DayOfWeek(thisMonday));
		system.assertEquals(0, DayOfWeek(prevMonday));
		CreateMetricData();

		// Create previous reports
		Company_Wide_Report__c previousCWR = new Company_Wide_Report__c(
			Reporting_Frequency__c = 'Weekly',
			End_Date__c = prevMonday
		);
		insert previousCWR;

		Metric__c metric = [SELECT Id FROM Metric__c WHERE Query_Name__c = 'Lead Count'];
		Reported_Metric_Value__c previousRMV = new Reported_Metric_Value__c(
			Company_Wide_Report__c = previousCWR.Id,
			Metric__c = metric.Id,
			Reported_Value__c = 1,
			Month_To_Date__c = 3,
			Year_To_Date__c = 5
		);
		insert previousRMV;

		CompanyWideReportDebugController debugController = new CompanyWideReportDebugController();

		system.assertEquals(3, debugController.reportTypes.size());

		Test.startTest();

		debugController.selectedReportType = 'Weekly';
		debugController.view();
		debugController.process();

		Test.stopTest();

		List<Company_Wide_Report__c> reports = [SELECT Id, Reporting_Frequency__c, End_Date__c FROM Company_Wide_Report__c];
		system.debug('**SZ: ' + reports);
		system.assertEquals(2, reports.size());
	}
	
	@isTest(SeeAllData=true) static void test_InputController() {
		if(!runalltests){ return; }

		//CreateMetricData();
		List<Metric__c> manualMetrics = [SELECT Id FROM Metric__c WHERE Is_Calculated__c = false LIMIT 1];
		if(manualMetrics.size() == 0){ return; }

		Metric__c manualMetric = manualMetrics[0];

		Test.startTest();

		CompanyWideReportInputController cwrInput = new CompanyWideReportInputController();
		system.assertEquals(2, cwrInput.years.size());
		system.assertEquals(13, cwrInput.periods.size());
		cwrInput.load();

		cwrInput.selectedYear = Date.today().year() - 1;
		cwrInput.selectedPeriod = '8';

		cwrInput.load();
		cwrInput.preview();
		cwrInput.newRMV();
		system.assertNotEquals(0, cwrInput.reportedMetricValues[0].metricOptions.size());

		cwrInput.newRMV();
		system.assertNotEquals(0, cwrInput.reportedMetricValues[1].metricOptions.size());
		cwrInput.rowToDelete = 1;
		cwrInput.deleteRow();

		cwrInput.reportedMetricValues[0].selectedValue = manualMetric.Id;
		cwrInput.reportedMetricValues[0].reportedMetricValue.Reported_Value__c = 8;
		cwrInput.reportedMetricValues[0].reportedMetricValue.Month_To_Date__c = 8;
		cwrInput.reportedMetricValues[0].reportedMetricValue.Year_To_Date__c = 8;

		Test.stopTest();

system.debug('**SZ: ' + cwrInput.reportedMetricValues);
		cwrInput.send();

		cwrInput.load();
	}
	
	@isTest static void test_ProcessorDaily() {
		if(!runalltests){ return; }

		CreateMetricData();

		String CRON_EXP = '0 0 0 15 3 ? 2022';

		Test.startTest();

		String jobId = System.schedule('CompanyWideReportProcessorTest',
			CRON_EXP, 
			new CompanyWideReportDailyProcessor());
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

		System.assertEquals(CRON_EXP, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));

		Test.stopTest();

		system.debug('**SZ: stop test called.');

		List<Company_Wide_Report__c> reports = [SELECT Id, Reporting_Frequency__c, End_Date__c FROM Company_Wide_Report__c];
		system.assertEquals(1, reports.size());
	}
	
	@isTest static void test_ProcessorWeeklyNotOnMonday() {
		if(!runalltests){ return; }

		CreateMetricData();

		String CRON_EXP = '0 0 0 15 3 ? 2022';

		Test.startTest();

		String jobId = System.schedule('CompanyWideReportProcessorTest',
			CRON_EXP, 
			new CompanyWideReportWeeklyProcessor());
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

		System.assertEquals(CRON_EXP, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));

		Test.stopTest();

		List<Company_Wide_Report__c> reports = [SELECT Id, Reporting_Frequency__c, End_Date__c FROM Company_Wide_Report__c];
		if(DayOfWeek(Date.today()) == 0){
			system.assertEquals(1, reports.size());
		} else {
			system.assertEquals(0, reports.size());
		}
	}
	
	@isTest static void test_ProcessorWeeklyOnMonday() {
		if(!runalltests){ return; }

		CreateMetricData();

		Date monday = Date.newInstance(2015, 6, 29);
		String CRON_EXP = '0 0 0 15 3 ? 2022';

		Test.startTest();

		String jobId = System.schedule('CompanyWideReportProcessorTest',
			CRON_EXP, 
			new CompanyWideReportWeeklyProcessor(monday));
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

		System.assertEquals(CRON_EXP, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));

		Test.stopTest();

		List<Company_Wide_Report__c> reports = [SELECT Id, Reporting_Frequency__c, End_Date__c FROM Company_Wide_Report__c];
		system.assertEquals(1, reports.size());
	}

	@isTest private static void test_componentControllerDaily(){
		if(!runalltests){ return; }

		CreateMetricData();

		CompanyWideReportController componentController = new CompanyWideReportController();		
		componentController.reportType = 'Monthly';

		componentController = new CompanyWideReportController();
		CompanyWideReportDebugController debugController = new CompanyWideReportDebugController();

		system.assertEquals(debugController.reportTypes.size(), 3);

		Test.startTest();

		debugController.selectedReportType = 'Daily';
		debugController.view();
		debugController.process();

		Test.stopTest();

		componentController.reportType = 'Daily';
		system.assertEquals(3, componentController.documentUrls.keySet().size());
	}

	@isTest private static void test_componentControllerWeekly(){
		if(!runalltests){ return; }

		CreateMetricData();
		
		CompanyWideReportController componentController = new CompanyWideReportController();		
		CompanyWideReportDebugController debugController = new CompanyWideReportDebugController();

		system.assertEquals(debugController.reportTypes.size(), 3);

		Test.startTest();

		debugController.selectedReportType = 'Weekly';
		debugController.view();
		debugController.process();

		Test.stopTest();

		componentController.reportType = 'Weekly';
		system.assertEquals(3, componentController.documentUrls.keySet().size());
	}

	@isTest private static void test_OverlappingTargetDates(){
		if(!runalltests){ return; }

		CreateMetricData();

		Metric__c dailyTargetMetric = [SELECT Id FROM Metric__c WHERE Name = 'Test Daily Target' LIMIT 1];
		Metric_Target_Goal__c dailyTargetGoal = [SELECT Id, Effective_From__c FROM Metric_Target_Goal__c WHERE Metric__c = :dailyTargetMetric.Id];
		dailyTargetGoal.Effective_From__c = dailyTargetGoal.Effective_From__c.addDays(-30);
		update dailyTargetGoal;

		try
		{
			Metric_Target_Goal__c dailyTargetGoal2 = new Metric_Target_Goal__c(
				Name = 'LE2',
				Metric__c = dailyTargetMetric.Id,
				Is_Active__c = true,
				Effective_From__c = Date.newInstance(2014, 12, 16),
				Effective_To__c = Date.newInstance(2015, 12, 15),
				Daily_Target__c = 5,
				Weekly_Target__c = 10,
				Monthly_Target__c = 20,
				Annual_Target__c = 30
			);

			insert dailyTargetGoal2;
			throw new TestException('An exception should have been thrown by the trigger but was not.');
		}
		catch(Exception e)
		{
			System.AssertEquals(e.getMessage().contains('Effective Range overlaps with an existing target.'), true);
		}
	}

	private static Integer DayOfWeek(Date resolveDate){
		Date monday = Date.newInstance(1900, 1, 1);
		return Math.mod(monday.daysBetween(resolveDate), 7);
	}

	private static void CreateMetricData(){
		List<Metric__c> existingMetrics = [SELECT Id, Include_On_Report__c FROM Metric__c];
		for(Metric__c metric : existingMetrics){
			metric.Include_On_Report__c = false;
		}
		update existingMetrics;

		Schema.DescribeFieldResult fieldResult = Metric__c.Query_Name__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

		// create calculated metrics
		List<Metric__c> metrics = new List<Metric__c>();
		List<Metric_Target_Goal__c> metricGoals = new List<Metric_Target_Goal__c>();
		for(Schema.PicklistEntry entry : ple)
		{
			String name = entry.getValue();
			Metric__c metric = new Metric__c(
				Name = name,
				Include_On_Report__c = true,
				Is_Calculated__c = true,
				Query_Name__c = name,
				Display_Order__c = 40 + metrics.size()
			);

			if (name.toLowerCase().Contains('backlog') || name.toLowerCase().Contains('appointments')){
				metric.Reporting_Frequency__c = 'Daily;Weekly';
				metric.Calculate_Delta__c = true;
				metric.Headcount_Profiles__c = 'System Administrator';
				metric.Delta_Object_Name__c = 'Test';
			} else {
				metric.Reporting_Frequency__c = 'Weekly;Monthly';
				metric.Calculate_Delta__c = false;
				metric.Headcount_Profiles__c = '';
				metric.Delta_Object_Name__c = '';
			}
			
			metrics.add(metric);
		}

		// create a manual metric
		Metric__c manualMetric = new Metric__c(
			Name = 'Test Manual',
			Include_On_Report__c = true,
			Is_Calculated__c = false,
			Display_Order__c = 40 + metrics.size(),
			Reporting_Frequency__c = 'Monthly',
			Calculate_Delta__c = false,
			Headcount_Profiles__c = '',
			Delta_Object_Name__c = ''
		);
		metrics.add(manualMetric);

		Metric__c dailyTargetMetric = new Metric__c(
			Name = 'Test Daily Target',
			Include_On_Report__c = true,
			Is_Calculated__c = true,
			Query_Name__c = 'opportunity count',
			Display_Order__c = 40 + metrics.size(),
			Reporting_Frequency__c = 'Daily',
			Calculate_Delta__c = false,
			Headcount_Profiles__c = '',
			Delta_Object_Name__c = ''
		);
		metrics.add(dailyTargetMetric);

		insert metrics;

		List<Metric__c> targetedMetrics = [SELECT Id, Name FROM Metric__c WHERE Reporting_Frequency__c INCLUDES ('Monthly')];
		for(Metric__c tm : targetedMetrics){
			if(tm.Name.toLowerCase().Contains('headcount')){
				Metric_Target_Goal__c goal = new Metric_Target_Goal__c(
					Name = 'LE2',
					Metric__c = tm.Id,
					Is_Active__c = true,
					Effective_From__c = Date.newInstance(2014, 12, 16),
					Effective_To__c = Date.newInstance(2015, 12, 15),
					Monthly_Target__c = 20
				);
				metricGoals.add(goal);
			} else {
				Metric_Target_Goal__c goal = new Metric_Target_Goal__c(
					Name = 'LE2',
					Metric__c = tm.Id,
					Is_Active__c = true,
					Effective_From__c = Date.newInstance(2014, 12, 16),
					Effective_To__c = Date.newInstance(2015, 12, 15),
					Weekly_Target__c = 10,
					Monthly_Target__c = 20,
					Annual_Target__c = 30
				);
				metricGoals.add(goal);
			}
		}

		dailyTargetMetric = [SELECT Id FROM Metric__c WHERE Name = 'Test Daily Target' LIMIT 1];
		Metric_Target_Goal__c dailyTargetGoal = new Metric_Target_Goal__c(
			Name = 'LE2',
			Metric__c = dailyTargetMetric.Id,
			Is_Active__c = true,
			Effective_From__c = Date.newInstance(2014, 12, 16),
			Effective_To__c = Date.newInstance(2015, 12, 15),
			Daily_Target__c = 5,
			Weekly_Target__c = 10,
			Monthly_Target__c = 20,
			Annual_Target__c = 30
		);
		metricGoals.add(dailyTargetGoal);

		insert metricGoals;

		List<Document> docs = new List<Document>();
		docs.add(new Document(Name='ArrowLine', FolderId=UserInfo.getUserId()));
		docs.add(new Document(Name='ChartLegend1', FolderId=UserInfo.getUserId()));
		docs.add(new Document(Name='ChartLegend2', FolderId=UserInfo.getUserId()));
		insert docs;
	}
}