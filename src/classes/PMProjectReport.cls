/* FILE: PMProjectReport.cls
 * AUTHOR: Pavitra Burla
 * DATE: Dec 30, 2015
 * PURPOSE: Controller for PMProjectReport page
 */
public class PMProjectReport {

    public String propertyType {get; set;}
    public Date startDate {get; set;}
    public Date endDate {get; set;}
    public Integer startRange {get; set;}
    public Integer endRange {get; set;}
    public String proofOfInspection {get; set;}
    transient public List<CustomReport> reportListHelper{get;set;}

    public PMProjectReport(){
        if(endRange == null){
            endRange = 100;
        }
        if(startRange == null){
            startRange = 0;
        }
        if(String.isBlank(proofOfInspection)){
            proofOfInspection = 'No';
        }
    }

    public Pagereference generateReport(){
        getRecords();
        return null;
    }
    
    public Pagereference exportToExcel(){
        Pagereference pr = new Pagereference('/apex/PMProjectExcelReport');
        getRecords();
        return pr;
    }

    public static List<SelectOption> getPropertyTypes(){
        List<SelectOption> options = new List<SelectOption>();

        Map<String, Schema.RecordTypeInfo> resultMap = Schema.SObjectType.Property__c.getRecordTypeInfosByName();
        options.add(new SelectOption('None','-- Select --'));
        for(String option:resultMap.keySet()){
            options.add(new SelectOption(option,option));
        }
        return options;
    }
    
    public class CustomReport{
        //Sales Order
        public SCRB_SalesOrder__c salesorder{get; private set;}        
        
        //Sales Invoice
        public Decimal salesInvoiceTotal {get; private set;}        

        public Decimal actualLabor {get;set;}
        public Decimal estimatedLabor {get;set;}
        public Decimal actualMaterial {get;set;}
        public Decimal estimatedMaterial {get;set;}
        public Decimal actualOther {get;set;}
        public Decimal estOther {get;set;}
        public Decimal percCompl {get;set;}

        public String projCreationDate {get;set;}
        public String opportunityCloseDate {get;set;}
        public String installDate {get;set;}
        public String workComplete {get;set;}
        public String proofOfInspection {get;set;}
        public String inspectionVerified {get;set;}
        
        public CustomReport(SCRB_SalesOrder__c salesorder){
            this.salesorder = salesorder;
            this.actualOther = 0.00;
            this.estOther = 0.00;
            this.percCompl = 0.00;
            this.actualLabor = 0.00;
            this.estimatedLabor = 0.00;
            this.actualMaterial = 0.00;
            this.estimatedMaterial = 0.00;
            this.salesInvoiceTotal = 0.00;
        }           
    }
    
    public void getRecords(){

        Map<Id,CustomReport> reportMap = new Map<Id,CustomReport>();
        Map<String,SCRB_SalesOrder__c> jobOrdersMap = new Map<String,SCRB_SalesOrder__c>();
        Date queryenddate;
        
        System.debug('***start date:' + startDate);
        System.debug('***end date:' + endDate);
        System.debug('***start range:' + startRange);
        System.debug('***end range:' + endRange);
        System.debug('***propertytype:' + propertyType);
        
        String query = 'SELECT Name';
        query+= ', CreatedDate';
        query+= ', Job_Id__c';
        query+= ', Property__r.Astrum_Office_New__r.Rootstock_Division__c';
        query+= ', Opportunity_Close_Date__c';
        query+= ', StatusCode__c';
        query+= ', Financing_Option__c';
        query+= ', System_Makeup__c';
        query+= ', System_Size_kW__c';
        query+= ', Property__r.Astrum_Office_New__r.Name'; 
        query+= ', Amount__c';
        query+= ', Property__r.RecordType.Name';
        query+= ', Financing_Type__c';
        query+= ', (SELECT Name';
        query+= '    , CreatedDate';
        query+= '    , Work_Completed__c';
        query+= '    , Install__c';        
        query+= '    , Proof_of_Inspection__c';
        query+= '    , Inspection_Verified__c'; 
        query+= '    FROM PM_Projects__r';

        if(proofOfInspection.equalsIgnoreCase('Yes')){
            query+= ' WHERE Proof_of_Inspection__c <> null)';
        }else{
            query+= ' WHERE Proof_of_Inspection__c = null)';
        }

        query+= ' FROM SCRB_SalesOrder__c';

        if(propertyType != 'None'){
            query+= ' WHERE Property__r.RecordType.Name =:propertyType';
            if(startDate != null){
                query+= ' AND CreatedDate >= :startDate';
            }
            if(endDate != null){
                queryenddate = endDate.addDays(1);                
                query+= ' AND CreatedDate < :queryenddate';
            }                        
        }else if(startDate != null){
            query+= ' WHERE CreatedDate >= :startDate';
            if(endDate != null){
                queryenddate = endDate.addDays(1);                
                query+= ' AND CreatedDate < :queryenddate';
            }
        }else if(endDate != null){
            queryenddate = endDate.addDays(1);                
            query+= ' WHERE CreatedDate < :queryenddate';
        } 

        query+= ' ORDER BY Job_Id__c DESC';
        if(Test.isRunningTest()){
            //query+= ' LIMIT 1';
        }
        System.debug(loggingLevel.ERROR,'***query:' + query);

        Map<Id,SCRB_SalesOrder__c> salesorderMap 
            = new Map<Id,SCRB_SalesOrder__c>((List<SCRB_SalesOrder__c>)Database.query(query));             
       
        //PM Projs
        for(SCRB_SalesOrder__c so:salesorderMap.values()){
            /*jobOrdersMap.put(so.Job_Id__c,so);
            reportMap.put(so.Id, new CustomReport(so));
            CustomReport report = reportMap.get(so.Id);
            if(so.Opportunity_Close_Date__c != null){
                report.opportunityCloseDate = so.Opportunity_Close_Date__c.format();
            }*/
            if(so.PM_Projects__r != null && so.PM_Projects__r.size() > 0){
                jobOrdersMap.put(so.Job_Id__c,so);
                reportMap.put(so.Id, new CustomReport(so));
                CustomReport report = reportMap.get(so.Id);
                if(so.Opportunity_Close_Date__c != null){
                    report.opportunityCloseDate = so.Opportunity_Close_Date__c.format();
                }

                report.projCreationDate = (so.PM_Projects__r[0].CreatedDate.format('MM/dd/YYYY'));                
                if(so.PM_Projects__r[0].Install__c != null){
                    report.installDate = so.PM_Projects__r[0].Install__c.format();
                }        
                if(so.PM_Projects__r[0].Work_Completed__c != null){
                    report.workComplete = so.PM_Projects__r[0].Work_Completed__c.format();
                }
                if(so.PM_Projects__r[0].Proof_of_Inspection__c != null){
                    report.proofOfInspection = so.PM_Projects__r[0].Proof_of_Inspection__c.format();
                }
                if(so.PM_Projects__r[0].Inspection_Verified__c != null){
                    report.inspectionVerified = so.PM_Projects__r[0].Inspection_Verified__c.format();
                }
            }        
        }
        
        //Invoices
        List<AggregateResult> invoices = [SELECT  Sales_Order__c, SUM(c2g__NetTotal__c) netTotal FROM c2g__codaInvoice__c WHERE Sales_Order__c IN:reportMap.keySet() GROUP BY Sales_Order__c];
        
        if(invoices!= null){
            for(AggregateResult result:invoices){
                reportMap.get((Id)result.get('Sales_Order__c')).salesInvoiceTotal = ((Decimal)result.get('netTotal')).setScale(2); 
            }
        }
        
        //ProjCst
        List<rstk__pjproj__c> projMasters = new List<rstk__pjproj__c>(); 
                
        projMasters = [SELECT Id,rstk__pjproj_div__c,rstk__pjproj_proj__c
                       , (SELECT rstk__pjprojcst_costs_subtot__c
                          , rstk__pjprojcst_budget_subtot__c
                          , rstk__pjprojcst_cstlab__c
                          , rstk__pjprojcst_cstmtl__c
                          , rstk__pjprojcst_baclab__c
                          , rstk__pjprojcst_bacmtl__c
                          FROM rstk__pjprojcsts__r)
                       FROM rstk__pjproj__c 
                       WHERE  rstk__pjproj_proj__c IN :jobOrdersMap.keySet()
                       AND rstk__pjproj_proj__c <> NULL];
        
        Decimal percentComplete = 0.00;
                 
        for(rstk__pjproj__c projMaster:projMasters){
            
            if( projMaster.rstk__pjproj_div__c  == jobOrdersMap.get(projMaster.rstk__pjproj_proj__c.capitalize()).Property__r.Astrum_Office_New__r.Rootstock_Division__c){
                 CustomReport report = reportMap.get(jobOrdersMap.get(projMaster.rstk__pjproj_proj__c.capitalize()).Id);
                 rstk__pjprojcst__c projCost = projMaster.rstk__pjprojcsts__r[0];
                 report.actualOther = (projCost.rstk__pjprojcst_costs_subtot__c - projCost.rstk__pjprojcst_cstlab__c - projCost.rstk__pjprojcst_cstmtl__c).setScale(2) ;
                 report.estOther = (projCost.rstk__pjprojcst_budget_subtot__c - projCost.rstk__pjprojcst_baclab__c - projCost.rstk__pjprojcst_bacmtl__c).setScale(2);
                 if(projCost.rstk__pjprojcst_budget_subtot__c != 0){                    
                    percentComplete = ((projCost.rstk__pjprojcst_costs_subtot__c)/ 
                        (projCost.rstk__pjprojcst_budget_subtot__c)) * 100;
                    report.percCompl = percentComplete<100?percentComplete.setScale(2):100;
                 }
                 report.actualLabor = projCost.rstk__pjprojcst_cstlab__c.setScale(2);
                 report.estimatedLabor = projCost.rstk__pjprojcst_baclab__c.setScale(2);
                 report.actualMaterial = projCost.rstk__pjprojcst_cstmtl__c.setScale(2);
                 report.estimatedMaterial = projCost.rstk__pjprojcst_bacmtl__c.setScale(2);
            }
        }

        //filter based on percent complete
        if(startRange!= null && endRange!=null){
            List<CustomReport> reportBasedOnPercCompl = new List<CustomReport>();        
            for(CustomReport report :reportMap.values()){
                if(report.percCompl >= startRange && report.percCompl <= endRange){
                    //System.debug('**perc compl' + report.percCompl + ':' + report.salesorder.Name);
                    reportBasedOnPercCompl.add(report);
                }
            }
            reportListHelper = reportBasedOnPercCompl;
            System.debug(reportListHelper.size());
            return;
        }
              
        reportListHelper = reportMap.values();
        System.debug(reportListHelper.size());
    }
}