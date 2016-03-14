public with sharing class SightenAPIIntegrator {

	/*
	 * SIGHTEN QUOTE API
	 */

	private static List<String> sdqFields = new List<String>{
		'Id',
		'System_Design__c',
		'System_Design__r.Overall_Site_Quality__c',
		'System_Design__r.Property__c',
		'System_Design__r.Property__r.Property_Owner__c',
		'Scenario_1_Final_EPC_Price_NUM__c',
		'Scenario_2_Final_EPC_Price_NUM__c',
		'Scenario_3_Final_EPC_Price_NUM__c',
		'Scenario_4_Final_EPC_Price_NUM__c',
		'Scenario_1_Installer_Paid_Incentive_Amt__c',
		'Scenario_2_Installer_Paid_Incentive_Amt__c',
		'Scenario_3_Installer_Paid_Incentive_Amt__c',
		'Scenario_4_Installer_Paid_Incentive_Amt__c',
		'Scenario_1_Adjusted_Price_NUM__c',
		'Scenario_2_Adjusted_Price_NUM__c',
		'Scenario_3_Adjusted_Price_NUM__c',
		'Scenario_4_Adjusted_Price_NUM__c',
		'Scenario_1_Lease_Escalator__c',
		'Scenario_2_Lease_Escalator__c',
		'Scenario_3_Lease_Escalator__c',
		'Scenario_4_Lease_Escalator__c',
		'Scenario_1_Down_Payment__c',
		'Scenario_2_Down_Payment__c',
		'Scenario_3_Down_Payment__c',
		'Scenario_4_Down_Payment__c',
		'Scenario_1_SREC_Contract_Discount__c',
		'Scenario_2_SREC_Contract_Discount__c',
		'Scenario_3_SREC_Contract_Discount__c',
		'Scenario_4_SREC_Contract_Discount__c',
		'Scenario_1_Refuse_ACH__c',
		'Scenario_2_Refuse_ACH__c',
		'Scenario_3_Refuse_ACH__c',
		'Scenario_4_Refuse_ACH__c',
		'Scenario_1_Term_Loan__r.Financing_Term_Months__c',
		'Scenario_2_Term_Loan__r.Financing_Term_Months__c',
		'Scenario_3_Term_Loan__r.Financing_Term_Months__c',
		'Scenario_4_Term_Loan__r.Financing_Term_Months__c',
		'Scenario_1_SAC_Loan__r.Financing_Term_Months__c',
		'Scenario_2_SAC_Loan__r.Financing_Term_Months__c',
		'Scenario_3_SAC_Loan__r.Financing_Term_Months__c',
		'Scenario_4_SAC_Loan__r.Financing_Term_Months__c',
		'Scenario_1_Lease_Fund__r.Financing_Term_Months__c',
		'Scenario_2_Lease_Fund__r.Financing_Term_Months__c',
		'Scenario_3_Lease_Fund__r.Financing_Term_Months__c',
		'Scenario_4_Lease_Fund__r.Financing_Term_Months__c',
		'Scenario_1_Term_Loan__c',
		'Scenario_2_Term_Loan__c',
		'Scenario_3_Term_Loan__c',
		'Scenario_4_Term_Loan__c',
		'Scenario_1_SAC_Loan__c',
		'Scenario_2_SAC_Loan__c',
		'Scenario_3_SAC_Loan__c',
		'Scenario_4_SAC_Loan__c',
		'Scenario_1_Lease_Fund__c',
		'Scenario_2_Lease_Fund__c',
		'Scenario_3_Lease_Fund__c',
		'Scenario_4_Lease_Fund__c',
		'Scenario_1_Term_Loan__r.sighten_product_uuid__c',
		'Scenario_2_Term_Loan__r.sighten_product_uuid__c',
		'Scenario_3_Term_Loan__r.sighten_product_uuid__c',
		'Scenario_4_Term_Loan__r.sighten_product_uuid__c',
		'Scenario_1_SAC_Loan__r.sighten_product_uuid__c',
		'Scenario_2_SAC_Loan__r.sighten_product_uuid__c',
		'Scenario_3_SAC_Loan__r.sighten_product_uuid__c',
		'Scenario_4_SAC_Loan__r.sighten_product_uuid__c',
		'Scenario_1_Lease_Fund__r.sighten_product_uuid__c',
		'Scenario_2_Lease_Fund__r.sighten_product_uuid__c',
		'Scenario_3_Lease_Fund__r.sighten_product_uuid__c',
		'Scenario_4_Lease_Fund__r.sighten_product_uuid__c',
		'Sighten_System_uuid__c',
		'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Sighten_Utility_uuid__c',
		'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Sighten_Custom_Rate_Code_uuid__c',
		'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Sighten_NA_Territory_uuid__c',
		'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_Before_Solar__r.Sighten_Rate_Territory_uuid__c',
		'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_Before_Solar__r.Sighten_Rate_Schedule_uuid__c',
		'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Jan__c',
		'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Feb__c',
		'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Mar__c',
		'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Apr__c',
		'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_May__c',
		'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Jun__c',
		'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Jul__c',
		'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Aug__c',
		'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Sep__c',
		'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Oct__c',
		'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Nov__c',
		'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Dec__c'
	};

	private static List<String> propertyFields = new List<String>{
		'Id',
		'Name',
		'Property_City__c',
		'QAS_Property_County__c',
		'Property_County__c',
		'Latitude__c',
		'Longitude__c',
		'Property_State__c',
		'Property_Address_2__c',
		'Property_ZIP__c',
		'Sighten_Site_uuid__c'
	};

	private static List<String> contactFields = new List<String>{
		'Id',
		'Email',
		'Last_Name_Standard__c',
		'First_Name_Standard__c',
		'Phone',
		'Sighten_Contact_uuid__c'
	};

	private static List<String> arrayFields = new List<String>{
		'Id',
		'Original_Surface_Azimuth__c',
		'Array_Size_kW__c',
		'Original_Surface_Tilt__c',
		'Panel_Count__c',
		'Projected_Annual_Output_kWh_y__c'
	};

	private static List<String> itemFields = new List<String>{
		'Id',
		'RecordType.Name',
		'System_Design_Array__c',
		'System_Design_Product__r.Sighten_Equipment_uuid__c'
	};

	public static SightenAPIHelper.SightenAPIHelperResponse GetPricingFromSDQ(Id sdqId, Integer scenario, Boolean saveQuoteToSighten){
		if(scenario <= 0 || scenario >= 5){
			SightenAPIHelper.SightenAPIHelperResponse helperResponse = new SightenAPIHelper.SightenAPIHelperResponse();
			helperResponse.responseStatusCode = 400;
			helperResponse.responseBody = GetJsonErrorResponseBody(-99, 'INVALID_SCENARIO', 'Expected: [1,2,3,4]; Actual: ' + scenario, 'Parameter: Scenario');
			return helperResponse;
		}

		Map<Integer, Boolean> scenarios = new Map<Integer, Boolean>{1=>false,2=>false,3=>false,4=>false};
		scenarios.put(scenario, true);

		Map<Integer, SightenAPIHelper.SightenAPIHelperResponse> pricingMap = GetPricingFromSDQ(sdqId, scenarios, saveQuoteToSighten);
		if(pricingMap.keySet().contains(0)){
			return pricingMap.get(0);
		}
		return pricingMap.get(scenario);
	}

	public static Map<Integer, SightenAPIHelper.SightenAPIHelperResponse> GetPricingFromSDQ(Id sdqId, Map<Integer, Boolean> scenarios, Boolean saveQuoteToSighten){
		/*
		 * 1. Retrieve SDQ and related objects: Utility, Property, Contact, SD Arrays
		 * 2. Use the other Sightern classes to construct the json request
		 * 3. Retrieve the request from Sighten and process for errors or success
		 */

		/*
		 * 1. Retrieve SDQ and related objects: Property, Contact, SD Arrays
		 */
		System_Design_Quote__c sdq = Database.query('SELECT ' + String.join(sdqFields, ',') + ' FROM System_Design_Quote__c WHERE Id = :sdqId LIMIT 1');
		if(sdq == null){
			SightenAPIHelper.SightenAPIHelperResponse helperResponse = new SightenAPIHelper.SightenAPIHelperResponse();
			helperResponse.responseStatusCode = 400;
			helperResponse.responseBody = GetJsonErrorResponseBody(-99, 'INVALID_SDQ_ID', 'Received: ' + sdqId, 'Parameter: sdqId');
			return new Map<Integer, SightenAPIHelper.SightenAPIHelperResponse>{0=>helperResponse};
		}

		Id sdId = sdq.System_Design__c;
		Id propertyId = sdq.System_Design__r.Property__c;

		Contact signerContact = GetContractSignerContact(sdq.System_Design__r.Property__c, sdq.System_Design__r.Property__r.Property_Owner__c);
		if(signerContact == null){
			SightenAPIHelper.SightenAPIHelperResponse helperResponse = new SightenAPIHelper.SightenAPIHelperResponse();
			helperResponse.responseStatusCode = 400;
			helperResponse.responseBody = GetJsonErrorResponseBody(-99, 'INVALID_CONTACT', 'A valid contact with a role of "Contract Signer" was not found for the property.', 'propertyId = ' + propertyId);
			return new Map<Integer, SightenAPIHelper.SightenAPIHelperResponse>{0=>helperResponse};
		}
		Property__c property = Database.query('SELECT ' + String.join(propertyFields, ',') + ' FROM Property__c WHERE Id = :propertyId LIMIT 1');
		Map<Id, System_Design_Array__c> sdArrays = new Map<Id, System_Design_Array__c>((List<System_Design_Array__c>)Database.query('SELECT ' + String.join(arrayFields, ',') + ' FROM System_Design_Array__c WHERE System_Design__c = :sdId'));

		Set<Id> sdaIds = sdArrays.keySet();
		Map<Id, System_Design_Item__c> allSDItems = new Map<Id, System_Design_Item__c>((List<System_Design_Item__c>)Database.query('SELECT ' + String.join(itemFields, ',') + ' FROM System_Design_Item__c WHERE System_Design_Array__c IN :sdaIds'));
		Map<Id, System_Design_Item__c> inverters = ConstructInverterMap(sdArrays, allSDItems);
		Map<Id, System_Design_Item__c> modules = ConstructModuleMap(sdArrays, allSDItems);

		Map<Integer, SightenAPIHelper.SightenAPIHelperResponse> helperResponses = new Map<Integer, SightenAPIHelper.SightenAPIHelperResponse>();

		for(Integer scenario : scenarios.keySet()){
			if(scenarios.get(scenario)){
				/*
				 * 2. Use the other Sighten classes to construct the json request
				 */
			 	SightenAPIQuote apiQuote = null;
				try{
					apiQuote = ConstructAPIQuote(sdq, signerContact, property, sdArrays, inverters, modules, String.valueOf(scenario), saveQuoteToSighten);
				} catch (Exception ex){
					SightenAPIHelper.SightenAPIHelperResponse helperResponse = new SightenAPIHelper.SightenAPIHelperResponse();
					helperResponse.responseStatusCode = 400;
					helperResponse.responseBody = GetJsonErrorResponseBody(-99, 'INVALID_QUOTE_FIELDS', 'One or more invalid fields were found while creating the quote.', ex.getMessage());
					return new Map<Integer, SightenAPIHelper.SightenAPIHelperResponse>{scenario=>helperResponse};
				}

				/*
				 * 3. Retrieve the request from Sighten and process for errors or success
				 */
				SightenAPIHelper helper = new SightenAPIHelper();
				system.debug('**SZ: body = ' + apiQuote.buildRequestBody());
				SightenAPIHelper.SightenAPIHelperResponse helperResponse = helper.doPostRequest(apiQuote.buildRequestBody(), SightenAPIQuote.getApiName());
				System.debug('**SZ : helperResponse.responseStatusCode - '+ helperResponse.responseStatusCode);
				System.debug('**SZ : helperResponse.responseBody - '+ helperResponse.responseBody);
				if(saveQuoteToSighten){
					// update all objects with the uuid
					helperResponse.responseDetail = GetUpdateObjectUUID(sdqId, scenario, propertyId, signerContact, helper, helperResponse);
					if(helperResponse.responseDetail.detailStatusCode == 200){
						for(String key : helperResponse.responseDetail.uuidUpdates.keySet()){
							String field = '';
							if(key.contains('System_Design_Quote__c')){
								field = key.substringAfter('.');
								sdq.put(field, helperResponse.responseDetail.uuidUpdates.get(key));
							}
							if(key.contains('Property__c')){
								field = key.substringAfter('.');
								property.put(field, helperResponse.responseDetail.uuidUpdates.get(key));
							}
						}
					}
				}
				helperResponses.put(scenario, helperResponse);
			}
			scenario++;
		}

		return helperResponses;
	}

	private static Contact GetContractSignerContact(Id propertyId, Id ownerId){
		// Code is replicated based on SystemDesignQuoteConfigExtension.getSDQContactInfos2 method
        Account acc;

        try{
            acc = Database.query('SELECT Name, (SELECT ' + String.join(contactFields, ',') + ' FROM Contacts) FROM Account WHERE Id = :ownerId');
        }catch(QueryException qe){
            throw new SightenAPIHelper.SightenAPIException('No related Account found. Please create an Account and relate it to the Property record.');
        }

        Opportunity[] opps = [SELECT Id, (SELECT ContactId, IsPrimary, Role, OpportunityId FROM OpportunityContactRoles WHERE Role = 'Contract Signer') FROM Opportunity WHERE Property__c = :propertyId ORDER BY CreatedDate Desc LIMIT 1];
        if (opps == null || opps.isEmpty()){    //See CPQ-569
            throw new SightenAPIHelper.SightenAPIException('No related Opportunity found. Please create an Opportunity and relate it to the Property record.');
        }
        Opportunity op = opps[0];

        Map<Id,OpportunityContactRole> oppMap = new Map<Id,OpportunityContactRole>();

        for(OpportunityContactRole opConRole: op.OpportunityContactRoles){
            oppMap.put(opConRole.ContactId, opConRole);
        }

        //PB  Throw custom exception when there is no contact associated with quote.
		Contact signerContact = null;
        if(acc.contacts.isEmpty()){
            throw new SightenAPIHelper.SightenAPIException('There is no Contact associated with the Account of this System Design Quote. Please search for Contact record and edit the Account Name.');
        }
        for (Contact con: acc.contacts){
            if (oppMap.containsKey(con.Id) && oppMap.get(con.Id).IsPrimary == true){
            	signerContact = con;
            	break;
            }
        }

		return signerContact;
	}

	private static Map<Id, System_Design_Item__c> ConstructInverterMap(Map<Id, System_Design_Array__c> sdArrays, Map<Id, System_Design_Item__c> sdItems){
		Map<Id, System_Design_Item__c> results = new Map<Id, System_Design_Item__c>();
		for(Id sdArrayId : sdArrays.keySet()){
			System_Design_Item__c inverter = null;
			for(System_Design_Item__c sdItem : sdItems.values()){
				if(sdItem.System_Design_Array__c == sdArrayId && sdItem.RecordType.Name == 'Inverter'){
					inverter = sdItem;
					break;
				}
			}
			if(inverter != null){
				results.put(sdArrayId, inverter);
			}
		}
		return results;
	}

	private static Map<Id, System_Design_Item__c> ConstructModuleMap(Map<Id, System_Design_Array__c> sdArrays, Map<Id, System_Design_Item__c> sdItems){
		Map<Id, System_Design_Item__c> results = new Map<Id, System_Design_Item__c>();
		for(Id sdArrayId : sdArrays.keySet()){
			System_Design_Item__c module = null;
			for(System_Design_Item__c sdItem : sdItems.values()){
				if(sdItem.System_Design_Array__c == sdArrayId && sdItem.RecordType.Name == 'Panel'){
					module = sdItem;
					break;
				}
			}
			if(module != null){
				results.put(sdArrayId, module);
			}
		}
		return results;
	}

	private static SightenAPIQuote ConstructAPIQuote(System_Design_Quote__c sdq, Contact contact, Property__c property, Map<Id, System_Design_Array__c> sdArrays, Map<Id, System_Design_Item__c> inverters, Map<Id, System_Design_Item__c> modules, String scenario, Boolean save){
		SightenAPIQuote apiQuote = new SightenAPIQuote();
		List<String> invalidFields = new List<String>();

		Integer contractTerm = 0;
		String productUUID = '';
		Boolean refuseACH = true;
		try{
			if(scenario == '1'){
				refuseACH = sdq.Scenario_1_Refuse_ACH__c;
				if(sdq.Scenario_1_Term_Loan__c != null){
					contractTerm = Integer.valueOf(sdq.Scenario_1_Term_Loan__r.Financing_Term_Months__c / 12);
					productUUID = sdq.Scenario_1_Term_Loan__r.Sighten_Product_uuid__c;
				} else if(sdq.Scenario_1_SAC_Loan__c != null){
					contractTerm = Integer.valueOf(sdq.Scenario_1_SAC_Loan__r.Financing_Term_Months__c / 12);
					productUUID = sdq.Scenario_1_SAC_Loan__r.Sighten_Product_uuid__c;
				} else if(sdq.Scenario_1_Lease_Fund__c != null){
					contractTerm = Integer.valueOf(sdq.Scenario_1_Lease_Fund__r.Financing_Term_Months__c / 12);
					productUUID = sdq.Scenario_1_Lease_Fund__r.Sighten_Product_uuid__c;
				}
			} else if(scenario == '2'){
				refuseACH = sdq.Scenario_2_Refuse_ACH__c;
				if(sdq.Scenario_2_Term_Loan__c != null){
					contractTerm = Integer.valueOf(sdq.Scenario_2_Term_Loan__r.Financing_Term_Months__c / 12);
					productUUID = sdq.Scenario_2_Term_Loan__r.Sighten_Product_uuid__c;
				} else if(sdq.Scenario_2_SAC_Loan__c != null){
					contractTerm = Integer.valueOf(sdq.Scenario_2_SAC_Loan__r.Financing_Term_Months__c / 12);
					productUUID = sdq.Scenario_2_SAC_Loan__r.Sighten_Product_uuid__c;
				} else if(sdq.Scenario_2_Lease_Fund__c != null){
					contractTerm = Integer.valueOf(sdq.Scenario_2_Lease_Fund__r.Financing_Term_Months__c / 12);
					productUUID = sdq.Scenario_2_Lease_Fund__r.Sighten_Product_uuid__c;
				}
			} else if(scenario == '3'){
				refuseACH = sdq.Scenario_3_Refuse_ACH__c;
				if(sdq.Scenario_3_Term_Loan__c != null){
					contractTerm = Integer.valueOf(sdq.Scenario_3_Term_Loan__r.Financing_Term_Months__c / 12);
					productUUID = sdq.Scenario_3_Term_Loan__r.Sighten_Product_uuid__c;
				} else if(sdq.Scenario_3_SAC_Loan__c != null){
					contractTerm = Integer.valueOf(sdq.Scenario_3_SAC_Loan__r.Financing_Term_Months__c / 12);
					productUUID = sdq.Scenario_3_SAC_Loan__r.Sighten_Product_uuid__c;
				} else if(sdq.Scenario_3_Lease_Fund__c != null){
					contractTerm = Integer.valueOf(sdq.Scenario_3_Lease_Fund__r.Financing_Term_Months__c / 12);
					productUUID = sdq.Scenario_3_Lease_Fund__r.Sighten_Product_uuid__c;
				}
			} else if(scenario == '4'){
				refuseACH = sdq.Scenario_4_Refuse_ACH__c;
				if(sdq.Scenario_4_Term_Loan__c != null){
					contractTerm = Integer.valueOf(sdq.Scenario_4_Term_Loan__r.Financing_Term_Months__c / 12);
					productUUID = sdq.Scenario_4_Term_Loan__r.Sighten_Product_uuid__c;
				} else if(sdq.Scenario_4_SAC_Loan__c != null){
					contractTerm = Integer.valueOf(sdq.Scenario_4_SAC_Loan__r.Financing_Term_Months__c / 12);
					productUUID = sdq.Scenario_4_SAC_Loan__r.Sighten_Product_uuid__c;
				} else if(sdq.Scenario_4_Lease_Fund__c != null){
					contractTerm = Integer.valueOf(sdq.Scenario_4_Lease_Fund__r.Financing_Term_Months__c / 12);
					productUUID = sdq.Scenario_4_Lease_Fund__r.Sighten_Product_uuid__c;
				}
			}

			if(contractTerm == 0){
				invalidFields.add('lease fund contract term');
			}
			if(productUUID == ''){
				invalidFields.add('product uuid');
			}
		} catch (Exception ex){
			invalidFields.add('lease fund contract term');
			invalidFields.add('product uuid');
			throw new SightenAPIHelper.SightenAPIException('Error getting contract term and/or product uuid - ' + ex.getMessage() + invalidFields);
		}

		// install_cost_cash = 
		Decimal adjustedPrice = 0.000;
		Decimal installerPaidAmt = 0.000;
		if(String.isBlank(String.valueOf(sdq.get('Scenario_' + scenario + '_Adjusted_Price_NUM__c')))){ invalidFields.add('adjusted price NUM'); } else { adjustedPrice = (Decimal)sdq.get('Scenario_' + scenario + '_Adjusted_Price_NUM__c'); }
		if(String.isBlank(String.valueOf(sdq.get('Scenario_' + scenario + '_Installer_Paid_Incentive_Amt__c')))){ invalidFields.add('installer paid incentives'); } else { installerPaidAmt = (Decimal)sdq.get('Scenario_' + scenario + '_Installer_Paid_Incentive_Amt__c'); }
		Decimal purchasePrice = adjustedPrice - installerPaidAmt;
		apiQuote.request.addPostParameter('install_cost_cash', purchasePrice);
		// rate_esc_pct = 
		apiQuote.request.addPostParameter('rate_esc_pct', sdq.get('Scenario_' + scenario + '_Lease_Escalator__c'));
		// inipmt = 
		Decimal downPayment = 0;
		if(sdq.get('Scenario_' + scenario + '_Down_Payment__c') != null){
			downPayment = (Decimal)sdq.get('Scenario_' + scenario + '_Down_Payment__c');
		}
		Decimal srecDiscounts = 0;
		if(sdq.get('Scenario_' + scenario + '_SREC_Contract_Discount__c') != null){
			srecDiscounts = (Decimal)sdq.get('Scenario_' + scenario + '_SREC_Contract_Discount__c');
		}
		apiQuote.request.addPostParameter('inipmt', downPayment + srecDiscounts);
		// contract_term = 
		apiQuote.request.addPostParameter('contract_term', contractTerm);
		// product = 
		apiQuote.request.addPostParameter('product', productUUID); // '819cfc2a-e428-49f7-a898-0c026f425d51', Retrieve from Sighten or make into a custom setting
		// ach_elected
		apiQuote.request.addPostParameter('ach_elected', !refuseACH);

		// strict = 
		apiQuote.request.process_args.put('strict', false); // should always be true, once they work out issue on their side
		// save = param:save
		apiQuote.request.process_args.put('save', save);

		// save = param:evaluate_rules //Added by RJ: 02/22/16
		//apiQuote.request.process_args.put('evaluate_rules', true);

		// solve = 
		apiQuote.request.process_args.put('solve', true);
		// solve_field = 
		apiQuote.request.process_args.put('solve_field', 'rate_contract');

		apiQuote.request.response_args.put('expand', new List<String>{'system'});

		// if we have a system uuid, use it
		if(sdq.Sighten_System_uuid__c != null){
			apiQuote.request.addPostParameter('system', sdq.Sighten_System_uuid__c);
		} else {
			if(property.Sighten_Site_uuid__c != null){
				apiQuote.request.x_system.addPostParameter('site', property.Sighten_Site_uuid__c);
			} else {
				// Get the custom settings
				SightenAPISettings__c sightenSettings = SightenAPISettings__c.getOrgDefaults();

				// usage_kwh_1 = 
				if(String.isBlank(String.valueOf(sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Jan__c))){ invalidFields.add('jan consumption'); }
				if(String.isBlank(String.valueOf(sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Feb__c))){ invalidFields.add('feb consumption'); }
				if(String.isBlank(String.valueOf(sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Mar__c))){ invalidFields.add('mar consumption'); }
				if(String.isBlank(String.valueOf(sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Apr__c))){ invalidFields.add('apr consumption'); }
				if(String.isBlank(String.valueOf(sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_May__c))){ invalidFields.add('may consumption'); }
				if(String.isBlank(String.valueOf(sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Jun__c))){ invalidFields.add('jun consumption'); }
				if(String.isBlank(String.valueOf(sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Jul__c))){ invalidFields.add('jul consumption'); }
				if(String.isBlank(String.valueOf(sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Aug__c))){ invalidFields.add('aug consumption'); }
				if(String.isBlank(String.valueOf(sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Sep__c))){ invalidFields.add('sep consumption'); }
				if(String.isBlank(String.valueOf(sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Oct__c))){ invalidFields.add('oct consumption'); }
				if(String.isBlank(String.valueOf(sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Nov__c))){ invalidFields.add('nov consumption'); }
				if(String.isBlank(String.valueOf(sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Dec__c))){ invalidFields.add('dec consumption'); }
				apiQuote.request.x_system.x_site.usage_months.put('12', sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Dec__c);
				apiQuote.request.x_system.x_site.usage_months.put('11', sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Nov__c);
				apiQuote.request.x_system.x_site.usage_months.put('10', sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Oct__c);
				apiQuote.request.x_system.x_site.usage_months.put('9', sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Sep__c);
				apiQuote.request.x_system.x_site.usage_months.put('8', sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Aug__c);
				apiQuote.request.x_system.x_site.usage_months.put('7', sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Jul__c);
				apiQuote.request.x_system.x_site.usage_months.put('6', sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Jun__c);
				apiQuote.request.x_system.x_site.usage_months.put('5', sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_May__c);
				apiQuote.request.x_system.x_site.usage_months.put('4', sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Apr__c);
				apiQuote.request.x_system.x_site.usage_months.put('3', sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Mar__c);
				apiQuote.request.x_system.x_site.usage_months.put('2', sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Feb__c);
				apiQuote.request.x_system.x_site.usage_months.put('1', sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Jan__c);
				/*
				apiQuote.request.x_system.x_site.addPostParameter('usage_kwh_12', sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Dec__c);
				apiQuote.request.x_system.x_site.addPostParameter('usage_kwh_11', sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Nov__c);
				apiQuote.request.x_system.x_site.addPostParameter('usage_kwh_10', sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Oct__c);
				apiQuote.request.x_system.x_site.addPostParameter('usage_kwh_9', sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Sep__c);
				apiQuote.request.x_system.x_site.addPostParameter('usage_kwh_8', sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Aug__c);
				apiQuote.request.x_system.x_site.addPostParameter('usage_kwh_7', sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Jul__c);
				apiQuote.request.x_system.x_site.addPostParameter('usage_kwh_6', sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Jun__c);
				apiQuote.request.x_system.x_site.addPostParameter('usage_kwh_5', sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_May__c);
				apiQuote.request.x_system.x_site.addPostParameter('usage_kwh_4', sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Apr__c);
				apiQuote.request.x_system.x_site.addPostParameter('usage_kwh_3', sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Mar__c);
				apiQuote.request.x_system.x_site.addPostParameter('usage_kwh_2', sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Feb__c);
				apiQuote.request.x_system.x_site.addPostParameter('usage_kwh_1', sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Total_Forecasted_Consumption_kWh_Jan__c);
				*/

				// determine if we are using a custom rate code / need to use the global NA uuids
				apiQuote.request.x_system.x_site.addPostParameter('custom_rate', 0.12);
				// utility = 
				if(String.isBlank(String.valueOf(sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Sighten_Utility_uuid__c))){ invalidFields.add('utility'); }
				if(String.isBlank(String.valueOf(sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Sighten_Custom_Rate_Code_uuid__c))){ invalidFields.add('utility rate schedule'); }
				if(String.isBlank(String.valueOf(sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Sighten_NA_Territory_uuid__c))){ invalidFields.add('utility territory'); }
				apiQuote.request.x_system.x_site.addPostParameter('utility', sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Sighten_Utility_uuid__c); // 'b54db28f-4f90-4a0e-acd4-88d2c86cf9c9'
				apiQuote.request.x_system.x_site.addPostParameter('utility_rate_schedule', sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Sighten_Custom_Rate_Code_uuid__c);
				apiQuote.request.x_system.x_site.addPostParameter('utility_territory', sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Sighten_NA_Territory_uuid__c);

/*				// utility_rate_schedule = 
				if(String.isBlank(String.valueOf(sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_Before_Solar__r.Sighten_Rate_Schedule_uuid__c))
					&& String.isBlank(sightenSettings.Global_NA_Rate_Schedule_UUID__c)){ invalidFields.add('utility rate schedule'); }
				if(String.isBlank(String.valueOf(sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_Before_Solar__r.Sighten_Rate_Schedule_uuid__c))){
					apiQuote.request.x_system.x_site.addPostParameter('utility_rate_schedule', sightenSettings.Global_NA_Rate_Schedule_UUID__c); //'64356a54-b040-44f4-9788-f30c5ac9dd4a'
				} else {
					apiQuote.request.x_system.x_site.addPostParameter('utility_rate_schedule', sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_Before_Solar__r.Sighten_Rate_Schedule_uuid__c); //'64356a54-b040-44f4-9788-f30c5ac9dd4a'
				}
				// utility_territory = 
				apiQuote.request.x_system.x_site.addPostParameter('utility_territory', sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_Before_Solar__r.Sighten_Rate_Territory_uuid__c); // '451972d4-c71c-4664-bff9-7c4e2a6ca7d8'
				// utility = 
				if(String.isBlank(String.valueOf(sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Sighten_Utility_uuid__c))){ invalidFields.add('utility'); }
				apiQuote.request.x_system.x_site.addPostParameter('utility', sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Sighten_Utility_uuid__c); // 'b54db28f-4f90-4a0e-acd4-88d2c86cf9c9'
*/
				// x_address = Property__c
				apiQuote.request.x_system.x_site.x_address.addPostParameter('longitude', property.Longitude__c);
				apiQuote.request.x_system.x_site.x_address.addPostParameter('latitude', property.Latitude__c);
				if(String.isBlank(String.valueOf(property.Property_ZIP__c))){ invalidFields.add('property ZIP'); }
				apiQuote.request.x_system.x_site.x_address.addPostParameter('zipcode', property.Property_ZIP__c);
				if(String.isBlank(String.valueOf(property.Property_State__c))){ invalidFields.add('property state'); }
				apiQuote.request.x_system.x_site.x_address.addPostParameter('state_abbreviation', property.Property_State__c);
				if(String.isBlank(String.valueOf(property.QAS_Property_County__c)) && String.isBlank(String.valueOf(property.Property_County__c))){ invalidFields.add('property county'); }
				apiQuote.request.x_system.x_site.x_address.addPostParameter('county_name', (property.QAS_Property_County__c == null ? property.Property_County__c : property.QAS_Property_County__c));
				if(String.isBlank(String.valueOf(property.Property_City__c))){ invalidFields.add('property city'); }
				apiQuote.request.x_system.x_site.x_address.addPostParameter('city_name', property.Property_City__c);
				if(property.Property_Address_2__c != null){
					apiQuote.request.x_system.x_site.x_address.addPostParameter('address_line_2', property.Property_Address_2__c);
				}
				if(String.isBlank(String.valueOf(property.Name))){ invalidFields.add('property address 1'); }
				apiQuote.request.x_system.x_site.x_address.addPostParameter('address_line_1', property.Name);

				// x_contact = Contact
				SightenAPIContact.SightenAPIContactRequest x_contact = new SightenAPIContact.SightenAPIContactRequest();
				if(String.isBlank(String.valueOf(contact.Phone)) && String.isBlank(String.valueOf(sightenSettings.Testing_Contact_Phone__C))){ invalidFields.add('contact phone'); }
				x_contact.addPostParameter('phone_number', (String.isNotBlank(sightenSettings.Testing_Contact_Phone__C)) ? sightenSettings.Testing_Contact_Phone__c : contact.Phone);
				if(String.isBlank(String.valueOf(contact.Last_Name_Standard__c))){ invalidFields.add('contact last name'); }
				x_contact.addPostParameter('last_name', contact.Last_Name_Standard__c);
				if(String.isBlank(String.valueOf(contact.First_Name_Standard__c))){ invalidFields.add('contact first name'); }
				x_contact.addPostParameter('first_name', contact.First_Name_Standard__c);
				if(String.isBlank(String.valueOf(contact.Email)) && String.isBlank(String.valueOf(sightenSettings.Testing_Contact_Email__c))){ invalidFields.add('contact email'); }
				x_contact.addPostParameter('email', (String.isNotBlank(sightenSettings.Testing_Contact_Email__c)) ? sightenSettings.Testing_Contact_Email__c : contact.Email);
				apiQuote.request.x_system.x_site.x_contacts.add(x_contact);
			}

			for(System_Design_Array__c sdArray : sdArrays.values()){
				// x_array = System_Design_Array__c
				SightenAPIArray.SightenAPIArrayRequest x_array = new SightenAPIArray.SightenAPIArrayRequest();
				//x_array.addPostParameter('n_inverters', 12);
				//if(String.isBlank(String.valueOf(sdArray.Original_Surface_Azimuth__c))){ invalidFields.add('azimuth'); }
				x_array.addPostParameter('azimuth', sdArray.Original_Surface_Azimuth__c);
				//x_array.addPostParameter('generation', sdArray.Array_Size_kW__c);
				//x_array.addPostParameter('gen_ac_total', sdArray.Array_Size_kW__c * 1000);
				if(String.isBlank(String.valueOf(sdArray.Projected_Annual_Output_kWh_y__c))){ invalidFields.add('projected annual output kWh'); }
				x_array.addPostParameter('gen_ac_total', sdArray.Projected_Annual_Output_kWh_y__c);
				//if(String.isBlank(String.valueOf(sdArray.Original_Surface_Tilt__c))){ invalidFields.add('tilt'); }
				x_array.addPostParameter('tilt', sdArray.Original_Surface_Tilt__c);
				if(String.isBlank(String.valueOf(sdq.System_Design__r.Overall_Site_Quality__c))){ invalidFields.add('overall site quality'); }
				x_array.addPostParameter('productivity', sdq.System_Design__r.Overall_Site_Quality__c);
				if(String.isBlank(String.valueOf(sdArray.Panel_Count__c))){ invalidFields.add('panel count'); }
				x_array.addPostParameter('n_modules_series', sdArray.Panel_Count__c);
				x_array.addPostParameter('n_series_parallel', 1);
				//x_array.addPostParameter('capacity', 10);

				if(inverters.containsKey(sdArray.Id)){
					if(String.isBlank(String.valueOf(inverters.get(sdArray.Id).System_Design_Product__r.Sighten_Equipment_uuid__c))){ invalidFields.add('inverter uuid'); }
					x_array.inverter_model = inverters.get(sdArray.Id).System_Design_Product__r.Sighten_Equipment_uuid__c; // comes from system_design_item with record type of Inverter, '48d5c488-16e2-4b25-ac00-08c2bf0afb88';
				}
				if(modules.containsKey(sdArray.Id)){
					if(String.isBlank(String.valueOf(modules.get(sdArray.Id).System_Design_Product__r.Sighten_Equipment_uuid__c))){ invalidFields.add('panel uuid'); }
					x_array.module_model = modules.get(sdArray.Id).System_Design_Product__r.Sighten_Equipment_uuid__c; // comes from system_design_item with record type of Inverter, '48d5c488-16e2-4b25-ac00-08c2bf0afb88';
				}

				apiQuote.request.x_system.x_arrays.add(x_array);
			}
		}

		if(invalidFields.size() > 0){
			SightenAPIHelper.SightenAPIException sightenException = new SightenAPIHelper.SightenAPIException();
			sightenException.setMessage('<br/>Invalid Field(s): ' + String.join(invalidFields, ';'));
			system.debug('**SZ: Constructed Quote - ' + apiQuote.buildRequestBody());
			throw sightenException;
		}
		return apiQuote;
	}

	private static SightenAPIHelper.SightenAPIHelperResponseDetail GetUpdateObjectUUID(Id sdqId, Integer scenario, Id propertyId, Contact signerContact, SightenAPIHelper helper, SightenAPIHelper.SightenAPIHelperResponse quoteHelperResponse){
		SightenAPIHelper.SightenAPIHelperResponseDetail responseDetail = null;

		if(quoteHelperResponse.responseStatusCode == 200){
			SightenAPIQuote apiQuote = null;
			SightenAPISite apiSite = null;
			SightenAPIContact apiContact = null;
			SightenAPIContact.SightenAPIContactList apiContactList = null;

			try{
				// Retrieve and parse all necessary API objects
				apiQuote = (SightenAPIQuote)helper.parseResponseBody(quoteHelperResponse.responseBody, SightenAPIQuote.class);
			} catch (Exception ex){
				responseDetail = new SightenAPIHelper.SightenAPIHelperResponseDetail();
				responseDetail.detailStatusCode = -99;
				responseDetail.detailBody = GetJsonErrorResponseBody(ex, 901, SightenAPIHelper.PARSEQUOTE, 'Quote Parsing Error');
				return responseDetail;
			}

			if(apiQuote != null && apiQuote.data != null && apiQuote.data.x_system != null && String.isNotBlank(apiQuote.data.x_system.uuid) &&
				apiQuote.data.x_system.site != null && String.isNotBlank(apiQuote.data.x_system.site.uuid)){
				try{
					SightenAPIHelper.SightenAPIHelperResponse siteHelperResponse = helper.doGetRequest(apiQuote.data.x_system.site.uuid, SightenAPISite.getApiName());

					// Retrieve the site in order to get the url for the contacts
					if(siteHelperResponse.responseStatusCode == 200){
						apiSite = (SightenAPISite)helper.parseResponseBody(siteHelperResponse.responseBody, SightenAPISite.class);
					}
				} catch (Exception ex){
					responseDetail = new SightenAPIHelper.SightenAPIHelperResponseDetail();
					responseDetail.detailStatusCode = -99;
					responseDetail.detailBody = GetJsonErrorResponseBody(ex, 901, SightenAPIHelper.PARSESITE, 'Site Parsing Error');
					return responseDetail;
				}
			} else {
				String field = '';
				if(apiQuote == null) { field = 'quote_null'; }
				if(apiQuote.data == null) { field = 'quote.data_null'; }
				if(apiQuote.data.x_system == null) { field = 'quote.data.system_null'; }
				if(String.isBlank(apiQuote.data.x_system.uuid)) { field = 'quote.data.system.uuid_blank'; }
				if(apiQuote.data.x_system.site == null) { field = 'quote.data.system.site_null'; }
				if(String.isBlank(apiQuote.data.x_system.site.uuid)) { field = 'quote.data.system.site.uuid_blank'; }
				responseDetail = new SightenAPIHelper.SightenAPIHelperResponseDetail();
				responseDetail.detailStatusCode = -99;
				responseDetail.detailBody = GetJsonErrorResponseBody(902, SightenAPIHelper.RESOLVEFROMQUOTE, 'Resolve Quote Error: Could not resolve the system and/or site uuid from the quote.', field);
				return responseDetail;
			}

			String contactUuid = '';
			if(apiSite != null && apiSite.data != null && apiSite.data.contacts != null && String.isNotBlank(apiSite.data.contacts.link)){
				try{
					String contactQueryParam = apiSite.data.contacts.link.substring(apiSite.data.contacts.link.indexOf('?'));
					SightenAPIHelper.SightenAPIHelperResponse contactHelperResponse = helper.doGetRequest(contactQueryParam, SightenAPIContact.getApiName());

					if(contactHelperResponse.responseStatusCode == 200){
						try{
							apiContact = (SightenAPIContact)helper.parseResponseBody(contactHelperResponse.responseBody, SightenAPIContact.class);
							contactUuid = apiContact.data.uuid;
						} catch(Exception ex){
							apiContactList = (SightenAPIContact.SightenAPIContactList)helper.parseResponseBody(contactHelperResponse.responseBody, SightenAPIContact.SightenAPIContactList.class);
							for(SightenAPIContact.SightenAPIContactData dataEle : apiContactList.data){
								if(signerContact.FirstName.toLowerCase() == dataEle.first_name.toLowerCase()){
									contactUuid = dataEle.uuid;
								}
							}
						}
					}
				} catch (Exception ex){
					responseDetail = new SightenAPIHelper.SightenAPIHelperResponseDetail();
					responseDetail.detailStatusCode = -99;
					responseDetail.detailBody = GetJsonErrorResponseBody(ex, 901, SightenAPIHelper.PARSECONTACT, 'Contact Parsing Error');
					return responseDetail;
				}
			} else {
				String field = '';
				if(apiSite == null) { field = 'site_null'; }
				if(apiSite.data == null) { field = 'site.data_null'; }
				if(apiSite.data.contacts == null) { field = 'site.data.contacts_null'; }
				if(String.isBlank(apiSite.data.contacts.link)) { field = 'site.data.contacts.link_blank'; }
				responseDetail = new SightenAPIHelper.SightenAPIHelperResponseDetail();
				responseDetail.detailStatusCode = -99;
				responseDetail.detailBody = GetJsonErrorResponseBody(902, SightenAPIHelper.RESOLVEFROMSITE, 'Resolve Quote Error: Could not resolve the contacts link from the site.', field);
				return responseDetail;
			}

			responseDetail = new SightenAPIHelper.SightenAPIHelperResponseDetail();
			responseDetail.detailStatusCode = 200;
			responseDetail.detailBody = '{"message":"Objects successfully parsed for uuid updates."}';
			responseDetail.uuidUpdates.put('System_Design_Quote__c.Sighten_System_uuid__c', apiQuote.data.x_system.uuid);
			responseDetail.uuidUpdates.put('Proposal__c.Sighten_Scenario_' + String.valueOf(scenario) + '_Quote_uuid__c', apiQuote.data.uuid);
			responseDetail.uuidUpdates.put('Property__c.Sighten_Site_uuid__c', propertyId + '=' + apiSite.data.uuid);
			responseDetail.uuidUpdates.put('Contact.Sighten_Contact_uuid__c', signerContact.Id + '=' + contactUuid);
			system.debug('**SZ: uuidUpdates = ' + responseDetail.uuidUpdates);
		}

		return responseDetail;
	}


	/*
	 * SIGHTEN CREDIT API
	 */

	private static List<String> proposalCreditFields = new List<String>{
		'Id',
		'System_Design_Quote__c',
		'Sighten_Scenario_1_Quote_uuid__c',
		'Sighten_Scenario_2_Quote_uuid__c',
		'Sighten_Scenario_3_Quote_uuid__c',
		'Sighten_Scenario_4_Quote_uuid__c'
	};

	private static List<String> sdqCreditFields = new List<String>{
		'Id',
		'System_Design__r.Property__c'
	};

	private static List<String> propertyCreditFields = new List<String>{
		'Id',
		'Sighten_Site_uuid__c'
	};

	public static SightenAPIHelper.SightenAPIHelperResponse CheckCreditQualification(String sightenQualificationUUID){
		SightenAPIHelper helper = new SightenAPIHelper();
		return helper.doGetRequest(sightenQualificationUUID, SightenAPICredit.getApiName());
	}

	public static SightenAPIHelper.SightenAPIHelperResponse InitiateCreditCheck(Id proposalId, Integer scenario){
		Proposal__c proposal = Database.query('SELECT ' + String.join(proposalCreditFields, ',') + ' FROM Proposal__c WHERE Id = :proposalId LIMIT 1');
		if(proposal == null){
			return null;
		}

		Id sdqId = proposal.System_Design_Quote__c;
		System_Design_Quote__c sdq = Database.query('SELECT ' + String.join(sdqCreditFields, ',') + ' FROM System_Design_Quote__c WHERE Id = :sdqId LIMIT 1');
		if(sdq == null){
			return null;
		}

		Id propertyId = sdq.System_Design__r.Property__c;
		Property__c property = Database.query('SELECT ' + String.join(propertyCreditFields, ',') + ' FROM Property__c WHERE Id = :propertyId LIMIT 1');

		/*
		 * 2. Use the other Sightern classes to construct the json request
		 */
		SightenAPICreditCheck apiCreditCheck = ConstructAPICreditCheck(proposal, String.valueOf(scenario), property);

		/*
		 * 3. Retrieve the request from Sighten and process for errors or success
		 */
		SightenAPIHelper helper = new SightenAPIHelper();
		system.debug('**SZ: body = ' + apiCreditCheck.buildRequestBody());
		return helper.doPostRequest(apiCreditCheck.buildRequestBody(), SightenAPICreditCheck.getApiName());
	}

	private static SightenAPICreditCheck ConstructAPICreditCheck(Proposal__c proposal, String scenario, Property__c property){
		SightenAPICreditCheck apiCreditCheck = new SightenAPICreditCheck();

		String quoteUUID = '';
		if(scenario == '1'){
			quoteUUID = proposal.Sighten_Scenario_1_Quote_uuid__c;
		} else if(scenario == '2'){
			quoteUUID = proposal.Sighten_Scenario_2_Quote_uuid__c;			
		} else if(scenario == '3'){
			quoteUUID = proposal.Sighten_Scenario_3_Quote_uuid__c;
		} else if(scenario == '4'){
			quoteUUID = proposal.Sighten_Scenario_4_Quote_uuid__c;
		}

		// action = 
		apiCreditCheck.request.addPostParameter('action', 'initiate');
		// action_type =
		apiCreditCheck.request.addPostParameter('action_type', 'all');
		// quote_id = 
		apiCreditCheck.request.addPostParameter('quote_id', quoteUUID);
		// qualification_definition_id = 
		// 6d159695-99ed-46f0-be0f-c59845dde610 - Sunlight qualification definition id
		// 513bd16e-e439-4833-a669-8b87dcbe2086 - Sungage qualification definition id
		// ad85ba39-a6a5-40cd-8368-a6830902006a - Sungage credit qualification definition id
		apiCreditCheck.request.addPostParameter('qualification_definition_id', '6d159695-99ed-46f0-be0f-c59845dde610');
		// solarsite_id =
		apiCreditCheck.request.addPostParameter('solarsite_id', property.Sighten_Site_uuid__c);

		return apiCreditCheck;
	}

    public static Map<Integer, Sighten_Credit_Approval__c> GetSightenCreditApprovals(Id sdqId, Map<Integer, Boolean> scenarios){
    	Map<Integer, Sighten_Credit_Approval__c> returnMap = new Map<Integer, Sighten_Credit_Approval__c>();

    	List<String> fields = new List<String>{
	        'Scenario_1_Term_Loan__c',
	        'Scenario_1_SAC_Loan__c',
	        'Scenario_1_Lease_Fund__c',
	        'Scenario_2_Term_Loan__c',
	        'Scenario_2_SAC_Loan__c',
	        'Scenario_2_Lease_Fund__c',
	        'Scenario_3_Term_Loan__c',
	        'Scenario_3_SAC_Loan__c',
	        'Scenario_3_Lease_Fund__c',
	        'Scenario_4_Term_Loan__c',
	        'Scenario_4_SAC_Loan__c',
	        'Scenario_4_Lease_Fund__c',
	        'System_Design__r.Property__c',
			'System_Design__r.Property__r.Property_Owner__c'
    	};

    	Boolean areAnySighten = false;
    	for(Boolean b : scenarios.values()){
    		if(b){
    			areAnySighten = true;
    			break;
    		}
    	}

		if(areAnySighten){
	    	System_Design_Quote__c sdq = Database.query('SELECT ' + String.join(fields, ',') + ' FROM System_Design_Quote__c WHERE Id = :sdqId LIMIT 1');
	    	Contact contact = GetContractSignerContact(sdq.System_Design__r.Property__c, sdq.System_Design__r.Property__r.Property_Owner__c);
	    	String contactId = contact.Id;
	    	String propertyId = sdq.System_Design__r.Property__c;

	    	String whereClause = 'WHERE Property__c = :propertyId AND Contact__c = :contactId AND (';
	    	Boolean isFirst = true;
	    	for(Integer scenario : scenarios.keySet()){
	    		if(scenarios.get(scenario)){
			        String termLoan = (sdq.get('Scenario_' + scenario + '_Term_Loan__c') == null) ? '' : (String)sdq.get('Scenario_' + scenario + '_Term_Loan__c');
			        String sacLoan = (sdq.get('Scenario_' + scenario + '_SAC_Loan__c') == null) ? '' : (String)sdq.get('Scenario_' + scenario + '_SAC_Loan__c');
			        String leaseFund = (sdq.get('Scenario_' + scenario + '_Lease_Fund__c') == null) ? '' : (String)sdq.get('Scenario_' + scenario + '_Lease_Fund__c');

			        if(!isFirst){
			        	whereClause += ' OR ';
			        }
			        String loanOrLeaseFund = '';
			        if(String.isNotBlank(termLoan)){
			        	loanOrLeaseFund = termLoan;
			        } else if(String.isNotBlank(sacLoan)){
			        	loanOrLeaseFund = sacLoan;
			        } else if(String.isNotBlank(leaseFund)){
			        	loanOrLeaseFund = leaseFund;
			        }
		        	whereClause += 'Lease_Fund__c = :loanOrLeaseFund';

			        if(isFirst){
			        	isFirst = false;
			        }
	    		}
	    	}
	    	whereClause += ')';
system.debug('**SZ: whereClause = ' +  whereClause);
			List<Sighten_Credit_Approval__c> creditApprovals = Database.query('SELECT Sighten_Qualification_uuid__c, Contact__c, Lease_Fund__c, Property__c, Credit_Status__c FROM Sighten_Credit_Approval__c ' + whereClause);
	    	for(Sighten_Credit_Approval__c creditApproval : creditApprovals){
	    		for(Integer scenario : scenarios.keyset()){
		    		if(sdq.get('Scenario_' + scenario + '_Term_Loan__c') == creditApproval.Lease_Fund__c || sdq.get('Scenario_' + scenario + '_SAC_Loan__c') == creditApproval.Lease_Fund__c || sdq.get('Scenario_' + scenario + '_Lease_Fund__c') == creditApproval.Lease_Fund__c){
		    			returnMap.put(scenario, creditApproval);
		    			break;
		    		}
	    		}
	    	}
		}

    	return returnMap;
    }

    public static Map<String, Id> GetLookupIdsForSightenCreditApprovals(Id sdqId, Integer scenario){
    	List<String> fields = new List<String>{
	        'Scenario_1_Term_Loan__c',
	        'Scenario_1_SAC_Loan__c',
	        'Scenario_1_Lease_Fund__c',
	        'Scenario_2_Term_Loan__c',
	        'Scenario_2_SAC_Loan__c',
	        'Scenario_2_Lease_Fund__c',
	        'Scenario_3_Term_Loan__c',
	        'Scenario_3_SAC_Loan__c',
	        'Scenario_3_Lease_Fund__c',
	        'Scenario_4_Term_Loan__c',
	        'Scenario_4_SAC_Loan__c',
	        'Scenario_4_Lease_Fund__c',
	        'System_Design__r.Property__c',
			'System_Design__r.Property__r.Property_Owner__c'
    	};

    	Map<String, Id> returnMap = new Map<String, Id>();
    	System_Design_Quote__c sdq = Database.query('SELECT ' + String.join(fields, ',') + ' FROM System_Design_Quote__c WHERE Id = :sdqId LIMIT 1');

    	Contact contact = GetContractSignerContact(sdq.System_Design__r.Property__c, sdq.System_Design__r.Property__r.Property_Owner__c);
    	returnMap.put('Contact', contact.Id);

    	returnMap.put('Property__c', sdq.System_Design__r.Property__c);

        String termLoan = (sdq.get('Scenario_' + scenario + '_Term_Loan__c') == null) ? '' : (String)sdq.get('Scenario_' + scenario + '_Term_Loan__c');
        String sacLoan = (sdq.get('Scenario_' + scenario + '_SAC_Loan__c') == null) ? '' : (String)sdq.get('Scenario_' + scenario + '_SAC_Loan__c');
        String leaseFund = (sdq.get('Scenario_' + scenario + '_Lease_Fund__c') == null) ? '' : (String)sdq.get('Scenario_' + scenario + '_Lease_Fund__c');

        if(String.isNotBlank(termLoan)){
        	returnMap.put('Lease_Fund__c', termLoan);
        } else if(String.isNotBlank(sacLoan)){
        	returnMap.put('Lease_Fund__c', sacLoan);
        } else if(String.isNotBlank(leaseFund)){
        	returnMap.put('Lease_Fund__c', leaseFund);
        }
        return returnMap;
    }


	/*
	 * SIGHTEN CONTRACT API
	 */

	public static SightenAPIHelper.SightenAPIHelperResponse SendContract(String sightenQuoteId){
		SightenAPIContract apiContract = new SightenAPIContract();
		apiContract.request.quote_id = sightenQuoteId;

		SightenAPIHelper helper = new SightenAPIHelper();
		system.debug('**SZ: body = ' + apiContract.buildRequestBody());
		return helper.doPostRequest(apiContract.buildRequestBody(), SightenAPIContract.getApiName('send'));
	}

	public static SightenAPIHelper.SightenAPIHelperResponse DownloadContract(String sightenQuoteId){
		SightenAPIContract apiContract = new SightenAPIContract();
		apiContract.request.quote_id = sightenQuoteId;

		SightenAPIHelper helper = new SightenAPIHelper();
		return helper.doGetRequest('?quote_id=' + sightenQuoteId, SightenAPIContract.getApiName('download'), true);
	}


	/*
	 * JOINT METHODS
	 */

	private static String GetJsonErrorResponseBody(Integer status_code, String msg_code, String msg, String field){
		SightenAPIEntity.SightenAPIErrorResponse errorResponse = new SightenAPIEntity.SightenAPIErrorResponse();
		errorResponse.status_code = status_code;

		SightenAPIEntity.SightenAPIMessage message = new SightenAPIEntity.SightenAPIMessage();
		message.timestamp = String.valueOf(Datetime.now());
		message.msg_code = msg_code;
		message.message = msg + ' -|- ' + field;
		errorResponse.messages.error.add(message);

		return JSON.serialize(errorResponse);
	}

	private static String GetJsonErrorResponseBody(Exception ex, Integer status_code, String msg_code, String msg){
		SightenAPIEntity.SightenAPIErrorResponse errorResponse = new SightenAPIEntity.SightenAPIErrorResponse();
		errorResponse.status_code = status_code;

		SightenAPIEntity.SightenAPIMessage message = new SightenAPIEntity.SightenAPIMessage();
		message.timestamp = String.valueOf(Datetime.now());
		message.msg_code = msg_code;
		message.message = msg + ' -|- ' + ex.getMessage() + ' -|- ' + ex.getStackTraceString();
		errorResponse.messages.error.add(message);

		return JSON.serialize(errorResponse);
	}

    public static Boolean IsSightenScenario(Id sdqId, Integer scenario){
        // code until a solution that can utilize is in place
        //return false;

        List<String> fields = new List<String>();
        fields.add('Scenario_' + scenario + '_Term_Loan__r.Sighten_Product_uuid__c');
        fields.add('Scenario_' + scenario + '_SAC_Loan__r.Sighten_Product_uuid__c');
        fields.add('Scenario_' + scenario + '_Lease_Fund__r.Sighten_Product_uuid__c');

		System_Design_Quote__c sdq = Database.query('SELECT ' + String.join(fields, ',') + ' FROM System_Design_Quote__c WHERE Id = :sdqId LIMIT 1');

        // Actual code
        system.debug('**SZ: Is Sighten Scenario? ' + scenario);
        String termLoanProductUUID = (sdq.getSObject('Scenario_' + scenario + '_Term_Loan__r') == null) ? '' : (String)sdq.getSObject('Scenario_' + scenario + '_Term_Loan__r').get('Sighten_Product_uuid__c');
        system.debug('**SZ: Is Sighten Scenario? ' + termLoanProductUUID);
        String sacLoanProductUUID = (sdq.getSObject('Scenario_' + scenario + '_SAC_Loan__r') == null) ? '' : (String)sdq.getSObject('Scenario_' + scenario + '_SAC_Loan__r').get('Sighten_Product_uuid__c');
        system.debug('**SZ: Is Sighten Scenario? ' + sacLoanProductUUID);
        String leaseFundProductUUID = (sdq.getSObject('Scenario_' + scenario + '_Lease_Fund__r') == null) ? '' : (String)sdq.getSObject('Scenario_' + scenario + '_Lease_Fund__r').get('Sighten_Product_uuid__c');
        system.debug('**SZ: Is Sighten Scenario? ' + leaseFundProductUUID);

        return (String.isNotBlank(termLoanProductUUID) || String.isNotBlank(sacLoanProductUUID) || String.isNotBlank(leaseFundProductUUID));
    }

    public static Map<Integer, List<Object>> GetSightenScenariosAndPayments(Id sdqId){
    	return GetSightenScenariosAndPayments(sdqId, new List<Integer>{1,2,3,4});
    }

    public static Map<Integer, List<Object>> GetSightenScenariosAndPayments(Id sdqId, List<Integer> scenarios){
        List<String> fields = new List<String>{
	        'Scenario_1_Term_Loan__r.Sighten_Product_uuid__c',
	        'Scenario_1_SAC_Loan__r.Sighten_Product_uuid__c',
	        'Scenario_1_Lease_Fund__r.Sighten_Product_uuid__c',
	        'Scenario_1_First_Month_Payment__c',
	        'Scenario_2_Term_Loan__r.Sighten_Product_uuid__c',
	        'Scenario_2_SAC_Loan__r.Sighten_Product_uuid__c',
	        'Scenario_2_Lease_Fund__r.Sighten_Product_uuid__c',
	        'Scenario_2_First_Month_Payment__c',
	        'Scenario_3_Term_Loan__r.Sighten_Product_uuid__c',
	        'Scenario_3_SAC_Loan__r.Sighten_Product_uuid__c',
	        'Scenario_3_Lease_Fund__r.Sighten_Product_uuid__c',
	        'Scenario_3_First_Month_Payment__c',
	        'Scenario_4_Term_Loan__r.Sighten_Product_uuid__c',
	        'Scenario_4_SAC_Loan__r.Sighten_Product_uuid__c',
	        'Scenario_4_Lease_Fund__r.Sighten_Product_uuid__c',
	        'Scenario_4_First_Month_Payment__c'
        };

		System_Design_Quote__c sdq = Database.query('SELECT ' + String.join(fields, ',') + ' FROM System_Design_Quote__c WHERE Id = :sdqId LIMIT 1');

        Map<Integer, List<Object>> returnMap = new Map<Integer, List<Object>>();
        for(Integer scenario : scenarios){
        	List<Object> results = new List<Object>();

	        String termLoanProductUUID = (sdq.getSObject('Scenario_' + scenario + '_Term_Loan__r') == null) ? '' : (String)sdq.getSObject('Scenario_' + scenario + '_Term_Loan__r').get('Sighten_Product_uuid__c');
	        String sacLoanProductUUID = (sdq.getSObject('Scenario_' + scenario + '_SAC_Loan__r') == null) ? '' : (String)sdq.getSObject('Scenario_' + scenario + '_SAC_Loan__r').get('Sighten_Product_uuid__c');
	        String leaseFundProductUUID = (sdq.getSObject('Scenario_' + scenario + '_Lease_Fund__r') == null) ? '' : (String)sdq.getSObject('Scenario_' + scenario + '_Lease_Fund__r').get('Sighten_Product_uuid__c');
	        results.add(String.isNotBlank(termLoanProductUUID) || String.isNotBlank(sacLoanProductUUID) || String.isNotBlank(leaseFundProductUUID));

	        results.add(sdq.get('Scenario_' + scenario + '_First_Month_Payment__c'));

        	returnMap.put(scenario, results);
        }

        return returnMap;
    }
}

/*
 * Below is an example of a working Sighten API Quote call for reference
 */

/*
	public void testPostQuote(){
		SightenAPIHelper helper = new SightenAPIHelper();
		SightenAPIQuote apiQuote = new SightenAPIQuote();
		apiQuote.request.addPostParameter('install_cost_cash', 1.13);
		apiQuote.request.addPostParameter('rate_esc_pct', 0);
		//apiQuote.request.addPostParameter('inipmt', 1000);
		apiQuote.request.addPostParameter('contract_term', 20);
		apiQuote.request.addPostParameter('product', '819cfc2a-e428-49f7-a898-0c026f425d51');

		apiQuote.request.process_args.put('strict', false);
		apiQuote.request.process_args.put('save', true);
		apiQuote.request.process_args.put('solve', true);
		apiQuote.request.process_args.put('solve_field', 'rate_contract');

		apiQuote.request.x_system.x_site.addPostParameter('utility', 'b54db28f-4f90-4a0e-acd4-88d2c86cf9c9');
		apiQuote.request.x_system.x_site.addPostParameter('utility_territory', '451972d4-c71c-4664-bff9-7c4e2a6ca7d8');
		apiQuote.request.x_system.x_site.addPostParameter('utility_rate_schedule', '64356a54-b040-44f4-9788-f30c5ac9dd4a');
		apiQuote.request.x_system.x_site.addPostParameter('usage_kwh_1', 1000);
		apiQuote.request.x_system.x_site.x_address.addPostParameter('city_name', 'Los Angeles');
		apiQuote.request.x_system.x_site.x_address.addPostParameter('state_abbreviation', 'CA');
		apiQuote.request.x_system.x_site.x_address.addPostParameter('address_line_1', '1111 S Figueroa St');
		apiQuote.request.x_system.x_site.x_address.addPostParameter('zipcode', '90015');

		SightenAPIContact.SightenAPIContactRequest contact = new SightenAPIContact.SightenAPIContactRequest();
		contact.addPostParameter('email', 'steven.zilligen@directenergysolar.com');
		contact.addPostParameter('last_name', 'Zilligen');
		contact.addPostParameter('first_name', 'Steven');
		contact.addPostParameter('phone_number', '999-999-9999');
		apiQuote.request.x_system.x_site.x_contacts.add(contact);

		SightenAPIArray.SightenAPIArrayRequest x_array1 = new SightenAPIArray.SightenAPIArrayRequest();
		x_array1.addPostParameter('n_inverters', 12);
		//x_array1.addPostParameter('azimuth', 180);
		//x_array1.addPostParameter('tilt', 25);
		x_array1.addPostParameter('n_modules_series', 12);
		x_array1.addPostParameter('n_series_parallel', 1);
		x_array1.inverter_model = '48d5c488-16e2-4b25-ac00-08c2bf0afb88';
		x_array1.module_model = '9014ac21-e684-4f41-b6fe-30fff322f8a9';
		//x_array1.addPostParameter('gen_ac_total', 12000);
		//x_array1.addPostParameter('capacity', 10);

		apiQuote.request.x_system.x_arrays.add(x_array1);

		writeMessage(apiQuote.buildRequestBody());
		SightenAPIHelper.SightenAPIHelperResponse helperResponse = helper.doPostRequest(apiQuote.buildRequestBody(), SightenAPIQuote.getApiName());
		if(helperResponse.responseStatusCode == 200){
			apiQuote = (SightenAPIQuote)helper.parseResponseBody(helperResponse.responseBody, SightenAPIQuote.class);
			writeMessage('apiQuote = ' + apiQuote);
		} else {
			SightenAPIEntity.SightenAPIErrorResponse errorResponse = (SightenAPIEntity.SightenAPIErrorResponse)helper.parseResponseBody(helperResponse.responseBody, SightenAPIEntity.SightenAPIErrorResponse.class);
			writeMessage('errorResponse = ' + errorResponse);
		}
		writeMessage(helperResponse.responseBody);
	}
*/