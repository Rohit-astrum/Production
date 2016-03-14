/* FILE: EnphaseAPI.cls
 * AUTHOR: Tino Mattheou
 * DATE: September 13, 2012
 * PURPOSE: Implements callouts to Enphase API  
 *     see: https://enlighten.enphaseenergy.com/doc/api/index.html
 * MODIFICATION HISTORY
 *
 */ 
 
global class EnphaseAPI {
    
    public static final String ENPHASE_ENDPOINT = 'https://api.enphaseenergy.com/api';
    public static final Integer ENPHASE_TIMEOUT = 30000; //30 seconds
    
    public transient String debugResponse;
    
    //used for testing; set to true to allow for mock response
    public Boolean mockResponse = false;
    
    private String apiKey {
        get {
            return Enphase_API_Settings__c.getOrgDefaults().API_Key__c;
        }
    } 
    
    ///////////// INDEX ///////////////////

    //list of systems you can call API on
    public List<EnphaseSystem> index() {
        
        List<EnphaseSystem> result = new List<EnphaseSystem>();
        
        if (Test.isRunningTest() && mockResponse != true) {
            return result;
        }

        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        String url = ENPHASE_ENDPOINT + '/systems' + '?key=' + apiKey; 
        req.setEndpoint(url);   
        req.setHeader('Accept-Encoding','compress, gzip');
        req.setTimeout(ENPHASE_TIMEOUT);
        
        Http http = new Http();
        HttpResponse response = http.send(req);
        
        String responseText = response.getBody();
        debugResponse = responseText;
        
        if (response.getStatusCode() != 200) {
            throw new EnphaseException(responseText);
        }       
        
        JSONParser parser = JSON.createParser(responseText);
        
        Integer nesting = 0;
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                nesting++;
            }
            if (parser.getCurrentToken() == JSONToken.END_OBJECT) {
                nesting--;
                if (nesting == 0) {
                    break;
                }
            }
            if (nesting == 1) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'systems') {
                    result = deserializeSystems(parser);
                }
            }
        }
        
        return result;      
    }
    
    //deserialize an array of EnphaseSystem objects
    private List<EnphaseSystem> deserializeSystems(JSONParser parser) {
        List<EnphaseSystem> systems = new List<EnphaseSystem>();
        Integer nesting = 0;
        while(parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                nesting++;
            }
            if (parser.getCurrentToken() == JSONToken.END_ARRAY) {
                nesting--;
                if (nesting == 0) {
                    break;
                }
            }
            if (parser.getCurrentToken() == JSONToken.START_OBJECT && nesting == 1) {
                systems.add(new EnphaseSystem().deserialize(parser));
            }
        }
        return systems;
    }

    ///////////////// SUMMARY //////////////////
    
    //summary stats for enphase system
    public EnphaseSummary summary(Integer system_id, DateTime summary_date) {

        EnphaseSummary result = new EnphaseSummary();

        if (Test.isRunningTest() && mockResponse != true) {
            return result;
        }
        
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        String url = ENPHASE_ENDPOINT + '/systems/' + system_id + '/summary' + '?key=' + apiKey;
        if (summary_date != null) {
            url += '&summary_date=' + summary_date.format('yyyy-MM-dd');
        } 
        req.setEndpoint(url);   
        req.setHeader('Accept-Encoding','compress, gzip');
        req.setTimeout(ENPHASE_TIMEOUT);
        
        Http http = new Http();
        HttpResponse response = http.send(req);

        String responseText = response.getBody();
        debugResponse = responseText;
        
        if (response.getStatusCode() != 200) {
            throw new EnphaseException(responseText);
        }       
        
        JSONParser parser = JSON.createParser(responseText);
        return result.deserialize(parser);  
        
    }

    ///////////////// ALERTS //////////////////
    
    //summary stats for enphase system
    //level = low, medium, high
    public List<EnphaseAlert> alerts(Integer system_id, String level) {

        List<EnphaseAlert> result = new List<EnphaseAlert>();

        if (Test.isRunningTest() && mockResponse != true) {
            return result;
        }
        
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        String url = ENPHASE_ENDPOINT + '/systems/' + system_id + '/alerts' + '?key=' + apiKey;
        if (level != null && level.trim() != '') {
            url += '&level=' + level;
        } 
        req.setEndpoint(url);   
        req.setHeader('Accept-Encoding','compress, gzip');
        req.setTimeout(ENPHASE_TIMEOUT);
        
        Http http = new Http();
        HttpResponse response = http.send(req);

        String responseText = response.getBody();
        debugResponse = responseText;
        
        if (response.getStatusCode() != 200) {
            throw new EnphaseException(responseText);
        }       
        
        JSONParser parser = JSON.createParser(responseText);
        
        Integer nesting = 0;
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                nesting++;
            }
            if (parser.getCurrentToken() == JSONToken.END_OBJECT) {
                nesting--;
                if (nesting == 0) {
                    break;
                }
            }
            if (nesting == 1) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'alerts') {
                    result = deserializeAlerts(parser);
                }
            }
        }
        
        return result;      
        
    }
    
    //deserialize an array of EnphaseSystem objects
    private List<EnphaseAlert> deserializeAlerts(JSONParser parser) {
        List<EnphaseAlert> alerts = new List<EnphaseAlert>();
        Integer nesting = 0;
        while(parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                nesting++;
            }
            if (parser.getCurrentToken() == JSONToken.END_ARRAY) {
                nesting--;
                if (nesting == 0) {
                    break;
                }
            }
            if (parser.getCurrentToken() == JSONToken.START_OBJECT && nesting == 1) {
                alerts.add(new EnphaseAlert().deserialize(parser));
            }
        }
        return alerts;
    }
    
    ///////////////// MONTHLY PRODUCTION //////////////////
    
    //one month production for enphase system
    public EnphaseMonthlyProduction monthly_production(Integer system_id, Date start) {

        EnphaseMonthlyProduction result = new EnphaseMonthlyProduction();

        if (Test.isRunningTest() && mockResponse != true) {
            return result;
        }
        
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        String url = ENPHASE_ENDPOINT + '/systems/' + system_id + '/monthly_production' + '?key=' + apiKey;
        if (start != null) {
            DateTime dtStart = DateTime.newInstance(start, Time.newInstance(0, 0, 0, 0));
            url += '&start=' + dtStart.format('yyyy-MM-dd');
        } 
        req.setEndpoint(url);   
        req.setHeader('Accept-Encoding','compress, gzip');
        req.setTimeout(ENPHASE_TIMEOUT);
        
        Http http = new Http();
        HttpResponse response = http.send(req);

        String responseText = response.getBody();
        debugResponse = responseText;
        
        if (response.getStatusCode() != 200) {
            throw new EnphaseException(responseText);
        }       
        
        JSONParser parser = JSON.createParser(responseText);
        return result.deserialize(parser);  
        
    }
    
    ///////////////// POWER TODAY / POWER WEEK //////////////////
    
    //days worth of data
    public List<EnphaseProduction> power_today(Integer system_id) {
        return power(system_id, 'power_today');
    }

    public List<EnphaseProduction> power_week(Integer system_id) {
        return power(system_id, 'power_week');
    }

    private List<EnphaseProduction> power(Integer system_id, String apiName) {

        List<EnphaseProduction> result = new List<EnphaseProduction>();

        if (Test.isRunningTest() && mockResponse != true) {
            return result;
        }
        
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        String url = ENPHASE_ENDPOINT + '/systems/' + system_id + '/' + apiName + '?key=' + apiKey;
        req.setEndpoint(url);   
        req.setHeader('Accept-Encoding','compress, gzip');
        req.setTimeout(ENPHASE_TIMEOUT);
        
        Http http = new Http();
        HttpResponse response = http.send(req);

        String responseText = response.getBody();
        debugResponse = responseText;
        
        if (response.getStatusCode() != 200) {
            throw new EnphaseException(responseText);
        }       
        
        JSONParser parser = JSON.createParser(responseText);
        
        DateTime first_interval_end_date;
        Integer interval_length;
        List<Integer> production;
        Integer nesting = 0;
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                nesting++;
            }
            if (parser.getCurrentToken() == JSONToken.END_OBJECT) {
                nesting--;
                if (nesting == 0) {
                    break;
                }
            }
            if (nesting == 1) {
                if (parser.getCurrentToken() == JSONToken.VALUE_STRING) {
                    if (parser.getCurrentName() == 'first_interval_end_date') {
                        first_interval_end_date = parser.getDatetimeValue();
                    }
                } else if (parser.getCurrentToken() == JSONToken.VALUE_NUMBER_INT) {
                    if (parser.getCurrentName() == 'interval_length') {
                        interval_length = parser.getIntegerValue();
                    }
                } else if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    if (parser.getCurrentName() == 'production') {
                         production = (List<Integer>)parser.readValueAs(List<Integer>.class);
                    }
                }
            }
        }
        
        if (first_interval_end_date != null && interval_length != null && production != null && interval_length > 0) {
            first_interval_end_date = first_interval_end_date.addSeconds(-interval_length); //back up to beginning of interval 
            for (Integer prod : production) {
                EnphaseProduction ep = new EnphaseProduction();
                ep.productionDate = first_interval_end_date;
                ep.wattHours = prod;
                result.add(ep);
                first_interval_end_date = first_interval_end_date.addSeconds(interval_length);
            }
        }
        
        return result;  
        
    }
    
    ///////////// ENERGY LIFETIME /////////////////////
    
    //lifetime production data (daily)
    public List<EnphaseProduction> energy_lifetime(Integer system_id) {
        
        List<EnphaseProduction> result = new List<EnphaseProduction>();

        if (Test.isRunningTest() && mockResponse != true) {
            return result;
        }
        
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        String url = ENPHASE_ENDPOINT + '/systems/' + system_id + '/energy_lifetime' + '?key=' + apiKey; 
        req.setEndpoint(url);   
        req.setHeader('Accept-Encoding','compress, gzip');
        req.setTimeout(ENPHASE_TIMEOUT);
        
        Http http = new Http();
        HttpResponse response = http.send(req);

        String responseText = response.getBody();
        debugResponse = responseText;
        
        if (response.getStatusCode() != 200) {
            throw new EnphaseException(responseText);
        }       
        
        JSONParser parser = JSON.createParser(responseText);
        
        DateTime startDate;
        List<Integer> production;
        Integer nesting = 0;
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                nesting++;
            }
            if (parser.getCurrentToken() == JSONToken.END_OBJECT) {
                nesting--;
                if (nesting == 0) {
                    break;
                }
            }
            if (nesting == 1) {
                if (parser.getCurrentToken() == JSONToken.VALUE_STRING) {
                    if (parser.getCurrentName() == 'start_date') {
                        startDate = parser.getDatetimeValue();
                    }
                } else if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    if (parser.getCurrentName() == 'production') {
                         production = (List<Integer>)parser.readValueAs(List<Integer>.class);
                    }
                }
            }
        }
        
        if (startDate != null && production != null) {
            for (Integer prod : production) {
                EnphaseProduction ep = new EnphaseProduction();
                ep.productionDate = startDate;
                ep.wattHours = prod;
                result.add(ep);
                startDate = startDate.addDays(1);
            }
        }
        
        return result;      
    }
    
    //summarizes daily data into monthly data
    public List<EnphaseProduction> energy_lifetime_monthly(Integer system_id) {
        
        List<EnphaseProduction> dailyProd = energy_lifetime(system_id);
        Boolean firstfullMonthFound = false;
        Boolean zeroProductionFound  = false;
        
        if (dailyProd.isEmpty()) {
            return dailyProd;
        }
        
        List<EnphaseProduction> monthlyProd = new List<EnphaseProduction>();
        
        DateTime startDate = dailyProd[0].productionDate;
        
        EnphaseProduction accum = new EnphaseProduction();
        //System.debug('*startDate  '+ startDate );
        if(startDate.day() != 1)
        {
            zeroProductionFound  = true;
        }
        
        for (EnphaseProduction ep : dailyProd) {
            if (accum.productionDate == null) {
                accum.productionDate = ep.ProductionDate;
                accum.wattHours = 0;
            }
            if( !(firstfullMonthFound ) &&  !(zeroProductionFound)   && (ep.wattHours == null || ep.wattHours <= 0))
            {
                zeroProductionFound  = true;    
            }
            accum.wattHours += ep.wattHours;
            startDate = startDate.addDays(1);
            if (startDate.day() == 1) {
               
                if(!(firstfullMonthFound ) &&  !(zeroProductionFound))
                {
                    firstfullMonthFound = true; 
                    accum.FirstFullMOnth = firstfullMonthFound;
                }
                
                monthlyProd.add(accum);
                accum = new EnphaseProduction();
                zeroProductionFound  = false;
            }
        }
        
        if (accum.productionDate != null) {
            monthlyProd.add(accum);
        }
        
        return monthlyProd;
        
    }
    
    ////////////// RGM STATS ///////////////////
    
    //revenue grade meter - start date must be within past year or no results
    public EnphaseRGMStatistics rgm_stats(Integer system_id, DateTime start_date, DateTime end_date) {
        
        EnphaseRGMStatistics result = new EnphaseRGMStatistics();

        if (Test.isRunningTest() && mockResponse != true) {
            return result;
        }
        
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        String url = ENPHASE_ENDPOINT + '/systems/' + system_id + '/rgm_stats' + '?key=' + apiKey;
        if (start_date != null) {
            url += '&start=' + start_date.format('yyyy-MM-dd\'T\'HH:mmZ');
        } 
        if (end_date != null) {
            url += '&end=' + end_date.format('yyyy-MM-dd\'T\'HH:mmZ');
        } 
        req.setEndpoint(url);   
        req.setHeader('Accept-Encoding','compress, gzip');
        req.setTimeout(ENPHASE_TIMEOUT);
        
        Http http = new Http();
        HttpResponse response = http.send(req);

        String responseText = response.getBody();
        debugResponse = responseText;
        
        if (response.getStatusCode() != 200) {
            throw new EnphaseException(responseText);
        }       
        
        JSONParser parser = JSON.createParser(responseText);
        return result.deserialize(parser);
    }
    
    ////////////// SYSTEM STATS ///////////////////
    
    //performance statistics - if range is over a day, one day is reported
    public EnphaseStatistics stats(Integer system_id, DateTime start_date, DateTime end_date) {
        
        EnphaseStatistics result = new EnphaseStatistics();

        if (Test.isRunningTest() && mockResponse != true) {
            return result;
        }
        
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        String url = ENPHASE_ENDPOINT + '/systems/' + system_id + '/stats' + '?key=' + apiKey;
        if (start_date != null) {
            url += '&start=' + start_date.format('yyyy-MM-dd\'T\'HH:mmZ');
        } 
        if (end_date != null) {
            url += '&end=' + end_date.format('yyyy-MM-dd\'T\'HH:mmZ');
        } 
        req.setEndpoint(url);   
        req.setHeader('Accept-Encoding','compress, gzip');
        req.setTimeout(ENPHASE_TIMEOUT);
        
        Http http = new Http();
        HttpResponse response = http.send(req);

        String responseText = response.getBody();
        debugResponse = responseText;
        
        if (response.getStatusCode() != 200) {
            throw new EnphaseException(responseText);
        }       
        
        JSONParser parser = JSON.createParser(responseText);
        return result.deserialize(parser);
    }
    
    
    ////////////// DATA OBJECTS /////////////////
        
    global class EnphaseSystem implements Comparable {
        public String city { get; set; }
        public String country { get; set; }
        public String postal_code { get; set; }
        public String state { get; set; }
        public String status { get; set; } //normal, warning, error
        public Integer system_id { get; set; }
        public String system_name { get; set; }
        public String system_public_name { get; set; }
        public String timezone { get; set; }
        public EnphaseSystem deserialize(JSONParser parser) {
            Integer nesting = 1; //start object already found
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    nesting++;
                } else if (parser.getCurrentToken() == JSONToken.END_OBJECT) {
                    nesting--;
                    if (nesting == 0) {
                        break;
                    }
                }
                if (nesting == 1) {
                    if (parser.getCurrentToken() == JSONToken.VALUE_STRING) {
                        if (parser.getCurrentName() == 'city') {
                            city = parser.getText();
                        } else if (parser.getCurrentName() == 'country') {
                            country = parser.getText();
                        } else if (parser.getCurrentName() == 'postal_code') {
                            postal_code = parser.getText();
                        } else if (parser.getCurrentName() == 'state') {
                            state = parser.getText();
                        } else if (parser.getCurrentName() == 'status') {
                            status = parser.getText();
                        } else if (parser.getCurrentName() == 'system_name') {
                            system_name = parser.getText();
                        } else if (parser.getCurrentName() == 'system_public_name') {
                            system_public_name = parser.getText();
                        }
                    } else if (parser.getCurrentToken() == JSONToken.VALUE_NUMBER_INT) {
                        if (parser.getCurrentName() == 'system_id') {
                            system_id = parser.getIntegerValue();
                        }
                    }
                }
            }
            return this;
        }
        global Integer compareTo(Object sys) {
            EnphaseSystem sys2 = (EnphaseSystem)sys;
            if (sys2 == null) {
                return 1;
            }
            if (system_name > sys2.system_name) {
                return 1;
            } else if (system_name < sys2.system_name) {
                return -1;
            }
            return 0;
        }
    }
    
    public class EnphaseSummary {
        public Integer current_power { get; set; }
        public Integer energy_lifetime { get; set; }
        public Integer energy_month { get; set; }
        public Integer energy_today { get; set; }
        public Integer energy_week { get; set; }
        public Integer modules { get; set; }
        public DateTime summary_date { get; set; }
        public Integer system_id { get; set; }
        public String source { get; set; } //meter
        public EnphaseSummary deserialize(JSONParser parser) {
            Integer nesting = 0; 
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    nesting++;
                } else if (parser.getCurrentToken() == JSONToken.END_OBJECT) {
                    nesting--;
                    if (nesting == 0) {
                        break;
                    }
                }
                if (nesting == 1) {
                    if (parser.getCurrentToken() == JSONToken.VALUE_STRING) {
                        if (parser.getCurrentName() == 'summary_date') {
                            summary_date = parser.getDatetimeValue();
                        } else if (parser.getCurrentName() == 'source') {
                            source = parser.getText();
                        } 
                    } else if (parser.getCurrentToken() == JSONToken.VALUE_NUMBER_INT) {
                        if (parser.getCurrentName() == 'current_power') {
                            current_power = parser.getIntegerValue();
                        } else if (parser.getCurrentName() == 'energy_lifetime') {
                            energy_lifetime = parser.getIntegerValue();
                        } else if (parser.getCurrentName() == 'energy_month') {
                            energy_month = parser.getIntegerValue();
                        } else if (parser.getCurrentName() == 'energy_today') {
                            energy_today = parser.getIntegerValue();
                        } else if (parser.getCurrentName() == 'energy_week') {
                            energy_week = parser.getIntegerValue();
                        } else if (parser.getCurrentName() == 'modules') {
                            modules = parser.getIntegerValue();
                        } else if (parser.getCurrentName() == 'system_id') {
                            system_id = parser.getIntegerValue();
                        }
                    }
                }
            }
            return this;
        }
    }
    
    public class EnphaseAlert {
        public String alert_name { get; set; }
        public Integer num_devices { get; set; }
        public DateTime alert_start { get; set; }
        public String level { get; set; }
        public EnphaseAlert deserialize(JSONParser parser) {
            Integer nesting = 1; //start object already found
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    nesting++;
                } else if (parser.getCurrentToken() == JSONToken.END_OBJECT) {
                    nesting--;
                    if (nesting == 0) {
                        break;
                    }
                }
                if (nesting == 1) {
                    if (parser.getCurrentToken() == JSONToken.VALUE_STRING) {
                        if (parser.getCurrentName() == 'alert_name') {
                            alert_name = parser.getText();
                        } else if (parser.getCurrentName() == 'alert_start') {
                            alert_start = parser.getDatetimeValue();
                        } else if (parser.getCurrentName() == 'level') {
                            level = parser.getText();
                        }
                    } else if (parser.getCurrentToken() == JSONToken.VALUE_NUMBER_INT) {
                        if (parser.getCurrentName() == 'num_devices') {
                            num_devices = parser.getIntegerValue();
                        } else if (parser.getCurrentName() == 'alert_start') { 
                            Long dateSerial = parser.getLongValue() * 1000;
                            alert_start = Datetime.newInstance(dateSerial);
                        }
                    }
                }
            }
            return this;
        }
    }
    
    public class EnphaseMonthlyProduction {
        public DateTime end_date { get; set; }
        public Integer production_Wh { get; set; }
        public Integer production_kWh { 
            get {
                if (production_Wh == null) { return null; }
                return Math.round(production_Wh / 1000.0);
            }
        }
        public DateTime start_date { get; set; }
        public Integer system_id { get; set; }
        public EnphaseMonthlyProduction deserialize(JSONParser parser) {
            Integer nesting = 0; 
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    nesting++;
                } else if (parser.getCurrentToken() == JSONToken.END_OBJECT) {
                    nesting--;
                    if (nesting == 0) {
                        break;
                    }
                }
                if (nesting == 1) {
                    if (parser.getCurrentToken() == JSONToken.VALUE_STRING) {
                        if (parser.getCurrentName() == 'end_date') {
                            end_date = parser.getDatetimeValue();
                        } else if (parser.getCurrentName() == 'start_date') {
                            start_date = parser.getDatetimeValue();
                        } 
                    } else if (parser.getCurrentToken() == JSONToken.VALUE_NUMBER_INT) {
                        if (parser.getCurrentName() == 'production_wh') {
                            production_wh = parser.getIntegerValue();
                        } else if (parser.getCurrentName() == 'system_id') {
                            system_id = parser.getIntegerValue();
                        }
                    }
                }
            }
            return this;
        }
    }
    
    global class EnphaseProduction implements Comparable {
        public DateTime productionDate { get; set; }
        public Integer wattHours { get; set; }
        public Decimal kilowattHours { 
            get {
                if (wattHours == null) { return null; }
                return Math.round(wattHours / 1000.0);
            }
        }
        global Integer compareTo(Object ep) { //reverse date order
            EnphaseProduction ep2 = (EnphaseProduction)ep;
            if (ep2 == null) {
                return -1;
            }
            if (productionDate == null && ep2.productionDate == null) {
                return 0;
            }
            if (productionDate == null && ep2.productionDate != null) {
                return 1;
            }
            if (ep2.productionDate == null) {
                return -1;
            }
            if (productionDate > ep2.productionDate) {
                return -1;
            } else if (productionDate < ep2.productionDate) {
                return 1;
            }
            return 0;
        }
        public Boolean firstFullMonth { get; set; }
    }
    
    public class EnphaseRGMStatistics {
        public Integer system_id { get; set; }
        public Integer total_devices { get; set; }
        public List<EnphaseRGMInterval> intervals { get; set; }
        public EnphaseRGMStatistics deserialize(JSONParser parser) {
            Integer nesting = 0;
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    nesting++;
                }
                if (parser.getCurrentToken() == JSONToken.END_OBJECT) {
                    nesting--;
                    if (nesting == 0) {
                        break;
                    }
                }
                if (nesting == 1) {
                    if (parser.getCurrentToken() == JSONToken.VALUE_NUMBER_INT) {
                        if (parser.getCurrentName() == 'system_id') {
                            system_id = parser.getIntegerValue();
                        } else if (parser.getCurrentName() == 'total_devices') {
                            total_devices = parser.getIntegerValue();
                        }
                        
                    } else if (intervals == null && parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'intervals') {
                         deserializeIntervals(parser);
                    }
                }
            }
            return this;
        }
        private void deserializeIntervals(JSONParser parser) {
            intervals = new List<EnphaseRGMInterval>();
            Integer nesting = 0;
            while(parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    nesting++;
                }
                if (parser.getCurrentToken() == JSONToken.END_ARRAY) {
                    nesting--;
                    if (nesting == 0) {
                        break;
                    }
                }
                if (parser.getCurrentToken() == JSONToken.START_OBJECT && nesting == 1) {
                    intervals.add(new EnphaseRGMInterval().deserialize(parser));
                }
            }
        }
    }
    
    public class EnphaseRGMInterval {
        public DateTime end_date { get; set; }
        public Decimal wh_del { get; set; }
        public Integer devices_reporting { get; set; }
        public EnphaseRGMInterval deserialize(JSONParser parser) {
            Integer nesting = 1; //start object already found
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    nesting++;
                } else if (parser.getCurrentToken() == JSONToken.END_OBJECT) {
                    nesting--;
                    if (nesting == 0) {
                        break;
                    }
                }
                if (nesting == 1) {
                    if (parser.getCurrentToken() == JSONToken.VALUE_STRING) {
                        if (parser.getCurrentName() == 'end_date') {
                            end_date = parser.getDatetimeValue();
                        } 
                    } else if (parser.getCurrentToken() == JSONToken.VALUE_NUMBER_INT) {
                        if (parser.getCurrentName() == 'wh_del') {
                            wh_del = parser.getDecimalValue();
                        } else if (parser.getCurrentName() == 'devices_reporting') {
                            devices_reporting = parser.getIntegerValue();
                        }
                    } else if (parser.getCurrentToken() == JSONToken.VALUE_NUMBER_FLOAT) {
                        if (parser.getCurrentName() == 'wh_del') {
                            wh_del = parser.getDecimalValue();
                        }
                    }
                }
            }
            return this;
        }
    }
    
    public class EnphaseStatistics {
        public Integer system_id { get; set; }
        public Integer total_devices { get; set; }
        public List<EnphaseInterval> intervals { get; set; }
        public EnphaseStatistics deserialize(JSONParser parser) {
            Integer nesting = 0;
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    nesting++;
                }
                if (parser.getCurrentToken() == JSONToken.END_OBJECT) {
                    nesting--;
                    if (nesting == 0) {
                        break;
                    }
                }
                if (nesting == 1) {
                    if (parser.getCurrentToken() == JSONToken.VALUE_NUMBER_INT) {
                        if (parser.getCurrentName() == 'system_id') {
                            system_id = parser.getIntegerValue();
                        } else if (parser.getCurrentName() == 'total_devices') {
                            total_devices = parser.getIntegerValue();
                        }
                        
                    } else if (intervals == null && parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName() == 'intervals') {
                         deserializeIntervals(parser);
                    }
                }
            }
            return this;
        }
        private void deserializeIntervals(JSONParser parser) {
            intervals = new List<EnphaseInterval>();
            Integer nesting = 0;
            while(parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    nesting++;
                }
                if (parser.getCurrentToken() == JSONToken.END_ARRAY) {
                    nesting--;
                    if (nesting == 0) {
                        break;
                    }
                }
                if (parser.getCurrentToken() == JSONToken.START_OBJECT && nesting == 1) {
                    intervals.add(new EnphaseInterval().deserialize(parser));
                }
            }
        }
    }
    
    public class EnphaseInterval {
        public DateTime end_date { get; set; }
        public Integer powr { get; set; }
        public Decimal enwh { get; set; }
        public Integer devices_reporting { get; set; }
        public EnphaseInterval deserialize(JSONParser parser) {
            Integer nesting = 1; //start object already found
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    nesting++;
                } else if (parser.getCurrentToken() == JSONToken.END_OBJECT) {
                    nesting--;
                    if (nesting == 0) {
                        break;
                    }
                }
                if (nesting == 1) {
                    if (parser.getCurrentToken() == JSONToken.VALUE_STRING) {
                        if (parser.getCurrentName() == 'end_date') {
                            end_date = parser.getDatetimeValue();
                        } 
                    } else if (parser.getCurrentToken() == JSONToken.VALUE_NUMBER_INT) {
                        if (parser.getCurrentName() == 'powr') {
                            powr = parser.getIntegerValue();
                        } else if (parser.getCurrentName() == 'enwh') {
                            enwh = parser.getDecimalValue();
                        } else if (parser.getCurrentName() == 'devices_reporting') {
                            devices_reporting = parser.getIntegerValue();
                        }
                    } else if (parser.getCurrentToken() == JSONToken.VALUE_NUMBER_FLOAT) {
                        if (parser.getCurrentName() == 'enwh') {
                            enwh = parser.getDecimalValue();
                        }
                    }
                }
            }
            return this;
        }
    }
    
    public class EnphaseException extends Exception {   }
}