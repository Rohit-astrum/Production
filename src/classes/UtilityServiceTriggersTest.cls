/* FILE: UtilityServiceTriggersTest.cls
 * AUTHOR: Dan Kelner
 * DATE: 10/31/14
 * PURPOSE: Common trigger test class for Utility Service
 * MODIFICATION HISTORY: 
 *      08/05/15  DK  Added rateCode_Test() for CPQ-224. Made invalidateSystemDesigns_Test() seeAllData = false.
 */
@isTest
public class UtilityServiceTriggersTest {
    
    @isTest(seeAllData = false) static void invalidateSystemDesigns_Test(){
        TestData.setupCustomSettingsPricing();
        TestData.setupCustomConfigObjectsPricing();
        
        //Create all the objects we need
        ID sysDesignID = TestData.setupSystemDesign('Residential', 'Purchase', null, false, Double.valueOf(5.000));
        
        Utility_Company__c utilRateCode = [SELECT ID FROM Utility_Company__c ORDER BY CreatedDate DESC LIMIT 1];    //Get the one that was created in setupSystemDesign()
        Utility_Service__c utilService = [SELECT Utility_Rate_Code_After_Solar__c, Utility_Value_of_Solar_Tariff__c, Utility_Company_Master__r.Solar_Compensation_Method__c 
                                          FROM Utility_Service__c ORDER BY CreatedDate DESC LIMIT 1];    //Get the one that was created in setupSystemDesign()
        if (utilService.Utility_Rate_Code_After_Solar__c == null)
            utilService.Utility_Rate_Code_After_Solar__c = utilRateCode.ID;
        else
            utilService.Utility_Rate_Code_After_Solar__c = null;
            
        if (utilService.Utility_Value_of_Solar_Tariff__c== null)
            utilService.Utility_Value_of_Solar_Tariff__c= utilRateCode.ID;
        else
            utilService.Utility_Value_of_Solar_Tariff__c= null;
        update utilService;
        
        //Check if System Design was updated
        System_Design__c systemDesign = [SELECT Astrum_SQ_Calculation_Status__c, Astrum_Invalid_SQ_Error_Message__c FROM System_Design__c WHERE ID = :sysDesignID];
        System.assertEquals('Invalid', systemDesign.Astrum_SQ_Calculation_Status__c);
        if (utilService.Utility_Company_Master__r.Solar_Compensation_Method__c == 'Net Metering')
            System.assertEquals('Utility Rate Code has changed', systemDesign.Astrum_Invalid_SQ_Error_Message__c);
        else if (utilService.Utility_Company_Master__r.Solar_Compensation_Method__c == 'VOST')
            System.assertEquals('Value of Solar Tariff has changed', systemDesign.Astrum_Invalid_SQ_Error_Message__c);
    }

    @isTest(seeAllData = false) static void rateCode_Test(){
        TestData.setupCustomSettingsPricing();
        TestData.setupCustomConfigObjectsPricing();
        
        //Create all the objects we need
        ID sysDesignID = TestData.setupSystemDesign('Residential', 'Purchase', null, false, Double.valueOf(5.000));
        
        Utility_Company__c utilRateCode = [SELECT RecordType.Name FROM Utility_Company__c ORDER BY CreatedDate DESC LIMIT 1];
        Utility_Service__c utilService = [SELECT Custom_Utility_Rate_Applied__c, Utility_Rate_Code_Before_Solar__c, Utility_Company__c 
                                          FROM Utility_Service__c ORDER BY CreatedDate DESC LIMIT 1];

        utilService.Utility_Rate_Code_Before_Solar__c = utilRateCode.ID;
        update utilService;

        //Test checkCustomUtilityRate()
        if (utilRateCode.RecordType.Name == 'Custom')
            System.assertEquals(true, utilService.Custom_Utility_Rate_Applied__c);
        else
            System.assertEquals(false, utilService.Custom_Utility_Rate_Applied__c);
    }
}