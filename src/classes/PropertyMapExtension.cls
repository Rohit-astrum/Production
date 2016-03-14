public with sharing class PropertyMapExtension {

	private Property__c property;

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public PropertyMapExtension(ApexPages.StandardController stdController) {
        this.property = (Property__c)stdController.getRecord();
        property = [Select Confirmed_Location__Longitude__s, Longitude__c , Confirmed_Location__Latitude__s,Latitude__c from Property__c Where id= :property.Id];
    }

    public Decimal Longitude {
        get{
            return (property.Confirmed_Location__Longitude__s != null ? property.Confirmed_Location__Longitude__s : property.Longitude__c );
            
        }
    }

    public Decimal Latitude {
        get{
             return (property.Confirmed_Location__Latitude__s != null ? property.Confirmed_Location__Latitude__s : property.Latitude__c );
        }
    }
}