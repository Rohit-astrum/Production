/* FILE: CompanyWideReportController.cls
 * AUTHOR: Steve Zilligen
 * DATE: May 5, 2015
 * PURPOSE: Class to display the data for the Company Wide Report
 */
public with sharing class CompanyWideReportController {

  public String reportType {
    get { return reportType; }
    set{
      reportType = value;
      init();
    }
  }
  public Date reportEndDate {get;set;}
  public Boolean managementFlag {get;set;}

  public Company_Wide_Report__c cwr {get;set;}
  public List<Metric__c> metrics {get;set;}
  public List<Metric__c> metricsWithTargets {get;set;}
  public List<Metric__c> metricsWithoutTargets {get;set;}
  public Map<Id, Metric_Target_Goal__c> metricTargets {get;set;}
  public Map<Id, Reported_Metric_Value__c> metricValues {get;set;}

  private String serverUrl {
    get {
      if(serverUrl == null){
        String sUrlRewrite = System.URL.getSalesforceBaseUrl().getHost();
          String sfBaseProtocol = System.URL.getSalesforceBaseUrl().getProtocol();
          System.debug(LoggingLevel.INFO, 'getHost: ' + sUrlRewrite);
          System.debug(LoggingLevel.INFO, 'getProtocol: ' + sfBaseProtocol);

          //remove namespace
          if(!sUrlRewrite.contains('salesforce')) {
            integer firstDotPos = sUrlRewrite.indexOf('.');
            sURlRewrite = sURlRewrite.substring(firstDotPos+1);

            //replace visual.force with salesforce
            sURlRewrite = sURlRewrite.replace('visual.force', 'salesforce');
        }
          sUrlRewrite = sfBaseProtocol+'://'+sURlRewrite;
        serverURL = sUrlRewrite;
      }
      return serverURL;
    }
    set;
  }

  public Map<String, String> documentUrls {
    get{
      if (documentUrls == null){
        Map<String, String> urls = new Map<String, String>();
        List<Document> documents = [SELECT Id, Name FROM Document WHERE Name IN ('ArrowLine', 'ChartLegend1', 'ChartLegend2', 'DailyReportLogo', 'DownArrowIcon', 'DownArrowIconRed', 'EmployeeIcon', 'LeaderboardNum1', 'LeaderboardNum2', 'LeaderboardNum3', 'LeaderboardNum4', 'LeaderboardNum5', 'MonthlyReportLogo', 'UpArrowIcon', 'UpArrowIconGreen', 'WeeklyReportLogo')];
        for(Document doc : documents){
          urls.put(doc.Name, serverUrl + '/servlet/servlet.ImageServer?id=' + doc.Id + '&oid=' + UserInfo.getOrganizationId());
        }
        documentUrls = urls;
      }
      return documentUrls;
    }
    set;
  }

  public Map<Id, String> chartUrls {get;set;}

  public CompanyWideReportController() {
    managementFlag = false;
    metricsWithTargets = new List<Metric__c>();
    metricsWithoutTargets = new List<Metric__c>();
    metricValues = new Map<Id, Reported_Metric_Value__c>();
  }

  private void init(){
    List<Company_Wide_Report__c> cwrList;
    if(reportEndDate != null){
      cwrList = [SELECT Id, End_Date__c FROM Company_Wide_Report__c WHERE Reporting_Frequency__c = :reportType AND End_Date__c = :reportEndDate LIMIT 1];
    } else {
      if(reportType == 'Daily'){
        cwrList = [SELECT Id, End_Date__c FROM Company_Wide_Report__c WHERE Reporting_Frequency__c = :reportType AND End_Date__c = YESTERDAY LIMIT 1];
      } else if (reportType == 'Weekly'){
        // Need to fix this calculation for display on a sunday, currently does not show last weeks report
        Date sunday = Date.today().addDays(-1).toStartOfWeek();
        cwrList = [SELECT Id, End_Date__c FROM Company_Wide_Report__c WHERE Reporting_Frequency__c = :reportType AND End_Date__c = :sunday LIMIT 1];
      }
    }

    if(cwrList == null){
      return;
    } else if(cwrList.size() > 0){
      cwr = cwrList[0];
    }

    if(cwr != null){
      //metrics = [SELECT Id, Name, Headcount_Profiles__c, Headcount_Profiles_Label__c, Calculate_Delta__c, Delta_Object_Name__c, Positive_Indicator__c FROM Metric__c WHERE Id IN :metricIdsWithValues AND (Management_Only__c = false OR Management_Only__c = :managementFlag) ORDER BY Display_Order__c];
      metrics = [SELECT Id, Name, Headcount_Profiles__c, Headcount_Profiles_Label__c, Calculate_Delta__c, Delta_Object_Name__c, Positive_Indicator__c, Is_Calculated__c FROM Metric__c WHERE Include_On_Report__c = true AND Reporting_Frequency__c INCLUDES (:reportType) AND (Management_Only__c = false OR Management_Only__c = :managementFlag) ORDER BY Display_Order__c];
      Map<Id, Metric__c> metricsMap = new Map<Id, Metric__c>(metrics);
      Set<Id> metricIds = new Set<Id>();
      for(Metric__c metric : metrics){
        if(!metricIds.contains(metric.Id)){
          metricIds.add(metric.Id);
        }
      }

      metricTargets = new Map<Id, Metric_Target_Goal__c>();
      //Map<Id, Metric_Target_Goal__c> metricTargetsMap = new Map<Id, Metric_Target_Goal__c>([SELECT Id, Name, Metric__c, Daily_Target__c, Weekly_Target__c, Monthly_Target__c, Annual_Target__c FROM Metric_Target_Goal__c WHERE Metric__c IN :metricIds AND Is_Active__c = true]);
      Map<Id, Metric_Target_Goal__c> metricTargetsMap = new Map<Id, Metric_Target_Goal__c>([SELECT Id, Name, Metric__c, Daily_Target__c, Weekly_Target__c, Monthly_Target__c, Annual_Target__c FROM Metric_Target_Goal__c WHERE Metric__c IN :metricIds AND Effective_From__c <= :cwr.End_Date__c AND Effective_To__c >= :cwr.End_Date__c]);
      for(Metric_Target_Goal__c mtg : metricTargetsMap.values()){
        if(!metricTargets.containsKey(mtg.Metric__c)){
          metricTargets.put(mtg.Metric__c, mtg);
        }
      }

      metricsWithTargets = new List<Metric__c>();
      for(Metric__c metric : metrics){
        if(metricTargets.containsKey(metric.Id)){
          metricsWithTargets.add(metric);
        }
      }

      metricsWithoutTargets = new List<Metric__c>();
      for(Metric__c metric : metrics){
        if(!metricTargets.containsKey(metric.Id)){
          metricsWithoutTargets.add(metric);
        }
      }

      metricValues = new Map<Id, Reported_Metric_Value__c>();
      Map<Id, Reported_Metric_Value__c> metricValuesMap = new Map<Id, Reported_Metric_Value__c>([SELECT Id, Company_Wide_Report__c, Metric__c, Reported_Value__c, Headcount__c, Delta__c, Week_To_Date__c, Month_To_Date__c, Year_To_Date__c FROM Reported_Metric_Value__c WHERE Company_Wide_Report__c = :cwr.Id]);
      for(Reported_Metric_Value__c rmv : metricValuesMap.values()){
        if(!metricValues.containsKey(rmv.Metric__c) && metricsMap.containsKey(rmv.Metric__c)){
          if(!metricTargets.containsKey(rmv.Metric__c) && rmv.Headcount__c == null){
            system.debug('**SZ: rmv.Metric__c = ' + rmv.Metric__c);
            if(metricsMap.get(rmv.Metric__c).Is_Calculated__c){
              rmv.Headcount__c = -1;
            } else {
              rmv.Headcount__c = 0;
            }
          }
          metricValues.put(rmv.Metric__c, rmv);
        }
      }

      for(Metric__c metric : metrics){
        if(!metricValues.containsKey(metric.Id)){
          metricValues.put(metric.Id, new Reported_Metric_Value__c(Headcount__c = -1));
        }
      }

      chartUrls = new Map<Id, String>();
      for(Id metricId : metricTargets.keySet()){
        chartUrls.put(metricId, CreateChartUrl(metricValues.get(metricId), metricTargets.get(metricId)));
      }
    }
  }

  private String CreateChartUrl(Reported_Metric_Value__c rmv, Metric_Target_Goal__c mtg){
    List<String> labels = new List<String>();
    List<String> goals = new List<String>();
    List<String> values = new List<String>();

    if(mtg.Daily_Target__c == null && mtg.Weekly_Target__c == null && mtg.Monthly_Target__c == null){
      return '#';
    }

    if(mtg.Daily_Target__c != null && reportType != 'Monthly'){
      labels.add('Yesterday');
      labels.add('Last 7 Days');
      labels.add('This Period');
      goals.add(String.valueOf(mtg.Daily_Target__c));
      goals.add(String.valueOf(mtg.Weekly_Target__c));
      goals.add(String.valueOf(mtg.Monthly_Target__c));
      values.add(String.valueOf(rmv.Reported_Value__c));
      values.add(String.valueOf(rmv.Week_To_Date__c));
      values.add(String.valueOf(rmv.Month_To_Date__c));
    } else if(mtg.Weekly_Target__c != null && reportType != 'Monthly'){
      if(rmv.Month_To_Date__c == null){
        labels.add('Last 7 Days');
        goals.add(String.valueOf(mtg.Weekly_Target__c));
        values.add(String.valueOf(rmv.Reported_Value__c));
      } else {
        labels.add('Last 7 Days');
        labels.add('This Period');
        goals.add(String.valueOf(mtg.Weekly_Target__c));
        goals.add(String.valueOf(mtg.Monthly_Target__c));
        values.add(String.valueOf(rmv.Reported_Value__c));
        values.add(String.valueOf(rmv.Month_To_Date__c));
      }
    } else if(mtg.Monthly_Target__c != null){
      labels.add('This Period');
      goals.add(String.valueOf(mtg.Monthly_Target__c));
      values.add(String.valueOf(rmv.Month_To_Date__c));
    }
    if(mtg.Annual_Target__c != null){
      labels.add('Year to Date');
      goals.add(String.valueOf(mtg.Annual_Target__c));
      values.add(String.valueOf(rmv.Year_To_Date__c));
    }

    double min = 0;
    double max = 0;
    List<Decimal> numbers = new List<Decimal>();
    if(mtg.Daily_Target__c != null){ numbers.add(mtg.Daily_Target__c); }
    if(mtg.Weekly_Target__c != null){ numbers.add(mtg.Weekly_Target__c); }
    if(mtg.Monthly_Target__c != null){ numbers.add(mtg.Monthly_Target__c); }
    if(mtg.Annual_Target__c != null){ numbers.add(mtg.Annual_Target__c); }
    if(rmv.Reported_Value__c != null){ numbers.add(rmv.Reported_Value__c); }
    if(rmv.Week_To_Date__c != null){ numbers.add(rmv.Week_To_Date__c); }
    if(rmv.Month_To_Date__c != null){ numbers.add(rmv.Month_To_Date__c); }
    if(rmv.Year_To_Date__c != null){ numbers.add(rmv.Year_To_Date__c); }
    numbers.sort();

    min = 0.0;
    if(numbers[0] >=0){
      min = 0.9 * numbers[0];
    } else {
      min = 1.1 * numbers[0];
    }

    max = 0.0;
    if(numbers[numbers.size() - 1] >=0){
      max = 1.1 * numbers[numbers.size() - 1];
    } else {
      max = 0.9 * numbers[numbers.size() - 1];
    }
system.debug('**SZ: metricId = ' + mtg.Metric__c);
system.debug('**SZ: numbers = ' + numbers);
system.debug('**SZ: min = ' + min);
system.debug('**SZ: max = ' + max);

    Decimal preliminaryStep = Math.abs((max - min) / Decimal.valueOf(12));
    system.debug('**SZ: preliminaryStep = ' + preliminaryStep.toPlainString());
    Decimal multiplier = 1;
    if(preliminaryStep >= 1){
      multiplier = Decimal.valueOf(10).pow(preliminaryStep.precision() - preliminaryStep.scale() - 1);
    }
    system.debug('**SZ: multiplier = ' + multiplier.toPlainString());
    Decimal step = multiplier * preliminaryStep;
    if(preliminaryStep > 1){
      step = multiplier * Decimal.valueOf(preliminaryStep.toPlainString().substring(0, 1));
    }
    if(step != 0 && Math.abs((max - min) / step) > 15){
        step = multiplier * (Decimal.valueOf(preliminaryStep.toPlainString().substring(0, 1)) + 1);
    }

system.debug('**SZ: labels = ' + labels);
system.debug('**SZ: values = ' + values);
    String width = '90';
    if (labels.size() == 4){
      width = '30';
    } else if (labels.size() == 2){
      width = '190';
    } else if (labels.size() == 1){
      width = '490';
    }

    return 'http://chart.apis.google.com/chart?chs=600x300&amp;cht=bvg'
        + '&amp;chxt=y'
        + '&amp;chm=N*f2*,666666,0,-1,11|N*f2*,666666,1,-1,11'
        + '&amp;chl=' + String.join(labels, '|')
        + '&amp;chxr=0,' + String.valueOf(min) + ',' + String.valueOf(max) + ',' + String.valueOf(step)
        + '&amp;chds=' + String.valueOf(min) + ',' + String.valueOf(max)
        + '&amp;chd=t:' + String.join(values, ',') + '|' + String.join(goals, ',')
        + '&amp;chco=e45206,f4ba9b'
        + '&amp;chbh=50,0,' + width;
  }
}