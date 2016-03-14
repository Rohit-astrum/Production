/* FILE: ProductionGuaranteeTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: October 26, 2012
 * PURPOSE: Test for ProductionGuaranteeCalculator class
 * MODIFICATION HISTORY
 *
 */
 
@isTest
private class ProductionGuaranteeTest {

    static testMethod void noGuarantee_calcGuarantee_correct() {

		PVWatts_Production_Estimates__c pvw = new PVWatts_Production_Estimates__c (
			January__c= 100, 
			February__c= 100, 
			March__c= 100, 
			April__c= 100, 
			May__c= 100, 
			June__c= 100,
			July__c= 100, 
			August__c= 100, 
			September__c= 100, 
			October__c= 100, 
			November__c= 100, 
			December__c = 100,
			Annual_Total__c = 1200
		);
		
		Date genStart = Date.newInstance(2011,3,1);
		
		List<ProductionGuaranteeCalculator.ProductionGuarantee> result 
			= ProductionGuaranteeCalculator.getProductionGuarantee(
				pvw, 
				1000, //systemSizekW, 
				12000, //annualProjectedkWh, 
				genStart, //generationStart, 
				0);
        
        Date dateWork = genStart;
        Date today = System.today().toStartOfMonth();
        
        for (Integer i = 0; i < result.size(); i++) {
        	System.assertEquals(dateWork, result[i].startOfMonth);
        	System.assertEquals(null, result[i].guarantee_kWh);
        	dateWork = dateWork.addMonths(1);
        }
        
    }
    
    static testMethod void guaranteeSnowDerate_calcGuarantee_correct() {

		PVWatts_Production_Estimates__c pvw = new PVWatts_Production_Estimates__c (
			January__c= 100, 
			February__c= 100, 
			March__c= 100, 
			April__c= 100, 
			May__c= 100, 
			June__c= 100,
			July__c= 100, 
			August__c= 100, 
			September__c= 100, 
			October__c= 100, 
			November__c= 100, 
			December__c = 100,
			Annual_Total__c = 1200
		);
		
		Date genStart = Date.newInstance(2012,1,1);
		
		List<ProductionGuaranteeCalculator.ProductionGuarantee> result 
			= ProductionGuaranteeCalculator.getProductionGuarantee(
				pvw, 
				1000, //systemSizekW, 
				12000, //annualProjectedkWh, 
				genStart, //generationStart, 
				75);
        
        Date dateWork = genStart;
        Date today = System.today().toStartOfMonth();
        
        for (Integer i = 0; i < result.size(); i++) {
        	System.assertEquals(dateWork, result[i].startOfMonth);
        	System.assertNotEquals(null, result[i].guarantee_kWh);
        	dateWork = dateWork.addMonths(1);
        }
        
    }
}