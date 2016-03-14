@isTest
public class D2DTestUtility {

	public static void InitializeRequiredMethods(){
		CreateDocuments();
		CreatePricebookEntry();
	}

	private static Integer userCount = 0;

	/*
	 * OBJECTS
	 */
	public static Map<String, Profile> profilesMap {
		get {
			if(profilesMap == null){
				CreateProfilesMap();
			}
			return profilesMap;
		}
		set;
	}
	public static Map<String, UserRole> userRolesMap {
		get {
			if(userRolesMap == null){
				CreateUserRolesMap();
			}
			return userRolesMap;
		}
		set;
	}
	public static Map<String, Group> queues {
		get {
			if(queues == null){
				CreateQueues();
			}
			return queues;
		}
		set;
	}

	private static PricebookEntry pricebookEntry {
		get {
			if(pricebookEntry == null){
				CreatePricebookEntry();
			}
			return pricebookEntry;
		}
		set;
	}

	public static List<Document> documents {
		get {
			if(documents == null){
				CreateDocuments();
			}
			return documents;
		}
		set;
	}

	public static D2DSettings__c d2dSettings {get;set;}
	public static Main_Office_Location_Settings__c officeLocationSettings {get;set;}

	private static Account portalUserAccount {
		get {
			if(portalUserAccount == null){
				CreatePortalUserAccount();
			}
			return portalUserAccount;
		}
		set;
	}
	public static User salesCoordinatorUser {
		get {
			if(salesCoordinatorUser == null){
				CreateSalesCoordinatorUser();
			}
			return salesCoordinatorUser;
		}
		set;
	}
	public static List<User> d2dAdminUsers {
		get {
			if(d2dAdminUsers == null){
				d2dAdminUsers = new List<User>();
			}
			return d2dAdminUsers;
		}
		set;
	}
	public static List<User> d2dManagerUsers {
		get {
			if(d2dManagerUsers == null){
				d2dManagerUsers = new List<User>();
			}
			return d2dManagerUsers;
		}
		set;
	}
	public static List<User> d2dSalesRepUsers {
		get {
			if(d2dSalesRepUsers == null){
				d2dSalesRepUsers = new List<User>();
			}
			return d2dSalesRepUsers;
		}
		set;
	}
	public static List<System_Designers_Assignment__c> systemDesignersAssignments {
		get {
			if(systemDesignersAssignments == null){
				systemDesignersAssignments = new List<System_Designers_Assignment__c>();
			}
			return systemDesignersAssignments;
		}
		set;
	}
	private static Map<String, User> allUsersAliasMap {
		get {
			if(allUsersAliasMap == null){
				allUsersAliasMap = new Map<String, User>();
			}
			return allUsersAliasMap;
		}
		set;
	}

	public static List<Campaign> primarySourceCampaigns {
		get {
			if(primarySourceCampaigns == null){
				primarySourceCampaigns = new List<Campaign>();
			}
			return primarySourceCampaigns;
		}
		set;
	}
	public static List<Office_Location__c> officeLocations {
		get {
			if(officeLocations == null){
				officeLocations = new List<Office_Location__c>();
			}
			return officeLocations;
		}
		set;
	}
	public static List<Utility_Company_Master__c> utilityCompanyMasters {
		get {
			if(utilityCompanyMasters == null){
				utilityCompanyMasters = new List<Utility_Company_Master__c>();
			}
			return utilityCompanyMasters;
		}
		set;
	}
	public static List<D2D_Proposal__c> d2dProposals {
		get {
			if(d2dProposals == null){
				d2dProposals = new List<D2D_Proposal__c>();
			}
			return d2dProposals;
		}
		set;
	}
	public static List<Event> siteSurveyEvents {
		get {
			if(siteSurveyEvents == null){
				siteSurveyEvents = new List<Event>();
			}
			return siteSurveyEvents;
		}
		set;
	}


	/*
	 * Profiles And UserRoles
	 */
	private static void CreateProfilesMap(){
		List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name IN ('D2D Admin', 'D2D Manager', 'D2D Sales Rep', 'Sales Coordinator', 'System Design Manager')];
		profilesMap = new Map<String, Profile>();
		for(Profile p : profiles){
			profilesMap.put(p.Name, p);
		}
	}

	private static void CreateUserRolesMap(){
		List<UserRole> userRoles = [SELECT Id, Name, DeveloperName FROM UserRole WHERE DeveloperName IN ('NYW_NYTS_LI_System_Design_Manager', 'Sales_Coordinator')];
		userRolesMap = new Map<String, UserRole>();
		for(UserRole ur : userRoles){
			userRolesMap.put(ur.DeveloperName, ur);
		}
	}

	private static void CreateQueues(){
		List<Group> groups = [SELECT Id, Name, DeveloperName FROM Group WHERE DeveloperName IN ('InsideSalesQueue', 'WebLeadQueue')];
		queues = new Map<String, Group>();
		for(Group grp : groups){
			queues.put(grp.DeveloperName, grp);
		}
	}

	/*
	 * PricebookEntry
	 */
	private static void CreatePricebookEntry(){
        Product2 p = new Product2(
	        Name='testProduct223',
	        ProductCode = 'system'
    	);
        insert p;

        Id pbookId = Test.getStandardPricebookId();
              
        pricebookEntry = new PricebookEntry(
	        UnitPrice = 2.32,
	        Pricebook2Id = pbookId,
	        UseStandardPrice = false,
	        Product2ID = p.Id,
	        IsActive  = true
    	);
        insert pricebookEntry;
	}


	/*
	 * Documents
	 */
	private static void CreateDocuments(){
		documents = new List<Document>();
		documents.add(new Document(Name='DESLogo', FolderId=UserInfo.getUserId()));
		insert documents;
	}


	/*
	 * Custom Settings
	 */
	public static void CreateCustomSettings(String sc){
		CreateCustomSettings(false, false, '', '', '', '', '', '', '', '', sc);
	}

	public static void CreateCustomSettings(Boolean alc, String sc){
		CreateCustomSettings(alc, false, '', '', '', '', '', '', '', '', sc);
	}

	public static void CreateCustomSettings(Boolean alc, Boolean car, String ccu, String d2dsu, String dsaid, String dsh, String dsik, String dsp, String dssu, String dsuid, String sc){
		d2dSettings = new D2DSettings__c(
			Allow_Lead_Creation__c = alc,
			Credit_Approval_Required__c = car,
			Credit_Check_Url__c = ccu,
			D2D_Site_Url__c = d2dsu,
			DocuSign_Account_Id__c = dsaid,
			DocuSign_Host__c = dsh,
			DocuSign_Integrators_Key__c = dsik,
			DocuSign_Password__c = dsp,
			DocuSign_Service_Url__c = dssu,
			DocuSign_User_Id__c = dsuid,
			Sales_Coordinator__c = sc //'tester@email.com'
		);
		insert d2dSettings;

		officeLocationSettings = new Main_Office_Location_Settings__c(
			Name__c = 'Columbia, MD',
			Street__c = '7101 Riverwood Drive',
			City__c = 'Columbia',
			State__c = 'MD',
			Zip__c = '21046'
		);
		insert officeLocationSettings;

		ContractSettings__c contractSettings = ContractSettings__c.getOrgDefaults();
		if(contractSettings.Maximum_Commission_Rate__c != 3.5){
	   		contractSettings.Minimum_Commission_Rate__c = 0.5;
			contractSettings.Maximum_Commission_Rate__c = 3.5;
			contractSettings.Minimum_Promotion__c = 0.0;
			contractSettings.Maximum_Promotion__c = 0.5;
			upsert contractSettings;
		}
	}


	/*
	 * Users w/ Support Objects
	 */

	private static String getUsernamePreface(){
		return Datetime.now().getTime() + '.';
	}

	private static void InsertUser(User u){
		InsertUsers(new List<User> { u });
	}

	private static void InsertUsers(List<User> users){
		Integer i = 1;
		for(User u : users){
			u.Username = getUsernamePreface() + u.Username;
			if(allUsersAliasMap.containsKey(u.Alias)){
				u.Alias += '-' + i;
				i++;
			}
		}
		System.runAs(new User(Id = UserInfo.getUserId())){
			insert users;
		}

		for(User u : users){
			allUsersAliasMap.put(u.Alias, u);
		}
	}

	public static void CreateSalesCoordinatorUser(){
		UserRole role = userRolesMap.get('Sales_Coordinator_xyz');
		Profile prof = profilesMap.get('Sales Coordinator');

		salesCoordinatorUser = new User(
			Email = d2dSettings.Sales_Coordinator__c,
			UserName = d2dSettings.Sales_Coordinator__c,
			LastName = 'D2D',
			Alias = 'd2d.sc',
			CommunityNickName = 'Sales Coordinator Test',
			TimeZoneSidKey = 'America/New_York',
			LocaleSidKey = 'en_US',
			LanguageLocaleKey = 'en_US',
			EmailEncodingKey = 'UTF-8',
			ProfileId = prof.Id/*,
			UserRoleId = role.Id*/
		);
		InsertUser(salesCoordinatorUser);
	}

	private static void CreatePortalUserAccount(){
        User accountOwner = 
            [SELECT Id FROM User 
            WHERE UserRoleId <> NULL
            AND Profile.UserType = 'Standard' 
            AND IsActive = TRUE 
            LIMIT 1];

        portalUserAccount = new Account (
            OwnerId = accountOwner.Id,
            Name = 'Test Employee',
            Related_User__c = accountOwner.Id
        );
        insert portalUserAccount;
	}

	private static List<User> CreatePortalUsers(Integer numberToCreate, String profileName, String email, String username, String lastName, String alias, String communityNickName, String company){
		return CreatePortalUsers(numberToCreate, profileName, email, username, lastName, alias, communityNickName, company, null);
	}

	private static List<User> CreatePortalUsers(Integer numberToCreate, String profileName, String email, String username, String lastName, String alias, String communityNickName, String company, User managerUser){
		List<User> createdUsers = new List<User>();
		for(Integer i = 0; i < numberToCreate; i++){
			Contact c = new Contact(
				LastName = lastName + '_' + i,
				AccountId = portalUserAccount.Id,
				Email = email
			);
			insert c;

			Profile profile = profilesMap.get(profileName);
			User u = new User(
				Email = email + '.' + userCount,
				UserName = username + '.' + userCount,
				LastName = lastName + '_' + userCount,
				Alias = alias + userCount,
				CommunityNickName = communityNickName + userCount,
				CompanyName = company,
				TimeZoneSidKey = 'America/New_York',
				LocaleSidKey = 'en_US',
				LanguageLocaleKey = 'en_US',
				EmailEncodingKey = 'UTF-8',
				ProfileId = profile.Id,
				ContactId = c.Id
			);
			userCount++;

			if(managerUser != null){
				u.D2D_Manager__c = managerUser.Id;
			}
			createdUsers.add(u);
		}
		InsertUsers(createdUsers);
		return createdUsers;
	}

	public static void CreateAdminUsers(Integer numberToCreate){
		CreateAdminUsers(numberToCreate, 'Test Company');
	}

	public static void CreateAdminUsers(Integer numberToCreate, String company){
		d2dAdminUsers.addAll(CreatePortalUsers(numberToCreate, 'D2D Admin', 'admin@email.com', 'admin@email.com', 'D2DADM', 'd2d.ad', 'Admin Test', company));
	}

	public static void CreateManagerUsers(Integer numberToCreate){
		CreateManagerUsers(numberToCreate, 'Test Company');
	}

	public static void CreateManagerUsers(Integer numberToCreate, String company){
		d2dManagerUsers.addAll(CreatePortalUsers(numberToCreate, 'D2D Manager', 'manager@email.com', 'manager@email.com', 'D2DMG', 'd2d.mg', 'Manager Test', company));
	}

	public static void CreateSalesRepUsers(Integer numberToCreate){
		CreateSalesRepUsers(numberToCreate, 'Test Company');
	}

	public static void CreateSalesRepUsers(Integer numberToCreate, String company){
		User mgr = null;
		Boolean foundMgr = false;
		while(!foundMgr){
			mgr = d2dManagerUsers[GetRandomIndex(d2dManagerUsers.size())];
			if(mgr.CompanyName == company){
				foundMgr = true;
			}
		}
		if(foundMgr){
			d2dSalesRepUsers.addAll(CreatePortalUsers(numberToCreate, 'D2D Sales Rep', 'salesrep@email.com', 'salesrep@email.com', 'D2DSR', 'd2d.sr', 'SalesRep Test', company, mgr));
		} else {
			throw new D2D_Utility.D2DException('Could not find a manager in the same company.');
		}
	}


	/*
	 * Leads and Portal Referrals w/ Support Objects
	 */

	// 
	// Primary Source Campaigns
	public static void CreatePrimarySourceCampaigns(Integer numberToCreate){
		List<Campaign> toInsert = new List<Campaign>();
		for(Integer i = 0; i < numberToCreate; i++){
			Campaign c = new Campaign(
				Type = 'Canvassing',
				Event_Type_Detail__c = 'Not Sure – Was Just In the Area',
				IsActive = true,
				City__c = 'Stony Point',
				State__c = 'NY',
				StartDate = Date.today(),
				EndDate = Date.today().addDays(30),
				Customer_Host_NA__c = true,
				Canvass_Area_Name__c = 'D2D Stony Point',
				Canvass_Zip_Codes__c = '10980',
				Sales_Region_s__c = 'WNY Region',
				Estimated_Event_Fees_Expenses__c = '1000'
			);
			toInsert.add(c);
		}
		insert toInsert;
		primarySourceCampaigns.addAll(toInsert);
	}

	//
	// Office Locations
	private static void CreateOfficeLocations(Integer numberToCreate, String stateServiced){
		List<Office_Location__c> toInsert = new List<Office_Location__c>();
		for(Integer i = 0; i < numberToCreate; i++){
			Office_Location__c ol = new Office_Location__c(
				Active__c = true,
				Name = 'Columbia, MD',
				Street__c = '7101 Riverwood Drive',
				City__c = 'Columbia',
				State__c = 'MD',
				Zip_Code__c = '21046',
				Main_Site__c = true,
				State_Coverage__c = stateServiced
			);
			toInsert.add(ol);
		}
		insert toInsert;
		officeLocations.addAll(toInsert);
	}

	//
	// Utility Company Masters
	private static void CreateUtilityCompanyMasters(Integer numberToCreate, String stateServiced){
        List<Utility_Company_Master__c> toInsert = new List<Utility_Company_Master__c>();
        for(Integer i = 0; i < numberToCreate; i++){
        	Utility_Company_Master__c ucm = new Utility_Company_Master__c(
		        Name = 'BG&E',
		        Solar_Compensation_Method__c = 'Net Metering',
		        State_Serviced__c = stateServiced,
		        Externally_Available__c = true
	        );
	        toInsert.add(ucm);
        }
        insert toInsert;
        utilityCompanyMasters.addAll(toInsert);
	}

	public static void CreateD2DProposals(Integer numberToCreate){
		CreateD2DProposals(numberToCreate, '24');
	}

	public static void CreateD2DProposals(Integer numberToCreate, String systemSize){
		Decimal numberOfPanels = Decimal.valueOf(systemSize.replace(' Panel', ''));

		List<D2D_Proposal__c> toInsert = new List<D2D_Proposal__c>();
		for(Integer i = 0; i < numberOfPanels; i++){
			D2D_Proposal__c p = new D2D_Proposal__c(
				Utility_Company_Master__c = utilityCompanyMasters[GetRandomIndex(utilityCompanyMasters.size())].Id,
				Number_of_Panels__c = numberOfPanels,
				State__c = 'NY',
				Site_Quality__c = 1050
			);
			toInsert.add(p);
		}
		insert toInsert;
		d2dProposals.addAll(toInsert);
	}

	//
	// System Designers Assignment
	public static void CreateSystemDesignersAssignments(Integer numberToCreate){
		List<User> usersToInsert = new List<User>();
		UserRole role = userRolesMap.get('NYW_NYTS_LI_System_Design_Manager');
		Profile prof = profilesMap.get('System Design Manager');
		for(Integer i = 0; i < numberToCreate; i++){
			User u = new User(
				Email = 'testing@email.com.' + i,
				UserName = 'testing@email.com.' + i,
				LastName = 'D2D_' + i,
				Alias = 'd2d.sd' + i,
				CommunityNickName = 'System Designers Assignment Test',
				TimeZoneSidKey = 'America/New_York',
				LocaleSidKey = 'en_US',
				LanguageLocaleKey = 'en_US',
				EmailEncodingKey = 'UTF-8',
				ProfileId = prof.Id/*,
				UserRoleId = role.Id*/
			);
			usersToInsert.add(u);
		}
		InsertUsers(usersToInsert);

		List<System_Designers_Assignment__c> toInsert = new List<System_Designers_Assignment__c>();
		for(Integer i = 0; i < numberToCreate; i++){
			System_Designers_Assignment__c sda = new System_Designers_Assignment__c(
				User__c = usersToInsert[i].Id,
				Last_Assignment_Datetime__c = Datetime.now()
			);
			toInsert.add(sda);
		}
		insert toInsert;
		systemDesignersAssignments.addAll(toInsert);
	}

	public static void CreatePortalReferralRequiredObjects(Integer numberToCreate, String state, String systemSize){
		CreatePrimarySourceCampaigns(numberToCreate);
		CreateUtilityCompanyMasters(numberToCreate, state);
		CreateSystemDesignersAssignments(numberToCreate);
		CreateOfficeLocations(numberToCreate, state);
		if(systemSize == ''){
			CreateD2DProposals(numberToCreate);
		} else {
			CreateD2DProposals(numberToCreate, systemSize);
		}
	}

	public static void CreatePortalReferralsWithLeads(Integer numberToCreate, Id d2dManagerUserId, Id d2dSalesRepUserId, String leadStatus, String d2dStatus, String systemSize, String segment,
		String lastName, String firstName, String street, String city, String state, String zip, String county, Boolean populateScheduledVisitDatetime){

		Map<Integer, lead> leads = new Map<Integer, Lead>();
		Map<Integer, Portal_Referral__c> referrals = new Map<Integer, Portal_Referral__c>();
		Group webLeadQueue = queues.get('WebLeadQueue');
		for(Integer i = 0; i < numberToCreate; i++){
			Lead lead = new Lead(
				OwnerId = webLeadQueue.Id, LastName = lastName + String.valueOf(i), FirstName = firstName, Company = lastName + String.valueOf(i) + ', ' + firstName, 
				Street = street + ', Suite ' + String.valueOf(i), City = city, State = state, D2D_State__c = state, PostalCode = zip, County__c = county,
				Site_Type__c = 'Residential', Status = 'Prospect New', LeadSource = 'Canvassing', Lead_Source_Detail__c = 'Canvassing', Method_of_Contact__c = '', Lead_Date__c = Date.today(),
				Affiliate_Community_Program__c = 'D2D Long Island', Primary_Source_Campaign__c = primarySourceCampaigns[GetRandomIndex(primarySourceCampaigns.size())].Id
			);
			leads.put(i, lead);
			Portal_Referral__c referral = new Portal_Referral__c(
				Segment_Priority__c = segment, Status__c = leadStatus, D2D_Lead_Status__c = d2dStatus, Last_Name__c = lastName + String.valueOf(i), First_Name__c = firstName,
				Street__c = street + ', Suite ' + String.valueOf(i), City__c = city, State__c = state, Zip__c = zip, Lead_Created_Date__c = Date.today(),
				D2D_System_Size__c = systemSize
			);
			if(d2dManagerUserId != null){
				referral.D2D_Manager__c = d2dManagerUserId;
			}
			if(d2dSalesRepUserId != null){
				referral.D2D_Sales_Rep__c = d2dSalesRepUserId;
			}
			if(populateScheduledVisitDatetime){
				referral.D2D_Scheduled_Visit_Datetime__c = Datetime.now().addDays(1);
			}
			referrals.put(i, referral);
		}
		insert leads.values();
		for(Integer idx : referrals.keySet()){
			referrals.get(idx).Lead__c = leads.get(idx).Id;
		}
		insert referrals.values();
	}

	public static void CreatePortalReferralsWithConvertedLeads(Integer numberToCreate, Id d2dManagerUserId, Id d2dSalesRepUserId, String leadStatus, String d2dStatus, String systemSize, String segment,
		String lastName, String firstName, String street, String city, String state, String zip, String county, Boolean populateScheduledVisitDatetime){

		Map<Integer, lead> leads = new Map<Integer, Lead>();
		Map<Integer, Portal_Referral__c> referrals = new Map<Integer, Portal_Referral__c>();
		Group webLeadQueue = queues.get('WebLeadQueue');
		for(Integer i = 0; i < numberToCreate; i++){
			Lead lead = new Lead(
				OwnerId = webLeadQueue.Id, LastName = lastName + String.valueOf(i), FirstName = firstName, Company = lastName + String.valueOf(i) + ', ' + firstName, 
				Street = street + ', Suite ' + String.valueOf(i), City = city, State = state, D2D_State__c = state, PostalCode = zip, County__c = county,
				Site_Type__c = 'Residential', Status = 'Prospect New', LeadSource = 'Canvassing', Lead_Source_Detail__c = 'Canvassing', Method_of_Contact__c = '', Lead_Date__c = Date.today(),
				Affiliate_Community_Program__c = 'D2D Long Island', Primary_Source_Campaign__c = primarySourceCampaigns[GetRandomIndex(primarySourceCampaigns.size())].Id, 
				Utility_Company_Master__c = utilityCompanyMasters[GetRandomIndex(utilityCompanyMasters.size())].Id, Prospect_Lead__c = true
			);
			leads.put(i, lead);
			Portal_Referral__c referral = new Portal_Referral__c(
				Segment_Priority__c = segment, Status__c = leadStatus, D2D_Lead_Status__c = d2dStatus, Last_Name__c = lastName + String.valueOf(i), First_Name__c = firstName,
				Street__c = street + ', Suite ' + String.valueOf(i), City__c = city, State__c = state, Zip__c = zip, Lead_Created_Date__c = Date.today(),
				D2D_System_Size__c = systemSize, D2D_Manager__c = d2dManagerUserId, D2D_Sales_Rep__c = d2dSalesRepUserId
			);
			if(populateScheduledVisitDatetime){
				referral.D2D_Scheduled_Visit_Datetime__c = Datetime.now().addDays(1);
			}
			referrals.put(i, referral);
		}
		insert leads.values();
		for(Integer idx : referrals.keySet()){
			referrals.get(idx).Lead__c = leads.get(idx).Id;
		}
		insert referrals.values();

		// Update leads status
		UpdateLeadsStatusToOpenNew(leads.values());

		// Convert leads
		ConvertLeads(leads.values(), systemDesignersAssignments[GetRandomIndex(systemDesignersAssignments.size())].User__c);
	}

	public static void CreateOpportunityWithProposalAndContract(Boolean includeProposal, Boolean includeProposalPdf, Boolean includeContract, Boolean includeContractPdf){
		Opportunity opp = Milestone1_Test_Utility.CreateTestOpp();

		List<Portal_Referral__c> referrals = [SELECT Id, State__c FROM Portal_Referral__c WHERE Opportunity__c = null LIMIT 1];
		if(referrals.size() > 0){
			referrals[0].Opportunity__c = opp.Id;
			update referrals;
		} else {
			throw new D2D_Utility.D2DException('No referral found to join to opp in D2DTestUtility.CreateOpportunityWithProposalAndContract().');
		}

		if(includeContract || includeProposal){
	    	Proposal__c proposal = new Proposal__c(System_Design_Quote__c = opp.System_Design_Quote__c, Current__c = true);
	    	insert proposal;

	    	if(includeProposalPdf){
	    		CreateProposalAttachment(proposal.Id);
	    	}

	    	if(includeContract){
		    	Astrum_Contract__c contract = new Astrum_Contract__c(Proposal__c = proposal.Id, Scenario__c = '1', Closed__c = false, Property_State__c = referrals[0].State__c);
		    	insert contract;

		    	if(includeContractPdf){
		    		CreateContractAttachment(contract.Id);
		    	}
	    	}
    	}
	}

	public static void CreateProposalAttachment(Id proposalId){
	    Attachment att = new Attachment(
	        Name = 'Proposal.pdf',
	        Body = Blob.valueOf('Sample Proposal Attachment.'),
	        ContentType = 'application/pdf',
	        ParentId = proposalId
		);
	    insert att;
	}

	public static void CreateContractAttachment(Id contractId){
	    Attachment att = new Attachment(
	        Name = 'Contract.pdf',
	        Body = Blob.valueOf('Sample Contract Attachment.  It contains some stuff to work with DocuSign.  Please Sign Here.  There are two pieces to that though.  Date Here.  That should be good enough.'),
	        ContentType = 'application/pdf',
	        ParentId = contractId
		);
	    insert att;
	}

	public static Attachment GetContractAttachmentForSigning(Id contractPdfId){
		return [SELECT Id, Body FROM Attachment WHERE Id = :contractPdfId LIMIT 1];
	}

	public static void CreateSalesOrderAttachment(Id salesorderId){
	    Attachment att = new Attachment(
	        Name = 'Signed Contract.pdf',
	        Body = Blob.valueOf('Sample Signed Contract Attachment'),
	        ContentType = 'application/pdf',
	        ParentId = salesorderId
		);
	    insert att;
	}

	public static void CreateSiteSurveyEvent(Integer numberToCreate, Opportunity opportunity, Property__c property, D2D_Proposal__c d2dProposal, String host){
		Id recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Event' AND DeveloperName = 'Site_Survey_Remote' LIMIT 1].Id;

		List<Event> toInsert = new List<Event>();
		for(Integer i = 0; i < numberToCreate; i++){
	        Event surveyEvent = new Event(
		        RecordTypeId = recordTypeId,
		        OwnerId = systemDesignersAssignments[GetRandomIndex(systemDesignersAssignments.size())].User__c,
		        WhatId = opportunity.Id,
		        Subject = 'Schedule Site Survey',
		        StartDateTime = Datetime.now(),
		        EndDateTime = Datetime.now().addDays(1),
		        Description = 'This is a D2D Survey Request - Utility Company: ' + d2dProposal.Utility_Company_Master__r.Name + '; Number of Panels: ' + d2dProposal.Number_of_Panels__c,
		        Related_Property_Link__c = host + property.Id,
		        Related_Property_Name__c = property.Name,
		        Site_Survey_Type__c = 'Site Survey Remote',
		        D2D_Survey_Request__c = true
	        );
	        toInsert.add(surveyEvent);
		}
        insert toInsert;
        siteSurveyEvents.addAll(toInsert);
	}

	public static DocuSignAPI_30.DocumentPDFs MockDocuSignPdfs(){
        DocuSignAPI_30.DocumentPDF docPdf = new DocuSignAPI_30.DocumentPDF();
        docPdf.Name = 'MockName';
        docPdf.PDFBytes = EncodingUtil.base64Encode(Blob.valueOf('Sample Signed Contract Attachment'));
        docPdf.DocumentID = 1;
        docPdf.DocumentType = 'PDF';

        DocuSignAPI_30.DocumentPDFs docPdfs = new DocuSignAPI_30.DocumentPDFs();
        docPdfs.DocumentPDF = new DocuSignAPI_30.DocumentPDF[] { docPdf };
        return docPdfs;
	}


	/*
	 * Support Functions
	 */

	public static String GenerateGuid(){
		Blob b = Crypto.GenerateAESKey(128);
		String h = EncodingUtil.ConvertTohex(b);
		return h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
	}

	private static void UpdateLeadsStatusToOpenNew(List<Lead> leadsToUpdate){
	    String leadStatus = '';
	    List<SelectOption> leadStatuses = D2D_Utility.GetPicklistOptions(Lead.Status.getDescribe(), false);
	    for(SelectOption so : leadStatuses){
	        if(so.getValue().contains('Open') && so.getValue().contains('New')){
	            leadStatus = so.getValue();
	        }
	    }
	    for(Lead lead : leadsToUpdate){
	    	lead.Status = leadStatus;
	    }
	    update leadsToUpdate;
	}

	private static void ConvertLeads(List<Lead> leadsToConvert, Id sdaUserId){
		for(Lead lead : leadsToConvert){
	        Database.LeadConvert lc = new Database.LeadConvert();
	        lc.setLeadId(lead.Id);
	        lc.setConvertedStatus('Qualified');
	        lc.setOwnerId(sdaUserId);
	        Database.LeadConvertResult lcr = Database.convertLead(lc);

	        if(lcr.isSuccess()){
	            // do success stuff
	            // link the property to the opportunity
	            Property__c property = [SELECT Id, Name FROM Property__c WHERE Property_Owner__c = :lcr.getAccountId()];
	            system.debug('**SZ: property = ' + property.Id);
	            
	            Opportunity opp = [SELECT Id, Property__c, Approved_System_Design__c, OwnerId FROM Opportunity WHERE Id = :lcr.getOpportunityId()];
	            opp.OwnerId = sdaUserId;
	            opp.Property__c = property.Id;
	            update opp;
	            system.debug('**SZ: opp.property = ' + opp.Property__c);

	            Account acct = [SELECT Id, OwnerId FROM Account WHERE Id = :lcr.getAccountId()];
	            acct.OwnerId = sdaUserId;
	            update acct;
	        }
		}
	}

	private static Integer GetRandomIndex(Integer size){
		return Integer.valueOf(Math.floor(Math.random() * size));
	}
}