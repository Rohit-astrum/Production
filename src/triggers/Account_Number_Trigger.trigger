// 10/12/2012 TCM - removed Account Number Logic
// 10/12/2012 TCM - change functionality to copy billing to shipping on insert
trigger Account_Number_Trigger on Account (before insert, before update) {

	if (Trigger.isBefore) {
		System_Designers_Assignment__c assignment = null;

		if(Trigger.isInsert && UserInfo.getUserType() == 'CspLitePortal'){
			List<System_Designers_Assignment__c> assignments = [SELECT User__c, Last_Assignment_Datetime__c FROM System_Designers_Assignment__c ORDER BY Last_Assignment_Datetime__c ASC LIMIT 1];
			if(assignments.size() == 1){
				assignment = assignments[0];
			}
		}

		for (Account a : Trigger.new) {
			if (a.ShippingStreet == null && a.ShippingCity == null && a.ShippingState == null && a.ShippingPostalCode == null && a.ShippingCountry == null
			&& (a.BillingStreet != null || a.BillingCity != null || a.BillingState != null || a.BillingPostalCode != null || a.BillingCountry != null)) {
				a.ShippingStreet = a.BillingStreet;
				a.ShippingCity = a.BillingCity;
				a.ShippingState = a.BillingState;
				a.ShippingPostalCode = a.BillingPostalCode;
				a.ShippingCountry = a.BillingCountry;
			}

			// Used in D2D...
            if(Trigger.isInsert && assignment != null && UserInfo.getUserType() == 'CspLitePortal'){
                system.debug('**SZ: account owner = ' + a.OwnerId);
                a.OwnerId = assignment.User__c;
            }
		}
	}
}