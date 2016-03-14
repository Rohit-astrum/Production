//10/12/2012 TCM - add dc-to-ac-derate parameter
@isTest(SeeAllData=true)
private class PVWatts_ServiceClient_Test {
       
    static testMethod void testGetSiteQuality() {

        // setup
        Account acct = new Account();
        acct.name='TestAcct';        
        insert acct;
        
        Contact ct = new Contact();
        ct.AccountId = acct.Id;
        ct.FirstName = 'TestC';
        ct.LastName = 'TestL';
        ct.Email = 'Test322@Test.comm';
        ct.Phone = '333-444-5555';
        insert ct;

        Utility_Company_Master__c utilCompany = new Utility_Company_Master__c();
        utilCompany.Name = 'BG&E';
        utilCompany.Solar_Compensation_Method__c = 'Net Metering';
        utilCompany.State_Serviced__c = 'MD';
        insert utilCompany;
        
        //Utility Rate Code
        Utility_Company__c uc = new Utility_Company__c();
        uc.Name = 'BG&E';
        uc.Utility_Company_Master__c = utilCompany.ID;
        uc.All_Electric_Service__c = 'No';
        uc.Baseline_Consumption_kWh_day__c = '10.1;10.1;10.1;10.1;9.6;9.6;9.6;9.6;9.6;9.6;10.1;10.1';
        uc.Baseline_Consumption_kWh_month__c = 'NA';
        uc.Tier_1_Cap__c = 100;
        uc.Tier_2_Cap__c = 120;
        uc.Tier_3_Cap__c = 150;
        uc.Tier_4_Cap__c = 200;
        uc.Tier_5_Cap__c = 225;
        uc.Average_Consumption_Profile__c = '3.3;3.0;2.9;2.8;2.9;3.2;3.9;4.4;4.4;4.3;4.3;4.1;4.0;3.9;3.8;3.9;4.3;5.4;5.9;5.9;5.7;5.3;4.6;3.8;3.3;3.0;2.9;2.8;2.9;3.3;4.0;4.5;4.4;4.4;4.3;4.1;4.0;3.9;3.8;3.8;4.2;5.0;5.9;5.9;5.8;5.3;4.6;3.8;3.3;3.0;2.8;2.8;2.9;3.2;4.0;4.5;4.4;4.3;4.3;4.2;4.1;4.0;3.9;3.9;4.2;4.7;5.5;5.9;5.9;5.5;4.7;3.9;3.3;3.0;2.8;2.8;2.8;3.1;3.8;4.3;4.3;4.3;4.3;4.3;4.2;4.2;4.1;4.1;4.3;4.7;5.1;5.5;6.0;5.7;4.8;4.0;3.3;3.0;2.8;2.7;2.7;2.9;3.5;3.9;3.9;4.0;4.1;4.1;4.2;4.2;4.3;4.5;4.9;5.2;5.4;5.5;5.9;5.8;4.9;4.0;3.3;2.9;2.7;2.6;2.5;2.7;3.0;3.3;3.5;3.7;3.9;4.1;4.3;4.5;4.8;5.1;5.4;5.8;5.9;5.7;5.7;5.7;4.9;4.0;3.3;2.9;2.6;2.5;2.4;2.5;2.7;3.0;3.3;3.5;3.7;4.0;4.4;4.7;5.1;5.4;5.8;6.1;6.2;5.9;5.8;5.6;4.8;3.9;3.2;2.8;2.6;2.5;2.5;2.6;2.9;3.1;3.3;3.5;3.7;3.9;4.2;4.6;4.9;5.4;5.8;6.1;6.2;6.0;6.0;5.6;4.7;3.9;3.2;2.9;2.7;2.6;2.6;2.8;3.2;3.5;3.5;3.7;3.8;3.9;4.1;4.4;4.7;5.1;5.4;5.8;5.9;6.1;6.1;5.5;4.7;3.8;3.3;3.0;2.8;2.8;2.8;3.1;3.7;4.2;4.2;4.2;4.2;4.2;4.1;4.1;4.1;4.3;4.5;5.0;5.6;6.1;5.9;5.4;4.6;3.8;3.2;2.9;2.8;2.8;2.8;3.2;3.9;4.4;4.4;4.3;4.3;4.2;4.1;4.0;3.9;4.0;4.5;5.6;6.0;5.9;5.7;5.2;4.5;3.7;3.3;3.0;2.8;2.8;2.8;3.1;3.7;4.2;4.3;4.3;4.2;4.1;4.0;3.9;3.8;3.9;4.4;5.6;6.0;6.0;5.8;5.4;4.7;3.9;';
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
        
        Property__c prop = new Property__c();
        prop.Name = '123 Main St';
        prop.Property_Owner__c = acct.Id;       
        prop.Optimal_Site_Quality_kWh_y_kW__c = double.valueOf('1250');
        prop.Property_State__c = 'MD';
        prop.Property_City__c = 'Annapolis Junction';
        prop.Property_ZIP__c = '20701';
        prop.Property_County__c = 'Howard';
        prop.Astrum_Office__c = testdata.defaultOffLocationName;// FPO Phase4 //'Annapolis Junction, MD';    
        prop.Latitude__c = 39.125951;
        prop.Longitude__c = -76.794940;
        prop.Confirmed_Location__Latitude__s =  39.125951;
        prop.Confirmed_Location__Longitude__s =  -76.794940;

        prop.Utility_Company__c =  ucId; 
        insert prop;
        
       
       
        Survey__c surv = new Survey__c();
        surv.Property__c = prop.Id;
        surv.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'Survey__c' and r.Name = 'Field Survey'].id;        
        insert surv;
        
        Utility_Service__c utilService = new Utility_Service__c();
        utilService.Amperage__c = double.valueOf('200');
        utilService.Utility_Company__c = uc.Id;
        utilService.Utility_Rate_Code_Before_Solar__c = uc.Id;
        utilService.Utility_Rate_Code_After_Solar__c = uc.Id;
        utilService.Utility_Company_Master__c = utilCompany.ID;
        utilService.Property__c = prop.Id;
        utilService.Service_Account_Number__c = 'abc123';
        Database.Saveresult utilServiceDBResult = Database.Insert(utilService,false);
        Id utilServiceId = utilServiceDBResult.getId();
        if(utilServiceId == null){
          System.debug('utilServiceDBResult Insert Errors --> ' + utilServiceDBResult.getErrors());
        }        
        System.debug('Added Utility_Service__c with Id --> ' + utilServiceId);

        CB_Panel__c mainPanel = new CB_Panel__c();
        mainPanel.Utility_Service__c = utilServiceId;
        mainPanel.Main_Breaker_Rating_Amps__c = Double.valueOf('200');
        System.debug('mainPanel --> ' + mainPanel);      
        Database.Saveresult mainPanelDBResult = Database.Insert(mainPanel,false);
        Id mainPanelId = mainPanelDBResult.getId();
        if(mainPanelId == null){
          System.debug('mainPanelDBResult Insert Errors --> ' + mainPanelDBResult.getErrors());
        }        
        System.debug('Added CB_Panel__c with Id --> ' + mainPanelId);
      
        
        //MK 2014-05-02
        //Insert Physical Surface & link survey        
        Physical_Surface__c ps = new Physical_Surface__c();
        ps.Property__c = prop.Id; //New link to property
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
                
        Install_Location__c instLoc = new Install_Location__c();
        instLoc.Location__c = 'S01';//MK 2014-05-02
        instLoc.Physical_Surface__c = ps.id;//MK 2014-05-02
        instLoc.Survey__c = surv.id;//MK 2014-05-02
        //instLoc.Property__c = propt.Id; //MK 2014-05-02
        instLoc.Azimuth__c = double.valueOf('180');
        instLoc.Pitch__c = double.valueOf('23');
        instLoc.TSRF__c = double.valueOf('90');
        instLoc.Jan_Solar_Access__c = double.valueOf('100');
        instLoc.Feb_Solar_Access__c = double.valueOf('100');
        instLoc.Mar_Solar_Access__c = double.valueOf('100');
        instLoc.Apr_Solar_Access__c = double.valueOf('100');
        instLoc.May_Solar_Access__c = double.valueOf('100');
        instLoc.Jun_Solar_Access__c = double.valueOf('100');
        instLoc.Jul_Solar_Access__c = double.valueOf('100');
        instLoc.Aug_Solar_Access__c = double.valueOf('100');
        instLoc.Sep_Solar_Access__c = double.valueOf('100'); 
        instLoc.Oct_Solar_Access__c = double.valueOf('100');
        instLoc.Nov_Solar_Access__c = double.valueOf('100');
        instLoc.Dec_Solar_Access__c = double.valueOf('100');
        instLoc.Annual_Solar_Access__c = double.valueOf('100');
        Database.Saveresult instLocDBResult = Database.Insert(instLoc,false);
        Id instLocId = instLocDBResult.getId();
        if(instLocId == null){
          System.debug('instLocDBResult Insert Errors --> ' + instLocDBResult.getErrors());
        }
        System.debug('Added Install Location with Id --> ' + instLocId);
        
        
        System_Design__c sd = new System_Design__c();
        sd.Property__c = prop.Id;
        sd.Default_CB_Panel__c = mainPanel.ID;
        sd.NRG_Balance_of_System_Derate__c = .946;
        sd.Astrum_Balance_of_System_Derate__c = .964;
        Database.Saveresult sdDBResult = Database.Insert(sd,false);
        Id sdId = sdDBResult.getId();
        if(sdId == null){
          System.debug('sdDBResult Insert Errors --> ' + sdDBResult.getErrors());
        }
        System.debug('Added System_Design__c with Id --> ' + sdId);
        
        
        System_Design_Array__c sda = new System_Design_Array__c();
        sda.CB_Panel__c = mainPanelId;
        sda.System_Design__c = sdId;
        sda.Physical_Surface__c = ps.id;//MK 2014-05-02
        sda.Survey__c = surv.id;//MK 2014-05-02
        sda.Mounting_Type__c = ps.Default_Mounting_Type__c;//MK 2014-05-02
        sda.Inverter_CEC_Efficiency__c = 1;
        sda.DC_Optimizer_Efficiency__c = 1;
        Database.Saveresult sdaDBResult = Database.Insert(sda,false);
        Id sdaId = sdaDBResult.getId();
        if(sdaId == null){
          System.debug('sdaDBResult Insert Errors --> ' + sdaDBResult.getErrors());
        }
        System.debug('Added System_Design_Array__c with Id --> ' + sdaId);

        System_Design_Product__c sdp = new System_Design_Product__c();
        sdp.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Product__c' and r.Name = 'Panel'].id;
        sdp.Description__c  = 'Sanyo 215';
        sdp.End_Clamp_Type__c = 'F End Clamp';  
        sdp.Make__c  = 'Sanyo';
        sdp.Max_Voltage__c = double.valueOf('600');
        sdp.Mid_Clamp_Type__c = 'F Mid Clamp';  
        sdp.Model__c = 'HIT Power 215N';
        sdp.Rated_Output_W__c = double.valueOf('215');  
        sdp.Unit__c = 'Count';
        Database.Saveresult sdpDBResult = Database.Insert(sdp,false);
        Id sdpId = sdpDBResult.getId();
        if(sdpId == null){
          System.debug('sdpDBResult Insert Errors --> ' + sdpDBResult.getErrors());
        }
        System.debug('Added System_Design_Product__c with Id --> ' + sdpId);
        
        System_Design_Product__c sdp1 = new System_Design_Product__c();
        sdp1.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Product__c' and r.Name = 'Inverter'].id;
        sdp1.Description__c  = 'M215-60-240-S22';
        sdp1.End_Clamp_Type__c = 'F End Clamp';  
        sdp1.Make__c  = 'Enphase';
        sdp1.Max_Voltage__c = double.valueOf('600');
        sdp1.Mid_Clamp_Type__c = 'F Mid Clamp';  
        sdp1.Model__c = 'M215-60-240-S22';
        sdp1.Rated_Output_W__c = double.valueOf('215');  
        sdp1.Unit__c = 'Count';
        Database.Saveresult sdpDBResult1 = Database.Insert(sdp1,false);
        Id sdpId1 = sdpDBResult1.getId();
        if(sdpId1 == null){
          System.debug('sdpDBResult Insert Errors --> ' + sdpDBResult1.getErrors());
        }
        System.debug('Added System_Design_Product__c with Id --> ' + sdpId1);
        
        Test.startTest();

        System_Design_Item__c sdi = new System_Design_Item__c();
        sdi.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Item__c' and r.Name = 'Panel'].id;
        sdi.System_Design_Array__c = sdaId;
        sdi.Install_Location__c = instLocId;
        sdi.System_Design_Product__c = sdp.Id;
        sdi.Quantity__c = double.valueOf('29');
        sdi.Annual_Solar_Access__c = double.valueOf('100');
        sdi.NRG_Site_Quality__c= double.valueOf('90');
        sdi.Rated_Output_kW__c = 12;
        sdi.Tilt__c = double.valueOf('3');
        sdi.Azimuth__c = double.valueOf('3');
        Database.Saveresult sdiDBResult = Database.Insert(sdi,false);
        Id sdiId = sdiDBResult.getId();
        if(sdiId == null){
          System.debug('sdiDBResult Insert Errors --> ' + sdiDBResult.getErrors());
        }
        System.debug('Added System_Design_Item__c with Id --> ' + sdiId);


        sdi = [Select System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_After_Solar__c
                    ,System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Solar_Compensation_Method__c
                    ,System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Value_of_Solar_Tariff__c
                    ,MasterSD__c,System_Design_Array__r.System_Design__r.Property__r.QAS_Latitude__c
                    ,System_Design_Array__r.System_Design__r.Property__r.QAS_Longitude__c
                    ,System_Design_Array__r.System_Design__r.Property__r.Latitude__c
                    ,System_Design_Array__r.System_Design__r.Property__r.Longitude__c
                    ,System_Design_Array__r.System_Design__r.Property__r.Confirmed_Location__Latitude__s
                    ,System_Design_Array__r.System_Design__r.Property__r.Confirmed_Location__Longitude__s
                    ,System_Design_Array__r.System_Design__r.Property__r.Snow_De_Rate_kWh_y_kW__c
                    ,Panel_Azimuth__c , Panel_Annual_Solar_Access__c,Panel_Pitch__c , CPRE_Azimuth__c
                    ,System_Design_Array__r.System_Design__r.Property__r.Property_State__c
                    ,System_Design_Array__r.System_Design__r.Property__r.Property_zip__c 
                    ,System_Design_Array__r.System_Design__r.Property__r.Utility_Company__c   
                    ,Astrum_PV_Watts_Derate__c,Astrum_PV_Watts_Optimal_Site_Quality__c
                    ,Astrum_PV_Watts_Site_Quality__c,Astrum_Balance_of_System_Derate_Text__c
                    ,Astrum_PV_Watts_Derate_Text__c,Astrum_Balance_of_System_Derate__c
                    ,Inverter_and_Transformer_Efficiency__c,Inverter_Transformer_Efficiency_Text__c
                    ,Snow_Derate_Text__c,Snow_De_Rate_kWh_y_kW__c, System_Design_Array__r.System_Design__r.Property__r.Community_Program_Offer__r.OneRoof_SiteQuality__c
                    ,NRG_Balance_of_System_Derate__c,NRG_PV_Watts_Derate_Text__c
                    ,NRG_Balance_of_System_Derate_Text__c,NRG_PV_Watts_De_Rate__c,NRG_Site_Quality__c
                    ,System_Design_Array__r.System_Design__c, Name, Sunnova_Upgrade_factor__c,Rated_Output_kW__c
                    ,Jan_Solar_Access__c,Feb_Solar_Access__c,Mar_Solar_Access__c,Apr_Solar_Access__c,May_Solar_Access__c,Jun_Solar_Access__c
                    ,Jul_Solar_Access__c,Aug_Solar_Access__c,Sep_Solar_Access__c,Oct_Solar_Access__c,Nov_Solar_Access__c,Dec_Solar_Access__c
                  from System_Design_Item__c Where id = :sdiId ];
        
        System.debug('Lat***'+sdi.System_Design_Array__r.System_Design__r.Property__r.Confirmed_Location__Latitude__s);
        System.debug('sdi*******'+sdi);
        //System_Design_Item__c item = PVWatts_ServiceClient.getSiteQualityHourly(sdi,'NRG' );

        System_Design_Item__c item = PVWatts_ServiceClient.getSiteQualityHourly(sdi,'ASTRUM' );

        List<System_Design_Item__c> items = new List<System_Design_Item__c>();
        items.add(sdi);

        PVWatts_ServiceClient.SystemDesignItem ss = new PVWatts_ServiceClient.SystemDesignItem();

        Map<System_Design_Item__c,String> itemMap = PVWatts_ServiceClient.getBulkSiteQualityHourly(items,'ASTRUM' );
        itemMap = PVWatts_ServiceClient.getBulkSiteQualityHourly(items,'NRG' );

        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];  
        System.runAs ( thisUser ) {  
             SiteQualitySettings__c configEntry = [Select Id, isHerokuProcess__c From SiteQualitySettings__c Where Name = 'SiteQuality'];  
             configEntry.isHerokuProcess__c = false;  
              configEntry.CPRE__c = true;  
             update configEntry;  
        }  

        System_Design_Item__c sdi1 = new System_Design_Item__c();
        sdi1.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Item__c' and r.Name = 'Panel'].id;
        sdi1.System_Design_Array__c = sdaId;
        sdi1.Install_Location__c = instLocId;
        sdi1.System_Design_Product__c = sdp.Id;
        sdi1.Quantity__c = double.valueOf('29');
       // sdi1.Annual_Solar_Access__c = double.valueOf('100');
        sdi1.NRG_Site_Quality__c= double.valueOf('90');
        sdi1.Rated_Output_kW__c = 12;
        sdi1.Tilt__c = double.valueOf('3');
        sdi1.Azimuth__c = double.valueOf('3');
        Database.Saveresult sdiDBResult1 = Database.Insert(sdi1,false);
        Id sdiId1 = sdiDBResult1.getId();
        if(sdiId1 == null){
          System.debug('sdiDBResult Insert Errors --> ' + sdiDBResult1.getErrors());
        }
        System.debug('Added System_Design_Item__c with Id --> ' + sdiId1);

        Test.stopTest();
        
    }    

    static testMethod void testGetNRGNJSiteQuality() {

        // setup
        Property__c property = new Property__c();
        
        property.Name = '1600 Pennsylvania Avenue NW';
        property.Property_City__c = 'Denville';
        property.Property_State__c = 'NJ';
        property.Property_County__c = 'Chester';
        property.Property_ZIP__c = '19000';
        property.latitude__c = 38.773;
        property.longitude__c = -76.887;
        property.DC_to_AC_Derate__c = 0.925;
        
        insert property;

        NJ_SCF_Region__c ns = new NJ_SCF_Region__c();
        ns.SCF_Region__c = 'ATLANTIC CITY';
        ns.Name = '19000';
        insert ns;

        NJ_Production_Estimate__c  np = new NJ_Production_Estimate__c ();
        np.Name = '35-241';
        np.Jan__c = 1445;
        np.SCF_Region__c =  'ATLANTIC CITY';
        np.Tilt__c = '35';
        np.Azimuth__c = '241';
        insert np;
        
        Double expected = 1445;           
        // execute
        Double actual = PVWatts_ServiceClient.getNRGNJSiteQuality('1','35','241','19000');      
        
        // assert    
        System.assert(expected - 1 < actual);
        System.assert(expected + 1 > actual);
        
    }    
}