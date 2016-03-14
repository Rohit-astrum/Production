/* FILE: ProjectDetailGridController.cls
 * AUTHOR: Tino Mattheou
 * DATE: April 20, 2012
 * PURPOSE: Controller for ProjectDetailGrid component
 * MODIFICATION HISTORY
 *     RJ - 09/04/13 - Added NRG Only Bin Alert
 *     DK - 12/07/14 - Made all Remote Action methods global to fix Salesforce Console errors
 */
 
global class ProjectDetailGridController {

    public String projectId { 
        get; 
        set {
            if (projectId != value && value != null) {
                projectId = value;
                //loadProject();
            }
        } 
    }
    
    public static List<Bin_Configuration__c> binConfig { 
        get { 
            if (binConfig == null) {
                binConfig = DocumentConfigurationHelper.getBins(DocumentConfigurationHelper.APP_ASTRUM_PM_20);
            }
            return binConfig;
        }
        private set;
    }
    
    public static List<DocumentConfigurationHelper.SpecialCategory> specialCategories {
        get {
            if (specialCategories == null) {
                specialCategories = DocumentConfigurationHelper.getSpecialCategories(DocumentConfigurationHelper.APP_ASTRUM_PM_20);
            }
            return specialCategories;       
        }
        private set;
    }
    
    @RemoteAction
    global static void setProjectDate(Id projectId, String dateField, String projectDate) {  //date needs to be in mm/dd/yyyy format
        PM_Project__c project = new PM_Project__c ( Id = projectId );
        if (projectDate == null || projectDate.trim().length() == 0) {
            project.put(dateField, null);
        } else {
            //datetime passed as long value in GMT
            if (dateField == 'Kickoff__c' || dateField == 'Inspection__c' || dateField == 'Survey_Date__c') {
                project.put(dateField, DateTime.newInstance(Long.valueOf(projectDate)));
            } else { //date passed as MM/DD/YYYY
                project.put(dateField, Date.parse(projectDate));
            }
        }
        update project;
    }
    
    //set the customer action note/resolution flag
    @RemoteAction
    global static void updateCustomerAction(Id projectId, String customerNote, Boolean resolved) { 
        PM_Project__c project = new PM_Project__c ( 
            Id = projectId, 
            Customer_Action_Notes__c = customerNote,
            Customer_Action_Resolved__c = resolved
        );
        update project;
    }

    //MIS-212 PB 01/28/2016
    @RemoteAction
    global static void updateSurveyEventDate(Id projectId, String dt) {
        Datetime surveydate = DateTime.parse(dt);
        System.debug(surveydate);
        Id recId = Schema.Sobjecttype.Event.getRecordTypeInfosByName().get('Site Survey Onsite').getRecordTypeId();
        Event evt;
        try{
            evt = [SELECT ID,EndDateTime 
                    FROM Event 
                    WHERE WhatID =:projectId 
                    AND RecordTypeId=:recId
                    AND Site_Survey_Type__c ='Site Survey Onsite' 
                    ORDER BY CREATEDDATE DESC 
                    LIMIT 1];    
        }catch(QueryException qe){}
        
        if(evt != null){
            evt.EndDateTime = surveydate;
            evt.StartDateTime = surveydate;
            update evt;
        }
    }

    @RemoteAction
    global static void setReadyForInstall(Id projectId, Boolean value) { 
        PM_Project__c project = new PM_Project__c ( Id = projectId, Ready_for_Install__c = value );
        update project;
    }
    
    @RemoteAction
    global static List<PM_Project_Issue__c> getOpenElectricIssueCount(PM_Project__c project) {
        List<PM_Project_Issue__c> issues =
          [SELECT Id , LastModifiedDate
          FROM PM_Project_Issue__c
          WHERE PM_Project__c = :project.Id
          AND Status__c = 'Open'
          AND Bin__c = 'Electrical Review' 
          LIMIT 1];
        return issues;
    }
   
    @RemoteAction
    global static List<PM_Project_Issue__c> getFixedElectricIssueCount(PM_Project__c project) {
        List<PM_Project_Issue__c> issues =
          [SELECT Id , LastModifiedDate
          FROM PM_Project_Issue__c
          WHERE PM_Project__c = :project.Id
          AND Status__c = 'Fixed'
          AND Bin__c = 'Electrical Review' 
          LIMIT 1];
        return issues;
    }
    
    
    @RemoteAction
    global static PM_Project__c getProject(Id projectId) {

        String appName = DocumentConfigurationHelper.APP_ASTRUM_PM_20;
        
        /*
        Set<String> SUBMITTED_CR = new Set<String> {
        'Submitted', 'Submitted for Electrical Review', 'Master Electrician Approved', 'Master Electrician Rejected', 'Submitted to Accounting', 'Accounting Rejected' 
        };
        Set<String> APPROVED_CR = new Set<String> {
        'Approved/Pending', 'Completion Approval Pending', 'Completion Approval Rejected', 'Completion Pending Accounting', 'Completion Accounting Rejected' 
        };
        Set<String> COMPLETED_CR = new Set<String> {
        'Complete/Ready for Install' 
        };
        */
        
        String query = 'SELECT Id, Name';
        query += ',Sales_Order__r.Property__r.Name,Sales_Order__r.Property__r.Property_City__c,Sales_Order__r.Property__r.Property_State__c,Sales_Order__r.Property__r.Property_County__c,Sales_Order__r.Property__r.Astrum_Office__c';
        query += ',Sales_Order__r.Financing_Type__c,Project_Lead__r.Name';
        query += ',Customer_Action_Notes__c,Customer_Action_Resolved__c,CR_Status__c,Lease_Funding_Status__C , Handoff_Checklist_Status__c ,Sales_Order__r.Lease_PPA_Fund__c';
        query += ',Sales_Order__r.Lease_PPA_Fund__r.Name';
        
        Set<String> binFields = new Set<String>();
        
        for (Bin_Configuration__c config : binConfig) {
            if (!binFields.contains(config.Field_Name__c)) {
                query += ',' + config.Field_Name__c;
                binFields.add(config.Field_Name__c);
            }
        }
        
        for (DocumentConfigurationHelper.SpecialCategory cat : specialCategories) {
            if (binFields.contains(cat.binDateFieldName)) {
                query += ',' + cat.categoryDateFieldName;
            }
        }
        
        query += ',Kickoff__c,Install__c,Inspection__c,Customer_Care_Handoff__c,Ready_for_Installation__c, Approval_Date__c, Survey_Date__c';
        query += ',Work_Completed__c';
        query += ',(SELECT Id, Bin__c, Description__c, LastModifiedDate,Status__c,To__c  FROM PM_Project_Issues__r WHERE (Status__c = \'Open\')';
        query += ' OR (Status__c = \'Fixed\'))';
        query += ',(SELECT Bin__c From Astrum_Docs__r WHERE IsNote__c = true)';
        
        //MIS-212 PB 01/28/2016
        Id recId = Schema.Sobjecttype.Event.getRecordTypeInfosByName().get('Site Survey Onsite').getRecordTypeId();        
        query += ',(SELECT Id, EndDateTime, Completed__c ';
        query += ' FROM Events ';
        query += ' WHERE RecordTypeId=:recId ';
        query += ' AND Site_Survey_Type__c =\'Site Survey Onsite\'';
        query += ' ORDER BY CreatedDate DESC ';
        query += ' LIMIT 1 )';

        query += ' FROM PM_Project__c WHERE Id = :projectId';

        PM_Project__c project = Database.query(query);

        Set<String> specialBins = new Set<String>();
        for (DocumentConfigurationHelper.SpecialCategory sc : specialCategories) {
            if (binFields.contains(sc.binDateFieldName)) {
                specialBins.add(sc.binDateFieldName);
            }
        }
        
        Map<ID,PM_Project_Issue__c> openElectricIssueMap = new Map<ID,PM_Project_Issue__c>();
        Map<ID,PM_Project_Issue__c > FixedElectricIssueMap = new Map<ID,PM_Project_Issue__c>();
        
        try{
            List<PM_Project_Issue__c> openElectricissues =
                          [SELECT PM_Project__c, Id , LastModifiedDate FROM PM_Project_Issue__c                   
                                      Where Status__c = 'Open'
                                      AND Bin__c = 'Electrical Review' 
                                      AND  PM_Project__c = :project.Id                                                           
                          ];
            for (PM_Project_Issue__c issue : openElectricissues )
            {
                openElectricIssueMap.put(issue.PM_Project__c , issue);    
            }
            
        }    
        catch(Exception e)
        {
              System.debug('*** Caught Exception ** Open');   
        }
        
        try{
             List<PM_Project_Issue__c> fixedElectricissues =
                          [SELECT PM_Project__c, Id , LastModifiedDate FROM PM_Project_Issue__c                   
                                      Where Status__c = 'Fixed'
                                      AND Bin__c = 'Electrical Review' 
                                      AND  PM_Project__c = :project.Id                                                            
                          ];
            for (PM_Project_Issue__c issue : fixedElectricissues )
            {
                FixedElectricIssueMap.put(issue.PM_Project__c , issue);    
            }
         }   
         catch(Exception e)
        {
             System.debug('*** Caught Exception ** Fix');     
        }
        
       Map<ID,String> projectCRStatusMap = new Map<ID,String>(); 
       try{
            List<Change_Request__c> changeRequests =
                          [SELECT PM_Project__c, Id , Status__c, CR_Overall_Status__C FROM Change_Request__c                   
                                      Where  CR_Overall_Status__C != null                                   
                                      AND  PM_Project__c = :project.Id
                                      order by CR_Overall_Status__C                                                          
                          ];
            for (Change_Request__c cr: changeRequests )
            {
                
                if(cr.cr_overall_status__c == 'S')
                    projectCRStatusMap.put(cr.PM_Project__c , 'S');    
                else if (cr.cr_overall_status__c == 'P')    
                    projectCRStatusMap.put(cr.PM_Project__c , 'P');                            
                else if (cr.cr_overall_status__c == 'C')    
                    projectCRStatusMap.put(cr.PM_Project__c , 'C');    
            }
            
        }    
        catch(Exception e)
        {
              System.debug('*** Caught Exception ** Open');   
        }
        
        PM_Project_Issue__c electricOpen = openElectricIssueMap.get(project.Id);   //getOpenElectricIssueCount(project);
        PM_Project_Issue__c electricFix =  FixedElectricIssueMap.get(project.Id);    //getFixedElectricIssueCount(project);        
        Integer openElectricIssue = (electricOpen !=null ? 1 : 0);   //electricOpen.size();
        Integer fixElectricIssue =  (electricFix !=null ? 1 : 0);
        System.debug('* CR Status -'+ projectCRStatusMap.get(project.id)); 
        project.put('CR_Status__c',projectCRStatusMap.get(project.id));
                
        // NRG Bin - RJ - 09/4/13
        if(project.Sales_Order__r.Lease_PPA_Fund__r.Name == 'NRG Residential Solar Solutions, LLC' && project.Lease_Approval_To_Inspect__c == null )
        {
           if(project.Lease_Commissioning_Checklist__c != null)
           {
               project.put('Lease_Commissioning_Checklist__c',project.Lease_Commissioning_Checklist__c.addYears(24000));
           }
           else
           {
               project.put('Lease_Commissioning_Checklist__c',System.today().addYears(20000));
           }    
        }    
        // Logic for Handoff to Customer Care
        if(project.Handoff_Checklist_Status__c == 'Completed' && project.Customer_Care_Handoff__c != null )
        {
            project.put('Customer_Care_Handoff__c', project.Customer_Care_Handoff__c.addYears(6000));
        
        }
        else if (project.Handoff_Checklist_Status__c == 'Rejected' && project.Customer_Care_Handoff__c != null )
        {
        
            project.put('Customer_Care_Handoff__c', project.Customer_Care_Handoff__c.addYears(16000));
        }
        
        for (String specialBin : specialBins) {
            Date dt = (Date)project.get(specialBin);
            if (dt == null) {
                for (DocumentConfigurationHelper.SpecialCategory sc : specialCategories) {
                    if (sc.binDateFieldName == specialBin) {
                        Date dt2 = (Date)project.get(sc.categoryDateFieldName);
                        if (dt2 != null && sc.binState != null) {
                           if (sc.binState == 'Ready to Sign') {
                                if(sc.binDateFieldName =='Electrical_Review__c' && openElectricIssue > 0)
                                {
                                    Date issueDate = date.newinstance(electricOpen.LastModifiedDate.year(), electricOpen.LastModifiedDate.month(), electricOpen.LastModifiedDate.day());
                                    project.put(specialBin, issueDate.addYears(14000));
                                }
                                else if(sc.binDateFieldName =='Electrical_Review__c' && openElectricIssue  < 1 && fixElectricIssue > 0 )
                                {
                                    Date issueDate = date.newinstance(electricFix.LastModifiedDate.year(), electricFix.LastModifiedDate.month(), electricFix.LastModifiedDate.day());
                                    project.put(specialBin, issueDate.addYears(12000));
                                }
                                else
                                {
                                    project.put(specialBin, dt2.addYears(2000));
                                }    
                            } else if (sc.binState == 'Signed') {
                                if(sc.binDateFieldName =='Electrical_Review__c' && openElectricIssue > 0)
                                {
                                    Date issueDate = date.newinstance(electricOpen.LastModifiedDate.year(), electricOpen.LastModifiedDate.month(), electricOpen.LastModifiedDate.day());
                                    project.put(specialBin, issueDate.addYears(14000));
                                }
                                else if(sc.binDateFieldName =='Electrical_Review__c' && openElectricIssue  < 1 && fixElectricIssue > 0 )
                                {
                                    Date issueDate = date.newinstance(electricFix.LastModifiedDate.year(), electricFix.LastModifiedDate.month(), electricFix.LastModifiedDate.day());
                                    project.put(specialBin, issueDate.addYears(12000));
                                }
                                else
                                {
                                    project.put(specialBin, dt2.addYears(4000));
                                }    
                            }                       
                            else if (sc.binState == 'ApprovedPt1') {  
                                    System.debug('$$ '+sc.binDateFieldName);                                  
                                    if(sc.binDateFieldName =='Grant_Completion_Approved_Part_2__c')
                                    {
                                        System.debug('Grant_Completion ');
                                        project.put(specialBin, dt2.addYears(27000));
                                    }                                     
                                }
                            else if (sc.binState == 'SubmittedPt2') {  
                                System.debug('$$ '+sc.binDateFieldName);                                  
                                if(sc.binDateFieldName =='Grant_Completion_Approved_Part_2__c')
                                {
                                    System.debug('Grant_Completion ');
                                    project.put(specialBin, dt2.addYears(30000));
                                }                                     
                            }          
                            else { //submitted
                                 if(sc.binDateFieldName =='Electrical_Review__c' && openElectricIssue > 0)
                                {
                                    Date issueDate = date.newinstance(electricOpen.LastModifiedDate.year(), electricOpen.LastModifiedDate.month(), electricOpen.LastModifiedDate.day());
                                    project.put(specialBin, issueDate.addYears(14000));
                                }
                                else if(sc.binDateFieldName =='Electrical_Review__c' && openElectricIssue  < 1 && fixElectricIssue > 0 )
                                {
                                    Date issueDate = date.newinstance(electricFix.LastModifiedDate.year(), electricFix.LastModifiedDate.month(), electricFix.LastModifiedDate.day());
                                    project.put(specialBin, issueDate.addYears(12000));
                                }
                                else
                                {
                                    project.put(specialBin, dt2.addYears(6000));
                                }
                                }
                            }
                            else{
                                    
                                if(sc.binDateFieldName =='Electrical_Review__c' && openElectricIssue > 0)
                                {
                                    Date issueDate = date.newinstance(electricOpen.LastModifiedDate.year(), electricOpen.LastModifiedDate.month(), electricOpen.LastModifiedDate.day());
                                    project.put(specialBin, issueDate.addYears(14000));
                                }
                                else if(sc.binDateFieldName =='Electrical_Review__c' && openElectricIssue  < 1 && fixElectricIssue > 0 )
                                {
                                    Date issueDate = date.newinstance(electricFix.LastModifiedDate.year(), electricFix.LastModifiedDate.month(), electricFix.LastModifiedDate.day());
                                    project.put(specialBin, issueDate.addYears(12000));
                                }
                            
                            }
                        }
                    }
                }
                else{
                                    
                    if(specialBin  =='Electrical_Review__c' && openElectricIssue > 0)
                    {
                        Date issueDate = date.newinstance(electricOpen.LastModifiedDate.year(), electricOpen.LastModifiedDate.month(), electricOpen.LastModifiedDate.day());
                        project.put(specialBin, issueDate.addYears(14000));
                    }
                    else if(specialBin =='Electrical_Review__c' && openElectricIssue  < 1 && fixElectricIssue > 0 )
                    {
                        Date issueDate = date.newinstance(electricFix.LastModifiedDate.year(), electricFix.LastModifiedDate.month(), electricFix.LastModifiedDate.day());
                        project.put(specialBin, issueDate.addYears(12000));
                    }
            
                }            
        }
        
        return project;
        
    }
    
}