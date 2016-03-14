/* FILE: MyProjects2Controller.cls
 * AUTHOR: Tino Mattheou
 * DATE: March 19, 2012
 * PURPOSE: Controller for MyProjects2 page
 * MODIFICATION HISTORY:
 * 06/27/2012 TCM - zen-2 Newly entered dates aren't sorted correctly (install, work completed, and customer care handoff)
 * 11/19/2012 TCM - augment project lead list to include PL's on existing projects
 * 05/01/2013 RJ - Addition of Change request Icons
 * 12/15/2015 PB - SOA-38 Additional filters in MyProjects
 */
 public class MyProjects2Controller {

    private static final Integer DEFAULT_KICKOFF_DURATION = 1; //1 hour
    private static final Integer DEFAULT_INSPECTION_DURATION = 1; //1 hour

    //GOOGLE CALENDAR API V3 - custom client key 
    private static String clientId = '174467368995.apps.googleusercontent.com';
    private static String clientSecret = 'yG_8Kwhtpso64Q5ZwEq-QZWb';
    private static String redirectUri { 
        get { return URL.getSalesForceBaseUrl().toExternalForm() + '/apex/MyProjects2'; }
    }
    
    private GoogleOAuth2Helper oauth;
    private GoogleCalendarV3 gCal;
    
    public Boolean googleCalendarEnabled {
        get {
            if (googleCalendarEnabled == null) {
                User u = [SELECT Id, UserRole.Name FROM User WHERE Id = :UserInfo.getUserId()];
                googleCalendarEnabled = (u.UserRole.Name != null && u.UserRole.Name.toLowerCase().endsWith('project lead'));
            }
            return googleCalendarEnabled;
        }
        private set;
    }
    
    public Boolean showAccessLink { get; set; }
        
    //calendarId is the user's email address
    private String calendarId {
        get {
            if (calendarId == null) {
                calendarId = UserInfo.getUserName();
                if (!calendarId.endsWith('.com')) {
                    calendarId = calendarId.substring(0, calendarId.lastIndexOf('.com') + 4);
                }
            }
            return calendarId;
        }
        set;
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
    
    public String userTimeZone {
        get { 
            if (userTimeZone == null) {
                User u = [SELECT Id, TimeZoneSidKey FROM User WHERE Id = :UserInfo.getUserId()];
                userTimeZone = u.TimeZoneSidKey;
            }
            return userTimeZone;
        }
        private set;
    }
    
    public List<String> getOffices() {
        List<String> result = new List<String>();
        Schema.DescribeFieldResult office = Property__c.Astrum_Office__c.getDescribe();
        for (Schema.PicklistEntry entry : office.getPicklistValues()) {
            result.add(entry.getLabel());
        }
        return result;
    } 

    public List<String> getStates() {
        List<String> result = new List<String>();
        Schema.DescribeFieldResult states = Property__c.Property_State__c.getDescribe();
        for (Schema.PicklistEntry state : states.getPicklistValues()) {
            result.add(state.getLabel());
        }
        return result;
    }

    public List<String> getStatuses() {
        List<String> result = new List<String>();
        Schema.DescribeFieldResult statuses = PM_Project__c.Status__c.getDescribe();
        for (Schema.PicklistEntry status : statuses.getPicklistValues()) {
            result.add(status.getLabel());
        }
        return result;
    }

    public List<SelectOption> getProjectLeads() {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('', 'Unassigned'));
        List<UserRole> roles = [SELECT Id FROM UserRole WHERE Name LIKE '%Project Lead'];
        List<User> leads = [SELECT Id, Name FROM User WHERE UserRoleId IN :roles ORDER BY Name];
        //add leads that are assigned to projects but not in a role
        leads.addAll([SELECT Id, Name FROM User WHERE Id IN (SELECT Project_Lead__c FROM PM_Project__c) AND Id NOT IN :leads]);
        //create a map to sort the names
        Map<String, User> nameMap = new Map<String, User>();
        for (User lead : leads) {
            nameMap.put(lead.Name + '|' + lead.Id, lead);
        }
        List<String> names = new List<String>();
        names.addAll(nameMap.keySet());
        names.sort();        
        for (String name : names) {
            User lead = nameMap.get(name);
            result.add(new SelectOption(lead.Id, lead.Name));
        }
        return result;
    }

    public List<SelectOption> getOperationsSurveyors(){
        List<SelectOption> result = new List<SelectOption>();
        List<User> surveyors = new List<User>();
        surveyors.addAll([SELECT Id, Name FROM User WHERE Id IN (SELECT System_Designer__c FROM PM_Project__c)]);
        Map<String, User> nameMap = new Map<String, User>();
        for(User surveyor:surveyors){
            nameMap.put(surveyor.Name + '|' + surveyor.Id, surveyor);
        }
        List<String> names = new List<String>();
        names.addAll(nameMap.keySet());
        names.sort();
        for (String name : names) {
            User surveyor = nameMap.get(name);
            result.add(new SelectOption(surveyor.Id, surveyor.Name));
        }

        return result;

    }

    public List<SelectOption> getElecDesigners(){
        List<SelectOption> result = new List<SelectOption>();
        List<User> designers = new List<User>();
        designers.addAll([SELECT Id, Name FROM User WHERE Id IN (SELECT Electrical_Designer__c FROM PM_Project__c)]);
        Map<String, User> nameMap = new Map<String, User>();
        for(User designer:designers){
            nameMap.put(designer.Name + '|' + designer.Id, designer);
        }
        List<String> names = new List<String>();
        names.addAll(nameMap.keySet());
        names.sort();
        for (String name : names) {
            User designer = nameMap.get(name);
            result.add(new SelectOption(designer.Id, designer.Name));
        }

        return result;

    }

    public List<SelectOption> getEngineers(){
        List<SelectOption> result = new List<SelectOption>();
        List<User> engineers = new List<User>();
        engineers.addAll([SELECT Id, Name FROM User WHERE Id IN (SELECT Project_Engineer__c FROM PM_Project__c)]);
        Map<String, User> nameMap = new Map<String, User>();
        for(User engineer:engineers){
            nameMap.put(engineer.Name + '|' + engineer.Id, engineer);
        }
        List<String> names = new List<String>();
        names.addAll(nameMap.keySet());
        names.sort();
        for (String name : names) {
            User engineer = nameMap.get(name);
            result.add(new SelectOption(engineer.Id, engineer.Name));
        }

        return result;

    }

    public List<SelectOption> getReadyForInstall(){
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('ReadyForInstall', 'Ready for Install'));
        result.add(new SelectOption('NotReadyForInstall', 'Not ready for Install'));
        return result;
    }

    public List<String> getSOStatuses() {
        List<String> result = new List<String>();
        Schema.DescribeFieldResult statuses = SCRB_SalesOrder__c.StatusCode__c.getDescribe();
        for (Schema.PicklistEntry status : statuses.getPicklistValues()) {
            result.add(status.getLabel());
        }
        return result;
    }
    
    public static Map<String,String> milestoneStatusMap = new Map<String,String> {
        'Kickoff Complete' => ' Kickoff__c <> null',
        'Kickoff Not Done' => ' Kickoff__c = null',
        'Install Complete' => ' Install__c <> null',
        'Install Not Done' => ' (Install__c = null AND Kickoff__c <> null)',
        'Inspection Complete' => ' Inspection__c <> null',
        'Inspection Not Done' => ' (Inspection__c = null AND Work_Completed__c <> null)',
        'Handoff Complete' => ' Customer_Care_Handoff__c <> null',
        'Handoff Not Done' => ' (Customer_Care_Handoff__c = null AND Inspection__c <> null)'
    };
    
    public MyProjects2Controller () {
        oauth = new GoogleOAuth2Helper(clientId, clientSecret, redirectUri);
        gCal = new GoogleCalendarV3(calendarId, oauth);
    }
    
    //checks if user authorized access
    public PageReference checkAccess() {

        String code = ApexPages.currentPage().getParameters().get('code');
        String state = ApexPages.currentPage().getParameters().get('state');
        
        Boolean hadRefreshToken = oauth.hasRefreshToken();

        //if no access token or no longer valid, get new one
        if (!oauth.isAccessTokenValid()) {
            oauth.refreshAccessToken(code);
        }
        
        if (code != null) {
            //TODO: make this smarter
            PageReference pr = Page.MyProjects2;
            pr.setRedirect(true);
            return pr;
        }
        
        //check if new token valid
        if (oauth.isAccessTokenValid()) {
            showAccessLink = false;
        } else {
            showAccessLink = true;
        }
    
        return null;    
    }
    
    public PageReference requestGoogleAccess() {
        return oauth.requestGoogleAccess();
    }

    public PageReference revokeAccess() {
        oauth.revokeAccess();
        showAccessLink = true;
        return Page.MyProjects2; 
    }
    
    @RemoteAction
    public static void setProjectDate(Id projectId, String dateField, String projectDate) {  //date needs to be in mm/dd/yyyy format
        System.debug(dateField);
        GoogleOAuth2Helper oauth = new GoogleOAuth2Helper(clientId, clientSecret, redirectUri);
        //only call the future method if there is an oauth token and it's a synced date
        if (oauth.hasRefreshToken() && updateFieldMap.keyset().contains(dateField)) {
            syncGoogleCalendar(projectId, dateField, projectDate);
        }
        
        PM_Project__c project = new PM_Project__c ( Id = projectId );
        if (projectDate == null || projectDate.trim().length() == 0) {
            project.put(dateField, null);
        } else {
            //datetime passed as long value in GMT
            Datetime newDate = DateTime.newInstance(Long.valueOf(projectDate));
            if (dateField == 'Kickoff__c' || dateField == 'Inspection__c' || dateField == 'Survey_Date__c') {
                project.put(dateField, newDate);
            } else { 
                project.put(dateField, newDate.date());
            }
        }
        update project;
    }
    
    //asynchronous update to google calendar, if calendar is connected, sync the changed event
    @future(callout=true)
    private static void syncGoogleCalendar(Id projectId, String dateField, String projectDate) {
        
        try {
            
            //email address is the gmail calendar id
            String calendarId = UserInfo.getUserName();
            //strip sandbox suffix, if any
            if (!calendarId.endsWith('.com')) {
                calendarId = calendarId.substring(0, calendarId.lastIndexOf('.com') + 4);
            }
            GoogleOAuth2Helper oauth = new GoogleOAuth2Helper(clientId, clientSecret, redirectUri);

            //if there is no refresh token, the google calendar isn't connected         
            if (!oauth.hasRefreshToken()) {
                return;
            }
            
            GoogleCalendarV3 gCal = new GoogleCalendarV3(calendarId, oauth);

            //see if the event is on the user's calendar, only look within the last 90 days and forward
            GoogleCalendarV3.CalendarEvents events = gCal.getEvents(System.now().addDays(-90));
            Boolean found = false;
            String orgId = UserInfo.getOrganizationId();
            for (GoogleCalendarV3.CalendarEvent evt : events.items) {
                if (evt.extendedProperties != null && evt.extendedProperties.gPrivate != null) {
                    GoogleCalendarV3.PrivateData pvt = evt.extendedProperties.gPrivate;
                    //NOTE: original version had no org ids
                    //match by orgid, project id, and date field
                    if ((pvt.orgId == null || pvt.orgId == orgId) && pvt.projectDateField == dateField && pvt.projectId == projectId) {
                        found = true;
                        //if project date was cleared out, delete the gcal event
                        if (projectDate == null || projectDate.trim().length() == 0) {
                            gCal.deleteEvent(evt.Id);
                        } else { //update the event
                            evt.start = new GoogleCalendarV3.CalendarDate();
                            evt.gEnd = new GoogleCalendarV3.CalendarDate();
                            Datetime start = Datetime.newInstance(Long.valueOf(projectDate));
                            if (dateField == 'Kickoff__c' || dateField == 'Inspection__c' || dateField == 'Survey_Date__c') { //date time
                                evt.start.gDateTime = start;
                                evt.gEnd.gDateTime = start
                                    .addHours(dateField == 'Kickoff__c' ? DEFAULT_KICKOFF_DURATION : DEFAULT_INSPECTION_DURATION);
                            } else { //date
                                evt.start.gDate = start.date();
                                evt.gEnd.gDate = evt.start.gDate;
                            }
                            pvt.orgId = orgId; //make sure orgid is set
                            gCal.updateEvent(evt);
                        }
                    }
                } 
            }
            
            //add a new event if not found
            if (!found && projectDate != null && projectDate.trim().length() > 0) {
    
                PM_Project__c project = 
                    [SELECT Id, Name,
                        Sales_Order__r.Property__r.Name,  
                        Sales_Order__r.Property__r.Property_Address_2__c,
                        Sales_Order__r.Property__r.Property_City__c,
                        Sales_Order__r.Property__r.Property_State__c,
                        Sales_Order__r.Property__r.Property_ZIP__c
                    FROM PM_Project__c
                    WHERE Id = :projectId];
    
                //set the color of the event for the google calendar UI
                String eventType, colorId;
                if (dateField == 'Kickoff__c') { eventType = 'KICKOFF: '; colorId = '6'; } //organge
                else if (dateField == 'Install__c') { eventType = 'INSTALL: '; colorId = '9'; } //blue
                else if (dateField == 'Inspection__c') { eventType = 'INSPECTION: '; colorId = '10'; } //green
                else if (dateField == 'Survey__c') { eventType = 'SURVEY: '; colorId = '10'; } //green

                //build the location based on the property address  
                String location = project.Sales_Order__r.Property__r.Name;
                if (project.Sales_Order__r.Property__r.Property_Address_2__c != null) {
                    location += ', ' + project.Sales_Order__r.Property__r.Property_Address_2__c;
                }
                location += ', ' + project.Sales_Order__r.Property__r.Property_City__c;
                location += ', ' + project.Sales_Order__r.Property__r.Property_State__c;
                location += '  ' + project.Sales_Order__r.Property__r.Property_ZIP__c;

                //              
                GoogleCalendarV3.CalendarEvent evt = new GoogleCalendarV3.CalendarEvent();
                evt.kind = 'calendar#event';
                evt.summary = eventType + project.Name + ' [ASTRUM PM SANDBOX]';
                evt.location = location;
                evt.attendees = new List<GoogleCalendarV3.CalendarUser>();
                evt.colorId = colorId; 
                evt.start = new GoogleCalendarV3.CalendarDate();
                evt.gEnd = new GoogleCalendarV3.CalendarDate();
                Datetime start = Datetime.newInstance(Long.valueOf(projectDate));
                if (dateField == 'Kickoff__c' || dateField == 'Inspection__c' || dateField == 'Survey_Date__c') { //date time
                    evt.start.gDateTime = start;
                    evt.gEnd.gDateTime = start
                        .addHours(dateField == 'Kickoff__c' ? DEFAULT_KICKOFF_DURATION : DEFAULT_INSPECTION_DURATION);
                } else { //date
                    evt.start.gDate = start.date();
                    evt.gEnd.gDate = evt.start.gDate;
                }
                evt.extendedProperties = new GoogleCalendarV3.ExtendedProperties();
                evt.extendedProperties.gPrivate = new GoogleCalendarV3.PrivateData();
                evt.extendedProperties.gPrivate.orgId = UserInfo.getOrganizationId();
                evt.extendedProperties.gPrivate.projectId = projectId;
                evt.extendedProperties.gPrivate.projectDateField = dateField;
                
                JSONGenerator generator = JSON.createGenerator(true);
                evt.serialize(generator);
                System.debug(generator.getAsString());
            
                gCal.insertEvent(evt);
            }
        
        } catch (Exception e) {
            //display detailed message in Monitoring > Apex Jobs
            System.assert(false, 'PROJECTID=' + projectId + '; DATEFIELD=' + dateField + '; PROJECTDATE=' + projectDate + '; EXCEPTION=' + e.getMessage() + ' ' + e.getStackTraceString()); 
        }
        
    } 
    
    //set the customer action note/resolution flag
    @RemoteAction
    public static void updateCustomerAction(Id projectId, String customerNote, Boolean resolved) { 
        PM_Project__c project = new PM_Project__c ( 
            Id = projectId, 
            Customer_Action_Notes__c = customerNote,
            Customer_Action_Resolved__c = resolved
        );
        update project;
    }

    //MIS-212 PB 01/28/2016
    @RemoteAction
    public static void updateSurveyEventDate(Id projectId, String dt) {
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

    //sets or clears the ready for install checkbox on the project
    @RemoteAction
    public static void setReadyForInstall(Id projectId, Boolean value) { 
        PM_Project__c project = new PM_Project__c ( Id = projectId, Ready_for_Install__c = value );
        update project;
    }
    
    private static Map<String, String> prefixSettingMap = new Map<String, String> {
        'status' => 'Status_Filter__c',
        'state' => 'State_Filter__c',
        'office' => 'Office_Filter__c',
        'lead' => 'Project_Lead_Filter__c',        
        'surveyor' => 'Surveyor_Filter__c',
        'sostatus'=> 'SOStatus_Filter__c',
        'designer'=> 'Designer_Filter__c',
        'engineer'=> 'Engineer_Filter__c',
        'install'=> 'Install_Filter__c'
    };
    
    public List<String> getdefaultFilter() {
        List<String> result = new List<String>();
        AstrumPM2__c setting = AstrumPM2__c.getValues(UserInfo.getUserId());
        for (String prefix : prefixSettingMap.keySet()) {
            if (setting != null) {
                String value = (String)setting.get(prefixSettingMap.get(prefix));
                if (value != null) {
                    result.add (prefix + ':' + value);
                }
            }
        }
        return result;
    }
    
    @RemoteAction
    public static void setDefaultFilter(String prefix, String value) {
        AstrumPM2__c setting = AstrumPM2__c.getValues(UserInfo.getUserId());
        if (setting == null) {
            setting = new AstrumPM2__c();
            setting.SetupOwnerId = UserInfo.getUserId();
        }
        setting.put(prefixSettingMap.get(prefix), value);
        if (setting.Id == null) {
            insert setting;
        } else {
            update setting;
        }
    }
    
    // Added by RJ
    
     
   @RemoteAction
  public static List<PM_Project_Issue__c> getOpenElectricIssueCount(PM_Project__c project) {
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
  public static List<PM_Project_Issue__c> getFixedElectricIssueCount(PM_Project__c project) {
    List<PM_Project_Issue__c> issues =
      [SELECT Id , LastModifiedDate
      FROM PM_Project_Issue__c
      WHERE PM_Project__c = :project.Id
      AND Status__c = 'Fixed'
      AND Bin__c = 'Electrical Review' 
      LIMIT 1];
    return issues;
   }
    
    //returns the projects by status using filters, if passed in
    @RemoteAction
    public static List<PM_Project__c> getProjects(String appName, String status, List<String> filters) {

        List<String> statuses = new List<String>();
        List<String> statusClauses = new List<String>();
        List<String> states = new List<String>();
        List<String> offices = new List<String>();      
        List<String> projectLeads = new List<String>();
        List<String> operationsSurveyors = new List<String>();
        List<String> elecDesigners = new List<String>();
        List<String> engineers = new List<String>();
        String readyForInstall ='';
        List<String> soStatuses = new List<String>();
        /*Set<String> SUBMITTED_CR = new Set<String> {
        'Submitted', 'Submitted for Electrical Review', 'Master Electrician Approved', 'Master Electrician Rejected', 'Submitted to Accounting', 'Accounting Rejected' 
        };
        Set<String> APPROVED_CR = new Set<String> {
        'Approved/Pending', 'Completion Approval Pending', 'Completion Approval Rejected', 'Completion Pending Accounting', 'Completion Accounting Rejected' 
        };
        Set<String> COMPLETED_CR = new Set<String> {
        'Complete/Ready for Install' 
        };
        */
       
        
        //add the filters values to the right collections
        for (String filter : filters) {
            String[] parts = filter.split(':');
            if (parts[1] == 'All') {
                continue;
            }
            if (parts[0] == 'status') {
                String clause = milestoneStatusMap.get(parts[1]);
                if (clause == null) {
                    statuses.add(parts[1]);
                } else {
                    statusClauses.add(clause);
                }
            } else if (parts[0] == 'state') {
                states.add(parts[1]);
            } else if (parts[0] == 'office') {
                offices.add(parts[1]);
            } else if (parts[0] == 'lead') {
                projectLeads.add(parts[1]);
            } else if (parts[0] == 'surveyor') {
                operationsSurveyors.add(parts[1]);
            } else if (parts[0] == 'sostatus') {
                soStatuses.add(parts[1]);
            } else if (parts[0] == 'designer') {
                elecDesigners.add(parts[1]);
            } else if (parts[0] == 'engineer') {
                engineers.add(parts[1]);
            } else if (parts[0] == 'install') {
                readyForInstall = parts[1];
            } 


        }
        
        //build the query
        String query = 'SELECT Id, Name';
        query += ',Sales_Order__r.Property__r.Name,Sales_Order__r.Property__r.Property_City__c,Sales_Order__r.Property__r.Property_State__c,Sales_Order__r.Property__r.Property_County__c,Sales_Order__r.Property__r.Astrum_Office__c';
        query += ',Sales_Order__r.Financing_Type__c,Project_Lead__r.Name,Constellation_Tranche__c';
        query += ',Customer_Action_Notes__c,Customer_Action_Resolved__c,CR_Status__c, Lease_Funding_Status__C ,Handoff_Checklist_Status__c,Sales_Order__r.Lease_PPA_Fund__c ';
        
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
        query += ',(SELECT Id, Bin__c, Description__c, LastModifiedDate,Status__c,To__c FROM PM_Project_Issues__r WHERE (Status__c = \'Open\')';
        query += ' OR (Status__c = \'Fixed\') Order by Status__C )';           
        query += ',(SELECT Bin__c From Astrum_Docs__r WHERE IsNote__c = true)';

        //MIS-212 PB 01/28/2016
        Id recId = Schema.Sobjecttype.Event.getRecordTypeInfosByName().get('Site Survey Onsite').getRecordTypeId();        
        query += ',(SELECT Id, EndDateTime, Completed__c ';
        query += ' FROM Events ';
        query += ' WHERE RecordTypeId=:recId ';
        query += ' AND Site_Survey_Type__c =\'Site Survey Onsite\'';        
        query += ' ORDER BY CreatedDate DESC ';
        query += ' LIMIT 1 )';

        query += ' FROM PM_Project__c WHERE Status__c = :status';

        //add filters to the query
        if (statuses.size() > 0) {
            query += ' AND Status__c IN :statuses';
        }
        if (statusClauses.size() > 0) {
            query += ' AND (';
            for (Integer i = 0; i < statusClauses.size(); i++) {
                if (i > 0) {
                    query += ' OR';
                }
                query += statusClauses[i];
            }
            query += ')'; 
        }
        if (states.size() > 0) {
            query += ' AND Sales_Order__r.Property__r.Property_State__c IN :states';
        }
        if (offices.size() > 0) {
            query += ' AND Sales_Order__r.Property__r.Astrum_Office__c IN :offices';
        }
        if (projectLeads.size() > 0) {
            query += ' AND Project_Lead__r.Name IN :projectLeads';
        }
        if (operationsSurveyors.size() > 0) {
            query += ' AND System_Designer__r.Name IN :operationsSurveyors';
        }
        if (soStatuses.size() > 0) {
            query += ' AND Sales_Order__r.StatusCode__c IN :soStatuses';
        }
        if (elecDesigners.size() > 0) {
            query += ' AND Electrical_Designer__r.Name IN :elecDesigners';
        }
        if (engineers.size() > 0) {
            query += ' AND Project_Engineer__r.Name IN :engineers';
        }
        if (String.isNotBlank(readyForInstall)) {
            if(readyForInstall.equalsIgnoreCase('Ready for Install')){
                query += ' AND Ready_for_Installation__c = true';

            }else if(readyForInstall.equalsIgnoreCase('Not ready for Install')){
                query += ' AND Ready_for_Installation__c = false';
            }            
        }
        
        query += ' ORDER BY Name ';
        //query += ' LIMIT 1000 ';
        List<PM_Project__c> projects = Database.query(query);

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
                                      AND  PM_Project__c IN :projects                                                           
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
                                      AND  PM_Project__c IN :projects                                                           
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
                                      AND  PM_Project__c IN :projects 
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
        
        
        
        String LeaseFundId;
        for(Lease_Fund__c lf : [SELECT Id FROM Lease_Fund__c WHERE Name = 'NRG Residential Solar Solutions, LLC'])
        {
        	LeaseFundId = lf.Id;
        }     
        
        for (PM_Project__c project : projects) {
            PM_Project_Issue__c electricOpen = openElectricIssueMap.get(project.Id);   //getOpenElectricIssueCount(project);
            PM_Project_Issue__c electricFix =  FixedElectricIssueMap.get(project.Id);    //getFixedElectricIssueCount(project);
              
            System.debug('*** Fix-'+electricFix );   
            Integer openElectricIssue = (electricOpen !=null ? 1 : 0);   //electricOpen.size();
            Integer fixElectricIssue =  (electricFix !=null ? 1 : 0);
                                  
            //System.debug('* CR Status -'+ projectCRStatusMap.get(project.id)); 
            project.put('CR_Status__c',projectCRStatusMap.get(project.id));
            project.put('Lease_Funding_Status__c',project.Lease_Funding_Status__C);            
            
            //project.put('Lease_Fund__c',project.Sales_Order__r.Lease_Fund__c);
            if(project.Sales_Order__r.Lease_PPA_Fund__c == LeaseFundId && project.Lease_Approval_To_Inspect__c == null )
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
            
            System.debug('*** project.Handoff_Checklist_Status__c - '+project.Handoff_Checklist_Status__c ); 
            
            // Logic for Handoff to Customer Care
            if(project.Handoff_Checklist_Status__c == 'Completed' && project.Customer_Care_Handoff__c != null )
            {
                project.put('Customer_Care_Handoff__c', project.Customer_Care_Handoff__c.addYears(6000));
            
            }
            else if (project.Handoff_Checklist_Status__c == 'Rejected' && project.Customer_Care_Handoff__c != null )
            {
            
                project.put('Customer_Care_Handoff__c', project.Customer_Care_Handoff__c.addYears(16000));
            }
            System.debug('*** project - '+project.Name ); 
            
            for (String specialBin : specialBins) {
                Date dt = (Date)project.get(specialBin);
                if (dt == null) {
                    for (DocumentConfigurationHelper.SpecialCategory sc : specialCategories) {
                        if (sc.binDateFieldName == specialBin) {
                            Date dt2 = (Date)project.get(sc.categoryDateFieldName);                          
                            if (dt2 != null && sc.binState != null) {
                                System.debug('$$ '+sc.binDateFieldName+' '+sc.binState);   
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
                 System.debug('*** end project - '+project.Name );    
            }
        }
        
        return projects;
    }
    
    
    
    ////////// GOOGLE CALENDAR SYNCHRONIZATION
    
    private static Map<String, String> updateFieldMap = new Map<String, String> {
        'Kickoff__c' => 'Kickoff_Last_Updated__c',
        'Install__c' => 'Install_Last_Updated__c',
        'Inspection__c' => 'Inspection_Last_Updated__c'
        //,'Survey_Date__c' => 'Survey_Date_Last_Updated__c'
    };
    
    public Boolean hasSync { 
        get { 
            return !ApexPages.hasMessages() && (projectIdsToUpdate.size() > 0 || eventIdsToDelete.size() > 0 || eventsToUpdate.size() > 0 || eventsToAdd.size() > 0);
        }
    }
    
    //projects to updated
    private Set<Id> projectIdsToUpdate = new Set<Id>();
    private List<PM_Project__c> projectsToUpdate = new List<PM_Project__c>();
        
    //google event ids to delete
    private List<String> eventIdsToDelete = new List<String>();
    private List<GoogleCalendarV3.CalendarEvent> eventsToUpdate = new List<GoogleCalendarV3.CalendarEvent>();

    private List<GoogleCalendarV3.CalendarEvent> eventsToAdd = new List<GoogleCalendarV3.CalendarEvent>();
    
    public PageReference synchronizeEvents() {

        if (projectIdsToUpdate.size() == 0 && eventIdsToDelete.size() == 0 && eventsToUpdate.size() == 0 && eventsToAdd.size() == 0) {
            buildSyncEvents();
        }

        System.debug(String.format('Projects to update: {0}\nEvents to delete: {1}\nEvents to update: {2}\nEvents to add: {3}',
            new String[] { 
                String.valueOf(projectIdsToUpdate.size()), 
                String.valueOf(eventIdsToDelete.size()),
                String.valueOf(eventsToUpdate.size()), 
                String.valueOf(eventsToAdd.size()) 
            })
        );

        processSyncEvents();

        System.debug(String.format('Projects left to update: {0}\nEvents to delete: {1}\nEvents to update: {2}\nEvents to add: {3}',
            new String[] { 
                String.valueOf(projectIdsToUpdate.size()), 
                String.valueOf(eventIdsToDelete.size()),
                String.valueOf(eventsToUpdate.size()), 
                String.valueOf(eventsToAdd.size()) 
            })
        );
        
        return null;
    
    }
        
    //get all projects in last 90 days and those updated in last 90 days
    private void buildSyncEvents () {
            
        DateTime start = DateTime.now().addDays(-90);
        
        Set<String> eventKeys = new Set<String>();  //eventId|field
        
//TODO: only your active projects
        Map<Id, PM_Project__c> projectMap = new Map<Id, PM_Project__c>(
            [SELECT Id, Name, Kickoff__c, Install__c, Inspection__c,Survey_Date__c,Approval_Date__c, 
                Kickoff_Last_Updated__c, Install_Last_Updated__c, Inspection_Last_Updated__c,
                Sales_Order__r.Property__r.Name,  
                Sales_Order__r.Property__r.Property_Address_2__c,
                Sales_Order__r.Property__r.Property_City__c,
                Sales_Order__r.Property__r.Property_State__c,
                Sales_Order__r.Property__r.Property_ZIP__c
            FROM PM_Project__c
            WHERE Status__c = 'Active']
        );
            
        GoogleCalendarV3.CalendarEvents events = gCal.getEvents(start);
        
        for (GoogleCalendarV3.CalendarEvent event : events.items) {
            if (event.extendedProperties == null || event.extendedProperties.gPrivate == null
            || (event.extendedProperties.gPrivate.orgId != null && event.extendedProperties.gPrivate.orgId != UserInfo.getOrganizationId())) {
                continue;
            }

            PM_Project__c project = projectMap.get(event.extendedProperties.gPrivate.projectId);
            String projectDateField = event.extendedProperties.gPrivate.projectDateField;
            if (!updateFieldMap.keyset().contains(projectDateField)) {
                continue;
            }
            

            if (project != null) {
                eventKeys.add(project.Id + '|' + projectDateField);
                object projDate = project.get(projectDateField);
                if (projDate == null) {
                    eventIdsToDelete.add(event.id);
                    continue;
                }
                object googleDate;
                if (projectDateField == 'Kickoff__c' || projectDateField == 'Inspection__c' || projectDateField == 'Survey_Date__c') { //date time
                    googleDate = event.start.gDateTime;
                } else { //date
                    googleDate = event.start.gDate;
                    if (googleDate == null) { 
                        googleDate = event.start.gDateTime.date();
                    }
                }
                if (googleDate == null || googleDate == projDate) {
                    continue;
                }
                //use whichever was updated last as the date
                Datetime lastUpdated = (Datetime)project.get(updateFieldMap.get(projectDateField));
                if (event.updated > lastUpdated) {
                    project.put(projectDateField, googleDate);
                    if (!projectIdsToUpdate.contains(project.Id)) {
                        projectIdsToUpdate.add(project.Id);
                        projectsToUpdate.add(project);
                    }
                } else if (lastUpdated > event.updated) {
                    event.start = new GoogleCalendarV3.CalendarDate();
                    event.gEnd = new GoogleCalendarV3.CalendarDate();
                    if (projectDateField == 'Kickoff__c' || projectDateField == 'Inspection__c' || projectDateField == 'Survey_Date__c' ) { //date time
                        event.start.gDateTime = (Datetime)projDate;
                        event.gEnd.gDateTime = ((Datetime)projDate)
                            .addHours(projectDateField == 'Kickoff__c' ? DEFAULT_KICKOFF_DURATION : DEFAULT_INSPECTION_DURATION);
                    } else {
                        event.start.gDate = (Date)projDate;
                        event.gEnd.gDate = (Date)projDate;
                    }
                    event.extendedProperties.gPrivate.orgId = UserInfo.getOrganizationId();
                    eventsToUpdate.add(event);
                }                   
            }
        }
        
        for (PM_Project__c project : projectMap.values()) {
            for (String dateField : updateFieldMap.keySet()) {
                object projectDate = project.get(dateField);
                if (projectDate != null /* && projectDate >= start */ && !eventKeys.contains(project.Id + '|' + dateField)) {
                    
                    Date compareDate = (projectDate instanceof Datetime) ? ((Datetime)projectDate).date() : (Date)projectDate;
                    
                    if (compareDate < start.date()) {
                        continue;
                    }

                    String eventType, colorId;
                    if (dateField == 'Kickoff__c') { eventType = 'KICKOFF: '; colorId = '6'; }
                    else if (dateField == 'Install__c') { eventType = 'INSTALL: '; colorId = '9'; }
                    else if (dateField == 'Inspection__c') { eventType = 'INSPECTION: '; colorId = '10'; }
                    else if (dateField == 'Survey_Date__c') { eventType = 'SURVEY: '; colorId = '10'; }
    
                    String location = project.Sales_Order__r.Property__r.Name;
                    if (project.Sales_Order__r.Property__r.Property_Address_2__c != null) {
                        location += ', ' + project.Sales_Order__r.Property__r.Property_Address_2__c;
                    }
                    location += ', ' + project.Sales_Order__r.Property__r.Property_City__c;
                    location += ', ' + project.Sales_Order__r.Property__r.Property_State__c;
                    location += '  ' + project.Sales_Order__r.Property__r.Property_ZIP__c;
                
                    GoogleCalendarV3.CalendarEvent evt = new GoogleCalendarV3.CalendarEvent();
                    evt.kind = 'calendar#event';
                    evt.summary = eventType + project.Name + ' [ASTRUM PM SANDBOX]';
                    evt.location = location;
                    evt.attendees = new List<GoogleCalendarV3.CalendarUser>();
                    evt.colorId = colorId; 
                    evt.start = new GoogleCalendarV3.CalendarDate();
                    evt.gEnd = new GoogleCalendarV3.CalendarDate();
                    if (dateField != 'Kickoff__c' && dateField != 'Inspection__c' && dateField != 'Survey_Date__c' ) { //date only - all day event 
                        evt.start.gDate = (Date)projectDate;
                        evt.gEnd.gDate = (Date)projectDate;
                    } else {
                        evt.start.gDateTime = (Datetime)projectDate;
                        evt.gEnd.gDateTime = ((Datetime)projectDate)
                            .addHours(dateField == 'Kickoff__c' ? DEFAULT_KICKOFF_DURATION : DEFAULT_INSPECTION_DURATION);
                    }
                    evt.extendedProperties = new GoogleCalendarV3.ExtendedProperties();
                    evt.extendedProperties.gPrivate = new GoogleCalendarV3.PrivateData();
                    evt.extendedProperties.gPrivate.orgId = UserInfo.getOrganizationId();
                    evt.extendedProperties.gPrivate.projectId = project.Id;
                    evt.extendedProperties.gPrivate.projectDateField = dateField;
            
                    eventsToAdd.add(evt);
                }
            }
        }
                
    }
    
    private void processSyncEvents() {
        if (eventIdsToDelete.size() > 0 || eventsToUpdate.size() > 0 || eventsToAdd.size() > 0) {
            oauth.ensureAccessToken();
        }
        while (Limits.getLimitCallouts() - Limits.getCallouts() >= 1 && eventsToUpdate.size() > 0) {
            GoogleCalendarV3.CalendarEvent evt = eventsToUpdate.get(0);
            gCal.updateEvent(evt);
            eventsToUpdate.remove(0);
        }
        while (Limits.getLimitCallouts() - Limits.getCallouts() >= 1 && eventsToAdd.size() > 0) {
            GoogleCalendarV3.CalendarEvent evt = eventsToAdd.get(0);
            gCal.insertEvent(evt);
            eventsToAdd.remove(0);
        }
        while (Limits.getLimitCallouts() - Limits.getCallouts() >= 1 && eventIdsToDelete.size() > 0) {
            String eventId = eventIdsToDelete.get(0);
            gCal.deleteEvent(eventId);
            eventIdsToDelete.remove(0);
        }
        if (projectsToUpdate.size() > 0) {
            update projectsToUpdate;
            projectIdsToUpdate.clear();
            projectsToUpdate.clear();
        }
    }
    

}