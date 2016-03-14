/* FILE: UtilityServiceTriggerHandler.cls
   AUTHOR: Mike Katulka
   DATE: 2014-08-28
   PURPOSE: Common trigger handler for Utility Service
   MODIFICATION HISTORY: 
       10/31/14  DK  Created invalidateSystemDesigns().
       11/24/14  DK  Created updateRateCodeServiceTerritories().
       12/09/14  DK  Created setDefaultUtilityCompanyDetails().
       08/04/15  DK  Created checkCustomUtilityRate() for CPQ-224.
       08/04/15  RJ  Added skipUtilityServiceTriggerSDValidation for CPQ-224.
*/
public class UtilityServiceTriggerHandler {
    
    public static boolean isUtilityServiceTriggerRunning = false;
    public static boolean skipUtilityServiceTrigger = false;
    public static boolean skipUtilityServiceTriggerSDValidation = false; //08/04/15  RJ 224

    private boolean m_isExecuting = false;

    public UtilityServiceTriggerHandler (boolean isExecuting){      
        m_isExecuting = isExecuting;

    }

    public void OnBeforeInsert(Utility_Service__c[] newUtilityServices){
        // EXECUTE BEFORE INSERT LOGIC  
        setDefaultUtilityCompanyDetails(newUtilityServices);
        updateRateCodeServiceTerritories(newUtilityServices);
        m_isExecuting = false;
    }

    public void OnBeforeUpdate(Utility_Service__c[] updatedUtilityServices, Map<ID, Utility_Service__c> utilityServiceMap, Map<ID, Utility_Service__c> oldUtilityServiceMap){
        // BEFORE UPDATE LOGIC  
        updateRateCodeServiceTerritories(updatedUtilityServices);
        m_isExecuting = false;
    }

    public void OnAfterInsert(Utility_Service__c[] insertedUtilityServices, map<id, Utility_Service__c> insertedUtilityServicesMap){
        // EXECUTE AFTER INSERT LOGIC
        checkCustomUtilityRate(insertedUtilityServicesMap);
        m_isExecuting = false;
    }

    public void OnAfterUpdate(Utility_Service__c[] updatedUtilityServices, Map<ID, Utility_Service__c> utilityServiceMap, Map<ID, Utility_Service__c> oldUtilityServiceMap,Boolean runValidation){
        //  EXECUTE AFTER UPDATE LOGIC
        //calculateUtilityServiceValues(updatedUtilityServices, oldUtilityServiceMap);
        invalidateSystemDesigns(utilityServiceMap, oldUtilityServiceMap,runValidation);
        checkCustomUtilityRate(utilityServiceMap);
        m_isExecuting = false;
    }

    
    /*
    public void OnBeforeDelete(Object[] ObjectsToDelete, Map<Id,Lead> MapObjectMap){
        // BEFORE DELETE LOGIC
    }

    public void OnAfterDelete(Object[] deletedObjects, Map<Id,Lead> MapObjectMap){
        // AFTER DELETE LOGIC
    }

    public void OnUndelete(Object[] restoredObjects){
        // AFTER UNDELETE LOGIC
    }
    */
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
    
    //If Utility.Solar Compensation Method = 'Net Metering' and if Utility Rate Code After Solar is updated OR 
    //If Utility.Solar Compensation method = 'VOST' and if Utility Value of Solar Tariff is updated
    //Invalidate the associated System Designs
    public void invalidateSystemDesigns(Map<ID, Utility_Service__c> utilityServices, Map<ID, Utility_Service__c> oldUtilityServices, Boolean runValidation){
        if(!runValidation) //08/04/15  RJ 224
        {
            Set<ID> updatedRateCode = new Set<ID>();
            Set<ID> updatedTariff = new Set<ID>();
            Set<ID> utilCompanyIDs = new Set<ID>();
            
            for (Utility_Service__c us : utilityServices.values()){
                if (us.Utility_Company_master__c != null)
                    utilCompanyIDs.add(us.Utility_Company_master__c);
            }
            
            Map<ID, Utility_Company_master__c> utilCompanies = new Map<ID, Utility_Company_master__c>(
                                                                    [SELECT Solar_Compensation_Method__c FROM Utility_Company_master__c WHERE ID IN :utilCompanyIDs]);
            for (ID usID : utilityServices.keySet()){
                Utility_Service__c us = utilityServices.get(usID);
                if (!utilCompanies.containsKey(us.Utility_Company_master__c))
                    continue;
                if (utilCompanies.get(us.Utility_Company_master__c).Solar_Compensation_Method__c == 'Net Metering' 
                    && us.Utility_Rate_Code_After_Solar__c != oldUtilityServices.get(usID).Utility_Rate_Code_After_Solar__c){
                    updatedRateCode.add(usID);
                } else if (utilCompanies.get(us.Utility_Company_master__c).Solar_Compensation_Method__c == 'VOST' 
                           && us.Utility_Value_of_Solar_Tariff__c != oldUtilityServices.get(usID).Utility_Value_of_Solar_Tariff__c){
                    updatedTariff.add(usID);
                }
            }
            
            Set<ID> rateCode_systemDesignIDs = new Set<ID>();
            Set<ID> tariff_systemDesignIDs = new Set<ID>();
            for (System_Design_Array__c sda : [SELECT System_Design__c, CB_Panel__r.Utility_Service__c FROM System_Design_Array__c 
                                               WHERE CB_Panel__r.Utility_Service__c IN :updatedRateCode OR CB_Panel__r.Utility_Service__c IN :updatedTariff]){
                
                //Get System Design IDs from the System Design Arrays related to the CB Panels related to the changed Utility Services
                if (updatedRateCode.contains(sda.CB_Panel__r.Utility_Service__c)){
                    rateCode_systemDesignIDs.add(sda.System_Design__c);
                } else if (updatedTariff.contains(sda.CB_Panel__r.Utility_Service__c)){
                    tariff_systemDesignIDs.add(sda.System_Design__c);
                }
            }
            
            System_Design__c[] systemDesigns = [SELECT Astrum_SQ_Calculation_Status__c, Astrum_Invalid_SQ_Error_Message__c FROM System_Design__c 
                                                WHERE ID IN :rateCode_systemDesignIDs OR ID IN :tariff_systemDesignIDs];
            for (System_Design__c sd : systemDesigns){
                sd.Astrum_SQ_Calculation_Status__c = 'Invalid';
                if (rateCode_systemDesignIDs.contains(sd.ID)){
                    sd.Astrum_Invalid_SQ_Error_Message__c = 'Utility Rate Code has changed';
                } else if (tariff_systemDesignIDs.contains(sd.ID)){
                    sd.Astrum_Invalid_SQ_Error_Message__c = 'Value of Solar Tariff has changed';
                }
            }
            update systemDesigns;
        }
    }
    
    //Enforce the rule: RateCodeBeforeSolar.ServiceTerritory must equal RateCodeAfterSolar.ServiceTerritory
    private void updateRateCodeServiceTerritories(Utility_Service__c[] utilityServices){
        Set<ID> rateCodeIDs = new Set<ID>();
        for (Utility_Service__c us : utilityServices){
            rateCodeIDs.add(us.Utility_Rate_Code_Before_Solar__c);
            rateCodeIDs.add(us.Utility_Rate_Code_After_Solar__c);
        }
        Map<ID, Utility_Company__c> rateCodes = new Map<ID, Utility_Company__c>([SELECT Utility_Service_Territory__c FROM Utility_Company__c WHERE ID IN :rateCodeIDs]);
        Set<Utility_Company__c> rateCodesToUpdate = new Set<Utility_Company__c>();
        for (Utility_Service__c us : utilityServices){
            ID beforeSolar = us.Utility_Rate_Code_Before_Solar__c;
            ID afterSolar = us.Utility_Rate_Code_After_Solar__c;
            if (beforeSolar == null || afterSolar == null)
                continue;
            if (rateCodes.get(beforeSolar).Utility_Service_Territory__c != rateCodes.get(afterSolar).Utility_Service_Territory__c){
                //Alert the user if the two territories are different
                if (String.isNotBlank(rateCodes.get(beforeSolar).Utility_Service_Territory__c) && 
                    String.isNotBlank(rateCodes.get(afterSolar).Utility_Service_Territory__c)){
                    
                    us.Utility_Rate_Code_Before_Solar__c.addError('Rate Code Before Solar\'s Service Territory does not match that of Rate Code After Solar');
                    us.Utility_Rate_Code_After_Solar__c.addError('Rate Code After Solar\'s Service Territory does not match that of Rate Code Before Solar');
                    continue;
                }
                
                //If one territory is null, then set it to the value of the other one
                if (String.isBlank(rateCodes.get(beforeSolar).Utility_Service_Territory__c) && 
                     String.isNotBlank(rateCodes.get(afterSolar).Utility_Service_Territory__c)){
                    rateCodes.get(beforeSolar).Utility_Service_Territory__c = rateCodes.get(afterSolar).Utility_Service_Territory__c;
                    rateCodesToUpdate.add(rateCodes.get(beforeSolar));
                } else if (String.isBlank(rateCodes.get(afterSolar).Utility_Service_Territory__c) && 
                            String.isNotBlank(rateCodes.get(beforeSolar).Utility_Service_Territory__c)){
                    rateCodes.get(afterSolar).Utility_Service_Territory__c = rateCodes.get(beforeSolar).Utility_Service_Territory__c;
                    rateCodesToUpdate.add(rateCodes.get(afterSolar));
                }
            }
        }
        update new List<Utility_Company__c>(rateCodesToUpdate);    //Will not update if we added errors
    }
    
    public void setDefaultUtilityCompanyDetails(Utility_Service__c[] newUtilServices){
        Set<ID> propSet = new Set<ID>();
        for (Utility_Service__c us : newUtilServices){
            propSet.add(us.Property__c);
        }
        
        Map<ID, String> propZips = new Map<ID, String>();   //Property ID --> Full Zip Code (Including hyphen)
        Map<ID, String> propZipsPartial = new Map<ID, String>();    //Property ID --> Partial Zip Code (Ending before hyphen)
        for (Property__c prop : [SELECT Property_Zip__c FROM Property__c WHERE ID IN :propSet AND Property_Zip__c != null]){
            propZips.put(prop.ID, prop.Property_Zip__c);
            propZipsPartial.put(prop.ID, prop.Property_Zip__c.substringBefore('-'));
        }
                
        Map<String, ID> defaultUtilComps = new Map<String, ID>();   //Zip Code --> Utility Company ID
        for (Utility_by_Zip_Code__c utilZip :[SELECT Utility_Company_Master__c, Utility_Zip_Code__c FROM Utility_by_Zip_Code__c 
                                              WHERE Utility_Zip_Code__c IN :propZips.values() OR Utility_Zip_Code__c IN :propZipsPartial.values()]){
            defaultUtilComps.put(utilZip.Utility_Zip_Code__c, utilZip.Utility_Company_Master__c);
        }
        
        Map<ID, Utility_Company__c> rateCodes = new Map<ID, Utility_Company__c>();  //Utility Company ID --> Utility Rate Code
        for (Utility_Company__c urc : [SELECT Utility_Company_Master__c, Utility_Company_Master__r.Solar_Compensation_Method__c FROM Utility_Company__c 
                                       WHERE Utility_Company_Master__c IN :defaultUtilComps.values() AND Default_Rate_Code__c = true ORDER BY Name]){
            if (rateCodes.get(urc.Utility_Company_Master__c) == null)
                rateCodes.put(urc.Utility_Company_Master__c, urc);
        }
        
        //For the VOST option
        Map<ID, ID> tariffRateCodes = new Map<ID, ID>();    //Utility Company ID --> Utility Rate Code ID
        for (Utility_Company__c urc : [SELECT Utility_Company_Master__c FROM Utility_Company__c WHERE Value_of_Solar_Tariiff__c = true AND 
                                       Utility_Company_Master__c IN :rateCodes.keySet() ORDER BY Name]){
            if (tariffRateCodes.get(urc.Utility_Company_Master__c) == null)
                tariffRateCodes.put(urc.Utility_Company_Master__c, urc.ID);
        }
        
        for (Utility_Service__c us : newUtilServices){
            ID propID = us.Property__c;
            String zip = propZips.get(propID);
            String partialZip = propZipsPartial.get(propID);
            ID utilCompID = defaultUtilComps.get(zip);
            if (utilCompID == null)
                utilCompID = defaultUtilComps.get(partialZip);
            Utility_Company__c rateCode = rateCodes.get(utilCompID);
            
            //Populate Utility Service.Utility Company Master by matching Property ZIP for Utility by ZIP Code record
            if (us.Utility_Company_Master__c == null)
                us.Utility_Company_Master__c = utilCompID;
            
            if (rateCode == null)
                continue;    //No match
            
            //Populate Utility Service.Rate Code Before Solar by finding the Utility Rate Code for the matched Utility Company where Default = true
            if (us.Utility_Rate_Code_Before_Solar__c == null)
                us.Utility_Rate_Code_Before_Solar__c = rateCode.ID;
            
            //Populate Utility Service.Rate Code After Solar with same record as Rate Code Before Solar
            if (us.Utility_Rate_Code_After_Solar__c == null)
                us.Utility_Rate_Code_After_Solar__c = rateCode.ID;
            
            //If Utility Service.Utility Company.Solar Compensation Method = 'Net Metering': Utility Value of Solar Tariff = null
            if (rateCode.Utility_Company_Master__r.Solar_Compensation_Method__c == 'Net Metering')
                us.Utility_Value_of_Solar_Tariff__c = null;
            
            //If Utility Service.Utility Company.Solar Compensation Method = 'VOST':
            //Utility Service.Utility Value of Solar Tariff = Utility Rate Code record for Utility Service.Utility Company Master where Utility Rate Code.Value of Solar Tariff = true
            if (rateCode.Utility_Company_Master__r.Solar_Compensation_Method__c == 'VOST' && tariffRateCodes.containsKey(us.Utility_Company_Master__c))
                us.Utility_Value_of_Solar_Tariff__c = tariffRateCodes.get(us.Utility_Company_Master__c);
        }
        //No DML necessary as long as this method is called in a "before" context
    }
    
    public void checkCustomUtilityRate(Map<ID, Utility_Service__c> utilServiceMap){
        Utility_Service__c[] utilServices = [SELECT Utility_Rate_Code_Before_Solar__r.RecordType.Name, Utility_Rate_Code_After_Solar__r.RecordType.Name, Custom_Utility_Rate_Applied__c FROM Utility_Service__c WHERE ID IN :utilServiceMap.keySet()];
        for (Utility_Service__c us : utilServices){
            if (us.Utility_Rate_Code_Before_Solar__r.RecordType.Name == 'Custom' || us.Utility_Rate_Code_After_Solar__r.RecordType.Name == 'Custom'){
                us.Custom_Utility_Rate_Applied__c = true;
            } else {
                us.Custom_Utility_Rate_Applied__c = false;
            }
        }
        update utilServices;
    }

    //MK - 2014-08-28 - This is used for when a user makes a change to the Annual Electricity Consumption (kWh) or 
    //Forecasted Add. Ann. Consumption (kW) fields.
    //private void calculateUtilityServiceValues(Utility_Service__c[] updatedUtilityServices, Map<Id,Utility_Service__c> oldUtilityServiceMap){
    //  system.debug('calculateUtilityServiceValues');
    //    set<id> usIDs = new set<id>();
    //  for(Utility_Service__c us : updatedUtilityServices){            
    //      Utility_Service__c oldUs = oldUtilityServiceMap.get(us.id);
    //      if(
    //            (us.Annual_Electricity_Consumption_kWh__c != oldus.Annual_Electricity_Consumption_kWh__c)
    //            ||
    //            (us.Forecasted_Add_Annual_Consumption_kWh__c != oldus.Forecasted_Add_Annual_Consumption_kWh__c)
    //      ){
    //          //Values changed
    //          usIDs.add(us.id);
    //      }           
    //  }

    //  AggregateResult[] groupedResults = [select System_Design__c 
    //                                          from System_Design_Array__c
    //                                          where CB_Panel__r.Utility_Service__c in : usIDs
    //                                          group by System_Design__c];

    //  map<id, System_Design__c> systemDesignMap = new map<id, System_Design__c>();
    //  for (AggregateResult ar : groupedResults){
    //        systemDesignMap.put((id)ar.get('System_Design__c'), new System_Design__c(id = (id)ar.get('System_Design__c')));
    //    }

    //    SystemDesignTriggerHandler handler = new SystemDesignTriggerHandler (false);
    //    //Call common class and tell the method to run a DML on the system designs.
    //    handler.calculateUtilityServiceValues(systemDesignMap, true);

    //}
 
}