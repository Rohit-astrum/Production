public class Milestone1_Task_Trigger_Utility {
    
    public static final string SUBSCRIPTION_LIMIT_EXCEEDED = 'Maximum per user chatter subscription limit has been exceeded';

    private static String ACCOUNTING_USER_EMAIL;
    private static String GRANT_USER_EMAIL;
    
    private static String PA_FIELD_MGR_OPS_USER_EMAIL;
    private static String MD_FIELD_MGR_OPS_USER_EMAIL;
    private static String OH_FIELD_MGR_OPS_USER_EMAIL;
    private static String MA_FIELD_MGR_OPS_USER_EMAIL;
    private static String NY_FIELD_MGR_OPS_USER_EMAIL;

    private static String PA_DIRECTOR_OPS_USER_EMAIL;
    private static String MD_DIRECTOR_OPS_USER_EMAIL;
    private static String OH_DIRECTOR_OPS_USER_EMAIL;
    private static String MA_DIRECTOR_OPS_USER_EMAIL;
    private static String NY_DIRECTOR_OPS_USER_EMAIL;
    
    public static final String PA_STATE_CODE = 'PA';
    public static final String MD_STATE_CODE = 'MD';
    public static final String OH_STATE_CODE = 'OH';    
    public static final String NY_STATE_CODE = 'NY';
    public static final String MA_STATE_CODE = 'MA';
        
    public static void handleTaskBeforeTrigger(List<Milestone1_Task__c> tasks){
        Map<Id, Milestone1_Milestone__c> taskMilestoneMap = getMilestonesForTasks(tasks);                   

        setAutoAssignEmailsFromCustomSettings();
        
        Set<String> projectIds = getProjectIds(tasks);
        
        Map<String, String> projectOffices = getProjectOffices(projectIds);
        
        Map<Id, List<Milestone1_Task__c>> allTasks = getAllTasksForProjects(projectIds);

        List<User> autoAssignUsers = getAutoAssignUsers();
               
        for(Milestone1_Task__c tempTask : tasks ){
            Milestone1_Milestone__c parentMilestone = taskMilestoneMap.get(tempTask.Project_Milestone__c);
                
            setTaskIndex(tempTask);     
                      
            setTaskDueDate(tempTask, parentMilestone);
                        
            setTaskStartDate(tempTask, parentMilestone);
            
            setTaskAssignedToCurrentUser(tempTask);
            
            setTaskDaysLate(tempTask); 
            
            handleReviewPreInstallSteps(tempTask, projectOffices, autoAssignUsers);                                                     
        }
    }

    public static void setProjectKeyDates(List<Milestone1_Task__c> tasks) {
        //TODO: Finish logic to set the four key dates in the project when the relevant tasks are complete
        Set<String> projectIds = getProjectIds(tasks);
        Map <Id,Milestone1_Project__c> projs = new Map <Id, Milestone1_Project__c>([Select id, Paid_In_Full_Date__c, Installation_Start_Date__c, Installation_Completion_Date__c, Inspection_Date__c, Install_Work_Complete__c From Milestone1_Project__c where id in :projectIds]);
        List<Milestone1_Task__c> installTasks = [SELECT id, ProjectId__c, Complete__c, Complete_Date__c, Workflow_Key__c FROM Milestone1_Task__c WHERE (Workflow_Key__c ='t_panel_work_complete' OR Workflow_Key__c ='t_electric_work_complete') AND ProjectId__c in :projectIds];
        
        for(Milestone1_Task__c tempTask : tasks) {
                Milestone1_Project__c proj = projs.get(tempTask.ProjectId__c);
                
                Date installDate = proj.Installation_Completion_Date__c;
                String installString = proj.Install_Work_Complete__c;
                Boolean hasInstallDate = false;
                String projIdString = proj.id;
                projIdString = projIdString.substring(0,15);
                
                if(tempTask.Workflow_Key__c =='t_installation_begins'){
                    proj.Installation_Start_Date__c = tempTask.Complete_Date__c;    
                } else if (tempTask.Workflow_Key__c =='t_panel_work_complete'){
                    if(installString=='ELECTRICAL'&&tempTask.Complete__c){
                        installString='PANELS,ELECTRICAL';
                        if(proj.Installation_Completion_Date__c < tempTask.Complete_Date__c){
                            proj.Installation_Completion_Date__c = tempTask.Complete_Date__c;
                        }
                    } else if(installString=='ELECTRICAL'){
                        installString='ELECTRICAL';
                        for(Milestone1_Task__c instTask : installTasks){
                            if(instTask.ProjectId__c==projIdString&&instTask.Workflow_Key__c =='t_electric_work_complete'&&instTask.Complete__c){
                                proj.Installation_Completion_Date__c = instTask.Complete_Date__c;
                            }
                        }
                    } else if(installString=='PANELS,ELECTRICAL'&&!tempTask.Complete__c){
                        installString='ELECTRICAL';
                        for(Milestone1_Task__c instTask : installTasks){
                            if(instTask.ProjectId__c==projIdString&&instTask.Workflow_Key__c =='t_electric_work_complete'&&instTask.Complete__c){
                                proj.Installation_Completion_Date__c = instTask.Complete_Date__c;
                            }
                        }
                    } else if(tempTask.Complete__c){
                        if(installString=='PANELS,ELECTRICAL'){
                            installString='PANELS,ELECTRICAL';
                        } else {
                            installString='PANELS';
                        }
                        proj.Installation_Completion_Date__c = tempTask.Complete_Date__c;
                    } else {
                        installString='';
                        proj.Installation_Completion_Date__c = null;
                    }                    
                    System.debug('PANEL WORK -- Install Complete Date: '+proj.Installation_Completion_Date__c);
                    proj.Install_Work_Complete__c = installString;
                    System.debug('PANEL WORK -- Install Complete String: '+proj.Install_Work_Complete__c);
                } else if (tempTask.Workflow_Key__c =='t_electric_work_complete'){
                    if(installString=='PANELS'&&tempTask.Complete__c){
                        installString='PANELS,ELECTRICAL';
                        if(proj.Installation_Completion_Date__c < tempTask.Complete_Date__c){
                            proj.Installation_Completion_Date__c = tempTask.Complete_Date__c;
                        }
                    } else if(installString=='PANELS'){
                        installString='PANELS';
                        for(Milestone1_Task__c instTask : installTasks){
                            if(instTask.ProjectId__c==projIdString&&instTask.Workflow_Key__c =='t_panel_work_complete'&&instTask.Complete__c){
                                proj.Installation_Completion_Date__c = instTask.Complete_Date__c;
                            }
                        }
                    } else if(installString=='PANELS,ELECTRICAL'&&!tempTask.Complete__c){
                        installString='PANELS';
                        for(Milestone1_Task__c instTask : installTasks){
                            if(instTask.ProjectId__c==projIdString&&instTask.Workflow_Key__c =='t_panel_work_complete'&&instTask.Complete__c){
                                proj.Installation_Completion_Date__c = instTask.Complete_Date__c;
                            }
                        }
                    } else if(tempTask.Complete__c){
                        if(installString=='PANELS,ELECTRICAL'){
                            installString='PANELS,ELECTRICAL';
                        } else {
                            installString='ELECTRICAL';
                        }
                        proj.Installation_Completion_Date__c = tempTask.Complete_Date__c;
                    } else {
                        installString='';
                        proj.Installation_Completion_Date__c = null;
                    } 
                    
                    System.debug('ELECTRICAL WORK -- Install Complete Date: '+proj.Installation_Completion_Date__c);
                    proj.Install_Work_Complete__c = installString;
                    System.debug('ELECTRICAL WORK -- Install Complete String: '+proj.Install_Work_Complete__c);
                } else if (tempTask.Workflow_Key__c =='t_inspection_complete') {
                    proj.Inspection_Date__c = tempTask.Complete_Date__c;
                } else if (tempTask.Workflow_Key__c =='t_final_30_received') {
                    proj.Paid_In_Full_Date__c = tempTask.Complete_Date__c;
                }       
                update(proj);    
        }
    }
        
    private static void handleReviewPreInstallSteps(Milestone1_Task__c tempTask, Map<String, String> projectOffices, List<User> autoAssignUsers) {
                    
        Boolean taskMatch = tempTask.Workflow_Key__c == Milestone1_Task_AutoAssignment_Utility.REVIEW_PREINSTALL_STEPS_WORK_FLOW_KEY;

        if (taskMatch) {

            String projectId = tempTask.projectId__c;           
            String office = projectOffices.get(projectId);
            String officeStateCode = null;
            User directorOpsUser = null;

            if (office != null) {
                officeStateCode = Milestone1_General_Utility.getStateFromAstrumOffice(office);
                directorOpsUser = getDirectorOps(autoAssignUsers, officeStateCode);
                
                if (directorOpsUser != null) {          
                    tempTask.Assigned_To__c = directorOpsUser.Id;
                }       
            }       
        }
    }
    
    private static void setTaskIndex(Milestone1_Task__c task) {
        if( task.Index_Helper__c.length() > 255 ){ 
            task.Index__c = task.Index_Helper__c.substring(0, 255); 
        } 
        else { 
            task.Index__c = task.Index_Helper__c; 
        }       
    }
    
    private static void setTaskDueDate(Milestone1_Task__c task, Milestone1_Milestone__c parentMilestone) {
        if (task.Due_Date__c == null ) {
            if (parentMilestone != null) { 
                task.Due_Date__c = parentMilestone.Deadline__c; 
            }
        }       
    }

    private static void setTaskStartDate(Milestone1_Task__c task, Milestone1_Milestone__c parentMilestone) {
        if (task.Start_Date__c == null) {
            if (parentMilestone != null) {
                task.Start_Date__c = parentMilestone.KickOff__c;                
            }
            
            if (task.Start_Date__c == null || task.Start_Date__c < Date.TODAY()) {
                task.Start_Date__c = Date.Today();
            }            
        }       
    }
    
    private static void setTaskAssignedToCurrentUser(Milestone1_Task__c task) {
        if (task.Assigned_To__c == null) {
            task.Assigned_To__c = UserInfo.getUserId();
        }
    }

    private static void setTaskDaysLate(Milestone1_Task__c task) {
       if (task.Days_Late_Formula__c > 0) {
            task.Days_Late__c = task.Days_Late_Formula__c;
        } else {
            task.Days_Late__c = 0; 
        }       
    }   
            
    public static List<User> getAutoAssignUsers() {
        List <User> users = [SELECT Id, FirstName, LastName, email 
                               FROM User u 
                               WHERE 
                               email like :ACCOUNTING_USER_EMAIL + '%'
                               or email like :GRANT_USER_EMAIL + '%'
                               or email like :PA_FIELD_MGR_OPS_USER_EMAIL + '%'
                               or email like :MD_FIELD_MGR_OPS_USER_EMAIL + '%'
                               or email like :OH_FIELD_MGR_OPS_USER_EMAIL + '%'
                               or email like :NY_FIELD_MGR_OPS_USER_EMAIL + '%'
                               or email like :MA_FIELD_MGR_OPS_USER_EMAIL + '%'
                               or email like :PA_DIRECTOR_OPS_USER_EMAIL + '%'
                               or email like :MD_DIRECTOR_OPS_USER_EMAIL + '%'
                               or email like :OH_DIRECTOR_OPS_USER_EMAIL + '%'
                               or email like :NY_DIRECTOR_OPS_USER_EMAIL + '%'
                               or email like :MA_DIRECTOR_OPS_USER_EMAIL + '%'
                               ];

        return users;
    }
    
    public static Map<String, String> getProjectOffices(Set<String> projectIds) {
        Map<String, String> projectOffices = new Map<String, String>();
        
        List<Milestone1_Project__c> projects = [Select id, Astrum_Office__c From Milestone1_Project__c where id in :projectIds];
        
        for (Milestone1_Project__c tempProject : projects) {
            String projectId = Milestone1_General_Utility.truncateId(tempProject.Id);
            String officeName = tempProject.Astrum_Office__c;
            
            projectOffices.put(projectId, officeName);  
        }
        
        return projectOffices;
    }

    public static void setAutoAssignEmailsFromCustomSettings() {
        Milestone1_Settings__c milestoneCustomSettings = Milestone1_Settings__c.getOrgDefaults();
        
        ACCOUNTING_USER_EMAIL = milestoneCustomSettings.Task_Auto_Assign_Accounting_User__c;
        GRANT_USER_EMAIL = milestoneCustomSettings.Task_Auto_Assign_Grants_User__c;
        
        PA_FIELD_MGR_OPS_USER_EMAIL = milestoneCustomSettings.Task_Auto_Assign_PA_Field_Manager_Ops__c;
        MD_FIELD_MGR_OPS_USER_EMAIL = milestoneCustomSettings.Task_Auto_Assign_MD_Field_Manager_Ops__c;
        OH_FIELD_MGR_OPS_USER_EMAIL = milestoneCustomSettings.Task_Auto_Assign_OH_Field_Manager_Ops__c;
        MA_FIELD_MGR_OPS_USER_EMAIL = milestoneCustomSettings.Task_Auto_Assign_MA_Field_Manager_Ops__c;
        NY_FIELD_MGR_OPS_USER_EMAIL = milestoneCustomSettings.Task_Auto_Assign_NY_Field_Manager_Ops__c;

        PA_DIRECTOR_OPS_USER_EMAIL = milestoneCustomSettings.Task_Auto_Assign_PA_Director_of_Ops__c;
        MD_DIRECTOR_OPS_USER_EMAIL = milestoneCustomSettings.Task_Auto_Assign_MD_Director_of_Ops__c;
        OH_DIRECTOR_OPS_USER_EMAIL = milestoneCustomSettings.Task_Auto_Assign_OH_Director_of_Ops__c;
        MA_DIRECTOR_OPS_USER_EMAIL = milestoneCustomSettings.Task_Auto_Assign_MA_Director_of_Ops__c;
        NY_DIRECTOR_OPS_USER_EMAIL = milestoneCustomSettings.Task_Auto_Assign_NY_Director_of_Ops__c;                
    }
    
    
    public static void performTaskAutoAssignment(List<Milestone1_Task__c> tasks){

        setAutoAssignEmailsFromCustomSettings();
        
        Set<String> projectIds = getProjectIds(tasks);
        
        Map<String, String> projectOffices = getProjectOffices(projectIds);
        
        Map<Id, List<Milestone1_Task__c>> allTasks = getAllTasksForProjects(projectIds);

        List<User> autoAssignUsers = getAutoAssignUsers();
        
        User accountingUser = getUser(autoAssignUsers, ACCOUNTING_USER_EMAIL);
        User grantUser = getUser(autoAssignUsers, GRANT_USER_EMAIL);
                
        for(Milestone1_Task__c tempTask : tasks){

            String projectId = tempTask.projectId__c;           
            String office = projectOffices.get(projectId);
            String officeStateCode = null;
            User fieldManagerUser = null;
                        
            if (office != null) {
                officeStateCode = Milestone1_General_Utility.getStateFromAstrumOffice(office);
                fieldManagerUser = getFieldManagerOps(autoAssignUsers, officeStateCode);
            }
                        
            List<Milestone1_Task__c> tasksForThisProject = allTasks.get(projectId);
            Milestone1_Task_AutoAssignment_Utility.performTaskAutoAssignment(tempTask, tasksForThisProject, accountingUser, grantUser, fieldManagerUser);
        }       
    }
    
    public static User getFieldManagerOps(List<User> users,  String state) {
        User theUser = null;
        
        String theEmail = null;

        if (state == null) {
            return null;    
        }   
            
        // determine which email to use
        if (state == PA_STATE_CODE) {
            theEmail =  PA_FIELD_MGR_OPS_USER_EMAIL;
        }
        else if (state == MD_STATE_CODE) {
            theEmail = MD_FIELD_MGR_OPS_USER_EMAIL;
        }
        else if (state == OH_STATE_CODE) {
            theEmail = OH_FIELD_MGR_OPS_USER_EMAIL;
        }
        else if (state == NY_STATE_CODE) {
            theEmail = NY_FIELD_MGR_OPS_USER_EMAIL;
        }
        else if (state == MA_STATE_CODE) {
            theEmail = MA_FIELD_MGR_OPS_USER_EMAIL;
        }
        else {
            // default to MD
            theEmail = MD_FIELD_MGR_OPS_USER_EMAIL;
        }
        
        theUser = getUser(users, theEmail);
                
        return theUser; 
    }

    public static User getDirectorOps(List<User> users,  String state) {
        User theUser = null;
        
        String theEmail = null;

        if (state == null) {
            return null;    
        }   
            
        // determine which email to use
        if (state == PA_STATE_CODE) {
            theEmail =  PA_DIRECTOR_OPS_USER_EMAIL;
        }
        else if (state == MD_STATE_CODE) {
            theEmail = MD_DIRECTOR_OPS_USER_EMAIL;
        }
        else if (state == OH_STATE_CODE) {
            theEmail = OH_DIRECTOR_OPS_USER_EMAIL;
        }
        else if (state == NY_STATE_CODE) {
            theEmail = NY_DIRECTOR_OPS_USER_EMAIL;
        }
        else if (state == MA_STATE_CODE) {
            theEmail = MA_DIRECTOR_OPS_USER_EMAIL;
        }
        else {
            // default to MD
            theEmail = MD_DIRECTOR_OPS_USER_EMAIL;
        }
        
        theUser = getUser(users, theEmail);
                
        return theUser; 
    }

    private static User getUser(List<User> users, String email) {
        User theUser = null;
        
        // get the user from the list, based on email address
        for (User tempUser : users) {           
            if (tempUser.Email.startsWith(email)) {
                theUser = tempUser;
                break;
            }   
        }
        
        return theUser;
    }    
    
    
    /**
    * This method prevent task creations for Users w/o Permissions over parent Milestone of task.
    * Checks if OWD for Milestone1_Milestone__c object are Private and then, checks if the current User have read/write permissons.
    * The way to do it its if Milestone1_Milestone__share exist, so we need do a QueryString to avoid compilations errors if that Object doesn't exist.
    * @params       taskList
    * @return       boolean
    * @author       Sebastian Muñoz
    * @createDate   January 19, 2011
    */
    public static Boolean checkOWDPermissions( List<Milestone1_Task__c> taskList ){
        
        //First of all, if the User is a SysAdmin and we are not runing a Test, leave this method.
        List<Sobject> obj_share = new List<Sobject>();  
        if( Milestone1_General_Utility.isSysAdmin() && !Test.isRunningTest() ){
            return true;
        } 
        else if( Schema.getGlobalDescribe().get('Milestone1_Milestone__Share') != null ){
            String inClause = '(';
            for( Milestone1_Task__c cTask : taskList ){
                inClause += '\'' + cTask.Project_Milestone__c + '\',';
            }             
            inClause = inClause.substring( 0, inClause.length() - 1 );
            inClause += ')';
            
            String queryStr = 'Select m.UserOrGroupId, m.RowCause, m.ParentId, m.AccessLevel From Milestone1_Milestone__Share m';
            queryStr        += ' where m.ParentId IN '+ inClause +' AND m.UserOrGroupId = \''+ Userinfo.getUserId() +'\' AND m.AccessLevel = \'Read\'';
            obj_share = Database.query( queryStr );
            
            return obj_share.isEmpty();
        }
        return true;
    }
    
    public static void checkMilestonesForAutoComplete(List<Milestone1_Task__c> tasks) {
            
        Map<Id, Milestone1_Milestone__c> milestones = getMilestonesForTasks(tasks);
        Map<Id, List<Milestone1_Task__c>> allTasks = getAllTasksForMilestones(milestones.values());
                
        List<Milestone1_Milestone__c> milestonesToUpdate = new List<Milestone1_Milestone__c>();
        
        for (Id tempMilestoneId : allTasks.keySet()) {
            List<Milestone1_Task__c> tempTasks = allTasks.get(tempMilestoneId);
            boolean milestoneReadyForUpdate = isMilestoneReadyForAutoComplete(tempTasks);
            
            System.debug('milestoneReadyForUpdate = ' + milestoneReadyForUpdate);
            
            if (milestoneReadyForUpdate) {
                Milestone1_Milestone__c tempMilestone = milestones.get(tempMilestoneId);

                tempMilestone.Complete__c = true;
                tempMilestone.Complete_Date__c = Date.today();      
                
                milestonesToUpdate.add(tempMilestone);              
            }           
        }

        if (!milestonesToUpdate.isEmpty()) {
            update milestonesToUpdate;
        }       
        
    }
    
    public static Boolean isMilestoneReadyForAutoComplete(List<Milestone1_Task__c> tasksForMilestone) {
        Boolean result = false;

        for (Milestone1_Task__c tempTask : tasksForMilestone) {
            result = tempTask.Complete__c;
            
            if (!result) {
                break;
            }   
        }
        
        return result;
    }

    
    public static Map<Id, Milestone1_Milestone__c> getMilestonesForTasks(List<Milestone1_Task__c> tasks) {
                
        List<Id> milestoneIds = getMilestoneIds(tasks);
                
        Map<Id, Milestone1_Milestone__c> milestones = new Map<Id, Milestone1_Milestone__c>([Select Id, Name, Deadline__c, KickOff__c, Complete__c, Complete_Date__c 
                                                                                            from Milestone1_Milestone__c 
                                                                                            where id IN :milestoneIds]);
        
        return milestones;
    } 
    
    /**
     * Build a map of tasks based on project id
     */
    public static Map<Id, List<Milestone1_Task__c>> getAllTasksForProjects(Set<String> projectIds) {
        Map<Id, List<Milestone1_Task__c>> projectsTaskMap = new Map<Id, List<Milestone1_Task__c>>();

        List<Milestone1_Task__c> allTasks = [Select Name, Complete__c, Complete_Date__c, Project_Milestone__c, Workflow_Key__c, ProjectId__c
                                             from Milestone1_Task__c 
                                             where ProjectId__c  = :projectIds];
        
        // build up the map of tasks based on project id
        for (Milestone1_Task__c tempTask : allTasks) {
            Id projId = tempTask.ProjectId__c;
            
            List<Milestone1_Task__c> theTasks = getTasksFromMap(projId, projectsTaskMap);
                        
            theTasks.add(tempTask);
        }
        
        return projectsTaskMap;
    }

    /**
     * Build a map of tasks based on milestone id
     */
    public static Map<Id, List<Milestone1_Task__c>> getAllTasksForMilestones(List<Milestone1_Milestone__c> milestones) {
        Map<Id, List<Milestone1_Task__c>> milestoneMap = new Map<Id, List<Milestone1_Task__c>>();

        List<Id> milestoneIds = getMilestoneIds(milestones);

        List<Milestone1_Task__c> allTasks = [Select Name, Complete__c, Complete_Date__c, Project_Milestone__c, Workflow_Key__c
                                             from Milestone1_Task__c 
                                             where Project_Milestone__c = :milestoneIds];
        
        // build up the map of tasks based on milestoneId
        for (Milestone1_Task__c tempTask : allTasks) {
            Id projId = tempTask.Project_Milestone__c;
            
            List<Milestone1_Task__c> theTasks = getTasksFromMap(projId, milestoneMap);
                        
            theTasks.add(tempTask);
        }
        
        return milestoneMap;
    }

    private static Set<String> getProjectIds(List<Milestone1_Task__c> tasks) {
        
        //Place all the task milestoneIds into a List for SOQL in Clause on Milestone Query        
        Set<String> ids = new Set<String>();
        
        for(Milestone1_Task__c tempTask : tasks) { 
            ids.add(tempTask.ProjectId__c); 
        }
        
        return ids;     
    }
    
    private static List<Id> getMilestoneIds(List<Milestone1_Task__c> tasks) {
        
        //Place all the task milestoneIds into a List for SOQL in Clause on Milestone Query        
        List<Id> milestoneIds = new List<String>();
        
        for(Milestone1_Task__c tempTask : tasks) { 
            milestoneIds.add(tempTask.Project_Milestone__c); 
        }
        
        return milestoneIds;        
    }
    
    private static List<Id> getMilestoneIds(List<Milestone1_Milestone__c> milestones) {
        
        //Place all the milestoneIds into a List for SOQL in Clause on Milestone Query        
        List<Id> milestoneIds = new List<String>();
        
        for(Milestone1_Milestone__c tempMilestone : milestones) { 
            milestoneIds.add(tempMilestone.id); 
        }
        
        return milestoneIds;        
    }   
    
    private static List<Milestone1_Task__c> getTasksFromMap(Id theId, Map<Id, List<Milestone1_Task__c>> theMap) {
        List<Milestone1_Task__c> theTasks = null;
        
        if (theMap.containsKey(theId)) {
            theTasks = theMap.get(theId);
        }
        else {
            theTasks = new List<Milestone1_Task__c>();
            theMap.put(theId, theTasks);
        }       
        
        return theTasks;
    }

    public static void handleTaskAfterTrigger(List<Milestone1_Task__c> recs, List<Milestone1_Task__c> oldRecs) {
        Milestone1_Task__c oldRec;
        //Place all the RecIds into a List for SOQL in Clause on Subscription Query
        List<String> recIds = new List<String>();
        for(Milestone1_Task__c rec : recs) { recIds.add(rec.Id); }
        
        //Retrieve existing list of Subscriptions for the Task(s) and store in Map by User. Salesforce does not allow user to subscribe to same object more than once so we can store in map.
        List<EntitySubscription> existingSubscriptions = [Select Id, ParentId, SubscriberId from EntitySubscription where ParentId in :recIds LIMIT 500];
         
        //Create a Map of Users to Subscriptions
        Map<String,List<EntitySubscription>> userSubscriptionMap = Milestone1_Task_Trigger_Utility.buildUserSubscriptionMap(existingSubscriptions);

        List<EntitySubscription> subscriptionsAddList = new List<EntitySubscription>();
        List<EntitySubscription> subscriptionsDeleteList = new List<EntitySubscription>();
        
        //Iterate over the list of Tasks and evaluate the Chatter rules to follow/unfollow based on Custom Settings for Users/Profiles
        Integer i = 0;
        for(Milestone1_Task__c rec : recs)
        {
            
            oldRec = null;
            //Retrieve the old record which matches current record
            if(oldRecs != null && oldRecs.size() > i){
                oldRec = oldRecs.get(i);
            }
            //If the Task is Assigned to a User then we can proceed
            if(rec.Assigned_To__c != null)
            {
                List<EntitySubscription> existingSubscriptionList = userSubscriptionMap.get(rec.Assigned_To__c);
                EntitySubscription existingSubscription = getSubscriptionForUserAndRec(rec,existingSubscriptionList,userSubscriptionMap);
                
                AutoChatterSetting chatterSettings = new AutoChatterSetting(rec.Assigned_To__c, rec.Assigned_To__r.ProfileId);
                //If the custom setting for automatically following is true, lets perform auto chatter logic
                if(chatterSettings.autoFollow)
                {
                    //If the there is not an existing subscription for the user, go ahead and follow the object. This prevents DUPLICATE_VALUE exception on subscription insert.
                    if(existingSubscription == null)
                    {
                        EntitySubscription subscription = new EntitySubscription(parentId=rec.id, SubscriberId=rec.Assigned_To__c);
                        subscriptionsAddList.add(subscription);
                    }
                }
                //If the custom setting for automatically unfollowing is true, let perform auto chatter logic to unfollow for the user.
                if(chatterSettings.autoCompleteFollow && rec.Complete__c && existingSubscription != null)
                {
                    subscriptionsDeleteList.add(existingSubscription);
                }
            }
            //Lets remove the previous Assigned To Follower if oldRec exists, and if the Assignment changed to another user.
            if(oldRec != null && oldRec.Assigned_To__c != null && oldRec.Assigned_To__c != rec.Assigned_To__c)
            {
                system.debug('Unfollow..');
                AutoChatterSetting chatterSettings = new AutoChatterSetting(oldRec.Assigned_To__c, oldRec.Assigned_To__r.ProfileId);
                List<EntitySubscription> existingSubscriptionList = userSubscriptionMap.get(oldRec.Assigned_To__c);
                EntitySubscription existingSubscription = getSubscriptionForUserAndRec(oldRec,existingSubscriptionList,userSubscriptionMap);
                if(chatterSettings.autoUnassignFollow && existingSubscription != null)
                {
                    subscriptionsDeleteList.add(existingSubscription);
                }
            }
            i++;
        }
        //Perform Inserts and Deletes of Subscriptions
        try{
            insert subscriptionsAddList;
            delete subscriptionsDeleteList;
        }
        catch(system.DmlException e){
            //TODO Validate the type of exception
            recs[0].addError(SUBSCRIPTION_LIMIT_EXCEEDED);
        }
        
        // check milestones for autocomplete if all tasks are complete  
        System.debug('TriggerUtility.milestoneTriggerHasNotRun = ' + TriggerUtility.milestoneTriggerHasNotRun);      
        if (TriggerUtility.milestoneTriggerHasNotRun) {
            System.debug('calling checkMilestonesForAutoComplete');      
            checkMilestonesForAutoComplete(recs);       
        }
        else {
            System.debug('NOT calling checkMilestonesForAutoComplete');
        }
        
    }
    
    public static EntitySubscription getSubscriptionForUserAndRec(Milestone1_Task__c rec, List<EntitySubscription> existingSubscriptionList, Map<String,List<EntitySubscription>> userSubscriptionMap)
    {
        EntitySubscription existingSubscription = null;
        if(userSubscriptionMap.get(rec.Assigned_To__c) != null)
        {   
            for(EntitySubscription tempSubscription : existingSubscriptionList)
            {
                if(tempSubscription.SubscriberId == rec.Assigned_To__c && tempSubscription.ParentId == rec.Id)
                {
                    existingSubscription = tempSubscription;
                    break;
                }
            }
        }
        return existingSubscription;
    }
    
    public static Map<String,List<EntitySubscription>> buildUserSubscriptionMap(List<EntitySubscription> existingSubscriptions)
    {
        Map<String,List<EntitySubscription>> userSubscriptionMap = new Map<String,List<EntitySubscription>>();
        for(EntitySubscription aSubscription : existingSubscriptions)
        {
            if(userSubscriptionMap.get(aSubscription.SubscriberId) == null)
            {
                userSubscriptionMap.put(aSubscription.SubscriberId,new List<EntitySubscription>());
                
            }
            List<EntitySubscription> tempList = userSubscriptionMap.get(aSubscription.SubscriberId);
            tempList.add(aSubscription);
            userSubscriptionMap.put(aSubscription.SubscriberId,tempList);
        }
        return userSubscriptionMap;
    }       
    
    private class AutoChatterSetting
    {
        public Boolean autoFollow = false;
        public Boolean autoCompleteFollow = false;
        public Boolean autoUnassignFollow = false;
        
        public autoChatterSetting(String userid, String profileId)
        {   
            Milestone1_Settings__c orgChatterDefaults = Milestone1_Settings__c.getOrgDefaults();        
            Milestone1_Settings__c profileChatter = Milestone1_Settings__c.getInstance(userid);
            Milestone1_Settings__c userChatter = Milestone1_Settings__c.getInstance(profileid);
            
            //If the User has a custom Chatter setting, use this setting else use a profile setting if available
            if(userChatter != null)
            {
                autoFollow = userChatter.Auto_Follow_Task__c;
                autoCompleteFollow = userChatter.Auto_Follow_Complete_Task__c;
                autoUnassignFollow = userChatter.Auto_Unfollow_Reassignment__c;
            }else if(profileChatter != null)
            {
                autoFollow = profileChatter.Auto_Follow_Task__c;
                autoCompleteFollow = profileChatter.Auto_Follow_Complete_Task__c;
                autoUnassignFollow = profileChatter.Auto_Unfollow_Reassignment__c;
            }else if(orgChatterDefaults != null)
            {
                autoFollow = orgChatterDefaults.Auto_Follow_Task__c;
                autoCompleteFollow = orgChatterDefaults.Auto_Follow_Complete_Task__c;
                autoUnassignFollow = orgChatterDefaults.Auto_Unfollow_Reassignment__c;  
            }
        }
    }
    
}