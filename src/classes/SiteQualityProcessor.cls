/*
    01/09/15  DK  Made class "without sharing". Peviously had no sharing signature.
    02/09/15 RJ Update for UtilityRate Code to look from UtilityService
*/
public without sharing class SiteQualityProcessor {
    
    Public static void processSiteQuality(List<System_Design_Item__c> items,Map<Id,String> sdCpreErrors
                                        ,Map<Id,String> sdNRGErrors,Map<Id,String> sdAstrumErrors,Boolean isCPRE , Boolean isNRG, Boolean isAstrum)
    {
        processSQ(items,sdCpreErrors,sdNRGErrors,sdAstrumErrors,isCPRE , isNRG, isAstrum);
    }   

    Public static void processSiteQuality(List<System_Design_Item__c> items,List<Id> systemDesigns,Boolean isCPRE , Boolean isNRG, Boolean isAstrum)
    {
        
        Map<Id,String> sdCpreErrors = new Map<Id,String>(); 
        Map<Id,String> sdNRGErrors = new Map<Id,String>();
        Map<Id,String> sdAstrumErrors = new Map<Id,String>();

        processSQ(items,sdCpreErrors,sdNRGErrors,sdAstrumErrors,isCPRE , isNRG, isAstrum);
           
        Map<Id,System_Design__c> systemDesignUpdates = new Map<Id,System_Design__c>();
        for(Id sdId : systemDesigns)
        {
            String astrumStatus = null;
            String astrumMessage = null;
            String nrgStatus = null;
            String nrgMessage = null;
            String cpreStatus = null;
            String cpreMessage = null;

            if(sdAstrumErrors.get(sdId) != null)
            {
                astrumStatus = 'Invalid';
                astrumMessage = sdAstrumErrors.get(sdId);
            }    
            else
            {
                if(isAstrum)
                {
                    astrumStatus = 'Valid'; 
                    astrumMessage = '';   
                }      
            } 
            if(astrumStatus != null)
            {
                if(systemDesignUpdates.get(sdId) != null)
                {
                    systemDesignUpdates.get(sdId).Astrum_SQ_Calculation_Status__c = astrumStatus;
                    systemDesignUpdates.get(sdId).Astrum_Invalid_SQ_Error_Message__c = astrumMessage;                                 
                }                
                else
                {
                   systemDesignUpdates.put(sdId, new System_Design__c(Id= sdId, Astrum_SQ_Calculation_Status__c = astrumStatus
                        ,Astrum_Invalid_SQ_Error_Message__c = astrumMessage));
                }
            }

            if(sdNRGErrors.get(sdId) != null)
            {
                nrgStatus = 'Invalid';
                nrgMessage = sdNRGErrors.get(sdId);
            }    
            else
            {
                if(isNRG)
                {
                    nrgStatus = 'Valid'; 
                    nrgMessage = '';   
                }      
            } 
            if(nrgStatus != null)
            {
                if(systemDesignUpdates.get(sdId) != null)
                {
                    systemDesignUpdates.get(sdId).NRG_SQ_Calculation_Status__c = nrgStatus;
                    systemDesignUpdates.get(sdId).NRG_Invalid_SQ_Error_Message__c = nrgMessage;                 
                }                
                else
                {
                    systemDesignUpdates.put(sdId, new System_Design__c(Id= sdId,NRG_SQ_Calculation_Status__c = nrgStatus
                        ,NRG_Invalid_SQ_Error_Message__c = nrgMessage));  
                }
            }

            if(sdCPREErrors.get(sdId) != null)
            {
                cpreStatus = 'Invalid';
                cpreMessage = sdCPREErrors.get(sdId);
            }    
            else
            {
                if(isCPRE)
                {
                    cpreStatus = 'Valid'; 
                    cpreMessage = '';   
                }      
            } 
            if(cpreStatus != null)
            {
                if(systemDesignUpdates.get(sdId) != null)
                {
                    systemDesignUpdates.get(sdId).CPRE_SQ_Calculation_Status__c = cpreStatus;
                    systemDesignUpdates.get(sdId).CPRE_Invalid_SQ_Error_Message__c = cpreMessage;                     
                }                
                else
                {
                    systemDesignUpdates.put(sdId, new System_Design__c(Id= sdId, CPRE_SQ_Calculation_Status__c = cpreStatus
                        ,CPRE_Invalid_SQ_Error_Message__c = cpreMessage));    
                }
            }
        }

        update systemDesignUpdates.values();  
    }

    private static void processSQ(List<System_Design_Item__c> items,Map<Id,String> sdCpreErrors,Map<Id,String> sdNRGErrors,Map<Id,String> sdAstrumErrors,Boolean isCPRE , Boolean isNRG, Boolean isAstrum)
    {
        Double sunnovaSiteQuality = null;
        Double NRGsiteQuality = null;        
        Boolean updateFlag = false;          
        
        List<String> requiredFields = New List<String>();
        

        List<System_Design_Item__c> itemsToUpdate = new List<System_Design_Item__c>();

        for(System_Design_Item__c item: items)
        {           
            updateFlag = false;

            String latitude = (item.System_Design_Array__r.System_Design__r.Property__r.Confirmed_Location__Latitude__s != null ? String.valueOf(item.System_Design_Array__r.System_Design__r.Property__r.Confirmed_Location__Latitude__s) : item.System_Design_Array__r.System_Design__r.Property__r.QAS_Latitude__c != null ? item.System_Design_Array__r.System_Design__r.Property__r.QAS_Latitude__c : String.valueOf(item.System_Design_Array__r.System_Design__r.Property__r.Latitude__c)  ) ;  
            String longitude = (item.System_Design_Array__r.System_Design__r.Property__r.Confirmed_Location__Longitude__s != null ? String.valueOf(item.System_Design_Array__r.System_Design__r.Property__r.Confirmed_Location__Longitude__s) : item.System_Design_Array__r.System_Design__r.Property__r.QAS_Longitude__c != null ? item.System_Design_Array__r.System_Design__r.Property__r.QAS_Longitude__c : String.valueOf(item.System_Design_Array__r.System_Design__r.Property__r.Longitude__c)  ) ;  

            String postalCode = ((item.System_Design_Array__r.System_Design__r.Property__r.Property_zip__c != null) ? item.System_Design_Array__r.System_Design__r.Property__r.Property_zip__c.subString(0,5) : null) ;     
            String state = item.System_Design_Array__r.System_Design__r.Property__r.Property_State__c;
            String cpreAzimuth = ((item.CPRE_Azimuth__c != null) ? String.valueOf(item.CPRE_Azimuth__c) : null) ;     
            String Azimuth = ((item.Panel_Azimuth__c != null) ? String.ValueOf(Integer.ValueOf(item.Panel_Azimuth__c)) : null) ;  
            String Tilt = ((item.Panel_Pitch__c != null) ? String.ValueOf(Integer.ValueOf(item.Panel_Pitch__c)) : null) ;  
            String shading = ((item.Panel_Annual_Solar_Access__c != null) ? String.valueOf(item.Panel_Annual_Solar_Access__c) : null) ;

            String utilityCompany;
            if (item.System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Solar_Compensation_Method__c == 'Net Metering'){
                utilityCompany = item.System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_After_Solar__c;
            } else if (item.System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Solar_Compensation_Method__c == 'VOST'){
                utilityCompany = item.System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Value_of_Solar_Tariff__c;
            }

            //String utilityCompany = item.System_Design_Array__r.System_Design__r.Property__r.Utility_Company__c ;
            
            //Sunnova
            if(isCPRE)
            {
                if( postalCode == null)
                {
                   requiredFields.add('Postal Code'); 
                }                
                if(state == null)
                {
                    requiredFields.add('State'); 
                }
                if(cpreAzimuth == null)
                {
                    requiredFields.add('CPRE Azimuth'); 
                }
                if(Tilt == null)
                {
                    requiredFields.add('Tilt');   
                }
                if(shading == null)
                {
                    requiredFields.add('Annual Solar Access');   
                }
                try {          
                    if(requiredFields.size() == 0)  
                    {    
                        sunnovaSiteQuality = CleanPowerEstimator_ServiceClient.getSiteQuality(PostalCode, State,CpreAzimuth,Tilt,Shading); 
                        if (sunnovaSiteQuality != null)
                        {
                            if(item.Sunnova_Upgrade_factor__c != null && item.Sunnova_Upgrade_factor__c != 0)
                            {
                                item.Sunnova_Site_Quality__c = sunnovaSiteQuality * item.Sunnova_Upgrade_factor__c;        
                            }   
                            else
                            {
                                item.Sunnova_Site_Quality__c = sunnovaSiteQuality ;
                            }
                            updateFlag = true;
                        }   
                    }
                    else
                    {                        
                        String itemError = 'Missing the following required fields to get CPRE SQ for '+item.Name+ ' - '+ String.join(requiredFields,',');
                        if(sdCpreErrors.get(item.MasterSD__c) != null)
                        {
                            sdCpreErrors.put(item.MasterSD__c,sdCpreErrors.get(item.MasterSD__c) + '\n' + itemError) ;
                        }
                        else
                        {
                            sdCpreErrors.put(item.MasterSD__c,itemError); 
                        }
                    }
                }
                catch(Exception e)
                {
                    String itemError = 'Unexpected error to get CPRE SQ for '+item.Name+ ' - '+ e.getMessage();
                    if(sdCpreErrors.get(item.MasterSD__c) != null)
                    {
                        sdCpreErrors.put(item.MasterSD__c,sdCpreErrors.get(item.MasterSD__c) + '\n' + itemError) ;
                    }
                    else
                    {
                        sdCpreErrors.put(item.MasterSD__c,itemError); 
                    }

                }    
                requiredFields.clear();
            }
            
            // NRG   
            if(isNRG)
            {
                if(Azimuth == null)
                {
                    requiredFields.add('Azimuth'); 
                }
                if(Tilt == null)
                {
                    requiredFields.add('Tilt');   
                }                
                if(item.NRG_PV_Watts_De_Rate__c == null || item.NRG_PV_Watts_De_Rate__c == 0)
                {
                    requiredFields.add('NRG PVWatts Derate');    
                }
                if(shading == null)
                {
                    requiredFields.add('Annual Solar Access');   
                }

                if(state != null && state == 'NJ')
                {
                    if( postalCode == null)
                    {
                        requiredFields.add('Postal Code'); 
                    } 

                    if(requiredFields.size() == 0)  
                    {    
                        NRGsiteQuality = PVWatts_ServiceClient.getNRGNJSiteQuality(item.NRG_PV_Watts_De_Rate__c.toPlainString(),Tilt,Azimuth,postalCode);  
                        if (NRGsiteQuality != null) {            
                            item.NRG_Site_Quality__c = NRGsiteQuality ; 
                            updateFlag = true; 
                        }   
                    }
                    else
                    {                        
                        String itemError = 'Missing the following required fields to get NRG NJ SQ for '+item.Name+ ' - '+ String.join(requiredFields,',');
                        if(sdNRGErrors.get(item.MasterSD__c) != null)
                        {
                            sdNRGErrors.put(item.MasterSD__c,sdNRGErrors.get(item.MasterSD__c) + '\n' + itemError) ;
                        }
                        else
                        {
                            sdNRGErrors.put(item.MasterSD__c,itemError); 
                        }
                        
                    }
                }           
                else
                {
                    if(Latitude == null)
                    {
                        requiredFields.add('Latitude'); 
                    }
                    if(Longitude == null)
                    {
                        requiredFields.add('Longitude');   
                    }                    
                    if(utilityCompany == null)
                    {
                        requiredFields.add('Utility Rate Code');  
                    }

                    if(requiredFields.size() == 0)  
                    {    
                        try{
                            item = PVWatts_ServiceClient.getSiteQualityHourly(item,'NRG');   
                            updateFlag = true;  
                        }
                        catch(Exception e)
                        {
                            String itemError = 'Error to get NRG SQ for '+item.Name+ ' - '+ e.getMessage();
                            if(sdNRGErrors.get(item.MasterSD__c) != null)
                            {
                                sdNRGErrors.put(item.MasterSD__c,sdNRGErrors.get(item.MasterSD__c) + '\n' + itemError) ;
                            }
                            else
                            {
                                sdNRGErrors.put(item.MasterSD__c,itemError); 
                            }
                        }    
                    }
                    else
                    {                        
                        String itemError = 'Missing the following required fields to get NRG SQ for '+item.Name+ ' - '+ String.join(requiredFields,',');
                        if(sdNRGErrors.get(item.MasterSD__c) != null)
                        {
                            sdNRGErrors.put(item.MasterSD__c,sdNRGErrors.get(item.MasterSD__c) + '\n' + itemError) ;
                        }
                        else
                        {
                            sdNRGErrors.put(item.MasterSD__c,itemError); 
                        }                        
                    }
                }
                requiredFields.clear();
            }    
            
            // Astrum
            if(isAstrum)
            {
                if(Azimuth == null)
                {
                    requiredFields.add('Azimuth'); 
                }
                if(Tilt == null)
                {
                    requiredFields.add('Tilt');   
                }
                if(shading == null)
                {
                    requiredFields.add('Annual Solar Access');   
                }
                if(Latitude == null)
                {
                    requiredFields.add('Latitude'); 
                }
                if(Longitude == null)
                {
                    requiredFields.add('Longitude');   
                }
                if(item.Astrum_PV_Watts_DeRate__c == null || item.Astrum_PV_Watts_DeRate__c == 0)
                {
                    requiredFields.add('Astrum PVWatts Derate');    
                }
                if(utilityCompany == null)
                {
                    requiredFields.add('Utility Rate Code');  
                }    
                if(requiredFields.size() == 0)  
                {    
                    try{
                        item = PVWatts_ServiceClient.getSiteQualityHourly(item,'ASTRUM');   
                        updateFlag = true;  
                    }
                    catch(Exception e)
                    {
                        String itemError = 'Error to get Astrum SQ for '+item.Name+ ' - '+ e.getMessage();
                        if(sdAstrumErrors.get(item.MasterSD__c) != null)
                        {
                            sdAstrumErrors.put(item.MasterSD__c,sdAstrumErrors.get(item.MasterSD__c) + '\n' + itemError) ;
                        }
                        else
                        {
                            sdAstrumErrors.put(item.MasterSD__c,itemError); 
                        }                        
                    }    
                }
                else
                {                        
                    String itemError = 'Missing the following required fields to get Astrum SQ for '+item.Name+ ' - '+ String.join(requiredFields,',');
                    if(sdAstrumErrors.get(item.MasterSD__c) != null)
                    {
                        sdAstrumErrors.put(item.MasterSD__c,sdAstrumErrors.get(item.MasterSD__c) + '\n' + itemError) ;
                    }
                    else
                    {
                        sdAstrumErrors.put(item.MasterSD__c,itemError); 
                    }                         
                }  
                requiredFields.clear();      
            } 

            if(updateFlag)
            {
                itemsToUpdate.add(item);
            }
        }

        if(itemsToUpdate.size() > 0)
        {
            update itemsToUpdate;
        }
    }

    Public static void processBulkSiteQuality(List<System_Design_Item__c> items,List<Id> systemDesigns,Boolean isCPRE , Boolean isNRG, Boolean isAstrum)
    {
        
        Map<Id,String> sdCpreErrors = new Map<Id,String>(); 
        Map<Id,String> sdNRGErrors = new Map<Id,String>();
        Map<Id,String> sdAstrumErrors = new Map<Id,String>();

        processBulkSQ(items,sdCpreErrors,sdNRGErrors,sdAstrumErrors,isCPRE , isNRG, isAstrum);
           
        Map<Id,System_Design__c> systemDesignUpdates = new Map<Id,System_Design__c>();
        for(Id sdId : systemDesigns)
        {
            String astrumStatus = null;
            String astrumMessage = null;
            String nrgStatus = null;
            String nrgMessage = null;
            String cpreStatus = null;
            String cpreMessage = null;

            if(sdAstrumErrors.get(sdId) != null)
            {
                astrumStatus = 'Invalid';
                astrumMessage = sdAstrumErrors.get(sdId);
            }    
            else
            {
                if(isAstrum)
                {
                    astrumStatus = 'Valid'; 
                    astrumMessage = '';   
                }      
            } 
            if(astrumStatus != null)
            {
                if(systemDesignUpdates.get(sdId) != null)
                {
                    systemDesignUpdates.get(sdId).Astrum_SQ_Calculation_Status__c = astrumStatus;
                    systemDesignUpdates.get(sdId).Astrum_Invalid_SQ_Error_Message__c = astrumMessage;                                 
                }                
                else
                {
                   systemDesignUpdates.put(sdId, new System_Design__c(Id= sdId, Astrum_SQ_Calculation_Status__c = astrumStatus
                        ,Astrum_Invalid_SQ_Error_Message__c = astrumMessage));
                }
            }

            if(sdNRGErrors.get(sdId) != null)
            {
                nrgStatus = 'Invalid';
                nrgMessage = sdNRGErrors.get(sdId);
            }    
            else
            {
                if(isNRG)
                {
                    nrgStatus = 'Valid'; 
                    nrgMessage = '';   
                }      
            } 
            if(nrgStatus != null)
            {
                if(systemDesignUpdates.get(sdId) != null)
                {
                    systemDesignUpdates.get(sdId).NRG_SQ_Calculation_Status__c = nrgStatus;
                    systemDesignUpdates.get(sdId).NRG_Invalid_SQ_Error_Message__c = nrgMessage;                 
                }                
                else
                {
                    systemDesignUpdates.put(sdId, new System_Design__c(Id= sdId,NRG_SQ_Calculation_Status__c = nrgStatus
                        ,NRG_Invalid_SQ_Error_Message__c = nrgMessage));  
                }
            }

            if(sdCPREErrors.get(sdId) != null)
            {
                cpreStatus = 'Invalid';
                cpreMessage = sdCPREErrors.get(sdId);
            }    
            else
            {
                if(isCPRE)
                {
                    cpreStatus = 'Valid'; 
                    cpreMessage = '';   
                }      
            } 
            if(cpreStatus != null)
            {
                if(systemDesignUpdates.get(sdId) != null)
                {
                    systemDesignUpdates.get(sdId).CPRE_SQ_Calculation_Status__c = cpreStatus;
                    systemDesignUpdates.get(sdId).CPRE_Invalid_SQ_Error_Message__c = cpreMessage;                     
                }                
                else
                {
                    systemDesignUpdates.put(sdId, new System_Design__c(Id= sdId, CPRE_SQ_Calculation_Status__c = cpreStatus
                        ,CPRE_Invalid_SQ_Error_Message__c = cpreMessage));    
                }
            }
        }

        update systemDesignUpdates.values();  
    }

    private static void processBulkSQ(List<System_Design_Item__c> items,Map<Id,String> sdCpreErrors,Map<Id,String> sdNRGErrors,Map<Id,String> sdAstrumErrors,Boolean isCPRE , Boolean isNRG, Boolean isAstrum)
    {
        Double sunnovaSiteQuality = null;
        Double NRGsiteQuality = null;        
        Boolean updateFlag = false;    
        List<System_Design_Item__c>   processAstrumItemList =   new List<System_Design_Item__c>();
        Map<System_Design_Item__c,String>   processAstrumItemMap =   new Map<System_Design_Item__c,String>();
        List<System_Design_Item__c>   processNRGItemList =   new List<System_Design_Item__c>(); 
        Map<System_Design_Item__c,String>   processNRGItemMap =   new Map<System_Design_Item__c,String>();
        
        List<String> requiredFields = New List<String>();
        

        List<System_Design_Item__c> itemsToUpdate = new List<System_Design_Item__c>();

        for(System_Design_Item__c item: items)
        {           
            updateFlag = false;

            String latitude = (item.System_Design_Array__r.System_Design__r.Property__r.Confirmed_Location__Latitude__s != null ? String.valueOf(item.System_Design_Array__r.System_Design__r.Property__r.Confirmed_Location__Latitude__s) : item.System_Design_Array__r.System_Design__r.Property__r.QAS_Latitude__c != null ? item.System_Design_Array__r.System_Design__r.Property__r.QAS_Latitude__c : String.valueOf(item.System_Design_Array__r.System_Design__r.Property__r.Latitude__c)  ) ;  
            String longitude = (item.System_Design_Array__r.System_Design__r.Property__r.Confirmed_Location__Longitude__s != null ? String.valueOf(item.System_Design_Array__r.System_Design__r.Property__r.Confirmed_Location__Longitude__s) : item.System_Design_Array__r.System_Design__r.Property__r.QAS_Longitude__c != null ? item.System_Design_Array__r.System_Design__r.Property__r.QAS_Longitude__c : String.valueOf(item.System_Design_Array__r.System_Design__r.Property__r.Longitude__c)  ) ;  
            String postalCode = ((item.System_Design_Array__r.System_Design__r.Property__r.Property_zip__c != null) ? item.System_Design_Array__r.System_Design__r.Property__r.Property_zip__c.subString(0,5) : null) ;     
            String state = item.System_Design_Array__r.System_Design__r.Property__r.Property_State__c;
            String cpreAzimuth = ((item.CPRE_Azimuth__c != null) ? String.valueOf(item.CPRE_Azimuth__c) : null) ;     
            String Azimuth = ((item.Panel_Azimuth__c != null) ? String.ValueOf(Integer.ValueOf(item.Panel_Azimuth__c)) : null) ;  
            String Tilt = ((item.Panel_Pitch__c != null) ? String.ValueOf(Integer.ValueOf(item.Panel_Pitch__c)) : null) ;  
            String shading = ((item.Panel_Annual_Solar_Access__c != null) ? String.valueOf(item.Panel_Annual_Solar_Access__c) : null) ;

            String utilityCompany;
            if (item.System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Solar_Compensation_Method__c == 'Net Metering'){
                utilityCompany = item.System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_After_Solar__c;
            } else if (item.System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Solar_Compensation_Method__c == 'VOST'){
                utilityCompany = item.System_Design_Array__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Value_of_Solar_Tariff__c;
            }

            //String utilityCompany = item.System_Design_Array__r.System_Design__r.Property__r.Utility_Company__c ;
            
            //Sunnova
            if(isCPRE)
            {
                if( postalCode == null)
                {
                   requiredFields.add('Postal Code'); 
                }                
                if(state == null)
                {
                    requiredFields.add('State'); 
                }
                if(cpreAzimuth == null)
                {
                    requiredFields.add('CPRE Azimuth'); 
                }
                if(Tilt == null)
                {
                    requiredFields.add('Tilt');   
                }
                if(shading == null)
                {
                    requiredFields.add('Annual Solar Access');   
                }
                try {          
                    if(requiredFields.size() == 0)  
                    {    
                        sunnovaSiteQuality = CleanPowerEstimator_ServiceClient.getSiteQuality(PostalCode, State,CpreAzimuth,Tilt,Shading); 
                        if (sunnovaSiteQuality != null)
                        {
                            if(item.Sunnova_Upgrade_factor__c != null && item.Sunnova_Upgrade_factor__c != 0)
                            {
                                item.Sunnova_Site_Quality__c = sunnovaSiteQuality * item.Sunnova_Upgrade_factor__c;        
                            }   
                            else
                            {
                                item.Sunnova_Site_Quality__c = sunnovaSiteQuality ;
                            }
                            updateFlag = true;
                        }   
                    }
                    else
                    {                        
                        String itemError = 'Missing the following required fields to get CPRE SQ for '+item.Name+ ' - '+ String.join(requiredFields,',');
                        if(sdCpreErrors.get(item.MasterSD__c) != null)
                        {
                            sdCpreErrors.put(item.MasterSD__c,sdCpreErrors.get(item.MasterSD__c) + '\n' + itemError) ;
                        }
                        else
                        {
                            sdCpreErrors.put(item.MasterSD__c,itemError); 
                        }
                    }
                }
                catch(Exception e)
                {
                    String itemError = 'Unexpected error to get CPRE SQ for '+item.Name+ ' - '+ e.getMessage();
                    if(sdCpreErrors.get(item.MasterSD__c) != null)
                    {
                        sdCpreErrors.put(item.MasterSD__c,sdCpreErrors.get(item.MasterSD__c) + '\n' + itemError) ;
                    }
                    else
                    {
                        sdCpreErrors.put(item.MasterSD__c,itemError); 
                    }

                }    
                requiredFields.clear();
            }
            
            // NRG   
            if(isNRG)
            {
                if(Azimuth == null)
                {
                    requiredFields.add('Azimuth'); 
                }
                if(Tilt == null)
                {
                    requiredFields.add('Tilt');   
                }                
                if(item.NRG_PV_Watts_De_Rate__c == null || item.NRG_PV_Watts_De_Rate__c == 0)
                {
                    requiredFields.add('NRG PVWatts Derate');    
                }
                if(shading == null)
                {
                    requiredFields.add('Annual Solar Access');   
                }

                if(state != null && state == 'NJ')
                {
                    if( postalCode == null)
                    {
                        requiredFields.add('Postal Code'); 
                    } 

                    if(requiredFields.size() == 0)  
                    {    
                        NRGsiteQuality = PVWatts_ServiceClient.getNRGNJSiteQuality(item.NRG_PV_Watts_De_Rate__c.toPlainString(),Tilt,Azimuth,postalCode);  
                        if (NRGsiteQuality != null) {            
                            item.NRG_Site_Quality__c = NRGsiteQuality ; 
                            updateFlag = true; 
                        }   
                    }
                    else
                    {                        
                        String itemError = 'Missing the following required fields to get NRG NJ SQ for '+item.Name+ ' - '+ String.join(requiredFields,',');
                        if(sdNRGErrors.get(item.MasterSD__c) != null)
                        {
                            sdNRGErrors.put(item.MasterSD__c,sdNRGErrors.get(item.MasterSD__c) + '\n' + itemError) ;
                        }
                        else
                        {
                            sdNRGErrors.put(item.MasterSD__c,itemError); 
                        }
                        
                    }
                }           
                else
                {
                    if(Latitude == null)
                    {
                        requiredFields.add('Latitude'); 
                    }
                    if(Longitude == null)
                    {
                        requiredFields.add('Longitude');   
                    }                    
                    if(utilityCompany == null)
                    {
                        requiredFields.add('Utility Rate Code');  
                    }

                    if(requiredFields.size() == 0)  
                    {    
                        processNRGItemList.add(item);
                        /*try{
                            item = PVWatts_ServiceClient.getSiteQualityHourly(item,'NRG');   
                            updateFlag = true;  
                        }
                        catch(Exception e)
                        {
                            String itemError = 'Error to get NRG SQ for '+item.Name+ ' - '+ e.getMessage();
                            if(sdNRGErrors.get(item.MasterSD__c) != null)
                            {
                                sdNRGErrors.put(item.MasterSD__c,sdNRGErrors.get(item.MasterSD__c) + '\n' + itemError) ;
                            }
                            else
                            {
                                sdNRGErrors.put(item.MasterSD__c,itemError); 
                            }
                        } */   
                    }
                    else
                    {                        
                        String itemError = 'Missing the following required fields to get NRG SQ for '+item.Name+ ' - '+ String.join(requiredFields,',');
                        if(sdNRGErrors.get(item.MasterSD__c) != null)
                        {
                            sdNRGErrors.put(item.MasterSD__c,sdNRGErrors.get(item.MasterSD__c) + '\n' + itemError) ;
                        }
                        else
                        {
                            sdNRGErrors.put(item.MasterSD__c,itemError); 
                        }                        
                    }
                }
                requiredFields.clear();
            }    
            
            // Astrum
            if(isAstrum)
            {
                if(Azimuth == null)
                {
                    requiredFields.add('Azimuth'); 
                }
                if(Tilt == null)
                {
                    requiredFields.add('Tilt');   
                }
                if(shading == null)
                {
                    requiredFields.add('Annual Solar Access');   
                }
                if(Latitude == null)
                {
                    requiredFields.add('Latitude'); 
                }
                if(Longitude == null)
                {
                    requiredFields.add('Longitude');   
                }
                if(item.Astrum_PV_Watts_DeRate__c == null || item.Astrum_PV_Watts_DeRate__c == 0)
                {
                    requiredFields.add('Astrum PVWatts Derate');    
                }
                if(utilityCompany == null)
                {
                    requiredFields.add('Utility Rate Code');  
                }    
                if(requiredFields.size() == 0)  
                {    
                    //try{
                        //item = PVWatts_ServiceClient.getSiteQualityHourly(item,'ASTRUM');   
                        processAstrumItemList.add(item);
                        //updateFlag = true;  
                    /*}
                    catch(Exception e)
                    {
                        String itemError = 'Error to get Astrum SQ for '+item.Name+ ' - '+ e.getMessage();
                        if(sdAstrumErrors.get(item.MasterSD__c) != null)
                        {
                            sdAstrumErrors.put(item.MasterSD__c,sdAstrumErrors.get(item.MasterSD__c) + '\n' + itemError) ;
                        }
                        else
                        {
                            sdAstrumErrors.put(item.MasterSD__c,itemError); 
                        }                        
                    } */   
                }
                else
                {                        
                    String itemError = 'Missing the following required fields to get Astrum SQ for '+item.Name+ ' - '+ String.join(requiredFields,',');
                    if(sdAstrumErrors.get(item.MasterSD__c) != null)
                    {
                        sdAstrumErrors.put(item.MasterSD__c,sdAstrumErrors.get(item.MasterSD__c) + '\n' + itemError) ;
                    }
                    else
                    {
                        sdAstrumErrors.put(item.MasterSD__c,itemError); 
                    }                         
                }  
                requiredFields.clear();      
            } 

            if(updateFlag)
            {
                itemsToUpdate.add(item);
            }
        }

        if(processAstrumItemList.size() > 0)
        {
            processAstrumItemMap = PVWatts_ServiceClient.getBulkSiteQualityHourly(processAstrumItemList,'ASTRUM');  
            processAstrumItemList.clear();
            //processAstrumItemList = processAstrumItemMap.keySet();
        }
        if(processNRGItemList.size() > 0)
        {
            processNRGItemMap = PVWatts_ServiceClient.getBulkSiteQualityHourly(processNRGItemList,'NRG');
            processNRGItemList.clear();
        }

        if(processAstrumItemMap.size() > 0)
        {
            for(System_Design_Item__c item : processAstrumItemMap.keySet())
            {
                if(processAstrumItemMap.get(item)  != '')
                {
                    if(sdAstrumErrors.get(item.MasterSD__c) != null)
                    {
                        sdAstrumErrors.put(item.MasterSD__c,sdAstrumErrors.get(item.MasterSD__c) + '\n' + processAstrumItemMap.get(item)) ;
                    }
                    else
                    {
                        sdAstrumErrors.put(item.MasterSD__c,processAstrumItemMap.get(item)); 
                    }    
                }   
                else
                {
                    processAstrumItemList.add(item);
                }  
            }
            if(processAstrumItemList.size() > 0)
            {
                update processAstrumItemList;
            }
        }
        if(processNRGItemMap.size() > 0)
        {
            for(System_Design_Item__c item : processNRGItemMap.keySet())
            {
                if(processNRGItemMap.get(item)  != '')
                {
                    if(sdNRGErrors.get(item.MasterSD__c) != null)
                    {
                        sdNRGErrors.put(item.MasterSD__c,sdNRGErrors.get(item.MasterSD__c) + '\n' + processNRGItemMap.get(item)) ;
                    }
                    else
                    {
                        sdNRGErrors.put(item.MasterSD__c,processNRGItemMap.get(item)); 
                    }    
                }   
                else
                {
                    processNRGItemList.add(item);
                }  
            }
            if(processNRGItemList.size() > 0)
            {
                update processNRGItemList;
            }
        }
        if(itemsToUpdate.size() > 0)
        {
            update itemsToUpdate;
        }


    }

}