@isTest
private class SurveyCreationPageTest {
    private static boolean runalltests = true; // true to run all tests; false to skip tests and only run those where the 'if' is commented out
	
	@isTest static void SurveyCreationFieldSurveyTest() {
		if(!runalltests){ return; }
		
		Account customer = new Account(Name = 'Test Customer');
    	insert customer;
    	Property__c property = CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');

		RecordType surveyRt = [Select Id , Name from RecordType Where SobjectType = 'Survey__c' and Name = 'Field Survey' ];

		Test.startTest();

		Survey__c fieldSurvey = new Survey__c();
		fieldSurvey.RecordTypeId = surveyRt.Id;
		
		Test.setCurrentPage(Page.SurveyCreationPage);
		ApexPages.currentPage().getParameters().put('RecordType',fieldSurvey.RecordTypeId );

		ApexPages.StandardController surveycontroller = new ApexPages.StandardController(fieldSurvey);
    	SurveyCreationPageExtension extn = new SurveyCreationPageExtension(surveycontroller);
		
		fieldSurvey.Surveyor__c = UserInfo.getUserId();
		fieldSurvey.Date_Completed__c = System.Now();  
		fieldSurvey.Property__c = property.Id;

    	extn.unziplocations = new List<Install_Location__c>();
    	Install_Location__c il = new Install_Location__c();
    	il.Location__c = 'S01';
    	il.Property__c = property.Id;
    	il.Pitch__c = 90;
    	il.Physical_Surface_Letter__c = 'A';
    	il.Azimuth__c = 122;
    	il.Annual_Solar_Access__c = 100;
    	il.TSRF__c = 90;

    	extn.unziplocations.add(il);

    	extn.Confirm();

    	extn.save();

    	extn.unzippedState = '[{"Pitch__c":36,"Apr_Solar_Access__c":99.8,"Aug_Solar_Access__c":99.6,"Oct_Solar_Access__c":99.7,"Azimuth__c":192,"Name":"S01","Jun_Solar_Access__c":99.1,"Jul_Solar_Access__c":99.4,"Mar_Solar_Access__c":99.5,"Feb_Solar_Access__c":99.7,"Jan_Solar_Access__c":98.8,"Sep_Solar_Access__c":99.7,"Annual_Solar_Access__c":99.4,"Dec_Solar_Access__c":98.9,"Nov_Solar_Access__c":98.9,"May_Solar_Access__c":99.4,"Location__c":"S01"}]';
    	extn.unzipped();

    	Test.setCurrentPage(Page.SurveyCreationPage);
		ApexPages.currentPage().getParameters().put('id',fieldSurvey.Id );
		ApexPages.StandardController surveycontroller1 = new ApexPages.StandardController(fieldSurvey);
    	SurveyCreationPageExtension extn1 = new SurveyCreationPageExtension(surveycontroller1);
    	extn1.Confirm();

    	extn1.save();

    	Test.stopTest(); 
		// Implement test code
	}

	@isTest static void SurveyCreationAerialSurveyTest() {
		if(!runalltests){ return; }
		
		Account customer = new Account(Name = 'Test Customer');
    	insert customer;
    	Property__c property = CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');

		RecordType surveyRt = [Select Id , Name from RecordType Where SobjectType = 'Survey__c' and Name = 'Aerial Photo Survey' ];

		Test.startTest();

		Survey__c fieldSurvey = new Survey__c();
		fieldSurvey.RecordTypeId = surveyRt.Id;
		
		Test.setCurrentPage(Page.SurveyCreationPage);
		ApexPages.currentPage().getParameters().put('RecordType',fieldSurvey.RecordTypeId );

		ApexPages.StandardController surveycontroller = new ApexPages.StandardController(fieldSurvey);
    	SurveyCreationPageExtension extn = new SurveyCreationPageExtension(surveycontroller);
		
		fieldSurvey.Surveyor__c = UserInfo.getUserId();
		fieldSurvey.Date_Completed__c = System.Now();  
		fieldSurvey.Property__c = property.Id;

    	extn.unziplocations = new List<Install_Location__c>();
    	
    	extn.addNewLocation();

    	Install_Location__c il = extn.unziplocations[0];
    	il.Location__c = 'S01';
    	il.Property__c = property.Id;
    	il.Pitch__c = 90;
    	il.Physical_Surface_Letter__c = 'A';
    	il.Azimuth__c = 122;
    	il.Annual_Solar_Access__c = 100;
    	il.TSRF__c = 90;

    	//

    	extn.Confirm();

    	extn.save();

    	extn.Reassign();

    	Test.stopTest(); 
		// Implement test code
	}

	@isTest static void SurveyCreationEditSurveyTest() {
		if(!runalltests){ return; }
		
		Account customer = new Account(Name = 'Test Customer');
    	insert customer;
    	Property__c property = CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');

		RecordType surveyRt = [Select Id , Name from RecordType Where SobjectType = 'Survey__c' and Name = 'Aerial Photo Survey' ];

		Test.startTest();

		Survey__c fieldSurvey = new Survey__c();
		fieldSurvey.RecordTypeId = surveyRt.Id;
		fieldSurvey.Surveyor__c = UserInfo.getUserId();
		fieldSurvey.Date_Completed__c = System.Now();  
		fieldSurvey.Property__c = property.Id;
		insert fieldSurvey;
		
		Test.setCurrentPage(Page.SurveyCreationPage);
		ApexPages.currentPage().getParameters().put('id',fieldSurvey.Id );
		ApexPages.currentPage().getParameters().put('index','0' );

		ApexPages.StandardController surveycontroller = new ApexPages.StandardController(fieldSurvey);
    	SurveyCreationPageExtension extn = new SurveyCreationPageExtension(surveycontroller);
		
		
    	extn.unziplocations = new List<Install_Location__c>();
    	
    	Install_Location__c il = new Install_Location__c();
    	il.Location__c = 'S01';
    	il.Property__c = property.Id;
    	il.Pitch__c = 90;
    	il.Physical_Surface_Letter__c = 'A';
    	il.Azimuth__c = 122;
    	il.Annual_Solar_Access__c = 100;
    	il.TSRF__c = 90;

    	extn.unziplocations.add(il);

    	//extn.addNewLocation();

    	extn.Confirm();

    	extn.save();

    	extn.deleteLocation();

    	extn.save();

    	Test.stopTest(); 
		// Implement test code
	}


	@isTest static void SurveyCreationRemoteMethodTest() {
		if(!runalltests){ return; }

		Blob s = Blob.valueof('Skyline:,Sky01-A \n Panel Tilt:,90 \n Panel Azimuth:,122 \n Annual:,100 \n Skyline:,Sky01-A  \n  Monthly totals:,,90,90,90,90,90,90,90,90,90,90,90,90');

		
		List<Install_Location__c> loc = SurveyCreationPageExtension.receiveZipFileEntry('DailySolarAccess', 'DailySolarAccess', EncodingUtil.base64Encode(s), null);	
	}
	
}