/* FILE: WordOrderDetailControllerTest.cls
 * AUTHOR: Pavitra Burla
 * DATE: Aug 20, 2015
 * PURPOSE: Test class for WordOrderDetailController
 * MODIFICATION HISTORY 
 */
@isTest(seeAllData=true)
public class WorkOrderDetailControllerTest {
    static testmethod void opstest(){
        
        List<PM_Project__c> projs = [SELECT Work_Order__c ,Sales_Order__r.System_Design_Quote__r.System_Design__c
                                        FROM PM_Project__c 
                                        WHERE Work_Order__r.rstk__wocst_ordsts_pl__c = '2-Firm' LIMIT 1];
        if(projs!=null && projs.size()>0){

            Test.setCurrentPage(Page.WordOrderDetail);
            ApexPages.StandardController controller = new ApexPages.StandardController(projs[0]);
            WorkOrderDetailController extn = new WorkOrderDetailController(controller);
            Id woId = extn.workorder.Id;

            Test.startTest();
            List<rstk__woordop__c> ops = [SELECT Id FROM rstk__woordop__c WHERE rstk__woordop_ordno__c = :woId];
            System.debug(loggingLevel.ERROR,'ops:' + ops + 'size:' +ops.size());
            extn.deleteOperations();
            
            ops = [SELECT Id FROM rstk__woordop__c WHERE rstk__woordop_ordno__c = :woId];
            System.debug(loggingLevel.ERROR,'ops:' + ops + 'size:' +ops.size());
            System.assertEquals(0,ops.size());
        
            //Since sydata executes in batch , the result of below operations are not immediate for us to verify.
            extn.extractOperations();
            extn.generatePicklist();
            extn.reGeneratePicklist();
            extn.completeWO();
            extn.closeWO();
            Test.stopTest();
        } 
    }

}