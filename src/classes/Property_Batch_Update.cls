global class Property_Batch_Update implements Database.Batchable<sObject>{
public String query = 'Select Name,Astrum_Office__c,QAS_Property_County__c,QAS_Latitude__c,QAS_Longitude__c, Property_State__c,Property_County__C from Property__c ' ;
public String batch = 'Office';


global Database.QueryLocator start(Database.BatchableContext BC){
    return Database.getQueryLocator(query);
}

global void execute(Database.BatchableContext BC, List<sObject> scope){
    List<Property__c> propUpdate = new List<Property__c>();
    if(batch == 'Office') {
        List<Office_Location__c> officeLocations = [Select Name,Location__Latitude__s, Location__Longitude__s,State_Coverage__c from Office_Location__c];
      
        Map<String,String> officeMap = new Map<String,String>();
        String[] tmpString;
       
        for (Office_Location__c ol :officeLocations  )
        {   
            System.Debug('**Prop Off');
            if(ol.State_Coverage__c != null)
                tmpString = ol.State_Coverage__c.split(';');
                
            if(tmpString != null && tmpString.size() > 0) 
            {
               for(String s : tmpString)
                    officeMap.put(s,ol.Name);   
               tmpString.clear();          
            }        
            
        }
            
        for(sObject s : scope)
        {
          
          Property__c propUpd = (Property__c)s;
          System.Debug('**Prop Off-'+propUpd.Name);
          propUpd.Astrum_Office__c = Astrum_Distance_Calculation.assignOfficeToProperty(officeMap,officeLocations,propUpd);  
          System.debug('Property - '+propUpd.Name);
          if(propUpd.Astrum_Office__c != null)
              propUpdate.add(PropUpd);           
                
        }
        if(! propUpdate.isEmpty())
            update(propUpdate); 
    }
    else if( batch == 'SalesRegion')
    {
         Map<String, Astrum_Sales_Region__c> salesRegionMap = new Map<String, Astrum_Sales_Region__c>(); 
         for( Astrum_Sales_Region__c objCS : [Select z.Name, z.Id From  Astrum_Sales_Region__c z])
            salesRegionMap.put(objCS.Name, objCS);
    
         for(sObject s : scope)
         { 
              Property__c p = (Property__c)s;
              p.Astrum_Sales_Region__c = salesRegionMap.get(p.Sales_Region__c).Id;      
              propUpdate.add(p);         
         }
         if(! propUpdate.isEmpty())
             update(propUpdate);   
    }   
  
}
global void finish(Database.BatchableContext BC){
  }

     
}