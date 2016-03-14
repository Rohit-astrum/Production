public with sharing class System_Design_Clone_Controller {
   
    public System_Design__c rec {get; set;}
    private Map<Id, System_Design_Array__c> arrays {get; set;}
    private Map<Id, System_Design_Item__c> items {get; set;}

    public System_Design_Clone_Controller(ApexPages.StandardController stc){
        //query System Design Record
        
        rec = [Select 
                    s.Vent_Stack_Movement_Required__c, 
                    s.Trenching_Required__c, 
                    s.Trench_Length__c,
                    s.Total_System_Size_kW__c, 
                    s.Total_Projected_Annual_Output_kWh_y__c, 
                    s.System_Makeup__c, 
                    s.System_Panel__c,
                    s.System_Inverter__c,                
                    s.Survey__c, 
                    s.Includes_Remote_Meter__c,                                        
                    s.Property__c, 
                    s.Panel_Count__c, 
                    s.Overall_TSRF__c, 
                    s.Overall_Site_Quality__c, 
                    s.Number_of_Arrays_on_Flat_Roofs__c, 
                    s.Number_of_Arrays__c, 
                    s.Notes__c, 
                    s.Name, 
                    s.Max_Install_Location_Stories__c, 
                    s.Max_Install_Location_Pitch__c, 
                    s.Inside_Only_Conduit__c, 
                    s.Includes_Outbuilding_Installation__c, 
                    s.Id, 
                    s.Ground_Mount_Arrays__c, 
                    s.Default_CB_Panel__c,
                    s.ConnectionSentId, 
                    s.ConnectionReceivedId, 
                    s.Calculated_System_Price__c, 
                    s.Calculated_Price_per_Watt__c, 
                    s.Account_Number__c 
                From System_Design__c s
                Where s.Id = :stc.getId()];
        
        //query Arrays

        arrays = new Map<Id, System_Design_Array__c>([Select s.System_Design__c, 
                    s.Survey__c,
                    s.Special_Parts_Required__c, 
                    s.Projected_Annual_Output_kWh_y__c, 
                    s.Physical_Surface__c,                    
                    s.Panel_Count__c, 
                    s.Original_Surface_Tilt__c,
                    s.Original_Surface_Azimuth__c,
                    s.Name, 
                    s.Mounting_Type__c, 
                    s.Max_Install_Location_Stories__c, 
                    s.Max_Install_Location_Pitch__c, 
                    s.LastModifiedDate, 
                    s.LastModifiedById, 
                    s.Items_On_Flat_Roof__c, 
                    s.IsDeleted, 
                    s.Id, 
                    s.Electrical_Adder__c, 
                    s.ConnectionSentId, 
                    s.ConnectionReceivedId, 
                    s.CB_Panel__c, 
                    s.Array_Size_kW__c 
                From System_Design_Array__c s
                Where s.System_Design__c = :rec.Id]);
            
        //query System Design Items
        items = new Map<Id, System_Design_Item__c>([Select s.Tilt__c, 
                    s.TSRF_Adjustment__c, 
                    s.System_Design_Product__c, 
                    s.System_Design_Array__c, 
                    s.RecordTypeId, 
                    s.Rated_Output_kW__c, 
                    s.Quantity__c, 
                    s.Property__c, 
                    s.Projected_Annual_Output_kWh_y__c, 
                    s.Panel_Pitch__c, 
                    s.Name, 
                    s.MasterSD__c, 
                    s.Location_Stories__c, 
                    s.Location_Pitch__c, 
                    s.Install_Location__c, 
                    s.Id, 
                    s.Effective_TSRF__c, 
                    s.ConnectionSentId, 
                    s.ConnectionReceivedId 
                From System_Design_Item__c s
                WHERE s.System_Design_Array__c in :arrays.keySet()]);
    }
    
    public PageReference createClone(){
        PageReference pageReference = null;
        Savepoint sp = Database.setSavepoint();
         
        try{
            //clone and insert System Design
            System_Design__c newSD = rec.clone(false);
            insert newSD;
            
            Id clonedSDId = newSD.Id;

            Map<Id, System_Design_Array__c> clonedSDAMap = cloneToSDAMap(arrays.Values(), clonedSDId);
            
            insert(clonedSDAMap.Values());
            
            Map<Id, System_Design_Item__c> clonedSDIMap = cloneToSDIMap(items.Values(), clonedSDAMap);
            
            insert(clonedSDIMap.Values());

            pageReference = new ApexPages.StandardController(newSD).view(); 
        }catch(Exception ex){
            Database.rollback(sp);
            Apexpages.addMessages(ex);
            return null;
        }
        //direct user to cloned milestone's detail page
        return pageReference;        
    }
    
    // Clones a List of SDAs and relates them to a SD (presumably one that was just cloned).  
    // Returns a Map of Original SDA.Id to Cloned SDA Object 
    private static Map<Id, System_Design_Array__c> cloneToSDAMap(List<System_Design_Array__c> SDAList, Id SystemDesignId){
        Map<Id, System_Design_Array__c> returnMap = new Map<Id, System_Design_Array__c>();
        
        List<System_Design_Array__c> clonedSDAList = SDAList.deepClone(false);
        Integer i = 0;
        for(System_Design_Array__c SDA : clonedSDAList){
            Id oldSDAId = SDAList[i].Id;
            SDA.System_Design__c = SystemDesignId;
            returnMap.put(oldSDAId, SDA);
            i++;
        }
        return returnMap;
    }    

    // Clones a List of SDIs and relates them to a SDA (presumably one that was just cloned).  
    // Returns a Map of Original SDI.Id to Cloned SDI Object 
    private static Map<Id, System_Design_Item__c> cloneToSDIMap(List<System_Design_Item__c> SDIList, Map<Id, System_Design_Array__c> SystemDesignArrayMap){
        Map<Id, System_Design_Item__c> returnMap = new Map<Id, System_Design_Item__c>();
        
        List<System_Design_Item__c> clonedSDIList = SDIList.deepClone(false);
        Integer i = 0;
        for(System_Design_Item__c SDI : clonedSDIList){
            Id oldSDIId = SDIList[i].Id;
            //retreive the old cloned SDA Id from the Map so we can relate the newly cloned SDI to the new SDAs
            Id oldSDAId = SDIList[i].System_Design_Array__c;
            Id newSDAId = SystemDesignArrayMap.get(oldSDAId).Id;
            SDI.System_Design_Array__c = newSDAId;
            returnMap.put(oldSDIId, SDI);
            i++;
        }
        return returnMap;
    }    

}