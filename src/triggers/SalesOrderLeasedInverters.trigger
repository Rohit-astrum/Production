/* FILE: SalesOrderLeasedInverters.trigger
 * AUTHOR: Tino Mattheou
 * DATE: March, 16, 2012
 * PURPOSE: Calculates Constellation Leased Inverters when sales order is created or changed.
 * MODIFICATION HISTORY: 
 * 08/08/2012 TCM - Change 6% FMV to 5.25% zen-45
 * 09/14/2012 SRS - Change 5.25% to 5.10%
 */
 
trigger SalesOrderLeasedInverters on SCRB_SalesOrder__c (before insert, before update) {

    List<SCRB_SalesOrder__c> salesOrdersToUpdate = new List<SCRB_SalesOrder__c>();
    Set<Id> systemDesignQuoteIds = new Set<Id>();
    
    //gather master ids
    for(SCRB_SalesOrder__c so: Trigger.new) {
        if (so.System_Design_Quote__c != null && so.Financing_Type__c == 'Lease' 
        && so.System_Size_kW__c != null && so.System_Size_kW__c > 0) {
            if (Trigger.isInsert 
            || (Trigger.isUpdate && //if one of these fields changes, the # of leased inverters changes 
                (Trigger.oldMap.get(so.Id).System_Design_Quote__c != so.System_Design_Quote__c
                || Trigger.oldMap.get(so.Id).CEG_FMV_per_Watt_W__c != so.CEG_FMV_per_Watt_W__c
                || Trigger.oldMap.get(so.Id).System_Size_kW__c != so.System_Size_kW__c || so.Potential_Lease_Inverters__c==null))) {
                    salesOrdersToUpdate.add(so);
                    systemDesignQuoteIds.add(so.System_Design_Quote__c);
            }
        }
    }
    
    //done if no changes
    if (salesOrdersToUpdate.isEmpty()) {
        return;
    }
    
    //find the system designs related to the sales orders
    Map<Id, System_Design_Quote__c> systemDesignQuoteMap = new Map<Id, System_Design_Quote__c>( 
        [SELECT Id, System_Design__c
        FROM System_Design_Quote__c
        WHERE ID IN :systemDesignQuoteIds]);
    
    //map system design ids to sales orders
    Set<Id> systemDesignsImpacted = new Set<Id>();  
    Map<Id,List<SCRB_SalesOrder__c>> designOrderMap = new Map<Id, List<SCRB_SalesOrder__c>>();
    for (SCRB_SalesOrder__c so : salesOrdersToUpdate) {
        System_Design_Quote__c quote = systemDesignQuoteMap.get(so.System_Design_Quote__c);
        if (quote == null) { continue; }
        Id systemDesignId = quote.System_Design__c;
        systemDesignsImpacted.add(systemDesignId);
        List<SCRB_SalesOrder__c> orders = designOrderMap.get(systemDesignId);
        if (orders == null) {
            orders = new List<SCRB_SalesOrder__c>();
            designOrderMap.put(systemDesignId, orders);
        }
        orders.add(so);
    }

    //done if no quotes found
    if (systemDesignsImpacted.isEmpty()) {
        return;
    }
    
    AggregateResult[] results = 
        [SELECT System_Design_Array__r.System_Design__c sdid, System_Design_Product__r.Micro_Inverter__c inv, SUM(Quantity__c) qty
        FROM System_Design_Item__c
        WHERE System_Design_Array__r.System_Design__c IN :systemDesignsImpacted
        AND System_Design_Product__r.Micro_Inverter__c <> NULL
        GROUP BY System_Design_Array__r.System_Design__c, System_Design_Product__r.Micro_Inverter__c
        HAVING SUM(Quantity__c) > 0];
    
    Id lastSystemDesignId = null;
    Decimal m215Cost = 0;
    Decimal m210Cost = 0;
    Decimal m190Cost = 0;
    Decimal m250Cost = 0;
    Decimal inverterCount = 0;
  
    for (AggregateResult ar : results) {
        Id systemDesignId = (Id)ar.get('sdid');
        if (systemDesignId != lastSystemDesignId) {
            if (inverterCount > 0) {
                updateQuotes(designOrderMap.get(lastSystemDesignId));
                inverterCount = m215Cost = m210Cost = m190Cost = m250Cost = 0;
            }
            lastSystemDesignId = systemDesignId;
        }
        Decimal qty = (Decimal)ar.get('qty');
        String inv = (String)ar.get('inv');

        inverterCount += qty;
        //percentage required varies by inverter type
        if (inv.equalsIgnoreCase('M215')) {
            m215Cost += 126.10 * qty;
        } else if (inv.equalsIgnoreCase('M210')) {
            m210Cost += 141.62 * qty;
        } else if (inv.equalsIgnoreCase('M190')) {
            m190Cost += 130.95 * qty;
        }
        else if (inv.equalsIgnoreCase('M250')) {
            m250Cost += 116.334426 * qty;
        }
    }
    //check for last one
    if (inverterCount > 0) {
        updateQuotes(designOrderMap.get(lastSystemDesignId));
    }
    
    private static Id updateQuotes(List<SCRB_SalesOrder__c> orders) {
        
        for (SCRB_SalesOrder__c so : orders) {

            Decimal totalInverterCost = m215Cost + m210Cost + m190Cost + m250Cost;
            Decimal avgInverterCost = totalInverterCost / inverterCount;
            Decimal fairMktValuePerW = so.CEG_FMV_per_Watt_W__c;
            if (fairMktValuePerW == null) {
                fairMktValuePerW = 7; //default to 7 if no value
            }
            
            Decimal sixPercentFairMarket = fairMktValuePerW * 0.0510 * so.System_Size_kW__c * 1000;
            
            Integer m215Count = Math.ceil((m215Cost / totalInverterCost) * (sixPercentFairMarket / avgInverterCost)).intValue();  
            Integer m210Count = Math.ceil((m210Cost / totalInverterCost) * (sixPercentFairMarket / avgInverterCost)).intValue();  
            Integer m190Count = Math.ceil((m190Cost / totalInverterCost) * (sixPercentFairMarket / avgInverterCost)).intValue(); 
            Integer m250Count = Math.ceil((m250Cost / totalInverterCost) * (sixPercentFairMarket / avgInverterCost)).intValue();  
            
            String leaseInverters = '';
            
            if (m215Count > 0) {
                leaseInverters += m215Count + ' M215, ';
            }
            if (m210Count > 0) {
                leaseInverters += m210Count + ' M210, ';
            }
            if (m190Count > 0) {
                leaseInverters += m190Count + ' M190, ';
            }
             if (m250Count > 0) {
                leaseInverters += m250Count + ' M250, ';
            }
            
            if (leaseInverters == '') {
                leaseInverters = '0';
            } else {
                leaseInverters = leaseInverters.substring(0, leaseInverters.length() - 2);
            }
            
            so.Potential_Lease_Inverters__c = leaseInverters;
        }
        
        return null;
            
    }

}