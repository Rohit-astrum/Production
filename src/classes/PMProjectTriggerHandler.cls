/* FILE: PMProjectTriggerHandler.cls
 * AUTHOR: Lawrence Hovind
 * DATE: June 16, 2014
 * PURPOSE: Work Order Trigger Handler
 * MODIFICATION HISTORY
 *
 */
public class PMProjectTriggerHandler {

    private boolean m_isExecuting = false;

	public PMProjectTriggerHandler(boolean isExecuting) {
		m_isExecuting = isExecuting;
	}
	
    //SOA- PB 10/13/2015
    public void OnBeforeInsert(List<PM_Project__c> newPMProjects){
        // EXECUTE BEFORE INSERT LOGIC
        for(PM_Project__c proj:newPMProjects){
        	if(proj.Project_Lead__c != null){
        		proj.Project_Lead_Assignment_Date__c = Datetime.now();        		
        	}
        }
    }
	
    public void OnAfterUpdate(PM_Project__c[] updatedPMProjects, Map<Id,PM_Project__c> oldPMProjectMap){
        //  EXECUTE AFTER UPDATE LOGIC       

        //  LLH - additions
        //  *** if Install Date changes, change Work Order Due Date
        //  we'll collect a list of Work Order Ids and add those PM Projects to a Map
        List<Id> workOrderIds = new List<Id>();
        Map<Id, PM_Project__c> projects = new Map<Id, PM_Project__c>();

        for( PM_Project__c proj : updatedPMProjects ) {
        	if( (proj.Install__c != oldPMProjectMap.get(proj.Id).Install__c) && (proj.Work_Order__c != null) ) {
	        	// collect Work Order Ids only for Projects whose Installation Dates have changed
	        	workOrderIds.add( proj.Work_Order__c);
	        	// and add that Project to the Map
	        	projects.put( proj.Id, proj );
	        }
        }

		if( projects.size() > 0 ) {
	        if( workOrderIds.size() > 0 ) {
	        	// retrieve the Work Orders
	        	//System.debug('SOQL: PMProjectTrigger: OnAfterUpdate: get workOrders');
		        Map<Id, rstk__wocst__c> workOrders = new Map<Id, rstk__wocst__c>([SELECT Id, rstk__wocst_duedte__c, PM_Project__c FROM rstk__wocst__c WHERE Id IN :workOrderIds]);
		        //System.debug('SOQL: PMProjectTrigger: OnAfterUpdate: Limits: ' + Limits.getQueries());
		        // update Work Orders from those retrieved
		        System.debug('PMProjectTriggerHandler: Number of Work Orders to update: ' + workOrders.size());
		        if( workOrders.size() > 0 ) {
			        for( PM_Project__c proj : projects.values() ) {
			        	workOrders.get( proj.Work_Order__c ).rstk__wocst_duedte__c = proj.Install__c;
			        	//System.debug('PMProjectTriggerHandler: update Work Order: ' + workOrders.get(proj.Work_Order__c).Name + ' due date to ' + proj.Install__c);
			        }
			        List<rstk__wocst__c> workOrderList = workOrders.values();
					
					Database.saveResult[] dmlList = Database.update( workOrderList, false );
				
					// email errors
		        	// email it@astrumsolar.com
		        	String errmsg = '';
			        
					for (Database.SaveResult sr : dmlList) {
					    if (sr.isSuccess()) {
					        // Operation was successful, so get the ID of the record that was processed
					        //System.debug('Successfully inserted account. Account ID: ' + sr.getId());
					    }
					    else {
					        // Operation failed, so get all errors                
					        for(Database.Error err : sr.getErrors()) {
					            errmsg += 'Id:' + sr.getId() + ' : ' + err.getStatusCode() + ': ' + err.getMessage() + ' affected fields - ' + err.getFields() + '\n';
					            //System.debug('Account fields that affected this error: ' + err.getFields());
					        }
				            errmsg = 'PMProjectTriggerHandler Errors \n' + errmsg;
				            EmailUtil.AdminEmail('PM Project Trigger Handler', 'PM Project Trigger Handler error message', errmsg);
					    }
					}						
				}
			}
		}

		// *** if PM Project Name changes, change the Name of the related Install Project
		// also change the Project Master Name - per A Bramante 6/20/14

        // the ProjMstr2PMProj Map connects Project Master Ids to PM_Project Ids - used if PM_Project.Name is changed
        Map<Id, Id> ProjMstr2PMProj = new Map<Id, Id>();

		projects.clear();

        for( PM_Project__c proj : updatedPMProjects ) {
        	if( proj.Name != oldPMProjectMap.get(proj.Id).Name ) {
	        	// collect MAP of PM Projects only for Projects whose Names have changed
	        	// and add that Project to the Map
	        	projects.put( proj.Id, proj );
	        }
        }

        if( projects.size() > 0 ) {
			// get list of affected Install Projects    
			//System.debug('SOQL: PMProjectTrigger: OnAfterUpdate: get installProjects');
			List<Install_Project__c> installProjects = [SELECT Id, Name, PM_Project__c, Work_Order__r.rstk__wocst_proj__c FROM Install_Project__c WHERE PM_Project__c IN :projects.keySet()];
			//System.debug('SOQL: PMProjectTrigger: OnAfterUpdate: Limits: ' + Limits.getQueries());
			System.debug('PMProjectTriggerHandler: Number of Install Projects to update: ' + installProjects.size());
	        if( installProjects.size() > 0 ) {
		        // update Install Projects
			        for( Install_Project__c installproj : installProjects ) {
			        	installproj.Name = projects.get( installproj.PM_Project__c ).Name;
			        	// collect the Project Master Ids for a little later
			        	ProjMstr2PMProj.put( installproj.Work_Order__r.rstk__wocst_proj__c, installproj.PM_Project__c);
			        }
					
					Database.saveResult[] dmlList = Database.update( installProjects, false );
				
					// email errors
		        	// email it@astrumsolar.com
		        	String errmsg = '';
			        
					for (Database.SaveResult sr : dmlList) {
					    if (sr.isSuccess()) {
					        // Operation was successful, so get the ID of the record that was processed
					        //System.debug('Successfully inserted account. Account ID: ' + sr.getId());
					    }
					    else {
					        // Operation failed, so get all errors                
					        for(Database.Error err : sr.getErrors()) {
					            errmsg += 'Id:' + sr.getId() + ' : ' + err.getStatusCode() + ': ' + err.getMessage() + ' affected fields - ' + err.getFields() + '\n';
					            //System.debug('Account fields that affected this error: ' + err.getFields());
					        }
				            errmsg = 'PMProjectTriggerHandler Errors \n' + errmsg;
				            EmailUtil.AdminEmail('PM Project Trigger Handler', 'PM Project Trigger Handler error message', errmsg);
					    }
					}						
			}

			// get list of affected Project Masters
			//System.debug('SOQL: PMProjectTrigger: OnAfterUpdate: get Project Masters');
			List<rstk__pjproj__c> projectMasters = [SELECT Id, Name, rstk__pjproj_descr__c FROM rstk__pjproj__c WHERE Id IN :ProjMstr2PMProj.keySet()];
			//System.debug('SOQL: PMProjectTrigger: OnAfterUpdate: Limits: ' + Limits.getQueries());
			System.debug('PMProjectTriggerHandler: Number of Project Masters to update: ' + projectMasters.size());

	        if( projectMasters.size() > 0 ) {
		        // update Project Masters
			        for( rstk__pjproj__c projmaster : projectMasters ) {
			        	projmaster.rstk__pjproj_descr__c = projects.get( ProjMstr2PMProj.get(projmaster.Id) ).Name;
			        	//projmaster.Name = projects.get( projmaster.PM_Project__c ).Name;
			        	// *** projmaster.rstk__pjproj_descr__c = project.Name,
			        }
					
					Database.saveResult[] dmlList = Database.update( projectMasters, false );
				
					// email errors
		        	// email it@astrumsolar.com
		        	String errmsg = '';
			        
					for (Database.SaveResult sr : dmlList) {
					    if (sr.isSuccess()) {
					        // Operation was successful, so get the ID of the record that was processed
					        //System.debug('Successfully inserted account. Account ID: ' + sr.getId());
					    }
					    else {
					        // Operation failed, so get all errors                
					        for(Database.Error err : sr.getErrors()) {
					            errmsg += 'Id:' + sr.getId() + ' : ' + err.getStatusCode() + ': ' + err.getMessage() + ' affected fields - ' + err.getFields() + '\n';
					            //System.debug('Account fields that affected this error: ' + err.getFields());
					        }
				            errmsg = 'PMProjectTriggerHandler Errors \n' + errmsg;
				            EmailUtil.AdminEmail('PM Project Trigger Handler', 'PM Project Trigger Handler error message', errmsg);
					    }
					}						
			}

		}

        //  end - LLH

        //  LLH - additions 07/15/2014

        //  *** when the PM Project is completed, update the related Work Order Operations Run Std Hrs
        //  get the list of Work Order Ids for the PM Projects that completed - field Work_Completed__c changes
        workOrderIds.clear();
        for( PM_Project__c proj : updatedPMProjects ) {
        	if( (proj.Work_Completed__c != oldPMProjectMap.get(proj.Id).Work_Completed__c) && (proj.Work_Order__c != null) ) {
	        	// collect Work Order Ids only for Projects whose Work Completed Dates have changed
	        	workOrderIds.add( proj.Work_Order__c);
	        }
        }
        System.debug('PMProjectTriggerHandler: calling updateWOOpsFromInstallProjs with ' + workOrderIds.size() + ' Work Order Ids.');
    	RootstockAutomation.updateWOOpsFromInstallProjs(null, null, workOrderIds);
        //  end - LLH
    }
    
    /*
    public void OnAfterInsert(PM_Project__c[] newPMProjects){
        // EXECUTE AFTER INSERT LOGIC
    }*/
	
    //SOA -PB 10/13/2015
    public void OnBeforeUpdate(List<PM_Project__c> updatedPMProjects, Map<Id,PM_Project__c> oldPMProjectMap){
        // BEFORE UPDATE LOGIC
        for(PM_Project__c proj:updatedPMProjects){
        	if(proj.Project_Lead_Assignment_Date__c == null 
        		&& proj.Project_Lead__c != null){
        		proj.Project_Lead_Assignment_Date__c = Datetime.now();        		
        	}
        }
        /*FPO-121 PB 01/22/2016
        for(PM_Project__c proj:updatedPMProjects){
        	if((proj.Project_Lead__c != null) 
        		&& (proj.Project_Lead__c != oldPMProjectMap.get(proj.Id).Project_Lead__c)){
        		proj.Project_Lead_Assignment_Date__c = Datetime.now();        		
        	}
        }*/
    }
    
    /*
    public void OnBeforeDelete(PM_Project__c[] PMProjectsToDelete, Map<Id,PM_Project__c> oldPMProjectMap){
        // BEFORE DELETE LOGIC
    }

    public void OnAfterDelete(PM_Project__c[] deletedPMProjects, Map<Id,PM_Project__c> oldPMProjectMap){
        // AFTER DELETE LOGIC
    }

    public void OnUndelete(PM_Project__c[] restoredPMProjects){
        // AFTER UNDELETE LOGIC
    }
    */
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }

}