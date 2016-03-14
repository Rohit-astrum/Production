@isTest
private class SystemDesignEditControllerExtensionTest {
    
    @isTest static void SystemDesignCreateTest() {
        
        testData.setupCustomSettings();
        testdata.setupCustomConfigObjects();

        id surveyID = testData.setupPropertyWithFieldSurvey();
        id propertyID = [select id, Property__c from Survey__c where id =: surveyID].Property__c;

        //System_Design__c sd = new System_Design__c(Property__c = propertyID);
        System_Design__c sdFromSurvey = new System_Design__c(Survey__c = surveyID);

        System_Design_Product__c panel = new System_Design_Product__c();
        panel.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Product__c' and r.Name = 'Panel'].id;
        panel.Description__c  = 'Sanyo 215';
        panel.End_Clamp_Type__c = 'F End Clamp';  
        panel.Make__c  = 'Sanyo';
        panel.Max_Voltage__c = double.valueOf('600');
        panel.Mid_Clamp_Type__c = 'F Mid Clamp';  
        panel.Model__c = 'HIT Power 215N';
        panel.Rated_Output_W__c = double.valueOf('215');  
        panel.Unit__c = 'Count';
        insert panel;
                
        System_Design_Product__c inverter = new System_Design_Product__c();
        inverter.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Product__c' and r.Name = 'Inverter'].id;
        inverter.Description__c  = 'M215-60-240-S22';
        inverter.End_Clamp_Type__c = 'F End Clamp';  
        inverter.Make__c  = 'Enphase';
        inverter.Max_Voltage__c = double.valueOf('600');
        inverter.Mid_Clamp_Type__c = 'F Mid Clamp';  
        inverter.Model__c = 'M215-60-240-S22';
        inverter.Rated_Output_W__c = double.valueOf('215');  
        inverter.Unit__c = 'Count';
        insert inverter;
        
        
        test.startTest();

        Test.setCurrentPage(Page.SystemDesignEdit);

        ApexPages.StandardController sdController = new ApexPages.StandardController(sdFromSurvey);
        SystemDesignEditControllerExtension extn = new SystemDesignEditControllerExtension(sdController);

        extn.initSDEditMode();        
        
        //getter methods
        string busRatingAmps = extn.busRatingAmps;
        string mainBreakerRatingAmps = extn.mainBreakerRatingAmps;
        string countofOpenCircuits = extn.countofOpenCircuits;
        string serviceEntryType = extn.serviceEntryType;
        string meterid = extn.meterid;
        List<selectOption> utilityServices = extn.utilityServices;
        List<selectOption> surveys = extn.surveys;
        
        extn.sysDesign.Default_CB_Panel__c = null;
        extn.utilityService = null;
        
        //Null cb panel
        extn.isWestCoast = true; //Set so that validation runs all the way through for code coverage
        extn.busRatingAmps = null;
        extn.mainBreakerRatingAmps = null;
        extn.countofOpenCircuits = null;
        extn.serviceEntryType = null;
        extn.meterid = null;
                    
        //fails due to validation issue with cbpanel
        extn.save();
        extn.saveAndNext();
        
        extn.busRatingAmps = 'abc';
        extn.mainBreakerRatingAmps = 'abc';
        extn.countofOpenCircuits = 'abc';
                            
        //fails due to validation issue with cbpanel        
        extn.saveAndNext();
        
        extn.busRatingAmps = '200';
        extn.mainBreakerRatingAmps = '200';
        extn.countofOpenCircuits = '2';
        extn.serviceEntryType = 'TBD';
        extn.meterid = '123';
        
        //Successful
        extn.saveAndNext();
        //If this line fails, the record did not insert.
        id sdID = [select id from System_Design__c where Survey__c =: surveyID].id;
        
        System_Design__c sd = [select 
                                    id, 
                                    Survey__c, 
                                    Property__c, 
                                    Property__r.Property_City__c,
                                    Property__r.Property_State__c,
                                    Property__r.Utility_Company__c,
                                    Property__r.Property_Owner__c,
                                    Property__r.Property_Owner__r.Client_Last_Name__c, 
                                    Default_CB_Panel__c,
                                    System_Panel__c, 
                                    System_Inverter__c, 
                                    Notes__c
                                from System_Design__c where Survey__c =: surveyID];
        
        //Assign default mounting for ps
        Physical_Surface__c ps = [SELECT id, Default_Mounting__c FROM Physical_Surface__c WHERE Property__c =: sd.Property__c];
        ps.Default_Mounting__c = panel.id;        
        update ps;

        //ArraysPage now
        Test.setCurrentPage(Page.SystemDesignArraysEdit);

        sdController = new ApexPages.StandardController(sd);
        extn = new SystemDesignEditControllerExtension(sdController);

        extn.initArrayEditMode();
        //getter methods
        surveys = extn.surveys;
        list<SystemDesignEditControllerExtension.cSurface> cSurfaceList = extn.cSurfaceList; 
        List<selectOption> panels = extn.getpanels();
        List<selectOption> inverters = extn.getinverters();
        
        extn.activePSid = extn.cSurfaceList[0].ps.id;        
        extn.surveyChangeOnPS();
        
        extn.sysDesign.System_Panel__c = null;
        extn.sysDesign.System_Inverter__c = null;
        //test validation
        extn.saveArrays(); //this will not save records in db because of validation errors.            
        
        //Fill out the install locations, select panel, save and assert that arrays and items are added.
        extn.sysDesign.System_Panel__c = panel.id;
        extn.sysDesign.System_Inverter__c = inverter.id;
        
        extn.cSurfaceList[0].cIls[0].quantity = 10;
        extn.calc();
        system.assertEquals(10, extn.panelQty);
		        
        extn.saveArrays();
        //Verify that the SDI's were inserted and rolled up to the SD level.
        system.assertEquals(10, [select panel_count__c from System_Design__c where id =: sdId].Panel_Count__c);

        test.stopTest();

    }
    
     @isTest static void SystemDesignArrayTest() {
        
        testData.setupCustomSettings();
        testdata.setupCustomConfigObjects();

        id surveyID = testData.setupPropertyWithFieldSurvey();
        id propertyID = [select id, Property__c from Survey__c where id =: surveyID].Property__c;

        //System_Design__c sd = new System_Design__c(Property__c = propertyID);
        System_Design__c sdFromSurvey = new System_Design__c(Survey__c = surveyID);

        System_Design_Product__c panel = new System_Design_Product__c();
        panel.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Product__c' and r.Name = 'Panel'].id;
        panel.Description__c  = 'Sanyo 215';
        panel.End_Clamp_Type__c = 'F End Clamp';  
        panel.Make__c  = 'Sanyo';
        panel.Max_Voltage__c = double.valueOf('600');
        panel.Mid_Clamp_Type__c = 'F Mid Clamp';  
        panel.Model__c = 'HIT Power 215N';
        panel.Rated_Output_W__c = double.valueOf('215');  
        panel.Unit__c = 'Count';
        insert panel;
                
        System_Design_Product__c inverter = new System_Design_Product__c();
        inverter.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Product__c' and r.Name = 'Inverter'].id;
        inverter.Description__c  = 'M215-60-240-S22';
        inverter.End_Clamp_Type__c = 'F End Clamp';  
        inverter.Make__c  = 'Enphase';
        inverter.Max_Voltage__c = double.valueOf('600');
        inverter.Mid_Clamp_Type__c = 'F Mid Clamp';  
        inverter.Model__c = 'M215-60-240-S22';
        inverter.Rated_Output_W__c = double.valueOf('215');  
        inverter.Unit__c = 'Count';
        insert inverter;
        
        System_Design_Product__c solarinverter = new System_Design_Product__c();
        solarinverter.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Product__c' and r.Name = 'Inverter'].id;
        solarinverter.Description__c  = 'Solar Edge Inverter System';
        solarinverter.End_Clamp_Type__c = 'F End Clamp';  
        solarinverter.Make__c  = 'Enphase';
        solarinverter.Max_Voltage__c = double.valueOf('600');
        solarinverter.Mid_Clamp_Type__c = 'F Mid Clamp';  
        solarinverter.Model__c = 'M215-60-240-S22';
        solarinverter.Rated_Output_W__c = double.valueOf('215');  
        solarinverter.Unit__c = 'Count';
        insert solarinverter;
        
        System_Design_Product__c trench = new System_Design_Product__c();
        trench.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Product__c' and r.Name = 'Trenching'].id;
        trench.Description__c  = 'Test Trench 1 - Aluminum';         
        trench.Unit__c = 'Count';
        trench.Wire_Type__c = 'Aluminum';
        insert trench;
        
        System_Design_Product__c mounting = new System_Design_Product__c();
        mounting.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Product__c' and r.Name = 'Mounting'].id;
        mounting.Description__c  = 'Test Ballasted System';        
       
        insert mounting;
        
        System_Design_Product__c specialPart = new System_Design_Product__c();
        specialPart.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Product__c' and r.Name = 'Special Part'].id;
        specialPart.Description__c  = 'Test Special Part';
		specialPart.Unit__c = 'Count';
		specialPart.Active__c = true;        
       
        insert specialPart;
        
        test.startTest();

        Test.setCurrentPage(Page.SystemDesignEdit);

        ApexPages.StandardController sdController = new ApexPages.StandardController(sdFromSurvey);
        SystemDesignEditControllerExtension extn = new SystemDesignEditControllerExtension(sdController);

        extn.initSDEditMode();
        
        extn.getUtilRateCodeOptions();
        extn.imgURL = 'Test: Image;Data,Test';
        extn.busRatingAmps = '200';
        extn.mainBreakerRatingAmps = '200';
        extn.countofOpenCircuits = '2';
        extn.serviceEntryType = 'TBD';
        extn.meterid = '123';
        
        //Successful
        extn.saveAndNext();
        //If this line fails, the record did not insert.
        id sdID = [select id from System_Design__c where Survey__c =: surveyID].id;
        
        System_Design__c sd = [select 
                                    id, 
                                    Survey__c, 
                                    Property__c, 
                                    Property__r.Property_City__c,
                                    Property__r.Property_State__c,
                                    Property__r.Utility_Company__c,
                                    Property__r.Property_Owner__c,
                                    Property__r.Property_Owner__r.Client_Last_Name__c, 
                                    Default_CB_Panel__c,
                                    System_Panel__c, 
                                    System_Inverter__c, 
                                    Notes__c
                                from System_Design__c where Survey__c =: surveyID];
        
        //Assign default mounting for ps
        Physical_Surface__c ps = [SELECT id, Default_Mounting__c FROM Physical_Surface__c WHERE Property__c =: sd.Property__c];
        ps.Default_Mounting__c = panel.id;        
        update ps;

        //ArraysPage now
        Test.setCurrentPage(Page.SystemDesignArraysEdit);

        sdController = new ApexPages.StandardController(sd);
        extn = new SystemDesignEditControllerExtension(sdController);

        extn.initArrayEditMode();
        //getter methods
        list<SystemDesignEditControllerExtension.cSurface> cSurfaceList = extn.cSurfaceList; 
        
        //Fill out the install locations, select panel, save and assert that arrays and items are added.
        extn.sysDesign.System_Panel__c = panel.id;
        extn.sysDesign.System_Inverter__c = inverter.id;
        
        extn.cSurfaceList[0].cIls[0].quantity = 10;
        extn.calc();
        system.assertEquals(10, extn.panelQty);
		        
        extn.saveArrays();
        
        
        System_Design_Array__c sda = [SELECT Id from System_Design_Array__c WHERE System_Design__c = :sd.Id LIMIT 1];
        
        System.debug(loggingLevel.ERROR, 'sdaid:' + sda.Id);
        System_Design_Item__c sdi = new System_Design_Item__c();
        sdi.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Item__c' and r.Name = 'Mounting'].id;
        sdi.System_Design_Array__c = sda.Id;
        sdi.System_Design_Product__c = mounting.Id;
        sdi.Quantity__c = double.valueOf('1');
        sdi.Astrum_Balance_of_System_Derate_Text__c = 0.964;        
        insert sdi;
        
        System_Design_Item__c sdiTrench = new System_Design_Item__c();
        sdiTrench.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Item__c' and r.Name = 'Trenching'].id;
        sdiTrench.System_Design_Array__c = sda.Id;
        sdiTrench.System_Design_Product__c = trench.Id;
        sdiTrench.Quantity__c = double.valueOf('1');
        sdiTrench.Total_Trenching_Lengthft__c = 5;
        insert sdiTrench;
        sda.Trench_Type__c = trench.Id;
        update sda;
        
        System_Design_Item__c sdiSpecialPart = new System_Design_Item__c();
        sdiSpecialPart.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Item__c' and r.Name = 'Special Part'].id;
        sdiSpecialPart.System_Design_Array__c = sda.Id;
        sdiSpecialPart.System_Design_Product__c = specialPart.Id;
        sdiSpecialPart.Quantity__c = double.valueOf('1');
        insert sdiSpecialPart;
        
		test.stopTest();
        
        System_Design_Array__c sysDesignArray =  [SELECT id, Array_Size_kW__c, Panel_Count__c, Physical_Surface__c, 
                                                            Default_Mounting_Type__c, Special_Parts_Required__c, Survey__c, Trench_Type__c,
                                                            System_Design__c, Name, Utility_Service__c, Electrical_Adder__c,
                                                            Original_Surface_Tilt__c, Original_Surface_Azimuth__c,
                                                            (select id, System_Design_Array__c, Quantity__c, 
                                                                    Install_Location__c, RecordType.DeveloperName,Total_Trenching_Lengthft__c                                                                    
                                                            from System_Design_Items__r 
                                                            where RecordType.DeveloperName in ('Panel', 'Inverter','Trenching','Mounting'))
                                                        FROM System_Design_Array__c
                                                        WHERE Id =: sda.id];
        extn.cSurfaceList[0].sda = sysDesignArray;
        extn.calc();
        extn.saveArrays();
        
        System.currentPageReference().getParameters().put('index', '0');
        extn.getTrenchItems();
        extn.getMountingItems();
        extn.specialParts =new List<System_Design_Item__c>{sdiSpecialPart};
        extn.deleteSpecialParts = new List<System_Design_Item__c>();
        extn.addSpecialPart();
        extn.deleteSpecialPart();
        extn.getImageAttachments();
		extn.cancelExn();
         
    }

}