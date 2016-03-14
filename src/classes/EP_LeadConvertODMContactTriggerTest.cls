/* FILE: EP_LeadConvertODMContactTriggerTest
 * AUTHOR: Tino Mattheou
 * DATE: December 12, 2012
 * PURPOSE: Test EP_LeadConvertODMContact trigger
 * MODIFICATION HISTORY:
 *
 */

@isTest(SeeAllData = true) 
public class EP_LeadConvertODMContactTriggerTest {

    static testMethod void leadWithODM_convert_contactCreated() {
    
        Lead l = new Lead (
            LeadSource = 'Events',
            Lead_Source_Detail__c = 'xyz',
            FirstName = 'Test',
            LastName = 'Lead',
            Site_Type__c = 'Residential', 
            Company = 'Lead, Test',
            Street = '22 Swed Road',
            City = 'Wayne',
            State = 'PA',
            County__c = 'Chester',
            POstalCode = '19087',
            ODM_Last_Name__c = 'Odm',
            ODM_First_Name__c = 'Test',
            ODM_Salutation__c = 'Dr.',
            ODM_Email__c = 'odm@test.com',
            ODM_Phone__c = '(215) 510-2032',
            ODM_Work_Phone__c = '(610) 394-2392',
            ODM_Mobile_Phone__c = '(610) 302-3430',
            ODM_Primary_Phone__c = 'Home Phone'
        );
        insert l;
        
        Test.startTest();
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(l.Id);
        lc.setConvertedStatus('Qualified');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        Test.stopTest();
        
        System.assert(lcr.isSuccess());
        
        Contact c = 
            [SELECT Id, Salutation, LastName, FirstName, HomePhone, Email, Work_Phone__c, MobilePhone, Primary_Phone__c
            FROM Contact
            WHERE Id <> :lcr.getContactId()
            AND AccountId = :lcr.getAccountId()];      
        
        System.assertEquals(l.ODM_Salutation__c, c.Salutation);
        System.assertEquals(l.ODM_Last_Name__c, c.LastName);
        System.assertEquals(l.ODM_First_Name__c, c.FirstName);
        System.assertEquals(l.ODM_Phone__c, c.HomePhone);
        System.assertEquals(l.ODM_Email__c, c.Email);
        System.assertEquals(l.ODM_Work_Phone__c, c.Work_Phone__c);
        System.assertEquals(l.ODM_Mobile_Phone__c, c.MobilePhone);
        System.assertEquals(l.ODM_Primary_Phone__c, c.Primary_Phone__c);
    
    }

}