/* FILE: EnphaseMonthlyProductionPullBatchTest.cls
 * AUTHOR: Rohit Jain
 * DATE: May 16, 2013
 * PURPOSE: Test class for EnphaseMonthlyProductionPullBatch processes
 * MODIFICATION HISTORY:
 *
 */

@isTest
public class EnphaseMonthlyProductionPullBatchTest{

    static testMethod void runProductionPullBatch() {
        
        Account customer = new Account ( Name = 'Test Customer' );
        insert customer;
        
        
        
        Property__c property = new Property__c(
          Name = '123 w street',
          Property_Owner__c = customer.id,
          Property_City__c = 'Test City',
          Property_State__c = 'PA',
          Property_Zip__c = '19403',
          Property_County__c = 'Test County'
        );
        insert property;
        
        property.Optimal_Site_Quality_kWh_y_kW__c = 1200;
        update property;
        
        Survey__c survey = new Survey__c (
            Property__c = property.Id
        );
        insert survey;
        
        Utility_Company__c utility = new Utility_Company__c (
            State_Serviced__c = 'PA'
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
        
        //MK 2014-05-02 - Move survey creation first so we can connect install locations to it

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
            //Property__c = property.Id, //MK 2014-05-02
            Location__c = 'S01',//MK 2014-05-02
            Physical_Surface__c = ps.id,//MK 2014-05-02
            Survey__c = survey.id,//MK 2014-05-02            
            Azimuth__c = 180,
            Pitch__c = 30,
            TSRF__c = 95
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

        SiteQualitySettings__c sq = new SiteQualitySettings__c();
        sq.Name = 'SiteQuality';
        sq.Batch_Size__c = 5;
        sq.CPRE__c = false;
        sq.NRG__c = false;
        sq.NRG_Batch_Size__C = 5;
        sq.Astrum__c = false;
        insert sq;

        RecordType panelItem = [SELECT Id FROM RecordType WHERE SObjectType = 'System_Design_Item__c' AND DeveloperName = 'Panel'];
        
        System_Design_Item__c item = new System_Design_Item__c (
            RecordTypeId = panelItem.Id,
            System_Design_Array__c = sda.Id,
            System_Design_Product__c = panel.Id,
            Install_Location__c = location.Id,
            Quantity__c = 10
        );
        insert item;
        
        System_Design_Quote__c sdq = new System_Design_Quote__c (
            System_Design__c = sd.Id
        );
        insert sdq;
        
        Installed_System__c sys = new Installed_System__c (
            Account__c = customer.Id,
            Enphase_ID__c = '12345',
            Monthly_Production_Factor_Jan__c = 0.2,
            Monthly_Production_Factor_Feb__c = 0.2,
            Monthly_Production_Factor_Mar__c = 0.2,
            Monthly_Production_Factor_Apr__c = 0.2,
            Monthly_Production_Factor_May__c = 0.2,
            Monthly_Production_Factor_Jun__c = 0.2,
            Monthly_Production_Factor_Jul__c = 0.2,
            Monthly_Production_Factor_Aug__c = 0.2,
            Quoted_System_Design__c = sdq.id            
        );
        insert sys;
        
        
        PVWatts_Production_Estimates__c pv = new PVWatts_Production_Estimates__c();
        pv.January__c = 1.0;
        pv.February__c= 1.0;
        pv.March__c= 1.0;
        pv.April__c= 1.0;
        pv.May__c= 1.0;
        pv.June__c= 1.0;
        pv.July__c= 1.0;
        pv.August__c= 1.0;
        pv.September__c= 1.0;
        pv.October__c= 1.0;
        pv.November__c= 1.0;
        pv.December__c= 1.0;
        pv.longitude__c =  -75.3;
        pv.latitude__c = 40.2;
        pv.Annual_Total__c = 12;
        pv.Installed_System__c = sys.Id;
        
        insert pv;
                
        EnphaseMonthlyProductionPullBatch batch = new EnphaseMonthlyProductionPullBatch();
                
        Test.startTest();
        Id batchId = Database.executeBatch(batch, 10);
        Test.stopTest();      
        
    }
}