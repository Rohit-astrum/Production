@isTest
public class PMProjUpdateBinCatBatchTest {
    static testmethod void updateAstrumDoc(){
        
        //create pm proj
        PM_Project__c proj = new PM_Project__c(name='test proj');
        insert proj;
        
        //create test docs
        List<Astrum_Doc__c> docs = new List<Astrum_Doc__c>();
        docs.add(new Astrum_Doc__c(Bin__c ='Drivers Licenses', Category__c = 'Drivers License', PM_Project__c = proj.Id));
        docs.add(new Astrum_Doc__c(Bin__c ='Kickoff Photos', Category__c = 'Property Photo', PM_Project__c = proj.Id));
        docs.add(new Astrum_Doc__c(Bin__c ='HOA Submitted Documents', Category__c = 'HOA Document', PM_Project__c = proj.Id));
        docs.add(new Astrum_Doc__c(Bin__c ='HOA Submitted Documents', Category__c = 'Historical Document', PM_Project__c = proj.Id));
        docs.add(new Astrum_Doc__c(Bin__c ='Utility Bill', Category__c = 'Utility Bill', PM_Project__c = proj.Id));
        docs.add(new Astrum_Doc__c(Bin__c ='Install Prep Sheet', Category__c = 'Install Prep Sheet', PM_Project__c = proj.Id));
        docs.add(new Astrum_Doc__c(Bin__c ='Signed Conduit Run and Layout', Category__c = 'Conduit Run and Layout - Customer Signed', PM_Project__c = proj.Id));
        docs.add(new Astrum_Doc__c(Bin__c ='Permit Design', Category__c = 'Structural Engineer Review', PM_Project__c = proj.Id));
        docs.add(new Astrum_Doc__c(Bin__c ='Building Permit', Category__c = 'Building Permit Package', PM_Project__c = proj.Id));
        docs.add(new Astrum_Doc__c(Bin__c ='Building Permit', Category__c = 'Electrical Permit Package', PM_Project__c = proj.Id));
        docs.add(new Astrum_Doc__c(Bin__c ='Building Permit', Category__c = 'Approved Building Permit', PM_Project__c = proj.Id));
        docs.add(new Astrum_Doc__c(Bin__c ='Building Permit', Category__c = 'Approved Electrical Permit', PM_Project__c = proj.Id));
        insert docs;
        
        //run batch process
        Test.startTest();
        PMProjUpdateBinCatBatch batch = new PMProjUpdateBinCatBatch();
        batch.execute(null, docs);
        batch.errors = 'Test Errors';
        batch.finish(null);
        Test.stopTest(); 
        
        
    }

}