@isTest
public class PMProjUpdateBinCompleteBatchTest {
    static testmethod void updateAstrumDoc(){

        list<Astrum_Application__c> appList = new list<Astrum_Application__c>();
        applist.add(new Astrum_Application__c(Name='Astrum PM 2.0'));
        insert appList;

        system.debug('setup Bin_Configuration__c');
        list<Bin_Configuration__c> binList = new list<Bin_Configuration__c>();

        id aPMid = applist[0].id;
        binList.add(new Bin_Configuration__c(Astrum_Application__c = aPMid, Bin_Column_Width__c = 70, Bin_Grouping_Name__c = 'Pre-Approval', Bin_Grouping_Order__c = 1, Bin_Order__c = 118, Bin__c = 'Kickoff Documents', Field_Name__c = 'Kickoff_Documents__c', Installer_Electrician_Access__c = false));
        
        insert binList;

        system.debug('setup Category_Configuration__c');
        list<Category_Configuration__c> catList = new list<Category_Configuration__c>();

        //ASTRUM PM 2.0
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Kickoff Documents', Category_Order_In_Bin__c = 1, Category__c = 'Prelim PDP', Document_Bin_State__c = 'Submitted', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = 'Building_Permit_Submitted__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Kickoff Documents', Category_Order_In_Bin__c = 2, Category__c = 'Utility Bill', Document_Bin_State__c = 'Approved', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = 'Building_Permit__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Kickoff Documents', Category_Order_In_Bin__c = 1, Category__c = 'Install Prep Sheet', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Kickoff Documents', Category_Order_In_Bin__c = 1, Category__c = 'Property Photo', Document_Bin_State__c = 'Submitted', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = 'Electrical_Permit_Submitted__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Kickoff Documents', Category_Order_In_Bin__c = 2, Category__c = 'Preliminary Conduit Run', Document_Bin_State__c = 'Approved', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = 'Electrical_Permit__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        
        insert catList;
        
        //create pm proj
        PM_Project__c proj = new PM_Project__c(name='test proj');
        insert proj;

        proj = [SELECT Kickoff_Documents__c FROM PM_Project__c WHERE Id =: proj.Id];
        System.assertEquals(proj.Kickoff_Documents__c, null);
        
        //create test docs
        List<Astrum_Doc__c> docs = new List<Astrum_Doc__c>();
        docs.add(new Astrum_Doc__c(Bin__c ='Kickoff Documents', Category__c = 'Prelim PDP', PM_Project__c = proj.Id));
        docs.add(new Astrum_Doc__c(Bin__c ='Kickoff Documents', Category__c = 'Utility Bill', PM_Project__c = proj.Id));
        docs.add(new Astrum_Doc__c(Bin__c ='Kickoff Documents', Category__c = 'Install Prep Sheet', PM_Project__c = proj.Id));
        docs.add(new Astrum_Doc__c(Bin__c ='Kickoff Documents', Category__c = 'Property Photo', PM_Project__c = proj.Id));
        docs.add(new Astrum_Doc__c(Bin__c ='Kickoff Documents', Category__c = 'Preliminary Conduit Run', PM_Project__c = proj.Id));
        insert docs;
        
        //run batch process
        Test.startTest();
        PMProjUpdateBinCompleteBatch batch = new PMProjUpdateBinCompleteBatch();
        batch.execute(null, new List<PM_Project__c>{proj});
        batch.errors = 'Test Errors';
        batch.finish(null);
        Test.stopTest();

        proj = [SELECT Kickoff_Documents__c FROM PM_Project__c WHERE Id =: proj.Id];

        System.assertNotEquals(proj.Kickoff_Documents__c, null);
    }

}