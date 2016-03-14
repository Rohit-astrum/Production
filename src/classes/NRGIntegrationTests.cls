/* FILE: NRGIntegrationTests.cls
 * AUTHOR: Rohit Jain
 * DATE: July 13, 2013
 * PURPOSE: Test Methods for NRG Integration
 * MODIFICATION HISTORY:
 * Commented by RJ on 05/5/2015
 */
@isTest(SeeAllData=true)
public class NRGIntegrationTests{
    /*
    static testMethod void SystemDesignSendToNRGTest()
    {
        Account acct = new Account();
        acct.name='TestAcct';        
        insert acct;
        
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
        
        Utility_Company__c uc = new Utility_Company__c();
        uc.Name = 'BG&E';
        uc.States_Serviced__c = 'MD';
        Database.Saveresult ucDBResult = Database.Insert(uc,false);
        Id ucId = ucDBResult.getId();
        if(ucId == null){
          System.debug('ucDBResult Insert Errors --> ' + ucDBResult.getErrors());
        }
        System.debug('Added Utility Company with Id --> ' + ucId);
       
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
                        
        sd.Calculated_System_Price__c = decimal.valueOf('100000.25');
        update(sd);
        
        System_Design_Quote__c sdq = new System_Design_Quote__c();
        sdq.System_Design__c = sdId;
        system.debug('SDA --> ' + [Select s.System_Design__c, s.SystemModstamp, s.Special_Parts_Required__c, s.Projected_Annual_Output_kWh_y__c, s.Panel_Count__c, s.Name, s.Mounting_Type__c, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Id, s.Electrical_Adder__c, s.CreatedDate, s.CreatedById, s.ConnectionSentId, s.ConnectionReceivedId, s.CB_Panel__c, s.Array_Size_kW__c From System_Design_Array__c s where s.Id = :sdaId]);
        system.debug('SD --> ' + [Select s.Total_System_Size_kW__c, s.Total_Projected_Annual_Output_kWh_y__c, s.SystemModstamp, s.Survey__c, s.Property__c, s.Panel_Count__c, s.Overall_TSRF__c, s.Overall_Site_Quality__c, s.Notes__c, s.Name, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Id, s.CreatedDate, s.CreatedById, s.ConnectionSentId, s.ConnectionReceivedId, s.Calculated_System_Price__c, s.Calculated_Price_per_Watt__c, s.Account_Number__c From System_Design__c s where s.Id = :sdId]);
        Database.Saveresult sdqDBResult = Database.Insert(sdq,false);
        Id sdqId = sdqDBResult.getId();
        if(sdqId == null){
          System.debug('sdqDBResult Insert Errors --> ' + sdqDBResult.getErrors());
        }
        
        NRG_String_Component__C comp = new  NRG_String_Component__C();
        comp.Name = 'Enphase M215';
        comp.String_Component_id__c = 'a1pA0000000EqGJIA0';
        comp.Group_Code__c = 'ALL';        
        insert comp;
        
        NRG_String_Component__C comp1 = new  NRG_String_Component__C();
        comp1.Name = 'Canadian Solar CS6P-245P';
        comp1.String_Component_id__c = 'a1pA0000000Ax0TIAS';
        comp1.Group_Code__c = 'ALL';        
        insert comp1;
        
        Lease_Fund_Product_Mapping__c mapp = new Lease_Fund_Product_Mapping__c();
        mapp.Astrum_Product__c = sdp1.Id;
        mapp.Lease_Fund_Product__C = comp.Id;
        insert mapp;
        
               
        
        ApexPages.StandardController controller = new ApexPages.StandardController(sd);
        
        Test.startTest();
            
        SystemDesignLeaseFundController cont = new SystemDesignLeaseFundController (controller);        
        PageReference result1 = cont.sendToLeaseFund();
        Test.setCurrentPage(result1 );
        System.assert(ApexPages.currentPage().getParameters().get('leadsent') == 'F');
        
        
        Contact ct = new Contact();
        ct.AccountId = acct.Id;
        ct.FirstName = 'TestC';
        ct.LastName = 'TestL';
        insert ct;
        
        result1 = cont.sendToLeaseFund();
        Test.setCurrentPage(result1 );
        System.assert(ApexPages.currentPage().getParameters().get('leadsent') == 'MF');
        
        Lease_Fund_Product_Mapping__c mapp1 = new Lease_Fund_Product_Mapping__c();
        mapp1.Astrum_Product__c = sdp.Id;
        mapp1.Lease_Fund_Product__C = comp1.Id;
        insert mapp1;
        
        result1 = cont.sendToLeaseFund();
        Test.setCurrentPage(result1 );
        System.assert(ApexPages.currentPage().getParameters().get('leadsent') == 'Y');
        
        
        result1 = cont.sendToLeaseFund();
        Test.setCurrentPage(result1 );
        System.assert(ApexPages.currentPage().getParameters().get('leadsent') == 'N');
        
        NRG_Lead__C nl = [Select Id,NRG_Lead_Id__C from NRG_Lead__c where System_Design__C = :sd.Id limit 1];
        nl.NRG_Lead_Id__C = 'Error-Test';
        update nl;
        
        result1 = cont.sendToLeaseFund();
        Test.setCurrentPage(result1 );
        //System.assert(ApexPages.currentPage().getParameters().get('leadsent') == 'Y');
        
        
        Test.stopTest();   
        
    
    }   
  
 
    static testMethod void NRGRequestQuotePriceTest()
    {
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
        
        Utility_Company__c uc = new Utility_Company__c();
        uc.Name = 'BG&E';
        uc.States_Serviced__c = 'MD';
        Database.Saveresult ucDBResult = Database.Insert(uc,false);
        Id ucId = ucDBResult.getId();
        if(ucId == null){
          System.debug('ucDBResult Insert Errors --> ' + ucDBResult.getErrors());
        }
        System.debug('Added Utility Company with Id --> ' + ucId);
       
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
        sdi.NRG_Site_Quality__c = 1200;
        
        Database.Saveresult sdiDBResult = Database.Insert(sdi,false);
        Id sdiId = sdiDBResult.getId();
        if(sdiId == null){
          System.debug('sdiDBResult Insert Errors --> ' + sdiDBResult.getErrors());
        }
        System.debug('Added System_Design_Item__c with Id --> ' + sdiId);
        
        sdi = [select id,Azimuth_Text__C,Tilt_Text__c,Shading_Text__C from System_Design_item__c where id = :sdiId  ];
        
        System.debug('$$ sdi  --> ' + sdi.Azimuth_Text__C);
        System.debug('$$ sdi  --> ' + sdi.Tilt_Text__c);
        System.debug('$$ sdi  --> ' + sdi.Shading_Text__C);
                        
        sd.Calculated_System_Price__c = decimal.valueOf('100000.25');
        
        update(sd);
        
        sd = [select id,NRG_Overall_Site_Quality__c,Total_System_Size_kW__c , NRG_Projected_Annual_Output_kWh_y__c from System_Design__c where id = :sd.Id ];
        
        System.debug('$$ System Design Array Out --> ' + sd.NRG_Projected_Annual_Output_kWh_y__c);
        System.debug('$$ System Design Array Out --> ' + sd.NRG_Overall_Site_Quality__c);
        
        
        NRG_String_Component__C comp = new  NRG_String_Component__C();
        comp.Name = 'Enphase M215';
        comp.String_Component_id__c = 'a1pA0000000EqGJIA0';
        comp.Group_Code__c = 'ALL';        
        insert comp;
        
        NRG_String_Component__C comp1 = new  NRG_String_Component__C();
        comp1.Name = 'Canadian Solar CS6P-245P';
        comp1.String_Component_id__c = 'a1pA0000000Ax0TIAS';
        comp1.Group_Code__c = 'ALL';        
        insert comp1;
        
        Lease_Fund_Product_Mapping__c mapp = new Lease_Fund_Product_Mapping__c();
        mapp.Astrum_Product__c = sdp1.Id;
        mapp.Lease_Fund_Product__C = comp.Id;
        insert mapp;
        
        Lease_Fund_Product_Mapping__c mapp1 = new Lease_Fund_Product_Mapping__c();
        mapp1.Astrum_Product__c = sdp.Id;
        mapp1.Lease_Fund_Product__C = comp1.Id;
        insert mapp1;
        
        Test.startTest();   
        System_Design_Quote__c sdq = new System_Design_Quote__c();
        sdq.System_Design__c = sdId;
        
        sdq.NRG_Calculator_System_Size_kW__c = sd.Total_System_Size_kW__c;
        sdq.NRG_Calculator_Projected_Annual_Output__c = sd.NRG_Projected_Annual_Output_kWh_y__c;
        sdq.NRG_EPC_Price__c = 38000;
        sdq.NRG_Calculator_Avoided_Cost__c = 0.026; 
        sdq.NRG_Calculator_Utility__c = 'NSTAR';
        
        system.debug('SDA --> ' + [Select s.System_Design__c, s.SystemModstamp, s.Special_Parts_Required__c, s.Projected_Annual_Output_kWh_y__c, s.Panel_Count__c, s.Name, s.Mounting_Type__c, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Id, s.Electrical_Adder__c, s.CreatedDate, s.CreatedById, s.ConnectionSentId, s.ConnectionReceivedId, s.CB_Panel__c, s.Array_Size_kW__c From System_Design_Array__c s where s.Id = :sdaId]);
        system.debug('SD --> ' + [Select s.Total_System_Size_kW__c, s.Total_Projected_Annual_Output_kWh_y__c, s.SystemModstamp, s.Survey__c, s.Property__c, s.Panel_Count__c, s.Overall_TSRF__c, s.Overall_Site_Quality__c, s.Notes__c, s.Name, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Id, s.CreatedDate, s.CreatedById, s.ConnectionSentId, s.ConnectionReceivedId, s.Calculated_System_Price__c, s.Calculated_Price_per_Watt__c, s.Account_Number__c From System_Design__c s where s.Id = :sdId]);
        Database.Saveresult sdqDBResult = Database.Insert(sdq,false);
        Id sdqId = sdqDBResult.getId();
        if(sdqId == null){
          System.debug('sdqDBResult Insert Errors --> ' + sdqDBResult.getErrors());
        }
        
        
        System_Design_Quote__c sdq1 = new System_Design_Quote__c();
        sdq1.System_Design__c = sdId;
        Database.Saveresult sdq1DBResult = Database.Insert(sdq,false);
        Id sdq1Id = sdqDBResult.getId();
        if(sdq1Id == null){
          System.debug('sdqDBResult Insert Errors --> ' + sdq1DBResult.getErrors());
        }
        
        
        
        
                 
        
        
        Test.stopTest();   
        
    
    }
    
  
    
    static testMethod void SalesOrderNRGSQTest()
    {
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
        
        Utility_Company__c uc = new Utility_Company__c();
        uc.Name = 'BG&E';
        uc.States_Serviced__c = 'MD';
        Database.Saveresult ucDBResult = Database.Insert(uc,false);
        Id ucId = ucDBResult.getId();
        if(ucId == null){
          System.debug('ucDBResult Insert Errors --> ' + ucDBResult.getErrors());
        }
        System.debug('Added Utility Company with Id --> ' + ucId);
       
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
        sdi.Annual_Solar_Access__c = double.valueOf('1100');
        sdi.NRG_Site_Quality__c= double.valueOf('90');
        sdi.Rated_Output_kW__c = 12;
        Database.Saveresult sdiDBResult = Database.Insert(sdi,false);
        Id sdiId = sdiDBResult.getId();
        if(sdiId == null){
          System.debug('sdiDBResult Insert Errors --> ' + sdiDBResult.getErrors());
        }
        System.debug('Added System_Design_Item__c with Id --> ' + sdiId);
                        
        sd.Calculated_System_Price__c = decimal.valueOf('100000.25');
        update(sd);
        
        System_Design_Quote__c sdq = new System_Design_Quote__c();
        sdq.System_Design__c = sdId;
        system.debug('SDA --> ' + [Select s.System_Design__c, s.SystemModstamp, s.Special_Parts_Required__c, s.Projected_Annual_Output_kWh_y__c, s.Panel_Count__c, s.Name, s.Mounting_Type__c, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Id, s.Electrical_Adder__c, s.CreatedDate, s.CreatedById, s.ConnectionSentId, s.ConnectionReceivedId, s.CB_Panel__c, s.Array_Size_kW__c From System_Design_Array__c s where s.Id = :sdaId]);
        system.debug('SD --> ' + [Select s.Total_System_Size_kW__c, s.Total_Projected_Annual_Output_kWh_y__c, s.SystemModstamp, s.Survey__c, s.Property__c, s.Panel_Count__c, s.Overall_TSRF__c, s.Overall_Site_Quality__c, s.Notes__c, s.Name, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Id, s.CreatedDate, s.CreatedById, s.ConnectionSentId, s.ConnectionReceivedId, s.Calculated_System_Price__c, s.Calculated_Price_per_Watt__c, s.Account_Number__c From System_Design__c s where s.Id = :sdId]);
        Database.Saveresult sdqDBResult = Database.Insert(sdq,false);
        Id sdqId = sdqDBResult.getId();
        if(sdqId == null){
          System.debug('sdqDBResult Insert Errors --> ' + sdqDBResult.getErrors());
        }
        
        NRG_String_Component__C comp = new  NRG_String_Component__C();
        comp.Name = 'Enphase M215';
        comp.String_Component_id__c = 'a1pA0000000EqGJIA0';
        comp.Group_Code__c = 'ALL';        
        insert comp;
        
        NRG_String_Component__C comp1 = new  NRG_String_Component__C();
        comp1.Name = 'Canadian Solar CS6P-245P';
        comp1.String_Component_id__c = 'a1pA0000000Ax0TIAS';
        comp1.Group_Code__c = 'ALL';        
        insert comp1;
        
        Lease_Fund_Product_Mapping__c mapp = new Lease_Fund_Product_Mapping__c();
        mapp.Astrum_Product__c = sdp1.Id;
        mapp.Lease_Fund_Product__C = comp.Id;
        insert mapp;
        
        Lease_Fund_Product_Mapping__c mapp1 = new Lease_Fund_Product_Mapping__c();
        mapp1.Astrum_Product__c = sdp.Id;
        mapp1.Lease_Fund_Product__C = comp1.Id;
        insert mapp1;
        
        SCRB_SalesOrder__c salesOrder = new SCRB_SalesOrder__c(
          Property__c = prop.Id,           
          //System_Design_Quote__c = sdq.Id,
          AccountId__c = acct.Id,
          CEG_Deposit__c = 1000,
          Lease_Escalator__c = 1.9,
          Year_1__c = 333.0,
          Total_Grant_Amount__c = 33,
          Sales_Tax_Percentage__c = 12,
          CEG_Total_System_Price__c = 332322         
        );
        insert salesOrder;
               
        
        ApexPages.StandardController controller = new ApexPages.StandardController(salesOrder);
        
        Test.startTest();
            
        SalesOrderLeaseFundController cont = new SalesOrderLeaseFundController(controller);        
        PageReference result1 = cont.sendAcceptNRGLeaseFundQuote();
        Test.setCurrentPage(result1 );
        System.assert(ApexPages.currentPage().getParameters().get('leadsent') == 'NSDQ');
        
        salesOrder.System_Design_Quote__c = sdq.Id;
        update salesOrder;
        cont = new SalesOrderLeaseFundController(controller);    
        result1 = cont.sendAcceptNRGLeaseFundQuote();
        Test.setCurrentPage(result1 );
        System.debug('*********leadsent-'+ApexPages.currentPage().getParameters().get('leadsent'));
        System.assert(ApexPages.currentPage().getParameters().get('leadsent') == 'NR');
        
        sdq.NRG_LeadId__c = '00QK00000050HZbMAM';
        sdq.NRG_QuoteId__c = '00QK00000050HZbMAM';
        sdq.NRG_SolarId__c = '00QK00000050HZbMAM';
        update sdq;
        cont = new SalesOrderLeaseFundController(controller); 
        result1 = cont.sendAcceptNRGLeaseFundQuote();
        Test.setCurrentPage(result1 );
        System.assert(ApexPages.currentPage().getParameters().get('leadsent') == 'LO');
        
        salesOrder.Leasing_Option__c = 'Pay';
        update salesOrder;
        cont = new SalesOrderLeaseFundController(controller); 
        result1 = cont.sendAcceptNRGLeaseFundQuote();
        Test.setCurrentPage(result1 );
        System.assert(ApexPages.currentPage().getParameters().get('leadsent') == 'ILO');
        
        
        salesOrder.Leasing_Option__c = 'One-Pay';
        update salesOrder;
        cont = new SalesOrderLeaseFundController(controller); 
        result1 = cont.sendAcceptNRGLeaseFundQuote();
        Test.setCurrentPage(result1 );
        System.assert(ApexPages.currentPage().getParameters().get('leadsent') == 'Y');
                
        
        
        
    
    }
    
      static testMethod void SalesOrderNRGSQSoapTest()
    {
        Account acct = new Account();
        acct.name='TestAcct';        
        insert acct;
        
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
        
        Utility_Company__c uc = new Utility_Company__c();
        uc.Name = 'BG&E';
        uc.States_Serviced__c = 'MD';
        Database.Saveresult ucDBResult = Database.Insert(uc,false);
        Id ucId = ucDBResult.getId();
        if(ucId == null){
          System.debug('ucDBResult Insert Errors --> ' + ucDBResult.getErrors());
        }
        System.debug('Added Utility Company with Id --> ' + ucId);
       
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
      
        Install_Location__c instLoc = new Install_Location__c();
        instLoc.Property__c = prop.Id;
        instLoc.Azimuth__c = double.valueOf('180');
        instLoc.Pitch__c = double.valueOf('23');
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
        sdi.Annual_Solar_Access__c = double.valueOf('1100');
        sdi.NRG_Site_Quality__c= double.valueOf('90');
        sdi.Rated_Output_kW__c = 12;
        Database.Saveresult sdiDBResult = Database.Insert(sdi,false);
        Id sdiId = sdiDBResult.getId();
        if(sdiId == null){
          System.debug('sdiDBResult Insert Errors --> ' + sdiDBResult.getErrors());
        }
        System.debug('Added System_Design_Item__c with Id --> ' + sdiId);
                        
        sd.Calculated_System_Price__c = decimal.valueOf('100000.25');
        update(sd);
        
        System_Design_Quote__c sdq = new System_Design_Quote__c();
        sdq.System_Design__c = sdId;
        system.debug('SDA --> ' + [Select s.System_Design__c, s.SystemModstamp, s.Special_Parts_Required__c, s.Projected_Annual_Output_kWh_y__c, s.Panel_Count__c, s.Name, s.Mounting_Type__c, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Id, s.Electrical_Adder__c, s.CreatedDate, s.CreatedById, s.ConnectionSentId, s.ConnectionReceivedId, s.CB_Panel__c, s.Array_Size_kW__c From System_Design_Array__c s where s.Id = :sdaId]);
        system.debug('SD --> ' + [Select s.Total_System_Size_kW__c, s.Total_Projected_Annual_Output_kWh_y__c, s.SystemModstamp, s.Survey__c, s.Property__c, s.Panel_Count__c, s.Overall_TSRF__c, s.Overall_Site_Quality__c, s.Notes__c, s.Name, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Id, s.CreatedDate, s.CreatedById, s.ConnectionSentId, s.ConnectionReceivedId, s.Calculated_System_Price__c, s.Calculated_Price_per_Watt__c, s.Account_Number__c From System_Design__c s where s.Id = :sdId]);
        Database.Saveresult sdqDBResult = Database.Insert(sdq,false);
        Id sdqId = sdqDBResult.getId();
        if(sdqId == null){
          System.debug('sdqDBResult Insert Errors --> ' + sdqDBResult.getErrors());
        }
        
        NRG_String_Component__C comp = new  NRG_String_Component__C();
        comp.Name = 'Enphase M215';
        comp.String_Component_id__c = 'a1pA0000000EqGJIA0';
        comp.Group_Code__c = 'ALL';        
        insert comp;
        
        NRG_String_Component__C comp1 = new  NRG_String_Component__C();
        comp1.Name = 'Canadian Solar CS6P-245P';
        comp1.String_Component_id__c = 'a1pA0000000Ax0TIAS';
        comp1.Group_Code__c = 'ALL';        
        insert comp1;
        
        Lease_Fund_Product_Mapping__c mapp = new Lease_Fund_Product_Mapping__c();
        mapp.Astrum_Product__c = sdp1.Id;
        mapp.Lease_Fund_Product__C = comp.Id;
        insert mapp;
        
        SCRB_SalesOrder__c salesOrder = new SCRB_SalesOrder__c(
          Property__c = prop.Id,           
          System_Design_Quote__c = sdq.Id,
          AccountId__c = acct.Id,
          CEG_Deposit__c = 1000,
          Lease_Escalator__c = 1.9,
          Year_1__c = 333.0,
          Total_Grant_Amount__c = 33,
          Sales_Tax_Percentage__c = 12,
          CEG_Total_System_Price__c = 332322         
        );
        insert salesOrder;
               
        
        ApexPages.StandardController controller = new ApexPages.StandardController(salesOrder);
        
        Test.startTest();
            
        SalesOrderLeaseFundController cont = new SalesOrderLeaseFundController(controller);        
        PageReference result1 = cont.sendNewToNRGLeaseFund();
        Test.setCurrentPage(result1 );
        System.assert(ApexPages.currentPage().getParameters().get('leadsent') == 'F');
        
        
        Contact ct = new Contact();
        ct.AccountId = acct.Id;
        ct.FirstName = 'TestC';
        ct.LastName = 'TestL';
        insert ct;
        
                
        Lease_Fund_Product_Mapping__c mapp1 = new Lease_Fund_Product_Mapping__c();
        mapp1.Astrum_Product__c = sdp.Id;
        mapp1.Lease_Fund_Product__C = comp1.Id;
        insert mapp1;
        
        result1 = cont.sendNewToNRGLeaseFund();
        Test.setCurrentPage(result1 );
        System.assert(ApexPages.currentPage().getParameters().get('leadsent') == 'Y');
        
        
        sdq.NRG_Lead_Id__C = '00QK00000044PUQMA2';
        update sdq;
        
        cont = new SalesOrderLeaseFundController(controller); 
        result1 = cont.sendNewToNRGLeaseFund();
        Test.setCurrentPage(result1 );
        System.assert(ApexPages.currentPage().getParameters().get('leadsent') == 'Y');
        
        
        
    
    }

    */

}