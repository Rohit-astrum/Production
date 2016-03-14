/* FILE: SystemDesignEditControllerExtension.cls
 * AUTHOR: Michael Katulka
 * DATE: 2014-04-21
 * PURPOSE: Controller for the system design creation page.
 * MODIFICATION HISTORY:   
 *          //MK - 2014-06-26 - Clearing out the trench length if user unchecks the checkbox.
 *    RJ  08/09/14  Commented the Trench Part
 *    DK  11/25/14  Updated Utility Rate Code and Utility Company logic
 *    DK  12/08/14  Added SketchUp file upload support. See uploadImg().
 *    RJ            Adding Logic to Fire Validation Rules while making changes from Input Page
 *    PB  12/09/14  SALES-60 When making Global panel change to a design, also update SDP's on SDI's that have a zero count of panels on there
 *    DK            Added "Active__c = true" criterion to panel, inverter, and special part queries
 *    RJ  05/21/15  Added Utility Pricing Call after Save from Input Page
 *    PB  06/02/15  CPQ-269 Filter SDW Mounting, Trenching, Special Parts by Active
 *    DK  06/10/15  Recalculate Site Quality if the user assigns a new Inverter. See runSiteQuality(). Completed for JIRA ticket CPQ-406.
 *    PB  06/30/15  CPQ-588 Display Special Parts with Quantity of 0
 *    RJ  01/14/2016 MIS-201
 */
public with sharing class SystemDesignEditControllerExtension { 


    //PRIVATE
    private decimal originalSnowDerate;
    private System_Design__c sysDesign;        
    private ApexPages.StandardController controller;
    private map<id, System_Design_Array__c> sdaMap;
    private list<Install_Location__c> ils;
    private set<string> westCoastStates = new set<string>{'CA', 'AZ'};
    private set<string> setSolarEdge = new set<string>{'NEEDHAM, MA', 'ANDOVER, MA', 'LEXINGTON, MA', 'BEDFORD, MA', 'NEWTOWN, CT', 'GLASTONBURY, CT', 'SOUTH ORANGE, NJ', 'MAPLEWOOD, NJ'};
    private List<Utility_Service__c> utsList;
    private Map<ID, System_Design_Product__c> mountings = new Map<ID, System_Design_Product__c>();
    private ID originalInverter;    //DK: Added for CPQ-406
    
    //PUBLIC
    public id selectedSurveyID{get;set;}
    public Property__c prop{get;set;}
    public boolean hideForm         { get{ if(hideForm == null){hideForm = false;} return hideForm; } set; }
    public boolean isSdInsert       { get{ if(isSdInsert == null){isSdInsert = false;} return isSdInsert; } set; }
    public boolean isArrayEditMode  { get{ if(isArrayEditMode == null){isArrayEditMode = false;} return isArrayEditMode; } set; }
    public boolean isNewArrayConfig { get{ if(isNewArrayConfig == null){isNewArrayConfig = false;} return isNewArrayConfig; } set; }    
    public boolean isWestCoast      { get{ if(isWestCoast == null){isWestCoast = false;} return isWestCoast; } set; }    
    public string activePSid {get; set;}
    public integer panelQty {get; set;}    
    public decimal blendedTSRF {get; set;}
    public List<System_Design_Item__c> specialParts {get;set;}
    public List<System_Design_Item__c> deleteSpecialParts;
    public Integer rowNum{get;set;}
    public ID utilRateCode {get; set;}    //Selected by picklist
    public String imgURL { get; set; }    //For SketchUp file upload
    public map<string, id> rTypesMap;
    public map<id, System_Design_Product__c> spProducts = new Map<id, System_Design_Product__c>();

    //fields for creating cb panel and utility service
    public List<selectOption> cbPanels{get; set;}
    public string countofOpenCircuits{get;set;}    
    public id utilityService{get;set;}
    
    //Added by RJ
    private String sdqid;

    public Boolean fromFactsheet {get{ if(fromFactsheet == null){fromFactsheet = false;} return fromFactsheet; } set;}

    public string busRatingAmps{
        get{
            if(busRatingAmps == null || busRatingAmps == ''){
                //East coast defaults to 200, for view, but does not get stored to the db.
                if(!isWestCoast) busRatingAmps = '200';
            } 
            return busRatingAmps;
        }set;
    }

    public string mainBreakerRatingAmps{
        get{
            if(mainBreakerRatingAmps == null || mainBreakerRatingAmps == ''){
                //East coast defaults to 200, for view, but does not get stored to the db.
                if(!isWestCoast) mainBreakerRatingAmps = '200';
            } 
            return mainBreakerRatingAmps;
        }set;
    }    

    public string serviceEntryType{
        get{
            if(serviceEntryType == null || serviceEntryType == ''){
                //East coast defaults to TBD, west coast must fill it in.
                if(!isWestCoast) serviceEntryType = 'TBD';
            } 
            return serviceEntryType;
        }set;
    }

    public string meterid{
        get{
            if(meterid == null || meterid == ''){
                //East coast defaults to TBD, west coast must fill it in.
                if(!isWestCoast) meterid = '0';
            } 
            return meterid;
        }set;
    }
    
    public list<cSurface> cSurfaceList {
        get{
            system.debug('***cSurfaceList getter');
            if(cSurfaceList == null){
                cSurfaceList = new list<cSurface>();
                if(sysDesign.Property__c == null) return cSurfaceList; //for some reason there is no associated property.. this could be on insert of sysdesign.  havent tested yet.

                //Loop through all physical surfaces
                for(Physical_Surface__c ps: [SELECT id, Number_of_Stories__c, Outbuilding__c, Physical_Surface_Assigned_Letter__c, Name, Property__c, 
                                                    Structural_Members__c, Suneye_Tilt_and_Orien_Factor__c, Surface_Azimuth__c, Surface_Tilt__c, 
                                                    Surface_Type__c, Default_Mounting__c , Description__c,Trenching_Dist_to_Intercon_Pt_ft__c
                                            FROM Physical_Surface__c 
                                            WHERE Property__c =: sysDesign.Property__c
                                            AND Legacy__c = false
                                            ORDER BY Physical_Surface_Assigned_Letter__c]){
                    //call constructor for cSurface and add it to cSurfaceList
                    cSurfaceList.add(new cSurface(sysDesign, ps, (isNewArrayConfig ? 'New' : (isArrayEditMode ? 'Edit' : 'View')), sdaMap, ils));
                }                    
                calculateStats();
            }
            return cSurfaceList;
        }set;
    }
    
    //builds a picklist of utilityServices
    public List<selectOption> utilityServices{
        get{
            if(utilityServices == null){
                utilityServices = new List<selectOption>(); 
                //new list for holding all of the picklist utilityServices
                utilityServices.add(new selectOption('', 'Create a new Utility Service'));
                //add the first option of '- None -' in case the user doesn't want to select a value or in case no values are returned from query below
                for (Utility_Service__c us : utsList) {
                    utilityServices.add(new selectOption(us.id, us.Name));
                    if(utilityService == null){
                        utilityService = us.id; //set this to the first option
                    }
                }
            }
            return utilityServices; //return the picklist options
        }set;        
    }

    //builds a picklist of panels
    public List<selectOption> getpanels() {
        List<selectOption> options = new List<selectOption>(); 
        //new list for holding all of the picklist options
        options.add(new selectOption('', '- None -')); 
        //add the first option of '- None -' in case the user doesn't want to select a value or in case no values are returned from query below
        
        //SO Approval Process changes - Include Legacy Panels in filter condition - PB 10/05/2015
        /*
        for (System_Design_Product__c product : [SELECT Description__c FROM System_Design_Product__c WHERE RecordType.DeveloperName = 'Panel' AND Active__c = true ORDER BY Description__c]) {             
            options.add(new selectOption(product.id, product.Description__c));         
        }*/
        String queryStr = 'SELECT Description__c FROM System_Design_Product__c WHERE RecordType.DeveloperName = \'Panel\' AND Active__c = true ORDER BY Description__c';
        if(sysDesign.Include_Legacy_Panels__c){
            queryStr = 'SELECT Description__c FROM System_Design_Product__c WHERE RecordType.DeveloperName = \'Panel\' AND (Active__c = true OR Legacy__c = true) ORDER BY Description__c';
        }
        for(System_Design_Product__c product : Database.query(queryStr)) {
            options.add(new selectOption(product.id, product.Description__c));
        }
        return options; //return the picklist options
    }

    //builds a picklist of inverters
    public List<selectOption> getinverters() {
        List<selectOption> options = new List<selectOption>(); 
        //new list for holding all of the inverter options
        options.add(new selectOption('', '- None -')); 
        //add the first option of '- None -' in case the user doesn't want to select a value or in case no values are returned from query below
        for (System_Design_Product__c product : [SELECT Inverter_Product_Name__c FROM System_Design_Product__c 
                                                 WHERE RecordType.DeveloperName = 'Inverter' AND Inverter_Product_Name__c != null AND Active__c = true 
                                                 ORDER BY Inverter_Product_Name__c]) {             
            options.add(new selectOption(product.id, product.Inverter_Product_Name__c));         
        }
        return options; //return the picklist options
    }

    //builds a picklist of trech items
    //PB 06/02/2015 - CPQ-269 Filter SDW Mounting, Trenching, Special Parts by Active
    public List<selectOption> getTrenchItems() {
        List<selectOption> options = new List<selectOption>(); 
        //new list for holding all of the inverter options
        options.add(new selectOption('', '- None -')); 
        //add the first option of '- None -' in case the user doesn't want to select a value or in case no values are returned from query below
        for (System_Design_Product__c product : [SELECT Description__c FROM System_Design_Product__c
                                                WHERE RecordType.DeveloperName = 'Trenching' AND Description__c != null AND Active__c = true
                                                ORDER BY Description__c]) {             
            options.add(new selectOption(product.id, product.Description__c));         
        }
        return options; //return the picklist options
    }

    //builds a picklist of mounting
    //PB 06/02/2015 - CPQ-269 Filter SDW Mounting, Trenching, Special Parts by Active
    public List<selectOption> getMountingItems() {
        List<selectOption> options = new List<selectOption>(); 
        //new list for holding all of the inverter options
        options.add(new selectOption('', '- None -')); 
        //add the first option of '- None -' in case the user doesn't want to select a value or in case no values are returned from query below
        for (System_Design_Product__c product : [SELECT Description__c FROM System_Design_Product__c
                                                WHERE RecordType.DeveloperName = 'Mounting' AND Description__c != null AND Active__c = true
                                                ORDER BY Description__c]) {             
            options.add(new selectOption(product.id, product.Description__c));
            mountings.put(product.ID, product);         
        }
        return options; //return the picklist options
    }

    //builds a picklist of special Parts
    //PB 06/02/2015 - CPQ-269 Filter SDW Mounting, Trenching, Special Parts by Active
    public List<selectOption> getSpecialPartItems() {
        List<selectOption> options = new List<selectOption>(); 
        //new list for holding all of the inverter options
        options.add(new selectOption('', '- None -')); 
        //add the first option of '- None -' in case the user doesn't want to select a value or in case no values are returned from query below
        for (System_Design_Product__c product : [SELECT Description__c FROM System_Design_Product__c
                                                WHERE RecordType.DeveloperName = 'Special_Part' AND Description__c != null AND Active__c = true 
                                                ORDER BY Description__c]) {             
            options.add(new selectOption(product.id, product.Description__c));  
            spProducts.put(product.id,product);       
        }
        return options; //return the picklist options
    }

    //builds a picklist of surveys
    public List<selectOption> surveys{
        get{
            if(surveys != null) return surveys; //For speed since each physical surface will be showing this list
            //Initiate the list of Surveys
            
            surveys = new List<selectOption>(); 
            //new list for holding all of the inverter options
            surveys.add(new selectOption('', '- None -')); 
            
            //add the first option of '- None -' in case the user doesn't want to select a value or in case no values are returned from query below
            for (Survey__c survey : [SELECT Name, RecordType.Name FROM Survey__c
                                    WHERE Property__c =: sysDesign.Property__c
                                    AND RecordType.DeveloperName in ('Aerial_Photo_Survey', 'Field_Survey')
                                    ORDER BY createddate desc]) {             
                surveys.add(new selectOption(survey.id, survey.Name + ' (' + survey.RecordType.Name + ')'));         
                system.debug('***survey.id: ' + survey.id);
            } 
            return surveys; //return the picklist options
        }set;            
    }

    //============================
    //CONSTRUCTOR
    public SystemDesignEditControllerExtension(ApexPages.StandardController stdController) {

        //Get recordtype ids
        list<RecordType> rTypes = [SELECT DeveloperName FROM RecordType where isActive = true and SobjectType = 'System_Design_Item__c'];
        rTypesMap = new map<string, id>();
        for(RecordType rType : rTypes){
            rTypesMap.put(rType.DeveloperName, rType.id);
        }

        system.debug('***Controller constructor');
        this.sysDesign = (System_Design__c)stdController.getRecord();
        controller = stdController;

        sdqid = ApexPages.currentPage().getparameters().get('sdqid');

        

        fromFactsheet = ApexPages.currentPage().getparameters().get('fromFactsheet') == 'true' ? true : false;

        
        //Initialize imgURL
        if(imgURL == null){
            imgURL = '';
        }

        system.debug('***sysDesign.id: ' + sysDesign.id);
        system.debug('***sysDesign.Survey__c: ' + sysDesign.Survey__c);
        if(sysDesign.Survey__c != null){
                selectedSurveyID = sysDesign.Survey__c;
        }
        specialParts = new List<System_Design_Item__c>();
        deleteSpecialParts = new List<System_Design_Item__c>();
        if(sysDesign.id == null){
            isSdInsert = true; 
            //Need to find out where this page was initiated from
            //Is this from the Survey page?
            system.debug('***sysDesign.Survey__c: ' + sysDesign.Survey__c);
            if(selectedSurveyID != null){                
                system.debug('***From Survey');
                //This was a new system design from a survey, need to backfill the property ID
                list<Survey__c> tempSurveys = [select Property__c from Survey__c where id =: selectedSurveyID];
                if(tempSurveys.isEmpty() || tempSurveys[0].Property__c == null){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to find Survey or Property in the database.'));
                    hideForm = true;
                    return;
                }else{                    
                    sysDesign.Property__c = tempSurveys[0].Property__c;
                }
                
            }else{
                system.debug('***From Property');
                //Else, this had to be from the property page itself
                if(sysDesign.Property__c == null){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Missing Property ID, unable to load this page.'));
                    hideForm = true;
                    return;
                }
            }
        }
        else
        {
            try {
                specialParts = [Select system_design_product__r.description__c,Quantity__c,System_Design_Array__c From System_Design_Item__c 
                                Where System_Design_Array__r.System_Design__c = :sysDesign.id AND System_Design_Product__r.Active__c = true 
                                AND RecordType.DeveloperName = 'Special_Part' ];
                                //cpq-588
                                //AND RecordType.DeveloperName = 'Special_Part' and Quantity__c > 0];
            }
            catch(Exception e) {
                System.debug('No Special Parts Found');
            }
        }
    }


    public void addSpecialPart() {    
        
        System_Design_Item__c item = new System_Design_Item__c(); 
        //item.SP_System_Design__c = sysDesign.id;
        item.recordtypeId = rTypesMap.get('Special_Part');
        integer num = specialParts.size() + 1;
        item.Name = 'Special Part '+num;
        specialParts.add(item);           
    }

    public void deleteSpecialPart()
    {
        rowNum = Integer.valueOf(apexpages.currentpage().getparameters().get('index'));
        if(specialParts[rowNum].Id != null && deleteSpecialParts != null)
        {
            deleteSpecialParts.add(specialParts[rowNum]);
        }        
        specialParts.remove(rowNum);          
    }    


    //ARRAY MODE INIT
    public pageReference initArrayEditMode(){
        system.debug('***initArrayEditMode');
        if(sysDesign.id == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot load this edit page without providing an existing System Design.'));
            return null;
        }
        isArrayEditMode = true;
        
        //Set east/west coast var
        if(sysDesign.Property__r.Property_State__c != null && westCoastStates.contains(sysDesign.Property__r.Property_State__c.toUpperCase())) isWestCoast = true;

        //Get list of system design arrays
        sdaMap = new map<id, System_Design_Array__c>([SELECT id, Array_Size_kW__c, Panel_Count__c, Physical_Surface__c, 
                                                            Default_Mounting_Type__r.Description__c, Special_Parts_Required__c, Survey__c, Trench_Type__r.Description__c,
                                                            System_Design__c, Name, Utility_Service__c, Electrical_Adder__c,
                                                            Original_Surface_Tilt__c, Original_Surface_Azimuth__c, Mounting_Type__c, 
                                                            (select id, System_Design_Array__c, Quantity__c, 
                                                                    Install_Location__c, RecordType.DeveloperName,Total_Trenching_Lengthft__c                                                                    
                                                            from System_Design_Items__r 
                                                            where RecordType.DeveloperName in ('Panel', 'Inverter','Trenching','Mounting'))
                                                        FROM System_Design_Array__c
                                                        WHERE System_Design__c =: sysDesign.id]);
        system.debug('***sdaMap size: ' + sdaMap.size());
        if(sdaMap.size() == 0) isNewArrayConfig = true;
        else{
            //Tell user that they cannot edit an existing system design
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Editing existing System Design Arrays and Items through this page is disabled.  Please edit the Arrays and Items from the related list of the System Design page manually.'));
            //hideForm = true;
            //return null;

            //INFO FOR USER
            if(!fromFactsheet)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Reminder: Editing existing System Design Arrays will overwrite the Arrays and Items.'));
            }
        }

        //Get list of all install locations for this property
        ils = [SELECT id, Annual_Solar_Access__c, Name, 
                        Physical_Surface__c, Physical_Surface_Assigned_Letter__c, Physical_Surface__r.Surface_Type__c, 
                        Survey__c, TSRF__c, Verified_Single_SunEye_Data__c, Location__c, Tree_Removal__c
                FROM Install_Location__c
                WHERE Physical_Surface__r.Property__c =: sysDesign.Property__c
                ORDER BY Location__c];
        system.debug('***ils size: ' + ils.size());
                

        //Need to populate the inverter if they are blank using defaulting logic.        
        if(sysDesign.System_Inverter__c == null){
            if(setSolarEdge.contains(sysDesign.Property__r.Property_City__c.toUpperCase() + ', ' + sysDesign.Property__r.Property_State__c.toUpperCase())){

                //Default inverter = "Solar Edge Inverter System" (SOQL to get this by description)
                for(System_Design_Product__c sdp : [select id from System_Design_Product__c 
                                                    where RecordType.DeveloperName = 'Inverter' 
                                                    and Description__c = 'Solar Edge Inverter System' order by createddate desc limit 1]){
                    sysDesign.System_Inverter__c = sdp.id;
                }
            }else{
                //Default inverter = "M215-60-240-S22" (SOQL to get this by description, This is an enphase)
                for(System_Design_Product__c sdp : [select id from System_Design_Product__c 
                                                    where RecordType.DeveloperName = 'Inverter' 
                                                    and Description__c = 'M215-60-240-S22' order by createddate desc limit 1]){
                    sysDesign.System_Inverter__c = sdp.id;
                }
            }
        }
        originalInverter = sysDesign.System_Inverter__c;

        return null;
    }

    //SD MODE INIT
    public pageReference initSDEditMode(){
        system.debug('***initSDEditMode');
        //Load the property snow derate
        if(sysDesign.Property__c == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Missing Property ID, unable to load this page.'));
            hideForm = true;
            return null;
        }
        list<Property__c> props = [select id, Snow_De_Rate_kWh_y_kW__c, Name, Property_City__c, Property_State__c, Property_Zip__c, 
                                   Utility_Company_Master__c, Utility_Company_Master__r.Solar_Compensation_Method__c, Utility_Company__c, Property_Owner__r.Client_Last_Name__c, Property_Owner__c 
                                   from Property__c where id =: sysDesign.Property__c];        
        //system.debug('***props: ' + props);
        prop = props[0];
        if(prop.Property_State__c != null && westCoastStates.contains(prop.Property_State__c.toUpperCase())) isWestCoast = true;
        originalSnowDerate = prop.Snow_De_Rate_kWh_y_kW__c;
        system.debug('***originalSnowDerate: ' + originalSnowDerate);
        system.debug('***prop.Snow_De_Rate_kWh_y_kW__c: ' + prop.Snow_De_Rate_kWh_y_kW__c);


        utsList = [SELECT Id, Name FROM Utility_Service__c
                        WHERE Property__c =: sysDesign.Property__c
                        ORDER BY createddate];

        //build a picklist of CBpanels        
        cbPanels = new List<selectOption>(); 
        //new list for holding all of the picklist cbPanels
        cbPanels.add(new selectOption('', 'Create a new CB Panel'));
        //add the first option of '- None -' in case the user doesn't want to select a value or in case no values are returned from query below        
        for (CB_Panel__c cb : [SELECT Id, Name, Utility_Service__c FROM CB_Panel__c
                                    WHERE Utility_Service__r.Property__c =: sysDesign.Property__c
                                    ORDER BY createddate]) {
            cbPanels.add(new selectOption(cb.id, cb.Name));
            //Set utilityService depending on if the default cb panel is picked
            if(sysDesign.Default_CB_Panel__c == cb.id){                
                utilityService = cb.Utility_Service__c;
            }

            if(sysDesign.Default_CB_Panel__c == null){
                sysDesign.Default_CB_Panel__c = cb.id;
                utilityService = cb.Utility_Service__c;
            }
        }

        return null;
    }

    public pageReference calc(){
        calculateStats();
        return null;
    }

    public pageReference surveyChangeOnPS(){
        //get activePSid and loop through the list of cSurfaces        
        system.debug('***SurveyChangeOnPS, activePSid: ' + activePSid);
        if(activePSid == null) return null;

        for(cSurface cs : cSurfaceList){
            if(cs.ps.id == activePSid){
                    system.debug('***Found matching cSurface');
                //Modify the list of install locations to pull from the new survey selected
                cs.cIls = getCLocationListForArray(cs.sda);
            }
        }

        return null;
    }

    //SAVE ARRAYS **
    public pageReference saveArrays(){
        //Validation:
        boolean isValidationError = false;

        //System Panel
        if(sysDesign.System_Panel__c == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Missing required field: Default System Solar Panel'));
            isValidationError = true;
        }

        //System Inverter
        if(sysDesign.System_Inverter__c == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Missing required field: Default System Inverter'));
            isValidationError = true;
        }
        
        ////Check that mounting type is selected
        //for(cSurface cs : cSurfaceList){            
        //    if(cs.sda.Mounting_Type__c == null || cs.sda.Mounting_Type__c == ''){
        //        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Missing required field: Surface ' + cs.ps.Physical_Surface_Assigned_Letter__c + ' Mounting Type'));
        //        isValidationError = true;
        //    }
        //}

        if(isValidationError) return null; //Return early since there is a validation issue

        list<System_Design_Array__c> arraysToUpsert = new list<System_Design_Array__c>();
        list<System_Design_Item__c> itemsToUpsert = new list<System_Design_Item__c>();
        set<id> recordIDsBeingUpdated = new set<id>();
        //list<System_Design_Item__c> itemsToDelete = new list<System_Design_Item__c>();

        

        //Map to help link items to arrays further down
        map<id, id> locationIDsurfaceIDMap = new map<id, id>();

        map<id, Decimal> surfaceTrechLengthMap = new map<id, Decimal>();

        //Create the Array record and items
        system.debug('***Create the Array record and items');
        for(cSurface cs : cSurfaceList){
            boolean validItems = false;
            id installLocationID;

            //Make sure this Array has a picked survey
            if(cs.sda.Survey__c != null){
                system.debug('***Look for install locations for this ps: ' + cs.ps.id);
                //This Array has a chosen survey, look for Install locations
                for(cInstallLocation cIns : cs.cIls){
                    if(cIns.quantity != null ){
                        system.debug('***This install location has quantity(' + cIns.quantity + ') entered: ' + cIns.il.id);
                        validItems = true;
                        installLocationID = cIns.il.id; 

                        //Add a Panel
                        System_Design_Item__c tempSDI = new System_Design_Item__c();

                        //UPDATE PREVIOUS ITEMS IF POSSIBLE
                        if(cs.sda.id != null && cs.sda.System_Design_Items__r != null){
                            //Loop through panels on this array
                            for(System_Design_Item__c sdi : cs.sda.System_Design_Items__r){
                                 if(sdi.RecordType.DeveloperName == 'Panel' && sdi.Install_Location__c == installLocationID){
                                    //Matching SDI in the same Install Location
                                    tempSDI.id = sdi.id;
                                    recordIDsBeingUpdated.add(tempSDI.id);
                                    break;//exit for loop
                                 }
                            }
                        }
                        tempSDI.Name = sysDesign.Property__r.Property_Owner__r.Client_Last_Name__c + ' ' + cIns.il.Location__c + ' Panel Item';
                        tempSDI.Install_Location__c = installLocationID;
                        tempSDI.System_Design_Product__c = sysDesign.System_Panel__c;
                        tempSDI.Quantity__c = cIns.quantity;
                        tempSDI.RecordTypeid = rTypesMap.get('Panel');

                        itemsToUpsert.add(tempSDI);

                        //Build map of install location ids and surface ids so that we can link the items to array IDs.
                        if(!locationIDsurfaceIDMap.containskey(cIns.il.id)) locationIDsurfaceIDMap.put(cIns.il.id, cIns.il.Physical_Surface__c);
                                            
                    }
                }
            }
            if(validItems){
                //Check that mounting type is selected
                Boolean arrayUpsert = false;
                if(cs.sda.Default_Mounting_Type__c == null){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Missing required field: Surface ' + cs.ps.Physical_Surface_Assigned_Letter__c + ' Mounting Type'));
                    isValidationError = true;
                }
                else
                {
                    if(mountings.containsKey(cs.sda.Default_Mounting_Type__c)){
                        cs.sda.Mounting_Type__c =  mountings.get(cs.sda.Default_Mounting_Type__c).Description__c;     //DK 05/13/15                        
                    }                    

                    System_Design_Item__c tempSDI = new System_Design_Item__c();                

                    //UPDATE PREVIOUS ITEMS IF POSSIBLE
                    if(cs.sda.id != null && cs.sda.System_Design_Items__r != null){
                        //Loop through Inverter on this array
                        for(System_Design_Item__c sdi : cs.sda.System_Design_Items__r){
                             if(sdi.RecordType.DeveloperName == 'Mounting'){
                                //Matching SDI on this array
                                tempSDI.id = sdi.id;
                                recordIDsBeingUpdated.add(tempSDI.id);
                                break;//exit for loop
                             }
                        }
                    }

                    tempSDI.Name = 'Array Mounting';
                    tempSDI.Install_Location__c = installLocationID; //THIS IS TEMPORARY SO THAT WE CAN LINK TO THE NEW ARRAY.  THIS WILL BE REMOVED AFTERWARDS.
                    tempSDI.System_Design_Product__c = cs.sda.Default_Mounting_Type__c;                    
                    tempSDI.RecordTypeid = rTypesMap.get('Mounting');
                    tempSDI.Quantity__c = 1;
                    itemsToUpsert.add(tempSDI);

                    //Add the Array record to list  
                    arrayUpsert = true;              
                }
                // Check Trench
                System.debug(cs.sda.Name+'**'+cs.sda.Trench_Type__c);
                if(cs.sda.Trench_Type__c == null ){
                    System.debug('**Trenching not selected ');        
                }    
                else
                {                    
                    if(cs.trenchLength == null || cs.trenchLength  == 0 ){
                        System.debug('**Missing required field: Trech Length ');
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Missing required field: Surface ' + cs.ps.Physical_Surface_Assigned_Letter__c + ' Trench Length'));
                        isValidationError = true;
                    }
                    else if(cs.ps.Trenching_Dist_to_Intercon_Pt_ft__c != null  && cs.trenchLength < cs.ps.Trenching_Dist_to_Intercon_Pt_ft__c ){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Trench Length is too short: Surface ' + cs.ps.Physical_Surface_Assigned_Letter__c + ' Trench Length is shorter than minimum required ('+cs.ps.Trenching_Dist_to_Intercon_Pt_ft__c+' ft)'));
                        isValidationError = true;
                    }
                    else
                    { 
                        //Add an Trench Item, but only 1 per array
                        if(surfaceTrechLengthMap.get(cs.sda.Trench_Type__c) != null)
                        {
                            if(surfaceTrechLengthMap.get(cs.sda.Trench_Type__c) != cs.trenchLength)
                            {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Different Trench Length : Surface ' + cs.ps.Physical_Surface_Assigned_Letter__c + ' is having different Trench Length from the same Trench Type in different Surface.'));
                                isValidationError = true;    
                            }    
                        }
                        else
                        {
                            surfaceTrechLengthMap.put(cs.sda.Trench_Type__c,cs.trenchLength);      
                        }
                        System_Design_Item__c tempSDI = new System_Design_Item__c();                

                        //UPDATE PREVIOUS ITEMS IF POSSIBLE
                        if(cs.sda.id != null && cs.sda.System_Design_Items__r != null){
                            //Loop through Inverter on this array
                            for(System_Design_Item__c sdi : cs.sda.System_Design_Items__r){
                                 if(sdi.RecordType.DeveloperName == 'Trenching'){
                                    //Matching SDI on this array
                                    tempSDI.id = sdi.id;
                                    recordIDsBeingUpdated.add(tempSDI.id);
                                    break;//exit for loop
                                 }
                            }
                        }

                        tempSDI.Name = 'Array Trench';
                        tempSDI.Install_Location__c = installLocationID; //THIS IS TEMPORARY SO THAT WE CAN LINK TO THE NEW ARRAY.  THIS WILL BE REMOVED AFTERWARDS.
                        tempSDI.System_Design_Product__c = cs.sda.Trench_Type__c;
                        tempSDI.Total_Trenching_Lengthft__c = cs.trenchLength;
                        tempSDI.RecordTypeid = rTypesMap.get('Trenching');
                        tempSDI.Quantity__c = 1;
                        itemsToUpsert.add(tempSDI);

                        //Add the Array record to list  
                        arrayUpsert = true;                    
                    }       
                }
                if(!isValidationError)
                {  
                    //Add an Inverter, but only 1 per array
                    System_Design_Item__c tempSDI = new System_Design_Item__c();                

                    //UPDATE PREVIOUS ITEMS IF POSSIBLE
                    if(cs.sda.id != null && cs.sda.System_Design_Items__r != null){
                        //Loop through Inverter on this array
                        for(System_Design_Item__c sdi : cs.sda.System_Design_Items__r){
                             if(sdi.RecordType.DeveloperName == 'Inverter'){
                                //Matching SDI on this array
                                tempSDI.id = sdi.id;
                                recordIDsBeingUpdated.add(tempSDI.id);
                                break;//exit for loop
                             }
                        }
                    }

                    tempSDI.Name = 'Array Inverter Type';
                    tempSDI.Install_Location__c = installLocationID; //THIS IS TEMPORARY SO THAT WE CAN LINK TO THE NEW ARRAY.  THIS WILL BE REMOVED AFTERWARDS.
                    tempSDI.System_Design_Product__c = sysDesign.System_Inverter__c;
                    tempSDI.Quantity__c = 1;
                    tempSDI.RecordTypeid = rTypesMap.get('Inverter');
                    itemsToUpsert.add(tempSDI);

                    //Add the Array record to list    
                    arrayUpsert = true;            
                    
                }
                
                if( arrayUpsert)
                {
                    arraysToUpsert.add(cs.sda);
                }

            }else{
                //SDA does not have a survey selected
                //Add the Array record to list if it contains an ID, so that any changes to it are reflected per what the user has done on screen
                if(cs.sda.id != null) arraysToUpsert.add(cs.sda);
            }
        }

        //CLEANUP PREVIOUS ITEMS IF POSSIBLE
        //Loop through all arrays, not just the arrays that were linked (This will fix if there are 2 arrays linked to the same physical surface)
        for(System_Design_Array__c sdaTemp : sdaMap.values()){
            if(sdaTemp.id != null && sdaTemp.System_Design_Items__r != null){            
                for(System_Design_Item__c sdi : sdaTemp.System_Design_Items__r){
                    if(!recordIDsBeingUpdated.contains(sdi.id)){
                        //This old item was not matched.  We need to do something with it.
                        sdi.Quantity__c = 0;
                        itemsToUpsert.add(sdi);
                        
                        //if(sdi.RecordTypeid = rTypesMap.get('Inverter')){
                            //If it's an inverter that was not matched, it means the array does not have panels.  This is likely OK to keep here, 
                            //it won't be referenced since the array has no panels.
                            //sdi.Quantity__c = 0;
                        //}
                        //if(sdi.RecordTypeid == rTypesMap.get('Panel')){
                            //If it's a panel that was not matched, then let's just zero it out and add it to the same list for upserting
                            //sdi.Quantity__c = 0;
                            //itemsToUpsert.add(sdi);
                        //}
                    }                
                }
            }
        }

        
        //Check for validation error which could happen within the creation of items to update
        if(isValidationError) return null; //Return early since there is a validation issue

        if(arraysToUpsert.isEmpty()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Panel Quantity is required in order to build System Arrays and Items.'));            
            return null;
        } 

        //Database savepoint        
        Savepoint sp = Database.setSavepoint();

        //Preserve ID, Deep Clone.  This is done so that in case of a failed upsert, we won't have "fake" salesforce IDs for these records
        //which would fail for sure on the second save attempt.  This will preserve our existing lists.
        list<System_Design_Array__c> arraysToUpsertTEMP = arraysToUpsert.deepClone(true); 
        list<System_Design_Item__c> itemsToUpsertTEMP = itemsToUpsert.deepClone(true);
        

        try{
            //Upsert Arrays
            system.debug('Upsert Arrays');
            upsert arraysToUpsertTEMP;
        }catch(exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to save Arrays due to the following error message: ' + e));
            Database.rollback(sp);
            return null;
        }

        //Loop through Arrays and build map of PS id and Array id
        system.debug('Get new array IDs');
        //Id defaultSAId;
        map<id, id> surfaceIDarrayID = new map<id, id>();
        for(System_Design_Array__c sda : arraysToUpsertTEMP){
            system.debug('PS ID: ' + sda.Physical_Surface__c);
            system.debug('Array ID: ' + sda.id);
            surfaceIDarrayID.put(sda.Physical_Surface__c, sda.id);
            //defaultSAId = sda.id;
        }

        //Loop through the new SDIs and link them to the new Arrays
        system.debug('Link items to Arrays before insert');
        for(System_Design_Item__c sdi : itemsToUpsertTEMP){
            //system.debug('***surfaceIDarrayID.get(locationIDsurfaceIDMap.get(sdi.Install_Location__c)): ' + surfaceIDarrayID.get(locationIDsurfaceIDMap.get(sdi.Install_Location__c)));
            if(sdi.id == null) sdi.System_Design_Array__c = surfaceIDarrayID.get(locationIDsurfaceIDMap.get(sdi.Install_Location__c));
            if(sdi.RecordTypeid != rTypesMap.get('Panel')) sdi.Install_Location__c = null;  //Only panels should be linked to an install location, but this was key in linking to the array.
        }
        // Add special parts if any 
        boolean ventMvmtRequired = false;
        //cpq-588
        if(specialParts != null && specialParts.size() > 0)
        {
            System_Design_Array__c sa;
            try{
                sa = [Select id from System_Design_Array__c where default_System_Design_Array__c = true and System_Design__c = : sysDesign.id limit 1];
            }
            catch(Exception e)
            {
                sa = new System_Design_Array__c();
                sa.CB_Panel__c = sysDesign.Default_CB_Panel__c;
                sa.System_Design__c = sysDesign.id;
                sa.default_System_Design_Array__c = true;
                insert sa;
            }
            for(System_Design_Item__c sdi : specialParts)
            {
                if(sdi.System_Design_Array__c == null )
                {
                    sdi.System_Design_Array__c =  sa.id;
                }
                if(spProducts.get(sdi.System_Design_Product__c).Description__c.contains('Vents'))
                {
                    ventMvmtRequired = true;                    
                }
                itemsToUpsertTEMP.add(sdi);   
            }
        }
        if(deleteSpecialParts != null && deleteSpecialParts.size() > 0)
        {
            for(System_Design_Item__c sdi : deleteSpecialParts)
            {
                sdi.Quantity__c =  0;                
                itemsToUpsertTEMP.add(sdi);   
            }            
        }

        try{
            //Upsert Items
            system.debug('Upsert Items');
            upsert itemsToUpsertTEMP;
        }catch(exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to save System Design Items due to the following error message: ' + e));
            Database.rollback(sp);
            return null;
        }


        try{
            //Update the System Design record
            system.debug('Update System Design');
            if(surfaceTrechLengthMap.size() > 0)
            {
                sysDesign.Trenching_Required__c = true;
                double sdTrenchLength = 0;
                for(Decimal len : surfaceTrechLengthMap.values())
                {
                    sdTrenchLength = sdTrenchLength + len;
                }
                sysDesign.Trench_Length__c = sdTrenchLength;
            }
            else
            {
                sysDesign.Trenching_Required__c = false;
                sysDesign.Trench_Length__c = null;
                   
            }
            sysDesign.Vent_Stack_Movement_Required__c = ventMvmtRequired;
            update sysDesign;
            //RJ: Call Validation Rules if saving from Input Page
            //if(sdqid != null)
            //{
            //    UtilityPricingProcessor upp = new UtilityPricingProcessor(sysDesign.Id,'Method_1');                
            //    String utilityErrors = upp.getUtilityServiceMonthlyProduction(null);
            //    SalesWorkflowValidationUtility.validateSystemDesign(sysDesign,true);    
            //}
        }catch(exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to save System Design Items due to the following error message: ' + e));
            Database.rollback(sp);
            return null;
        }

        return null;    //runSiteQuality() will be called in an actionFunction when this method completes, and that is when a PageReference will be returned
    }

    public PageReference runSiteQuality(){
        //If the System Inverter has been changed, then recalculate Astrum Site Quality
        if (originalInverter != sysDesign.System_Inverter__c){
            SystemDesignSQCalculation.calculateSQ(sysDesign, 'ASTRUM');
        }

        if (sdqid != null){
            //Run Utility Pricing and System Design validation
            UtilityPricingProcessor upp = new UtilityPricingProcessor(sysDesign.Id,'Method_1');                
            String utilityErrors = upp.getUtilityServiceMonthlyProduction(null);
            SalesWorkflowValidationUtility.validateSystemDesign(sysDesign, true, Date.today());    //Will create new SDQ if System Design passes validation

            //If coming from Input page, handle return
            String currentsdqid = [SELECT Id FROM System_Design_Quote__c WHERE System_Design__r.Id = :sysDesign.Id AND Current__c = true][0].Id;
            if(currentsdqid.equals(sdqid)){
                return new PageReference('javascript:window.close();parent.jsclosePopup2();parent.location.reload();' );                
            }
            return new PageReference('javascript:window.close();parent.jsclosePopup2();' );
        }
        return controller.cancel();
    }

    //SAVE SYSTEM DESIGN **
    private pageReference saveSD(boolean nextPage){
        boolean isValidationError = false;

        integer busRatingAmpsI;
        integer mainBreakerRatingAmpsI;
        integer countofOpenCircuitsI;
        
        //Validation

        //Validate Survey
        if(selectedSurveyID == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Survey is required.'));
            isValidationError = true;
        }

        //Validate Trenching length if it's checked
        /* Commented RJ : 08/09/14
        if(sysDesign.Trenching_Required__c && (sysDesign.Trench_Length__c == null || sysDesign.Trench_Length__c < 1) ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Trenching is entered as required but Trenching Length is zero. Please enter a trenching length.'));
            isValidationError = true;
        }
        */

        //Validate the CB Panel and Utility fields
        if(sysDesign.Default_CB_Panel__c == null){
            if(isWestCoast){

                if(busRatingAmps == null){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Bus Rating Amps is required.'));
                    isValidationError = true;
                }else{
                    try{
                        busRatingAmpsI = Integer.valueOf(busRatingAmps);            
                    }Catch (exception e) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Bus Rating Amps must be a number.'));
                        isValidationError = true;
                    }
                }

                if(mainBreakerRatingAmps == null){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Main Breaker Rating Amps is required.'));
                    isValidationError = true;
                }else{
                    try{
                        mainBreakerRatingAmpsI = Integer.valueOf(mainBreakerRatingAmps);            
                    }Catch (exception e) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Main Breaker Rating Amps must be a number.'));
                        isValidationError = true;
                    }
                }

                if(countofOpenCircuits == null){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Count of Open Circuits is required.'));
                    isValidationError = true;
                }else{
                    try{
                        countofOpenCircuitsI = Integer.valueOf(countofOpenCircuits);            
                    }Catch (exception e) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Count of Open Circuits must be a number.'));
                        isValidationError = true;
                    }
                }
            }            

             //Check to see if they picked an existing Utility Service
            if(utilityService == null){
                //User typed in a new utility service
                if(serviceEntryType == null){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Service Entry Type is required.'));
                    isValidationError = true;
                }

                if(meterid == null){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Meter ID is required.'));
                    isValidationError = true;
                }
            }

        }

        if(isValidationError) return null; //Return early since there is a validation issue

        //Database savepoint        
        Savepoint sp = Database.setSavepoint();
        
        //Save Property Snow DeRate        
        try{            
            system.debug('***originalSnowDerate: ' + originalSnowDerate);
            system.debug('***prop.Snow_De_Rate_kWh_y_kW__c: ' + prop.Snow_De_Rate_kWh_y_kW__c);
            if(originalSnowDerate != prop.Snow_De_Rate_kWh_y_kW__c) update prop;
        }catch(exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to save Property Snow De-Rate due to the following error message: ' + e));
            Database.rollback(sp);
            return null;
        }

        //Save Utility Service, CB Panel
        try{            
            if(sysDesign.Default_CB_Panel__c == null){
                //Utility_Service__c.Service_Entry_Type__c
                Utility_Service__c uts = new Utility_Service__c();                
                id utsID;

                //User typed in a new CB panel.

                //Check to see if they picked an existing Utility Service
                if(utilityService == null){
                    //User typed in a new utility service
                    if (utilRateCode != null){
                        //User selected a Utility Rate Code
                        Utility_Company__c defaultRateCode = [SELECT Utility_Company_Master__c, Utility_Company_Master__r.Solar_Compensation_Method__c FROM Utility_Company__c WHERE ID = :utilRateCode LIMIT 1];
                        uts.Utility_Company_Master__c = defaultRateCode.Utility_Company_Master__c;
                        String compMethod = defaultRateCode.Utility_Company_Master__r.Solar_Compensation_Method__c;
                        
                        uts.Utility_Rate_Code_Before_Solar__c = defaultRateCode.ID;
                        uts.Utility_Rate_Code_After_Solar__c = defaultRateCode.ID;
                        
                        if (compMethod == 'Net Metering'){
                            uts.Utility_Value_of_Solar_Tariff__c = null;
                        } else if (compMethod == 'VOST'){
                            Utility_Company__c[] tariffRateCode = [SELECT ID FROM Utility_Company__c WHERE Utility_Company_Master__c = :uts.Utility_Company_Master__c 
                                                                   AND Value_of_Solar_Tariiff__c = true LIMIT 1];
                            if (tariffRateCode.size() == 1)
                                uts.Utility_Value_of_Solar_Tariff__c = tariffRateCode[0].ID;
                        }
                    }
                    uts.Name = meterid;
                    uts.Property__c = sysDesign.Property__c;
                    uts.Service_Entry_Type__c = serviceEntryType;
                    upsert uts;
                    utsID = uts.id;
                }else{
                    utsID = utilityService;
                }

                CB_Panel__c cbpanel = new CB_Panel__c();
                //Only in certain states
                if(isWestCoast){
                    cbpanel.Bus_Rating_Amps__c = busRatingAmpsI;
                    cbpanel.Main_Breaker_Rating_Amps__c = mainBreakerRatingAmpsI;
                    cbpanel.Count_of_Open_Circuits__c = countofOpenCircuitsI;
                }
                //link to parent utility service
                cbpanel.Utility_Service__c = utsID;                
                cbpanel.name = prop.Property_Owner__r.Client_Last_Name__c + ' Main Panel';     

                insert cbpanel;
                sysDesign.Default_CB_Panel__c = cbpanel.id;
            }
        }catch(exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to save Utility Service and/or CB Panel due to the following error message: ' + e));
            Database.rollback(sp);            
            return null;
        }


        //Save the System Design       
        try{            
            //if(!sysDesign.Trenching_Required__c) sysDesign.Trench_Length__c = null; //MK - 2014-06-26 Commented RJ : 08/09/14
            sysDesign.Survey__c = selectedSurveyID;
            upsert sysDesign;
        }catch(exception e){            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to save System Design due to the following error message: ' + e));
            Database.rollback(sp);
            if(isSdInsert) sysDesign = sysDesign.clone(false, false); //Explicit clear ID and keep deep clone reference to save on memory usage.  
                                                                    //If we don't clear ID, then we could have an issue where the record will have a trashed new 
                                                                    //ID and the platform will try upserting on it but will throw an error.
            return null;
        }
        
        if (isSdInsert)    //If the sketch-up image couldn't be inserted earlier (due to a null sysDesign ID), insert it now
            uploadImg();
        
        PageReference pageRef;        
        if(nextPage){
            //Send to Arrays Edit page
            pageRef = Page.SystemDesignArraysEdit;
            pageRef.setRedirect(true);
            pageRef.getParameters().put('id', sysDesign.id);
        }else{
            pageRef = new PageReference('/' + sysDesign.id);
        }
        return pageRef;
    }
    
    //DK  11-14-14  Allow the user to select a Utility Rate Code if they are inserting a new Utility Service
    public SelectOption[] getUtilRateCodeOptions(){
        SelectOption[] rateCodes = new SelectOption[]{};
        rateCodes.add(new SelectOption('', '-- None --'));
        ID[] utilComps = new ID[]{};
            System.debug(LoggingLevel.ERROR, 'PROPERTY ZIP:' + prop.Property_Zip__c);
        for (Utility_by_Zip_Code__c utilZip : [SELECT Utility_Company_Master__c FROM Utility_by_Zip_Code__c WHERE Utility_Company_Master__c != null AND Utility_Zip_Code__c = :prop.Property_Zip__c]){
            utilComps.add(utilZip.Utility_Company_Master__c);
        }
        for (Utility_Company__c urc : [SELECT Name FROM Utility_Company__c WHERE Default_Rate_Code__c = true AND Utility_Company_Master__c IN :utilComps]){
            rateCodes.add(new SelectOption(urc.ID, urc.Name));
            if (utilRateCode == null)
                utilRateCode = urc.ID;    //Default value if null
        }
        return rateCodes;
    }
    
    //DK  12-08-14  Ripped from SystemDesignImageController. Inserts the SketchUp file as an attachment on the System Design.
    public PageReference uploadImg() {
        Attachment imgFile = new Attachment();
        System.debug('ImgURL length: ' + imgURL.length());
        
        if( imgURL.length() > 0 && sysDesign.ID != null) {
            String tmpstr = imgURL;

            // break string apart into parts
            Integer pos1 = tmpstr.indexOf(':');
            Integer pos2 = tmpstr.indexOf(';', pos1);
            Integer pos3 = tmpstr.indexOf(',', pos2);

            System.debug('Pos1: ' + pos1 + '  Pos2: ' + pos2 + '  Pos3: ' + pos3);

            // decode the base64 encoded imag
            imgFile.Body = EncodingUtil.base64Decode(tmpstr.substring(pos3+1));

            // set imgFile parts to proper values
            imgFile.ContentType = tmpstr.substring((pos1+1), pos2);
            imgFile.Name = 'sample_sketch.jpg';
            imgFile.ParentId = sysDesign.ID;

            // insert imgFile
            try {
                insert imgFile;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Image successfully saved as an attachment on ' + System.now().format()));
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error on line: ' + e.getLineNumber()));
                return null;
            }
            PageReference pgref = null;
            //PageReference pgref = new PageReference('/apex/SystemDesignProposal?id=' + imgFile.Id);
            return pgref;
        }
        return null;
    }
    
    public Attachment[] getImageAttachments(){
        Attachment[] imgList = [SELECT Name, CreatedDate FROM Attachment WHERE ParentID = :sysDesign.ID AND ContentType = 'image/jpeg' ORDER BY CreatedDate DESC LIMIT 50];
        if (imgList.size() == 0)
            imgList = null;    //So Visualforce has an "Exists" flag
        return imgList;
    }
    
    public pageReference save(){        
        return saveSD(false);
    }

    public pageReference saveAndNext(){
        return saveSD(true);
    }
    
    public pageReference cancelExn(){
        
        PageReference pageRef;
        pageRef = controller.cancel();
        //If coming from Input page handle return
        if(sdqid != null){
            return new PageReference('javascript:window.close();parent.jsclosePopup2();');
        }        
        return pageRef;
        
    }
    
    //======================================
    //UTILITY METHODS

    //calculate stats
    private void calculateStats(){        
        system.debug('***calculateStats');        

        //System stats
        panelQty = 0;
        blendedTSRF = 0.00;

        for(cSurface cs : cSurfaceList){            
            //Array stats
            cs.panelQty = 0;
            cs.blendedTSRF = 0.00;
            for(cInstallLocation ci : cs.cIls){
                //Loop through each install location to calculate the total stats
                cs.panelQty += ci.quantity;
                cs.blendedTSRF += (ci.il.TSRF__c == null ? 0 : ci.il.TSRF__c) * ci.quantity; //weighted average
            }
            //Capture total TSRF (before dividing by qty)
            //System stats
            blendedTSRF += cs.blendedTSRF;
            panelQty += cs.panelQty;

            //Array stats
            if(cs.panelQty > 0) cs.blendedTSRF = cs.blendedTSRF / cs.panelQty;
            else cs.blendedTSRF = 0;
        }

        //System Stats
        if(panelQty > 0) blendedTSRF = blendedTSRF / panelQty;
        else blendedTSRF = 0;
    }

    private list<cInstallLocation> getCLocationListForArray(System_Design_Array__c sysArray){
        list<cInstallLocation> cIls = new list<cInstallLocation>();
        //Build the Install Location Containers
            //Get all Install Locations for the survey assigned to this Array            
        for(Install_Location__c il:ils){
            system.debug('***check if matching install location: ' + il);
            if(il.Survey__c == sysArray.Survey__c && il.Physical_Surface__c == sysArray.Physical_Surface__c){
                integer tQuantity = 0;
                cIls.add(new cInstallLocation(il, tQuantity));
            }
        }
        return cIls;
    }


    //=====================================
    //CONTAINER CLASSES

    @TestVisible public class cInstallLocation {
        public Install_Location__c il {get; set;}
        //Variables help re-create each array and it's items while allowing flexibility to switch install location tree options in the UI
        //public string chosenIL {get; set;}
        public integer quantity {get; set;}
        //public List<SelectOption> ilOptions {get; set;}

        //This is the contructor method. 
        //public cInstallLocation(Install_Location__c installLocation, integer q, list<Install_Location__c> installLocations) {
        public cInstallLocation(Install_Location__c installLocation, integer q) {
        
            il = installLocation;
            //chosenIL = il.id;
            quantity = q;

            //Build the list of options for user to switch between tree options for this location
            //for(Install_Location__c iLoc:installLocations){
            //    ilOptions.add(new SelectOption(iLoc.id, iLoc.Site__c));
            //}
        }
    }

    @TestVisible public class cSurface {
        public Physical_Surface__c ps {get; set;}
        public System_Design_Array__c sda {get; set;}
        public integer panelQty {get; set;}
        //public decimal arraySize {get; set;}
        public decimal blendedTSRF {get; set;}
        public list<cInstallLocation> cIls {get; set;}
        public decimal trenchLength {get; set;}

        //This is the contructor method.             
        public cSurface(System_Design__c sysDesign, Physical_Surface__c pSurface, string mode, map<id, System_Design_Array__c> sysArrayMap, 
                            list<Install_Location__c> allInstallLocations) {
            system.debug('***cSurface contructor');
            
            //initialize variables
            panelQty = 0;
            //arraySize = 0.00;
            blendedTSRF = 0.00;
            //trenchLength = 0.00;
            ps = pSurface;
            system.debug('***PS ID: ' + ps.id);
            map<id, Integer> installLocationIdSDImap = new map<id, Integer>();
            cIls = new list<cInstallLocation>();

            system.debug('***Mode: ' + mode);
            if(mode == 'Edit' || mode == 'New'){
                //This is NEW or EDIT mode                                
                //Get the matching Array and create one if it does not exist
                system.debug('Checking if PS matches any of the existing arrays');
                for(System_Design_Array__c sa:sysArrayMap.values()){
                    system.debug('sa: ' + sa);
                    if(sa.Physical_Surface__c == ps.id){
                        system.debug('Found Matching Array from PS id. ' + ps.id);
                        sda = sa;
                        break;
                    }                    
                }

                if(sda == null) sda = new System_Design_Array__c();

                //Always overwrite the original tilt and azimuth in the Array for snapshot purposes.
                sda.Original_Surface_Tilt__c = ps.Surface_Tilt__c;
                sda.Original_Surface_Azimuth__c = ps.Surface_Azimuth__c;

                //Back-fill missing data for new Array's
                if(sda.Physical_Surface__c == null) sda.Physical_Surface__c = ps.id;
                if(sda.Survey__c == null) sda.Survey__c = sysDesign.Survey__c;
                if(sda.Default_Mounting_Type__c == null) sda.Default_Mounting_Type__c = ps.Default_Mounting__c;                 
                if(sda.Electrical_Adder__c == null) sda.Electrical_Adder__c = 'No Change to Electrical Service';
                if(sda.Default_Mounting_Type__r.Description__c != 'Flush Mounted on pitched roof, penetrating') sda.Special_Parts_Required__c = true;
                if(sda.System_Design__c == null) sda.System_Design__c = sysDesign.id;
                if(sda.CB_Panel__c == null) sda.CB_Panel__c = sysDesign.Default_CB_Panel__c;
                                
                if(mode == 'Edit'){
                    //Need to load up any existing panels by Install location id

                    //Get system design items if array id exists                
                    if(sda.id != null && sda.System_Design_Items__r != null){
                        system.debug('Array might have items to link to Install Locations, loop through them now.');
                        //Loop through the subquery of panels & inverters for this array
                        for(System_Design_Item__c sdi : sda.System_Design_Items__r){
                            //If this is a panel, add it to the map
                            system.debug('**'+sdi.RecordType.DeveloperName);
                            system.debug('Found existing item in array, check to see if its a panel and record the quantity.');
                            if(sdi.RecordType.DeveloperName == 'Panel') installLocationIdSDImap.put(sdi.Install_Location__c, (Integer)sdi.Quantity__c);
                            
                            if(sdi.RecordType.DeveloperName == 'Trenching') {
                                trenchLength = sdi.Total_Trenching_Lengthft__c;      

                            }
                        }
                    }
                }
               
                //Build the Install Location Containers
                    //Get all Install Locations for the survey assigned to this Array
                    //passed in from: allInstallLocations                
                for(Install_Location__c il:allInstallLocations){
                    system.debug('***check if matching install location: ' + il);
                    if(il.Survey__c == sda.Survey__c && il.Physical_Surface__c == sda.Physical_Surface__c){
                        //If we have items, transfer the quantity into the cInstallLocation wrapper to display properly    
                        integer tQuantity;
                        if(mode == 'Edit'){
                            //Look for existing SDI
                            if(installLocationIdSDImap.containskey(il.id)){
                                tQuantity = installLocationIdSDImap.get(il.id);
                            }
                        }
                        tQuantity = tQuantity == null ? 0 : tQuantity;
                        cIls.add(new cInstallLocation(il, tQuantity));
                    }
                }

                

                //At this point we should have everything we need to populate the screen.

            }//else{
                //View mode for the system design page
                /*
                if(sda.id == null){
                    sdis = new list<System_Design_Item__c>();
                }else{
                    sdis = [select id, name, Quantity__c, System_Design_Product__c, Install_Location__c, Install_Location__r.Name, Install_Location__r.Azimuth__c, Install_Location__r.TSRF__c, 
                                    Install_Location__r.Annual_Solar_Access__c, Install_Location__r.Pitch__c
                            from System_Design_Item__c where System_Design_Array__c =: sda.id and RecordType.DeveloperName = 'Panel'];
                }
                */
            //}
        }
    }
    
}