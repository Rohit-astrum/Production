/* FILE: PropertySalesRegion.trigger
 * AUTHOR: Tino Mattheou
 * DATE: August 15, 2012
 * PURPOSE: set the sales region based on the county of the property
 * MODIFICATION HISTORY
 * RJ: Added Logic to Update Sales Region Lookup
 *
 */

trigger PropertySalesRegion on Property__c (before insert, before update) {
    
    //don't perform updates if bypass is on
    if (SalesRegionHelper.bypassSalesRegionTriggers) {
        return;
    }

    String query = 'SELECT Name, State_Abbreviation__c, Sales_Region__c FROM County__c WHERE Sales_Region__c <> NULL AND (';
    List<String> criteria = new List<String>();
    List<Property__c> propertiesToUpdate = new List<Property__c>();

    for (Property__c p : Trigger.new) {
        if (p.Property_State__c != null && (p.Property_State__c == 'DC' || p.Property_County__c != null || p.QAS_Property_County__c != null)
        && ( Trigger.isInsert
        || p.Sales_Region__c == null  
        || SalesRegionHelper.reprocessSalesRegions //force update to sales region
        || p.Property_County__c != Trigger.oldMap.get(p.Id).Property_County__c
        || p.QAS_Property_County__c != Trigger.oldMap.get(p.Id).QAS_Property_County__c
        || p.Property_State__c != Trigger.oldMap.get(p.Id).Property_State__c)) {
            propertiesToUpdate.add(p);
            String crit = '(State_Abbreviation__c = \'' + String.escapeSingleQuotes(p.Property_State__c) + '\'';
            if (p.Property_State__c != 'DC') {
                crit += ' AND Name LIKE \'' + String.escapeSingleQuotes(p.QAS_Property_County__c != null ? p.QAS_Property_County__c : SalesRegionHelper.removeState(p.Property_County__c)) + '%\'';
            }
            crit += ')';
            criteria.add(crit);
        }
    }
    
    if (!criteria.isEmpty()) {
    
        Boolean isFirst = true;
        for (String crit : criteria) {
            query += (isFirst ? '' : ' OR ') + crit; 
            isFirst = false;
        }
        query += ')';
        
        List<County__c> counties = Database.query(query);        
         
        for (County__c county : counties) {
            for (Property__c p : propertiesToUpdate) {
                if (p.Property_State__c.toUpperCase() == county.State_Abbreviation__c) {
                    if (county.State_Abbreviation__c == 'DC') {
                        p.Sales_Region__c = county.Sales_Region__c;
                    } else {
                        String countyName = p.QAS_Property_County__c != null ? p.QAS_Property_County__c : SalesRegionHelper.removeState(p.Property_County__c);
                        if (county.Name.toLowerCase().startsWith(countyName.toLowerCase())) {
                            p.Sales_Region__c = county.Sales_Region__c;
                        }
                    }
                }
            }
        }

    }
    // Update Sales Region Lookup
    Map<String, Astrum_Sales_Region__c> salesRegionMap = new Map<String, Astrum_Sales_Region__c>(); 
        for( Astrum_Sales_Region__c objCS : [Select z.Name, z.Id From  Astrum_Sales_Region__c z])
            salesRegionMap.put(objCS.Name, objCS);
    
    for (Property__c p : Trigger.new) {
        if ((Trigger.isInsert && p.Sales_Region__c != null) || (Trigger.isUpdate && p.Sales_Region__c != Trigger.oldMap.get(p.Id).Sales_Region__c ))
        {
           System.debug('** Sales Region '+ p.Sales_Region__c);
           Astrum_Sales_Region__c asr = salesRegionMap.get(p.Sales_Region__c);
           if(asr != null)
               p.Astrum_Sales_Region__c = asr.Id; 
        }           
    
    }
    
}