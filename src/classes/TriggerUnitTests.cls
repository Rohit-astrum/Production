@isTest(SeeAllData=true)
public class TriggerUnitTests {
  public static testmethod void InsertLeadTest() {
          Lead lead = new Lead(Company='QAS Test Lead',
                                        LastName='Smith',
                                        Street = 'Hamilton Ave',
                                        Country = 'US',
                                        State = 'NY',
                                        PostalCode = '10606',
                                        City = 'White Plains');
          insert lead;        
    }

     public static testmethod void InsertContractTest() {
          Account account = new Account(Name='QAS Test Account',                                    
                      ShippingStreet = 'Hamilton Ave',
                      ShippingCountry = 'US',
                      ShippingState = 'NY',
                      ShippingPostalCode = '10606',
                      ShippingCity = 'White Plains');
          insert account;        
          
          Contract contract = new Contract(Name='QAS Contract test name',
                                        StartDate = Date.today(),
                                        ContractTerm=1,
                                        AccountId = account.Id);
          insert contract;        
    }
    
    public static testmethod void InsertAccountTest() {
          Account account = new Account(Name='QAS Test Account',                                    
                      ShippingStreet = 'Hamilton Ave',
                      ShippingCountry = 'US',
                      ShippingState = 'NY',
                      ShippingPostalCode = '10606',
                      ShippingCity = 'White Plains');
          insert account;     
    }

     public static testmethod void InsertContactTest() {
          Contact contact = new Contact(LastName='Smith');
          insert contact;        
    }
    
     public static testmethod void InsertPropertyTest() {
        
          Account account = new Account(Name='QAS Test Account',                                    
                      ShippingStreet = 'Hamilton Ave',
                      ShippingCountry = 'US',
                      ShippingState = 'NY',
                      ShippingPostalCode = '10606',
                      ShippingCity = 'White Plains');
          insert account;        
          
          Property__c property = new Property__c(Name='QAS Test Property',
                                        Property_City__c='Boston',
                                        Property_ZIP__c='02110',
                                        Property_Owner__c=account.Id,
                                        Property_County__c='Suffolk',
                                        Property_State__c='MA',
                                        Astrum_Office__c='Hopkinton, MA');
          insert property;        
    }
    
    
}