/* FILE: PVWattsBatch.cls
 * AUTHOR: Tino Mattheou
 * DATE: October 2, 2012
 * PURPOSE: Collects and adds PVWatts production estimates for Installed Systems
 *   to invoke: PVWattsBatch pwb = new PVWattsBatch();
 *          Id batchId = Database.executeBatch(pwb, 10); //must be 10 - callout governor limit
 * MODIFICATION HISTORY
 *
 */

global class PVWattsBatch  {
    /*
    //submits the batch to run
    public static Id run() {
        PVWattsBatch pwb = new PVWattsBatch();
        return Database.executeBatch(pwb, 10);
    }
    
    //jan-dec and total
    private static String[] fieldNames = new String[] {
        'PVWatts_January_Estimate_kWh__c', 'PVWatts_February_Estimate_kWh__c', 
        'PVWatts_March_Estimate_kWh__c', 'PVWatts_April_Estimate_kWh__c', 
        'PVWatts_May_Estimate_kWh__c', 'PVWatts_June_Estimate_kWh__c',
        'PVWatts_July_Estimate_kWh__c', 'PVWatts_August_Estimate_kWh__c', 
        'PVWatts_September_Estimate_kWh__c', 'PVWatts_October_Estimate_kWh__c', 
        'PVWatts_November_Estimate_kWh__c', 'PVWatts_December_Estimate_kWh__c'
    };

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Total_System_Size_kW__c, Quoted_System_Design__r.System_Design__r.Overall_TSRF__c, ' + 
            'Property__r.Latitude__c, Property__r.Longitude__c, Property__r.QAS_Latitude__c, ' + 
            'Property__r.QAS_Longitude__c ' +
            'FROM Installed_System__c ' +
            'WHERE Quoted_System_Design__c <> NULL ' +
            'AND PVWatts_Annual_Estimate_kWh__c = NULL'
        );
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        
        List<Installed_System__c> estimates = new List<Installed_System__c>(); 
        
        for (Installed_System__c sys : (List<Installed_System__c>)scope) {
//          try {
            
                estimates.add(getPVWattsData(sys));
        
//          } catch (Exception e) {
                //TODO: log this somewhere
//          }
            
        }
        
        if (!estimates.isEmpty()) {
            update estimates;
        }
        
    }

    global void finish(Database.BatchableContext bc) {
        
    }

    private Installed_System__c getPVWattsData(Installed_System__c sys) {
        
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
            + '<pvw:DCrating>{5}</pvw:DCrating>'
            + '<pvw:derate>0.876</pvw:derate>'
            + '<pvw:cost>0.1001</pvw:cost>'
            + '<pvw:mode>0</pvw:mode>'
            + '<pvw:tilt>{3}</pvw:tilt>'
            + '<pvw:azimuth>{4}</pvw:azimuth>'
            + '<pvw:inoct>1</pvw:inoct>'
            + '<pvw:pwrdgr>1</pvw:pwrdgr>'
            + '</pvw:GetPVWATTS>'
            + '</soapenv:Body>'
            + '</soapenv:Envelope>',
            new String [] {
                PVWatts_ServiceClient.key,
                sys.Property__r.QAS_Latitude__c != null ? sys.Property__r.QAS_Latitude__c : String.valueOf(sys.Property__r.Latitude__c), 
                sys.Property__r.QAS_Longitude__c != null ? sys.Property__r.QAS_Longitude__c : String.valueOf(sys.Property__r.Longitude__c),
                '32.0', //optimal pitch
                '180.0', //optimal azimuth
                String.valueOf(sys.Total_System_Size_kW__c * sys.Quoted_System_Design__r.System_Design__r.Overall_TSRF__c / 100.0) //system size * TSRF 
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
        for (Integer i = 0; i < 12; i++) {
            PVWatts.PVWATTSinfo info = new PVWatts.PVWATTSInfo();
            Dom.Xmlnode pv = pvWattsInfos[i];
            
            String fieldName = fieldNames[i];
            
            DOM.XmlNode ACenergy = pv.getChildElement('ACenergy', PVWatts_ServiceClient.pvWattsNamespace);
            if (ACenergy != null) { 
                sys.put(fieldName, Decimal.valueOf(ACenergy.getText())); 
            }
            
        }     

        return sys;             
        
    }
    
    */

}