/* FILE: LeadSalesRegionTriggerTest.cls
 * AUTHOR: Tino Mattheou
 * DATE: August 14, 2012
 * PURPOSE: Test class for LeadSalesRegion and LeadSalesRegion_AIAU triggers
 * MODIFICATION HISTORY
 * 09/10/2012 TCM - delete Lead_Sales_Region__c record when Lead is deleted - zen-52
 */
 
@isTest
public class LeadSalesRegionTriggerTest {

    static testMethod void counties_insertLeads_RegionSet () {
        
        createCounties();
        
        Test.startTest();
        
        Lead lead1 = new Lead (
            LastName = 'Test1',
            Company = 'Testco1',
            County__c = 'Test1 County',
            Street = 'Test',
            State = 'PA' 
        );
        insert lead1;
        Lead lead2 = new Lead (
            LastName = 'Test2',
            Company = 'Testco2',
            Street = 'Test12',
            QAS_County__c = 'test2 county',
            State = 'PA' 
        );
        insert lead2;
        Lead lead3 = new Lead (
            LastName = 'Test3',
            Company = 'Testco3',
            QAS_County__c = 'Washington DC',
            State = 'DC' 
        );
        insert lead3;

        Test.stopTest();
        
        lead1 = [SELECT Id, Sales_Region__c FROM Lead WHERE Id = :lead1.Id];
        lead2 = [SELECT Id, Sales_Region__c FROM Lead WHERE Id = :lead2.Id];
        lead3 = [SELECT Id, Sales_Region__c FROM Lead WHERE Id = :lead3.Id];

        System.assertEquals('TEST1 Region', lead1.Sales_Region__c);     
        System.assertEquals('TEST2 Region', lead2.Sales_Region__c);     
        System.assertEquals('DC Region', lead3.Sales_Region__c);
        
        Lead_Sales_Region__c lsr1 = [SELECT Id, Sales_Region__c, Lead_Created_Date__c FROM Lead_Sales_Region__c WHERE Lead_ID_Unique__c = :lead1.Id];   
        Lead_Sales_Region__c lsr2 = [SELECT Id, Sales_Region__c, Lead_Created_Date__c FROM Lead_Sales_Region__c WHERE Lead_ID_Unique__c = :lead2.Id];   
        Lead_Sales_Region__c lsr3 = [SELECT Id, Sales_Region__c, Lead_Created_Date__c FROM Lead_Sales_Region__c WHERE Lead_ID_Unique__c = :lead3.Id];   

        System.assertEquals('TEST1 Region', lsr1.Sales_Region__c);      
        System.assertEquals('TEST2 Region', lsr2.Sales_Region__c);      
        System.assertEquals('DC Region', lsr3.Sales_Region__c);
        
    } 
    
    static testMethod void counties_updateLead_RegionSet () {
        
        createCounties();
        
        Lead lead1 = new Lead (
            LastName = 'Test1',
            Company = 'Testco',
            County__c = 'Some County',
            State = 'PA' 
        );
        insert lead1;
        
        Lead_Sales_Region__c lsr1 = [SELECT Id, Sales_Region__c, Lead_Created_Date__c FROM Lead_Sales_Region__c WHERE Lead_ID_Unique__c = :lead1.Id];   
        System.assertEquals(null, lsr1.Sales_Region__c);        
        
        Test.startTest();
        
        lead1 = new Lead(Id = lead1.Id, QAS_County__c = 'Test1 County');
        update lead1;

        Test.stopTest();
        
        lead1 = [SELECT Id, Sales_Region__c FROM Lead WHERE Id = :lead1.Id];
        System.assertEquals('TEST1 Region', lead1.Sales_Region__c);
        
        lsr1 = [SELECT Id, Sales_Region__c, Lead_Created_Date__c FROM Lead_Sales_Region__c WHERE Lead_ID_Unique__c = :lead1.Id];    
        System.assertEquals('TEST1 Region', lsr1.Sales_Region__c);      
        
    }
    
    static testMethod void bypassTriggers_updateLead_NoRegionSet () {
        
        createCounties();
        
        Lead lead1 = new Lead (
            LastName = 'Test1',
            Company = 'Testco',
            County__c = 'Some County',
            State = 'PA' 
        );
        insert lead1;
        
        Test.startTest();
        
        SalesRegionHelper.bypassSalesRegionTriggers = true;
        
        lead1 = new Lead(Id = lead1.Id, QAS_County__c = 'Test1 County');
        update lead1;

        Test.stopTest();
        
        lead1 = [SELECT Id, Sales_Region__c FROM Lead WHERE Id = :lead1.Id];

        System.assertEquals(null, lead1.Sales_Region__c);       
        
    }  
    
    public static void createCounties() {
        
        State__c state1 = new State__c (
            Name = 'Pennsylvania',
            FIPS_Code__c = '00',
            State_Abbreviation__c = 'PA'
        );
        insert state1;
        
        County__c county1 = new County__c (
            Name = 'Test1 County, PA',
            FIPS_Code__c = '00000',
            State__c = state1.Id,
            Sales_Region__c = 'TEST1 Region'
        );
        insert county1;
        
        County__c county2 = new County__c (
            Name = 'Test2 County, PA',
            FIPS_Code__c = '00001',
            State__c = state1.Id,
            Sales_Region__c = 'TEST2 Region'            
        );
        insert county2;

        State__c state2 = new State__c (
            Name = 'District of Columbia',
            FIPS_Code__c = '01',
            State_Abbreviation__c = 'DC'
        );
        insert state2;

        County__c county3 = new County__c (
            Name = 'District of Columbia',
            FIPS_Code__c = '01000',
            State__c = state2.Id,
            Sales_Region__c = 'DC Region'
        );
        insert county3;
        
    }
    
    static testMethod void counties_deleteLeads_RegionsDeleted () {
        
        createCounties();

        Lead lead1 = new Lead (
            LastName = 'Test1',
            Company = 'Testco1',
            County__c = 'Test1 County',
            State = 'PA' 
        );
        insert lead1;
        Lead lead2 = new Lead (
            LastName = 'Test2',
            Company = 'Testco2',
            Street = 'ZTest1',
            QAS_County__c = 'test2 county',
            State = 'PA' 
        );
        insert lead2;
        Lead lead3 = new Lead (
            LastName = 'Test3',
            Company = 'Testco3',
            Street = 'ZTest2',
            QAS_County__c = 'Washington DC',
            State = 'DC' 
        );
        insert lead3;
        
        System.assertEquals(3, [SELECT count() FROM Lead WHERE Id IN (:lead1.Id, :lead2.Id, :lead3.Id)]);

        Test.startTest();

        delete lead1;
        
        delete new Lead[] { lead2, lead3 };
        
        Test.stopTest();
        
        System.assertEquals(0, [SELECT count() FROM Lead WHERE Id IN (:lead1.Id, :lead2.Id, :lead3.Id)]);
        
    } 
    

}