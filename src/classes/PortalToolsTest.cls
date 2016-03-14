/* FILE: PortalToolsTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: August 3, 2012
 * PURPOSE: Test class for PortalTools page and PortalToolsController
 * MODIFICATION HISTORY
 * 01/11/2013 TCM - outreach tools are portal-specific 
 */
 
@isTest
public class PortalToolsTest {

    static testMethod void outReachTools_showPage_documentsShown() {

        Portal_Outreach_Tool__c tool1 = new Portal_Outreach_Tool__c (
            Name = 'Document 1',
            Description__c = 'Description 1',
            Active__c = true,
            Type__c = 'Flyers (PDF)',
            Partner_Type__c = 'Professional',
            Portal_Availability__c = 'Partner Portal'
        );
        insert tool1;

        Portal_Outreach_Tool__c tool2 = new Portal_Outreach_Tool__c (
            Name = 'Document 2',
            Description__c = 'Description 2',
            Active__c = true,
            Type__c = 'Web Ads (JPG)',
            Partner_Type__c = 'Professional',
            Portal_Availability__c = 'Partner Portal'
        );
        insert tool2;

        Attachment doc1 = new Attachment (
            ParentId = tool1.Id,
            Name = 'test.pdf',
            ContentType = 'application/pdf',
            Body = Blob.valueOf('DATA'),
            Description = 'Document'
        );
        insert doc1;
        Attachment doc2 = new Attachment (
            ParentId = tool2.Id,
            Name = 'test.pdf',
            ContentType = 'application/pdf',
            Body = Blob.valueOf('DATA'),
            Description = 'Document'
        );
        insert doc2;
        Attachment thumb1 = new Attachment (
            ParentId = tool1.Id,
            Name = 'test.jpg',
            Body = Blob.valueOf('DATA'),
            ContentType = 'image/jpg',
            Description = 'Thumbnail'
        );
        insert thumb1;

        Test.setCurrentPage(Page.PortalTools);
        PortalToolsController controller = new PortalToolsController();
        
        Test.startTest();

        System.runAs(createPortalUser()) {
            List<Portal_Outreach_Tool__c> docs = controller.getTools();
            System.assertEquals(1, docs.size());
            System.assertEquals(tool1.Name, docs[0].Name);
            System.assertEquals(tool1.Description__c, docs[0].Description__c);
            System.assertEquals(2, docs[0].Attachments.size());

            docs = controller.getWebTools();
            System.assertEquals(1, docs.size());
            System.assertEquals(tool2.Name, docs[0].Name);
            System.assertEquals(tool2.Description__c, docs[0].Description__c);
            System.assertEquals(1, docs[0].Attachments.size());
        }
        
        Test.stopTest();

    }
    
    /*
    static testMethod void hasDocument_showPage_documentsShown() {
        
        Folder f = 
            [SELECT Id 
            FROM Folder 
            WHERE Name = :PortalToolsController.FOLDER_NAME 
            AND Type = 'Document'];
        
        Document doc1 = new Document(
            FolderId = f.Id,
            Name = 'Document 1',
            Description = 'Description 1'
        );
        insert doc1;
        Document doc2 = new Document(
            FolderId = f.Id,
            Name = 'Document 2',
            Description = 'Description 2'
        );
        insert doc2;
        
        Test.setCurrentPage(Page.PortalTools);
        PortalToolsController controller = new PortalToolsController();
        
        Test.startTest();

        System.runAs(getSiteGuestUser()) {
            List<Document> docs = controller.getDocuments();
            System.assertEquals(2, docs.size());
            System.assert(docs[0].Name.startsWith('Document'));
            System.assert(docs[0].Description.startsWith('Description'));
        }
        
        Test.stopTest();
        
    } */
    
    public static User getSiteGuestUser() {
        
        return 
            [SELECT Id FROM User 
            WHERE Profile.Name = 'Partner Portal Site Profile' 
            AND UserType = 'Guest'];
        
    }
    
    public static User createPortalUser() {
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Partner Portal - Full User'];
        
        User accountOwner = 
            [SELECT Id FROM User 
            WHERE UserRoleId <> NULL
            AND Profile.UserType = 'Standard' 
            AND IsActive = TRUE 
            LIMIT 1];
        
        Account a = new Account (
            OwnerId = accountOwner.Id,
            Name = 'Test Partner',
            Partner_Type__c = 'Professional'
        );
        insert a;
        
        Contact c = new Contact (
            LastName = 'Partner',
            AccountId = a.Id
        );
        insert c; 
        
        User newUser = new User (
            FirstName = 'Portal',
            LastName = 'Test',
            Email = 'portal.test1234abcxyz@test.com',
            UserName = 'portal.test1234abcxyz@test.com',
            ContactId = c.Id,
            Alias = 'partner', 
            ProfileId = portalProfile.Id, 
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'UTF-8'
        );
        insert newUser;
        
        return newUser;
    }
    
    public static User createStrategicPortalUser() {
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Strategic Partner Portal - Full User'];
        
        User accountOwner = 
            [SELECT Id FROM User 
            WHERE UserRoleId <> NULL
            AND Profile.UserType = 'Standard' 
            AND IsActive = TRUE 
            LIMIT 1];
        
        Account a = new Account (
            OwnerId = accountOwner.Id,
            Name = 'Test Partner',
            Partner_Type__c = 'Strategic',
            Community_Program__c = 'Solarize Bridgeport',
            Community_Program_Start_date__c = system.today()
        );
        insert a;
        
        Contact c = new Contact (
            LastName = 'Partner',
            AccountId = a.Id
        );
        insert c; 
        
        User newUser = new User (
            FirstName = 'Portal',
            LastName = 'Test',
            Email = 'portal.test1234abcxyz@test.com',
            UserName = 'portal.test1234abcxyz@test.com',
            ContactId = c.Id,
            Alias = 'partner', 
            ProfileId = portalProfile.Id, 
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'UTF-8'
        );
        insert newUser;
        
        return newUser;
    }
    
    public static User createAffiliatePortalUser() {
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Affiliate Partner Portal - Full User'];
        
        User accountOwner = 
            [SELECT Id FROM User 
            WHERE UserRoleId <> NULL
            AND Profile.UserType = 'Standard' 
            AND IsActive = TRUE 
            LIMIT 1];
        
        Account a = new Account (
            OwnerId = accountOwner.Id,
            Name = 'Test Partner',
            Partner_Type__c = 'Affiliate'         
        );
        insert a;
        
        Contact c = new Contact (
            LastName = 'Partner',
            AccountId = a.Id
        );
        insert c; 
        
        User newUser = new User (
            FirstName = 'Portal',
            LastName = 'Test',
            Email = 'portal.test1234abcxyz@test.com',
            UserName = 'portal.test1234abcxyz@test.com',
            ContactId = c.Id,
            Alias = 'partner', 
            ProfileId = portalProfile.Id, 
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'UTF-8'
        );
        insert newUser;
        
        return newUser;
    }
    
}