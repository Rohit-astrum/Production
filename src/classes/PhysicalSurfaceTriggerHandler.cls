/* FILE: PhysicalSurfaceTriggerHandler.cls
 * AUTHOR: Rohit Jain
 * DATE: Apr 24, 2014
 * PURPOSE: Physical SurfaceTrigger Handler
 * MODIFICATION HISTORY
 *
 */

public with sharing class PhysicalSurfaceTriggerHandler {
	private boolean m_isExecuting = false;
	
	public PhysicalSurfaceTriggerHandler(boolean isExecuting) {
		m_isExecuting = isExecuting;	
	}

	public void OnBeforeInsert(Physical_Surface__c[] newSurfaces){
        // EXECUTE BEFORE INSERT LOGIC
        defaultSurfaceName(newSurfaces);
        m_isExecuting = false;
    }

    public void OnAfterUpdate(Physical_Surface__c[] updatedSurfaces){
        // EXECUTE BEFORE INSERT LOGIC
        updateInstallLocations(updatedSurfaces);
        m_isExecuting = false;
    }

    public void OnAfterDelete(Physical_Surface__c[] deletedSurfaces, map<id, Physical_Surface__c> deletedSurfacesMap){
        // EXECUTE BEFORE INSERT LOGIC
        updateSystemDesignItems(deletedSurfaces);
        m_isExecuting = false;
    }

    private void updateInstallLocations(Physical_Surface__c[] updatedSurfaces)
    {
        //MK - 2014-05-01
        //After update - Need to update all SDI records.
        //Here we can simply update all child Install Location records and let that trigger fire.  The good thing here will be that if in the futre we add logic to
        //the Install Location trigger that pulls data from Physical Surface, it will automatically run as needed. 
        List<Install_Location__c> ilsToUpdate = [Select id from Install_Location__c where Physical_Surface__c in: updatedSurfaces];
        update(ilsToUpdate);
    }


    private void updateSystemDesignItems(Physical_Surface__c[] deletedSurfaces)
    {        
        //Here we need to go up the chain to grab the Property id if it exists. Then go back down the chain > SD > SDA > SDIs in order to update the 
        //SDIs so that the roll-up calculation is valid
        //Gather Prop IDs
        set<ID> propIDs = new set<ID>();
        for ( Physical_Surface__c rec : deletedSurfaces) {
            if(rec.Property__c != null) propIDs.add(rec.Property__c);
        }
        
        //Update SDIs       
        if(!propIDs.isEmpty()) PropertyCommonUtil.UpdateSDIsFromPropertyIDs(propIDs);
    }

    

    private void defaultSurfaceName(Physical_Surface__c[] newSurfaces)
    {
    	Set<Id> propertyIds = new Set<Id>();
        for(Physical_Surface__c surface : newSurfaces)
        {
            propertyIds.add(surface.Property__c);
        }       
        Map<Id,Property__c> propertiesMap;

        if(propertyIds.size() > 0)
        {
           propertiesMap = new Map<Id,Property__c> ([Select Id, Name,Property_Owner__r.Client_Last_Name__c 
                                                                                   from Property__c Where id in :propertyIds]);
        }

        for(Physical_Surface__c surface : newSurfaces)
    	{
    		if(propertiesMap.get(surface.Property__c) != null)
            {
                surface.Name = propertiesMap.get(surface.Property__c).Property_Owner__r.Client_Last_Name__c + ' - Surface '+ surface.Physical_Surface_Assigned_Letter__c;
            }
            else
            {
                surface.Name = 'Surface '+ surface.Physical_Surface_Assigned_Letter__c;    
            }   
    	} 

    }
}