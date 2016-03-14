/* FILE: SalesOrderLeasingActionControllerTest.cls
 * AUTHOR: Rohit Jain
 * DATE: June 4, 2013
 * PURPOSE: Test class for SalesOrderLeasingActionControllerTest 
 * MODIFICATION HISTORY:
 *
 */

@isTest(seeAllData=true)
public class SalesOrderLeasingActionControllerTest{

    
  static testMethod void LeasingActionReadytoPrepareTest() {
    
    Account customer = new Account(Name = 'Test Customer');
    insert customer;
    Property__c property = CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');
    Opportunity opp = CreateAstrumPM2ProjectTest.createOpportunity(customer.Id, 'Test Oppty');    
    SCRB_SalesOrder__c salesOrder = CreateAstrumPM2ProjectTest.createSalesOrder(property.Id, opp.Id);
    salesOrder.AccountId__c = customer.Id;
    update salesOrder;
    
    //Test.setCurrentPage(Page.CreateAstrumPM2Project);
    ApexPages.StandardController controller = new ApexPages.StandardController(salesOrder);
    //CreateAstrumPM2ProjectExtension extension = new CreateAstrumPM2ProjectExtension(controller);
    //PageReference result = extension.createProject();
    //String projectId = result.getUrl().substring(1);
    
    RootstockAutomation amr = new RootstockAutomation();
    String projectId = amr.createProject(salesOrder );
    
    Test.startTest();
    
    SalesOrderLeasingActionController leasecontroller = new SalesOrderLeasingActionController(controller);
    PageReference result1 = leasecontroller.submitReadyToPrepare();
    
    Test.stopTest();   
    
    PM_Project__c project =  
      [SELECT Id, Lease_Funding_Status__c
      FROM PM_Project__c 
      WHERE Id = :projectid];
    
    
    System.assertEquals(project.Lease_Funding_Status__c, 'Ready to Prepare'); 
      
  }
  
  static testMethod void LeasingActionCancellationTest() {
    
    //Account customer = new Account(Name = 'Test Customer');
    //insert customer;
    //Property__c property = CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');
    //Opportunity opp = CreateAstrumPM2ProjectTest.createOpportunity(customer.Id, 'Test Oppty'); 
    Opportunity opp = CreateTestOpp();  
    opp.StageName = 'Closed - Won'; 
    opp.Lead_Source_Detail__c = 'Unknown';    
    Update opp;
    SCRB_SalesOrder__c salesOrder = CreateAstrumPM2ProjectTest.createSalesOrder(opp.Property__c, opp.Id);
    salesOrder.AccountId__c = opp.AccountId;
    //SOA PB //salesOrder.StatusCode__c = 'Conversion Pending';
    salesOrder.StatusCode__c = 'Canceled';
    update salesOrder;
    
    
    
    //Test.setCurrentPage(Page.CreateAstrumPM2Project);
    ApexPages.StandardController controller = new ApexPages.StandardController(salesOrder);
    //CreateAstrumPM2ProjectExtension extension = new CreateAstrumPM2ProjectExtension(controller);
    //PageReference result = extension.createProject();
    //String projectId = result.getUrl().substring(1);    
    RootstockAutomation amr = new RootstockAutomation();
    String projectId = amr.createProject(salesOrder );
    
    
       
    Test.startTest();
    
    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();    
    req1.setObjectId(salesOrder.Id);
    // Submit the approval request for the account
    //SOA PB //Approval.ProcessResult result4 = Approval.process(req1);
    
    SalesOrderLeasingActionController leasecontroller = new SalesOrderLeasingActionController(controller);
    PageReference result2 = leasecontroller.submitCancellation();
    
    Test.stopTest();   
    
    salesOrder =  
      [SELECT Id, StatusCode__c
      FROM SCRB_SalesOrder__c
      WHERE Id = :salesOrder .Id];
    
    PM_Project__c project =  
      [SELECT Id, Lease_Funding_Status__c
      FROM PM_Project__c 
      WHERE Id = :projectid];
    
    System.assertEquals(project.Lease_Funding_Status__c, 'Cancelled'); 
    System.assertEquals(salesOrder.StatusCode__c, 'Canceled'); 
      
  }
  
  
  static testMethod void SOApprovaltriggerTest() {
    
    Account customer = new Account(Name = 'Test Customer');
    insert customer;
    Property__c property = CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');
    Opportunity opp = CreateAstrumPM2ProjectTest.createOpportunity(customer.Id, 'Test Oppty');    
    SCRB_SalesOrder__c salesOrder = CreateAstrumPM2ProjectTest.createSalesOrder(property.Id, opp.Id);
    salesOrder.AccountId__c = customer.Id;
    salesOrder.StatusCode__c = 'Submit Pending';
    update salesOrder;  
    
    
    //Test.setCurrentPage(Page.CreateAstrumPM2Project);
    ApexPages.StandardController controller = new ApexPages.StandardController(salesOrder);
    //CreateAstrumPM2ProjectExtension extension = new CreateAstrumPM2ProjectExtension(controller);
    //PageReference result = extension.createProject();
    //String projectId = result.getUrl().substring(1);
    
    RootstockAutomation amr = new RootstockAutomation();
    String projectId = amr.createProject(salesOrder );
    
    
    Test.startTest();
    salesOrder.StatusCode__c = 'Conversion Pending';
    update salesOrder;
    
    
    
    PM_Project__c project =  
      [SELECT Id, Lease_Funding_Status__c
      FROM PM_Project__c 
      WHERE Id = :projectid];
    
    
    
    System.assertEquals(project.Lease_Funding_Status__c, 'Change Pending'); 
    
    salesOrder.StatusCode__c = 'Conversion Approved';
    update salesOrder;
    
    Test.stopTest(); 
    
    PM_Project__c project2 =  
      [SELECT Id, Lease_Funding_Status__c
      FROM PM_Project__c 
      WHERE Id = :projectid];
    
    
    
    System.assertEquals(project2.Lease_Funding_Status__c, 'Ready to Install'); 
    
    
     
      
  }
  
  static testMethod void SOBeforeUpdateTriggerTest() {
    
    Account customer = new Account(Name = 'Test Customer');
    insert customer;
    Property__c property = CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');
    Opportunity opp = CreateAstrumPM2ProjectTest.createOpportunity(customer.Id, 'Test Oppty');    
    SCRB_SalesOrder__c salesOrder = CreateAstrumPM2ProjectTest.createSalesOrder(property.Id, opp.Id);
    
    salesOrder.AccountId__c = customer.Id;
    salesOrder.Lease_Fund__c = 'OldTest';
     update salesOrder; 
    Test.startTest();
    
    salesOrder =  
      [SELECT Id, StatusCode__c,Lease_Fund__c,Orig_Lease_Fund__c
      FROM SCRB_SalesOrder__c
      WHERE Id = :salesOrder.Id];
      
    salesOrder.StatusCode__c = 'Conversion Pending';
    salesOrder.Approval_Comment_Check__C = 'Requested';
    salesOrder.Lease_Fund__c = 'Test';
    update salesOrder; 
    
    
    salesOrder =  
      [SELECT Id, StatusCode__c,Lease_Fund__c,Orig_Lease_Fund__c
      FROM SCRB_SalesOrder__c
      WHERE Id = :salesOrder.Id];
    
    System.assertEquals(salesOrder.Orig_Lease_Fund__c, 'OldTest');
    //System.assertEquals(null, salesOrder.Orig_Lease_Fund__c);   //05/14/15
    System.assertEquals(salesOrder.Lease_Fund__c, 'Test'); 
    
    salesOrder.StatusCode__c = 'New'; 
    salesOrder.Lease_Fund__c = 'New Test'; 
    update salesOrder;    
    
    
    salesOrder.StatusCode__c = 'Conversion Pending';
    update salesOrder; 
    Test.stopTest();
    
     salesOrder =  
      [SELECT Id, StatusCode__c,Lease_Fund__c,Orig_Lease_Fund__c
      FROM SCRB_SalesOrder__c
      WHERE Id = :salesOrder.Id];
    
    System.assertEquals(salesOrder.Orig_Lease_Fund__c, 'OldTest');
    //System.assertEquals(null, salesOrder.Orig_Lease_Fund__c);   //05/14/15  
    System.assertEquals(salesOrder.Lease_Fund__c, 'New Test'); 
      
  }
  
   private static Property__c CreateTestProp(String AcctId,ID ucId){
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
        prop.Utility_Company__c = ucId;
       
        Database.Saveresult propDBResult = Database.Insert(prop,false);
        Id propId = propDBResult.getId();
        if(propId == null){
          System.debug('propDBResult Insert Errors --> ' + propDBResult.getErrors());
        }
        System.debug('Added Property with Id --> ' + propId);
        
       
       return prop;
    }
  
  private static Opportunity CreateTestOpp(){

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
       op.Leasing_Option__c = null;
       
       Property__c prop = CreateTestProp(acct.id,ucId);
       
      
       
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
        
        
        
        System_Design_Item__c sdi = new System_Design_Item__c();
        sdi.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Item__c' and r.Name = 'Panel'].id;
        sdi.System_Design_Array__c = sda.Id;
        sdi.Install_Location__c = instLoc.Id;
        sdi.System_Design_Product__c = sdp.Id;
        sdi.Quantity__c = double.valueOf('29');
        sdi.Annual_Solar_Access__c = double.valueOf('100');
        sdi.NRG_Site_Quality__c= double.valueOf('90');
        sdi.Rated_Output_kW__c = 12;
        sdi.Tilt__c = double.valueOf('3');
        sdi.Azimuth__c = double.valueOf('3');
        sdi.Astrum_PV_Watts_Site_Quality__c = double.valueOf('1200');
        
        
        
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
       
       
       op.Property__c = prop.id;
       
       insert op;
       
        return op;
    }   
}