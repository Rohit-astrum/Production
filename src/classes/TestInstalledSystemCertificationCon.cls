@isTest
private class TestInstalledSystemCertificationCon 
{

    static testMethod void TestInstalledSystemCertificationCon() 
    {
        InstalledSystemCertificationController objInstSystem = new InstalledSystemCertificationController();
        
        Account acc = new Account(
            Name = 'Test'
        );
        insert acc;
        
        Installed_System__c installedSysObj = new Installed_System__c(
            Account__c = acc.id,
            Generation_Start_Date__c = System.today(),
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
            Year__c = 2012,
            
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
            December_Production_Guarantee_kWh__c = 5
        );
        
        insert annProd;        
           
        objInstSystem.queryType = 'outer';
        objInstSystem.sortExpression = 'Account__c';
        objInstSystem.getSystemList();
        objInstSystem.getSysGrntURL();
        
        objInstSystem.getSRECChartURL();
        objInstSystem.getSortDirection();
        objInstSystem.viewData();
        //objInstSystem.getPiecChartURL();
        
        InstalledSystemController.InstallWrapper wrapObj = new InstalledSystemController.InstallWrapper(installedSysObj);
        wrapObj.getFieldValue('Annual_Production_Guarantee_To_Date_kWh__c');
        
        List<InstalledSystemController.InstallWrapper> unSortedList = new List<InstalledSystemController.InstallWrapper>();
        unSortedList.add(new InstalledSystemController.InstallWrapper(installedSysObj));
        
        //objInstSystem.customSort(unSortedList, 'Annual_Production_Guarantee_To_Date_kWh__c', 'ASC');
        
        objInstSystem.getStateChartURL();        
    }
}