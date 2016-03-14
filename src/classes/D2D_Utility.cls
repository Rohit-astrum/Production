global without sharing class D2D_Utility {

    public class D2DException extends Exception {} 

    public class ErrorMessage {
        public String Message {get;set;}
        public String ErrorFields {get;set;}

        public ErrorMessage(String msg, String fields) {
            this.Message = msg;
            this.ErrorFields = fields;
        }
    }

    public static final D2DSettings__c d2dSettings = D2DSettings__c.getOrgDefaults();
	
	// Build a local cache so that we don't request this multiple times
	private static Map<Schema.SObjectType,Map<String,Id>> rtypesCache;

	static {
	    rtypesCache = new Map<Schema.SObjectType,Map<String,Id>>();
	}
     
    // Returns a map of active, user-available RecordType IDs for a given SObjectType,
    // keyed by each RecordType's unique, unchanging DeveloperName 
    public static Map<String, Id> GetRecordTypeIdsByDeveloperName(Schema.SObjectType token){
        // Do we already have a result? 
        Map<String, Id> mapRecordTypes = rtypesCache.get(token);
        // If not, build a map of RecordTypeIds keyed by DeveloperName
        if (mapRecordTypes == null) {
            mapRecordTypes = new Map<String, Id>();
            rtypesCache.put(token,mapRecordTypes);
        } else {
           // If we do, return our cached result immediately!
           return mapRecordTypes;
        }

        // Get the Describe Result
        Schema.DescribeSObjectResult obj = token.getDescribe();

        // Obtain ALL Active Record Types for the given SObjectType token
        // (We will filter out the Record Types that are unavailable
        // to the Running User using Schema information)
        String soql = 'SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = \'' + String.escapeSingleQuotes(obj.getName()) + '\' AND IsActive = TRUE';
        List<SObject> results;
        try {
            results = Database.query(soql);
        } catch (Exception ex) {
            results = new List<SObject>();
        }

        // Obtain the RecordTypeInfos for this SObjectType token
        Map<Id,Schema.RecordTypeInfo> recordTypeInfos = obj.getRecordTypeInfosByID();

        // Loop through all of the Record Types we found,
        //      and weed out those that are unavailable to the Running User
        for (SObject rt : results) {  
            if (recordTypeInfos.get(rt.Id).isAvailable()) {
                // This RecordType IS available to the running user,
                //      so add it to our map of RecordTypeIds by DeveloperName
                mapRecordTypes.put(String.valueOf(rt.get('DeveloperName')),rt.Id);
            }
        }

        return mapRecordTypes;
    }

    public static String CurrentUserCompanyName = '';
    public static Boolean CurrentUserIsD2DAdmin = false;
    static {
        User user = [SELECT CompanyName, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        CurrentUserCompanyName = user.CompanyName;
        CurrentUserIsD2DAdmin = (user.Profile.Name == 'D2D Admin');
    }

	public static String GetValueFromParam(string key){
		String retval = '';
		if(ApexPages.currentPage().getParameters().containsKey(key)){
			retval = ApexPages.currentPage().getParameters().get(key);
		}
		return retval;
	}

    public static List<SelectOption> GetPicklistOptions(Schema.DescribeFieldResult fieldResult){
        return GetPicklistOptions(fieldResult, true);
    }

    public static List<SelectOption> GetPicklistOptions(Schema.DescribeFieldResult fieldResult, Boolean includeEmpty){
        return GetPicklistOptions(fieldResult, true, '--None--');
    }

    public static List<SelectOption> GetPicklistOptions(Schema.DescribeFieldResult fieldResult, Boolean includeEmpty, String emptyElement){
        return GetPicklistOptions(fieldResult, includeEmpty, emptyElement, '0');
    }

    public static List<SelectOption> GetPicklistOptions(Schema.DescribeFieldResult fieldResult, Boolean includeEmpty, String emptyLabel, String emptyValue){
        List<SelectOption> options = new List<SelectOption>();
        if(includeEmpty){
            options.add(new SelectOption(emptyValue, emptyLabel));
        }
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }
        return options;
    }

    public static String GetDashboardUrl(Id profileId){
        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id = :profileId LIMIT 1];

        String dashboardUrl = '/d2d/';
        if(userProfile.Name == 'D2D Manager' || userProfile.Name == 'D2D Admin'){
            dashboardUrl += 'D2D_ManagerDashboard';
        } else if(userProfile.Name == 'D2D Sales Rep' || userProfile.Name == 'D2D Portal User'){
            dashboardUrl += 'D2D_SalesRepDashboard';
        } else {
            throw new D2DException('User profile is not valid for D2D site.');
        }
        return dashboardUrl;
    }

    public static String GetPDFUrl(Id fileId) {
        if(D2D_Utility.isiPad()){
            return 'https://docs.google.com/gview?embedded=true&url=' + EncodingUtil.urlEncode(URL.getSalesforceBaseUrl().toExternalForm() + '/d2d/servlet/servlet.FileDownload?file=' + fileId + '&html=true', 'UTF-8');
        } else {
            return '/d2d/servlet/servlet.FileDownload?file=' + fileId + '&html=false';
        }
    }

    public static Boolean isiPad() {
        String userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
        
        if (userAgent != null && (userAgent.contains('iPhone') || userAgent.contains('iPad')))
            return true;
        else
            return false;
    }

    public static ApexPages.Message GetMessageFromString(ApexPages.Severity severity, String message){
        return new ApexPages.Message(severity, message);
    }

    public static ApexPages.Message SendEmail(String templateName, Id targetObjectId, List<Messaging.EmailFileAttachment> emailAttachments){
        return SendEmail(templateName, targetObjectId, null, emailAttachments);
    }

    public static ApexPages.Message SendEmail(String templateName, Id targetObjectId, Id whatId, List<Messaging.EmailFileAttachment> emailAttachments){
        EmailTemplate templateId = [SELECT Id FROM EmailTemplate WHERE Name = :templateName LIMIT 1];
        if(templateId != null){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateID(templateId.Id); 
            email.setSaveAsActivity(false);
            email.setTargetObjectId(targetObjectId);
            if(whatId != null){
                email.setWhatId(whatId);
            }
            if(emailAttachments != null){
                email.setFileAttachments(emailAttachments);
            }

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            return null;
        } else {
            return GetMessageFromString(ApexPages.Severity.FATAL, 'The email template could not be found.');
        }
    }

    public static ApexPages.Message SendEmailOutsideSalesforce(String templateName, String outsideEmail, Id whatId, List<Messaging.EmailFileAttachment> emailAttachments){
        Contact dummyContact = [SELECT Id, Email FROM Contact WHERE Email <> null LIMIT 1];

        EmailTemplate templateId = [SELECT Id FROM EmailTemplate WHERE Name = :templateName LIMIT 1];
        if(templateId != null){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateID(templateId.Id); 
            email.setSaveAsActivity(false);
            email.setTargetObjectId(dummyContact.Id);
            if(whatId != null) {
                email.setWhatId(whatId);
            }
            email.setToAddresses(new List<String> { outsideEmail });

            Savepoint sp = Database.setSavepoint();
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            Database.rollback(sp);

            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setToAddresses(email.getToAddresses());
            emailToSend.setPlainTextBody(email.getPlainTextBody());
            emailToSend.setHTMLBody(email.getHTMLBody());
            emailToSend.setSubject(email.getSubject());
            if(emailAttachments != null){
                emailToSend.setFileAttachments(emailAttachments);
            }

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailToSend });
            return null;
        } else {
            return GetMessageFromString(ApexPages.Severity.FATAL, 'The email template could not be found.');
        }
    }

    public static ErrorMessage ConvertLead(Id leadId, D2D_Proposal__c d2dProposal){
        ErrorMessage errorMessage = null;

        try{
            System_Designers_Assignment__c assignment = [SELECT User__c, Last_Assignment_Datetime__c FROM System_Designers_Assignment__c ORDER BY Last_Assignment_Datetime__c ASC LIMIT 1];

            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(leadId);
            lc.setConvertedStatus('Qualified');
            lc.setOwnerId(assignment.User__c);
            Database.LeadConvertResult lcr = Database.convertLead(lc);

            if(lcr.isSuccess()){
                // do success stuff
                system.debug('**SZ: lcr success');
                // link the property to the opportunity
                Property__c property;
                try {
                    property = [SELECT Id, Name FROM Property__c WHERE Property_Owner__c = :lcr.getAccountId() LIMIT 1];
                } catch (Exception ex){
                    throw new D2DException('There was an error updating records after conversion [Property]: ' + ex.getMessage());
                }

                Opportunity opp;
                try {
                    opp = [SELECT Id, Property__c, Approved_System_Design__c, OwnerId FROM Opportunity WHERE Id = :lcr.getOpportunityId() LIMIT 1];
                    opp.OwnerId = assignment.User__c;
                    opp.Property__c = property.Id;
                    update opp;
                } catch (Exception ex){
                    throw new D2DException('There was an error updating records after conversion [Opportunity]: ' + ex.getMessage());
                }

                Contact contact;
                try {
                    contact = [SELECT Id, OwnerId FROM Contact WHERE AccountId = :lcr.getAccountId() LIMIT 1];
                    contact.OwnerId = assignment.User__c;
                    update contact;
                } catch (Exception ex){
                    throw new D2DException('There was an error updating records after conversion [Contact]: ' + ex.getMessage());
                }

                Event surveyEvent = new Event();
                surveyEvent.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Event' AND DeveloperName = 'Site_Survey_Remote' LIMIT 1].Id;
                surveyEvent.OwnerId = assignment.User__c;
                surveyEvent.WhatId = lcr.getOpportunityId();
                surveyEvent.Subject = 'Schedule Site Survey';
                surveyEvent.StartDateTime = Datetime.now();
                surveyEvent.EndDateTime = surveyEvent.StartDateTime.addDays(1);
                surveyEvent.Description = 'This is a D2D Survey Request - Utility Company: ' + d2dProposal.Utility_Company_Master__r.Name + '; Number of Panels: ' + d2dProposal.Number_of_Panels__c;
                surveyEvent.Related_Property_Link__c = d2dSettings.DocuSign_Host__c + property.Id;
                surveyEvent.Related_Property_Name__c = property.Name;
                surveyEvent.Site_Survey_Type__c = 'Site Survey Remote';
                surveyEvent.D2D_Survey_Request__c = true;
                insert surveyEvent;

                assignment.Last_Assignment_Datetime__c = Datetime.now();
                update assignment;

                errorMessage = new ErrorMessage('Success', '');
                errorMessage.ErrorFields += '[AccountId:' + lcr.getAccountId() + ']';
                errorMessage.ErrorFields += '[OpportunityId:' + lcr.getOpportunityId() + ']';
                errorMessage.ErrorFields += '[PropertyId:' + property.Id + ']';
                errorMessage.ErrorFields += '[ContactId:' + contact.Id + ']';
            } else {
                // report errors
                system.debug('**SZ: lcr not success');
                errorMessage = new ErrorMessage('There was an error while attempting to convert the lead.', '');
                for(Database.Error err : lcr.getErrors()){
                    errorMessage.ErrorFields += '[Error: ' + err.getMessage() + '; ' + err.getFields() + ']';
                }
            }
        }
        catch (Exception ex){
            if(ex.getMessage().contains('Property Address fields')){
                errorMessage = new ErrorMessage('There wan an error during lead conversion.  One or more address fields were not present.', ex.getMessage() + ' -- stack trace -- ' + ex.getStackTraceString());
            } else {
                system.debug('**SZ: exception caught');
                errorMessage = new ErrorMessage('There was an error during lead conversion.  ' + ex.getMessage(), ex.getStackTraceString());
            }
        }

        return errorMessage;
    }

    private static String contractFields = 'Name, Closed__c, Locked__c, State_Grant_Amount__c, Proposal__r.System_Design_Quote__r.System_Design__r.Property__r.Name, SAC_Loan__c, ' + 
                                            'Proposal__r.System_Design_Quote__r.System_Design__r.Survey__c, Contract_Execution_Date__c, Scenario__c, Term_Loan__c, ' + 
                                            'Proposal__r.System_Design_Quote__r.Calculated_System_Price__c, ' + 
                                            'Proposal__r.System_Design_Quote__r.Total_Closed_Scenario_Adjustments__c, Proposal__r.System_Design_Quote__r.Scenario_1_Financing_Option__c, ' + 
                                            'Proposal__r.System_Design_Quote__r.Scenario_2_Financing_Option__c, Proposal__r.System_Design_Quote__r.Scenario_3_Financing_Option__c, ' + 
                                            'Proposal__r.System_Design_Quote__r.Scenario_4_Financing_Option__c, Proposal__r.System_Design_Quote__r.Scenario_1_Lease_Fund__c, ' + 
                                            'Proposal__r.System_Design_Quote__r.Scenario_2_Lease_Fund__c, Proposal__r.System_Design_Quote__r.Scenario_3_Lease_Fund__c, ' + 
                                            'Proposal__r.System_Design_Quote__r.Scenario_4_Lease_Fund__c, Financing_Type__c, Lease_Option__c, ' + 
                                            'Proposal__r.System_Design_Quote__r.Scenario_1_Available_SREC_Contract_Offer__r.RecordTypeDeveloperName__c, ' + 
                                            'Proposal__r.System_Design_Quote__r.Scenario_2_Available_SREC_Contract_Offer__r.RecordTypeDeveloperName__c, ' + 
                                            'Proposal__r.System_Design_Quote__r.Scenario_3_Available_SREC_Contract_Offer__r.RecordTypeDeveloperName__c, ' + 
                                            'Proposal__r.System_Design_Quote__r.Scenario_4_Available_SREC_Contract_Offer__r.RecordTypeDeveloperName__c, ' + 
                                            'Proposal__r.System_Design_Quote__r.Scenario_1_Available_SREC_Contract_Offer__r.Applicable_Scenario__c, ' + 
                                            'Proposal__r.System_Design_Quote__r.Scenario_2_Available_SREC_Contract_Offer__r.Applicable_Scenario__c, ' + 
                                            'Proposal__r.System_Design_Quote__r.Scenario_3_Available_SREC_Contract_Offer__r.Applicable_Scenario__c, ' + 
                                            'Proposal__r.System_Design_Quote__r.Scenario_4_Available_SREC_Contract_Offer__r.Applicable_Scenario__c, ' + 
                                            'Proposal__r.System_Design_Quote__r.Scenario_1_Available_SREC_Contract_Offer__r.Contract_Offer_Applied__c, ' + 
                                            'Proposal__r.System_Design_Quote__r.Scenario_2_Available_SREC_Contract_Offer__r.Contract_Offer_Applied__c, ' + 
                                            'Proposal__r.System_Design_Quote__r.Scenario_3_Available_SREC_Contract_Offer__r.Contract_Offer_Applied__c, ' + 
                                            'Proposal__r.System_Design_Quote__r.Scenario_4_Available_SREC_Contract_Offer__r.Contract_Offer_Applied__c, ' +
                                            'Proposal__r.System_Design_Quote__r.Scenario_1_Financing_Type__c, Proposal__r.System_Design_Quote__r.Scenario_2_Financing_Type__c, ' +
                                            'Proposal__r.System_Design_Quote__r.Scenario_3_Financing_Type__c, Proposal__r.System_Design_Quote__r.Scenario_4_Financing_Type__c, ' + 
                                            'Proposal__r.System_Design_Quote__r.Scenario_1_Adjusted_Price_NUM__c, Proposal__r.System_Design_Quote__r.Scenario_2_Adjusted_Price_NUM__c, ' + 
                                            'Proposal__r.System_Design_Quote__r.Scenario_3_Adjusted_Price_NUM__c, Proposal__r.System_Design_Quote__r.Scenario_4_Adjusted_Price_NUM__c';

    public static void CloseOpportunity(Id contractId, Id opportunityId){
        Astrum_Contract__c[] contractQuery = Database.query('SELECT ' + contractFields + ' FROM Astrum_Contract__c WHERE ID = \'' + String.escapeSingleQuotes(contractID) + '\' LIMIT 1');
        Astrum_Contract__c contr = contractQuery[0];

        Opportunity selectedOpp = [SELECT Name, CloseDate, StageName, AccountID, Account.Name, Survey__c, System_Design__c, System_Design_Quote__c, Proposal__c, Property__c, 
                                   Astrum_Contract__c, Lease_PPA_Fund__c, Leasing_Option__c, Amount, Financing_Type__c, Financing_Option__c, State_Grant_Amount__c, SREC__c 
                                   FROM Opportunity WHERE Id = :opportunityId];
        selectedOpp.Survey__c = contr.Proposal__r.System_Design_Quote__r.System_Design__r.Survey__c;
        selectedOpp.System_Design__c = contr.Proposal__r.System_Design_Quote__r.System_Design__c;
        selectedOpp.System_Design_Quote__c = contr.Proposal__r.System_Design_Quote__c;
        selectedOpp.Proposal__c = contr.Proposal__c;
        selectedOpp.Astrum_Contract__c = contr.ID;
        selectedOpp.CloseDate = contr.Contract_Execution_Date__c != null ? contr.Contract_Execution_Date__c : Date.today();
        Integer n = Integer.valueOf(contr.Scenario__c);
        //selectedOpp.Amount = getOppAmount(contr, n);
        selectedOpp.Financing_Type__c = contr.Financing_Type__c;
        if (contr.Financing_Type__c == 'PPA')
            selectedOpp.Financing_Type__c = 'Lease';    //CPQ-684
        if (selectedOpp.Financing_Type__c == 'Purchase' && (String.isNotBlank(contr.Term_Loan__c) || String.isNotBlank(contr.SAC_Loan__c))){
            selectedOpp.Financing_Option__c = contr.Term_Loan__c + '; ' + contr.SAC_Loan__c;
        } else if (selectedOpp.Financing_Type__c == 'Purchase' && String.isBlank(contr.Term_Loan__c) && String.isBlank(contr.SAC_Loan__c)){
            selectedOpp.Financing_Option__c = 'No Financing';
        }
        selectedOpp.Lease_PPA_Fund__c = (String)contr.Proposal__r.System_Design_Quote__r.get('Scenario_' + n + '_Lease_Fund__c');
        selectedOpp.Leasing_Option__c = contr.Lease_Option__c;
        selectedOpp.SREC__c = getSRECContract(contr, n);
        selectedOpp.State_Grant_Amount__c = contr.State_Grant_Amount__c;
        selectedOpp.StageName = 'Closed - Won';

        //Update a System Design field
        //System_Design__c sysDesign = new System_Design__c(ID = contr.Proposal__r.System_Design_Quote__r.System_Design__c);
        //sysDesign.Calculated_System_Price__c = contr.Proposal__r.System_Design_Quote__r.Commission_Design_Price__c;

        //Update an SDQ field (Total_Closed_Scenario_Adjustments__c controls Opportunity.Amount)
        System_Design_Quote__c sdq = new System_Design_Quote__c(Id = contr.Proposal__r.System_Design_Quote__c);
        String financingType = (String)contr.getSObject('Proposal__r').getSObject('System_Design_Quote__r').get('Scenario_' + n + '_Financing_Type__c');
        Decimal adjustedPrice = (Decimal)contr.getSObject('Proposal__r').getSObject('System_Design_Quote__r').get('Scenario_' + n + '_Adjusted_Price_NUM__c');
        //Updated formula for CPQ-122
        if (financingType == 'Purchase'){
            sdq.Total_Closed_Scenario_Adjustments__c = adjustedPrice;
        } else if (financingType == 'Lease' || financingType == 'PPA'){
            sdq.Total_Closed_Scenario_Adjustments__c = 0;
        }
        
        try {
            //update sysDesign;
            update sdq;
            update selectedOpp;
            CloseContractCtrl.lockAllRelatedRecords(selectedOpp.Property__c, contr.Id);
        } catch (Exception ex){
            ApexPages.addMessages(ex);
        }
    }

    private static String getSRECContract(Astrum_Contract__c c, Integer scenario){
        String returnStr = 'N/A - NO SRECs';
        try {
            sObject availableSREC = c.Proposal__r.System_Design_Quote__r.getSObject('Scenario_' + scenario + '_Available_SREC_Contract_Offer__r');
            String applicableScenario = (String)availableSREC.get('Applicable_Scenario__c');
            Boolean offerApplied = (Boolean)availableSREC.get('Contract_Offer_Applied__c');
            String recType = (String)availableSREC.get('RecordTypeDeveloperName__c');
            if (applicableScenario == String.valueOf(scenario) && offerApplied && String.isNotBlank(recType))
                returnStr = recType;
        } catch (Exception ex){
            System.debug(ex.getStackTraceString());
        }
        return returnStr;
    }

    public static ApexPages.Message SellContract(Id contractId){
        ApexPages.Message returnMessage = null;

        Astrum_Contract__c contract = [SELECT Id, Closed__c, Proposal__c FROM Astrum_Contract__c WHERE ID = :contractId LIMIT 1];

        String acceptedResult = SalesWorkflowValidationUtility.contractWorkflowOnAccepted(contract);
        if (acceptedResult != 'Valid'){
            returnMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + acceptedResult);
            return null;
        }
        return returnMessage;
    }

    public static ApexPages.Message CreateSalesOrder(Id opportunityId, List<Attachment> contractAttachments){
        ApexPages.Message returnMessage = null;
        Opportunity opportunity = retrieveOppById(opportunityId);
        SCRB_SalesOrder__c order = buildSalesOrderFromOpportunity(opportunity, null);
        SCRB_SalesOrderLineItem__c[] salesOrderLineItems = createSOLineItems(order, opportunity);
        
        Account account = [SELECT a.Id, a.Name, a.Accounting_ID__c, a.JobCount__c, a.Accountnumber, a.Billingstreet, a.BillingCity, a.BillingState, a.BillingPostalCode, a.BillingCountry, 
            a.ShippingStreet, a.ShippingCity, a.ShippingState, a.ShippingPostalCode, a.ShippingCountry, a.Phone, a.Fax 
            FROM Account a WHERE a.Id = :order.AccountId__c];

        /*
            The following four fields have inputFields on the CreateSalesOrder form in CPQ
        order.RequestedShipmentOn__c = Date.today();
        order.Has_Field_Survey_Been__c = 'No'; // 'Yes - Pending', 'Yes - Complete'
        order.Down_Payment__c = 'Yes'; // 'No'
        order.Hand_Off_Notes__c = '';
        */

        try {
            CreateJobId(account, opportunity, order);

            System_Design_Quote__c[] relatedSDQ = [SELECT System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_Before_Solar__c, System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_After_Solar__c, 
                                                    System_Design__r.Default_CB_Panel__r.Utility_Service__r.Custom_Utility_Rate_Set_By__c, System_Design__r.Default_CB_Panel__r.Utility_Service__r.Custom_Utility_Rate_Applied__c, 
                                                    Scenario_1_Adjusted_Price_NUM__c, Scenario_2_Adjusted_Price_NUM__c, Scenario_3_Adjusted_Price_NUM__c, Scenario_4_Adjusted_Price_NUM__c, 
                                                    Closed_Scenario__c FROM System_Design_Quote__c WHERE ID = :opportunity.System_Design_Quote__c LIMIT 1];

            if (!relatedSDQ.isEmpty()){   //CPQ-224
                order.Rate_Code_Before_Solar__c = relatedSDQ[0].System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_Before_Solar__c;
                order.Rate_Code_After_Solar__c = relatedSDQ[0].System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_After_Solar__c;
                order.Custom_Utility_Rate_Set_By__c = relatedSDQ[0].System_Design__r.Default_CB_Panel__r.Utility_Service__r.Custom_Utility_Rate_Set_By__c;
                order.Custom_Utility_Rate_Applied__c = relatedSDQ[0].System_Design__r.Default_CB_Panel__r.Utility_Service__r.Custom_Utility_Rate_Applied__c;

                //CPQ-122, updated for CPQ-790
                String n = relatedSDQ[0].Closed_Scenario__c;
                if (n != null){
                    order.Commission_System_Price__c = relatedSDQ[0].get('Scenario_' + n + '_Adjusted_Price_NUM__c') != null ? (Decimal)relatedSDQ[0].get('Scenario_' + n + '_Adjusted_Price_NUM__c') : 0;
                } else {
                    order.Commission_System_Price__c = -1;  //To make it clear that an error occurred
                }
            }
            
            
            try {
				List<User> salesOrderOwnerList = [Select Id, Profile.Name from User where Email = :d2dSettings.Sales_Order_Owner__c];
              
				if(salesOrderOwnerList.size() == 1) {
					order.OwnerId = salesOrderOwnerList[0].Id; 
				} 
				else {
					for(User salesOrderOwner : salesOrderOwnerList) {
						if(!salesOrderOwner.Profile.Name.contains('D2D')) { 
							order.OwnerId = salesOrderOwner.Id; 
						}
					}
				}
            }
            catch(Exception e) {
                System.debug('Sales order owner error: ' + e.getStackTraceString());
                returnMessage = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage(), e.getStackTraceString());
                return returnMessage;
            }

            insert order;
            System.Debug('New Sales Order: ' + order.id);
            for (SCRB_SalesOrderLineItem__c li: salesOrderLineItems){
                li.SalesOrderId__c = order.id;                   
            }
            
            insert salesOrderLineItems;
            
            //If the Opportunity Stage is not 'Closed Won' then update it
            if (Opportunity.StageName != 'Closed - Won'){
                Opportunity.StageName = 'Closed - Won';
                update Opportunity;
            }

            //The CloseContract VF page sent us a Contract Attachment that needs to be cloned onto the new Sales Order
            try {
                if (!Test.isRunningTest()){
                    //insert pdf;     //Temporarily insert the Attachment before we re-parent it to the new Sales Order
                    // Associate the docu-signed attachments to the contract
                    List<Attachment> attachmentsToInsert = new List<Attachment>();
                    for(Attachment att : contractAttachments){
                        Attachment newAtt = att.clone();
                        newAtt.ParentId = order.Id;
                        attachmentsToInsert.add(newAtt);
                    }
                    insert attachmentsToInsert;
                }
            } catch (Exception e){
                System.debug('Attachment handling failed: ' + e.getStackTraceString());
                returnMessage = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage(), e.getStackTraceString());
                return returnMessage;
            }

            /*
             * Do not allow automatic submission for approval
            // Submit for Approval
            Approval.ProcessResult result = null;
            try {
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Auto-submitting request for approval.');
                req1.setObjectId(order.Id);
                req1.setSubmitterId(UserInfo.getUserId()); 
                req1.setProcessDefinitionNameOrId('Sales_Coordinator_Approval');
                req1.setSkipEntryCriteria(false);
                
                // Submit the approval request for the account
                result = Approval.process(req1);
            }
            
            // Verify the result
            if(result != null && !result.isSuccess()){
                String errorDetail = '';
                for(Database.Error err : result.getErrors()){
                    errorDetail += '[' + err.getStatusCode() + '][' + err.getMessage() + '][' + err.getFields() + ']<br/>';
                }
                returnMessage = new ApexPages.Message(ApexPages.Severity.WARNING, 'The sales order was not submitted for approval.', errorDetail);
            }
            */
        } catch(System.DMLException e) {
            System.debug('Update Exception --> ' + e);
            returnMessage = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage(), e.getStackTraceString());
        }         

        return returnMessage;
    }


    /*
     * This section of code was copied from the SalesOrder_Utility class to allow SalesReps to have access to records that would be blocked by sharing rules trying to leverage that class
     *
     */
    public class MissingAccountException extends Exception {}
    public class MissingPropertyException extends Exception {}
    public class NoLineItemsException extends Exception {}

    private static SCRB_SalesOrder__c buildSalesOrderFromOpportunity(Opportunity opportunity, String soId){ 
        //soId can be null - if not null, the salesorder will be retrieved and updated.  If null, we'll create a new slaesorder
        Account acct = new Account();   
                   
        if  (opportunity.AccountId != null){ 
             acct = [
                SELECT 
                    Id,
                    Name, 
                    AccountNumber, 
                    Accounting_ID__c,
                    JobCount__c,    
                    BillingStreet, 
                    BillingCity, 
                    BillingState, 
                    BillingPostalCode, 
                    BillingCountry,
                    ShippingStreet,  
                    ShippingCity, 
                    ShippingState, 
                    ShippingPostalCode, 
                    ShippingCountry, 
                    Phone, 
                    Fax 
                FROM Account 
                WHERE Id = :opportunity.AccountId] ;
        }else {
             throw new MissingAccountException('Cannot create an order from this opportunity: Please assign an account to the opportunity.  opportunity.Id --> ' + opportunity.Id );        
        }
 
        Property__c property = new Property__c();
                
        if  (opportunity.Property__c != null){ 
            /*  Current Property__c Fields
                Name (Property_Address_1)
                RecordType
                HOA_Contact_Email__c    Email
                HOA_Contact_Name__c Text(60)
                HOA_Contact_Phone__c    Phone
                Property_Address_2__c   Text(40)
                Property_City__c    Text(40)
                Property_County__c  Picklist
                Property_Owner__c   Lookup(Account)
                Property_State__c   Picklist
                Property_ZIP__c Text(10)
                Authorization_Bodies__c Picklist (Multi-Select)
                Survey_Count__c
                RecordTyId
                Qualified_Utililty_Service_Count__c
                Prorty_ZIP__c
                Prorty_State__c
                Prorty_Owner__c
                Prorty_County__c
                Prorty_City__c
                Prorty_Address_2__c 
                Permit_Jurisdiction__c
                OwnerId
                Oimal_Site_Quality_kWh_y_kW__c
                Name
                Id
                HOA_Contact_Phone__c
                HOA_Contact_Name__c
                HOA_Contact_Email__c
                ConnectionSentId
                ConnectionReceivedId
                Authorization_Bodies__c
                Astrum_Office__c
                Account_Number__c               
            
            */ 
               
                property = [
                    SELECT id, 
                    name, //Property_Address_1
                    Survey_Count__c,
                    RecordTypeId,
                    Qualified_Utililty_Service_Count__c,
                    Property_ZIP__c,
                    Property_State__c,
                    Property_Owner__c,
                    Property_County__c,
                    Property_City__c,
                    Property_Address_2__c,
                    Permit_Jurisdiction__c,
                    OwnerId,
                    Optimal_Site_Quality_kWh_y_kW__c,
                    HOA_Contact_Phone__c,
                    HOA_Contact_Name__c,
                    HOA_Contact_Email__c,
                    ConnectionSentId,
                    ConnectionReceivedId,
                    Authorization_Bodies__c,
                    Astrum_Office__c,
                    Account_Number__c,
                    Astrum_Sales_Region__r.Sales_Coordinator__c,
                    Astrum_Office_New__r.Director_of_Operations__c,
                    Astrum_Office_New__r.Sales_Alert_Email__c                                    
                FROM Property__c 
                WHERE id = :opportunity.Property__c] ;
        }else {
             throw new MissingPropertyException('Cannot create an order from this opportunity: Please assign a property to the opportunity.');        
        }
        
        Boolean newOrder=false;
        if(soId==null){
            newOrder=true;
        }
        SCRB_SalesOrder__c order = (soId == null) ? new SCRB_SalesOrder__c() : 
        [SELECT SCRB_SalesOrder__c.Name, StatusCode__c FROM SCRB_SalesOrder__c WHERE id = :soId];
                                       
        //Pre-populate Opportunity and account information
        //order.Name=Opportunity.Name;
        order.AccountId__c=opportunity.AccountId;             
        order.OpportunityId__c = opportunity.id;
        order.Description__c=opportunity.description;
        order.Amount__c = opportunity.Amount;
        order.discountAmount__c=0;
        order.freightAmount__c=0; 
        order.Type__c='Order';
        if(newOrder){
            order.StatusCode__c='Submit Pending';
        } else {
            if(order.StatusCode__c=='Sales Manager Approved'){order.Changed_By_Sales__c = true;}
        }
        order.RequestedShipmentOn__c=Date.Today() + 60;
        order.DocumentDate__c=Date.Today();
        System_Design__c sysdes; 
        if(opportunity.System_Design_Quote__c != null){
            sysdes = [Select Id, System_Makeup__c, Total_System_Size_kW__c, Panel_Count__c FROM System_Design__c WHERE id=:[Select System_Design__c FROM System_Design_Quote__c WHERE id=:opportunity.System_Design_Quote__c LIMIT 1].System_Design__c];
            order.System_Design_Quote__c = opportunity.System_Design_Quote__c;        
            // Added by RJ 1/22/14
            order.Upfront_Lease_Payment_Due_at_Final_Comp__c = opportunity.System_Design_Quote__r.NRG_Prepay_Amount__c;
            order.Astrum_Upfront_SREC_Value__c = opportunity.System_Design_Quote__r.Upfront_SREC_Value__c;
            order.Sales_Tax_Prepaid__c =   opportunity.System_Design_Quote__r.Sales_Tax_Prepaid__c;
        }
                      
        if(sysdes != null) {
            order.System_Makeup__c = sysdes.System_Makeup__c;
            order.System_Size_kW__c = sysdes.Total_System_Size_kW__c;
            order.Total_Panel_Count__c = sysdes.Panel_Count__c;
        }
        order.BillingStreet__c = acct.BillingStreet;
        order.BillingCity__c=acct.BillingCity;
        order.BillingState__c=acct.BillingState;
        order.BillingPostalCode__c=acct.BillingPostalCode;
        order.BillingPhone__c=acct.Phone;
        order.BillingFax__c=acct.Fax;
        order.BillingCountry__c=acct.BillingCountry;                                
         
        order.ShippingStreet__c= acct.ShippingStreet;
        order.ShippingCity__c=acct.ShippingCity;
        order.ShippingState__c=acct.ShippingState;
        order.ShippingPostalCode__c=acct.ShippingPostalCode;
        order.ShippingPhone__c=acct.Phone;
        order.ShippingFax__c=acct.Fax;
        order.ShippingCountry__c=acct.ShippingCountry;
             
        //Begin Astrum Specific Order Fields
             
        order.Property__c = property.id;
        order.Installation_Address_1__c=property.name;
        order.Installation_Address_2__c=property.Property_Address_2__c;
        order.Installation_City__c=property.Property_City__c;
        order.Installation_State__c=property.Property_State__c;
        order.Installation_Zip_PostalCode__c=property.Property_ZIP__c;
        order.Installation_Permit_Jurisdiction__c=property.Permit_Jurisdiction__c;
         
        order.Opportunity_Close_Date__c = opportunity.CloseDate;
        order.Financing_Option__c = opportunity.Financing_Option__c;
        order.Financing_Type__c = opportunity.Financing_Type__c;
        order.Leasing_Option__c = opportunity.Leasing_Option__c;
        // Added by RJ on 10/24/13
        order.Lease_PPA_Fund__c = opportunity.Lease_PPA_Fund__c;
        
        // Added by RJ 1/18/13
        order.Sales_Coordinator__c = property.Astrum_Sales_Region__r.Sales_Coordinator__c;
        order.Director_of_Operations__c = property.Astrum_Office_New__r.Director_of_Operations__c;      
        order.Sales_Alert_Email__c = property.Astrum_Office_New__r.Sales_Alert_Email__c;        
        order.Owner_User__c = UserInfo.getUserId();


        
        if(opportunity.contact_detail__c != null)
        {
            try{
              User contactDetail = [Select email from User where alias = :opportunity.contact_detail__c ];
              order.Contact_Detail_Email__c =   contactDetail.email;    
            }
            catch(Exception e)
            {
                System.debug('Email not Found');
            }
        }
        //End Astrum Specific        
        
        
        
        return order;
    }    
   
    private static void CreateJobId(Account acct, Opportunity opportunity, SCRB_SalesOrder__c objOrder)
    {
        // 
        // Create the Job Id
        //
        integer idx = acct.Accounting_ID__c.indexOf('-');   
        integer cnt = 0;            
        
        if (acct.JobCount__c != null)
        {
            cnt = acct.JobCount__c.intValue();  
        }                           
            
        cnt++;
        acct.JobCount__c = cnt;
        
        // update the account with the new job count
       
        try
        {
            update(acct);
        }
        catch (DmlException de)
        {
            throw new MissingAccountException(de.getMessage());         
        }
        
        
        // Lead char comes from financing type
        // Figure out if "L" or "P"     
        String jobId;
        jobId = opportunity.Financing_Type__c.substring(0,1);
        
        jobId += acct.Accounting_ID__c.substring(idx) + '-' + cnt;
        
        objOrder.Job_Id__c = jobId;                         
    }
    
    private static List<SCRB_SalesOrderLineItem__c> createSOLineItems(SCRB_SalesOrder__c order, Opportunity opportunity){
        //Retrieve the PriceBook name for Prepopulation in order 
        string pbID = opportunity.Pricebook2Id;
        system.debug('**SZ: pbId = ' + pbId);
        //system.debug('**SZ: test id = ' + Test.getStandardPricebookId());
        PriceBook2 pb = (opportunity.Pricebook2Id == null || (Test.isRunningTest() && opportunity.Pricebook2Id == Test.getStandardPricebookId())) ? new PriceBook2() : [Select Id, Name from Pricebook2 where Id=:pbID];
        order.Pricebook__c=pb.Name;     
         
        //Create a new SCRB_SalesOrderLineItem__c and populate a row for each oppLineItem that exists
        
        integer i = 0;
        List<SCRB_SalesOrderLineItem__c> salesOrderLineItems = new SCRB_SalesOrderLineItem__c[0];
        for(OpportunityLineItem oli: [SELECT Id, SortOrder, 
                                        PricebookEntryId, Description, Quantity, 
                                        ListPrice, UnitPrice, TotalPrice, ServiceDate 
                                      FROM OpportunityLineItem 
                                      WHERE Opportunityid = :opportunity.Id]){
            string pbeID = oli.PricebookEntryId;
            PriceBookEntry pbEntry = (pbeId == null) ? new PriceBookEntry() : 
            [Select Id, Name, Pricebook2Id, Product2Id, ProductCode from PricebookEntry where Id=:pbeID];
                       
            SCRB_SalesOrderLineItem__c salesOrderLineItem = new SCRB_SalesOrderLineItem__c();
            salesOrderLineItem.SalesOrderId__c=order.Id;
            salesOrderLineItem.SortOrder__c = i+1;
            salesOrderlineItem.ProductId__c = pbEntry.Product2Id;  
            salesOrderLineItem.Name = pbEntry.Name;
            salesOrderLineItem.Quantity__c = oli.Quantity;
            salesOrderLineItem.ListPrice__c= oli.ListPrice;
            salesOrderLineItem.SalesPrice__c=oli.UnitPrice;
            salesOrderLineItem.TotalPrice__c=oli.TotalPrice;
            salesOrderLineItem.RequestedShipmentOn__c=Date.Today();
            SalesOrderLineItems.add(salesOrderLineItem);
            i++;
        }
        Integer itemCount=i;
        if (itemCount == 0) {
            throw new NoLineItemsException('Unable to create Sales Order: Products must be added to the Opportunity before creating a Sales Order.');
        }
        
        return salesOrderLineItems;     
    }

    private static void removeSOLineItems(SCRB_SalesOrder__c so){
            List<SCRB_SalesOrderLineItem__c> salesOrderLineItems = [
                            Select s.SalesOrderId__c, 
                            s.Id 
                            From SCRB_SalesOrderLineItem__c s 
                            Where s.SalesOrderId__c = :so.Id];
            delete(salesOrderLineItems);
    }

    private static Opportunity retrieveOppById(Id oppId){
        System.Debug('In D2D_Utilitity : retrieveOppById - oppId --> ' + oppId );
        
        Opportunity opportunity = [SELECT name, Property__c, 
                                    accountID, CloseDate, 
                                    Description, StageName, 
                                    Pricebook2Id, System_Design__c, 
                                    System_Design_Quote__r.Upfront_SREC_Value__c,System_Design_Quote__r.Sales_Tax_Prepaid__c,
                                    System_Design_Quote__r.NRG_Prepay_Amount__c,  System_Design_Quote__r.System_Design__r.Tree_Removal__c,
                                    Amount,Financing_Option__c,Financing_Type__c,Leasing_Option__c,Contact_Detail__C,Lease_PPA_Fund__c
                                    //Amount, Financing_Type__c, Leasing_Option__c
                                   FROM Opportunity 
                                   WHERE id = :oppId];
        System.Debug('opportunity --> ' + opportunity );
        return opportunity;
    }
}