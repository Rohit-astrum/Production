//07/11/2012 TCM - add more test coverage
//10/24/2012 TCM - rewrite test coverage
@isTest
private class Test_InstalledSystems_Detail {
    
    static testMethod void testSysDesignItems() {

        Account customer = new Account(Name='Test Customer');
        insert customer;
        
        Property__c property = CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');
        property.Optimal_Site_Quality_kWh_y_kW__c = 1100;
        update property;
        
        System_Design__c sd = new System_Design__c(
            Property__c = property.Id
        );
        insert sd;
        
        System_Design_Quote__c sdq = new System_Design_Quote__c(
            System_Design__c = sd.Id
        );
        insert sdq;
        
        Installed_System__c sys = new Installed_System__c (
            Account__c = customer.Id,
            Quoted_System_Design__c = sdq.Id
        );
        insert sys;
        
        Attachment img = new Attachment (
            ParentId = sys.Id,
            Name = 'system design',
            Body = Blob.valueOf('img')
        );
        insert img;

        Test.setCurrentPage(Page.InstalledSystemsDetail);
        ApexPages.StandardController controller = new ApexPages.StandardController(sys);
        InstalledSystems_Detail extension = new InstalledSystems_Detail(controller);    
        
        List<System_Design_Item__c> items = extension.getSysDesignItems();
        
        System.assertEquals(0, items.size());
        
    }

    static testMethod void testMonthlyProd() {

        Account customer = new Account(Name='Test Customer');
        insert customer;
        
        Installed_System__c sys = new Installed_System__c (
            Account__c = customer.Id
        );
        insert sys;
        
        Monthly_Production__c mProd = new Monthly_Production__c (
            Installed_System__c = sys.Id,
            Start_of_Month__c = System.today()
        );
        insert mProd;

        Test.setCurrentPage(Page.InstalledSystemsDetail);
        ApexPages.StandardController controller = new ApexPages.StandardController(sys);
        InstalledSystems_Detail extension = new InstalledSystems_Detail(controller);    
        
        List<Monthly_Production__c> mProds = extension.production;
        List<InstalledSystems_Detail.ProdWrapper> wProds = extension.getProductionHistory();
        
        System.assertEquals(1, mProds.size());
        System.assertEquals(1, wProds.size());
        
    }    
    
    static testMethod void testAlerts() {

        Account customer = new Account(Name='Test Customer');
        insert customer;
        
        Installed_System__c sys = new Installed_System__c (
            Account__c = customer.Id
        );
        insert sys;
        
        Enphase_Alert__c alert = new Enphase_Alert__c (
            Installed_System__c = sys.Id
        );
        insert alert;

        Test.setCurrentPage(Page.InstalledSystemsDetail);
        ApexPages.StandardController controller = new ApexPages.StandardController(sys);
        InstalledSystems_Detail extension = new InstalledSystems_Detail(controller);    
        
        List<Enphase_Alert__c> alerts = extension.alerts;
        
        System.assertEquals(1, alerts.size());
        
    }    
    
    static testMethod void testSRECS() {
        
        Account customer = new Account(Name='Test Customer');
        insert customer;
        
        Installed_System__c sys = new Installed_System__c (
            Account__c = customer.Id
        );
        insert sys;
        
        SREC_Certificate__c srec = new SREC_Certificate__c ( 
           Installed_System__c = sys.Id 
        ); 
        insert srec; 
        
        Test.setCurrentPage(Page.InstalledSystemsDetail);
        ApexPages.StandardController controller = new ApexPages.StandardController(sys);
        InstalledSystems_Detail extension = new InstalledSystems_Detail(controller);    
        
        List<SREC_Certificate__c> srecs = extension.srecs; 
        
        System.assertEquals(1, srecs.size()); 
        
    }
    
    /*
    private static testmethod void unitTest() {
        Date objDate = Date.today().addMonths(-1);
       
        Account acc = new Account(
            Name = 'Test'
        );
        insert acc;
        
        Installed_System__c installedSysObj = new Installed_System__c(
            Account__c = acc.id,
            Generation_Start_Date__c = Date.newInstance(2009,11,30),
            January_Daily_Peak_Sun_Hours__c = 5,
            February_Daily_Peak_Sun_Hours__c = 5,
            March_Daily_Peak_Sun_Hours__c = 5,
            April_Daily_Peak_Sun_Hours__c = 5,
            May_Daily_Peak_Sun_Hours__c = 5,
            June_Daily_Peak_Sun_Hours__c = 5,
            July_Daily_Peak_Sun_Hours__c = 5,
            August_Daily_Peak_Sun_Hours__c = 5,
            September_Daily_Peak_Sun_Hours__c = 5,
            October_Daily_Peak_Sun_Hours__c = 5,
            November_Daily_Peak_Sun_Hours__c = 5,
            December_Daily_Peak_Sun_Hours__c = 5
        );  // Installation_Year__c = 1900 , System.today()   Date.newInstance(2011,12,30)
        insert installedSysObj;
        
        Blob content = Blob.valueOf('test image');
        Attachment image = new Attachment (
            ParentId = installedSysObj.Id,
            Name = 'systemdesign.png',
            Body = content,
            ContentType = 'image/png'
        );
        insert image;
        image = new Attachment (
            ParentId = installedSysObj.Id,
            Name = 'install.png',
            Body = content,
            ContentType = 'image/png'
        );
        insert image;
        
        Annual_Production__c annProd = new Annual_Production__c(
            Installed_System__c = installedSysObj.id,
            Year__c = 2009,
            January_Actual_Production_kWh__c = 5,
            February_Actual_Production_kWh__c = 5,
            March_Actual_Production_kWh__c = 5,
            April_Actual_Production_kWh__c = 5,
            May_Actual_Production_kWh__c = 5,
            June_Actual_Production_kWh__c = 5,
            July_Actual_Production_kWh__c = 5,
            August_Actual_Production_kWh__c = 5,
            September_Actual_Production_kWh__c = 5,
            October_Actual_Production_kWh__c = 5,
            November_Actual_Production_kWh__c = 5,
            December_Actual_Production_kWh__c = 5,            
            January_Production_Guarantee_kWh__c = 5,
            February_Production_Guarantee_kWh__c = 5,
            March_Production_Guarantee_kWh__c = 5,
            April_Production_Guarantee_kWh__c = 5,
            May_Production_Guarantee_kWh__c = 5,
            June_Production_Guarantee_kWh__c = 5,
            July_Production_Guarantee_kWh__c = 5,
            August_Production_Guarantee_kWh__c = 5,
            September_Production_Guarantee_kWh__c = 5,
            October_Production_Guarantee_kWh__c = 5,
            November_Production_Guarantee_kWh__c = 5,
            December_Production_Guarantee_kWh__c = 5
            
        );
        insert annProd;
        
        Annual_Production__c annProd2 = new Annual_Production__c(
            Installed_System__c = installedSysObj.id,
            Year__c = 2010,
            January_Actual_Production_kWh__c = 5,
            February_Actual_Production_kWh__c = 5,
            March_Actual_Production_kWh__c = 5,
            April_Actual_Production_kWh__c = 5,
            May_Actual_Production_kWh__c = 5,
            June_Actual_Production_kWh__c = 5,
            July_Actual_Production_kWh__c = 5,
            August_Actual_Production_kWh__c = 5,
            September_Actual_Production_kWh__c = 5,
            October_Actual_Production_kWh__c = 5,
            November_Actual_Production_kWh__c = 5,
            December_Actual_Production_kWh__c = 5,            
            January_Production_Guarantee_kWh__c = 5,
            February_Production_Guarantee_kWh__c = 5,
            March_Production_Guarantee_kWh__c = 5,
            April_Production_Guarantee_kWh__c = 5,
            May_Production_Guarantee_kWh__c = 5,
            June_Production_Guarantee_kWh__c = 5,
            July_Production_Guarantee_kWh__c = 5,
            August_Production_Guarantee_kWh__c = 5,
            September_Production_Guarantee_kWh__c = 5,
            October_Production_Guarantee_kWh__c = 5,
            November_Production_Guarantee_kWh__c = 5,
            December_Production_Guarantee_kWh__c = 5
            
        );
        insert annProd2; 

        annProd2 = new Annual_Production__c(
            Installed_System__c = installedSysObj.id,
            Year__c = 2011,
            January_Actual_Production_kWh__c = 5,
            February_Actual_Production_kWh__c = 5,
            March_Actual_Production_kWh__c = 5,
            April_Actual_Production_kWh__c = 5,
            May_Actual_Production_kWh__c = 5,
            June_Actual_Production_kWh__c = 5,
            July_Actual_Production_kWh__c = 5,
            August_Actual_Production_kWh__c = 5,
            September_Actual_Production_kWh__c = 5,
            October_Actual_Production_kWh__c = 5,
            November_Actual_Production_kWh__c = 5,
            December_Actual_Production_kWh__c = 5,            
            January_Production_Guarantee_kWh__c = 5,
            February_Production_Guarantee_kWh__c = 5,
            March_Production_Guarantee_kWh__c = 5,
            April_Production_Guarantee_kWh__c = 5,
            May_Production_Guarantee_kWh__c = 5,
            June_Production_Guarantee_kWh__c = 5,
            July_Production_Guarantee_kWh__c = 5,
            August_Production_Guarantee_kWh__c = 5,
            September_Production_Guarantee_kWh__c = 5,
            October_Production_Guarantee_kWh__c = 5,
            November_Production_Guarantee_kWh__c = 5,
            December_Production_Guarantee_kWh__c = 5
            
        );
        insert annProd2; 
        
        InstalledSystems_Detail ctrl = new InstalledSystems_Detail(new ApexPages.StandardController(installedSysObj));          
        
        ctrl.getInstalledPanelsData();
        ctrl.doSystemCertified();
        ctrl.getSysGrntURL();
        ctrl.getSRECChartURL();
        ctrl.getProductionHistory();
        ctrl.getSysDesignItems();
        ctrl.doDocumentsSubmitted10();
        ctrl.doDocumentsSubmitted60();
        ctrl.doDocumentsSubmitted30();
        ctrl.doInvoiceAuthorized10();
        ctrl.doInvoiceAuthorized60();
        ctrl.doInvoiceAuthorized30();
        
        //force exception
        delete installedSysObj;
        ctrl.doDocumentsSubmitted10();
        ctrl.doDocumentsSubmitted60();
        ctrl.doDocumentsSubmitted30();
        ctrl.doInvoiceAuthorized10();
        ctrl.doInvoiceAuthorized60();
        ctrl.doInvoiceAuthorized30();
    */
        
        
        /*    
        List<Annual_Production__c> objAnnualList1 = [select Id, Installed_System__c from Annual_Production__c where Year__c = 2011];
        
        Id isysId1 = objAnnualList1[0].Installed_System__c;       
        List<Installed_System__c> objInstallList1 = [select Id from Installed_System__c where Id = :isysId1];
        InstalledSystems_Detail ctrl1 = new InstalledSystems_Detail(new ApexPages.StandardController(objInstallList1[0])); 
        ctrl1.getInstalledPanelsData();
        ctrl1.doSystemCertified();
        ctrl1.getSysGrntURL();
        ctrl1.getSRECChartURL();
        ctrl1.getProductionHistory();
        ctrl1.getSysDesignItems();
        */

    //}
    
}