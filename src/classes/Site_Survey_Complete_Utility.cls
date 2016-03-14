public class Site_Survey_Complete_Utility {

    public static void sendNotificationEmail(Event theEvent, Opportunity opp) {
    	
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

		mail.setToAddresses(new String[] {opp.Owner.Email});
		mail.setCcAddresses(new String[] {'stephen.simons@astrumsolar.com'});
											
		mail.setSubject('Site Survey Completed: ' + opp.Name);

		String plainTextContent = getPlainTextContent(theEvent, opp);
		String htmlContent = getHtmlContent(theEvent, opp);
				
		mail.setPlainTextBody(plainTextContent);
		mail.setHtmlBody(htmlContent);
			
		Messaging.sendEmail(new Messaging.Singleemailmessage[] { mail });	    	
    }

	public static String getPlainTextContent(Event theEvent, Opportunity theOpp) {
		String content = '';
		
		String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm()+'/';
		String propertyAddress = theOpp.Property__r.Name + ', ' + theOpp.Property__r.Property_City__c + ', ' + theOpp.Property__r.Property_State__c + ', ' + theOpp.Property__r.Property_ZIP__c;
		
		content += 'The Site Survey is complete.\n\n';
		content += 'Link to the Opportunity:  ' + theOpp.Name + '.  ' + baseUrl + theEvent.WhatId + '\n';
		content += 'Link to the Property: ' + propertyAddress + '.  ' + theEvent.Related_Property_Link__c + '\n';
		
		return content;
	}

	public static String getHtmlContent(Event theEvent, Opportunity theOpp) {
		String content = '';

		String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm()+'/';
		
		String propertyAddress = theOpp.Property__r.Name + ', ' + theOpp.Property__r.Property_City__c + ', ' + theOpp.Property__r.Property_State__c + ', ' + theOpp.Property__r.Property_ZIP__c;
		
		content += 'The Site Survey is complete.<br><br>';

		content += '<ul>';
		content += '<li>Opportunity: <a href="' + baseUrl + theEvent.WhatId + '">' + theOpp.name + '</a></li>';
		content += '<li>Property: <a href="' + theEvent.Related_Property_Link__c + '">' + propertyAddress + '</a></li>';
		content += '</ul>';

		return content;
	}

}