/* 
 * AUTHOR:Rohit Jain
 * DATE: 2016-02-05
 * PURPOSE: A single trigger handler for the Task object.
 * MODIFICATION HISTORY:
 *     
 */
public without sharing class TaskTriggerHandler {

    private boolean m_isExecuting = false;

    private map<string, Schema.RecordTypeInfo> eventRecordTypeNameMap;
    private map<id, Schema.RecordTypeInfo> eventRecordTypeIDMap;    
    private set<id> salesVisitRTIDs;
    final String SURVEYTYPE_RESIDENTIAL_REMOTE_SURVEY = 'Residential Remote Survey';
    final String SURVEYTYPE_RESIDENTIAL_FIELD_SURVEY = 'Residential Field Survey';
    final String SURVEYTYPE_COMMERCIAL_SURVEY = 'Commercial Survey';
    final String SURVEYTYPE_CHANNEL_SURVEY = 'Channel Survey';

    public TaskTriggerHandler(boolean isExecuting){
        m_isExecuting = isExecuting;
    	system.debug('TaskTriggerHandler');
        
        //Load recordtypes for Event
        Schema.DescribeSObjectResult dsr = Event.SObjectType.getDescribe();
        eventRecordTypeNameMap = dsr.getRecordTypeInfosByName();
        eventRecordTypeIDMap = dsr.getRecordTypeInfosById();

        salesVisitRTIDs = new set<id>();
        salesVisitRTIDs.add(eventRecordTypeNameMap.get('Sales Visit Onsite').getRecordTypeID());
        salesVisitRTIDs.add(eventRecordTypeNameMap.get('Sales Visit Remote').getRecordTypeID());        
        
    }
    
    public void OnBeforeInsert(Task[] newTasks){
        // EXECUTE BEFORE INSERT LOGIC    
        setSiteSurveyDate(newTasks);     
        m_isExecuting = false;
    }

    private void setSiteSurveyDate(Task[] insertedUpdatedTasks){
    	Set<id> whatIds = new Set<id>();
        for(Task ts: insertedUpdatedTasks) {
        	system.debug('TaskTriggerHandler ts.Site_Survey_Type__c '+ ts.Site_Survey_Type__c);
        	if(ts.whatid != null && ((string)ts.whatid).startsWith('006')){ //&& (ts.Site_Survey_Type__c == 'Site Survey Onsite')){
            	whatIds.add(ts.whatID);
            	system.debug('TaskTriggerHandler '+ ts.whatid );
            }
        }
        Map<id, Opportunity> OppMap = new Map<id,Opportunity>([ Select Id, o.Account.Name, o.Property__r.Property_County__c, o.Property__r.Property_ZIP__c, o.Property__r.Property_State__c, o.Property__r.Property_City__c, o.Property__r.Name, o.Property__r.Astrum_Office__c, o.Property__c, 
                                  o.Owner.Email, o.Owner.FirstName, o.Owner.LastName, o.Owner.Manager.Email, o.OwnerId, o.Name  , o.Property__r.Astrum_Office_New__r.Sales_Coordinator__r.Id,  o.Property__r.Astrum_Sales_Region__r.Sales_Coordinator__r.Id                              
                                  , o.Property__r.Astrum_Office_New__r.Regional_Operations_Manager__c, o.Property__r.Astrum_Office_New__r.Survey_Scheduler__c
                                  , (SELECT StartDateTime FROM Events WHERE RecordTypeId IN:salesVisitRTIDs AND isChild= false and Completed__c = false LIMIT 1)
                                  From Opportunity o 
                                  where id in :whatIds]);

       system.debug('TaskTriggerHandler oppMap '+ OppMap);
        
       for(Task ts: insertedUpdatedTasks) {
        	if(ts.whatid != null && ((string)ts.whatid).startsWith('006')){
                if(ts.Site_Survey_Type__c == SURVEYTYPE_RESIDENTIAL_FIELD_SURVEY 
                    || ts.Site_Survey_Type__c == SURVEYTYPE_COMMERCIAL_SURVEY){
                    ts.OwnerId = OppMap.get(ts.whatid).Property__r.Astrum_Office_New__r.Survey_Scheduler__c != null ? 
                            OppMap.get(ts.whatid).Property__r.Astrum_Office_New__r.Survey_Scheduler__c : ts.OwnerId ;

                    system.debug('TaskTriggerHandler oppMap '+ OppMap.get(ts.whatid).Events );
                    System.debug('**recType:' + ts.RecordType + ':' + ts.RecordTypeId);                      

                }else if(ts.Site_Survey_Type__c == SURVEYTYPE_RESIDENTIAL_REMOTE_SURVEY 
                    || ts.Site_Survey_Type__c == SURVEYTYPE_CHANNEL_SURVEY){
                    ts.OwnerId = OppMap.get(ts.whatid).Property__r.Astrum_Office_New__r.Sales_Coordinator__r.Id != null ? 
                            OppMap.get(ts.whatid).Property__r.Astrum_Office_New__r.Sales_Coordinator__r.Id : ts.OwnerId ;
                }else if(String.isBlank(ts.Site_Survey_Type__c)){
                    ts.OwnerId = UserInfo.getUserId();
                }

                if(OppMap.get(ts.whatid).Events != null 
                    && !(OppMap.get(ts.whatid).Events.isEmpty())
                    && (ts.activityDate != null && ts.activityDate > OppMap.get(ts.whatid).Events[0].StartDateTime.date())){
                    System.debug('setting due date: ' + ts.activitydate + 'sales startdate:' + OppMap.get(ts.whatid).Events[0].StartDateTime.date());
                    ts.activitydate = OppMap.get(ts.whatid).Events[0].StartDateTime.date();
                }
            	
            }
        }

    }
}