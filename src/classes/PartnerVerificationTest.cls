/* FILE: PartnerVerificationTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: September 11, 2012
 * PURPOSE: Test class for PartnerVerification page and PartnerVerificationExtension
 * MODIFICATION HISTORY
 *
 */

@isTest
private class PartnerVerificationTest {

	static testMethod void submittedApp_Approve_UserAccountContactCreated() {
		
		Portal_Payment_Plan__c plan = new Portal_Payment_Plan__c (
		);
		insert plan;

		User usr = [Select u.Username, u.UserRoleId, u.Email From User u Where  u.UserRoleId != null And isActive = true and Profile.Name like 'Sales%' limit 1];

		
		PartnerPortalSettings__c mc = new PartnerPortalSettings__c();
		mc.Name = 'Portal Contact';
		mc.Portal_Contact__c = usr.Username;
		insert mc;

		Partner_Application__c app = new Partner_Application__c();
    	app.First_Name__c = 'Test';
    	app.Last_Name__c = 'Partner';
    	app.Title__c = 'Contractor';
    	app.Email__c = 'test.partnerxyz123@partner.com';
    	app.Phone__c = '(215) 555-1898';
    	app.Fax__c = '(800) 555-1212';
    	app.Company_Name__c = 'Zyx 321 Construction Company';
    	app.Website__c = 'http://www.partner.com';
    	app.Address__c = '99 Blackwater Rd';
    	app.City__c = 'Malvern';
    	app.State__c = 'PA';
    	app.Zip_Code__c = '19403';
    	insert app;
    	
    	ApexPages.Standardcontroller controller = new ApexPages.StandardController(app);
    	PartnerVerificationExtension extension = new PartnerVerificationExtension(controller);
	    
	    Test.startTest();
	    
	    List<SelectOption> plans = extension.getPaymentPlans();
	    	
	    extension.paymentPlanAccount.Portal_Payment_Plan__c = plans[1].getValue();
	    PageReference pr = extension.approve();
	    
	   	Test.stopTest();
	    
	   	System.assertEquals(false, ApexPages.hasMessages());
	   	
	   	System.assertEquals(2, plans.size());
	   	
		//check account info	   
		Account a = [SELECT Name, BillingStreet, BillingCity, BillingState,	BillingPostalCode, Website, Portal_Payment_Plan__c FROM Account];
	    System.assertEquals(app.Address__c, a.BillingStreet);
	    System.assertEquals(app.City__c, a.BillingCity);
	    System.assertEquals(app.State__c, a.BillingState);
	    System.assertEquals(app.Zip_Code__c, a.BillingPostalCode);
	    System.assertEquals(app.Website__c, a.Website);
	    System.assertEquals(plan.Id, a.Portal_Payment_Plan__c);
	    
	    //check contact info
	    Contact c = [SELECT AccountId, FirstName, LastName, Title, Email, Phone, Fax FROM Contact];
	    System.assertEquals(a.Id, c.AccountId);
	    System.assertEquals(app.First_Name__c, c.FirstName);
	    System.assertEquals(app.Last_Name__c, c.LastName);
	    System.assertEquals(app.Title__c, c.Title);
	    System.assertEquals(app.Email__c, c.Email);
	    System.assertEquals(app.Phone__c, c.Phone);
	    System.assertEquals(app.Fax__c, c.Fax);
	    
	    System.assertEquals('/' + c.Id, pr.getUrl());
	   
	   	//check user info	
	    User u = [SELECT FirstName, LastName, Email, UserName, Profile.Name FROM User WHERE ContactId = :c.Id];
	    System.assertEquals(app.First_Name__c, u.FirstName);
	    System.assertEquals(app.Last_Name__c, u.LastName);
	    System.assertEquals(app.Email__c, u.Email);
	    System.assertEquals(app.Email__c, u.UserName);
	    System.assertEquals('Partner Portal - Full User', u.Profile.Name);

		app = [SELECT Status__c FROM Partner_Application__c WHERE Id = :app.Id];
		System.assertEquals('Approved', app.Status__c);
			    
	}
	
	static testMethod void submittedApp_Decline_StatusChanged() {

		Partner_Application__c app = new Partner_Application__c();
    	app.First_Name__c = 'Test';
    	app.Last_Name__c = 'Partner';
    	app.Title__c = 'Contractor';
    	app.Email__c = 'test.partnerxyz123@partner.com';
    	app.Phone__c = '(215) 555-1898';
    	app.Fax__c = '(800) 555-1212';
    	app.Company_Name__c = 'Zyx 321 Construction Company';
    	app.Website__c = 'http://www.partner.com';
    	app.Address__c = '99 Blackwater Rd';
    	app.City__c = 'Malvern';
    	app.State__c = 'PA';
    	app.Zip_Code__c = '19403';
    	insert app;
    	
    	ApexPages.Standardcontroller controller = new ApexPages.StandardController(app);
    	PartnerVerificationExtension extension = new PartnerVerificationExtension(controller);
	    
	    Test.startTest();
	    	
	    PageReference pr = extension.decline();
	    
	   	Test.stopTest();

	    System.assertEquals('/' + app.Id, pr.getUrl());

		app = [SELECT Status__c FROM Partner_Application__c WHERE Id = :app.Id];
		System.assertEquals('Declined', app.Status__c);
		
	}

	static testMethod void submittedApp_Duplicate_StatusAndLinkToContact() {

		Partner_Application__c app = new Partner_Application__c();
    	app.First_Name__c = 'Test';
    	app.Last_Name__c = 'Partner';
    	app.Title__c = 'Contractor';
    	app.Email__c = 'test.partnerxyz123@partner.com';
    	app.Phone__c = '(215) 555-1898';
    	app.Fax__c = '(800) 555-1212';
    	app.Company_Name__c = 'Zyx 321 Construction Company';
    	app.Website__c = 'http://www.partner.com';
    	app.Address__c = '99 Blackwater Rd';
    	app.City__c = 'Malvern';
    	app.State__c = 'PA';
    	app.Zip_Code__c = '19403';
    	insert app;
    	
    	Account a = new Account ( Name = app.Company_Name__c );
    	insert a;
    	Contact c = new Contact ( 
    		AccountId = a.Id,
    		FirstName = app.First_Name__c,
    		LastName = app.Last_Name__c 
    	);
    	insert c;
    	
    	ApexPages.Standardcontroller controller = new ApexPages.StandardController(app);
    	PartnerVerificationExtension extension = new PartnerVerificationExtension(controller);

	    System.assertEquals(a.Id, extension.accounts[0].Id);
	    System.assertEquals(c.Id, extension.contacts[0].Id);
	    
	    Test.startTest();
	    
	    extension.duplicateId = c.Id;	
	    PageReference pr = extension.duplicate();
	    
	   	Test.stopTest();

	    System.assertEquals('/' + app.Id, pr.getUrl());

		app = [SELECT Status__c, Contact__c FROM Partner_Application__c WHERE Id = :app.Id];
		System.assertEquals('Duplicate', app.Status__c);
		System.assertEquals(c.Id, app.Contact__c);
		
	}

	static testMethod void submittedApp_ApproveDiffAccount_CreatedWithExistingAccount() {
		
		Portal_Payment_Plan__c plan = new Portal_Payment_Plan__c (
		);
		insert plan;

		User usr = [Select u.Username, u.UserRoleId, u.Email From User u Where  u.UserRoleId != null And isActive = true and Profile.Name like 'Sales%' limit 1];

		
		PartnerPortalSettings__c mc = new PartnerPortalSettings__c();
		mc.Name = 'Portal Contact';
		mc.Portal_Contact__c = usr.Username;
		insert mc;

		Partner_Application__c app = new Partner_Application__c();
    	app.First_Name__c = 'Test';
    	app.Last_Name__c = 'Partner';
    	app.Title__c = 'Contractor';
    	app.Email__c = 'test.partnerxyz123@partner.com';
    	app.Phone__c = '(215) 555-1898';
    	app.Fax__c = '(800) 555-1212';
    	app.Company_Name__c = 'Zyx 321 Construction Company';
    	app.Website__c = 'http://www.partner.com';
    	app.Address__c = '99 Blackwater Rd';
    	app.City__c = 'Malvern';
    	app.State__c = 'PA';
    	app.Zip_Code__c = '19403';
    	insert app;
    	
    	Account a = new Account ( Name = 'Another Company' );
    	insert a;
    	
    	ApexPages.Standardcontroller controller = new ApexPages.StandardController(app);
    	PartnerVerificationExtension extension = new PartnerVerificationExtension(controller);

	    Test.startTest();
	    
	    extension.accountNameSearch = 'Another*';
	    System.assertEquals(null, extension.searchAccounts());
	    System.assertEquals(a.Id, extension.accounts[0].Id);
	    
	    extension.contactCompanyNameSearch = '*';
	    System.assertEquals(null, extension.searchContacts());
	    
		extension.selectedAccountId = a.Id;
	    System.assertEquals(null, extension.selectAccount());
	    
	    extension.paymentPlanAccount.Portal_Payment_Plan__c = plan.Id;
	    
	    PageReference pr = extension.approve();
	    
	   	Test.stopTest();
	   	
	   	System.assertEquals(false, ApexPages.hasMessages(), String.valueOf(ApexPages.getMessages()));

		//check account info - shouldn't be a new account	   
		Account a2 = [SELECT Name, Portal_Payment_Plan__c FROM Account];
	    System.assertEquals(a.Name, a2.Name);
	    System.assertEquals(plan.Id, a2.Portal_Payment_Plan__c);
	    
	    //check contact info
	    Contact c = [SELECT AccountId, FirstName, LastName, Title, Email, Phone, Fax FROM Contact];
	    System.assertEquals(a.Id, c.AccountId);
	    System.assertEquals(app.First_Name__c, c.FirstName);
	    System.assertEquals(app.Last_Name__c, c.LastName);
	    System.assertEquals(app.Title__c, c.Title);
	    System.assertEquals(app.Email__c, c.Email);
	    System.assertEquals(app.Phone__c, c.Phone);
	    System.assertEquals(app.Fax__c, c.Fax);
	    
	    System.assertEquals('/' + c.Id, pr.getUrl());
	   
	   	//check user info	
	    User u = [SELECT FirstName, LastName, Email, UserName, Profile.Name FROM User WHERE ContactId = :c.Id];
	    System.assertEquals(app.First_Name__c, u.FirstName);
	    System.assertEquals(app.Last_Name__c, u.LastName);
	    System.assertEquals(app.Email__c, u.Email);
	    System.assertEquals(app.Email__c, u.UserName);
	    System.assertEquals('Partner Portal - Full User', u.Profile.Name);

		app = [SELECT Status__c FROM Partner_Application__c WHERE Id = :app.Id];
		System.assertEquals('Approved', app.Status__c);
		
	}
	
	static testMethod void submittedApp_ForceError_ErrorMsg() {

		Partner_Application__c app = new Partner_Application__c();
    	app.First_Name__c = 'Test';
    	app.Last_Name__c = 'Partner';
    	app.Title__c = 'Contractor';
    	app.Email__c = 'test.partnerxyz123@partner.com';
    	app.Phone__c = '(215) 555-1898';
    	app.Fax__c = '(800) 555-1212';
    	app.Company_Name__c = 'Zyx 321 Construction Company';
    	app.Website__c = 'http://www.partner.com';
    	app.Address__c = '99 Blackwater Rd';
    	app.City__c = 'Malvern';
    	app.State__c = 'PA';
    	app.Zip_Code__c = '19403';
    	insert app;
    	
    	Account a = new Account ( Name = app.Company_Name__c );
    	insert a;
    	
    	ApexPages.Standardcontroller controller = new ApexPages.StandardController(app);
    	PartnerVerificationExtension extension = new PartnerVerificationExtension(controller);

		extension.selectedAccountId = a.Id;

		//force error
	    delete a;
	    
	    Test.startTest();
	    
	    PageReference pr = extension.approve();
	    
	   	Test.stopTest();

	    System.assertEquals(null, pr);

		System.assertEquals(true, ApexPages.hasMessages());
		
	}
	

}