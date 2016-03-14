/* FILE: InstallLocationTriggerHandler.cls
 * AUTHOR: Rohit Jain
 * DATE: Apr 24, 2014
 * PURPOSE: Install Location Trigger Handler
 * MODIFICATION HISTORY
 *
 */
public with sharing class InstallLocationTriggerHandler {
	private boolean m_isExecuting = false;
	public InstallLocationTriggerHandler(boolean isExecuting) {
		m_isExecuting = isExecuting;		
	}

	public void OnBeforeInsert(Install_Location__c[] newProperties){
        // EXECUTE BEFORE INSERT LOGIC
        defaultLocationName(newProperties);
        m_isExecuting = false;
    }

    public void OnBeforeUpdate(Install_Location__c[] newProperties){
        // EXECUTE BEFORE INSERT LOGIC
        defaultLocationName(newProperties);
        m_isExecuting = false;
    }

    public void OnAfterUpdate(Install_Location__c[] updatedLocations){
        //  EXECUTE AFTER UPDATE LOGIC       
        updateSystemDesignItems(updatedLocations);
        m_isExecuting = false;
    }

    public void OnAfterDelete(Install_Location__c[] deletedLocations, map<id, Install_Location__c> deletedLocationsMap){
    	//MK - 2014-04-30
        //  EXECUTE AFTER UPDATE LOGIC       
        updateSystemDesignItemsOnLocationDelete(deletedLocations);
        m_isExecuting = false;
    }

	private void updateSystemDesignItemsOnLocationDelete(Install_Location__c[] deletedLocations)
    {   
    	//MK - 2014-04-30 - merged trigger logic from pricing sandbox installlocationtrigger. 	
	    //Here we need to go up the chain to grab the Property id if it exists. Then go back down the chain > SD > SDA > SDIs in order to update the 
	    //SDIs so that the roll-up calculation is valid	    
    	//Gather Physical Surface IDs
    	set<ID> psIDs = new set<ID>();
		for ( Install_Location__c rec : deletedLocations) {
		    if(rec.Physical_Surface__c != null) psIDs.add(rec.Physical_Surface__c);
		}
    	
    	//Gather Prop IDs from the Physical Surface IDs
    	set<ID> propIDs = new set<ID>();
		for ( Physical_Surface__c rec : [select Property__c from Physical_Surface__c where id in : psIDs]) {
		    if(rec.Property__c != null) propIDs.add(rec.Property__c);
		}
		
		//Update SDIs from the Property IDs
		if(!propIDs.isEmpty()) PropertyCommonUtil.UpdateSDIsFromPropertyIDs(propIDs);
    }     

    private void updateSystemDesignItems(Install_Location__c[] updatedLocations)
    {
    	List<System_Design_Item__c> sdisToUpdate = [Select id from System_Design_Item__c where Install_Location__c in : updatedLocations];    
        update(sdisToUpdate);    	
    }

    private void defaultLocationName(Install_Location__c[] newLocations)
    {
    	Map<Id,Install_Location__c> surfaceLocationMap = new Map<Id,Install_Location__c>();
    	Set<Id> surveyIds = new Set<Id>();
    	for(Install_Location__c loc : newLocations)
    	{
    		surfaceLocationMap.put(loc.Physical_Surface__c,loc);
    		surveyIds.add(loc.survey__c);
    	}    	
        Map<Id,Physical_Surface__c> surfaces;

        if(surfaceLocationMap.size() > 0)
        {
    	   surfaces = new Map<Id,Physical_Surface__c> ([Select Id, Name,Property__r.Property_Owner__r.Client_Last_Name__c , Legacy__c
    																			   from Physical_Surface__c Where id in :surfaceLocationMap.keySet()]);
        }

    	Map<Id,Survey__c> surveys;

        if(surveyIds.size() > 0)
        {
            surveys = new Map<Id,Survey__c> ([Select Id, CreatedDate from Survey__c Where id in :surveyIds]);
        }
    	for(Install_Location__c loc : newLocations)
    	{
    		Boolean legacyFlag = false;

    		if(surfaces != null && surfaces.get(loc.Physical_Surface__c) != null)
    		{
    			Physical_Surface__c surface = surfaces.get(loc.Physical_Surface__c);    	
                legacyFlag = surface.Legacy__c;	
                if(!legacyFlag)	
                {
    			 loc.Name = surface.Name + ' - ';
                } 
    		}
            if(!legacyFlag) 
            {
        		loc.Name = loc.Name + 'Skyline '+loc.Location__c ;
        		if(surveys != null && surveys.get(loc.Survey__C) != null)
        		{
        			String surveyDate = surveys.get(loc.survey__c).CreatedDate.format('MM/dd/yyyy');
        			loc.Name = loc.Name + ' - ' + surveyDate;
        		}   
            } 		
    	} 

    }
}