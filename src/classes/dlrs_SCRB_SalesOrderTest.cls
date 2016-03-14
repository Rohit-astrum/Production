/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_SCRB_SalesOrderTest
{
    private static testmethod void testTrigger()
    {
        // Force the dlrs_SCRB_SalesOrderTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new SCRB_SalesOrder__c());
    }
}