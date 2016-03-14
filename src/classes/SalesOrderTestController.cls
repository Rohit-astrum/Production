@isTest
private class SalesOrderTestController {

        
      private static Property__c CreateTestProp(String AcctId){
         Property__c prop = new Property__c();
         prop.Name = '123 Main St';
         prop.Property_Owner__c = AcctId;
         
        prop.Optimal_Site_Quality_kWh_y_kW__c = double.valueOf('1250');
        prop.Property_State__c = 'MD';
        prop.Property_City__c = 'Annapolis Junction';
        prop.Property_ZIP__c = '20701';
        prop.Permit_Jurisdiction__c = 'Howard';
        prop.Property_County__c = 'Howard';
        prop.Astrum_Office__c = testdata.defaultOffLocationName;// FPO Phase4 //'Annapolis Junction, MD';
         
        Database.Saveresult propDBResult = Database.Insert(prop,false);
        Id propId = propDBResult.getId();
        if(propId == null){
            System.debug('propDBResult Insert Errors --> ' + propDBResult.getErrors());
        }
        System.debug('Added Property with Id --> ' + propId);
         
         
         return prop;
      }     
      
      private static Opportunity CreateTestOpp(){
        //Populate the Opportunity ID query parameter
       Account acct = new Account();
       acct.name='TestAcct';
       insert acct;
       System.Debug('Account:' + acct.id);
       
       Opportunity op = new Opportunity(); 
       OpportunityLineItem li= new OpportunityLineItem();
       List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
       Product2 product = new Product2();
       product.Name='testProduct223';
       insert product;
       PriceBook2 pbook2=[select id, Name from PriceBook2 where Name='Standard Price Book'];
              
       PriceBookEntry prod = new PricebookEntry();
       prod.UnitPrice = 2.32;
       prod.PriceBook2Id = pbook2.id;
       prod.UseStandardPrice=FALSE;
       prod.Product2ID=product.id;
       prod.IsActive     = true;
       insert prod;
       
       System.debug('Account Created with Id --> ' + acct.id);
       op.AccountId = acct.id;
       op.Name='Test Opportunity223';
       op.StageName = 'Submit Pending';
       op.CloseDate= Date.Today();
       op.Financing_Type__c = 'Purchase';
       op.Financing_Option__c = 'No Financing';
       
       Property__c prop = CreateTestProp(acct.id);
       
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
        mainPanel.Main_Breaker_Rating_Amps__c = double.valueOf('200');
        
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
            sdp.Make__c = 'Sanyo';
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
        
        
        
        System_Design_Item__c sdi = new System_Design_Item__c();
        sdi.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Item__c' and r.Name = 'Panel'].id;
        sdi.System_Design_Array__c = sdaId;
        sdi.Install_Location__c = instLocId;
        sdi.System_Design_Product__c = sdp.Id;
        sdi.Quantity__c = double.valueOf('29');
        
        
        
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
        System.debug('Added System_Design_Quote__c with Id --> ' + sdqId);
   

       
        op.SREC__c = 'Yearly';
        op.State_Grant_Amount__c = double.valueOf('100.00');
        op.System_Design_Quote__c = sdqId;
        op.Leasing_Option__c = null;
       
       
       op.Property__c = prop.id;
       
       insert op;


        Contact c = new Contact();
        c.FirstName = 'Pete';
        c.LastName = 'Varga';
        c.AccountId = op.AccountId;
        Database.Saveresult contactDBResult = Database.Insert(c,false);
        Id cId = contactDBResult.getId();
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = cId;
        ocr.IsPrimary = true;
        ocr.Role = 'Decision Maker';
        ocr.OpportunityId = op.Id;
        
        
        Database.Saveresult ocrDBResult = Database.Insert(ocr,false);
        Id ocrId = ocrDBResult.getId();


       li.PriceBookEntryID = prod.id;
       li.OpportunityId = op.Id;
       li.UnitPrice=2.32;
       li.Quantity= 1;
       lineItems.add(li);
       insert lineItems[0];
       return op;

              } 
              
       private static SCRB_SalesOrder__c CreateTestOrder(){
        Opportunity op= CreateTestOpp();
        SCRB_SalesOrder__c order = new SCRB_SalesOrder__c();
        SCRB_SalesOrderLineItem__c[] salesOrderLineItems = new SCRB_SalesOrderLineItem__c[1];
        SCRB_SalesOrderLineItem__c salesOrderLineItem = new SCRB_SalesOrderLineItem__c();
        
        order.name = op.name;
        order.AccountId__c = op.AccountId;
        order.OpportunityId__c = op.Id;
        order.StatusCode__c = 'Submitted';
        
        System.Debug('op.Property__r.id --> ' + op.Property__r.id);
        System.Debug('op.Property__c --> ' + op.Property__c);
        order.Property__c = op.Property__c;
        
        insert order;
        
         Product2 product = new Product2();
         product.Name='testProduct223';
         insert product;
         PriceBook2 pbook2=[select id, Name from PriceBook2 where Name='Standard Price Book'];
              
       PriceBookEntry prod = new PricebookEntry();
       prod.UnitPrice = 2.32;
       prod.PriceBook2Id = pbook2.id;
       prod.UseStandardPrice=FALSE;
       prod.Product2ID=product.id;
       prod.IsActive     = true;
       insert prod;
       
         salesOrderLineItem.SalesOrderId__c=order.Id;
         salesOrderLineItem.SortOrder__c = 1;
         salesOrderlineItem.ProductId__c = product.id;
         salesOrderLineItem.Quantity__c = 1;
         salesOrderLineItem.ListPrice__c= 2.32;
         salesOrderLineItem.SalesPrice__c=2.32;
         salesOrderLineItem.TotalPrice__c=2.32;
         salesOrderLineItem.RequestedShipmentOn__c=Date.Today();
         //SalesOrderLineItems.add(salesOrderLineItem); 
         
         insert SalesOrderLineItem;     
         
        return order;               
       }

      //*******************************************************************  
      //*Tests that the Page Loads with after being passed an opportunity id.  
      //**********************************************************************
      public static testMethod void TestLoadPage() {
        
        PageReference pageRef = Page.TestSalesOrder;
        Test.setCurrentPage(pageRef);
        Opportunity op = CreateTestOpp();
                          
        ApexPages.currentPage().getParameters().put('oId', op.Id);
  
        //Load the Page
        SalesOrderController controller = new SalesOrderController();
            
           
      }
             
        //****************************************************************************
        //*  Tests that the Page saves with defaults  
        //**************************************************************************** 
          public static testMethod void TestCreateOrderSubmit() {
      
            PageReference pageRef = Page.TestSalesOrder;
            Test.setCurrentPage(pageRef);
      
            Opportunity op = CreateTestOpp();  
            SCRB_SalesOrder__c ord = new SCRB_SalesOrder__c();
            //Populate the Opportunity ID query parameter
            ApexPages.currentPage().getParameters().put('oId', op.Id);
  
            //Load the Page
            SalesOrderController controller = new SalesOrderController();
            System.debug('controller  --> ' + controller);
            controller.save();
          }
          
         //Tests that the Cancel Method returns to the appropriate source opportunity        
         public static testMethod void TestCreateSalesOrderCancel(){
     
            PageReference pageRef = Page.TestSalesOrder;
            Test.setCurrentPage(pageRef);
      
            Opportunity op = CreateTestOpp();  
            ApexPages.currentPage().getParameters().put('oId', op.Id);
  
            SalesOrderController controller = new SalesOrderController();
            string cancelPage = controller.cancel().getUrl();
        
            System.Debug('Cancel Page:'+ cancelPage);
         
            //System.assertEquals(cancelPage,'/'+op.Id);
        
     }

      //Tests that an existing sales order can be cancelled.  
      public static testMethod void TestCancelSalesOrderOK() {
      
        PageReference pageRef = Page.TestSalesOrder;
        Test.setCurrentPage(pageRef);
      
         SCRB_SalesOrder__c ord = CreateTestOrder();

        ApexPages.currentPage().getParameters().put('id', ord.Id);
  
        //Load the Page
        CancelSalesOrderController controller = new CancelSalesOrderController();
            
        String nextPage = controller.OK().getUrl();      
        //User u1 = [select id from User where alias='auser'];

             }
             
     //Tests that the Cancel Method returns to the appropriate source opportunity        
     public static testMethod void TestCancelSalesOrderCancel(){
     
        PageReference pageRef = Page.TestSalesOrder;
        Test.setCurrentPage(pageRef);
       SCRB_SalesOrder__c ord = CreateTestOrder();
        
                
        ApexPages.currentPage().getParameters().put('id', ord.id);
  
        CancelSalesOrderController controller = new CancelSalesOrderController();
        string cancelPage = controller.cancel().getUrl();
        
        System.Debug('Cancel Page:'+ cancelPage);
         
        // System.assertEquals(cancelPage,'/006A0000003CFdD');
        
     }

     public static testmethod void salesorderCancellationEmailTest(){
        SCRB_SalesOrder__c ord = CreateTestOrder();
        PM_Project__c pmproject = new PM_Project__c(name='test proj', Sales_Order__c = ord.Id);
        insert pmproject;

        Test.startTest();
        SalesOrderCancellationEmailController contr = new SalesOrderCancellationEmailController();
        contr.getSalesOrderInfo();
        Test.stopTest();
     }
}