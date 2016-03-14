/* FILE: CleanPowerEstimator_ServiceClient.cls
 * AUTHOR: Rohit Jain
 * DATE: July 24, 2013
 * PURPOSE: Clean Power Estimator Web Service Callout for Site Quality
 * MODIFICATION HISTORY 
 */

public with sharing class CleanPowerEstimator_ServiceClient {

    public static String key = '681871320';         
    public static String cleanPowerUrl = 'http://cleanpowerestimator.com/estimator/webservice.asmx';
    public static String cleanPowerNamespace = 'http://www.clean-power.com';
    public static String soapNamespace = 'http://schemas.xmlsoap.org/soap/envelope/';
    
    private static final Map<String, String> STATE_OUTPUT_ADJ = new Map<String, String> {
        'NJ' => '-2', 
        'CT' => '-4',
        'MD' => '-15', 
        'MA' => '0',   
        'NY' => '-3',
        'PA' => '0',
        'DC' => '-5'
    };
     
    public static HttpResponse submitWebServiceRequest(String url, String body) {      
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(url);
        req.setBody(body);
        req.setTimeout(100000);
        req.setHeader('Content-Type', 'text/xml; charset=utf-8');        
        req.setHeader('SOAPAction', 'http://www.clean-power.com/GetDetailedResults');
        
        String contentLength = String.valueOf(body.length());
        req.setHeader('Content-Length', contentLength);

        Http h = new Http();
        if(!Test.isRunningTest())
        {
            return h.send(req);     
        }
        else
        {
            HttpResponse response = new HttpResponse ();
            response.setBody('<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><GetDetailedResultsResponse xmlns="http://www.clean-power.com"><GetDetailedResultsResult><PVSystem><rating_dc>1</rating_dc><rating_ac_ptc>0.855</rating_ac_ptc><annualOutput>1267.524</annualOutput></PVSystem><errorStatus><number /><message /></errorStatus></GetDetailedResultsResult></GetDetailedResultsResponse></soap:Body></soap:Envelope>'); 
            return response;
            
        }    
    }
    
    @Future(callout=true)
    public static void updateSiteQualityForLocation(ID itemid,String PostalCode, String State, String Azimuth, String Tilt, String Shading, Decimal upgradeFactor) {  
        Double siteQuality = getSiteQuality(PostalCode, State,Azimuth,Tilt,Shading);                           
         if (siteQuality != null) {
            System_Design_Item__c item = [Select Sunnova_Site_Quality__C from System_Design_Item__c Where Id = :itemid];
            if(upgradeFactor != null && upgradeFactor != 0)
            {
                item.Sunnova_Site_Quality__c = siteQuality * upgradeFactor;        
            }   
            else
            {
                item.Sunnova_Site_Quality__c = siteQuality;
            } 
            update item ;
        }
    }
    
    
    public static Double getSiteQuality(String PostalCode, String State, String Azimuth, String Tilt, String Shading) {     
      
      String soapMessage = 
         String.format( 
        '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
         + ' <soap:Body>'
         + '   <GetDetailedResults xmlns="http://www.clean-power.com">'
         + '     <xmlData>'
                    + '&lt;xmlInput&gt;'
                        + '&lt;assumptionsSet&gt;'
                              + '  &lt;license&gt;{0}&lt;/license&gt;'
                              + '  &lt;zipCode&gt;{1}&lt;/zipCode&gt;'
                              + '  &lt;PVCostTotal&gt;6000&lt;/PVCostTotal&gt;'
                              + '  &lt;weatherDataSource&gt;TMY3&lt;/weatherDataSource&gt;'
                              + '  &lt;PVSubsystemQuantity&gt;1&lt;/PVSubsystemQuantity&gt;'
                              + '  &lt;PVEquipmentLife&gt;30&lt;/PVEquipmentLife&gt;'
                              + '  &lt;systemDegradation&gt;0.005&lt;/systemDegradation&gt;'
                              + '  &lt;utilityBillEscalation&gt;3.00000&lt;/utilityBillEscalation&gt;'
                              + '  &lt;PVOutputAdjustment&gt;{2}&lt;/PVOutputAdjustment&gt;'
                              + '  &lt;PVSystemNameplate_1&gt;1&lt;/PVSystemNameplate_1&gt;'
                              + '  &lt;PVSystemSlope_1&gt;{3}&lt;/PVSystemSlope_1&gt;'
                              + '  &lt;PVSystemAzimuth_1&gt;{4}&lt;/PVSystemAzimuth_1&gt;'
                              + '  &lt;PVSystemMonthlyShading_1_1&gt;{5}&lt;/PVSystemMonthlyShading_1_1&gt;'
                              + '  &lt;PVSystemMonthlyShading_1_2&gt;{5}&lt;/PVSystemMonthlyShading_1_2&gt;'
                              + '  &lt;PVSystemMonthlyShading_1_3&gt;{5}&lt;/PVSystemMonthlyShading_1_3&gt;'
                              + '  &lt;PVSystemMonthlyShading_1_4&gt;{5}&lt;/PVSystemMonthlyShading_1_4&gt;'
                              + '  &lt;PVSystemMonthlyShading_1_5&gt;{5}&lt;/PVSystemMonthlyShading_1_5&gt;'
                              + '  &lt;PVSystemMonthlyShading_1_6&gt;{5}&lt;/PVSystemMonthlyShading_1_6&gt;'
                              + '  &lt;PVSystemMonthlyShading_1_7&gt;{5}&lt;/PVSystemMonthlyShading_1_7&gt;'
                              + '  &lt;PVSystemMonthlyShading_1_8&gt;{5}&lt;/PVSystemMonthlyShading_1_8&gt;'
                              + '  &lt;PVSystemMonthlyShading_1_9&gt;{5}&lt;/PVSystemMonthlyShading_1_9&gt;'
                              + '  &lt;PVSystemMonthlyShading_1_10&gt;{5}&lt;/PVSystemMonthlyShading_1_10&gt;'
                              + ' &lt;PVSystemMonthlyShading_1_11&gt;{5}&lt;/PVSystemMonthlyShading_1_11&gt;'
                              + '  &lt;PVSystemMonthlyShading_1_12&gt;{5}&lt;/PVSystemMonthlyShading_1_12&gt;'
                              + '  &lt;annualConsumption&gt;12000.00000&lt;/annualConsumption&gt;'
                        + '  &lt;/assumptionsSet&gt;'
                        + ' &lt;outputsSet&gt;'
                             + '   &lt;summary&gt;no&lt;/summary&gt;'
                             + '   &lt;PVSystem&gt;yes&lt;/PVSystem&gt;'
                             + '   &lt;STSystem&gt;no&lt;/STSystem&gt;'
                             + '   &lt;costBreakdown&gt;no&lt;/costBreakdown&gt;'
                             + '   &lt;netCostDetail&gt;no&lt;/netCostDetail&gt;'
                             + '   &lt;incentiveDetails&gt;no&lt;/incentiveDetails&gt;'
                             + '   &lt;emissionsReduction&gt;no&lt;/emissionsReduction&gt;'
                             + '   &lt;electricBillDetails&gt;no&lt;/electricBillDetails&gt;'
                             + '   &lt;electricBillBreakdown&gt;no&lt;/electricBillBreakdown&gt;'
                             + '   &lt;monthlyUtilityBill&gt;no&lt;/monthlyUtilityBill&gt;'
                             + '   &lt;cashFlowSummary&gt;no&lt;/cashFlowSummary&gt;'
                             + '   &lt;cashFlowDetails&gt;no&lt;/cashFlowDetails&gt;'
                             + '   &lt;annualLoad&gt;no&lt;/annualLoad&gt;'
                             + '   &lt;monthlyLoad&gt;no&lt;/monthlyLoad&gt;'
                             + '   &lt;hourlyLoad_1&gt;no&lt;/hourlyLoad_1&gt;'
                        + ' &lt;/outputsSet&gt;'
                  + '  &lt;/xmlInput&gt;'
                 + '      </xmlData>'
             + '    </GetDetailedResults>'
             + '  </soap:Body>'
         + ' </soap:Envelope>'  ,  new String [] {KEY,PostalCode,STATE_OUTPUT_ADJ.GET(State),Tilt,Azimuth,Shading});
    
        System.debug(soapMessage);
        HttpResponse response = submitWebServiceRequest(cleanPowerUrl , soapMessage);         
        System.debug(response.getBody());
        Dom.Document doc = response.getBodyDocument();                
        Dom.Xmlnode getCPREResultNode = doc.getRootElement().getChildElement('Body', soapNamespace).getChildElement('GetDetailedResultsResponse', cleanPowerNamespace ).getChildElement('GetDetailedResultsResult', cleanPowerNamespace );
        
        Dom.Xmlnode annualOutputInfoNode = getCPREResultNode .getChildren()[0];
        Double annualOutput = getValue(annualOutputInfoNode , 'annualOutput', cleanPowerNamespace );
        System.debug('*'+annualOutput );                   
        return annualOutput ;
    }
    
    public static double getValue(Dom.Xmlnode theParentNode, String elementName, String namespace) {
        Dom.xmlnode theNode = theParentNode.getChildElement(elementName, namespace);
        return Double.valueOf(theNode.getText());       
    }
    
}