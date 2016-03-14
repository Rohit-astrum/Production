/* FILE: InstalledSystemsChartsTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: July 30, 2012
 * PURPOSE: Test class for InstalledSystemsCharts component and InstalledSystemsChartsController
 * MODIFICATION HISTORY:
 * 08/23/2012 TCM - fix test due to changing BingMaps trigger to not perform callouts under test
 */
 
@isTest
private class InstalledSystemsChartsTest {

    static testMethod void twoYearsProdData_getGuarVsActual() {

		Installed_System__c installedSystem = createInstalledSystem();
		
        addAnnualProduction (installedSystem.Id, System.today().year());
        addAnnualProduction (installedSystem.Id, System.today().year() - 1);
        
        InstalledSystemsChartsController controller = new InstalledSystemsChartsController();
        
        Test.startTest();
        
        List<InstalledSystemsChartsController.GuaranteeData> guarVsActual = controller.getguarVsActual();
        
        Test.stopTest();
        
        Date workDate = System.today().toStartOfMonth().addYears(-1);
        InstalledSystemsChartsController.GuaranteeData dat;
        for (Integer i = 0; i < 12; i++) {
        	dat = guarVsActual[i];
        	System.assertEquals(workDate.month(), dat.guarantee);
        	System.assertEquals(workDate.month() / 2.0, dat.actual);
        	workDate = workDate.addMonths(1);
        }
        
        //srecs are accumulated
        System.assertEquals(13 * 6 * 2, guarVsActual[11].projSREC);
		System.assertEquals(13 * 6 * 3, guarVsActual[11].genSREC);
        
    }
    
    static testMethod void twoYearsPAProdData_getStateProd() {

		Installed_System__c installedSystem = createInstalledSystem();
		
        addAnnualProduction (installedSystem.Id, System.today().year());
        addAnnualProduction (installedSystem.Id, System.today().year() - 1);
        
        InstalledSystemsChartsController controller = new InstalledSystemsChartsController();
        
        Test.startTest();
        
        List<InstalledSystemsChartsController.StateProduction> stateProd = controller.getStateProd();
        
        Test.stopTest();
        
        //srecs are accumulated
        System.assertEquals('PA', stateProd[0].state);
        System.assertEquals(13 * 6, stateProd[0].guarantee);
		System.assertEquals(13 * 6 * 0.5, stateProd[0].actual);
        
    }
    
    static testMethod void threeSystems_getSystemOverview() {

		Installed_System__c installedSystem1 = createInstalledSystem(); //under
		Installed_System__c installedSystem2 = createInstalledSystem(); //over
		Installed_System__c installedSystem3 = createInstalledSystem(); //on target
		
		Annual_Production__c ap;
		//under (default)
        addAnnualProduction (installedSystem1.Id, System.today().year());
        addAnnualProduction (installedSystem1.Id, System.today().year() - 1);
        
        //over
        addAnnualProduction (installedSystem2.Id, System.today().year());
        ap = addAnnualProduction (installedSystem2.Id, System.today().year() - 1);
        ap.December_Actual_Production_kWh__c = 5000;
        update ap;
		
		//on target
        addAnnualProduction (installedSystem3.Id, System.today().year());
        ap = addAnnualProduction (installedSystem3.Id, System.today().year() - 1);
        ap.December_Actual_Production_kWh__c += 13 * 6 * 0.5;
        update ap;
        
        InstalledSystemsChartsController controller = new InstalledSystemsChartsController();
        
        Test.startTest();
        
        InstalledSystemsChartsController.SystemOverview overview = controller.getSystemOverview();
        
        Test.stopTest();
        
        System.assertEquals(1, overview.overProducing);
        System.assertEquals(1, overview.underProducing);
        System.assertEquals(1, overview.onTarget);
        
    }
    
    public static Installed_System__c createInstalledSystem () {
    	
        Account acct = new Account(
            Name = 'Test Account'
        );
        insert acct;
        
		Property__c property = new Property__c(
			Property_Owner__c = acct.Id,
			Name = '123 Oak St',
			Property_City__c = 'Test City',
			Property_State__c = 'PA',
			Property_Zip__c = '19403',
			Property_County__c = 'Test County'
		);
		insert property;
        
        Installed_System__c installedSystem = new Installed_System__c (
            Account__c = acct.Id,
            Property__c = property.Id,
            Generation_Start_Date__c = Date.newInstance(2010, 1, 1)
        );
        insert installedSystem;
        
        return installedSystem;    	
    }
    
    public static Annual_Production__c addAnnualProduction (Id installedSystemId, Integer year) {
    	Annual_Production__c prod = new Annual_Production__c (
    		Installed_System__c = installedSystemId,
    		Year__c = year,
			January_Production_Guarantee_kWh__c = 1,
			February_Production_Guarantee_kWh__c = 2,
			March_Production_Guarantee_kWh__c = 3,
			April_Production_Guarantee_kWh__c = 4, 
			May_Production_Guarantee_kWh__c = 5,
			June_Production_Guarantee_kWh__c = 6,
			July_Production_Guarantee_kWh__c = 7, 
			August_Production_Guarantee_kWh__c = 8, 
            September_Production_Guarantee_kWh__c = 9,
            October_Production_Guarantee_kWh__c = 10, 
            November_Production_Guarantee_kWh__c = 11, 
            December_Production_Guarantee_kWh__c = 12, 
            January_Actual_Production_kWh__c = 0.5, 
            February_Actual_Production_kWh__c = 1, 
            March_Actual_Production_kWh__c = 1.5, 
            April_Actual_Production_kWh__c = 2, 
            May_Actual_Production_kWh__c = 2.5, 
            June_Actual_Production_kWh__c = 3, 
            July_Actual_Production_kWh__c = 3.5,
            August_Actual_Production_kWh__c = 4,
            September_Actual_Production_kWh__c = 4.5, 
            October_Actual_Production_kWh__c = 5, 
            November_Actual_Production_kWh__c = 5.5, 
            December_Actual_Production_kWh__c = 6,
            January_Projected_SRECs__c = 2, 
			February_Projected_SRECs__c = 4, 
			March_Projected_SRECs__c = 6, 
			April_Projected_SRECs__c = 8, 
			May_Projected_SRECs__c = 10, 
			June_Projected_SRECs__c = 12, 
			July_Projected_SRECs__c = 14, 
			August_Projected_SRECs__c = 16, 
			September_Projected_SRECs__c = 18, 
			October_Projected_SRECs__c = 20, 
			November_Projected_SRECs__c = 22, 
			December_Projected_SRECs__c = 24,
			January_SRECs_Generated__c = 3, 
			February_SRECs_Generated__c = 6, 
			March_SRECs_Generated__c = 9, 
			April_SRECs_Generated__c = 12, 
			May_SRECs_Generated__c = 15, 
			June_SRECs_Generated__c = 18, 
			July_SRECs_Generated__c = 21, 
			August_SRECs_Generated__c = 24, 
			September_SRECs_Generated__c = 27, 
			October_SRECs_Generated__c = 30, 
			November_SRECs_Generated__c = 33, 
			December_SRECs_Generated__c = 36 
		);
		insert prod;
		
		return prod;
    } 
    
}