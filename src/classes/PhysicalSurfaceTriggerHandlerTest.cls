@isTest
private class PhysicalSurfaceTriggerHandlerTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out
	
	@isTest static void test_method_one() {
		if(!runalltests){ return; }

        //Create Custom Settings
        testdata.setupCustomSettings();
        testdata.setupCustomConfigObjects();

        Account acct = new Account();
        acct.name='TestAcct';        
        insert acct;

        Property__c prop = new Property__c();
        prop.Name = '123 Main St';
        prop.RecordTypeid = [Select id from RecordType where sobjecttype = 'Property__c' and Name = 'Residential' limit 1].id;
        prop.Property_Owner__c = acct.Id;       
        prop.Optimal_Site_Quality_kWh_y_kW__c = double.valueOf('1250');
        prop.Property_State__c = 'MD';
        prop.Property_City__c = 'Annapolis Junction';        
        prop.Property_ZIP__c = '20701';
        prop.Property_County__c = 'Howard';
        prop.Astrum_Office__c = testdata.defaultOffLocationName;// FPO Phase4 //'Annapolis Junction, MD';        
        prop.Sales_Region__c = [select id from Astrum_Sales_Region__c where name='MD Region'].id;  
        prop.QAS_Property_County__c = 'Howard County, MD';    //DK 12-23-14
        insert prop;
        
        Test.startTest();

        Physical_Surface__c physicalSurface = new Physical_Surface__c();
        physicalSurface.Property__c = prop.Id; //New link to property
        physicalSurface.Surface_Tilt__c = 10;
        physicalSurface.Surface_Azimuth__c = 90;
        physicalSurface.Trenching_Dist_to_Intercon_Pt_ft__c = 10;
        physicalSurface.Suneye_Tilt_and_Orien_Factor__c = 2;        
        physicalSurface.Physical_Surface_Assigned_Letter__c = 'A'; //MK 2014-05-02
        physicalSurface.Surface_Type__c = 'Asphalt Shingle';//MK 2014-05-02
        insert physicalSurface; 

        physicalSurface.Surface_Tilt__c = 11;
        update physicalSurface;

        delete physicalSurface;

        Test.stopTest();
	}
}