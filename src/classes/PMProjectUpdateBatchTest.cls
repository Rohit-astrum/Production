@isTest
public class PMProjectUpdateBatchTest {
    static testmethod void updatePMProject(){
        
        //create pm proj
        PM_Project__c proj = new PM_Project__c(name='test proj',Permit_Design__c= Date.Today());
        insert proj;
        Date finalEngDocDate1 = [SELECT Final_Structural_Engineering_Documents__c FROM PM_Project__c WHERE Id =:proj.Id].Final_Structural_Engineering_Documents__c;
        System.assertEquals(null, finalEngDocDate1);
        
        List<PM_Project__c> projs = new List<PM_Project__c>();
        projs.add(proj);
        
        //run batch process
        Test.startTest();
        PMProjectUpdateBatch batch = new PMProjectUpdateBatch();
        batch.execute(null, projs);
        batch.errors = 'Test Errors';
        batch.finish(null);
        Test.stopTest();
        
        Date finalEngDocDate2 = [SELECT Final_Structural_Engineering_Documents__c FROM PM_Project__c WHERE Id =:proj.Id].Final_Structural_Engineering_Documents__c;
        System.assertNotEquals(null, finalEngDocDate2);
        
    }
}