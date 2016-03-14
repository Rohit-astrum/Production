/* FILE: PropertyCommonUtil.cls
	 * AUTHOR: Mike Katulka	
	 * DATE: March 17, 2014
	 * PURPOSE: Class meant for methods that can be used anywhere that relate to the Property object and child records.
	 * MODIFICATION HISTORY 
*/
public without sharing class PropertyCommonUtil {
	
	public static void UpdateSDIsFromPropertyIDs(set <id> propIDs){
		//Fetch array IDs linked to this property		
		if(!propIDs.isEmpty()){
			set<id> sdaIds = (new Map<Id,SObject>([select Id From System_Design__c where Property__c in:propIDs])).keySet();		
			
			//Fetch SDIs linked to these arrays and update them in order to initiate rollups
			if(sdaIDs != null && !sdaIDs.isEmpty()){
			  list<System_Design_Item__c> sdis = [Select id from System_Design_Item__c where System_Design_Array__c in : SDAIds];
			  if(sdis != null && !sdis.isEmpty()) update sdis;
			}
		}
	}

}