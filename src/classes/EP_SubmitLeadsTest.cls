/* FILE: EP_SubmitLeadsTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: December 28, 2012
 * PURPOSE: Test class for EP_SubmitLeadsExtension
 * MODIFICATION HISTORY
 * 01/07/2013 TCM - add Primary Source Campaign for acquisition costing
 * 01/11/2013 TCM - best time to call no longer required; utility by state, campaign by region/date
 * 07/03/2014 LLH - added call to 'resetForm()' to properly simulate Page functionality, removed changed assertions
 * 06/09/2015 PB  - Changed Utility to derive from Utility_Company_Master__c rather than Utility_Company__c
 */
 
 @isTest
 public class EP_SubmitLeadsTest {

    static testMethod void newLead_load_pickLists() {
        
        Utility_Company_Master__c utilMaster1 = new Utility_Company_Master__c(Name = 'Test Utility Company 1', State_Serviced__c = 'MA', Externally_Available__c = true);
        Utility_Company_Master__c utilMaster2 = new Utility_Company_Master__c(Name = 'Test Utility Company 2', State_Serviced__c = 'MA', Externally_Available__c = true);
        Utility_Company_Master__c[] utilMasters = new Utility_Company_Master__c[]{utilMaster1 , utilMaster2};
        insert utilMasters;
        
        Utility_Company__c util1 = new Utility_Company__c (
            Name = 'Util 1',
            Utility_Company_Master__c = utilMaster1.ID
        );
        insert util1;
        Utility_Company__c util2 = new Utility_Company__c (
            Name = 'Util 2',
            Utility_Company_Master__c = utilMaster2.ID
        );
        insert util2;
        
        Campaign camp1 = new Campaign(
            Name = 'Campaign 1', 
            StartDate = System.today(),
            One_Day_Event__c = true,
            Sales_Region_s__c = 'MA Region;'
        );
        insert camp1;
        Campaign camp2 = new Campaign(
            Name = 'Campaign 2', 
            StartDate = System.today().addDays(-1),
            EndDate = System.today(),
            Sales_Region_s__c = 'MA Region;'
        );
        insert camp2;

        Account acct1 = new Account(Name = 'Acct 1');
        insert acct1;
        Account acct2 = new Account(Name = 'Acct 2');
        insert acct2;
        
        Test.setCurrentPage(Page.EP_SubmitLeads);
        Portal_Referral__c referral = new Portal_Referral__c();
        ApexPages.StandardController controller = new ApexPages.StandardController(referral);
        EP_SubmitLeadsExtension extension = new EP_SubmitLeadsExtension(controller);
        
        System.runAs(createPortalUser()) {
        
            extension.resetForm();
            
            System.assertNotEquals(null, extension.userAlias);
            System.assertNotEquals(0, extension.states.size());
            System.assertNotEquals(0, extension.siteTypes.size());
            System.assertNotEquals(0, extension.timelines.size());
            System.assertNotEquals(0, extension.salutations.size());
            System.assertNotEquals(0, extension.bestTimes.size());
            System.assertNotEquals(0, extension.odmSalutations.size());
            System.assertNotEquals(0, extension.leadSources.size());
            System.assertNotEquals(0, extension.nameRanges.size());
            //System.assertNotEquals(0, extension.secondLeadSources.size());
            System.assertNotEquals(0, extension.ratings.size());
            System.assertNotEquals(0, extension.siteQualities.size());
            extension.newState = 'MA';
            System.assertEquals(3, extension.getUtilities().size());
            extension.newSalesRegion = 'MA Region';
            System.assertEquals(3, extension.getCampaigns().size());
            extension.newNameRange = extension.nameRanges[0].getValue();
            //System.assertEquals(3, extension.getRefAccounts().size());
        
        }
        
    }
 
    static testMethod void emptyForm_submit_Errors () {
        
        Test.setCurrentPage(Page.EP_SubmitLeads);
        Portal_Referral__c referral = new Portal_Referral__c();
        ApexPages.StandardController controller = new ApexPages.StandardController(referral);
        EP_SubmitLeadsExtension extension = new EP_SubmitLeadsExtension(controller);
        
        System.runAs(createPortalUser()) {
            
            Test.startTest();
            
            extension.resetForm();
            
            System.assertEquals(null, extension.submit());
            
            Test.stopTest();
            
            System.assert(extension.errorFields.contains('[1]'));
            System.assert(extension.errorFields.contains('[street]'));
            System.assert(extension.errorFields.contains('[city]'));
            System.assert(extension.errorFields.contains('[state]'));
            System.assert(extension.errorFields.contains('[zip]'));
            // System.assert(extension.errorFields.contains('[homeOwner]'));    // LLH
            // System.assert(extension.errorFields.contains('[siteType]'));     // LLH
            // these assertions have been removed since the controller now populates these fields on purpose
            System.assert(extension.errorFields.contains('[2]'));
            System.assert(extension.errorFields.contains('[fname]'));
            System.assert(extension.errorFields.contains('[lname]'));
            System.assert(extension.errorFields.contains('[email]'));
            System.assert(extension.errorFields.contains('[phone]'));
            
            System.assert(extension.errorFields.contains('[4]'));
            System.assert(extension.errorFields.contains('[leadSource]'));
            
        }
        
    }
    
    static testMethod void badData_submit_Errors () {
        
        Test.setCurrentPage(Page.EP_SubmitLeads);
        Portal_Referral__c referral = new Portal_Referral__c();
        ApexPages.StandardController controller = new ApexPages.StandardController(referral);
        EP_SubmitLeadsExtension extension = new EP_SubmitLeadsExtension(controller);
        
        System.runAs(createPortalUser()) {
            
            Test.startTest();
            
            extension.resetForm();
            
            referral.Street__c = '99 Oakmark Ave';
            referral.City__c = 'Yardley';
            referral.State__c = 'PA';
            referral.Zip__c = '19394';
            extension.homeOwner = 'Yes';
            extension.siteType = 'Residential';

            referral.First_Name__c = 'Test';
            referral.Last_Name__c = 'Referral';
            referral.Email__c = 'test_test.com';

            extension.odm.Last_Name__c = 'Decision';
            extension.odm.Email__c = 'test2_test.com';
            
            referral.Lead_Source__c = 'Door Hanger';
            
            System.assertEquals(null, extension.submit());
            
            Test.stopTest();
            
            System.assert(extension.errorFields.contains('[2]'));
            System.assert(extension.errorFields.contains('[email]'));

        }
        
    }

    static testMethod void missingData_submit_Errors () {
        
        Test.setCurrentPage(Page.EP_SubmitLeads);
        Portal_Referral__c referral = new Portal_Referral__c();
        ApexPages.StandardController controller = new ApexPages.StandardController(referral);
        EP_SubmitLeadsExtension extension = new EP_SubmitLeadsExtension(controller);
        
        System.runAs(createPortalUser()) {
            
            Test.startTest();
            
            extension.resetForm();

            referral.Street__c = '99 Oakmark Ave';
            referral.City__c = 'Yardley';
            referral.State__c = 'PA';
            referral.Zip__c = '19394';
            extension.homeOwner = 'Yes';
            extension.siteType = 'Commercial';

            referral.First_Name__c = 'Test';
            referral.Last_Name__c = 'Referral';
            referral.Phone__c = '215-555-1212';

            extension.odm.Last_Name__c = 'Decision';
            extension.odm.Email__c = 'test2_test.com';
            
            referral.Lead_Source__c = 'Door Hanger';
            
            System.assertEquals(null, extension.submit());
            
            Test.stopTest();
            
            System.assert(extension.errorFields.contains('[1]'));
            System.assert(extension.errorFields.contains('[companyName]'));

            //auto set if only one phone
            System.assertEquals('Home Phone', referral.Primary_Phone__c);

        }
        
    }
    
    static testMethod void loadPage_changePicklist_FlagsChange () {
        
        Test.setCurrentPage(Page.EP_SubmitLeads);
        Portal_Referral__c referral = new Portal_Referral__c();
        ApexPages.StandardController controller = new ApexPages.StandardController(referral);
        EP_SubmitLeadsExtension extension = new EP_SubmitLeadsExtension(controller);
        
        System.runAs(createPortalUser()) {
            
            extension.resetForm();
            
            System.assertNotEquals(true, extension.showCompany);
            extension.newSiteType = 'Commercial';
            extension.siteTypeChanged();
            System.assertEquals(true, extension.showCompany);
            
            System.assertNotEquals(true, extension.showCampaign1);
            System.assertNotEquals(true, extension.showRefAcct1);
            extension.newLeadSource = 'Trade Show';
            extension.leadSourceChanged();
            extension.nameRangeChanged();
            System.assertEquals(true, extension.showCampaign1);
            System.assertNotEquals(true, extension.showRefAcct1);
            extension.newLeadSource = 'Partner Referral';
            extension.leadSourceChanged();
            System.assertNotEquals(true, extension.showCampaign1);
            System.assertEquals(true, extension.showRefAcct1);
            
            System.assertNotEquals(true, extension.showCampaign2);
            extension.newLeadSource2 = 'Trade Show';
            extension.leadSource2Changed();
            System.assertEquals(true, extension.showCampaign2);
            
        }
        
    }
    
    static testMethod void completeForm_submit_ReferralCreated() {
        
        //Utility_Company__c util1 = new Utility_Company__c (Name = 'Util 1');
        //insert util1;
        Utility_Company_Master__c utilMaster1 = new Utility_Company_Master__c(Name = 'Test Utility Company 1', State_Serviced__c = 'MA', Externally_Available__c = true);
        insert utilMaster1;        
        
        Campaign camp1 = new Campaign (         
            Name = 'Campaign 1', 
            StartDate = System.today(),
            One_Day_Event__c = true,
            Sales_Region_s__c = 'MA Region;'
        );
        insert camp1;

        Account acct1 = new Account(Name = 'Acct 1');
        insert acct1;
        
        Test.setCurrentPage(Page.EP_SubmitLeads);
        Portal_Referral__c referral = new Portal_Referral__c();
        ApexPages.StandardController controller = new ApexPages.StandardController(referral);
        EP_SubmitLeadsExtension extension = new EP_SubmitLeadsExtension(controller);
        
        System.runAs(createPortalUser()) {

            extension.resetForm();
            
            referral.Street__c = '99 Oakmark Ave';
            referral.City__c = 'Yardley';
            referral.State__c = 'PA';
            referral.Zip__c = '19394';
            extension.homeOwner = 'Yes';
            ApexPages.currentPage().getParameters().put('siteQuality', 'Google Maps');
            extension.siteType = 'Residential';
            extension.electricBill = '150';
            //extension.utilityId = util1.Id;
            extension.utilityId = utilMaster1.Id;
            extension.propertyNotes = 'Test Property Notes';

            extension.salutation = 'Mr.';                       
            referral.First_Name__c = 'Test';
            referral.Last_Name__c = 'Referral';
            referral.Phone__c = '215-555-1212';
            referral.Mobile_Phone__c = '215-333-1212';
            referral.Work_Phone__c = '215-444-1212';
            ApexPages.currentPage().getParameters().put('primaryPhone', 'Home Phone');
            referral.Email__c = 'test@test.com';
            extension.bestTime = 'Midday';

            extension.odmSalutation = 'Mrs.';                   
            extension.odm.First_Name__c = 'Mary';
            extension.odm.Last_Name__c = 'Referral';
            extension.odm.Email__c = 'test2@test.com';
            extension.odm.Phone__c = '215-555-1212';
            extension.odm.Mobile_Phone__c = '215-634-1212';
            extension.odm.Work_Phone__c = '215-234-1212';
            ApexPages.currentPage().getParameters().put('odmPrimaryPhone', 'Work Phone');

            referral.Lead_Source__c = 'Individual Referral';
            extension.newLeadSource = 'Individual Referral';
            extension.leadSourceChanged();
            extension.refAcct = acct1.Id;
            extension.leadSourceNotes = 'Test Lead Source Notes';
            extension.secondLeadSource = 'Trade Show';
            extension.newLeadSource2 = 'Trade Show';
            extension.leadSource2Changed();
            extension.campaignId = camp1.Id;
            extension.timeline = 'Deciding Now';
            extension.competitive = true;
            extension.rating = 'Hot';
            referral.Notes__c = 'test notes';
            
            Test.startTest();
            
            PageReference result = extension.submit();
            
            Test.stopTest();
            
            System.assert(String.isBlank(extension.errorFields), extension.errorFields);
            
            // System.assert(result.getUrl().startsWith(Page.EP_SubmitLeads.getUrl())); // LLH - no longer needed due to behavior change

        }
        
        referral = 
            [SELECT Id, Lead__c, Status__c, Detail__c, First_Name__c,
                    Last_Name__c, Street__c, City__c, State__c, Zip__c, Phone__c,
                    Work_Phone__c, Mobile_Phone__c, Primary_Phone__c, Email__c,
                    Lead_Source__c
            FROM Portal_Referral__c];
            
        System.assertEquals(PortalReferralStatus.OPEN_STATUS, referral.Status__c);
        System.assertEquals('New', referral.Detail__c);
        System.assertEquals('99 Oakmark Ave', referral.Street__c);
        System.assertEquals('Yardley', referral.City__c);
        System.assertEquals('PA', referral.State__c);
        System.assertEquals('19394', referral.Zip__c);

        System.assertEquals('Test', referral.First_Name__c);
        System.assertEquals('Referral', referral.Last_Name__c);
        System.assertEquals('215-555-1212', referral.Phone__c);
        System.assertEquals('215-333-1212', referral.Mobile_Phone__c);
        System.assertEquals('215-444-1212', referral.Work_Phone__c);
        System.assertEquals('test@test.com', referral.Email__c);
        System.assertEquals('Home Phone', referral.Primary_Phone__c);
        
        Lead l = [SELECT Id, OwnerId, FirstName, LastName, Company, Phone,
            Email, Street, City, State, PostalCode, Lead_Date__c, 
            Method_of_Contact__c, Lead_Source_Notes__c, LeadSource,
            Referring_Account__c, Home_Owner__c, Site_Quality_Confirmed__c,
            Monthly_Electric_Bill__c, Utility_Company__c, Property_Notes__c,
            Primary_Phone__c, Best_Time_to_Call__c, ODM_Salutation__c,
            ODM_First_Name__c, ODM_Last_Name__c, ODM_Email__c,
            ODM_Phone__c, ODM_Mobile_Phone__c, ODM_Work_Phone__c,
            ODM_Primary_Phone__c, Self_Generated__c, Contact_Detail__c, 
            Second_Lead_Source__c, Competitive_Quote_Mentioned__c, 
            Customer_Timeframe__c, Rating, Internal_Sales_Notes__c,
            Salutation, MobilePhone, Work_Phone__c, Primary_Source_Campaign__c,
            Utility_Company_Master__c,
            (Select CampaignId From CampaignMembers)
            FROM Lead];     

        Group g = [SELECT Id, DeveloperName FROM Group WHERE Id = :l.OwnerId];

        System.assertEquals('WebLeadQueue' , g.DeveloperName);
    
        System.assertEquals('99 Oakmark Ave', l.Street);
        System.assertEquals('Yardley', l.City);
        System.assertEquals('PA', l.State);
        System.assertEquals('19394', l.PostalCode);
        System.assertEquals(true, l.Home_Owner__c);
        System.assertEquals('Google Maps', l.Site_Quality_Confirmed__c);
        System.assertEquals(150, l.Monthly_Electric_Bill__c);
        //System.assertEquals(util1.Id, l.Utility_Company__c);
        System.assertEquals(utilMaster1.Id, l.Utility_Company_Master__c);
        System.assertEquals('Test Property Notes', l.Property_Notes__c);
        
        System.assertEquals('Mr.', l.Salutation);
        System.assertEquals('Test', l.FirstName);
        System.assertEquals('Referral', l.LastName);
        System.assertEquals('Referral, Test', l.Company);
        System.assertEquals('test@test.com', l.Email);  
        System.assertEquals('215-555-1212', l.Phone);
        System.assertEquals('215-333-1212', l.MobilePhone);
        System.assertEquals('215-444-1212', l.Work_Phone__c);
        System.assertEquals('Home Phone', l.Primary_Phone__c);
        System.assertEquals('Midday', l.Best_Time_To_Call__c);
        
        System.assertEquals('Mrs.', l.ODM_Salutation__c);
        System.assertEquals('Mary', l.ODM_First_Name__c);
        System.assertEquals('Referral', l.ODM_Last_Name__c);
        System.assertEquals('215-555-1212', l.ODM_Phone__c);
        System.assertEquals('215-634-1212', l.ODM_Mobile_Phone__c);
        System.assertEquals('215-234-1212', l.ODM_Work_Phone__c);
        System.assertEquals('Work Phone', l.ODM_Primary_Phone__c);

        System.assertEquals(Date.today(), l.Lead_Date__c);
        System.assertEquals(true, l.Self_Generated__c);
        System.assertEquals(extension.userAlias, l.Contact_Detail__c);
        System.assertEquals('Individual Referral', l.LeadSource);
        System.assertEquals('Test Lead Source Notes', l.Lead_Source_Notes__c);
        System.assertEquals('Employee Portal', l.Method_of_Contact__c);
        //System.assertEquals('Trade Show', l.Second_Lead_Source__c);
        System.assertEquals(1, l.CampaignMembers.size());
        System.assertEquals(camp1.Id, l.CampaignMembers[0].CampaignId);
       //System.assertEquals('Mentioned', l.Competitive_Quote_Mentioned__c);
        System.assertEquals('Deciding Now', l.Customer_Timeframe__c);
        System.assertEquals('Hot', l.Rating);
        System.assertEquals('test notes', l.Internal_Sales_Notes__c);
        System.assertEquals(acct1.Id, l.Referring_Account__c);
        System.assertEquals(null, l.Primary_Source_Campaign__c);
        
    }
    
    static testMethod void duplicateLead_submit_duplicateError() {
        
        Lead l = new Lead (
            LastName = 'Test',
            Company = 'Test',
            Street = '99 Oakmark Ave',
            City = 'Yardley',
            State = 'PA'
        );
        insert l;

        System.runAs(createPortalUser()) {

            Test.setCurrentPage(Page.EP_SubmitLeads);
            Portal_Referral__c referral = new Portal_Referral__c();
            ApexPages.StandardController controller = new ApexPages.StandardController(referral);
            EP_SubmitLeadsExtension extension = new EP_SubmitLeadsExtension(controller);

            extension.resetForm();
            
            referral.First_Name__c = 'Test';
            referral.Last_Name__c = 'Referral';
            referral.Street__c = '99 Oakmark Ave';
            referral.City__c = 'Yardley';
            referral.State__c = 'PA';
            referral.Zip__c = '19394';
            referral.Phone__c = '215-555-1212';
            extension.homeOwner = 'Yet';
            extension.siteType = 'Residential';
            referral.Lead_Source__c = 'Door Hanger';
            extension.bestTime = 'Midday';
            
            Test.startTest();
            
            PageReference result = extension.submit();

            Test.stopTest();

            System.assert(String.isBlank(extension.errorFields), extension.errorFields);

            System.assert(result.getUrl().startsWith(Page.EP_DuplicateLead.getUrl()));

        }
        
        Portal_Referral__c referral = 
            [SELECT Id, Lead__c, Status__c, First_Name__c,
                    Last_Name__c, Street__c, City__c, State__c, Zip__c, Phone__c, Email__c
            FROM Portal_Referral__c];
            
        System.assertEquals(null, referral.Lead__c);
        System.assertEquals(PortalReferralStatus.DUPLICATE_STATUS, referral.Status__c);
        System.assertEquals('Test', referral.First_Name__c);
        System.assertEquals('Referral', referral.Last_Name__c);
        System.assertEquals('99 Oakmark Ave', referral.Street__c);
        System.assertEquals('Yardley', referral.City__c);
        System.assertEquals('PA', referral.State__c);
        System.assertEquals('19394', referral.Zip__c);
        System.assertEquals('215-555-1212', referral.Phone__c);

        List<Task> tasks = [SELECT Subject, Description, WhoId FROM Task WHERE WhoId = :l.Id];
        System.assertEquals(1, tasks.size());
        System.assert(tasks[0].Subject.startsWith('Duplicate Lead Submitted by '));
        System.assert(tasks[0].Description.startsWith('Property Information'));
        
    }
    
    //create employee portal user
    public static User createPortalUser() {
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Employee Portal User'];
        
        User accountOwner = 
            [SELECT Id FROM User 
            WHERE UserRoleId <> NULL
            AND Profile.UserType = 'Standard' 
            AND IsActive = TRUE 
            LIMIT 1];
        
        Account a = new Account (
            OwnerId = accountOwner.Id,
            Name = 'Test Employee',
            Related_User__c = accountOwner.Id
        );
        insert a;
        
        Contact c = new Contact (
            LastName = 'Employee',
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