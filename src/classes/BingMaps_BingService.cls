//10/12/2012 TCM - add dc-to-ac-derate parameter
public with sharing class BingMaps_BingService {

    @Future(callout=true)
    public static void updateGeoPointsAndMaxSiteQuality(String street, String zip, Id propertyId, Decimal dcToACDerate,String State) {    	  
    	BingMaps_LocationResult theLocationResult = BingMaps_BingServiceUtility.geoCodeAddress(street, zip);
    	
    	String homeAddress = street + ', ' + zip;
		BingMaps_RouteResult theRouteResult = BingMaps_BingServiceUtility.computeGeoPoints(homeAddress, propertyId);
		
		/*if (BingMaps_BingServiceUtility.isValid(theLocationResult)) {
			if (dcToACDerate == null) {
				dcToACDerate = 0.925;
			} 
			Double maxSiteQuality = PVWatts_ServiceClient.getSiteQuality(theLocationResult.latitude, theLocationResult.longitude, dcToACDerate, State);					
			BingMaps_BingServiceUtility.updateProperty(propertyId, theLocationResult, theRouteResult, maxSiteQuality);    				
		}
		else {
			 	
		}*/
		BingMaps_BingServiceUtility.updateProperty(propertyId, theLocationResult, theRouteResult);   
		
    }
    
    @Future(callout=true)
    public static void updateGeoPoints(String street, String zip, Id propertyId) {    	    	
    	BingMaps_LocationResult theLocationResult = BingMaps_BingServiceUtility.geoCodeAddress(street, zip);

    	String homeAddress = street + ', ' + zip;
		BingMaps_RouteResult theRouteResult = BingMaps_BingServiceUtility.computeGeoPoints(homeAddress, propertyId);
				
		BingMaps_BingServiceUtility.updateProperty(propertyId, theLocationResult, theRouteResult);    	
    }
    
}