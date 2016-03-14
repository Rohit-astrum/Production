/* FILE: PartnerLandingConfigTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: January 14, 2013
 * PURPOSE: Test class for PartnerLandingConfigExtension
 * MODIFICATION HISTORY:
 *
 */

@isTest
public class PartnerLandingConfigTest {

	static testMethod void createTemplate_save_newTemplate() {
		
		Partner_Page_Template__c template = new Partner_Page_Template__c (
			 Name = 'Test Template', 
			 VisualForce_Page__c = 'PartnerLandingTemplate1',
			 Active__c = true,
			 Portal__c = 'Partner Portal Site'
		);
		insert template;
		
		Account partner = new Account (
			Name = 'Test Partner'
		);
		insert partner;
        
        Contact c = new Contact (
            LastName = 'Partner2',
            AccountId = partner.Id
        );
        insert c;
		
		Partner_Landing_Page__c landingPage = new Partner_Landing_Page__c (
			Partner_Account__c = partner.Id,
			Portal_Site__c = 'Partner Portal Site (partners.astrumsolar.com)'
		);
		Test.setCurrentPage(Page.PartnerLandingConfig);
		ApexPages.StandardController controller = new ApexPages.StandardController(landingPage);
		PartnerLandingConfigExtension extension = new PartnerLandingConfigExtension(controller);
		
		Test.startTest();

		System.assertNotEquals(extension.portalUrl, '');
		
		extension.newPortalSite = 'Partner Portal Site (partners.astrumsolar.com)';
		extension.refreshTemplates();
		List<Partner_Page_Template__c> templates = extension.templates;
		System.assertEquals(1, templates.size());
		
		extension.newAccountId = partner.Id;
		List<SelectOption> contacts = extension.contacts;
		System.assertEquals(2, contacts.size());
		
		landingPage.Partner_Display_Name__c = 'Test Partner Inc';
		landingPage.Active__c = true;
		landingPage.Site_Url__c = 'some-test-link-2x9483';
		landingPage.Page_Template__c = template.Id;
		
		extension.logoFileName = 'image.jpg';
		extension.logoContentType = 'image/jpg';
		Blob imageBlob = Blob.valueOf('my image file');
		extension.logoContent = imageBlob;
		
		extension.savePage();
		
		System.assertEquals(false, ApexPages.hasMessages(), String.valueOf(ApexPages.getMessages()));
		
		Test.stopTest();

		landingPage = 
			[SELECT Id, Partner_Account__c, Portal_Site__c, Active__c,
					Site_Url__c, Page_Template__c, Partner_Display_Name__c,
					(SELECT Id FROM Attachments)
			FROM Partner_Landing_Page__c];
		
		System.assertEquals(partner.Id, landingPage.Partner_Account__c);
		System.assertEquals('Partner Portal Site (partners.astrumsolar.com)', landingPage.Portal_Site__c);
		System.assertEquals(true, landingPage.Active__c);
		System.assertEquals('some-test-link-2x9483', landingPage.Site_Url__c);
		System.assertEquals(template.Id, landingPage.Page_Template__c);
		System.assertEquals('Test Partner Inc', landingPage.Partner_Display_Name__c);

		System.assertEquals(1, landingPage.Attachments.size());
		
		Attachment att = [SELECT Id, Name, ContentType, Body FROM Attachment WHERE Id = :landingPage.Attachments[0].Id];
		System.assertEquals('image.jpg', att.Name);
		System.assertEquals('image/jpg', att.ContentType);
		System.assertEquals(imageBlob.toString(), att.Body.toString());
		
	}

}