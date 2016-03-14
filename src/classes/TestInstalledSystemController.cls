//07/09/2012 TCM - comment out due to Heap Limit issue
//07/11/2012 TCM - add code coverage for controller
@isTest
private class TestInstalledSystemController {
    
    private static testmethod void unitTest() {
    	
        Account acc = new Account(
            Name = 'Test'
        );
        insert acc;
        
        Installed_System__c installedSysObj = new Installed_System__c(
            Account__c = acc.id,
            Generation_Start_Date__c = Date.newInstance(2010,10,1),
            January_Daily_Peak_Sun_Hours__c = 5,
            February_Daily_Peak_Sun_Hours__c = 5,
            March_Daily_Peak_Sun_Hours__c = 5,
            April_Daily_Peak_Sun_Hours__c = 5,
            May_Daily_Peak_Sun_Hours__c = 5,
            June_Daily_Peak_Sun_Hours__c = 5,
            July_Daily_Peak_Sun_Hours__c = 5,
            August_Daily_Peak_Sun_Hours__c = 5,
            September_Daily_Peak_Sun_Hours__c = 5,
            October_Daily_Peak_Sun_Hours__c = 5,
            November_Daily_Peak_Sun_Hours__c = 5,
            December_Daily_Peak_Sun_Hours__c = 5
        );
        insert installedSysObj;

        Annual_Production__c annProd = new Annual_Production__c(
            Installed_System__c = installedSysObj.id,
            Year__c = 2010,

            October_Actual_Production_kWh__c = 5,
            November_Actual_Production_kWh__c = 5,
            December_Actual_Production_kWh__c = 5,
            
            October_Production_Guarantee_kWh__c = 5,
            November_Production_Guarantee_kWh__c = 5,
            December_Production_Guarantee_kWh__c = 5,
            
			October_Projected_SRECs__c = 1, 
			November_Projected_SRECs__c = 1, 
			December_Projected_SRECs__c = 1,
			
			October_SRECs_Generated__c = 1, 
			November_SRECs_Generated__c = 1, 
			December_SRECs_Generated__c = 1         
		);
        insert annProd;
        
        annProd = new Annual_Production__c (
            Installed_System__c = installedSysObj.id,
            Year__c = 2011,

            January_Actual_Production_kWh__c = 5,
            February_Actual_Production_kWh__c = 5,
            March_Actual_Production_kWh__c = 5,
            April_Actual_Production_kWh__c = 5,
            May_Actual_Production_kWh__c = 5,
            June_Actual_Production_kWh__c = 5,
            July_Actual_Production_kWh__c = 5,
            August_Actual_Production_kWh__c = 5,
            September_Actual_Production_kWh__c = 5,
            October_Actual_Production_kWh__c = 5,
            November_Actual_Production_kWh__c = 5,
            December_Actual_Production_kWh__c = 5,
            
            January_Production_Guarantee_kWh__c = 5,
            February_Production_Guarantee_kWh__c = 5,
            March_Production_Guarantee_kWh__c = 5,
            April_Production_Guarantee_kWh__c = 5,
            May_Production_Guarantee_kWh__c = 5,
            June_Production_Guarantee_kWh__c = 5,
            July_Production_Guarantee_kWh__c = 5,
            August_Production_Guarantee_kWh__c = 5,
            September_Production_Guarantee_kWh__c = 5,
            October_Production_Guarantee_kWh__c = 5,
            November_Production_Guarantee_kWh__c = 5,
            December_Production_Guarantee_kWh__c = 5,

			January_Projected_SRECs__c = 1, 
			February_Projected_SRECs__c = 1, 
			March_Projected_SRECs__c = 1, 
			April_Projected_SRECs__c = 1, 
			May_Projected_SRECs__c = 1, 
            June_Projected_SRECs__c = 1, 
            July_Projected_SRECs__c = 1, 
            August_Projected_SRECs__c = 1, 
			September_Projected_SRECs__c = 1, 
			October_Projected_SRECs__c = 1, 
			November_Projected_SRECs__c = 1, 
			December_Projected_SRECs__c = 1,
			
			January_SRECs_Generated__c = 1, 
			February_SRECs_Generated__c = 1, 
			March_SRECs_Generated__c = 1, 
			April_SRECs_Generated__c = 1, 
			May_SRECs_Generated__c = 1, 
			June_SRECs_Generated__c = 1, 
			July_SRECs_Generated__c = 1, 
			August_SRECs_Generated__c = 1, 
			September_SRECs_Generated__c = 1, 
			October_SRECs_Generated__c = 1, 
			November_SRECs_Generated__c = 1, 
			December_SRECs_Generated__c = 1         
        );
        insert annProd;

        annProd = new Annual_Production__c (
            Installed_System__c = installedSysObj.id,
            Year__c = System.today().year(),

            January_Actual_Production_kWh__c = 5,
            February_Actual_Production_kWh__c = 5,
            March_Actual_Production_kWh__c = 5,
            April_Actual_Production_kWh__c = 5,
            May_Actual_Production_kWh__c = 5,
            June_Actual_Production_kWh__c = 5,
            July_Actual_Production_kWh__c = 5,
            August_Actual_Production_kWh__c = 5,
            September_Actual_Production_kWh__c = 5,
            October_Actual_Production_kWh__c = 5,
            November_Actual_Production_kWh__c = 5,
            December_Actual_Production_kWh__c = 5,
            
            January_Production_Guarantee_kWh__c = 5,
            February_Production_Guarantee_kWh__c = 5,
            March_Production_Guarantee_kWh__c = 5,
            April_Production_Guarantee_kWh__c = 5,
            May_Production_Guarantee_kWh__c = 5,
            June_Production_Guarantee_kWh__c = 5,
            July_Production_Guarantee_kWh__c = 5,
            August_Production_Guarantee_kWh__c = 5,
            September_Production_Guarantee_kWh__c = 5,
            October_Production_Guarantee_kWh__c = 5,
            November_Production_Guarantee_kWh__c = 5,
            December_Production_Guarantee_kWh__c = 5,

			January_Projected_SRECs__c = 1, 
			February_Projected_SRECs__c = 1, 
			March_Projected_SRECs__c = 1, 
			April_Projected_SRECs__c = 1, 
			May_Projected_SRECs__c = 1, 
            June_Projected_SRECs__c = 1, 
            July_Projected_SRECs__c = 1, 
            August_Projected_SRECs__c = 1, 
			September_Projected_SRECs__c = 1, 
			October_Projected_SRECs__c = 1, 
			November_Projected_SRECs__c = 1, 
			December_Projected_SRECs__c = 1,
			
			January_SRECs_Generated__c = 1, 
			February_SRECs_Generated__c = 1, 
			March_SRECs_Generated__c = 1, 
			April_SRECs_Generated__c = 1, 
			May_SRECs_Generated__c = 1, 
			June_SRECs_Generated__c = 1, 
			July_SRECs_Generated__c = 1, 
			August_SRECs_Generated__c = 1, 
			September_SRECs_Generated__c = 1, 
			October_SRECs_Generated__c = 1, 
			November_SRECs_Generated__c = 1, 
			December_SRECs_Generated__c = 1         
        );
        insert annProd;
        
        InstalledSystemController controller = new InstalledSystemController();
        controller.queryType = 'outer';
        controller.sortExpression = 'Account__c';
        controller.getSystemList();
        //controller.getSysGrntURL();
        
        System.assertEquals(1, controller.setCon.getResultSize());
        
        System.assertEquals(1, controller.totalPages);
        System.assertEquals(1, controller.pageList.size());
        System.assertEquals(1, controller.pageList[0]);
        
        //controller.getSRECChartURL();
        controller.getSortDirection();
        controller.viewData();
        //controller.getPiecChartURL();

		System.assertEquals('ASC', controller.getSortDirection());
        controller.sortExpression = 'Account__c';
		System.assertEquals('DESC', controller.getSortDirection());

        controller.changePage();
        
        InstalledSystemController.InstallWrapper wrapObj = new InstalledSystemController.InstallWrapper(installedSysObj);
		wrapObj.getFieldValue('Annual_Production_Guarantee_To_Date_kWh__c');
		wrapObj.getFieldValue('Annual_Production_Guarantee__c');
		wrapObj.getFieldValue('Annual_Production_To_Date_kWh__c');
		wrapObj.getFieldValue('Annual_Guarantee_vs_Actual_Prod_To_Date__c');
		wrapObj.getFieldValue('Expected_SRECs_To_Date__c');
		wrapObj.getFieldValue('Annual_SRECs_To_Date__c');
		wrapObj.getFieldValue('Projected_vs_Actual_SRECs_To_Date__c');
        
        //List<InstalledSystemController.InstallWrapper> unSortedList = new List<InstalledSystemController.InstallWrapper>();
        //unSortedList.add(new InstalledSystemController.InstallWrapper(installedSysObj));
        //objInstSystem.customSort(unSortedList, 'Annual_Production_Guarantee_To_Date_kWh__c', 'ASC');
        //objInstSystem.getStateChartURL();
    }
    
    
}