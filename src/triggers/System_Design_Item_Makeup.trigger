//TCM 03/02/2012 - Constellation Lease Inverters - update System Design Potential Lease Inverters
//TCM 03/06/2012 - Constellation Lease Inverters - new calculation, bulk update issues
//TCM 06/15/2012 - Don't do anything if this is an update from the Project trigger
//TCM 08/08/2012 - Change 6% FMV to 5.25% zen-45
//SRS 09/14/2012 - Change 5.25% to 5.10%
//RJ 03/21/2014 - Logic for Invalid SQ
//RJ 02/09/15 Updated Logic for Invalid SQ
trigger System_Design_Item_Makeup on System_Design_Item__c (after insert, after update) {

    //property trigger isn't changing item makeup
    if (PropertyTriggerHelper.propertyTriggerFiring == true) {
        return;
    }

    Set<Id> systemDesignIds = new Set<Id>();    
    Map<Id,System_Design__c> sdMapToUpdate = new Map<Id,System_Design__c>();

    Set<Id> changedSDIds = new Set<Id>();
   
    Set<Id> changedTiltSDIds = new Set<Id>();
    Set<Id> changedAzimuthSDIds = new Set<Id>();
    Set<Id> changedShadingSDIds = new Set<Id>();
    Set<Id> changedSunnovaSDIds = new Set<Id>();
    Set<Id> changedQtySDIds = new Set<Id>();
    Set<Id> changedInvSDIds = new Set<Id>();
    Set<Id> changedAstSDIds = new Set<Id>();
    Set<Id> changedNrgSDIds = new Set<Id>();

    Set<String> astrumInvalidSQMessage = new Set<String>(); 
    Set<String> nrgInvalidSQMessage = new Set<String>(); 
    Set<String> cpreInvalidSQMessage = new Set<String>();   

    String itemType;

    Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.System_Design_Item__c.getRecordTypeInfosById();

    //gather master ids
    for(System_Design_Item__c rec: Trigger.new) {
        if (rec.MasterSD__c != null) {
            systemDesignIds.add(rec.MasterSD__c);
            itemType = rtMap.get(rec.RecordTypeId).getName();
            //Commented out as we should validate this when Inverter is getting inserted - We should only validate during Update
           /* if(itemType == 'Inverter' && Trigger.isInsert)
            {
                changedSDIds.add(rec.MasterSD__c);
                changedInvSDIds.add(rec.MasterSD__c);    
            }
            */
        }                    
        if(Trigger.isUpdate)
        {
            System_Design_Item__c oldSD = Trigger.OldMap.get(rec.Id);
            System_Design_Item__c newSD = Trigger.newMap.get(rec.Id);

            if(itemType == 'Inverter' && oldSD.System_Design_Product__c != null && newSD.System_Design_Product__c != null && oldSD.System_Design_Product__c != newSD.System_Design_Product__c )
            {
                changedSDIds.add(rec.MasterSD__c);
                changedInvSDIds.add(rec.MasterSD__c);    
            }
            

            if((newSD.Tilt_Text__c == '0' ? null : newSD.Tilt_Text__c) != (oldSD.Tilt_Text__c == '0' ? null : oldSD.Tilt_Text__c ))
            {
                changedSDIds.add(rec.MasterSD__c);    
                changedTiltSDIds.add(rec.MasterSD__c);
            }
            if((newSd.Azimuth_Text__c == '0' ? null : newSd.Azimuth_Text__c) != (oldSd.Azimuth_Text__c == '0' ? null : OldSd.Azimuth_Text__c))
            {
                changedSDIds.add(rec.MasterSD__c);    
                changedAzimuthSDIds.add(rec.MasterSD__c);
            }
            if((newSd.Shading_Text__c == '0.000' ? null : newSd.Shading_Text__c) != (oldSd.Shading_Text__c == '0.000' ? null : oldSd.Shading_Text__c))
            {
                changedSDIds.add(rec.MasterSD__c);    
                changedShadingSDIds.add(rec.MasterSD__c);
            }
            if(oldSD.Sunnova_Upgrade_Factor__c !=null && newSD.Sunnova_Upgrade_Factor__c != oldSD.Sunnova_Upgrade_Factor__c)
            {                  
                changedSDIds.add(rec.MasterSD__c);
                changedSunnovaSDIds.add(rec.MasterSD__c);
            }
            if(oldSD.Inverter_Transformer_Efficiency_Text__c !=null && newSD.Inverter_and_Transformer_Efficiency__c != oldSD.Inverter_Transformer_Efficiency_Text__c)
            {                  
                System.debug('*****************oldSD.Inverter_Transformer_Efficiency_Text__c '+oldSD.Inverter_Transformer_Efficiency_Text__c);
                System.debug('*****************newSD.Inverter_Transformer_Efficiency_Text__c '+newSD.Inverter_Transformer_Efficiency_Text__c);
                changedSDIds.add(rec.MasterSD__c);
                changedInvSDIds.add(rec.MasterSD__c);
            }            
            if(oldSD.Astrum_PV_Watts_Derate_Text__c !=null && newSD.Astrum_PV_Watts_Derate__c != oldSD.Astrum_PV_Watts_Derate_Text__c)
            {                  
                changedSDIds.add(rec.MasterSD__c);
                changedAstSDIds.add(rec.MasterSD__c);
            } 
            if(oldSD.NRG_PV_Watts_Derate_Text__c !=null && newSD.NRG_PV_Watts_De_Rate__c != oldSD.NRG_PV_Watts_Derate_Text__c)
            {                  
                changedSDIds.add(rec.MasterSD__c);
                changedNrgSDIds.add(rec.MasterSD__c);
            }            
            if(rec.Legacy_Astrum_Site_Quality__c && (changedTiltSDIds.contains(rec.MasterSD__c) 
                || changedAzimuthSDIds.contains(rec.MasterSD__c) || changedShadingSDIds.contains(rec.MasterSD__c) 
                || newSD.Quantity__c != oldSD.Quantity__c || newSD.Rated_Output_kW__c != oldSD.Rated_Output_kW__c))
            {
               sdMapToUpdate.put(rec.MasterSD__c,new System_Design__c(Id = rec.MasterSD__c, Legacy_Astrum_Site_Quality__c = false));
            }
        }    
        
    }
    
    // Update the System Makeup Field on the System Design.
    if (!systemDesignIds.isEmpty()) {
    
        //List<System_Design__c> systemDesignsToUpdate = new List<System_Design__c>();
        
        AggregateResult[] results = 
            [SELECT System_Design_Array__r.System_Design__c sdid, RecordType.Name recType, System_Design_Product__r.Description__c des, SUM(Quantity__c) qty
            FROM System_Design_Item__c
            WHERE System_Design_Array__r.System_Design__c IN :systemDesignIds
            AND RecordType.Name IN ('Panel','Inverter')
            GROUP BY System_Design_Array__r.System_Design__c, RecordType.Name,System_Design_Product__r.Description__c Order by System_Design_Array__r.System_Design__c];

        Id lastSystemDesignId = null;
        String systemMakeup = '';
        Boolean firstOne = false;
         
        for (AggregateResult ar : results) {
            Id systemDesignId = (Id)ar.get('sdid');
            if (systemDesignId != lastSystemDesignId) {
                if (systemMakeup != '') {
                    //systemDesignsToUpdate.add(new System_Design__c(Id = lastSystemDesignId, System_Makeup__c = systemMakeup)); 
                    if(sdMapToUpdate.get(lastSystemDesignId) != null)
                    {
                       sdMapToUpdate.get(lastSystemDesignId).System_Makeup__c = systemMakeup;   
                    }   
                    else
                    {
                        sdMapToUpdate.put(lastSystemDesignId,new System_Design__c(Id = lastSystemDesignId, System_Makeup__c = systemMakeup));    
                    }                
                    systemMakeup = '';
                }
                lastSystemDesignId = systemDesignId;
                firstOne = false;
            }
            String recType = (String)ar.get('recType');
            String des = (String)ar.get('des');
            Decimal qty = (Decimal)ar.get('qty');
            
            if (firstOne && qty > 0) {
                systemMakeup += ', ';
            }  

            if(qty > 0)
            {
                firstOne = true;
            }  
            
            if(recType == 'Panel')            
            {
                if(qty > 0)
                {
                   systemMakeup += '(' + qty.intValue() + ') ' + des;
                }   
            }
            else
            {
                systemMakeup += des;    
            }    
        }
        //check for last one
        if (systemMakeup != '') {
            //systemDesignsToUpdate.add(new System_Design__c(Id = lastSystemDesignId, System_Makeup__c = systemMakeup));
            if(sdMapToUpdate.get(lastSystemDesignId) != null)
            {
                sdMapToUpdate.get(lastSystemDesignId).System_Makeup__c = systemMakeup;        
            }                      
            else
            {
                sdMapToUpdate.put(lastSystemDesignId,new System_Design__c(Id = lastSystemDesignId, System_Makeup__c = systemMakeup));    
            }       
        }        
       

        if (!changedSDIds.isEmpty()) {        
            
            for(System_Design__c systemDesign :[Select Astrum_Invalid_SQ_Error_Message__c , NRG_Invalid_SQ_Error_Message__c
                                                      ,CPRE_Invalid_SQ_Error_Message__c from System_Design__c 
                                                 Where Id in :changedSDIds ])
            {
                astrumInvalidSQMessage.clear();
                nrgInvalidSQMessage.clear();
                cpreInvalidSQMessage.clear();

                if(systemDesign.Astrum_Invalid_SQ_Error_Message__c != null && systemDesign.Astrum_Invalid_SQ_Error_Message__c != '')
                {
                    astrumInvalidSQMessage.addAll(systemDesign.Astrum_Invalid_SQ_Error_Message__c.split('\n')); 
                }
                if(systemDesign.NRG_Invalid_SQ_Error_Message__c != null && systemDesign.NRG_Invalid_SQ_Error_Message__c != '')
                {
                    nrgInvalidSQMessage.addAll(systemDesign.NRG_Invalid_SQ_Error_Message__c.split('\n'));   
                }
                if(systemDesign.CPRE_Invalid_SQ_Error_Message__c != null && systemDesign.CPRE_Invalid_SQ_Error_Message__c != '')
                {
                    cpreInvalidSQMessage.addAll(systemDesign.CPRE_Invalid_SQ_Error_Message__c.split('\n'));   
                }

                if(changedTiltSDIds.contains(systemDesign.Id))
                {
                    astrumInvalidSQMessage.add('Panel Pitch has changed on one or more SDIs');                    
                    nrgInvalidSQMessage.add('Panel Pitch has changed on one or more SDIs'); 
                    cpreInvalidSQMessage.add('Panel Pitch has changed on one or more SDIs'); 
                }

                if(changedAzimuthSDIds.contains(systemDesign.Id))
                {
                    astrumInvalidSQMessage.add('Panel Azimuth has changed on one or more SDIs');
                    nrgInvalidSQMessage.add('Panel Azimuth has changed on one or more SDIs');
                    cpreInvalidSQMessage.add('Panel Azimuth has changed on one or more SDIs');                   
                }

                if(changedShadingSDIds.contains(systemDesign.Id))
                {
                    astrumInvalidSQMessage.add('Panel Annual Solar Access has changed on one or more SDIs');
                    nrgInvalidSQMessage.add('Panel Annual Solar Access has changed on one or more SDIs');
                    cpreInvalidSQMessage.add('Panel Annual Solar Access has changed on one or more SDIs');                   
                } 
                if(changedSunnovaSDIds.contains(systemDesign.Id))
                {
                    cpreInvalidSQMessage.add('Sunnova Upgrade Factor has changed on one or more SDIs');                   
                } 
                if(changedInvSDIds.contains(systemDesign.Id))
                {
                    astrumInvalidSQMessage.add('Inverter Efficiency has changed on one or more SDIs');
                    nrgInvalidSQMessage.add('Inverter Efficiency has changed on one or more SDIs');                  
                }
                if(changedAstSDIds.contains(systemDesign.Id))
                {
                    astrumInvalidSQMessage.add('Derate has changed on one or more SDIs.');                   
                } 
                if(changedNrgSDIds.contains(systemDesign.Id))
                {
                    nrgInvalidSQMessage.add('Derate has changed on one or more SDIs.');                   
                }              

                if(astrumInvalidSQMessage.size() > 0)
                {
                    List<String> astrumInvalidMessageList = new List<String>(astrumInvalidSQMessage);    
                    String astrumInvalidMessage = (astrumInvalidMessageList.size() > 1 ? String.join(astrumInvalidMessageList,'\n') : astrumInvalidMessageList[0]);
                    if(sdMapToUpdate.get(systemDesign.Id) != null)
                    {
                        sdMapToUpdate.get(systemDesign.Id).ASTRUM_SQ_Calculation_Status__c = 'Invalid'; 
                        sdMapToUpdate.get(systemDesign.Id).Astrum_Invalid_SQ_Error_Message__c = astrumInvalidMessage;
                    }
                    else
                    {
                        System_Design__c sysDesign = new System_Design__c(id=systemDesign.Id
                                    ,ASTRUM_SQ_Calculation_Status__c = 'Invalid'
                                    ,Astrum_Invalid_SQ_Error_Message__c = astrumInvalidMessage                                    
                                  );
                           
                        sdMapToUpdate.put(systemDesign.Id,sysDesign);
                    }

                }
                
                if(nrgInvalidSQMessage.size() > 0)
                {
                    List<String> nrgInvalidMessageList = new List<String>(nrgInvalidSQMessage);    
                    String nrgInvalidMessage = (nrgInvalidMessageList.size() > 1 ? String.join(nrgInvalidMessageList,'\n') : nrgInvalidMessageList[0]);
                    
                    if(sdMapToUpdate.get(systemDesign.Id) != null)
                    {
                        sdMapToUpdate.get(systemDesign.Id).NRG_SQ_Calculation_Status__c = 'Invalid'; 
                        sdMapToUpdate.get(systemDesign.Id).NRG_Invalid_SQ_Error_Message__c = nrgInvalidMessage;
                    }
                    else
                    {
                        System_Design__c sysDesign = new System_Design__c(id=systemDesign.Id
                                    ,NRG_SQ_Calculation_Status__c = 'Invalid'
                                    ,NRG_Invalid_SQ_Error_Message__c = nrgInvalidMessage                                    
                                  );
                           
                        sdMapToUpdate.put(systemDesign.Id,sysDesign);
                    }

                }

                if(cpreInvalidSQMessage.size() > 0)
                {
                    List<String> cpreInvalidMessageList = new List<String>(cpreInvalidSQMessage);    
                    String cpreInvalidMessage = (cpreInvalidMessageList.size() > 1 ? String.join(cpreInvalidMessageList,'\n') : cpreInvalidMessageList[0]);
                    
                    if(sdMapToUpdate.get(systemDesign.Id) != null)
                    {
                        sdMapToUpdate.get(systemDesign.Id).CPRE_SQ_Calculation_Status__c = 'Invalid'; 
                        sdMapToUpdate.get(systemDesign.Id).CPRE_Invalid_SQ_Error_Message__c = cpreInvalidMessage;
                    }
                    else
                    {
                        System_Design__c sysDesign = new System_Design__c(id=systemDesign.Id
                                    ,CPRE_SQ_Calculation_Status__c = 'Invalid'
                                    ,CPRE_Invalid_SQ_Error_Message__c = cpreInvalidMessage                                    
                                  );
                           
                        sdMapToUpdate.put(systemDesign.Id,sysDesign);
                    }

                }

                System.debug('2$$'+astrumInvalidSQMessage);
                
            }         
           
        }        

         //update the System Design records affected
        if (sdMapToUpdate.size() > 0) {
            update sdMapToUpdate.Values();
        }
        
    }
    
    //calculate Potential Lease Inverters for each SalesOrder
    if (!systemDesignIds.isEmpty()) {
        List<SCRB_SalesOrder__c> salesOrdersToUpdate = new List<SCRB_SalesOrder__c>();
        
        //find the system design quotes impacted by item changes
        List<SCRB_SalesOrder__c> salesOrdersImpacted = 
            [SELECT Id, System_Design_Quote__r.System_Design__c, CEG_FMV_per_Watt_W__c, System_Size_kW__c
            FROM SCRB_SalesOrder__c
            WHERE Financing_Type__c = 'Lease'
            AND System_Design_Quote__c <> null
            AND System_Size_kW__c <> null
            AND System_Size_kW__c > 0
            AND System_Design_Quote__r.System_Design__c IN :systemDesignIds];
        
        //map system design ids to sales orders
        Set<Id> systemDesignsImpacted = new Set<Id>();  
        Map<Id,List<SCRB_SalesOrder__c>> designOrderMap = new Map<Id, List<SCRB_SalesOrder__c>>();
        for (SCRB_SalesOrder__c so : salesOrdersImpacted) {
            Id systemDesignId = so.System_Design_Quote__r.System_Design__c;
            systemDesignsImpacted.add(systemDesignId);
            List<SCRB_SalesOrder__c> orders = designOrderMap.get(systemDesignId);
            if (orders == null) {
                orders = new List<SCRB_SalesOrder__c>();
                designOrderMap.put(systemDesignId, orders);
            }
            orders.add(so);
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
        Decimal inverterCount = 0;
  
        for (AggregateResult ar : results) {
            Id systemDesignId = (Id)ar.get('sdid');
            if (systemDesignId != lastSystemDesignId) {
                if (inverterCount > 0) {
                    salesOrdersToUpdate.addAll(updateQuotes(inverterCount, m215Cost, m210Cost, m190Cost, 
                        designOrderMap.get(lastSystemDesignId)));
                    inverterCount = m215Cost = m210Cost = m190Cost = 0;
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
            
        }
        //check for last one
        if (inverterCount > 0) {
            salesOrdersToUpdate.addAll(updateQuotes(inverterCount, m215Cost, m210Cost, m190Cost, 
                designOrderMap.get(lastSystemDesignId)));
        }
        
        //update the System Design records affected
        if (!salesOrdersToUpdate.isEmpty()) {
            update salesOrdersToUpdate;
        }
        
    }
    
    private static List<SCRB_SalesOrder__c> updateQuotes(Decimal inverterCount, Decimal m215Cost, Decimal m210Cost, Decimal m190Cost, List<SCRB_SalesOrder__c> orders) {
        
        List<SCRB_SalesOrder__c> results = new List<SCRB_SalesOrder__c>();
                    
        for (SCRB_SalesOrder__c so : orders) {
            
            SCRB_SalesOrder__c result = new SCRB_SalesOrder__c ( Id = so.Id );
            
            Decimal totalInverterCost = m215Cost + m210Cost + m190Cost;
            Decimal avgInverterCost = totalInverterCost / inverterCount;
            Decimal fairMktValuePerW = so.CEG_FMV_per_Watt_W__c;
            if (fairMktValuePerW == null) {
                fairMktValuePerW = 7; //default to 7 if no value
            }
            
            Decimal sixPercentFairMarket = fairMktValuePerW * 0.0510 * so.System_Size_kW__c * 1000;
            
            Integer m215Count = Math.ceil((m215Cost / totalInverterCost) * (sixPercentFairMarket / avgInverterCost)).intValue();  
            Integer m210Count = Math.ceil((m210Cost / totalInverterCost) * (sixPercentFairMarket / avgInverterCost)).intValue();  
            Integer m190Count = Math.ceil((m190Cost / totalInverterCost) * (sixPercentFairMarket / avgInverterCost)).intValue();  
            
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
            
            if (leaseInverters == '') {
                leaseInverters = '0';
            } else {
                leaseInverters = leaseInverters.substring(0, leaseInverters.length() - 2);
            }
            
            result.Potential_Lease_Inverters__c = leaseInverters;
            results.add(result);
            
        }   

        return results;
    }
}