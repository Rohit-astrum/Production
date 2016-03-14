public class VoicemailPlayerExtension {

	Case c;

	public VoicemailPlayerExtension(ApexPages.StandardController controller) {
		c = (Case)controller.getRecord();
	}
	
	public List<Attachment> getEmailAudioFiles() {
		
		List<Attachment> result = new List<Attachment>();
		
		List<EmailMessage> emails = 
			[SELECT Id,
				(SELECT Id, ContentType
				FROM Attachments
				WHERE ContentType LIKE 'audio/%')
			FROM EmailMessage
			WHERE ParentId = :c.Id];
			
		for (EmailMessage email : emails) {
			for (Attachment att : email.Attachments) {
				result.add(att);
			}
		}
		
		return result;
	} 

}