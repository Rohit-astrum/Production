/* FILE: AstrumEventTriggerHandler.cls
 * AUTHOR: Mike Katulka
 * DATE: 2014-06-18
 * PURPOSE: To synchronize changes to the users calendar
 * MODIFICATION HISTORY: 
 *    12/04/14  DK  Set additional Event fields in trackAvailability()
 */
public without sharing class AstrumEventTriggerHandler {
    private boolean m_isExecuting = false;

    private map<string, Schema.RecordTypeInfo> eventRecordTypeNameMap;
    private map<id, Schema.RecordTypeInfo> eventRecordTypeIDMap;    
    private map<string, Schema.RecordTypeInfo> astrumEventRecordTypeNameMap;
    private map<id, Schema.RecordTypeInfo> astrumEventRecordTypeIDMap;
    private set<id> salesVisitRTIDs;    
    private id availabilityBlockRTID;
    private string debugSection = 'AstrumEventTriggerHandler > ';

    // Statuses which open up the Users calandar
    private static final Set<String> OPEN_STATUSES = new Set<String> {
        'Schedule Pending', 'Missed', 'Canceled by Customer', 'Disqualified', 'Disqualified-Approved', 'Customer No-Show' 
    };

    // Statuses which blocks the Users calandar
    private static final Set<String> CLOSE_STATUSES = new Set<String> {
        'Scheduled', 'Rescheduled', 'Completed'
    };

    public AstrumEventTriggerHandler (boolean isExecuting){     
        m_isExecuting = isExecuting;

        //Load recordtypes for Event
        Schema.DescribeSObjectResult dsr = Event.SObjectType.getDescribe();
        eventRecordTypeNameMap = dsr.getRecordTypeInfosByName();
        eventRecordTypeIDMap = dsr.getRecordTypeInfosById();

        //Load recordtypes for Astrum Event
        Schema.DescribeSObjectResult dsra = Astrum_Event__c.SObjectType.getDescribe();
        astrumEventRecordTypeNameMap = dsra.getRecordTypeInfosByName();
        astrumEventRecordTypeIDMap = dsra.getRecordTypeInfosById();

        salesVisitRTIDs = new set<id>();
        salesVisitRTIDs.add(astrumEventRecordTypeNameMap.get('Sales Visit Onsite').getRecordTypeID());
        salesVisitRTIDs.add(astrumEventRecordTypeNameMap.get('Sales Visit Remote').getRecordTypeID());

        availabilityBlockRTID = astrumEventRecordTypeNameMap.get('Availability Block').getRecordTypeID();

    }

  //  public void OnBeforeInsert(Astrum_Event__c[] newAstrumEvents){
  //      // EXECUTE BEFORE INSERT LOGIC
        
  //      m_isExecuting = false;
  //  }

  //  public void OnBeforeUpdate(Astrum_Event__c[] updatedAstrumEvents, Map<Id,Astrum_Event__c> astrumEventMap, Map<Id,Astrum_Event__c> oldAstrumEventMap){
  //      // BEFORE UPDATE LOGIC
  //      //insertScheduledEvents(updatedAstrumEvents, astrumEventMap, oldAstrumEventMap);
  //      //processEvents(updatedAstrumEvents, astrumEventMap, oldAstrumEventMap);
        //m_isExecuting = false;
  //  }

    public void OnAfterInsert(Astrum_Event__c[] insertedAstrumEvents){
        // EXECUTE AFTER INSERT LOGIC        
        trackAvailability(insertedAstrumEvents, null);
        m_isExecuting = false;
    }

    public void OnAfterUpdate(Astrum_Event__c[] updatedAstrumEvents, Map<Id,Astrum_Event__c> astrumEventMap, Map<Id,Astrum_Event__c> oldAstrumEventMap){
        //  EXECUTE AFTER UPDATE LOGIC
        trackAvailability(updatedAstrumEvents, oldAstrumEventMap);
        m_isExecuting = false;
    }


    public void OnBeforeInsert(Astrum_Event__c[] insertedAstrumEvents){
        // EXECUTE AFTER INSERT LOGIC        
        checkDayAndWeekLimits(insertedAstrumEvents, null);
        m_isExecuting = false;
    }

    public void OnBeforeUpdate(Astrum_Event__c[] updatedAstrumEvents, Map<Id,Astrum_Event__c> astrumEventMap, Map<Id,Astrum_Event__c> oldAstrumEventMap){
        //  EXECUTE AFTER UPDATE LOGIC
        checkDayAndWeekLimits(updatedAstrumEvents, oldAstrumEventMap);
        m_isExecuting = false;
    }

    
    /*
    public void OnBeforeDelete(Object[] ObjectsToDelete, Map<Id,Lead> MapObjectMap){
        // BEFORE DELETE LOGIC
    }

    public void OnAfterDelete(Object[] deletedObjects, Map<Id,Lead> MapObjectMap){
        // AFTER DELETE LOGIC
    }

    public void OnUndelete(Object[] restoredObjects){
        // AFTER UNDELETE LOGIC
    }
    */
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    } 

    /*  Added by RJ : 08/13/2014    
        Summary: This function will check if the day and week Limit Flags needs to be checked while inserting or updating Avl Block Event. 
                 If there exists any other event on the day or week it will copy the flag status from that event
                 If there are no events on the day or week then we need to run the logic to get the limits and compare and then check/uncheck the flag.
        
    */

    private void checkDayAndWeekLimits(Astrum_Event__c[] updatedAstrumEvents, Map<Id,Astrum_Event__c> oldAstrumEventMap)
    {
        system.debug(debugSection + 'checkDayAndWeekLimits');
        system.debug(debugSection + 'Trigger.isbefore: ' + trigger.isBefore);       
        system.debug(debugSection + 'Trigger.isinsert: ' + trigger.isInsert);
        system.debug(debugSection + 'Trigger.isUpdate: ' + trigger.isUpdate);

        // Check if any flagged records exists for a day

        for(Astrum_Event__c astrumEvent : updatedAstrumEvents)
        {

            Astrum_Event__c oldAstrumEvent;
            if(trigger.isUpdate) 
            {
                oldAstrumEvent = oldAstrumEventMap.get(astrumEvent.id);
                System.debug('oldAstrumEvent.status__c:'+oldAstrumEvent.status__c);  
            }

            // If insert and type in Avl Block or if Update and Start time is changed.
            if((trigger.isInsert && astrumEvent.recordtypeid == availabilityBlockRTID ) 
                 ||(trigger.isUpdate && astrumEvent.recordtypeid == availabilityBlockRTID  && astrumEvent.start_date_time__c != oldAstrumEvent.start_date_time__c ))
            {
                
                // Get the User limits. 
                AstrumScheduling__c userSettings = AstrumScheduling__c.getInstance(astrumEvent.ownerid);            
                Map<String,Decimal> userLimits = new Map<String,Decimal>();
                userLimits.put('Monday', userSettings.Monday_Sales_Visits__c );
                userLimits.put('Tuesday', userSettings.Tuesday_Sales_Visits__c );
                userLimits.put('Wednesday', userSettings.Wednesday_Sales_Visits__c );
                userLimits.put('Thursday', userSettings.Thursday_Sales_Visits__c );
                userLimits.put('Friday', userSettings.Friday_Sales_Visits__c );
                userLimits.put('Saturday', userSettings.Saturday_Sales_Visits__c );
                userLimits.put('Sunday', userSettings.Sunday_Sales_Visits__c );
                userLimits.put('Week', userSettings.Sales_Visits_Per_Week__c );

                System.debug('userLimits:'+userLimits);
                
                System.debug('Day limit logic Starts');  

                // Query all the avl block events for this rep for this day
                List<Astrum_Event__c> dayFlaggedEvents = [Select is_day_limit_reached__c
                                                         From Astrum_Event__c 
                                                        where ownerid = :astrumEvent.ownerid
                                                          AND DAY_ONLY(convertTimezone(start_date_time__c)) = :astrumEvent.start_date_time__c.date() 
                                                          AND RecordTypeId = :availabilityBlockRTID ];

                // Initialize the day sales visits count to 0                                        
                Integer dayScheduledVisitsCount = 0;
                // If other avl block exists for this day copy the flag 
                if(dayFlaggedEvents != null && dayFlaggedEvents.size() > 0 )
                {
                    
                    astrumEvent.is_day_limit_reached__c = dayFlaggedEvents[0].is_day_limit_reached__c;
                }
                else // else Derive the flag by comparing limits  versus actual Sales Visits if exists.
                {            

                    // Count the number of Scheduled/Completed Sales Visits on this date
                    AggregateResult[] dayScheduledVisits = [SELECT count(id) totalbooked
                                                FROM Astrum_Event__c
                                                WHERE ownerid = :astrumEvent.ownerid
                                                AND RecordTypeId IN :salesVisitRTIDs
                                                AND Status__c IN :CLOSE_STATUSES
                                                AND DAY_ONLY(convertTimezone(start_date_time__c)) = :astrumEvent.start_date_time__c.date() ];            
            
                   
                    for (AggregateResult ar : dayScheduledVisits)  {             
                       dayScheduledVisitsCount = (Integer)ar.get('totalbooked');        
                       System.debug('dayScheduledVisitsCount:'+dayScheduledVisitsCount);               
                    } 
                    //1a. Get the Day Limit 
                    if(userLimits.get(astrumEvent.Start_Date_Week_Day__c) != null &&  dayScheduledVisitsCount >= userLimits.get(astrumEvent.Start_Date_Week_Day__c)  )
                    {
                        System.debug('Daily Limit Reached Update  Avail. Blocks day Flag');
                        astrumEvent.is_day_limit_reached__c = true;
                    }
                    else
                    {
                        astrumEvent.is_day_limit_reached__c = false;    
                    }
                }
                
                System.debug('Week limit logic Starts');  

                // Weekend date is week start date plus 7
                Date weekEndDate = astrumEvent.Week_Start_Date__c + 7;

                // Query all the avl block events for this rep for this week
                List<Astrum_Event__c> weekFlaggedEvents = [Select is_week_limit_reached__c
                                                         From Astrum_Event__c 
                                                        where ownerid = :astrumEvent.ownerid
                                                          AND RecordTypeId = :availabilityBlockRTID  
                                                          AND DAY_ONLY(convertTimezone(start_date_time__c)) >= :astrumEvent.Week_Start_Date__c
                                                          AND  DAY_ONLY(convertTimezone(start_date_time__c)) < :weekEndDate];

                // Initialize the week sales visits count to 0  
                Integer weekScheduledVisitsCount = 0;

                // If other avl block exists for this week copy the flag 
                if(weekFlaggedEvents != null && weekFlaggedEvents.size() > 0 )
                {
                    astrumEvent.is_week_limit_reached__c = weekFlaggedEvents[0].is_week_limit_reached__c;
                }
                else
                {
                    
                    System.debug('weekEndDate:'+weekEndDate);
                    // Count the number of Scheduled/Completed Sales Visits on this Week
                    AggregateResult[] weekScheduledVisits = [SELECT count(Id) totalbooked
                                                FROM Astrum_Event__c
                                                WHERE ownerid = :astrumEvent.ownerid
                                                AND RecordTypeId IN :salesVisitRTIDs
                                                AND Status__c IN :CLOSE_STATUSES
                                                AND DAY_ONLY(convertTimezone(start_date_time__c)) >= :astrumEvent.Week_Start_Date__c
                                                AND DAY_ONLY(convertTimezone(start_date_time__c)) < :weekEndDate];            
            
                    
                    for (AggregateResult ar : weekScheduledVisits)  {             
                       weekScheduledVisitsCount = (Integer)ar.get('totalbooked');       
                       System.debug('weekScheduledVisitsCount:'+weekScheduledVisitsCount);               
                    } 

                    //1a. Get the week Limit 
                    if(userLimits.get('Week') != null &&  weekScheduledVisitsCount >= userLimits.get('Week')  )
                    {
                        System.debug('Weekly Limit Reached Update  Avail. Blocks day Flag');
                        astrumEvent.is_week_limit_reached__c = true;

                    }
                    else
                    {
                        astrumEvent.is_week_limit_reached__c = false;   
                    }

                }

            }

        }   
    }

    private void LimitCheck(Astrum_Event__c astrumEvent, Boolean isCheck)   
    {
        
        AstrumScheduling__c userSettings = AstrumScheduling__c.getInstance(astrumEvent.ownerid);            
        Map<String,Decimal> userLimits = new Map<String,Decimal>();
        userLimits.put('Monday', userSettings.Monday_Sales_Visits__c );
        userLimits.put('Tuesday', userSettings.Tuesday_Sales_Visits__c );
        userLimits.put('Wednesday', userSettings.Wednesday_Sales_Visits__c );
        userLimits.put('Thursday', userSettings.Thursday_Sales_Visits__c );
        userLimits.put('Friday', userSettings.Friday_Sales_Visits__c );
        userLimits.put('Saturday', userSettings.Saturday_Sales_Visits__c );
        userLimits.put('Sunday', userSettings.Sunday_Sales_Visits__c );
        userLimits.put('Week', userSettings.Sales_Visits_Per_Week__c );

        System.debug('userLimits:'+userLimits);

        // Query all the avl block events for this rep for this day
        List<Astrum_Event__c> dayFlaggedEvents = [Select is_day_limit_reached__c
                                                 From Astrum_Event__c 
                                                where ownerid = :astrumEvent.ownerid
                                                  AND DAY_ONLY(convertTimezone(start_date_time__c)) = :astrumEvent.start_date_time__c.date() 
                                                  AND RecordTypeId = :availabilityBlockRTID ];

        System.debug('dayFlaggedEvents '+dayFlaggedEvents);
        Integer dayScheduledVisitsCount = 0;
        // If daily limit flag is not checked - process futher
        if(dayFlaggedEvents != null && dayFlaggedEvents.size() > 0 && ( (isCheck && !dayFlaggedEvents[0].is_day_limit_reached__c) || (!isCheck && dayFlaggedEvents[0].is_day_limit_reached__c))) 
        {
            // Count the number of Scheduled/Completed Sales Visits on this date
            AggregateResult[] dayScheduledVisits = [SELECT count(id) totalbooked
                                        FROM Astrum_Event__c
                                        WHERE ownerid = :astrumEvent.ownerid
                                        AND RecordTypeId IN :salesVisitRTIDs
                                        AND Status__c IN :CLOSE_STATUSES
                                        AND DAY_ONLY(convertTimezone(start_date_time__c)) = :astrumEvent.start_date_time__c.date() ];            
    
           
            for (AggregateResult ar : dayScheduledVisits)  {             
               dayScheduledVisitsCount = (Integer)ar.get('totalbooked');        
               System.debug('dayScheduledVisitsCount:'+dayScheduledVisitsCount);               
            } 

            //1a. Get the Day Limit 
            if(isCheck)
            {
                if(userLimits.get(astrumEvent.Start_Date_Week_Day__c) != null &&  dayScheduledVisitsCount >= userLimits.get(astrumEvent.Start_Date_Week_Day__c)  )
                {
                    System.debug('Daily Limit Reached Update  Avail. Blocks day Flag');

                    for(Astrum_Event__c event: dayFlaggedEvents)
                    {
                        event.is_day_limit_reached__c = true;
                    }
                    update dayFlaggedEvents; 
                }
            }
            else
            {
                if(userLimits.get(astrumEvent.Start_Date_Week_Day__c) != null &&  dayScheduledVisitsCount < userLimits.get(astrumEvent.Start_Date_Week_Day__c)  )
                {
                    System.debug('Daily Limitreversed  Avail. Blocks day Flag');

                    for(Astrum_Event__c event: dayFlaggedEvents)
                    {
                        event.is_day_limit_reached__c = false;
                    }

                    update dayFlaggedEvents; 

                }

            }
        }
        
        // 2. Check if we need to perform the Week flag update
        Date weekEndDate = astrumEvent.Week_Start_Date__c + 7;
        List<Astrum_Event__c> weekFlaggedEvents = [Select is_week_limit_reached__c
                                                 From Astrum_Event__c 
                                                where ownerid = :astrumEvent.ownerid
                                                  AND RecordTypeId = :availabilityBlockRTID  
                                                 AND DAY_ONLY(convertTimezone(start_date_time__c)) >= :astrumEvent.Week_Start_Date__c
                                                  AND  DAY_ONLY(convertTimezone(start_date_time__c)) < :weekEndDate];

        Integer weekScheduledVisitsCount = 0;
        // If daily limit flag is not checked - process futher
        if(weekFlaggedEvents != null && weekFlaggedEvents.size() > 0 && ( (isCheck && !weekFlaggedEvents[0].is_week_limit_reached__c) || (!isCheck && weekFlaggedEvents[0].is_week_limit_reached__c))) 
        {
            
            
            System.debug('weekEndDate:'+weekEndDate);
            // Count the number of Scheduled/Completed Sales Visits on this week
            AggregateResult[] weekScheduledVisits = [SELECT count(Id) totalbooked
                                        FROM Astrum_Event__c
                                        WHERE ownerid = :astrumEvent.ownerid
                                        AND RecordTypeId IN :salesVisitRTIDs
                                        AND Status__c IN :CLOSE_STATUSES
                                        AND DAY_ONLY(convertTimezone(start_date_time__c)) >= :astrumEvent.Week_Start_Date__c
                                        AND DAY_ONLY(convertTimezone(start_date_time__c)) < :weekEndDate];            
    
            
            for (AggregateResult ar : weekScheduledVisits)  {             
               weekScheduledVisitsCount = (Integer)ar.get('totalbooked');       
               System.debug('weekScheduledVisitsCount:'+weekScheduledVisitsCount);               
            } 

            //1a. Get the Day Limit 
            if(isCheck)
            {
                if(userLimits.get('Week') != null &&  weekScheduledVisitsCount >= userLimits.get('Week')  )
                {
                    System.debug('Weekly Limit Reached Update  Avail. Blocks day Flag');

                    for(Astrum_Event__c event: weekFlaggedEvents)
                    {
                        event.is_Week_limit_reached__c = true;
                    }

                    update weekFlaggedEvents; 

                }
            }
            else
            {
                if(userLimits.get('Week') != null &&  weekScheduledVisitsCount < userLimits.get('Week')  )
                {
                    System.debug('Weekly Limit Reverse Update  Avail. Blocks day Flag');

                    for(Astrum_Event__c event: weekFlaggedEvents)
                    {
                        event.is_Week_limit_reached__c = false;
                    }

                    update weekFlaggedEvents; 

                }

            }

        }

    }


    /*      
        Summary: This trigger’s role is to put newly scheduled events into the users calendar.
                 This trigger will Block/UnBlock the schedule when changes occur.
        Notes: (After trigger would be much easier to track conflicts etc since the SOQL queries would represent 
                the current state of the status/dates/times.  In a before trigger, this could add complexity to 
                the blocking/unblocking logic since we would need to filter out the current trigger records but 
                include them in the logic later on. In a later phase we could consider doing this in a before 
                trigger, but for the sake of time we are making this easier.)
        Updated by RJ on 08/13/2014 : If a Sales Visit Event is inserted or updated - we will check how many Sales Visits are scheduled for this day/week
                and then will compare it against limits. If the limits are reached we will update all the avl block events for that day/week with flag checked
                Simillarly , we will uncheck the flags when any Sales visits gets updated to Open Status like Cancelled.
    */
    private void trackAvailability(Astrum_Event__c[] updatedAstrumEvents, Map<Id,Astrum_Event__c> oldAstrumEventMap){
        system.debug(debugSection + 'trackAvailability');
        system.debug(debugSection + 'Trigger.isbefore: ' + trigger.isBefore);       
        system.debug(debugSection + 'Trigger.isinsert: ' + trigger.isInsert);
        system.debug(debugSection + 'Trigger.isUpdate: ' + trigger.isUpdate);

        

        //Limit the trigger size to something like 20 because we will be running complex queries (in the where clause) 
        //looking for conflicts etc.
        if(updatedAstrumEvents.size() > 20){
            for(Astrum_Event__c astrumEvent : updatedAstrumEvents){
                astrumEvent.adderror('Updating Events is limited to batches of 20.  Please try updating with a smaller set.  If using data loader, set the batch size to 20 in the settings.');
            }
            return;
        }

        //AFTER INSERT OR UPDATE
        List<Event> eventsToInsert = new List<Event>();
        map<id, Astrum_Event__c> astrumEventsToUpdateMap = new map<id, Astrum_Event__c>(); //Map allows overwrite of same astrum event keyed on the id      
        
        for(Astrum_Event__c astrumEvent : updatedAstrumEvents){

            boolean toInsert = false;

            

            Astrum_Event__c oldAstrumEvent;
            if(trigger.isUpdate) 
            {
                oldAstrumEvent = oldAstrumEventMap.get(astrumEvent.id);
                System.debug('oldAstrumEvent.status__c:'+oldAstrumEvent.status__c);  
            }
            

            // Added by RJ          
            if((trigger.isInsert && salesVisitRTIDs.contains(astrumEvent.recordtypeid) && CLOSE_STATUSES.contains(astrumEvent.status__c)) 
                 ||(trigger.isUpdate && salesVisitRTIDs.contains(astrumEvent.recordtypeid) && ( (CLOSE_STATUSES.contains(astrumEvent.status__c) &&  OPEN_STATUSES.contains(oldAstrumEvent.status__c) 
                                                                                            || (astrumEvent.status__c != oldAstrumEvent.status__c && astrumEvent.status__c == 'Rescheduled' )))))
            {   
                LimitCheck(astrumEvent,true);
                if(trigger.isUpdate && astrumEvent.status__c == 'Rescheduled' && astrumEvent.start_date_time__c != oldAstrumEvent.start_date_time__c)
                {
                    LimitCheck(oldAstrumEvent,false);
                }
            }
            // Added by RJ          
            else if((trigger.isUpdate && salesVisitRTIDs.contains(astrumEvent.recordtypeid) && OPEN_STATUSES.contains(astrumEvent.status__c) &&  CLOSE_STATUSES.contains(oldAstrumEvent.status__c)))
            {
                System.debug('Check if we need to Reverse the flag:');  
                LimitCheck(astrumEvent,false);
            }


            
            
            debugSection = 'AstrumEventTriggerHandler > TriggeredEventRecord: ';
            system.debug(debugSection + 'Inside for loop, what type of event is this...');

            system.debug(debugSection + 'astrumEvent.ID: ' + astrumEvent.ID);
            system.debug(debugSection + 'astrumEvent.Event_ID__c: ' + astrumEvent.Event_ID__c);
            system.debug(debugSection + 'astrumEvent.Status__c: ' + astrumEvent.Status__c);

            //When Sales Visit record changes from “Schedule Pending” to “Scheduled”, and there is not a link to event yet:
            if(salesVisitRTIDs.contains(astrumEvent.recordtypeid)
                && astrumEvent.status__c != null && astrumEvent.status__c == 'Scheduled' && astrumEvent.Event_ID__c == null
                && (trigger.isInsert || oldAstrumEvent.status__c == null || oldAstrumEvent.status__c != astrumEvent.status__c)
            ){
                system.debug(debugSection + 'This is a newly scheduled event.');

                //This is a newly scheduled Sales Visit
                Event stdEvt = new Event();                                     
                stdEvt.Astrum_Event_ID__c = astrumEvent.id; //Back-link

                //Match recordtype's
                stdEvt.recordtypeid = eventRecordTypeNameMap.get(astrumEvent.Record_Type_Name__c).getRecordTypeID(); //pass in the name from the astrum event to find the matching recordtype for astrumEvent.
                
                //Copy all of these fields data
                stdEvt.Description = (String)astrumEvent.get('Notes__c');               
                stdEvt.ownerID = astrumEvent.ownerID;
                stdEvt.subject = astrumEvent.subject__c;                    
                stdEvt.location = astrumEvent.location__c;
                stdEvt.StartDateTime = astrumEvent.start_date_time__c;
                stdEvt.EndDateTime = astrumEvent.stop_date_time__c;
                stdEvt.Original_Start_Date_Time__c = stdEvt.StartDateTime;    //Because the Event trigger will be skipped, set these fields manually
                stdEvt.Original_End_Date_Time__c = stdEvt.EndDateTime;    //Because the Event trigger will be skipped, set these fields manually
                stdEvt.Customer_Start_Date_Time_Text__c = astrumEvent.Customer_Start_Date_Time_Text__c;
                stdEvt.Customer_End_Date_Time_Text__c = astrumEvent.Customer_Stop_Date_Time_Text__c;                
                if(astrumEvent.opportunity__c != null){
                    stdEvt.whatid = astrumEvent.opportunity__c;
                    stdEvt.Related_Property_Link__c = System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + astrumEvent.Property_ID__c;
                    stdEvt.Related_Property_Name__c = astrumEvent.Property_Address_1__c;
                }
                if(astrumEvent.lead__c != null) stdEvt.whoid = astrumEvent.lead__c;
                else if(astrumEvent.contact__c != null) stdEvt.whoid = astrumEvent.contact__c;

                eventsToInsert.add(stdEvt);
            }


            //Perform Blocking/UnBlocking check:            
            //If this is an Availability Block(No entry criteria needed for availability blocks, this way the recalculation will
                            // always run which is good for nightly batch.)
            //Set search start/end date times
            datetime startSearch = astrumEvent.start_date_time__c;
            datetime stopSearch = astrumEvent.stop_date_time__c;
            
            //If this is an event in the past, skip all of this heavy logic.  
            if(startSearch.date() < system.today() && stopSearch.date() < system.today()){
                system.debug('Event is in the past, no need to reconcile availability');
                continue; //Next event.
            }


            system.debug(debugSection + 'Need to block/unblock');

            if(astrumEvent.recordtypeid == availabilityBlockRTID){
                system.debug(debugSection + 'This is an availability block');
                //If this is a block record, simply look for events list size   
                //SOQL 1A           
                if(getBlockingAstrumEventsCount(startSearch, stopSearch, astrumEvent.ownerid) < 1){
                    //There are no "To Block" events for this block that overlap, this timeslot is available.
                    if(astrumEvent.status__c != 'Available'){
                        //Add to map for update, only if it's not been added/handled before
                        if(!astrumEventsToUpdateMap.containskey(astrumevent.id)) astrumEventsToUpdateMap.put(astrumEvent.id, new Astrum_Event__c(id = astrumEvent.id, status__c = 'Available'));
                    }
                }else{
                    //There is at least one event that is overlapping this block, set this block to unavaiable
                    if(astrumEvent.status__c != 'Unavailable'){
                        //Add to map for update, only if it's not been added/handled before
                        if(!astrumEventsToUpdateMap.containskey(astrumevent.id)) astrumEventsToUpdateMap.put(astrumEvent.id, new Astrum_Event__c(id = astrumEvent.id, status__c = 'Unavailable'));                      
                    }

                }
            
            }else{                      
                system.debug(debugSection + 'This is an event, always recalculate the availability.');              

                //If this was a Date/Time change, then need to get the previous date/time and perform a blocking check.
                system.debug(debugSection + 'Check to see if this is a date/time change.');
                if(trigger.isUpdate 
                        && (astrumEvent.start_date_time__c != oldAstrumEvent.start_date_time__c
                            || astrumEvent.stop_date_time__c != oldAstrumEvent.stop_date_time__c)
                ){                  
                    system.debug(debugSection + 'Date/Time changed, need to go recalculate old date/time.');                                        
                    debugSection = 'AstrumEventTriggerHandler > Reconcile Old Date/Time: ';

                    //TODO: //If isalldayevent then the date is stored in the StartDateTime field with 00:00, so in order to 
                            //get the right date every time, use the dateGMT function.                  
                            
                    list<Astrum_Event__c> overlappingBlocksOld = getOverlappingBlocks(oldAstrumEvent.start_date_time__c, oldAstrumEvent.stop_date_time__c, oldAstrumEvent.IsAllDayEvent__c, oldAstrumEvent.ownerid);
                    if(!overlappingBlocksOld.isEmpty()){
                        reconcileBlockAvailability(overlappingBlocksOld, oldAstrumEvent, astrumEventsToUpdateMap);
                    }
                }


                debugSection = 'AstrumEventTriggerHandler > Reconcile this event Date/Time: ';
                system.debug(debugSection + 'Reconcile this events blocks.');
                //SOQL to get all overlapping blocks for the current start/stop date/time
                //SOQL 1B



                //TODO: //If isalldayevent then the date is stored in the StartDateTime field with 00:00, so in order to 
                        //get the right date every time, use the dateGMT function.

                list<Astrum_Event__c> overlappingBlocks = getOverlappingBlocks(startSearch, stopSearch, astrumEvent.IsAllDayEvent__c, astrumEvent.ownerid);
                if(!overlappingBlocks.isEmpty()){
                    debugSection = 'AstrumEventTriggerHandler > Reconcile this event Blocks: ';
                    //If we get here, there are blocks to check for availability
                    //If this event is a “To Block” event                   
                    if(isABlockingAstrumEvent(astrumEvent)){
                        system.debug(debugSection + 'This is an event that blocks out availability.');
                        //Block out the results
                        for(Astrum_Event__c block : overlappingBlocks){
                            system.debug(debugSection + 'Set this block to Unavailable, ID=' + block.id + ' Status=' + block.status__c);
                            if(block.status__c != 'Unavailable'){
                                //Add to map for update, only if it's not been added/handled before
                                if(!astrumEventsToUpdateMap.containskey(block.id)) astrumEventsToUpdateMap.put(block.id, new Astrum_Event__c(id = block.id, status__c = 'Unavailable'));
                            }
                        }
                    }else{
                        system.debug(debugSection + 'This is an un-blocking type event, need to fully reconcile the blocks availability in case there are other events.');
                        reconcileBlockAvailability(overlappingBlocks, astrumEvent, astrumEventsToUpdateMap);
                    }
                }
            }
        }//End For

        debugSection = 'AstrumEventTriggerHandler > Finish up: ';
        system.debug(debugSection + 'Done all heavy logic, run DML operations');

        //Update Blocks and Astrum Events as needed.
        system.debug(debugSection + 'astrumEventsToUpdateMap.size: ' + astrumEventsToUpdateMap.size());
        if(!astrumEventsToUpdateMap.isEmpty()) update astrumEventsToUpdateMap.values();

        //Push newly scheduled Events into the events calendar and link them together.
        system.debug(debugSection + 'eventsToInsert.size: ' + eventsToInsert.size());
        if(!eventsToInsert.isempty()){
            system.debug(debugSection + 'Insert events');
            //Disable the Event trigger
            triggerUtility.skipEventTrigger = true;
            insert eventsToInsert;
            triggerUtility.skipEventTrigger = false; //reset to false for controller/unit test scenarios

            //Clear and reinitialize list
            astrumEventsToUpdateMap = new map<id, Astrum_Event__c>();
            
            //Loop through the standard events that were Inserted and make sure the linking is correct
            for(Event stdEvt : eventsToInsert){
                //backlink              
                //After trigger, make temp evt with the ID and link.
                Astrum_Event__c tempEvt = new Astrum_Event__c(id = stdEvt.Astrum_Event_ID__c, Event_ID__c = stdEvt.id, Event_ID_Backup__c = stdEvt.id, Event_Name__c = stdEvt.subject);

                //Add to map for update
                astrumEventsToUpdateMap.put(tempEvt.id, tempEvt);
            }

            //Update list
            update astrumEventsToUpdateMap.values();
        }
    }

    private void reconcileBlockAvailability(list<Astrum_Event__c> overlappingBlocks, Astrum_Event__c astrumEvent, map<id, Astrum_Event__c> astrumEventsToUpdateMap){
        system.debug(debugSection + 'reconcileBlockAvailability');
        //Need to reconcile the availability for all overlapping blocks.
        //a. Loop through blocks and get the earliest date/time, and the latest date/time.
            //(This is just a technique to cut down on SOQL's, this will result in a larger time-span, but
                //it will give us the ability to run 1 soql of events which may or may not overlap with these blocks.)
                //Then we will loop to find overlaps.
        datetime startSearch = null;
        datetime stopSearch = null;
        list<datetime> startList = new list<datetime>();
        list<datetime> stopList = new list<datetime>();
        for(Astrum_Event__c block : overlappingBlocks){
            //if(startSearch == null || block.start_date_time__c < startSearch) startSearch = block.start_date_time__c;
            //if(stopSearch == null || block.stop_date_time__c > stopSearch) stopSearch = block.stop_date_time__c;
            startList.add(block.start_date_time__c);
            stopList.add(block.stop_date_time__c);
        }
        startList.sort(); //sort ascending
        stopList.sort(); //sort ascending
        startSearch = startList[0];
        stopSearch = stopList[stopList.size() - 1]; //sort ascending, so get the last item

        //b. Run a query to get all “To Block” events between this date range.
        //SOQL 2
        list<Astrum_Event__c> toBlockEvents = getBlockingAstrumEvents(startSearch, stopSearch, astrumEvent.ownerid);

        //c. For each Availability Block:
        system.debug(debugSection + 'Loop through the overlapping blocks, size: ' + overlappingBlocks.size());
        for(Astrum_Event__c block : overlappingBlocks){
            system.debug(debugSection + 'Inside for.... this block: ' + block.id);
            string origStatus = block.status__c;
            system.debug(debugSection + 'Original block status: ' + origStatus);

            //i. Set to Available initially
            block.status__c = 'Available';

            //ii.Loop through the “To Block” events and if there are any date overlaps then set to Unavailable.
            for(Astrum_Event__c evt : toBlockEvents){
                system.debug(debugSection + 'Inside for... this blocking type event: ' + evt.id);
                if(
                    //If the event start falls between the start and before stop of block
                    (evt.Start_Date_Time__c >= block.start_date_time__c && evt.Start_Date_Time__c < block.stop_date_time__c) 
                    ||
                    //If the event stop falls after the start through stop of block
                    (evt.Stop_Date_Time__c > block.start_date_time__c && evt.Stop_Date_Time__c <= block.stop_date_time__c) 
                    ||
                    //If the entire block falls inside of the event start/stop or they match exactly
                    (evt.Start_Date_Time__c <= block.start_date_time__c && evt.Stop_Date_Time__c >= block.stop_date_time__c) 
                ){
                    system.debug(debugSection + 'Found an overlapping event that blocks out availability: ' + evt.id);
                    block.status__c = 'Unavailable';
                    break;
                }
            }
            system.debug(debugSection + 'Block status after logic: ' + block.status__c);

            //Look for a change in status to see if it's worth putting in update list for dml update
            if(block.status__c != origStatus){
                //Add to map for update, only if it's not been added/handled before
                if(!astrumEventsToUpdateMap.containskey(block.id)) astrumEventsToUpdateMap.put(block.id, new Astrum_Event__c(id = block.id, status__c = block.status__c));              
            }
        }
    }

    //Definition of “To Block” event: NOT(Manually Deleted or Automatically Deleted) 
    //and (Sales Visit and (Scheduled, Disqualified, Completed)) or (non-sales visit record type)
    private boolean isABlockingAstrumEvent(Astrum_Event__c astrumEvent){
        system.debug(debugSection + 'isABlockingAstrumEvent');
        boolean isBlocking = false;
        set<string> blockingStatuses = new set<string>{'Scheduled', 'Schedule Pending', 'Disqualified', 'Completed'};

        if(astrumEvent.Event_Automatically_Deleted__c == false
                && astrumEvent.Event_Manually_Deleted__c == false
                && (
                        //If this is a sales visit and certain statuses, then it's blocking.
                        (salesVisitRTIDs.contains(astrumEvent.RecordTypeid) && astrumEvent.status__c != null && blockingStatuses.contains(astrumEvent.status__c))
                        ||
                        //If this is not a sales visit and not an availability block, it's a blocking event.
                        (!salesVisitRTIDs.contains(astrumEvent.RecordTypeid) && astrumEvent.RecordTypeid != availabilityBlockRTID)
                    )
                ){
            isBlocking = true;
        }
        return isBlocking;
    }

    private list<Astrum_Event__c> getOverlappingBlocks(datetime startSearch, datetime stopSearch, boolean isAllDayEvent, id ownerid){
        system.debug(debugSection + 'getOverlappingBlocks');
        list<Astrum_Event__c> overlappingBlocks = [select id, start_date_time__c, stop_date_time__c, status__c
                                                   from Astrum_Event__c
                                                   where ownerID =: ownerid
                                                   and Event_Automatically_Deleted__c = false
                                                   and Event_Manually_Deleted__c = false
                                                   and RecordTypeid =: availabilityBlockRTID
                                                   and (
                                                            (Start_Date_Time__c >= :startSearch AND Start_Date_Time__c < :stopSearch) OR
                                                            (Stop_Date_Time__c  > :startSearch AND Stop_Date_Time__c  <= :stopSearch) OR
                                                            (Start_Date_Time__c <= :startSearch AND Stop_Date_Time__c  >= :stopSearch)
                                                        )];
        system.debug(debugSection + 'overlappingBlocks.size: ' + overlappingBlocks.size());
        return overlappingBlocks;
    }

    private list<Astrum_Event__c> getBlockingAstrumEvents(datetime startSearch, datetime stopSearch, id ownerid){
        system.debug(debugSection + 'getBlockingAstrumEvents');
        system.debug(debugSection + 'startSearch: ' + startSearch);
        system.debug(debugSection + 'stopSearch: ' + stopSearch);
        system.debug(debugSection + 'ownerid: ' + ownerid);
        list<Astrum_Event__c> toBlockEvents = [select id, start_date_time__c, stop_date_time__c 
                                                   from Astrum_Event__c
                                                   where ownerID =: ownerid
                                                   and Event_Automatically_Deleted__c = false
                                                   and Event_Manually_Deleted__c = false
                                                   and (
                                                            (RecordTypeID in : salesVisitRTIDs
                                                            and status__c in ('Scheduled', 'Disqualified', 'Completed'))
                                                            or
                                                            (RecordTypeID not in : salesVisitRTIDs and RecordTypeID !=: availabilityBlockRTID)
                                                        )
                                                   and (
                                                            (Start_Date_Time__c >= :startSearch AND Start_Date_Time__c < :stopSearch) OR
                                                            (Stop_Date_Time__c  > :startSearch AND Stop_Date_Time__c  <= :stopSearch) OR
                                                            (Start_Date_Time__c <= :startSearch AND Stop_Date_Time__c  >= :stopSearch)
                                                        )];
        system.debug(debugSection + 'toBlockEvents.size: ' + toBlockEvents.size());
        return toBlockEvents;
    }
    
    private integer getBlockingAstrumEventsCount(datetime startSearch, datetime stopSearch, id ownerid){
        system.debug(debugSection + 'getBlockingAstrumEventsCount');
        integer toBlockEvents = [select count() from Astrum_Event__c
                                   where ownerID =: ownerid
                                   and Event_Automatically_Deleted__c = false
                                   and Event_Manually_Deleted__c = false
                                   and (
                                            (RecordTypeID in : salesVisitRTIDs
                                            and status__c in ('Scheduled', 'Disqualified', 'Completed'))
                                            or
                                            (RecordTypeID not in : salesVisitRTIDs and RecordTypeID !=: availabilityBlockRTID)
                                        )
                                   and (
                                                (Start_Date_Time__c >= :startSearch AND Start_Date_Time__c < :stopSearch) OR
                                            (Stop_Date_Time__c  > :startSearch AND Stop_Date_Time__c  <= :stopSearch) OR
                                            (Start_Date_Time__c <= :startSearch AND Stop_Date_Time__c  >= :stopSearch)
                                    )];
        system.debug(debugSection + 'toBlockEvents integer: ' + toBlockEvents);
        return toBlockEvents;
    }   

}