/* FILE: PVWattsMonthlyBatchTest.cls
 * AUTHOR: Rohit Jain
 * DATE: May 15, 2013
 * PURPOSE: Test class for PVWattsMonthlyBatch
 * MODIFICATION HISTORY 
 */ 

@isTest
public class PVWattsMonthlyBatchTest{

    static testMethod void installSystem_getPVWatts_Added() {
        
        //Savepoint sp = Database.setSavepoint();

        Account customer = new Account(Name = 'Test Customer');
        insert customer;
        
        Property__c property = CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');
        property.Latitude__c = 40.12;
        property.Longitude__c = -75.40;
        property.Optimal_Site_Quality_kWh_y_kW__c = 1100;
        update property;
        
        System_Design__c sd = new System_Design__c (
            Property__c = property.Id
            ,Trench_Length__c = 0
        );
        insert sd;
        
        System_Design_Quote__c sdq = new System_Design_Quote__c(
            System_Design__c = sd.Id
        );
        insert sdq;
        
        SCRB_SalesOrder__c so = new SCRB_SalesOrder__c(
            Name = 'ABC123',
            Property__c = property.Id,
            System_Size_kW__c = 5
        );
        insert so;
        
        Installed_System__c sys = new Installed_System__c (
            Account__c = customer.Id,
            Property__c = property.Id,
            Quoted_System_Design__c = sdq.Id,
            Sales_Order__c = so.Id
        );
        insert sys;
        
        sys = [SELECT Id, Quoted_System_Design__r.System_Design__r.Overall_TSRF__c,
                Property__r.QAS_Latitude__c, Property__r.QAS_Longitude__c, Property__r.Latitude__c,
                Property__r.Longitude__c
            FROM Installed_System__c];
            
        //Database.rollback(sp);
        
        Test.setMock(WebServiceMock.class, new PVWattsMock());
        
        Test.startTest();
        
        PVWattsMonthlyBatch batch = new PVWattsMonthlyBatch();
        batch.execute(null, new List<Installed_System__c> { sys });
        
        Test.stopTest();
        
        Installed_System__c pvw = 
            [SELECT Id, Monthly_Production_Factor_Jan__c, 
                    Monthly_Production_Factor_Feb__c, Monthly_Production_Factor_Mar__c, 
                    Monthly_Production_Factor_Apr__c, Monthly_Production_Factor_May__c,
                    Monthly_Production_Factor_Jun__c, Monthly_Production_Factor_Jul__c, 
                    Monthly_Production_Factor_Aug__c, Monthly_Production_Factor_Sep__c, 
                    Monthly_Production_Factor_Oct__c, Monthly_Production_Factor_Nov__c, 
                    Monthly_Production_Factor_Dec__c
            FROM Installed_System__c Where Id = :sys.Id];

        
        System.debug('* pvw - '+pvw );
        /*System.assertEquals(100, pvw.PVWatts_January_Estimate_kWh__c);
        System.assertEquals(200, pvw.PVWatts_February_Estimate_kWh__c);
        System.assertEquals(300, pvw.PVWatts_March_Estimate_kWh__c); 
        System.assertEquals(400, pvw.PVWatts_April_Estimate_kWh__c);
        System.assertEquals(500, pvw.PVWatts_May_Estimate_kWh__c);
        System.assertEquals(600, pvw.PVWatts_June_Estimate_kWh__c);
        System.assertEquals(700, pvw.PVWatts_July_Estimate_kWh__c); 
        System.assertEquals(800, pvw.PVWatts_August_Estimate_kWh__c); 
        System.assertEquals(900, pvw.PVWatts_September_Estimate_kWh__c); 
        System.assertEquals(1000, pvw.PVWatts_October_Estimate_kWh__c); 
        System.assertEquals(1100, pvw.PVWatts_November_Estimate_kWh__c); 
        System.assertEquals(1200, pvw.PVWatts_December_Estimate_kWh__c);   */     
        
    }
    
}