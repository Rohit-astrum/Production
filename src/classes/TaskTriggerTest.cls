/* FILE: TaskTriggerTest.trigger
 * AUTHOR: Pavitra Burla
 * DATE: Feb 09, 2016
 * PURPOSE: test class for TaskTrigger trigger
 * MODIFICATION HISTORY
 *
 */
@isTest
public class TaskTriggerTest {
	static testMethod void testTaskTrigger(){
		
		User surveyor = new User(
          Username = 'surveyor' + 'testuser@testorg.com',
          Alias = 'test',
          email = 'testuser@testorg.com',
          emailencodingkey = 'UTF-8',
          LastName = 'Survey Scheduler',
          LanguageLocaleKey = 'en_US',
          LocaleSidKey = 'en_US',
          ProfileId = UserInfo.getProfileId(),
          TimeZoneSidKey = 'America/New_York'

        );
        insert surveyor;

        Office_Location__c norristownoffloc = new Office_Location__c(Name = 'Norristown, PA', Street__c = '705 General Washington Avenue', City__c = 'Norristown', State__c = 'PA', Zip_Code__c = '19403', Director_of_Operations__c = UserInfo.getUserId(), Sales_Coordinator__c = UserInfo.getUserId(), Sales_Alert_Email__c = UserInfo.getUserEmail(), State_Coverage__c = '', Location__Latitude__s = 40.127031, Location__Longitude__s = -75.400675, Active__c = true , Survey_Scheduler__c= surveyor.Id);
        insert norristownoffloc;

        testdata.createMainofficeSetting();
        
        Account customer = new Account(Name = 'Test Customer', BillingStreet = '244 Torrey Pine', BillingState = 'PA' , BillingPostalCode = '19380', BillingCountry = 'USA' ,BillingCity = 'West Chester');
        insert customer;
        
        Property__c property = createNewProperty(customer.Id, '123 Test St',norristownoffloc.Id);       
        Opportunity opp = testdata.createTestOppForProperty(property);     
        		
		Test.startTest();

		Request_Site_Survey_Utility.assignTask(opp
					, UserInfo.getUserId()
					, 'test comments'
					, 'Residential Field Survey'
					, Date.today()
					, false
					, Date.today());

		
        Test.stopTest();
        
        opp = [SELECT Id
                , Property__r.Astrum_Office_New__r.name
                , (SELECT Owner.name FROM Tasks) 
                FROM Opportunity WHERE Id=:opp.Id];
        
        System.assertEquals(opp.Tasks[0].Owner.name, 'Survey Scheduler');
	}	

    public static Property__c createNewProperty(Id ownerId, String name, Id offlocId) {
        Property__c property = new Property__c(
            Name = name,
            Property_Owner__c = ownerId,
            Property_City__c = 'Test City',
            Property_State__c = 'PA',
            Property_Zip__c = '19403',
            Property_County__c = 'Test County',
            //Astrum_Office__c = 'Norristown, PA',
            Astrum_Office_New__c = offlocId,
            Hours_From_Nearest_Office__c = 1
        );
        insert property;
        return property;
    }
}