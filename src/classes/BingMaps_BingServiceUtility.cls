public with sharing class BingMaps_BingServiceUtility {

    public static String bingMapAPIKey = 'AmNusenC9lFa9mEzNcPkA20qId_7uSQjr13KIPqpc2dCcl7VovwdcBi-G9tQIxa5'; 
    
    private static String bingMapRoutesUrl = 'http://dev.virtualearth.net/REST/v1/Routes?';
    private static String bingNamespace = 'http://schemas.microsoft.com/search/local/ws/rest/v1';

    private static String bingMapLocationsUrl = 'http://dev.virtualearth.net/REST/v1/Locations?';
    
    public static String getAddress(Property__c property) {
        String address = '';
        
        if (property.Name != null) {
            address += property.Name + ', ';
        }
        
        if (property.Property_City__c != null) {
            address += property.Property_City__c + ', ';
        }
        
        if (property.Property_State__c != null) {
            address += property.Property_State__c + ', ';
        }
        
        if (property.Property_ZIP__c != null) {
            address += property.Property_ZIP__c;
        }
        
        return address;     
    }

    public static String getAddress(Office_Location__c officeLocation) {
        String address = '';
        
        if (officeLocation.Street__c != null) {
            address += officeLocation.Street__c + ', ';
        }
        
        if (officeLocation.City__c != null) {
            address += officeLocation.City__c + ', ';
        }
        
        if (officeLocation.State__c != null) {
            address += officeLocation.State__c + ', ';
        }
        
        if (officeLocation.Zip_Code__c != null) {
            address += officeLocation.Zip_Code__c;
        }
        
        return address;     
    }

    public static String buildCompleteRoutesUrl(String homeAddress, String officeAddress) {
        String encodingScheme = 'UTF-8';
        String encodedHomeAddress = EncodingUtil.urlEncode(homeAddress, encodingScheme);
        String encodedOfficeAddress = EncodingUtil.urlEncode(officeAddress, encodingScheme);        
        
        String wayPoint1 = 'wayPoint.1=' + encodedHomeAddress;
        String wayPoint2 = 'wayPoint.2=' + encodedOfficeAddress;
        String distanceUnit = 'du=Mile';
        
        String output = 'output=xml';
        String key= 'key=' + bingMapAPIKey;     
                
        String completeRoutesUrl = bingMapRoutesUrl + wayPoint1 + '&' + wayPoint2 + '&' + distanceUnit + '&' + output + '&' + key;
        
        return completeRoutesUrl;       
    }

    public static String buildCompleteLocationUrl(String streetAddress, String zipCode) {
        String encodingScheme = 'UTF-8';
        String encodedHomeAddress = EncodingUtil.urlEncode(streetAddress, encodingScheme);
        
        String addressLine = 'addressLine=' + encodedHomeAddress;       
        String postalCode = 'postalCode=' + zipCode;        
        String output = 'output=xml';
        String key= 'key=' + bingMapAPIKey;     
                
        String completeUrl = bingMapLocationsUrl 
                                    + addressLine + '&' 
                                    + postalCode + '&' 
                                    + output + '&' 
                                    + key;
        
        return completeUrl;     
    }

    public static String getResponseElement(String body) {
        return body.substring(body.indexOf('<Response'));   
    }

    public static BingMaps_RouteResult parseRouteResponse(String responseElement) {
        BingMaps_RouteResult theRouteResult = new BingMaps_RouteResult();       
        
        try {
            Dom.Document doc = new Dom.Document();
            doc.load(responseElement);
            
            Dom.Xmlnode root = doc.getRootElement();    

            Dom.Xmlnode routeLeg = root.getChildElement('ResourceSets', bingNamespace).getChildElement('ResourceSet', bingNamespace).getChildElement('Resources', bingNamespace).getChildElement('Route', bingNamespace).getChildElement('RouteLeg', bingNamespace);        
            theRouteResult.driveTimeInHours = getValue(routeLeg, 'TravelDuration', bingNamespace) / 3600.0;
            theRouteResult.milesToOffice = getValue(routeLeg, 'TravelDistance', bingNamespace);         
        }
        catch (Exception exc) {
            theRouteResult.driveTimeInHours = 0;
            theRouteResult.milesToOffice = 0;           
        }
        
        return theRouteResult;
    }

    public static BingMaps_LocationResult parseLocationResponse(String responseElement) {
        BingMaps_LocationResult theLocationResult = new BingMaps_LocationResult();      


        System.debug('responseElement = ' + responseElement);
        
         try {
            Dom.Document doc = new Dom.Document();
            doc.load(responseElement);
            
            Dom.Xmlnode root = doc.getRootElement();    
            Dom.Xmlnode point = root.getChildElement('ResourceSets', bingNamespace).getChildElement('ResourceSet', bingNamespace).getChildElement('Resources', bingNamespace).getChildElement('Location', bingNamespace).getChildElement('Point', bingNamespace);       
            
            System.debug('got point');
            
            theLocationResult.latitude = getValue(point, 'Latitude', bingNamespace);
            System.debug('got latitude');
            
            theLocationResult.longitude = getValue(point, 'Longitude', bingNamespace);          
            System.debug('got longitude');
         }
        
        
        catch (Exception exc) {
            theLocationResult.latitude = 0;
            theLocationResult.longitude = 0;
        }
        
        
        return theLocationResult;
    }

    public static boolean isValid(BingMaps_LocationResult theLocationResult) {
        return (theLocationResult.latitude != 0 && theLocationResult.longitude != 0);           
    }
    
    public static double getValue(Dom.Xmlnode theParentNode, String elementName, String namespace) {
        Dom.xmlnode theNode = theParentNode.getChildElement(elementName, namespace);
        return Double.valueOf(theNode.getText());       
    }

    public static BingMaps_LocationResult geoCodeAddress(String street, String zip) {
        String completeUrl = buildCompleteLocationUrl(street, zip);
        HttpResponse response = submitWebServiceRequest(completeUrl);
        String  body = response.getBody();      
        String responseElement = getResponseElement(body);           
        return parseLocationResponse(body);     
    }

    public static BingMaps_RouteResult computeGeoPoints(String propertyAddress, String officeAddress) {
        BingMaps_RouteResult result = new BingMaps_RouteResult();
        String completeUrl = buildCompleteRoutesUrl(propertyAddress, officeAddress);
        HttpResponse response = submitWebServiceRequest(completeUrl);
        String  body = response.getBody();      
        String responseElement = getResponseElement(body);           
        return parseRouteResponse(body);
    }

    public static BingMaps_RouteResult computeGeoPoints(String propertyAddress, Id propertyId) {
        String officeAddress = getAstrumOfficeAddressForProperty(propertyId);
        return computeGeoPoints(propertyAddress, officeAddress);
    }
        
    static HttpResponse submitWebServiceRequest(String url) {       
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(url);
        req.setTimeout(60 * 1000);
        Http h = new Http();

        if(!Test.isRunningTest())
        {
            return h.send(req);      
        }
        else
        {
            HttpResponse res = new HttpResponse();
            res.setBody('<Response> </Response>');
            return res;
        }
    }

    public static void updateProperty(Id propertyId, BingMaps_LocationResult theLocationResult, BingMaps_RouteResult theRouteResult) {      
        Property__c property = new Property__c(Id=propertyId);      
        if (theRouteResult != null) {
            property.Hours_From_Nearest_Office__c = theRouteResult.driveTimeInHours;
            property.Miles_To_Office__c = theRouteResult.milesToOffice;         
            property.latitude__c = theLocationResult.latitude;
            property.longitude__c = theLocationResult.longitude;            
        }

        update property;        
    }

    public static void updateProperty(Id propertyId, BingMaps_LocationResult theLocationResult, BingMaps_RouteResult theRouteResult, Double maxSiteQuality) {       
        Property__c property = [SELECT Hours_From_Nearest_Office__c, Miles_To_Office__c, latitude__c, longitude__c, 
                                Max_Site_Quality__c, Optimal_Site_Quality_kWh_y_kW__c, Snow_De_Rate_kWh_y_kW__c  
                                from Property__c 
                                where id =: propertyId LIMIT 1];        
        
        if (theRouteResult != null) {
            property.Hours_From_Nearest_Office__c = theRouteResult.driveTimeInHours;
            property.Miles_To_Office__c = theRouteResult.milesToOffice;         
            property.latitude__c = theLocationResult.latitude;
            property.longitude__c = theLocationResult.longitude;            
        }
        
        if (maxSiteQuality != null) {
            property.Max_Site_Quality__c = maxSiteQuality;        
            property.Optimal_Site_Quality_kWh_y_kW__c = maxSiteQuality - property.Snow_De_Rate_kWh_y_kW__c;
        }
                    
        update property;        
    }
        
    public static String getAstrumOfficeAddressForProperty(Id propertyId) {
        //Property__c property = [SELECT Astrum_Office__c from Property__c where id =: propertyId LIMIT 1];       
        Property__c property = [SELECT Astrum_Office_New__r.Id,Astrum_Office_New__r.Street__C,Astrum_Office_New__r.City__C,Astrum_Office_New__r.State__C,Astrum_Office_New__r.Zip_Code__C from Property__c where id =: propertyId LIMIT 1];       
        //String officeName = Milestone1_General_Utility.getStateFromAstrumOffice(property.Astrum_Office__C);     
        //Office_Location__c officeLocation = [SELECT Name, Street__C, City__c, State__C, Zip_Code__c from Office_Location__c where Id = :property.Astrum_Office_New__r.Id LIMIT 1];      
        return getAddress(property.Astrum_Office_New__r);
        //return getAddress(property );
    }
    
    public static boolean hasDifferentAddresses(Property__c property1, Property__c property2) {
        return property1.Name != property2.Name || property1.Property_City__c != property2.Property_City__c || property1.Property_State__c != property2.Property_State__c || property1.Property_ZIP__c != property2.Property_ZIP__c;    
    }
    
    public static boolean hasDifferentAstrumOffice(Property__c property1, Property__c property2) {
        return property1.Astrum_Office__c != property2.Astrum_Office__c;
    }
    
}