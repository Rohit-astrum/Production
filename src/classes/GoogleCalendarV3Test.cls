/* FILE: GoogleCalendarV3Test.cls
 * AUTHOR: Tino Mattheou
 * DATE: May 11, 2012
 * PURPOSE: Test class for GoogleCalendarV3 class  
 * MODIFICATION HISTORY
 * change for push
 */ 
 
@isTest
private class GoogleCalendarV3Test {

    static testMethod void deserializeTest() {
    	
    	GoogleCalendarV3 gCal = new GoogleCalendarV3(null, null);
    	JSONParser parser = JSON.createParser(SERIALIZED_RESPONSE);

    	GoogleCalendarV3.CalendarEvents events = new GoogleCalendarV3.CalendarEvents().deserialize(parser);

		System.assertNotEquals(null, events);
		System.assertEquals(2, events.items.size());

		System.assertEquals('calendar#events', events.kind);
		System.assertEquals('"NvHxTTtMBgLPgyiAM57hud7kBKk/PrxnUm5FM6u0W_BBUjmM_P16e60"', events.etag);
		System.assertEquals('tino.mattheou@astrumsolar.com', events.summary);
		System.assertEquals(Datetime.newInstanceGmt(2012,5,8,20,57,57), events.updated);
		System.assertEquals('America/New_York', events.timeZone);
		System.assertEquals('owner', events.accessRole);
 		System.assertEquals(2, events.defaultReminders.size());
		System.assertEquals('email', events.defaultReminders[0].method);
		System.assertEquals(10, events.defaultReminders[0].minutes);
		System.assertEquals('popup', events.defaultReminders[1].method);
		System.assertEquals(10, events.defaultReminders[1].minutes);
		
		//event #1
		GoogleCalendarV3.CalendarEvent evt = events.items[0];
		System.assertEquals('calendar#event', evt.kind);
		System.assertEquals('"NvHxTTtMBgLPgyiAM57hud7kBKk/Q0xqa3RPbmhKaEVBQUFBQUFBQUFBQT09"', evt.etag);
		System.assertEquals('07bj32t9cv6pt96n17ki1cm5dg_20120316T190000Z', evt.id);
    	System.assertEquals('https://www.google.com/calendar/event?eid=MDdiajMydDljdjZwdDk2bjE3a2kxY201ZGdfMjAxMjAzMTZUMTkwMDAwWiB0aW5vLm1hdHRoZW91QGFzdHJ1bXNvbGFyLmNvbQ', evt.htmlLink);
		System.assertEquals(Datetime.newInstanceGmt(2012,3,12,2,9,20), evt.created);
		System.assertEquals(Datetime.newInstanceGmt(2012,3,16,20,22,43), evt.updated);
		System.assertEquals('Astrum PM Task Force', evt.summary);
		System.assertEquals('gotomeeting', evt.location);
		System.assertEquals('ben@astrumsolar.com', evt.creator.email);
		System.assertEquals('Ben Davis', evt.creator.displayName);
		System.assertEquals('ben@astrumsolar.com', evt.organizer.email);
		System.assertEquals('Ben Davis', evt.organizer.displayName);
		
		System.assertEquals(Datetime.newInstance(2012,3,16,15,0,0), evt.start.gDatetime);
		System.assertEquals(Datetime.newInstance(2012,3,16,16,0,0), evt.gEnd.gDatetime);
		System.assertEquals('07bj32t9cv6pt96n17ki1cm5dg', evt.recurringEventId);
		System.assertEquals(Datetime.newInstance(2012,3,16,15,0,0), evt.originalStartTime.gDateTime);
		System.assertEquals('07bj32t9cv6pt96n17ki1cm5dg@google.com', evt.iCalUID);
		System.assertEquals(0, evt.sequence);

       	System.assertEquals(true, evt.guestsCanInviteOthers);
       	System.assertEquals(true, evt.guestsCanSeeOtherGuests);
       	System.assertEquals(true, evt.reminders.useDefault);
		
		System.assertEquals(9, evt.attendees.size());
		System.assertEquals(true, evt.attendees[0].organizer);
		System.assertEquals('accepted', evt.attendees[0].responseStatus);
		System.assertEquals(true, evt.attendees[3].self);

		//event #2
		evt = events.items[1];
		System.assertEquals('calendar#event', evt.kind);
		System.assertEquals('"NvHxTTtMBgLPgyiAM57hud7kBKk/Q1BDSG5NRHhKaEVCQUFBQUFBQUFBQT09"', evt.etag);
		System.assertEquals('ffuukkc4vfm6pt1pt50ng4p1p4', evt.id);
		System.assertEquals('confirmed', evt.status);
    	System.assertEquals('https://www.google.com/calendar/event?eid=ZmZ1dWtrYzR2Zm02cHQxcHQ1MG5nNHAxcDRfMjAxMjAzMDVUMTQzMDAwWiB0aW5vLm1hdHRoZW91QGFzdHJ1bXNvbGFyLmNvbQ', evt.htmlLink);
		System.assertEquals(Datetime.newInstanceGmt(2012,3,5,14,28,50), evt.created);
		System.assertEquals(Datetime.newInstanceGmt(2012,5,4,13,25,42), evt.updated);
		System.assertEquals('Morning Stand Up', evt.summary);
		System.assertEquals('Skype for now.', evt.description);
		System.assertEquals('Video Chat', evt.location);
		System.assertEquals('stephen.simons@astrumsolar.com', evt.creator.email);
		System.assertEquals('Stephen Simons', evt.creator.displayName);
		System.assertEquals('stephen.simons@astrumsolar.com', evt.organizer.email);
		System.assertEquals('Stephen Simons', evt.organizer.displayName);
		
		System.assertEquals(Datetime.newInstance(2012,3,5,9,30,0), evt.start.gDatetime);
		System.assertEquals(Datetime.newInstance(2012,3,5,10,0,0), evt.gEnd.gDatetime);
		System.assertEquals('ffuukkc4vfm6pt1pt50ng4p1p4@google.com', evt.iCalUID);
		System.assertEquals(1, evt.sequence);

       	System.assertEquals(true, evt.guestsCanInviteOthers);
       	System.assertEquals(true, evt.guestsCanSeeOtherGuests);
       	System.assertEquals(false, evt.reminders.useDefault);
		
		System.assertEquals(2, evt.attendees.size());
		System.assertEquals(true, evt.attendees[0].self);
		System.assertEquals('accepted', evt.attendees[0].responseStatus);
		System.assertEquals('tino.mattheou@astrumsolar.com', evt.attendees[0].email);
		System.assertEquals('Constantine Mattheou', evt.attendees[0].displayName);
		System.assertEquals(true, evt.attendees[1].organizer);
		System.assertEquals('accepted', evt.attendees[1].responseStatus);
		System.assertEquals('stephen.simons@astrumsolar.com', evt.attendees[1].email);
		System.assertEquals('Stephen Simons', evt.attendees[1].displayName);
    	
    }
    
    static testMethod void calendarEvents_serialize_json() {
    	GoogleCalendarV3.CalendarEvents events = new GoogleCalendarV3.CalendarEvents();
    	
		events.kind = 'calendar#events';
		events.etag = '"NvHxTTtMBgLPgyiAM57hud7kBKk/PrxnUm5FM6u0W_BBUjmM_P16e60"';
		events.summary = 'tino.mattheou@astrumsolar.com';
		events.updated = Datetime.newInstanceGmt(2012,5,8,20,57,57);
		events.timeZone = 'America/New_York';
		events.accessRole = 'owner';
		events.items = new List<GoogleCalendarV3.CalendarEvent>();
		
		String eventsJSON = events.getAsString();
		
    	JSONGenerator generator = JSON.createGenerator(false);
    	events.serialize(generator);
    	String result = generator.getAsString();
    	
		System.assert(result.startsWith('{'));
		System.assert(result.endsWith('}'));
		System.assert(result.contains('"kind":"calendar#events"'));
		System.assert(result.contains('"etag":"\\"NvHxTTtMBgLPgyiAM57hud7kBKk/PrxnUm5FM6u0W_BBUjmM_P16e60\\""'));
		System.assert(result.contains('"summary":"tino.mattheou@astrumsolar.com"'));
		System.assert(result.contains('"updated":"2012-05-08T20:57:57.000Z"'));
		System.assert(result.contains('"timeZone":"America/New_York"'));
		System.assert(result.contains('"accessRole":"owner"'));
    }

    static testMethod void calendarEvent_serialize_json() {
    	GoogleCalendarV3.CalendarEvent evt = new GoogleCalendarV3.CalendarEvent();

		evt.kind = 'calendar#event';
		evt.etag = '"NvHxTTtMBgLPgyiAM57hud7kBKk/Q0xqa3RPbmhKaEVBQUFBQUFBQUFBQT09"';
		evt.id = '07bj32t9cv6pt96n17ki1cm5dg_20120316T190000Z';
    	evt.htmlLink = 'https://www.google.com/calendar/event?eid=MDdiajMydDljdjZwdDk2bjE3a2kxY201ZGdfMjAxMjAzMTZUMTkwMDAwWiB0aW5vLm1hdHRoZW91QGFzdHJ1bXNvbGFyLmNvbQ';
		evt.created = Datetime.newInstanceGmt(2012,3,12,2,9,20);
		evt.updated = Datetime.newInstanceGmt(2012,3,16,20,22,43);
		evt.summary = 'Astrum PM Task Force';
		evt.location = 'gotomeeting';
		evt.creator = new GoogleCalendarV3.CalendarUser();
		evt.creator.email = 'ben@astrumsolar.com';
		evt.creator.displayName = 'Ben Davis';
		evt.organizer = new GoogleCalendarV3.CalendarUser();
		evt.organizer.email = 'ben@astrumsolar.com';
		evt.organizer.displayName = 'Ben Davis';
		
		evt.start = new GoogleCalendarV3.CalendarDate();
		evt.start.gDatetime = Datetime.newInstance(2012,3,16,15,0,0);
		evt.gEnd = new GoogleCalendarV3.CalendarDate();
		evt.gEnd.gDatetime = Datetime.newInstance(2012,3,16,16,0,0);
		evt.recurringEventId = '07bj32t9cv6pt96n17ki1cm5dg';
		evt.originalStartTime = new GoogleCalendarV3.CalendarDate();
		evt.originalStartTime.gDateTime = Datetime.newInstance(2012,3,16,15,0,0);
		evt.iCalUID = '07bj32t9cv6pt96n17ki1cm5dg@google.com';
		evt.sequence = 0;

		evt.guestsCanInviteOthers = true;
		evt.guestsCanSeeOtherGuests = true;
		
		//exercising the code
		String created = evt.createdFormatted;
		String updated = evt.updatedFormatted;
		String start = evt.startFormatted;
		String gEnd = evt.endFormatted;
		String origStart = evt.origFormatted;
		String evtJSON = evt.getAsString();
    	
    	JSONGenerator generator = JSON.createGenerator(false);
    	evt.serialize(generator);
    	String result = generator.getAsString();
    	
		System.assert(result.startsWith('{'));
		System.assert(result.endsWith('}'));
		System.assert(result.contains('"kind":"calendar#event"'));
		System.assert(result.contains('"etag":"\\"NvHxTTtMBgLPgyiAM57hud7kBKk/Q0xqa3RPbmhKaEVBQUFBQUFBQUFBQT09\\""'));
		System.assert(result.contains('"id":"07bj32t9cv6pt96n17ki1cm5dg_20120316T190000Z"'));
		System.assert(result.contains('"htmlLink":"https://www.google.com/calendar/event?eid=MDdiajMydDljdjZwdDk2bjE3a2kxY201ZGdfMjAxMjAzMTZUMTkwMDAwWiB0aW5vLm1hdHRoZW91QGFzdHJ1bXNvbGFyLmNvbQ"'));
		System.assert(result.contains('"created":"2012-03-12T02:09:20.000Z"'));
		System.assert(result.contains('"updated":"2012-03-16T20:22:43.000Z"'));
		
    }
    
    static testMethod void privateData_deserialize_projectIdAndDateField() {
    	JSONParser parser = JSON.createParser(SERIALIZED_EXTENDED_PROPERTIES);
    	GoogleCalendarV3.ExtendedProperties properties = new GoogleCalendarV3.ExtendedProperties().deserialize(parser);
    	System.assertEquals('XYZABC123', properties.gPrivate.projectId); 
    	System.assertEquals('Kickoff__c', properties.gPrivate.projectDateField); 
    }

    static testMethod void privateData_serialize_projectIdAndDateField() {
    	GoogleCalendarV3.ExtendedProperties extended = new GoogleCalendarV3.ExtendedProperties();
    	extended.gPrivate = new GoogleCalendarV3.PrivateData();
    	extended.gPrivate.orgId = 'ABC123';
    	extended.gPrivate.projectId = 'DEF456';
    	extended.gPrivate.projectDateField = 'Install__c';
    	JSONGenerator generator = JSON.createGenerator(false);
    	extended.serialize(generator);
    	String result = generator.getAsString();
    	System.assert(result.startsWith('{"private":{'));
    	System.assert(result.endsWith('}}'));
    	System.assert(result.contains('"orgId":"ABC123"'));
    	System.assert(result.contains('"projectId":"DEF456"'));
    	System.assert(result.contains('"projectDateField":"Install__c"'));
    }
    
    static testMethod void calendarDate_deserialize_date() {
    	JSONParser parser = JSON.createParser('{"date":"2012-03-16","timeZone":"America/New_York"}');
    	GoogleCalendarV3.CalendarDate cd = new GoogleCalendarV3.CalendarDate();
    	cd.deserialize(parser);
    	System.assertEquals(Date.newInstance(2012,3,16), cd.gDate); 
    	System.assertEquals('America/New_York', cd.timeZone);
    	System.assertEquals('03/16/2012', cd.format('MM/dd/yyyy')); 
    }

    static testMethod void calendarDate_serialize_date() {
    	GoogleCalendarV3.CalendarDate cd = new GoogleCalendarV3.CalendarDate();
    	cd.gDate = Date.newInstance(2012,3,16);
    	cd.timeZone = 'America/New_York';
    	JSONGenerator generator = JSON.createGenerator(false);
    	cd.serialize(generator);
    	String result = generator.getAsString();
    	System.assert(result.startsWith('{'));
    	System.assert(result.endsWith('}'));
    	System.assert(result.contains('"date":"2012-03-16"'));
    	System.assert(result.contains('"timeZone":"America/New_York"'));
    }

    static testMethod void calendarDate_deserialize_dateTime() {
    	JSONParser parser = JSON.createParser('{"dateTime":"2012-03-16T12:30:00.000Z"}');
    	GoogleCalendarV3.CalendarDate cd = new GoogleCalendarV3.CalendarDate();
    	cd.deserialize(parser);
    	System.assertEquals(Datetime.newInstanceGmt(2012,3,16,12,30,0), cd.gDateTime);
    }

    static testMethod void calendarDate_serialize_dateTime() {
    	GoogleCalendarV3.CalendarDate cd = new GoogleCalendarV3.CalendarDate();
    	cd.gDateTime = Datetime.newInstanceGmt(2012,3,16,12,30,0);
    	JSONGenerator generator = JSON.createGenerator(false);
    	cd.serialize(generator);
    	String result = generator.getAsString();
    	System.assertEquals('{"dateTime":"2012-03-16T12:30:00.000Z"}', result);
    }
    
    static testMethod void testJSON() {
    	String privateData = '{"private": {"projectId": "XYZABC123","projectDateField": "Kickoff__c"}}';
    	JSONParser parser = JSON.createParser(privateData);
    	System.assert(parser.nextToken() == JSONToken.START_OBJECT);
    	System.assert(parser.nextToken() == JSONToken.FIELD_NAME);
    	System.assert(parser.nextToken() == JSONToken.START_OBJECT);
    	GoogleCalendarV3.PrivateData o = (GoogleCalendarV3.PrivateData)parser.readValueAs(GoogleCalendarV3.PrivateData.class);
    	System.assertEquals('XYZABC123', o.projectId);
    	System.assertEquals('Kickoff__c', o.projectDateField);
    }
    
    static testMethod void noEvents_testGetEvents_noResults() {
    	GoogleOAuth2Helper oauth = new GoogleOAuth2Helper(null, null, null);
    	GoogleCalendarV3 gCal = new GoogleCalendarV3(null, oauth);
		//GoogleCalendarV3.CalendarEvents events = gCal.getEvents();
    }
    
    static testMethod void error_parse_messageParsed() {
    	String jsonError = '{ "error": { "errors": [ { "domain": "global", "reason": "authError",' 
			+ '"message": "Invalid Credentials", "locationType": "header", "location": "Authorization" } ], "code": 401, "message": "Invalid Credentials" } } ';
    	String result = GoogleCalendarV3.parseError(jsonError);
    	System.assertEquals('Invalid Credentials', result);
    }
    
    static String SERIALIZED_EXTENDED_PROPERTIES = 
       	'{"shared": {"Glook.ResponseRequested": "1","Glook.StartDisplayTimeZone": "America/New_York","GLook.EndDisplayTimeZone": "America/New_York"},'
       	+ '"private": {"projectId": "XYZABC123","projectDateField": "Kickoff__c"}}';
    
    static String SERIALIZED_RESPONSE = '{'
 		+ '"kind": "calendar#events",'
 		+ '"etag": "\\"NvHxTTtMBgLPgyiAM57hud7kBKk/PrxnUm5FM6u0W_BBUjmM_P16e60\\"",'
 		+ '"summary": "tino.mattheou@astrumsolar.com",'
 		+ '"updated": "2012-05-08T20:57:57.000Z",'
 		+ '"timeZone": "America/New_York",'
 		+ '"accessRole": "owner",'
 		+ '"defaultReminders": [{"method":"email","minutes":10}, {"method": "popup","minutes": 10}],'
 		+ '"items": ['

  		+ '{"kind": "calendar#event",'
		+ '"etag": "\\"NvHxTTtMBgLPgyiAM57hud7kBKk/Q0xqa3RPbmhKaEVBQUFBQUFBQUFBQT09\\"",'
		+ '"id": "07bj32t9cv6pt96n17ki1cm5dg_20120316T190000Z",'
   		+ '"status": "confirmed",'
   		+ '"htmlLink": "https://www.google.com/calendar/event?eid=MDdiajMydDljdjZwdDk2bjE3a2kxY201ZGdfMjAxMjAzMTZUMTkwMDAwWiB0aW5vLm1hdHRoZW91QGFzdHJ1bXNvbGFyLmNvbQ",'
   		+ '"created": "2012-03-12T02:09:20.000Z",'
   		+ '"updated": "2012-03-16T20:22:43.000Z",'
   		+ '"summary": "Astrum PM Task Force",'
   		+ '"description": "Hey All,\\n\\nI have set up a gotomeeting for our weekly task force.  Please see the attached meeting agenda, and use the below info to login for the screen share '
   		+ 'and conference bridge this afternoon and disregard the call in info in the original calendar invite.\\n\\nCheers,\\n\\nSteve\\n\\n1.  Please join my meeting, Friday, March 16, 2012 at 3:00 PM Eastern Daylight Time.\\n'
   		+ 'https://www4.gotomeeting.com/join/465089567\\n\\n2.  Use your microphone and speakers (VoIP) - a headset is recommended.  Or, call in using your telephone.\\n\\nDial +1 (646) 982-0000\\n'
   		+ 'Access Code: 465-089-567\\nAudio PIN: Shown after joining the meeting\\n\\nMeeting ID: 465-089-567\\n\\nGoToMeeting\\nOnline Meetings Made Easy\\n",'
   		+ '"location": "gotomeeting",'
   		+ '"creator": {"email": "ben@astrumsolar.com", "displayName": "Ben Davis"},'
   		+ '"organizer": {"email": "ben@astrumsolar.com","displayName": "Ben Davis"},'
		+ '"start": { "dateTime": "2012-03-16T15:00:00-04:00" },'
		+ '"end": { "dateTime": "2012-03-16T16:00:00-04:00" },'
		+ '"recurringEventId": "07bj32t9cv6pt96n17ki1cm5dg",'
		+ '"originalStartTime": {"dateTime": "2012-03-16T15:00:00-04:00"},'
		+ '"iCalUID": "07bj32t9cv6pt96n17ki1cm5dg@google.com",'
		+ '"sequence": 0,'
		+ '"attendees": [{"email": "ben@astrumsolar.com", "displayName": "Ben Davis", "organizer": true,"responseStatus": "accepted"},'
    	+ '{"email": "noah@astrumsolar.com","displayName": "Noah Jacobs","responseStatus": "needsAction"},'
    	+ '{"email": "eric.corsi@astrumsolar.com","displayName": "Eric Corsi","responseStatus": "needsAction"},'
    	+ '{"email": "tino.mattheou@astrumsolar.com","displayName": "Constantine Mattheou","self": true,"responseStatus": "accepted"},'
    	+ '{"email": "joe.rice@astrumsolar.com","displayName": "Joe Rice","responseStatus": "accepted"},'
    	+ '{"email": "steve.lukovics@astrumsolar.com","displayName":"Steve Lukovics","responseStatus":"accepted"},'
    	+ '{"email": "chris.benonis@astrumsolar.com","displayName":"Chris Benonis","responseStatus":"accepted"},'
    	+ '{"email": "john.teti@astrumsolar.com","displayName": "John Teti","responseStatus": "accepted"},'
    	+ '{"email": "stephen.simons@astrumsolar.com","displayName": "Stephen Simons","responseStatus": "accepted"}],'
       	+ '"guestsCanInviteOthers": true,'
       	+ '"guestsCanSeeOtherGuests": true,'
       	+ '"reminders": {"useDefault": true}},'
       	  
       	+ '{"kind": "calendar#event",'
       	+ '"etag": "\\"NvHxTTtMBgLPgyiAM57hud7kBKk/Q1BDSG5NRHhKaEVCQUFBQUFBQUFBQT09\\"",'
       	+ '"id": "ffuukkc4vfm6pt1pt50ng4p1p4",'
       	+ '"status": "confirmed",'
       	+ '"htmlLink": "https://www.google.com/calendar/event?eid=ZmZ1dWtrYzR2Zm02cHQxcHQ1MG5nNHAxcDRfMjAxMjAzMDVUMTQzMDAwWiB0aW5vLm1hdHRoZW91QGFzdHJ1bXNvbGFyLmNvbQ",'
       	+ '"created": "2012-03-05T14:28:50.000Z",'
       	+ '"updated": "2012-05-04T13:25:42.000Z",'
       	+ '"summary": "Morning Stand Up",'
       	+ '"description": "Skype for now.",'
       	+ '"location": "Video Chat",'
       	+ '"creator": {"email": "stephen.simons@astrumsolar.com","displayName": "Stephen Simons"},'
       	+ '"organizer": {"email": "stephen.simons@astrumsolar.com","displayName": "Stephen Simons"},'
       	+ '"start": {"dateTime": "2012-03-05T09:30:00-05:00","timeZone": "America/New_York"},'
       	+ '"end": {"dateTime": "2012-03-05T10:00:00-05:00","timeZone": "America/New_York"},'
       	+ '"recurrence": ["RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,TU,WE,TH,FR"],'
       	+ '"iCalUID": "ffuukkc4vfm6pt1pt50ng4p1p4@google.com",'
       	+ '"sequence": 1,'
       	+ '"attendees": [{"email": "tino.mattheou@astrumsolar.com","displayName": "Constantine Mattheou","self": true,"responseStatus": "accepted"},'
       	+ '{"email": "stephen.simons@astrumsolar.com","displayName": "Stephen Simons","organizer": true,"responseStatus": "accepted"}],'
       	+ '"extendedProperties": {'
       	+ '"shared": {"Glook.ResponseRequested": "1","Glook.StartDisplayTimeZone": "America/New_York","GLook.EndDisplayTimeZone": "America/New_York"}'
       	+ '},'
       	+ '"guestsCanInviteOthers": true,'
       	+ '"guestsCanSeeOtherGuests": true,'
       	+ '"reminders": {"useDefault": false}}'

    
    	+ ']}';
}