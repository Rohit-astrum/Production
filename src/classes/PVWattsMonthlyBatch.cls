/* FILE: PVWattsMonthlyBatch.cls
 * AUTHOR: Rohit Jain
 * DATE: May 10, 2013
 * PURPOSE: Collects and adds PVWatts production estimates for Installed Systems
 *   to invoke: PVWattsMonthlyBatch pwb = new PVWattsMonthlyBatch();
 *          Id batchId = Database.executeBatch(pwb, 10); //must be 10 - callout governor limit
 * MODIFICATION HISTORY
 *
 */

global class PVWattsMonthlyBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    
    //jan-dec and total
    private static String[] fieldNames = new String[] {
        'January__c', 'February__c', 'March__c', 'April__c', 'May__c', 'June__c',
        'July__c', 'August__c', 'September__c', 'October__c', 'November__c', 'December__c',
        'Annual_Total__c'
    };

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Quoted_System_Design__r.System_Design__r.Overall_TSRF__c, ' + 
            'Property__r.Confirmed_Location__Latitude__s, Property__r.Confirmed_Location__Longitude__s,Property__r.Latitude__c, Property__r.Longitude__c, Property__r.QAS_Latitude__c, ' + 
            'Property__r.QAS_Longitude__c, Property__r.DC_to_AC_Derate__c ' +
            'FROM Installed_System__c ' +
            'WHERE Quoted_System_Design__c <> NULL ' +
            'AND Id NOT IN ' +
            ' (SELECT Installed_System__c FROM PVWatts_Production_Estimates__c) ' 
        );
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        
        List<PVWatts_Production_Estimates__c> estimates = new List<PVWatts_Production_Estimates__c>(); 
        List<Installed_System__c> installSystemUpdates = new List<Installed_System__c>(); 
        
        for (Installed_System__c sys : (List<Installed_System__c>)scope) 
        {
            try 
            {
                
                PVWatts_Production_Estimates__c estimate = getPVWattsData(sys);

                System.debug('******************'+estimate);
                if(estimate != null && estimate.January__C != null && estimate.Annual_Total__c != null)
                {
                    estimates.add(estimate);
               
                    sys.Monthly_Production_Factor_Jan__c = ((estimate.January__C/estimate.Annual_Total__c)*100).setScale(2);
                    sys.Monthly_Production_Factor_Feb__c = ((estimate.February__C/estimate.Annual_Total__c)*100).setScale(2);
                    sys.Monthly_Production_Factor_Mar__c = ((estimate.March__C/estimate.Annual_Total__c)*100).setScale(2);
                    sys.Monthly_Production_Factor_Apr__c = ((estimate.April__C/estimate.Annual_Total__c)*100).setScale(2);
                    sys.Monthly_Production_Factor_May__c = ((estimate.May__C/estimate.Annual_Total__c)*100).setScale(2);
                    sys.Monthly_Production_Factor_Jun__c = ((estimate.June__C/estimate.Annual_Total__c)*100).setScale(2);
                    sys.Monthly_Production_Factor_Jul__c = ((estimate.July__C/estimate.Annual_Total__c)*100).setScale(2);
                    sys.Monthly_Production_Factor_Aug__c = ((estimate.August__C/estimate.Annual_Total__c)*100).setScale(2);
                    sys.Monthly_Production_Factor_Sep__c = ((estimate.September__C/estimate.Annual_Total__c)*100).setScale(2);
                    sys.Monthly_Production_Factor_Oct__c = ((estimate.October__C/estimate.Annual_Total__c)*100).setScale(2);
                    sys.Monthly_Production_Factor_Nov__c = ((estimate.November__C/estimate.Annual_Total__c)*100).setScale(2);
                    sys.Monthly_Production_Factor_Dec__c = ((estimate.December__C/estimate.Annual_Total__c)*100).setScale(2);
                    
                    installSystemUpdates.add(sys); 
                
                }
                
        
            } 
            catch (Exception e) 
            {
                System.debug('**Error - '+ e);
            }
            
        }
        
        if (!estimates.isEmpty()) {
            insert estimates;
        }
        
         if (!installSystemUpdates.isEmpty()) {
            update installSystemUpdates;
        }
        
    }
    
    global void execute(SchedulableContext SC) {
      PVWattsMonthlyBatch batch = new PVWattsMonthlyBatch ();
      Id batchId = Database.executeBatch(batch, 10);
    }

    global void finish(Database.BatchableContext bc) {
        
    }
    
    private PVWatts_Production_Estimates__c getPVWattsData(Installed_System__c sys) {
        
        PVWatts_Production_Estimates__c result = new PVWatts_Production_Estimates__c (
            Installed_System__c = sys.Id
        );

        String soapMessage = 
         String.format( 
        'http://developer.nrel.gov/api/pvwatts/v4.json?api_key={0}&system_size=1.0&derate={1}&lat={2}&lon={3}&azimuth={4}&track_mode=0&tilt={5}&timeframe=hourly'  
            ,  new String [] {PVWatts_ServiceClient.nrgkey 
                             ,sys.Property__r.DC_to_AC_Derate__c != null ? String.valueOf(sys.Property__r.DC_to_AC_Derate__c) : '0.925'
                             ,sys.Property__r.Confirmed_Location__Latitude__s != null ? String.valueOf(sys.Property__r.Confirmed_Location__Latitude__s) : (sys.Property__r.QAS_Latitude__c != null ? sys.Property__r.QAS_Latitude__c : String.valueOf(sys.Property__r.Latitude__c))
                             ,sys.Property__r.Confirmed_Location__Longitude__s != null ? String.valueOf(sys.Property__r.Confirmed_Location__Longitude__s) : (sys.Property__r.QAS_Longitude__c != null ? sys.Property__r.QAS_Longitude__c : String.valueOf(sys.Property__r.Longitude__c))
                             ,'180.0'
                             ,sys.Property__r.Confirmed_Location__Latitude__s != null ? String.valueOf(sys.Property__r.Confirmed_Location__Latitude__s) : (sys.Property__r.QAS_Latitude__c != null ? sys.Property__r.QAS_Latitude__c : String.valueOf(sys.Property__r.Latitude__c))
                            });
    
        System.debug('##soapMessage - '+soapMessage);
        HttpResponse response = PVWatts_ServiceClient.submitWebServiceRequest(soapMessage);         
        System.debug(response.getBody());        
        // Parse JSON response to get all the totalPrice field values.
        JSONParser parser = JSON.createParser(response.getBody());              
        
        double annual_total = 0;
        String currentArray;
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'ac_monthly')) 
            {    
                currentArray =  parser.getText();
            }
            if (parser.getCurrentToken() == JSONToken.START_ARRAY && currentArray == 'ac_monthly') 
            {
                integer i = 0;
                while (parser.nextToken() != null ) 
                {                                   
                    if(parser.getCurrentToken() == JSONToken.END_ARRAY)  
                    {
                        break;
                    }   
                    result.put(fieldNames[i], parser.getDoubleValue());  
                    System.debug(fieldNames[i] + ':' + parser.getDoubleValue());        
                    annual_total = annual_total + parser.getDoubleValue();     
                    i = i+1;  
                }
                result.Annual_Total__c =  annual_total; 
                result.Latitude__c =  sys.Property__r.Confirmed_Location__Latitude__s != null ? sys.Property__r.Confirmed_Location__Latitude__s : (sys.Property__r.QAS_Latitude__c != null ? Decimal.valueOf(sys.Property__r.QAS_Latitude__c) : sys.Property__r.Latitude__c);
                result.Longitude__c = sys.Property__r.Confirmed_Location__Longitude__s != null ? sys.Property__r.Confirmed_Location__Longitude__s : (sys.Property__r.QAS_Longitude__c != null ? Decimal.valueOf(sys.Property__r.QAS_Longitude__c) : sys.Property__r.Longitude__c);
                break;
            }    
        }


        /*

        //0-11 are monthly, 12 is annual
        for (Integer i = 0; i < 12; i++) {
            String fieldName = fieldNames[i];
            result.put(fieldName, ac_monthly[i]);  
            
            PVWatts.PVWATTSinfo info = new PVWatts.PVWATTSInfo();
            Dom.Xmlnode pv = pvWattsInfos[i];
            
            if (i == 0) {

                DOM.XmlNode Latitude = pv.getChildElement('Latitude', PVWatts_ServiceClient.pvWattsNamespace);
                if (Latitude != null) { result.Latitude__c = Decimal.valueOf(Latitude.getText()); }
    
                DOM.XmlNode Longitude = pv.getChildElement('Longitude', PVWatts_ServiceClient.pvWattsNamespace);
                if (Longitude != null) { result.Longitude__c = Decimal.valueOf(Longitude.getText()); }
    
                DOM.XmlNode DCrating = pv.getChildElement('DCrating', PVWatts_ServiceClient.pvWattsNamespace);
                if (DCrating != null) { result.DCrating__c = Decimal.valueOf(DCrating.getText()); }
                
            }
            
            
           
            DOM.XmlNode ACenergy = pv.getChildElement('ACenergy', PVWatts_ServiceClient.pvWattsNamespace);
            if (ACenergy != null) { 
                              
            }
            
        }   */  

        return result;              
        
    }
    
    /*
    private PVWatts_Production_Estimates__c getPVWattsData(Installed_System__c sys) {
        
        PVWatts_Production_Estimates__c result = new PVWatts_Production_Estimates__c (
            Installed_System__c = sys.Id
        );
       
        String soapMessage = String.format(
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"'
            + ' xmlns:pvw="http://pvwatts.nrel.gov">'
            + '<soapenv:Header/>'
            + '<soapenv:Body>'
            + '<pvw:GetPVWATTS>'
            + '<pvw:key>{0}</pvw:key>'
            + '<pvw:latitude>{1}</pvw:latitude>'
            + '<pvw:longitude>{2}</pvw:longitude>'
            + '<pvw:locationID>location</pvw:locationID>'
            + '<pvw:DCrating>{6}</pvw:DCrating>'
            + '<pvw:derate>{4}</pvw:derate>'
            + '<pvw:cost>0.1001</pvw:cost>'
            + '<pvw:mode>0</pvw:mode>'
            + '<pvw:tilt>{3}</pvw:tilt>'
            + '<pvw:azimuth>{5}</pvw:azimuth>'
            + '<pvw:inoct>1</pvw:inoct>'
            + '<pvw:pwrdgr>1</pvw:pwrdgr>'
            + '</pvw:GetPVWATTS>'
            + '</soapenv:Body>'
            + '</soapenv:Envelope>',
            new String [] {
                PVWatts_ServiceClient.key,
                sys.Property__r.QAS_Latitude__c != null ? sys.Property__r.QAS_Latitude__c : String.valueOf(sys.Property__r.Latitude__c), 
                sys.Property__r.QAS_Longitude__c != null ? sys.Property__r.QAS_Longitude__c : String.valueOf(sys.Property__r.Longitude__c),
                sys.Property__r.QAS_Latitude__c != null ? sys.Property__r.QAS_Latitude__c : String.valueOf(sys.Property__r.Latitude__c),  // Latitude of System //'32.0', //optimal pitch
                sys.Property__r.DC_to_AC_Derate__c != null ? String.valueOf(sys.Property__r.DC_to_AC_Derate__c) : '0.925' ,
                '180.0', //optimal azimuth
                '1' //DC Rating = 1 
            }
        );
        
        HttpResponse response = PVWatts_ServiceClient.submitWebServiceRequest(PVWatts_ServiceClient.pvWattsUrl, soapMessage);
       
        Dom.Document doc = new Dom.Document();
        doc.load(response.getBody());       

        Dom.Xmlnode getPvWattsResultNode = 
            doc.getRootElement().getChildElement('Body', PVWatts_ServiceClient.soapNamespace)
            .getChildElement('GetPVWATTSResponse', PVWatts_ServiceClient.pvWattsNamespace)
            .getChildElement('GetPVWATTSResult', PVWatts_ServiceClient.pvWattsNamespace);
        
        Dom.Xmlnode[] pvWattsInfos = getPvWattsResultNode.getChildren();

        //0-11 are monthly, 12 is annual
        for (Integer i = 0; i < 13; i++) {
            PVWatts.PVWATTSinfo info = new PVWatts.PVWATTSInfo();
            Dom.Xmlnode pv = pvWattsInfos[i];
            
            if (i == 0) {

                DOM.XmlNode Latitude = pv.getChildElement('Latitude', PVWatts_ServiceClient.pvWattsNamespace);
                if (Latitude != null) { result.Latitude__c = Decimal.valueOf(Latitude.getText()); }
    
                DOM.XmlNode Longitude = pv.getChildElement('Longitude', PVWatts_ServiceClient.pvWattsNamespace);
                if (Longitude != null) { result.Longitude__c = Decimal.valueOf(Longitude.getText()); }
    
                DOM.XmlNode DCrating = pv.getChildElement('DCrating', PVWatts_ServiceClient.pvWattsNamespace);
                if (DCrating != null) { result.DCrating__c = Decimal.valueOf(DCrating.getText()); }
                
            }

            String fieldName = fieldNames[i];
           
            DOM.XmlNode ACenergy = pv.getChildElement('ACenergy', PVWatts_ServiceClient.pvWattsNamespace);
            if (ACenergy != null) { 
                result.put(fieldName, Decimal.valueOf(ACenergy.getText()));                
            }
            
        }     

        return result;              
        
    }
    */

}