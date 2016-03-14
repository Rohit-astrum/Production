/* FILE: ProjectCostBudgetBatch.cls
 * AUTHOR: Pavitra Burla
 * DATE: Aug 27, 2015
 * PURPOSE: Simulate running the Cost projection process without updating the data and get results.
 * MODIFICATION HISTORY
 */
global class ProjectCostBudgetBatch implements Database.Batchable<sObject>, Database.Stateful{
            
    public String query;
    public String batchErrors = '';
    private Integer batchNumber = 0;
    public String datastr;
    public final String startDate;
	public final String endDate;
	public final String[] emailstr;
    
    global ProjectCostBudgetBatch(String startDate, String endDate, String[] emailStr){
        this.startDate = startDate;
        this.endDate = endDate;
        this.emailstr = emailstr;        
    }    
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        datastr = 'PM Proj Id, Labor Cost , Mat Cost, Overhead Cost \n';
        query ='SELECT Id, Name, Sales_Order__c';
        query += ' FROM PM_Project__c';
        query += ' WHERE CreatedDate > ' + startDate + ' AND CreatedDate <' + endDate;
        query += ' AND Work_Order__c!=NULL'; 
        query += ' AND Sales_Order__r.StatusCode__c <> \'Canceled\'';
        query += ' ORDER BY Sales_Order__r.Job_Id__c,CreatedDate';
        
        if(Test.isRunningTest()){
            query+=' LIMIT 1';
        }
        System.debug(loggingLevel.ERROR,query); 
        return Database.getQueryLocator(query);        
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        
        List<PM_Project__c> pmprojs = new List<PM_Project__c>();
        
        for(sObject s : scope){            
            PM_Project__c proj = (PM_Project__c)s;
            pmprojs.add(proj);            
        }
        
        SCRB_SalesOrder__c salesOrder = [SELECT Property__r.Astrum_Office_New__r.Rootstock_Division__c, Job_Id__c
                                 ,System_Design_Quote__r.System_Design__c, Property__r.Property_State__c
                                 , Property__r.Property_County__c, Property__r.QAS_Property_County__c
                                 , Amount__c  
                                 FROM SCRB_SalesOrder__c 
                                 WHERE Id=:pmprojs[0].Sales_Order__c];
        
        List<rstk__pjproj__c> projMasters = new List<rstk__pjproj__c>(); 
		
		projMasters = [SELECT Id, (SELECT Id 
	                        FROM rstk__pjprojcsts__r)
	                     FROM rstk__pjproj__c 
	                     WHERE rstk__pjproj_div__c =:salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c 
	                     AND rstk__pjproj_proj__c = :salesOrder.Job_Id__c];
		
		if(projMasters.size() >0){
			rstk__pjproj__c projMaster = projMasters[0];
			rstk__pjprojcst__c projCst = projMaster.rstk__pjprojcsts__r[0];
			projCst.rstk__pjprojcst_baclab__c = CostProjectionProcessor.getLaborCostProjection(salesOrder);
		    projCst.rstk__pjprojcst_bacmtl__c = CostProjectionProcessor.getMatlCostProjection(salesOrder,pmprojs[0],false);		    
		    projCst.rstk__pjprojcst_bacmodc__c= CostProjectionProcessor.getOverheadProjection(salesOrder);

		    projCst.rstk__pjprojcst_budprodrevenue__c = salesOrder.Amount__c;
		    datastr+= pmprojs[0].Id + ',' + projCst.rstk__pjprojcst_baclab__c + ',' + projCst.rstk__pjprojcst_bacmtl__c + ',' + projCst.rstk__pjprojcst_bacmodc__c +'\n';   

		}
        
        
        
    }
    
    global void finish(Database.BatchableContext bc){
        
        ///Email        
        String datestr = ' Between ' +  startDate.substringBefore(' ') + ' and ' + endDate.substringBefore(' ');
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(datastr);
        string csvname= 'PMprojCost.csv';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        String[] toAddresses = emailstr;
        String subject ='PMprojCost CSV' + datestr;
        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody('PMprojCost CSV' + datestr);
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        
    }    
}