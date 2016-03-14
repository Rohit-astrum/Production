/* FILE: SystemDesignSiteQualityBatch.cls
 * AUTHOR: Rohit Jain
 * DATE: Sep 24, 2013
 * PURPOSE: batch to get CPRE Site Quality from System Design
 *   to invoke: SystemDesignSiteQualityBatch pwb = new SystemDesignSiteQualityBatch();
 *          Id batchId = Database.executeBatch(pwb, 10); //must be 10 - callout governor limit
 * MODIFICATION HISTORY
 *
 */

global class SystemDesignSiteQualityBatch implements Database.Batchable<SObject>, Database.AllowsCallouts,Database.Stateful {
    
    Public String Query;
    Public Boolean isCPRE;
    Public Boolean isNRG;
    Public Boolean isAstrum;
    Public List<Id> sysDesigns;
    Public List<System_Design_Item__c> sdItems;     

    global Map<Id,String> sdCpreErrors = new Map<Id,String>(); 
    global Map<Id,String> sdNRGErrors = new Map<Id,String>();
    global Map<Id,String> sdAstrumErrors = new Map<Id,String>();    

    global Database.QueryLocator start(Database.BatchableContext bc) {       
        return Database.getQueryLocator(
           Query
        );
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<System_Design_Item__c> sysItems = (List<System_Design_Item__c>)scope;        
        execBatch(sysItems );        
    }
    
    public void execBatch(List<System_Design_Item__c> sysItems  )
    {
        SiteQualityProcessor.processSiteQuality(sysItems, sdCpreErrors,sdNRGErrors ,sdAstrumErrors, isCPRE, isNRG, isAstrum);
    }

    global void finish(Database.BatchableContext bc) {  
        Map<Id,System_Design__c> systemDesignUpdates = new Map<Id,System_Design__c>();
        for(Id sdId : sysDesigns)
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
}