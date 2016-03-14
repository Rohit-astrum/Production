/* FILE: VoicemailPlayerTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: October 24, 2012
 * PURPOSE: Test class for VoicemailPlayer page and VoicemailPlayerExtension
 * MODIFICATION HISTORY
 *
 */ 

@isTest
public with sharing class VoicemailPlayerTest {

	static testMethod void caseWithVoicemail_load_1Found() {
		
		Case c = new Case();
		insert c;
		
		EmailMessage email = new EmailMessage(
			ParentId = c.Id
		);
		insert email;
		
		Blob audio = Blob.valueOf('audio data');
		Attachment att = new Attachment(
			Name = 'voicemail.wav',
			ParentId = email.Id,
			Body = audio,
			ContentType = 'audio/wav'
		); 
		insert att;
		
		Test.startTest();
		
		Test.setCurrentPage(Page.VoicemailPlayer);
		ApexPages.StandardController controller = new ApexPages.StandardController(c);
		VoicemailPlayerExtension extension = new VoicemailPlayerExtension(controller);
		
		List<Attachment> atts = extension.getEmailAudioFiles(); 
		
		Test.stopTest();
		
		System.assertEquals(1, atts.size());
		System.assertEquals(att.Id, atts[0].Id);
		System.assertEquals(att.ContentType, atts[0].ContentType);
		
	}

}