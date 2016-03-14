/* FILE: WordOrderDetailController.cls
 * AUTHOR: Larry Hovind
 * DATE: Apr 18, 2014
 * PURPOSE: controller for WordOrderDetail visualforce page in PM_Project 2.0
 * MODIFICATION HISTORY
 * 		May 13th 2014 - LLH - modified fields used in WO Detail Section
 * 		May 20th 2014 - LLH - enabled Update functionality, commented out prototype code
 * 		July 10 2014 - LLH - change the workorder lookup from oldest to that references by PM_Project.Work_Order__c (primary)
 * 		July 31 2014 - LLH - removed 'with sharing' for class
 *		Aug 18 2015 -  PB  - FPO Phase III- CloseWO, regeneratePicklist, completeWO,delete operations
 *		Sept 25 2015 -  PB  - Restrict non rootstock users.
 */

global class WorkOrderDetailController
{
    // the standard controller
    private ApexPages.StandardController stdCtrl {get; set;}
    
    // the project being managed by the standard controller
    public PM_Project__c project {get; private set;}

    // the Work Order
    public rstk__wocst__c workorder {get; set;}
    
    // the System Design
    public System_Design__c sysdesign {get; set;}

	public List<String> lstBackflushes {get; set;}
	public List<String> lstProjHomes {get; set;}
	public String claimFor {get; set;}
	public String rstkURL { get{
		String url = System.URL.getSalesforceBaseUrl().getHost();
		if( url.startsWith('c.') ) {
			url = url.substring(2);
		}
		url = 'https://rstk.' + url;
		return url;
		}}
	public Map<String, Id> CommCodes { get; set;}
	private List<String> BOMstages { get; set; }
	public Boolean renderClaimBy {get; private set;}
	public Boolean woStatus2 {get; private set;}
	public Boolean woStatus5 {get; private set;}
	public Boolean woStatus8 {get; private set;}
	public Boolean woStatus9 {get; private set;}
	public Boolean opsExtracted {get; private set;}
	public Boolean opsExtracting {get; private set;}
	public Boolean opsDeleting {get; private set;}
	//public String myErrorMsg {get; set;}
	public Boolean hasComps {get; private set;}
	public Boolean projHasWorkOrder  {get; private set;}
	public WorkOrderDetailController(ApexPages.StandardController std) {UserInfo.getUserId();
		//PB 09/25/2015 If not a rootstock user return
		try{
			Id rstkuser = [SELECT Id FROM rstk__syusr__c WHERE rstk__syusr_employee__c=:UserInfo.getUserId()].Id;			
		}catch(QueryException qe){
			System.debug(loggingLevel.ERROR,'**insufficient privileges');
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'insufficient privileges'));
			return;
		}
		
		Schema.DescribeFieldResult BOM_Stages = rstk__wocst__c.BOM_Stage__c.getDescribe();
		List<Schema.PicklistEntry> plvs = BOM_Stages.getPicklistValues();
		BOMstages = new List<String>();
		for(  Schema.PicklistEntry entry : plvs ) {
			BOMstages.add( entry.value );
		}

		stdCtrl=std;
		if(!Test.isRunningTest()){
			std.addFields( new List<String>{'Work_Order__c', 'Electrical_Review__c', 'Permit_Design__c'} );
		}
		//std.addFields( new List<String>{'Electrical_Review__c'} );
		//std.addFields( new List<String>{'Permit_Design__c'} );
		project = (PM_Project__c) stdCtrl.getRecord();

		sysdesign = [SELECT Ground_Mount_Arrays__c, Number_of_Arrays_on_Flat_Roofs__c, Number_of_Arrays_With_Special_Parts__c,
						Max_Install_Location_Pitch__c, Max_Install_Location_Stories__c, System_Makeup__c, Trenching_Required__c,
						Trench_Length__c, Vent_Stack_Movement_Required__c, Includes_Outbuilding_Installation__c, Notes__c
						FROM System_Design__c
						WHERE Id=:project.Sales_Order__r.System_Design_Quote__r.System_Design__c];

		opsExtracting = false;
		opsDeleting = false;
		retrieveWorkOrder();
		if(workorder != null){
			projHasWorkOrder = true;
			System.debug(loggingLevel.ERROR,'**Project has work order');

		}else{
			projHasWorkOrder = false;
			System.debug(loggingLevel.ERROR,'**Project does not have work order');
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Work Order found. Please create a Work Order'));
			return;
		}

		CommCodes = new Map<String, Id>();
		for( rstk__iccomcod__c code : [SELECT id, Name, rstk__iccomcod_comcod__c FROM rstk__iccomcod__c WHERE rstk__iccomcod_div__c = :workorder.rstk__wocst_div__c]) {
			CommCodes.put( code.rstk__iccomcod_comcod__c, code.id );
		}

		//setClaimFor();

/*		*** no longer needed - used for prototype - save in case it is re-implemented
		if( lstBackflushes == null ) {
			lstBackflushes = new List<String>();
			Schema.DescribeFieldResult backflushesDesc = rstk__woorddmd__c.rstk__woorddmd_backflushpol_pl__c.getDescribe();
			List<Schema.PicklistEntry> backflushes = backflushesDesc.getPicklistValues();
			for( Schema.PicklistEntry backflush : backflushes ) {
				lstBackflushes.add('"' + backflush.value + '"');
			}
		}

		if( lstProjHomes == null ) {
			lstProjHomes = new List<String>();
			Schema.DescribeFieldResult projhomesDesc = rstk__woorddmd__c.rstk__woorddmd_homeprojind_pl__c.getDescribe();
			List<Schema.PicklistEntry> projhomes = projhomesDesc.getPicklistValues();
			for( Schema.PicklistEntry projhome : projhomes ) {
				lstProjHomes.add('"' + projhome.value + '"');
			}
		}
*/

	}

	private void retrieveWorkOrder() {

		if( project.Work_Order__c != null ) {
			workorder = [SELECT id, name, rstk__wocst_ordno__c, rstk__wocst_ordsts__c, rstk__wocst_ordsts_pl__c, rstk__wocst_proj__c,
							rstk__wocst_soline__c, rstk__wocst_soline__r.Id, rstk__wocst_soline__r.Name, BOM_Stage__c,
							 Field_Designer__c, Final_BOM_Complete__c, rstk__wocst_div__c ,Electrical_Reviewer__c
							 ,rstk__wocst_item__r.rstk__icitem_rcptlocid__c,rstk__wocst_item__r.rstk__icitem_div__c
							 ,rstk__wocst_item__r.rstk__icitem_iccomcod__r.rstk__iccomcod_rcptlocid__c
							FROM rstk__wocst__c
							WHERE Id = :project.Work_Order__c];
		} else {
			List<rstk__wocst__c> workorders = [SELECT id, name, rstk__wocst_ordno__c, rstk__wocst_ordsts__c, rstk__wocst_ordsts_pl__c, rstk__wocst_proj__c,
							rstk__wocst_soline__c, rstk__wocst_soline__r.Id, rstk__wocst_soline__r.Name, BOM_Stage__c,
							Field_Designer__c, Final_BOM_Complete__c, rstk__wocst_div__c,Electrical_Reviewer__c
							,rstk__wocst_item__r.rstk__icitem_rcptlocid__c,rstk__wocst_item__r.rstk__icitem_div__c
							,rstk__wocst_item__r.rstk__icitem_iccomcod__r.rstk__iccomcod_rcptlocid__c
							FROM rstk__wocst__c
							WHERE PM_Project__c = :project.Id];
			if( workorders.size() > 0 ) {
				workorder = workorders[0];
			} else {
				workorder = null;
				return;
			}
		}

		if( workorder.BOM_Stage__c == null ) {
			workorder.BOM_Stage__c = BOMstages[0];
		}

		// set flags for which Command Buttons should be visisble based on Work Order Status
		woStatus2 = (workorder.rstk__wocst_ordsts__c == '2') ? true : false;
		woStatus5 = (workorder.rstk__wocst_ordsts__c == '5') ? true : false;
		woStatus8 = (workorder.rstk__wocst_ordsts__c == '8') ? true : false;
		woStatus9 = (workorder.rstk__wocst_ordsts__c == '9') ? true : false;

		List<rstk__woordop__c> ops = [SELECT Id FROM rstk__woordop__c WHERE rstk__woordop_ordno__c = :workorder.Id];
		opsExtracted = (ops.size() > 0) ? ( opsDeleting ? false : true) : ( opsExtracting ? true : false);

		List<rstk__woorddmd__c> comps = [SELECT Id FROM rstk__woorddmd__c WHERE rstk__woorddmd_ordno__c=:workorder.Id];
		if(comps!=null &&comps.size()>0){
			hasComps = true;
		}else{
			hasComps = false;
		}
	}


	global PageReference noop() {
		return null;
	}

	global PageReference extractOperations() {

        List<rstk__sydata__c> extractOps = new List<rstk__sydata__c>();

    	extractOps.add( new rstk__sydata__c(
    						rstk__sydata_sourcepgm__c = 'WorkOrderDetailCtlr',
    						rstk__sydata_txntype__c = 'Extract Operations',
    						rstk__sydata_wocst__c = workorder.Id
    						) );

        insert extractOps;

        // there is no point to retriving the Work Order
        // the SYDATA object executes in batch and this page will return
        // before any of the requested changes are made
        // instead, we set an internal flag to indicate the result
        // and the page can be refreshed later to confirm
        opsExtracting = true;
        opsExtracted = true;

		return null;
	}

	global PageReference deleteOperations() {		

        List<rstk__woordop__c> ops = [SELECT Id FROM rstk__woordop__c WHERE rstk__woordop_ordno__c = :workorder.Id];
        if(ops!=null && ops.size()>0){
        	delete ops;
        }
		

		// re-retrieve PM_Project and Work Order
		project = (PM_Project__c) stdCtrl.getRecord();
		retrieveWorkOrder();

		return null;
	}

	global PageReference generatePicklist() {

        List<rstk__sydata__c> extractOps = new List<rstk__sydata__c>();

    	extractOps.add( new rstk__sydata__c(
    						rstk__sydata_sourcepgm__c = 'WorkOrderDetailCtlr',
    						rstk__sydata_txntype__c = 'Generate WO Picklist',
    						rstk__sydata_wocst__c = workorder.Id
    						) );

        insert extractOps;

        // again we have this problem that the SYDATA operations are run as batches.
        // but this time they actually change the Status of the Work Order
        // so I'm setting a page message to alert the user to refresh in the future
        // since this page will return before the changes have been applied
        // another option is to cause the page to gray out and reload after a specific time interval
        // by which the batch should have run
        
		// re-retrieve PM_Project and Work Order
		project = (PM_Project__c) stdCtrl.getRecord();
		retrieveWorkOrder();

		return null;
	}

	global PageReference reGeneratePicklist() {

        List<rstk__sydata__c> extractOps = new List<rstk__sydata__c>();

    	extractOps.add( new rstk__sydata__c(
    						rstk__sydata_sourcepgm__c = 'WorkOrderDetailCtlr',
    						rstk__sydata_txntype__c = 'Delete WO Picklist',
    						rstk__sydata_wocst__c = workorder.Id
    						) );

        insert extractOps;

        List<rstk__sydata__c> extractOps2 = new List<rstk__sydata__c>();

    	extractOps2.add( new rstk__sydata__c(
    						rstk__sydata_sourcepgm__c = 'WorkOrderDetailCtlr',
    						rstk__sydata_txntype__c = 'Generate WO Picklist',
    						rstk__sydata_wocst__c = workorder.Id
    						) );

        insert extractOps2;
        //locid: rstk__wocst_item__r.rstk__icitem_rcptlocid__c
        // again we have this problem that the SYDATA operations are run as batches.
        // but this time they actually change the Status of the Work Order
        // so I'm setting a page message to alert the user to refresh in the future
        // since this page will return before the changes have been applied
        // another option is to cause the page to gray out and reload after a specific time interval
        // by which the batch should have run
        
		// re-retrieve PM_Project and Work Order
		project = (PM_Project__c) stdCtrl.getRecord();
		retrieveWorkOrder();

		return null;
	}

	global PageReference completeWO() {

        List<rstk__sydata__c> extractOps = new List<rstk__sydata__c>();

        Id locId;
        if(String.isNotBlank(workorder.rstk__wocst_item__r.rstk__icitem_rcptlocid__c)){
        	locId = workorder.rstk__wocst_item__r.rstk__icitem_rcptlocid__c;

        }else{
        	locId = workorder.rstk__wocst_item__r.rstk__icitem_iccomcod__r.rstk__iccomcod_rcptlocid__c;
        }

    	extractOps.add( new rstk__sydata__c(
    						rstk__sydata_sourcepgm__c = 'WorkOrderDetailCtlr',
    						rstk__sydata_txntype__c = 'WO Receipt',
    						rstk__sydata_wocst__c = workorder.Id,
    						rstk__sydata_woordopn__c = null,
    						rstk__sydata_sylocid__c =  locId,
    						rstk__sydata_locnum__c = '1',
    						rstk__sydata_txnqty__c = 1,
    						rstk__sydata_lotno__c = 'null',
    						rstk__sydata_srlnos__c = 'null'

    						) );

        insert extractOps;

        // again we have this problem that the SYDATA operations are run as batches.
        // but this time they actually change the Status of the Work Order
        // so I'm setting a page message to alert the user to refresh in the future
        // since this page will return before the changes have been applied
        // another option is to cause the page to gray out and reload after a specific time interval
        // by which the batch should have run
        
		// re-retrieve PM_Project and Work Order
		project = (PM_Project__c) stdCtrl.getRecord();
		retrieveWorkOrder();

		return null;
	}

	global PageReference closeWO() {

        List<rstk__sydata__c> extractOps = new List<rstk__sydata__c>();

    	extractOps.add( new rstk__sydata__c(
    						rstk__sydata_sourcepgm__c = 'WorkOrderDetailCtlr',
    						rstk__sydata_process__c = 'Ready',
    						rstk__sydata_sydiv__c = workorder.rstk__wocst_item__r.rstk__icitem_div__c,
    						rstk__sydata_txntype__c = 'WO Close',
    						rstk__sydata_wocst__c = workorder.Id

    						) );

        insert extractOps;

        // again we have this problem that the SYDATA operations are run as batches.
        // but this time they actually change the Status of the Work Order
        // so I'm setting a page message to alert the user to refresh in the future
        // since this page will return before the changes have been applied
        // another option is to cause the page to gray out and reload after a specific time interval
        // by which the batch should have run
        
		// re-retrieve PM_Project and Work Order
		project = (PM_Project__c) stdCtrl.getRecord();
		retrieveWorkOrder();

		return null;
	}


	/*
	private void setClaimFor() {

		// set the 'Claim for' button value or hide altogether
		claimFor = '';
		if( workorder.Field_Designer__c == null ) {
			claimFor = 'Field';
		}
		
		if( workorder.Electrical_Reviewer__c == null ) {
			claimFor = 'Electrical';
		}
		if( claimFor.length() > 0 ) {
			renderClaimBy = true;
		} else {
			renderClaimBy = false;
		}
	}

	global PageReference processCompleteStage() {

		integer i;
		for( i=0; i<BOMstages.size(); i++ ) {
			if( BOMstages[i] == workorder.BOM_Stage__c ) {
				break;
			}
		}

		i++;
		if( i < BOMstages.size() ) {
			workorder.BOM_Stage__c = BOMstages[i];

			try {
				update workorder;
			}
			catch (DmlException e) {
				ApexPages.addMessages( e );
				//return null;
			}

			// re-retrieve PM_Project and Work Order
			project = (PM_Project__c) stdCtrl.getRecord();
			retrieveWorkOrder();
		}

		return null;
	}
*/


/* 	*** no longer needed - used for prototype - save in case it is re-implemented
	@RemoteAction
	global static List<rstk__woorddmd__c> getWorkOrderComponents( String WorkOrderId ) {
		List<rstk__woorddmd__c> wocomps = [SELECT id, rstk__woorddmd_compitem__r.name, rstk__woorddmd_desc__c,
												rstk__woorddmd_invuom__r.name, rstk__woorddmd_qtyper__c,
												rstk__woorddmd_qtyiss__c, rstk__woorddmd_qtyoutstdg__c,
												rstk__woorddmd_backflushpol_pl__c, rstk__woorddmd_homeprojind_pl__c
											FROM rstk__woorddmd__c
											WHERE rstk__woorddmd_ordno__c = :WorkOrderId];
		return wocomps;
	}

	@RemoteAction
	global static List<rstk__peitem__c> getItemMasters( String ItemName ) {
		//System.debug('GetItemMasters for: ' + ItemName);
		String sstr = '%' + ItemName + '%';
		System.debug('GetItemMasters for: ' + sstr);
		List<rstk__peitem__c> peitems = [SELECT name FROM rstk__peitem__c WHERE name LIKE :sstr LIMIT 25];
		System.debug(peitems);
		return peitems;
	}

	@RemoteAction
	global static List< Map<String, Object> > setWorkOrderComponentsFake( String ItemName ) {
		// get Item from ItemMasters
		List<rstk__peitem__c> peitems = [SELECT name, rstk__peitem_descr__c, rstk__peitem_enguom__r.name FROM rstk__peitem__c WHERE name LIKE :ItemName LIMIT 25];
		// new List
		List< Map<String, Object> > wocomps = new List< Map<String, Object> >();
		// new WO Comp
		Map<String, Object> wocomp = new Map<String, Object>();		
		// load WO Comp from ItemMaster
		wocomp.put('Id', 'xxx00000000yyyy');

		//wocomp.put('rstk__woorddmd_compitem__r', '{"Name":"' + peitems[0].name + '"}');
		Map<String, Object> compitem = new Map<String, Object>();
		compitem.put('Name', peitems[0].name);
		wocomp.put('rstk__woorddmd_compitem__r', compitem );

		wocomp.put('rstk__woorddmd_desc__c', peitems[0].rstk__peitem_descr__c);

		//wocomp.put('rstk__woorddmd_invuom__r', '{"Name":"' + peitems[0].rstk__peitem_enguom__r.Name + '"}');
		Map<String, Object> invuom = new Map<String, Object>();
		invuom.put('Name', peitems[0].rstk__peitem_enguom__r.Name);
		wocomp.put('rstk__woorddmd_invuom__r', invuom);

		wocomp.put('rstk__woorddmd_qtyper__c', '0');
		wocomp.put('rstk__woorddmd_qtyiss__c', '0');
		wocomp.put('rstk__woorddmd_qtyoutstdg__c', '0');
		wocomp.put('rstk__woorddmd_backflushpol_pl__c', 'No Backflushing');
		wocomp.put('rstk__woorddmd_homeprojind_pl__c', 'Project Home');
		// push WO Comp onto List
		wocomps.add( wocomp );
		// return WO Comp
		return wocomps;
	}
*/

/*
	global PageReference processClaimBy() {
		String UserId = UserInfo.getUserId();
		
		if( claimFor == 'Electrical' ) {
			workorder.Electrical_Reviewer__c = UserId;
		} else {
			workorder.Field_Designer__c = UserId;
		}

		try {
			update workorder;
		}
		catch (DmlException e) {
			ApexPages.addMessages( e );
		}

		setClaimFor();

		return null;
	}
*/

}