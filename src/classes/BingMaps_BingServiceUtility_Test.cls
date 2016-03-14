/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 * MODIFICATION HISTORY: 
 * 07/16/2015 PB FPO Phase2- Set active field on Office Location
 * 07/27/2015 PB Fix assertion for testGetAstrumOfficeAddressForProperty to check for state not street and city
 */
@isTest
private class BingMaps_BingServiceUtility_Test {

    public static testMethod void testGetAddressProperty() {

        // setup
        Property__c property = new Property__c();
        
        property.Name = '1600 Pennsylvania Avenue NW';
        property.Property_City__c = 'Washington';
        property.Property_State__c = 'DC';
        property.Property_ZIP__c = '20500';
        property.Property_County__c = 'DC';
        
        String expected = property.Name + ', ' + property.Property_City__c + ', ' + property.Property_State__c + ', ' + property.Property_ZIP__c;
        
        // execute
        String actual = BingMaps_BingServiceUtility.getAddress(property);
        
        // assert    
        System.assertEquals(expected, actual);
    }

    public static testMethod void testGetAddressOfficeLocation() {

        // setup
        Office_Location__c officeLocation = new Office_Location__c();
        
        officeLocation.Street__c = '1600 Pennsylvania Avenue NW';
        officeLocation.City__c = 'Washington';
        officeLocation.State__c = 'DC';
        officeLocation.Zip_Code__c = '20500';
        officeLocation.Active__c = true;//fpo2
        
        String expected = officeLocation.Street__c + ', ' + officeLocation.City__c + ', ' + officeLocation.State__c + ', ' + officeLocation.Zip_Code__c;
        
        // execute
        String actual = BingMaps_BingServiceUtility.getAddress(officeLocation);
        
        // assert    
        System.assertEquals(expected, actual);
    }
    
    public static testMethod void testHasDifferentAddressesZipCodeIsDifferent() {

        Property__c property = new Property__c();       
        property.Name = '1600 Pennsylvania Avenue NW';
        property.Property_City__c = 'Washington';
        property.Property_State__c = 'DC';
        property.Property_ZIP__c = '20500';


        Property__c property2 = new Property__c();      
        property2.Name = '1600 Pennsylvania Avenue NW';
        property2.Property_City__c = 'Washington';
        property2.Property_State__c = 'DC';
        property2.Property_ZIP__c = '90500';
        
        // execute
        boolean actual = BingMaps_BingServiceUtility.hasDifferentAddresses(property, property2);
        
        // assert    
        System.assert(actual);
    }    

    public static testMethod void testHasDifferentAstrumOffice() {

        Property__c property = new Property__c();       
        property.Name = '1600 Pennsylvania Avenue NW';
        property.Property_City__c = 'Washington';
        property.Property_State__c = 'DC';
        property.Property_ZIP__c = '20500';
        property.Astrum_Office__c = 'Annapolis Junction, MD';

        Property__c property2 = new Property__c();      
        property2.Name = '1600 Pennsylvania Avenue NW';
        property2.Property_City__c = 'Washington';
        property2.Property_State__c = 'DC';
        property2.Property_ZIP__c = '90500';
        property.Astrum_Office__c = 'Hopkinton, MA';
        
        // execute
        boolean actual = BingMaps_BingServiceUtility.hasDifferentAstrumOffice(property, property2);
        
        // assert    
        System.assert(actual);
    }    
    
    public static testMethod void testBuildCompleteRoutesUrl() {
        String homeAddress = '1600 Pennsylvania Avenue NW, Washington, DC, 20500';  
        String officeAddress = '8955 Henkels Lane, Annapolis Junction, MD, 20701';  
        
        String completeUrl = BingMaps_BingServiceUtility.buildCompleteRoutesUrl(homeAddress, officeAddress);    
        
        String expected = 'http://dev.virtualearth.net/REST/v1/Routes?wayPoint.1=1600+Pennsylvania+Avenue+NW%2C+Washington%2C+DC%2C+20500&wayPoint.2=8955+Henkels+Lane%2C+Annapolis+Junction%2C+MD%2C+20701&du=Mile&output=xml&key=' + BingMaps_BingServiceUtility.bingMapAPIKey;       

        System.assertEquals(expected, completeUrl);
    }
    
    public static testMethod void testBuildCompleteLocationUrl() {
        String street = '1600 Pennsylvania Avenue NW';
        String zip  = '20500';
        
        String completeUrl = BingMaps_BingServiceUtility.buildCompleteLocationUrl(street, zip);    
        
        String expected = 'http://dev.virtualearth.net/REST/v1/Locations?addressLine=1600+Pennsylvania+Avenue+NW&postalCode=20500&output=xml&key=AmNusenC9lFa9mEzNcPkA20qId_7uSQjr13KIPqpc2dCcl7VovwdcBi-G9tQIxa5';     

        System.assertEquals(expected, completeUrl);
    }
    
    public static testMethod void testGetResponseElement() {
        String body = '<?xml version="1.0" encoding="utf-8"?><Response>test</Response>';
        
        String responseElement = BingMaps_BingServiceUtility.getResponseElement(body);

        System.assert(responseElement.startsWith('<Response'));
        System.assert(responseElement.endsWith('Response>'));       
    }

    public static testMethod void testParseRouteResponseForMilesToOfficeAndDriveTime() {
        // setup
        String body = '<?xml version="1.0" encoding="utf-8"?><Response xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://schemas.microsoft.com/search/local/ws/rest/v1"><Copyright>Copyright © 2011 Microsoft and its suppliers. All rights reserved. This API cannot be accessed and the content and any results may not be used, reproduced or transmitted in any manner without express written permission from Microsoft Corporation.</Copyright><BrandLogoUri>http://dev.virtualearth.net/Branding/logo_powered_by.png</BrandLogoUri><StatusCode>200</StatusCode><StatusDescription>OK</StatusDescription><AuthenticationResultCode>ValidCredentials</AuthenticationResultCode><TraceId>a018111f94ca41a48a35f0b5c6d74361|BL2M002302|02.00.126.1500|BL2MSNVM001284, BL2MSNVM001290</TraceId><ResourceSets><ResourceSet><EstimatedTotal>1</EstimatedTotal><Resources><Route><Id>v62,i0,a0,cen-US,dAAAAAAAAAAA=,y0,s1,m1,o1,t4,wBiB1A7f8Jvk=~mIPG/+FabRwAAOABrubPPgI=~MTYwMCBQZW5uc3lsdmFuaWEgQXZlIE5XLCBXYXNoaW5ndG9uLCBEQyAyMDUwMC0wMDAz~~~,wC1V6AwaHLPk=~mIPG//GzYBwAAOAB2IdTPwI=~ODk1NSBIZW5rZWxzIExuLCBBbm5hcG9saXMgSnVuY3Rpb24sIE1EIDIwNzAxLTExNjI=~~~,k0,u</Id><BoundingBox><SouthLatitude>38.874559</SouthLatitude><WestLongitude>-77.041401</WestLongitude><NorthLatitude>39.128918</NorthLatitude><EastLongitude>-76.775969</EastLongitude></BoundingBox><DistanceUnit>Mile</DistanceUnit><DurationUnit>Second</DurationUnit><TravelDistance>27.156407</TravelDistance><TravelDuration>2184</TravelDuration><RouteLeg><TravelDistance>27.156407</TravelDistance><TravelDuration>2184</TravelDuration><ActualStart><Latitude>38.89727</Latitude><Longitude>-77.036724</Longitude></ActualStart><ActualEnd><Latitude>39.125276</Latitude><Longitude>-76.793373</Longitude></ActualEnd><StartLocation><Name>1600 Pennsylvania Ave NW, Washington, DC 20500-0003</Name><Point><Latitude>38.897099</Latitude><Longitude>-77.036697</Longitude></Point><BoundingBox><SouthLatitude>38.893236</SouthLatitude><WestLongitude>-77.043314</WestLongitude><NorthLatitude>38.900962</NorthLatitude><EastLongitude>-77.03008</EastLongitude></BoundingBox><EntityType>Address</EntityType><Address><AddressLine>1600 Pennsylvania Ave NW</AddressLine><AdminDistrict>DC</AdminDistrict><AdminDistrict2>City of Washington</AdminDistrict2><CountryRegion>United States</CountryRegion><FormattedAddress>1600 Pennsylvania Ave NW, Washington, DC 20500-0003</FormattedAddress><Locality>Washington</Locality><PostalCode>20500-0003</PostalCode></Address><Confidence>High</Confidence></StartLocation><EndLocation><Name>8955 Henkels Ln, Annapolis Junction, MD 20701-1162</Name><Point><Latitude>39.125927</Latitude><Longitude>-76.793228</Longitude></Point><BoundingBox><SouthLatitude>39.122064</SouthLatitude><WestLongitude>-76.799867</WestLongitude><NorthLatitude>39.12979</NorthLatitude><EastLongitude>-76.786589</EastLongitude></BoundingBox><EntityType>Address</EntityType><Address><AddressLine>8955 Henkels Ln</AddressLine><AdminDistrict>MD</AdminDistrict><AdminDistrict2>Howard Co.</AdminDistrict2><CountryRegion>United States</CountryRegion><FormattedAddress>8955 Henkels Ln, Annapolis Junction, MD 20701-1162</FormattedAddress><Locality>Annapolis Junction</Locality><PostalCode>20701-1162</PostalCode></Address><Confidence>High</Confidence></EndLocation><ItineraryItem><TravelMode>Driving</TravelMode><TravelDistance>0.053438</TravelDistance><TravelDuration>22</TravelDuration><ManeuverPoint><Latitude>38.89727</Latitude><Longitude>-77.036724</Longitude></ManeuverPoint><Instruction maneuverType="DepartStart">Depart from 1600 Pennsylvania Ave NW, Washington, DC 20500-0003</Instruction><CompassDirection>west</CompassDirection><Warning warningType="PrivateRoad" severity="None">Private Road</Warning><Detail><ManeuverType>DepartStart</ManeuverType><StartPathIndex>0</StartPathIndex><EndPathIndex>3</EndPathIndex><CompassDegrees>261</CompassDegrees><Mode>Driving</Mode><PreviousEntityId>0</PreviousEntityId><NextEntityId>0</NextEntityId><RoadType>Street</RoadType></Detail><Exit /><TollZone /><TransitTerminus /><IconType>Auto</IconType><Time>0001-01-01T00:00:00</Time><TransitStopId>0</TransitStopId><TowardsRoadName>State Pl NW</TowardsRoadName><SideOfStreet>Unknown</SideOfStreet></ItineraryItem><ItineraryItem><TravelMode>Driving</TravelMode><TravelDistance>0.126138</TravelDistance><TravelDuration>50</TravelDuration><ManeuverPoint><Latitude>38.896708</Latitude><Longitude>-77.037281</Longitude></ManeuverPoint><Instruction maneuverType="TurnRight">Turn right onto State Pl NW</Instruction><CompassDirection>west</CompassDirection><Warning warningType="PrivateRoad" severity="None">Private Road</Warning><Detail><ManeuverType>TurnRight</ManeuverType><StartPathIndex>3</StartPathIndex><EndPathIndex>5</EndPathIndex><CompassDegrees>270</CompassDegrees><Mode>Driving</Mode><PreviousEntityId>0</PreviousEntityId><NextEntityId>0</NextEntityId><RoadType>Street</RoadType></Detail><Detail><ManeuverType>KeepStraight</ManeuverType><StartPathIndex>5</StartPathIndex><EndPathIndex>6</EndPathIndex><Name>State Pl NW</Name><CompassDegrees>270</CompassDegrees><Mode>Driving</Mode><PreviousEntityId>0</PreviousEntityId><NextEntityId>0</NextEntityId><RoadType>Street</RoadType></Detail><Exit /><TollZone /><TransitTerminus /><IconType>Auto</IconType><Time>0001-01-01T00:00:00</Time><TransitStopId>0</TransitStopId><TowardsRoadName /><SideOfStreet>Unknown</SideOfStreet></ItineraryItem><ItineraryItem><TravelMode>Driving</TravelMode><TravelDistance>0.453601</TravelDistance><TravelDuration>145</TravelDuration><ManeuverPoint><Latitude>38.896403</Latitude><Longitude>-77.039448</Longitude></ManeuverPoint><Instruction maneuverType="TurnLeft">Turn left onto 17TH St NW</Instruction><CompassDirection>south</CompassDirection><Detail><ManeuverType>TurnLeft</ManeuverType><StartPathIndex>6</StartPathIndex><EndPathIndex>8</EndPathIndex><Name>17TH St NW</Name><CompassDegrees>180</CompassDegrees><Mode>Driving</Mode><PreviousEntityId>0</PreviousEntityId><NextEntityId>0</NextEntityId><RoadType>MajorRoad</RoadType></Detail><Exit /><TollZone /><TransitTerminus /><IconType>Auto</IconType><Time>0001-01-01T00:00:00</Time><TransitStopId>0</TransitStopId><TowardsRoadName /><SideOfStreet>Unknown</SideOfStreet></ItineraryItem><ItineraryItem><TravelMode>Driving</TravelMode><TravelDistance>0.155964</TravelDistance><TravelDuration>25</TravelDuration><ManeuverPoint><Latitude>38.889901</Latitude><Longitude>-77.039459</Longitude></ManeuverPoint><Instruction maneuverType="RoadNameChange">Road name changes to 17TH St SW</Instruction><CompassDirection>south</CompassDirection><Detail><ManeuverType>RoadNameChange</ManeuverType><StartPathIndex>8</StartPathIndex><EndPathIndex>13</EndPathIndex><Name>17TH St SW</Name><CompassDegrees>181</CompassDegrees><Mode>Driving</Mode><PreviousEntityId>0</PreviousEntityId><NextEntityId>0</NextEntityId><RoadType>MajorRoad</RoadType></Detail><Exit /><TollZone /><TransitTerminus /><IconType>Auto</IconType><Time>0001-01-01T00:00:00</Time><TransitStopId>0</TransitStopId><TowardsRoadName /><SideOfStreet>Unknown</SideOfStreet></ItineraryItem><ItineraryItem><TravelMode>Driving</TravelMode><TravelDistance>0.06338</TravelDistance><TravelDuration>10</TravelDuration><ManeuverPoint><Latitude>38.887959</Latitude><Longitude>-77.04022</Longitude></ManeuverPoint><Instruction maneuverType="KeepStraight">Keep straight onto Independence Ave SW</Instruction><CompassDirection>west</CompassDirection><Detail><ManeuverType>KeepStraight</ManeuverType><StartPathIndex>13</StartPathIndex><EndPathIndex>17</EndPathIndex><Name>Independence Ave SW</Name><CompassDegrees>256</CompassDegrees><Mode>Driving</Mode><PreviousEntityId>0</PreviousEntityId><NextEntityId>0</NextEntityId><RoadType>MajorRoad</RoadType></Detail><Exit /><TollZone /><TransitTerminus /><IconType>Auto</IconType><Time>0001-01-01T00:00:00</Time><TransitStopId>0</TransitStopId><TowardsRoadName /><SideOfStreet>Unknown</SideOfStreet></ItineraryItem><ItineraryItem><TravelMode>Driving</TravelMode><TravelDistance>0.287073</TravelDistance><TravelDuration>45</TravelDuration><ManeuverPoint><Latitude>38.887573</Latitude><Longitude>-77.04125</Longitude></ManeuverPoint><Instruction maneuverType="UTurn">Make a U-turn to stay on Independence Ave SW</Instruction><CompassDirection>east</CompassDirection><Detail><ManeuverType>UTurn</ManeuverType><StartPathIndex>17</StartPathIndex><EndPathIndex>22</EndPathIndex><Name>Independence Ave SW</Name><CompassDegrees>89</CompassDegrees><Mode>Driving</Mode><PreviousEntityId>0</PreviousEntityId><NextEntityId>0</NextEntityId><RoadType>MajorRoad</RoadType></Detail><Exit /><TollZone /><TransitTerminus /><IconType>Auto</IconType><Time>0001-01-01T00:00:00</Time><TransitStopId>0</TransitStopId><TowardsRoadName /><SideOfStreet>Unknown</SideOfStreet></ItineraryItem><ItineraryItem><TravelMode>Driving</TravelMode><TravelDistance>0.429367</TravelDistance><TravelDuration>84</TravelDuration><ManeuverPoint><Latitude>38.886951</Latitude><Longitude>-77.036701</Longitude></ManeuverPoint><Instruction maneuverType="BearRight">Bear right onto Maine Ave SW</Instruction><CompassDirection>east</CompassDirection><Detail><ManeuverType>BearRight</ManeuverType><StartPathIndex>22</StartPathIndex><EndPathIndex>29</EndPathIndex><Name>Maine Ave SW</Name><CompassDegrees>102</CompassDegrees><Mode>Driving</Mode><PreviousEntityId>0</PreviousEntityId><NextEntityId>0</NextEntityId><RoadType>MajorRoad</RoadType></Detail><Exit /><TollZone /><TransitTerminus /><IconType>Auto</IconType><Time>0001-01-01T00:00:00</Time><TransitStopId>0</TransitStopId><TowardsRoadName /><SideOfStreet>Unknown</SideOfStreet></ItineraryItem><ItineraryItem><TravelMode>Driving</TravelMode><TravelDistance>0.694693</TravelDistance><TravelDuration>65</TravelDuration><ManeuverPoint><Latitude>38.882879</Latitude><Longitude>-77.031101</Longitude></ManeuverPoint><Instruction maneuverType="RampThenHighwayLeft">Take ramp left for I-395 North / SouthWest Fwy toward South Capitol Street</Instruction><CompassDirection>east</CompassDirection><Detail><ManeuverType>TakeRampLeft</ManeuverType><StartPathIndex>29</StartPathIndex><EndPathIndex>34</EndPathIndex><CompassDegrees>103</CompassDegrees><Mode>Driving</Mode><PreviousEntityId>0</PreviousEntityId><NextEntityId>0</NextEntityId><RoadType>Ramp</RoadType></Detail><Detail><ManeuverType>Merge</ManeuverType><StartPathIndex>34</StartPathIndex><EndPathIndex>36</EndPathIndex><Name>SouthWest Fwy</Name><CompassDegrees>90</CompassDegrees><Mode>Driving</Mode><PreviousEntityId>0</PreviousEntityId><NextEntityId>0</NextEntityId><RoadType>LimitedAccessHighway</RoadType><RoadShieldRequestParameters><Bucket>50402</Bucket><Shield><RoadShieldType>1</RoadShieldType><Label>395</Label></Shield></RoadShieldRequestParameters></Detail><Sign>I-395 North</Sign><Sign>South Capitol Street</Sign><Exit /><TollZone /><TransitTerminus /><IconType>Auto</IconType><Time>0001-01-01T00:00:00</Time><TransitStopId>0</TransitStopId><TowardsRoadName /><SideOfStreet>Unknown</SideOfStreet></ItineraryItem><ItineraryItem><TravelMode>Driving</TravelMode><TravelDistance>0.066487</TravelDistance><TravelDuration>5</TravelDuration><ManeuverPoint><Latitude>38.882343</Latitude><Longitude>-77.018452</Longitude></ManeuverPoint><Instruction maneuverType="KeepLeft">Keep left onto I-295 South / Southeast Fwy</Instruction><CompassDirection>east</CompassDirection><Detail><ManeuverType>KeepLeft</ManeuverType><StartPathIndex>36</StartPathIndex><EndPathIndex>38</EndPathIndex><Name>Southeast Fwy</Name><CompassDegrees>87</CompassDegrees><Mode>Driving</Mode><PreviousEntityId>0</PreviousEntityId><NextEntityId>0</NextEntityId><RoadType>LimitedAccessHighway</RoadType><RoadShieldRequestParameters><Bucket>50402</Bucket><Shield><RoadShieldType>1</RoadShieldType><Label>295</Label></Shield></RoadShieldRequestParameters></Detail><Sign>I-295 South</Sign><Exit /><TollZone /><TransitTerminus /><IconType>Auto</IconType><Time>0001-01-01T00:00:00</Time><TransitStopId>0</TransitStopId><TowardsRoadName /><SideOfStreet>Unknown</SideOfStreet></ItineraryItem><ItineraryItem><TravelMode>Driving</TravelMode><TravelDistance>1.121575</TravelDistance><TravelDuration>86</TravelDuration><ManeuverPoint><Latitude>38.88238</Latitude><Longitude>-77.017239</Longitude></ManeuverPoint><Instruction maneuverType="RoadNameChange">Road name changes to I-295 South / I-695 South / Southeast Fwy</Instruction><CompassDirection>east</CompassDirection><Detail><ManeuverType>RoadNameChange</ManeuverType><StartPathIndex>38</StartPathIndex><EndPathIndex>44</EndPathIndex><Name>Southeast Fwy</Name><CompassDegrees>90</CompassDegrees><Mode>Driving</Mode><PreviousEntityId>0</PreviousEntityId><NextEntityId>0</NextEntityId><RoadType>LimitedAccessHighway</RoadType><RoadShieldRequestParameters><Bucket>50402</Bucket><Shield><RoadShieldType>1</RoadShieldType><Label>295</Label></Shield></RoadShieldRequestParameters></Detail><Exit /><TollZone /><TransitTerminus /><IconType>Auto</IconType><Time>0001-01-01T00:00:00</Time><TransitStopId>0</TransitStopId><TowardsRoadName /><SideOfStreet>Unknown</SideOfStreet></ItineraryItem><ItineraryItem><TravelMode>Driving</TravelMode><TravelDistance>0.738189</TravelDistance><TravelDuration>53</TravelDuration><ManeuverPoint><Latitude>38.879108</Latitude><Longitude>-76.997219</Longitude></ManeuverPoint><Instruction maneuverType="KeepLeft">Keep left onto I-695 South / Southeast Fwy</Instruction><CompassDirection>east</CompassDirection><Detail><ManeuverType>KeepLeft</ManeuverType><StartPathIndex>44</StartPathIndex><EndPathIndex>50</EndPathIndex><Name>Southeast Fwy</Name><CompassDegrees>99</CompassDegrees><Mode>Driving</Mode><PreviousEntityId>0</PreviousEntityId><NextEntityId>0</NextEntityId><RoadType>LimitedAccessHighway</RoadType><RoadShieldRequestParameters><Bucket>50402</Bucket><Shield><RoadShieldType>1</RoadShieldType><Label>695</Label></Shield></RoadShieldRequestParameters></Detail><Sign>Pennsylvania Ave</Sign><Exit /><TollZone /><TransitTerminus /><IconType>Auto</IconType><Time>0001-01-01T00:00:00</Time><TransitStopId>0</TransitStopId><TowardsRoadName /><SideOfStreet>Unknown</SideOfStreet></ItineraryItem><ItineraryItem><TravelMode>Driving</TravelMode><TravelDistance>0.255384</TravelDistance><TravelDuration>32</TravelDuration><ManeuverPoint><Latitude>38.876973</Latitude><Longitude>-76.984017</Longitude></ManeuverPoint><Instruction maneuverType="TakeRampRight">Take ramp right and follow signs for Pennsylvania Avenue</Instruction><CompassDirection>east</CompassDirection><Detail><ManeuverType>TakeRampRight</ManeuverType><StartPathIndex>50</StartPathIndex><EndPathIndex>55</EndPathIndex><CompassDegrees>82</CompassDegrees><Mode>Driving</Mode><PreviousEntityId>0</PreviousEntityId><NextEntityId>0</NextEntityId><RoadType>Ramp</RoadType></Detail><Sign>Pennsylvania Avenue</Sign><Exit /><TollZone /><TransitTerminus /><IconType>Auto</IconType><Time>0001-01-01T00:00:00</Time><TransitStopId>0</TransitStopId><TowardsRoadName /><SideOfStreet>Unknown</SideOfStreet></ItineraryItem><ItineraryItem><TravelMode>Driving</TravelMode><TravelDistance>0.451115</TravelDistance><TravelDuration>71</TravelDuration><ManeuverPoint><Latitude>38.877611</Latitude><Longitude>-76.979501</Longitude></ManeuverPoint><Instruction maneuverType="BearRight">Bear right onto Pennsylvania Ave SE</Instruction><CompassDirection>southeast</CompassDirection><Warning warningType="TrafficFlow" severity="Minor">Minor Congestion</Warning><Detail><ManeuverType>BearRight</ManeuverType><StartPathIndex>55</StartPathIndex><EndPathIndex>59</EndPathIndex><Name>Pennsylvania Ave SE</Name><CompassDegrees>117</CompassDegrees><Mode>Driving</Mode><PreviousEntityId>0</PreviousEntityId><NextEntityId>0</NextEntityId><RoadType>Highway</RoadType></Detail><Exit /><TollZone /><TransitTerminus /><IconType>Auto</IconType><Time>0001-01-01T00:00:00</Time><TransitStopId>0</TransitStopId><TowardsRoadName /><SideOfStreet>Unknown</SideOfStreet></ItineraryItem><ItineraryItem><TravelMode>Driving</TravelMode><TravelDistance>3.372181</TravelDistance><TravelDuration>231</TravelDuration><ManeuverPoint><Latitude>38.875031</Latitude><Longitude>-76.972522</Longitude></ManeuverPoint><Instruction maneuverType="RampThenHighwayLeft">Take ramp left for DC-295 North / Anacostia Fwy</Instruction><CompassDirection>northeast</CompassDirection><Detail><ManeuverType>TakeRampLeft</ManeuverType><StartPathIndex>59</StartPathIndex><EndPathIndex>62</EndPathIndex><CompassDegrees>35</CompassDegrees><Mode>Driving</Mode><PreviousEntityId>0</PreviousEntityId><NextEntityId>0</NextEntityId><RoadType>Ramp</RoadType></Detail><Detail><ManeuverType>Merge</ManeuverType><StartPathIndex>62</StartPathIndex><EndPathIndex>82</EndPathIndex><Name>Anacostia Fwy</Name><CompassDegrees>77</CompassDegrees><Mode>Driving</Mode><PreviousEntityId>0</PreviousEntityId><NextEntityId>0</NextEntityId><RoadType>LimitedAccessHighway</RoadType><RoadShieldRequestParameters><Bucket>50402</Bucket><Shield><RoadShieldType>3</RoadShieldType><Label>295</Label></Shield></RoadShieldRequestParameters></Detail><Exit /><TollZone /><TransitTerminus /><IconType>Auto</IconType><Time>0001-01-01T00:00:00</Time><TransitStopId>0</TransitStopId><TowardsRoadName /><SideOfStreet>Unknown</SideOfStreet></ItineraryItem><ItineraryItem><TravelMode>Driving</TravelMode><TravelDistance>16.947899</TravelDistance><TravelDuration>1023</TravelDuration><ManeuverPoint><Latitude>38.912169</Latitude><Longitude>-76.93401</Longitude></ManeuverPoint><Instruction maneuverType="RoadNameChange">Road name changes to MD-295 North</Instruction><CompassDirection>northeast</CompassDirection><Warning warningType="AdminDivisionChange" severity="None">Entering Maryland</Warning><Warning warningType="Congestion" severity="Minor">Minor Congestion: slow RT-450/Annapolis Rd to RT-197/Laurel Bowie Rd</Warning><Detail><ManeuverType>RoadNameChange</ManeuverType><StartPathIndex>82</StartPathIndex><EndPathIndex>176</EndPathIndex><CompassDegrees>42</CompassDegrees><Mode>Driving</Mode><PreviousEntityId>0</PreviousEntityId><NextEntityId>0</NextEntityId><RoadType>LimitedAccessHighway</RoadType><RoadShieldRequestParameters><Bucket>50402</Bucket><Shield><RoadShieldType>3</RoadShieldType><Label>295</Label></Shield></RoadShieldRequestParameters></Detail><Exit /><TollZone /><TransitTerminus /><IconType>Auto</IconType><Time>0001-01-01T00:00:00</Time><TransitStopId>0</TransitStopId><TowardsRoadName /><SideOfStreet>Unknown</SideOfStreet></ItineraryItem><ItineraryItem><TravelMode>Driving</TravelMode><TravelDistance>1.283753</TravelDistance><TravelDuration>108</TravelDuration><ManeuverPoint><Latitude>39.114633</Latitude><Longitude>-76.777187</Longitude></ManeuverPoint><Instruction maneuverType="RampThenHighwayRight">Take ramp right for MD-32 West toward Columbia</Instruction><CompassDirection>northeast</CompassDirection><Detail><ManeuverType>TakeRampRight</ManeuverType><StartPathIndex>176</StartPathIndex><EndPathIndex>183</EndPathIndex><CompassDegrees>65</CompassDegrees><Mode>Driving</Mode><PreviousEntityId>0</PreviousEntityId><NextEntityId>0</NextEntityId><RoadType>Ramp</RoadType></Detail><Detail><ManeuverType>Merge</ManeuverType><StartPathIndex>183</StartPathIndex><EndPathIndex>189</EndPathIndex><CompassDegrees>328</CompassDegrees><Mode>Driving</Mode><PreviousEntityId>0</PreviousEntityId><NextEntityId>0</NextEntityId><RoadType>LimitedAccessHighway</RoadType><RoadShieldRequestParameters><Bucket>50402</Bucket><Shield><RoadShieldType>3</RoadShieldType><Label>32</Label></Shield></RoadShieldRequestParameters></Detail><Sign>Columbia</Sign><Sign>MD-32 West</Sign><Exit /><TollZone /><TransitTerminus /><IconType>Auto</IconType><Time>0001-01-01T00:00:00</Time><TransitStopId>0</TransitStopId><TowardsRoadName /><SideOfStreet>Unknown</SideOfStreet></ItineraryItem><ItineraryItem><TravelMode>Driving</TravelMode><TravelDistance>0.288938</TravelDistance><TravelDuration>28</TravelDuration><ManeuverPoint><Latitude>39.125769</Latitude><Longitude>-76.790432</Longitude></ManeuverPoint><Instruction maneuverType="TakeRampRight">At exit 11, take ramp right and follow signs for Dorsey Run Road</Instruction><CompassDirection>northwest</CompassDirection><Detail><ManeuverType>TakeRampRight</ManeuverType><StartPathIndex>189</StartPathIndex><EndPathIndex>192</EndPathIndex><CompassDegrees>307</CompassDegrees><Mode>Driving</Mode><PreviousEntityId>0</PreviousEntityId><NextEntityId>0</NextEntityId><RoadType>Ramp</RoadType></Detail><Sign>Dorsey Run Road</Sign><Exit>11</Exit><TollZone /><TransitTerminus /><IconType>Auto</IconType><Time>0001-01-01T00:00:00</Time><TransitStopId>0</TransitStopId><TowardsRoadName /><SideOfStreet>Unknown</SideOfStreet></ItineraryItem><ItineraryItem><TravelMode>Driving</TravelMode><TravelDistance>0.198839</TravelDistance><TravelDuration>40</TravelDuration><ManeuverPoint><Latitude>39.12865</Latitude><Longitude>-76.794289</Longitude></ManeuverPoint><Instruction maneuverType="TurnLeft">Turn left onto Dorsey Run Rd</Instruction><CompassDirection>southwest</CompassDirection><Detail><ManeuverType>TurnLeft</ManeuverType><StartPathIndex>192</StartPathIndex><EndPathIndex>195</EndPathIndex><Name>Dorsey Run Rd</Name><CompassDegrees>205</CompassDegrees><Mode>Driving</Mode><PreviousEntityId>0</PreviousEntityId><NextEntityId>0</NextEntityId><RoadType>Ramp</RoadType></Detail><Exit /><TollZone /><TransitTerminus /><IconType>Auto</IconType><Time>0001-01-01T00:00:00</Time><TransitStopId>0</TransitStopId><TowardsRoadName /><SideOfStreet>Unknown</SideOfStreet></ItineraryItem><ItineraryItem><TravelMode>Driving</TravelMode><TravelDistance>0.168392</TravelDistance><TravelDuration>52</TravelDuration><ManeuverPoint><Latitude>39.126649</Latitude><Longitude>-76.795791</Longitude></ManeuverPoint><Instruction maneuverType="TurnLeft">Turn left onto Henkels Ln</Instruction><CompassDirection>east</CompassDirection><Detail><ManeuverType>TurnLeft</ManeuverType><StartPathIndex>195</StartPathIndex><EndPathIndex>200</EndPathIndex><Name>Henkels Ln</Name><CompassDegrees>111</CompassDegrees><Mode>Driving</Mode><PreviousEntityId>0</PreviousEntityId><NextEntityId>0</NextEntityId><RoadType>Street</RoadType></Detail><Exit /><TollZone /><TransitTerminus /><IconType>Auto</IconType><Time>0001-01-01T00:00:00</Time><TransitStopId>0</TransitStopId><TowardsRoadName /><SideOfStreet>Unknown</SideOfStreet></ItineraryItem><ItineraryItem><TravelMode>Driving</TravelMode><TravelDistance>0</TravelDistance><TravelDuration>0</TravelDuration><ManeuverPoint><Latitude>39.125276</Latitude><Longitude>-76.793373</Longitude></ManeuverPoint><Instruction maneuverType="ArriveFinish">Arrive at 8955 Henkels Ln, Annapolis Junction, MD 20701-1162 on the left</Instruction><CompassDirection>east</CompassDirection><Detail><ManeuverType>ArriveFinish</ManeuverType><StartPathIndex>200</StartPathIndex><EndPathIndex>200</EndPathIndex><Name>Henkels Ln</Name><CompassDegrees>102</CompassDegrees><Mode>Driving</Mode><PreviousEntityId>0</PreviousEntityId><NextEntityId>0</NextEntityId><RoadType>Street</RoadType></Detail><Exit /><TollZone /><TransitTerminus /><IconType>Auto</IconType><Time>0001-01-01T00:00:00</Time><TransitStopId>0</TransitStopId><TowardsRoadName /><SideOfStreet>Left</SideOfStreet></ItineraryItem><StartTime>0001-01-01T00:00:00</StartTime><EndTime>0001-01-01T00:00:00</EndTime></RouteLeg></Route></Resources></ResourceSet></ResourceSets></Response>';
        
        // execute
        String responseElement = BingMaps_BingServiceUtility.getResponseElement(body);
        BingMaps_RouteResult theRouteResult = BingMaps_BingServiceUtility.parseRouteResponse(responseElement);
        
        // assert
        double expectedMilesToOffice = 27.156407;
        double expectedDriveTimeInHoursLowBound = .60;      
        double expectedDriveTimeInHoursUpperBound = .61;
                
        System.assert(expectedDriveTimeInHoursLowBound < theRouteResult.driveTimeInHours);
        System.assert(expectedDriveTimeInHoursUpperBound > theRouteResult.driveTimeInHours);
        
        System.assertEquals(expectedMilesToOffice, theRouteResult.milesToOffice);           
    }

    public static testMethod void testParseLocationResponseForLatitudeAndLongitude() {
        // setup
        String body = '<?xml version="1.0" encoding="utf-8"?><Response xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://schemas.microsoft.com/search/local/ws/rest/v1"><Copyright>Copyright © 2011 Microsoft and its suppliers. All rights reserved. This API cannot be accessed and the content and any results may not be used, reproduced or transmitted in any manner without express written permission from Microsoft Corporation.</Copyright><BrandLogoUri>http://dev.virtualearth.net/Branding/logo_powered_by.png</BrandLogoUri><StatusCode>200</StatusCode><StatusDescription>OK</StatusDescription><AuthenticationResultCode>ValidCredentials</AuthenticationResultCode><TraceId>1f4e10f663a24806a6f101237a8faf2e|BL2M001304|02.00.126.1500|BL2MSNVM001280</TraceId><ResourceSets><ResourceSet><EstimatedTotal>3</EstimatedTotal><Resources><Location><Name>1600 Pennsylvania Ave NW, Washington, DC 20500-0003</Name><Point><Latitude>38.897099</Latitude><Longitude>-77.036697</Longitude></Point><BoundingBox><SouthLatitude>38.893236282429321</SouthLatitude><WestLongitude>-77.043314211613392</WestLongitude><NorthLatitude>38.900961717570674</NorthLatitude><EastLongitude>-77.030079788386615</EastLongitude></BoundingBox><EntityType>Address</EntityType><Address><AddressLine>1600 Pennsylvania Ave NW</AddressLine><AdminDistrict>DC</AdminDistrict><AdminDistrict2>City of Washington</AdminDistrict2><CountryRegion>United States</CountryRegion><FormattedAddress>1600 Pennsylvania Ave NW, Washington, DC 20500-0003</FormattedAddress><Locality>Washington</Locality><PostalCode>20500-0003</PostalCode></Address><Confidence>High</Confidence></Location><Location><Name>1600 Pennsylvania Ave NW, Washington, DC 20006</Name><Point><Latitude>38.898685474220486</Latitude><Longitude>-77.0356341012553</Longitude></Point><BoundingBox><SouthLatitude>38.894822756649809</SouthLatitude><WestLongitude>-77.042251460682976</WestLongitude><NorthLatitude>38.902548191791162</NorthLatitude><EastLongitude>-77.029016741827618</EastLongitude></BoundingBox><EntityType>Address</EntityType><Address><AddressLine>1600 Pennsylvania Ave NW</AddressLine><AdminDistrict>DC</AdminDistrict><CountryRegion>United States</CountryRegion><FormattedAddress>1600 Pennsylvania Ave NW, Washington, DC 20006</FormattedAddress><Locality>Washington</Locality><PostalCode>20006</PostalCode></Address><Confidence>High</Confidence></Location><Location><Name>1600 Pennsylvania Ave NW, Washington, DC 20005</Name><Point><Latitude>38.898685474220486</Latitude><Longitude>-77.035517988039416</Longitude></Point><BoundingBox><SouthLatitude>38.894822756649809</SouthLatitude><WestLongitude>-77.0421353474671</WestLongitude><NorthLatitude>38.902548191791162</NorthLatitude><EastLongitude>-77.028900628611737</EastLongitude></BoundingBox><EntityType>Address</EntityType><Address><AddressLine>1600 Pennsylvania Ave NW</AddressLine><AdminDistrict>DC</AdminDistrict><CountryRegion>United States</CountryRegion><FormattedAddress>1600 Pennsylvania Ave NW, Washington, DC 20005</FormattedAddress><Locality>Washington</Locality><PostalCode>20005</PostalCode></Address><Confidence>High</Confidence></Location></Resources></ResourceSet></ResourceSets></Response>';
        
        // execute
        String responseElement = BingMaps_BingServiceUtility.getResponseElement(body);
        BingMaps_LocationResult theLocationResult = BingMaps_BingServiceUtility.parseLocationResponse(responseElement);
        
        // assert
        double expectedLatitude = 38.897099;
        double expectedLongitude = -77.036697;      
                
        System.assertEquals(expectedLatitude, theLocationResult.latitude);
        System.assertEquals(expectedLongitude, theLocationResult.longitude);                
    }
  
    public static testMethod void testComputeGeoPoints() {
        String homeAddress = '1600 Pennsylvania Avenue NW, Washington, DC, 20500';  
        String officeAddress = '8955 Henkels Lane, Annapolis Junction, MD, 20701';  
        
        BingMaps_RouteResult theRouteResult = BingMaps_BingServiceUtility.computeGeoPoints(homeAddress, officeAddress);         
    }
   
    public static testMethod void testUpdateWithLocationResultAndRouteResult() {
        
        // setup
        double expectedDriveTimeInHours = .61;
        double expectedMilesToOffice = 27.156407;
    
        double expectedLatitude = 38.898748;
        double expectedLongitude= -77.037684;
        
        Property__c property = new Property__c();       
        property.Name = '1600 Pennsylvania Avenue NW';
        property.Property_City__c = 'Washington';
        property.Property_State__c = 'DC';
        property.Property_County__c = 'DC';
        property.Property_ZIP__c = '20500';
        property.Astrum_Office__c = testdata.defaultOffLocationName;// FPO Phase4 //'Annapolis Junction, MD';
        
        insert property;        
        Id propertyId = property.Id;
                
        // execute
        BingMaps_RouteResult theRouteResult = new BingMaps_RouteResult();
        theRouteResult.driveTimeInHours = expectedDriveTimeInHours;
        theRouteResult.milesToOffice = expectedMilesToOffice;
        
        BingMaps_LocationResult theLocationResult = new BingMaps_LocationResult();      
        theLocationResult.latitude = expectedLatitude;
        theLocationResult.longitude = expectedLongitude;
        
        BingMaps_BingServiceUtility.updateProperty(propertyId, theLocationResult, theRouteResult, 0);
                
        // assert       
        Property__c tempProperty = [SELECT Name, Hours_From_Nearest_Office__c, Miles_To_Office__c, Latitude__c, Longitude__c from Property__c where id =: propertyId LIMIT 1];
        System.assertEquals(expectedDriveTimeInHours, tempProperty.Hours_From_Nearest_Office__c);
        System.assertEquals(expectedMilesToOffice, tempProperty.Miles_To_Office__c);
        
        System.assertEquals(expectedLatitude, tempProperty.Latitude__c);
        System.assertEquals(expectedLongitude, tempProperty.Longitude__c);
    }

    public static testMethod void testUpdateWithAstrumOfficeChange() {
        
        // setup
        double expectedDriveTimeInHours = .61;
        double expectedMilesToOffice = 27.156407;
    
        double expectedLatitude = 38.898748;
        double expectedLongitude= -77.037684;
        
        Property__c property = new Property__c();       
        property.Name = '1600 Pennsylvania Avenue NW';
        property.Property_City__c = 'Washington';
        property.Property_State__c = 'DC';
        property.Property_County__c = 'DC';
        property.Property_ZIP__c = '20500';
        property.Astrum_Office__c = testdata.defaultOffLocationName;// FPO Phase4 //'Annapolis Junction, MD';
        
        insert property;        
        Id propertyId = property.Id;

        // execute
        BingMaps_RouteResult theRouteResult = new BingMaps_RouteResult();
        theRouteResult.driveTimeInHours = expectedDriveTimeInHours;
        theRouteResult.milesToOffice = expectedMilesToOffice;

        BingMaps_LocationResult theLocationResult = new BingMaps_LocationResult();      
        theLocationResult.latitude = expectedLatitude;
        theLocationResult.longitude = expectedLongitude;
        
        BingMaps_BingServiceUtility.updateProperty(propertyId, theLocationResult, theRouteResult);
         
        property.Astrum_Office__c = 'Hopkinton, MA';
        update property;
    }

    public static testMethod void testGetAstrumOfficeAddressForProperty() {
        
        // setup    
        String expected = '8955 Henkels Lane, Annapolis Junction, MD, 20701';           
        
        Property__c property = new Property__c();       
        property.Name = '1600 Pennsylvania Avenue NW';
        property.Property_City__c = 'Washington';
        property.Property_State__c = 'DC';
        property.Property_County__c = 'DC';
        property.Property_ZIP__c = '20500';
        property.Astrum_Office__c = testdata.defaultOffLocationName;// FPO Phase4 //'Annapolis Junction, MD';
        
        insert property;        
        Id propertyId = property.Id;
                
        Office_Location__c mdOffice = new Office_Location__c();
        mdOffice.Name = 'Annapolis Junction, MD';
        mdOffice.Street__c = '8955 Henkels Lane';
        mdOffice.City__c = 'Annapolis Junction';
        mdOffice.State__c = 'MD';
        mdOffice.Zip_Code__c = '20701';
        mdOffice.Active__c = true;//fpo2
        
        insert mdOffice;

        Office_Location__c paOffice = new Office_Location__c();
        paOffice.Name = 'Norristown, PA';
        paOffice.Street__c = '705 General Washington Avenue';
        paOffice.City__c = 'Norristown';
        paOffice.State__c = 'PA';
        paOffice.Zip_Code__c = '19403';
        paOffice.Active__c = true;//fpo2
        
        insert paOffice;
                    
        // execute
        String actual = BingMaps_BingServiceUtility.getAstrumOfficeAddressForProperty(propertyId);
        
        // assert       
        //System.assertEquals(expected, actual);
        System.assert(actual.containsIgnoreCase('MD'));
    }    
}