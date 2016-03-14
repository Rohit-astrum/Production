/* FILE: EnphaseMock.cls
 * AUTHOR: Tino Mattheou
 * DATE: October 23, 2012
 * PURPOSE: Mock HTTP responses for EnphaseAPI
 * MODIFICATION HISTORY:
 *
 */

@isTest
global class EnphaseMock implements HttpCalloutMock {
	
	//whether to return an error
	global Boolean forceError = false;

	global HttpResponse respond(HttpRequest req) {
		
		String endpoint = req.getEndpoint();
		
		if (endpoint.contains('/systems?')) {
			return indexResponse();
		} else if (endpoint.contains('/summary?')) {
			return summaryResponse();
		} else if (endpoint.contains('/alerts?')) {
			return alertsResponse();
		} else if (endpoint.contains('/monthly_production?')) {
			return monthlyProductionResponse();
		} else if (endpoint.contains('/power_today?')) {
			return powerTodayResponse();
		} else if (endpoint.contains('/energy_lifetime?')) {
			return energyLifetimeResponse();
		} else if (endpoint.contains('/rgm_stats?')) {
			return rgmStatsResponse();
		} else if (endpoint.contains('/stats?')) {
			return statsResponse();
		}
	
		return unknownResponse();
		
	}
	
	private HttpResponse indexResponse() {
		HttpResponse resp = new HttpResponse();
		resp.setHeader('Content-Type', 'application/json');
        resp.setBody('{ "systems": ['
			+ '{ "city": "Petaluma", "country": "US", "postal_code": "94954", "state": "CA", "status": "normal", "system_id": 66, "system_name": "Smith Residence", "system_public_name": "Residential System", "timezone": "America/Los_Angeles" },'
			+ '{ "city": "Atherton", "country": "US", "postal_code": "94954", "state": "CA", "status": "error", "system_id": 77, "system_name": "Jones Residence", "system_public_name": "Jones Residence", "timezone": "America/Los_Angeles" },'			
			+ '{ "city": "Oakland", "country": "US", "postal_code": "94602", "state": "CA", "status": "expired", "system_id": 1811, "system_name": "Thompson System", "system_public_name": "Commercial System", "timezone": "America/Los_Angeles" }'
  			+ '] }');
		resp.setStatusCode(200);
		return resp;
	}

	private HttpResponse summaryResponse() {
		HttpResponse resp = new HttpResponse();
		resp.setHeader('Content-Type', 'application/json');
        resp.setBody('{ "current_power": 2200, "energy_lifetime": 4011891, "energy_month": 67222, "energy_today": 13723, "energy_week": 50422, "modules": 41, "source": "microinverters", "summary_date": "2011-01-12T00:00:00-08:00", "system_id": 67 }');
		resp.setStatusCode(200);
		return resp;
	}

	private HttpResponse alertsResponse() {
		HttpResponse resp = new HttpResponse();
		resp.setHeader('Content-Type', 'application/json');
        resp.setBody('{ "system_id":1765, "alerts":[ {"alert_name":"Module failed to report", "num_devices":3, "alert_start":1348253552, "level":"medium" } ] }');
        resp.setStatusCode(200);
		return resp;
	}

	private HttpResponse monthlyProductionResponse() {
		HttpResponse resp = new HttpResponse();
		resp.setHeader('Content-Type', 'application/json');
        resp.setBody('{ "end_date": "2011-08-01T00:00:00-07:00", "production_wh": 208435, "start_date": "2011-07-01T00:00:00-07:00", "system_id": 66 }');
        resp.setStatusCode(200);
		return resp;
	}

	private HttpResponse powerTodayResponse() {
		HttpResponse resp = new HttpResponse();
		resp.setHeader('Content-Type', 'application/json');
        resp.setBody('{ "first_interval_end_date":"2011-09-10T00:05-07:00", "interval_length":300, "production": [0,0,0,0,32,246,379,184,41,0,0,0,0] }');
        resp.setStatusCode(200);
		return resp;
	}

	private HttpResponse energyLifetimeResponse() {
		HttpResponse resp = new HttpResponse();
		resp.setHeader('Content-Type', 'application/json');
        resp.setBody('{ "start_date":"2011-09-03T00:05-07:00", "production": [613,659,661,675,674,679] }');
        resp.setStatusCode(200);
		return resp;
	}

	private HttpResponse rgmStatsResponse() {
		HttpResponse resp = new HttpResponse();
		resp.setHeader('Content-Type', 'application/json');
        resp.setBody('{"system_id":1765, "total_devices":1, "intervals":[{"end_date":"2010-09-10T00:15-07:00", "wh_del":0, "devices_reporting":0},{"end_date":"2010-09-10T00:30-07:00", "wh_del":0, "devices_reporting":0},{"end_date":"2010-09-10T00:45-07:00", "wh_del":0, "devices_reporting":0},'
			+ '{"end_date":"2010-09-10T06:00-07:00", "wh_del":0, "devices_reporting":0}, {"end_date":"2010-09-10T06:15-07:00", "wh_del":2.6, "devices_reporting":1}, {"end_date":"2010-09-10T06:30-07:00", "wh_del":21.2, "devices_reporting":1}, {"end_date":"2010-09-10T06:45-07:00", "wh_del":37.7, "devices_reporting":1}, {"end_date":"2010-09-11T00:00-07:00", "wh_del":0, "devices_reporting":0}] }');
        resp.setStatusCode(200);
		return resp;
	}

	private HttpResponse statsResponse() {
		HttpResponse resp = new HttpResponse();
		resp.setHeader('Content-Type', 'application/json');
        resp.setBody('{"system_id":1765, "total_devices":12, "intervals":[{"end_date":"2009-09-10T00:05-07:00", "powr":0, "enwh":0, "devices_reporting":0},{"end_date":"2009-09-10T00:10-07:00", "powr":0, "enwh":0, "devices_reporting":0},{"end_date":"2009-09-10T00:15-07:00", "powr":0, "enwh":0, "devices_reporting":0},{"end_date":"2009-09-10T01:20-07:00", "powr":0, "enwh":0, "devices_reporting":0},'
			+ '{"end_date":"2009-09-10T06:00-07:00", "powr":0, "enwh":0, "devices_reporting":0},{"end_date":"2009-09-10T06:05-7:00", "powr":32, "enwh":2.6, "devices_reporting":12},{"end_date":"2009-09-10T06:10-7:00", "powr":256, "enwh":21.2, "devices_reporting":12},{"end_date":"2009-09-10T06:15-7:00", "powr":453, "enwh":37.7, "devices_reporting":12},{"end_date":"2009-09-10T06:20-7:00", "powr":658, "enwh":55.2, "devices_reporting":12},'
			+ '{"end_date":"2009-09-10T06:25-07:00", "powr":847, "enwh":70.7, "devices_reporting":12},{"end_date":"2009-09-10T23:45-07:00", "powr":0, "enwh":0, "devices_reporting":"0"}] }');
        resp.setStatusCode(200);
		return resp;
	}
	
	private HttpResponse unknownResponse() {
		HttpResponse resp = new HttpResponse();
		resp.setStatusCode(404);
		return resp;
	}

}