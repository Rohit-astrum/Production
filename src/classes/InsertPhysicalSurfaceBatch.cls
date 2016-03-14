//Created by MK 2014-04-01 - temporarily used to create physical surfaces, when done this can be deleted.
/*
	//run this a couple times to clear in sandboxes
	list<Physical_Surface__c> tl = [Select Id from Physical_Surface__c where Physical_Surface_Assigned_Letter__c in ('-', '*', '', null) limit 9000];
	triggerUtility.bypassPhysicalSurfaceTriggersForBatchProcessing = true;
    triggerUtility.bypassInstallLocationTriggersForBatchProcessing = true;	
    triggerUtility.bypassSystemDesignArrayTriggersForBatchProcessing = true;
	delete tl;
	id batchinstanceid = Database.executeBatch(new InsertPhysicalSurfaceBatch(), 50); //true disables triggers.  



================================

This is a block of cleanup code to run in execute anonymous after the batch finishes.  For some reason there could be failures, so use this to cleanup so you can create the master-detail:


		triggerUtility.bypassPhysicalSurfaceTriggersForBatchProcessing = true;
        triggerUtility.bypassInstallLocationTriggersForBatchProcessing = true;	
        triggerUtility.bypassSystemDesignArrayTriggersForBatchProcessing = true;

		set<id> propids = new set<id>();
		for(Install_Location__c is : [select Property__c from install_location__c where physical_surface__c = null]){
			propids.add(is.Property__c);
		}

   		List<Property__c> proplist = [Select Id, Property_Owner__r.Client_Last_Name__c, (select id from Install_Locations__r) from Property__c where id in : propids];   		
   		List<Physical_Surface__C> pslist = new List<Physical_Surface__C>();
		
		for(Property__c prop :  proplist)
		{
			//Let's only create physical surfaces for properties with install locations
			if(prop.Install_Locations__r.size() > 0){
		        Physical_Surface__c ps = new Physical_Surface__c();

		        if(prop.Property_Owner__c != null){
						ps.Name = prop.Property_Owner__r.Client_Last_Name__c + ' - Legacy Surface';
		        }else{
		        		ps.Name = 'Client Name - Legacy Surface';
		        }
		        ps.Property__c = prop.Id; 
				ps.Physical_Surface_Assigned_Letter__c = ''; 
				ps.Legacy__c = true;
				ps.Description__c = 'Legacy Surface';
				pslist.add(ps);
			}
		} 
		insert pslist;

		Map<Id,ID> propidPSid = new Map<Id,Id>(); 
		for(Physical_Surface__c ps :  pslist)
		{
		           propidPSid.put(ps.Property__C,ps.Id); 
		}

		List<Install_Location__C> insList = [Select Id, Property__c
											from Install_Location__c where Physical_Surface__c = null and Property__c in : propidPSid.keyset()];
		for(Install_Location__c inst : insList)
		{
		            inst.Physical_Surface__c = propidPSid.get(inst.Property__c);
		            inst.Location__c = 'S0#'; 
		}
		update insList;



		List<System_Design_Array__c> sdaList = [Select Id, System_Design__r.Property__c
											from System_Design_Array__c where Physical_Surface__c = null and System_Design__r.Property__c in : propidPSid.keyset()];
		for(System_Design_Array__c sda : sdaList)
		{
		            sda.Physical_Surface__c = propidPSid.get(sda.System_Design__r.Property__c);
		}
		update sdaList;




*/
global class InsertPhysicalSurfaceBatch implements Database.Batchable<sObject> {

	global Database.QueryLocator start(Database.BatchableContext BC) {return Database.getQueryLocator('Select Id, Property_Owner__r.Client_Last_Name__c, (select id from Install_Locations__r) from Property__c');}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
        /*



		MK - Saving code lines, we don't need this anymore but it's good to have for reference




        //No unit test for this because it's only meant for updating legacy data and as soon as that's done, this class would become invalid
        //Combining lines for line coverage
		triggerUtility.bypassPhysicalSurfaceTriggersForBatchProcessing = true; triggerUtility.bypassInstallLocationTriggersForBatchProcessing = true; triggerUtility.bypassSystemDesignArrayTriggersForBatchProcessing = true;

   		List<Property__c> proplist = (List<Property__c>)scope; List<Physical_Surface__C> pslist = new List<Physical_Surface__C>();
		
		for(Property__c prop :  proplist)
		{
			//Let's only create physical surfaces for properties with install locations
			if(prop.Install_Locations__r.size() > 0){
		        Physical_Surface__c ps = new Physical_Surface__c();
		        if(prop.Property_Owner__c != null) ps.Name = prop.Property_Owner__r.Client_Last_Name__c + ' - Legacy Surface';
		        else ps.Name = 'Client Name - Legacy Surface';
		        ps.Property__c = prop.Id; ps.Physical_Surface_Assigned_Letter__c = ''; 	ps.Legacy__c = true; ps.Description__c = 'Legacy Surface';	pslist.add(ps);
			}
		} 
		insert pslist;

		Map<Id,ID> propidPSid = new Map<Id,Id>(); 
		for(Physical_Surface__c ps :  pslist){ propidPSid.put(ps.Property__C,ps.Id); }

		List<Install_Location__C> insList = [Select Id, Property__c
											from Install_Location__c where Physical_Surface__c = null and Property__c in : propidPSid.keyset()];
		for(Install_Location__c inst : insList){ inst.Physical_Surface__c = propidPSid.get(inst.Property__c); inst.Location__c = 'S0#'; }
		update insList;



		List<System_Design_Array__c> sdaList = [Select Id, System_Design__r.Property__c
											from System_Design_Array__c where Physical_Surface__c = null and System_Design__r.Property__c in : propidPSid.keyset()];
		for(System_Design_Array__c sda : sdaList){sda.Physical_Surface__c = propidPSid.get(sda.System_Design__r.Property__c);}
		update sdaList;
		*/
	
	}
	
	global void finish(Database.BatchableContext BC) { }
	
}