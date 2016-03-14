/* FILE: CPRE_ServiceClient_Test 
 * MODIFICATION HISTORY
 * 09/22/2015 PB Astrum Main Office Location name change 
 */
@isTest(SeeAllData=true)
private class CPRE_ServiceClient_Test {

    public static testMethod void testCPREWebCall() {

        Account acct = new Account();
        acct.name='TestAcct';        
        insert acct;
        
        
        
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
       
       
        
       
        
        Property__c prop = new Property__c();
        prop.Name = '123 Main St';
        prop.Property_Owner__c = acct.Id;       
        prop.Optimal_Site_Quality_kWh_y_kW__c = double.valueOf('1250');
        prop.Property_State__c = 'MD';
        prop.Property_City__c = 'Annapolis Junction';
        prop.Property_ZIP__c = '20701';
        prop.Property_County__c = 'Howard';
        prop.Astrum_Office__c = testdata.defaultOffLocationName; //FPO Phase4 //'Annapolis Junction, MD';   
        prop.QAS_latitude__C =  '39.125919';    
        prop.QAS_longitude__C =  '-76.793228';  
         prop.Utility_Company__c =  ucId;   
        insert prop;
         Survey__c surv = new Survey__c();
        surv.Property__c = prop.Id;
        surv.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'Survey__c' and r.Name = 'Field Survey'].id;        
        insert surv;
         Utility_Service__c utilService = new Utility_Service__c();
        utilService.Amperage__c = double.valueOf('200');
        utilService.Utility_Company__c = ucId;
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
        instLoc.Annual_Solar_Access__c = double.valueOf('90');
        Database.Saveresult instLocDBResult = Database.Insert(instLoc,false);
        Id instLocId = instLocDBResult.getId();
        if(instLocId == null){
          System.debug('instLocDBResult Insert Errors --> ' + instLocDBResult.getErrors());
        }
        System.debug('Added Install Location with Id --> ' + instLocId);
        
        
        System_Design__c sd = new System_Design__c();
        sd.Property__c = prop.Id;
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
        Database.Saveresult sdaDBResult = Database.Insert(sda,false);
        Id sdaId = sdaDBResult.getId();
        if(sdaId == null){
          System.debug('sdaDBResult Insert Errors --> ' + sdaDBResult.getErrors());
        }
        System.debug('Added System_Design_Array__c with Id --> ' + sdaId);
        
        System_Design_Array__c sda2 = new System_Design_Array__c();
        sda2.CB_Panel__c = mainPanelId;
        sda2.System_Design__c = sdId;
        Database.Saveresult sda2DBResult = Database.Insert(sda2,false);
        Id sda2Id = sda2DBResult.getId();
        if(sda2Id == null){
          System.debug('sdaDBResult Insert Errors --> ' + sda2DBResult.getErrors());
        }
        System.debug('Added System_Design_Array__c with Id --> ' + sda2Id);

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
        
        SiteQualitySettings__c sq = SiteQualitySettings__c.getValues('SiteQuality');
        sq.CPRE__c = true;
        
        update sq;
        
        List<System_Design_Item__c> sysItems = new List<System_Design_Item__c>();
               
        System_Design_Item__c sdi = new System_Design_Item__c();
        sdi.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Item__c' and r.Name = 'Panel'].id;
        sdi.System_Design_Array__c = sdaId;
        sdi.Install_Location__c = instLocId;
        sdi.System_Design_Product__c = sdp.Id;
        sdi.Quantity__c = double.valueOf('29');
        sdi.Sunnova_Upgrade_Factor__c = double.valueOf('1.05');
        sdi.NRG_Site_Quality__c= double.valueOf('90');
        sdi.Rated_Output_kW__c = 12;
        sdi.Tilt__c = double.valueOf('3');
        sdi.Azimuth__c = double.valueOf('3');
        
        System_Design_Item__c sdi2 = new System_Design_Item__c();
        sdi2.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Item__c' and r.Name = 'Panel'].id;
        sdi2.System_Design_Array__c = sda2Id;
        sdi2.Install_Location__c = instLocId;
        sdi2.System_Design_Product__c = sdp.Id;
        sdi2.Quantity__c = double.valueOf('29');
        sdi2.Sunnova_Upgrade_Factor__c = null;
        sdi2.NRG_Site_Quality__c= double.valueOf('90');
        sdi2.Rated_Output_kW__c = 12;
        sdi2.Tilt__c = double.valueOf('3');
        sdi2.Azimuth__c = double.valueOf('3');
                
        Test.StartTest();
        
        Database.Saveresult sdiDBResult = Database.Insert(sdi,false);
        Id sdiId = sdiDBResult.getId();
        if(sdiId == null){
          System.debug('sdiDBResult Insert Errors --> ' + sdiDBResult.getErrors());
        }
        sysItems.add(sdi);
        System.debug('Added System_Design_Item__c with Id --> ' + sdiId);        
        sdi.Sunnova_Upgrade_Factor__c = null;
        update sdi;
        sdiDBResult = Database.Insert(sdi2,false);
        sysItems.add(sdi2);
        
        
        ApexPages.StandardController crcontroller = new ApexPages.StandardController(sdi);
        CPREReCallExtension cpre = new CPREReCallExtension(crcontroller);   
       
        PageReference escResult = cpre.reCallCPRE();     
        
        escResult = cpre.reCallCPRE();  
        
                
        Test.StopTest();
    }
    
    /*
    public static testMethod void testNRGReCall() {

        Account acct = new Account();
        acct.name='TestAcct';        
        insert acct;
        
        
        
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
       
       
        
       
        
        Property__c prop = new Property__c();
        prop.Name = '123 Main St';
        prop.Property_Owner__c = acct.Id;       
        prop.Optimal_Site_Quality_kWh_y_kW__c = double.valueOf('1250');
        prop.Property_State__c = 'MD';
        prop.Property_City__c = 'Annapolis Junction';
        prop.Property_ZIP__c = '20701';
        prop.Property_County__c = 'Howard';
        prop.Astrum_Office__c = 'Annapolis Junction, MD';   
        prop.QAS_latitude__C =  '39.125919';    
        prop.QAS_longitude__C =  '-76.793228';  
         prop.Utility_Company__c =  ucId;   
        insert prop;
         Survey__c surv = new Survey__c();
        surv.Property__c = prop.Id;
        surv.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'Survey__c' and r.Name = 'Field Survey'].id;        
        insert surv;
         Utility_Service__c utilService = new Utility_Service__c();
        utilService.Amperage__c = double.valueOf('200');
        utilService.Utility_Company__c = ucId;
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

         //RJ 2014-05-02
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
        instLoc.Annual_Solar_Access__c = double.valueOf('90');
        Database.Saveresult instLocDBResult = Database.Insert(instLoc,false);
        Id instLocId = instLocDBResult.getId();
        if(instLocId == null){
          System.debug('instLocDBResult Insert Errors --> ' + instLocDBResult.getErrors());
        }
        System.debug('Added Install Location with Id --> ' + instLocId);
      
                
        
        System_Design__c sd = new System_Design__c();
        sd.Property__c = prop.Id;
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
       
        Database.Saveresult sdaDBResult = Database.Insert(sda,false);
        Id sdaId = sdaDBResult.getId();
        if(sdaId == null){
          System.debug('sdaDBResult Insert Errors --> ' + sdaDBResult.getErrors());
        }
        System.debug('Added System_Design_Array__c with Id --> ' + sdaId);
        
        System_Design_Array__c sda2 = new System_Design_Array__c();
        sda2.CB_Panel__c = mainPanelId;
        sda2.System_Design__c = sdId;
        Database.Saveresult sda2DBResult = Database.Insert(sda2,false);
        Id sda2Id = sda2DBResult.getId();
        if(sda2Id == null){
          System.debug('sdaDBResult Insert Errors --> ' + sda2DBResult.getErrors());
        }
        System.debug('Added System_Design_Array__c with Id --> ' + sda2Id);

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
        
        SiteQualitySettings__c sq = SiteQualitySettings__c.getValues('SiteQuality');
        sq.CPRE__c = true;
        
        update sq;
        
        List<System_Design_Item__c> sysItems = new List<System_Design_Item__c>();
               
        System_Design_Item__c sdi = new System_Design_Item__c();
        sdi.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Item__c' and r.Name = 'Panel'].id;
        sdi.System_Design_Array__c = sdaId;
        sdi.Install_Location__c = instLocId;
        sdi.System_Design_Product__c = sdp.Id;
        sdi.Quantity__c = double.valueOf('29');
        sdi.Sunnova_Upgrade_Factor__c = double.valueOf('1.05');
        sdi.NRG_Site_Quality__c= double.valueOf('90');
        sdi.Rated_Output_kW__c = 12;
        sdi.Tilt__c = double.valueOf('3');
        sdi.Azimuth__c = double.valueOf('3');
        
        System_Design_Item__c sdi2 = new System_Design_Item__c();
        sdi2.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Item__c' and r.Name = 'Panel'].id;
        sdi2.System_Design_Array__c = sda2Id;
        sdi2.Install_Location__c = instLocId;
        sdi2.System_Design_Product__c = sdp.Id;
        sdi2.Quantity__c = double.valueOf('29');
        sdi2.Sunnova_Upgrade_Factor__c = null;
        sdi2.NRG_Site_Quality__c= double.valueOf('90');
        sdi2.Rated_Output_kW__c = 12;
        sdi2.Tilt__c = double.valueOf('3');
        sdi2.Azimuth__c = double.valueOf('3');
                
        Test.StartTest(); 
        
        Database.Saveresult sdiDBResult = Database.Insert(sdi,false);
        Id sdiId = sdiDBResult.getId();
        if(sdiId == null){
          System.debug('sdiDBResult Insert Errors --> ' + sdiDBResult.getErrors());
        }
        sysItems.add(sdi);
        System.debug('Added System_Design_Item__c with Id --> ' + sdiId);        
        
        sdiDBResult = Database.Insert(sdi2,false);
        sysItems.add(sdi2);
        
        
        ApexPages.StandardController crcontroller = new ApexPages.StandardController(sdi);
               
        NRGReCallExtension nrg= new NRGReCallExtension(crcontroller);   
       
        PageReference nrgResult= nrg.reCallNRG();     
        
        nrgResult= nrg.reCallNRG();     
        
       
        
        Test.StopTest();
    }
    */
    public static testMethod void testBatchNRGReCall() {

        Account acct = new Account();
        acct.name='TestAcct';        
        insert acct;
        
        
        
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
       
       
        
       
        
        Property__c prop = new Property__c();
        prop.Name = '123 Main St';
        prop.Property_Owner__c = acct.Id;       
        prop.Optimal_Site_Quality_kWh_y_kW__c = double.valueOf('1250');
        prop.Property_State__c = 'MD';
        prop.Property_City__c = 'Annapolis Junction';
        prop.Property_ZIP__c = '20701';
        prop.Property_County__c = 'Howard';
        prop.Astrum_Office__c = testdata.defaultOffLocationName; //FPO Phase4 //'Annapolis Junction, MD';   
        prop.QAS_latitude__C =  '39.125919';    
        prop.QAS_longitude__C =  '-76.793228';  
         prop.Utility_Company__c =  ucId;   
        insert prop;
         Survey__c surv = new Survey__c();
        surv.Property__c = prop.Id;
        surv.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'Survey__c' and r.Name = 'Field Survey'].id;        
        insert surv;
         Utility_Service__c utilService = new Utility_Service__c();
        utilService.Amperage__c = double.valueOf('200');
        utilService.Utility_Company__c = ucId;
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
      
        //RJ 2014-05-02
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
        instLoc.Annual_Solar_Access__c = double.valueOf('90');
        Database.Saveresult instLocDBResult = Database.Insert(instLoc,false);
        Id instLocId = instLocDBResult.getId();
        if(instLocId == null){
          System.debug('instLocDBResult Insert Errors --> ' + instLocDBResult.getErrors());
        }
        System.debug('Added Install Location with Id --> ' + instLocId);
        
        
        System_Design__c sd = new System_Design__c();
        sd.Property__c = prop.Id;
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
        Database.Saveresult sdaDBResult = Database.Insert(sda,false);
        Id sdaId = sdaDBResult.getId();
        if(sdaId == null){
          System.debug('sdaDBResult Insert Errors --> ' + sdaDBResult.getErrors());
        }
        System.debug('Added System_Design_Array__c with Id --> ' + sdaId);
        
        System_Design_Array__c sda2 = new System_Design_Array__c();
        sda2.CB_Panel__c = mainPanelId;
        sda2.System_Design__c = sdId;
        Database.Saveresult sda2DBResult = Database.Insert(sda2,false);
        Id sda2Id = sda2DBResult.getId();
        if(sda2Id == null){
          System.debug('sdaDBResult Insert Errors --> ' + sda2DBResult.getErrors());
        }
        System.debug('Added System_Design_Array__c with Id --> ' + sda2Id);

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
        
        SiteQualitySettings__c sq = SiteQualitySettings__c.getValues('SiteQuality');
        sq.CPRE__c = true;
        
        update sq;
        
        List<System_Design_Item__c> sysItems = new List<System_Design_Item__c>();
               
        System_Design_Item__c sdi = new System_Design_Item__c();
        sdi.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Item__c' and r.Name = 'Panel'].id;
        sdi.System_Design_Array__c = sdaId;
        sdi.Install_Location__c = instLocId;
        sdi.System_Design_Product__c = sdp.Id;
        sdi.Quantity__c = double.valueOf('29');
        sdi.Sunnova_Upgrade_Factor__c = double.valueOf('1.05');
        sdi.NRG_Site_Quality__c= double.valueOf('90');
        sdi.Rated_Output_kW__c = 12;
        sdi.Tilt__c = double.valueOf('3');
        sdi.Azimuth__c = double.valueOf('3');
        
        System_Design_Item__c sdi2 = new System_Design_Item__c();
        sdi2.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Item__c' and r.Name = 'Panel'].id;
        sdi2.System_Design_Array__c = sda2Id;
        sdi2.Install_Location__c = instLocId;
        sdi2.System_Design_Product__c = sdp.Id;
        sdi2.Quantity__c = double.valueOf('29');
        sdi2.Sunnova_Upgrade_Factor__c = null;
        sdi2.NRG_Site_Quality__c= double.valueOf('90');
        sdi2.Rated_Output_kW__c = 12;
        sdi2.Tilt__c = double.valueOf('3');
        sdi2.Azimuth__c = double.valueOf('3');
                
        
        
        //Database.Saveresult sdiDBResult = Database.Insert(sdi,false);
        //Id sdiId = sdiDBResult.getId();
        //if(sdiId == null){
          //System.debug('sdiDBResult Insert Errors --> ' + sdiDBResult.getErrors());
        //}
        sysItems.add(sdi);
        //System.debug('Added System_Design_Item__c with Id --> ' + sdiId);        
        
        //sdiDBResult = Database.Insert(sdi2,false);
        sysItems.add(sdi2);
        insert sysItems;
        
              
        sysItems = [Select Id,System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_After_Solar__c
                      ,System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Solar_Compensation_Method__c
                      ,System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Value_of_Solar_Tariff__c
                      ,Panel_Annual_Solar_Access__c,NRG_Site_Quality__c
                      ,System_Design_Array__r.System_Design__r.Property__r.QAS_Latitude__c
                      ,System_Design_Array__r.System_Design__r.Property__r.QAS_Longitude__c
                       ,System_Design_Array__r.System_Design__r.Property__r.Latitude__c
                      ,System_Design_Array__r.System_Design__r.Property__r.Longitude__c
                      ,Panel_Azimuth__c,Panel_Pitch__c
                      ,System_Design_Array__r.System_Design__r.Property__r.Property_State__c
                      ,System_Design_Array__r.System_Design__r.Property__r.Property_zip__c 
                      ,System_Design_Array__r.System_Design__r.Property__r.Utility_Company__c                      
                      ,Astrum_PV_Watts_Derate__c,Astrum_PV_Watts_Optimal_Site_Quality__c,Astrum_PV_Watts_Site_Quality__c
                      ,Astrum_Balance_of_System_Derate_Text__c,Astrum_PV_Watts_Derate_Text__c
                      ,Astrum_Balance_of_System_Derate__c,Inverter_and_Transformer_Efficiency__c
                      ,Inverter_Transformer_Efficiency_Text__c,Snow_Derate_Text__c,Snow_De_Rate_kWh_y_kW__c
                      ,Jan_Solar_Access__c,Feb_Solar_Access__c,Mar_Solar_Access__c,Apr_Solar_Access__c,May_Solar_Access__c,Jun_Solar_Access__c
                      ,Jul_Solar_Access__c,Aug_Solar_Access__c,Sep_Solar_Access__c,Oct_Solar_Access__c,Nov_Solar_Access__c,Dec_Solar_Access__c
                      ,System_Design_Array__r.System_Design__r.Property__r.Confirmed_Location__Latitude__s
                      ,System_Design_Array__r.System_Design__r.Property__r.Confirmed_Location__Longitude__s
                      ,Name,System_Design_Array__r.System_Design__r.Name,Sunnova_Site_Quality__c            
                     ,System_Design_Array__r.System_Design__r.Property__r.Snow_De_Rate_kWh_y_kW__c
                     ,CPRE_Azimuth__c,Sunnova_Upgrade_factor__c
             from System_Design_Item__c Where Id in :sysItems ];
        

        List<Id> sds = new List<Id>();
        sds.add(sd.Id);
        Test.StartTest();

        SystemDesignSiteQualityBatch  batch = new SystemDesignSiteQualityBatch ();
        batch.Query = 'Select Id from System_Design_Item__C limit 10 ';
        Database.QueryLocator ql = batch.start(null);
        batch.isCPRE = true;
        batch.isNRG = false;
        batch.isAstrum = false;
        batch.execute(null, sysItems );
        batch.isCPRE = false;
        batch.isAstrum = false;
        batch.isNRG = true;
        batch.execute(null, sysItems );
        batch.isCPRE = false;
        batch.isNRG = false;
        batch.isAstrum = true;
        batch.execute(null, sysItems );
        batch.isCPRE = true;
        batch.isNRG = true; 
        batch.isAstrum = true;       
        batch.sysDesigns = sds;
        batch.execute(null, sysItems );       
        batch.finish(null);
        //batch.batchErrors = 'Test Errs';
        //batch.finish(null);
        
        Test.StopTest();
    }
    
    
    
}