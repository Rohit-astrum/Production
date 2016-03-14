/* FILE: AAA_EnphaseAPITest.cls
 * AUTHOR: Tino Mattheou
 * DATE: October 23, 2012
 * PURPOSE: Test class for EnphaseAPI class
 * MODIFICATION HISTORY:
 * RJ: 2/8/13: Added AAA prefix to get around WebServiceMock bug. Test Test 
 */

@isTest
public class AAA_EnphaseAPITest {

    static testMethod void index_call_getSystems() {

        Test.setMock(HttpCalloutMock.class, new EnphaseMock());
        
        EnphaseAPI api = new EnphaseAPI();
        api.mockResponse = true;
        List<EnphaseAPI.EnphaseSystem> systems = api.index();
        
        System.assertEquals(3, systems.size());
        
        System.assertEquals(66, systems[0].system_id);
        System.assertEquals('Smith Residence', systems[0].system_name);
        System.assertEquals('Residential System', systems[0].system_public_name);
        
        System.assertEquals(77, systems[1].system_id);
        System.assertEquals(1811, systems[2].system_id);
        
    }  

    static testMethod void summary_call_getSummary() {

        Test.setMock(HttpCalloutMock.class, new EnphaseMock());
        
        EnphaseAPI api = new EnphaseAPI();
        api.mockResponse = true;
        EnphaseAPI.EnphaseSummary summary = api.summary(67, null);
        
        System.assertEquals(2200, summary.current_power);
        System.assertEquals(4011891, summary.energy_lifetime);
        System.assertEquals(67222, summary.energy_month);
        System.assertEquals(13723, summary.energy_today);
        System.assertEquals(50422, summary.energy_week);
        System.assertEquals(41, summary.modules);
        System.assertEquals('microinverters', summary.source);
        System.assertEquals(Datetime.newInstanceGmt(2011,1,12,8,0,0), summary.summary_date);
        System.assertEquals(67, summary.system_id);
        
    }  

    static testMethod void alerts_call_getAlerts() {

        Test.setMock(HttpCalloutMock.class, new EnphaseMock());
        
        EnphaseAPI api = new EnphaseAPI();
        api.mockResponse = true;
        List<EnphaseAPI.EnphaseAlert> alerts = api.alerts(1765, 'low');
        
        System.assertEquals(1, alerts.size());
        System.assertEquals('Module failed to report', alerts[0].alert_name);
        System.assertEquals(3, alerts[0].num_devices);
        System.assertEquals(DateTime.newInstance(1348253552000L), alerts[0].alert_start);
        System.assertEquals('medium', alerts[0].level);
        
    }  

    static testMethod void monthly_production_call_getSystems() {

        Test.setMock(HttpCalloutMock.class, new EnphaseMock());
        
        EnphaseAPI api = new EnphaseAPI();
        api.mockResponse = true;
        EnphaseAPI.EnphaseMonthlyProduction prod = api.monthly_production(1765, Date.today().toStartOfMonth().addMonths(-1));
        
        System.assertEquals(208435, prod.production_wh);
        System.assertEquals(DateTime.newInstanceGmt(2011,7,1,7,0,0), prod.start_date);
        System.assertEquals(DateTime.newInstanceGmt(2011,8,1,7,0,0), prod.end_date);
        
    }  
    
    static testMethod void power_today_call_getPower() {

        Test.setMock(HttpCalloutMock.class, new EnphaseMock());
        
        EnphaseAPI api = new EnphaseAPI();
        api.mockResponse = true;
        List<EnphaseAPI.EnphaseProduction> prod = api.power_today(561);
        
        System.assertEquals(13, prod.size());
        
        System.assertEquals(0, prod[0].wattHours);
        System.assertEquals(0, prod[3].wattHours);
        System.assertEquals(32, prod[4].wattHours);
        System.assertEquals(246, prod[5].wattHours);
        System.assertEquals(379, prod[6].wattHours);
        System.assertEquals(184, prod[7].wattHours);
        System.assertEquals(41, prod[8].wattHours);
        System.assertEquals(0, prod[9].wattHours);
        System.assertEquals(0, prod[12].wattHours);

        System.assertEquals(DateTime.newInstanceGmt(2011,9,10,7,0,0), prod[0].productionDate);
        System.assertEquals(DateTime.newInstanceGmt(2011,9,10,8,0,0), prod[12].productionDate);
        
    }  
    
    static testMethod void energyLifetime_call_getPower() {

        Test.setMock(HttpCalloutMock.class, new EnphaseMock());
        
        EnphaseAPI api = new EnphaseAPI();
        api.mockResponse = true;
        List <EnphaseAPI.EnphaseProduction> energy = api.energy_lifetime(561);
        
        System.assertEquals(6, energy.size());
        
        System.assertEquals(613, energy[0].wattHours);
        System.assertEquals(659, energy[1].wattHours);
        System.assertEquals(661, energy[2].wattHours);
        System.assertEquals(675, energy[3].wattHours);
        System.assertEquals(674, energy[4].wattHours);
        System.assertEquals(679, energy[5].wattHours);

        DateTime prodDate = DateTime.newInstanceGmt(2011,9,3,7,5,0);
        
        for (EnphaseAPI.EnphaseProduction e : energy) {
            System.assertEquals(prodDate, e.productionDate);
            prodDate = prodDate.addDays(1);
        }
        
    }  
    
    static testMethod void energyLifetimeMonthly_call_getPower() {

        Test.setMock(HttpCalloutMock.class, new EnphaseMock());
        
        EnphaseAPI api = new EnphaseAPI();
        api.mockResponse = true;
        List <EnphaseAPI.EnphaseProduction> energy = api.energy_lifetime_monthly(561);
        
        System.assertEquals(1, energy.size());
        
        Integer monthlyProduction = 613 + 659 + 661 + 675 + 674 + 679;
         
        System.assertEquals(monthlyProduction, energy[0].wattHours);
        System.assertEquals( ( monthlyProduction + 500 ) / 1000, energy[0].kilowattHours);

        System.assertEquals(DateTime.newInstanceGmt(2011,9,3,7,5,0), energy[0].productionDate);
        
    }  
    
    static testMethod void rgmStats_call_getStats() {

        Test.setMock(HttpCalloutMock.class, new EnphaseMock());
        
        EnphaseAPI api = new EnphaseAPI();
        api.mockResponse = true;
        EnphaseAPI.EnphaseRGMStatistics stats = api.rgm_stats(1765, DateTime.now().addDays(-30), DateTime.now());
        
        System.assertEquals(1765, stats.system_id);
        System.assertEquals(1, stats.total_devices);
        System.assertEquals(8, stats.intervals.size());
        
        System.assertEquals(0, stats.intervals[0].devices_reporting);
        System.assertEquals(0, stats.intervals[1].devices_reporting);
        System.assertEquals(0, stats.intervals[2].devices_reporting);
        System.assertEquals(0, stats.intervals[3].devices_reporting);
        System.assertEquals(1, stats.intervals[4].devices_reporting);
        System.assertEquals(1, stats.intervals[5].devices_reporting);
        System.assertEquals(1, stats.intervals[6].devices_reporting);
        System.assertEquals(0, stats.intervals[7].devices_reporting);

        System.assertEquals(0, stats.intervals[0].wh_del);
        System.assertEquals(0, stats.intervals[1].wh_del);
        System.assertEquals(0, stats.intervals[2].wh_del);
        System.assertEquals(0, stats.intervals[3].wh_del);
        System.assertEquals(2.6, stats.intervals[4].wh_del);
        System.assertEquals(21.2, stats.intervals[5].wh_del);
        System.assertEquals(37.7, stats.intervals[6].wh_del);
        System.assertEquals(0, stats.intervals[7].wh_del);
        
        System.assertEquals(DateTime.newInstanceGmt(2010,9,10,7,15,0), stats.intervals[0].end_date);
        System.assertEquals(DateTime.newInstanceGmt(2010,9,10,7,30,0), stats.intervals[1].end_date);
        System.assertEquals(DateTime.newInstanceGmt(2010,9,10,7,45,0), stats.intervals[2].end_date);
        System.assertEquals(DateTime.newInstanceGmt(2010,9,10,13,0,0), stats.intervals[3].end_date);
        System.assertEquals(DateTime.newInstanceGmt(2010,9,10,13,15,0), stats.intervals[4].end_date);
        System.assertEquals(DateTime.newInstanceGmt(2010,9,10,13,30,0), stats.intervals[5].end_date);
        System.assertEquals(DateTime.newInstanceGmt(2010,9,10,13,45,0), stats.intervals[6].end_date);
        System.assertEquals(DateTime.newInstanceGmt(2010,9,11,7,0,0), stats.intervals[7].end_date);
        
    }
      
}