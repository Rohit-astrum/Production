/* FILE: LeadConvertAttachmentsTriggerTest.trigger
 * AUTHOR: Tino Mattheou
 * DATE: September 10, 2012
 * PURPOSE: test class for LeadConvertAttachments trigger
 * MODIFICATION HISTORY
 *
 */

@isTest(SeeAllData = true)
public class LeadConvertAttachmentsTriggerTest {

    static testMethod void leadWithAttachment_convertNewAccount_OpptyAttachment() {
        
        Lead l = new Lead (
            FirstName = 'Test',
            LastName = 'Lead',
            Site_Type__c = 'Residential', 
            Company = 'Lead, Test',
            LeadSource = 'Search Engine',
            Lead_Source_Detail__c = 'Partner' ,
            Street = '22 Swed Road',
            City = 'Wayne',
            State = 'PA',
            County__c = 'Chester',
            POstalCode = '19087'
        );
        insert l;
        
        Blob content = Blob.valueOf('test image');
        Attachment att = new Attachment(
            ParentId = l.Id, 
            Name = 'test.jpg',
            Description = 'Test description',
            ContentType = 'image/jpg',
            Body = content
        );
        insert att;
        
        Test.startTest();
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(l.Id);
        lc.setConvertedStatus('Qualified');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        Test.stopTest();
        
        System.assert(lcr.isSuccess());
        
        Attachment att2 = 
            [SELECT Id, Name, Description, ContentType, Body 
            FROM Attachment
            WHERE ParentId = :lcr.getOpportunityId()];      
        
        System.assertEquals(att.Name, att2.Name);
        System.assertEquals(att.Description, att2.Description);
        System.assertEquals(att.ContentType, att2.ContentType);
        System.assertEquals(att.Body.size(), att2.Body.size());
        
    }

    static testMethod void leadWithAttachment_convertExistingAccount_OpptyAttachment() {
        
        Account a = new Account( Name = 'Test Account');
        insert a;
        
        Lead l = new Lead (
            FirstName = 'Test',
            LastName = 'Lead',
            Site_Type__c = 'Residential', 
            Company = 'Lead, Test',
            LeadSource = 'Search Engine',
            Lead_Source_Detail__c = 'Partner' ,
            Street = '22 Swed Road',
            City = 'Wayne',
            State = 'PA',
            County__c = 'Chester',
            POstalCode = '19087'
        );
        insert l;
        
        Blob content = Blob.valueOf('test image');
        Attachment att = new Attachment(
            ParentId = l.Id, 
            Name = 'test.jpg',
            Description = 'Test description',
            ContentType = 'image/jpg',
            Body = content
        );
        insert att;
        
        Test.startTest();
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(l.Id);
        lc.setConvertedStatus('Qualified');
        lc.setAccountId(a.Id);
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        Test.stopTest();
        
        System.assert(lcr.isSuccess());
        
        Attachment att2 = 
            [SELECT Id, Name, Description, ContentType, Body 
            FROM Attachment
            WHERE ParentId = :lcr.getOpportunityId()];      
        
        System.assertEquals(att.Name, att2.Name);
        System.assertEquals(att.Description, att2.Description);
        System.assertEquals(att.ContentType, att2.ContentType);
        System.assertEquals(att.Body.size(), att2.Body.size());
        
    }


}