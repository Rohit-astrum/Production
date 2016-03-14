//Commented by RJ on 05/5/2015
@IsTest(SeeAllData=true)
private class NRGOpportunityLeadSendControllerTest {
	/*
	@isTest static void testSendNRGLead() {
		// Implement test code
		Account acct = new Account();
        acct.name='TestAcct';        
        insert acct;

        Contact ct = new Contact();
        ct.AccountId = acct.Id;
        ct.FirstName = 'TestC';
        ct.LastName = 'TestL';
        ct.Email = 'ra@test.comm';
        //ct.Phone = '3334445555';
        insert ct;

        Contact ct1 = new Contact();
        ct1.AccountId = acct.Id;
        ct1.FirstName = 'TestC1';
        ct1.LastName = 'TestL1';
        ct1.Email = 'ra1@test.comm';
        //ct1.Phone = '3434445555';

        insert ct1;

        Office_Location__c ao = new Office_Location__c();
        ao.Name = 'Annapolis Junction, MD';
        ao.Street__c = '8955 Henkels Lane';
        ao.City__c = 'Annapolis Junction';
        ao.state__c = 'MD';
        ao.Zip_Code__c = '20701';        
        ao.State_Coverage__c = 'MD';
        insert ao;

        Utility_Company__c uc = new Utility_Company__c();
        uc.Name = 'BG&E';
        uc.States_Serviced__c = 'MD';
        insert uc;
        
        Utility_by_zip_code__c uz = new Utility_by_zip_code__c();
        uz.Utility_Zip_Code__c = '20701';
        uz.Utility_Company__c = uc.Id;
        insert uz;
        
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

		Survey__c surv = new Survey__c();
        surv.Property__c = prop.Id;
        surv.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'Survey__c' and r.Name = 'Field Survey'].id;        
        insert surv;
        
        Utility_Service__c utilService = new Utility_Service__c();
        utilService.Amperage__c = double.valueOf('200');
        utilService.Utility_Company__c = uc.Id;
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
      
        //MK 2014-05-02 - Move survey creation first so we can connect install locations to it

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
        sd.Calculated_System_Price__c = decimal.valueOf('100000.25');
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

        System_Design_Quote__c sdq = new System_Design_Quote__c();
        sdq.System_Design__c = sdId;
        insert sdq;
        

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


        Test.startTest();
        ApexPages.StandardController controller = new ApexPages.StandardController(opp);        
        
        NRGOpportunityLeadSendController oppController = new NRGOpportunityLeadSendController(controller);    
        PageReference result1 = oppController.sendNRGLead();
        Test.setCurrentPage(result1);
        System.assert(ApexPages.currentPage().getParameters().get('leadsent') == 'NSDQ');

        opp.System_Design_Quote__c = sdq.Id;
        update opp;
        prop.Utility_Company__c =null;    
        update prop;

        oppController = new NRGOpportunityLeadSendController(controller); 
        result1 = oppController.sendNRGLead(); 
        Test.setCurrentPage(result1);
        System.assert(ApexPages.currentPage().getParameters().get('leadsent') == 'NPU');

        prop.Utility_Company__c = uc.Id;    
        update prop;

        oppController = new NRGOpportunityLeadSendController(controller); 
        result1 = oppController.sendNRGLead(); 
        Test.setCurrentPage(result1);
        System.assert(ApexPages.currentPage().getParameters().get('leadsent') == 'NOC');

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

        oppController = new NRGOpportunityLeadSendController(controller); 
        result1 = oppController.sendNRGLead(); 
        Test.setCurrentPage(result1);
        System.assert(ApexPages.currentPage().getParameters().get('leadsent') == 'LFS');

        ct.Phone = '3334445555';
        ct1.Phone = '3434445555';
        update ct;
        update ct1;

        oppController = new NRGOpportunityLeadSendController(controller); 
        result1 = oppController.sendNRGLead(); 
        Test.setCurrentPage(result1);
        System.assert(ApexPages.currentPage().getParameters().get('leadsent') == 'CY');

        oppController = new NRGOpportunityLeadSendController(controller);
        result1 = oppController.sendNRGLead(); 
        Test.setCurrentPage(result1);        
        System.assert(ApexPages.currentPage().getParameters().get('id')  == opp.Id);

		oppController = new NRGOpportunityLeadSendController(controller);
        result1 = oppController.resendNRGLead();
        Test.setCurrentPage(result1);
        System.assert(ApexPages.currentPage().getParameters().get('leadsent') == 'CY');
        
        Test.stopTest();
        

	}	
	*/
	
}