public with sharing class Opportunity_Status_Holder {

	public Opportunity theOpportunity {get; set;}

	public Integer index {get; set;}
	
	public String lastActivityDateTime {get; set;}

	public String createdDateTime {get; set;}
	
	public String propertyAddress {get; set;}

	public String siteSurveyDateTime {get; set;}
	public String salesVisitDateTime {get; set;}
	
	public Boolean siteSurveyComplete {get; set;}
	public String siteSurveyColor {get; set;}

	public Boolean salesVisitComplete {get; set;}
	public String salesVisitColor {get; set;}
		
	public Opportunity_Status_Holder(Integer theIndex, Opportunity currentOpportunity, String theLastActivityDateTime, String theCreatedDateTime, 
									String theSiteSurveyDateTime, Boolean theSiteSurveyComplete, 
									String theSalesVisitDateTime, Boolean theSalesVisitComplete) {
		index = theIndex;
		theOpportunity = currentOpportunity;
		lastActivityDateTime  = theLastActivityDateTime;
		createdDateTime = theCreatedDateTime;
		
		siteSurveyDateTime = theSiteSurveyDateTime;		
		salesVisitDateTime = theSalesVisitDateTime;
		
		propertyAddress = buildPropertyAddress(theOpportunity.Property__r.name, theOpportunity.Property__r.property_city__c, theOpportunity.Property__r.property_state__c);
		
		siteSurveyColor = getColor(theSiteSurveyDateTime, theSiteSurveyComplete);
		salesVisitColor = getColor(theSalesVisitDateTime, theSalesVisitComplete);
	}	

	private String getColor(String theDateTime, Boolean isComplete) {
		
		String theColor = null;
	
		if (theDateTime.length() <= 1) {
			theColor = Opportunity_Status_Controller_Extension.SCHEDULED_COLOR;
		}
		else {
			// strip off time zone
			Integer len = theDateTime.length() - 4;
			String timeStr = theDateTime.substring(0, len);
			
			DateTime targetDateTime = DateTime.parse(timeStr);
			DateTime now = DateTime.now();
			
			if (isComplete) {
				theColor = Opportunity_Status_Controller_Extension.COMPLETED_COLOR;				
			}
			else if (targetDateTime < now) {
				theColor = Opportunity_Status_Controller_Extension.PAST_DUE_COLOR;								
			} 
			else {
				theColor = Opportunity_Status_Controller_Extension.SCHEDULED_COLOR;								
			}
		}	
		
		return theColor;	
	}
	
	private String buildPropertyAddress(String street, String city, String state) {		
		String result = '';
		
		result += String_Utils.getDefaultStringWithComma(street);
		result += String_Utils.getDefaultStringWithComma(city);
		result += String_Utils.getDefaultString(state);
		
		if (result.trim().length() == 0) {
			result = '-';
		}
		
		return result;
	}	
	
}