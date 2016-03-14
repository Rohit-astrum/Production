//Test in scheduling:   https://c.cs7.visual.force.com/apex/AstrumEventEdit?oppid=006M0000008RbUV&retURL=%2F006M0000008RbUV&debug=1
public with sharing class AstrumEventController {

    public Astrum_Event__c event {get;set;}    
    public Opportunity opp {get;set;}
    public Lead theLead {get;set;}
    public boolean isNew {get;set;}
    public boolean showHS {get;set;}    
    public List<selectOption> dates{get; set;}
    public List<selectOption> times{get; set;} 
    public String chosenDate {get;set;}    
    public id chosenTime {get;set;}
    public boolean hideForm {get;set;}
    public contact dummyContact {get;set;}

    //Public so they show in debug mode
    public boolean debug {get;set;}
    public list<Astrum_Event__c> eventOptions{get;set;} //list of ordered dates/times available filtered by the most available rep for the day
    public list<Astrum_Event__c> openBlocks{get;set;} //list of ordered dates/times available filtered by county availability   
    public date nextScheduleStart{get;set;}
    public list<Zip_Code_Schedule_Availability__c> potentialReps{get;set;}        
    public string state{get;set;}
    public string county{get;set;}
    public string qasCounty{get;set;}
    public string tzID{get;set;}
    //public TimeZone localTZ{get;set;} //Timezone local to the customer/Sales person
    
    private AstrumEventSettings__c settings;
    public boolean viewRestricted {get;set;}
    private date lastDateShown;  
    private date lastScheduleStart;    
    private string address1;
    private string address2;
    private string city;
    private string zip;
    private string salesRegion;
    private Astrum_Sales_Region__c region;
    
    public AstrumEventController(){
        system.debug('AstrumEventController');
        hideForm = false;
        debug = false;
        viewRestricted = false;
        dummyContact = new contact();
        system.debug('Get custom settings'); 
        settings = AstrumEventSettings__c.getInstance(UserInfo.getUserId());
        if (settings == null
            || settings.Number_day_options_to_return__c == null
            || settings.Number_days_to_schedule_new_visits_out__c == null            
            || settings.Default_Onsite_Sales_Visit_Subject__c == null
            || settings.Open_Blocks_SOQL__c == null            
        ){
            hideForm = true; 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Missing required custom settings in AstrumEventSettings__c. Please contact your administrator.'));
            return;
        }        
        
        
        

        
        system.debug('Look for url parameters');
        Map<String,String> params = ApexPages.currentPage().getParameters();        
        string eventID = params.get('id');
        string oppID = params.get('oppid');
        string leadID = params.get('leadid');
        string retUrl = params.get('retURL');
        system.debug('eventid: ' + eventID); 
        system.debug('oppID: ' + oppID);
        system.debug('leadID: ' + leadID);

        if(retUrl != null && retUrl != '')
        {
            showHS = true;
        }
        else
        {
            showHS = false;    
        }

        if(eventID == null || eventID == ''){ 
            isNew = true;
            event = new Astrum_Event__c(); 
            if(oppID != null && oppID != '') event.Opportunity__c = oppID;
            if(leadID != null && leadID != '') event.Lead__c = leadID;
        }else{
            event = [select id, name, Opportunity__c, Lead__c, start_date_time__c, stop_date_time__c from Astrum_Event__c where id =: eventID];
        } 

        if(event.Opportunity__c == null && event.Lead__c == null){
            hideForm = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Opportunity or Lead is selected, missing link.'));
            return; 
        }
        

        if(event.Opportunity__c != null){
            try{
                opp = [select id, Name, Property__c, Property__r.Property_County__c, Property__r.QAS_Property_County__c, 
                            Property__r.Property_City__c, Property__r.Name, Property__r.Property_Address_2__c, Property__r.Property_State__c, 
                            Property__r.Property_ZIP__c, Property__r.Time_Zone__c, Sales_Region__c,
                            (SELECT ContactId, Contact.Name, IsPrimary, Role FROM OpportunityContactRoles)
                       from Opportunity 
                       where id =: event.Opportunity__c];
            }catch(exception e){
                hideForm = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to locate Opportunity: ' + e));
                return; 
            }

            if(opp.property__r.Time_Zone__c == null){
                hideForm = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to schedule for this Property because the Time Zone can not be calculated for the property\'s state'));
                return;
            }
            //localTZ = TimeZone.getTimeZone(opp.property__r.Time_Zone__c);
            tzID = opp.property__r.Time_Zone__c;
            state = opp.Property__r.Property_State__c;
            county = opp.Property__r.Property_County__c;
            qasCounty = opp.Property__r.QAS_Property_County__c;

            address1 = opp.Property__r.Name;            
            address2 = opp.Property__r.Property_Address_2__c;
            city = opp.Property__r.Property_City__c;
            zip = opp.Property__r.Property_ZIP__c;
            salesRegion = opp.Sales_Region__c;

            
        }else if(event.Lead__c != null){
            try{
                theLead = [select id, Name, Street, County__c, QAS_County__c, City, State, PostalCode, Time_Zone__c, Sales_Region__c
                       from Lead
                       where id =: event.Lead__c];
            }catch(exception e){
                hideForm = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to locate Lead: ' + e));
                return; 
            }

            if(theLead.Time_Zone__c == null){
                hideForm = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to schedule for this Lead because the Time Zone can not be calculated for the Lead\'s state'));
                return;
            }
            //localTZ = TimeZone.getTimeZone(theLead.Time_Zone__c);
            tzID = theLead.Time_Zone__c;
            state = theLead.state;
            county = theLead.County__c;
            qasCounty = theLead.QAS_County__c;

            address1 = theLead.Street;
            address2 = null;
            city = theLead.City;
            zip = theLead.PostalCode;
            salesRegion = theLead.Sales_Region__c;
        }

        
        /*
            Set the local time zone object
            http://salesforce.stackexchange.com/questions/8538/convert-time-from-a-different-timezone-other-than-local-to-gmt
            string customerTimeZoneSidId = 'America/Los_Angeles';

            TimeZone customerTimeZone = TimeZone.getTimeZone(customerTimeZoneSidId);
            System.assertEquals('Pacific Standard Time',  customerTimeZone.getDisplayName());
        */  
        if(tzID == null || tzID == ''){
            hideForm = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to set the local time zone for this customer, please verify the State is correct.'));
            return;     
        }
        // Added by RJ
        if(salesRegion != null || salesRegion != ''){    
            try{        
                region = [Select backlog_in_days__c from Astrum_Sales_Region__c where Name = :salesRegion];     
            }
            catch(exception e){
                hideForm = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unidentified Sales Region: ' + e));
                return; 
            }
                
        }
        else
        {
            hideForm = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to identify the Sales Region for this customer address, please verify that Sales Region is correct.'));
            return;        
        }

        // Get time zone offset
        TimeZone userTz = UserInfo.getTimeZone();
        TimeZone tz = TimeZone.getTimeZone(tzID);
        Datetime backlogdate = Datetime.now().addDays((Integer)region.backlog_in_days__c);

        Integer tzOffset = tz.getOffset(backlogdate);
        Integer userOffset = userTz.getOffset(backlogdate);
        Integer tzDiff = tzOffset - userOffset;

        system.debug('**SZ: original code = ' + backlogdate);
        system.debug('**SZ: tz offset = ' +  tzOffset);
        system.debug('**SZ: user offset = ' +  userOffset);
        system.debug('**SZ: tz diff = ' +  tzDiff);
        system.debug('**SZ: new datetime = ' +  backlogdate.addSeconds(tzDiff/1000));

        nextScheduleStart = date.Today().addDays((integer)region.backlog_in_days__c);
        lastScheduleStart = nextScheduleStart;
        dummyContact.Birthdate = nextScheduleStart;

        //try{           
        //    tzID = localTZ.getID();
        //}catch(exception e){
        //    hideForm = true;
        //    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to set the local time zone: ' + e));
        //    return; 
        //}

        getAvailability(false); 

    }

    //Load the availability list
    private void getAvailability(Boolean showRestricted){
        system.debug('getAvailabilityByZipcode');

        if(nextScheduleStart < system.today()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to look for dates that are in the past.'));
            startOver();
            return;
        }

        String query = '';

        //soql to get the available field sales for this county using the Opportunity lookup to property
        dates = new List<selectOption>();
        times = new List<selectOption>(); 
        chosenDate = null;
        chosenTime =null;

        if(zip != null){
            String crit = 'Office_Zip_Code__r.Name = \'' + String.escapeSingleQuotes(zip).left(5) + '\'';
            system.debug('crit: ' + crit);
            
            system.debug('nextScheduleStart: ' + nextScheduleStart);
            query = ' SELECT id, Name, Employee__c, Employee__r.Name, Start_Date__c, End_Date__c FROM Zip_Code_Schedule_Availability__c ';
            query+= ' WHERE Employee__r.isactive = true ';
            query+= ' AND Employee__r.TimeZoneSidKey = : tzID ';
            query+= ' AND (Start_Date__c = null OR Start_Date__c <= :nextScheduleStart) ';
            query+= ' AND (End_Date__c = null OR End_Date__c >= :nextScheduleStart) ';
            query+= ' AND Type__c = \'Sales Rep\' ';
            query+= ' AND (' + crit + ')'; //, State_Abbreviation__c, Sales_Region__c, Available_Field_Sales__c';
            system.debug('query: ' + query);

            potentialReps = database.query(query);
            Map<Id, Zip_Code_Schedule_Availability__c> potentialRepsMap = new Map<Id, Zip_Code_Schedule_Availability__c>();
            for(Zip_Code_Schedule_Availability__c zcsa : potentialReps){
                potentialRepsMap.put(zcsa.Employee__c, zcsa);
            }
            
            if(potentialRepsMap.isEmpty()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Sales Reps are available in this zip code.'));
                return; 
            }

            //soql to get their astrum events calendar (filter out the current record if there is an ID);
            system.debug('SOQL for open blocks');
            Integer openBlocksRowLimit = 100;
            Datetime nextScheduleStarttimeGmt = Datetime.newInstanceGmt(nextScheduleStart.year(), nextScheduleStart.month(), nextScheduleStart.day(), 0, 0, 0);
            TimeZone tz = TimeZone.getTimeZone(tzID);
            Integer tzOffset = tz.getOffset(nextScheduleStarttimeGmt);

            system.debug('**SZ: tz offset = ' +  tzOffset);
            system.debug('**SZ: new datetime = ' +  nextScheduleStarttimeGmt.addSeconds(-1*tzOffset/1000));
            nextScheduleStarttimeGmt = nextScheduleStarttimeGmt.addSeconds(-1 * tzOffset / 1000);

            if(settings.Open_Blocks_SOQL__c != null && (Integer)settings.Open_Blocks_SOQL__c > 0) openBlocksRowLimit = (Integer)settings.Open_Blocks_SOQL__c;

            if(!showRestricted)
            {
                openBlocks = [Select id, Name, start_date_time__c, stop_date_time__c, DurationInMinutes__c, ownerid, owner.name
                                                    From Astrum_Event__c
                                                    Where ownerid in : potentialRepsMap.keyset()
                                                    And RecordType.DeveloperName = 'Availability_Block'
                                                    And Status__c = 'Available'
                                                    And start_date_time__c >= : nextScheduleStarttimeGmt
                                                    And Is_Day_Limit_Reached__c = false
                                                    And Is_Week_Limit_Reached__c = false
                                                    Order by start_date_time__c ASC
                                                    Limit : openBlocksRowLimit];
                                                    //Ordering by start date instead of user so that we get the earliest available openings and can still limit the query.
            }
            else
            {
                openBlocks = [Select id, Name, start_date_time__c, stop_date_time__c, DurationInMinutes__c, ownerid, owner.name
                                                    From Astrum_Event__c
                                                    Where ownerid in : potentialRepsMap.keyset()
                                                    And RecordType.DeveloperName = 'Availability_Block'
                                                    And Status__c = 'Available'
                                                    And start_date_time__c >= : nextScheduleStarttimeGmt                                            
                                                    Order by start_date_time__c ASC
                                                    Limit : openBlocksRowLimit];    
            }
            if(openBlocks.isEmpty()){               
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Sales Reps have availablity on their schedule for this zip code after this date: ' + datetime.newInstance(nextScheduleStart, Time.newInstance(0,0,0,0)).format('E, MMM dd, yy')));
                return;
            }

            //Get the days that we need to check availability density on for the reps
            Map<Date, id> openDays = new Map<Date, id>();

            //Fill list from openBlocks
            List<Astrum_Event__c> openBlocksFiltered = new List<Astrum_Event__c>();
            
            //Build a map of all available Start times.
            Map<datetime, id> startDateTimeWinnerIDMap = new Map<datetime, id>();

            //looping instead of aggregate because the aggregate could retun too many rows without a limit            
            for(Astrum_Event__c ae : openBlocks){
                //LIST ORDER IS KEY, THIS IS SORTED BY START DATE ASC
                //MAPS DO NOT SORT, CAN'T DEPEND ON MAP ORDER WHEN USING METHODS LIKE KEYSET OR VALUES
                
                //Get just the Days in a map
                Date curDate = ae.start_date_time__c.date();
                openDays.put(curDate, null); //.put method will overwrite matching dates, so when we reach Number_day_options_to_return__c...
                lastDateShown = curDate;
                openBlocksFiltered.add(ae);
                
                //Get unique list of startdatetime which we will use later on to populate the correct user id
                Datetime curDatetime = ae.start_date_time__c; //this will store the gmt datetime
                if(!startDateTimeWinnerIDMap.containskey(curDatetime)) startDateTimeWinnerIDMap.put(curDatetime, null);
                
                //Exit the loop if we've gathered all of the dates we need
                if(openDays.size() == (Integer)settings.Number_day_options_to_return__c) break; //We've got # dates now, we are good to move on.
            }

            
            //TODO: Loop through the sales rep availability start/stop dates and make sure that they are available for all of the 
            //      days listed in the openDays map.  Remove the user from the potential reps map, 
            //      display an error on screen if there are no reps
             


            //Check density of the reps calendars to rate them on this and schedule accordingly, do this locally so it's 1 less query
            system.debug('Check availability count for each rep');
            //Using converttimezone function because otherwise it will run GMT.  GMT might be 1am the next day for a PDT 6pm datetime, 
            //this will at least run as EDT or PDT so it's in the correct day and groups properly.
            AggregateResult[] groupedResults = [SELECT ownerid, DAY_ONLY(convertTimezone(start_date_time__c)) day, SUM(DurationInMinutes__c) total
                                                FROM Astrum_Event__c
                                                WHERE ownerid in : potentialRepsMap.keyset()
                                                AND RecordType.DeveloperName = 'Availability_Block'
                                                AND Status__c = 'Available'
                                                AND DAY_ONLY(convertTimezone(start_date_time__c)) in : openDays.keyset()
                                                GROUP BY ownerid, DAY_ONLY(convertTimezone(start_date_time__c))
                                                ORDER BY DAY_ONLY(convertTimezone(start_date_time__c)) ASC, SUM(DurationInMinutes__c) DESC];            
            Date previousDate;
            for (AggregateResult ar : groupedResults)  {             
                Date curDate = (Date)ar.get('day');
                //system.debug('curDate: ' + curDate);
                //system.debug('ownerid: ' + ar.get('ownerid'));
                //system.debug('total: ' + ar.get('total'));
                //The rep with the most availability will be first for each of the days
                if(previousDate == null || previousDate != curDate){                    
                    system.debug('We have a new winner');
                    openDays.put(curDate, (id)ar.get('ownerid'));
                    previousDate = curDate;
                }//else we are moving to the next record
            }
            //openDays Map is now our list of the Days with the preferred rep with the most availability that day.

            for(Astrum_Event__c ae : openBlocksFiltered){
                Date curDate = ae.start_date_time__c.date(); //Date() function runs as current user time zone, which matches the aggregate
                Datetime curDatetime = ae.start_date_time__c; //this will store the gmt date/time which matches the winners map

                if(startDateTimeWinnerIDMap.get(curDateTime) == null){
                    //Fill in with the first rep regardless of the day winner
                    startDateTimeWinnerIDMap.put(curDateTime, ae.ownerid);
                }else{                    
                    //if this event is in the map of openDays, check to see if it's the winners event
                    if(openDays.containskey(curDate) && openDays.get(curDate) == ae.ownerid){
                        //Only overwrite id if this is the daily winner and it's one of their time slots
                        startDateTimeWinnerIDMap.put(curDateTime, ae.ownerid);
                    }
                }
            }

            //Populate the lists on screen                      
            eventOptions = new list<Astrum_Event__c>();
            for(Astrum_Event__c ae : openBlocksFiltered){
                Date curDate = ae.start_date_time__c.date(); //Date() function runs as current user time zone, which matches the aggregate
                Datetime curDatetime = ae.start_date_time__c; //this will store the gmt date/time which matches the winners map
                
                //LIST ORDER IS KEY, openBlocksFiltered IS SORTED BY START DATE ASC
                if(startDateTimeWinnerIDMap.get(curDatetime) == ae.ownerid){
                    system.debug('This block is the correct one, the winner for that time slot');
                    //Add this time slot linked to the rep, this is sorted already for time asc
                    eventOptions.add(ae);                   
                    if(chosenDate == null) chosenDate = string.valueof(curDate);
                }
            }

            loadDateOptions();
            loadTimeOptions();

            //Setup the next search date, the user can modify this and search again
            nextScheduleStart = lastDateShown.addDays(1);
            dummyContact.Birthdate = nextScheduleStart;
        }


        //TODO: If Solarize/community program, grab only those reps if they exist.
    }

/*
    //Load the availability list
    private void getAvailability(Boolean showRestricted){
        system.debug('getAvailability');
        
        if(nextScheduleStart < system.today()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to look for dates that are in the past.'));
            startOver();
            return;
        }

        String query;
        
        //soql to get the available field sales for this county using the Opportunity lookup to property
        dates = new List<selectOption>();
        times = new List<selectOption>(); 
        chosenDate = null;
        chosenTime =null;
            
        if(state != null 
            && (state == 'DC' 
                || county != null 
                || qasCounty != null)
            ){
                        
            system.debug('This is valid for searching for the county, build the query to search for reps');
            String crit = '(County__r.State_Abbreviation__c = \'' + String.escapeSingleQuotes(state) + '\'';
            if (state != 'DC') {
                crit += ' AND County__r.Name LIKE \'' + String.escapeSingleQuotes(qasCounty != null ? qasCounty : SalesRegionHelper.removeState(county)) + '%\'';
            }
            crit += ')';
            system.debug('crit: ' + crit);
            
            
            system.debug('nextScheduleStart: ' + nextScheduleStart);
            query = ' SELECT id, County__r.Name, Employee__c, Employee__r.Name, Start_Date__c, End_Date__c FROM County_Schedule_Availability__c ';
            query+= ' WHERE Employee__r.isactive = true ';
            query+= ' AND Employee__r.TimeZoneSidKey = : tzID ';
            query+= ' AND County__r.Sales_Region__c <> NULL ';
            query+= ' AND (Start_Date__c = null OR Start_Date__c <= :nextScheduleStart) ';
            query+= ' AND (End_Date__c = null OR End_Date__c >= :nextScheduleStart) ';
            query+= ' AND Type__c = \'Sales Rep\' ';
            query+= ' AND (' + crit + ')'; //, State_Abbreviation__c, Sales_Region__c, Available_Field_Sales__c';
            system.debug('query: ' + query);
            potentialReps = database.query(query);
            if(potentialReps.isEmpty()){                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Sales Reps are available in this county.'));
                return; 
            }

            //Build map of rep IDs with their county availability 
            map<id, County_Schedule_Availability__c> potentialRepsMap = new map<id, County_Schedule_Availability__c>();
            for(County_Schedule_Availability__c csa : potentialReps){
                potentialRepsMap.put(csa.Employee__c, csa);
            }
            
            //soql to get their astrum events calendar (filter out the current record if there is an ID);
            system.debug('SOQL for open blocks');
            Integer openBlocksRowLimit = 100;
            if(settings.Open_Blocks_SOQL__c != null && (Integer)settings.Open_Blocks_SOQL__c > 0) openBlocksRowLimit = (Integer)settings.Open_Blocks_SOQL__c;

            if(!showRestricted)
            {
                openBlocks = [Select id, Name, start_date_time__c, stop_date_time__c, DurationInMinutes__c, ownerid, owner.name
                                                    From Astrum_Event__c
                                                    Where ownerid in : potentialRepsMap.keyset()
                                                    And RecordType.DeveloperName = 'Availability_Block'
                                                    And Status__c = 'Available'
                                                    And start_date_time__c >= : nextScheduleStart
                                                    And Is_Day_Limit_Reached__c = false
                                                    And Is_Week_Limit_Reached__c = false
                                                    Order by start_date_time__c ASC
                                                    Limit : openBlocksRowLimit];
                                                    //Ordering by start date instead of user so that we get the earliest available openings and can still limit the query.
            }
            else
            {
                openBlocks = [Select id, Name, start_date_time__c, stop_date_time__c, DurationInMinutes__c, ownerid, owner.name
                                                    From Astrum_Event__c
                                                    Where ownerid in : potentialRepsMap.keyset()
                                                    And RecordType.DeveloperName = 'Availability_Block'
                                                    And Status__c = 'Available'
                                                    And start_date_time__c >= : nextScheduleStart                                                   
                                                    Order by start_date_time__c ASC
                                                    Limit : openBlocksRowLimit];    
            }
            if(openBlocks.isEmpty()){               
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Sales Reps have availablity on their schedule for this county after this date: ' + datetime.newInstance(nextScheduleStart, Time.newInstance(0,0,0,0)).format('E, MMM dd, yy')));
                return;
            }

            //Get the days that we need to check availability density on for the reps
            map<Date, id> openDays = new map<Date, id>();

            //Fill list from openBlocks
            list<Astrum_Event__c> openBlocksFiltered = new list<Astrum_Event__c>();
            
            //Build a map of all available Start times.
            map<datetime, id> startDateTimeWinnerIDMap = new map<datetime, id>();

            //looping instead of aggregate because the aggregate could retun too many rows without a limit            
            for(Astrum_Event__c ae : openBlocks){
                //LIST ORDER IS KEY, THIS IS SORTED BY START DATE ASC
                //MAPS DO NOT SORT, CAN'T DEPEND ON MAP ORDER WHEN USING METHODS LIKE KEYSET OR VALUES
                
                //Get just the Days in a map
                Date curDate = ae.start_date_time__c.date();
                openDays.put(curDate, null); //.put method will overwrite matching dates, so when we reach Number_day_options_to_return__c...
                lastDateShown = curDate;
                openBlocksFiltered.add(ae);
                
                //Get unique list of startdatetime which we will use later on to populate the correct user id
                Datetime curDatetime = ae.start_date_time__c; //this will store the gmt datetime
                if(!startDateTimeWinnerIDMap.containskey(curDatetime)) startDateTimeWinnerIDMap.put(curDatetime, null);
                
                //Exit the loop if we've gathered all of the dates we need
                if(openDays.size() == (Integer)settings.Number_day_options_to_return__c) break; //We've got # dates now, we are good to move on.
            }

            
            //TODO: Loop through the sales rep availability start/stop dates and make sure that they are available for all of the 
            //      days listed in the openDays map.  Remove the user from the potential reps map, 
            //      display an error on screen if there are no reps
             


            //Check density of the reps calendars to rate them on this and schedule accordingly, do this locally so it's 1 less query
            system.debug('Check availability count for each rep');
            //Using converttimezone function because otherwise it will run GMT.  GMT might be 1am the next day for a PDT 6pm datetime, 
            //this will at least run as EDT or PDT so it's in the correct day and groups properly.
            AggregateResult[] groupedResults = [SELECT ownerid, DAY_ONLY(convertTimezone(start_date_time__c)) day, SUM(DurationInMinutes__c) total
                                                FROM Astrum_Event__c
                                                WHERE ownerid in : potentialRepsMap.keyset()
                                                AND RecordType.DeveloperName = 'Availability_Block'
                                                AND Status__c = 'Available'
                                                AND DAY_ONLY(convertTimezone(start_date_time__c)) in : openDays.keyset()
                                                GROUP BY ownerid, DAY_ONLY(convertTimezone(start_date_time__c))
                                                ORDER BY DAY_ONLY(convertTimezone(start_date_time__c)) ASC, SUM(DurationInMinutes__c) DESC];            
            Date previousDate;
            for (AggregateResult ar : groupedResults)  {             
                Date curDate = (Date)ar.get('day');
                //system.debug('curDate: ' + curDate);
                //system.debug('ownerid: ' + ar.get('ownerid'));
                //system.debug('total: ' + ar.get('total'));
                //The rep with the most availability will be first for each of the days
                if(previousDate == null || previousDate != curDate){                    
                    system.debug('We have a new winner');
                    openDays.put(curDate, (id)ar.get('ownerid'));
                    previousDate = curDate;
                }//else we are moving to the next record
            }
            //openDays Map is now our list of the Days with the preferred rep with the most availability that day.

            //Pick a rep for each startdatetime
            /*Example:
                Winner for the day = "John Most Available"
                "John Most Available" - Open start time slots:
                    9am
                    12am
                    6pm

                Other Rep = "Sam"
                "Sam" - Open start time slots:                    
                    12am
                    3pm
                    

                Other Rep = "Tom"
                "Tom" - Open start time slots:                    
                    6am
                    12am
                    
                Other Rep = "Suzy"
                "Suzy" - Open start time slots:                    
                    6pm

                Goal:
                    6am - "Tom"
                    9am - "John Most Available"
                    12am - "John Most Available" (overwrites "Sam" and "Tom")
                    3pm - "Sam"
                    6pm - "John Most Available" (overwrites "Suzy")
            */

/*            for(Astrum_Event__c ae : openBlocksFiltered){
                Date curDate = ae.start_date_time__c.date(); //Date() function runs as current user time zone, which matches the aggregate
                Datetime curDatetime = ae.start_date_time__c; //this will store the gmt date/time which matches the winners map

                if(startDateTimeWinnerIDMap.get(curDateTime) == null){
                    //Fill in with the first rep regardless of the day winner
                    startDateTimeWinnerIDMap.put(curDateTime, ae.ownerid);
                }else{                    
                    //if this event is in the map of openDays, check to see if it's the winners event
                    if(openDays.containskey(curDate) && openDays.get(curDate) == ae.ownerid){
                        //Only overwrite id if this is the daily winner and it's one of their time slots
                        startDateTimeWinnerIDMap.put(curDateTime, ae.ownerid);
                    }
                }
            }

            //Populate the lists on screen                      
            eventOptions = new list<Astrum_Event__c>();
            for(Astrum_Event__c ae : openBlocksFiltered){
                Date curDate = ae.start_date_time__c.date(); //Date() function runs as current user time zone, which matches the aggregate
                Datetime curDatetime = ae.start_date_time__c; //this will store the gmt date/time which matches the winners map
                
                //LIST ORDER IS KEY, openBlocksFiltered IS SORTED BY START DATE ASC
                if(startDateTimeWinnerIDMap.get(curDatetime) == ae.ownerid){
                    system.debug('This block is the correct one, the winner for that time slot');
                    //Add this time slot linked to the rep, this is sorted already for time asc
                    eventOptions.add(ae);                   
                    if(chosenDate == null) chosenDate = string.valueof(curDate);
                }
            }

            loadDateOptions();
            loadTimeOptions();

            //Setup the next search date, the user can modify this and search again
            nextScheduleStart = lastDateShown.addDays(1);
            dummyContact.Birthdate = nextScheduleStart;
        }


        //TODO: If Solarize/community program, grab only those reps if they exist.
    }
*/

    private void loadDateOptions(){
        system.debug('LoadDateOptions');        
        dates = new list<selectOption>();
        Date previousDate;
        //Load the Dates Options on screen
        for(Astrum_Event__c ae : eventOptions){        
            Date curDate = ae.start_date_time__c.date(); //.date() returns local user time which as long as current user
            //is EDT or PDT will pull the correct Date.  If this user is East of the GMT line, it will show the wrong date, 1 day ahead.
            
            if(previousDate == null || previousDate != curDate){
                //datetime date_time = datetime.newInstance(curDate, Time.newInstance(0,0,0,0));                
                dates.add(new selectOption(string.valueof(curDate), ae.start_date_time__c.format('E, MMM dd, yy', tzID)));
                previousDate = curDate;
            }
        }
    }

    private void loadTimeOptions(){
        system.debug('LoadTimeOptions');
        times = new list<selectOption>();
        Time previousTime;
        chosenTime = null;

        //Set the offset for the chosen Date
        //integer tzOffset = getTZOffset(datetime.newInstance(chosenDate, Time.newInstance(0,0,0,0)));        

        //Load the Times Options on screen
        for(Astrum_Event__c ae : eventOptions){        
            if(string.valueof(ae.start_date_time__c.date()) != chosenDate) continue; //skip
            Time curTime = ae.start_Date_time__c.Time();
            if(previousTime == null || previousTime != curTime){            
                //This is a time that should be loaded right now
                if(chosenTime == null) chosenTime = ae.id; //Load the first time in the day

                //Show the time in proper time zone aware format
                datetime date_time = datetime.newInstance(ae.start_date_time__c.date(), curTime);                
                Times.add(new selectOption(ae.id, date_time.format('hh:mm a zzzzz', tzID)));

       //       datetime date_time = datetime.newInstance(ae.start_date_time__c.date(), curTime);
       //         Times.add(new selectOption(ae.id, date_time.format('hh:mm a zzzzz')));
                previousTime = curTime;
            }
        }
    }

    //private integer getTZOffset(datetime date_time){
    //    //localTZ has to be set prior
    //    long tzMillSec = localTZ.getOffset(date_time);
    //    return (integer)(tzMillSec / (1000 * 60));
    //    //Returns the offset in minutes
    //}

    public pagereference dateChanged(){
        loadTimeOptions();
        return null;
    }

    public pagereference lookForMore(){
        nextScheduleStart = dummyContact.Birthdate; //Take potential user input
        lastScheduleStart = nextScheduleStart;
        getAvailability(false);
        viewRestricted = false;
        return null;
    }

    public pagereference showRestricted(){      
        nextScheduleStart = lastScheduleStart;
        viewRestricted = true;
        getAvailability(true);
        return null;
    }

    public pagereference hideRestricted(){      
        nextScheduleStart = lastScheduleStart;
        viewRestricted = false;
        getAvailability(false);
        return null;
    }

    public pagereference startOver(){
        nextScheduleStart = date.Today().addDays((integer)region.backlog_in_days__c);
        lastScheduleStart = nextScheduleStart;
        dummyContact.Birthdate = nextScheduleStart;
        getAvailability(false);
        viewRestricted = false;
        return null;
    }

    public pagereference bookit(){
        //Find the currently selected eventid/time
        Astrum_Event__c bookThisBlock;      
        for(Astrum_Event__c ae : eventOptions){ 
            if(ae.id == chosenTime){
                bookThisBlock = ae;
                break;
            }
        }

        //Re-SOQL the event block to confirm that it's still available, and to confirm that the time has not been modified, use this for update
        Astrum_Event__c verifyBlock = [Select id, start_date_time__c, stop_date_time__c, Status__c, ownerid
                                            From Astrum_Event__c
                                            Where id =: bookThisBlock.id];

        if(bookThisBlock.start_date_time__c != verifyBlock.start_date_time__c 
            || verifyBlock.Status__c != 'Available'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The chosen time slot has just been modified by another user and is not available.  The Date/Time options have been re-loaded for you to try again.'));
            return startOver();
        }

        Astrum_Event__c bookThisVisit = new Astrum_Event__c();
        bookThisVisit.RecordTypeid = [select id from RecordType where sObjectType = 'Astrum_Event__c' and DeveloperName = 'Sales_Visit_Onsite'].id;
        string subject = (settings.Default_Onsite_Sales_Visit_Subject__c + ' - ' + (opp != null ? opp.Name : theLead.Name + ' - ' + address1));
        if(subject.length() > 80) subject = subject.substring(0,79);
        bookThisVisit.Subject__c = subject;
        bookThisVisit.Location__c = address1 + (address2 == null ? '' : ' ' + address2) + ', ' + city + ', ' + state + ' ' + zip;
        bookThisVisit.start_date_time__c = verifyBlock.start_date_time__c;
        bookThisVisit.stop_date_time__c = verifyBlock.stop_date_time__c;
        
        //record date/time so it can be used in the email, or shown on page layout for event.
        bookThisVisit.Customer_Start_Date_Time_Text__c = verifyBlock.Start_Date_Time__c.format('M/d/yyyy h:mm a zzzzz', tzID);
        bookThisVisit.Customer_Stop_Date_Time_Text__c = verifyBlock.Stop_Date_Time__c.format('M/d/yyyy h:mm a zzzzz', tzID);

        bookThisVisit.ownerid = verifyBlock.ownerid;
        bookThisVisit.Status__c = 'Schedule Pending';
        if(opp != null){
            bookThisVisit.Opportunity__c = opp.id;
            //Get the correct contact to link to the event, take the primary, or select the first one
            if(Opp.OpportunityContactRoles != null && Opp.OpportunityContactRoles.size() > 0){
                for(OpportunityContactRole contact : opp.OpportunityContactRoles){
                    if(contact.IsPrimary){
                        bookThisVisit.Contact__c = contact.contactid;
                        break;
                    }
                } 
                if(bookThisVisit.Contact__c == null) bookThisVisit.Contact__c = opp.OpportunityContactRoles[0].contactid;
            }
        }
        if(theLead != null) bookThisVisit.Lead__c = theLead.id;
        

        //TriggerUtility.skipAstrumEventTrigger = true; //Skip event trigger so that the recalculation of availability does not run while in this in-between status.
        insert bookThisVisit; //Once this get's set to Scheduled, the trigger will run and sync to calendar and recalculate availability

        //Success, make block unavailable
        //verifyBlock.Status__c = 'Unavailable';
        //update verifyBlock;

        //Send to new event page                
        Map<String,String> params = ApexPages.currentPage().getParameters();
        string retURL = params.get('retURL');        
        if(retURL == null){
            retURL = '';
        }

        PageReference pageRef = new PageReference('/apex/AstrumEventToSchedule');
        pageref.getParameters().put('id',bookThisVisit.id);
        pageref.getParameters().put('retURL',retURL);        
        //URL Hack to set the scheduled status so that when the user types up the notes and saves, the record will make it to calendar and send email
        //pageref.getParameters().put(settings.Astrum_Event_Status_Field_Form_ID__c,'Scheduled');
        return pageRef;
    }

    public pagereference cancel(){
        Map<String,String> params = ApexPages.currentPage().getParameters();
        string retURL = params.get('retURL');        
        if(retURL == null){
            retURL = '';
            return new PageReference('javascript:self.close()');
        }else{
            retURL = EncodingUtil.urlDecode(retURL, 'UTF-8');
            return new PageReference(retURL); 
        }
        //PageReference pageRef = new PageReference(retURL);        
        //return pageRef;
    }

}