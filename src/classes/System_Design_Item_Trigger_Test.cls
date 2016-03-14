//TCM 06/16/2012 - fix for inserts failing and not covering the trigger
@isTest(SeeAllData=true)
private class System_Design_Item_Trigger_Test {

    static testMethod void testSystemDesignItemTrigger() {
        
        Utility_Company__c uc = new Utility_Company__c();
        uc.Name = 'BG&E';
        uc.States_Serviced__c = 'MD';
        uc.Weekend_Schedule__c = '111111111111111111111111222111111111111111111111111111111133111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';
        uc.Weekday_Schedule__c  = '111111111111111111111111111111111111111111111111221111111111111111111111111111133333311111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';
        Database.Saveresult ucDBResult = Database.Insert(uc,false);
        Id ucId = ucDBResult.getId();
        if(ucId == null){
          System.debug('ucDBResult Insert Errors --> ' + ucDBResult.getErrors());
        }
        System.debug('Added Utility Company with Id --> ' + ucId);

        List<Rate_Period__c> rps = new List<Rate_Period__c>();
        Rate_period__c rp = new Rate_period__c();
        rp.Period_Type__c = 'Peak';
        rp.Name = 'Period 1';
        rp.Utility_Company__c = ucId;
        rp.Rate_Period__c = 1;
        rps.add(rp);

        Rate_period__c rp1 = new Rate_period__c();
        rp1.Period_Type__c = 'Part_Peak';
        rp1.Name = 'Period 2';
        rp1.Utility_Company__c = ucId;
        rp1.Rate_Period__c = 2;
         rps.add(rp1);

        Rate_period__c rp2 = new Rate_period__c();
        rp2.Period_Type__c = 'Off_Peak';
        rp2.Name = 'Period 3';
        rp2.Utility_Company__c = ucId;
        rp2.Rate_Period__c = 3;
        rps.add(rp2);

        insert rps;

        Property__c property = new Property__c (
        	Name = '123 Test St',
        	Property_City__c = 'Test City',
        	Property_State__c = 'MD',        	
        	Property_Zip__c = '19403',
        	Max_Site_Quality__c = 1400,
        	Optimal_Site_Quality_kWh_y_kW__c = 1400,
        	Utility_Company__c =  ucId,
        	Property_County__c = 'Howard',
        	Astrum_Office__c = testdata.defaultOffLocationName// FPO Phase4 //'Annapolis Junction, MD' 
        );
        insert property;  

        //MK - 2014-05-04 added survey
        Survey__c survey = new Survey__c (
            Property__c = property.Id
        );
        insert survey;
        
        Utility_Service__c utility = new Utility_Service__c (
        	Property__c = property.Id
        );
        insert utility;
        
        CB_Panel__c panel = new CB_Panel__c (
        	Utility_Service__c = utility.Id,
        	Main_Breaker_Rating_Amps__c = 200
        );
		insert panel;
		
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
        ps.Number_of_Stories__c = '3';
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
			Pitch__c = 0.25,
			TSRF__c = 89,
			Number_of_Stories__c = 3
		);
		insert location;
		
		RecordType sdpPanel = [SELECT Id FROM RecordType WHERE SObjectType = 'System_Design_Product__c' AND Name = 'Panel'];
		
		System_Design_Product__c sdp = new System_Design_Product__c (
			RecordTypeId = sdpPanel.Id,
			Rated_Output_W__c = 240
		);
		insert sdp;
        
        System_Design__c sd = new System_Design__c (
        	Property__c = property.Id
        );
        insert sd;
        
		System_Design_Array__c sda = new System_Design_Array__c (
        	System_Design__c = sd.Id,
        	CB_Panel__c = panel.Id,
            Physical_Surface__c = ps.id, //MK 2014-05-02
            Survey__c = survey.id, //MK 2014-05-02
            Mounting_Type__c = ps.Default_Mounting_Type__c //MK 2014-05-02
		);
		insert sda;
		
		RecordType sdiPanel = [SELECT Id FROM RecordType WHERE SObjectType = 'System_Design_Item__c' AND Name = 'Panel'];
		
        System_Design_Item__c sdi = new System_Design_Item__c();
        sdi.RecordTypeId = sdiPanel.id;
        sdi.System_Design_Array__c = sda.Id;
        sdi.Install_Location__c = Location.Id;
        sdi.System_Design_Product__c = sdp.Id;
        sdi.Quantity__c = double.valueOf('29');
        sdi.Annual_Solar_Access__c = double.valueOf('100');
        sdi.NRG_Site_Quality__c= double.valueOf('90');
        sdi.Rated_Output_kW__c = 12;
        sdi.Tilt__c = double.valueOf('3');
        sdi.Azimuth__c = double.valueOf('3');
        sdi.Astrum_PV_Watts_Site_Quality__c = double.valueOf('1200');

        insert sdi;
    	
    	sdi = [SELECT Id, Location_Pitch__c, Location_Stories__c, Rated_Output_Kw__c,  
    		Projected_Annual_Output_kWh_y__c FROM System_Design_Item__c WHERE Id = :sdi.Id];
    		
    	System.assertEquals(location.Pitch__c, sdi.Location_Pitch__c);
    	System.assertEquals(location.Number_of_Stories__c, sdi.Location_Stories__c);
		
    }
}