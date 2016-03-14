/* FILE: Astrum_Distance_Calculation
 * AUTHOR: Rohit Jain
 * DATE: December 17, 2012
 * PURPOSE: Calculates Distance between two points
 * MODIFICATION HISTORY
 * 01/07/2015 PB - OPS-73 MA locations
 * 07/16/2015 PB FPO Phase2 Assign office based on State coverage and Proximity
 * 09/22/2015 PB FPO Phase4
 */

Public class Astrum_Distance_Calculation {
  static final String defaultOffLocName = Main_Office_Location_Settings__c.getOrgDefaults().Name__c;
  
  /*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
  /*::  This function derives the Astrum Office Assignment while Converting a Lead   :*/
  /*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
  /* Deprecated
  public static String assignOffice(Map<String,String> officeMap,List<Office_Location__c> officeLocations, Lead l) {
      
        String assignOffice;
        Map<double,String> officeDistance = new Map<double,String>();
        List<double> sortDistance = new List<double>();
        String county;
        if (officeMap != null)
        {
          assignOffice = officeMap.get(l.State.toUpperCase());
          System.debug('**Assign Office-'+assignOffice );
          if(assignOffice != null)
               System.debug('**Assign Office-Derived from MAp' );  
          else 
          {
            // Get the County
            county =  (l.QAS_County__c != null ? l.QAS_County__c : SalesRegionHelper.removeState(l.County__c));
                
            if(l.State.toUpperCase() =='NY' && (county.toUpperCase() == 'NASSAU' || county.toUpperCase() == 'SUFFOLK' ))
            {
                 assignOffice  = 'Long Island, NY';                                  
            }      
            else { 
                // Default the closest Astrum Office from Property Address
                   
                if(l.QAS_Latitude__c != null && l.QAS_Longitude__c != null && officeLocations != null ) {
                    for (Office_Location__c ol :officeLocations  )
                    {
                        
                        if(l.State.toUpperCase() =='NY')
                        {
                           
                            if((ol.Name == 'Middletown, NY') || (ol.Name == 'Henrietta, NY'))  
                            officeDistance.put( Astrum_Distance_Calculation.distance( Double.valueOf(ol.Location__Latitude__s),Double.valueOf(ol.Location__Longitude__s)
                                        ,Double.valueOf(l.QAS_Latitude__c),Double.valueOf(l.QAS_Longitude__c),'K'),ol.Name);
                        }
                        
                        else if(l.State.toUpperCase() =='PA' )
                        {
                            if((ol.Name == 'Norristown, PA') || (ol.Name == 'Youngstown, OH'))
                            officeDistance.put( Astrum_Distance_Calculation.distance( Double.valueOf(ol.Location__Latitude__s),Double.valueOf(ol.Location__Longitude__s)
                                        ,Double.valueOf(l.QAS_Latitude__c),Double.valueOf(l.QAS_Longitude__c),'K'),ol.Name);
                        }
                        else if(l.State.toUpperCase() =='NJ')
                        {
                            if((ol.Name == 'Norristown, PA') || (ol.Name == 'Middletown, NY'))
                            officeDistance.put( Astrum_Distance_Calculation.distance( Double.valueOf(ol.Location__Latitude__s),Double.valueOf(ol.Location__Longitude__s)
                                        ,Double.valueOf(l.QAS_Latitude__c),Double.valueOf(l.QAS_Longitude__c),'K'),ol.Name);
                        }
                        else if(l.State.toUpperCase() =='MA')
                        {
                            if((ol.Name == 'Westford, MA') || (ol.Name == 'Hopkinton, MA') || (ol.Name == 'Taunton, MA'))
                            officeDistance.put( Astrum_Distance_Calculation.distance( Double.valueOf(ol.Location__Latitude__s),Double.valueOf(ol.Location__Longitude__s)
                                        ,Double.valueOf(l.QAS_Latitude__c),Double.valueOf(l.QAS_Longitude__c),'K'),ol.Name);
                        }
                        else
                        {
                            if(!(ol.Name == 'Long Island, NY'))
                            {
                                 
                                officeDistance.put( Astrum_Distance_Calculation.distance( Double.valueOf(ol.Location__Latitude__s),Double.valueOf(ol.Location__Longitude__s)
                                        ,Double.valueOf(l.QAS_Latitude__c),Double.valueOf(l.QAS_Longitude__c),'K'),ol.Name);
                            }            
                        }
                              
                     }                       
                     sortDistance.addAll(officeDistance.keySet());
                     sortDistance.sort();  
                     assignOffice  = officeDistance.get(sortDistance[0]);
                     System.debug('**property.Astrum_Office__c-'+assignOffice   );
                     }
                else{
                        if(l.State.toUpperCase() =='PA')
                            assignOffice  = 'Norristown, PA';  
                        else if(l.State.toUpperCase() =='NY')  
                            assignOffice  = 'Middletown, NY';
                        else if(l.State.toUpperCase() =='NJ')  
                             assignOffice  = 'Norristown, PA';  
                        else
                            assignOffice  = 'Annapolis Junction, MD';           
                    }
                }          
            }
             
      }
      return assignOffice;
  }
  */
  
  /*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
  /*::  This function derives the Astrum Office Assignment for a Property   :*/
  /*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
  
  public static String assignOfficeToProperty(Map<String,String> officeMap,List<Office_Location__c> officeLocations, Property__c p) {
      
        String assignOffice;
        Map<double,String> officeDistance = new Map<double,String>();
        List<double> sortDistance = new List<double>();
        String county;
        if (officeMap != null && p.Property_State__c != null)
        {
          assignOffice = officeMap.get(p.Property_State__c.toUpperCase());
          System.debug('**Assign Office-'+assignOffice );
          if(assignOffice != null)
               System.debug('**Assign Office-Derived from MAp' );  
          else 
          {
            
            if(p.Property_State__c.toUpperCase() =='NY' && p.Property_County__c !=null && (p.Property_County__c.toUpperCase() == 'NASSAU' || p.Property_County__c.toUpperCase() == 'SUFFOLK' ))
            {
                 assignOffice  = 'Long Island, NY'; 
                 System.debug('**Assign Office-Long Island, NY' );                 
            }      
            else { 
                // Default the closest Astrum Office from Property Address
                if(p.QAS_Latitude__c != null && p.QAS_Longitude__c != null && officeLocations != null ) {
                    for (Office_Location__c ol :officeLocations  )
                    {
                        
                        if(p.Property_State__c.toUpperCase() =='NY')
                        {
                           
                            if((ol.Name == 'Middletown, NY') || (ol.Name == 'Henrietta, NY'))  
                            officeDistance.put( Astrum_Distance_Calculation.distance( Double.valueOf(ol.Location__Latitude__s),Double.valueOf(ol.Location__Longitude__s)
                                        ,Double.valueOf(p.QAS_Latitude__c),Double.valueOf(p.QAS_Longitude__c),'K'),ol.Name);
                        }
                        
                        else if(p.Property_State__c.toUpperCase() =='PA' )
                        {
                            if((ol.Name == 'Norristown, PA') || (ol.Name == 'Youngstown, OH'))
                            officeDistance.put( Astrum_Distance_Calculation.distance( Double.valueOf(ol.Location__Latitude__s),Double.valueOf(ol.Location__Longitude__s)
                                        ,Double.valueOf(p.QAS_Latitude__c),Double.valueOf(p.QAS_Longitude__c),'K'),ol.Name);
                        }
                        else if(p.Property_State__c.toUpperCase() =='NJ')
                        {
                            if((ol.Name == 'Norristown, PA') || (ol.Name == 'Middletown, NY'))
                            officeDistance.put( Astrum_Distance_Calculation.distance( Double.valueOf(ol.Location__Latitude__s),Double.valueOf(ol.Location__Longitude__s)
                                        ,Double.valueOf(p.QAS_Latitude__c),Double.valueOf(p.QAS_Longitude__c),'K'),ol.Name);
                        }
                        else if(p.Property_State__c.toUpperCase() =='MA')
                        {
                            if((ol.Name == 'Westford, MA') || (ol.Name == 'Hopkinton, MA') || (ol.Name == 'Taunton, MA'))
                            officeDistance.put( Astrum_Distance_Calculation.distance( Double.valueOf(ol.Location__Latitude__s),Double.valueOf(ol.Location__Longitude__s)
                                        ,Double.valueOf(p.QAS_Latitude__c),Double.valueOf(p.QAS_Longitude__c),'K'),ol.Name);
                        }
                        else
                        {
                            if(!(ol.Name == 'Long Island, NY'))
                            {
                                 
                                officeDistance.put( Astrum_Distance_Calculation.distance( Double.valueOf(ol.Location__Latitude__s),Double.valueOf(ol.Location__Longitude__s)
                                        ,Double.valueOf(p.QAS_Latitude__c),Double.valueOf(p.QAS_Longitude__c),'K'),ol.Name);
                            }            
                        }
                     }
                       
                     sortDistance.addAll(officeDistance.keySet());
                     sortDistance.sort();                       
                     System.debug('**sortDistance-'+sortDistance );
                     assignOffice  = officeDistance.get(sortDistance[0]);
                     System.debug('**property.Astrum_Office__c-'+assignOffice   );
                     }
                else
                    assignOffice  = defaultOffLocName; //FPO Phase4 //'Annapolis Junction, MD';  
                }          
            }
             
      }
      return assignOffice;
  }
  
  /*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
  /*::  This function Caculate Distance between two locations         :*/
  /*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
  public static double distance(Double lat1, Double lon1, Double lat2, Double lon2, String unit) {
      double theta = lon1 - lon2;
      double dist = Math.sin(deg2rad(lat1)) * Math.sin(deg2rad(lat2)) + Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) * Math.cos(deg2rad(theta));
      dist = Math.acos(dist);
      dist = rad2deg(dist);
      dist = dist * 60 * 1.1515;
      if (unit == 'K') {
        dist = dist * 1.609344;
      } else if (unit == 'N') {
        dist = dist * 0.8684;
        }
      return (dist);
    }

    /*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
    /*::  This function converts decimal degrees to radians             :*/
    /*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
    private static double deg2rad(double deg) {
      return (deg * 3.14159 / 180.0);
    }
    
    /*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
    /*::  This function converts radians to decimal degrees             :*/
    /*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
    private static double rad2deg(double rad) {
      return (rad * 180.0 / 3.14159);
    }
    
    //Deprecated FPO Phase4
    /*
    public static String assignOffice(List<Office_Location__c> officeLocations, Lead l){
      
      String assignedOffice;
      Map<double,String> officeDistance = new Map<double,String>();
      List<double> sortDistance = new List<double>();
      String county;
      List<Office_Location__c> locationsWithCoverage = new List<Office_Location__c>();
      
      // Get the County
      county =  (l.QAS_County__c != null ? l.QAS_County__c : SalesRegionHelper.removeState(l.County__c));

      //Special case for new york county
      if(l.State.toUpperCase() =='NY' && (county.toUpperCase() == 'NASSAU' || county.toUpperCase() == 'SUFFOLK' )){
        assignedOffice  = 'Long Island, NY';
        return assignedOffice;
      }

      //Check for Lat and Long
      if(!(l.QAS_Latitude__c != null && l.QAS_Longitude__c != null)){
        //throw new CustomException('Error in Assigning Office Location. Lead/Property latitude and longitude cannot be verified.');
        //
        for(Office_Location__c offLoc:officeLocations){
          if(String.isNotBlank(offLoc.State__c ) && offLoc.State__c == 'MD'){
            assignedOffice = offLoc.Name;
            return assignedOffice;
          }
        }
        //
        assignedOffice  = 'Annapolis Junction, MD';
        return assignedOffice;

      }
      
      //For all other dynamically assign office location based on State coverage and proximity to property
      else if(officeLocations != null ){
        //Find locations with state coverage
        for(Office_Location__c offLoc:officeLocations){
          if(String.isNotBlank(offLoc.State_Coverage__c) && offLoc.State_Coverage__c.containsIgnoreCase(l.State)){
            locationsWithCoverage.add(offLoc);
          }
        }

        //Find the location with state coverage thats closest
        for(Office_Location__c offLoc: locationsWithCoverage){
          if((offLoc.Location__Latitude__s) != null && (offLoc.Location__Longitude__s !=null)){
            officeDistance.put( Astrum_Distance_Calculation.distance( Double.valueOf(offLoc.Location__Latitude__s),Double.valueOf(offLoc.Location__Longitude__s)
                                        ,Double.valueOf(l.QAS_Latitude__c),Double.valueOf(l.QAS_Longitude__c),'K'),offLoc.Name);
          }          
        }

        //If there are no office locations with State coverage, calculate distance from all office locations
        if(locationsWithCoverage.isEmpty()){
          for(Office_Location__c offLoc:officeLocations){
            if((offLoc.Location__Latitude__s) != null && (offLoc.Location__Longitude__s !=null)){
              officeDistance.put( Astrum_Distance_Calculation.distance( Double.valueOf(offLoc.Location__Latitude__s),Double.valueOf(offLoc.Location__Longitude__s)
                                          ,Double.valueOf(l.QAS_Latitude__c),Double.valueOf(l.QAS_Longitude__c),'K'),offLoc.Name);
            }
          }
        }

        //Sort the distances
        if(officeDistance.keySet().size() > 0){
          sortDistance.addAll(officeDistance.keySet());
          sortDistance.sort();                       
          System.debug('**sortDistance-'+sortDistance );
          assignedOffice  = officeDistance.get(sortDistance[0]);
        }       

      }

      return assignedOffice;

    }
    */

    //FPO Phase4
    public static Office_Location__c assignOfficeLocation(List<Office_Location__c> officeLocations, Lead l){
      
      Office_Location__c assignedOffice;
      Map<double,Office_Location__c> officeDistance = new Map<double,Office_Location__c>();
      List<double> sortDistance = new List<double>();
      String county;
      List<Office_Location__c> locationsWithCoverage = new List<Office_Location__c>();
      Map<String,Office_Location__c> officeMap = new Map<String,Office_Location__c>();

      for(Office_Location__c offLoc:officeLocations){
        officeMap.put(offLoc.Name,offLoc);          
      }
      
      // Get the County
      county =  (l.QAS_County__c != null ? l.QAS_County__c : SalesRegionHelper.removeState(l.County__c));

      //Special case for new york county
      if(l.State.toUpperCase() =='NY' 
        && (county.toUpperCase() == 'NASSAU' || county.toUpperCase() == 'SUFFOLK' )
        && officeMap.containsKey('Long Island, NY'))
      {        
        assignedOffice  = officeMap.get('Long Island, NY');
        return assignedOffice;
      }

      //Check for Lat and Long
      if(!(l.QAS_Latitude__c != null && l.QAS_Longitude__c != null) && officeMap.containsKey(defaultOffLocName)){        
        assignedOffice = officeMap.get(defaultOffLocName);//FPO Phase4 //officeMap.get('Annapolis Junction, MD');
        return assignedOffice;
      }
      
      //For all other dynamically assign office location based on State coverage and proximity to property
      else if(officeLocations != null ){
        //Find locations with state coverage
        for(Office_Location__c offLoc:officeLocations){
          if(String.isNotBlank(offLoc.State_Coverage__c) && offLoc.State_Coverage__c.containsIgnoreCase(l.State)){
            locationsWithCoverage.add(offLoc);
          }
        }

        //Find the location with state coverage thats closest
        for(Office_Location__c offLoc: locationsWithCoverage){
          if((offLoc.Location__Latitude__s) != null && (offLoc.Location__Longitude__s !=null)){
            officeDistance.put( Astrum_Distance_Calculation.distance( Double.valueOf(offLoc.Location__Latitude__s),Double.valueOf(offLoc.Location__Longitude__s)
                                        ,Double.valueOf(l.QAS_Latitude__c),Double.valueOf(l.QAS_Longitude__c),'K'),offLoc);
          }          
        }

        //If there are no office locations with State coverage, calculate distance from all office locations
        if(locationsWithCoverage.isEmpty()){
          for(Office_Location__c offLoc:officeLocations){
            if((offLoc.Location__Latitude__s) != null && (offLoc.Location__Longitude__s !=null)){
              officeDistance.put( Astrum_Distance_Calculation.distance( Double.valueOf(offLoc.Location__Latitude__s),Double.valueOf(offLoc.Location__Longitude__s)
                                          ,Double.valueOf(l.QAS_Latitude__c),Double.valueOf(l.QAS_Longitude__c),'K'),offLoc);
            }
          }
        }

        //Sort the distances
        if(officeDistance.keySet().size() > 0){
          sortDistance.addAll(officeDistance.keySet());
          sortDistance.sort();                       
          System.debug('**sortDistance-'+sortDistance );
          assignedOffice  = officeDistance.get(sortDistance[0]);
        }       

      }

      return assignedOffice;

    }

    public class CustomException extends Exception{ } 
}