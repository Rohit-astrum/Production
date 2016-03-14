@isTest(SeeAlldata=true)
public class LeadDuplicateHandlingTests{
    static testMethod void testLeadDuplicate() {
      
      Server_Info__c serverinfo = New Server_Info__c();
      serverinfo.Name = 'Test';
      insert serverinfo;   
      // Bulk Insert Works Fine
      Lead lead1 = new Lead(LastName='TestAbc2', Company='Test1 Inc.',
                            Street= '100 Astrum Lane' , City = 'Wayne', State = 'PA', PostalCode = '19087' , LeadSource = 'Search Engine', Method_Of_Contact__c = 'Astrum Web Form'
                           );
      Lead lead2 = new Lead(LastName='TestAbc2', Company='Test2 Inc.',
                            Street= '201 Astrum Lane' , City = 'Wayne', State = 'PA', PostalCode = '19087' , LeadSource = 'Search Engine', Method_Of_Contact__c = 'Astrum Web Form'
                           );
      Lead lead3 = new Lead(LastName='TestAbc3', Company='Test3 Inc.',
                            Street= '301 Astrum Lane' , City = 'Wayne', State = 'PA', PostalCode = '19087' , LeadSource = 'Search Engine', Method_Of_Contact__c = 'Astrum Web Form'
                           );
                           
      List<Lead> leads  = new List<Lead>(); 
      
      leads.add(lead1);
      leads.add(lead2);
      leads.add(lead3);      
      
      insert leads;
      
      // Bulk Update Works Fine         
      lead2.Street = '200 Astrum Lane';
      lead3.Street = '300 Astrum Lane';
      Lead[] upLeads = new Lead[] {lead2 , lead3 };   
      update upLeads ;        
         
      // Insert Dup             
      Lead dup1= new Lead(LastName='TestAbc4', Company='Test4 Inc.',
                            Street= '100 Astrum Lane' , City = 'Wayne', State = 'PA', PostalCode = '19087' , LeadSource = 'Search Engine', Method_Of_Contact__c = 'Astrum Web Form'
                           );
      
      insert dup1; 
      
      dup1 = [Select Status from Lead Where Id = :dup1.Id ]; 
      List<Task> tasks = [Select t.WhoId, t.Description, t.ActivityDate, t.Status From Task t where whoId = :lead1.Id];
           
      System.assertEquals(1, tasks.size());      
      System.assert(dup1.Status == 'Not a Lead - DUPLICATE');
     
      Lead dup2= new Lead(LastName='TestAbc5', Company='Test5 Inc.',
                            Street= '400 Astrum Lane' , City = 'Wayne', State = 'PA', PostalCode = '19087' , LeadSource = 'Search Engine', Method_Of_Contact__c = 'Astrum Web Form'
                           );
      
      insert dup2; 

      // Update Dup 
      dup2.Street = '100 Astrum Lane';
      update dup2;
      
      dup2 = [Select Status from Lead Where Id = :dup2.Id ]; 
      List<Task> tasks2 = [Select t.WhoId, t.Description, t.ActivityDate, t.Status From Task t where whoId = :lead1.Id];
      
      System.assertEquals(2, tasks2 .size()); 
      System.assert(dup2.Status == 'Not a Lead - DUPLICATE');
          
      // Bulk Insert Dup  
      Lead lead4 = new Lead(LastName='TestAbc44', Company='Test44 Inc.',
                            Street= '4400 Astrum Lane' , City = 'Wayne', State = 'PA', PostalCode = '19087' , LeadSource = 'Search Engine', Method_Of_Contact__c = 'Astrum Web Form'
                           );
      Lead lead5 = new Lead(LastName='TestAbc55', Company='Test55 Inc.',
                            Street= '4400 Astrum Lane' , City = 'Wayne', State = 'PA', PostalCode = '19087' , LeadSource = 'Search Engine', Method_Of_Contact__c = 'Astrum Web Form'
                           );
      Lead lead6 = new Lead(LastName='TestAbc66', Company='Test66 Inc.',
                            Street= '300 Astrum Lane' , City = 'Wayne', State = 'PA', PostalCode = '19087' , LeadSource = 'Search Engine', Method_Of_Contact__c = 'Astrum Web Form'
                           );
                           
      Lead[] dups = new Lead[] {lead4 , lead5 , lead6 };      
      
      insert dups;
      
      lead4 = [Select Status from Lead Where Id = :lead4.Id ]; 
      lead5 = [Select Status from Lead Where Id = :lead5.Id ]; 
      lead6 = [Select Status from Lead Where Id = :lead6.Id ]; 
      
      System.assert(lead4.Status != 'Not a Lead - DUPLICATE');
      System.assert(lead5.Status == 'Not a Lead - DUPLICATE');
      System.assert(lead6.Status == 'Not a Lead - DUPLICATE');   
    
      // Bulk Update Dup     
      lead2.Street = '100 Astrum Lane';
      lead3.Street = '100 Astrum Lane';
      lead4.Street = '500 Astrum Lane';
      
      dups = new Lead[] {lead2, lead3, lead4};
     
      update dups;
      lead2 = [Select Status from Lead Where Id = :lead2.Id ]; 
      lead3 = [Select Status from Lead Where Id = :lead3.Id ]; 
      
      System.assert(lead2.Status == 'Not a Lead - DUPLICATE');
      System.assert(lead3.Status == 'Not a Lead - DUPLICATE');   
      
    }  
    static testMethod void testLeadDuplicateforOpp() {
      
      Server_Info__c serverinfo = New Server_Info__c();
      serverinfo.Name = 'Test';
      insert serverinfo;   
    
      //create a lead
      Lead ld = new Lead (
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Lead, Test',
            Street = '123 Test St',
            City = 'Test City',
            State = 'PA',
            PostalCode = '19403',
            County__c = 'Chester',
            Phone = '(215) 555-1212',
            Email = 'test@test.com',
            Method_of_Contact__c = 'Referral', 
            LeadSource = 'Portal Referral',
            Lead_Source_Detail__c = 'Professional',
            Site_Type__c = 'Residential'
            //Lead_Source_Detail_2__c = 'Channel',
           // Lead_Source_Detail_4__c = 'Astrum Solar Connect'
      );
      insert ld;

      //convert to oppty      
      Database.LeadConvert lc = new Database.LeadConvert();
      lc.setLeadId(ld.Id);
      lc.setConvertedStatus('Qualified');
      Database.LeadConvertResult lcr = Database.convertLead(lc);
      System.assert(lcr.isSuccess());
        
      //create a lead
      Lead ld2 = new Lead (
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Lead, Test',
            Street = '123 Test St',
            City = 'Test City',
            State = 'PA',
            PostalCode = '19403',
            County__c = 'Chester',
            Phone = '(215) 555-1212',
            Email = 'test@test.com',
            Method_of_Contact__c = 'Referral', 
            LeadSource = 'Portal Referral',
            Lead_Source_Detail__c = 'Professional',
            Site_Type__c = 'Residential'
            //Lead_Source_Detail_2__c = 'Channel',
           // Lead_Source_Detail_4__c = 'Astrum Solar Connect'
      );
      
      
      Test.startTest();
      insert ld2;
      Test.stopTest();
      
      ld2 = [Select Status from Lead Where Id = :ld2.Id ]; 
      
      System.assert(ld2.Status == 'Not a Lead - DUPLICATE');    
   }   
      
}