/* FILE: CommunityProgramOfferUtility.cls
 * AUTHOR: Mike Katulka
 * DATE: Aug 18, 2014
 * PURPOSE: Utility class called from triggers to help match a Community Program Offer to the source record.
 * MODIFICATION HISTORY: 
 *
 */
public class CommunityProgramOfferUtility {

	//Public variable which would first be populated from an SDQ update, then in the Opportunity trigger
	//we could reference this to save on querying for the same data
	public static List<Community_Program_Offer__c> CPOs;

	public static void matchCommunityProgramOffer(list<sObject> sourceRecs){
		system.debug('matchCommunityProgramOffer');
		schema.sObjectType sourceType = sourceRecs[0].getsObjectType();		
		
		system.debug('Get list of Community_Program_Offer__c');
		
		//CPOs could have been queried already through SDQ trigger and be needed for the Opp trigger later on
		if(CommunityProgramOfferUtility.CPOs == null){
			CommunityProgramOfferUtility.CPOs = [SELECT Start_Date__c, Eligibility_Criterion__c, Eligible_Values__c, 
														Extension_End_Date__c, Initial_End_Date__c
												FROM Community_Program_Offer__c
												ORDER BY Start_Date__c DESC
												LIMIT 10000]; //This object should never reach this number but just in case..
		}

		//Even if CPO's returns no records, go through the records to clear values as needed
		system.debug('CPO Size: ' + CommunityProgramOfferUtility.CPOs.size());
		system.debug('Find out which type of object this is.');
		
		//LEADS
		if(sourceType == Lead.sObjectType){
			system.debug('These are leads');
			
			List<Lead> leadListForUpdate = new List<Lead>();

			// Cast the sObject List to a Lead List....
			List<Lead> leadList = (List<Lead>)sourceRecs;
			for(Lead l : leadList){	
				if(l.isConverted) continue; //Skip if this lead has been converted
				system.debug('Lead being matched: ' + l.id);

				string county = (l.QAS_County__c != null ? l.QAS_County__c : SalesRegionHelper.removeState(l.County__c));
				Community_Program_Offer__c cpo = CommunityProgramOfferUtility.getCPO(county, l.State, l.City, l.PostalCode, l.Affiliate_Community_Program__c);
				if(cpo == null){
					//Need to clear the community program fields					
					l.Community_Program_Offer__c = null;
					l.Split_Community_Program_Credit__c = false;
				}else{					
					date startDate = l.CreatedDate == null ? date.today() : l.CreatedDate.date();
					list<string> vals = CommunityProgramOfferUtility.getNewCommFieldValues(startDate, date.today(), cpo, null);

					//Check to see if there is a community program for this record
					if(vals[0] == 'NULL') l.Community_Program_Offer__c = null;
					else l.Community_Program_Offer__c = vals[0];

					//Check if the cpo credit should be split
					if(vals[1] == 'TRUE') l.Split_Community_Program_Credit__c = true;
					else l.Split_Community_Program_Credit__c = false;

				}
				leadListForUpdate.add(l);
			}

			if(!leadListForUpdate.isEmpty() && !trigger.isExecuting) update leadListForUpdate;

		//OPPORTUNITIES
		}else if(sourceType == Opportunity.sObjectType){
			system.debug('These are Opps');

			List<Opportunity> oppList = (List<Opportunity>)sourceRecs;
			List<Opportunity> opportunityListForUpdate = new List<Opportunity>();
			Set<Id> propIds = new Set<Id>();
			for(Opportunity o : oppList){	
				propIds.add(o.Property__c);
			}

			Map<Id,Property__c> PropertyMap = new Map<Id,Property__c>([Select Id, Community_Program_Offer__c from Property__c Where Id in : PropIds]);

			
			// Cast the sObject List to an Opp List....
			
			for(Opportunity o : oppList){	
				//if(o.isClosed) continue; //Skip if this Opportunity has been closed
				system.debug('Opportunity being matched: ' + o.id);

				string county = (o.QAS_Property_County__c != null ? o.QAS_Property_County__c : SalesRegionHelper.removeState(o.Property_County__c));				
				Community_Program_Offer__c cpo = CommunityProgramOfferUtility.getCPO(county, o.Property_State__c, o.Property_City__c, o.Property_Zip__c, o.Affiliate_Community_Program__c);
				if(cpo == null){
					//Need to clear the community program fields					
					o.Community_Program_Offer__c = null;					
					o.Split_Community_Program_Credit__c = false;
					if(PropertyMap.get(o.Property__c) != null)
					{
						PropertyMap.get(o.Property__c).Community_Program_Offer__c = null;	
					}
				}else{					
					date startDate = o.CreatedDate == null ? date.today() : o.CreatedDate.date();
					list<string> vals = CommunityProgramOfferUtility.getNewCommFieldValues(startDate, o.closeDate, cpo, o);

					//Check to see if there is a community program for this record
					if(vals[0] == 'NULL') 
					{
						o.Community_Program_Offer__c = null;
						if(PropertyMap.get(o.Property__c) != null)
						{
							PropertyMap.get(o.Property__c).Community_Program_Offer__c = null;	
						}
					}
					else {
						o.Community_Program_Offer__c = vals[0];
						if(PropertyMap.get(o.Property__c) != null)
						{
							PropertyMap.get(o.Property__c).Community_Program_Offer__c = vals[0];
						}
					}

					//Check if the cpo credit should be split
					if(vals[1] == 'TRUE') o.Split_Community_Program_Credit__c = true;
					else o.Split_Community_Program_Credit__c = false;
				}
				opportunityListForUpdate.add(o);
			}

			if(!opportunityListForUpdate.isEmpty() && !trigger.isExecuting) update opportunityListForUpdate;
			if(!PropertyMap.isEmpty() && !trigger.isExecuting) update PropertyMap.Values();

		//SYSTEM DESIGN QUOTE
		}else if(sourceType == System_Design_Quote__c.sObjectType){
			system.debug('These are SDQs');

			List<System_Design_Quote__c> sdqListForUpdate = new List<System_Design_Quote__c>();
			
			// Cast the sObject List to an SDQ List....
			List<System_Design_Quote__c> sdqList = (List<System_Design_Quote__c>)sourceRecs;
			for(System_Design_Quote__c sdq : sdqList){	
				if(sdq.Pricing_Locked__c) continue; //Skip if pricing is locked
				system.debug('System_Design_Quote__c being matched: ' + sdq.id);

				string county = (sdq.QAS_Property_County__c != null ? sdq.QAS_Property_County__c : SalesRegionHelper.removeState(sdq.Property_County__c));				
				Community_Program_Offer__c cpo = CommunityProgramOfferUtility.getCPO(county, sdq.Property_State__c, sdq.Property_City__c, sdq.Property_Zip__c, sdq.Affiliate_Community_Program__c);
				if(cpo == null){
					//Need to clear the community program fields					
					sdq.Community_Program_Offer__c = null;					
				}else{
					Date pricingDate = Date.today();    //sdq.CreatedDate == null ? date.today() : sdq.CreatedDate.date();
			        if (sdq.Pricing_Date__c != null)
			            pricingDate = Date.newInstance(sdq.Pricing_Date__c.year(), sdq.Pricing_Date__c.month(), sdq.Pricing_Date__c.day());	//CPQ-717

					list<string> vals = CommunityProgramOfferUtility.getNewCommFieldValues(pricingDate, pricingDate, cpo, null);

					//Check to see if there is a community program for this record
					if(vals[0] == 'NULL') sdq.Community_Program_Offer__c = null;
					else sdq.Community_Program_Offer__c = vals[0];

					//SDQ does not have split checkbox field, ignore vals[1]					
				}
				sdqListForUpdate.add(sdq);
			}

			if(!sdqListForUpdate.isEmpty() && !trigger.isExecuting) update sdqListForUpdate;
		}

	}


	public static List<String> getNewCommFieldValues(date startDate, date endDate, Community_Program_Offer__c cpo, Opportunity opp){
		system.debug('getNewCommFieldValues');
		system.debug('startDate of source record: ' + startDate);
		system.debug('endDate of source record: ' + endDate);
		system.debug('Start_Date__c of cpo record: ' + cpo.Start_Date__c);
		system.debug('Extension_End_Date__c of cpo record: ' + cpo.Extension_End_Date__c);
		system.debug('Initial_End_Date__c of cpo record: ' + cpo.Initial_End_Date__c);

		//startDate usually represents the created date of the record
		//endDate usually represents today() or the opp closed date

		//default values if nothing below matches
		boolean splitComm = false;
		id cpoId;

		//1. If the Record StartDate is before the CommStartDate AND
		if(startDate < cpo.Start_Date__c){
			//The Record EndDate is before the CommStartDate AND
			if(endDate < cpo.Start_Date__c){				
				//This is not an Opp
				if(opp == null){
					system.debug('outcome 1');
					//Community Program fields should be blank
					cpoId = null;
					//Split Community Program Credit fields = FALSE
					splitComm = false;
				//This is an Opp
				}else{
					system.debug('Opp ID: ' + opp.id);
					system.debug('Opp Stage: ' + opp.stagename);
					system.debug('Opp isClosed: ' + opp.isclosed);					
					//Stage = Closed - Won or Closed - Lost	
					if(opp.isClosed){
						system.debug('outcome 2');
						//Community Program fields should be blank
						cpoId = null;
						//Split Community Program Credit fields = FALSE
						splitComm = false;
					//Stage <> Closed - Won or Closed - Lost
					}else{
						system.debug('outcome 3');
						//Community Program fields should be blank
						cpoId = cpo.id;
						//Split Community Program Credit fields = FALSE
						splitComm = true;
					}
				}				
			}

			//The Record EndDate is after the CommStartDate and before the Extension End Date
			else if(endDate > cpo.Start_Date__c && (cpo.Extension_End_Date__c == null || endDate < cpo.Extension_End_Date__c)){
				//This is not an Opp
				if(opp == null){
					system.debug('outcome 4');
					//Community Program fields should be populated
					cpoId = cpo.id;
					//Split Community Program Credit fields = TRUE
					splitComm = true;
				//This is an Opp
				}else{
					system.debug('Opp ID: ' + opp.id);
					system.debug('Opp Stage: ' + opp.stagename);
					system.debug('Opp isClosed: ' + opp.isclosed);
					//Stage = Closed - Won or Closed - Lost	
					if(opp.isClosed){
						system.debug('outcome 5');
						//Community Program fields should be populated
						cpoId = cpo.id;
						//Split Community Program Credit fields = TRUE
						splitComm = true;
					//Stage <> Closed - Won or Closed - Lost
					}else{
						system.debug('outcome 6');
						//Community Program fields should be populated
						cpoId = cpo.id;
						//Split Community Program Credit fields = TRUE
						splitComm = true;
					}
				}				
			}

			//The Record Enddate is after the CPOExtensionEndDate
			else if(cpo.Extension_End_Date__c != null && endDate > cpo.Extension_End_Date__c){
				system.debug('outcome 7');
				//Community Program fields should be blank
				cpoId = null;
				//Split Community Program Credit fields = FALSE
				splitComm = false;
			}
		}
		//2. OR If the Opportunity Created Date is between Start Date and Extension End Date AND
		else if(startDate >= cpo.Start_Date__c && (cpo.Extension_End_Date__c == null || startDate < cpo.Extension_End_Date__c)){
			//The Record EndDate is before the CPOExtensionEndDate
			if(cpo.Extension_End_Date__c == null || endDate < cpo.Extension_End_Date__c){
				system.debug('outcome 8');
				//Community Program fields should be blank
				cpoId = cpo.id;
				//Split Community Program Credit fields = FALSE
				splitComm = false;
			}
			
			//The Record Enddate is after the CPOExtensionEndDate
			else if(cpo.Extension_End_Date__c != null && endDate > cpo.Extension_End_Date__c){
				system.debug('outcome 9');
				//Community Program fields should be blank
				cpoId = cpo.id;
				//Split Community Program Credit fields = FALSE
				splitComm = true;
			}
		}

		
		//Extra checking for special circumstances... separate if statements

		//3. If the Record StartDate is after the CPOInitialEndDate AND		
		if(cpo.Initial_End_Date__c != null && startDate > cpo.Initial_End_Date__c){
			//The Record EndDate is before the CPOExtensionEndDate
			if(cpo.Extension_End_Date__c == null || endDate < cpo.Extension_End_Date__c){
				system.debug('extra outcome 1');
				//Community Program fields should be blank
				cpoId = cpo.id;
				//Split Community Program Credit fields = FALSE
				splitComm = false;
			}
			//The Record Enddate is after the CPOExtensionEndDate
			else if(cpo.Extension_End_Date__c != null && endDate > cpo.Extension_End_Date__c){
				system.debug('extra outcome 2');
				//Community Program fields should be blank
				cpoId = null;
				//Split Community Program Credit fields = FALSE
				splitComm = false;
			}
		}


		//4. If the Record StartDate is after the CPOExtensionEndDate AND
		if(cpo.Extension_End_Date__c != null && startDate > cpo.Extension_End_Date__c
					//The Record Enddate is after the CPOExtensionEndDate
					&& endDate > cpo.Extension_End_Date__c){

			system.debug('extra outcome 3');
			//Community Program fields should be blank
			cpoId = null;
			//Split Community Program Credit fields = FALSE
			splitComm = false;
			
		}

		//Construct the return variables into a list of strings
		list<string> retVal = new list<string>();
		retVal.add(cpoId == null ? 'NULL' : cpoId);
		retVal.add(splitComm ? 'TRUE' : 'FALSE');
		return retVal;
	}

	public static Community_Program_Offer__c getCPO(string county, string state, string city, string zip, String affiliateProgram){
		system.debug('getCPO');
		string cityState;
		string countyState;


		//Validate that data pulled from the record is good.
		if(county == null) system.debug('***Missing County on this record');
		if(city == null) system.debug('***Missing City on this record');
		if(state == null) system.debug('***Missing State on this record');
		if(zip == null) system.debug('***Missing Zip on this record');
		else{
			zip = zip.length() > 5 ? zip.substring(0,5) : zip;
		}
		
		//build the search strings
		if(city != null && state != null){
			cityState = city.trim().tolowercase() + ', ' + state.trim().tolowercase();
		}
		
		if(county != null && state != null){
			countyState = county.trim().tolowercase() + ', ' + state.trim().tolowercase();
		}


		system.debug('CityState: ' + cityState);
		system.debug('countyState: ' + countyState);
		system.debug('Zip: ' + zip);	
		system.debug('affiliateProgram: ' + affiliateProgram);		

		Community_Program_Offer__c cpo;

		for(Community_Program_Offer__c c : CommunityProgramOfferUtility.CPOs){			
			
			system.debug('CPO: ' + c.id);
			system.debug('Eligibility_Criterion__c: ' + c.Eligibility_Criterion__c);
			system.debug('Eligible_Values__c: ' + c.Eligible_Values__c);
			if(c.Eligibility_Criterion__c == null || c.Eligible_Values__c == null){
				system.debug('***ERROR, skip: This CPO is missing the Eligibility_Criterion__c and/or Eligible_Values__c values.');
				continue; //next record
			}


			//Split the semi-colon space delimited text into a searchable set
			//Split returns a list, that we can put in the constructor of the set
			//Split into set insead of string.contains search because these can get mixed up: "west goshen, pa"... where searching for "goshen, pa" 
					//will return true using string.contains
			set<string> valSet = new set<string>(c.Eligible_Values__c.tolowercase().replace('; ', ';').replace(' ;', ';').split(';'));
			//CITY
			if(c.Eligibility_Criterion__c == 'City'){
				if(cityState == null){					
					continue; //next record
				}
				if(valSet.contains(cityState)){
					//We have a match!
					system.debug('Found the first matching record! - ' + c.id);
					cpo = c;
					break;
				}
			}
			//COUNTY
			else if(c.Eligibility_Criterion__c == 'County'){
				if(countyState == null){					
					continue; //next record
				}
				if(valSet.contains(countyState)){
					//We have a match!
					system.debug('Found the first matching record! - ' + c.id);
					cpo = c;
					break;
				}
			}
			//ZIP
			else if(c.Eligibility_Criterion__c == 'Zip'){
				if(zip == null){					
					continue; //next record
				}
				if(valSet.contains(zip)){
					//We have a match!
					system.debug('Found the first matching record! - ' + c.id);
					cpo = c;
					break;
				}
			}

			else if(c.Eligibility_Criterion__c == 'Affiliate Program'){
				if(affiliateProgram == null){					
					continue; //next record
				}
				if(valSet.contains(affiliateProgram.tolowercase())){
					//We have a match!
					system.debug('Found the first matching record! - ' + c.id);
					cpo = c;
					break;
				}
			}
		}

		return cpo;
	}
}