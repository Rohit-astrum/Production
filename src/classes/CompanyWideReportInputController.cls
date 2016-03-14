public with sharing class CompanyWideReportInputController {

    public Company_Wide_Report__c companyWideReport {get;private set;}
    public List<ReportedMetricValueWrapper> reportedMetricValues {get;private set;}
    public Boolean previewReport {get;set;}
    public Integer rowToDelete {get;set;}

    public List<SelectOption> years {get;private set;}
    public Integer selectedYear {get;set;}
    public List<SelectOption> periods {get;private set;}
    public String selectedPeriod {get;set;}

    private List<SelectOption> metricOptions {get;private set;}

    public CompanyWideReportInputController() {
        system.debug('**SZ: (constructor) reportedMetricValues = ' + reportedMetricValues);
        this.previewReport = false;

        this.years = new List<SelectOption>();
        this.years.add(new SelectOption(String.valueOf(Date.today().year() - 1), String.valueOf(Date.today().year() - 1)));
        this.years.add(new SelectOption(String.valueOf(Date.today().year()), String.valueOf(Date.today().year())));
        this.selectedYear = Date.today().year();

        this.periods = new List<SelectOption>();
        this.periods.add(new SelectOption('', ''));
        this.periods.add(new SelectOption('1', 'DEC16-JAN15'));
        this.periods.add(new SelectOption('2', 'JAN16-FEB15'));
        this.periods.add(new SelectOption('3', 'FEB16-MAR15'));
        this.periods.add(new SelectOption('4', 'MAR16-APR15'));
        this.periods.add(new SelectOption('5', 'APR16-MAY15'));
        this.periods.add(new SelectOption('6', 'MAY16-JUN15'));
        this.periods.add(new SelectOption('7', 'JUN16-JUL15'));
        this.periods.add(new SelectOption('8', 'JUL16-AUG15'));
        this.periods.add(new SelectOption('9', 'AUG16-SEP15'));
        this.periods.add(new SelectOption('10', 'SEP16-OCT15'));
        this.periods.add(new SelectOption('11', 'OCT16-NOV15'));
        this.periods.add(new SelectOption('12', 'NOV16-DEC15'));

        this.metricOptions = new List<SelectOption>();
        this.metricOptions.add(new SelectOption('', ''));
        List<Metric__c> metrics = [SELECT Id, Name FROM Metric__c WHERE Reporting_Frequency__c INCLUDES ('Monthly') AND Include_On_Report__c = true AND Is_Calculated__c = false ORDER BY Display_Order__c];
        for(Metric__c metric : metrics){
            this.metricOptions.add(new SelectOption(metric.Id, metric.Name));
        }

        if(reportedMetricValues == null){
            reportedMetricValues = new List<ReportedMetricValueWrapper>();
        }
    }

    private Date ReportingPeriodEndDate(){
        if(this.selectedYear != null && this.selectedPeriod != null){
            return Date.newInstance(this.selectedYear, Integer.valueOf(this.selectedPeriod), 15);
        } else {
            return null;
        }
    }

    public PageReference load(){
        if(previewReport){ previewReport = false; }
        reportedMetricValues = new List<ReportedMetricValueWrapper>();

        if(ReportingPeriodEndDate() != null){
            List<Company_Wide_Report__c> cwrList = [SELECT Id, Reporting_Frequency__c, End_Date__c, Ready_To_Send__c FROM Company_Wide_Report__c WHERE Reporting_Frequency__c = 'Monthly' AND End_Date__c = :ReportingPeriodEndDate() LIMIT 1];
            if(cwrList.size() == 1){
                companyWideReport = cwrList[0];
                List<Reported_Metric_Value__c> rmvList = [SELECT Id, Company_Wide_Report__c, Metric__c, Reported_Value__c, Delta__c, Headcount__c, Week_To_Date__c, Month_To_Date__c, Year_To_Date__c FROM Reported_Metric_Value__c WHERE Company_Wide_Report__c = :companyWideReport.Id AND Metric__r.Is_Calculated__c = false];
                for(Reported_Metric_Value__c rmv : rmvList){
                    reportedMetricValues.add(new ReportedMetricValueWrapper(rmv, metricOptions, rmv.Metric__c));
                }
            } else {
                companyWideReport = new Company_Wide_Report__c(Reporting_Frequency__c = 'Monthly', End_Date__c = ReportingPeriodEndDate());
                reportedMetricValues = new List<ReportedMetricValueWrapper>();
            }
        }
        return null;
    }

    public PageReference newRMV(){
        if(previewReport){ previewReport = false; }

        //if(reportedMetricValues == null){
        //    reportedMetricValues = new List<ReportedMetricValueWrapper>();
        //}
        system.debug('**SZ: reportedMetricValues = ' + reportedMetricValues);
        reportedMetricValues.add(new ReportedMetricValueWrapper(new Reported_Metric_Value__c(), metricOptions, null));

        return null;
    }

    public PageReference preview(){
        previewReport = true;
        return null;
    }

    public PageReference save(){
        upsert companyWideReport;
        system.debug('**SZ: reportedMetricValues = ' + reportedMetricValues);
        List<Reported_Metric_Value__c> rmvList = new List<Reported_Metric_Value__c>();
        for(ReportedMetricValueWrapper rmv : reportedMetricValues){
            if (rmv.reportedMetricValue.Company_Wide_Report__c == null){
                rmv.reportedMetricValue.Company_Wide_Report__c = companyWideReport.Id;
            }
            rmv.reportedMetricValue.Metric__c = rmv.selectedValue;
            rmvList.add(rmv.reportedMetricValue);
        }
        upsert rmvList;
        previewReport = true;
        
        return null;
    }

    public PageReference saveAndPreview(){
        CompanyWideReportCalculator.processMonthly(companyWideReport.End_Date__c);
        companyWideReport = [SELECT Id, Reporting_Frequency__c, End_Date__c, Ready_To_Send__c FROM Company_Wide_Report__c WHERE Reporting_Frequency__c = 'Monthly' AND End_Date__c = :companyWideReport.End_Date__c];
        save();
        previewReport = true;
        
        return null;
    }

    public PageReference send(){
        PageReference reference = saveAndPreview();

        companyWideReport.Ready_To_Send__c = true;
        update companyWideReport;

        return null;
    }

    public PageReference deleteRow(){
        if(previewReport){ previewReport = false; }

        reportedMetricValues.remove(rowToDelete);
        return null;
    }

    public class ReportedMetricValueWrapper {
        public Reported_Metric_Value__c reportedMetricValue {get;set;}
        public List<SelectOption> metricOptions {get;set;}
        public String selectedValue {get;set;}

        public ReportedMetricValueWrapper(Reported_Metric_Value__c rmv, List<SelectOption> options, Id metricId){
            this.reportedMetricValue = rmv;
            this.metricOptions = options;
            this.selectedValue = metricId;
        }
    }
}