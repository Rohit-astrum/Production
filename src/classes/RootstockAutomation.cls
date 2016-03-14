/* FILE: RootstockAutomation.cls
 * AUTHOR: Rohit Jain
 * DATE: Aug 07, 2013
 * PURPOSE: Creates Astrum PM 2.0 Project and Rootsstock Objects from Sales Order
 * MODIFICATION HISTORY
 * 6/10/14  LLH - begin Rootstock Reintegration Phase 1 - complete 7/31/14
 * 8/1/14   LLH - replace WHERE condition on Rootstock SOQLs to look for 'externalid'
 * 8/26/14  LLH - modified updateWOOpsFromInstall to no longer update Operations that don't have Install Projects
 * 7/22/2015 PB - FPO Phase2 Assign Site when creating rstk SalesOrder and Inventory Item Master
 * 08/12/2015 PB - FPO PhaseIII update primary proj budget cost and primary proj when rootstock objects1 are created
 * 10/12/2015 PB - SOA Remove status code restrictions so that 'Create PM 2.0 Project' button can be clicked at any time in the SO Process 
 * 01/15/2016 PB- FPO Sprint 6- On Rootstock objects recreation transfer components and budget. 
 */
public class RootstockAutomation {
    
    //public class CustomException extends Exception{}
    
    public String processSalesOrder(SCRB_SalesOrder__c salesOrder) {
        //System.debug('SOQL: processSalesOrder: get SCRB Sales Order');
        SCRB_SalesOrder__c so = [Select Name,Property__r.Name,Property__r.Astrum_Office_New__r.Name,Property__r.Astrum_Office_New__r.Rootstock_Division__c
                                       ,AccountId__r.Name, OpportunityId__r.OwnerId,RequestedShipmentOn__c,Job_Id__c,Amount__c,Opportunity_Close_Date__c
                                       ,Rootstock_Sales_Order__c,StatusCode__c, Cleared4PM_Project__c, Property__r.Hours_From_Nearest_Office__c
                                       ,Property__r.Astrum_Office_New__r.Survey_Scheduler__c
                                   From SCRB_SalesOrder__c 
                                  Where Id = :salesOrder.Id];
        //System.debug('SOQL: processSalesOrder: Limits: ' + Limits.getQueries());
        //System.debug('RA: Sales Order: Rootstock Division: ' + so.Property__r.Astrum_Office_New__r.Rootstock_Division__c);
        //System.debug('RA: Sales Order: Hours from nearest office: ' + so.Property__r.Hours_From_Nearest_Office__c);
        
        //System.debug('* '+ so.Name + ' Job id -'+so.Job_Id__c );
        String projectId;
        //String socustId;
       
        //if (so.StatusCode__C != 'Final/Accounting Approved') {
        /* 10/12/2015 PB - SOA - Remove status code restrictions
        if ( !so.Cleared4PM_Project__c ) { // LLH
            System.debug('RA: processSalesOrder: NOT Cleared for PM Project, insert failed.');
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Sales Order should be Final/Accounting Approved in order to create PM 2.0 Project and Rootstock Sales Order.'));           
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Sales Order should be Final/Accounting Approved in order to create PM 2.0 Project.'));    // LLH       
            return null;
        }
        */
        //List<rstk__pjproj__c> rjproj = [SELECT Id FROM rstk__pjproj__c WHERE rstk__pjproj_proj__c = :so.Job_Id__c];
        //System.debug('SOQL: processSalesOrder: get PM Project');
        List<PM_Project__c> pmproj = [SELECT Id FROM PM_Project__c WHERE Sales_Order__c = :so.Id];
        //System.debug('SOQL: processSalesOrder: Limits: ' + Limits.getQueries());

        //if project already exists, display the project      
        // LLH - and yet we don't, we return an error only. Does this need fixing?
        if (pmproj.size() > 0) {
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'A Rootstock Sales Order already exists for this Sales Order.'));           
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'A PM Project already exists for this Sales Order.'));   // LLH
            //return null;

            //return new PageReference('/apex/PMProjectDetail?id=' + pmproj[0].Id + '&sfdc.override=1'); // LLH
            return pmproj[0].Id;
        }
        
        projectId = createProject(so );        

        System.debug('RA: processSalesOrder: created PM Project: ' + projectId);
               
        return projectId ;
    }

    // LLH - new method split from processSalesOrder()
    // this will be called from the PM Project page
    /* ************************ No longer used, replaced by split up methods below
    public String processPMProject( PM_Project__c proj ) {

      //System.debug('SOQL: processPMProject: get PM Project');
      PM_Project__c project = [SELECT Id, name, Sales_Order__c, Job_Id__c, Install__c, Installation_Date__c FROM PM_Project__c WHERE Id = :proj.Id];
      //System.debug('SOQL: processPMProject: Limits: ' + Limits.getQueries());
      // TODO - check return value for valid sObject
      
      //System.debug('SOQL: processPMProject: get SCRB Sales Order');
      SCRB_SalesOrder__c so = [Select Id, Name,Property__r.Name,Property__r.Astrum_Office_New__r.Name,Property__r.Astrum_Office_New__r.Rootstock_Division__c
                                     ,Property__r.Astrum_Office_New__r.Rootstock_Division__r.Name, Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c
                                     ,AccountId__r.Name, OpportunityId__r.OwnerId,RequestedShipmentOn__c,Job_Id__c,Amount__c,Opportunity_Close_Date__c
                                     ,Rootstock_Sales_Order__c,StatusCode__c
                                 From SCRB_SalesOrder__c 
                                Where Id = :project.Sales_Order__c];
      //System.debug('SOQL: processPMProject: Limits: ' + Limits.getQueries());
      // TODO - check return value for valid sObject
      
      String rstkSOCustId;

      //rstkSOCustId = updateAccount( so );
      rstkSOCustId = updateAccount( so.AccountId__c );

      if( rstkSOCustId != null && rstkSOCustId != '' ) {
            createRootStockObjects1( so, project ) ;
            createRootStockObjects2( so, rstkSOCustId, project ) ;
      } else {
          // notify someone of an error condition
          Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
          String[] toAddresses = new String[] {'it@astrumsolar.com'};
          mail.setToAddresses(toAddresses);
          mail.setReplyTo('it@astrumsolar.com');
          mail.setSenderDisplayName('Rootstock Automation error message');
          mail.setSubject('Error from Org : ' + UserInfo.getOrganizationName());
          //mail.setPlainTextBody(e.getMessage());
          mail.setPlainTextBody('No Rootstock Customer Master could be found for this PM Project: ' + project.Id);
          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        return 'ERROR: No Rootstock Customer Master could be found for this PM Project.';
      }

      return null;
    }
    ******************************************** */

    public String processPMProject1( PM_Project__c proj, RootstockAutomation.RootstockObjects raobjs) {

      //System.debug('SOQL: processPMProject: get PM Project');
      PM_Project__c project = [SELECT Id, name, Sales_Order__c, Job_Id__c, Install__c, Installation_Date__c FROM PM_Project__c WHERE Id = :proj.Id];
      //System.debug('SOQL: processPMProject: Limits: ' + Limits.getQueries());
      // TODO - check return value for valid sObject
      
      //System.debug('SOQL: processPMProject: get SCRB Sales Order');
      SCRB_SalesOrder__c so = [Select Id, Name,Property__r.Name,Property__r.Astrum_Office_New__r.Name,Property__r.Astrum_Office_New__r.Rootstock_Division__c
                                     ,Property__r.Astrum_Office_New__r.Rootstock_Division__r.Name, Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c
                                     ,AccountId__r.Name, OpportunityId__r.OwnerId,RequestedShipmentOn__c,Job_Id__c,Amount__c,Opportunity_Close_Date__c
                                     ,Rootstock_Sales_Order__c,StatusCode__c, Property__r.Astrum_Office_New__r.Site__c,Primary_Project_Master__c
                                 From SCRB_SalesOrder__c 
                                Where Id = :project.Sales_Order__c];
      //System.debug('SOQL: processPMProject: Limits: ' + Limits.getQueries());
      // TODO - check return value for valid sObject
      
      //if( rstkSOCustId != null && rstkSOCustId != '' ) {
            createRootStockObjects1( so, project, raobjs) ;
      //} else {
          /*
          // notify someone of an error condition
          Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
          String[] toAddresses = new String[] {'it@astrumsolar.com'};
          mail.setToAddresses(toAddresses);
          mail.setReplyTo('it@astrumsolar.com');
          mail.setSenderDisplayName('Rootstock Automation error message');
          mail.setSubject('Error from Org : ' + UserInfo.getOrganizationName());
          //mail.setPlainTextBody(e.getMessage());
          mail.setPlainTextBody('No Rootstock Customer Master could be found for this PM Project: ' + project.Id);
          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

          return 'ERROR: No Rootstock Customer Master could be found for this PM Project.';
          */
      //}

      return null;
    }

    public String processPMProject2( PM_Project__c proj, RootstockAutomation.RootstockObjects raobjs) {

      //System.debug('SOQL: processPMProject: get PM Project');
      PM_Project__c project = [SELECT Id, name, Sales_Order__c, Job_Id__c, Install__c, Installation_Date__c FROM PM_Project__c WHERE Id = :proj.Id];
      //System.debug('SOQL: processPMProject: Limits: ' + Limits.getQueries());
      // TODO - check return value for valid sObject
      
      //System.debug('SOQL: processPMProject: get SCRB Sales Order');
      SCRB_SalesOrder__c so = [Select Id, Name,Property__r.Name,Property__r.Astrum_Office_New__r.Name,Property__r.Astrum_Office_New__r.Rootstock_Division__c
                                     ,Property__r.Astrum_Office_New__r.Rootstock_Division__r.Name, Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c
                                     ,AccountId__r.Name, OpportunityId__r.OwnerId,RequestedShipmentOn__c,Job_Id__c,Amount__c,Opportunity_Close_Date__c
                                     ,Rootstock_Sales_Order__c,StatusCode__c,Property__r.Astrum_Office_New__r.Site__c 
                                 From SCRB_SalesOrder__c 
                                Where Id = :project.Sales_Order__c];
      //System.debug('SOQL: processPMProject: Limits: ' + Limits.getQueries());
      // TODO - check return value for valid sObject
      
      String rstkSOCustId;

      //rstkSOCustId = updateAccount( so );
      rstkSOCustId = updateAccount( so.AccountId__c );

      if( rstkSOCustId != null && rstkSOCustId != '' ) {
            createRootStockObjects2( so, rstkSOCustId, project, raobjs) ;
      } else {
          // notify someone of an error condition
          EmailUtil.AdminEmail('Rootstock Automation', 'Rootstock Automation error message', 'No Rootstock Customer Master could be found for this PM Project: ' + project.Id);

        return 'ERROR: No Rootstock Customer Master could be found for this PM Project.';
      }

      return null;
    }
    // end - LLH

    public String updateAccount(Id AccountId) {   // LLH

      // this method will update Account information if needed
      // BUT will always return the Rootstock Customer Master Id
      // unless one does not exist
    
        //System.debug('SOQL: updateAccount: get Accounts');
//        List<Account> accts = [Select a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity, a.ShippingStreet, a.ShippingState, a.ShippingPostalCode
//                             , a.ShippingCountry, a.ShippingCity, rstk__Rootstock_Customer__c ,  a.c2g__CODATaxCode1__c, a.Accounting_Id__c
//                          from Account a Where Id = :salesOrder.AccountId__c];
        List<Account> accts = [Select a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity, a.ShippingStreet, a.ShippingState, a.ShippingPostalCode
                             , a.ShippingCountry, a.ShippingCity, rstk__Rootstock_Customer__c ,  a.c2g__CODATaxCode1__c, a.Accounting_Id__c, a.Name
                          from Account a Where Id = :AccountId];
        //System.debug('SOQL: updateAccount: Limits: ' + Limits.getQueries());
        // LLH - new additions
        if( accts.size() == 0 ) {
          // error condition, no account exists for this Sales Order
          return null;
        }

        Account acct = accts[0];

        // end - LLH

        Boolean updateFlag = false;
        // Flag the Account as Rootsstock Customer
        if(!acct.rstk__Rootstock_Customer__c)
        {
            acct.rstk__Rootstock_Customer__c = true;            
            updateFlag = true;
        }
        // LLH - new addition
        // If Country is blank fill it with 'USA'
        if( (acct.BillingCountry == null) || (acct.BillingCountry.length() == 0) ) {
            acct.BillingCountry = 'USA';
            acct.ShippingCountry = 'USA';
            //System.debug('Account Billing Country was blank. Set to: ' + acct.BillingCountry);
            updateFlag = true;
        }
        // end - LLH
        // Populate Tax Code with Tax Exempt
        if(acct.c2g__CODATaxCode1__c == null)
        {
            //System.debug('SOQL: updateAccount: get taxCode');
            c2g__codaTaxCode__c taxCode = [Select c.Name, c.Id From c2g__codaTaxCode__c c Where Name = 'Tax Exempt' limit 1];
            //System.debug('SOQL: updateAccount: Limits: ' + Limits.getQueries());
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
            //System.debug('DML: updateAccount: update');
            acct.c2g__CODAAccountTradingCurrency__c = 'USD';           
            update acct;
        }         
        
        // Query Rootstcok Customer 
        //System.debug('SOQL: updateAccount: get SO Cust');
        rstk__socust__c socust = [Select r.rstk__socust_sf_account_name__c, r.rstk__socust_sf_account__c, r.Name, r.Id 
                                    From rstk__socust__c r
                                    Where r.rstk__socust_custno__c = :acct.Accounting_Id__c];
        //System.debug('SOQL: updateAccount: Limits: ' + Limits.getQueries());
        
        // 
        /*If customer master is not created create new customer master
        // Query Rootstcok Customer
        rstk__socust__c socust; 
        try{
          socust = [SELECT r.rstk__socust_sf_account_name__c, r.rstk__socust_sf_account__c
                                  , r.Name, r.Id 
                                  FROM rstk__socust__c r 
                                  WHERE r.rstk__socust_custno__c = :acct.Accounting_Id__c];

          }catch(QueryException qe){
            rstk__socclass__c custclass = [select id from rstk__socclass__c ];
            socust = new rstk__socust__c(rstk__socust_sf_account__c = acct.Id
              , rstk__socust_sf_account_name__c = acct.Name
              , rstk__socust_custno__c = acct.Accounting_Id__c
              , rstk__socust_cclass__c = custclass.Id);
            insert socust;
            System.debug('socustid' + socust.Id);
          }
          */ 
        return socust.Id;
         
         
    }

  /*
    public String getSOCust(Id AccountId) {   // LLH

      // this method will return the Rootstock Customer Master Id
      // unless one does not exist
    
        //System.debug('SOQL: updateAccount: get Accounts');
        List<Account> accts = [Select Id, Accounting_Id__c from Account Where Id = :AccountId];
        
        if( accts.size() == 0 ) {
          // error condition, no account exists for this Sales Order
          return null;
        }

        Account acct = accts[0];
        // Query Rootstcok Customer 
        //System.debug('SOQL: updateAccount: get SO Cust');
        rstk__socust__c socust = [Select r.rstk__socust_sf_account_name__c, r.rstk__socust_sf_account__c, r.Name, r.Id 
                                    From rstk__socust__c r
                                    Where r.rstk__socust_custno__c = :acct.Accounting_Id__c];
        //System.debug('SOQL: updateAccount: Limits: ' + Limits.getQueries());
         
        return socust.Id;

        */

/*    
    //public void createRootStockObjects(SCRB_SalesOrder__c salesOrder, String soCustId) {
    public void createRootStockObjects(SCRB_SalesOrder__c salesOrder, String soCustId, PM_Project__c project) {     // LLH
    
        // Create Project Master 
        rstk__pjproj__c pjproj = new rstk__pjproj__c(
           rstk__pjproj_div__c = salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c,         
           //rstk__pjproj_descr__c = salesOrder.AccountId__r.Name,
           rstk__pjproj_descr__c = project.Job_Id__c + '-' + project.Name,    // LLH
           rstk__pjproj_proj__c = salesOrder.Job_Id__c
           );
         

        insert pjproj ;
        System.debug('* salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c '+ salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c); 
        // Create Engineering Item Master
        
        rstk__Iccomcod__c  commcode = [Select Id from rstk__Iccomcod__c Where Name = 'Routing' AND rstk__iccomcod_div__c = :salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c];  
        rstk__sydiv__c div = [Select Id from rstk__sydiv__c Where rstk__externalid__c = '300']; // Maryland Division
        
        rstk__peitem__c peitem = new rstk__peitem__c(
           rstk__peitem_div__c = div.Id,         
           rstk__peitem_item__c = salesOrder.Job_Id__c,
           //rstk__peitem_descr__c = salesOrder.AccountId__r.Name,
           rstk__peitem_descr__c = project.Job_Id__c + '-' + project.Name,    // LLH
           rstk__peitem_iccomcod__c = commcode.Id,
           rstk__peitem_status_pl__c = 'Active',
           rstk__peitem_invdiv__c = salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c,
           rstk__peitem_src_pl__c = 'Manufactured',
           rstk__peitem_type_pl__c = 'Standard',
           rstk__peitem_tracklot_pl__c = 'No',
           rstk__peitem_tracksrl_pl__c = 'No'          
           );
        
        
        insert peitem ;
        System.debug('* peitem '+ peitem );        
        //System.debug('* sydiv '+ salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c );     
        
        rstk__socomm__c scomm = [Select Id from rstk__socomm__c Where rstk__socomm_div__c = :salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c];
        rstk__icitem__c item = [Select r.Id From rstk__icitem__c r Where r.rstk__icitem_item__c = :peitem.Id limit 1 ];
        rstk__syuom__c uom = [Select Id from rstk__syuom__c Where Name = 'EA (Each)'];
         // Create Product Master 
        rstk__soprod__c product = new rstk__soprod__c(
           rstk__soprod_div__c = salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c,         
           //rstk__soprod_prod__c = salesOrder.Job_Id__c,
           rstk__soprod_prod__c = peitem.rstk__peitem_item__c,    // LLH
           rstk__soprod_descr__c = salesOrder.AccountId__r.Name,
           rstk__soprod_prodtype__c = 'Stock',
           rstk__soprod_comcod__c = scomm.Id,
           rstk__soprod_price__c = 0,
           rstk__soprod_icitem__c = item.Id ,
           rstk__soprod_slsuom__c = uom.Id ,
           rstk__soprod_addsfproduct_ui__c = true
           );
        
        
        
        insert product;
        System.debug('* product  '+ product );  
        
        
        LIST<rstk__syterms__c> terms = [SELECT id, name FROM rstk__syterms__c WHERE Name = '10-60-30 (10-60-30)'];
        LIST<rstk__sotax__c> taxlocs = [SELECT id, name FROM rstk__sotax__c WHERE Name = 'OTHER'];
        // Create Sales Order        
        rstk__sohdr__c sohdr = new rstk__sohdr__c();
        sohdr.rstk__sohdr_div__c = salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c ;
        sohdr.rstk__sohdr_order__c = salesOrder.Name;
        sohdr.rstk__sohdr_orderdate__c = salesOrder.Opportunity_Close_Date__c;
        sohdr.rstk__sohdr_custno__c = soCustId;
        sohdr.rstk__sohdr_custref__c = salesOrder.Job_Id__c;
        // LLH - new additions
        if( terms.size() > 0 ) {
          sohdr.rstk__sohdr_terms__c = terms[0].Id;
        }
        if( taxlocs.size() > 0 ) {
          sohdr.rstk__sohdr_taxloc__c = taxlocs[0].Id;
        }
        // TODO - check that the SO Cust Addr is pulled from the Customer Master automatically
        // collect data for Sales Order Header Extention
        LIST<rstk__syacc__c> freightAccts = [SELECT id FROM rstk__syacc__c WHERE rstk__syacc_mfgacct__c = '49950' AND rstk__syacc_div__c = :salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c];
        LIST<rstk__syacc__c> handlingAccts = [SELECT id FROM rstk__syacc__c WHERE rstk__syacc_mfgacct__c = '49950-2' AND rstk__syacc_div__c = :salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c];
        LIST<rstk__syacc__c> packagingAccts = [SELECT id FROM rstk__syacc__c WHERE rstk__syacc_mfgacct__c = '49950-1' AND rstk__syacc_div__c = :salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c];
        // Create Sales Order Header Extention
        rstk__sohdrextn__c sohdrextn = new rstk__sohdrextn__c();
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
        // end - LLH
        
        List<rstk__soline__c> solines = new List<rstk__soline__c>();
        
        rstk__soline__c line = new rstk__soline__c();
        line.rstk__soline_firm__c = true;
        line.rstk__soline_line__c = 1;        
        line.rstk__soline_prod__c = product.id;
        line.rstk__soline_prodtype__c = 'Stock';  // LLH
        line.rstk__soline_qtyorder__c = 1;        
        line.rstk__soline_price__c = salesOrder.Amount__c;        
        // RJ : Changes Today() + 60 days on 10/7/13
        //line.rstk__soline_duedate__c = salesOrder.Opportunity_Close_Date__c.addDays(60);    
        //line.rstk__soline_duedate__c = System.Today().addDays(60);     
        line.rstk__soline_duedate__c = project.Installation_Date__c;     // LLH - PM 2.0 Project Install Date
        line.rstk__soline_shipdiv__c = salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c;
        // Added on 10/16 by RJ
        line.rstk__soline_project__c = pjproj.Id;
        // LLH new additions
        List<rstk__syuom__c> uoms = [SELECT id, name FROM rstk__syuom__c WHERE Name = 'EA (Each)'];
        if( uoms.size() > 0 ) {
          line.rstk__soline_uom__c = uoms[0].Id;        // Sales UOM
        }
        line.rstk__soline_useconfig__c = true;  // Configure This Time
        line.rstk__soline_firm__c = true;       // Firm True
        line.Sales_Order__c = salesOrder.Id;    // Astrum SCRB Sales Order Reference
        line.PM_Project__c = project.Id;        // Astrum PM Project Reference
        // end - LLH
        

        solines.add(line);
        
        rstk.SalesOrderAPI.createSalesOrder( sohdr, solines);
        
        System.debug('* sohdr '+ sohdr);  

        // LLH - new additions
        // bind SOHdrExtn to SOHdr and save
        sohdrextn.rstk__sohdrextn_sohdr__c = sohdr.Id;
        insert sohdrextn;

        // TODO - add Work Order Id to the PM_Project
        // idea: pull WO from SO_Line
        project.Work_Order__c = line.rstk__soline_wocstordno__c;
        System.debug('Rootstock Automation: SO_line-WorkOrderId returned was: ' + project.Work_Order__c);
        update project;
        // end - LLH

        // Update Sale Order with RS Sales Order
        salesOrder.Rootstock_Sales_Order__c  = sohdr.Id;
        Update salesOrder;
        
    }
*/
    // inner class designed to store the Rootstock Objects related to a PM Project
    // this should be used primarily for the Rootstock Automation / Intergration
    public class RootstockObjects {

      public PM_Project__c project {get; private set;}
      public rstk__socust__c socust {get; private set;}
      public rstk__pjproj__c pjproj {get; private set;}
      public rstk__soprod__c soprod {get; private set;}
      public rstk__sohdr__c sohdr {get; private set;}
      public rstk__sohdrextn__c sohdr_extn {get; private set;}
      public rstk__soline__c soline {get; private set;}
      public rstk__wocst__c workorder {get; private set;}
      public rstk__pjproj__c oldpjproj {get; private set;}
      public rstk__sohdr__c oldsohdr {get; private set;}
      public rstk__soline__c oldsoline {get; private set;}
      public rstk__wocst__c oldworkorder {get; private set;}
      public Install_Project__c installproj {get; private set;}
      public String ipBy {get; private set;}                     // string indicating how the Install Project was retrieved: WO - from Work Order | PM - from PM Project
      public Boolean sohdr_extn_exists {get; private set;}       // flag indicating if Sales Order Extension exists
      //FPO 6- Rtsk Duplication for Div change
      public Boolean oldpjprojHasAsscCst {get{if(oldpjprojHasAsscCst == null){oldpjprojHasAsscCst = false;}return oldpjprojHasAsscCst;} private set;}
      public Boolean oldWOHasLbrBooked {get{if(oldWOHasLbrBooked == null){oldWOHasLbrBooked = false;}return oldWOHasLbrBooked;} private set;}
      public Boolean oldWOHasIssuedParts {get{if(oldWOHasIssuedParts == null){oldWOHasIssuedParts = false;}return oldWOHasIssuedParts;} private set;}
      public Boolean oldsohdrIsClosed {get{if(oldsohdrIsClosed == null){oldsohdrIsClosed = false;}return oldsohdrIsClosed;} private set;}
      public Boolean oldpjprojHasOpenPOs {get{if(oldpjprojHasOpenPOs == null){oldpjprojHasOpenPOs = false;}return oldpjprojHasOpenPOs;} private set;}
      public rstk__pjprojcst__c oldpjprojcst {get; private set;}
      public List<rstk__woorddmd__c> oldwocomps {get; private set;}
      public Map<String,String> engMasterToInvItemMap {get; private set;}
      public Boolean transferComps {get{if(transferComps == null){transferComps = false;}return transferComps;} private set;}

      public RootstockObjects() {
        ipBy = '';
        sohdr_extn_exists = false;
        System.debug('RA: construct RootstockObject:');
      }

      public RootstockObjects( PM_Project__c project) {
        ipBy = '';
        sohdr_extn_exists = false;
        //retrievePMProject(project);
        //System.debug('RA: construct RootstockObject: w/ project');
        retrieveRootstockObjects( project);
      }

      public PM_Project__c retrievePMProject( PM_Project__c proj ) {

        if( project == null ) {
          // get required fields from PM Project
          //System.debug('SOQL: retrievePMProject: get PM_Project');
          //PM_Project__c project = [SELECT Id, Name, Sales_Order__c, Sales_Order__r.Name, Sales_Order__r.AccountId__r.Accounting_Id__c, Sales_Order__r.Job_Id__c
          //             FROM PM_Project__c WHERE Id = :proj.Id ];
          project = [SELECT Id, Name, Sales_Order__c, Sales_Order__r.Name, Sales_Order__r.AccountId__r.Accounting_Id__c, Work_Order__c,
                             Sales_Order__r.Job_Id__c, Sales_Order__r.Property__r.Astrum_Office_New__r.Rootstock_Division__c,
                             Sales_Order__r.Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c
                       FROM PM_Project__c WHERE Id = :proj.Id ];
          //System.debug('SOQL: retrievePMProject: Limits: ' + Limits.getQueries());
          //System.debug('PM Project Id: ' + project.Id + ' and Account_Id: ' + project.Sales_Order__r.AccountId__r.Accounting_Id__c);
          //System.debug('PM Project - Sales Order Job Id: ' + project.Sales_Order__r.Job_Id__c);
        }

        return project;
      }

      public rstk__socust__c retrieveRootstockCustomer( PM_Project__c proj ) {

        retrievePMProject( proj );

        if( socust == null ) {
          // Query Rootstock Customer 
          //System.debug('Account_Id: ' + project.Sales_Order__r.AccountId__r.Accounting_Id__c);
          //System.debug('SOQL: retrieveRootstockObjects: get Rootstock Customer');
          List<rstk__socust__c> socusts = [Select r.rstk__socust_sf_account_name__c, r.rstk__socust_sf_account__c, r.Name, r.Id, r.rstk__externalid__c 
                            From rstk__socust__c r
                            Where r.rstk__socust_custno__c = :project.Sales_Order__r.AccountId__r.Accounting_Id__c];
          //System.debug('SOQL: retrieveRootstockObjects: Limits: ' + Limits.getQueries());
          if( socusts.size() > 0 ) {
              socust = socusts[0];
              //System.debug('Rootstock Customer: ' + socust.Id);
          }
        }

        return socust;
      }

      public void retrieveRootstockObjects( PM_Project__c proj ) {

        retrievePMProject( proj );

        // Query Rootstock Customer 
        retrieveRootstockCustomer( proj );

        // Query for Rootstock Project Master
        //System.debug('SOQL: retrieveRootstockObjects: get Rootstock Project Master');
        System.debug('RA: retrieveRootstockObjects: for pjproj with external id: ' + project.Sales_Order__r.Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c + '_' + project.Sales_Order__r.Job_Id__c);
        List<rstk__pjproj__c> pjprojs = [SELECT Id, Name, rstk__externalid__c FROM rstk__pjproj__c
                                            WHERE rstk__pjproj_div__c = :project.Sales_Order__r.Property__r.Astrum_Office_New__r.Rootstock_Division__c
                                                 AND rstk__pjproj_proj__c = :project.Sales_Order__r.Job_Id__c];
        //List<rstk__pjproj__c> pjprojs = [SELECT Id, Name, rstk__externalid__c FROM rstk__pjproj__c
        //                                        WHERE rstk__externalid__c =: project.Sales_Order__r.Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c + '_' + project.Sales_Order__r.Job_Id__c
        //                                        ];
        //System.debug('SOQL: retrieveRootstockObjects: Limits: ' + Limits.getQueries());
        if( pjprojs!= null && pjprojs.size() > 0 ) {
            pjproj = pjprojs[0];System.debug('**pjproj is:' + pjproj.Id);
            //System.debug('Rootstock Project Master: ' + pjproj.Id + '  External Id: ' + pjproj.rstk__externalid__c);
        }

        // Query for Rootstock Product Master
        List<rstk__soprod__c> soprods = [SELECT Id, Name, rstk__externalid__c FROM rstk__soprod__c
                                                WHERE rstk__externalid__c =: project.Sales_Order__r.Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c + '_' + project.Sales_Order__r.Job_Id__c];
        if( soprods.size() > 0 ) {
          soprod = soprods[0];
        }

        // Query for Rootstock Sales Order Header
        //System.debug('SOQL: retrieveRootstockObjects: get Sales Order Header');
        //List<rstk__sohdr__c> sohdrs = [SELECT Id, Name, rstk__sohdr_proj__c FROM rstk__sohdr__c
        //                                 WHERE Name = :project.Sales_Order__r.Name
        //                                 AND rstk__sohdr_div__c = :project.Sales_Order__r.Property__r.Astrum_Office_New__r.Rootstock_Division__c
        //                                 ];
        //System.debug('RA: retrieveRootstockObjects: sohdr external id: ' + project.Sales_Order__r.Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c + '_' + project.Sales_Order__r.Name);
        List<rstk__sohdr__c> sohdrs = [SELECT Id, Name, rstk__sohdr_proj__c, rstk__externalid__c FROM rstk__sohdr__c
                                         WHERE rstk__externalid__c =: project.Sales_Order__r.Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c + '_' + project.Sales_Order__r.Name
                                         ];
        //System.debug('SOQL: retrieveRootstockObjects: Limits: ' + Limits.getQueries());
        if( sohdrs.size() > 0 ) {
            sohdr = sohdrs[0];
            // Query for SO Hdr Extension
            //System.debug('SOQL: retrieveRootstockObjects: get Sales Order Header Extension');
            List<rstk__sohdrextn__c> sohdr_extns = [SELECT Id, Name, rstk__externalid__c FROM rstk__sohdrextn__c WHERE rstk__sohdrextn_sohdr__c = :sohdr.Id];
            //System.debug('SOQL: retrieveRootstockObjects: Limits: ' + Limits.getQueries());
            if( sohdr_extns.size() > 0 ) {
              sohdr_extn_exists = true;
              sohdr_extn = sohdr_extns[0];
            }
            // Query for SalesOrder Lines
            //System.debug('SOQL: retrieveRootstockObjects: get Sales Order Lines');
            List<rstk__soline__c> solines = [SELECT Id, Name, rstk__soline_project__c, rstk__soline_prod__c, rstk__soline_wocstordno__c,
                                                    rstk__soline_wocstordno__r.Name, Sales_Order__c, PM_Project__c, rstk__externalid__c
                                                FROM rstk__soline__c WHERE rstk__soline_sohdr__c = :sohdr.Id];
            //System.debug('SOQL: retrieveRootstockObjects: Limits: ' + Limits.getQueries());
            if( solines.size() > 0 ) {
                soline = solines[0];System.debug('**soline is:' + soline.Id);
            }
        }

        // Query for Work Order
        // if SOLine pull WO.Id from there else SOQL from PM_Project.Id
        List<rstk__wocst__c> workorders;
        //System.debug('SOQL: retrieveRootstockObjects: get Work Orders');
        if( soline !=null ) {
            workorders = [SELECT Id, Name, Sales_Order__c, PM_Project__c, rstk__wocst_proj__c, rstk__wocst_item__c, rstk__wocst_soline__c,
                                  rstk__externalid__c, rstk__wocst_ordsts__c
                                FROM rstk__wocst__c  WHERE rstk__wocst_soline__c = :soline.Id];
        } else {
            workorders = [SELECT Id, Name, Sales_Order__c, PM_Project__c, rstk__wocst_proj__c, rstk__wocst_item__c, rstk__wocst_soline__c,
                                  rstk__externalid__c, rstk__wocst_ordsts__c
                                FROM rstk__wocst__c WHERE PM_Project__c = :project.Id];
        }
        //System.debug('SOQL: retrieveRootstockObjects: Limits: ' + Limits.getQueries());
        if( workorders.size() > 0 ) {
            workorder = workorders[0];System.debug('**workorder is:' + workorder.Id);
        }

        //Query for Install Project
        List<Install_Project__c> installprojs;
        //System.debug('SOQL: retrieveRootstockObjects: get Install Project');
        if( (workorder != null) && (workorder.Id != null) ) {
            // search by Work Order
            installprojs = [SELECT Id, Name, Sales_Order__c, PM_Project__c, Work_Order__c FROM Install_Project__c WHERE Work_Order__c = :workorder.Id];
            ipBy = 'WO';
        } else {
            // search by PM Project
            installprojs = [SELECT Id, Name, Sales_Order__c, PM_Project__c, Work_Order__c FROM Install_Project__c WHERE PM_Project__c = :project.Id];
            ipBy = 'PM';
            if( installprojs.size() == 0 ) {
                // search by Sales Order
                installprojs = [SELECT Id, Name, Sales_Order__c, PM_Project__c, Work_Order__c FROM Install_Project__c WHERE Sales_Order__c = :project.Sales_Order__c];
                ipBy = 'SCRB';
            }
        }
        //System.debug('SOQL: retrieveRootstockObjects: Limits: ' + Limits.getQueries());
        if( installprojs.size() > 0 ) {
            installproj = installprojs[0];System.debug('**installproj is:' + installproj.Id);
        } else {
            ipBy = '';
        }

        if( !RootstockObjectsExist() ) {
          
          // Query for Old Rootstock Project Master
          pjprojs = [SELECT Id, Name, rstk__externalid__c
                      , (SELECT Id , rstk__pjprojcst_costs_subtot__c
                        , rstk__pjprojcst_baclab__c
                        , rstk__pjprojcst_bacmtl__c
                        , rstk__pjprojcst_bacmodc__c
                        , rstk__pjprojcst_budservrevenue__c
                        , rstk__pjprojcst_budprodrevenue__c
                        , rstk__pjprojcst_bacohdmtl__c
                        , rstk__pjprojcst_bacohdlab__c
                        , rstk__pjprojcst_bacohdfrng__c
                        , rstk__pjprojcst_bacohdmach__c
                        , rstk__pjprojcst_bacsubmtl__c
                        , rstk__pjprojcst_bacsublab__c
                        , rstk__pjprojcst_baciodc__c
                        , rstk__pjprojcst_bacsodc__c
                        , rstk__pjprojcst_baclodc__c
                          FROM rstk__pjprojcsts__r) 
                      FROM rstk__pjproj__c 
                      WHERE rstk__pjproj_proj__c = :project.Sales_Order__r.Job_Id__c
                      AND rstk__pjproj_div__c != :project.Sales_Order__r.Property__r.Astrum_Office_New__r.Rootstock_Division__c
                      ORDER BY CreatedDate DESC]; 
                      //AND rstk__pjproj_div__c != :project.Sales_Order__r.Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c
                      //ORDER BY CreatedDate DESC];
          /* FPO Sprint6 - Check if Project has 
          *  any associated costs 
          *  Open PO’s 
          *  Issued Parts 
          *  Booked labor
          *  Associated SO is closed  
          */
          if(pjprojs!= null && pjprojs.size() > 0 ) {
              oldpjproj = pjprojs[0];
              //FPO Sprint6 - check if there are any associated costs or open po's
              oldpjprojcst = pjprojs[0].rstk__pjprojcsts__r[0];
              List<rstk__poline__c> polines = [SELECT id, rstk__poline_ordsts__c  
                                                FROM rstk__poline__c 
                                                WHERE rstk__poline_proj__c = :pjprojs[0].Id];
              if(polines != null && polines.size()>0){
                oldpjprojHasOpenPOs = true;                
              }
              if(pjprojs[0].rstk__pjprojcsts__r[0].rstk__pjprojcst_costs_subtot__c > 0){
                oldpjprojHasAsscCst = true;
              }
              
              //System.debug('RA: SOQL: retrieve OLD Project Master: id: ' + oldpjproj.id + '  External Id: ' + oldpjproj.rstk__externalid__c);
          }

          // Query for Old Rootstock Sales Order Header
          sohdrs = [SELECT Id, Name, rstk__sohdr_proj__c, rstk__externalid__c, rstk__sohdr_closed__c FROM rstk__sohdr__c
                                            WHERE Name = :project.Sales_Order__r.Name 
                                            AND rstk__sohdr_div__c != :project.Sales_Order__r.Property__r.Astrum_Office_New__r.Rootstock_Division__c
                                            ORDER BY CreatedDate DESC];
                                            //AND rstk__sohdr_div__c != :project.Sales_Order__r.Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c
                                            //ORDER BY CreatedDate DESC];
          if( sohdrs!= null && sohdrs.size() > 0 ) {
              oldsohdr = sohdrs[0];              
              //System.debug('RA: SOQL: retrieve OLD Sales Order Hdr: id: ' + oldsohdr.id);
              // Query for SalesOrder Lines
              List<rstk__soline__c> solines = [SELECT Id, Name, rstk__soline_project__c, rstk__soline_prod__c
                                                , rstk__soline_wocstordno__c, rstk__soline_qtyship__c
                                                , rstk__soline_wocstordno__r.Name, rstk__externalid__c 
                                                FROM rstk__soline__c 
                                                WHERE rstk__soline_sohdr__c = :oldsohdr.Id 
                                                ORDER BY rstk__soline_qtyship__c DESC];
              if(solines!=null && solines.size() > 0 ) {
                  oldsoline = solines[0];
                  //FPO Sprint6 - check if asociated salesorder is closed
                  if(solines[0].rstk__soline_qtyship__c > 0){
                    oldsohdrIsClosed = true;
                  }
                  // Query for Old Work Order
                  if( oldsoline !=null ) {
                      workorders = [SELECT Id, Name, rstk__wocst_totlabhrs__c, rstk__externalid__c 
                                    FROM rstk__wocst__c 
                                    WHERE rstk__wocst_soline__c = :oldsoline.Id 
                                    ORDER BY CreatedDate DESC];
                      if(workorders!= null && workorders.size() > 0 ) {
                          oldworkorder = workorders[0];
                          //FPO Sprint6 
                          //check if labor is booked 
                          if(workorders[0].rstk__wocst_totlabhrs__c > 0){
                            oldWOHasLbrBooked = true;
                            return;
                          }
                          //Work Order components
                          oldwocomps = getWorkOrderComponents(oldworkorder.Id);
                          if(oldwocomps!= null && oldwocomps.size()>0){
                              System.debug('**1oldwocomps.size():' + oldwocomps.size());
                              //check if parts are issued
                              if(oldwocomps[0].rstk__woorddmd_qtyiss__c > 0){
                                  oldWOHasIssuedParts = true;
                                  return;
                              }
                              Set<String> engItemMastersSet = new Set<String>();
                              engMasterToInvItemMap = new Map<String,String>();
                              for(rstk__woorddmd__c wocomp:oldwocomps){        
                                  engItemMastersSet.add(wocomp.rstk__woorddmd_compitem__r.rstk__icitem_item__c);
                                  //System.debug('**compid:' + wocomp.Id);
                              }
                              
                              List<rstk__icitem__c> invitems = [SELECT Id,rstk__icitem_item__c 
                                                                FROM rstk__icitem__c 
                                                                WHERE rstk__icitem_item__c IN:engItemMastersSet 
                                                                AND rstk__icitem_div__c =:project.Sales_Order__r.Property__r.Astrum_Office_New__r.Rootstock_Division__c];
                              if(invitems != null){        
                                  for(rstk__icitem__c invitem:invitems){
                                      engMasterToInvItemMap.put(invitem.rstk__icitem_item__c,invitem.Id);
                                  }
                              }    
                          }// End of FPO Sprint6
                      }
                  }
              }
          }

        }

        System.debug('RA - RootstockObjects: Retrieved Rootstock Objects');

      }

      //FPO Sprint6
      private List<rstk__woorddmd__c> getWorkOrderComponents(String workOrderId){
        
        List<rstk__woorddmd__c> oldwocomps;
        String objectName = 'rstk__woorddmd__c';  
        String query = 'SELECT';
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();

        for(String s : objectFields.keySet()) {
           query += ' ' + s + ',';
        }
        query += 'rstk__woorddmd_compitem__r.rstk__icitem_item__c';
        query = query.removeEnd(',');
        query += ' FROM ' + objectName;
        query += ' WHERE rstk__woorddmd_ordno__c   = '+ '\'' +  workOrderId + '\''; 
        query += ' ORDER BY rstk__woorddmd_qtyiss__c DESC';

        System.debug('query' + query);                          
        oldwocomps = database.query(query);
        return oldwocomps;

      }

      public Boolean RootstockCustomerExists() {
        if( socust != null ) {
          return true;
        } else {
          return false;
        }
      }

      public Boolean RootstockMastersExist() {
        if( (pjproj != null) && (soprod != null) ) {
          return true;
        } else {
          return false;
        }
      }

      public Boolean RootstockSalesOrderExist() {
        if( sohdr != null ) {
          return true;
        } else {
          return false;
        }
      }

      public Boolean RootstockObjectsExist() {
          return RootstockMastersExist() && RootstockSalesOrderExist();
      }

      public Boolean OldRootstockObjectsExist() {
        if( (oldsohdr != null) || (oldworkorder != null) ) {
          return true;
        } else {
          return false;
        }
      }

      public Boolean RootstockObjectsNeedReconnection() {

        // check objects to see if they are connected to each other.

        Boolean needFlg = false;

        if( project != null ) {

            if( workorder != null ) {

                needFlg |= (project.Work_Order__c != workorder.Id);

                needFlg |= (workorder.Sales_Order__c != project.Sales_Order__c);
                needFlg |= (workorder.PM_Project__c != project.Id);

                if( soline != null ) {

                  needFlg |= (workorder.rstk__wocst_soline__c != soline.Id);

                  needFlg |= (soline.Sales_Order__c != project.Sales_Order__c);
                  needFlg |= (soline.PM_Project__c != project.Id);
                  needFlg |= (soline.rstk__soline_wocstordno__c != workorder.Id);
                }

                if( installproj != null ) {
                  needFlg |= (installproj.Sales_Order__c != project.Sales_Order__c);
                  needFlg |= (installproj.PM_Project__c != project.Id);
                  needFlg |= (installproj.Work_Order__c != workorder.Id);
                }

            }

        }

        return needFlg;
      }

      public void reconnectObjects() {

        Boolean updProject = false;
        Boolean updWorkOrder = false;
        Boolean updInstallProject = false;
        Boolean updSOLine = false;

        if( project != null ) {

            if( workorder != null ) {

                if (project.Work_Order__c != workorder.Id) {
                    project.Work_Order__c = workorder.Id;
                    updProject = true;
                }

                if (workorder.Sales_Order__c != project.Sales_Order__c) {
                    workorder.Sales_Order__c = project.Sales_Order__c;
                    updWorkOrder = true;
                }
                if (workorder.PM_Project__c != project.Id) {
                    workorder.PM_Project__c = project.Id;
                    updWorkOrder = true;
                }

                if( soline != null ) {

                  if (workorder.rstk__wocst_soline__c != soline.Id) {
                      workorder.rstk__wocst_soline__c = soline.Id;
                      updWorkOrder = true;
                  }

                  if (soline.Sales_Order__c != project.Sales_Order__c) {
                      soline.Sales_Order__c = project.Sales_Order__c;
                      updSOLine = true;
                  }
                  if (soline.PM_Project__c != project.Id) {
                      soline.PM_Project__c = project.Id;
                      updSOLine = true;
                  }
                  if (soline.rstk__soline_wocstordno__c != workorder.Id) {
                      soline.rstk__soline_wocstordno__c = workorder.Id;
                      updSOLine = true;
                  }
                }

                if( installproj != null ) {
                  if (installproj.Sales_Order__c != project.Sales_Order__c) {
                      installproj.Sales_Order__c = project.Sales_Order__c;
                      updInstallProject = true;
                  }
                  if (installproj.PM_Project__c != project.Id) {
                      installproj.PM_Project__c = project.Id;
                      updInstallProject = true;
                  }
                  if (installproj.Work_Order__c != workorder.Id) {
                      installproj.Work_Order__c = workorder.Id;
                      updInstallProject = true;
                  }
                }

            }

        }
        System.debug('SOQL: Limits5: ' + Limits.getQueries());
        if( updProject ) {
            update project;System.debug('SOQL: Limits5b: ' + Limits.getQueries());
        }
        if( updWorkOrder ) {
            update workorder;System.debug('SOQL: Limits6: ' + Limits.getQueries());
        }
        if( updSOLine ) {
            update soline;System.debug('SOQL: Limits7: ' + Limits.getQueries());
        }
        if( updInstallProject ) {
            update installproj;System.debug('SOQL: Limits8: ' + Limits.getQueries());
        }

        retrieveRootstockObjects(project);
      }

    }
    // end of inner class

    public String createRootStockObjects1(SCRB_SalesOrder__c salesOrder, PM_Project__c project, RootstockAutomation.RootstockObjects raobjs) {     // LLH

      if( (salesOrder != null) && (project != null) ) {

          //System.debug('createRootStockObjects: calling createProjectMaster');
          rstk__pjproj__c pjproj = createProjectMaster( project, salesOrder, raobjs);

          //System.debug('createRootStockObjects: calling createEngineeringItemMaster');
          rstk__peitem__c peitem = createEngineeringItemMaster( project, salesOrder);

          //System.debug('createRootStockObjects: calling createProductMaster');
          System.debug(loggingLevel.ERROR,'*****Invoke createProductMaster:');        
          rstk__soprod__c product = createProductMaster( project, salesOrder, peitem );

      }        

      return 'ERROR: Unable to create Rootstock Objects. Either Sales Order, PM Project was invalid.';
    }

    public String createRootStockObjects2(SCRB_SalesOrder__c salesOrder, String soCustId, PM_Project__c project, RootstockAutomation.RootstockObjects raobjs) {     // LLH

      if( (salesOrder != null) && (soCustId != null) && (soCustId != '') && (project != null) ) {


          // retrieve Product Master and Project Master
          rstk__soprod__c product;
          rstk__pjproj__c pjproj;

          List<rstk__soprod__c> products = [SELECT Id, Name FROM rstk__soprod__c 
                                              WHERE rstk__externalid__c =: salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c + '_' + salesOrder.Job_Id__c];
          if( products.size() > 0 ) {
            product = products[0];
          }
          List<rstk__pjproj__c> pjprojs = [SELECT Id, Name, rstk__externalid__c FROM rstk__pjproj__c
                                            WHERE rstk__pjproj_div__c = :salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c
                                                 AND rstk__pjproj_proj__c = :salesOrder.Job_Id__c];
          //List<rstk__pjproj__c> pjprojs = [SELECT Id, Name FROM rstk__pjproj__c 
          //                                    WHERE rstk__externalid__c =: salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c + '_' + salesOrder.Job_Id__c];
          if( pjprojs.size() > 0 ) {
            pjproj = pjprojs[0];
          }
  
          if( (product != null) && (pjproj != null) ) {

            rstk__sohdr__c sohdr = createRootstockSalesOrder( project, salesOrder, soCustId, product, pjproj, raobjs);
            //System.debug('createRootStockObjects: returned from createRootstockSalesOrder');
            //System.debug('SOQL: createProject: Limits: ' + Limits.getQueries());
            // Rootstock Sales Order Lines will create a Work Order
            // the Work Order will create an Install Project

            // Update Sale Order with RS Sales Order
            salesOrder.Rootstock_Sales_Order__c  = sohdr.Id;
            //System.debug('DML: createRootStockObjects: update salesOrder');
            update salesOrder;
            //FPO Sprint6 - Set transfer components Flag
            if(raobjs != null){
              raobjs.transferComps = true;
            }
            return 'OK';

          } else {
            return 'ERROR: No Product/Project Masters';
          }
      }        

      return 'ERROR: Unable to create Rootstock Objects. Either Sales Order, PM Project or Rootstock Customer Master was invalid.';
    }


    public String createProject(SCRB_SalesOrder__c salesOrder) {
        
        Id projectId; 
        //System.debug('SOQL: createProject: get projects');
        List<PM_Project__c> projects = [SELECT Id FROM PM_Project__c WHERE Sales_Order__c = :salesOrder.Id];
        //System.debug('SOQL: createProject: Limits: ' + Limits.getQueries());

        //if project already exists, display the project      
        if (projects.size() > 0) {
            projectId = projects[0].Id;
            System.debug('Existing projectId=' + projectId);
            //throw new CustomException ('A project already exists for this sales order.');
            return projectId ;
        }
        
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
        
        //System.debug('DML: createProject: insert');
        insert newProject;

        //MIS-212 PB 02/02/2016 - Create post-sale task 
        System.debug(loggingLevel.ERROR, 'salesOrder.Property__r.Astrum_Office_New__r.Survey_Scheduler__c' + salesOrder.Property__r.Astrum_Office_New__r.Survey_Scheduler__c) ;    
        Request_Site_Survey_Utility.assignTask(newProject
                                                , salesOrder.Property__r.Astrum_Office_New__r.Survey_Scheduler__c
                                                , null
                                                , null
                                                , null
                                                , false
                                                , null);
        
        return newProject.Id;
        
    }
    
    //find the first day of week after the requested date
    private Date nextWeekday(Date dt)
    {
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

    public rstk__pjproj__c createProjectMaster( PM_Project__c project, SCRB_SalesOrder__c salesOrder, RootstockAutomation.RootstockObjects raobjs) {
        rstk__pjproj__c pjproj;

        List<rstk__pjproj__c> pjprojs = [SELECT Id, Name, rstk__externalid__c, rstk__pjproj_div__c, rstk__pjproj_descr__c, rstk__pjproj_proj__c
                                            ,Primary_Project_BudgetCost__c
                                            FROM rstk__pjproj__c
                                            WHERE rstk__pjproj_div__c = :salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c
                                                 AND rstk__pjproj_proj__c = :salesOrder.Job_Id__c];
        //List<rstk__pjproj__c> pjprojs = [SELECT Id, Name, rstk__externalid__c, rstk__pjproj_div__c, rstk__pjproj_descr__c, rstk__pjproj_proj__c
        //                                    FROM rstk__pjproj__c
        //                                    WHERE rstk__externalid__c =: salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c + '_' + salesOrder.Job_Id__c];
        if( pjprojs.size() > 0 ) {

          pjproj = pjprojs[0];
          //fpo-3
          if(pjproj.Primary_Project_BudgetCost__c == null){
            Id projCostId;
            try{
              projCostId = [SELECT Id FROM rstk__pjprojcst__c WHERE rstk__pjprojcst_proj__c =:pjproj.Id LIMIT 1].Id;
            }catch(QueryException qe){}
            pjproj.Primary_Project_BudgetCost__c = projCostId;
            update pjproj;
          }
          if(salesOrder.Primary_Project_Master__c == null){
            //Assign Primary Project Master to SO.
            salesOrder.Primary_Project_Master__c = pjproj.Id;
            update salesOrder;
          }          
          
          //System.debug('createProjectMaster: found pjproj: ' + pjproj.Id);
        } else {
          // Create Project Master 
          pjproj = new rstk__pjproj__c(
            rstk__pjproj_div__c = salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c,         
            rstk__pjproj_descr__c = project.Name,
            rstk__pjproj_proj__c = salesOrder.Job_Id__c
            );
              
          //System.debug('DML: createProjectMaster: insert');
          insert pjproj ;
          //rstk__pjproj__c newproj = [SELECT Id, rstk__externalid__c FROM rstk__pjproj__c WHERE Id = :pjproj.Id];
          //System.debug('createProjectMaster: inserted pjproj: ' + newproj.Id + ' External Id: ' + newproj.rstk__externalid__c);

          //FPO-3 PB
          //Id projCostId;
          rstk__pjprojcst__c pjprojcst;//FPO Sprint6
          try{
            //projCostId = [SELECT Id FROM rstk__pjprojcst__c WHERE rstk__pjprojcst_proj__c =:pjproj.Id LIMIT 1].Id;            
            pjprojcst = [SELECT Id FROM rstk__pjprojcst__c WHERE rstk__pjprojcst_proj__c =:pjproj.Id LIMIT 1];//FPO Sprint6
          }catch(QueryException qe){}
          pjproj.Primary_Project_BudgetCost__c = pjprojcst.Id;          
          update pjproj;
          //FPO Sprint6
          if(raobjs!= null && raobjs.oldpjprojcst != null){
            pjprojcst.rstk__pjprojcst_baclab__c = raobjs.oldpjprojcst.rstk__pjprojcst_baclab__c;
            pjprojcst.rstk__pjprojcst_bacmtl__c = raobjs.oldpjprojcst.rstk__pjprojcst_bacmtl__c;
            pjprojcst.rstk__pjprojcst_bacmodc__c = raobjs.oldpjprojcst.rstk__pjprojcst_bacmodc__c;
            pjprojcst.rstk__pjprojcst_budservrevenue__c = raobjs.oldpjprojcst.rstk__pjprojcst_budservrevenue__c;
            pjprojcst.rstk__pjprojcst_budprodrevenue__c = raobjs.oldpjprojcst.rstk__pjprojcst_budprodrevenue__c;
            pjprojcst.rstk__pjprojcst_bacohdmtl__c = raobjs.oldpjprojcst.rstk__pjprojcst_bacohdmtl__c;
            pjprojcst.rstk__pjprojcst_bacohdlab__c = raobjs.oldpjprojcst.rstk__pjprojcst_bacohdlab__c;
            pjprojcst.rstk__pjprojcst_bacohdfrng__c = raobjs.oldpjprojcst.rstk__pjprojcst_bacohdfrng__c;
            pjprojcst.rstk__pjprojcst_bacohdmach__c = raobjs.oldpjprojcst.rstk__pjprojcst_bacohdmach__c;
            pjprojcst.rstk__pjprojcst_bacsubmtl__c = raobjs.oldpjprojcst.rstk__pjprojcst_bacsubmtl__c;
            pjprojcst.rstk__pjprojcst_bacsublab__c = raobjs.oldpjprojcst.rstk__pjprojcst_bacsublab__c;
            pjprojcst.rstk__pjprojcst_baciodc__c = raobjs.oldpjprojcst.rstk__pjprojcst_baciodc__c;
            pjprojcst.rstk__pjprojcst_bacsodc__c = raobjs.oldpjprojcst.rstk__pjprojcst_bacsodc__c;
            pjprojcst.rstk__pjprojcst_baclodc__c = raobjs.oldpjprojcst.rstk__pjprojcst_baclodc__c;
            update pjprojcst;
          }
          
          //Assign Primary Project Master to SO.
          salesOrder.Primary_Project_Master__c = pjproj.Id;
          update salesOrder;
        }
       
        //System.debug('* salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c '+ salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c); 
        //System.debug('* salesOrder.Job_Id__c '+ salesOrder.Job_Id__c); 

        return pjproj;
    }

    public rstk__peitem__c createEngineeringItemMaster( PM_Project__c project, SCRB_SalesOrder__c salesOrder ) {
        // Create Engineering Item Master
        
        rstk__peitem__c peitem;

        //System.debug('SOQL: createEngineeringItemMaster: get commcode');
        //System.debug('RA: createEngineeringItemMaster: Rootstock_Division__c: ' + salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c );
        //rstk__Iccomcod__c  commcode = [Select Id from rstk__Iccomcod__c Where Name = 'Routing' AND rstk__iccomcod_div__c = :salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c];  
        rstk__Iccomcod__c  commcode = [Select Id from rstk__Iccomcod__c Where rstk__externalid__c =: salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c + '_Routing'];  
        //System.debug('SOQL: createEngineeringItemMaster: Limits: ' + Limits.getQueries());
        //System.debug('SOQL: createEngineeringItemMaster: get div');
        rstk__sydiv__c div = [Select Id, rstk__externalid__c from rstk__sydiv__c Where rstk__externalid__c = '300']; // Maryland Division
        //System.debug('SOQL: createEngineeringItemMaster: Limits: ' + Limits.getQueries());
        
        // ******* Alert - ALL Eng Item Masters are in the MD Division *************
        // so when re-created they will all FAIL insert, check if they exist first
        // 
        // check if an EIM already exists for this and use that one instead
        // EIM External IDs are the concatenation of DIV & Job_Id
        //List<rstk__peitem__c> peitems = [SELECT Id, Name, rstk__externalid__c, rstk__peitem_item__c, rstk__peitem_iccomcod__c
        //                                    FROM rstk__peitem__c
        //                                    WHERE rstk__peitem_div__c = :div.Id AND rstk__peitem_item__c = :salesOrder.Job_Id__c];
        List<rstk__peitem__c> peitems = [SELECT Id, Name, rstk__externalid__c, rstk__peitem_item__c, rstk__peitem_iccomcod__c
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
            
            //System.debug('DML: createEngineeringItemMaster: insert');
            insert peitem ;
          }

        //System.debug('* peitem '+ peitem );        
        //System.debug('* sydiv '+ salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c );     

        return peitem;
    }

    public rstk__soprod__c createProductMaster( PM_Project__c project, SCRB_SalesOrder__c salesOrder, rstk__peitem__c peitem ) {
        System.debug(loggingLevel.ERROR,'*****ProdMaster:' + salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c + '_' + peitem.rstk__peitem_item__c);
          
         // Create Product Master 
        rstk__soprod__c product;
        rstk__icitem__c item;

        //System.debug('SOQL: createProductMaster: get scomm');
        rstk__socomm__c scomm = [Select Id from rstk__socomm__c Where rstk__socomm_div__c = :salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c];
        //System.debug('SOQL: createProductMaster: Limits: ' + Limits.getQueries());
        //System.debug('SOQL: createProductMaster: get item');

        //FPO Phase2 PB
          Id invLocId;
          String invLocNum ='';
          Boolean invLocInd = true;
          Id offdiv = salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c;
          Id offsite = salesOrder.Property__r.Astrum_Office_New__r.Site__c;

          //Inventory location Id 
          if(offdiv!= null && offsite != null){
            try{
              invLocId = [SELECT Id FROM rstk__sylocid__c 
                        WHERE rstk__sylocid_loctype_pl__c = 'On Hand'
                        AND rstk__sylocid_div__c =:offdiv
                        AND rstk__sylocid_site__c = :offsite LIMIT 1].Id;
              invLocNum = '1';
              invLocInd = false;

            }
            catch(QueryException qe){
              System.debug(loggingLevel.ERROR,'*****Error in fetching invLocId:' + qe.getMessage());
              invLocId = null;
            }

          }
          
          System.debug(loggingLevel.ERROR,'*****offdiv:' + offdiv);
          System.debug(loggingLevel.ERROR,'*****offsite:' + offsite);
          System.debug(loggingLevel.ERROR,'*****InvLocId:' + invLocId + ':InvLocId');
          ///

        // Get or Create Inventory Item Master
        //rstk__icitem__c item = [Select r.Id From rstk__icitem__c r Where r.rstk__icitem_item__c = :peitem.Id limit 1 ];
        //List<rstk__icitem__c> items = [SELECT r.Id, r.rstk__icitem_item__c, r.rstk__icitem_div__c FROM rstk__icitem__c r WHERE r.rstk__icitem_item__c = :peitem.Id AND rstk__icitem_div__c = :salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c];
        List<rstk__icitem__c> items = [SELECT r.Id, r.rstk__icitem_item__c, r.rstk__icitem_div__c FROM rstk__icitem__c r WHERE r.rstk__externalid__c =: salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c + '_' + peitem.rstk__peitem_item__c];
        if( items.size() > 0 ) {
            item = items[0];
            System.debug(loggingLevel.ERROR,'*****item exists:' + items[0].Id);
            //FPO Phase2 PB
              item.rstk__icitem_rcptlocid__c = invLocId;
              item.rstk__icitem_rcptlocnum__c = invLocNum;
              item.rstk__icitem_rcptlocidind__c = invLocInd;
              update item;
        } else {
          //rstk__Iccomcod__c  commcode = [Select Id from rstk__Iccomcod__c Where Name = 'Routing' AND rstk__iccomcod_div__c = :salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c];  
          rstk__Iccomcod__c  commcode = [Select Id from rstk__Iccomcod__c Where rstk__externalid__c =: salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c + '_Routing'];
          

          // create new Inventory Master
          item = new rstk__icitem__c(
              rstk__icitem_div__c = salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c,
              rstk__icitem_item__c = peitem.Id,
              rstk__icitem_iccomcod__c = commcode.Id,
              Name = peitem.Name,
              //FPO Phase2 PB
              rstk__icitem_rcptlocid__c = invLocId,
              rstk__icitem_rcptlocnum__c = invLocNum,
              rstk__icitem_rcptlocidind__c = invLocInd
              );
          //System.debug('DML: createProductMaster: createInventoryItemMaster - pre insert - icitem_div:' + item.rstk__icitem_div__c);
          //System.debug('DML: createProductMaster: createInventoryItemMaster - insert');
          insert item;
        }
        //System.debug('DML: createProductMaster: createInventoryItemMaster - result: Id:' + item.Id);
        //System.debug('DML: createProductMaster: createInventoryItemMaster - post insert - icitem_div:' + item.rstk__icitem_div__c);

        //System.debug('SOQL: createProductMaster: Limits: ' + Limits.getQueries());
        //System.debug('SOQL: createProductMaster: get uom');
        rstk__syuom__c uom = [Select Id from rstk__syuom__c Where rstk__externalid__c = 'EA'];
        //System.debug('SOQL: createProductMaster: Limits: ' + Limits.getQueries());

        // TODO - check the External ID to see if a Product Master already exists and use that one
        //System.debug('createProductMaster: for Sales Order Div: ' + salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__r.Name + '  EIM: ' + peitem.rstk__externalid__c + '  Item: ' + item.Id);
        //List<rstk__soprod__c> products = [SELECT Id, Name FROM rstk__soprod__c WHERE rstk__externalid__c = :peitem.rstk__externalid__c];
        //List<rstk__soprod__c> products = [SELECT Id, Name FROM rstk__soprod__c WHERE rstk__soprod_prod__c = :peitem.rstk__peitem_item__c];
        //List<rstk__soprod__c> products = [SELECT Id, Name FROM rstk__soprod__c WHERE rstk__soprod_prod__c = :peitem.rstk__peitem_item__c AND rstk__soprod_div__c = :salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c];
        List<rstk__soprod__c> products = [SELECT Id, Name FROM rstk__soprod__c WHERE rstk__externalid__c =: salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c + '_' + peitem.rstk__peitem_item__c];

          if( products.size() > 0 ) {

            product = products[0];
            System.debug(loggingLevel.ERROR,'*****product exists:' + product.Id);
            //fpo-2
               product.rstk__soprod_shiplocid__c = invLocId;
               product.rstk__soprod_shiplocnum__c = invLocNum;
               product.rstk__soprod_shipsite__c = offsite;
               product.rstk__soprod_shiplocnumind__c = false;
               product.rstk__soprod_shipsiteind__c = false;
               product.rstk__soprod_shiplocidind__c = false;
               update product;//

          } else {
            System.debug(loggingLevel.ERROR,'*****product doesnot exist:');
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
        
            //System.debug('DML: createProductMaster: insert');
            //System.debug('createProductMaster: ProdDiv:' + product.rstk__soprod_div__c + '  InvDiv:' + item.rstk__icitem_div__c);
            //System.debug('createProductMaster: Prod:' + product.rstk__soprod_prod__c);
            insert product;

            //fpo-2
            product = [SELECT Id FROM rstk__soprod__c  WHERE Id=:product.Id];
            
            product.rstk__soprod_shiplocid__c = invLocId;
            product.rstk__soprod_shiplocnum__c = invLocNum;
            product.rstk__soprod_shipsite__c = offsite;
            product.rstk__soprod_shiplocnumind__c = false;
            product.rstk__soprod_shipsiteind__c = false;
            product.rstk__soprod_shiplocidind__c = false;
            update product;

            //System.debug('DML: createProductMaster: - result: Id:' + product.Id);
          }

        //System.debug('* product  '+ product );  

        return product;
    }

    public rstk__sohdr__c createRootstockSalesOrder( PM_Project__c project, SCRB_SalesOrder__c salesOrder, String rstkSOCustId, rstk__soprod__c product, rstk__pjproj__c pjproj, RootstockAutomation.RootstockObjects raobjs) {
        // Create Sales Order        
        //System.debug('SOQL: createRootstockSalesOrder: get terms');
        //LIST<rstk__syterms__c> terms = [SELECT id, name FROM rstk__syterms__c WHERE Name = '10-60-30 (10-60-30)'];
        LIST<rstk__syterms__c> terms = [SELECT id, name FROM rstk__syterms__c WHERE rstk__externalid__c = '10-60-30'];
        //System.debug('SOQL: createRootstockSalesOrder: Limits: ' + Limits.getQueries());
        //System.debug('SOQL: createRootstockSalesOrder: get taxlocs');
        //LIST<rstk__sotax__c> taxlocs = [SELECT id, name FROM rstk__sotax__c WHERE Name = 'OTHER'];
        LIST<rstk__sotax__c> taxlocs = [SELECT id, name FROM rstk__sotax__c WHERE rstk__externalid__c = 'OTHER'];
        //System.debug('SOQL: createRootstockSalesOrder: Limits: ' + Limits.getQueries());

        rstk__sohdr__c sohdr = new rstk__sohdr__c();
        sohdr.rstk__sohdr_div__c = salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c ;
        sohdr.rstk__sohdr_order__c = salesOrder.Name;
        sohdr.rstk__sohdr_orderdate__c = salesOrder.Opportunity_Close_Date__c;
        sohdr.rstk__sohdr_custno__c = rstkSOCustId;
        sohdr.rstk__sohdr_custref__c = salesOrder.Job_Id__c;
        // LLH - new additions
        sohdr.rstk__sohdr_proj__c = pjproj.Id;
        //System.debug('Rootstock Sales Order: Header: Default Project Master: ' + pjproj.Id);
        if( terms.size() > 0 ) {
          sohdr.rstk__sohdr_terms__c = terms[0].Id;
        }
        if( taxlocs.size() > 0 ) {
          sohdr.rstk__sohdr_taxloc__c = taxlocs[0].Id;
        }

        // end - LLH

        //FPO Phase2 PB
        //Assign Site based on offLoc
        sohdr.rstk__sohdr_site__c = salesOrder.Property__r.Astrum_Office_New__r.Site__c;
        
        List<rstk__soline__c> solines = new List<rstk__soline__c>();
        
        rstk__soline__c line = new rstk__soline__c();
        line.rstk__soline_firm__c = true;
        line.rstk__soline_line__c = 1;        
        line.rstk__soline_prod__c = product.id;
        line.rstk__soline_prodtype__c = 'Stock';  // LLH
        line.rstk__soline_qtyorder__c = 1;        
        line.rstk__soline_price__c = salesOrder.Amount__c;

        //fpo2
        //line.rstk__soline_shiplocid__c = 
        //line.rstk__soline_shiplocnum__c = 
        line.rstk__soline_shipsite__c = salesOrder.Property__r.Astrum_Office_New__r.Site__c;


        //

        // RJ : Changes Today() + 60 days on 10/7/13
        //line.rstk__soline_duedate__c = salesOrder.Opportunity_Close_Date__c.addDays(60);    
        //line.rstk__soline_duedate__c = System.Today().addDays(60);
        if( project.Install__c > System.today() ) {               //only assign if Install Date is in the future
          line.rstk__soline_duedate__c = project.Install__c;     // LLH - PM 2.0 Project Install Date
        }
        line.rstk__soline_shipdiv__c = salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c;
        // Added on 10/16 by RJ
        line.rstk__soline_project__c = pjproj.Id;
        // LLH new additions

        //System.debug('SOQL: createRootstockSalesOrder: get uoms');
        List<rstk__syuom__c> uoms = [SELECT id, name FROM rstk__syuom__c WHERE rstk__externalid__c = 'EA'];
        //System.debug('SOQL: createRootstockSalesOrder: Limits: ' + Limits.getQueries());
        if( uoms.size() > 0 ) {
          line.rstk__soline_uom__c = uoms[0].Id;        // Sales UOM
        }

        line.rstk__soline_useconfig__c = true;  // Configure This Time
        line.rstk__soline_firm__c = true;       // Firm True
        line.Sales_Order__c = salesOrder.Id;    // Astrum SCRB Sales Order Reference
        line.PM_Project__c = project.Id;        // Astrum PM Project Reference
        // end - LLH
        

        solines.add(line);
        
        //System.debug('Before createSalesOrder Limits: ' + Limits.getQueries());
        rstk.SalesOrderAPI.createSalesOrder( sohdr, solines);
        //System.debug('After createSalesOrder  Limits: ' + Limits.getQueries());
        //System.debug('* sohdr '+ sohdr);  

        // LLH - new additions

        // add Work Order Id to the PM_Project
        project.Work_Order__c = line.rstk__soline_wocstordno__c;
        
        //System.debug('DML: createRootstockSalesOrder: update project');
        update project;

        // retrieve Sales Order Header Extension
        //System.debug('SOQL: createRootstockSalesOrder: get Sales Order Header Extension');
        rstk__sohdrextn__c sohdrextn = [SELECT Id, Name FROM rstk__sohdrextn__c WHERE rstk__sohdrextn_sohdr__c = :sohdr.Id];
        //System.debug('SOQL: createRootstockSalesOrder: Limits: ' + Limits.getQueries());
        // TODO - check for error

        // collect data for Sales Order Header Extention
        //System.debug('SOQL: createRootstockSalesOrder: get freightAccts');
        //LIST<rstk__syacc__c> freightAccts = [SELECT id FROM rstk__syacc__c WHERE rstk__syacc_mfgacct__c = '49950' AND rstk__syacc_div__c = :salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c];
        LIST<rstk__syacc__c> freightAccts = [SELECT id FROM rstk__syacc__c WHERE rstk__externalid__c =: salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c + '_49950'];
        //System.debug('SOQL: createRootstockSalesOrder: Limits: ' + Limits.getQueries());
        //System.debug('SOQL: createRootstockSalesOrder: get handlingAccts');
        //LIST<rstk__syacc__c> handlingAccts = [SELECT id FROM rstk__syacc__c WHERE rstk__syacc_mfgacct__c = '49950-2' AND rstk__syacc_div__c = :salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c];
        LIST<rstk__syacc__c> handlingAccts = [SELECT id FROM rstk__syacc__c WHERE rstk__externalid__c =: salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c + '_49950-2'];
        //System.debug('SOQL: createRootstockSalesOrder: Limits: ' + Limits.getQueries());
        //System.debug('SOQL: createRootstockSalesOrder: get packagingAccts');
        //LIST<rstk__syacc__c> packagingAccts = [SELECT id FROM rstk__syacc__c WHERE rstk__syacc_mfgacct__c = '49950-1' AND rstk__syacc_div__c = :salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__c];
        LIST<rstk__syacc__c> packagingAccts = [SELECT id FROM rstk__syacc__c WHERE rstk__externalid__c =: salesOrder.Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c + '_49950-1'];
        //System.debug('SOQL: createRootstockSalesOrder: Limits: ' + Limits.getQueries());

        // Create Sales Order Header Extention
        //rstk__sohdrextn__c sohdrextn = new rstk__sohdrextn__c();
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
        //System.debug('DML: createRootstockSalesOrder: update sohdrextn');
        //System.debug('DML: createRootstockSalesOrder: update sohdrextn - disabled');
        update sohdrextn;
        //System.debug('SOQL: createRootstockSalesOrder: Limits: ' + Limits.getQueries());

        //System.debug('Rootstock Sales Order: Header: Default Project Master: ' + sohdr.rstk__sohdr_proj__c);
        // end - LLH

        return sohdr;
    }

    //FPO Sprint6 Create New workorder Components from old workorder if one exists
    public void transterWorkOrderComps(RootstockAutomation.RootstockObjects raobjs){

      String workOrderId = raobjs.WorkOrder.Id;
      rstk__wocst__c newworkorder = [SELECT rstk__wocst_div__c, rstk__wocst_site__c
                                        , rstk__wocst_div__r.rstk__externalid__c
                                        , rstk__wocst_site__r.rstk__sysite_site__c
                                        , Name 
                                        FROM rstk__wocst__c 
                                        WHERE Id=:workOrderId];
                
        //Create New workorder Components from old workorder if one exists
        if(raobjs.oldworkorder!= null && raobjs.oldwocomps!= null){          
            System.debug(loggingLevel.DEBUG,'**oldwocomps.size():' + raobjs.oldwocomps.size());
            List<rstk__woorddmd__c> wocompsToInsert = new List<rstk__woorddmd__c>();

            for(rstk__woorddmd__c oldwocomp:raobjs.oldwocomps){
                
                if(oldwocomp.rstk__woorddmd_lne__c != 0){
                  continue;
                }
                //clone components
                rstk__woorddmd__c  newwocomp = oldwocomp.clone(false,true,false,false);
                String extidStr = newworkorder.rstk__wocst_div__r.rstk__externalid__c + '_' + newworkorder.rstk__wocst_site__r.rstk__sysite_site__c + '_' + newworkorder.Name + '_' + oldwocomp.Name.substringAfter('_');                
                newwocomp.rstk__woorddmd_proj__c = raobjs.pjproj.Id ; //projmaster
                newwocomp.rstk__woorddmd_site__c = newworkorder.rstk__wocst_site__c; //site
                newwocomp.rstk__woorddmd_issproj__c = raobjs.pjproj.Id; //issued project
                newwocomp.rstk__woorddmd_ordno__c = newworkorder.Id ;//wo 
                newwocomp.rstk__woorddmd_compitem__c = raobjs.engMasterToInvItemMap.get(oldwocomp.rstk__woorddmd_compitem__r.rstk__icitem_item__c); // inv item master
                newwocomp.rstk__woorddmd_div__c = newworkorder.rstk__wocst_div__c; //div
                newwocomp.rstk__externalid__c = extidStr;// extid
                System.debug(loggingLevel.DEBUG,'**compitem: ' + newwocomp.rstk__woorddmd_compitem__c) ; 
                System.debug(loggingLevel.DEBUG,'**extid: ' + newwocomp.rstk__externalid__c) ; 
                wocompsToInsert.add(newwocomp);
            }
            upsert wocompsToInsert rstk__externalid__c;
            System.debug('**inserted comps.size' + wocompsToInsert.size());          
        }
    }


    // LLH - additions
    // Note: this method is called from a trigger and is bulkified
    public List<Install_Project__c> upsertInstallProjects( List<rstk__wocst__c> WorkOrders, List<Id> WorkOrderIds, List<Id> PM_ProjectIds, List<Id> SalesOrderIds ) {
        Map<Id, Install_Project__c> installProjsMap = new Map<Id, Install_Project__c>();

        // retrieve list of existing Install Projects by PM Project
        List<Install_Project__c> installProjects = [SELECT Id, Name, PM_Project__c FROM Install_Project__c WHERE PM_Project__c IN :PM_ProjectIds];
        // turn list into a Map indexed on Work Order
        for( Install_Project__c installproj : installProjects ) {
            installProjsMap.put( installproj.PM_Project__c, installproj);
        }

        // retrieve PM_projects objects referenced by WorkOrders
        Map<Id, PM_Project__c> ProjectMap = new Map<Id, PM_Project__c>([SELECT Id, Name  FROM PM_Project__c WHERE Id IN :PM_ProjectIds]);

        // retrieve SalesOrder objects referenced by WorkOrders
        Map<Id, SCRB_SalesOrder__c> SalesOrderMap = new Map<Id, SCRB_SalesOrder__c>([SELECT Id, Property__r.Hours_From_Nearest_Office__c,
                                                                                         System_Design_Quote__r.System_Design__r.Number_of_Arrays__c
                                                                                       FROM SCRB_SalesOrder__c WHERE Id IN :SalesOrderIds]);

        installProjects.clear();
        // loop through WorkOrders updating or inserting Install Projects
        for( rstk__wocst__c wo: WorkOrders ) {

          Install_Project__c installProj = installProjsMap.get(wo.PM_Project__c);
          // if Install Project exists - update
          if( installProj != null ) {
            // update Install Project
            installProj.Work_Order__c = wo.Id;
            installProjects.add(installProj);
          } else {
            // else create Install Project
            installProjects.add( createInstallProject( wo, ProjectMap.get(wo.PM_Project__c), SalesOrderMap.get(wo.Sales_Order__c) ) );
          }
        }

      return installProjects;
    }


    public Install_Project__c createInstallProject( rstk__wocst__c WorkOrder, PM_Project__c PM_Project, SCRB_SalesOrder__c SalesOrder ) {

      Install_Project__c ip = new Install_Project__c();

      ip.Name = PM_Project.Name;
      ip.PM_Project__c = WorkOrder.PM_Project__c;
      ip.Sales_Order__c = WorkOrder.Sales_Order__c;
      ip.Work_Order__c = WorkOrder.Id;
      ip.Number_of_Roofs__c = SalesOrder.System_Design_Quote__r.System_Design__r.Number_of_Arrays__c;
      ip.Standard_Project__c = true;

      ip.Electrician_Drive_Time_To_Site__c = SalesOrder.Property__r.Hours_From_Nearest_Office__c;
      ip.Drive_Time_Office_To_Site__c = SalesOrder.Property__r.Hours_From_Nearest_Office__c;
  
      return ip;      
    }
    // end - LLH

    // LLH - additions

    // Note: these methods are called from several triggers and are bulkified
    // these methods are called from (at least) InstallProjectTriggerHandler, PMProjectTriggerHandler and WorkOrderOperationsTriggerHandler

    // this is an overload of the 'updateWOOpsFromInstallProjs' method below that defaults to saving the Work Order Operations
    public static List<rstk__woordop__c> updateWOOpsFromInstallProjs( List<rstk__woordop__c> workOrderOps, Map<Id, Install_Project__c> installProjsMap, List<Id> workOrderIds ) {

        return updateWOOpsFromInstallProjs( workOrderOps, installProjsMap, workOrderIds, true);

    }

    public static List<rstk__woordop__c> updateWOOpsFromInstallProjs( List<rstk__woordop__c> workOrderOps, Map<Id, Install_Project__c> installProjsMap, List<Id> workOrderIds, Boolean updflg) {

        // the intent is to update the Run Std Hrs on Work Order Operations (10 & 20) when they are first created and any time the
        // Install Project is updated and whenever the PM Project is completed (which is an implicit change of the Install Project)
        System.debug('Entering updateWOOpsFromInstallProjs');

        List<rstk__woordop__c> woOpsNeedUpdate = new List<rstk__woordop__c>();

        // I need two things: 1) List<WO Ops> and 2) Map<Install Projs>

        // If I don't have both I'll need WO Ids
        if( (workOrderOps == null) || (installProjsMap == null) ) {

            // did, per chance, I get workOrderIds
            if( workOrderIds == null ) {

                workOrderIds = new List<Id>();

                if( installProjsMap != null ) {
                  // extract workOrderIds from InstallProjsMap
                  // 
                  for( Install_Project__c installProj : installProjsMap.values() ) {
                      workOrderIds.add( installProj.Work_Order__c );
                  }
                }

                if( workOrderOps != null ) {
                  // extract workOrderIds from workOrderOps
                  // 
                  for( rstk__woordop__c op : workOrderOps ) {
                      workOrderIds.add( op.rstk__woordop_ordno__c );
                  }
                }
            }

        }

        // by this point I have at least two of three essential things
        // workOrderOps, installProjsMap and/or workOrderIds
        // now I MUST have or derive workOrderOps and installProjsMap
        
        if( workOrderOps == null ) {
            workOrderOps = new List<rstk__woordop__c>();
            List<rstk__woordop__c> woOps = [SELECT Id, rstk__woordop_oper__c, rstk__woordop_runhrstd__c, rstk__woordop_ordno__c
                                                  FROM rstk__woordop__c
                                                  WHERE rstk__woordop_ordno__c IN :workOrderIds AND rstk__woordop_oper__c IN (10, 20)];
        }

        if( installProjsMap == null ) {
            installProjsMap = new Map<Id, Install_Project__c>();
            List<Install_Project__c> installProjs = [SELECT Id, Name, Electrician_Bonus_Budget_Hours__c, Installer_Bonus_Budget_Hours__c, Work_Order__c
                                            FROM Install_Project__c
                                            WHERE Work_Order__c IN :workOrderIds];
            for( Install_Project__c proj : installProjs ) {
                // put the Install Projects in a Map<> indexed by Work Order
                installProjsMap.put(proj.Work_Order__c, proj);
            }
        }

        // at this point I should have the two vital things needed workOrderOps and the installProjsMap

        if( workOrderOps.size() > 0 ) {
            // loop through the WO Ops detecting changes and adding to woOpsNeedUpdate list
            for( rstk__woordop__c op : workOrderOps ) {
              if( installProjsMap.containsKey(op.rstk__woordop_ordno__c) ) {  // skip operation is there's no Install Project
                if( op.rstk__woordop_oper__c == 10 ) {
                  op.rstk__woordop_runhrstd__c = installProjsMap.get(op.rstk__woordop_ordno__c).Installer_Bonus_Budget_Hours__c;
                  woOpsNeedUpdate.add(op);
                }
                if( op.rstk__woordop_oper__c == 20 ) {
                  op.rstk__woordop_runhrstd__c = installProjsMap.get(op.rstk__woordop_ordno__c).Electrician_Bonus_Budget_Hours__c;
                  woOpsNeedUpdate.add(op);
                }
              }
            }
        }

        // update if appropriate and/or pass back the WO Ops
        if( updflg ) {
            Database.saveResult[] dmlList = Database.update( woOpsNeedUpdate, false );
          
            // email errors
                // email it@astrumsolar.com
                String errmsg = '';
                
            for (Database.SaveResult sr : dmlList) {
                if (sr.isSuccess()) {
                    // Operation was successful
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        errmsg += 'Id:' + sr.getId() + ' : ' + err.getStatusCode() + ': ' + err.getMessage() + ' affected fields - ' + err.getFields() + '\n';
                    }
                    errmsg = 'Rootstock Automation Errors \n' + errmsg;
                    EmailUtil.AdminEmail('Rootstock Automation', 'Rootstock Automation error message', errmsg);
                }
            }           
        }

        return woOpsNeedUpdate;
    }
    // end - LLH

}