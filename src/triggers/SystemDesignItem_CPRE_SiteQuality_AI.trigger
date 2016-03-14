/* FILE: InstallLocation_CPRE_SiteQuality_BI.cls
 * AUTHOR: Rohit Jain
 * DATE: July 24, 2013
 * PURPOSE: Web Service Callout for Site Quality before Insert on SDI
 * MODIFICATION HISTORY 
 * 08/30/13 - Added NRG in same trigger. 
 */
trigger SystemDesignItem_CPRE_SiteQuality_AI on System_Design_Item__c (After Insert) 
{   
    if(Trigger.IsInsert)
    {        
              
        Id panelRecId = Schema.Sobjecttype.System_Design_Item__c.getRecordTypeInfosByName().get('Panel').getRecordTypeId();
        SiteQualitySettings__c sq = SiteQualitySettings__c.getValues('SiteQuality');
        Integer batchSize = Integer.ValueOf(sq.Batch_Size__c);       
        List<ID> panelItemIds = new List<Id>();
        List<System_Design_Item__c> panelItems = new List<System_Design_Item__c>();
        Set<Id> systemDesignIds = new Set<Id>();       
        for(System_Design_Item__c item : Trigger.New){
            if(item.RecordTypeId == panelRecId )
            {
              panelItems.add(item);
              panelItemIds.add(item.Id);
              systemDesignIds.add(item.MasterSD__c);
            }          
        }

        if(!panelItems.isEmpty())
        {
           List<System_Design__c> sysDesigns = [Select Astrum_SQ_Calculation_Status__c,NRG_SQ_Calculation_Status__C,CPRE_SQ_Calculation_Status__c
                                                  from System_Design__c Where Id in :systemDesignIds];
           for(System_Design__c sysDesign : sysDesigns)
           {
              sysDesign.Astrum_SQ_Calculation_Status__c = (sq.ASTRUM__c ? 'Processing' : 'Invalid');
              sysDesign.NRG_SQ_Calculation_Status__c = (sq.NRG__c ? 'Processing' : 'Invalid');
              sysDesign.CPRE_SQ_Calculation_Status__c = (sq.CPRE__c ? 'Processing' : 'Invalid');            
           }
           update sysDesigns;

           if(sq.isHerokuProcess__c)
           {

             // Future Call   
             System.debug('**********Heroku Processing***********');
             List<Id> sdIds = new List<Id>(systemDesignIds);
             String sdText = (sdIds.size() > 1 ? String.join(sdIds,';') : sdIds[0]);
             String sdiText = (panelItemIds.size() > 1 ? String.join(panelItemIds,';') : String.valueOf(panelItemIds[0]));                  
             SiteQualityCalculator.updateSiteQualityForItem(sdiText,sdText,sq.CPRE__c,sq.NRG__c,sq.ASTRUM__c,true); 
           }
           else
           { 

             if(panelItems.size() > batchSize)
             {
                 // batch Process
                 SystemDesignSiteQualityBatch pwb = new SystemDesignSiteQualityBatch ();              
                 pwb.isCPRE = sq.CPRE__c;
                 pwb.isNRG = sq.NRG__c;
                 pwb.isAstrum = sq.ASTRUM__c;
                 pwb.sysDesigns = new List<Id>(systemDesignIds);
                 pwb.sdItems = panelItems;
                 Integer nrgbatchSize = Integer.ValueOf(sq.NRG_Batch_Size__c);
                 pwb.Query = 'Select Name,MasterSD__c,System_Design_Array__r.System_Design__r.Name,Sunnova_Site_Quality__c,Panel_Annual_Solar_Access__c,NRG_PV_Watts_De_Rate__c,NRG_Site_Quality__c '
                             + ',System_Design_Array__r.System_Design__r.Property__r.Property_ZIP__c '
                             + ' ,System_Design_Array__r.System_Design__r.Property__r.QAS_Latitude__c '
                             + ' ,System_Design_Array__r.System_Design__r.Property__r.QAS_Longitude__c'
                             + ' ,System_Design_Array__r.System_Design__r.Property__r.Latitude__c'
                             + ' ,System_Design_Array__r.System_Design__r.Property__r.Longitude__c'
                             + ' ,System_Design_Array__r.System_Design__r.Property__r.Snow_De_Rate_kWh_y_kW__c'
                             + ',System_Design_Array__r.System_Design__r.Property__r.Property_State__c,CPRE_Azimuth__c '
                             + ',Panel_Pitch__c,Sunnova_Upgrade_factor__c,Panel_Azimuth__c, System_Design_Array__r.System_Design__r.Property__r.Utility_Company__c '
                             + ',System_Design_Array__r.System_Design__r.Property__r.Community_Program_Offer__r.OneRoof_SiteQuality__c ' 
                             + ',Astrum_PV_Watts_Derate__c,Astrum_PV_Watts_Optimal_Site_Quality__c,Astrum_PV_Watts_Site_Quality__c '
                             + ',Astrum_Balance_of_System_Derate_Text__c,Astrum_PV_Watts_Derate_Text__c '
                             + ',Astrum_Balance_of_System_Derate__c,Inverter_and_Transformer_Efficiency__c '
                             + ',Inverter_Transformer_Efficiency_Text__c,Snow_Derate_Text__c,Snow_De_Rate_kWh_y_kW__c'
                             + ' ,NRG_Balance_of_System_Derate__c,NRG_PV_Watts_Derate_Text__c,NRG_Balance_of_System_Derate_Text__c,Rated_Output_kW__c '
                             + ' from System_Design_Item__c Where Id in :sdItems ';
                 System.debug('#'+pwb.Query);            
                 //pwb.sdItems = sditems;             
                 Id batchId = Database.executeBatch(pwb, nrgbatchSize);  
             }
             else
             {
                 // Future Call   
                 List<Id> sdIds = new List<Id>(systemDesignIds);
                 String sdText = (sdIds.size() > 1 ? String.join(sdIds,';') : sdIds[0]);
                 String sdiText = (panelItemIds.size() > 1 ? String.join(panelItemIds,';') : String.valueOf(panelItemIds[0]));                  
                 SiteQualityCalculator.updateSiteQualityForItem(sdiText,sdText,sq.CPRE__c,sq.NRG__c,sq.ASTRUM__c,false);
             }          
           }  
        }
    }
}