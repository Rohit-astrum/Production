trigger UpdateOppOnSDChange on System_Design__c (after update) {

	if(!TriggerUtility.isSystemDesignTriggerRunning)
	{
		TriggerUtility.isSystemDesignTriggerRunning = true;
		Map<Id, System_Design__c> sdNewMap = Trigger.newMap;
		List<Opportunity> oppsToUpdate = new List<Opportunity>([Select o.System_Design_Quote__r.System_Design__c, 
																   o.System_Design_Quote__c, 
																   o.Name, 
																   o.Id 
																From Opportunity o 
																Where o.System_Design_Quote__r.System_Design__c 
																IN :sdNewMap.keySet()]);
		
		update(oppsToUpdate);
		
		List<System_Design__c> sdUpdated = new List<System_Design__c>();

		for(System_Design__c sd : Trigger.New)
		{
			If(Trigger.newMap.get(sd.Id).Legacy_Astrum_site_Quality__c != Trigger.oldMap.get(sd.id).Legacy_Astrum_site_Quality__c)
			{
				sdUpdated.add(sd);
			}

		}
		if(sdUpdated.size() > 0)
		{
			List<System_Design_Item__c> sdis = [Select Legacy_Astrum_site_Quality__c ,System_Design_Array__r.System_Design__c From System_Design_Item__c 
												 Where RecordType.Name = 'Panel' AND System_Design_Array__r.System_Design__c in :sdUpdated ];

			for(System_Design_Item__c sdi : sdis)
			{
				sdi.Legacy_Astrum_site_Quality__c = Trigger.newMap.get(sdi.System_Design_Array__r.System_Design__c).Legacy_Astrum_site_Quality__c;
			}
			update sdis;
		}

		TriggerUtility.isSystemDesignTriggerRunning = false;
	}	
}