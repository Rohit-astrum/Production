/* FILE: PropertyTriggerHandler.cls
 * AUTHOR: Rohit Jain
 * DATE: Mar 24, 2014
 * PURPOSE: Property Trigger Handler
 * MODIFICATION HISTORY
 *    10/30/14  DK  Updated Utility Rate Code and Utility Company logic in defaultUtilityCompany()
 *    1/27/15   RJ  Commented the Utility Company Change Validation for SQ as it is moved to Utility Service now.
 */
public with sharing class PropertyTriggerHandler {

    private boolean m_isExecuting = false;

    public PropertyTriggerHandler (boolean isExecuting){
        m_isExecuting = isExecuting;
    }

    public void OnBeforeInsert(Property__c[] newProperties){
        // EXECUTE BEFORE INSERT LOGIC
        //defaultUtilityCompany(newProperties);
        m_isExecuting = false;
    }

    public void OnAfterUpdate(Property__c[] updatedProperties, Map<Id,Property__c> propertyMap){
        //  EXECUTE AFTER UPDATE LOGIC       
        checkUpdatesforSystemDesign(updatedProperties,propertyMap);
        m_isExecuting = false;
    }

    /*
    public void OnAfterInsert(Property__c[] newObjects){
        // EXECUTE AFTER INSERT LOGIC
    }

    public void OnBeforeUpdate(Property__c[] oldObjects, Property__c[] updatedObjects, Map<Id,Lead> MapObjectMap){
        // BEFORE UPDATE LOGIC
    }

    
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

    private void checkUpdatesforSystemDesign(Property__c[] updatedProperties, Map<Id,Property__c> OldPropertyMap)
    {
        Set<Id> changedPropertyIds = new Set<Id>();
        Set<Id> changedPropertyLocationIds = new Set<Id>();
        //Set<Id> changedPropertyUtilityIds = new Set<Id>();
        Set<Id> changedCPREPropertyIds = new Set<Id>();
        Set<Id> changedSnowPropertyIds = new Set<Id>();

        Set<String> astrumInvalidSQMessage = new Set<String>(); 
        Set<String> nrgInvalidSQMessage = new Set<String>(); 
        Set<String> cpreInvalidSQMessage = new Set<String>();   


        for(Property__c prop : updatedProperties)
        {
            if(   prop.Latitude__c != OldPropertyMap.get(prop.Id).Latitude__c
               || prop.Longitude__c != OldPropertyMap.get(prop.Id).Longitude__c
               || prop.QAS_Latitude__c != OldPropertyMap.get(prop.Id).QAS_Latitude__c
               || prop.QAS_Longitude__c != OldPropertyMap.get(prop.Id).QAS_Longitude__c               
               )
            {
                changedPropertyIds.add(prop.Id);
                changedPropertyLocationIds.add(prop.Id);
            }

            /*if( prop.Utility_Company__c != OldPropertyMap.get(prop.Id).Utility_Company__c )
            {
                changedPropertyIds.add(prop.Id);
                changedPropertyUtilityIds.add(prop.Id);
            }*/

            if( prop.Snow_De_Rate_kWh_y_kW__c != OldPropertyMap.get(prop.Id).Snow_De_Rate_kWh_y_kW__c )
            {
                changedPropertyIds.add(prop.Id);
                changedSnowPropertyIds.add(prop.Id);
            }

            if(   prop.Property_Zip__c != OldPropertyMap.get(prop.Id).Property_Zip__c
               || prop.Property_State__c != OldPropertyMap.get(prop.Id).Property_State__c                              
               )
            {
                changedPropertyIds.add(prop.Id);
                changedCPREPropertyIds.add(prop.Id);
            }
        }

        if (!changedPropertyIds.isEmpty()) {
            List<System_Design__c> systemDesigns = [Select Property__c,NRG_SQ_Calculation_Status__c,Astrum_SQ_Calculation_Status__c
                                                     ,CPRE_SQ_Calculation_Status__c, NRG_Invalid_SQ_Error_Message__c
                                                     ,Astrum_Invalid_SQ_Error_Message__c,CPRE_Invalid_SQ_Error_Message__c
                                                 from  System_Design__c 
                                               Where Property__c IN :changedPropertyIds]; 

            if(systemDesigns != null && !systemDesigns.isEmpty())
            {
                for(System_Design__c systemDesign :systemDesigns )
                {
                    
                    astrumInvalidSQMessage.clear();
                    nrgInvalidSQMessage.clear();
                    cpreInvalidSQMessage.clear();

                    if(systemDesign.Astrum_Invalid_SQ_Error_Message__c != null && systemDesign.Astrum_Invalid_SQ_Error_Message__c != '')
                    {
                        astrumInvalidSQMessage.addAll(systemDesign.Astrum_Invalid_SQ_Error_Message__c.split('/n'));   
                    }
                    if(systemDesign.NRG_Invalid_SQ_Error_Message__c != null && systemDesign.NRG_Invalid_SQ_Error_Message__c != '')
                    {
                        nrgInvalidSQMessage.addAll(systemDesign.NRG_Invalid_SQ_Error_Message__c.split('/n'));   
                    }
                    if(systemDesign.CPRE_Invalid_SQ_Error_Message__c != null && systemDesign.CPRE_Invalid_SQ_Error_Message__c != '')
                    {
                        cpreInvalidSQMessage.addAll(systemDesign.CPRE_Invalid_SQ_Error_Message__c.split('/n'));   
                    }

                    if(changedPropertyLocationIds.contains(systemDesign.Property__c))
                    {
                        astrumInvalidSQMessage.add('Property location has changed');
                        nrgInvalidSQMessage.add('Property location has changed');                         
                    }
                    /*if(changedPropertyUtilityIds.contains(systemDesign.Property__c))    
                    {
                        
                        astrumInvalidSQMessage.add('Property Utility Rate Code has changed');
                        nrgInvalidSQMessage.add('Property Utility Rate Code has changed');
                        cpreInvalidSQMessage.add('Property Utility Rate Code has changed');
                    }*/

                    if(changedSnowPropertyIds.contains(systemDesign.Property__c))    
                    {
                        astrumInvalidSQMessage.add('Snow Derate has changed for the Property');                          
                    }

                    if(changedCPREPropertyIds.contains(systemDesign.Property__c))
                    {
                        cpreInvalidSQMessage.add('Property location has changed');                                                     
                    }

                    if(astrumInvalidSQMessage.size() > 0)
                    {
                        List<String> astrumInvalidMessageList = new List<String>(astrumInvalidSQMessage);    
                        String astrumInvalidMessage = (astrumInvalidMessageList.size() > 1 ? String.join(astrumInvalidMessageList,'\n') : astrumInvalidMessageList[0]);
                        systemDesign.ASTRUM_SQ_Calculation_Status__c = 'Invalid'; 
                        systemDesign.Astrum_Invalid_SQ_Error_Message__c = astrumInvalidMessage;
                    }
                    if(nrgInvalidSQMessage.size() > 0)
                    {
                        List<String> nrgInvalidMessageList = new List<String>(nrgInvalidSQMessage);    
                        String nrgInvalidMessage = (nrgInvalidMessageList.size() > 1 ? String.join(nrgInvalidMessageList,'\n') : nrgInvalidMessageList[0]);
                        systemDesign.NRG_SQ_Calculation_Status__c = 'Invalid'; 
                        systemDesign.NRG_Invalid_SQ_Error_Message__c = nrgInvalidMessage;
                    }
                    if(cpreInvalidSQMessage.size() > 0)
                    {
                        List<String> cpreInvalidMessageList = new List<String>(cpreInvalidSQMessage);    
                        String cpreInvalidMessage = (cpreInvalidMessageList.size() > 1 ? String.join(cpreInvalidMessageList,'\n') : cpreInvalidMessageList[0]);
                        systemDesign.CPRE_SQ_Calculation_Status__c = 'Invalid'; 
                        systemDesign.CPRE_Invalid_SQ_Error_Message__c = cpreInvalidMessage;
                    }
                }
                update systemDesigns;
            }
        }

    }
   
    private void defaultUtilityCompany(Property__c[] newProperties)
    {
        /*Map<String,ID> UtilityMap = new Map<String,ID>();
        Set<String> zipCodesList   = new Set<String>();
        List<Property__c> propsToUpdate = new List<Property__c>();
        for(Property__c prop : newProperties)
        {
            if(prop.Utility_Company_Master__c == null && prop.Property_Zip__c != null)
            {
               zipCodesList.add(prop.Property_Zip__c.subString(0,5));
               propsToUpdate.add(prop);
            }
        }
        zipCodesList.add('00000');
        if(propsToUpdate.size() > 0)
        {
            for(Utility_by_zip_code__c uc : [Select Utility_Zip_Code__c, Utility_Company_Master__c from Utility_by_zip_code__c Where Utility_Company_Master__c !=null And Utility_Zip_Code__c in :zipCodesList])
            {       
              UtilityMap.put(uc.utility_zip_code__c, uc.Utility_Company_Master__c);
            }

            Map<ID, ID> utilCompanyDefaults = new Map<ID, ID>();        //Utility Company ID --> Utility Rate Code ID
            for (Utility_Company__c urc : [SELECT Utility_Company_Master__c FROM Utility_Company__c WHERE Default_Rate_Code__c = true AND Utility_Company_Master__c IN :UtilityMap.values() LIMIT 10000]){
                utilCompanyDefaults.put(urc.Utility_Company_Master__c, urc.ID);
            }
            
            for(Property__c prop :propsToUpdate )
            {
                prop.Utility_Company_Master__c = (UtilityMap.get(prop.Property_zip__c.subString(0,5)) != null ? UtilityMap.get(prop.Property_Zip__c.subString(0,5)) : UtilityMap.get('00000'));
                prop.Utility_Company__c = utilCompanyDefaults.get(prop.Utility_Company_Master__c);
            }
        }*/    //The Utility Company and Utility Rate Code fields on Property have been deprecated    
    
    }
}