/* FILE: WorkOrderTriggerHandler.cls
 * AUTHOR: Lawrence Hovind
 * DATE: June 11, 2014
 * PURPOSE: Work Order Trigger Handler
 * MODIFICATION HISTORY
 * 07/18/2014   LLH -   moved 'CreateInstallProjects' code to Rootstock Automation
 * 03/17/2015   PB -   If running Test return before Insert Extract Operations to prevent exceeding limit for number of batch executions in Test
 * 09/21/2015   PB -   Make call to extract operations from future method 
 */
public class WorkOrderTriggerHandler {

    private boolean m_isExecuting = false;

	public WorkOrderTriggerHandler(boolean isExecuting) {
		m_isExecuting = isExecuting;
	}

    public void OnBeforeInsert(rstk__wocst__c[] newWorkOrders){
        
        // EXECUTE BEFORE INSERT LOGIC
        
        // LLH - additions
        List<Id> SOLineIds = new List<Id>();

        // collect all the SO_Line Ids of the new Work Orders
        for( rstk__wocst__c wo : newWorkOrders) {

        	//System.debug('BI WO_SO_Line Indicator: ' + wo.rstk__wocst_wosonumind__c);
        	//System.debug('BI Sales Order Line: ' + wo.rstk__wocst_soline__c);

        	if( wo.rstk__wocst_wosonumind__c && (wo.rstk__wocst_soline__c != null)) {
        		SOLineIds.add(wo.rstk__wocst_soline__c);
        	}
        }
        // retrieve SO Line objects referenced in newWorkOrders
        //System.debug('SOQL: WorkOrderTrigger: OnBeforeInsert: get SOLines');
        Map<Id, rstk__soline__c> SOLines = new Map<Id, rstk__soline__c>([SELECT Id, Sales_Order__c, PM_Project__c FROM rstk__soline__c WHERE Id IN :SOLineIds]);
        //System.debug('SOQL: WorkOrderTrigger: OnBeforeInsert: Limits: ' + Limits.getQueries());

        // update Sales Order and PM Project lookup fields
        for( rstk__wocst__c wo : newWorkOrders) {

        	if( wo.rstk__wocst_wosonumind__c && (wo.rstk__wocst_soline__c != null)) {
        		wo.Sales_Order__c = SOLines.get(wo.rstk__wocst_soline__c).Sales_Order__c;
        		wo.PM_Project__c = SOLines.get(wo.rstk__wocst_soline__c).PM_Project__c;
        	}
        }
        // end - LLH
    }
    /*
    public void OnAfterUpdate(rstk__wocst__c[] updatedWorkOrders, Map<Id,rstk__wocst__c> WorkOrderMap){
        //  EXECUTE AFTER UPDATE LOGIC       
    }
    */
    public void OnAfterInsert(rstk__wocst__c[] newWorkOrders){
        
        // EXECUTE AFTER INSERT LOGIC
    	// FYI - there is to be one Install Project per Work Order, per Anthony Bramante 6/1/2014
 
        // LLH - additions
        // Create one InstallProject per Work Order
        // for Work Orders with SO_Line link and SO_Line lookup

        List<Id> PM_ProjectIds = new List<Id>();
        List<Id> SalesOrderIds = new List<Id>();
        List<Id> WorkOrderIds = new List<Id>();
        RootstockAutomation ra = new RootstockAutomation();
        List<rstk__wocst__c> workOrdersForInstallProjects = new List<rstk__wocst__c>();
        List<rstk__sydata__c> extractOps = new List<rstk__sydata__c>();
        //PB 09/20/2015
        List<String> woIdStrs = new List<String>();

        // collect list of PM Project and Sales Order Ids for new Work Orders
        // and insert Extract Operations order
        for( rstk__wocst__c wo : newWorkOrders) {

            if( wo.rstk__wocst_wosonumind__c && (wo.rstk__wocst_soline__c != null) ) {

                workOrdersForInstallProjects.add(wo);
            	PM_ProjectIds.add( wo.PM_Project__c );
            	SalesOrderIds.add( wo.Sales_Order__c );
                WorkOrderIds.add( wo.Id );
                //Rootstock soql exception issue fix
                woIdStrs.add(wo.Id);

            	// create Extract Ops
            	extractOps.add( new rstk__sydata__c(
            						rstk__sydata_sourcepgm__c = 'WorkOrderTriggerHandler',
            						rstk__sydata_txntype__c = 'Extract Operations',
            						rstk__sydata_wocst__c = wo.Id
            						) );
            }

        }

        // create list of new Install Projects
		List<Install_Project__c> installProjects = ra.upsertInstallProjects( workOrdersForInstallProjects, WorkOrderIds, PM_ProjectIds, SalesOrderIds );
		
		// insert created Install Projects
		
			//System.debug('SOQL: WorkOrderTrigger: OnAfterInsert: insert InstallProjects');
		
					//Database.saveResult[] dmlList = Database.insert( installProjects, false );
                    Database.UpsertResult[] dmlList = Database.upsert( installProjects, false );
				
					// email errors
		        	// email it@astrumsolar.com
		        	String errmsg = '';
			        
					//for (Database.SaveResult sr : dmlList) {
                    for (Database.UpsertResult sr : dmlList) {
					    if (sr.isSuccess()) {
					        // Operation was successful, so get the ID of the record that was processed
					        //System.debug('Successfully inserted account. Account ID: ' + sr.getId());
					    }
					    else {
					        // Operation failed, so get all errors                
					        for(Database.Error err : sr.getErrors()) {
					            errmsg += 'Id:' + sr.getId() + ' : ' + err.getStatusCode() + ': ' + err.getMessage() + ' affected fields - ' + err.getFields() + '\n';
					            System.debug('WorkOrderTriggerHandler: upsert error: Account fields that affected this error: ' + err.getFields());
					        }
                            errmsg = 'WorkOrderTriggerHandler Errors \n' + errmsg;
                            EmailUtil.AdminEmail('Work Order Trigger Handler', 'Work Order Trigger Handler error message', errmsg);
					    }
					}						
			//System.debug('SOQL: WorkOrderTrigger: OnAfterInsert: Limits: ' + Limits.getQueries());
							

		// Perform Extract Operations for Work Orders
		// Extract Operations is a method available in the SYDATA object
					//If running test return at this point since we can't have more than 1 execute batch in Test
					//and inserting to Sys_data__c will trigger batch process.
					if(Test.isRunningTest()){return;}
					
			//PB 09/20/2015 Commenting old code , the call to extract operations will be made from future method instead
            /*
            //System.debug('SOQL: WorkOrderTrigger: OnAfterInsert: insert extractOps');
					Database.saveResult[] dmlList2 = Database.insert( extractOps, false );
				
					// email errors
		        	// email it@astrumsolar.com
		        	errmsg = '';
			        
					for (Database.SaveResult sr : dmlList2) {
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
                            errmsg = 'WorkOrderTriggerHandler Errors \n' + errmsg;
                            EmailUtil.AdminEmail('Work Order Trigger Handler', 'Work Order Trigger Handler error message', errmsg);
					    }
					}						
			//System.debug('SOQL: WorkOrderTrigger: OnAfterInsert: Limits: ' + Limits.getQueries());
            */
            if(woIdStrs.size()>0){
                extractOperations(woIdStrs);
            }
            


    }
    /*	
    public void OnBeforeUpdate(rstk__wocst__c[] oldObjects, rstk__wocst__c[] updatedObjects, Map<Id,rstk__wocst__c> oldMap){
        // BEFORE UPDATE LOGIC
    }
    */
    /*
    public void OnBeforeDelete(Object[] ObjectsToDelete, Map<Id,Lead> MapObjectMap){
        // BEFORE DELETE LOGIC
    }

    public void OnAfterDelete(Object[] deletedObjects, Map<Id,Lead> MapObjectMap){
        // AFTER DELETE LOGIC
    }

    public void OnUndelete(Object[] restoredObjects){
        // AFTER UNDELETE LOGIC
    }
    */
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }

    //PB 09/20/2015 Call extract operations from future method to avoid soql limit exceptions
    @future
    public static void extractOperations(List<String> woIdStrs){
        
        List<rstk__sydata__c> extractOps = new List<rstk__sydata__c>();

        for(String woidstr: woIdStrs){
            // create Extract Ops
                extractOps.add( new rstk__sydata__c(
                                    rstk__sydata_sourcepgm__c = 'WorkOrderTriggerHandler',
                                    rstk__sydata_txntype__c = 'Extract Operations',
                                    rstk__sydata_wocst__c = woidstr
                                    ) );

        }

        Database.saveResult[] dmlList2 = Database.insert( extractOps, false );
                
        // email errors
        // email it@astrumsolar.com
        String errmsg = '';
        
        for (Database.SaveResult sr : dmlList2) {
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
                errmsg = 'WorkOrderTriggerHandler Errors \n' + errmsg;
                EmailUtil.AdminEmail('Work Order Trigger Handler', 'Work Order Trigger Handler error message', errmsg);
            }
        }   
        

    }

}