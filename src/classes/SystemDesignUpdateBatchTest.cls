@isTest
public class SystemDesignUpdateBatchTest {
    
    static testMethod void updateSystemDesign(){
        testData.setupCustomSettings();
        testdata.setupCustomConfigObjects();
        Id sdID = testData.setupSystemDesign('Residential', 'Purchase', null, true, 12000);
        System_Design_Array__c sda = [SELECT Id, Default_Mounting_Type__c, Mounting_Type__c, CB_Panel__r.Utility_Service__c 
                                      FROM System_Design_Array__c 
                                      WHERE System_Design__c =:sdID][0];
        sda.Default_Mounting_Type__c = null;
        sda.Mounting_Type__c = 'I-Beam';
        update sda;
        
        System_Design__c sysDes = [SELECT Id, Property__c FROM System_Design__c WHERE Id=:sdID];
        Property__c prop = [SELECT Id, Property_Owner__c FROM Property__c WHERE Id=:sysDes.Property__c];
        Opportunity opp = testdata.createTestOppForProperty(prop);        
        
        Test.startTest();
        SystemDesignUpdateBatch batch = new SystemDesignUpdateBatch();
        batch.execute(null, new List<Opportunity>{opp});
        batch.errors = 'Test Errors';
        batch.finish(null);
        Test.stopTest();        
        
    }
    
    static testMethod void updateSQValidation(){
        testData.setupCustomSettings();
        testdata.setupCustomConfigObjects();
        Id sdID = testData.setupSystemDesign('Residential', 'Purchase', null, true, 12000);
        System_Design_Array__c sda = [SELECT Id, Default_Mounting_Type__c, Mounting_Type__c, CB_Panel__r.Utility_Service__c 
                                      FROM System_Design_Array__c 
                                      WHERE System_Design__c =:sdID][0];
        sda.Default_Mounting_Type__c = null;
        sda.Mounting_Type__c = 'I-Beam';
        update sda;
        
        System_Design__c sysDes = [SELECT Id, Property__c FROM System_Design__c WHERE Id=:sdID];
        Property__c prop = [SELECT Id, Property_Owner__c FROM Property__c WHERE Id=:sysDes.Property__c];
        Opportunity opp = testdata.createTestOppForProperty(prop);        
        
        Test.startTest();
        SystemDesignUpdateSQValidationBatch batch = new SystemDesignUpdateSQValidationBatch();
        batch.execute(null, new List<System_Design__c>{sysDes});
        batch.errors = 'Test Errors';
        batch.finish(null);
        Test.stopTest();        
        
    }

}