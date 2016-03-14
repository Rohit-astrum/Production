/* FILE: CreateRootstockExtension.cls
 * AUTHOR: Lawrence Hovind
 * DATE: June 10, 2014
 * PURPOSE: Creates Rootstock Objects from Astrum PM 2.0 Project
 * MODIFICATION HISTORY
 *	2014-10-07	-	LLH	-	modify 'createRootstockObjects' to use 'checkRootstockObjects' re-entrant, automatic process to avoid rstk SOQL limits
 * 01/15/2016 PB - FPO Sprint6- On Rootstock objects recreation transfer components and budget 
 */
public class CreateRootstockExtension {

    private PM_Project__c proj;

    public RootstockAutomation ra {get; private set;}
    public RootstockAutomation.RootstockObjects raobjs {get; private set;}
    public String statusMsg ='';
    public String ovrlyMsg {get; set;}
    public String btnsJSON {get; set;}
    //private Integer step = 0;
    public Integer step {get; set;}
    public Boolean autoprocess {get; set;}
    public Boolean reCreateActive {get; set;}
    public Boolean createMissingActive {get; set;}
    public Boolean reconnectActive {get; set;}
    public Boolean ignoreOldObjects {get; set;}

    // The extension constructor initializes the private member
    // variable proj by using the getRecord method from the standard
    // controller.
    public CreateRootstockExtension(ApexPages.StandardController stdController) {

        if( !Test.isRunningTest() ) {
            stdController.addFields( new List<String>{'Sales_Order__r.Job_Id__c', 'Sales_Order__r.Name',
                                                     'Sales_Order__r.Property__r.Astrum_Office_New__r.Rootstock_Division__c'} );
        }

        proj = (PM_Project__c)stdController.getRecord();

        ra = new RootstockAutomation();
        raobjs = new RootstockAutomation.RootstockObjects( proj );
        autoprocess = false;
        step = 0;
        reCreateActive = false;
        createMissingActive = false;
        reconnectActive = raobjs.RootstockObjectsNeedReconnection();
        ignoreOldObjects = false;System.debug(loggingLevel.ERROR,'*******Constructor IgnoreOldObjects is:' + ignoreOldObjects);
        ovrlyMsg = '';
        //btnsJSON = '[{"label": "Cancel", "value": "cancel","func": "HideLoading();" }]';
        btnsJSON = '';
    }

    public PageReference checkRootstockObjects() {

        //System.debug(loggingLevel.ERROR,'*******CheckRootstockObjects');        
        String result;

        if( autoprocess ) {

            if( step == 1 ) {
                //System.debug('About to create Rootstock Customer Master');
                ra.updateAccount(raobjs.project.Sales_Order__r.AccountId__c);
                raobjs.retrieveRootstockCustomer(proj);
                //System.debug('Returned from creating Rootstock Customer Master');
            }

            if( step == 2 ) {
                //System.debug('About to create Rootstock Sales Order');
                result = ra.processPMProject1( proj, raobjs);//result = ra.processPMProject1( proj);
                raobjs.retrieveRootstockObjects(proj);
                //System.debug('Returned from creating Rootstock Sales Order');
            }

            if( step == 3 ) {
                //System.debug('About to create Rootstock Sales Order');
                result = ra.processPMProject2( proj, raobjs);//result = ra.processPMProject2( proj );
                raobjs.retrieveRootstockObjects(proj);
                if(raobjs.transferComps){
                    if((raobjs.oldworkorder!= null) && (raobjs.oldwocomps!= null)){
                        ra.transterWorkOrderComps(raobjs);
                    }
                    
                    String sohdrId = null;
                    String pjprojId = null;
                    String workorderId = null;
                    
                    if(raobjs.oldworkorder!= null){
                        workorderId = raobjs.oldworkorder.Id;
                    }                    
                    if(raobjs.oldpjproj != null){
                        pjprojId = raobjs.oldpjproj.Id;                        
                    }
                    if(raobjs.oldsohdr != null){
                       sohdrId = raobjs.oldsohdr.Id; 
                    }

                    //delete old rstk objects
                    deleteRstkObjects(sohdrId, pjprojId,workorderId);
                                                          
                }
                //System.debug('Returned from creating Rootstock Sales Order');
            }

        }

        if( raobjs.RootstockObjectsExist() ) {

            if( !autoprocess ) {
                // entering page without autoprocess
                // display objects and warning
                //System.debug('CreateRootstockExtension: Rootstock Objects found.');
                //ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, 'A Rootstock Sales Order and Work Order already exist for this project.  Be sure you want to create another set of Rootstock records before clicking the button!') );
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, 'A Rootstock Sales Order and Work Order already exist for this project.') );
                return null;

            } else {
                // completing autoprocessing
                autoprocess = false;
                // redirect back to PM Project page
                PageReference returnpg = new PageReference('/apex/PMProjectDetailTab?id=' + proj.Id + '&tab=Detail');
                //ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, 'URL to redirect to: ' + returnpg.getUrl() ) );
                returnpg.setRedirect(true);
                return returnpg;
            }

        } else if( !ignoreOldObjects && raobjs.OldRootstockObjectsExist() ) {
                //FPO 6- Rtsk Duplication for Div change
                if(raobjs.oldWOHasIssuedParts){
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, 'Work Order has issued parts. Please reverse issue parts and try again.') );
                    return null;
                }
                if(raobjs.oldWOHasLbrBooked){
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, 'Labor is booked to the work order. Please unbook labor and try again.') );
                    return null;
                }
                if(raobjs.oldsohdrIsClosed){
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, 'Rootstock Sales Order is closed. Please reverse ship Sales Order.') );
                    return null;
                }
                if(raobjs.oldpjprojHasOpenPOs){
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, 'Project has open Purchase Order. Please close Purchase Order.') );
                    return null;
                }
                if(raobjs.oldpjprojHasAsscCst){
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, 'Costs are associated with this project. Please reverse incurred costs.') );
                    return null;
                }
                else{
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.WARNING, 'An Old Rootstock Sales Order and Work Order already exist for this project! But they are not for the correct Division.') );
                    reCreateActive = true;
                    //ovrlyMsg = 'WARNING: A Rootstock Sales Order and Work Order already exist for this project.<br/>But, they are not for the correct Division. If you are sure you want to create another set of Rootstock records please click OK. Otherwise, please click Cancel.';
                    ovrlyMsg = 'WARNING: A Rootstock Sales Order and Work Order already exist for this project. But, they are not for the correct Division.<br/>Be sure you want to create another set of Rootstock records before clicking the &quot;(Re)Create Rootstock Objects&quot; button!';
                    //btnsJSON = '[{"label": "OK", "value": "ok","func": "reCreateObjects();" }, {"label": "Cancel", "value": "cancel","func": "HideLoading();" }]';
                    btnsJSON = '[{"label": "OK", "value": "ok","func": "HideLoading();" }]';
                    return null;
                }              

        } else {
            //System.debug('CreateRootstockExtension: Rootstock Objects NOT found.');
            //System.debug('CreateRootstockExtension: Step: ' + step);
            //
            autoprocess = true; // this is a flag that triggers the browser to press the page buttons for us
            reCreateActive = false;

                if( !raobjs.RootstockCustomerExists() ) {

                    step = 1;
                    statusMsg = 'Creating Rootstock Customer Master';
                    ovrlyMsg = 'Creating Rootstock Customer Master';
                    btnsJSON = '';

                } else if( !raobjs.RootstockMastersExist() ) {

                    step = 2;
                    statusMsg = 'Creating Rootstock Product and Project Masters';
                    ovrlyMsg = 'Creating Rootstock Product and Project Masters';
                    btnsJSON = '';

                } else if( !raobjs.RootstockSalesOrderExist() ){

                    step = 3;
                    statusMsg = 'Creating Rootstock Sales Order and Work Order';
                    ovrlyMsg = 'Creating Rootstock Sales Order and Work Order';
                    btnsJSON = '';
                }

            //statusMsg = 'Problem creating Rootstock Objects';
            //return ApexPages.currentpage().setRedirect(true);
        }


        if( statusMsg.length() > 0 ) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, statusMsg) );
        }

        return null;
    }

    public PageReference createRootstockObjects() {

		// LLH - 10/7/14 - comment out, use checkRootstockObjects instead
		//					this gives us a single thread of logic
        /*
        String result = ra.processPMProject1( proj );

        if( (result == null ) || (result.length() == 0) ) {
            result = ra.processPMProject2( proj );
        }

        // process any errors
        if( (result != null) && (result.length() > 0) ) {
            ApexPages.Message msg;

            if( result.startsWith('ERROR') ) {
                msg = new ApexPages.Message(ApexPages.Severity.ERROR, result);
            } else {
                msg = new ApexPages.Message(ApexPages.Severity.INFO, result);
            }
            ApexPages.addMessage(msg);
        }
        
        //return null;
        return ApexPages.currentPage().setRedirect(true);
        */
        
        ignoreOldObjects = true;
		System.debug(loggingLevel.ERROR,'*******createRootstockObjects IgnoreOldObjects is:' + ignoreOldObjects);
		return checkRootstockObjects();
    }

    public PageReference connectLostRootstockObjects() {
        raobjs.reconnectObjects();

        return null;
    }

    public PageReference noop() {
        return null;
    }

    @future
    public static void deleteRstkObjects(String sohdrId,String pjprojId,String workorderId){
        System.debug('sohdr:' + sohdrId);
        System.debug('pjprojId:' + pjprojId);
        System.debug('workorderId:' + workorderId);

        if(workorderId != null){
            try{
                rstk__wocst__c wo = [SELECT Id,rstk__wocst_ordsts_pl__c FROM rstk__wocst__c WHERE Id =:workorderId];

                //if wo has picklist, delete picklist
                if(wo.rstk__wocst_ordsts_pl__c == '5-Pick List records generated'){
                    List<rstk__sydata__c> trans = new List<rstk__sydata__c>();

                    trans.add( new rstk__sydata__c(
                                rstk__sydata_sourcepgm__c = 'WorkOrderDetailCtlr2',
                                rstk__sydata_txntype__c = 'Delete WO Picklist',
                                rstk__sydata_wocst__c = wo.Id
                                ) );

                    insert trans;
                }

                //If wo has components , delete components
                try{
                    List<rstk__woorddmd__c> wocomps = [SELECT Id FROM rstk__woorddmd__c WHERE rstk__woorddmd_ordno__c =:workorderId];
                    delete wocomps;
                }catch(QueryException qe){
                    System.debug(loggingLevel.ERROR,'**No workorder components found');
                }
                
                //delete wo
                delete wo;

            }catch(QueryException qe){
                System.debug(loggingLevel.ERROR,'**No workorder found for Id:' + workorderId);
            }
                        
        }

        try{
            rstk__wocst__c wo = [SELECT Id FROM rstk__wocst__c WHERE Id =:workorderId];       

        }catch(QueryException qe){
            System.debug('Work Order deleted successfully' );
        }
        
        if(sohdrId != null){
            rstk__soapi__c soapi = new rstk__soapi__c();
            soapi.rstk__soapi_sohdr__c = sohdrId;
            soapi.rstk__soapi_mode__c = 'Delete Both';
            soapi.rstk__soapi_delalllines__c = true;
            insert soapi;            
        }

        try{
            rstk__sohdr__c salesorder = [SELECT Id FROM rstk__sohdr__c WHERE Id =:sohdrId];        

        }catch(QueryException qe){
            System.debug('Sales order deleted successfully' );
        }
        
        if(pjprojId != null){
            try{List<rstk__icixr__c> requirements = [select id from rstk__icixr__c where rstk__icixr_proj__c=:pjprojId];
                if(requirements!= null && requirements.size()>0){
                    delete requirements;            
                }
                rstk__pjproj__c pjproj = [SELECT Id FROM rstk__pjproj__c WHERE Id =:pjprojId];
                delete pjproj; 
                
            }catch(QueryException qe){
                System.debug(loggingLevel.ERROR,'**No pjproj found for Id:' + pjprojId);
            }                        
        }

        try{
            rstk__pjproj__c pjproj = [SELECT Id FROM rstk__pjproj__c WHERE Id =:pjprojId];    

        }catch(QueryException qe){
            System.debug('Proj Master deleted successfully' );
        }        
    }    
}