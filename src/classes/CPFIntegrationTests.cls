// Commented by RJ 05/5/2015
@isTest(SeeAllData=true)
private class CPFIntegrationTests {
	/*
	static testMethod void RequestCPFQuoteTest()
    {
        Account acct = new Account();
        acct.name='TestAcct';        
        insert acct;
        
        Contact ct = new Contact();
        ct.AccountId = acct.Id;
        ct.FirstName = 'TestC';
        ct.LastName = 'TestL';
        insert ct;        
       
        
        Utility_Company__c uc = new Utility_Company__c();
        uc.Name = 'BG&E';
        uc.CPF_Rate_Code_Id__c = 'c56ca47c-6b4a-102e-8d27-00e081583152';
        uc.States_Serviced__c = 'MD';
        Database.Saveresult ucDBResult = Database.Insert(uc,false);
        Id ucId = ucDBResult.getId();
        if(ucId == null){
          System.debug('ucDBResult Insert Errors --> ' + ucDBResult.getErrors());
        }
        System.debug('Added Utility Company with Id --> ' + ucId);

        Property__c prop = new Property__c();
        prop.Name = '123 Main St';
        prop.Property_Owner__c = acct.Id;       
        prop.Optimal_Site_Quality_kWh_y_kW__c = double.valueOf('1250');
        prop.Property_State__c = 'MD';
        prop.Property_City__c = 'Annapolis Junction';
        prop.Property_ZIP__c = '20701';
        prop.Property_County__c = 'Howard';
        prop.Astrum_Office__c = 'Annapolis Junction, MD';

        insert prop;

        prop.Utility_Company__c = ucId;
        update prop;
       
        Survey__c surv = new Survey__c();
        surv.Property__c = prop.Id;
        surv.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'Survey__c' and r.Name = 'Field Survey'].id;        
        insert surv;
        
        Utility_Service__c utilService = new Utility_Service__c();
        utilService.Amperage__c = double.valueOf('200');
        utilService.Utility_Company__c = ucId;
        utilService.Property__c = prop.Id;
        utilService.Service_Account_Number__c = 'abc123';  
        utilService.Monthly_Electric_Bill_Jan__c = 200;
        utilService.Monthly_Electric_Bill_Feb__c = 200;
        utilService.Monthly_Electric_Bill_Mar__c = 200;
        utilService.Monthly_Electric_Bill_Apr__c = 200;
        utilService.Monthly_Electric_Bill_May__c = 200;
        utilService.Monthly_Electric_Bill_Jun__c = 200;
        utilService.Monthly_Electric_Bill_Jul__c = 200;
        utilService.Monthly_Electric_Bill_Aug__c = 200;
        utilService.Monthly_Electric_Bill_Sep__c = 200;
        utilService.Monthly_Electric_Bill_Oct__c = 200;
        utilService.Monthly_Electric_Bill_Nov__c = 200;
        utilService.Monthly_Electric_Bill_Dec__c = 200;      
        Database.Saveresult utilServiceDBResult = Database.Insert(utilService,false);
        Id utilServiceId = utilServiceDBResult.getId();
        if(utilServiceId == null){
          System.debug('utilServiceDBResult Insert Errors --> ' + utilServiceDBResult.getErrors());
        }        
        System.debug('Added Utility_Service__c with Id --> ' + utilServiceId);

        Utility_Territory_Rate_Codes__c utrc = new Utility_Territory_Rate_Codes__c();
        utrc.Territory__c = '1';
        utrc.CPF_Rate_Code_Id__c = 'c56ca47c-6b4a-102e-8d27-00e081583152';
        utrc.Utility_Company__c = ucId;
        insert utrc;

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
        instLoc.Annual_Solar_Access__c = double.valueOf('90');
        instLoc.TSRF__c = double.valueOf('90');
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
        
        System_Design_Item__c sdi = new System_Design_Item__c();
        sdi.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Item__c' and r.Name = 'Panel'].id;
        sdi.System_Design_Array__c = sdaId;
        sdi.Install_Location__c = instLocId;
        sdi.System_Design_Product__c = sdp.Id;
        sdi.Quantity__c = double.valueOf('29');
        sdi.Annual_Solar_Access__c = double.valueOf('90');
        Database.Saveresult sdiDBResult = Database.Insert(sdi,false);
        Id sdiId = sdiDBResult.getId();
        if(sdiId == null){
          System.debug('sdiDBResult Insert Errors --> ' + sdiDBResult.getErrors());
        }
        System.debug('Added System_Design_Item__c with Id --> ' + sdiId);

        System_Design_Item__c sdi1 = new System_Design_Item__c();
        sdi1.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Item__c' and r.Name = 'Inverter'].id;
        sdi1.System_Design_Array__c = sdaId;
        sdi1.Install_Location__c = instLocId;
        sdi1.System_Design_Product__c = sdp1.Id;
        sdi1.Quantity__c = double.valueOf('29');
        sdi1.Annual_Solar_Access__c = double.valueOf('90');
        Database.Saveresult sdiDBResult1 = Database.Insert(sdi1,false);
        Id sdi1Id = sdiDBResult1.getId();
        if(sdi1Id == null){
          System.debug('sdiDBResult Insert Errors --> ' + sdiDBResult1.getErrors());
        }
        System.debug('Added System_Design_Item__c with Id --> ' + sdiId);
                        
        sd.Calculated_System_Price__c = decimal.valueOf('100000.25');
        update(sd);

        CPF_Equipment_Mapping__C comp = new  CPF_Equipment_Mapping__C();        
        comp.CPF_id__c = 'a1pA0000000EqGJIA0';            
        comp.Model_Number__c = 'M215';   
        Comp.System_Design_Product__c = sdp1.Id;
        comp.Type__c = 'Inverter';
        insert comp;
        
               
        CPF_Equipment_Mapping__C comp2 = new  CPF_Equipment_Mapping__C();        
        comp2.CPF_id__c = 'a1pA0000000EqGJIA0';            
        comp2.Model_Number__c = 'CD';   
        Comp2.System_Design_Product__c = sdp.Id;
        comp2.Type__c = 'Module';
        insert comp2;

       

        Test.startTest();
        
        System_Design_Quote__c sdq = new System_Design_Quote__c();
        sdq.System_Design__c = sdId;
        sdq.Utility_Territory__c = '1';
        Database.Saveresult sdqDBResult = Database.Insert(sdq,false);
        Id sdqId = sdqDBResult.getId();
        if(sdqId == null){
          System.debug('sdqDBResult Insert Errors --> ' + sdqDBResult.getErrors());
        }

        /*
        utilService.Estimated_Average_Monthly_Bill__c = 800;
        update utilService;

        System_Design_Quote__c sdq11 = new System_Design_Quote__c();
        sdq11.System_Design__c = sdId;
        sdq11.Utility_Territory__c = '1';
        Database.Saveresult sdq11DBResult = Database.Insert(sdq11,false);
        Id sdq11Id = sdq11DBResult.getId();
        if(sdq11Id == null){
          System.debug('sdqDBResult Insert Errors --> ' + sdq11DBResult.getErrors());
        }

        utilService.Monthly_Electric_Bill_Jan__c = 200;
        utilService.Monthly_Electric_Bill_Feb__c = 200;
        utilService.Monthly_Electric_Bill_Mar__c = 200;
        utilService.Monthly_Electric_Bill_Apr__c = 200;
        utilService.Monthly_Electric_Bill_May__c = 200;
        utilService.Monthly_Electric_Bill_Jun__c = 200;
        utilService.Monthly_Electric_Bill_Jul__c = 200;
        utilService.Monthly_Electric_Bill_Aug__c = 200;
        utilService.Monthly_Electric_Bill_Sep__c = 200;
        utilService.Monthly_Electric_Bill_Oct__c = 200;
        utilService.Monthly_Electric_Bill_Nov__c = 200;
        utilService.Monthly_Electric_Bill_Dec__c = 200;
        
        update utilService;

        System_Design_Quote__c sdq2 = new System_Design_Quote__c();
        sdq2.System_Design__c = sdId;
        sdq2.Utility_Territory__c = '1';       
        Database.Saveresult sdqDBResult2 = Database.Insert(sdq2,false);
        Id sdq2Id = sdqDBResult2.getId();
        if(sdq2Id == null){
          System.debug('sdqDBResult Insert Errors --> ' + sdqDBResult2.getErrors());
        }

        utilService.Monthly_Electric_Consumption_KWH_Jan__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Feb__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Mar__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Apr__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_May__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Jun__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Jul__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Aug__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Sep__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Oct__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Nov__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Dec__c = 200;
        
        update utilService;

        System_Design_Quote__c sdq3 = new System_Design_Quote__c();
        sdq3.System_Design__c = sdId;
        sdq3.Utility_Territory__c = '1';       
        Database.Saveresult sdqDBResult3 = Database.Insert(sdq3,false);
        Id sdq3Id = sdqDBResult3.getId();
        if(sdq3Id == null){
          System.debug('sdqDBResult Insert Errors --> ' + sdqDBResult3.getErrors());
        }

        
        utilService.Monthly_Electric_Consumption_KWH_Jan__c = null;
        utilService.Monthly_Electric_Bill_Jan__c = null;
        utilService.Annual_Electricity_Consumption_kWh__c = 800;
        utilService.Estimated_Average_Monthly_Bill__c = null;
        update utilService;

        System_Design_Quote__c sdq4 = new System_Design_Quote__c();
        sdq4.System_Design__c = sdId;
        sdq4.Utility_Territory__c = '1';       
        Database.Saveresult sdqDBResult4 = Database.Insert(sdq4,false);
        Id sdq4Id = sdqDBResult4.getId();
        if(sdq4Id == null){
          System.debug('sdqDBResult Insert Errors --> ' + sdqDBResult4.getErrors());
        }
        
        Test.stopTest();   
        
    
    }   

    static testMethod void RequestCPFQuote2Test()
    {
        Account acct = new Account();
        acct.name='TestAcct';        
        insert acct;
        
        Contact ct = new Contact();
        ct.AccountId = acct.Id;
        ct.FirstName = 'TestC';
        ct.LastName = 'TestL';
        insert ct;        

        Contact ct1 = new Contact();
        ct1.AccountId = acct.Id;
        ct1.FirstName = 'TestC1';
        ct1.LastName = 'TestL1';
        insert ct1;        
       
        
        Utility_Company__c uc = new Utility_Company__c();
        uc.Name = 'BG&E';
        uc.CPF_Rate_Code_Id__c = 'c56ca47c-6b4a-102e-8d27-00e081583152';
        uc.States_Serviced__c = 'MD';
        Database.Saveresult ucDBResult = Database.Insert(uc,false);
        Id ucId = ucDBResult.getId();
        if(ucId == null){
          System.debug('ucDBResult Insert Errors --> ' + ucDBResult.getErrors());
        }
        System.debug('Added Utility Company with Id --> ' + ucId);

        Property__c prop = new Property__c();
        prop.Name = '123 Main St';
        prop.Property_Owner__c = acct.Id;       
        prop.Optimal_Site_Quality_kWh_y_kW__c = double.valueOf('1250');
        prop.Property_State__c = 'MD';
        prop.Property_City__c = 'Annapolis Junction';
        prop.Property_ZIP__c = '20701';
        prop.Property_County__c = 'Howard';
        prop.Astrum_Office__c = 'Annapolis Junction, MD';

        insert prop;

        prop.Utility_Company__c = ucId;
        update prop;
       
        Survey__c surv = new Survey__c();
        surv.Property__c = prop.Id;
        surv.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'Survey__c' and r.Name = 'Field Survey'].id;        
        insert surv;
        
        Utility_Service__c utilService = new Utility_Service__c();
        utilService.Amperage__c = double.valueOf('200');
        utilService.Utility_Company__c = ucId;
        utilService.Property__c = prop.Id;
        utilService.Service_Account_Number__c = 'abc123';  
        utilService.Monthly_Electric_Bill_Jan__c = 200;
        utilService.Monthly_Electric_Bill_Feb__c = 200;
        utilService.Monthly_Electric_Bill_Mar__c = 200;
        utilService.Monthly_Electric_Bill_Apr__c = 200;
        utilService.Monthly_Electric_Bill_May__c = 200;
        utilService.Monthly_Electric_Bill_Jun__c = 200;
        utilService.Monthly_Electric_Bill_Jul__c = 200;
        utilService.Monthly_Electric_Bill_Aug__c = 200;
        utilService.Monthly_Electric_Bill_Sep__c = 200;
        utilService.Monthly_Electric_Bill_Oct__c = 200;
        utilService.Monthly_Electric_Bill_Nov__c = 200;
        utilService.Monthly_Electric_Bill_Dec__c = 200;      
         utilService.Monthly_Electric_Consumption_KWH_Jan__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Feb__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Mar__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Apr__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_May__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Jun__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Jul__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Aug__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Sep__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Oct__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Nov__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Dec__c = 200;
        Database.Saveresult utilServiceDBResult = Database.Insert(utilService,false);
        Id utilServiceId = utilServiceDBResult.getId();
        if(utilServiceId == null){
          System.debug('utilServiceDBResult Insert Errors --> ' + utilServiceDBResult.getErrors());
        }        
        System.debug('Added Utility_Service__c with Id --> ' + utilServiceId);

        Utility_Territory_Rate_Codes__c utrc = new Utility_Territory_Rate_Codes__c();
        utrc.Territory__c = '1';
        utrc.CPF_Rate_Code_Id__c = 'c56ca47c-6b4a-102e-8d27-00e081583152';
        utrc.Utility_Company__c = ucId;
        insert utrc;

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
        instLoc.Annual_Solar_Access__c = double.valueOf('90');
        instLoc.TSRF__c = double.valueOf('90');
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
        
        System_Design_Item__c sdi = new System_Design_Item__c();
        sdi.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Item__c' and r.Name = 'Panel'].id;
        sdi.System_Design_Array__c = sdaId;
        sdi.Install_Location__c = instLocId;
        sdi.System_Design_Product__c = sdp.Id;
        sdi.Quantity__c = double.valueOf('29');
        sdi.Annual_Solar_Access__c = double.valueOf('90');
        Database.Saveresult sdiDBResult = Database.Insert(sdi,false);
        Id sdiId = sdiDBResult.getId();
        if(sdiId == null){
          System.debug('sdiDBResult Insert Errors --> ' + sdiDBResult.getErrors());
        }
        System.debug('Added System_Design_Item__c with Id --> ' + sdiId);

        System_Design_Item__c sdi1 = new System_Design_Item__c();
        sdi1.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Item__c' and r.Name = 'Inverter'].id;
        sdi1.System_Design_Array__c = sdaId;
        sdi1.Install_Location__c = instLocId;
        sdi1.System_Design_Product__c = sdp1.Id;
        sdi1.Quantity__c = double.valueOf('29');
        sdi1.Annual_Solar_Access__c = double.valueOf('90');
        Database.Saveresult sdiDBResult1 = Database.Insert(sdi1,false);
        Id sdi1Id = sdiDBResult1.getId();
        if(sdi1Id == null){
          System.debug('sdiDBResult Insert Errors --> ' + sdiDBResult1.getErrors());
        }
        System.debug('Added System_Design_Item__c with Id --> ' + sdiId);
                        
        sd.Calculated_System_Price__c = decimal.valueOf('100000.25');
        update(sd);

        CPF_Equipment_Mapping__C comp = new  CPF_Equipment_Mapping__C();        
        comp.CPF_id__c = 'a1pA0000000EqGJIA0';            
        comp.Model_Number__c = 'M215';   
        Comp.System_Design_Product__c = sdp1.Id;
        comp.Type__c = 'Inverter';
        insert comp;
        
               
        CPF_Equipment_Mapping__C comp2 = new  CPF_Equipment_Mapping__C();        
        comp2.CPF_id__c = 'a1pA0000000EqGJIA0';            
        comp2.Model_Number__c = 'CD';   
        Comp2.System_Design_Product__c = sdp.Id;
        comp2.Type__c = 'Module';
        insert comp2;

       

        Test.startTest();
        
        System_Design_Quote__c sdq = new System_Design_Quote__c();
        sdq.System_Design__c = sdId;
        sdq.Utility_Territory__c = '1';
        Database.Saveresult sdqDBResult = Database.Insert(sdq,false);
        Id sdqId = sdqDBResult.getId();
        if(sdqId == null){
          System.debug('sdqDBResult Insert Errors --> ' + sdqDBResult.getErrors());
        }

        
        utilService.Estimated_Average_Monthly_Bill__c = 800;
        update utilService;

        System_Design_Quote__c sdq11 = new System_Design_Quote__c();
        sdq11.System_Design__c = sdId;
        sdq11.Utility_Territory__c = '1';
        Database.Saveresult sdq11DBResult = Database.Insert(sdq11,false);
        Id sdq11Id = sdq11DBResult.getId();
        if(sdq11Id == null){
          System.debug('sdqDBResult Insert Errors --> ' + sdq11DBResult.getErrors());
        }

        utilService.Monthly_Electric_Bill_Jan__c = 200;
        utilService.Monthly_Electric_Bill_Feb__c = 200;
        utilService.Monthly_Electric_Bill_Mar__c = 200;
        utilService.Monthly_Electric_Bill_Apr__c = 200;
        utilService.Monthly_Electric_Bill_May__c = 200;
        utilService.Monthly_Electric_Bill_Jun__c = 200;
        utilService.Monthly_Electric_Bill_Jul__c = 200;
        utilService.Monthly_Electric_Bill_Aug__c = 200;
        utilService.Monthly_Electric_Bill_Sep__c = 200;
        utilService.Monthly_Electric_Bill_Oct__c = 200;
        utilService.Monthly_Electric_Bill_Nov__c = 200;
        utilService.Monthly_Electric_Bill_Dec__c = 200;
        
        update utilService;

        System_Design_Quote__c sdq2 = new System_Design_Quote__c();
        sdq2.System_Design__c = sdId;
        sdq2.Utility_Territory__c = '1';       
        Database.Saveresult sdqDBResult2 = Database.Insert(sdq2,false);
        Id sdq2Id = sdqDBResult2.getId();
        if(sdq2Id == null){
          System.debug('sdqDBResult Insert Errors --> ' + sdqDBResult2.getErrors());
        }

        utilService.Monthly_Electric_Consumption_KWH_Jan__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Feb__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Mar__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Apr__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_May__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Jun__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Jul__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Aug__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Sep__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Oct__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Nov__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Dec__c = 200;
        
        update utilService;

        System_Design_Quote__c sdq3 = new System_Design_Quote__c();
        sdq3.System_Design__c = sdId;
        sdq3.Utility_Territory__c = '1';       
        Database.Saveresult sdqDBResult3 = Database.Insert(sdq3,false);
        Id sdq3Id = sdqDBResult3.getId();
        if(sdq3Id == null){
          System.debug('sdqDBResult Insert Errors --> ' + sdqDBResult3.getErrors());
        }

        
        utilService.Monthly_Electric_Consumption_KWH_Jan__c = null;
        utilService.Monthly_Electric_Bill_Jan__c = null;
        utilService.Annual_Electricity_Consumption_kWh__c = 800;
        utilService.Estimated_Average_Monthly_Bill__c = null;
        update utilService;

        System_Design_Quote__c sdq4 = new System_Design_Quote__c();
        sdq4.System_Design__c = sdId;
        sdq4.Utility_Territory__c = '1';       
        Database.Saveresult sdqDBResult4 = Database.Insert(sdq4,false);
        Id sdq4Id = sdqDBResult4.getId();
        if(sdq4Id == null){
          System.debug('sdqDBResult Insert Errors --> ' + sdqDBResult4.getErrors());
        }
        

        //CPFIntegrationProcessor ci = new CPFIntegrationProcessor();        
        String res = '<Response><Status>Error</Status><Messages><Error>The Job was not successfully created</Error><Error>The Job was not successfully created</Error></Messages></Response>';
        sdq = CPFIntegrationProcessor.parseJobResponse(res,sdq,false);
        sdq = CPFIntegrationProcessor.parseJobResponse(res,sdq,true);
        res = '<Response><Status>Error</Status><Errors><Error><Message>The Job was not successfully created</Message></Error><Error><Message>The Job was not successfully created</Message></Error></Errors></Response>';
        sdq = CPFIntegrationProcessor.parseGenerateDocumentResponse(res,sdq,false);
        res = '<Response><Status>Error</Status><Message>The Job was not successfully created</Message></Response>';
        sdq = CPFIntegrationProcessor.parseJobResponse(res,sdq,false);
        sdq = CPFIntegrationProcessor.parseJobResponse(res,sdq,true);
        sdq = CPFIntegrationProcessor.parseGenerateDocumentResponse(res,sdq,false);
        sdq = CPFIntegrationProcessor.parseGenerateDocumentResponse(res,sdq,true);
        Test.stopTest();   

        
        
    
    }   

    static testMethod void RequestElligibilityTest()
    {
        Account acct = new Account();
        acct.name='TestAcct';        
        insert acct;
        
        Contact ct = new Contact();
        ct.AccountId = acct.Id;
        ct.FirstName = 'TestC';
        ct.LastName = 'TestL';
        insert ct;        
       
        
        Utility_Company__c uc = new Utility_Company__c();
        uc.Name = 'BG&E';
        uc.CPF_Rate_Code_Id__c = 'c56ca47c-6b4a-102e-8d27-00e081583152';
        uc.States_Serviced__c = 'MD';
        Database.Saveresult ucDBResult = Database.Insert(uc,false);
        Id ucId = ucDBResult.getId();
        if(ucId == null){
          System.debug('ucDBResult Insert Errors --> ' + ucDBResult.getErrors());
        }
        System.debug('Added Utility Company with Id --> ' + ucId);

        Property__c prop = new Property__c();
        prop.Name = '123 Main St';
        prop.Property_Owner__c = acct.Id;       
        prop.Optimal_Site_Quality_kWh_y_kW__c = double.valueOf('1250');
        prop.Property_State__c = 'MD';
        prop.Property_City__c = 'Annapolis Junction';
        prop.Property_ZIP__c = '20701';
        prop.Property_County__c = 'Howard';
        prop.Astrum_Office__c = 'Annapolis Junction, MD';

        insert prop;

        prop.Utility_Company__c = ucId;
        update prop;

        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            AccountId = acct.Id,
            StageName = 'Test',
            CloseDate = System.today().addDays(-8),
            Financing_Type__c = 'Purchase',
            Financing_Option__c = 'No Financing',
            Leasing_Option__c = null,
            Property__c = prop.Id
        );
        insert opp;
       
        Survey__c surv = new Survey__c();
        surv.Property__c = prop.Id;
        surv.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'Survey__c' and r.Name = 'Field Survey'].id;        
        insert surv;
        
        Utility_Service__c utilService = new Utility_Service__c();
        utilService.Amperage__c = double.valueOf('200');
        utilService.Utility_Company__c = ucId;
        utilService.Property__c = prop.Id;
        utilService.Service_Account_Number__c = 'abc123';
        utilService.Monthly_Electric_Consumption_KWH_Jan__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Feb__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Mar__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Apr__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_May__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Jun__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Jul__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Aug__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Sep__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Oct__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Nov__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Dec__c = 200;
        Database.Saveresult utilServiceDBResult = Database.Insert(utilService,false);
        Id utilServiceId = utilServiceDBResult.getId();
        if(utilServiceId == null){
          System.debug('utilServiceDBResult Insert Errors --> ' + utilServiceDBResult.getErrors());
        }        
        System.debug('Added Utility_Service__c with Id --> ' + utilServiceId);

        Utility_Territory_Rate_Codes__c utrc = new Utility_Territory_Rate_Codes__c();
        utrc.Territory__c = '1';
        utrc.CPF_Rate_Code_Id__c = 'c56ca47c-6b4a-102e-8d27-00e081583152';
        utrc.Utility_Company__c = ucId;
        insert utrc;

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
        instLoc.Annual_Solar_Access__c = double.valueOf('90');
        instLoc.TSRF__c = double.valueOf('90');
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
        
        System_Design_Item__c sdi = new System_Design_Item__c();
        sdi.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Item__c' and r.Name = 'Panel'].id;
        sdi.System_Design_Array__c = sdaId;
        sdi.Install_Location__c = instLocId;
        sdi.System_Design_Product__c = sdp.Id;
        sdi.Quantity__c = double.valueOf('29');
        sdi.Annual_Solar_Access__c = double.valueOf('90');
        Database.Saveresult sdiDBResult = Database.Insert(sdi,false);
        Id sdiId = sdiDBResult.getId();
        if(sdiId == null){
          System.debug('sdiDBResult Insert Errors --> ' + sdiDBResult.getErrors());
        }
        System.debug('Added System_Design_Item__c with Id --> ' + sdiId);

        System_Design_Item__c sdi1 = new System_Design_Item__c();
        sdi1.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Item__c' and r.Name = 'Inverter'].id;
        sdi1.System_Design_Array__c = sdaId;
        sdi1.Install_Location__c = instLocId;
        sdi1.System_Design_Product__c = sdp1.Id;
        sdi1.Quantity__c = double.valueOf('29');
        sdi1.Annual_Solar_Access__c = double.valueOf('90');
        Database.Saveresult sdiDBResult1 = Database.Insert(sdi1,false);
        Id sdi1Id = sdiDBResult1.getId();
        if(sdi1Id == null){
          System.debug('sdiDBResult Insert Errors --> ' + sdiDBResult1.getErrors());
        }
        System.debug('Added System_Design_Item__c with Id --> ' + sdiId);
                        
        sd.Calculated_System_Price__c = decimal.valueOf('100000.25');
        update(sd);

        CPF_Equipment_Mapping__C comp = new  CPF_Equipment_Mapping__C();        
        comp.CPF_id__c = 'a1pA0000000EqGJIA0';            
        comp.Model_Number__c = 'M215';   
        Comp.System_Design_Product__c = sdp1.Id;
        comp.Type__c = 'Inverter';
        insert comp;
        
               
        CPF_Equipment_Mapping__C comp2 = new  CPF_Equipment_Mapping__C();        
        comp2.CPF_id__c = 'a1pA0000000EqGJIA0';            
        comp2.Model_Number__c = 'CD';   
        Comp2.System_Design_Product__c = sdp.Id;
        comp2.Type__c = 'Module';
        insert comp2;

       

        Test.startTest();
        
        System_Design_Quote__c sdq = new System_Design_Quote__c();
        sdq.System_Design__c = sdId;
        sdq.Utility_Territory__c = '1';  
        sdq.CPF_Price_Per_Watt__c = 4;
        sdq.CPF_Annual_Increase__c = 2.9;
        sdq.CPF_Down_Payment__c = 1000;      
        Database.Saveresult sdqDBResult = Database.Insert(sdq,false);
        Id sdqId = sdqDBResult.getId();
        if(sdqId == null){
          System.debug('sdqDBResult Insert Errors --> ' + sdqDBResult.getErrors());
        }

        ApexPages.StandardController oppController = new ApexPages.StandardController(opp);
    	CPFRequestCreditController creditController = new CPFRequestCreditController(oppController);
    	creditController.initiateCreditCheck();

    	opp.System_Design_Quote__c = sdqId;
    	update opp;

    	oppController = new ApexPages.StandardController(opp);
    	creditController = new CPFRequestCreditController(oppController);
    	creditController.initiateCreditCheck();

        sdq.CPF_Customer_Id__c = '12345678';
        update sdq;

        oppController = new ApexPages.StandardController(opp);
        creditController = new CPFRequestCreditController(oppController);
        creditController.initiateCreditCheck();


        oppController = new ApexPages.StandardController(opp);
        creditController = new CPFRequestCreditController(oppController);
        creditController.initiateCreditCheck();

        sdq.CPF_Customer_Id__c = null;
        update sdq;

        oppController = new ApexPages.StandardController(opp);
        creditController = new CPFRequestCreditController(oppController);
        creditController.ResendCreditRequest();

        sdq.CPF_Customer_Id__c = '12333';
        update sdq;

        oppController = new ApexPages.StandardController(opp);
        creditController = new CPFRequestCreditController(oppController);
        creditController.ResendCreditRequest();

        CPFIntegrationProcessor ci = new CPFIntegrationProcessor();        
        String res = '<Response><Status>Error</Status><Messages><Error>The Job was not successfully created</Error><Error>The Job was not successfully created</Error></Messages></Response>';
        sdq = ci.parseElligibleInitiateResponse(res,sdq);
        res = '<Response><Status>Error</Status><Message>The Job was not successfully created</Message></Response>';
        sdq = ci.parseElligibleInitiateResponse(res,sdq);
        Test.stopTest();   
        
    
    } 

    static testMethod void SendForSignatureTest()
    {
        Account acct = new Account();
        acct.name='TestAcct';        
        insert acct;
        
        Contact ct = new Contact();
        ct.AccountId = acct.Id;
        ct.FirstName = 'TestC';
        ct.LastName = 'TestL';
        insert ct;     

        Contact ct1 = new Contact();
        ct1.AccountId = acct.Id;
        ct1.FirstName = 'TestC1';
        ct1.LastName = 'TestL1';
        insert ct1;         
       
        
        Utility_Company__c uc = new Utility_Company__c();
        uc.Name = 'BG&E';
        uc.CPF_Rate_Code_Id__c = 'c56ca47c-6b4a-102e-8d27-00e081583152';
        uc.States_Serviced__c = 'MD';
        Database.Saveresult ucDBResult = Database.Insert(uc,false);
        Id ucId = ucDBResult.getId();
        if(ucId == null){
          System.debug('ucDBResult Insert Errors --> ' + ucDBResult.getErrors());
        }
        System.debug('Added Utility Company with Id --> ' + ucId);

        Property__c prop = new Property__c();
        prop.Name = '123 Main St';
        prop.Property_Owner__c = acct.Id;       
        prop.Optimal_Site_Quality_kWh_y_kW__c = double.valueOf('1250');
        prop.Property_State__c = 'MD';
        prop.Property_City__c = 'Annapolis Junction';
        prop.Property_ZIP__c = '20701';
        prop.Property_County__c = 'Howard';
        prop.Astrum_Office__c = 'Annapolis Junction, MD';

        insert prop;

        prop.Utility_Company__c = ucId;
        update prop;

        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            AccountId = acct.Id,
            StageName = 'Test',
            CloseDate = System.today().addDays(-8),
            Financing_Type__c = 'Purchase',
            Financing_Option__c = 'No Financing',
            Leasing_Option__c = null,
            Property__c = prop.Id
        );
        insert opp;

        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = ct.Id;
        ocr.Role = 'Contract Signer';
        ocr.OpportunityId = opp.Id;
        insert ocr;
        OpportunityContactRole ocr1 = new OpportunityContactRole();
        ocr1.ContactId = ct1.Id;
        ocr1.Role = 'Contract Signer';
        ocr1.OpportunityId = opp.Id;
        insert ocr1;

       
        Survey__c surv = new Survey__c();
        surv.Property__c = prop.Id;
        surv.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'Survey__c' and r.Name = 'Field Survey'].id;        
        insert surv;
        
        Utility_Service__c utilService = new Utility_Service__c();
        utilService.Amperage__c = double.valueOf('200');
        utilService.Utility_Company__c = ucId;
        utilService.Property__c = prop.Id;
        utilService.Service_Account_Number__c = 'abc123';
        utilService.Estimated_Average_Monthly_Bill__c = 800;
        utilService.Monthly_Electric_Consumption_KWH_Jan__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Feb__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Mar__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Apr__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_May__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Jun__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Jul__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Aug__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Sep__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Oct__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Nov__c = 200;
        utilService.Monthly_Electric_Consumption_KWH_Dec__c = 200;
        Database.Saveresult utilServiceDBResult = Database.Insert(utilService,false);
        Id utilServiceId = utilServiceDBResult.getId();
        if(utilServiceId == null){
          System.debug('utilServiceDBResult Insert Errors --> ' + utilServiceDBResult.getErrors());
        }        
        System.debug('Added Utility_Service__c with Id --> ' + utilServiceId);

        Utility_Territory_Rate_Codes__c utrc = new Utility_Territory_Rate_Codes__c();
        utrc.Territory__c = '1';
        utrc.CPF_Rate_Code_Id__c = 'c56ca47c-6b4a-102e-8d27-00e081583152';
        utrc.Utility_Company__c = ucId;
        insert utrc;

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
        instLoc.Annual_Solar_Access__c = double.valueOf('90');
        instLoc.TSRF__c = double.valueOf('90');
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
        
        System_Design_Item__c sdi = new System_Design_Item__c();
        sdi.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Item__c' and r.Name = 'Panel'].id;
        sdi.System_Design_Array__c = sdaId;
        sdi.Install_Location__c = instLocId;
        sdi.System_Design_Product__c = sdp.Id;
        sdi.Quantity__c = double.valueOf('29');
        sdi.Annual_Solar_Access__c = double.valueOf('90');
        Database.Saveresult sdiDBResult = Database.Insert(sdi,false);
        Id sdiId = sdiDBResult.getId();
        if(sdiId == null){
          System.debug('sdiDBResult Insert Errors --> ' + sdiDBResult.getErrors());
        }
        System.debug('Added System_Design_Item__c with Id --> ' + sdiId);

        System_Design_Item__c sdi1 = new System_Design_Item__c();
        sdi1.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Item__c' and r.Name = 'Inverter'].id;
        sdi1.System_Design_Array__c = sdaId;
        sdi1.Install_Location__c = instLocId;
        sdi1.System_Design_Product__c = sdp1.Id;
        sdi1.Quantity__c = double.valueOf('29');
        sdi1.Annual_Solar_Access__c = double.valueOf('90');
        Database.Saveresult sdiDBResult1 = Database.Insert(sdi1,false);
        Id sdi1Id = sdiDBResult1.getId();
        if(sdi1Id == null){
          System.debug('sdiDBResult Insert Errors --> ' + sdiDBResult1.getErrors());
        }
        System.debug('Added System_Design_Item__c with Id --> ' + sdiId);
                        
        sd.Calculated_System_Price__c = decimal.valueOf('100000.25');
        update(sd);

        CPF_Equipment_Mapping__C comp = new  CPF_Equipment_Mapping__C();        
        comp.CPF_id__c = 'a1pA0000000EqGJIA0';            
        comp.Model_Number__c = 'M215';   
        Comp.System_Design_Product__c = sdp1.Id;
        comp.Type__c = 'Inverter';
        insert comp;
        
               
        CPF_Equipment_Mapping__C comp2 = new  CPF_Equipment_Mapping__C();        
        comp2.CPF_id__c = 'a1pA0000000EqGJIA0';            
        comp2.Model_Number__c = 'CD';   
        Comp2.System_Design_Product__c = sdp.Id;
        comp2.Type__c = 'Module';
        insert comp2;

        SCRB_SalesOrder__c salesOrder = new SCRB_SalesOrder__c(
          Property__c = prop.Id,           
          //System_Design_Quote__c = sdq.Id,
          AccountId__c = acct.Id,
          CEG_Deposit__c = 1000,
          Lease_Escalator__c = 1.9,
          Year_1__c = 333.0,
          Total_Grant_Amount__c = 33,
          Sales_Tax_Percentage__c = 12,
          CEG_Total_System_Price__c = 332322,
          OpportunityId__c = opp.Id     ,
          Leasing_Option__c = 'Monthly'    
        );
        insert salesOrder;

       

        Test.startTest();
        
        System_Design_Quote__c sdq = new System_Design_Quote__c();
        sdq.System_Design__c = sdId;
        sdq.Utility_Territory__c = '1';
        sdq.CPF_Customer_Id__c = '12345678';        
        Database.Saveresult sdqDBResult = Database.Insert(sdq,false);
        Id sdqId = sdqDBResult.getId();
        if(sdqId == null){
          System.debug('sdqDBResult Insert Errors --> ' + sdqDBResult.getErrors());
        }

        


        ApexPages.StandardController salesController = new ApexPages.StandardController(salesOrder);
        CPFSignatureRequestController sigController = new CPFSignatureRequestController(salesController);
        sigController.RequestSignatureForCPFQuote();

        salesOrder.System_Design_Quote__c = sdqId;
        update salesOrder;

        salesController = new ApexPages.StandardController(salesOrder);
        sigController = new CPFSignatureRequestController(salesController);
        sigController.RequestSignatureForCPFQuote();

        sdq.CPF_Document_Generation_Completed__c = true;
        sdq.CPF_Eligibility_Completed__c = true;
        sdq.CPF_Proposal_Id__c = '34344343';
        update sdq;

        salesController = new ApexPages.StandardController(salesOrder);
        sigController = new CPFSignatureRequestController(salesController);
        sigController.RequestSignatureForCPFQuote();

        ct.Email = 'rj@test.comm';
        update ct;
        ct1.Email = 'tt@test.comm';
        update ct1;

        salesController = new ApexPages.StandardController(salesOrder);
        sigController = new CPFSignatureRequestController(salesController);
        sigController.RequestSignatureForCPFQuote();

        CPFIntegrationProcessor ci = new CPFIntegrationProcessor();        
        String res = '<Response><Status>Error</Status><Messages><Error>The Job was not successfully created</Error><Error>The Job was not successfully created</Error></Messages></Response>';
        sdq = ci.parseSendForSignatureResponse(res,sdq);
        res = '<Response><Status>Error</Status><Message>The Job was not successfully created</Message></Response>';
        sdq = ci.parseSendForSignatureResponse(res,sdq);
        Test.stopTest();   
        
    
    }

    static testMethod void testElligibilityHandler() {

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Elligible';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('<Response><Customer>1234</Customer></Response>');
        RestContext.request = req;
        RestContext.response = res;

        CPFCustomerElligibilityHandler.doPost();
        
    } 
    
    static testMethod void testCPFProposalCallBackHandler() {

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Proposal';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('<Response><ProposalUUID>1234</ProposalUUID></Response>');
        RestContext.request = req;
        RestContext.response = res;

        CPFProposalCallBackHandler.doPost();
        
    } 
    */

	
}