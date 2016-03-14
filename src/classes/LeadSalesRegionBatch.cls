/* FILE: LeadSalesRegionBatch.cls
 * AUTHOR: Tino Mattheou
 * DATE: August 20, 2012
 * PURPOSE: Performs full update on all sales region objects
 * MODIFICATION HISTORY
 *         MK - 2013-03-20 - Added Available_Field_Sales__c field to the query and flag to disable all Lead triggers
 */

global class LeadSalesRegionBatch implements Database.Batchable<SObject>, Database.Stateful {
	
	global Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator('SELECT Id, County__c, Available_Field_Sales__c, State, QAS_County__c, Sales_Region__c, CreatedDate, IsConverted, ConvertedOpportunityId FROM Lead');
	}
	
	global void execute(Database.BatchableContext bc, List<SObject> scope) {
		
		if (scope[0] instanceof Lead) {
			updateLeads((List<Lead>)scope);
		}
		
	}
	
	global void finish(Database.BatchableContext bc) {
		
	}
	
	private void updateLeads(List<Lead> leads) {

/* 
     MK - 2014-03-20
     IMPORTANT: This logic is replicated in a few places.  All places are listed here so be sure to modify all logic for changes.
       LeadSalesRegionBatch.cls
       LeadSalesRegion.trigger
       LeadSalesRegion_AIAU.trigger
 */
		
		List<Lead> leadsToUpdate = new List<Lead>();
		Map<Id, Lead> opportunityLeadMap = new Map<Id, Lead>();
		Map<Id, Lead_Sales_Region__c> regionMap = new Map<Id, Lead_Sales_Region__c>(); 

		List<String> criteria = new List<String>();
		
		for (Lead l : leads) {
			if (l.State != null && (l.State == 'DC' || l.County__c != null || l.QAS_County__c != null)) {
				//only update non-converted leads
				if (l.IsConverted != true) {
					leadsToUpdate.add(l);
				}
				String crit = '(State_Abbreviation__c = \'' + String.escapeSingleQuotes(l.State) + '\'';
				if (l.State != 'DC') {
					crit += 'AND Name LIKE \'' + String.escapeSingleQuotes(l.QAS_County__c != null ? l.QAS_County__c : SalesRegionHelper.removeState(l.County__c)) + '%\'';
				}
				crit += ')';
				criteria.add(crit);
			} else if (l.IsConverted == true && l.ConvertedOpportunityId != null) { //look at opportunity property for sales region
				opportunityLeadMap.put(l.ConvertedOpportunityId, l);
			}
		}
		
		//update Lead_Sales_Region for converted leads
		if (!criteria.isEmpty()) {
			String query = 'SELECT Name, State_Abbreviation__c, Sales_Region__c, Available_Field_Sales__c FROM County__c WHERE Sales_Region__c <> NULL AND (';
			Boolean isFirst = true;
			for (String crit : criteria) {
				query += (isFirst ? '' : ' OR ') + crit; 
				isFirst = false;
			}
			query += ')';
	
			List<County__c> counties = Database.query(query);
	
			for (County__c county : counties) {
				for (Lead l : leads) {
					if (l.State != null && l.State.toUpperCase() == county.State_Abbreviation__c) {
						if (county.State_Abbreviation__c == 'DC') {
							l.Sales_Region__c = county.Sales_Region__c;
							regionMap.put(l.Id,
								new Lead_Sales_Region__c(
									Sales_Region__c = county.Sales_Region__c,
									Lead_ID_Unique__c = l.Id,
									Lead_Created_Date__c = l.CreatedDate.date()
								)
							);
						} else {
							String countyName = l.QAS_County__c != null ? l.QAS_County__c : SalesRegionHelper.removeState(l.County__c);
							if (countyName != null && county.Name.toLowerCase().startsWith(countyName.toLowerCase())) {
								l.Sales_Region__c = county.Sales_Region__c;
								l.Available_Field_Sales__c = county.Available_Field_Sales__c;//MK - 2014-03-20
								regionMap.put(l.Id, 
									new Lead_Sales_Region__c(
										Sales_Region__c = county.Sales_Region__c,
										Lead_ID_Unique__c = l.Id,
										Lead_Created_Date__c = l.CreatedDate.date()
									)
								);
							}
						}
					}
				}
			}
		}

		//find sales region from opportunity		
		if (!opportunityLeadMap.isEmpty()) {
			List<Opportunity> opps = 
				[SELECT Id, Property__r.Sales_Region__c
				FROM Opportunity
				WHERE Id IN :opportunityLeadMap.keySet()];
			for (Opportunity opp : opps) {
				if (opp.Property__r.Sales_Region__c != null) {
					Lead l = opportunityLeadMap.get(opp.Id);
					if (l != null) {
						regionMap.put(l.Id, 
							new Lead_Sales_Region__c (
								Lead_ID_Unique__c = l.Id,
								Lead_Created_Date__c = l.CreatedDate.date()
							)
						);
					}
				}
			}
		}
		
		// add empty lead sales region records for other leads
		for (Lead l : leads) {
			if (regionMap.get(l.Id) == null) {
				regionMap.put(l.Id, 
					new Lead_Sales_Region__c (
						Lead_ID_Unique__c = l.Id,
						Lead_Created_Date__c = l.CreatedDate.date()
					)
				);
			}
		}
			
		if (!leadsToUpdate.isEmpty()) {
			SalesRegionHelper.bypassSalesRegionTriggers = true;
			TriggerUtility.bypassLeadTriggersForBatchProcessing = true; //MK - 2014-03-20
			Database.update(leadsToUpdate);
		}
	
		if (!regionMap.isEmpty()) {		
			Database.upsert(regionMap.values(), Lead_Sales_Region__c.Lead_ID_Unique__c);
		}
		
	}

}