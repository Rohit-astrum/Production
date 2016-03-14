/* FILE: CompanyWideReportBatchCalculator.cls
 * AUTHOR: Steve Zilligen
 * DATE: May 5, 2015
 * PURPOSE: Class to use batch methods to calculate the data for the Company Wide Report
 * NOTES: Query Names Calculated: lead backlog, system design backlog, opportunity backlog, sales order backlog
 */
global class CompanyWideReportBatchCalculator implements Database.Batchable<sObject>, Database.Stateful {

	global final Type queryObject;
	global final Id companyWideReportId;
	global final Date reportEndDate;
	global final Date reportEndDateTime;
	global final Map<Id, String> metricIdToQueryNameMap;
	global final Map<Id, Integer> metricIdToHeadcountMap;
	global final Map<Id, Double> metricIdToPreviousValueMap;

	global final Set<String> queryNames;
	global final String query;
	global final Company_Wide_Report__c companyWideReport;
	global final Date reportingPeriodBegDate;
	global final Date reportingPeriodEndDate;
	global final Date yearBegDate;
	global final Map<String, Map<String, Double>> reportedValuesByQuery; // Map<queryName, Map<valueType, value>>, valueType is one of: A,R,D,W,M,Y
	global final Map<String, Set<String>> picklistValuesByQuery; // Map<queryName, Set<picklist value>>
	global Map<String, Map<String, List<Decimal>>> medianCalculationsMap;
	global Map<string, Map<Id, Decimal>> multiQueryCalculationsMap;
	
	global CompanyWideReportBatchCalculator(Type obj, Id cwrId, Date endDate, Map<Id, String> mIdToQNMap, Map<Id, Integer> mIdToHdcntMap, Map<Id, Double> mIdToPrevValMap) {
		queryObject = obj;
		companyWideReportId = cwrId;
		companyWideReport = [SELECT Id, Reporting_Frequency__c FROM Company_Wide_Report__c WHERE Id = :cwrId LIMIT 1];
		reportEndDate = endDate;
		reportEndDateTime = endDate.addDays(1);
		metricIdToQueryNameMap = mIdToQNMap;
		metricIdToHeadcountMap = mIdToHdcntMap;
		metricIdToPreviousValueMap = mIdToPrevValMap;

		queryNames = new Set<String>();
		PopulateValidQueryNames();
		reportingPeriodBegDate = GetReportingPeriodBegDate(endDate);
		reportingPeriodEndDate = GetReportingPeriodEndDate(endDate);
		yearBegDate = GetYearBegDate(endDate);

		reportedValuesByQuery = new Map<String, Map<String, Double>>();
		for(String queryName : metricIdToQueryNameMap.values()){
			reportedValuesByQuery.put(queryName.toLowerCase(), new Map<String, Double>());
		}
		picklistValuesByQuery = new Map<String, Set<String>>();
		PopulatePicklistValues();

		medianCalculationsMap = new Map<String, Map<String, List<Decimal>>>();
		multiQueryCalculationsMap = new Map<String, Map<Id, Decimal>>();

		query = ConstructQuery();
		system.debug('**SZ: query = ' + query);
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		ProcessQuery(scope);
	}
	
	global void finish(Database.BatchableContext BC) {
		ProcessMetricValues();
	}

	private void PopulateValidQueryNames(){
		if(queryObject == Lead.class){
			queryNames.add('lead backlog');
			queryNames.add('lead count');
			queryNames.add('lead conversion rate');
		} else if(queryObject == Event.class){
			queryNames.add('system design backlog');
			queryNames.add('appointments scheduled');
			queryNames.add('appointments completed');
			queryNames.add('median time to first sales call');
		} else if(queryObject == Opportunity.class){
			queryNames.add('opportunity backlog');
			queryNames.add('opportunity count');
			queryNames.add('opportunity conversion rate');
			queryNames.add('sales count');
			queryNames.add('total referrals count');
			queryNames.add('internal referrals count');
			queryNames.add('cancellations');
		} else if(queryObject == SCRB_SalesOrder__c.class){
			queryNames.add('sales order backlog');
			queryNames.add('capacity in backlog');
		} else if(queryObject == Case.class){
			queryNames.add('customer case backlog');
			queryNames.add('maintenance backlog');
		} else if(queryObject == Customer_Survey__c.class){
			queryNames.add('nps');
		} else if(queryObject == PM_Project__c.class){
			queryNames.add('kickoff backlog');
			queryNames.add('install backlog');
			queryNames.add('inspection backlog');
			queryNames.add('inspections count');
			queryNames.add('capacity inspected');
			queryNames.add('average system size');
			queryNames.add('median time sale to inspection');
			queryNames.add('median time project creation to inspection');
		} else if(queryObject == User.class){
			queryNames.add('operations headcount');
			queryNames.add('sales consultant headcount');
		}
	}

	private Date GetReportingPeriodBegDate(Date dateInPeriod){
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

	private Date GetReportingPeriodEndDate(Date dateInPeriod){
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

	private Date GetYearBegDate(Date dateInPeriod){
		Date today = dateInPeriod;
		Integer currDay = today.day() - 1;
        Integer currMonth = today.month();
        Integer currYear = today.year();

        if(currMonth == 12 && currDay > 15)
        {
        	return Date.newInstance(currYear, 12, 16);
        }
        else
        {
        	return Date.newInstance(currYear - 1, 12, 16);
        }
	}

    private Double getMedian(List<Double> values){
        Integer sizeOfList = values.size();
        Double median = 0;
        if(sizeOfList == 0)
        {
            return median;
        }
        system.debug('size of list is '+ sizeOfList);
        Integer index = sizeOfList - 1;
        system.debug('the index is '+index);
        

        // sort the list first
        values.sort();

        //Calculate median
        if (Math.mod(sizeOfList, 2) == 0) {
           median = (values[(index-1)/2] + values[(index/2)+1])/2;
        }else{
           median = values[(index+1)/2];
        }

        if(median > 0)
        {
            median = (median/24).round();
        }

        return median;
    }

	private void PopulatePicklistValues(){
		if(queryObject == Lead.class){
			if(!picklistValuesByQuery.containsKey(queryObject.getName())){
				picklistValuesByQuery.put(queryObject.getName(), new Set<String>());
			}

			Schema.DescribeFieldResult fieldResult = Lead.Status.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for(Schema.PicklistEntry f : ple)
			{
				if(!f.getValue().contains('Prospect')){
					picklistValuesByQuery.get(queryObject.getName()).add(f.getValue());
				}
			}
		} else if(queryObject == Opportunity.class){
			if(!picklistValuesByQuery.containsKey(queryObject.getName())){
				picklistValuesByQuery.put(queryObject.getName(), new Set<String>());
			}

			Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for(Schema.PicklistEntry f : ple)
			{
				if(f.getValue() != 'Closed - Lost' && f.getValue() != 'Closed - Won' && f.getValue() != 'Contract Cancelled' && f.getValue() != 'Unresponsive'){
					picklistValuesByQuery.get(queryObject.getName()).add(f.getValue());
				}
			}
		} else if(queryObject == SCRB_SalesOrder__c.class){
			if(!picklistValuesByQuery.containsKey(queryObject.getName())){
				picklistValuesByQuery.put(queryObject.getName(), new Set<String>());
			}

			Schema.DescribeFieldResult fieldResult = SCRB_SalesOrder__c.StatusCode__c.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for(Schema.PicklistEntry f : ple)
			{
				if(f.getValue() != 'Final/Accounting Approved' && f.getValue() != 'Canceled'){
					picklistValuesByQuery.get(queryObject.getName()).add(f.getValue());
				}
			}
		}
	}

	private void AddToMap(String queryName, String valueType){
		AddToMap(queryName, valueType, 1, true);
	}

	private void AddToMap(String queryName, String valueType, Double value){
		AddToMap(queryName, valueType, value, false);
	}

	private void AddToMap(String queryName, String valueType, Double value, Boolean addValue){
		queryName = queryName.toLowerCase();
		if(!reportedValuesByQuery.containsKey(queryName)){
			reportedValuesByQuery.put(queryName, new Map<String, Double>());
		}

		if(addValue){
			if(reportedValuesByQuery.get(queryName).containsKey(valueType)){
				reportedValuesByQuery.get(queryName).put(valueType, reportedValuesByQuery.get(queryName).get(valueType) + value);
			} else {
				reportedValuesByQuery.get(queryName).put(valueType, value);
			}
		} else {
			reportedValuesByQuery.get(queryName).put(valueType, value);
		}
	}

	private String ConstructQuery(){
		String constructedQuery = 'SELECT Id, {f} FROM ' + queryObject.getName() + ' {w}';
		Set<String> fields = new Set<String>();
		String whereClause = '';

		if(queryObject == Lead.class){
			for(String queryName : metricIdToQueryNameMap.values()){
				if(queryName.toLowerCase() == 'lead backlog'){
					if(!fields.contains('Status')) { fields.add('Status'); }
					if(!fields.contains('IsConverted')) { fields.add('IsConverted'); }
					if(!fields.contains('Unqualified_Reason__c')) { fields.add('Unqualified_Reason__c'); }
				} else if(queryName.toLowerCase() == 'lead count'){
					if(!fields.contains('CreatedDate')) { fields.add('CreatedDate'); }
					if(!fields.contains('Status')) { fields.add('Status'); }
				} else if(queryName.toLowerCase() == 'lead conversion rate'){
					if(!fields.contains('CreatedDate')) { fields.add('CreatedDate'); }
					if(!fields.contains('Status')) { fields.add('Status'); }
					if(!fields.contains('IsConverted')) { fields.add('IsConverted'); }
				}
			}
		} else if(queryObject == Event.class){
			for(String queryName : metricIdToQueryNameMap.values()){
				if(queryName.toLowerCase() == 'system design backlog'){
					if(!fields.contains('Record_Type_Name__c')) { fields.add('Record_Type_Name__c'); }
					if(!fields.contains('Event_Status__c')) { fields.add('Event_Status__c'); }
					if(!fields.contains('IsChild')) { fields.add('IsChild'); }
					if(!fields.contains('Completed__c')) { fields.add('Completed__c'); }
					if(!fields.contains('What.type')) { fields.add('What.type'); }
				} else if(queryName.toLowerCase() == 'appointments scheduled'){
					if(!fields.contains('Record_Type_Name__c')) { fields.add('Record_Type_Name__c'); }
					if(!fields.contains('StartDateTime')) { fields.add('StartDateTime'); }
				} else if(queryName.toLowerCase() == 'appointments completed'){
					if(!fields.contains('Record_Type_Name__c')) { fields.add('Record_Type_Name__c'); }
					if(!fields.contains('StartDateTime')) { fields.add('StartDateTime'); }
					if(!fields.contains('Completed__c')) { fields.add('Completed__c'); }
				} else if(queryName.toLowerCase() == 'median time to first sales call'){
					medianCalculationsMap.put(queryName.toLowerCase(), new Map<String, List<Decimal>>());
					if(!fields.contains('Record_Type_Name__c')) { fields.add('Record_Type_Name__c'); }
					if(!fields.contains('StartDateTime')) { fields.add('StartDateTime'); }
					if(!fields.contains('IsChild')) { fields.add('IsChild'); }
					if(!fields.contains('What.type')) { fields.add('What.type'); }
					if(!fields.contains('WhatId')) { fields.add('WhatId'); }
				}
			}
		} else if(queryObject == Opportunity.class){
			for(String queryName : metricIdToQueryNameMap.values()){
				if(queryName.toLowerCase() == 'opportunity backlog'){
					if(!fields.contains('StageName')) { fields.add('StageName'); }
				} else if(queryName.toLowerCase() == 'opportunity count'){
					if(!fields.contains('CreatedDate')) { fields.add('CreatedDate'); }
				} else if(queryName.toLowerCase() == 'opportunity conversion rate'){
					if(!fields.contains('CreatedDate')) { fields.add('CreatedDate'); }
					if(!fields.contains('StageName')) { fields.add('StageName'); }
				} else if(queryName.toLowerCase() == 'sales count'){
					if(!fields.contains('Initial_Sales_Order_Close_Date__c')) { fields.add('Initial_Sales_Order_Close_Date__c'); }
					if(!fields.contains('StageName')) { fields.add('StageName'); }
				} else if(queryName.toLowerCase() == 'total referrals count'){
					if(!fields.contains('Initial_Sales_Order_Close_Date__c')) { fields.add('Initial_Sales_Order_Close_Date__c'); }
					if(!fields.contains('LeadSource')) { fields.add('LeadSource'); }
				} else if(queryName.toLowerCase() == 'internal referrals count'){
					if(!fields.contains('Initial_Sales_Order_Close_Date__c')) { fields.add('Initial_Sales_Order_Close_Date__c'); }
					if(!fields.contains('StageName')) { fields.add('StageName'); }
					if(!fields.contains('Lead_Source_Detail__c')) { fields.add('Lead_Source_Detail__c'); }
				} else if(queryName.toLowerCase() == 'cancellations'){
					if(!fields.contains('StageName')) { fields.add('StageName'); }
					if(!fields.contains('Date_Opp_Cancelled__c')) { fields.add('Date_Opp_Cancelled__c'); }
				}
			}
		} else if(queryObject == SCRB_SalesOrder__c.class){
			for(String queryName : metricIdToQueryNameMap.values()){
				if(queryName.toLowerCase() == 'sales order backlog'){
					if(!fields.contains('StatusCode__c')) { fields.add('StatusCode__c'); }
				} else if(queryName.toLowerCase() == 'capacity in backlog'){
					if(!fields.contains('StatusCode__c')) { fields.add('StatusCode__c'); }
					if(!fields.contains('System_Size_kW__c')) { fields.add('System_Size_kW__c'); }
					if(!fields.contains('Property__c')) { fields.add('Property__c'); }
					if(!fields.contains('OpportunityId__c')) { fields.add('OpportunityId__c'); }
				}
			}
		} else if(queryObject == Case.class){
			for(String queryName : metricIdToQueryNameMap.values()){
				if(queryName.toLowerCase() == 'customer case backlog'){
					if(!fields.contains('Status')) { fields.add('Status'); }
				} else if(queryName.toLowerCase() == 'maintenance backlog'){
					if(!fields.contains('Status')) { fields.add('Status'); }
					if(!fields.contains('Sub_Type_1__c')) { fields.add('Sub_Type_1__c'); }
				}
			}
		} else if(queryObject == Customer_Survey__c.class){
			for(String queryName : metricIdToQueryNameMap.values()){
				if(queryName.toLowerCase() == 'nps'){
					if(!fields.contains('Likelihood_of_Recommendation_Numeric__c')) { fields.add('Likelihood_of_Recommendation_Numeric__c'); }
					if(!fields.contains('Survey_Date_Completed__c')) { fields.add('Survey_Date_Completed__c'); }
				}
			}
			whereClause = 'WHERE Survey_Date_Completed__c >= ' + String.valueOf(yearBegDate) + ' AND Survey_Date_Completed__c <= ' + String.valueOf(reportEndDate);
		} else if(queryObject == PM_Project__c.class){
			for(String queryName : metricIdToQueryNameMap.values()){
				if(queryName.toLowerCase() == 'kickoff backlog'){
					if(!fields.contains('Status__c')) { fields.add('Status__c'); }
					if(!fields.contains('Kickoff__c')) { fields.add('Kickoff__c'); }
				} else if(queryName.toLowerCase() == 'install backlog'){
					if(!fields.contains('Status__c')) { fields.add('Status__c'); }
					if(!fields.contains('Kickoff__c')) { fields.add('Kickoff__c'); }
					if(!fields.contains('Work_Completed__c')) { fields.add('Work_Completed__c'); }
				} else if(queryName.toLowerCase() == 'inspection backlog'){
					if(!fields.contains('Status__c')) { fields.add('Status__c'); }
					if(!fields.contains('Work_Completed__c')) { fields.add('Work_Completed__c'); }
					if(!fields.contains('Proof_of_Inspection__c')) { fields.add('Proof_of_Inspection__c'); }
				} else if(queryName.toLowerCase() == 'inspections count'){
					if(!fields.contains('Proof_of_Inspection__c')) { fields.add('Proof_of_Inspection__c'); }
				} else if(queryName.toLowerCase() == 'capacity inspected'){
					if(!fields.contains('Proof_of_Inspection__c')) { fields.add('Proof_of_Inspection__c'); }
					if(!fields.contains('Total_System_Size_kW_DC__c')) { fields.add('Total_System_Size_kW_DC__c'); }
				} else if(queryName.toLowerCase() == 'average system size'){
					if(!fields.contains('Proof_of_Inspection__c')) { fields.add('Proof_of_Inspection__c'); }
					if(!fields.contains('Total_System_Size_kW_DC__c')) { fields.add('Total_System_Size_kW_DC__c'); }
				} else if(queryName.toLowerCase() == 'median time sale to inspection'){
					medianCalculationsMap.put(queryName.toLowerCase(), new Map<String, List<Decimal>>());
					if(!fields.contains('Proof_of_Inspection__c')) { fields.add('Proof_of_Inspection__c'); }
					if(!fields.contains('Sales_Order__r.Opportunity_Close_Date__c')) { fields.add('Sales_Order__r.Opportunity_Close_Date__c'); }
				} else if(queryName.toLowerCase() == 'median time project creation to inspection'){
					medianCalculationsMap.put(queryName.toLowerCase(), new Map<String, List<Decimal>>());
					if(!fields.contains('Work_Completed__c')) { fields.add('Work_Completed__c'); }
					if(!fields.contains('Total_System_Size_kW_DC__c')) { fields.add('Total_System_Size_kW_DC__c'); }
				}
			}
		} else if(queryObject == User.class){
			for(String queryName : metricIdToQueryNameMap.values()){
				if(queryName.toLowerCase() == 'operations headcount'){
					if(!fields.contains('IsActive')) { fields.add('IsActive'); }
					if(!fields.contains('Profile.Name')) { fields.add('Profile.Name'); }
				} else if(queryName.toLowerCase() == 'sales consultant headcount'){
					if(!fields.contains('IsActive')) { fields.add('IsActive'); }
					if(!fields.contains('Profile.Name')) { fields.add('Profile.Name'); }
				}
			}
			whereClause = 'LIMIT 1';
		}

		constructedQuery = constructedQuery.replace('{f}', String.join(new List<String>(fields), ', ')).replace('{w}', whereClause);
		if(Test.isRunningTest() && !constructedQuery.contains('LIMIT')){
			constructedQuery += ' LIMIT 100';
		}
		return constructedQuery;
	}

	private void ProcessQuery(List<sObject> scope){
		if(queryObject == Lead.class){
			for(Lead lead : (List<Lead>)scope){
				for(String queryName : metricIdToQueryNameMap.values()){
					if(queryName.toLowerCase() == 'lead backlog'){
						if(picklistValuesByQuery.get(queryObject.getName()).contains(lead.Status) && lead.IsConverted ==  false && (lead.Unqualified_Reason__c == null || lead.Unqualified_Reason__c == '')){
							AddToMap(queryName, 'R');
						}
					} else if(queryName.toLowerCase() == 'lead count'){
						if(picklistValuesByQuery.get(queryObject.getName()).contains(lead.Status) && lead.CreatedDate >= reportEndDateTime){
							AddToMap(queryName, 'D');
						}
						if(picklistValuesByQuery.get(queryObject.getName()).contains(lead.Status) && lead.CreatedDate >= reportEndDateTime.addDays(-7) && lead.CreatedDate <= reportEndDateTime){
							AddToMap(queryName, 'W');
						}
						if(picklistValuesByQuery.get(queryObject.getName()).contains(lead.Status) && lead.CreatedDate >= reportingPeriodBegDate && lead.CreatedDate <= reportEndDateTime){
							AddToMap(queryName, 'M');
						}
						if(picklistValuesByQuery.get(queryObject.getName()).contains(lead.Status) && lead.CreatedDate >= yearBegDate && lead.CreatedDate <= reportEndDateTime){
							AddToMap(queryName, 'Y');
						}
					} else if(queryName.toLowerCase() == 'lead conversion rate'){
						if(picklistValuesByQuery.get(queryObject.getName()).contains(lead.Status) && lead.CreatedDate >= reportEndDateTime){
							AddToMap(queryName, 'DT');
							if(lead.IsConverted == true){
								AddToMap(queryName, 'DC');
							}
						}
						if(picklistValuesByQuery.get(queryObject.getName()).contains(lead.Status) && lead.CreatedDate >= reportEndDateTime.addDays(-7) && lead.CreatedDate <= reportEndDateTime){
							AddToMap(queryName, 'WT');
							if(lead.IsConverted == true){
								AddToMap(queryName, 'WC');
							}
						}
						if(picklistValuesByQuery.get(queryObject.getName()).contains(lead.Status) && lead.CreatedDate >= reportingPeriodBegDate && lead.CreatedDate <= reportEndDateTime){
							AddToMap(queryName, 'MT');
							if(lead.IsConverted == true){
								AddToMap(queryName, 'MC');
							}
						}
						if(picklistValuesByQuery.get(queryObject.getName()).contains(lead.Status) && lead.CreatedDate >= yearBegDate && lead.CreatedDate <= reportEndDateTime){
							AddToMap(queryName, 'YT');
							if(lead.IsConverted == true){
								AddToMap(queryName, 'YC');
							}
						}
					}
				}
			}
		} else if(queryObject == Event.class){
			Map<Id, Map<Id, Event>> weeklySalesCallsByOpp = new Map<Id, Map<Id, Event>>();
			Map<Id, Map<Id, Event>> monthlySalesCallsByOpp = new Map<Id, Map<Id, Event>>();
			Map<Id, Map<Id, Event>> yearlySalesCallsByOpp = new Map<Id, Map<Id, Event>>();
			Set<Id> oppIds = new Set<Id>();
			for(Event event : (List<Event>)scope){
				for(String queryName : metricIdToQueryNameMap.values()){
					if(queryName.toLowerCase() == 'system design backlog'){
						if((event.Record_Type_Name__c == 'Site Survey Onsite' || event.Record_Type_Name__c == 'Site Survey Remote') && event.Event_Status__c == null && event.IsChild == false && event.Completed__c == false && event.What.type == 'Opportunity'){
							AddToMap(queryName, 'R');
						}
					} else if(queryName.toLowerCase() == 'appointments scheduled'){
						if(companyWideReport.Reporting_Frequency__c == 'Weekly'){
							if((event.Record_Type_Name__c == 'Sales Visit Onsite' || event.Record_Type_Name__c == 'Sales Visit Remote') && event.StartDateTime >= reportEndDateTime.addDays(-7) && event.StartDateTime <= reportEndDateTime){
								AddToMap(queryName, 'R');
							}
						} else if(companyWideReport.Reporting_Frequency__c == 'Monthly'){
							if((event.Record_Type_Name__c == 'Sales Visit Onsite' || event.Record_Type_Name__c == 'Sales Visit Remote') && event.StartDateTime >= reportingPeriodBegDate && event.StartDateTime <= reportEndDateTime){
								AddToMap(queryName, 'R');
							}
						}
					} else if(queryName.toLowerCase() == 'appointments completed'){
						if(companyWideReport.Reporting_Frequency__c == 'Weekly'){
							if((event.Record_Type_Name__c == 'Sales Visit Onsite' || event.Record_Type_Name__c == 'Sales Visit Remote') && event.Completed__c == true && event.StartDateTime >= reportEndDateTime.addDays(-7) && event.StartDateTime <= reportEndDateTime){
								AddToMap(queryName, 'R');
							}
						} else if(companyWideReport.Reporting_Frequency__c == 'Monthly'){
							if((event.Record_Type_Name__c == 'Sales Visit Onsite' || event.Record_Type_Name__c == 'Sales Visit Remote') && event.Completed__c == true && event.StartDateTime >= reportingPeriodBegDate && event.StartDateTime <= reportEndDateTime){
								AddToMap(queryName, 'R');
							}
						}
					} else if(queryName.toLowerCase() == 'median time to first sales call'){
                        if(event.Record_Type_Name__c == 'Sales Visit Onsite' && event.IsChild == false && event.What.Type == 'Opportunity' && event.StartDateTime >= reportEndDateTime.addDays(-7) && event.StartDateTime < reportEndDateTime){
                        	oppIds.add(event.WhatId);
                        	if(weeklySalesCallsByOpp.containsKey(event.WhatId)){
                        		for(Id eventId : weeklySalesCallsByOpp.get(event.WhatId).keySet()){
                        			if(event.StartDateTime < weeklySalesCallsByOpp.get(event.WhatId).get(eventId).StartDateTime){
		                        		weeklySalesCallsByOpp.put(event.WhatId, new Map<Id, Event>{event.Id=>event});
                        			}
                        		}
                        	} else {
                        		weeklySalesCallsByOpp.put(event.WhatId, new Map<Id, Event>{event.Id=>event});
                        	}
                        }
                        if(event.Record_Type_Name__c == 'Sales Visit Onsite' && event.IsChild == false && event.What.Type == 'Opportunity' && event.StartDateTime >= reportingPeriodBegDate && event.StartDateTime < reportEndDateTime){
                        	oppIds.add(event.WhatId);
                        	if(monthlySalesCallsByOpp.containsKey(event.WhatId)){
                        		for(Id eventId : monthlySalesCallsByOpp.get(event.WhatId).keySet()){
                        			if(event.StartDateTime < monthlySalesCallsByOpp.get(event.WhatId).get(eventId).StartDateTime){
		                        		monthlySalesCallsByOpp.put(event.WhatId, new Map<Id, Event>{event.Id=>event});
                        			}
                        		}
                        	} else {
                        		monthlySalesCallsByOpp.put(event.WhatId, new Map<Id, Event>{event.Id=>event});
                        	}
                    	}
                    	if(event.Record_Type_Name__c == 'Sales Visit Onsite' && event.IsChild == false && event.What.Type == 'Opportunity' && event.StartDateTime >= yearBegDate && event.StartDateTime < reportEndDateTime){
                        	oppIds.add(event.WhatId);
                        	if(yearlySalesCallsByOpp.containsKey(event.WhatId)){
                        		for(Id eventId : yearlySalesCallsByOpp.get(event.WhatId).keySet()){
                        			if(event.StartDateTime < yearlySalesCallsByOpp.get(event.WhatId).get(eventId).StartDateTime){
		                        		yearlySalesCallsByOpp.put(event.WhatId, new Map<Id, Event>{event.Id=>event});
                        			}
                        		}
                        	} else {
                        		yearlySalesCallsByOpp.put(event.WhatId, new Map<Id, Event>{event.Id=>event});
                        	}
                    	}
                    }
                }
            }

            // Calculate median
			for(String queryName : metricIdToQueryNameMap.values()){
				if(queryName.toLowerCase() == 'median time to first sales call'){
			        Map<Id,Opportunity> opptyMap = new Map<Id,Opportunity>([SELECT Id, CreatedDate FROM Opportunity WHERE Id in :oppIds]);

			        List<Decimal> timeDiff = new List<Decimal>();
			        for(Id oppId : weeklySalesCallsByOpp.keySet())
			        {
			        	for(Event evt : weeklySalesCallsByOpp.get(oppId).values()){
				            timeDiff.add((evt.StartDateTime.getTime()/1000/60/60)
				                     - (opptyMap.get(oppId).CreatedDate.getTime()/1000/60/60));
			        	}
			        }
					if(medianCalculationsMap.get(queryName.toLowerCase()).containsKey('W')){
						medianCalculationsMap.get(queryName.toLowerCase()).get('W').addAll(timeDiff);
					} else {
				        medianCalculationsMap.get(queryName.toLowerCase()).put('W', timeDiff);
					}

			        timeDiff = new List<Decimal>();
			        for(Id oppId : monthlySalesCallsByOpp.keySet())
			        {
			        	for(Event evt : monthlySalesCallsByOpp.get(oppId).values()){
				            timeDiff.add((evt.StartDateTime.getTime()/1000/60/60)
				                     - (opptyMap.get(oppId).CreatedDate.getTime()/1000/60/60));
			        	}
			        }
					if(medianCalculationsMap.get(queryName.toLowerCase()).containsKey('M')){
						medianCalculationsMap.get(queryName.toLowerCase()).get('M').addAll(timeDiff);
					} else {
				        medianCalculationsMap.get(queryName.toLowerCase()).put('M', timeDiff);
					}

			        timeDiff = new List<Decimal>();
			        for(Id oppId : yearlySalesCallsByOpp.keySet())
			        {
			        	for(Event evt : yearlySalesCallsByOpp.get(oppId).values()){
				            timeDiff.add((evt.StartDateTime.getTime()/1000/60/60)
				                     - (opptyMap.get(oppId).CreatedDate.getTime()/1000/60/60));
			        	}
			        }
					if(medianCalculationsMap.get(queryName.toLowerCase()).containsKey('Y')){
						medianCalculationsMap.get(queryName.toLowerCase()).get('Y').addAll(timeDiff);
					} else {
				        medianCalculationsMap.get(queryName.toLowerCase()).put('Y', timeDiff);
					}
				}
			}
		} else if(queryObject == Opportunity.class){
			for(Opportunity opp : (List<Opportunity>)scope){
				for(String queryName : metricIdToQueryNameMap.values()){
					if(queryName.toLowerCase() == 'opportunity backlog'){
						if(picklistValuesByQuery.get(queryObject.getName()).contains(opp.StageName)){
							AddToMap(queryName, 'R');
						}
					} else if(queryName.toLowerCase() == 'opportunity count'){
						if(opp.CreatedDate >= reportEndDateTime){
							AddToMap(queryName, 'D');
						}
						if(opp.CreatedDate >= reportEndDateTime.addDays(-7) && opp.CreatedDate <= reportEndDateTime){
							AddToMap(queryName, 'W');
						}
						if(opp.CreatedDate >= reportingPeriodBegDate && opp.CreatedDate <= reportEndDateTime){
							AddToMap(queryName, 'M');
						}
						if(opp.CreatedDate >= yearBegDate && opp.CreatedDate <= reportEndDateTime){
							AddToMap(queryName, 'Y');
						}
					} else if(queryName.toLowerCase() == 'opportunity conversion rate'){
						if(opp.CreatedDate >= reportEndDateTime.addDays(-84) && opp.CreatedDate <= reportEndDateTime){
							AddToMap(queryName, 'MT');
							if(opp.StageName == 'Closed - Won' || opp.StageName == 'Contract Cancelled'){
								AddToMap(queryName, 'MC');
							}
						}
					} else if(queryName.toLowerCase() == 'sales count'){
						if(opp.StageName == 'Closed - Won' || opp.StageName == 'Contract Cancelled'){
							if(opp.Initial_Sales_Order_Close_Date__c >= reportEndDate){
								AddToMap(queryName, 'D');
							}
							if(opp.Initial_Sales_Order_Close_Date__c >= reportEndDate.addDays(-6) && opp.Initial_Sales_Order_Close_Date__c <= reportEndDate){
								AddToMap(queryName, 'W');
							}
							if(opp.Initial_Sales_Order_Close_Date__c >= reportingPeriodBegDate && opp.Initial_Sales_Order_Close_Date__c <= reportEndDate){
								AddToMap(queryName, 'M');
							}
							if(opp.Initial_Sales_Order_Close_Date__c >= yearBegDate && opp.Initial_Sales_Order_Close_Date__c <= reportEndDate){
								AddToMap(queryName, 'Y');
							}
						}
					} else if(queryName.toLowerCase() == 'total referrals count'){
						if(opp.Initial_Sales_Order_Close_Date__c != null && (opp.LeadSource == 'Individual Referral' || opp.LeadSource == 'Partner Referral') && (opp.StageName == 'Closed - Won' || opp.StageName == 'Contract Cancelled')){
							if(opp.Initial_Sales_Order_Close_Date__c >= reportEndDate){
								AddToMap(queryName, 'D');
							}
							if(opp.Initial_Sales_Order_Close_Date__c >= reportEndDate.addDays(-6) && opp.Initial_Sales_Order_Close_Date__c <= reportEndDate){
								AddToMap(queryName, 'W');
							}
							if(opp.Initial_Sales_Order_Close_Date__c >= reportingPeriodBegDate && opp.Initial_Sales_Order_Close_Date__c <= reportEndDate){
								AddToMap(queryName, 'M');
							}
							if(opp.Initial_Sales_Order_Close_Date__c >= yearBegDate && opp.Initial_Sales_Order_Close_Date__c <= reportEndDate){
								AddToMap(queryName, 'Y');
							}
						}
					} else if(queryName.toLowerCase() == 'internal referrals count'){
						Set<String> leadSourceDetails = new Set<String>();
						leadSourceDetails.add('Benjamin Franklin (DES)');
						leadSourceDetails.add('Mr. Sparky (DES)');
						leadSourceDetails.add('OneHour Air conditioning and Heating (DES)');
						leadSourceDetails.add('DE MyAccount');
						leadSourceDetails.add('Airtron (DES)');
						leadSourceDetails.add('Home Warranty of America (DES)');
						leadSourceDetails.add('Other (DES)');
						if(opp.Initial_Sales_Order_Close_Date__c != null && (opp.StageName == 'Closed - Won' || opp.StageName == 'Contract Cancelled') && leadSourceDetails.contains(opp.Lead_Source_Detail__c)){
							if(opp.Initial_Sales_Order_Close_Date__c >= reportEndDate){
								AddToMap(queryName, 'D');
							}
							if(opp.Initial_Sales_Order_Close_Date__c >= reportEndDate.addDays(-6) && opp.Initial_Sales_Order_Close_Date__c <= reportEndDate){
								AddToMap(queryName, 'W');
							}
							if(opp.Initial_Sales_Order_Close_Date__c >= reportingPeriodBegDate && opp.Initial_Sales_Order_Close_Date__c <= reportEndDate){
								AddToMap(queryName, 'M');
							}
							if(opp.Initial_Sales_Order_Close_Date__c >= yearBegDate && opp.Initial_Sales_Order_Close_Date__c <= reportEndDate){
								AddToMap(queryName, 'Y');
							}
						}
					} else if(queryName.toLowerCase() == 'cancellations'){
						if(opp.StageName == 'Contract Cancelled'){
							if(opp.Date_Opp_Cancelled__c >= reportEndDate){
								AddToMap(queryName, 'D');
							}
							if(opp.Date_Opp_Cancelled__c >= reportEndDate.addDays(-6) && opp.Date_Opp_Cancelled__c <= reportEndDate){
								AddToMap(queryName, 'W');
							}
							if(opp.Date_Opp_Cancelled__c >= reportingPeriodBegDate && opp.Date_Opp_Cancelled__c <= reportEndDate){
								AddToMap(queryName, 'M');
							}
							if(opp.Date_Opp_Cancelled__c >= yearBegDate && opp.Date_Opp_Cancelled__c <= reportEndDate){
								AddToMap(queryName, 'Y');
							}
						}
					}
				}
			}
		} else if(queryObject == SCRB_SalesOrder__c.class){
			for(SCRB_SalesOrder__c salesOrder : (List<SCRB_SalesOrder__c>)scope){
				for(String queryName : metricIdToQueryNameMap.values()){
					if(queryName.toLowerCase() == 'sales order backlog'){
						if(picklistValuesByQuery.get(queryObject.getName()).contains(salesOrder.StatusCode__c)){
							AddToMap(queryName, 'R');
						}
					} else if(queryName.toLowerCase() == 'capacity in backlog'){
						if(salesOrder.StatusCode__c != 'Canceled' && salesOrder.Property__c != null && salesOrder.OpportunityId__c != null && salesOrder.System_Size_kW__c != null){
							if(multiQueryCalculationsMap.containsKey(queryName.toLowerCase())){
								multiQueryCalculationsMap.get(queryName.toLowerCase()).put(salesOrder.Id, salesOrder.System_Size_kW__c);
							} else {
								multiQueryCalculationsMap.put(queryName.toLowerCase(), new Map<Id, Decimal>{salesOrder.Id=>salesOrder.System_Size_kW__c});
							}
						}
					}
				}
			}
		} else if(queryObject == Case.class){
			for(Case cs : (List<Case>)scope){
				for(String queryName : metricIdToQueryNameMap.values()){
					if(queryName.toLowerCase() == 'customer case backlog'){
						if(cs.Status != 'Closed' && cs.Status != 'Closed - Duplicate'){
							AddToMap(queryName, 'R');
						}
					} else if(queryName.toLowerCase() == 'maintenance backlog'){
						if(cs.Status != 'Closed' && cs.Status != 'Closed - Duplicate' && (cs.Sub_Type_1__c == 'Equipment Maintenance' || cs.Sub_Type_1__c == 'Account Maintenance')){
							AddToMap(queryName, 'R');
						}
					}
				}
			}
		} else if(queryObject == Customer_Survey__c.class){
			for(Customer_Survey__c survey : (List<Customer_Survey__c>)scope){
				for(String queryName : metricIdToQueryNameMap.values()){
					if(queryName.toLowerCase() == 'nps'){
						if(survey.Survey_Date_Completed__c >= reportEndDate){
							if(survey.Likelihood_of_Recommendation_Numeric__c >= 9){
								AddToMap(queryName, 'D9');
							} else if(survey.Likelihood_of_Recommendation_Numeric__c <= 6){
								AddToMap(queryName, 'D6');
							}
							AddToMap(queryName, 'DT');
						}
						if(survey.Survey_Date_Completed__c >= reportEndDate.addDays(-6) && survey.Survey_Date_Completed__c <= reportEndDate){
							if(survey.Likelihood_of_Recommendation_Numeric__c >= 9){
								AddToMap(queryName, 'W9');
							} else if(survey.Likelihood_of_Recommendation_Numeric__c <= 6){
								AddToMap(queryName, 'W6');
							}
							AddToMap(queryName, 'WT');
						}
						if(survey.Survey_Date_Completed__c >= reportingPeriodBegDate && survey.Survey_Date_Completed__c <= reportEndDate){
							if(survey.Likelihood_of_Recommendation_Numeric__c >= 9){
								AddToMap(queryName, 'M9');
							} else if(survey.Likelihood_of_Recommendation_Numeric__c <= 6){
								AddToMap(queryName, 'M6');
							}
							AddToMap(queryName, 'MT');
						}
						if(survey.Survey_Date_Completed__c >= yearBegDate && survey.Survey_Date_Completed__c <= reportEndDate){
							if(survey.Likelihood_of_Recommendation_Numeric__c >= 9){
								AddToMap(queryName, 'Y9');
							} else if(survey.Likelihood_of_Recommendation_Numeric__c <= 6){
								AddToMap(queryName, 'Y6');
							}
							AddToMap(queryName, 'YT');
						}
					}
				}
			}
		} else if(queryObject == PM_Project__c.class){
			for(PM_Project__c project : (List<PM_Project__c>)scope){
				for(String queryName : metricIdToQueryNameMap.values()){
					if(queryName.toLowerCase() == 'kickoff backlog'){
						if(project.Status__c != 'Cancelled' && (project.Kickoff__c == null || project.Kickoff__c >= Date.today())){
							AddToMap(queryName, 'R');
						}
					} else if(queryName.toLowerCase() == 'install backlog'){
						if(project.Status__c != 'Cancelled' && project.Kickoff__c < Date.today() && project.Work_Completed__c == null){
							AddToMap(queryName, 'R');
						}
					} else if(queryName.toLowerCase() == 'inspection backlog'){
						if(project.Status__c != 'Cancelled' && project.Work_Completed__c != null && project.Proof_of_Inspection__c == null){
							AddToMap(queryName, 'R');
						}
					} else if(queryName.toLowerCase() == 'inspections count'){
						if(project.Proof_of_Inspection__c >= reportEndDate){
							AddToMap(queryName, 'D');
						}
						if(project.Proof_of_Inspection__c >= reportEndDate.addDays(-6) && project.Proof_of_Inspection__c <= reportEndDate){
							AddToMap(queryName, 'W');
						}
						if(project.Proof_of_Inspection__c >= reportingPeriodBegDate && project.Proof_of_Inspection__c <= reportEndDate){
							AddToMap(queryName, 'M');
						}
						if(project.Proof_of_Inspection__c >= yearBegDate && project.Proof_of_Inspection__c <= reportEndDate){
							AddToMap(queryName, 'Y');
						}
					} else if(queryName.toLowerCase() == 'capacity inspected'){
						if(project.Proof_of_Inspection__c >= reportEndDate){
							AddToMap(queryName, 'D', Double.valueOf(project.Total_System_Size_kW_DC__c), true);
						}
						if(project.Proof_of_Inspection__c >= reportEndDate.addDays(-6) && project.Proof_of_Inspection__c <= reportEndDate){
							AddToMap(queryName, 'W', Double.valueOf(project.Total_System_Size_kW_DC__c), true);
						}
						if(project.Proof_of_Inspection__c >= reportingPeriodBegDate && project.Proof_of_Inspection__c <= reportEndDate){
							AddToMap(queryName, 'M', Double.valueOf(project.Total_System_Size_kW_DC__c), true);
						}
						if(project.Proof_of_Inspection__c >= yearBegDate && project.Proof_of_Inspection__c <= reportEndDate){
							AddToMap(queryName, 'Y', Double.valueOf(project.Total_System_Size_kW_DC__c), true);
						}
					} else if(queryName.toLowerCase() == 'average system size'){
						if(project.Proof_of_Inspection__c >= reportEndDate){
							AddToMap(queryName, 'DS', Double.valueOf(project.Total_System_Size_kW_DC__c), true);
							AddToMap(queryName, 'DC');
						}
						if(project.Proof_of_Inspection__c >= reportEndDate.addDays(-6) && project.Proof_of_Inspection__c <= reportEndDate){
							AddToMap(queryName, 'WS', Double.valueOf(project.Total_System_Size_kW_DC__c), true);
							AddToMap(queryName, 'WC');
						}
						if(project.Proof_of_Inspection__c >= reportingPeriodBegDate && project.Proof_of_Inspection__c <= reportEndDate){
							AddToMap(queryName, 'MS', Double.valueOf(project.Total_System_Size_kW_DC__c), true);
							AddToMap(queryName, 'MC');
						}
						if(project.Proof_of_Inspection__c >= yearBegDate && project.Proof_of_Inspection__c <= reportEndDate){
							AddToMap(queryName, 'YS', Double.valueOf(project.Total_System_Size_kW_DC__c), true);
							AddToMap(queryName, 'YC');
						}
					} else if(queryName.toLowerCase() == 'median time sale to inspection'){
						if(project.Proof_of_Inspection__c != null){
	                    	Datetime proofDate = Datetime.newInstance(project.Proof_of_Inspection__c.year(), project.Proof_of_Inspection__c.month(), project.Proof_of_Inspection__c.day());
	                    	Datetime closeDate = Datetime.newInstance(project.Sales_Order__r.Opportunity_Close_Date__c.year(), project.Sales_Order__r.Opportunity_Close_Date__c.month(), project.Sales_Order__r.Opportunity_Close_Date__c.day());
				            Decimal timeDiff = (proofDate.getTime()/1000/60/60) - (closeDate.getTime()/1000/60/60);

	                        if(project.Proof_of_Inspection__c == reportEndDate.addDays(-1)){
								if(medianCalculationsMap.get(queryName.toLowerCase()).containsKey('D')){
									medianCalculationsMap.get(queryName.toLowerCase()).get('D').add(timeDiff);
								} else {
							        medianCalculationsMap.get(queryName.toLowerCase()).put('D', new List<Decimal>{timeDiff});
								}
	                        }
	                        if(project.Proof_of_Inspection__c >= reportEndDate.addDays(-6) && project.Proof_of_Inspection__c < reportEndDate){
								if(medianCalculationsMap.get(queryName.toLowerCase()).containsKey('W')){
									medianCalculationsMap.get(queryName.toLowerCase()).get('W').add(timeDiff);
								} else {
							        medianCalculationsMap.get(queryName.toLowerCase()).put('W', new List<Decimal>{timeDiff});
								}
	                        }
	                        if(project.Proof_of_Inspection__c >= reportingPeriodBegDate && project.Proof_of_Inspection__c < reportEndDate){
								if(medianCalculationsMap.get(queryName.toLowerCase()).containsKey('M')){
									medianCalculationsMap.get(queryName.toLowerCase()).get('M').add(timeDiff);
								} else {
							        medianCalculationsMap.get(queryName.toLowerCase()).put('M', new List<Decimal>{timeDiff});
								}
	                    	}
	                    	if(project.Proof_of_Inspection__c >= yearBegDate && project.Proof_of_Inspection__c < reportEndDate){
								if(medianCalculationsMap.get(queryName.toLowerCase()).containsKey('Y')){
									medianCalculationsMap.get(queryName.toLowerCase()).get('Y').add(timeDiff);
								} else {
							        medianCalculationsMap.get(queryName.toLowerCase()).put('Y', new List<Decimal>{timeDiff});
								}
	                    	}
						}
					} else if(queryName.toLowerCase() == 'median time project creation to inspection'){
						// not resolved yet
					}
				}
			}
		} else if(queryObject == User.class){
			// handled by the metricIdToHeadcountMap
		}
	}

	private void ProcessMetricValues(){
		Map<Id, Reported_Metric_Value__c> metricsToValuesMap = new Map<Id, Reported_Metric_Value__c>();
		Map<Id, Reported_Metric_Value__c> reportedMetricValues = new Map<Id, Reported_Metric_Value__c>([SELECT Id, Company_Wide_Report__c, Metric__c, Reported_Value__c, Headcount__c, Delta__c, Week_To_Date__c, Month_To_Date__c, Year_To_Date__c FROM Reported_Metric_Value__c WHERE Company_Wide_Report__c = :companyWideReportId]);
		for(Reported_Metric_Value__c metricValue : reportedMetricValues.values()){
			if(!metricsToValuesMap.containsKey(metricValue.Metric__c)){
				metricsToValuesMap.put(metricValue.Metric__c, metricValue);
			}
		}

		Map<Id, Metric__c> metrics = new Map<Id, Metric__c>([SELECT Id, Name, Calculate_Delta__c, Query_Name__c, Headcount_Profiles__c FROM Metric__c WHERE Id IN :metricsToValuesMap.keySet() AND Is_Calculated__c = true]);

		// get targets
		// Id = Metric_Target_Goal__c.Id
		Map<Id, Metric_Target_Goal__c> metricTargets = new Map<Id, Metric_Target_Goal__c>([SELECT Id, Name, Metric__c, Daily_Target__c, Weekly_Target__c, Monthly_Target__c, Annual_Target__c FROM Metric_Target_Goal__c WHERE Effective_From__c <= :reportEndDate AND Effective_To__c >= :reportEndDate AND Metric__c IN :metrics.keySet()]);

		// Id = Metric__c.Id
		Map<Id, Metric_Target_Goal__c> metricsToTargetsMap = new Map<Id, Metric_Target_Goal__c>();
		for(Metric_Target_Goal__c target : metricTargets.values()){
			if(!metricsToTargetsMap.containsKey(target.Metric__c)){
				metricsToTargetsMap.put(target.Metric__c, target);
			}
		}

		for(Reported_Metric_Value__c rmv : metricsToValuesMap.values()){
			Metric__c metric = metrics.get(rmv.Metric__c);
			if(metric != null && queryNames.contains(metric.Query_Name__c.toLowerCase())){
				// Get reported value
				Boolean hasDailyTarget = false;
				if(metricsToTargetsMap.containsKey(metric.Id)){
					if (metricsToTargetsMap.get(metric.Id).Daily_Target__c != null && metricsToTargetsMap.get(metric.Id).Daily_Target__c > 0){
						hasDailyTarget = true;
					}
				}

				GetReportedValue(rmv, metric.Query_Name__c, hasDailyTarget);

				if(!metricsToTargetsMap.containsKey(metric.Id)){
					// Get Delta, if needed
					if(metric.Calculate_Delta__c){
						if(metricIdToPreviousValueMap != null && metricIdToPreviousValueMap.containsKey(metric.Id)){
							rmv.Delta__c = rmv.Reported_Value__c - metricIdToPreviousValueMap.get(metric.Id);
						} else {
							rmv.Delta__c = rmv.Reported_Value__c;
						}
					}

					// Get Headcount
					if(metricIdToHeadcountMap.containsKey(metric.Id)){
						rmv.Headcount__c = metricIdToHeadcountMap.get(metric.Id);
					}
				}
			}
		}

		update metricsToValuesMap.values();
	}

	private void GetReportedValue(Reported_Metric_Value__c rmv, String queryName, Boolean hasDailyTarget){
		queryName = queryName.toLowerCase();
		Map<String, Double> reportedValues = reportedValuesByQuery.get(queryName);
		if(queryName == 'lead backlog'){
			if(reportedValues.containsKey('R')){
				rmv.Reported_Value__c = reportedValues.get('R');
			}
		} else if(queryName == 'lead count'){
			rmv.Reported_Value__c = 0;
			rmv.Week_To_Date__c = 0;
			rmv.Month_To_Date__c = 0;
			rmv.Year_To_Date__c = 0;
			if(hasDailyTarget){
				if(reportedValues.containsKey('D')){
					rmv.Reported_Value__c = reportedValues.get('D');
				}
			} else {
				if(reportedValues.containsKey('W')){
					rmv.Reported_Value__c = reportedValues.get('W');
				}
			}
			if(reportedValues.containsKey('W')){
				rmv.Week_To_Date__c = reportedValues.get('W');
			}
			if(reportedValues.containsKey('M')){
				rmv.Month_To_Date__c = reportedValues.get('M');
			}
			if(reportedValues.containsKey('Y')){
				rmv.Year_To_Date__c = reportedValues.get('Y');
			}
		} else if(queryName == 'lead conversion rate'){
			if(!reportedValues.containsKey('YT')){
				rmv.Reported_Value__c = 0;
				rmv.Week_To_Date__c = 0;
				rmv.Month_To_Date__c = 0;
				rmv.Year_To_Date__c = 0;
			} else {
				if(hasDailyTarget){
					if(!reportedValues.containsKey('DC') || !reportedValues.containsKey('DT')){
						rmv.Reported_Value__c = 0;
					} else {
						rmv.Reported_Value__c = 100 * reportedValues.get('DC') / reportedValues.get('DT');
					}
				} else {
					if(!reportedValues.containsKey('WC') || !reportedValues.containsKey('WT')){
						rmv.Reported_Value__c = 0;
					} else {
						rmv.Reported_Value__c = 100 * reportedValues.get('WC') / reportedValues.get('WT');
					}
				}
				if(!reportedValues.containsKey('WC') || !reportedValues.containsKey('WT')){
					rmv.Week_To_Date__c = 0;
				} else {
					rmv.Week_To_Date__c = 100 * reportedValues.get('WC') / reportedValues.get('WT');
				}
				if(!reportedValues.containsKey('MC') || !reportedValues.containsKey('MT')){
					rmv.Month_To_Date__c = 0;
				} else {
					rmv.Month_To_Date__c = 100 * reportedValues.get('MC') / reportedValues.get('MT');
				}
				if(!reportedValues.containsKey('YC') || !reportedValues.containsKey('YT')){
					rmv.Year_To_Date__c = 0;
				} else {
					rmv.Year_To_Date__c = 100 * reportedValues.get('YC') / reportedValues.get('YT');
				}
			}
		} else if(queryName == 'system design backlog'){
			if(reportedValues.containsKey('R')){
				rmv.Reported_Value__c = reportedValues.get('R');
			}
		} else if(queryName == 'appointments scheduled'){
			if(reportedValues.containsKey('R')){
				rmv.Reported_Value__c = reportedValues.get('R');
			}
		} else if(queryName == 'appointments completed'){
			if(reportedValues.containsKey('R')){
				rmv.Reported_Value__c = reportedValues.get('R');
			}
		} else if(queryName == 'median time to first sales call'){
			if(medianCalculationsMap.containsKey(queryName)){
				system.debug('**SZ: calc map = ' + medianCalculationsMap.get(queryName));
				rmv.Reported_Value__c = 0;
				rmv.Week_To_Date__c = 0;
				rmv.Month_To_Date__c = 0;
				rmv.Year_To_Date__c = 0;
				if(hasDailyTarget){
					if(medianCalculationsMap.get(queryName).containsKey('D')){
						rmv.Reported_Value__c = getMedian(medianCalculationsMap.get(queryName).get('D'));
					}
				} else {
					if(medianCalculationsMap.get(queryName).containsKey('W')){
						rmv.Reported_Value__c = getMedian(medianCalculationsMap.get(queryName).get('W'));
					}
				}
				if(medianCalculationsMap.get(queryName).containsKey('W')){
					rmv.Week_To_Date__c = getMedian(medianCalculationsMap.get(queryName).get('W'));
				}
				if(medianCalculationsMap.get(queryName).containsKey('M')){
					rmv.Month_To_Date__c = getMedian(medianCalculationsMap.get(queryName).get('M'));
				}
				if(medianCalculationsMap.get(queryName).containsKey('Y')){
					rmv.Year_To_Date__c = getMedian(medianCalculationsMap.get(queryName).get('Y'));
				}
			}
		} else if(queryName == 'opportunity backlog'){
			if(reportedValues.containsKey('R')){
				rmv.Reported_Value__c = reportedValues.get('R');
			}
		} else if(queryName == 'opportunity count'){
			rmv.Reported_Value__c = 0;
			rmv.Week_To_Date__c = 0;
			rmv.Month_To_Date__c = 0;
			rmv.Year_To_Date__c = 0;
			if(hasDailyTarget){
				if(reportedValues.containsKey('D')){
					rmv.Reported_Value__c = reportedValues.get('D');
				}
			} else {
				if(reportedValues.containsKey('W')){
					rmv.Reported_Value__c = reportedValues.get('W');
				}
			}
			if(reportedValues.containsKey('W')){
				rmv.Week_To_Date__c = reportedValues.get('W');
			}
			if(reportedValues.containsKey('M')){
				rmv.Month_To_Date__c = reportedValues.get('M');
			}
			if(reportedValues.containsKey('Y')){
				rmv.Year_To_Date__c = reportedValues.get('Y');
			}
		} else if(queryName == 'opportunity conversion rate'){
			if(!reportedValues.containsKey('MC') || !reportedValues.containsKey('MT')){
				rmv.Reported_Value__c = 0;
				rmv.Week_To_Date__c = 0;
				rmv.Month_To_Date__c = 0;
				rmv.Year_To_Date__c = 0;
			} else {
				rmv.Reported_Value__c = 100 * (reportedValues.get('MC') / reportedValues.get('MT'));
				rmv.Week_To_Date__c = rmv.Reported_Value__c;
				rmv.Month_To_Date__c = rmv.Reported_Value__c;
				rmv.Year_To_Date__c = rmv.Reported_Value__c;
			}
		} else if(queryName == 'sales count'){
			rmv.Reported_Value__c = 0;
			rmv.Week_To_Date__c = 0;
			rmv.Month_To_Date__c = 0;
			rmv.Year_To_Date__c = 0;
			if(hasDailyTarget){
				if(reportedValues.containsKey('D')){
					rmv.Reported_Value__c = reportedValues.get('D');
				}
			} else {
				if(reportedValues.containsKey('W')){
					rmv.Reported_Value__c = reportedValues.get('W');
				}
			}
			if(reportedValues.containsKey('W')){
				rmv.Week_To_Date__c = reportedValues.get('W');
			}
			if(reportedValues.containsKey('M')){
				rmv.Month_To_Date__c = reportedValues.get('M');
			}
			if(reportedValues.containsKey('Y')){
				rmv.Year_To_Date__c = reportedValues.get('Y');
			}
		} else if(queryName == 'total referrals count'){
			rmv.Reported_Value__c = 0;
			rmv.Week_To_Date__c = 0;
			rmv.Month_To_Date__c = 0;
			rmv.Year_To_Date__c = 0;
			if(hasDailyTarget){
				if(reportedValues.containsKey('D')){
					rmv.Reported_Value__c = reportedValues.get('D');
				}
			} else {
				if(reportedValues.containsKey('W')){
					rmv.Reported_Value__c = reportedValues.get('W');
				}
			}
			if(reportedValues.containsKey('W')){
				rmv.Week_To_Date__c = reportedValues.get('W');
			}
			if(reportedValues.containsKey('M')){
				rmv.Month_To_Date__c = reportedValues.get('M');
			}
			if(reportedValues.containsKey('Y')){
				rmv.Year_To_Date__c = reportedValues.get('Y');
			}
		} else if(queryName == 'internal referrals count'){
			rmv.Reported_Value__c = 0;
			rmv.Week_To_Date__c = 0;
			rmv.Month_To_Date__c = 0;
			rmv.Year_To_Date__c = 0;
			if(hasDailyTarget){
				if(reportedValues.containsKey('D')){
					rmv.Reported_Value__c = reportedValues.get('D');
				}
			} else {
				if(reportedValues.containsKey('W')){
					rmv.Reported_Value__c = reportedValues.get('W');
				}
			}
			if(reportedValues.containsKey('W')){
				rmv.Week_To_Date__c = reportedValues.get('W');
			}
			if(reportedValues.containsKey('M')){
				rmv.Month_To_Date__c = reportedValues.get('M');
			}
			if(reportedValues.containsKey('Y')){
				rmv.Year_To_Date__c = reportedValues.get('Y');
			}
		} else if(queryName.toLowerCase() == 'sales order backlog'){
			if(reportedValues.containsKey('R')){
				rmv.Reported_Value__c = reportedValues.get('R');
			}
		} else if(queryName.toLowerCase() == 'cancellations'){
			rmv.Reported_Value__c = 0;
			rmv.Week_To_Date__c = 0;
			rmv.Month_To_Date__c = 0;
			rmv.Year_To_Date__c = 0;
			if(hasDailyTarget){
				if(reportedValues.containsKey('D')){
					rmv.Reported_Value__c = reportedValues.get('D');
				}
			} else {
				if(reportedValues.containsKey('W')){
					rmv.Reported_Value__c = reportedValues.get('W');
				}
			}
			if(reportedValues.containsKey('W')){
				rmv.Week_To_Date__c = reportedValues.get('W');
			}
			if(reportedValues.containsKey('M')){
				rmv.Month_To_Date__c = reportedValues.get('M');
			}
			if(reportedValues.containsKey('Y')){
				rmv.Year_To_Date__c = reportedValues.get('Y');
			}
		} else if(queryName.toLowerCase() == 'customer case backlog'){
			if(reportedValues.containsKey('R')){
				rmv.Reported_Value__c = reportedValues.get('R');
			}
		} else if(queryName.toLowerCase() == 'maintenance backlog'){
			if(reportedValues.containsKey('R')){
				rmv.Reported_Value__c = reportedValues.get('R');
			}
		} else if(queryName.toLowerCase() == 'nps'){
			if(!reportedValues.containsKey('YT')){
				rmv.Reported_Value__c = 0;
				rmv.Week_To_Date__c = 0;
				rmv.Month_To_Date__c = 0;
				rmv.Year_To_Date__c = 0;
			} else {
				if(hasDailyTarget){
					if(!reportedValues.containsKey('D9') || !reportedValues.containsKey('D6') || !reportedValues.containsKey('DT')){
						rmv.Reported_Value__c = 0;
					} else {
						rmv.Reported_Value__c = 100 * (reportedValues.get('D9') - reportedValues.get('D6')) / reportedValues.get('DT');
					}
				} else {
					if(!reportedValues.containsKey('W9') || !reportedValues.containsKey('W6') || !reportedValues.containsKey('WT')){
						rmv.Reported_Value__c = 0;
					} else {
						rmv.Reported_Value__c = 100 * (reportedValues.get('W9') - reportedValues.get('W6')) / reportedValues.get('WT');
					}
				}
				if(!reportedValues.containsKey('W9') || !reportedValues.containsKey('W6') || !reportedValues.containsKey('WT')){
					rmv.Week_To_Date__c = 0;
				} else {
					rmv.Week_To_Date__c = 100 * (reportedValues.get('W9') - reportedValues.get('W6')) / reportedValues.get('WT');
				}
				if(!reportedValues.containsKey('M9') || !reportedValues.containsKey('M6') || !reportedValues.containsKey('MT')){
					rmv.Month_To_Date__c = 0;
				} else {
					rmv.Month_To_Date__c = 100 * (reportedValues.get('M9') - reportedValues.get('M6')) / reportedValues.get('MT');
				}
				if(!reportedValues.containsKey('Y9') || !reportedValues.containsKey('Y6') || !reportedValues.containsKey('YT')){
					rmv.Year_To_Date__c = 0;
				} else {
					rmv.Year_To_Date__c = 100 * (reportedValues.get('Y9') - reportedValues.get('Y6')) / reportedValues.get('YT');
				}
			}
		} else if(queryName.toLowerCase() == 'kickoff backlog'){
			if(reportedValues.containsKey('R')){
				rmv.Reported_Value__c = reportedValues.get('R');
			}
		} else if(queryName.toLowerCase() == 'install backlog'){
			if(reportedValues.containsKey('R')){
				rmv.Reported_Value__c = reportedValues.get('R');
			}
		} else if(queryName.toLowerCase() == 'inspection backlog'){
			if(reportedValues.containsKey('R')){
				rmv.Reported_Value__c = reportedValues.get('R');
			}
		} else if(queryName.toLowerCase() == 'inspections count'){
			rmv.Reported_Value__c = 0;
			rmv.Week_To_Date__c = 0;
			rmv.Month_To_Date__c = 0;
			rmv.Year_To_Date__c = 0;
			if(hasDailyTarget){
				if(reportedValues.containsKey('D')){
					rmv.Reported_Value__c = reportedValues.get('D');
				}
			} else {
				if(reportedValues.containsKey('W')){
					rmv.Reported_Value__c = reportedValues.get('W');
				}
			}
			if(reportedValues.containsKey('W')){
				rmv.Week_To_Date__c = reportedValues.get('W');
			}
			if(reportedValues.containsKey('M')){
				rmv.Month_To_Date__c = reportedValues.get('M');
			}
			if(reportedValues.containsKey('Y')){
				rmv.Year_To_Date__c = reportedValues.get('Y');
			}
		} else if(queryName.toLowerCase() == 'capacity inspected'){
			rmv.Reported_Value__c = 0;
			rmv.Week_To_Date__c = 0;
			rmv.Month_To_Date__c = 0;
			rmv.Year_To_Date__c = 0;
			if(hasDailyTarget){
				if(reportedValues.containsKey('D')){
					rmv.Reported_Value__c = reportedValues.get('D');
				}
			} else {
				if(reportedValues.containsKey('W')){
					rmv.Reported_Value__c = reportedValues.get('W');
				}
			}
			if(reportedValues.containsKey('W')){
				rmv.Week_To_Date__c = reportedValues.get('W');
			}
			if(reportedValues.containsKey('M')){
				rmv.Month_To_Date__c = reportedValues.get('M');
			}
			if(reportedValues.containsKey('Y')){
				rmv.Year_To_Date__c = reportedValues.get('Y');
			}
		} else if(queryName.toLowerCase() == 'average system size'){
			if(!reportedValues.containsKey('YC')){
				rmv.Reported_Value__c = 0;
				rmv.Week_To_Date__c = 0;
				rmv.Month_To_Date__c = 0;
				rmv.Year_To_Date__c = 0;
			} else {
				if(hasDailyTarget){
					if(!reportedValues.containsKey('DS') || !reportedValues.containsKey('DC')){
						rmv.Reported_Value__c = 0;
					} else {
						rmv.Reported_Value__c = reportedValues.get('DS') / reportedValues.get('DC');
					}
				} else {
					if(!reportedValues.containsKey('WS') || !reportedValues.containsKey('WC')){
						rmv.Reported_Value__c = 0;
					} else {
						rmv.Reported_Value__c = reportedValues.get('WS') / reportedValues.get('WC');
					}
				}
				if(!reportedValues.containsKey('WS') || !reportedValues.containsKey('WC')){
					rmv.Week_To_Date__c = 0;
				} else {
					rmv.Week_To_Date__c = reportedValues.get('WS') / reportedValues.get('WC');
				}
				if(!reportedValues.containsKey('MS') || !reportedValues.containsKey('MC')){
					rmv.Month_To_Date__c = 0;
				} else {
					rmv.Month_To_Date__c = reportedValues.get('MS') / reportedValues.get('MC');
				}
				if(!reportedValues.containsKey('YS') || !reportedValues.containsKey('YC')){
					rmv.Year_To_Date__c = 0;
				} else {
					rmv.Year_To_Date__c = reportedValues.get('YS') / reportedValues.get('YC');
				}
			}
		} else if(queryName.toLowerCase() == 'median time sale to inspection'){
			if(medianCalculationsMap.containsKey(queryName)){
				system.debug('**SZ: calc map = ' + medianCalculationsMap.get(queryName));
				rmv.Reported_Value__c = 0;
				rmv.Week_To_Date__c = 0;
				rmv.Month_To_Date__c = 0;
				rmv.Year_To_Date__c = 0;
				if(hasDailyTarget){
					if(medianCalculationsMap.get(queryName).containsKey('D')){
						rmv.Reported_Value__c = getMedian(medianCalculationsMap.get(queryName).get('D'));
					}
				} else {
					if(medianCalculationsMap.get(queryName).containsKey('W')){
						rmv.Reported_Value__c = getMedian(medianCalculationsMap.get(queryName).get('W'));
					}
				}
				if(medianCalculationsMap.get(queryName).containsKey('W')){
					rmv.Week_To_Date__c = getMedian(medianCalculationsMap.get(queryName).get('W'));
				}
				if(medianCalculationsMap.get(queryName).containsKey('M')){
					rmv.Month_To_Date__c = getMedian(medianCalculationsMap.get(queryName).get('M'));
				}
				if(medianCalculationsMap.get(queryName).containsKey('Y')){
					rmv.Year_To_Date__c = getMedian(medianCalculationsMap.get(queryName).get('Y'));
				}
			}
		} else if(queryName.toLowerCase() == 'capacity in backlog'){
			rmv.Reported_Value__c = 0;
			rmv.Week_To_Date__c = 0;
			rmv.Month_To_Date__c = 0;
			rmv.Year_To_Date__c = 0;
			if(multiQueryCalculationsMap.containsKey(queryName.toLowerCase())){
				Map<Id, Decimal> salesOrders = multiQueryCalculationsMap.get(queryName.toLowerCase());

				Map<Id, Milestone1_Project__c> milestoneprojectsWithSalesOrders = new Map<Id, Milestone1_Project__c>([SELECT Id, Sales_Order__c FROM Milestone1_Project__c WHERE Sales_Order__c IN :salesOrders.keySet()]);
				Map<Id, PM_Project__c> pmprojectsWithSalesOrders = new Map<Id, PM_Project__c>([SELECT Id, Sales_Order__c FROM PM_Project__c WHERE Sales_Order__c IN :salesOrders.keySet()]);
				Set<Id> salesOrdersWithProjects = new Set<Id>();
				for(Milestone1_Project__c project : milestoneprojectsWithSalesOrders.values()){
					salesOrdersWithProjects.add(project.Sales_Order__c);
				}
				for(PM_Project__c project : pmprojectsWithSalesOrders.values()){
					salesOrdersWithProjects.add(project.Sales_Order__c);
				}

				Decimal salesOrdersWithoutProjectsTotalSystemSize = 0;
				for(Id salesOrder : salesOrders.keySet()){
					if(!salesOrdersWithProjects.contains(salesOrder)){
						salesOrdersWithoutProjectsTotalSystemSize += salesOrders.get(salesOrder);
					}
				}

				Decimal projectTotalSystemSize = 0;
				AggregateResult[] query = [SELECT SUM(Total_System_Size_kW_DC__c) total FROM PM_Project__c WHERE Sales_Order__r.StatusCode__c != 'Canceled' AND Status__c != 'Cancelled' AND Proof_of_Inspection__c = null];
				for(AggregateResult ar : query){
					projectTotalSystemSize += (Decimal)ar.get('total');
				}

				rmv.Reported_Value__c = salesOrdersWithoutProjectsTotalSystemSize + projectTotalSystemSize;
				rmv.Week_To_Date__c = salesOrdersWithoutProjectsTotalSystemSize + projectTotalSystemSize;
				rmv.Month_To_Date__c = salesOrdersWithoutProjectsTotalSystemSize + projectTotalSystemSize;
				rmv.Year_To_Date__c = salesOrdersWithoutProjectsTotalSystemSize + projectTotalSystemSize;
			}
		} else if(queryName.toLowerCase() == 'median time project creation to inspection'){
			// not resolved yet
		} else if(queryName.toLowerCase() == 'operations headcount'){
			if(metricIdToHeadcountMap.containsKey(rmv.Metric__c)){
				rmv.Reported_Value__c = metricIdToHeadcountMap.get(rmv.Metric__c);
				rmv.Week_To_Date__c = rmv.Reported_Value__c;
				rmv.Month_To_Date__c = rmv.Reported_Value__c;
				rmv.Year_To_Date__c = rmv.Reported_Value__c;
			}
		} else if(queryName.toLowerCase() == 'sales consultant headcount'){
			if(metricIdToHeadcountMap.containsKey(rmv.Metric__c)){
				rmv.Reported_Value__c = metricIdToHeadcountMap.get(rmv.Metric__c);
				rmv.Week_To_Date__c = rmv.Reported_Value__c;
				rmv.Month_To_Date__c = rmv.Reported_Value__c;
				rmv.Year_To_Date__c = rmv.Reported_Value__c;
			}
		}
	}
}