/* FILE: CompanyWideReportCalculator.cls
 * AUTHOR: Steve Zilligen
 * DATE: May 5, 2015
 * PURPOSE: Class to calculate the data for the Company Wide Report
 */
public with sharing class CompanyWideReportCalculator {

	private static Map<Id, Integer> metricHeadcountsMap;
	private static Map<Id, Double> metricPreviousValuesMap;
	private static Map<String, Type> queryNameToTypeMap;
	private static Map<Type, Integer> batchSizeMap;

	private static void populateValidQueryNames(){
		queryNameToTypeMap = new Map<String, Type>();
		queryNameToTypeMap.put('lead backlog', Lead.class);
		queryNameToTypeMap.put('lead count', Lead.class);
		queryNameToTypeMap.put('lead conversion rate', Lead.class);
		queryNameToTypeMap.put('system design backlog', Event.class);
		queryNameToTypeMap.put('appointments scheduled', Event.class);
		queryNameToTypeMap.put('appointments completed', Event.class);
		queryNameToTypeMap.put('median time to first sales call', Event.class);
		queryNameToTypeMap.put('opportunity backlog', Opportunity.class);
		queryNameToTypeMap.put('opportunity count', Opportunity.class);
		queryNameToTypeMap.put('opportunity conversion rate', Opportunity.class);
		queryNameToTypeMap.put('sales count', Opportunity.class);
		queryNameToTypeMap.put('total referrals count', Opportunity.class);
		queryNameToTypeMap.put('internal referrals count', Opportunity.class);
		queryNameToTypeMap.put('cancellations', Opportunity.class);
		queryNameToTypeMap.put('sales order backlog', SCRB_SalesOrder__c.class);
		queryNameToTypeMap.put('capacity in backlog', SCRB_SalesOrder__c.class);
		queryNameToTypeMap.put('customer case backlog', Case.class);
		queryNameToTypeMap.put('maintenance backlog', Case.class);
		queryNameToTypeMap.put('nps', Customer_Survey__c.class);
		queryNameToTypeMap.put('kickoff backlog', PM_Project__c.class);
		queryNameToTypeMap.put('install backlog', PM_Project__c.class);
		queryNameToTypeMap.put('inspection backlog', PM_Project__c.class);
		queryNameToTypeMap.put('inspections count', PM_Project__c.class);
		queryNameToTypeMap.put('capacity inspected', PM_Project__c.class);
		queryNameToTypeMap.put('average system size', PM_Project__c.class);
		queryNameToTypeMap.put('median time sale to inspection', PM_Project__c.class);
		queryNameToTypeMap.put('median time project creation to inspection', PM_Project__c.class);
		queryNameToTypeMap.put('operations headcount', User.class);
		queryNameToTypeMap.put('sales consultant headcount', User.class);
	}

	private static void populateBatchSizeMap(){
		batchSizeMap = new Map<Type, Integer>();
		batchSizeMap.put(Lead.class, 200);
		batchSizeMap.put(Event.class, 400);
		batchSizeMap.put(Opportunity.class, 200);
		batchSizeMap.put(SCRB_SalesOrder__c.class, 200);
		batchSizeMap.put(Case.class, 200);
		batchSizeMap.put(Customer_Survey__c.class, 200);
		batchSizeMap.put(PM_Project__c.class, 1000);
		batchSizeMap.put(User.class, 200);
	}

	private static Map<Id, String> getMetricIdToQueryNameMap(String reportingFrequency){
		List<Metric__c> metrics = [SELECT Id, Query_Name__c FROM Metric__c WHERE Is_Calculated__c = true AND Include_On_Report__c = true AND Reporting_Frequency__c INCLUDES (:reportingFrequency)];
		Map<Id, String> metricIdToQueryNameMap = new Map<Id, String>();
		for(Metric__c metric : metrics){
			metricIdToQueryNameMap.put(metric.Id, metric.Query_Name__c);
		}
		return metricIdToQueryNameMap;
	}

	private static Map<String, Integer> GetHeadcountByNameMap(String headcountProfilesString){
		Map<String, Integer> headcountsByName = new Map<String, Integer>();
		List<String> headcountProfiles = headcountProfilesString.replace(' ,', ',').replace(', ', ',').split(',');
		AggregateResult[] headcountQuery = [SELECT Profile.Name nm, COUNT(Id) cnt FROM User WHERE IsActive = true AND Profile.Name IN :headcountProfiles GROUP BY Profile.Name];
		for(AggregateResult ar : headcountQuery){
			headcountsByName.put((String)ar.get('nm'), (Integer)ar.get('cnt'));
		}
		return headcountsByName;
	}

	private static Date GetReportingPeriodBegDate(Date dateInPeriod){
		Date today = dateInPeriod;
		Integer currDay = today.day() - 1;
        Integer currMonth = today.month();
        Integer currYear = today.year();

        if(currDay > 15)
        {
        	return Date.newInstance(currYear, currMonth, 16);
        }
        else
        {
            if(currMonth == 1)
            {
            	return Date.newInstance(currYear - 1, 12, 16);
            }
            else
            {
            	return Date.newInstance(currYear, currMonth - 1, 16);
            }
        }
	}

	private static Date GetReportingPeriodEndDate(Date dateInPeriod){
		Date today = dateInPeriod;
		Integer currDay = today.day() - 1;
        Integer currMonth = today.month();
        Integer currYear = today.year();

        if(currDay <= 15)
        {
        	return Date.newInstance(currYear, currMonth, 15);
        }
        else
        {
            if(currMonth == 12)
            {
            	return Date.newInstance(currYear + 1, 1, 15);
            }
            else
            {
            	return Date.newInstance(currYear, currMonth + 1, 15);
            }
        }
	}

	public static void processDaily(){
		Company_Wide_Report__c cwr = getDailyCWR();
		upsert cwr;

		List<Reported_Metric_Value__c> rmvs = getDailyRMVS(cwr.Id);
		upsert rmvs;

		Map<Id, String> metricIdToQueryNameMap = getMetricIdToQueryNameMap('Daily');
		populateValidQueryNames();

		Set<Type> validTypes = new Set<Type>();
		for(String queryName : metricIdToQueryNameMap.values()){
			if(queryNameToTypeMap.containsKey(queryName.toLowerCase()) && !validTypes.contains(queryNameToTypeMap.get(queryName.toLowerCase()))){
				validTypes.add(queryNameToTypeMap.get(queryName.toLowerCase()));
			}
		}

		CompanyWideReportBatchCalculator batchCalculator;
		populateBatchSizeMap();
		if(validTypes.contains(Lead.class)){
			batchCalculator = new CompanyWideReportBatchCalculator(Lead.class, cwr.Id, cwr.End_Date__c, metricIdToQueryNameMap, metricHeadcountsMap, metricPreviousValuesMap);
			Database.executeBatch(batchCalculator, batchSizeMap.get(Lead.class));
		}
		if(validTypes.contains(Event.class)){
			batchCalculator = new CompanyWideReportBatchCalculator(Event.class, cwr.Id, cwr.End_Date__c, metricIdToQueryNameMap, metricHeadcountsMap, metricPreviousValuesMap);
			Database.executeBatch(batchCalculator, batchSizeMap.get(Event.class));
		}
		if(validTypes.contains(Opportunity.class)){
			batchCalculator = new CompanyWideReportBatchCalculator(Opportunity.class, cwr.Id, cwr.End_Date__c, metricIdToQueryNameMap, metricHeadcountsMap, metricPreviousValuesMap);
			Database.executeBatch(batchCalculator, batchSizeMap.get(Opportunity.class));
		}
		if(validTypes.contains(SCRB_SalesOrder__c.class)){
			batchCalculator = new CompanyWideReportBatchCalculator(SCRB_SalesOrder__c.class, cwr.Id, cwr.End_Date__c, metricIdToQueryNameMap, metricHeadcountsMap, metricPreviousValuesMap);
			Database.executeBatch(batchCalculator, batchSizeMap.get(SCRB_SalesOrder__c.class));
		}
		if(validTypes.contains(Case.class)){
			batchCalculator = new CompanyWideReportBatchCalculator(Case.class, cwr.Id, cwr.End_Date__c, metricIdToQueryNameMap, metricHeadcountsMap, metricPreviousValuesMap);
			Database.executeBatch(batchCalculator, batchSizeMap.get(Case.class));
		}
		if(validTypes.contains(Customer_Survey__c.class)){
			batchCalculator = new CompanyWideReportBatchCalculator(Customer_Survey__c.class, cwr.Id, cwr.End_Date__c, metricIdToQueryNameMap, metricHeadcountsMap, metricPreviousValuesMap);
			Database.executeBatch(batchCalculator, batchSizeMap.get(Customer_Survey__c.class));
		}
		if(validTypes.contains(PM_Project__c.class)){
			batchCalculator = new CompanyWideReportBatchCalculator(PM_Project__c.class, cwr.Id, cwr.End_Date__c, metricIdToQueryNameMap, metricHeadcountsMap, metricPreviousValuesMap);
			Database.executeBatch(batchCalculator, batchSizeMap.get(PM_Project__c.class));
		}
		if(validTypes.contains(User.class)){
			batchCalculator = new CompanyWideReportBatchCalculator(User.class, cwr.Id, cwr.End_Date__c, metricIdToQueryNameMap, metricHeadcountsMap, metricPreviousValuesMap);
			Database.executeBatch(batchCalculator, batchSizeMap.get(User.class));
		}

		cwr.Ready_To_Send__c = true;
		update cwr;
	}

	public static Company_Wide_Report__c getDailyCWR(){
		// get CWR if exists
		Company_Wide_Report__c cwr;

		List<Company_Wide_Report__c> cwrList = [SELECT Id, Reporting_Frequency__c, End_Date__c, Ready_To_Send__c FROM Company_Wide_Report__c WHERE Reporting_Frequency__c = 'Daily' AND End_Date__c = YESTERDAY LIMIT 1];
		if(cwrList.size() == 0){
			cwr = new Company_Wide_Report__c(Reporting_Frequency__c = 'Daily', End_Date__c = Date.today().addDays(-1));
		} else {
			cwr = cwrList[0];
		}

		return cwr;
	}

	public static List<Reported_Metric_Value__c> getDailyRMVS(Id cwrId){
		// get all daily metrics
		// Id = Metric__c.Id
		Map<Id, Metric__c> metrics = new Map<Id, Metric__c>([SELECT Id, Name, Calculate_Delta__c, Query_Name__c, Headcount_Profiles__c FROM Metric__c WHERE Is_Calculated__c = true AND Include_On_Report__c = true AND Reporting_Frequency__c INCLUDES ('Daily')]);

		// Id = Metric__c.Id
		List<String> metricHeadcountProfiles = new List<String>();
		for(Metric__c metric : metrics.values()){
			if(metric.Headcount_Profiles__c != ''){
				metricHeadcountProfiles.add(metric.Headcount_Profiles__c);
			}
		}
		Map<String, Integer> metricHeadcountsByNameMap = GetHeadcountByNameMap(String.join(metricHeadcountProfiles, ','));
		metricHeadcountsMap = new Map<Id, Integer>();
		for(Metric__c metric : metrics.values()){
			metricHeadcountsMap.put(metric.Id, 0);
			if(metric.Headcount_Profiles__c != null){
				List<String> profiles = metric.Headcount_Profiles__c.replace(' ,', ',').replace(', ', ',').split(',');
				for(String profile : profiles){
					if(metricHeadcountsByNameMap.containsKey(profile)){
						metricHeadcountsMap.put(metric.Id, metricHeadcountsMap.get(metric.Id) + metricHeadcountsByNameMap.get(profile));
					}
				}
			}
		}

		// get CWR if exists
		Company_Wide_Report__c previousCwr;

		// Id = Metric__c.Id
		Map<Id, Reported_Metric_Value__c> metricsToValuesMap = new Map<Id, Reported_Metric_Value__c>();
		metricPreviousValuesMap = new Map<Id, Double>();

		List<Company_Wide_Report__c> cwrList = [SELECT Id, Reporting_Frequency__c, End_Date__c, Ready_To_Send__c FROM Company_Wide_Report__c WHERE Reporting_Frequency__c = 'Daily' AND End_Date__c = LAST_N_DAYS:2];
		for(Company_Wide_Report__c cwrRecord : cwrList){
			if(cwrRecord.End_Date__c != Date.today().addDays(-1)){
				previousCwr = cwrRecord;
			}
		}
		if(cwrId != null){
			Map<Id, Reported_Metric_Value__c> reportedMetricValues = new Map<Id, Reported_Metric_Value__c>([SELECT Id, Company_Wide_Report__c, Metric__c, Reported_Value__c, Headcount__c, Delta__c, Week_To_Date__c, Month_To_Date__c, Year_To_Date__c FROM Reported_Metric_Value__c WHERE Company_Wide_Report__c = :cwrId]);
			for(Reported_Metric_Value__c metricValue : reportedMetricValues.values()){
				if(!metricsToValuesMap.containsKey(metricValue.Metric__c)){
					metricsToValuesMap.put(metricValue.Metric__c, metricValue);
				}
			}
		}
		if(previousCwr != null){
			Map<Id, Reported_Metric_Value__c> reportedMetricValues = new Map<Id, Reported_Metric_Value__c>([SELECT Id, Metric__c, Reported_Value__c FROM Reported_Metric_Value__c WHERE Company_Wide_Report__c = :previousCwr.Id]);
			for(Reported_Metric_Value__c metricValue : reportedMetricValues.values()){
				if(!metricPreviousValuesMap.containsKey(metricValue.Metric__c)){
					metricPreviousValuesMap.put(metricValue.Metric__c, metricValue.Reported_Value__c);
				}
			}
		}

		for(Id metricId : metrics.keySet()){
			if(!metricsToValuesMap.containsKey(metricId)){
				metricsToValuesMap.put(metricId, new Reported_Metric_Value__c(Company_Wide_Report__c = cwrId, Metric__c = metricId, Reported_Value__c = 0));
			}
		}

		return metricsToValuesMap.values();
	}

	public static void processWeekly(Integer daysAgo){
		Company_Wide_Report__c cwr = getWeeklyCWR(daysAgo);
		upsert cwr;

		List<Reported_Metric_Value__c> rmvs = getWeeklyRMVS(cwr.Id, daysAgo);
		upsert rmvs;

		Map<Id, String> metricIdToQueryNameMap = getMetricIdToQueryNameMap('Weekly');
		populateValidQueryNames();

		Set<Type> validTypes = new Set<Type>();
		for(String queryName : metricIdToQueryNameMap.values()){
			if(queryNameToTypeMap.containsKey(queryName.toLowerCase()) && !validTypes.contains(queryNameToTypeMap.get(queryName.toLowerCase()))){
				validTypes.add(queryNameToTypeMap.get(queryName.toLowerCase()));
			}
		}

		CompanyWideReportBatchCalculator batchCalculator;
		populateBatchSizeMap();
		if(validTypes.contains(Lead.class)){
			batchCalculator = new CompanyWideReportBatchCalculator(Lead.class, cwr.Id, cwr.End_Date__c, metricIdToQueryNameMap, metricHeadcountsMap, metricPreviousValuesMap);
			Database.executeBatch(batchCalculator, batchSizeMap.get(Lead.class));
		}
		if(validTypes.contains(Event.class)){
			batchCalculator = new CompanyWideReportBatchCalculator(Event.class, cwr.Id, cwr.End_Date__c, metricIdToQueryNameMap, metricHeadcountsMap, metricPreviousValuesMap);
			Database.executeBatch(batchCalculator, batchSizeMap.get(Event.class));
		}
		if(validTypes.contains(Opportunity.class)){
			batchCalculator = new CompanyWideReportBatchCalculator(Opportunity.class, cwr.Id, cwr.End_Date__c, metricIdToQueryNameMap, metricHeadcountsMap, metricPreviousValuesMap);
			Database.executeBatch(batchCalculator, batchSizeMap.get(Opportunity.class));
		}
		if(validTypes.contains(SCRB_SalesOrder__c.class)){
			batchCalculator = new CompanyWideReportBatchCalculator(SCRB_SalesOrder__c.class, cwr.Id, cwr.End_Date__c, metricIdToQueryNameMap, metricHeadcountsMap, metricPreviousValuesMap);
			Database.executeBatch(batchCalculator, batchSizeMap.get(SCRB_SalesOrder__c.class));
		}
		if(validTypes.contains(Case.class)){
			batchCalculator = new CompanyWideReportBatchCalculator(Case.class, cwr.Id, cwr.End_Date__c, metricIdToQueryNameMap, metricHeadcountsMap, metricPreviousValuesMap);
			Database.executeBatch(batchCalculator, batchSizeMap.get(Case.class));
		}
		if(validTypes.contains(Customer_Survey__c.class)){
			batchCalculator = new CompanyWideReportBatchCalculator(Customer_Survey__c.class, cwr.Id, cwr.End_Date__c, metricIdToQueryNameMap, metricHeadcountsMap, metricPreviousValuesMap);
			Database.executeBatch(batchCalculator, batchSizeMap.get(Customer_Survey__c.class));
		}
		if(validTypes.contains(PM_Project__c.class)){
			batchCalculator = new CompanyWideReportBatchCalculator(PM_Project__c.class, cwr.Id, cwr.End_Date__c, metricIdToQueryNameMap, metricHeadcountsMap, metricPreviousValuesMap);
			Database.executeBatch(batchCalculator, batchSizeMap.get(PM_Project__c.class));
		}
		if(validTypes.contains(User.class)){
			batchCalculator = new CompanyWideReportBatchCalculator(User.class, cwr.Id, cwr.End_Date__c, metricIdToQueryNameMap, metricHeadcountsMap, metricPreviousValuesMap);
			Database.executeBatch(batchCalculator, batchSizeMap.get(User.class));
		}

		cwr.Ready_To_Send__c = true;
		update cwr;
	}

	public static Company_Wide_Report__c getWeeklyCWR(Integer daysAgo){
		// get CWR if exists
		Company_Wide_Report__c cwr;

		List<Company_Wide_Report__c> cwrList = [SELECT Id, Reporting_Frequency__c, End_Date__c, Ready_To_Send__c FROM Company_Wide_Report__c WHERE Reporting_Frequency__c = 'Weekly' AND End_Date__c = :Date.today().addDays(daysAgo) LIMIT 1];
		if(cwrList.size() == 0){
			cwr = new Company_Wide_Report__c(Reporting_Frequency__c = 'Weekly', End_Date__c = Date.today().addDays(daysAgo));
		} else {
			cwr = cwrList[0];
		}

		return cwr;
	}

	public static List<Reported_Metric_Value__c> getWeeklyRMVS(Id cwrId, Integer daysAgo){
		Integer weekAgo = daysAgo - 7;
		
		// get all weekly metrics
		// Id = Metric__c.Id
		Map<Id, Metric__c> metrics = new Map<Id, Metric__c>([SELECT Id, Name, Calculate_Delta__c, Query_Name__c, Headcount_Profiles__c FROM Metric__c WHERE Is_Calculated__c = true AND Include_On_Report__c = true AND Reporting_Frequency__c INCLUDES ('Weekly')]);

		// Id = Metric__c.Id
		List<String> metricHeadcountProfiles = new List<String>();
		for(Metric__c metric : metrics.values()){
			if(metric.Headcount_Profiles__c != ''){
				metricHeadcountProfiles.add(metric.Headcount_Profiles__c);
			}
		}
		Map<String, Integer> metricHeadcountsByNameMap = GetHeadcountByNameMap(String.join(metricHeadcountProfiles, ','));
		metricHeadcountsMap = new Map<Id, Integer>();
		for(Metric__c metric : metrics.values()){
			metricHeadcountsMap.put(metric.Id, 0);
			if(metric.Headcount_Profiles__c != null){
				List<String> profiles = metric.Headcount_Profiles__c.replace(' ,', ',').replace(', ', ',').split(',');
				for(String profile : profiles){
					if(metricHeadcountsByNameMap.containsKey(profile)){
						metricHeadcountsMap.put(metric.Id, metricHeadcountsMap.get(metric.Id) + metricHeadcountsByNameMap.get(profile));
					}
				}
			}
		}

		// get CWR if exists
		Company_Wide_Report__c previousCwr;

		// Id = Metric__c.Id
		Map<Id, Reported_Metric_Value__c> metricsToValuesMap = new Map<Id, Reported_Metric_Value__c>();
		metricPreviousValuesMap = new Map<Id, Double>();

		//List<Company_Wide_Report__c> cwrList = [SELECT Id, Reporting_Frequency__c, End_Date__c, Ready_To_Send__c FROM Company_Wide_Report__c WHERE Reporting_Frequency__c = 'Weekly' AND End_Date__c = LAST_N_DAYS:weekAgo];
		List<Company_Wide_Report__c> cwrList = [SELECT Id, Reporting_Frequency__c, End_Date__c, Ready_To_Send__c FROM Company_Wide_Report__c WHERE Reporting_Frequency__c = 'Weekly' AND End_Date__c >= :Date.today().addDays(weekAgo)];
		for(Company_Wide_Report__c cwrRecord : cwrList){
			if(cwrRecord.End_Date__c != Date.today().addDays(daysAgo)){
				previousCwr = cwrRecord;
			}
		}
		if(cwrId != null){
			Map<Id, Reported_Metric_Value__c> reportedMetricValues = new Map<Id, Reported_Metric_Value__c>([SELECT Id, Company_Wide_Report__c, Metric__c, Reported_Value__c, Headcount__c, Delta__c, Week_To_Date__c, Month_To_Date__c, Year_To_Date__c FROM Reported_Metric_Value__c WHERE Company_Wide_Report__c = :cwrId]);
			for(Reported_Metric_Value__c metricValue : reportedMetricValues.values()){
				if(!metricsToValuesMap.containsKey(metricValue.Metric__c)){
					metricsToValuesMap.put(metricValue.Metric__c, metricValue);
				}
			}
		}
		if(previousCwr != null){
			Map<Id, Reported_Metric_Value__c> reportedMetricValues = new Map<Id, Reported_Metric_Value__c>([SELECT Id, Metric__c, Reported_Value__c FROM Reported_Metric_Value__c WHERE Company_Wide_Report__c = :previousCwr.Id]);
			for(Reported_Metric_Value__c metricValue : reportedMetricValues.values()){
				if(!metricPreviousValuesMap.containsKey(metricValue.Metric__c)){
					metricPreviousValuesMap.put(metricValue.Metric__c, metricValue.Reported_Value__c);
				}
			}
		}

		for(Id metricId : metrics.keySet()){
			if(!metricsToValuesMap.containsKey(metricId)){
				metricsToValuesMap.put(metricId, new Reported_Metric_Value__c(Company_Wide_Report__c = cwrId, Metric__c = metricId, Reported_Value__c = 0));
			}
		}

		return metricsToValuesMap.values();
	}

	public static void processMonthly(Date reportingPeriodEndDate){
		Company_Wide_Report__c cwr = getMonthlyCWR(reportingPeriodEndDate);
		upsert cwr;

		List<Reported_Metric_Value__c> rmvs = getMonthlylyRMVS(cwr.Id, reportingPeriodEndDate);
		upsert rmvs;

		Map<Id, String> metricIdToQueryNameMap = getMetricIdToQueryNameMap('Monthly');
		populateValidQueryNames();

		Set<Type> validTypes = new Set<Type>();
		for(String queryName : metricIdToQueryNameMap.values()){
			if(queryNameToTypeMap.containsKey(queryName.toLowerCase()) && !validTypes.contains(queryNameToTypeMap.get(queryName.toLowerCase()))){
				validTypes.add(queryNameToTypeMap.get(queryName.toLowerCase()));
			}
		}

		CompanyWideReportBatchCalculator batchCalculator;
		populateBatchSizeMap();
		if(validTypes.contains(Lead.class)){
			batchCalculator = new CompanyWideReportBatchCalculator(Lead.class, cwr.Id, cwr.End_Date__c, metricIdToQueryNameMap, metricHeadcountsMap, metricPreviousValuesMap);
			Database.executeBatch(batchCalculator, batchSizeMap.get(Lead.class));
		}
		if(validTypes.contains(Event.class)){
			batchCalculator = new CompanyWideReportBatchCalculator(Event.class, cwr.Id, cwr.End_Date__c, metricIdToQueryNameMap, metricHeadcountsMap, metricPreviousValuesMap);
			Database.executeBatch(batchCalculator, batchSizeMap.get(Event.class));
		}
		if(validTypes.contains(Opportunity.class)){
			batchCalculator = new CompanyWideReportBatchCalculator(Opportunity.class, cwr.Id, cwr.End_Date__c, metricIdToQueryNameMap, metricHeadcountsMap, metricPreviousValuesMap);
			Database.executeBatch(batchCalculator, batchSizeMap.get(Opportunity.class));
		}
		if(validTypes.contains(SCRB_SalesOrder__c.class)){
			batchCalculator = new CompanyWideReportBatchCalculator(SCRB_SalesOrder__c.class, cwr.Id, cwr.End_Date__c, metricIdToQueryNameMap, metricHeadcountsMap, metricPreviousValuesMap);
			Database.executeBatch(batchCalculator, batchSizeMap.get(SCRB_SalesOrder__c.class));
		}
		if(validTypes.contains(Case.class)){
			batchCalculator = new CompanyWideReportBatchCalculator(Case.class, cwr.Id, cwr.End_Date__c, metricIdToQueryNameMap, metricHeadcountsMap, metricPreviousValuesMap);
			Database.executeBatch(batchCalculator, batchSizeMap.get(Case.class));
		}
		if(validTypes.contains(Customer_Survey__c.class)){
			batchCalculator = new CompanyWideReportBatchCalculator(Customer_Survey__c.class, cwr.Id, cwr.End_Date__c, metricIdToQueryNameMap, metricHeadcountsMap, metricPreviousValuesMap);
			Database.executeBatch(batchCalculator, batchSizeMap.get(Customer_Survey__c.class));
		}
		if(validTypes.contains(PM_Project__c.class)){
			batchCalculator = new CompanyWideReportBatchCalculator(PM_Project__c.class, cwr.Id, cwr.End_Date__c, metricIdToQueryNameMap, metricHeadcountsMap, metricPreviousValuesMap);
			Database.executeBatch(batchCalculator, batchSizeMap.get(PM_Project__c.class));
		}
		if(validTypes.contains(User.class)){
			batchCalculator = new CompanyWideReportBatchCalculator(User.class, cwr.Id, cwr.End_Date__c, metricIdToQueryNameMap, metricHeadcountsMap, metricPreviousValuesMap);
			Database.executeBatch(batchCalculator, batchSizeMap.get(User.class));
		}
	}

	public static Company_Wide_Report__c getMonthlyCWR(Date reportingPeriodEndDate){
		// get CWR if exists
		Company_Wide_Report__c cwr;

		List<Company_Wide_Report__c> cwrList = [SELECT Id, Reporting_Frequency__c, End_Date__c, Ready_To_Send__c FROM Company_Wide_Report__c WHERE Reporting_Frequency__c = 'Monthly' AND End_Date__c = :reportingPeriodEndDate LIMIT 1];
		if(cwrList.size() == 0){
			cwr = new Company_Wide_Report__c(Reporting_Frequency__c = 'Monthly', End_Date__c = reportingPeriodEndDate);
		} else {
			cwr = cwrList[0];
		}

		return cwr;
	}

	public static List<Reported_Metric_Value__c> getMonthlylyRMVS(Id cwrId, Date reportingPeriodEndDate){
		Date reportingPeriodBegDate = GetReportingPeriodBegDate(reportingPeriodEndDate);
		Date previousPeriodBegDate = reportingPeriodBegDate.addMonths(-1);
		Date previousPeriodEndDate = reportingPeriodEndDate.addMonths(-1);

		// get all monthly metrics
		// Id = Metric__c.Id
		Map<Id, Metric__c> metrics = new Map<Id, Metric__c>([SELECT Id, Name, Calculate_Delta__c, Query_Name__c, Headcount_Profiles__c FROM Metric__c WHERE Is_Calculated__c = true AND Include_On_Report__c = true AND Reporting_Frequency__c INCLUDES ('Monthly')]);

		// Id = Metric__c.Id
		List<String> metricHeadcountProfiles = new List<String>();
		for(Metric__c metric : metrics.values()){
			if(metric.Headcount_Profiles__c != ''){
				metricHeadcountProfiles.add(metric.Headcount_Profiles__c);
			}
		}
		Map<String, Integer> metricHeadcountsByNameMap = GetHeadcountByNameMap(String.join(metricHeadcountProfiles, ','));
		metricHeadcountsMap = new Map<Id, Integer>();
		for(Metric__c metric : metrics.values()){
			metricHeadcountsMap.put(metric.Id, 0);
			if(metric.Headcount_Profiles__c != null){
				List<String> profiles = metric.Headcount_Profiles__c.replace(' ,', ',').replace(', ', ',').split(',');
				for(String profile : profiles){
					if(metricHeadcountsByNameMap.containsKey(profile)){
						metricHeadcountsMap.put(metric.Id, metricHeadcountsMap.get(metric.Id) + metricHeadcountsByNameMap.get(profile));
					}
				}
			}
		}

		// get CWR if exists
		Company_Wide_Report__c previousCwr;

		// Id = Metric__c.Id
		Map<Id, Reported_Metric_Value__c> metricsToValuesMap = new Map<Id, Reported_Metric_Value__c>();
		metricPreviousValuesMap = new Map<Id, Double>();

		List<Company_Wide_Report__c> cwrList = [SELECT Id, Reporting_Frequency__c, End_Date__c FROM Company_Wide_Report__c WHERE Reporting_Frequency__c = 'Monthly' AND (End_Date__c = :reportingPeriodEndDate OR End_Date__c = :previousPeriodEndDate)];
		for(Company_Wide_Report__c cwrRecord : cwrList){
			if(cwrRecord.End_Date__c != reportingPeriodEndDate){
				previousCwr = cwrRecord;
			}
		}
		if(cwrId != null){
			Map<Id, Reported_Metric_Value__c> reportedMetricValues = new Map<Id, Reported_Metric_Value__c>([SELECT Id, Company_Wide_Report__c, Metric__c, Reported_Value__c, Headcount__c, Delta__c, Week_To_Date__c, Month_To_Date__c, Year_To_Date__c FROM Reported_Metric_Value__c WHERE Company_Wide_Report__c = :cwrId]);
			for(Reported_Metric_Value__c metricValue : reportedMetricValues.values()){
				if(!metricsToValuesMap.containsKey(metricValue.Metric__c)){
					metricsToValuesMap.put(metricValue.Metric__c, metricValue);
				}
			}
		}
		if(previousCwr != null){
			Map<Id, Reported_Metric_Value__c> reportedMetricValues = new Map<Id, Reported_Metric_Value__c>([SELECT Id, Metric__c, Reported_Value__c FROM Reported_Metric_Value__c WHERE Company_Wide_Report__c = :previousCwr.Id]);
			for(Reported_Metric_Value__c metricValue : reportedMetricValues.values()){
				if(!metricPreviousValuesMap.containsKey(metricValue.Metric__c)){
					metricPreviousValuesMap.put(metricValue.Metric__c, metricValue.Reported_Value__c);
				}
			}
		}

		for(Id metricId : metrics.keySet()){
			if(!metricsToValuesMap.containsKey(metricId)){
				metricsToValuesMap.put(metricId, new Reported_Metric_Value__c(Company_Wide_Report__c = cwrId, Metric__c = metricId, Reported_Value__c = 0));
			}
		}

		return metricsToValuesMap.values();
	}
}
/*
	private static Integer GetReportedValueForBacklogType(String queryName, Date begDate, Date endDate){
		Date reportingPeriodBegDate = begDate;
		Date reportingPeriodEndDate = endDate;
		Integer result = 0;

		// Create the query as a string
		String soqlQuery = '';
		Boolean breakQuery = false;
		if(queryName.toLowerCase() == 'lead backlog'){
			// lead backlog
			Schema.DescribeFieldResult fieldResult = Lead.Status.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			List<String> picklistValuesToQuery = new List<String>();
			for(Schema.PicklistEntry f : ple)
			{
				if(!f.getValue().contains('Prospect')){
					picklistValuesToQuery.add(f.getValue());
				}
			}
			soqlQuery = 'SELECT COUNT(Id) totalRecords'
						+ ' FROM Lead'
                        + ' WHERE IsConverted = false AND (Unqualified_Reason__c = null OR Unqualified_Reason__c = \'\')'
                        + ' AND Status IN (\'' + String.join(picklistValuesToQuery, '\',\'') + '\')';
            breakQuery = true;
		} else if(queryName.toLowerCase() == 'system design backlog'){
			// system design backlog
	        soqlQuery = 'SELECT COUNT(Id) totalRecords'
						+ ' FROM Event'
						+ ' WHERE Record_Type_Name__c IN (\'Site Survey Onsite\',\'Site Survey Remote\')'
						+ ' AND Event_Status__c = null'
						+ ' AND IsChild = false'
						+ ' AND Completed__c = false'
	                	+ ' AND What.type = \'Opportunity\'';
        	breakQuery = true;
		} else if(queryName.toLowerCase() == 'opportunity backlog'){
			Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			List<String> picklistValuesToQuery = new List<String>();
			for(Schema.PicklistEntry f : ple)
			{
				if(f.getValue() != 'Closed - Lost' && f.getValue() != 'Closed - Won' && f.getValue() != 'Contract Cancelled'){
					picklistValuesToQuery.add(f.getValue());
				}
			}
			soqlQuery = 'SELECT COUNT(Id) totalRecords'
                        + ' FROM Opportunity'
                        + ' WHERE StageName IN (\'' + String.join(picklistValuesToQuery, '\',\'') + '\')';
            breakQuery = true;
		} else if(queryName.toLowerCase() == 'sales order backlog'){
			Schema.DescribeFieldResult fieldResult = SCRB_SalesOrder__c.StatusCode__c.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			List<String> picklistValuesToQuery = new List<String>();
			for(Schema.PicklistEntry f : ple)
			{
				if(f.getValue() != 'Final/Accounting Approved' && f.getValue() != 'Canceled'){
					picklistValuesToQuery.add(f.getValue());
				}
			}
			soqlQuery = 'SELECT COUNT(Id) totalRecords'
                        + ' FROM SCRB_SalesOrder__c'
                        + ' WHERE StatusCode__c IN (\'' + String.join(picklistValuesToQuery, '\',\'') + '\')';
		} else if(queryName.toLowerCase() == 'kickoff backlog'){
			soqlQuery = 'SELECT COUNT(Id) totalRecords'
                        + ' FROM PM_Project__c'
                        + ' WHERE Status__c != \'Cancelled\' AND (Kickoff__c = null OR Kickoff__c >= TODAY)';
		} else if(queryName.toLowerCase() == 'install backlog'){
			soqlQuery = 'SELECT COUNT(Id) totalRecords'
                        + ' FROM PM_Project__c'
                        + ' WHERE Status__c != \'Cancelled\' AND Kickoff__c < TODAY AND Work_Completed__c = null';
		} else if(queryName.toLowerCase() == 'inspection backlog'){
			soqlQuery = 'SELECT COUNT(Id) totalRecords'
                        + ' FROM PM_Project__c'
                        + ' WHERE Status__c != \'Cancelled\' AND Work_Completed__c != null AND Proof_of_Inspection__c = null';
		} else if(queryName.toLowerCase() == 'customer case backlog'){
			soqlQuery = 'SELECT COUNT(Id) totalRecords'
                        + ' FROM Case'
                        + ' WHERE Status != \'Closed\' AND Status != \'Closed - Duplicate\'';
            breakQuery = true;
		} else if(queryName.toLowerCase() == 'maintenance backlog'){
			soqlQuery = 'SELECT COUNT(Id) totalRecords'
                        + ' FROM Case'
                        + ' WHERE Status != \'Closed\' AND Status != \'Closed - Duplicate\' AND Sub_Type_1__c IN (\'Equipment Maintenance\',\'Account Maintenance\')';
            breakQuery = true;
		} else if(queryName.toLowerCase() == 'appointments scheduled'){
			Integer timezoneOffset = UserInfo.getTimeZone().getOffset(reportingPeriodEndDate)/1000/60/60; // central = -5, eastern = -4
			String timeString = 'T0' + Math.abs(timezoneOffset) + ':00:00Z';
			soqlQuery = 'SELECT COUNT(Id) totalRecords'
                        + ' FROM Event'
						+ ' WHERE Record_Type_Name__c IN (\'Sales Visit Onsite\',\'Sales Visit Remote\')'
                    	+ ' AND StartDateTime >= ' + String.valueOf(reportingPeriodBegDate) + timeString + ' AND StartDateTime <= ' + String.valueOf(reportingPeriodEndDate.addDays(1)) + timeString;
		} else if(queryName.toLowerCase() == 'appointments completed'){
			Integer timezoneOffset = UserInfo.getTimeZone().getOffset(reportingPeriodEndDate)/1000/60/60; // central = -5, eastern = -4
			String timeString = 'T0' + Math.abs(timezoneOffset) + ':00:00Z';
			soqlQuery = 'SELECT COUNT(Id) totalRecords'
                        + ' FROM Event'
						+ ' WHERE Record_Type_Name__c IN (\'Sales Visit Onsite\',\'Sales Visit Remote\')'
                    	+ ' AND StartDateTime >= ' + String.valueOf(reportingPeriodBegDate) + timeString + ' AND StartDateTime <= ' + String.valueOf(reportingPeriodEndDate.addDays(1)) + timeString
                    	+ ' AND Completed__c = true';
		}

		// process the query using the HttpRequest model
		if(!Test.isRunningTest()){
			if(soqlQuery == ''){
				return 0;
			} else {
				return GetQueryCount(soqlQuery, breakQuery);
			}
		} else {
			return Integer.valueOf(Math.floor(Math.random() * 1000));
		}
	}

	private static Map<String, Double> GetReportedValueForTargetedType(String queryName, Boolean hasDailyTarget, Date reportEndDate, Date periodBegDate, Date periodEndDate){
		Map<String, Double> results = new Map<String, Double>();
		Integer timezoneOffset = UserInfo.getTimeZone().getOffset(reportEndDate)/1000/60/60; // central = -5, eastern = -4
		String timeString = 'T0' + Math.abs(timezoneOffset) + ':00:00Z';
		Double dailyCount = 0;
		Double weeklyCount = 0;
		Double monthlyCount = 0;
		Double annualCount = 0;
		Date reportingPeriodBegDate = periodBegDate;
		Date reportingPeriodEndDate = periodEndDate.addDays(1);
		Date yearBegDate = Date.newInstance(periodEndDate.year() - 1, 12, 16);
		reportEndDate = reportEndDate.addDays(1);

		Datetime reportingPeriodBegDatetime = Datetime.newInstance(periodBegDate.year(), periodBegDate.month(), periodBegDate.day(), 0, 0, 0);
		Datetime reportingPeriodEndDatetime = Datetime.newInstance(periodEndDate.year(), periodEndDate.month(), periodEndDate.day(), 0, 0, 0);
		Datetime yearBegDatetime = Datetime.newInstance(periodEndDate.year() - 1, 12, 16, 0, 0, 0);
		Datetime reportEndDatetime = Datetime.newInstance(reportEndDate.year(), reportEndDate.month(), reportEndDate.day(), 0, 0, 0);

		Map<String, String> soqlQueries = new Map<String, String>();
		Map<String, Integer> counts = new Map<String, Integer>();
		if(queryName.toLowerCase() == 'lead count'){
			if(!Test.isRunningTest()){
				if(hasDailyTarget){
					soqlQueries.put('D', 'SELECT COUNT(Id) totalRecords FROM Lead WHERE CreatedDate = ' + String.valueOf(reportEndDate) + timeString);
				}
				soqlQueries.put('W', 'SELECT COUNT(Id) totalRecords FROM Lead WHERE CreatedDate >= ' + String.valueOf(reportEndDate.addDays(-7)) + timeString + ' AND CreatedDate <= ' + String.valueOf(reportEndDate) + timeString);
				soqlQueries.put('M', 'SELECT COUNT(Id) totalRecords FROM Lead WHERE CreatedDate >= ' + String.valueOf(reportingPeriodBegDate) + timeString +' AND CreatedDate <= ' + String.valueOf(reportEndDate) + timeString);
				soqlQueries.put('Y', 'SELECT COUNT(Id) totalRecords FROM Lead WHERE CreatedDate >= ' + String.valueOf(yearBegDate) + timeString + ' AND CreatedDate <= ' + String.valueOf(reportEndDate) + timeString);
				counts = GetQueryCount(soqlQueries);
			} else {
				counts.put('D', 1);
				counts.put('W', 2);
				counts.put('M', 3);
				counts.put('Y', 4);
			}

			if(hasDailyTarget){
				results.put('ReportedValue', counts.get('D'));
			} else {
				results.put('ReportedValue', counts.get('W'));
			}
			results.put('WeekToDate', counts.get('W'));
			results.put('MonthToDate', counts.get('M'));
			results.put('YearToDate', counts.get('Y'));
		} else if(queryName.toLowerCase() == 'opportunity count'){
			if(!Test.isRunningTest()){
				if(hasDailyTarget){
					soqlQueries.put('D', 'SELECT COUNT(Id) totalRecords FROM Opportunity WHERE CreatedDate = ' + String.valueOf(reportEndDate) + timeString);
				}
				soqlQueries.put('W', 'SELECT COUNT(Id) totalRecords FROM Opportunity WHERE CreatedDate >= ' + String.valueOf(reportEndDate.addDays(-7)) + timeString + ' AND CreatedDate <= ' + String.valueOf(reportEndDate) + timeString);
				soqlQueries.put('M', 'SELECT COUNT(Id) totalRecords FROM Opportunity WHERE CreatedDate >= ' + String.valueOf(reportingPeriodBegDate) + timeString + ' AND CreatedDate <= ' + String.valueOf(reportEndDate) + timeString);
				soqlQueries.put('Y', 'SELECT COUNT(Id) totalRecords FROM Opportunity WHERE CreatedDate >= ' + String.valueOf(yearBegDate) + timeString + ' AND CreatedDate <= ' + String.valueOf(reportEndDate) + timeString);
				counts = GetQueryCount(soqlQueries);
			} else {
				counts.put('D', 1);
				counts.put('W', 2);
				counts.put('M', 3);
				counts.put('Y', 4);
			}

			if(hasDailyTarget){
				results.put('ReportedValue', counts.get('D'));
			} else {
				results.put('ReportedValue', counts.get('W'));
			}
			results.put('WeekToDate', counts.get('W'));
			results.put('MonthToDate', counts.get('M'));
			results.put('YearToDate', counts.get('Y'));
		} else if(queryName.toLowerCase() == 'sales count'){
			if(!Test.isRunningTest()){
				if(hasDailyTarget){
					soqlQueries.put('D', 'SELECT COUNT(Id) totalRecords FROM Opportunity WHERE StageName IN (\'Closed - Won\',\'Contract Cancelled\') AND CloseDate = ' + String.valueOf(reportEndDate));
				}
				soqlQueries.put('W', 'SELECT COUNT(Id) totalRecords FROM Opportunity WHERE StageName IN (\'Closed - Won\',\'Contract Cancelled\') AND CloseDate >= ' + String.valueOf(reportEndDate.addDays(-7)) + ' AND CloseDate <= ' + String.valueOf(reportEndDate));
				soqlQueries.put('M', 'SELECT COUNT(Id) totalRecords FROM Opportunity WHERE StageName IN (\'Closed - Won\',\'Contract Cancelled\') AND CloseDate >= ' + String.valueOf(reportingPeriodBegDate) + ' AND CloseDate <= ' + String.valueOf(reportEndDate));
				soqlQueries.put('Y', 'SELECT COUNT(Id) totalRecords FROM Opportunity WHERE StageName IN (\'Closed - Won\',\'Contract Cancelled\') AND CloseDate >= ' + String.valueOf(yearBegDate) + ' AND CloseDate <= ' + String.valueOf(reportEndDate));
				counts = GetQueryCount(soqlQueries);
			} else {
				counts.put('D', 1);
				counts.put('W', 2);
				counts.put('M', 3);
				counts.put('Y', 4);
			}

			if(hasDailyTarget){
				results.put('ReportedValue', counts.get('D'));
			} else {
				results.put('ReportedValue', counts.get('W'));
			}
			results.put('WeekToDate', counts.get('W'));
			results.put('MonthToDate', counts.get('M'));
			results.put('YearToDate', counts.get('Y'));
		} else if(queryName.toLowerCase() == 'cancellations'){
			if(!Test.isRunningTest()){
				if(hasDailyTarget){
					soqlQueries.put('D', 'SELECT COUNT(Id) totalRecords FROM SCRB_SalesOrder__c WHERE Canceled_Date__c = ' + String.valueOf(reportEndDate) + timeString);
				}
				soqlQueries.put('W', 'SELECT COUNT(Id) totalRecords FROM SCRB_SalesOrder__c WHERE Canceled_Date__c >= ' + String.valueOf(reportEndDate.addDays(-7)) + timeString + ' AND Canceled_Date__c <= ' + String.valueOf(reportEndDate) + timeString);
				soqlQueries.put('M', 'SELECT COUNT(Id) totalRecords FROM SCRB_SalesOrder__c WHERE Canceled_Date__c >= ' + String.valueOf(reportingPeriodBegDate) + timeString + ' AND Canceled_Date__c <= ' + String.valueOf(reportEndDate) + timeString);
				soqlQueries.put('Y', 'SELECT COUNT(Id) totalRecords FROM SCRB_SalesOrder__c WHERE Canceled_Date__c >= ' + String.valueOf(yearBegDate) + timeString + ' AND Canceled_Date__c <= ' + String.valueOf(reportEndDate) + timeString);
				counts = GetQueryCount(soqlQueries);
			} else {
				counts.put('D', 1);
				counts.put('W', 2);
				counts.put('M', 3);
				counts.put('Y', 4);
			}

			if(hasDailyTarget){
				results.put('ReportedValue', counts.get('D'));
			} else {
				results.put('ReportedValue', counts.get('W'));
			}
			results.put('WeekToDate', counts.get('W'));
			results.put('MonthToDate', counts.get('M'));
			results.put('YearToDate', counts.get('Y'));
		} else if(queryName.toLowerCase() == 'inspections count'){
			if(!Test.isRunningTest()){
				if(hasDailyTarget){
					soqlQueries.put('D', 'SELECT COUNT(Id) totalRecords FROM PM_Project__c WHERE Proof_of_Inspection__c = ' + String.valueOf(reportEndDate));
				}
				soqlQueries.put('W', 'SELECT COUNT(Id) totalRecords FROM PM_Project__c WHERE Proof_of_Inspection__c >= ' + String.valueOf(reportEndDate.addDays(-7)) + ' AND Proof_of_Inspection__c <= ' + String.valueOf(reportEndDate));
				soqlQueries.put('M', 'SELECT COUNT(Id) totalRecords FROM PM_Project__c WHERE Proof_of_Inspection__c >= ' + String.valueOf(reportingPeriodBegDate) + ' AND Proof_of_Inspection__c <= ' + String.valueOf(reportEndDate));
				soqlQueries.put('Y', 'SELECT COUNT(Id) totalRecords FROM PM_Project__c WHERE Proof_of_Inspection__c >= ' + String.valueOf(yearBegDate) + ' AND Proof_of_Inspection__c <= ' + String.valueOf(reportEndDate));
				counts = GetQueryCount(soqlQueries);
			} else {
				counts.put('D', 1);
				counts.put('W', 2);
				counts.put('M', 3);
				counts.put('Y', 4);
			}

			if(hasDailyTarget){
				results.put('ReportedValue', counts.get('D'));
			} else {
				results.put('ReportedValue', counts.get('W'));
			}
			results.put('WeekToDate', counts.get('W'));
			results.put('MonthToDate', counts.get('M'));
			results.put('YearToDate', counts.get('Y'));
		} else if(queryName.toLowerCase() == 'lead conversion rate'){
			Map<String, Integer> totals = new Map<String, Integer>();
			Map<String, String> totalQueries = new Map<String, String>();
			if(!Test.isRunningTest()){
				if(hasDailyTarget){
					soqlQueries.put('D', 'SELECT COUNT(Id) totalRecords FROM Lead WHERE IsConverted = true AND CreatedDate = ' + String.valueOf(reportEndDate) + timeString);
					totalQueries.put('D', 'SELECT COUNT(Id) totalRecords FROM Lead WHERE AND CreatedDate = ' + String.valueOf(reportEndDate) + timeString);
				}
				soqlQueries.put('W', 'SELECT COUNT(Id) totalRecords FROM Lead WHERE IsConverted = true AND CreatedDate >= ' + String.valueOf(reportEndDate.addDays(-7)) + timeString + ' AND CreatedDate <= ' + String.valueOf(reportEndDate) + timeString);
				soqlQueries.put('M', 'SELECT COUNT(Id) totalRecords FROM Lead WHERE IsConverted = true AND CreatedDate >= ' + String.valueOf(reportingPeriodBegDate) + timeString + ' AND CreatedDate <= ' + String.valueOf(reportEndDate) + timeString);
				soqlQueries.put('Y', 'SELECT COUNT(Id) totalRecords FROM Lead WHERE IsConverted = true AND CreatedDate >= ' + String.valueOf(yearBegDate) + timeString + ' AND CreatedDate <= ' + String.valueOf(reportEndDate) + timeString);
				totalQueries.put('W', 'SELECT COUNT(Id) totalRecords FROM Lead WHERE CreatedDate >= ' + String.valueOf(reportEndDate.addDays(-7)) + timeString + ' AND CreatedDate <= ' + String.valueOf(reportEndDate) + timeString);
				totalQueries.put('M', 'SELECT COUNT(Id) totalRecords FROM Lead WHERE CreatedDate >= ' + String.valueOf(reportingPeriodBegDate) + timeString + ' AND CreatedDate <= ' + String.valueOf(reportEndDate) + timeString);
				totalQueries.put('Y', 'SELECT COUNT(Id) totalRecords FROM Lead WHERE CreatedDate >= ' + String.valueOf(yearBegDate) + timeString + ' AND CreatedDate <= ' + String.valueOf(reportEndDate) + timeString);
				counts = GetQueryCount(soqlQueries);
				totals = GetQueryCount(totalQueries);
			} else {
				counts.put('D', 1);
				counts.put('W', 2);
				counts.put('M', 3);
				counts.put('Y', 4);
				totals.put('D', 10);
				totals.put('W', 20);
				totals.put('M', 30);
				totals.put('Y', 40);
			}

			if(totals.containsKey('Y') && totals.get('Y') == 0){
				results.put('ReportedValue', 0);
				results.put('WeekToDate', 0);
				results.put('MonthToDate', 0);
				results.put('YearToDate', 0);
			} else {
				if(hasDailyTarget){
					if(totals.get('D') == 0){
						results.put('ReportedValue', 0);
					} else {
						results.put('ReportedValue', counts.get('D') * 100 / totals.get('D'));
					}
				} else {
					if(totals.get('W') == 0){
						results.put('ReportedValue', 0);
					} else {
						results.put('ReportedValue', counts.get('W') * 100 / totals.get('W'));
					}
				}
				if(totals.get('W') == 0){
					results.put('WeekToDate', 0);
				} else {
					results.put('WeekToDate', counts.get('W') * 100 / totals.get('W'));
				}
				if(totals.get('W') == 0){
					results.put('MonthToDate', 0);
				} else {
					results.put('MonthToDate', counts.get('M') * 100 / totals.get('M'));
				}
				if(totals.get('W') == 0){
					results.put('YearToDate', 0);
				} else {
					results.put('YearToDate', counts.get('Y') * 100 / totals.get('Y'));
				}
			}
		} else if(queryName.toLowerCase() == 'opportunity conversion rate'){
			Map<String, Integer> totals = new Map<String, Integer>();
			Map<String, String> totalQueries = new Map<String, String>();
			if(!Test.isRunningTest()){
				if(hasDailyTarget){
					soqlQueries.put('D', 'SELECT COUNT(Id) totalRecords FROM FROM Opportunity WHERE StageName = \'Closed - Won\' AND CreatedDate = ' + String.valueOf(reportEndDate) + timeString);
					totalQueries.put('D', 'SELECT COUNT(Id) totalRecords FROM Opportunity WHERE CreatedDate = ' + String.valueOf(reportEndDate) + timeString);
				}
				soqlQueries.put('W', 'SELECT COUNT(Id) totalRecords FROM Opportunity WHERE StageName = \'Closed - Won\' AND CreatedDate >= ' + String.valueOf(reportEndDate.addDays(-7)) + timeString + ' AND CreatedDate <= ' + String.valueOf(reportEndDate) + timeString);
				soqlQueries.put('M', 'SELECT COUNT(Id) totalRecords FROM Opportunity WHERE StageName = \'Closed - Won\' AND CreatedDate >= ' + String.valueOf(reportingPeriodBegDate) + timeString + ' AND CreatedDate <= ' + String.valueOf(reportEndDate) + timeString);
				soqlQueries.put('Y', 'SELECT COUNT(Id) totalRecords FROM Opportunity WHERE StageName = \'Closed - Won\' AND CreatedDate >= ' + String.valueOf(yearBegDate) + timeString + ' AND CreatedDate <= ' + String.valueOf(reportEndDate) + timeString);
				totalQueries.put('W', 'SELECT COUNT(Id) totalRecords FROM Opportunity WHERE CreatedDate >= ' + String.valueOf(reportEndDate.addDays(-7)) + timeString + ' AND CreatedDate <= ' + String.valueOf(reportEndDate) + timeString);
				totalQueries.put('M', 'SELECT COUNT(Id) totalRecords FROM Opportunity WHERE CreatedDate >= ' + String.valueOf(reportingPeriodBegDate) + timeString + ' AND CreatedDate <= ' + String.valueOf(reportEndDate) + timeString);
				totalQueries.put('Y', 'SELECT COUNT(Id) totalRecords FROM Opportunity WHERE CreatedDate >= ' + String.valueOf(yearBegDate) + timeString + ' AND CreatedDate <= ' + String.valueOf(reportEndDate) + timeString);
				counts = GetQueryCount(soqlQueries);
				totals = GetQueryCount(totalQueries);
			} else {
				counts.put('D', 1);
				counts.put('W', 2);
				counts.put('M', 3);
				counts.put('Y', 4);
				totals.put('D', 10);
				totals.put('W', 20);
				totals.put('M', 30);
				totals.put('Y', 40);
			}

			if(totals.containsKey('Y') && totals.get('Y') == 0){
				results.put('ReportedValue', 0);
				results.put('WeekToDate', 0);
				results.put('MonthToDate', 0);
				results.put('YearToDate', 0);
			} else {
				if(hasDailyTarget){
					if(totals.get('D') == 0){
						results.put('ReportedValue', 0);
					} else {
						results.put('ReportedValue', counts.get('D') * 100 / totals.get('D'));
					}
				} else {
					if(totals.get('W') == 0){
						results.put('ReportedValue', 0);
					} else {
						results.put('ReportedValue', counts.get('W') * 100 / totals.get('W'));
					}
				}
				if(totals.get('W') == 0){
					results.put('WeekToDate', 0);
				} else {
					results.put('WeekToDate', counts.get('W') * 100 / totals.get('W'));
				}
				if(totals.get('W') == 0){
					results.put('MonthToDate', 0);
				} else {
					results.put('MonthToDate', counts.get('M') * 100 / totals.get('M'));
				}
				if(totals.get('W') == 0){
					results.put('YearToDate', 0);
				} else {
					results.put('YearToDate', counts.get('Y') * 100 / totals.get('Y'));
				}
			}
		} else if(queryName.toLowerCase() == 'total referrals count'){
			if(!Test.isRunningTest()){
				if(hasDailyTarget){
					soqlQueries.put('D', 'SELECT COUNT(Id) totalRecords FROM Opportunity WHERE CloseDate = ' + String.valueOf(reportEndDate));
				}
				soqlQueries.put('W', 'SELECT COUNT(Id) totalRecords FROM Opportunity WHERE CloseDate >= ' + String.valueOf(reportEndDate.addDays(-7)) + ' AND CloseDate <= ' + String.valueOf(reportEndDate));
				soqlQueries.put('M', 'SELECT COUNT(Id) totalRecords FROM Opportunity WHERE CloseDate >= ' + String.valueOf(reportingPeriodBegDate) + ' AND CloseDate <= ' + String.valueOf(reportEndDate));
				soqlQueries.put('Y', 'SELECT COUNT(Id) totalRecords FROM Opportunity WHERE CloseDate >= ' + String.valueOf(yearBegDate) + ' AND CloseDate <= ' + String.valueOf(reportEndDate));
				counts = GetQueryCount(soqlQueries);
			} else {
				counts.put('D', 1);
				counts.put('W', 2);
				counts.put('M', 3);
				counts.put('Y', 4);
			}

			if(hasDailyTarget){
				results.put('ReportedValue', counts.get('D'));
			} else {
				results.put('ReportedValue', counts.get('W'));
			}
			results.put('WeekToDate', counts.get('W'));
			results.put('MonthToDate', counts.get('M'));
			results.put('YearToDate', counts.get('Y'));
		} else if(queryName.toLowerCase() == 'internal referrals count'){
			if(!Test.isRunningTest()){
				if(hasDailyTarget){
					soqlQueries.put('D', 'SELECT COUNT(Id) totalRecords FROM Opportunity WHERE CloseDate = ' + String.valueOf(reportEndDate)
											+ ' AND StageName IN (\'Closed - Won\')'
											+ ' AND Lead_Source_Detail__c IN (\'Benjamin Franklin (DES)\',\'Mr. Sparky (DES)\',\'OneHour Air conditioning and Heating (DES)\',\'DE MyAccount\',\'Airtron (DES)\',\'Home Warranty of America (DES)\',\'Other (DES)\')'
						);
				}
				soqlQueries.put('W', 'SELECT COUNT(Id) totalRecords FROM Opportunity WHERE CloseDate >= ' + String.valueOf(reportEndDate.addDays(-7)) + ' AND CloseDate <= ' + String.valueOf(reportEndDate)
										+ ' AND StageName IN (\'Closed - Won\')'
										+ ' AND Lead_Source_Detail__c IN (\'Benjamin Franklin (DES)\',\'Mr. Sparky (DES)\',\'OneHour Air conditioning and Heating (DES)\',\'DE MyAccount\',\'Airtron (DES)\',\'Home Warranty of America (DES)\',\'Other (DES)\')'
					);
				soqlQueries.put('M', 'SELECT COUNT(Id) totalRecords FROM Opportunity WHERE CloseDate >= ' + String.valueOf(reportingPeriodBegDate) + ' AND CloseDate <= ' + String.valueOf(reportEndDate)
										+ ' AND StageName IN (\'Closed - Won\')'
										+ ' AND Lead_Source_Detail__c IN (\'Benjamin Franklin (DES)\',\'Mr. Sparky (DES)\',\'OneHour Air conditioning and Heating (DES)\',\'DE MyAccount\',\'Airtron (DES)\',\'Home Warranty of America (DES)\',\'Other (DES)\')'
					);
				soqlQueries.put('Y', 'SELECT COUNT(Id) totalRecords FROM Opportunity WHERE CloseDate >= ' + String.valueOf(yearBegDate) + ' AND CloseDate <= ' + String.valueOf(reportEndDate)
										+ ' AND StageName IN (\'Closed - Won\')'
										+ ' AND Lead_Source_Detail__c IN (\'Benjamin Franklin (DES)\',\'Mr. Sparky (DES)\',\'OneHour Air conditioning and Heating (DES)\',\'DE MyAccount\',\'Airtron (DES)\',\'Home Warranty of America (DES)\',\'Other (DES)\')'
					);
				counts = GetQueryCount(soqlQueries);
			} else {
				counts.put('D', 1);
				counts.put('W', 2);
				counts.put('M', 3);
				counts.put('Y', 4);
			}

			if(hasDailyTarget){
				results.put('ReportedValue', counts.get('D'));
			} else {
				results.put('ReportedValue', counts.get('W'));
			}
			results.put('WeekToDate', counts.get('W'));
			results.put('MonthToDate', counts.get('M'));
			results.put('YearToDate', counts.get('Y'));
		} else if(queryName.toLowerCase() == 'capacity inspected'){
			for(PM_Project__c proj : [SELECT Id, Proof_of_Inspection__c, Total_System_Size_kW_DC__c FROM PM_Project__c WHERE Proof_of_Inspection__c >= :yearBegDate AND Proof_of_Inspection__c <= :reportEndDate]){
				if(hasDailyTarget && proj.Proof_of_Inspection__c >= reportEndDate.addDays(-1)){
					dailyCount += proj.Total_System_Size_kW_DC__c;
					weeklyCount += proj.Total_System_Size_kW_DC__c;
					monthlyCount += proj.Total_System_Size_kW_DC__c;
				} else if(proj.Proof_of_Inspection__c >= reportEndDate.addDays(-7)){
					weeklyCount += proj.Total_System_Size_kW_DC__c;
					monthlyCount += proj.Total_System_Size_kW_DC__c;
				} else if (proj.Proof_of_Inspection__c >= reportingPeriodBegDate && proj.Proof_of_Inspection__c <= reportingPeriodEndDate){
					monthlyCount += proj.Total_System_Size_kW_DC__c;
				}
				annualCount += proj.Total_System_Size_kW_DC__c;
			}

			if(hasDailyTarget){
				results.put('ReportedValue', dailyCount);
			} else {
				results.put('ReportedValue', weeklyCount);
			}
			results.put('WeekToDate', weeklyCount);
			results.put('MonthToDate', monthlyCount);
			results.put('YearToDate', annualCount);
		} else if(queryName.toLowerCase() == 'average system size'){
			Integer dailies = 0;
			Integer weeklies = 0;
			Integer monthlies = 0;
			Integer total = 0;
			for(PM_Project__c proj : [SELECT Id, Proof_of_Inspection__c, Total_System_Size_kW_DC__c FROM PM_Project__c WHERE Proof_of_Inspection__c >= :yearBegDate AND Proof_of_Inspection__c <= :reportEndDate]){
				if(hasDailyTarget && proj.Proof_of_Inspection__c >= reportEndDate.addDays(-1)){
					dailyCount += proj.Total_System_Size_kW_DC__c;
					weeklyCount += proj.Total_System_Size_kW_DC__c;
					monthlyCount += proj.Total_System_Size_kW_DC__c;
					dailies++;
					weeklies++;
					monthlies++;
				} else if(proj.Proof_of_Inspection__c >= reportEndDate.addDays(-7)){
					weeklyCount += proj.Total_System_Size_kW_DC__c;
					monthlyCount += proj.Total_System_Size_kW_DC__c;
					weeklies++;
					monthlies++;
				} else if (proj.Proof_of_Inspection__c >= reportingPeriodBegDate && proj.Proof_of_Inspection__c <= reportingPeriodEndDate){
					monthlyCount += proj.Total_System_Size_kW_DC__c;
					monthlies++;
				}
				annualCount += proj.Total_System_Size_kW_DC__c;
				total++;
			}

			if(hasDailyTarget){
				if(dailies == 0){
					results.put('ReportedValue', 0);
				} else {
					results.put('ReportedValue', dailyCount / dailies);
				}
			} else {
				if(weeklies == 0){
					results.put('ReportedValue', 0);
				} else {
					results.put('ReportedValue', weeklyCount / weeklies);
				}
			}
			if(weeklies == 0){
				results.put('WeekToDate', 0);
			} else {
				results.put('WeekToDate', weeklyCount / weeklies);
			}
			if(monthlies == 0){
				results.put('MonthToDate', 0);
			} else {
				results.put('MonthToDate', monthlyCount / monthlies);
			}
			if(total == 0){
				results.put('YearToDate', 0);
			} else {
				results.put('YearToDate', annualCount / total);
			}
		} else if(queryName.toLowerCase() == 'median time to first sales call'){
	        List<Event> weekSalesVisits = [Select WhatId,StartDateTime from Event 
	                                             Where Record_Type_Name__c = 'Sales Visit Onsite'
	                                               AND isChild = false 
	                                               AND What.Type = 'Opportunity'
	                                               AND StartDateTime >= :reportEndDate.addDays(-7) AND StartDateTime < :reportEndDate];
	        Set<Id> oppId = new Set<Id>();
	        for(Event evt : weekSalesVisits )
	        {
	            oppId.add(evt.WhatId);
	        }


	        // Get the Map of Evetns created MOnthly
	        List<Event> monthSalesVisits = [Select WhatId,StartDateTime from Event 
	                                             Where Record_Type_Name__c = 'Sales Visit Onsite'
	                                               AND isChild = false 
	                                               AND What.Type = 'Opportunity'
	                                               AND StartDateTime >= :reportingPeriodBegDate AND StartDateTime < :reportEndDate];
	        for(Event evt : monthSalesVisits )
	        {
	            oppId.add(evt.WhatId);
	        }

	        // Get the Map of Evetns created YTD
	        List<Event> yearSalesVisits = [Select WhatId,StartDateTime from Event 
	                                             Where Record_Type_Name__c = 'Sales Visit Onsite'
	                                               AND isChild = false 
	                                               AND What.Type = 'Opportunity'
	                                               AND StartDateTime >= :yearBegDate AND StartDateTime < :reportEndDate];
	        for(Event evt : yearSalesVisits )
	        {
	            oppId.add(evt.WhatId);
	        }

	        Map<Id,Opportunity> opptyMap = new Map<Id,Opportunity>([Select id,CreatedDate from Opportunity where id in :oppId]);

	        List<Decimal> timeDiff = new List<Decimal>();
	        for(Event evt : weekSalesVisits )
	        {            
	            timeDiff.add((evt.StartDateTime.getTime()/1000/60/60)
	                     - (opptyMap.get(evt.WhatId).CreatedDate.getTime()/1000/60/60));
	        }        
			results.put('ReportedValue', getMedian(timeDiff));
			results.put('WeekToDate', getMedian(timeDiff));

	        timeDiff = new List<Decimal>();
	        for(Event evt : monthSalesVisits )
	        {
	            timeDiff.add((evt.StartDateTime.getTime()/1000/60/60)
	                     - (opptyMap.get(evt.WhatId).CreatedDate.getTime()/1000/60/60));
	        }        
			results.put('MonthToDate', getMedian(timeDiff));

	        timeDiff = new List<Decimal>();
	        for(Event evt : yearSalesVisits )
	        {
	            timeDiff.add((evt.StartDateTime.getTime()/1000/60/60)
	                     - (opptyMap.get(evt.WhatId).CreatedDate.getTime()/1000/60/60));
	        }        
			results.put('YearToDate', getMedian(timeDiff));
		} else if(queryName.toLowerCase() == 'median time sale to inspection'){
			List<Double> dailyDifferences = new List<Double>();
			List<Double> weeklyDifferences = new List<Double>();
			List<Double> monthlyDifferences = new List<Double>();
			List<Double> annualDifferences = new List<Double>();
			for(PM_Project__c proj : [SELECT Id, Proof_of_Inspection__c, Sales_Order__r.Opportunity_Close_Date__c FROM PM_Project__c WHERE Proof_of_Inspection__c >= :yearBegDate AND Proof_of_Inspection__c <= :reportEndDate]){
				Datetime proofDatetime = Datetime.newInstance(proj.Proof_of_Inspection__c.year(), proj.Proof_of_Inspection__c.month(), proj.Proof_of_Inspection__c.day());
				Datetime closeDatetime = Datetime.newInstance(proj.Sales_Order__r.Opportunity_Close_Date__c.year(), proj.Sales_Order__r.Opportunity_Close_Date__c.month(), proj.Sales_Order__r.Opportunity_Close_Date__c.day());
				if(hasDailyTarget && proj.Proof_of_Inspection__c == reportEndDate.addDays(-1)){
					dailyDifferences.add((proofDatetime.getTime()/1000/60/60) - (closeDatetime.getTime()/1000/60/60));
					weeklyDifferences.add((proofDatetime.getTime()/1000/60/60) - (closeDatetime.getTime()/1000/60/60));
					monthlyDifferences.add((proofDatetime.getTime()/1000/60/60) - (closeDatetime.getTime()/1000/60/60));
				} else if(proj.Proof_of_Inspection__c > reportEndDate.addDays(-7)){
					weeklyDifferences.add((proofDatetime.getTime()/1000/60/60) - (closeDatetime.getTime()/1000/60/60));
					monthlyDifferences.add((proofDatetime.getTime()/1000/60/60) - (closeDatetime.getTime()/1000/60/60));
				} else if (proj.Proof_of_Inspection__c >= reportingPeriodBegDate && proj.Proof_of_Inspection__c <= reportingPeriodEndDate){
					monthlyDifferences.add((proofDatetime.getTime()/1000/60/60) - (closeDatetime.getTime()/1000/60/60));
				}
				annualDifferences.add((proofDatetime.getTime()/1000/60/60) - (closeDatetime.getTime()/1000/60/60));
			}

			if(hasDailyTarget){
				results.put('ReportedValue', getMedian(dailyDifferences));
			} else {
				results.put('ReportedValue', getMedian(weeklyDifferences));
			}
			results.put('WeekToDate', getMedian(weeklyDifferences));
			results.put('MonthToDate', getMedian(monthlyDifferences));
			results.put('YearToDate', getMedian(annualDifferences));
		} else if(queryName.toLowerCase() == 'capacity in backlog'){
			for(PM_Project__c proj : [SELECT Id, Proof_of_Inspection__c, Total_System_Size_kW_DC__c FROM PM_Project__c WHERE Status__c != 'Cancelled' AND Proof_of_Inspection__c >= :yearBegDate AND Proof_of_Inspection__c <= :reportEndDate]){
				dailyCount += proj.Total_System_Size_kW_DC__c;
				weeklyCount += proj.Total_System_Size_kW_DC__c;
				monthlyCount += proj.Total_System_Size_kW_DC__c;
				annualCount += proj.Total_System_Size_kW_DC__c;
			}

			if(hasDailyTarget){
				results.put('ReportedValue', dailyCount);
			} else {
				results.put('ReportedValue', weeklyCount);
			}
			results.put('WeekToDate', weeklyCount);
			results.put('MonthToDate', monthlyCount);
			results.put('YearToDate', annualCount);
		} else if(queryName.toLowerCase() == 'median time project creation to inspection'){
			Double dailyManHours = 0;
			Double weeklyManHours = 0;
			Double monthlyManHours = 0;
			Double annualManHours = 0;
			Set<Id> projIds = new Set<Id>();
			for(PM_Project__c proj : [SELECT Id, Work_Completed__c, Total_System_Size_kW_DC__c FROM PM_Project__c WHERE Work_Completed__c >= :yearBegDate AND Work_Completed__c <= :reportEndDate]){
				Datetime completeDatetime = Datetime.newInstance(proj.Work_Completed__c.year(), proj.Work_Completed__c.month(), proj.Work_Completed__c.day());
				if(hasDailyTarget && proj.Work_Completed__c >= reportEndDate.addDays(-1)){
					dailyCount += proj.Total_System_Size_kW_DC__c;
					weeklyCount += proj.Total_System_Size_kW_DC__c;
					monthlyCount += proj.Total_System_Size_kW_DC__c;
				} else if(proj.Work_Completed__c >= reportEndDate.addDays(-7)){
					weeklyCount += proj.Total_System_Size_kW_DC__c;
					monthlyCount += proj.Total_System_Size_kW_DC__c;
				} else if (proj.Work_Completed__c >= reportingPeriodBegDate && proj.Work_Completed__c <= reportingPeriodEndDate){
					monthlyCount += proj.Total_System_Size_kW_DC__c;
				}
				annualCount += proj.Total_System_Size_kW_DC__c;
				projIds.add(proj.Id);
			}
			for(Time_Sheet_Entry__c tse : [SELECT Id, Total_Hours__c, End_Time__c FROM Time_Sheet_Entry__c WHERE Project_Client_Job__r.PM_Project__c IN :projIds AND End_Time__c >= :yearBegDatetime AND End_Time__c <= :reportEndDatetime]){
				if(hasDailyTarget && tse.End_Time__c >= reportEndDate.addDays(-1)){
					dailyManHours += tse.Total_Hours__c;
					weeklyManHours += tse.Total_Hours__c;
					monthlyManHours += tse.Total_Hours__c;
				} else if(tse.End_Time__c >= reportEndDate.addDays(-7)){
					weeklyManHours += tse.Total_Hours__c;
					monthlyManHours += tse.Total_Hours__c;
				} else if (tse.End_Time__c >= reportingPeriodBegDate && tse.End_Time__c <= reportingPeriodEndDate){
					monthlyManHours += tse.Total_Hours__c;
				}
				annualManHours += tse.Total_Hours__c;
			}

			if(hasDailyTarget){
				if(dailyCount == 0){
					results.put('ReportedValue', 0);
				} else {
					results.put('ReportedValue', dailyManHours / dailyCount);
				}
			} else {
				if(weeklyCount == 0){
					results.put('ReportedValue', 0);
				} else {
					results.put('ReportedValue', weeklyManHours / weeklyCount);
				}
			}
			if(weeklyCount == 0){
				results.put('WeekToDate', 0);
			} else {
				results.put('WeekToDate', weeklyManHours / weeklyCount);
			}
			if(monthlyCount == 0){
				results.put('MonthToDate', 0);
			} else {
				results.put('MonthToDate', monthlyManHours / monthlyCount);
			}
			if(annualCount == 0){
				results.put('YearToDate', 0);
			} else {
				results.put('YearToDate', annualManHours / annualCount);
			}
		} else if(queryName.toLowerCase() == 'nps'){
			Decimal dailies = 0;
			Decimal weeklies = 0;
			Decimal monthlies = 0;
			Decimal total = 0;
			Decimal daily1to6 = 0;
			Decimal weekly1to6 = 0;
			Decimal monthly1to6 = 0;
			Decimal annual1to6 = 0;
			for(Customer_Survey__c surv : [SELECT Id, Likelihood_of_Recommendation_Numeric__c, Survey_Date_Completed__c FROM Customer_Survey__c WHERE Survey_Date_Completed__c >= :yearBegDate AND Survey_Date_Completed__c <= :reportEndDate]){
				if(hasDailyTarget && surv.Survey_Date_Completed__c >= reportEndDate.addDays(-1)){
					if(surv.Likelihood_of_Recommendation_Numeric__c >= 9){
						dailyCount++;
						weeklyCount++;
						monthlyCount++;
					} else if(surv.Likelihood_of_Recommendation_Numeric__c <= 6){
						daily1to6++;
						weekly1to6++;
						monthly1to6++;
					}
					dailies++;
					weeklies++;
					monthlies++;
				} else if(surv.Survey_Date_Completed__c >= reportEndDate.addDays(-7)){
					if(surv.Likelihood_of_Recommendation_Numeric__c >= 9){
						weeklyCount++;
						monthlyCount++;
					} else if(surv.Likelihood_of_Recommendation_Numeric__c <= 6){
						weekly1to6++;
						monthly1to6++;
					}
					weeklies++;
					monthlies++;
				} else if (surv.Survey_Date_Completed__c >= reportingPeriodBegDate && surv.Survey_Date_Completed__c <= reportingPeriodEndDate){
					if(surv.Likelihood_of_Recommendation_Numeric__c >= 9){
						monthlyCount++;
					} else if(surv.Likelihood_of_Recommendation_Numeric__c <= 6){
						monthly1to6++;
					}
					monthlies++;
				}

				if(surv.Likelihood_of_Recommendation_Numeric__c >= 9){
					annualCount++;
				} else if(surv.Likelihood_of_Recommendation_Numeric__c <= 6){
					annual1to6++;
				}
				total++;
			}

			if(hasDailyTarget){
				if(dailies == 0){
					results.put('ReportedValue', 0);
				} else {
					results.put('ReportedValue', 100 * (dailyCount - daily1to6) / dailies);
				}
			} else {
				if(weeklies == 0){
					results.put('ReportedValue', 0);
				} else {
					results.put('ReportedValue', 100 * (weeklyCount - weekly1to6) / weeklies);
				}
			}
			if(weeklies == 0){
				results.put('WeekToDate', 0);
			} else {
				results.put('WeekToDate', 100 * (weeklyCount - weekly1to6) / weeklies);
			}
			if(monthlies == 0){
				results.put('MonthToDate', 0);
			} else {
				results.put('MonthToDate', 100 * (monthlyCount - monthly1to6) / monthlies);
			}
			if(total == 0){
				results.put('YearToDate', 0);
			} else {
				results.put('YearToDate', 100 * (annualCount - annual1to6) / total);
			}
		} else if(queryName.toLowerCase() == 'sales consultant headcount'){
			monthlyCount += GetHeadcount('Sales User,Rehash Sales Consultant');
			results.put('ReportedValue', monthlyCount);
			results.put('WeekToDate', monthlyCount);
			results.put('MonthToDate', monthlyCount);
			results.put('YearToDate', monthlyCount);
		} else if(queryName.toLowerCase() == 'operations headcount'){
			monthlyCount += GetHeadcount('Install/Electric Lead,Chatter Free User,Project Leads');
			results.put('ReportedValue', monthlyCount);
			results.put('WeekToDate', monthlyCount);
			results.put('MonthToDate', monthlyCount);
			results.put('YearToDate', monthlyCount);
		}

		return results;
	}
*/