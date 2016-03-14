/*MODIFICATIONS
* 06/15/2012 TCM - bulkify this trigger for snow de-rate fix in property trigger
* 06/25/2015  PB - (Related to JIRA-429) Update the Method 1 Period Production when item Qty changes.
*/
trigger System_Design_Item_Trigger on System_Design_Item__c (before insert, before update) {

    Set<Id> locationIds = new Set<Id>();
    Set<Id> productIds = new Set<Id>();
    Map<Id, Install_Location__c> locationMap = new Map<Id, Install_Location__c>();
    Map<Id, System_Design_Product__c> productMap = new Map<Id, System_Design_Product__c>(); 

    List<System_Design_Item__c> recs = Trigger.new;
    Map<Id,System_Design_Item__c> oldItemsMap = Trigger.oldMap;
    
    //get install location and system design product ids    
    for(System_Design_Item__c rec : recs) {
        if (rec.Install_Location__c != null) {
            locationIds.add(rec.Install_Location__c);
        }
        if (rec.System_Design_Product__c != null) {
            productIds.add(rec.System_Design_Product__c);
        }
    }
    
    //get the install locations in bulk
    if (!locationIds.isEmpty()) {
        //MK - 2014-05-05 - Added PS relationship to get to property
        locationMap = new Map<Id, Install_Location__c>(
            [SELECT Id, Name, Azimuth__c,TSRF__c, Pitch__c, Number_of_Stories__c,Annual_Solar_Access__c ,
                    Physical_Surface__r.Property__r.Optimal_Site_Quality_kWh_y_kW__c 
                    ,Physical_Surface__r.Number_of_Stories__c 
            FROM Install_Location__c 
            WHERE Id IN :locationIds] 
        );
    }
    
    //the System Design Products in bulk
    if (!productIds.isEmpty()) {    
        productMap = new Map<Id, System_Design_Product__c>(
            [SELECT Id, Name, Rated_Output_W__c
            FROM System_Design_Product__c 
            WHERE Id = :productIds]
        );
    }
            
    for (System_Design_Item__c rec : recs) {
        
        Install_Location__c il = locationMap.get(rec.Install_Location__c);
        if (il != null) {
            
            System.debug('il.TSRF__c --> ' + il.TSRF__c);
            System.debug('il.Physical_Surface__r.Property__r.Optimal_Site_Quality_kWh_y_kW__c --> ' + il.Physical_Surface__r.Property__r.Optimal_Site_Quality_kWh_y_kW__c);
            System.debug('rec.System_Design_Product__c --> ' + rec.System_Design_Product__c);
            
            if (il.Pitch__c != null) {
                rec.Location_Pitch__c = il.Pitch__c;
            } else {
                rec.Location_Pitch__c = 0;
            }
            // RJ for SDW Changes CPQ 09/09/14
            if (il.Physical_Surface__r.Number_of_Stories__c != null) {
                rec.Location_Stories__c = Integer.valueOf(il.Physical_Surface__r.Number_of_Stories__c) ; //il.Number_of_Stories__c;
            } else {
                rec.Location_Stories__c = 0;
            }
            
            if (il.Azimuth__c != null) {
                rec.Azimuth_Text__c = String.valueof(il.Azimuth__c);
            } else {
                rec.Azimuth_Text__c = null;
            }
            if (il.Annual_Solar_Access__c != null) {
                if(rec.Annual_Solar_Access__c != null){
                    rec.Shading_Text__c = String.Valueof(il.Annual_Solar_Access__c + rec.Annual_Solar_Access__c );
                }
                else
                {
                    rec.Shading_Text__c = String.Valueof(il.Annual_Solar_Access__c );
                }
            } else {
                rec.Shading_Text__c = String.valueof(rec.Annual_Solar_Access__c );
            }
            if (il.Pitch__c != null) {
                if(rec.Tilt__c != null)
                {
                    rec.Tilt_Text__c = String.Valueof(il.Pitch__c + rec.Tilt__c);
                }
                else
                {
                    rec.Tilt_Text__c = String.Valueof(il.Pitch__c);
                }    
            } else {
                rec.Tilt_Text__c = String.Valueof(rec.Tilt__c);
            }
            
        }
        
        System_Design_Product__c sdp = productMap.get(rec.System_Design_Product__c);
        if (sdp != null) {
           
            System.debug('sdp.Rated_Output_W__c --> ' + sdp.Rated_Output_W__c);
            
            if ( sdp.Rated_Output_W__c != null ) {
                if ((rec.Quantity__c * sdp.Rated_Output_W__c)/1000 != rec.Rated_Output_kW__c ) { 
                    rec.Rated_Output_kW__c = (rec.Quantity__c * sdp.Rated_Output_W__c)/1000;
                    if(Trigger.isUpdate){
                        //Update the Method 1 Period Production (Related to JIRA-429)
                        for(Integer periodNo = 1; periodNo<7; periodNo++){
                            if(rec.get('Method_1_Period_' + periodNo + '_Production_kWH__c') != null){
                                rec.put('Method_1_Period_' + periodNo + '_Production_kWH__c'
                                    , System_Design_Item_TriggerHelper.getActualProduction(
                                        (String)rec.get('Method_1_Period_' + periodNo + '_Production_kWH__c')
                                        ,(rec.Quantity__c).intValue()
                                        ,(oldItemsMap.get(rec.Id).Quantity__c).intValue()));                
                            }
                        }

                    }
                    

                }
               /* if ((rec.Rated_Output_kW__c * (rec.Effective_TSRF__c/100) * il.Property__r.Optimal_Site_Quality_kWh_y_kW__c) != rec.Projected_Annual_Output_kWh_y__c) {
                    rec.Projected_Annual_Output_kWh_y__c = rec.Rated_Output_kW__c * (rec.Effective_TSRF__c/100) * il.Property__r.Optimal_Site_Quality_kWh_y_kW__c;
                }   */
            }
            System.debug('rec.Rated_Output_kW__c --> ' + rec.Rated_Output_kW__c);
        }

            
    } //for

}