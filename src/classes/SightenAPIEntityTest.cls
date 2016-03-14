@isTest
private class SightenAPIEntityTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out
	
	@isTest static void testCreateAndInitializeEntities() {
        if(!runalltests){ return; }

		SightenAPIAddress.getApiName();
        SightenAPIAddress apiAddress = new SightenAPIAddress();
		apiAddress.data.city_name = '';
		apiAddress.data.county_name = '';
		apiAddress.data.elevation = 0;
		apiAddress.data.full_address = '';
		apiAddress.data.latitude = 0;
		apiAddress.data.longitude = 0;
		apiAddress.data.plus4_code = '';
		apiAddress.data.primary_number = '';
		apiAddress.data.secondary_designator = '';
		apiAddress.data.secondary_number = '';
		apiAddress.data.state_abbreviation = '';
		apiAddress.data.street_name = '';
		apiAddress.data.street_suffix = '';
		apiAddress.data.zipcode = '';

		apiAddress.data.uuid = '';
		apiAddress.data.date_created = '';
		apiAddress.data.created_by = new SightenAPIEntity.SightenAPIRelation();
		apiAddress.data.date_updated = '';
		apiAddress.data.modified_by = new SightenAPIEntity.SightenAPIRelation();

		apiAddress.buildRequestBody();
        SightenAPIAddress.SightenAPIAddressList apiAddressList = new SightenAPIAddress.SightenAPIAddressList();

        SightenAPIArray.getApiName();
        SightenAPIArray apiArray = new SightenAPIArray();
		apiArray.data.azimuth = 0;
		apiArray.data.capacity = 0;
		apiArray.data.gen_ac_1 = 0;
		apiArray.data.gen_ac_10 = 0;
		apiArray.data.gen_ac_11 = 0;
		apiArray.data.gen_ac_12 = 0;
		apiArray.data.gen_ac_2 = 0;
		apiArray.data.gen_ac_3 = 0;
		apiArray.data.gen_ac_4 = 0;
		apiArray.data.gen_ac_5 = 0;
		apiArray.data.gen_ac_6 = 0;
		apiArray.data.gen_ac_7 = 0;
		apiArray.data.gen_ac_8 = 0;
		apiArray.data.gen_ac_9 = 0;
		apiArray.data.gen_ac_total = 0;
		apiArray.data.gen_dc_total = 0;
		apiArray.data.generation = 0;
		apiArray.data.n_inverters = 0;
		apiArray.data.n_modules_series = 0;
		apiArray.data.n_series_parallel = 0;
		apiArray.data.productivity = 0;
		apiArray.data.shade_pct_1 = 0;
		apiArray.data.shade_pct_10 = 0;
		apiArray.data.shade_pct_11 = 0;
		apiArray.data.shade_pct_12 = 0;
		apiArray.data.shade_pct_2 = 0;
		apiArray.data.shade_pct_3 = 0;
		apiArray.data.shade_pct_4 = 0;
		apiArray.data.shade_pct_5 = 0;
		apiArray.data.shade_pct_6 = 0;
		apiArray.data.shade_pct_7 = 0;
		apiArray.data.shade_pct_8 = 0;
		apiArray.data.shade_pct_9 = 0;
		apiArray.data.tilt = 0;
		apiArray.data.x_system = new SightenAPIEntity.SightenAPIRelation();
		apiArray.data.x_system.uuid = '';
		apiArray.data.x_system.link = '';
		apiArray.data.x_system.natural_id = '';

		apiArray.request.module_model = 'a';
		apiArray.request.inverter_model = 'b';
		apiArray.buildRequestBody();
		SightenAPIArray.SightenAPIArrayList apiArrayList = new SightenAPIArray.SightenAPIArrayList();

		SightenAPIContact.getApiName();
		SightenAPIContact apiContact = new SightenAPIContact();
		apiContact.data.email = '';
		apiContact.data.first_name = '';
		apiContact.data.last_name = '';
		apiContact.data.phone_number = '';
		apiContact.data.site = new SightenAPIEntity.SightenAPIRelation();
		apiContact.data.site.uuid = '';
		apiContact.data.site.link = '';
		apiContact.data.site.natural_id = '';

		apiContact.buildRequestBody();
		SightenAPIContact.SightenAPIContactList apiContactList = new SightenAPIContact.SightenAPIContactList();

		SightenAPIContract.getApiName('send');
		SightenAPIContract.getApiName('download');
		SightenAPIContract.getApiName('');
		SightenAPIContract apiContract = new SightenAPIContract();
		apiContract.data.doc_id = '';
		apiContract.data.download_url = '';
		apiContract.data.sent_to = '';

		apiContract.request.quote_id = 'a';
		apiContract.buildRequestBody();
		SightenAPIContract.SightenAPIContractList apiContractList = new SightenAPIContract.SightenAPIContractList();

		SightenAPIEntity apiEntity = new SightenAPIEntity();
		apiEntity.db_table = '';
		apiEntity.status_code = 0;
		apiEntity.count = 0;
		apiEntity.messages = new SightenAPIEntity.SightenAPIMessages();

		SightenAPIEntity.SightenAPIMessage message = new SightenAPIEntity.SightenAPIMessage();
		message.msg_code = '';
		message.message = '';
		message.timestamp = '';
		apiEntity.messages.info.add(message);

		apiEntity.buildRequestBody();
	}
	
	@isTest static void testCallbackHandlerCredit() {
        if(!runalltests){ return; }

        String responseBody = '';

        SightenTestUtility.createSightenCustomSettings();

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		RestContext.request = req;
		RestContext.response= res;
		SightenRestCallbackHandler.doPut();
		responseBody = RestContext.response.responseBody.toString();
		system.assert(responseBody.contains('MISSING_IDENTIFICATION'));



		req.requestURI = '/services/apexrest/Lead';  //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.addHeader('Content-Type', 'application/json');
		req.addHeader('Identification', 'XXXXX');

		RestContext.request = req;
		RestContext.response= res;
		SightenRestCallbackHandler.doPut();
		responseBody = RestContext.response.responseBody.toString();
		system.assert(responseBody.contains('INVALID_TOKEN'));



		req.addHeader('Identification', 'D6B5A89663685F465FA358E53665A81E853527A53693F175D127359A55A11AF79CEE2DC77E2B1B4D');
		req.requestBody = Blob.valueOf(SightenTestCalloutMock.SIGHTEN_CONTACT_API_UPDATECREDIT_SUCCESS);

		RestContext.request = req;
		RestContext.response= res;
		SightenRestCallbackHandler.doPut();
		responseBody = RestContext.response.responseBody.toString();
		system.assert(responseBody.contains('INVALID_UUID'));



		CreateSCA();

		RestContext.request = req;
		RestContext.response= res;
		SightenRestCallbackHandler.doPut();
		responseBody = RestContext.response.responseBody.toString();
		system.assert(responseBody.contains('Your request was successful.'));
	}
	
	@isTest static void testCallbackHandlerContract() {
        if(!runalltests){ return; }

        String responseBody = '';

        SightenTestUtility.createSightenCustomSettings();

        testdata.setupCustomSettingsPricing();
        testdata.setupCustomConfigObjectsPricing();

        //Create System Design Quote        
        Opportunity_Trigger_Utility.skipOpportunityTrigger = true;
        System_Design_Quote__c sdq = testdata.setupSystemDesignQuote('Residential', 'Purchase', null, true, 12000);
        Opportunity_Trigger_Utility.skipOpportunityTrigger = false;

        // Add values to the Sighten uuid field for the lease fund
        SightenTestUtility.AddSightenUUIDValues(sdq);

        System_Design_Quote__c sdqTermLoan = [SELECT Id, Scenario_1_Term_Loan__c, Scenario_1_Term_Loan__r.Sighten_Product_uuid__c FROM System_Design_Quote__c WHERE Id = :sdq.Id LIMIT 1];

        Proposal__c prop = new Proposal__c(System_Design_Quote__c = sdq.ID);
        insert prop;

        Astrum_Contract__c contr1 = new Astrum_Contract__c(Proposal__c = prop.ID, Closed__c = true, Scenario__c = '1', Sighten_Contract_uuid__c = 'f874025e-e784-4a97-9fe8-76e3ffe88023', Sighten_Signing_Status__c = 'SENT');
        insert contr1;

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/Lead';  //Request URL
		req.httpMethod = 'POST';//HTTP Request Type
		req.addHeader('Content-Type', 'application/json');
		req.addHeader('Identification', 'XXXXX');
		req.addHeader('Identification', 'D6B5A89663685F465FA358E53665A81E853527A53693F175D127359A55A11AF79CEE2DC77E2B1B4D');
		req.requestBody = Blob.valueOf(SightenTestCalloutMock.SIGHTEN_QUOTE_API_GETMONTHLYPAYMENT_SUCCESS);

		RestContext.request = req;
		RestContext.response= res;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new SightenTestCalloutMock(200));
		SightenRestCallbackHandler.doPut();

		Test.stopTest();

		responseBody = RestContext.response.responseBody.toString();
		system.assert(responseBody.contains('Your request was successful.'));
	}

	private static void CreateSCA(){
        Account customer = new Account(Name = 'Test Customer');
        insert customer;

        Property__c prop = new Property__c();
        prop.Name = '123 Main St';
        prop.RecordTypeid = [Select id from RecordType where sobjecttype = 'Property__c' and Name ='Residential' limit 1].id;
        prop.Property_Owner__c = customer.Id;       
        prop.Optimal_Site_Quality_kWh_y_kW__c = double.valueOf('1250');
        prop.Property_State__c = 'MD';
        prop.Property_City__c = 'Annapolis Junction';        
        prop.Property_ZIP__c = '20701';
        prop.Property_County__c = 'Howard';
        prop.QAS_Property_County__c = 'Howard County, MD';    
        insert prop;

		Contact cont = new Contact(LastName = 'TestContact');
		insert cont;

		Lease_Fund__c lf = new Lease_Fund__c(Name = 'TestFund', Fund_Partner__c = customer.Id);
		insert lf;

        Sighten_Credit_Approval__c sca = new Sighten_Credit_Approval__c(
        	Credit_Status__c = 'NEW',
        	Property__c = prop.Id,
        	Contact__c = cont.Id,
        	Lease_Fund__c = lf.Id,
    		Sighten_Qualification_uuid__c = 'f534992e-670f-4c38-a259-696095b63e9d'
		);
        insert sca;
	}
}