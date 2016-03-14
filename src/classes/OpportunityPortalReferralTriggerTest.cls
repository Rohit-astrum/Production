/* FILE: EventPortalReferral.trigger
 * AUTHOR: Tino Mattheou
 * DATE: September 4, 2012
 * PURPOSE: updates portal referral if sales visit event is completed
 * MODIFICATION HISTORY
 *     10/09/2012 TCM - updates to connect referring account leads to portal
 *     10/27/2014 DK - Utility_Company_Master__c insertion in referralWithOpp_sold_statusChanged()
 */
 
@isTest(SeeAllData = true)
public class OpportunityPortalReferralTriggerTest {

    static testMethod void referral_completeSiteSurvey_detailChanged() {
        
        Portal_Referral__c referral = createReferralWithOpp();
        
        referral = [SELECT Id, Lead__c, Opportunity__c, Status__c, Detail__c
            FROM Portal_Referral__c
            WHERE Id = :referral.Id];
            
        System.assertEquals(PortalReferralStatus.OPEN_STATUS, referral.Status__c);
        System.assertEquals('New', referral.Detail__c);     
        
        Test.startTest();
        
        Opportunity opp = new Opportunity(
            Id = referral.Opportunity__c,
            StageName = 'Qualified',
            Date_Site_Survey_Completed__c = Date.today()
        );
        update opp;
        
        Test.stopTest();

        referral = [SELECT Id, Lead__c, Status__c, Detail__c
            FROM Portal_Referral__c
            WHERE Id = :referral.Id];
            
        System.assertEquals(PortalReferralStatus.QUALIFIED_STATUS, referral.Status__c);
        System.assertEquals('Site Survey Completed', referral.Detail__c);       
        
    }
    
    static testMethod void referralWithSalesVisit_changeStatus_detailChanged() {
        
        Portal_Referral__c referral = createReferralWithOpp();
        
        RecordType salesVisit = [SELECT Id FROM RecordType 
            WHERE SObjectType='Event' AND DeveloperName = 'Sales_Visit_Onsite'];
        
        Event evt = new Event(
            RecordTypeId = salesVisit.Id,
            WhatId = referral.Opportunity__c,
            ActivityDateTime = Datetime.now().addHours(-2),
            DurationInMinutes = 60,
            Completed__c = true
        );
        insert evt;
        
        referral = [SELECT Id, Lead__c, Opportunity__c, Status__c, Detail__c
            FROM Portal_Referral__c
            WHERE Id = :referral.Id];
            
        System.assertEquals(PortalReferralStatus.OPEN_STATUS, referral.Status__c);
        System.assertEquals('New', referral.Detail__c);     
        
        Test.startTest();
        
        Opportunity opp = new Opportunity(
            Id = referral.Opportunity__c,
            StageName = 'Sales Process Ongoing'
        );
        update opp;
        
        Test.stopTest();

        referral = [SELECT Id, Lead__c, Status__c, Detail__c
            FROM Portal_Referral__c
            WHERE Id = :referral.Id];
            
        System.assertEquals(PortalReferralStatus.QUALIFIED_STATUS, referral.Status__c);
        System.assertEquals('Sales Call Completed', referral.Detail__c);        
        
    }

    static testMethod void referralWithOpp_sold_statusChanged() {
        
        Portal_Referral__c referral = createReferralWithOpp();
        
        referral = [SELECT Id, Lead__c, Opportunity__c, Status__c, Detail__c
            FROM Portal_Referral__c
            WHERE Id = :referral.Id];
        
        
        Portal_Payment_Plan__c plan = new Portal_Payment_Plan__c (
        );
        insert plan;
        
        referral.Portal_Payment_Plan__c = plan.Id;
        update referral; 
            
        System.assertEquals(PortalReferralStatus.OPEN_STATUS, referral.Status__c);
        System.assertEquals('New', referral.Detail__c);

        Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE Id = :referral.Opportunity__c];
        
        Property__c property = CreateAstrumPM2ProjectTest.createProperty(opp.AccountId, '123 Test St');
        
        property.Optimal_Site_Quality_kWh_y_kW__c = 1200;
        update property;
        
        Survey__c survey = new Survey__c (
            Property__c = property.Id
        );
        insert survey;
        
        Utility_Company_Master__c utilMaster = new Utility_Company_Master__c(Name = 'Test Utility Company', State_Serviced__c = 'PA');
        insert utilMaster;
        
        Utility_Company__c utility = new Utility_Company__c (
            Utility_Company_Master__c = utilMaster.ID
        );
        insert utility;
        
        Utility_Service__c service = new Utility_Service__c (
            Utility_Company__c = utility.Id,
            Property__c = property.Id
        );
        insert service;
        
        CB_Panel__c cb = new CB_Panel__c (
            Utility_Service__c = service.Id,
            Main_Breaker_Rating_Amps__c = 200
        );
        insert cb;
        
        


        //MK 2014-05-02
        //Insert Physical Surface & link survey
        Physical_Surface__c ps = new Physical_Surface__c();
        ps.Property__c = property.Id; //New link to property
        ps.Surface_Tilt__c = 10;
        ps.Surface_Azimuth__c = 90;
        ps.Trenching_Dist_to_Intercon_Pt_ft__c = 10;
        ps.Suneye_Tilt_and_Orien_Factor__c = 2;        
        ps.Physical_Surface_Assigned_Letter__c = 'A'; //MK 2014-05-02
        ps.Surface_Type__c = 'Asphalt Shingle';//MK 2014-05-02

        insert ps;
        //MK 2014-05-02
        //Get PS in order to get the default mounting type
        ps = [select id, Default_Mounting_Type__c, Property__c, Surface_Tilt__c, Surface_Azimuth__c,
                Trenching_Dist_to_Intercon_Pt_ft__c, Suneye_Tilt_and_Orien_Factor__c, Surface_Type__c, 
                Name, Physical_Surface_Assigned_Letter__c from Physical_Surface__c where id =: ps.id];


        Install_Location__c location = new Install_Location__c (
            //Property__c = property.Id,
            Azimuth__c = 180,
            Pitch__c = 30,
            TSRF__c = 95,
            Location__c = 'S01', //MK 2014-05-02
            Physical_Surface__c = ps.id, //MK 2014-05-02
            Survey__c = survey.id //MK 2014-05-02            
        );
        insert location;
        
        System_Design__c sd = new System_Design__c (
            Property__c = property.Id,
            Calculated_System_Price__c = 35000
        );
        insert sd;
        
        System_Design_Array__c sda = new System_Design_Array__c (
            System_Design__c = sd.Id,
            CB_Panel__c = cb.Id,
            Physical_Surface__c = ps.id, //MK 2014-05-02
            Survey__c = survey.id, //MK 2014-05-02
            Mounting_Type__c = ps.Default_Mounting_Type__c //MK 2014-05-02
        );
        insert sda;
        
        RecordType panelProduct = [SELECT Id FROM RecordType WHERE SObjectType = 'System_Design_Product__c' AND DeveloperName = 'Panel'];
        System_Design_Product__c panel = new System_Design_Product__c (
            RecordTypeId = panelProduct.Id,
            Rated_Output_W__c = 250
        );
        insert panel;

        RecordType panelItem = [SELECT Id FROM RecordType WHERE SObjectType = 'System_Design_Item__c' AND DeveloperName = 'Panel'];
        
        System_Design_Item__c sdi = new System_Design_Item__c();
        sdi.RecordTypeId = panelItem.id;
        sdi.System_Design_Array__c = sda.Id;
        sdi.Install_Location__c = Location.Id;
        sdi.System_Design_Product__c = panel.Id;
        sdi.Quantity__c = double.valueOf('29');
        sdi.Annual_Solar_Access__c = double.valueOf('100');
        sdi.NRG_Site_Quality__c= double.valueOf('90');
        sdi.Rated_Output_kW__c = 12;
        sdi.Tilt__c = double.valueOf('3');
        sdi.Azimuth__c = double.valueOf('3');
        sdi.Astrum_PV_Watts_Site_Quality__c = double.valueOf('1200');

        insert sdi;
        
        System_Design_Quote__c sdq = new System_Design_Quote__c (
            System_Design__c = sd.Id
        );
        insert sdq;
        
        Test.startTest();

        //update the opportunity        
        opp = new Opportunity(
            Id = referral.Opportunity__c,
            Property__c = property.Id,
            SREC__c = 'Keep SRECS',
            System_Design_Quote__c = sdq.Id,
            LeadSource = 'Unknown',
            Lead_Source_Detail__c = 'Email',
            StageName = 'Closed - Won',
            Leasing_Option__c = null
        );
        update opp;
        
        Test.stopTest();

        referral = [SELECT Id, Lead__c, Status__c, Detail__c
            FROM Portal_Referral__c
            WHERE Id = :referral.Id];
            
        System.assertEquals(PortalReferralStatus.SOLD_STATUS, referral.Status__c);
        System.assertEquals(System.today().addDays(-8).format(), referral.Detail__c);       
        
    }
    
    static testMethod void oppsNoReferral_update_codeCoverage() {
        
        Account customer = new Account(Name = 'Test Customer');
        insert customer;
        Opportunity opp1 = CreateAstrumPM2ProjectTest.createOpportunity(customer.Id, 'Test Oppty');
        Opportunity opp2 = CreateAstrumPM2ProjectTest.createOpportunity(customer.Id, 'Test Oppty 2');
        
        opp1.StageName = 'Sales Process Ongoing';
        //opp2.Leasing_Option__c = 'Test Option';     
        
        Test.startTest();
        
        update opp1;
        update opp2;
        
        Test.stopTest();
        
    }

    static testMethod void portalAccount_setReferringAcct_referralCreated() {
        
        //create portal account and set payment plan
        Portal_Payment_Plan__c plan = new Portal_Payment_Plan__c();
        insert plan;
        
        User u = PortalToolsTest.createPortalUser();

        Account a = 
            [SELECT Id, Name, Portal_Payment_Plan__c 
            FROM Account
            WHERE Id IN (SELECT AccountId FROM Contact WHERE Id = :u.ContactId)];
        
        a.Portal_Payment_Plan__c = plan.Id;
        update a;
        
        //create a lead
        Lead ld = new Lead (
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Lead, Test',
            Site_Type__c = 'Residential', 
            Street = '123 Test St',
            City = 'Test City',
            State = 'PA',
            PostalCode = '19403',
            County__c = 'Chester',
            Phone = '(215) 555-1212',
            Email = 'test@test.com',
            Method_of_Contact__c = 'Referral', 
            LeadSource = 'Portal Referral',
            Lead_Source_Detail__c = 'Professional'
            //Lead_Source_Detail_2__c = 'Channel',
           // Lead_Source_Detail_4__c = 'Astrum Solar Connect'
        );
        insert ld;

        //convert to oppty      
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(ld.Id);
        lc.setConvertedStatus('Qualified');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        Lead ld2 = [SELECT Id, ConvertedOpportunityId FROM Lead WHERE Id = :ld.Id];
        
        Test.startTest();

        Opportunity opp = new Opportunity (
            Id = ld2.ConvertedOpportunityId,
            Referring_Account__c = a.Id
        );
        
        update opp;     
        
        Test.stopTest();
        
        Portal_Referral__c referral = 
            [SELECT Id, First_Name__c, Last_Name__c, Street__c, City__c, State__c, Zip__c, 
                Email__c, Account__c, Phone__c, Portal_Payment_Plan__c, Lead__c,
                Status__c, Detail__c
            FROM Portal_Referral__c
            WHERE Opportunity__c = :opp.Id];
            
        System.assertEquals(ld.FirstName, referral.First_Name__c);
        System.assertEquals(ld.LastName, referral.Last_Name__c);
        System.assertEquals(ld.Street, referral.Street__c);
        System.assertEquals(ld.City, referral.City__c);
        System.assertEquals(ld.State, referral.State__c);
        System.assertEquals(ld.PostalCode, referral.Zip__c);
        System.assertEquals(ld.Phone, referral.Phone__c);
        System.assertEquals(ld.Email, referral.Email__c);
        System.assertEquals(a.Id, referral.Account__c);
        System.assertEquals(plan.Id, referral.Portal_Payment_Plan__c);
        
        System.assertEquals(PortalReferralStatus.QUALIFIED_STATUS, referral.Status__c);
        System.assertEquals('Evaluation in Progress', referral.Detail__c);      
        
    }
    
    public static Portal_Referral__c createReferralWithOpp() {
        
        Portal_Referral__c referral = LeadPortalReferralTriggerTest.createPortalReferral();
        
        Account customer = new Account(Name = 'Test Customer');
        insert customer;
        Opportunity opp = CreateAstrumPM2ProjectTest.createOpportunity(customer.Id, 'Test Oppty');
        
        referral.Opportunity__c = opp.Id;
        update referral;
        
        return referral;    
        
    }

}