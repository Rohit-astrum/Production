/* FILE: LeadSalesRegion.trigger
 * AUTHOR: Tino Mattheou
 * DATE: August 14, 2012
 * PURPOSE: set the sales region based on the county of the lead
 * MODIFICATION HISTORY
 * SRS - Added Available_Field_Sales__c assignment
 */
 
trigger LeadSalesRegion on Lead (before insert, before update) {


/* 
     MK - 2014-03-20
     IMPORTANT: This logic is replicated in a few places.  All places are listed here so be sure to modify all logic for changes.
       LeadSalesRegionBatch.cls
       LeadSalesRegion.trigger
       LeadSalesRegion_AIAU.trigger
 */
 
    //don't perform updates if bypass is on	
	if (SalesRegionHelper.bypassSalesRegionTriggers || TriggerUtility.bypassLeadTriggersForBatchProcessing) { return; }

    List<String> criteria = new List<String>();
    List<Lead> leadsToUpdate = new List<Lead>();
    //Map<Id, Lead_Sales_Region__c> regionMap = new Map<Id, Lead_Sales_Region__c>(); 

    for (Lead l : Trigger.new) {
        if (l.IsConverted != true && l.State != null && (l.State == 'DC' || l.County__c != null || l.QAS_County__c != null)
        && (Trigger.isInsert
        || l.Sales_Region__c == null  
        || SalesRegionHelper.reprocessSalesRegions //force update to sales region
        || l.County__c != Trigger.oldMap.get(l.Id).County__c
        || l.QAS_County__c != Trigger.oldMap.get(l.Id).QAS_County__c
        || l.State != Trigger.oldMap.get(l.Id).State)) {
            leadsToUpdate.add(l);
            String crit = '(State_Abbreviation__c = \'' + String.escapeSingleQuotes(l.State) + '\'';
            if (l.State != 'DC') {
                crit += 'AND Name LIKE \'' + String.escapeSingleQuotes(l.QAS_County__c != null ? l.QAS_County__c : SalesRegionHelper.removeState(l.County__c)) + '%\'';
            }
            crit += ')';
            criteria.add(crit);
        }
    }
    
    if (criteria.isEmpty()) {
        return;
    }

    String query = 'SELECT Name, State_Abbreviation__c, Sales_Region__c, Available_Field_Sales__c FROM County__c WHERE Sales_Region__c <> NULL AND (';
    Boolean isFirst = true;
    for (String crit : criteria) {
        query += (isFirst ? '' : ' OR ') + crit; 
        isFirst = false;
    }
    query += ')';

    List<County__c> counties = Database.query(query);
    
    for (County__c county : counties) {
        for (Lead l : leadsToUpdate) {
            if (l.State.toUpperCase() == county.State_Abbreviation__c) {
                if (county.State_Abbreviation__c == 'DC') {
                    l.Sales_Region__c = county.Sales_Region__c;
                    //regionMap.put(l.Id, new Lead_Sales_Region__c(Sales_Region__c = county.Sales_Region__c, Lead_ID_Unique__c = l.Id, Lead_Created_Date__c = l.CreatedDate.date()));
                } else {
                    String countyName = l.QAS_County__c != null ? l.QAS_County__c : SalesRegionHelper.removeState(l.County__c);
                    if (county.Name.toLowerCase().startsWith(countyName.toLowerCase())) {
                        l.Sales_Region__c = county.Sales_Region__c;
                        l.Available_Field_Sales__c = county.Available_Field_Sales__c;
                        //regionMap.put(l.Id, new Lead_Sales_Region__c(Sales_Region__c = county.Sales_Region__c, Lead_ID_Unique__c = l.Id, Lead_Created_Date__c = l.CreatedDate.date()));
                    }
                }
            }
        }
    }
    
    //if (!regionMap.isEmpty()) {
    //  Database.upsert(regionMap.values(), Lead_Sales_Region__c.Lead_ID_Unique__c); 
    //}

}