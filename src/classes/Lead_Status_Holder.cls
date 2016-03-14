public with sharing class Lead_Status_Holder {

	public Lead theLead {get; set;}

	public Integer index {get; set;}
	
	public String lastActivityDateTime {get; set;}

	public String createdDateTime {get; set;}

	public String leadAddress {get; set;}
	
	public Lead_Status_Holder(Integer theIndex, Lead currentLead, String theLastActivityDateTime, String theCreatedDateTime) {
		index = theIndex;
		theLead = currentLead;
		lastActivityDateTime  = theLastActivityDateTime;
		createdDateTime = theCreatedDateTime;
		
		leadAddress = buildLeadAddress(theLead.street, theLead.city, theLead.state);
	}	
	
	private String buildLeadAddress(String street, String city, String state) {
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