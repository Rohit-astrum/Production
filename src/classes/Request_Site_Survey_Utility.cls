//10/26/2012 - TCM - replace notes with comments
//09/29/2015 - PB  - Remove reference to Annapolis MD
public class Request_Site_Survey_Utility {

    public static final String TASK_STATUS = 'Not Started';
    public static final String TASK_PRIORITY = 'Normal';
    public static final String TASK_SUBJECT = 'Schedule Site Survey';
    public static final String TASK_DESCRIPTION = 'Please schedule a site survey.';

    public static final String MA_OFFICE = 'MA';
    public static final String MD_OFFICE = Main_Office_Location_Settings__c.getOrgDefaults().Name__c;//FPO Phase4 //'Annapolis Junction, MD';
    public static final String MI_OFFICE = 'MI';
    public static final String NY_OFFICE = 'NY';
    public static final String OH_OFFICE = 'Youngstown, OH';
    public static final String PA_OFFICE = 'Norristown, PA';
    public static final String HOPKINTON_MA_OFFICE = 'Hopkinton, MA';
    public static final String HENRIETTA_NY_OFFICE = 'Henrietta, NY';
    public static final String WHITE_PLAINS_NY_OFFICE = 'White Plains, NY';
    public static final String BRIDGEWATER_NJ_OFFICE = 'Bridgewater, NJ';

    public static final String RECORDTYPE_SCHEDULE_EVENT = 'Schedule Event';
    public static final String SURVEYTYPE_SITE_SURVEY_ONSITE = 'Site Survey Onsite';
    public static final String TASK_STATUS_NOT_STARTED = 'Not Started';
    public static final String TASK_PRIORITY_NORMAL = 'Normal';
    
    public static final String SURVEYTYPE_RESIDENTIAL_REMOTE_SURVEY = 'Residential Remote Survey';
    public static final String SURVEYTYPE_RESIDENTIAL_FIELD_SURVEY = 'Residential Field Survey';
    public static final String SURVEYTYPE_COMMERCIAL_SURVEY = 'Commercial Survey';
    public static final String SURVEYTYPE_CHANNEL_SURVEY = 'Channel Survey';
    
    public class MyException extends Exception{}
    
      public static void submitRequest(Id oppId, String comments, String siteSurveyType, Date requestedDate, Boolean highPriority) {
        
        Set<Id> salesvisitrecIds = new Set<Id>();
        
        Date activitydate;
        salesvisitrecIds.add(Schema.Sobjecttype.Event.getRecordTypeInfosByName().get('Sales Visit Onsite').getRecordTypeId());
        salesvisitrecIds.add(Schema.Sobjecttype.Event.getRecordTypeInfosByName().get('Sales Visit Remote').getRecordTypeId());
        
        Opportunity opp = [Select Id, o.Account.Name, o.Property__r.Property_County__c, o.Property__r.Property_ZIP__c, o.Property__r.Property_State__c, o.Property__r.Property_City__c, o.Property__r.Name, o.Property__r.Astrum_Office__c, o.Property__c, 
                                  o.Owner.Email, o.Owner.FirstName, o.Owner.LastName, o.Owner.Manager.Email, o.OwnerId, o.Name  , o.Property__r.Astrum_Office_New__r.Sales_Coordinator__r.Id,  o.Property__r.Astrum_Sales_Region__r.Sales_Coordinator__r.Id                              
                                  , o.Property__r.Astrum_Office_New__r.Regional_Operations_Manager__c, o.Property__r.Astrum_Office_New__r.Survey_Scheduler__c
                                  , (SELECT StartDateTime FROM Events WHERE RecordTypeId IN:salesvisitrecIds AND Completed__c = false LIMIT 1)                                  
                                  From Opportunity o 
                                  where id = :oppId
                                  limit 1];
        
        if(opp.Events != null && !(opp.Events.isEmpty())){
            activitydate = opp.Events[0].StartDateTime.date();
        }
               
        //User salesCoordinator = getSalesCoordinator(opp);
        //Added by Rohit  
        User  salesCoordinator;
        try{
            if(siteSurveyType == SURVEYTYPE_RESIDENTIAL_FIELD_SURVEY 
                    || siteSurveyType == SURVEYTYPE_COMMERCIAL_SURVEY)
            {
                salesCoordinator =  [Select u.Id, u.Email, u.userName From User u where Id = :opp.Property__r.Astrum_Office_New__r.Survey_Scheduler__c  ];                
            }
            else if(siteSurveyType == SURVEYTYPE_RESIDENTIAL_REMOTE_SURVEY 
                    || siteSurveyType == SURVEYTYPE_CHANNEL_SURVEY)
            {
                salesCoordinator =  [Select u.Id, u.Email, u.userName From User u where Id = :opp.Property__r.Astrum_Office_New__r.Sales_Coordinator__r.Id];    
            }else if(String.isBlank(siteSurveyType)){
                salesCoordinator = new User(Id = UserInfo.getUserId(), Email = UserInfo.getUserEmail(), userName = UserInfo.getUserName());
            }
        }
        catch(Exception e)
        {
            throw new MyException ('Please check that Opportunity is linked to Property and Property is assigned to a Sales Region.');
           
        }
        if(salesCoordinator != null) {       
        // assign task
        //assignTask(opp, salesCoordinator, recType, comments, siteSurveyType, requestedDate, highPriority);
        assignTask(opp, salesCoordinator.Id, comments, siteSurveyType, requestedDate, highPriority,activitydate);
        
        // 
        // send email
        sendEmail(opp, salesCoordinator, comments, siteSurveyType, requestedDate, highPriority);
        }
           
    }

    private static User getSalesCoordinator(Opportunity opp) {

        User salesCoordinator = null;
        
        AstrumCRMSettings__c astrumCRMSettings = AstrumCRMSettings__c.getOrgDefaults();
                
        String theUserName = null;
        
        String office = opp.Property__r.Astrum_Office__c;
    
        if (office == MA_OFFICE) {
            theUserName = astrumCRMSettings.MA_Sales_Coord__c;  
        }   
        else if (office == HOPKINTON_MA_OFFICE) {
            theUserName = astrumCRMSettings.HOPKINTON_MA_Sales_Coord__c;
        }
        else if (office == MD_OFFICE) {
            theUserName = astrumCRMSettings.Annapolis_Junction_MD_Sales_Coord__c;
        }
        else if (office == MI_OFFICE) {
            theUserName = astrumCRMSettings.MI_Sales_Coord__c;
        }
        else if (office == NY_OFFICE) {
            theUserName = astrumCRMSettings.NY_Sales_Coord__c;
        }
        else if (office == OH_OFFICE) {
            theUserName = astrumCRMSettings.Youngstown_OH_Coord__c;
        }
        else if (office == PA_OFFICE) {
            theUserName = astrumCRMSettings.Norristown_PA_Sales_Coord__c;
        }
        else if (office == HENRIETTA_NY_OFFICE) {
            theUserName = astrumCRMSettings.HENRIETTA_NY_Sales_Coord__c;
        }
        else if (office == WHITE_PLAINS_NY_OFFICE) {
            theUserName = astrumCRMSettings.White_Plains_NY_Sales_Coord__c;         
        }
        else if (office == BRIDGEWATER_NJ_OFFICE) {
            theUserName = astrumCRMSettings.Bridgewater_NJ_Sales_Coord__c;
        }
        else {          
            // default
            theUserName = astrumCRMSettings.Annapolis_Junction_MD_Sales_Coord__c;           
        }
        
        salesCoordinator = [Select u.Id, u.Email, u.userName From User u where userName = :theUserName limit 1];
        
        return salesCoordinator;
    }
    
    private static void sendEmail(sObject obj, User salesCoordinator, String comments, String siteSurveyType, Date requestedDate, Boolean highPriority) {
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // send email to sales coordinator
        mail.setToAddresses(new String[] {salesCoordinator.email});

        schema.sObjectType sourceType = obj.getsObjectType();
        if(sourceType == Opportunity.sObjectType){
            //system.debug('This is a Promotion record');
            Opportunity opp = (Opportunity)obj;
            mail.setSubject('Request Site Survey: ' + opp.Name + ',  Solar Consultant: ' + opp.Owner.LastName + ', ' + opp.Owner.FirstName);
        }
        else if (sourceType == PM_Project__c.sObjectType)
        {
            PM_Project__c project = (PM_Project__c)obj;
            mail.setSubject('Request Site Survey: ' + project.Name + ',  Project Lead : ' + project.Project_Lead__c);
        }

        String plainTextContent = getPlainTextContent(obj, comments, siteSurveyType, requestedDate, highPriority);
        String htmlContent = getHtmlContent(obj, comments, siteSurveyType, requestedDate, highPriority);
                
        mail.setPlainTextBody(plainTextContent);
        mail.setHtmlBody(htmlContent);
        
        if (!Test.isRunningTest())
            Messaging.sendEmail(new Messaging.Singleemailmessage[] { mail });                   
    }
    
    public static String getPlainTextContent(sObject obj, String comments, String siteSurveyType, Date requestedDate, Boolean highPriority) {
        String content = '';
        
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm()+'/';        
       

        schema.sObjectType sourceType = obj.getsObjectType();
        if(sourceType == Opportunity.sObjectType){
            //system.debug('This is a Promotion record');
            Opportunity theOpp = (Opportunity)obj;
        
            String solarConsultantName = theOpp.Owner.FirstName + ' ' + theOpp.Owner.LastName;

            content += 'The Solar Consultant, ' + solarConsultantName + ', has requested that you scheduled a Site Survey for the opportunity ' + theOpp.Name + '.\n\n';

            content += '\n';
            content += theOpp.Account.name + '\n';
            content += theOpp.Property__r.Name + '\n';
            content += theOpp.Property__r.Property_City__c + ', ' + theOpp.Property__r.Property_State__c + ', ' + theOpp.Property__r.Property_ZIP__c + '\n\n';
            content += String_Utils.getDefaultString(theOpp.Property__r.Property_County__c) + '\n';

            content += '\n';

            content += 'Link to Account: ' + theOpp.Account.name + '.  ' + baseUrl + theOpp.Account.Id+ '\n';
            content += 'Link to the Opportunity:  ' + theOpp.Name + '.  ' + baseUrl + theOpp.Id + '\n';
            content += 'Link to Property: ' + theOpp.Property__r.Name + '.  ' + baseUrl + theOpp.Property__c + '\n';
            content += 'Notes: ' + String_Utils.getDefaultString(comments) + '\n';
            content += 'Site Survey Type: ' + String_Utils.getDefaultString(siteSurveyType) + '\n';
            
            String requestedDateStr = '';
            if (requestedDate != null) {
                requestedDateStr = requestedDate.format();
            }
            
            content += 'Requested Date: ' + String_Utils.getDefaultString(requestedDateStr) + '\n';
            content += 'High Priority: ' + String_Utils.toStringYesNo(highPriority) + '\n';
        }
        else if (sourceType == PM_Project__c.sObjectType)
        {
            PM_Project__c project = (PM_Project__c)obj;
        
            //String solarConsultantName = theOpp.Owner.FirstName + ' ' + theOpp.Owner.LastName;

            content += 'You are requested to schedule a Post Sale Site Survey for the PM Project ' + project.Name + '.\n\n';

            content += '\n';
            
            content += 'Link to the PM Project:  ' + project.Name + '.  ' + baseUrl + project.Id + '\n';
                        
            content += 'Site Survey Type: ' + String_Utils.getDefaultString(siteSurveyType) + '\n';
            
            String requestedDateStr = '';
            if (requestedDate != null) {
                requestedDateStr = requestedDate.format();
            }
            
            content += 'Requested Date: ' + String_Utils.getDefaultString(requestedDateStr) + '\n';
            
        }
        
        
        return content;
    }

    public static String getHtmlContent(sObject obj, String comments, String siteSurveyType, Date requestedDate, Boolean highPriority) {
        String content = '';

        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm()+'/';

        schema.sObjectType sourceType = obj.getsObjectType();
        if(sourceType == Opportunity.sObjectType){
            //system.debug('This is a Promotion record');
            Opportunity theOpp = (Opportunity)obj;
        
            String solarConsultantName = theOpp.Owner.FirstName + ' ' + theOpp.Owner.LastName;
            
            content += 'The Solar Consultant, ' + solarConsultantName + ', has requested that you schedule a Site Survey for the opportunity: ' + theOpp.name + '.<br>';
            content += '<br>';

            content += theOpp.Account.name + '<br>';
            content += theOpp.Property__r.Name + '<br>';
            content += theOpp.Property__r.Property_City__c + ', ' + theOpp.Property__r.Property_State__c + ', ' + theOpp.Property__r.Property_ZIP__c + '<br>';
            content += String_Utils.getDefaultString(theOpp.Property__r.Property_County__c) + '<br>';

            content += '<br>';
            
            content += 'Account: <a href="' + baseUrl + theOpp.Account.Id+ '">' + theOpp.Account.name + '</a><br>';
            content += 'Opportunity: <a href="' + baseUrl + theOpp.Id + '">' + theOpp.name + '</a><br>';
            content += 'Property: <a href="'+ baseUrl + theOpp.Property__c + '">' + theOpp.Property__r.Name + '</a><br>';

            content += '<br>';

            content += 'Notes: ' + String_Utils.getDefaultString(comments) + '<br>';
            content += 'Site Survey Type: ' + String_Utils.getDefaultString(siteSurveyType) + '<br>';

            String requestedDateStr = ''; 
            if (requestedDate != null) {
                requestedDateStr = requestedDate.format();
            }

            content += 'Requested Date: ' + requestedDateStr + '<br>';

            content += 'High Priority: ' + String_Utils.toStringYesNo(highPriority) + '<br>';
        }
        else if (sourceType == PM_Project__c.sObjectType)
        {
            PM_Project__c project = (PM_Project__c)obj;

            content += 'You are requested to schedule a Post Sale Site Survey for the PM Project: ' + project.name + '.<br>';
            content += '<br>';
            
            content += 'PM Project: <a href="' + baseUrl + project.Id + '">' + project.name + '</a><br>';
            
            content += '<br>';
           
            content += 'Site Survey Type: ' + String_Utils.getDefaultString(siteSurveyType) + '<br>';

            String requestedDateStr = ''; 
            if (requestedDate != null) {
                requestedDateStr = requestedDate.format();
            }

            content += 'Requested Date: ' + requestedDateStr + '<br>';


        }
        
        return content;
    }
    
    public static void assignTask(sObject obj, Id salesCoordinatorId, String comments, String siteSurveyType, Date requestedDate, Boolean highPriority, Date activityDate) {
        Id recTypeId = [SELECT Id FROM RecordType WHERE Name = 'Schedule Event' AND SobjectType = 'Task' limit 1].Id; 
        System.debug('**recTypeId:' + recTypeId);
        Task tempTask = new Task();
        tempTask.whatId = obj.Id;
        tempTask.RecordTypeId = recTypeId;
        
        
        tempTask.ownerId = salesCoordinatorId; 
        
        // due date
        if(activityDate != null && Date.today() > activityDate){
            tempTask.activityDate = activityDate;
        }else{
            tempTask.activityDate = Date.today();
        }        

        tempTask.description = TASK_DESCRIPTION;
        tempTask.priority = TASK_PRIORITY;
        tempTask.status = TASK_STATUS;
        tempTask.subject = TASK_SUBJECT;
        
        tempTask.Description = comments;
        tempTask.Site_Survey_Type__c = siteSurveyType;
        tempTask.Requested_Date__c = requestedDate;
        tempTask.High_Priority__c = highPriority;

        schema.sObjectType sourceType = obj.getsObjectType();
        if(sourceType == PM_Project__c.sObjectType){
            PM_Project__c proj = (PM_Project__c)obj;
            if(Test.isRunningTest()){
                tempTask.ownerId = salesCoordinatorId != null ?salesCoordinatorId:UserInfo.getUserId();
            }else{
                tempTask.ownerId = salesCoordinatorId;
            }
            
            tempTask.subject = 'Operations Survey for [' + proj.Name + ']';
            tempTask.ActivityDate = Date.today().addDays(7); 
            tempTask.Requested_Date__c = Date.today();
            tempTask.Site_Survey_Type__c = SURVEYTYPE_RESIDENTIAL_FIELD_SURVEY;
            tempTask.status = TASK_STATUS_NOT_STARTED;
            tempTask.priority = TASK_PRIORITY_NORMAL;             
        }
        
        insert tempTask;
        
        // store this task id on the opportunity

        //Check to see what type of object this is for
        
        if(sourceType == Opportunity.sObjectType){
            Opportunity opp = (Opportunity)obj;

            opp.Schedule_Site_Survey_Task_id__c = tempTask.id;  
             update opp; 
        }            
           
    }
    
}