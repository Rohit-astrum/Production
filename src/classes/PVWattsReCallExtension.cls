public class PVWattsReCallExtension {

	private ApexPages.StandardController controller;
	
	public PVWattsReCallExtension(ApexPages.StandardController controller) {
		this.controller = controller;
	}
	
	public PageReference reCallPVWatts() {

		/*

		Property__c property = (Property__c) controller.getRecord();

		property = 
			[SELECT Id, DC_to_AC_Derate__c, Latitude__c, Longitude__c, QAS_Latitude__c, QAS_Longitude__c, Snow_De_Rate_kWh_y_kW__c,Property_State__c
			FROM Property__c
			WHERE Id = :property.Id];
			
		Double latitude = property.QAS_Latitude__c != null ? Double.valueOf(property.QAS_Latitude__c) : property.Latitude__c; 
		Double longitude = property.QAS_Longitude__c != null ? Double.valueOf(property.QAS_Longitude__c) : property.Longitude__c;
		
		if (property.DC_to_AC_Derate__c == null) {
			property.DC_to_AC_Derate__c = 0.925;
		} 
		
		if (latitude != null && longitude != null && property.DC_to_AC_Derate__c != null) {
			
			Double maxSiteQuality = PVWatts_ServiceClient.getSiteQuality(latitude, longitude, property.DC_to_AC_Derate__c,property.Property_State__c);
			
			if (maxSiteQuality != null) {
		        property.Max_Site_Quality__c = maxSiteQuality;        
				property.Optimal_Site_Quality_kWh_y_kW__c = maxSiteQuality;
				if (property.Snow_De_Rate_kWh_y_kW__c != null) {
					property.Optimal_Site_Quality_kWh_y_kW__c = property.Optimal_Site_Quality_kWh_y_kW__c - property.Snow_De_Rate_kWh_y_kW__c;
				}
				update property;
			}
		
		}
		*/
		
		return controller.cancel();
	} 

}