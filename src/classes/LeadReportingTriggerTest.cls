@isTest(SeeAllData=true)
public class LeadReportingTriggerTest {
    
     
     static testMethod void LeadTriggerTest() {
    
        Lead l = new Lead (
            LeadSource = 'Search Engine',           
            FirstName = 'Test1',
            LastName = 'Lead1',
            Site_Type__c = 'Residential', 
            Company = 'Lead1, Test1',            
            Street  = '135 E Main Street',
            City = 'Westborough',
            QAS_County__c = 'Worcester',
            State = 'MA',
            PostalCode = '01581',
            QAS_Latitude__c = '42.283932',
            QAS_Longitude__c = '-71.597206'           
        );
        
        insert l;
        
        //Test.startTest();
        /*
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(l.Id);
        lc.setConvertedStatus('Qualified');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        //Test.stopTest();
        
        System.assert(lcr.isSuccess());
        */
        Lead_Reporting__c lsr;
        try{
            lsr = 
                [SELECT Id, Lead__c 
                FROM Lead_Reporting__c
                WHERE Lead__c = :l.Id];
        }
        catch(Exception e)
        {
            lsr = null;    
        }  
        System.assertEquals(lsr.Lead__c , l.Id );
            
    }
    static testMethod void LeadTriggerConversionTest() {
    
        Lead l = new Lead (
            LeadSource = 'Search Engine', 
            FirstName = 'Test1',
            LastName = 'Lead1',
            Site_Type__c = 'Residential', 
            Company = 'Lead1, Test1', 
            Street  = '135 E Main Street',
            City = 'Westborough',
            QAS_County__c = 'Worcester',
            State = 'MA',
            PostalCode = '01581',
            QAS_Latitude__c = '42.283932',
            QAS_Longitude__c = '-71.597206' 
        );
        
        insert l;
        
        Test.startTest();
       
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(l.Id);
        lc.setConvertedStatus('Qualified');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        Test.stopTest();
        
        System.assert(lcr.isSuccess());
        
        l = [Select ConvertedOpportunityId from Lead Where Id = :l.Id];
        
        Lead_Reporting__c lsr;
        try{
            lsr = 
                [SELECT Id, Lead__c , Opportunity__c
                FROM Lead_Reporting__c
                WHERE Lead__c = :l.Id];
        }
        catch(Exception e)
        {
            lsr = null;    
        }  
        System.assertEquals(lsr.Opportunity__c , l.ConvertedOpportunityId  );
            
    }
    
     static testMethod void LeadTriggerDeletionTest() {
    
        Lead l = new Lead (
            LeadSource = 'Search Engine',           
            FirstName = 'Test1',
            LastName = 'Lead1',
            Site_Type__c = 'Residential', 
            Company = 'Lead1, Test1',            
            Street  = '135 E Main Street',
            City = 'Westborough',
            QAS_County__c = 'Worcester',
            State = 'MA',
            PostalCode = '01581',
            QAS_Latitude__c = '42.283932',
            QAS_Longitude__c = '-71.597206'           
        );
        
        insert l;        
        Delete l;
        
        Lead_Reporting__c lsr;
        try{
            lsr = 
                [SELECT Id, Lead__c 
                FROM Lead_Reporting__c
                WHERE Lead__c = :l.Id];
        }
        catch(Exception e)
        {
            lsr = null;    
        }  
        System.assertEquals(lsr ,null );
        
            
    }
    static testMethod void OpportunityTriggerTest() {
    
        Account acct = new Account(Name = 'Test Acct');
        insert acct;
        
        Property__c prop = new Property__c();
        prop.Name = '123 Main St';
        prop.Property_Owner__c = Acct.Id;
       
        prop.Optimal_Site_Quality_kWh_y_kW__c = double.valueOf('1250');
        prop.Property_State__c = 'MD';
        prop.Property_City__c = 'Annapolis Junction';
        prop.Property_ZIP__c = '20701';
        prop.Permit_Jurisdiction__c = 'Howard';
        prop.Property_County__c = 'Howard';
        prop.Astrum_Office__c = testdata.defaultOffLocationName;// FPO Phase4 //'Annapolis Junction, MD';
        
        insert prop;
        
        Test.startTest();
        
        Opportunity op = new Opportunity (
            LeadSource = 'Search Engine'                                  
        );
        op.AccountId = acct.id;
        op.Name='Test Opportunity223';
        op.StageName = 'Submit Pending';
        op.CloseDate= Date.Today();
        op.Property__c = prop.Id;
        
        insert op;
        Test.stopTest();
        
        //Test.startTest();
        /*
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(l.Id);
        lc.setConvertedStatus('Qualified');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        //Test.stopTest();
        
        System.assert(lcr.isSuccess());
        */
        Lead_Reporting__c lsr;
        try{
            lsr = 
                [SELECT Id, Opportunity__c 
                FROM Lead_Reporting__c
                WHERE Opportunity__c = :op.Id];
        }
        catch(Exception e)
        {
            lsr = null;    
        }  
        System.assertEquals(lsr.Opportunity__c , op.Id );
            
    }
    
     static testMethod void OpportunityTriggerDeletionTest() {
    
        Account acct = new Account(Name = 'Test Acct');
        insert acct;
        
        Property__c prop = new Property__c();
        prop.Name = '123 Main St';
        prop.Property_Owner__c = Acct.Id;
       
        prop.Optimal_Site_Quality_kWh_y_kW__c = double.valueOf('1250');
        prop.Property_State__c = 'MD';
        prop.Property_City__c = 'Annapolis Junction';
        prop.Property_ZIP__c = '20701';
        prop.Permit_Jurisdiction__c = 'Howard';
        prop.Property_County__c = 'Howard';
        prop.Astrum_Office__c = testdata.defaultOffLocationName;// FPO Phase4 //'Annapolis Junction, MD';
        
        insert prop;
        
        
        
        Opportunity op = new Opportunity (
            LeadSource = 'Search Engine'                                  
        );
        op.AccountId = acct.id;
        op.Name='Test Opportunity223';
        op.StageName = 'Submit Pending';
        op.CloseDate= Date.Today();
        op.Property__c = prop.Id;
        
        insert op;
        
        Test.startTest();
        Delete op;
        Test.stopTest();
       
        Lead_Reporting__c lsr;
        try{
            lsr = 
                [SELECT Id, Opportunity__c 
                FROM Lead_Reporting__c
                WHERE Opportunity__c = :op.Id];
        }
        catch(Exception e)
        {
            lsr = null;    
        }  
        System.assertEquals(lsr , null );
            
    }
}