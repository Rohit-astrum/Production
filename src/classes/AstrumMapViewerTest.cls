@isTest
public class AstrumMapViewerTest {

	static testMethod void testGetSalesOrders() {
		
		Account a = new Account(
			Name = 'Test Account'
		);
		insert a;
		
		Property__c p = new Property__c(
			Name = 'Test Property',
			Property_Owner__c = a.Id,
			Property_City__c = 'Test City',
			Property_State__c = 'PA',
			Property_ZIP__c = '19403',
			Property_County__c = 'Test County'
		);
		insert p;
		
		SCRB_SalesOrder__c o = new SCRB_SalesOrder__c (
			Property__c = p.Id,
			Requires_Tree_Removal__c = 'No'
		);
		insert o;
		
	}

}