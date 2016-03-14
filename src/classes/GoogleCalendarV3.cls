/* FILE: GoogleCalendarV3.cls
 * AUTHOR: Tino Mattheou
 * DATE: May 10, 2012
 * PURPOSE: Implements callouts to Google V3 Calendar API  
 * MODIFICATION HISTORY
 *
 */ 
 
public class GoogleCalendarV3 {

	public static final String UTF8 = 'UTF-8';
	public static final Integer GOOGLE_TIMEOUT = 30000; //30 seconds
	public static final Time ZERO = Time.newInstance(0,0,0,0);
	public static final String DATETIME_FORMAT = 'M/d/yyyy h:mma'; 

	private GoogleOAuth2Helper oauth;
	private String calendarId;
	
	//calendarId is the email address
	public GoogleCalendarV3(String calendarId, GoogleOAuth2Helper oauth) {
		this.calendarId = calendarId;
		this.oauth = oauth;
	}
	
	// ********** API METHODS ********** //
	
	public CalendarEvents getEvents() {
		return getEvents(null);
	}

	public CalendarEvents getEvents(Datetime since) {
		
		if (Test.isRunningTest()) {
			CalendarEvents result = new CalendarEvents();
			result.items = new List<CalendarEvent>();
			return result;
		}
		
		oauth.ensureAccessToken();
		
		String sinceString = '';
		if (since != null) {
			Jsongenerator gen = JSON.createGenerator(false);
			gen.writeDateTime(since);
			sinceString = '&timeMin=' + gen.getAsString().replace('"','');
		}
		
		HttpRequest req = new HttpRequest();
		req.setMethod('GET');
		String url = String.format('https://www.googleapis.com/calendar/v3/calendars/{0}/events?maxAttendees=1{1}', 
			new String[] { EncodingUtil.urlEncode(calendarId, UTF8), sinceString });
		req.setEndpoint(url);   
		req.setHeader('Accept-Encoding','compress, gzip');
		req.setHeader('Authorization', 'Bearer ' + oauth.accessToken);
		req.setTimeout(GOOGLE_TIMEOUT);
		
		Http http = new Http();
		HttpResponse response = http.send(req);

		String responseText = response.getBody();
		
		if (response.getStatusCode() != 200) {
			throw new GoogleCalendarV3Exception(parseError(responseText));
		}		
		
		JSONParser parser = JSON.createParser(responseText);
		return new CalendarEvents().deserialize(parser);
	}

	//get 1 event
	public CalendarEvent getEvent(String eventId) {
		
		CalendarEvent result;
		
		oauth.ensureAccessToken();
		
		HttpRequest req = new HttpRequest();
		req.setMethod('GET');
		String url = String.format('https://www.googleapis.com/calendar/v3/calendars/{0}/events/{1}?maxAttendees=1', 
			new String[] { 
				EncodingUtil.urlEncode(calendarId, UTF8), 
				EncodingUtil.urlEncode(eventId, UTF8)
			});
		req.setEndpoint(url);   
		req.setHeader('Accept-Encoding','compress, gzip');
		req.setHeader('Authorization', 'Bearer ' + oauth.accessToken);
		req.setHeader('Content-Type', 'application/json');
		req.setTimeout(GOOGLE_TIMEOUT);
		
		Http http = new Http();
		HttpResponse response = http.send(req);

		String responseText = response.getBody();
		
		if (response.getStatusCode() != 200) {
			throw new GoogleCalendarV3Exception(parseError(responseText));
		}		
		
		JSONParser parser = JSON.createParser(responseText);
		
		System.assert(parser.nextToken() == JSONToken.START_OBJECT);

		//returns the new event
		return new CalendarEvent().deserialize(parser); 
	}
	
	//REFERENCE: https://developers.google.com/google-apps/calendar/v3/reference/events/insert
	public CalendarEvent insertEvent(CalendarEvent evt) {
		
		if (Test.isRunningTest()) {
			return evt;
		}
		
		CalendarEvent result;
		
		oauth.ensureAccessToken();
		
		JSONGenerator generator = JSON.createGenerator(true);
		evt.serialize(generator);
		
		HttpRequest req = new HttpRequest();
		req.setMethod('POST');
		String url = String.format('https://www.googleapis.com/calendar/v3/calendars/{0}/events', new String[] { EncodingUtil.urlEncode(calendarId, UTF8) });
		req.setEndpoint(url);   
		req.setHeader('Accept-Encoding','compress, gzip');
		req.setHeader('Authorization', 'Bearer ' + oauth.accessToken);
		req.setHeader('Content-Type', 'application/json');
		req.setBody(generator.getAsString());
		req.setTimeout(GOOGLE_TIMEOUT);
		
		Http http = new Http();
		HttpResponse response = http.send(req);

		String responseText = response.getBody();
		
		if (response.getStatusCode() != 200) {
			throw new GoogleCalendarV3Exception(parseError(responseText));
		}		
		
		JSONParser parser = JSON.createParser(responseText);
		
		System.assert(parser.nextToken() == JSONToken.START_OBJECT);

		//returns the new event
		return new CalendarEvent().deserialize(parser); 
	}
	
	//deletes based on google calendar event id
	public void deleteEvent(String eventId) {
		
		oauth.ensureAccessToken();
		
		HttpRequest req = new HttpRequest();
		req.setMethod('DELETE');
		String url = String.format('https://www.googleapis.com/calendar/v3/calendars/{0}/events/{1}', 
			new String[] { 
				EncodingUtil.urlEncode(calendarId, UTF8), 
				EncodingUtil.urlEncode(eventId, UTF8)
			});
		req.setEndpoint(url);   
		req.setHeader('Accept-Encoding','compress, gzip');
		req.setHeader('Authorization', 'Bearer ' + oauth.accessToken);
		req.setHeader('Content-Type', 'application/json');
		req.setTimeout(GOOGLE_TIMEOUT);
		
		Http http = new Http();
		HttpResponse response = http.send(req);

		String responseText = response.getBody();
		
		if (response.getStatusCode() != 204) { //204 = NO CONTENT
			throw new GoogleCalendarV3Exception(parseError(responseText));
		}		
		
	}
	
	//REFERENCE: https://developers.google.com/google-apps/calendar/v3/reference/events/update
	public CalendarEvent updateEvent(CalendarEvent evt) {
		
		CalendarEvent result;
		
		oauth.ensureAccessToken();
		
		JSONGenerator generator = JSON.createGenerator(true);
		evt.serialize(generator);
		
		HttpRequest req = new HttpRequest();
		req.setMethod('PUT');
		String url = String.format('https://www.googleapis.com/calendar/v3/calendars/{0}/events/{1}', 
			new String[] { 
				EncodingUtil.urlEncode(calendarId, UTF8), 
				EncodingUtil.urlEncode(evt.id, UTF8)
			});
		req.setEndpoint(url);   
		req.setHeader('Accept-Encoding','compress, gzip');
		req.setHeader('Authorization', 'Bearer ' + oauth.accessToken);
		req.setHeader('Content-Type', 'application/json');
		req.setBody(generator.getAsString());
		req.setTimeout(GOOGLE_TIMEOUT);
		
		Http http = new Http();
		HttpResponse response = http.send(req);

		String responseText = response.getBody();
		
		if (response.getStatusCode() != 200) {
			throw new GoogleCalendarV3Exception(parseError(responseText));
		}		
		
		JSONParser parser = JSON.createParser(responseText);
		
		System.assert(parser.nextToken() == JSONToken.START_OBJECT);

		//returns updated event
		return new CalendarEvent().deserialize(parser); 
	}
	
	// ********** DATA OBJECTS ********** //

	public class CalendarEvents {
		public String kind { get; set; }
		public String etag { get; set; }
		public String summary { get; set; }
		public DateTime updated { get; set; }
		public String timeZone { get; set; }
		public String accessRole { get; set; }
		public List<Reminder> defaultReminders { get; set; }
		public List<CalendarEvent> items { get; set; } 
		public void serialize(System.JSONGenerator generator) {
			generator.writeStartObject();
			if (kind != null) { generator.writeStringField('kind', kind); }
			if (etag != null) { generator.writeStringField('etag', etag); }
			if (summary != null) { generator.writeStringField('summary', summary); }
			if (updated != null) { generator.writeDateTimeField('updated', updated); }
			if (timeZone != null) { generator.writeStringField('timeZone', timeZone); }
			if (accessRole != null) { generator.writeStringField('accessRole', accessRole); }
			if (defaultReminders != null) { generator.writeObjectField('defaultReminders', defaultReminders); }
			if (items != null) {
				generator.writeFieldName('items');
				generator.writeStartArray();
				for (CalendarEvent item : items) {
					item.serialize(generator);
				}
				generator.writeEndArray();
			}
			generator.writeEndObject();
		}
		public CalendarEvents deserialize(JSONParser parser) {
			Integer nesting = 0;
			while (parser.nextToken() != null) {
				if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
					nesting++;
				} else if (parser.getCurrentToken() == JSONToken.END_OBJECT) {
					nesting--;
					if (nesting == 0) {
						break;
					}
				}
				if (nesting == 1) {
					if (parser.getCurrentToken() == JSONToken.VALUE_STRING) {
						if (parser.getCurrentName() == 'kind') {
							kind = parser.getText();
						} else if (parser.getCurrentName() == 'etag') {
							etag = parser.getText();
						} else if (parser.getCurrentName() == 'summary') {
							summary = parser.getText();
						} else if (parser.getCurrentName() == 'updated') {
							updated = parser.getDatetimeValue();
						} else if (parser.getCurrentName() == 'timeZone') {
							timeZone = parser.getText();
						} else if (parser.getCurrentName() == 'accessRole') {
							accessRole = parser.getText();
						}
					} else if (defaultReminders == null && parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'defaultReminders') {
						System.assert(parser.nextToken() == JSONToken.START_ARRAY);
						defaultReminders = (List<Reminder>)parser.readValueAs(List<Reminder>.class);
					} else if (items == null && parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'items') {
						deserializeItems(parser);
					}
				}
			}
			return this;
		}
		private void deserializeItems(JSONParser parser) {
			items = new List<CalendarEvent>();
			Integer nesting = 0;
			while(parser.nextToken() != null) {
				if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
					nesting++;
				}
				if (parser.getCurrentToken() == JSONToken.END_ARRAY) {
					nesting--;
					if (nesting == 0) {
						break;
					}
				}
				if (parser.getCurrentToken() == JSONToken.START_OBJECT && nesting == 1) {
					items.add(new CalendarEvent().deserialize(parser));
				}
			}
		}
		public String getAsString() {
			JSONGenerator generator = JSON.createGenerator(true);
			serialize(generator);
			return generator.getAsString();
		}
	} /* CalendarEvents */

	//single calendar event	
	public class CalendarEvent {
		public String kind { get; set; }
		public String id { get; set; }
		public String etag { get; set; }
		public String status { get; set; }
		public String htmlLink { get; set; }
		public DateTime created { get; set; }
		public String createdFormatted { get { 
			if (created != null) { return created.format(DATETIME_FORMAT); } return null;
		}}
		public DateTime updated { get; set; }
		public String updatedFormatted { get { 
			if (updated != null) { return updated.format(DATETIME_FORMAT); } return null;
		}}
		public String summary { get; set; } //title
		public String description { get; set; }
		public String location { get; set; }
		public String colorId { get; set; }
		public CalendarUser creator { get; set; }
		public CalendarUser organizer { get; set; }
		public CalendarDate start { get; set; }
		public String startFormatted { get { 
			if (start != null) { return start.format(DATETIME_FORMAT); } return null;
		}}
		public CalendarDate gEnd { get; set; }
		public String endFormatted { get { 
			if (gEnd != null) { return gEnd.format(DATETIME_FORMAT); } return null;
		}}
		public String recurringEventId { get; set; }		
		public CalendarDate originalStartTime { get; set; }
		public String origFormatted { get { 
			if (originalStartTime != null) { return originalStartTime.format(DATETIME_FORMAT); } return null;
		}}
		public String transparency { get; set; }
		public String visibility { get; set; }
		public String iCalUID { get; set; }
		public Integer sequence { get; set; }
		public List<CalendarUser> attendees { get; set; }
		public Boolean attendeesOmitted { get; set; }
		public ExtendedProperties extendedProperties { get; set; }
		public Boolean anyoneCanAddSelf { get; set; }
		public Boolean guestsCanInviteOthers { get; set; }
		public Boolean guestsCanModify { get; set; }
		public Boolean guestsCanSeeOtherGuests { get; set; }
		public Boolean privateCopy { get; set; }
		public Reminders reminders { get; set; }
		public void serialize(System.JSONGenerator generator) {
			generator.writeStartObject();
			if (kind != null) { generator.writeStringField('kind', kind); }
			if (id != null) { generator.writeStringField('id', id); }
			if (etag != null) { generator.writeStringField('etag', etag); }
			if (status != null) { generator.writeStringField('status', status); }
			if (htmlLink != null) { generator.writeStringField('htmlLink', htmlLink); }
			if (created != null) { generator.writeDateTimeField('created', created); }
			if (updated != null) { generator.writeDateTimeField('updated', updated); }
			if (summary != null) { generator.writeStringField('summary', summary); }
			if (description != null) { generator.writeStringField('description', description); }
			if (location != null) { generator.writeStringField('location', location); }
			if (colorId != null) { generator.writeStringField('colorId', colorId); }
			if (creator != null) { generator.writeObjectField('creator', creator); }
			if (organizer != null) { generator.writeObjectField('organizer', organizer); }
			if (start != null) {
				generator.writeFieldName('start');
				start.serialize(generator);
			}
			if (gEnd != null) {
				generator.writeFieldName('end');
				gEnd.serialize(generator);
			}
			if (recurringEventId != null) { generator.writeStringField('recurringEventId', recurringEventId); }
			if (originalStartTime != null) {
				generator.writeFieldName('originalStartTime');
				originalStartTime.serialize(generator);
			}
			if (transparency != null) { generator.writeStringField('transparency', transparency); }
			if (visibility != null) { generator.writeStringField('visibility', visibility); }
			if (iCalUID != null) { generator.writeStringField('iCalUID', iCalUID); }
			if (sequence != null) { generator.writeNumberField('sequence', sequence); }
			if (extendedProperties != null) {
				generator.writeFieldName('extendedProperties');
				extendedProperties.serialize(generator);
			}
			if (attendees != null) { generator.writeObjectField('attendees', attendees); }
			if (attendeesOmitted != null) { generator.writeBooleanField('attendeesOmitted', attendeesOmitted); }
			generator.writeEndObject();
		}
		public CalendarEvent deserialize(JSONParser parser) {
			Integer nesting = 1; //start object already found
			while (parser.nextToken() != null) {
				if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
					nesting++;
				} else if (parser.getCurrentToken() == JSONToken.END_OBJECT) {
					nesting--;
					if (nesting == 0) {
						break;
					}
				}
				if (nesting == 1) {
					if (parser.getCurrentToken() == JSONToken.VALUE_STRING) {
						if (parser.getCurrentName() == 'kind') {
							kind = parser.getText();
						} else if (parser.getCurrentName() == 'etag') {
							etag = parser.getText();
						} else if (parser.getCurrentName() == 'id') {
							id = parser.getText();
						} else if (parser.getCurrentName() == 'status') {
							status = parser.getText();
						} else if (parser.getCurrentName() == 'htmlLink') {
							htmlLink = parser.getText();
						} else if (parser.getCurrentName() == 'created') {
							created = parser.getDatetimeValue();
						} else if (parser.getCurrentName() == 'updated') {
							updated = parser.getDatetimeValue();
						} else if (parser.getCurrentName() == 'summary') {
							summary = parser.getText();
						} else if (parser.getCurrentName() == 'description') {
							description = parser.getText();
						} else if (parser.getCurrentName() == 'location') {
							location = parser.getText();
						} else if (parser.getCurrentName() == 'colorId') {
							colorId = parser.getText();
						} else if (parser.getCurrentName() == 'recurringEventId') {
							recurringEventId = parser.getText();
						} else if (parser.getCurrentName() == 'transparency') {
							transparency = parser.getText();
						} else if (parser.getCurrentName() == 'visibility') {
							visibility = parser.getText();
						} else if (parser.getCurrentName() == 'iCalUID') {
							iCalUID = parser.getText();
						}
					} else if (parser.getCurrentToken() == JSONToken.VALUE_NUMBER_INT) {
						if (parser.getCurrentName() == 'sequence') {
							sequence = parser.getIntegerValue();
						}
					} else if (parser.getCurrentToken() == JSONToken.VALUE_FALSE || parser.getCurrentToken() == JSONToken.VALUE_TRUE) {
						if (parser.getCurrentName() == 'attendeesOmitted') {
							attendeesOmitted = parser.getBooleanValue();
						} else if (parser.getCurrentName() == 'anyoneCanAddSelf') {
							anyoneCanAddSelf = parser.getBooleanValue();
						} else if (parser.getCurrentName() == 'guestsCanInviteOthers') {
							guestsCanInviteOthers = parser.getBooleanValue();
						} else if (parser.getCurrentName() == 'guestsCanModify') {
							guestsCanModify = parser.getBooleanValue();
						} else if (parser.getCurrentName() == 'guestsCanSeeOtherGuests') {
							guestsCanSeeOtherGuests = parser.getBooleanValue();
						} else if (parser.getCurrentName() == 'privateCopy') {
							privateCopy = parser.getBooleanValue();
						}
					} else if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
						if (parser.getCurrentName() == 'creator') {
							System.assert(parser.nextToken() == JSONToken.START_OBJECT);
							creator = (CalendarUser)parser.readValueAs(CalendarUser.class);
						} else if (parser.getCurrentName() == 'organizer') {
							System.assert(parser.nextToken() == JSONToken.START_OBJECT);
							organizer = (CalendarUser)parser.readValueAs(CalendarUser.class);
						} else if (parser.getCurrentName() == 'start') {
							start = new CalendarDate().deserialize(parser);
						} else if (parser.getCurrentName() == 'end') {
							gEnd = new CalendarDate().deserialize(parser);
						} else if (parser.getCurrentName() == 'originalStartTime') {
							originalStartTime = new CalendarDate().deserialize(parser);
						} else if (parser.getCurrentName() == 'extendedProperties') {
							extendedProperties = new ExtendedProperties().deserialize(parser);
						} else if (parser.getCurrentName() == 'reminders') {
							System.assert(parser.nextToken() == JSONToken.START_OBJECT);
							reminders = (Reminders)parser.readValueAs(GoogleCalendarV3.Reminders.class);
						} else if (parser.getCurrentName() == 'attendees') {
							System.assert(parser.nextToken() == JSONToken.START_ARRAY);
							attendees = (List<CalendarUser>)parser.readValueAs(List<CalendarUser>.class);
						} else if (parser.getCurrentName() == 'recurrence') {
							if (parser.nextToken() == null) {
								break;
							}
							parser.skipChildren();
						}
					}
				}
			}
			return this;
		}
		public String getAsString() {
			JSONGenerator generator = JSON.createGenerator(true);
			serialize(generator);
			return generator.getAsString();
		}
	} /* CalendarEvent */
	
	public class CalendarUser {
		public String email { get; set; }
		public String displayName { get; set; }
		public Boolean organizer { get; set; }
		public Boolean self { get; set; }
		public Boolean resource { get; set; }
		public Boolean optional { get; set; }
		public String responseStatus { get; set; }
		public String comment { get; set; }
		public Integer additionalGuests { get; set; }
	}
	
	//custom serialization because date and dateTime are reserved words in Apex
	public class CalendarDate {
		public Date gDate { get; set; }
		public DateTime gDateTime { get; set; }
		public String timeZone { get; set; }
		public void serialize(System.JSONGenerator generator) {
			generator.writeStartObject();
			if (gDate != null) {
				generator.writeDateField('date', gDate);
			}
			if (gDateTime != null) {
				generator.writeDateTimeField('dateTime', gDateTime);
			}
			if (timeZone != null) {
				generator.writeStringField('timeZone', timeZone);
			}
			generator.writeEndObject();
		}
		public CalendarDate deserialize(JSONParser parser) {
			Integer nesting = 0;
			while (parser.nextToken() != null) {
				if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
					nesting++;
				}
				if (parser.getCurrentToken() == JSONToken.END_OBJECT) {
					nesting--;
					if (nesting == 0) {
						break;
					}
				}
				if (nesting == 1) {
					if (parser.getCurrentToken() == JSONToken.VALUE_STRING) {
						if (parser.getCurrentName() == 'date') {
							gDate = parser.getDateValue();
						} else if (parser.getCurrentName() == 'dateTime') {
							gDateTime = parser.getDatetimeValue();
						} else if (parser.getCurrentName() == 'timeZone') {
							timeZone = parser.getText();
						}
					}
				}
			}
			return this;
		}
		public String format(String formatString) {
			if (gDateTime != null) {
				return gDateTime.format(formatString);
			}
			if (gDate != null) {
				return DateTime.newInstance(gDate, ZERO).format(formatString);
			}
			return null;
		}
	}
	
	//custom serialization because private is a reserved word in Apex
	public class ExtendedProperties {
		public PrivateData gPrivate { get; set; }
		public Object shared { get; set; }
		public void serialize(System.JSONGenerator generator) {
			generator.writeStartObject();
			if (gPrivate != null) {
				generator.writeObjectField('private', gPrivate);
			}
			generator.writeEndObject();
		}
		public ExtendedProperties deserialize(JSONParser parser) {
			Integer nesting = 0;
			while (parser.nextToken() != null) {
				if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
					nesting++;
				}
				if (parser.getCurrentToken() == JSONToken.END_OBJECT) {
					nesting--;
					if (nesting == 0) {
						break;
					}
				}
				if (nesting == 1 && parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'private') {
					System.assert(parser.nextToken() == JSONToken.START_OBJECT);
					gPrivate = (PrivateData)parser.readValueAs(PrivateData.class);
				}
			}
			return this;
		}
	}
	
	public class PrivateData {
		public String orgId { get; set; }
		public String projectId { get; set; }
		public String projectDateField { get; set; }
	}
	
	public class Reminders {
		public Boolean useDefault { get; set; }
		public List<Reminder> overrides { get; set; }
	}
	
	public class Reminder {
		public String method { get; set; }
		public Integer minutes { get; set; }
	}
	
	public static String parseError(String responseText) {
		return GoogleOAuth2Helper.parseError(responseText);
	}
	
	public class GoogleCalendarV3Exception extends Exception {	}

}