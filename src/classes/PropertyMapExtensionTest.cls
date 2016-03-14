@isTest(seeAllData=true)
private class PropertyMapExtensionTest {
	
	@isTest static void PropertyMapTest() {

		Account acct = new Account();
        acct.name='TestAcct';        
        insert acct;

		Property__c prop = new Property__c();
        prop.Name = '123 Main St';
        prop.Property_Owner__c = acct.Id;       
        prop.Optimal_Site_Quality_kWh_y_kW__c = double.valueOf('1250');
        prop.Property_State__c = 'MD';
        prop.Property_City__c = 'Annapolis Junction';
        prop.Property_ZIP__c = '20701';
        prop.Property_County__c = 'Howard';
        prop.Astrum_Office__c = testdata.defaultOffLocationName;// FPO Phase4 //'Annapolis Junction, MD';   
        prop.QAS_latitude__C =  '39.125919';    
        prop.QAS_longitude__C =  '-76.793228';  

        prop.Confirmed_Location__latitude__s = 39.125919;    
        prop.Confirmed_Location__longitude__s =  -76.793228; 

        

        insert prop;

        ApexPages.StandardController prcontroller = new ApexPages.StandardController(prop);
    	PropertyMapExtension extController = new  PropertyMapExtension(prcontroller);    
    	Decimal latitude = extController.Latitude;
    	Decimal longitude = extController.longitude;

    	System.assertEquals(latitude,prop.Confirmed_Location__latitude__s);


	}
	
	
}