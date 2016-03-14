@isTest //(seealldata=true)
private class AstrumEventControllerTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out

	@testSetup static void setupData() {
		CreatePricebookEntry();

		testData.setupCustomSettings();
		system.debug('setup AstrumEventSettings__c');
        AstrumEventSettings__c eventsettings = new AstrumEventSettings__c();

        eventsettings.Default_Onsite_Sales_Visit_Subject__c = 'Sales Visit';
    	eventsettings.Number_day_options_to_return__c = 5;
    	eventsettings.Number_days_to_schedule_new_visits_out__c = 0;
    	eventsettings.Open_Blocks_SOQL__c = 100;
    	insert eventsettings;

		User coordinator = createSalesCoordinator();
		User salesUser1 = createSalesUser('1');
		User salesUser2 = createSalesUser('2');

		createSalesRegion(coordinator.Id);
		Id olId = createOfficeLocation();
		Id stateId = createState();
		Id countyId = createCounty(stateId);
		Id ozcId = createOfficeZipCode('20701', stateId, olId);

		createZipCodeAvailability(salesUser1.Id, ozcId);
		createZipCodeAvailability(salesUser2.Id, ozcId);

		createBlocks(salesUser1.Id);
		createBlocks(salesUser2.Id);
	}

	@isTest static void TestAstrumEventControllerFromOpp() {
		if(!runalltests){ return; }

		//Create an opp that we will link to the new scheduled event, and the opp will be in the Eastern time to match the sales reps.
		Opportunity opp = Milestone1_Test_Utility.CreateTestOpp();
		opp.Sales_Region__c = 'MD Region';
		update opp;

        Test.startTest();
		
		Test.setCurrentPage(Page.AstrumEventEdit);
		AstrumEventController cont = new AstrumEventController();

		ApexPages.currentPage().getParameters().put('oppid', opp.id);
		ApexPages.currentPage().getParameters().put('retURL', opp.id);
		cont = new AstrumEventController();

		//System.assertEquals(2, cont.dates.size());
		//System.assertEquals(1, cont.times.size());

		cont.chosenDate  = cont.dates[1].getValue();
		cont.dateChanged();
		//System.assertEquals(1, cont.times.size());

		cont.cancel();
		Test.stopTest();
	}

	@isTest static void TestAstrumEventControllerFromOppBooked() {
		if(!runalltests){ return; }

		Test.startTest();

		//Create an opp that we will link to the new scheduled event, and the opp will be in the Eastern time to match the sales reps.
		Opportunity opp = Milestone1_Test_Utility.CreateTestOpp();

		Test.setCurrentPage(Page.AstrumEventEdit);
		AstrumEventController cont = new AstrumEventController();

		ApexPages.currentPage().getParameters().put('oppid', opp.id);
		ApexPages.currentPage().getParameters().put('retURL', opp.id);
		cont = new AstrumEventController();
		pagereference  ref = cont.bookit();

		Id eventId = ref.getParameters().get('id');

		String aquery = 'Select id,Status__c,Opportunity__c,Lead__c,Subject__c, Notes__c '
		 							+ ',start_date_time__c,stop_date_time__c,ownerID,location__c, '
		 							+' Customer_Start_Date_Time_Text__c,Customer_Stop_Date_Time_Text__c, '
		 							+' Property_ID__c,Property_Address_1__c,contact__c,Event_ID__c '
							    +' from Astrum_Event__c where id = :eventId' ; 

		/*Astrum_Event__c ae = [Select id,Status__c,Opportunity__c,Lead__c,Subject__c
		 							,start_date_time__c,stop_date_time__c,ownerID,location__c,
		 							Customer_Start_Date_Time_Text__c,Customer_Stop_Date_Time_Text__c,
		 							Property_ID__c,Property_Address_1__c,contact__c,Event_ID__c
							    from Astrum_Event__c where id = :ref.getParameters().get('id')];*/

		Astrum_Event__c ae = Database.query(aquery);	

		System.assertEquals('Schedule Pending', ae.status__c);

		System.debug('**ae -'+ ae);

		Test.setCurrentPage(ref);

		ApexPages.StandardController aecontroller = new ApexPages.StandardController(ae);
    	AstrumEventToScheduleController schController = new AstrumEventToScheduleController(aecontroller);  
		
		pagereference  refsch = schController.save();
		System.assertEquals(null, refsch);

		//schController.astrumEvent.notes__c = 'Test';

		schController.astrumEvent.put('notes__c' , 'Test');

		refsch = schController.save();
		ae = [Select id,Status__c,Opportunity__c,Lead__c,Subject__c from Astrum_Event__c where id = :ae.id];
		System.debug('**ae -'+ ae);
		System.assertEquals('Scheduled', ae.status__c);

		Test.stopTest();
	}


	@isTest static void TestAstrumEventControllerFromLead() {
		if(!runalltests){ return; }

    	Test.startTest();

    	AstrumScheduling__c userSettings = AstrumScheduling__c.getOrgDefaults();
    	userSettings.Monday_Sales_Visits__c  = 1;
    	userSettings.Tuesday_Sales_Visits__c  = 1;
    	userSettings.Wednesday_Sales_Visits__c = 1;
    	userSettings.Thursday_Sales_Visits__c = 1;
    	userSettings.Friday_Sales_Visits__c = 1;
    	userSettings.Saturday_Sales_Visits__c = 1;
    	userSettings.Sunday_Sales_Visits__c = 1;
    	userSettings.Sales_Visits_Per_Week__c = 1;
    	insert userSettings;

		Lead lead1 = new Lead(LastName='TestAbc2', Company='Test1 Inc.', County__c = 'Howard County, MD',
			Street= '100 Astrum Lane' , City = 'Annapolis Junction', State = 'MD', PostalCode = '20701' , LeadSource = 'Search Engine', Method_Of_Contact__c = 'Astrum Web Form'
		);

		insert lead1;

		Test.setCurrentPage(Page.AstrumEventEdit);
		ApexPages.currentPage().getParameters().put('leadid', lead1.id);
		ApexPages.currentPage().getParameters().put('retURL', lead1.id);
		AstrumEventController cont = new AstrumEventController();

		//System.assertEquals(2, cont.dates.size());
		//System.assertEquals(1, cont.times.size());

		cont.dummyContact.Birthdate = System.today() + 5;
		cont.lookForMore();

		//System.assertEquals(0, cont.dates.size());
		//System.assertEquals(0, cont.times.size());

		cont.startOver();

		//System.assertEquals(2, cont.dates.size());
		//System.assertEquals(1, cont.times.size());

		pagereference  ref = cont.bookit();

		System.debug('**Curr PAge -'+ref);
		System.debug('**ref PAge -'+ ref.getParameters());

		Id eventId = ref.getParameters().get('id');

		String aquery = 'Select id,Status__c,Opportunity__c,Lead__c,Subject__c, Notes__c '
		 							+ ',start_date_time__c,stop_date_time__c,ownerID,location__c, '
		 							+' Customer_Start_Date_Time_Text__c,Customer_Stop_Date_Time_Text__c, '
		 							+' Property_ID__c,Property_Address_1__c,contact__c,Event_ID__c '
							    +' from Astrum_Event__c where id = :eventId' ; 


		/*Astrum_Event__c ae = [Select id,Status__c,Opportunity__c,Lead__c,Subject__c
		 							,start_date_time__c,stop_date_time__c,ownerID,location__c,
		 							Customer_Start_Date_Time_Text__c,Customer_Stop_Date_Time_Text__c,
		 							Property_ID__c,Property_Address_1__c,contact__c,Event_ID__c
							    from Astrum_Event__c where id = :ref.getParameters().get('id')];*/

		Astrum_Event__c ae = Database.query(aquery);	

		System.assertEquals('Schedule Pending', ae.status__c);

		System.debug('**ae -'+ ae);

		Test.setCurrentPage(ref);

		ApexPages.StandardController aecontroller = new ApexPages.StandardController(ae);
    	AstrumEventToScheduleController schController = new AstrumEventToScheduleController(aecontroller);  

    	//schController.astrumEvent.notes__c = 'Test';
    	schController.astrumEvent.put('notes__c' , 'Test');
		schController.save();

		ae = [Select id,Status__c,Opportunity__c,Lead__c,Subject__c from Astrum_Event__c where id = :ae.id];
		System.debug('**ae -'+ ae);
		System.assertEquals('Scheduled', ae.status__c);

		schController.successFinish();

		Test.stopTest();
	}

	@isTest static void TestAstrumEventControllerFromLeadCancel() {
		if(!runalltests){ return; }

    	AstrumScheduling__c userSettings = AstrumScheduling__c.getOrgDefaults();
    	userSettings.Monday_Sales_Visits__c  = 1;
    	userSettings.Tuesday_Sales_Visits__c  = 1;
    	userSettings.Wednesday_Sales_Visits__c = 1;
    	userSettings.Thursday_Sales_Visits__c = 1;
    	userSettings.Friday_Sales_Visits__c = 1;
    	userSettings.Saturday_Sales_Visits__c = 1;
    	userSettings.Sunday_Sales_Visits__c = 1;
    	userSettings.Sales_Visits_Per_Week__c = 1;
    	insert userSettings;
        
		Test.startTest();

		Lead lead1 = new Lead(LastName='TestAbc2', Company='Test1 Inc.', County__c = 'Howard County, MD',
			Street= '100 Astrum Lane' , City = 'Annapolis Junction', State = 'MD', PostalCode = '20701' , LeadSource = 'Search Engine', Method_Of_Contact__c = 'Astrum Web Form'
		);
		insert lead1;

		Test.setCurrentPage(Page.AstrumEventEdit);
		ApexPages.currentPage().getParameters().put('leadid', lead1.id);
		ApexPages.currentPage().getParameters().put('retURL', lead1.id);
		AstrumEventController cont = new AstrumEventController();

		cont.showRestricted();
		cont.hideRestricted();


		pagereference  ref = cont.bookit();

		System.debug('**Curr PAge -'+ref);
		System.debug('**ref PAge -'+ ref.getParameters());

		Id eventId = ref.getParameters().get('id');

		String aquery = 'Select id,Status__c,Opportunity__c,Lead__c,Subject__c, Notes__c '
		 							+ ',start_date_time__c,stop_date_time__c,ownerID,location__c, '
		 							+' Customer_Start_Date_Time_Text__c,Customer_Stop_Date_Time_Text__c, '
		 							+' Property_ID__c,Property_Address_1__c,contact__c,Event_ID__c '
							    +' from Astrum_Event__c where id = :eventId' ; 


		/*Astrum_Event__c ae = [Select id,Status__c,Opportunity__c,Lead__c,Subject__c
		 							,start_date_time__c,stop_date_time__c,ownerID,location__c,
		 							Customer_Start_Date_Time_Text__c,Customer_Stop_Date_Time_Text__c,
		 							Property_ID__c,Property_Address_1__c,contact__c,Event_ID__c
							    from Astrum_Event__c where id = :ref.getParameters().get('id')];*/

		Astrum_Event__c ae = Database.query(aquery);	

		System.assertEquals('Schedule Pending', ae.status__c);

		System.debug('**ae -'+ ae);

		Test.setCurrentPage(ref);

		ApexPages.StandardController aecontroller = new ApexPages.StandardController(ae);
    	AstrumEventToScheduleController schController = new AstrumEventToScheduleController(aecontroller);  

    	

		schController.cancel();

		ae = [Select id,Status__c,Opportunity__c,Lead__c,Subject__c from Astrum_Event__c where id = :ae.id];
		System.debug('**ae -'+ ae);
		System.assertEquals('Schedule Pending - Cancelled', ae.status__c);

		Test.stopTest();
	}


	
	@isTest static void TestAstrumEventControllerFromOppBadData() {
		if(!runalltests){ return; }

		Test.setCurrentPage(Page.AstrumEventEdit);
		AstrumEventController cont = new AstrumEventController();

		ApexPages.currentPage().getParameters().put('oppid', '006M0000008V8sa');
		ApexPages.currentPage().getParameters().put('retURL', '006M0000008V8sa');
		cont = new AstrumEventController();
	}

	@isTest static void TestAstrumEventControllerFromLeadBadData() {
		if(!runalltests){ return; }

		Test.setCurrentPage(Page.AstrumEventEdit);
		AstrumEventController cont = new AstrumEventController();

		ApexPages.currentPage().getParameters().put('leadid', '00QM0000004XSVC');
		ApexPages.currentPage().getParameters().put('retURL', '00QM0000004XSVC');
		cont = new AstrumEventController();
	}
	


	@isTest static void TestAstrumEventSync() {
		if(!runalltests){ return; }

        AstrumEventSettings__c eventsettings = AstrumEventSettings__c.getInstance(UserInfo.getUserId());
        if (eventsettings == null)
        {
        	eventsettings.Default_Onsite_Sales_Visit_Subject__c = 'Sales Visit';
        	eventsettings.Number_day_options_to_return__c = 5;
        	eventsettings.Number_days_to_schedule_new_visits_out__c = 4;
        	eventsettings.Open_Blocks_SOQL__c = 100;
        	update eventsettings;
        }

        Test.startTest();

		Opportunity opp = Milestone1_Test_Utility.CreateTestOpp();
        Event theEvent = createEvent(opp);

        //assert that the astrum event was inserted and that the records are synced together
        Test.stopTest();
	}

	public static User createSalesCoordinator(){
		
		UserRole role = [SELECT Id FROM UserRole WHERE Name LIKE '%Sales%' AND Name LIKE '%coordinator%' LIMIT 1];
		Profile profile = [SELECT Id FROM Profile WHERE Name = 'Sales coordinator'];
		User salesUser = new User(
			UserName = 'salesCoord@test.com',
			LastName = 'sales',
			Email = 'salescoord@test.com',
			Alias = 'salescrd',
			CommunityNickName = 'Sales coordinator Test',
			TimeZoneSidKey = 'America/New_York',
			LocaleSidKey = 'en_US',
			LanguageLocaleKey = 'en_US',
			EmailEncodingKey = 'UTF-8',
			ProfileId = profile.Id,
			UserRoleId = role.Id
		);
		System.runAs(new User(Id = UserInfo.getUserId())){
			insert salesUser;
		}
		return salesUser;
	}

	public static User createSalesUser(string userNum){
		
		UserRole salesConsultantRole = [SELECT Id FROM UserRole WHERE Name LIKE '%Sales%' AND Name LIKE '%Consultant%' LIMIT 1];
		Profile salesUserProfile = [SELECT Id FROM Profile WHERE Name = 'Sales User'];
		User salesUser = new User(
			UserName = userNum + 'salesuser@test.com',
			LastName = 'sales',
			Email = userNum + 'salesuser@test.com',
			Alias = 'salesT1' + userNum,
			CommunityNickName = userNum + 'Sales Consultant Test',
			TimeZoneSidKey = 'America/New_York',
			LocaleSidKey = 'en_US',
			LanguageLocaleKey = 'en_US',
			EmailEncodingKey = 'UTF-8',
			ProfileId = salesUserProfile.Id,
			UserRoleId = salesConsultantRole.Id
		);
		System.runAs(new User(Id = UserInfo.getUserId())){
			insert salesUser;
		}
		return salesUser;
	}

	private static Event createEvent(Opportunity opp) {
        
        RecordType salesVisitRecordType = [SELECT Id FROM RecordType WHERE (DeveloperName = 'Sales_Visit_Onsite' or  DeveloperName = 'Sales_Visit_Remote') AND SobjectType = 'Event' limit 1];
        Event tempEvent = new Event();
        tempEvent.OwnerId = UserInfo.getUserId();
        tempEvent.RecordTypeId = salesVisitRecordType.Id;  
        tempEvent.Subject = 'Test';
        tempEvent.Event_Status__c = 'Scheduled';
        tempEvent.StartDateTime = Datetime.now()-3;
        tempEvent.EndDateTime = Datetime.now().addDays(1);
        tempEvent.WhatId = opp.Id;
                
        insert tempEvent;           
    
        return tempEvent;
    }

    private static void createBlocks(id userID) {
        
        RecordType blockRT = [SELECT Id FROM RecordType WHERE (DeveloperName = 'Availability_Block') AND SobjectType = 'Astrum_Event__c' limit 1];        
        list<Astrum_Event__c> events = new list<Astrum_Event__c>();
        
        //Start with a 3 hour long block
        datetime starttime = datetime.newInstance(System.today(), Time.newInstance(20, 0, 0, 0));
        datetime endtime = starttime.addHours(1);
        
        for(integer i = 0; i < 2; i++){ 
        	events.add(new Astrum_Event__c(start_date_time__c = starttime, stop_date_time__c = endtime, Status__c = 'Available', 
        									Subject__c = 'Availability Block', recordtypeid = blockRT.id, OwnerId = userID));
        	//space out the blocks by 1 hour
        	starttime = starttime.addDays(1);
        	endtime = endtime.addDays(1);
        }

        insert events;
    }
	
	public static Id createCounty(Id stateId) {
        County__c county = new County__c (
            Name = 'Howard County, MD',
            FIPS_Code__c = '00000',
            State__c = stateId,
            Sales_Region__c = 'MD Region'
        );
        insert county;
        return county.Id;
    }
	

	public static void createCountyAvailability(id userID, id countyID){
		County_Schedule_Availability__c salesCountyAvailability = new County_Schedule_Availability__c();
        salesCountyAvailability.County__c = countyID;
        salesCountyAvailability.Employee__c = userID;
        salesCountyAvailability.Type__c = 'Sales Rep';
        insert salesCountyAvailability;
	}

	private static void createSalesRegion(Id userId){
        Astrum_Sales_Region__c sr = new Astrum_Sales_Region__c(
        	Name = 'MD Region',
			backlog_in_days__c = 0,
			sales_coordinator__c = userId
		);
        insert sr;
	}
	
	private static Id createOfficeLocation(){
		Office_Location__c ol = new Office_Location__c(
			Name = 'Columbia Test, MD',
			Street__c = '7101 Riverwood Drive',
			City__c = 'Columbia',
			State__c = 'MD',
			Zip_Code__c = '21046',
			Active__c = true,
			State_Coverage__c = 'DC;MD;VA'
		);
		insert ol;
		return ol.Id;
	}

	private static Id createState(){
		State__c state = new State__c(
			Name = 'Maryland Test',
			State_Abbreviation__c = 'MD',
			FIPS_Code__c = '00'
		);
		insert state;
		return state.Id;
	}

	private static Id createOfficeZipCode(String zipCode, Id stateId, Id officeLocationId){
		Office_Zip_Code__c ozc = new Office_Zip_Code__c(
			Name = zipCode,
			Office_Location__c = officeLocationId,
			State__c = stateId
		);
		insert ozc;
		return ozc.Id;
	}

	private static void createZipCodeAvailability(Id userId, Id officeZipCodeId){
		Zip_Code_Schedule_Availability__c zcsa = new Zip_Code_Schedule_Availability__c(
			Office_Zip_Code__c = officeZipCodeId,
			Employee__c = userId,
			Type__c = 'Sales Rep',
			Start_Date__c = Date.today().addDays(-3),
			End_Date__c = Date.today().addDays(3)
		);
		insert zcsa;
	}

	private static void CreatePricebookEntry(){
        Product2 p = new Product2(
	        Name='testProduct223',
	        ProductCode = 'system'
    	);
        insert p;

        Id pbookId = Test.getStandardPricebookId();
              
        PricebookEntry pricebookEntry = new PricebookEntry(
	        UnitPrice = 2.32,
	        Pricebook2Id = pbookId,
	        UseStandardPrice = false,
	        Product2ID = p.Id,
	        IsActive  = true
    	);
        insert pricebookEntry;
	}
}