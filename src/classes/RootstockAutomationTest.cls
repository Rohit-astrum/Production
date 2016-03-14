/* FILE: RootstockAutomationTest.cls
 * AUTHOR: Lawrence Hovind
 * DATE: Aug 08, 2014
 * PURPOSE: Test the creation of Rootstock Objects from Astrum PM 2.0 Project.
 * MODIFICATION HISTORY
 * 08/12/2015 PB fpo-PhaseII- Modified test_Rootstock_Objects_creation method to fix soql limit exception
 * 02/16/2016 PB fpo-Sprint6
 */

@isTest(SeeAllData=true)
private class RootstockAutomationTest {
	
	// test creation of PM Project from Sales Order
	@isTest static void test_PM_Project_creation() {
		
		// test for VP of Operations override of Sales_Order.Status
		Profile p = [SELECT id FROM Profile WHERE Name = 'VP of Operations'];
		User u = new User( alias='vpuser', lastname='Ops', email='vpops@astrumsolar.com', EMailEncodingKey='UTF-8', TimeZoneSidKey='America/New_York',
							LocaleSidKey='en_US', LanguageLocaleKey='en_US', username='vpops@astrumsolar.com', profileid = p.Id );
		insert u;	
		

		//******************* Create New Sales Order to use for testing ************************
        Account customer = new Account(Name = 'Test Customer', BillingStreet = '244 Torrey Pine', BillingState = 'PA' , BillingPostalCode = '19380', BillingCountry = 'USA' ,BillingCity = 'West Chester');
        insert customer;
        Property__c property = CreateAstrumPM2ProjectTest.createNewProperty(customer.Id, '123 Test St');
        
        
        Opportunity opp = CreateAstrumPM2ProjectTest.createOpportunity(customer.Id, 'Test Oppty');     
        SCRB_SalesOrder__c salesOrder = CreateAstrumPM2ProjectTest.createSalesOrder(property.Id, opp.Id);
        salesOrder.AccountId__c = customer.Id;
        salesOrder.StatusCode__c = 'Sales Manager Approved';
        salesOrder.Opportunity_Close_Date__c = System.today().addDays(-8);
        update salesOrder;
        
        salesOrder = 
            [SELECT Id, Name, AccountId__c, AccountId__r.Name, RequestedShipmentOn__c, StatusCode__c
            FROM SCRB_SalesOrder__c 
            WHERE Id = :salesOrder.Id];
		//*******************************************

		PageReference pgref = Page.CreateAstrumPM2Project;
		pgref.getParameters().put('id', salesOrder.Id);

		Test.setCurrentPage(pgref);

		ApexPages.StandardController stdCntlr = new ApexPages.StandardController(salesOrder);
		CreateAstrumPM2ProjectExtension cntlr = new CreateAstrumPM2ProjectExtension(stdCntlr);		

		/*System.runAs(u) {

			//stdCntlr = new ApexPages.StandardController(so);
			//cntlr = new CreateAstrumPM2ProjectExtension(stdCntlr);

			cntlr.createProject();

			System.assertNotEquals(null, cntlr.projectId);
			System.debug('RA Test: Project created by VP of Operations: ' + cntlr.projectId);
		}
		*/

		salesOrder.StatusCode__c = 'Final/Accounting Approved';
		update salesOrder;
		System.debug('RA Test: working Sales Order updated to Final/Approved');
		
		Test.startTest();
		cntlr.createProject();
		Test.stopTest();
		System.assertNotEquals(null, cntlr.projectId);
		System.debug('RA Test: Project created as expected');
	}	

	
	@isTest static void test_Rootstock_Objects_creation() {	


		//******************* Create New Sales Order to use for testing ************************
        Account customer = new Account(Name = 'Test Customer', BillingStreet = '244 Torrey Pine', BillingState = 'PA' , BillingPostalCode = '19380', BillingCountry = 'USA' ,BillingCity = 'West Chester');
        insert customer;
        //Property__c property = CreateAstrumPM2ProjectTest.createNewProperty(customer.Id, '123 Test St');
        Property__c property = createNewProperty(customer.Id, '123 Test St');
        Opportunity opp = CreateAstrumPM2ProjectTest.createOpportunity(customer.Id, 'Test Oppty');     
        SCRB_SalesOrder__c salesOrder = CreateAstrumPM2ProjectTest.createSalesOrder(property.Id, opp.Id);
        salesOrder.AccountId__c = customer.Id;
        salesOrder.StatusCode__c = 'Final/Accounting Approved';
        salesOrder.Opportunity_Close_Date__c = System.today().addDays(-8);
        update salesOrder;
        
        salesOrder = 
            [SELECT Id, Name, AccountId__c, AccountId__r.Name, RequestedShipmentOn__c, StatusCode__c
            FROM SCRB_SalesOrder__c 
            WHERE Id = :salesOrder.Id];
		//*******************************************

		// use Rootstock automation to create a new PM Project
		System.debug('RA Test: testing PM Project creation');
		RootstockAutomation ra = new RootstockAutomation();
		Id projectId = ra.processSalesOrder( salesOrder );

		System.assertNotEquals(null, projectId);

		// use the newly created PM Project for the next tests
		PM_Project__c proj = [SELECT Id, Name FROM PM_Project__c WHERE Id = :projectId];

		PageReference pgref = Page.CreateRootstockObjects;
		pgref.getParameters().put('id', projectId);

		Test.setCurrentPage(pgref);

		// calling Visualforce page for first time
		ApexPages.StandardController stdCntlr = new ApexPages.StandardController(proj);
		CreateRootstockExtension cntlr = new CreateRootstockExtension(stdCntlr);

		cntlr.checkRootstockObjects();

		System.debug('Rootstock Objects: project: ' + ((cntlr.raobjs.project != null) ? (cntlr.raobjs.project.Id + '  Name: ' + cntlr.raobjs.project.Name) : 'null') );
		System.debug('Rootstock Objects: socust: ' + ((cntlr.raobjs.socust != null) ? (cntlr.raobjs.socust.Id + '  External Id: ' + cntlr.raobjs.socust.rstk__externalid__c) : 'null') );
		System.debug('Rootstock Objects: pjproj: ' + ((cntlr.raobjs.pjproj != null) ? (cntlr.raobjs.pjproj.Id + '  External Id: ' + cntlr.raobjs.pjproj.rstk__externalid__c) : 'null') );
		System.debug('Rootstock Objects: soprod: ' + ((cntlr.raobjs.soprod != null) ? (cntlr.raobjs.soprod.Id + '  External Id: ' + cntlr.raobjs.soprod.rstk__externalid__c) : 'null') );
		System.debug('Rootstock Objects: sohdr: ' + ((cntlr.raobjs.sohdr != null) ? (cntlr.raobjs.sohdr.Id + '  External Id: ' + cntlr.raobjs.sohdr.rstk__externalid__c) : 'null') );
		System.debug('Rootstock Objects: workorder: ' + ((cntlr.raobjs.workorder != null) ? (cntlr.raobjs.workorder.Id + '  External Id: ' + cntlr.raobjs.workorder.rstk__externalid__c) : 'null') );
		System.debug('Rootstock Objects: installproj: ' + ((cntlr.raobjs.installproj != null) ? (cntlr.raobjs.installproj.Id + '  Name: ' + cntlr.raobjs.installproj.Name) : 'null') );

		System.assertEquals(true, cntlr.autoprocess);

		// test creation of Rootstock Customer Object
		cntlr.checkRootstockObjects();
		System.assertEquals(true, cntlr.raobjs.RootstockCustomerExists());

		// test creation of EIM, Project Master and Product Master
		cntlr.checkRootstockObjects();
		System.debug('RA - Test: Project Master: ' + cntlr.raobjs.pjproj);
		System.debug('RA - Test: Product Master: ' + cntlr.raobjs.soprod);
		System.assertEquals(true, cntlr.raobjs.RootstockMastersExist());
		System.debug('SOQL: LimitsbeforeStart: ' + Limits.getQueries());
		Test.startTest();
		System.debug('SOQL: LimitsStart: ' + Limits.getQueries());
		// test for Rootstock Sales Order, SO Line and Work Order creation
		//Test.setCurrentPage(pgref);

		//stdCntlr = new ApexPages.StandardController(proj);
		//cntlr = new CreateRootstockExtension(stdCntlr);
		//cntlr.autoprocess = true;
		//cntlr.step = 3;

		cntlr.checkRootstockObjects();
		System.assertEquals(true, cntlr.raobjs.RootstockObjectsExist());


		System.debug(loggingLevel.ERROR,'Rootstock Objects: project: ' + ((cntlr.raobjs.project != null) ? (cntlr.raobjs.project.Id + '  Name: ' + cntlr.raobjs.project.Name) : 'null') );
		System.debug(loggingLevel.ERROR,'Rootstock Objects: socust: ' + ((cntlr.raobjs.socust != null) ? (cntlr.raobjs.socust.Id + '  External Id: ' + cntlr.raobjs.socust.rstk__externalid__c) : 'null') );
		System.debug(loggingLevel.ERROR,'Rootstock Objects: pjproj: ' + ((cntlr.raobjs.pjproj != null) ? (cntlr.raobjs.pjproj.Id + '  External Id: ' + cntlr.raobjs.pjproj.rstk__externalid__c) : 'null') );
		System.debug(loggingLevel.ERROR,'Rootstock Objects: soprod: ' + ((cntlr.raobjs.soprod != null) ? (cntlr.raobjs.soprod.Id + '  External Id: ' + cntlr.raobjs.soprod.rstk__externalid__c) : 'null') );
		System.debug(loggingLevel.ERROR,'Rootstock Objects: sohdr: ' + ((cntlr.raobjs.sohdr != null) ? (cntlr.raobjs.sohdr.Id + '  External Id: ' + cntlr.raobjs.sohdr.rstk__externalid__c) : 'null') );
		System.debug(loggingLevel.ERROR,'Rootstock Objects: workorder: ' + ((cntlr.raobjs.workorder != null) ? (cntlr.raobjs.workorder.Id + '  External Id: ' + cntlr.raobjs.workorder.rstk__externalid__c) : 'null') );
		System.debug(loggingLevel.ERROR,'Rootstock Objects: installproj: ' + ((cntlr.raobjs.installproj != null) ? (cntlr.raobjs.installproj.Id + '  Name: ' + cntlr.raobjs.installproj.Name) : 'null') );

		System.debug('Checking for Work Order creation');
		System.assertNotEquals(null, cntlr.raobjs.workorder);
		// test WO initial status is '2-Firm'
		System.debug('RA Test: Work Order Status: ' + cntlr.raobjs.workorder.rstk__wocst_ordsts__c);
		System.assertEquals('2', cntlr.raobjs.workorder.rstk__wocst_ordsts__c);
		// test WO has Sales Order and PM Project references
		System.assertEquals(cntlr.raobjs.workorder.Sales_Order__c, salesOrder.Id);
		System.assertEquals(cntlr.raobjs.workorder.PM_Project__c, cntlr.raobjs.project.Id);

		// this triggers Install Project creation and Extract Operations
		// check creation of Install Project
		System.debug('Checking for Install Project creation');
		System.assertNotEquals(null, cntlr.raobjs.installproj);

		// check Install Project has Work Order reference
		System.debug('Checking that Work Order is linked to Install Project');
		System.assertEquals(cntlr.raobjs.installproj.Work_Order__c, cntlr.raobjs.workorder.Id);
		// test Install Project has PM Project reference from WO PM Project reference
		System.debug('Checking that Install Project has link to PM PM Project');
		System.assertEquals(cntlr.raobjs.installproj.PM_Project__c, cntlr.raobjs.project.Id);

		// check if Extract Operations has been performed
		
		// reload page after creation
		cntlr.checkRootstockObjects();		
		System.assertEquals( false, cntlr.autoprocess );

		System.debug('SOQL: Limits1: ' + Limits.getQueries());
		// test for WO Due Date update from PM Project Install date update
		proj = [SELECT Id, Name, Install__c FROM PM_Project__c WHERE Id = :cntlr.raobjs.project.Id];
		proj.Install__c = Date.Today();
		update proj;

		rstk__wocst__c wo = [SELECT Id, Name, rstk__wocst_duedte__c FROM rstk__wocst__c WHERE Id = :cntlr.raobjs.workorder.Id];

		System.debug('RA Test: Checking Work Order Due Date has been updated from PM Project');
		System.debug('Work Order: ' + wo.Name + ' with PM Project: ' + proj.Name);
		System.assertEquals(proj.Install__c, wo.rstk__wocst_duedte__c);

		System.debug('SOQL: Limits2: ' + Limits.getQueries());
		// test for Install Project name update from PM Project name update
		proj.Name = proj.Name + '-changed';
		update proj;

		System.debug('SOQL: Limits3: ' + Limits.getQueries());
		Install_Project__c installproj2 = [SELECT Id, Name FROM Install_Project__c WHERE Id = :cntlr.raobjs.installproj.Id];

		System.debug('RA Test: Checking Install Project Name change has been updated from PM Project');
		System.assertEquals(proj.Name, installproj2.Name);
		Test.stopTest();

		// test for Completing PM Project
		//proj.Work_Completed__c = Date.Today();
		//update proj;
		/* FPO Sprint 6 
		System.debug('RA Test: set PM Project completion');


		// break connections so we can test reconnect
		cntlr.raobjs.project.Work_Order__c = null;
		cntlr.raobjs.workorder.Sales_Order__c = null;
		cntlr.raobjs.workorder.PM_Project__c = null;
		cntlr.raobjs.workorder.rstk__wocst_soline__c = null;
		cntlr.raobjs.soline.rstk__soline_wocstordno__c = null;
		cntlr.raobjs.soline.Sales_Order__c = null;
		cntlr.raobjs.installproj.Sales_Order__c = null;
		cntlr.raobjs.installproj.PM_Project__c = null;
		cntlr.raobjs.installproj.Work_Order__c = null;

		System.debug(loggingLevel.ERROR,'Before test stop************1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
		System.debug(loggingLevel.ERROR,'Before test stop************2.Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
		System.debug(loggingLevel.ERROR,'Before test stop************3. Number of script statements used so far : ' +  Limits.getDmlStatements());
		Test.stopTest();//fpo-2
		System.debug(loggingLevel.ERROR,'after test stop************1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
		System.debug(loggingLevel.ERROR,'after test stop************2.Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
		System.debug(loggingLevel.ERROR,'after test stop************3. Number of script statements used so far : ' +  Limits.getDmlStatements());
		System.debug('SOQL: Limits4: ' + Limits.getQueries());
		// re-connect lost objects
		//cntlr.connectLostRootstockObjects(); */
		
		
	}

	//fpo-Sprint6
	@isTest static void test_connectLostRootstockObjects(){
		
		Id projId;
		try{
			projId = [SELECT Sales_Order__c
					, PM_Project__c
					, rstk__wocst_soline__c
					, rstk__wocst_soline__r.rstk__soline_wocstordno__c 
					FROM rstk__wocst__c  
					WHERE rstk__wocst_soline__c <> null
					AND rstk__wocst_soline__r.rstk__soline_wocstordno__c <> null
					AND PM_Project__c <> null 
					AND Sales_Order__c <> null 
					AND rstk__wocst_ordsts_pl__c ='2-Firm' 
					ORDER BY CreatedDate DESC 
					LIMIT 1].PM_Project__c;

		}catch(QueryException qe){
			System.debug('No work order found that meets the query criteria');
		}

		if(projId != null){
			System.debug('**pm projId:' + projId);
			PM_Project__c proj = [SELECT Id, Name FROM PM_Project__c WHERE Id=:projId];
			
			ApexPages.StandardController stdCntlr = new ApexPages.StandardController(proj);		
			CreateRootstockExtension cntlr = new CreateRootstockExtension(stdCntlr);

			System.assertNotEquals(null,cntlr.raobjs.project.Work_Order__c);
			System.assertNotEquals(null,cntlr.raobjs.workorder.Sales_Order__c);
			System.assertNotEquals(null,cntlr.raobjs.workorder.PM_Project__c);
			System.assertNotEquals(null,cntlr.raobjs.workorder.rstk__wocst_soline__c);
			System.assertNotEquals(null,cntlr.raobjs.soline);
			if(cntlr.raobjs.soline != null){
				System.debug(cntlr.raobjs.soline.rstk__soline_wocstordno__c);
				System.debug(cntlr.raobjs.soline.Sales_Order__c);
			}
			System.assertNotEquals(null,cntlr.raobjs.installproj);
			if(cntlr.raobjs.installproj != null){
				System.debug(cntlr.raobjs.installproj.Sales_Order__c);
				System.debug(cntlr.raobjs.installproj.PM_Project__c);
				System.debug(cntlr.raobjs.installproj.Work_Order__c);
			}
			
			// break connections so we can test reconnect
			cntlr.raobjs.project.Work_Order__c = null;
			cntlr.raobjs.workorder.Sales_Order__c = null;
			cntlr.raobjs.workorder.PM_Project__c = null;
			cntlr.raobjs.workorder.rstk__wocst_soline__c = null;
			if(cntlr.raobjs.soline != null){
				cntlr.raobjs.soline.rstk__soline_wocstordno__c = null;
				cntlr.raobjs.soline.Sales_Order__c = null;
			}
			
			if(cntlr.raobjs.installproj != null){
				cntlr.raobjs.installproj.Sales_Order__c = null;
				cntlr.raobjs.installproj.PM_Project__c = null;
				cntlr.raobjs.installproj.Work_Order__c = null;
			}
			
			cntlr.connectLostRootstockObjects();
			/*
			System.assertNotEquals(null,cntlr.raobjs.project.Work_Order__c);
			System.assertNotEquals(null,cntlr.raobjs.workorder.Sales_Order__c);
			System.assertNotEquals(null,cntlr.raobjs.workorder.PM_Project__c);
			System.assertNotEquals(null,cntlr.raobjs.workorder.rstk__wocst_soline__c);
			System.assertNotEquals(null,cntlr.raobjs.soline);
			if(cntlr.raobjs.soline != null){
				System.debug(cntlr.raobjs.soline.rstk__soline_wocstordno__c);
				System.debug(cntlr.raobjs.soline.Sales_Order__c);
			}
			System.assertNotEquals(null,cntlr.raobjs.installproj);
			if(cntlr.raobjs.installproj != null){
				System.debug(cntlr.raobjs.installproj.Sales_Order__c);
				System.debug(cntlr.raobjs.installproj.PM_Project__c);
				System.debug(cntlr.raobjs.installproj.Work_Order__c);
			}*/
		}		
	}

	//fpo-Sprint6
	@isTest static void test_Work_Order_Operations() {

		// update random Work Order Op to fire WorkOrderOperations trigger
		try {
			rstk__woordop__c woop = [SELECT Id, name, rstk__woordop_runhrstd__c FROM rstk__woordop__c WHERE rstk__woordop_oper__c = 10 ORDER BY CreatedDate DESC LIMIT 1];		
			update woop;
		}
		catch ( Exception e ) {
			System.debug('RA Test: Rootstock Work Order Operations Update: caught exception' + e);
		}

	}
	

	// Test Admin Email
	@isTest static void test_Admin_Email() {
		EmailUtil.AdminEmail('Rootstock Automation Test', 'Rootstock Automation Test email message', 'You may ignore this test message.');
	}
    public static Property__c createNewProperty(Id ownerId, String name) {
        Property__c property = new Property__c(
            Name = name,
            Property_Owner__c = ownerId,
            Property_City__c = 'Shippensburg',
            Property_State__c = 'PA',
            Property_Zip__c = '17257-9266',
            Property_County__c = 'Franklin',
            Astrum_Office__c = 'Norristown, PA',
            Hours_From_Nearest_Office__c = 1.0
        );
        insert property;
        return property;
    }


    /********************************************Legacy test code*******************************************************
    
	@isTest static void test_Work_Order_updates() {

		//testData.setupCustomConfigObjects();

		
		// get a Sales Order to use for the tests
		//SCRB_SalesOrder__c so;
		// SOQl for working Sales Order
		//List<SCRB_SalesOrder__c> salesorders = [SELECT Id, StatusCode__c FROM SCRB_SalesOrder__c 
		//											WHERE StatusCode__c = 'Sales Manager Approved'
		//											 	AND Property__r.Property_State__c != 'OH'
		//											  	AND Rootstock_Sales_Order__c = null
		//											   	AND Opportunity_Close_Date__c != null];
		//if( salesorders.size() > 0 ) {
		//	so = salesorders[0];
		//}
		//System.assertNotEquals(null, so);
		//System.debug('RA Test: Found working Sales Order: ' + so.Id);
		////////////////////////////////////////////////////////////////////////////////////////////////////
		//testData.setupCustomConfigObjects();

		// we need a NEW PM Project, so find a working Sales Order, create a PM Project for it and use that one
		// 		
		//SCRB_SalesOrder__c so;
		// SOQl for working Sales Order
		//List<SCRB_SalesOrder__c> salesorders = [SELECT Id, Name, StatusCode__c FROM SCRB_SalesOrder__c 
		//											WHERE StatusCode__c = 'Sales Manager Approved'
		//											 	AND Property__r.Astrum_Office_New__r.Rootstock_Division__r.rstk__externalid__c != '500'
		//											  	AND Rootstock_Sales_Order__c = null];
		//											   	//AND Opportunity_Close_Date__c != null];
		//if( salesorders.size() > 0 ) {
		//	Integer idx = salesorders.size() - 1;
		//	idx = 0;
		//	so = salesorders[idx];
		//}
		//System.assertNotEquals(null, so.Id);

		//System.debug('RA Test: Sales Order selected, Id: ' + so.Id + '  Name: ' + so.Name);
		// set Sales_Order.Status = "Final/Approved"
		//so.StatusCode__c = 'Final/Accounting Approved';
		//update so;

		Install_Project__c installproj;

		// find Install Project with PM Project and Work Order
		List<Install_Project__c> installprojs = [SELECT Id, Name, PM_Project__c, PM_Project__r.Work_Order__c, Work_Order__c FROM Install_Project__c
														WHERE PM_Project__c != null AND Work_Order__c != null];
		//if( installprojs.size() > 0 ) {
		//	installproj = installprojs[0];
		//}
		for( Install_Project__c insproj : installprojs ) {
			if( (insproj.Work_Order__c == insproj.PM_Project__r.Work_Order__c) ) {
				installproj = insproj;
				break;
			}
		}
		System.assertNotEquals(null, installproj);

		Test.startTest();

		rstk__wocst__c wo = [SELECT Id, Name, rstk__wocst_duedte__c FROM rstk__wocst__c WHERE Id = :installproj.Work_Order__c];
		// extract operations for Work Order
		List<rstk__sydata__c> extractOps = new List<rstk__sydata__c>();
    	// create Extract Ops
    	extractOps.add( new rstk__sydata__c(
    						rstk__sydata_sourcepgm__c = 'RstkAutomationTest',
    						rstk__sydata_txntype__c = 'Extract Operations',
    						rstk__sydata_wocst__c = wo.Id
    						) );
		insert extractOps;

		Test.stopTest();

		// test for WO Due Date update from PM Project Install date update
		PM_Project__c proj = [SELECT Id, Name, Install__c FROM PM_Project__c WHERE Id = :installproj.PM_Project__c];
		proj.Install__c = Date.Today();
		update proj;

		wo = [SELECT Id, Name, rstk__wocst_duedte__c FROM rstk__wocst__c WHERE Id = :installproj.Work_Order__c];

		System.debug('RA Test: Checking Work Order Due Date has been updated from PM Project');
		System.debug('Work Order: ' + wo.Name + ' with PM Project: ' + proj.Name);
		System.assertEquals(proj.Install__c, wo.rstk__wocst_duedte__c);

		// test for Install Project name update from PM Project name update
		proj.Name = proj.Name + '-changed';
		update proj;

		Install_Project__c installproj2 = [SELECT Id, Name FROM Install_Project__c WHERE Id = :installproj.Id];

		System.debug('RA Test: Checking Install Project Name change has been updated from PM Project');
		System.assertEquals(proj.Name, installproj2.Name);


		// test for Completing PM Project
		//proj.Work_Completed__c = Date.Today();
		//update proj;
		
		System.debug('RA Test: set PM Project completion');
	}

	// test for WO Operations update on PM Project update
	// test for WO Operations Run STd Hrs update from Install Project Bonus Hrs update
	@isTest static void test_Work_Order_Operations() {
		// retrieve a Work Order with Operations
		// then change its PM Project or Install Project

		PM_Project__c project;
		Id projectId;
		Install_Project__c installproj;
		List<Id> workorderIds = new List<Id>();

		// find Install Project with PM Project and Work Order
		List<Install_Project__c> installprojs = [SELECT Id, Name, PM_Project__c, PM_Project__r.Work_Order__c, Work_Order__c, Work_Order__r.PM_Project__c
														FROM Install_Project__c
														WHERE PM_Project__c != null AND Work_Order__c != null];
		for( Install_Project__c insproj : installprojs ) {
			if( (insproj.Work_Order__r.PM_Project__c == insproj.PM_Project__c) ) {
				workorderIds.add(insproj.Work_Order__c);
			}
		}

		List<rstk__wocst__c> workorders = [SELECT Id, Name, PM_Project__c, (SELECT Id, Name, rstk__woordop_oper__c FROM rstk__WOORDOPS__r)
												FROM rstk__wocst__c WHERE Id IN :workorderIds];
		for( rstk__wocst__c wo : workorders ) {
			if( wo.rstk__WOORDOPS__r.size() > 0 ) {
				for( rstk__woordop__c woop : wo.rstk__WOORDOPS__r ) {
					if( (woop.rstk__woordop_oper__c == 10) || (woop.rstk__woordop_oper__c == 20) ) {
						projectId = wo.PM_Project__c;
						break;
					}
				}
			}
			if( projectId != null ) {
				break;
			}
		}

		project = [SELECT Id, Name FROM PM_Project__c WHERE Id = :projectId];
		System.assertNotEquals(null, project);

		project.Work_Completed__c = Date.Today();
		update project;

		// this should fire off the trigger to update Work Order Operations update

	}

*/
/*
    static testmethod void testCustCreation(){

      Account acct = new Account(Name = 'Test CustomerRstk1'
	    , BillingStreet = '48 Hawkins Rd'
	    , BillingState = 'NY' 
	    , BillingPostalCode = '13813-1602'
	    , BillingCountry = 'USA' 
	    ,BillingCity = 'Nineveh');
	    insert acct;

        acct.rstk__Rootstock_Customer__c = true;
        acct.c2g__CODAAccountTradingCurrency__c = 'USD';
        acct.ShippingCountry='USA';
        acct.c2g__CODASalesTaxStatus__c = 'Exempt';
        acct.c2g__CODAVATStatus__c = 'Home';
        acct.c2g__CODAIncomeTaxType__c = 'Not Reportable';
        acct.c2g__CODATaxCalculationMethod__c = 'Gross';
     	acct.c2g__CODACreditStatus__c = 'Credit Allowed';
     	acct.c2g__CODAPaymentMethod__c = 'Check';
        update acct;
        

       acct =  [SELECT a.BillingStreet, a.BillingState, a.BillingPostalCode
                           , a.BillingCountry, a.BillingCity, a.ShippingStreet
                           , a.ShippingState, a.ShippingPostalCode, a.ShippingCountry
                           , a.ShippingCity, rstk__Rootstock_Customer__c
                           ,  a.c2g__CODATaxCode1__c, a.Accounting_Id__c , a.name
                           FROM Account a 
                           WHERE Id = :acct.Id];
                
        System.debug(loggingLevel.ERROR,'AccountId:' + acct.Id + ':' + acct.Accounting_Id__c);
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
    }
    ******************************************************************************************************************/   
	
}