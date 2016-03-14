/* FILE: EventTriggerHandler.cls
 * AUTHOR: Michael Katulka
 * DATE: 2014-06-17
 * PURPOSE: A single trigger handler for the Event object.
 * MODIFICATION HISTORY:
 *     12/01/14  DK  Populated Original_Start_Date_Time__c and Original_End_Date_Time__c with setOriginalDateFields()
 *     1/11/15   SK  Added CycleTimeAcutalScheduled__c, CycleTimeActualScheduled__c, CompleteTime with setEventCycleTimes()
 * 	   09/04/15  PB SYS-374
 *     01/29/16  PB MIS-212
 *     02/09/16  RJ SFS-662
 */
public without sharing class EventTriggerHandler {
    private boolean m_isExecuting = false;

    private map<string, Schema.RecordTypeInfo> eventRecordTypeNameMap;
    private map<id, Schema.RecordTypeInfo> eventRecordTypeIDMap;    
    private map<string, Schema.RecordTypeInfo> astrumEventRecordTypeNameMap;
    private map<id, Schema.RecordTypeInfo> astrumEventRecordTypeIDMap;
    private set<id> salesVisitRTIDs;    
    private set<id> siteSurveyRTIDs;
    private string debugSection = 'EventTriggerHandler > ';
    private id sysAdminID;
    


    //private map<string, id> rtypes = new map<string, id>();

    public EventTriggerHandler(boolean isExecuting){
        m_isExecuting = isExecuting;
    system.debug('EventTriggerHandler');
        
        //Load recordtypes for Event
        Schema.DescribeSObjectResult dsr = Event.SObjectType.getDescribe();
        eventRecordTypeNameMap = dsr.getRecordTypeInfosByName();
        eventRecordTypeIDMap = dsr.getRecordTypeInfosById();

        salesVisitRTIDs = new set<id>();
        salesVisitRTIDs.add(eventRecordTypeNameMap.get('Sales Visit Onsite').getRecordTypeID());
        salesVisitRTIDs.add(eventRecordTypeNameMap.get('Sales Visit Remote').getRecordTypeID());        

        // Added by RJ - Jira Key SALES-45
        siteSurveyRTIDs = new set<id>();
        siteSurveyRTIDs.add(eventRecordTypeNameMap.get('Site Survey Onsite').getRecordTypeID());
        siteSurveyRTIDs.add(eventRecordTypeNameMap.get('Site Survey Remote').getRecordTypeID());

        //Load recordtypes for Astrum Event
        Schema.DescribeSObjectResult dsra = Astrum_Event__c.SObjectType.getDescribe();
        astrumEventRecordTypeNameMap = dsra.getRecordTypeInfosByName();
        astrumEventRecordTypeIDMap = dsra.getRecordTypeInfosById();

        //Load system administrator id
        List<Profile> PROFILE = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        if(!PROFILE.isempty()){
            sysAdminID = PROFILE[0].Id;
        }

        /*
        Schema.DescribeSObjectResult dsr = Event.SObjectType.getDescribe();
        for (Schema.RecordTypeInfo rti : dsr.getRecordTypeInfos()) {                        
            //TODO: A future release might allow us to use the developername instead of the name/label for this, so switch this when they do.
            rtypes.put(rti.getName(), rti.getRecordTypeId());
        }
        */          
        
    }

    
    public void OnBeforeInsert(Event[] newEvents){
        // EXECUTE BEFORE INSERT LOGIC    
        copySurveyNotes(newEvents, null);
        setCustomerLocalTime(newEvents, null);
        setOriginalDateFields(newEvents);
        // 1/11/15 SK Added setEventCycleTimes
        setEventCycleTimes(newEvents);        
        m_isExecuting = false;
    }
    
    public void OnBeforeUpdate(Event[] updatedEvents, Map<Id,Event> oldEventMap){
        // BEFORE UPDATE LOGIC
        copySurveyNotes(updatedEvents, oldEventMap.values());        
        setCustomerLocalTime(updatedEvents, oldEventMap);
        // 1/11/15 SK Added setEventCycleTimes
        setEventCycleTimes(updatedEvents);
        m_isExecuting = false;
    }
    
    public void OnBeforeDelete(Event[] eventsToDelete, Map<Id,Event> oldEventMap){
        // BEFORE DELETE LOGIC
        copySurveyNotes(null, eventsToDelete);
        m_isExecuting = false;
    }    

    public void OnAfterUpdate(Event[] updatedEvents, Map<Id,Event> oldEventMap){
        //  EXECUTE AFTER UPDATE LOGIC       
        portalReferral(updatedEvents,oldEventMap);
        syncEvents(updatedEvents, oldEventMap);
        updatePMProject(updatedEvents, oldEventMap);
        m_isExecuting = false;
    }

    
    public void OnAfterInsert(Event[] newEvents){
        // EXECUTE AFTER INSERT LOGIC
        portalReferral(newEvents,null);
        syncEvents(newEvents, null);
        updatePMProject(newEvents);
        m_isExecuting = false;
    }

    public void OnAfterDelete(Event[] deletedEvents, Map<Id,Event> oldEventMap){
        // AFTER DELETE LOGIC
        syncEvents(null, oldEventMap);
        m_isExecuting = false;
    }

    //public void OnUndelete(Event[] restoredEvents){ 
    //    // AFTER UNDELETE LOGIC
    //    m_isExecuting = false;
    //}
    
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }

    private void setOriginalDateFields(Event[] insertedEvents){
        //Set Original_Start_Date_Time__c and Original_End_Date_Time__c upon Event insertion
        //Retain the UTC date/time format so that the dates match exactly (even though they may appear different in the UI)
        for (Event ev : insertedEvents){
            if (ev.StartDateTime != null){
                ev.Original_Start_Date_Time__c = ev.StartDateTime;
                if (ev.EndDateTime != null){
                    ev.Original_End_Date_Time__c = ev.EndDateTime;
                } else if (ev.DurationInMinutes != null){
                    ev.Original_End_Date_Time__c = ev.Original_Start_Date_Time__c.addMinutes(ev.DurationInMinutes);
                }
            }
        }
    }

    private void setCustomerLocalTime(Event[] updatedEvents, Map<Id,Event> oldEventMap){

        system.debug('setCustomerLocalTime - Begin');
        set<id> opportunityIds = new set<id>();
        set<id> leadIds = new set<id>();
        list<Event> changedEvents = new list<Event>();

        for(Event stdEvent : updatedEvents){            
            Event oldEvent;
            if(trigger.isUpdate) oldEvent = oldEventMap.get(stdEvent.id);
            
            system.debug('check to see if there was a change to the start/end time');
            if(trigger.isInsert 
                    || (stdEvent.startdatetime != oldEvent.startdatetime
                        || stdEvent.enddatetime != oldEvent.enddatetime)
                ){

                //Gather IDs so that we can soql for records later and fill in the time zone ids
                changedEvents.add(stdEvent);

                //If linked to an Opportunity
                if(stdEvent.whatid != null && ((string)stdEvent.whatid).startsWith('006')){
                    opportunityIds.add(stdEvent.whatid);
                }else if(stdEvent.whoid != null && ((string)stdEvent.whoid).startsWith('00Q')){
                    //Linked to a lead
                    leadIds.add(stdEvent.whoid);
                }
            }
        }

        map<id, string> oppIDTimeZoneID = new map<id, string>();
        if(!opportunityIds.isEmpty()){
            for(Opportunity opp : [select id, Name, Property__r.Time_Zone__c
                                       from Opportunity
                                       where id in: opportunityIds]){
                if(opp.Property__r.Time_Zone__c != null){                   
                    oppIDTimeZoneID.put(opp.id, opp.Property__r.Time_Zone__c);
                }
            }
        }

        map<id, string> leadIDTimeZoneID = new map<id, string>();
        if(!leadIds.isEmpty()){         
            for(Lead theLead : [select id, Name, Time_Zone__c 
                                    from Lead
                                    where id in: leadIds]){
                if(theLead.Time_Zone__c != null){                   
                    leadIDTimeZoneID.put(theLead.id, theLead.Time_Zone__c);
                }
            }
        }

        system.debug('oppIDTimeZoneID.size(): ' + oppIDTimeZoneID.size());
        system.debug('leadIDTimeZoneID.size(): ' + leadIDTimeZoneID.size());

        //exit early if both maps are empty
        if(oppIDTimeZoneID.isEmpty() && leadIDTimeZoneID.isEmpty()){
            system.debug('setCustomerLocalTime - Return early because maps for time zones are empty!');
            return;
        }

        for(Event stdEvent : changedEvents){
            string tzID;

            //If linked to an Opportunity
            if(stdEvent.whatid != null && ((string)stdEvent.whatid).startsWith('006')){
                tzID = oppIDTimeZoneID.get(stdEvent.whatid);
            }else if(stdEvent.whoid != null && ((string)stdEvent.whoid).startsWith('00Q')){
                //Linked to a lead
                tzID = leadIDTimeZoneID.get(stdEvent.whoid);
            }

            system.debug('tzID: ' + tzID);
            if(tzID != null){
                //record date/time
                
                if(stdEvent.StartDateTime != null)
                {
                    stdEvent.Customer_Start_Date_Time_Text__c = stdEvent.StartDateTime.format('M/d/yyyy h:mm a zzzzz', tzID);
                }
                if(stdEvent.EndDateTime != null)
                {
                    stdEvent.Customer_End_Date_Time_Text__c = stdEvent.EndDateTime.format('M/d/yyyy h:mm a zzzzz', tzID);
                }
            }
        }

        system.debug('setCustomerLocalTime - End');     

    }


    private void syncEvents(Event[] updatedEvents, Map<Id,Event> oldEventMap){
        /* METHOD: EventTriggerHandler.syncEvents()
         * AUTHOR: Michael Katulka
         * DATE: 2014-06-17
         * PURPOSE:  This trigger’s role is to Create/Update the mirror Astrum Event record.  
         *          This trigger will also de-clutter the calendar by removing unnecessary events from 
         *          the user’s calendar.  Finally, it will handle the historical tracking of the Rescheduled 
         *          Sales Visits and manually deleted records.
         * MODIFICATION HISTORY: 
         *
        */
        debugSection = 'EventTriggerHandler > syncEvents: ';
        system.debug(debugSection + 'Method start');

        List<Astrum_Event__c> astrumEventsToUpsert = new List<Astrum_Event__c>();
        List<Astrum_Event__c> rescheduledAstrumEventsToUpdate = new List<Astrum_Event__c>();
        List<Event> eventsToUpdate = new List<Event>();
        List<Event> eventsToDelete = new List<Event>();

        set<string> eventStatusToDelete = new set<string>{'Customer No-Show', 'Disqualified-Approved', 'Canceled by Customer'};

        if(trigger.isdelete){           
            debugSection = 'EventTriggerHandler > Delete Trigger: ';            
            //DELETE
            for(Event stdEvent : oldEventMap.values()){
                system.debug(debugSection + 'Check to see if this is a missed event.');
                if(!stdEvent.isChild &&  !system.isBatch() && stdEvent.Event_Status__c != null 
                            && stdEvent.Event_Status__c == 'Missed' 
                            && stdEvent.startdatetime.date() < date.today()
                            && UserInfo.getProfileId() != sysAdminID){
                    system.debug(debugSection + 'This is a missed event in the past, no deleting allowed.');
                    stdEvent.addError('You cannot delete missed events in the past.');
                }else{
                    system.debug(debugSection + 'Tag linked astrum event as deleted');
                    //If this event is deleted, mark the counterpart deleted as a historical item.
                    Astrum_Event__c astrumEvent = createAstrumEvent(stdEvent);
                    //Keep the event id link just in case the record get's restored, or we need to query the database for the deleted record.
                    //astrumEvent.Event_ID__c = null;
                    //astrumEvent.Event_Name__c = null;
                    astrumEvent.Event_Manually_Deleted__c = true;
                    astrumEventsToUpsert.add(astrumEvent);
                    //This is a delete trigger, so this record will be deleted at the end of this trigger execution.
                }
            }

        }else if((trigger.isAfter && trigger.isinsert) || trigger.isupdate){ //after insert is a requirement, set to after update 
                                                                    //because when we delete the record, it needs to be an after trigger.
            debugSection = 'EventTriggerHandler > Insert/Update Trigger: ';
            system.debug(debugSection + 'Start logic, loop through records');

            if(trigger.isafter) updatedEvents = updatedEvents.deepClone(true);  //Cloned because in an after trigger we cannot modify data in list, but we need to
            for(Event stdEvent : updatedEvents){                
                if(stdEvent.isChild)
                {
                    continue;
                }
                Event oldEvent;
                if(trigger.isUpdate) oldEvent = oldEventMap.get(stdEvent.id);
                
                //i.    If Record Type == Sales Visit 
                if(salesVisitRTIDs.contains(stdEvent.recordtypeid)){
                    system.debug(debugSection + 'Sales Visit type');
                    //1.    If status == ‘Scheduled’ && Date/time changed then Sync the data to Astrum Event (Replacement for the 
                            //Reschedule Button)
                    if(trigger.isUpdate 
                        && stdEvent.Event_Status__c != null && stdEvent.Event_Status__c == 'Scheduled'
                        && (stdEvent.startdatetime != oldEvent.startdatetime
                            || stdEvent.enddatetime != oldEvent.enddatetime)
                    ){                      
                        debugSection = 'EventTriggerHandler > Reschedule: ';
                        system.debug(debugSection + 'Reschedule');
                        
                        //Need to track history of this change
                        if(stdEvent.Astrum_Event_ID__c != null){
                            Astrum_Event__c astrumEvent = new Astrum_Event__c();
                            astrumEvent.id = stdEvent.Astrum_Event_ID__c;
                            //a.    Set the linked Astrum Event status = Rescheduled
                            astrumEvent.status__c = 'Rescheduled';
                            //b.    Populate Rescheduled_Date__c and set to completed (old logic pulled from old reschedule button)
                            astrumEvent.Rescheduled_Date__c = System.Now();
                            astrumEvent.completed__c = true;
                            //c.    Clear the Astrum_Event__c.Event_ID__c field (It’s unique external ID, need to clear since there will be a 
                                    //new record with the same ID which is the newly scheduled record.
                            astrumEvent.Event_ID__c = null;
                            astrumEvent.Event_Name__c = null;
                            //d.    Add to UPSERT list.
                            rescheduledAstrumEventsToUpdate.add(astrumEvent);
                        }
                        
                        //e.    Create a new Astrum Event with all of the new info                      
                        //i.    Clear the Event.Astrum_Event_ID to initiate a new record and use the {Standard field mapping method, 
                                    //link the events if not linked}
                        stdEvent.Astrum_Event_ID__c = null;
                        Astrum_Event__c astrumEvent = createAstrumEvent(stdEvent);
                        astrumEventsToUpsert.add(astrumEvent);

                    //2.    Else If ('Customer No-Show', ‘Disqualified-Approved’, ‘Canceled by Customer’)
                    }else if(stdEvent.Event_Status__c != null && eventStatusToDelete.contains(stdEvent.Event_Status__c)){
                        debugSection = 'EventTriggerHandler > Status for Automatic Deletion: ';
                        system.debug(debugSection + 'To be deleted and astrum event tagged');
                        //a.    {Standard field mapping method }
                        Astrum_Event__c astrumEvent = createAstrumEvent(stdEvent);
                        //b.    Also set the linked Astrum Event checkbox "Event Automatically Deleted", add to UPSERT list.
                        astrumEvent.Event_Automatically_Deleted__c = true;
                        astrumEventsToUpsert.add(astrumEvent);
                        //c.    Add event to DeleteEvents list                      
                        eventsToDelete.add(new Event(id = stdEvent.id));
                    //3.    Else                        
                    }else{
                        system.debug(debugSection + 'Standard sync');
                        //a.    {Standard field mapping method, link the events if not linked}
                        Astrum_Event__c astrumEvent = createAstrumEvent(stdEvent);
                        astrumEventsToUpsert.add(astrumEvent);
                    }
                }else{
                //ii.   Else(Non-sales visit)
                    debugSection = 'EventTriggerHandler > Non-sales visit type: ';
                    system.debug(debugSection + 'Standard Sync');
                    //1.    {Standard field mapping method, link the events if not linked}
                    Astrum_Event__c astrumEvent = createAstrumEvent(stdEvent);
                    astrumEventsToUpsert.add(astrumEvent);

                }
            }
        }




        //DML Operations
        //Allow astrum event trigger to fire which will calculate all of the availability
        debugSection = 'EventTriggerHandler > Finish up: ';
        system.debug(debugSection + 'Done all heavy logic, run DML operations');

        //Update the rescheduled records, removing the external id value
        //This has to happen first before trying to insert new records with same external ID
        system.debug(debugSection + 'rescheduledAstrumEventsToUpdate.size: ' + rescheduledAstrumEventsToUpdate.size());
        if(!rescheduledAstrumEventsToUpdate.isEmpty()) update rescheduledAstrumEventsToUpdate;


        //Update Blocks and Astrum Events as needed.
        system.debug(debugSection + 'astrumEventsToUpsert.size: ' + astrumEventsToUpsert.size());
        if(!astrumEventsToUpsert.isEmpty()){
            upsert astrumEventsToUpsert;

            if(!trigger.isdelete){
                //After DML operation, loop through the records to fill in any missing links.
                //Update this event with the linked Astrum Event ID, if this is a before trigger, no need to DML.
                
                //Create map for fast linking, better than nested for loops.
                map<id, Astrum_Event__c> mapForLinking = new map<id, Astrum_Event__c>();
                for(Astrum_Event__c astrumEvent : astrumEventsToUpsert){
                    if(astrumEvent.Event_ID__c != null){ //This could be null for rescheduled historical records
                        mapForLinking.put(astrumEvent.Event_ID__c, astrumEvent);
                    }
                }

                for(Event stdEvent : updatedEvents){
                    //Only attempt linking if this field is blank
                    if(stdEvent.Astrum_Event_ID__c == null){
                        if(stdEvent.isChild)
                        {
                            continue;
                        }
                        if(mapForLinking.containsKey(stdEvent.id)){
                            stdEvent.Astrum_Event_ID__c = mapForLinking.get(stdEvent.id).id;
                            if(trigger.isAfter) eventsToUpdate.add(stdEvent);
                        }
                    }
                }
            }
            
            system.debug(debugSection + 'eventsToUpdate.size: ' + eventsToUpdate.size());
            //Contains list of events with the Astrum Event ID filled in.  This is used in the After Insert trigger.
            if(trigger.isAfter && !eventsToUpdate.isEmpty()) upsert eventsToUpdate;
        }

        system.debug(debugSection + 'eventsToDelete.size: ' + eventsToDelete.size());
        if(!eventsToDelete.isEmpty()) delete eventsToDelete;

        debugSection = 'EventTriggerHandler > syncEvents: ';
        system.debug(debugSection + 'Method stop');
    }

    //MK - 2016-06-26
    //Standard field mapping method
    //Method that takes Event as a parameter and returns an Astrum Event with the same data, ready for upserting.
    //Use the AstrumEvent.ID / Event.Astrum_Event_ID for the upsert if it exists.  The reason is that we will have 
    //duplicate external IDs for the rescheduled events within Astrum Event. So use the actual ID for upsert.
    private Astrum_Event__c createAstrumEvent(Event stdEvent){

        Astrum_Event__c astrumEvent = new Astrum_Event__c();

        //Copy from Event Standard Fields
        //==============================

        //Store this event's ID into the Astrum Event
        astrumEvent.Event_ID__c = stdEvent.id;
        astrumEvent.Event_ID_Backup__c = stdEvent.id;//Stored because we will be clearing out the event_id field for rescheduled events.
        astrumEvent.Event_Name__c = stdEvent.Subject;

        //Match recordtype's
        
        //String recordTypeName = (stdEvent.Record_Type_Name__c == 'Standard' ? 'Master' : stdEvent.Record_Type_Name__c);

        astrumEvent.recordtypeid = astrumEventRecordTypeNameMap.get(stdEvent.Record_Type_Name__c).getRecordTypeID(); //pass in the name from the astrum event to find the matching recordtype for astrumEvent.
        
        //Copy all of these fields data
        //astrumEvent.Notes__c = stdEvent.Description;
        astrumEvent.put('Notes__c' , stdEvent.Description);
        astrumEvent.ownerID = stdEvent.ownerID; //TODO: make sure this user is active, can't insert records for an inactive user.
        astrumEvent.subject__c = stdEvent.subject;
        astrumEvent.location__c = stdEvent.location;
        astrumEvent.Start_Date_Time__c = stdEvent.StartDateTime;
        astrumEvent.Stop_Date_Time__c = stdEvent.EndDateTime;
        astrumEvent.IsAllDayEvent__c = stdEvent.isalldayevent;

        //If linked to an Opportunity
        if(stdEvent.whatid == null){
            astrumEvent.opportunity__c = null; //reset to null in case user removes link to opp
        }else if(((string)stdEvent.whatid).startsWith('006')){
            astrumEvent.opportunity__c = stdEvent.whatid;   
        }

        //If linked to a Contact
        if(stdEvent.whoid == null){
            astrumEvent.contact__c = null;
            astrumEvent.lead__c = null;
        }else if(((string)stdEvent.whoid).startsWith('003')){
            //Linked to a contact
            astrumEvent.contact__c = stdEvent.whoid;
            astrumEvent.lead__c = null;
        }else if(((string)stdEvent.whoid).startsWith('00Q')){
            //Linked to a lead
            astrumEvent.lead__c = stdEvent.whoid;
            astrumEvent.contact__c = null;
        }

        //Copy from Event Custom Fields
        //==============================

        //If there is a link already, use it for the upsert
        if(stdEvent.Astrum_Event_ID__c != null) astrumEvent.id = stdEvent.Astrum_Event_ID__c;

        astrumEvent.status__c = stdEvent.Event_Status__c;
        astrumEvent.Missed_Date__c = stdEvent.Missed_Date__c;
        astrumEvent.Ever_Been_Missed__c = stdEvent.Ever_Been_Missed__c;
        astrumEvent.Canceled_by_Customer_Date__c = stdEvent.Canceled_by_Customer_Date__c;
        astrumEvent.Customer_No_Show_Date__c = stdEvent.Customer_No_Show_Date__c;
        astrumEvent.Disqualified_Approved_Date__c = stdEvent.Disqualified_Approved_Date__c;
        astrumEvent.Disqualified_Rejected_Date__c = stdEvent.Disqualified_Rejected_Date__c;
        astrumEvent.Rescheduled_Date__c = stdEvent.Rescheduled_Date__c;
        astrumEvent.completed__c = stdEvent.completed__c;
        astrumEvent.StartDateTimeCopy__c = stdEvent.StartDateTimeCopy__c;
        astrumEvent.Site_Survey_Type__c = stdEvent.Site_Survey_Type__c;
        astrumEvent.Requested_Date__c = stdEvent.Requested_Date__c;
        astrumEvent.Customer_Start_Date_Time_Text__c = stdEvent.Customer_Start_Date_Time_Text__c;
        astrumEvent.Customer_Stop_Date_Time_Text__c = stdEvent.Customer_End_Date_Time_Text__c;

        astrumEvent.D2D_Survey_Request__c = stdEvent.D2D_Survey_Request__c;

        //Formula: Site_Survey_Points__c

        return astrumEvent;

    }


    private void portalReferral(Event[] updatedEvents, Map<Id,Event> oldEventMap){
        /* AUTHOR: Tino Mattheou
         * DATE: September 4, 2012
         * PURPOSE: updates portal referral if sales visit event is completed
         * MODIFICATION HISTORY
         *        MK - 2014-06-17 - Merged into single trigger
        */
        /* MK 2014-07-02 - SD-18: Refactoring, use common variables - Comment Begin
        Set<Id> salesVisitRecordTypes = new Set<Id>();
        Schema.DescribeSObjectResult dsr = Event.SObjectType.getDescribe();
        for (Schema.RecordTypeInfo rti : dsr.getRecordTypeInfos()) {
            if (rti.getName().startsWith('Sales Visit')) {
                salesVisitRecordTypes.add(rti.getRecordTypeId());
            }
        }
        MK 2014-07-02 - SD-18: Refactoring, use common variables - Comment End */
        system.debug('portalReferral - Begin');
        Set<Id> opportunityIds = new Set<Id>();

        for (Event evt : updatedEvents) {
            String whatId = evt.WhatId;
            //if (salesVisitRecordTypes.contains(evt.RecordTypeId) //MK 2014-07-02 - SD-18: Refactoring, use common variables
            if (salesVisitRTIDs.contains(evt.RecordTypeId)              
            && evt.WhatId != null && whatId.startsWith('006') //opportunity
            && evt.Completed__c == true
            && (Trigger.isInsert 
            || evt.Completed__c != oldEventMap.get(evt.Id).Completed__c
            || evt.WhatId != oldEventMap.get(evt.Id).WhatId
            || evt.RecordTypeId != oldEventMap.get(evt.Id).RecordTypeId
            || evt.EndDateTime != oldEventMap.get(evt.Id).EndDateTime)) {
                opportunityIds.add(whatId);
            }
        }
        
        if (opportunityIds.isEmpty()) {
            return;
        }
        
        //get the related referrals
        List<Portal_Referral__c> referrals = 
            [SELECT Id, Lead__c, Opportunity__c, Status__c, Detail__c
            FROM Portal_Referral__c
            WHERE Opportunity__c IN :opportunityIds];

        if (referrals.isEmpty()) {
            return;
        }

        //get first completed sales visit event per opportunity 
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>( 
            [SELECT Id, StageName, Date_Site_Survey_Completed__c, Closed_Reason__c, CreatedDate,CloseDate, Closed_Type__c,On_hold_until__c,
                (SELECT Id, EndDateTime 
                FROM Events
                WHERE RecordType.DeveloperName LIKE 'Sales_Visit%' 
                AND Completed__c = true
                ORDER BY EndDateTime
                LIMIT 1)
            FROM Opportunity
            WHERE Id IN :opportunityIds
        ]);

        List<Portal_Referral__c> referralsToUpdate = new List<Portal_Referral__c>(); 
            
        for (Portal_Referral__c referral : referrals) {
            Opportunity opp = oppMap.get(referral.Opportunity__c);
            if (opp != null) {
                if (PortalReferralStatus.setReferralStatus(null, opp, opp.Events[0], referral)) {
                    referralsToUpdate.add(referral);
                }
            }
        }
        
        if (!referralsToUpdate.isEmpty()) {
            update referralsToUpdate;
        }   
        system.debug('portalReferral - End');
    }

    private void copySurveyNotes(list<Event> updatedEvents, list<Event> oldEvents)
    {   
        system.debug('copySurveyNotes - Begin');
        // Modified 
        //   RJ 02/11/13 : Use Discription to Copy Notes from Task
        //   MK - 2016-06-16 - merged into single trigger
        //   MK - 2014-07-02 - SD-18: Allowing permissions to edit
        // get record type
        //RecordType siteSurveyRecordType = [SELECT Id FROM RecordType WHERE (Name = 'Site Survey Onsite' or  Name = 'Site Survey Remote') AND SobjectType = 'Event' limit 1];
        
        //get all of the objects from org
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Map<String, String> keyPrefixMap = new Map<String, String>{};
        
        //get the prefix of the objects in Ids
        Set<String> keyPrefixSet = gd.keySet();
        for(String sObj : keyPrefixSet) {
            Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
            //store all the Objects with their prefixes
            keyPrefixMap.put(r.getKeyPrefix(),r.getName());
        }
        
        /* MK 2014-07-02 - SD-18: Allowing permissions to edit - Comment Begin
        List<Id> createdByList = new List<Id>();
        Map<Id,User> userRoleMap;
        String currentUserRole;
        
        if(Trigger.isUpdate || Trigger.isDelete)
        {
            for (Event rec:oldEvents) {
                createdByList.add(rec.CreatedById); 
                System.debug('**Created '+rec.CreatedById);
                System.debug('**Current '+UserInfo.getUserRoleId());        
                }  
        
        if(createdByList.size() > 0)
        {
            userRoleMap  = new Map<Id,User>([Select Id,UserRoleId,UserRole.Name from User Where Id in :createdByList]);
            List<UserRole> urs = [Select Name from UserRole Where id = :UserInfo.getUserRoleId()];
            if(urs != null && urs.size() > 0)
            {
                currentUserRole = urs[0].Name;    
            }
        }       
        
        if(Trigger.isDelete)
        {
            for (Event rec:oldEvents) {
            
            
                if(userRoleMap != null && userRoleMap.get(rec.CreatedById) !=null && userRoleMap.get(rec.CreatedById).UserRole != null )
                {
                    System.debug('**Created '+ userRoleMap.get(rec.CreatedById).UserRole.Name);
                    System.debug('**Current '+currentUserRole );
                    if(userRoleMap.get(rec.CreatedById).UserRole.Name == 'Inside Sales Consultant' && !(currentUserRole == 'Inside Sales Consultant' || currentUserRole == 'Inside Sales Manager' || currentUserRole == 'VP of Sales' ))
                    {
                         rec.addError('You do not have permission to modify/delete this record.');    
                    }
                }   
                     
            
            }    
            
        }
        MK 2014-07-02 - SD-18: Allowing permissions to edit - Comment End */
        
        if(Trigger.isUpdate || Trigger.isInsert)
        {
            for (Event rec:updatedEvents) {
             
                
                /* MK 2014-07-02 - SD-18: Allowing permissions to edit - Comment Begin
                if( !rec.Run_Trigger__c && userRoleMap != null && userRoleMap.get(rec.CreatedById) !=null && userRoleMap.get(rec.CreatedById).UserRole != null )
                {
                    System.debug('**Created '+ userRoleMap.get(rec.CreatedById).UserRole.Name);
                    System.debug('**Current '+currentUserRole );
                    if(userRoleMap.get(rec.CreatedById).UserRole.Name == 'Inside Sales Consultant' && !(currentUserRole == 'Inside Sales Consultant' || currentUserRole == 'Inside Sales Manager' || currentUserRole == 'VP of Sales' ))
                    {
                         rec.addError('You do not have permission to modify/delete this record.');
                    }
                }   
                else
                { MK 2014-07-02 - SD-18: Allowing permissions to edit - Comment End */
                    rec.Run_Trigger__c = false;
                /*MK 2014-07-02 - SD-18: Allowing permissions to edit - Comment Begin 
                } 
                MK 2014-07-02 - SD-18: Allowing permissions to edit - Comment End */
                    
            
          
        
                String whatPrefix = rec.WhatId;
                
                if (whatPrefix != null) {
                    whatPrefix = whatPrefix.subString(0,3);
                    String objectType = keyPrefixMap.get(whatPrefix);
                    
                    //If opportunity, copy the related info, but only for the main event... not the cloned child from a shared event.
                    /*  MK - 2016-06-16 - SD-34
                        Prevent error: You can not update fields except ReminderDateTime and IsReminderSet on a child event.: [Related_Property_Link__c]
                        Some of the events that your query retrieved are due to shared events.These events are child event and has originated when someone has invited you for event and during this salesforce creates multiple event for each assignee.
                        Filter the rows to get only parent Events.Use Ischild field and query Ischild=false
                        https://www.salesforce.com/us/developer/docs/api/Content/sforce_api_objects_event.htm
                        You can use database.update with false parameter that will allow success for all events except shared events.
                    */
                    if (rec.WhatId != null && objectType == 'Opportunity' && rec.isChild == false) {
                        Opportunity op = [Select Property__c, Property__r.Name, Schedule_Site_Survey_Task_id__c from Opportunity where id=:rec.WhatId];

                        /* SZ - 2015-10-14
                            Added the if statements to prevent issues with an event being created from the D2D site having the D2D site url instead of the internal SF url.
                        */
                        if(!rec.D2D_Survey_Request__c){
                            rec.Related_Property_Link__c = System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + op.Property__c;
                        }
                        if(!rec.D2D_Survey_Request__c){
                            rec.Related_Property_Name__c = op.Property__r.Name;            
                        }
            
                        //SYS-374 Commented Below code since the description and notes are copied to new event by using a custom create follow-up event button
                        /* pull over the notes
                        if (siteSurveyRTIDs.contains(rec.RecordTypeId)) {
                            // get the original site survey task
                            List<Task> tasks = [Select Notes__c,Description From Task where id = :op.Schedule_Site_Survey_Task_id__c];
        
                            if (tasks != null && !tasks.isEmpty()) {
                                Task theTask = tasks[0];
                                                
                                // assign the notes to the new event
                                if(rec.Description != null)                        
                                    rec.Description = rec.Description+'\n'+theTask.Description;
                                else
                                    rec.Description = theTask.Description;
                                    
                                if(theTask.Notes__c != null)
                                {
                                    rec.Description = rec.Description +'\n'+theTask.Notes__c;
                                }   
        
                            }
                        } */
                    }
                }  
            }     
        }
        system.debug('copySurveyNotes - End');
    }
    private void setEventCycleTimes(Event[] insertedUpdatedEvents){
        /* AUTHOR: Sam Kandasamy
         * DATE: January 11, 2015
         * PURPOSE: set CycleTimeOriginalScheduled__c, CycleTimeActualScheduled__c, CompleteTime__c
         * MODIFICATION HISTORY
         *       
        */
        
        Decimal cycleTimeOriginal;
        Decimal cycleTimeActual;
        Decimal completeTime;
        Decimal decimalNumber;
        Long timeDiff;
        Set<id> whatIds = new Set<id>();
        for(Event ev: insertedUpdatedEvents) {
            whatIds.add(ev.whatID);
        }
        Map<id, Opportunity> OppMap = new Map<id,Opportunity>([SELECT CreatedDate FROM Opportunity WHERE id in :whatIds]);
        for(Event ev: insertedUpdatedEvents) {
            if( ev.Original_Start_Date_Time__c != null && oppMap.get(ev.whatId) != null) {

                timeDiff = ev.Original_Start_Date_Time__c.getTime() - oppMap.get(ev.whatId).CreatedDate.getTime();
                System.Debug('OriginalStartDateTime '+ev.Original_Start_Date_Time__c);
                System.Debug('Opportunity created date '+oppMap.get(ev.whatId).CreatedDate);
                System.Debug('timeDiff '+timeDiff);
                        
                //cycleTimeOriginal = timeDiff/(1000*60*60); // In Days
                decimalNumber = timediff;
                cycleTimeOriginal = decimalNumber.divide(1000*60*60*24, 4);
                //   cycleTimeOriginal = timeDiff/(1000 *24*60*60); // In hours
                ev.CycleTimeOriginalScheduled__c = cycleTimeOriginal;
            }
            else {
                ev.CycleTimeOriginalScheduled__c = null;
            }

            if( ev.StartDateTime != null && oppMap.get(ev.whatId) != null ) {         // Not really needed. But to be consistent with original start date time check. 
                timeDiff = ev.StartDateTime.getTime() - oppMap.get(ev.whatID).CreatedDate.getTime();
                System.Debug('StartDateTime '+ev.StartDateTime);
                System.Debug('Opportunity created date '+oppMap.get(ev.whatId).CreatedDate);
                System.Debug('timeDiff '+timeDiff);
                decimalNumber = timediff;
                cycleTimeActual = decimalNumber.divide(1000*60*60*24, 4);  // in days
                ev.CycleTimeActualScheduled__c = cycleTimeActual;
            }
            else {
                ev.CycleTimeActualScheduled__c = null;
            }
            if(Trigger.isInsert) {
                if(ev.Completed_Date__c != null) {
                //   timeDiff = ev.Completed_Date__c.getTime() - ev.CreatedDate.getTime();
                //   Event.CreatedDate is not available before insert. Instead use current Datetime
                    timeDiff = ev.Completed_Date__c.getTime() - Datetime.now().getTime();
                    decimalNumber = timeDiff;
                    completeTime = decimalNumber.divide(1000*60*60*24, 4);   // in days
                    ev.CompleteTime__c = completeTime;
                }
                else {
                    ev.CompleteTime__c = null;
                }
            }
            if(Trigger.isUpdate) {
                if(ev.Completed_Date__c != null) {
                    timeDiff = ev.Completed_Date__c.getTime() -ev.CreatedDate.getTime();
                    decimalNumber = timeDiff;
                    completeTime = decimalNumber.divide(1000*60*60*24, 4);   // in days
                    ev.CompleteTime__c = completeTime;
                }
               else {
                     ev.CompleteTime__c = null;
               }
            }
        }
        
    }

    //MIS-212 PB 01/29/2016
    //If Event is related to PM Project and of type Site Survey Onsite Update Survey Date
    private void updatePMProject(Event[] newEvents){

        Id onsiteRecId = Schema.Sobjecttype.Event.getRecordTypeInfosByName().get('Site Survey Onsite').getRecordTypeId();
        Map<Id,Datetime> projTodateMap = new Map<Id,Datetime>();
        List<PM_Project__c> projsToUpdate;
        String whatIdStr;
        String proj_prefix = Schema.SObjectType.PM_Project__c.getKeyPrefix();
        System.debug(proj_prefix);

        for(Event theEvent:newEvents){
            whatIdStr = theEvent.WhatId;            
            if(String.isNotBlank(whatIdStr) 
               && whatIdStr.startsWith(proj_prefix) 
               && theEvent.Site_Survey_Type__c == 'Site Survey Onsite'){

                projTodateMap.put(theEvent.whatid,theEvent.StartDateTime);
            }
        }

        if(projTodateMap.size()>0){
            projsToUpdate = [SELECT Id FROM PM_Project__c WHERE Id IN:projTodateMap.keySet()];
        }

        if(projsToUpdate!= null){
            for(PM_Project__c proj:projsToUpdate){
                proj.Survey_Date__c = projTodateMap.get(proj.Id);
            }
            update projsToUpdate;
        }
    }

    //MIS-212 PB 01/29/2016
    //If Event is related to PM Project and of type Site Survey Onsite Update Survey Date
    private void updatePMProject(Event[] newEvents, Map<Id,Event> oldEventMap){

        Id onsiteRecId = Schema.Sobjecttype.Event.getRecordTypeInfosByName().get('Site Survey Onsite').getRecordTypeId();
        Map<Id,Event> projToEventMap = new Map<Id,Event>();
        List<PM_Project__c> projs;
        List<PM_Project__c> projsToUpdate = new List<PM_Project__c>();
        String whatIdStr;
        String proj_prefix = Schema.SObjectType.PM_Project__c.getKeyPrefix();
        System.debug(proj_prefix);

        for(Event theEvent:newEvents){
            whatIdStr = theEvent.WhatId;            
            if(String.isNotBlank(whatIdStr) 
               && whatIdStr.startsWith(proj_prefix) 
               && theEvent.Site_Survey_Type__c == 'Site Survey Onsite' 
               && oldEventMap.get(theEvent.Id).Completed__c == false){

                projToEventMap.put(theEvent.whatid,theEvent);
            }
        }

        if(projToEventMap.size()>0){
            projs = [SELECT Id
                            , (SELECT Id FROM Events ORDER BY CreatedDate DESC LIMIT 1) 
                            FROM PM_Project__c 
                            WHERE Id IN:projToEventMap.keySet()];
        }

        if(projs!= null){
            for(PM_Project__c proj:projs){
                if(proj.Events == null || proj.Events[0].Id == projToEventMap.get(proj.Id).Id){
                    if(projToEventMap.get(proj.Id).Completed__c){
                        proj.Survey_Date__c = projToEventMap.get(proj.Id).Completed_Date__c;
                    }else{
                        proj.Survey_Date__c = projToEventMap.get(proj.Id).StartDateTime;
                    }
                    projsToUpdate.add(proj);
                }
            }
        }

        if(projsToUpdate!= null && !projsToUpdate.isEmpty()){            
            update projsToUpdate;
        }
    }

}