@isTest(seeAllData=false)
public class LeadSalesRegionBatchTest {
  static testMethod void runBatch() {	  
	    createCounties();
        
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
        /*
        Lead lead4 = new Lead (
            LeadSource = 'Events',
            //Lead_Source_Detail_1__c = 'xyz',
            FirstName = 'Test1',
            LastName = 'Lead1',
            Company = 'Lead1, Test1',            
            Street  = '135 E Main Street',
            City = 'Westborough',
            QAS_County__c = 'Worcester',
            State = 'MA',
            PostalCode = '01581',
            QAS_Latitude__c = '42.283932',
            QAS_Longitude__c = '-71.597206'           
        );
        
        insert lead4;
        */
        Test.startTest();
        
        /*
        //Need a converted lead in order to have the batch process the sales region by getting it from the opportunity.
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(lead4.Id);
        lc.setConvertedStatus('Qualified');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        System.assert(lcr.isSuccess());
        */
               
        //Run the batch process
        LeadSalesRegionBatch batch = new LeadSalesRegionBatch();
        Id batchId = Database.executeBatch(batch, 10); 

        Test.stopTest();
        
        lead1 = [SELECT Id, Sales_Region__c FROM Lead WHERE Id = :lead1.Id];
        lead2 = [SELECT Id, Sales_Region__c FROM Lead WHERE Id = :lead2.Id];
        lead3 = [SELECT Id, Sales_Region__c FROM Lead WHERE Id = :lead3.Id];
        //lead4 = [SELECT Id, Sales_Region__c FROM Lead WHERE Id = :lead4.Id];

        System.assertEquals('TEST1 Region', lead1.Sales_Region__c);     
        System.assertEquals('TEST2 Region', lead2.Sales_Region__c);     
        System.assertEquals('DC Region', lead3.Sales_Region__c);
        //System.assertEquals('Worcester Region', lead4.Sales_Region__c);
        
        Lead_Sales_Region__c lsr1 = [SELECT Id, Sales_Region__c, Lead_Created_Date__c FROM Lead_Sales_Region__c WHERE Lead_ID_Unique__c = :lead1.Id];   
        Lead_Sales_Region__c lsr2 = [SELECT Id, Sales_Region__c, Lead_Created_Date__c FROM Lead_Sales_Region__c WHERE Lead_ID_Unique__c = :lead2.Id];   
        Lead_Sales_Region__c lsr3 = [SELECT Id, Sales_Region__c, Lead_Created_Date__c FROM Lead_Sales_Region__c WHERE Lead_ID_Unique__c = :lead3.Id];   
        //Lead_Sales_Region__c lsr4 = [SELECT Id, Sales_Region__c, Lead_Created_Date__c FROM Lead_Sales_Region__c WHERE Lead_ID_Unique__c = :lead4.Id];

        System.assertEquals('TEST1 Region', lsr1.Sales_Region__c);      
        System.assertEquals('TEST2 Region', lsr2.Sales_Region__c);      
        System.assertEquals('DC Region', lsr3.Sales_Region__c);
        //System.assertEquals('Worcester Region', lsr4.Sales_Region__c);
  }
  
  public static void createCounties() {
        
        //PA
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


        //DC
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

        /*
        //County for converted lead test    
        State__c state3 = new State__c (
            Name = 'Massachusetts',
            FIPS_Code__c = '11',
            State_Abbreviation__c = 'MA'
        );
        insert state3;
                
        County__c county4 = new County__c (
            Name = 'Worcester, MA',
            FIPS_Code__c = '00100',
            State__c = state3.Id,
            Sales_Region__c = 'Worcester Region'
        );
        insert county4;
        */
    }
}