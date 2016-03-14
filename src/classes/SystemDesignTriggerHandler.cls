/* FILE: SystemDesignTriggerHandler.cls
 * AUTHOR: Rohit Jain
 * DATE: Mar 24, 2014
 * PURPOSE: System Design Trigger Handler
 * MODIFICATION HISTORY
 * RJ 06/18/15 : CPQ-394
 * RJ 07/09/15 : CPQ-447
 */
public class SystemDesignTriggerHandler {
	
    public static boolean isSystemDesignTriggerRunning = false;
    public static boolean skipSystemDesignTrigger = false;

    private boolean m_isExecuting = false;

	public SystemDesignTriggerHandler(boolean isExecuting) {
		m_isExecuting = isExecuting;
	}

	public void OnBeforeUpdate(System_Design__c[] newSystemDesigns,Map<Id,System_Design__c> oldMap,Map<Id,System_Design__c> newMap){
        // EXECUTE BEFORE UPDATE LOGIC
        checkBalanceDerateChange(newSystemDesigns,oldMap,newMap);
        //calculateUtilityServiceValues(newMap, false); //Changes to SDA's like when the CB panel on the SDA changes, will always roll up 
                                                        //and fire this trigger, so this will calculate properly.
                                                        //There will be a trigger on the Utility Service and CB Panel that will ensure that
                                                        //these fields will be accurate
        m_isExecuting = false;
    }

    public void OnAfterUpdate(System_Design__c[] newSystemDesigns,Map<Id,System_Design__c> oldMap,Map<Id,System_Design__c> newMap){
        //  EXECUTE AFTER UPDATE LOGIC                      
		updateOpportunities(newSystemDesigns,oldMap,newMap);
		updateSDIAstrumLegacyFlag(newSystemDesigns,oldMap,newMap);
        //updateSalesOrderMakeup(newSystemDesigns,oldMap,newMap); //CPQ-394
        updateCurrentDesignFlag(newSystemDesigns, oldMap, false);		
        m_isExecuting = false;

    }

    public void OnAfterInsert(System_Design__c[] newSystemDesigns){
        //  EXECUTE AFTER INSERT LOGIC                      
        updateCurrentDesignFlag(newSystemDesigns, null, true);        
        m_isExecuting = false;

    }

    ////MK - 2014-08-28: New method used to fill in values for pricing calculations
    //public void calculateUtilityServiceValues(Map<Id,System_Design__c> updatedSystemDesignMap, boolean doDML){
    //    //For each Array with a panel count > 0, Need to locate all Utility Service records.  For each unique Utility Service need to add the numeric values.
    //    for(System_Design__c sd : updatedSystemDesignMap.values()){
    //        //reset the values to 0
    //        sd.Annual_Electricity_Consumption_kWh__c = 0;
    //        sd.Forecasted_Add_Annual_Consumption_kWh__cAnn_Consumption_kW__c = 0;
    //    }

    //    //Get the unique values so we can sum later
    //    AggregateResult[] groupedResults = [SELECT System_Design__c, CB_Panel__r.Utility_Service__c utilityServiceID
    //                                                , AVG(CB_Panel__r.Utility_Service__r.Annual_Electricity_Consumption_kWh__c) annualElecConsumption
    //                                                , AVG(CB_Panel__r.Utility_Service__r.Forecasted_Add_Annual_Consumption_kWh__c) forecastedAddAnnCons
    //                                        FROM System_Design_Array__c
    //                                        WHERE System_Design__c in : updatedSystemDesignMap.keySet()
    //                                        AND Panel_Count__c > 0
    //                                        GROUP BY System_Design__c, CB_Panel__r.Utility_Service__c];
        
        
    //    for (AggregateResult ar : groupedResults)  {
    //        //For each system design, add up the unique values (cannot be done fully within the SOQL because if 2 arrays use the same utility service, they will be duplicates and added incorrectly)
    //        System_Design__c sd = updatedSystemDesignMap.get((id)ar.get('System_Design__c'));
    //        decimal annElec = (decimal)ar.get('annualElecConsumption');            
    //        if(annElec != null) sd.Annual_Electricity_Consumption_kWh__c += annElec;

    //        decimal forecastedAnn = (decimal)ar.get('forecastedAddAnnCons');
    //        if(forecastedAnn != null) sd.Forecasted_Add_Ann_Consumption_kW__c += forecastedAnn;
    //    }

    //    //Check if this is being called from somewhere other than the SD before trigger
    //    if(doDML){
    //        //Prevent unecessary trigger
    //        SystemDesignTriggerHandler.skipSystemDesignTrigger = true;
    //        update updatedSystemDesignMap.values();
    //        SystemDesignTriggerHandler.skipSystemDesignTrigger = false;
    //    }
    //}

    private void checkBalanceDerateChange(System_Design__c[] newSystemDesigns,Map<Id,System_Design__c> oldMap,Map<Id,System_Design__c> newMap)
    {
        Set<String> astrumInvalidSQMessage = new Set<String>(); 
        Set<String> nrgInvalidSQMessage = new Set<String>(); 
        Set<String> cpreInvalidSQMessage = new Set<String>();  

        for(System_Design__c sysDesign : newSystemDesigns)
        {
            
            astrumInvalidSQMessage.clear();
            nrgInvalidSQMessage.clear();
            cpreInvalidSQMessage.clear();

            if(sysDesign.Astrum_Invalid_SQ_Error_Message__c != null && sysDesign.Astrum_Invalid_SQ_Error_Message__c != '')
            {
                astrumInvalidSQMessage.addAll(sysDesign.Astrum_Invalid_SQ_Error_Message__c.split('/n'));   
            }
            if(sysDesign.NRG_Invalid_SQ_Error_Message__c != null && sysDesign.NRG_Invalid_SQ_Error_Message__c != '')
            {
                nrgInvalidSQMessage.addAll(sysDesign.NRG_Invalid_SQ_Error_Message__c.split('/n'));   
            }
            if(sysDesign.CPRE_Invalid_SQ_Error_Message__c != null && sysDesign.CPRE_Invalid_SQ_Error_Message__c != '')
            {
                cpreInvalidSQMessage.addAll(sysDesign.CPRE_Invalid_SQ_Error_Message__c.split('/n'));   
            }

            if(oldMap.get(sysDesign.Id).Astrum_Balance_of_System_Derate__c != null
                && oldMap.get(sysDesign.Id).Astrum_Balance_of_System_Derate__c != newMap.get(sysDesign.Id).Astrum_Balance_of_System_Derate__c )
            {
                astrumInvalidSQMessage.add('Astrum Balance Of System Derate has changed for this System Design');               
            }
            if(oldMap.get(sysDesign.Id).NRG_Balance_of_System_Derate__c != null
                && oldMap.get(sysDesign.Id).NRG_Balance_of_System_Derate__c != newMap.get(sysDesign.Id).NRG_Balance_of_System_Derate__c )
            {
                astrumInvalidSQMessage.add('NRG Balance Of System Derate has changed for this System Design');              
            }

            if(astrumInvalidSQMessage.size() > 0)
            {
                List<String> astrumInvalidMessageList = new List<String>(astrumInvalidSQMessage);    
                String astrumInvalidMessage = (astrumInvalidMessageList.size() > 1 ? String.join(astrumInvalidMessageList,'\n') : astrumInvalidMessageList[0]); 
                sysDesign.Astrum_Invalid_SQ_Error_Message__c = astrumInvalidMessage;
                if (!(sysDesign.Astrum_Invalid_SQ_Error_Message__c.contains('Processing')))  //DK CPQ-447
                    sysDesign.ASTRUM_SQ_Calculation_Status__c = 'Invalid'; // CPQ-447
            }
            if(nrgInvalidSQMessage.size() > 0)
            {
                List<String> nrgInvalidMessageList = new List<String>(nrgInvalidSQMessage);    
                String nrgInvalidMessage = (nrgInvalidMessageList.size() > 1 ? String.join(nrgInvalidMessageList,'\n') : nrgInvalidMessageList[0]);
                sysDesign.NRG_SQ_Calculation_Status__c = 'Invalid'; 
                sysDesign.NRG_Invalid_SQ_Error_Message__c = nrgInvalidMessage;
            }

        }

    }

    private void updateCurrentDesignFlag(System_Design__c[] newSystemDesigns,Map<Id,System_Design__c> oldMap,boolean isInsert)
    {        
        set<id> sdsCurrent = new set<id>();
        set<id> propIDs = new set<id>();
        //Check to see if "Current Design" is checked
        for(System_Design__c sd: newSystemDesigns){            
            if(sd.Current_Design__c 
                && (
                    isInsert
                    ||
                    !(boolean)oldMap.get(sd.id).Current_Design__c
                   )
            ){
                sdsCurrent.add(sd.id);
                propIDs.add(sd.Property__c);
            }
        }
        if(propIDs.isEmpty()) return;

        //Select other system designs from the same properties, but exclude these designs
        List<System_Design__c> sdsToUpdate = [Select id, Current_Design__c 
                                                From System_Design__c 
                                                Where Property__c IN : propIDs 
                                                AND id NOT IN : sdsCurrent 
                                                AND Current_Design__c = true];
        //Loop through the old checked designs and uncheck them
        for(System_Design__c sd: sdsToUpdate){            
            sd.Current_Design__c = false;             
        }        
        if(!sdsToUpdate.isEmpty()) update(sdsToUpdate);
    }

    private void updateOpportunities(System_Design__c[] newSystemDesigns,Map<Id,System_Design__c> oldMap,Map<Id,System_Design__c> newMap)
    {
        List<Opportunity> oppsToUpdate = new List<Opportunity>([Select o.System_Design_Quote__r.System_Design__c, 
                                                                   o.System_Design_Quote__c, 
                                                                   o.Name, 
                                                                   o.Id 
                                                                From Opportunity o 
                                                                Where o.System_Design_Quote__r.System_Design__c 
                                                                IN :newMap.keySet()]);
        
        update(oppsToUpdate);

    }

    private void updateSDIAstrumLegacyFlag(System_Design__c[] newSystemDesigns,Map<Id,System_Design__c> oldMap,Map<Id,System_Design__c> newMap)
    {
        List<System_Design__c> sdUpdated = new List<System_Design__c>();

        for(System_Design__c sd : newSystemDesigns)
        {
            If(newMap.get(sd.Id).Legacy_Astrum_site_Quality__c != oldMap.get(sd.id).Legacy_Astrum_site_Quality__c)
            {
                sdUpdated.add(sd);
            }

        }
        if(sdUpdated.size() > 0)
        {
            List<System_Design_Item__c> sdis = [Select Legacy_Astrum_site_Quality__c ,System_Design_Array__r.System_Design__c From System_Design_Item__c 
                                                 Where RecordType.Name = 'Panel' AND System_Design_Array__r.System_Design__c in :sdUpdated ];

            for(System_Design_Item__c sdi : sdis)
            {
                sdi.Legacy_Astrum_site_Quality__c = newMap.get(sdi.System_Design_Array__r.System_Design__c).Legacy_Astrum_site_Quality__c;
            }
            update sdis;
        }

    }
    //Commented for CPQ-394
    /*private void updateSalesOrderMakeup(System_Design__c[] newSystemDesigns,Map<Id,System_Design__c> oldMap,Map<Id,System_Design__c> newMap)
    {
        List<System_Design__c> sdUpdated = new List<System_Design__c>();

        for(System_Design__c sd : newSystemDesigns)
        {
            If(newMap.get(sd.Id).System_Makeup__c != oldMap.get(sd.id).System_Makeup__c )
            {
                sdUpdated.add(sd);
            }

        }
        if(sdUpdated.size() > 0)
        {
            List<SCRB_SalesOrder__c> sos = [Select System_Makeup__c,System_Design_Quote__r.System_Design__c From SCRB_SalesOrder__c 
                                                 Where System_Design_Quote__r.System_Design__c in :sdUpdated ];

            if(sos != null && sos.size() > 0)
            {
                for(SCRB_SalesOrder__c so : sos)
                {
                    so.System_Makeup__c = newMap.get(so.System_Design_Quote__r.System_Design__c).System_Makeup__c;
                }
                update sos;
            }
        }

    }
    */

}