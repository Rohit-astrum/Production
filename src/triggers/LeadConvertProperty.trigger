/* FILE: LeadConvertProperty.trigger
 * AUTHOR: Rohit Jain
 * DATE: December 17, 2012
 * PURPOSE: Creates Property Object from converted lead
 * MODIFICATION HISTORY
 *     Commented out by MK - 6-10-2014 - The trigger was inactive already, but this prevents us from 
       thinking it's active when performing code searches and debugging etc.
 */
 
trigger LeadConvertProperty on Lead (after update) {
  system.debug('This trigger is disabled.  This debug message should not show up in debug logs since the trigger is inactive.');
/*
    //don't perform updates if bypass is on 
  if (TriggerUtility.bypassLeadTriggersForBatchProcessing) { return; }
   
    // Variable Declarations
    List<Property__c> propertyInsert= new List<Property__C>();  
    Map<Id,Property__C> optyUpdateMap = new Map<Id,Property__C>();    
    List<Office_Location__c> officeLocations   = new List<Office_Location__c>();  
    Map<String,String> officeMap = new Map<String,String>();
    Property__c property;
    String[] tmpString;
    String assignOffice;
    Boolean convertLeadFlag = false;
    
    for (Lead l : Trigger.new) {
          if (l.IsConverted == true){
              convertLeadFlag = true;
              break;              
          }    
    }
   
    if(convertLeadFlag)
    {
        officeLocations = [Select Name,Location__Latitude__s, Location__Longitude__s,State_Coverage__c from Office_Location__c];    
  
        for (Office_Location__c ol :officeLocations  )
        {   
            if(ol.State_Coverage__c != null)
                tmpString = ol.State_Coverage__c.split(';');
                
            if(tmpString != null && tmpString.size() > 0) 
            {
               for(String s : tmpString)
                    officeMap.put(s,ol.Name);   
               tmpString.clear();          
            }        
            
        } 
    
        System.debug('**'+officeMap);
    
        for (Lead l : Trigger.new) {
            if (l.IsConverted == true) {               
                if (l.ConvertedAccountId != null && l.Street != null && l.city != null && (l.QAS_County__c != null || l.County__c != null) && l.PostalCode != null && l.State != null  ) {
                       // Create Property Object
                    
                        property = new Property__c();       
                        property.Name = l.Street;
                        property.Property_City__c = l.city;
                        property.Property_State__c = l.State;
                        property.Property_County__c = (l.QAS_County__c != null ? l.QAS_County__c : SalesRegionHelper.removeState(l.County__c));
                        property.Property_ZIP__c = l.PostalCode;
                        property.Property_Country__c = l.Country;
                        property.Sales_Region__c  = l.Sales_Region__c ;
                        property.Property_Owner__c = l.ConvertedAccountId ;
                        property.QAS_Latitude__c = l.QAS_Latitude__c;
                        property.QAS_Longitude__c = l.QAS_Longitude__c;   
                        property.ValidationStatus__c = l.ValidationStatus_Address__c;   
                        property.ValidationTimestamp__c = l.ValidationTimestamp_Address__c;   
                        property.QAS_Property_County__c   = (l.QAS_County__c != null ? l.QAS_County__c : SalesRegionHelper.removeState(l.County__c));
                        property.Astrum_Office__c = Astrum_Distance_Calculation.assignOffice(officeMap,officeLocations,l); 
                        propertyInsert.add(property);              
                        optyUpdateMap.put(l.ConvertedOpportunityId, property);                                                              
                }
            }
        }
        
    }
    
    if (!propertyInsert.isEmpty()) {
    insert propertyInsert;
    }
    // Associate Property to Opportunity
    if(!optyUpdateMap.isEmpty())
    {
      List<Opportunity> opty = [Select Id,Property__c from Opportunity where Id in :optyUpdateMap.keySet()];
      List<Opportunity> optyUpdate = new List<Opportunity>();
      
      for(Opportunity opt: opty )
      {         
          opt.Property__c = optyUpdateMap.get(opt.Id).Id;
          optyUpdate.add(opt); 
      }  
  
      if (!optyUpdate.isEmpty()) {
       upsert optyUpdate;
      }
            
    }
    */
}