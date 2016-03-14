public class EmailUtil {

	public static void AdminEmail( String displayName, String subject, String message ) {

		Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {'it@astrumsolar.com'};
		mail.setToAddresses(toAddresses);
		mail.setReplyTo('it@astrumsolar.com');
		mail.setSenderDisplayName(displayName);
		mail.setSubject('Error from Org : ' + UserInfo.getOrganizationName() + ' - ' + subject);
		mail.setPlainTextBody(message);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

	}

}