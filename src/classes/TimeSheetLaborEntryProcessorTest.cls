/* FILE: TimeSheetLaborEntryProcessorTest.cls
 * AUTHOR: Pavitra Burla
 * DATE: Jan 22, 2015
 * PURPOSE: Test for TimeSheetEntryProcessor and TimeSheetRootStockLaborEntryBatch
 * MODIFICATION HISTORY
 * 04/03/2015 SZ, update for the Home_Office__c changed to lookup from picklist
 * 07/16/2015 PB FPO Phase2- Set active field on Office Location
 */
@isTest(seeAllData=true)
public class TimeSheetLaborEntryProcessorTest {
    
    static testMethod void runLaborProcessor(){
        
        SCRB_SalesOrder__c salesOrder = createSalesOrder();
        String rstkSOCustId = updateAccount(salesOrder.AccountId__c);
        PM_Project__c pmProj = createProject(salesOrder);
        rstk__pjproj__c projMaster = createProjectMaster(pmProj, salesOrder);
        rstk__peitem__c engItemMaster =  createEngineeringItemMaster(pmProj, salesOrder);
        rstk__soprod__c prdMaster =  createProductMaster(pmProj, salesOrder, engItemMaster);
        
        Test.startTest();
        
        rstk__sohdr__c rskSalesOrd = createRootstockSalesOrder(pmProj, salesOrder, rstkSOCustId, prdMaster, projMaster );        
        List<Employee__c> employees = createEmployees();
        Install_Team__c team = createInstallTeam(employees);
        
        Install_Project__c[] deleteProjects = [SELECT PM_Project__c FROM Install_Project__c WHERE PM_Project__c = :pmProj.ID];  //DK 10/21/15: Resolving a duplicate value error
        delete deleteProjects;  //This is only a test context, so it's okay

        Install_Project__c installProj = createInstallProj(pmProj,team);        
        List<Time_Sheet__c> timeSheets = createTimeSheets(employees);
        List<Time_Sheet_Entry__c> timeSheetEntries = createTimeSheetEntries(timeSheets, installProj);
        
        String endOfWeek =  String.valueof(date.today().addDays(-7).toStartOfWeek().addDays(8));
    String startOfWeek =  String.valueof(date.today().addDays(-7).toStartOfWeek().addDays(1));
        
        // SZ: update the query to retrieve the State__c from the lookup
        String query = 'SELECT End_Time__c,Entry_Date__c,Id,Name,Posted__c,Project_Client_Job__r.Work_Order__c, Project_Client_Job__r.Work_Order__r.rstk__wocst_qtyreq__c, Project_Client_Job__r.Work_Order__r.rstk__externalid__c ,Start_Time__c,Timesheet_Purpose__r.name, Timesheet_Purpose__r.DE_Code__c ,Time_Sheet__r.Employee__c,Time_Sheet__r.Employee__r.Home_Office_Location__r.State__c,Total_Hours__c,Time_Sheet__r.Employee__r.Employee_Number__c';
        query+= ' FROM Time_Sheet_Entry__c';
        query+= ' WHERE Posted__c = true';
        query+= ' AND Entry_Date__c >=' + startOfWeek;
        query+= ' AND Entry_Date__c <' + endOfWeek;
        query+= ' AND Timesheet_Purpose__r.DE_Code__c = \'9005\'';
        query+= ' AND Labor_Processed__c = false';
        query+= ' AND Total_Hours__c > 0';
        query+= ' AND Id IN(\''+ timeSheetEntries[0].Id + '\',\'' + timeSheetEntries[1].Id + '\')';
        query+= ' ORDER BY Time_Sheet__r.Employee__r.Employee_Number__c, Entry_Date__c';
        
        // SZ: update the query to retrieve the State__c from the lookup
        String query2 = 'SELECT End_Time__c,Entry_Date__c,Id,Name,Posted__c,Project_Client_Job__r.Work_Order__c, Project_Client_Job__r.Work_Order__r.rstk__wocst_qtyreq__c, Project_Client_Job__r.Work_Order__r.rstk__externalid__c ,Start_Time__c,Timesheet_Purpose__r.name, Timesheet_Purpose__r.DE_Code__c ,Time_Sheet__r.Employee__c,Time_Sheet__r.Employee__r.Home_Office_Location__r.State__c,Total_Hours__c,Time_Sheet__r.Employee__r.Employee_Number__c';
        query2+= ' FROM Time_Sheet_Entry__c';
        query2+= ' WHERE Posted__c = true';
        query2+= ' AND Entry_Date__c >=' + startOfWeek;
        query2+= ' AND Entry_Date__c <' + endOfWeek;
        query2+= ' AND Timesheet_Purpose__r.DE_Code__c = \'9005\'';
        query2+= ' AND Labor_Processed__c = false';
        query2+= ' AND Total_Hours__c > 0';
        query2+= ' AND Id =\''+ timeSheetEntries[2].Id + '\'';
        query2+= ' ORDER BY Time_Sheet__r.Employee__r.Employee_Number__c, Entry_Date__c';
        
        TimeSheetLaborEntryProcessor processor = new TimeSheetLaborEntryProcessor();
        
        processor.processLabor(query);
        List<TimeSheet_Labor_Entry__c> lbrEntries = [SELECT Id, Status__c, Source_Program__c
                                                    , Transaction_Type__c, Work_Order__r.Id
                                                    , Work_Order_Operation__r.Id, Transaction_Qty__c
                                                    , Rate_Factor__c, Labor_Booking_Hours__c
                                                    , Booking_User__r.Id, Posted__c
                                                    FROM TimeSheet_Labor_Entry__c 
                                                    WHERE Time_Sheet_Entry__c =: timeSheetEntries[0].Id];
        //Verify results
        System.assertEquals(3, lbrEntries.size());
        System.assertEquals('New', lbrEntries[0].Status__c);
        
        TimeSheetLaborEntryEoMProcessor processorEoM = new TimeSheetLaborEntryEoMProcessor();
        processorEoM.processLabor(query2);
        List<TimeSheet_Labor_Entry__c> lbrEntriesEoM = [SELECT Id, Status__c, Source_Program__c
                                                    , Transaction_Type__c, Work_Order__r.Id
                                                    , Work_Order_Operation__r.Id, Transaction_Qty__c
                                                    , Rate_Factor__c, Labor_Booking_Hours__c
                                                    , Booking_User__r.Id, Posted__c
                                                    FROM TimeSheet_Labor_Entry__c 
                                                    WHERE Time_Sheet_Entry__c =: timeSheetEntries[2].Id];
        //Verify results
        if(lbrEntriesEoM.size() > 0){//If this test runs after the week of 15th, lbrEntriesEoM size will be zero
            System.assertEquals(3, lbrEntries.size());
            System.assertEquals('New', lbrEntriesEoM[0].Status__c);
        }
                   
    TimeSheetRootStockLaborEntryBatch batch = new TimeSheetRootStockLaborEntryBatch();
        Database.QueryLocator ql = batch.start(null);
        batch.execute(null, new List<TimeSheet_Labor_Entry__c> { lbrEntries[0] });
        batch.batchErrors = 'Test Errs';
        batch.finish(null);
        Test.stopTest();
        
        //Verify Results
        TimeSheet_Labor_Entry__c lbrEntry = [SELECT Id, Status__c 
                            FROM TimeSheet_Labor_Entry__c 
                            WHERE Id=:lbrEntries[0].Id];
        System.assertEquals(true, (!lbrEntry.Status__c.equals('New')));
        
    }
    
    public static Property__c createProperty(Id ownerId, String name) {
        //Office_Location__c coronaOffice = new Office_Location__c(Name='Corona, CA', Street__c='123 Test St', City__c='Corona', State__c='CA', Zip_Code__c='10101', Active__c = true);
        //insert coronaOffice;

        Property__c property = new Property__c(
            Name = name,
            Property_Owner__c = ownerId,
            Property_City__c = 'West Chester',
            Property_State__c = 'PA',
            Property_Zip__c = '19380',
            Property_County__c = 'Chester, PA',
            Astrum_Office__c = 'Norristown, PA'            
        );
        insert property;


        return property;
    }
    
    public static SCRB_SalesOrder__c createSalesOrder(){
        
        Account customer = new Account(Name = 'Test Customer', BillingStreet = '244 Torrey Pine', BillingState = 'PA' , BillingPostalCode = '19380', BillingCountry = 'USA' ,BillingCity = 'West Chester');
        insert customer;
        Property__c property = createProperty(customer.Id, '117 Birchwood Drive');
        Opportunity opp = CreateAstrumPM2ProjectTest.createOpportunity(customer.Id, 'Test Oppty');     
        SCRB_SalesOrder__c salesOrder = CreateAstrumPM2ProjectTest.createSalesOrder(property.Id, opp.Id);
        salesOrder.AccountId__c = customer.Id;
        salesOrder.StatusCode__c = 'Final/Accounting Approved';
        salesOrder.Opportunity_Close_Date__c = System.today().addDays(-8);
        update salesOrder;
        
        salesOrder = 
            [SELECT Id, Name, AccountId__c, AccountId__r.Name, RequestedShipmentOn__c
             , StatusCode__c, OpportunityId__r.OwnerId, Job_Id__c
             , Property__r.Astrum_Office_New__r.Rootstock_Division__c
             , Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c
             , Opportunity_Close_Date__c, Amount__c
            FROM SCRB_SalesOrder__c 
            WHERE Id = :salesOrder.Id];

        System.debug('*** ' + salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c);

        return salesOrder;
    }
    
    public static String updateAccount(Id AccountId) {
        
        List<Account> accts = [SELECT a.BillingStreet, a.BillingState, a.BillingPostalCode
                               , a.BillingCountry, a.BillingCity, a.ShippingStreet
                               , a.ShippingState, a.ShippingPostalCode, a.ShippingCountry
                               , a.ShippingCity, rstk__Rootstock_Customer__c
                               ,  a.c2g__CODATaxCode1__c, a.Accounting_Id__c 
                               FROM Account a 
                               WHERE Id = :AccountId];
        if( accts.size() == 0 ) {
          //No account exists for this Sales Order
          return null;
        }

        Account acct = accts[0];

        Boolean updateFlag = false;
        // Flag the Account as Rootsstock Customer
        if(!acct.rstk__Rootstock_Customer__c)
        {
            acct.rstk__Rootstock_Customer__c = true;            
            updateFlag = true;
        }
        // If Country is blank fill it with 'USA'
        if( (acct.BillingCountry == null) || (acct.BillingCountry.length() == 0) ) {
            acct.BillingCountry = 'USA';
            acct.ShippingCountry = 'USA';
             updateFlag = true;
        }
         // Populate Tax Code with Tax Exempt
        if(acct.c2g__CODATaxCode1__c == null)
        {
            c2g__codaTaxCode__c taxCode = [SELECT c.Name, c.Id 
                                           FROM c2g__codaTaxCode__c c 
                                           WHERE Name = 'Tax Exempt' limit 1];
            acct.c2g__CODATaxCode1__c = taxCode.Id;
            updateFlag = true;
        }    
        // If Shipping Address is Null Copy it from Billing Address
        if (acct.ShippingStreet == null || acct.ShippingStreet == '')
        {
            acct.ShippingStreet = acct.BillingStreet;
            acct.ShippingState= acct.BillingState;
            acct.ShippingPostalCode = acct.BillingPostalCode;
            acct.ShippingCity = acct.BillingCity;
            acct.ShippingCountry= acct.BillingCountry;
            updateFlag = true;
        }
        if(updateFlag)
        {
           acct.c2g__CODAAccountTradingCurrency__c = 'USD';
           update acct;
        }         
        
        // Query Rootstcok Customer 
        rstk__socust__c socust = [SELECT r.rstk__socust_sf_account_name__c, r.rstk__socust_sf_account__c
                                  , r.Name, r.Id 
                                  FROM rstk__socust__c r 
                                  WHERE r.rstk__socust_custno__c = :acct.Accounting_Id__c];
        return socust.Id;
         
    }
    
    public static PM_Project__c createProject(SCRB_SalesOrder__c salesOrder) {
        
        //create a new PM 2.0 project
        PM_Project__c newProject = new PM_Project__c(
            Name = salesOrder.AccountId__r.Name,
            Sales_Order__c = salesOrder.Id,
            Salesperson__c = salesOrder.OpportunityId__r.OwnerId
        );
        
        Date requestedInstall = salesOrder.RequestedShipmentOn__c;
        if (requestedInstall == null) {
            requestedInstall = Date.today().addDays(90);
        }
        newProject.Install__c = nextWeekday(requestedInstall); 
        
        //default to noon
        newProject.Kickoff__c = Datetime.newInstance(nextWeekDay(Date.today().addDays(7)), Time.newInstance(12,0,0,0));
        
        insert newProject;
        newProject = [SELECT Id, Name, Install__c FROM PM_Project__c WHERE Id =:newProject.Id];
        
        return newProject;
        
    }
    
    private static Date nextWeekday(Date dt) {
      
      Date startOfWeek = dt.toStartOfWeek();
      Integer days = startOfWeek.daysBetween(dt);
      if (days == 0) { //Sunday
        return dt.addDays(1);
      } 
      if (days == 6) { //Saturday
        return dt.addDays(2);
      }
      return dt;
        
    }

    public static rstk__pjproj__c createProjectMaster( PM_Project__c project, SCRB_SalesOrder__c salesOrder ) {
        
        rstk__pjproj__c pjproj;
        List<rstk__pjproj__c> pjprojs = [SELECT Id, Name, rstk__externalid__c, rstk__pjproj_div__c
                                         , rstk__pjproj_descr__c, rstk__pjproj_proj__c 
                                         FROM rstk__pjproj__c 
                                         WHERE rstk__pjproj_div__c = :salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c 
                                         AND rstk__pjproj_proj__c = :salesOrder.Job_Id__c];
        
        if( pjprojs.size() > 0 ) {
          pjproj = pjprojs[0];
        } else {
          // Create Project Master 
          pjproj = new rstk__pjproj__c(
            rstk__pjproj_div__c = salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c,         
            rstk__pjproj_descr__c = project.Name,
            rstk__pjproj_proj__c = salesOrder.Job_Id__c
            );
          insert pjproj ;
        }
        return pjproj;
        
    }

    public static rstk__peitem__c createEngineeringItemMaster( PM_Project__c project, SCRB_SalesOrder__c salesOrder ) {
        
        // Create Engineering Item Master        
        rstk__peitem__c peitem;
        
        rstk__Iccomcod__c  commcode = [SELECT Id FROM rstk__Iccomcod__c WHERE rstk__externalid__c =: salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c + '_Routing'];  
        
        rstk__sydiv__c div = [SELECT Id, rstk__externalid__c FROM rstk__sydiv__c WHERE rstk__externalid__c = '300']; // Maryland Division
        
        List<rstk__peitem__c> peitems = [SELECT Id, Name, rstk__externalid__c, rstk__peitem_item__c
                                         , rstk__peitem_iccomcod__c 
                                         FROM rstk__peitem__c 
                                         WHERE rstk__externalid__c =: div.rstk__externalid__c + '_' + salesOrder.Job_Id__c];
          if( peitems.size() > 0 ) {
            peitem = peitems[0];
          } else {
            peitem = new rstk__peitem__c(
               rstk__peitem_div__c = div.Id,         
               rstk__peitem_item__c = salesOrder.Job_Id__c,
               rstk__peitem_descr__c = project.Name,
               rstk__peitem_iccomcod__c = commcode.Id,
               rstk__peitem_status_pl__c = 'Active',
               rstk__peitem_invdiv__c = salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c,
               rstk__peitem_src_pl__c = 'Manufactured',
               rstk__peitem_type_pl__c = 'Standard',
               rstk__peitem_tracklot_pl__c = 'No',
               rstk__peitem_tracksrl_pl__c = 'No'          
               );            
            insert peitem ;
          }
 
    peitem = [SELECT Id, rstk__peitem_item__c FROM rstk__peitem__c WHERE Id =:peitem.Id];
        return peitem;
    }

    public static rstk__soprod__c createProductMaster( PM_Project__c project, SCRB_SalesOrder__c salesOrder, rstk__peitem__c peitem ) {
        
        // Create Product Master 
        rstk__soprod__c product;
        rstk__icitem__c item;
        rstk__socomm__c scomm = [SELECT Id FROM rstk__socomm__c WHERE rstk__socomm_div__c = :salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c];
        
        List<rstk__icitem__c> items = [SELECT r.Id, r.rstk__icitem_item__c, r.rstk__icitem_div__c FROM rstk__icitem__c r WHERE r.rstk__externalid__c =: salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c + '_' + peitem.rstk__peitem_item__c];
        if( items.size() > 0 ) {
            item = items[0];
        } else { 
          rstk__Iccomcod__c  commcode = [Select Id from rstk__Iccomcod__c Where rstk__externalid__c =: salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c + '_Routing'];
          
          // create new Inventory Master
          item = new rstk__icitem__c(
              rstk__icitem_div__c = salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c,
              rstk__icitem_item__c = peitem.Id,
              rstk__icitem_iccomcod__c = commcode.Id,
              Name = peitem.Name
              );
          insert item;
        }
        
        rstk__syuom__c uom = [SELECT Id FROM rstk__syuom__c WHERE rstk__externalid__c = 'EA'];        
        List<rstk__soprod__c> products = [SELECT Id, Name FROM rstk__soprod__c WHERE rstk__externalid__c =: salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c + '_' + peitem.rstk__peitem_item__c];

          if( products.size() > 0 ) {
            product = products[0];
          } else {
            product = new rstk__soprod__c(
               rstk__soprod_div__c = salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c,         
               rstk__soprod_prod__c = peitem.rstk__peitem_item__c,
               rstk__soprod_descr__c = salesOrder.AccountId__r.Name,
               rstk__soprod_prodtype__c = 'Stock',
               rstk__soprod_comcod__c = scomm.Id,
               rstk__soprod_price__c = 0,
               rstk__soprod_icitem__c = item.Id ,
               rstk__soprod_slsuom__c = uom.Id ,
               rstk__soprod_addsfproduct_ui__c = true
               );
            insert product;
          }
        return product;
    }

    public static rstk__sohdr__c createRootstockSalesOrder( PM_Project__c project, SCRB_SalesOrder__c salesOrder, String rstkSOCustId, rstk__soprod__c product, rstk__pjproj__c pjproj ) {
        // Create Sales Order
        LIST<rstk__syterms__c> terms = [SELECT id, name FROM rstk__syterms__c WHERE rstk__externalid__c = '10-60-30'];        
        LIST<rstk__sotax__c> taxlocs = [SELECT id, name FROM rstk__sotax__c WHERE rstk__externalid__c = 'OTHER'];
        
        rstk__sohdr__c sohdr = new rstk__sohdr__c();
        sohdr.rstk__sohdr_div__c = salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c ;
        sohdr.rstk__sohdr_order__c = salesOrder.Name;
        sohdr.rstk__sohdr_orderdate__c = salesOrder.Opportunity_Close_Date__c;
        sohdr.rstk__sohdr_custno__c = rstkSOCustId;
        sohdr.rstk__sohdr_custref__c = salesOrder.Job_Id__c;
        sohdr.rstk__sohdr_proj__c = pjproj.Id;
        if( terms.size() > 0 ) {
          sohdr.rstk__sohdr_terms__c = terms[0].Id;
        }
        if( taxlocs.size() > 0 ) {
          sohdr.rstk__sohdr_taxloc__c = taxlocs[0].Id;
        }

        List<rstk__soline__c> solines = new List<rstk__soline__c>();
        
        rstk__soline__c line = new rstk__soline__c();
        line.rstk__soline_firm__c = true;
        line.rstk__soline_line__c = 1;        
        line.rstk__soline_prod__c = product.id;
        line.rstk__soline_prodtype__c = 'Stock';  // LLH
        line.rstk__soline_qtyorder__c = 1;        
        line.rstk__soline_price__c = salesOrder.Amount__c;        
        
        if( project.Install__c > System.today() ) {               //only assign if Install Date is in the future
          line.rstk__soline_duedate__c = project.Install__c;     // LLH - PM 2.0 Project Install Date
        }
        line.rstk__soline_shipdiv__c = salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c;
        line.rstk__soline_project__c = pjproj.Id;
        List<rstk__syuom__c> uoms = [SELECT id, name FROM rstk__syuom__c WHERE rstk__externalid__c = 'EA'];
        
        if( uoms.size() > 0 ) {
          line.rstk__soline_uom__c = uoms[0].Id;        // Sales UOM
        }

        line.rstk__soline_useconfig__c = true;  // Configure This Time
        line.rstk__soline_firm__c = true;       // Firm True
        line.Sales_Order__c = salesOrder.Id;    // Astrum SCRB Sales Order Reference
        line.PM_Project__c = project.Id;        // Astrum PM Project Reference
        
        solines.add(line);        
        rstk.SalesOrderAPI.createSalesOrder( sohdr, solines);
        
        // add Work Order Id to the PM_Project
        project.Work_Order__c = line.rstk__soline_wocstordno__c;
        
        update project;

        // retrieve Sales Order Header Extension
        rstk__sohdrextn__c sohdrextn = [SELECT Id, Name FROM rstk__sohdrextn__c WHERE rstk__sohdrextn_sohdr__c = :sohdr.Id];
        
        // collect data for Sales Order Header Extention
        LIST<rstk__syacc__c> freightAccts = [SELECT id FROM rstk__syacc__c WHERE rstk__externalid__c =: salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c + '_49950'];
        LIST<rstk__syacc__c> handlingAccts = [SELECT id FROM rstk__syacc__c WHERE rstk__externalid__c =: salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c + '_49950-2'];
        LIST<rstk__syacc__c> packagingAccts = [SELECT id FROM rstk__syacc__c WHERE rstk__externalid__c =: salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c + '_49950-1'];
        
        // Create Sales Order Header Extention
        if( freightAccts.size() == 1 ) {
          sohdrextn.rstk__sohdrextn_freightacct__c = freightAccts[0].Id;
        } else {
          System.debug('NOT FOUND - Frieght Acct for SOHdr where Sales Order: ' + salesOrder.Name);
        }
        if( handlingAccts.size() == 1 ) {
          sohdrextn.rstk__sohdrextn_handlingacct__c = handlingAccts[0].Id;
        } else {
          System.debug('NOT FOUND - Handling Acct for SOHdr where Sales Order: ' + salesOrder.Name);
        }
        if( packagingAccts.size() == 1 ) {
          sohdrextn.rstk__sohdrextn_packageacct__c = packagingAccts[0].Id;
        } else {
          System.debug('NOT FOUND - Packaging Acct for SOHdr where Sales Order: ' + salesOrder.Name);
        }
        // bind SOHdrExtn to SOHdr and save
        update sohdrextn;
        
        return sohdr;
    }

    public static List<Employee__c> createEmployees(){
        // SZ: Use the Office_Location__c
        List<Office_Location__c> offices = new List<Office_Location__c>();

        Office_Location__c coronaOffice = new Office_Location__c(Name='Corona, CA', Street__c='123 Test St', City__c='Corona', State__c='CA', Zip_Code__c='10101', Active__c = true);
        offices.add(coronaOffice);

        Office_Location__c middletownOffice = new Office_Location__c(Name='Middletown, NY', Street__c='123 Test St', City__c='Middletown', State__c='NY', Zip_Code__c='12345', Active__c = true);
        offices.add(middletownOffice);

        insert offices;

        List<Employee__c> employees = new List<Employee__c>();
        Employee__c emp1 = new Employee__c(name='Test Installer1', Department__c='Install', Job_Title__c='Solar Installer', Status__c='W-2',Home_Office_Location__c=coronaOffice.Id);
        employees.add(emp1);        
        Employee__c emp2 = new Employee__c(name='Test Installer2', Department__c='Install', Job_Title__c='Lead Installer', Status__c='W-2',Home_Office_Location__c=middletownOffice.Id);
        employees.add(emp2);        
        insert employees;
        return employees;
        
    }
    
    public static Install_Team__c createInstallTeam(List<Employee__c> employees){
        
        Install_Team__c installTeam = new Install_Team__c();
        installTeam.name = 'Test Install Team';
        installTeam.Team_Lead__c = employees[0].id;
        insert installTeam;
        employees[0].Install_Team__c = installTeam.Id;
        employees[1].Install_Team__c = installTeam.Id;
    update employees;        
        return installTeam;
    }
    
    public static Install_Project__c createInstallProj(PM_Project__c pmProj, Install_Team__c inTeam){
        
        Install_Project__c instProj = new Install_Project__c();
        instProj.name = 'Test Install Project';
        instProj.PM_Project__c = pmProj.Id;
        instProj.Installer_Team__c = inTeam.id;
        instProj.Drive_Time_Office_To_Site__c = 1.0;
        instProj.Electrician_Drive_Time_To_Site__c = 1.0;
        insert instProj;
        return instProj;
        
    }
    
    public static List<Time_Sheet__c> createTimeSheets(List<Employee__c> employees){
        
        Date myDate = date.today();
        Date weekStart = myDate.addDays(-7).toStartofWeek()+1;
        List<Time_Sheet__c> timeSheets = new List<Time_Sheet__c>();
        
        Time_Sheet__c timesheet = new Time_Sheet__c();
        timesheet.Employee__c = employees[0].id;
        timesheet.For_The_Week_Starting__c = weekStart;
        timeSheets.add(timesheet);
        
        Time_Sheet__c timesheetLead = new Time_Sheet__c();
        timesheetLead.Employee__c = employees[1].id;
        timesheetLead.For_The_Week_Starting__c = weekStart;
        timeSheets.add(timesheetLead);        
        insert timeSheets;
        return timeSheets;
        
    }
    
    public static List<Time_Sheet_Entry__c> createTimeSheetEntries(List<Time_Sheet__c> timeSheets, Install_Project__c installProject){
        
        Date dt = date.Today().addDays(-7).toStartOfWeek().addDays(2);
        List<Time_Sheet_Entry__c> timeSheetEntries = new List<Time_Sheet_Entry__c>();
        
        Timesheet_Purpose__c purpose = [SELECT Id FROM Timesheet_Purpose__c WHERE Name = 'Install'];
        
        Time_Sheet_Entry__c timeSheetEntry1 = new Time_Sheet_Entry__c();
        timeSheetEntry1.Start_Time__c = datetime.newInstance(dt,time.newInstance(7, 0, 0, 0));
        timeSheetEntry1.End_Time__c = datetime.newInstance(dt,time.newInstance(20, 0, 0, 0));
        timeSheetEntry1.Project_Client_Job__c = installProject.Id;
        timeSheetEntry1.Half_Hour_Lunch_Break__c = 'No';
        timeSheetEntry1.Time_Sheet__c = timeSheets[0].Id;
        timeSheetEntry1.Timesheet_Purpose__c = purpose.Id;
        timeSheetEntry1.Posted__c = true;
        timeSheetEntries.add(timeSheetEntry1);
        
        Time_Sheet_Entry__c timeSheetEntry2 = new Time_Sheet_Entry__c();
        timeSheetEntry2.Start_Time__c = datetime.newInstance(dt,time.newInstance(7, 0, 0, 0)); 
        timeSheetEntry2.End_Time__c = datetime.newInstance(dt,time.newInstance(20, 0, 0, 0)); 
        timeSheetEntry2.Project_Client_Job__c = installProject.Id;
        timeSheetEntry2.Half_Hour_Lunch_Break__c = 'No';
        timeSheetEntry2.Time_Sheet__c = timeSheets[1].Id;
        timeSheetEntry2.Timesheet_Purpose__c = purpose.Id;
    timeSheetEntry2.Posted__c = true;        
        timeSheetEntries.add(timeSheetEntry2);
        
        Time_Sheet_Entry__c timeSheetEntry3 = new Time_Sheet_Entry__c();
        timeSheetEntry3.Start_Time__c = datetime.newInstance(date.today().toStartOfWeek().addDays(1),time.newInstance(7, 0, 0, 0)); 
        timeSheetEntry3.End_Time__c = datetime.newInstance(date.today().toStartOfWeek().addDays(1),time.newInstance(20, 0, 0, 0)); 
        timeSheetEntry3.Project_Client_Job__c = installProject.Id;
        timeSheetEntry3.Half_Hour_Lunch_Break__c = 'No';
        timeSheetEntry3.Time_Sheet__c = timeSheets[0].Id;
        timeSheetEntry3.Timesheet_Purpose__c = purpose.Id;
    timeSheetEntry3.Posted__c = true;        
        timeSheetEntries.add(timeSheetEntry3);
        
        insert timeSheetEntries;
     return timeSheetEntries;       
        
    }
    
}