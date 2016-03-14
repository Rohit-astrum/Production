/* FILE: testData.cls
 * AUTHOR: Mike Katulka
 * DATE: April 1, 2014
 * PURPOSE: Common test utiliy class for loading test data to be used in test methods
 * MODIFICATION HISTORY: 
 * 07/16/2015 PB FPO Phase2- Set active field on Office Location
 * 09/28/2015 PB FPO Phase4- Remove hard coded reference to Annapolis , MD
 */

//data loader:
//Import Trenching Table        
//Import SDP's for trenching

@isTest
public class testData {

    public static final String defaultOffLocationName = getdefaultOffLocName();

    /*

    Good sample for creating bulk related data: 

    public static void createTestRecords(Integer numAccts, Integer numContactsPerAcct) {
        List<Account> accts = new List<Account>();
        
        for(Integer i=0;i<numAccts;i++) {
            Account a = new Account(Name='TestAccount' + i);
            accts.add(a);
        }
        insert accts;
         
        for (Integer j=0;j<numAccts;j++) {
            Account acct = accts[j];
            List<Contact> cons = new List<Contact>();
            // For each account just inserted, add contacts
            for (Integer k=numContactsPerAcct*j;k<numContactsPerAcct*(j+1);k++) {
                cons.add(new Contact(firstname='Test'+k,lastname='Test'+k,AccountId=acct.Id));
            }
            insert cons;
        }
    }

    */
    //public static id setupSystemDesign(string propType, string finType, id LeaseFund, boolean commProgram, double siteQuality) //returns ID of System Design
    //{
    //    id tempID;
    //    return tempID;
    //}

    //Only call this method if your unit test is set to "seealldata=false"
    public static void setupCustomSettings(){
        system.debug('setupCustomSettings');

        system.debug('setup SiteQualitySettings__c');
        SiteQualitySettings__c sq = new SiteQualitySettings__c();
        sq.Name = 'SiteQuality';
        sq.Batch_Size__c = 5;
        sq.CPRE__c = false;
        sq.NRG__c = false;
        sq.NRG_Batch_Size__C = 5;
        sq.Astrum__c = false;
        insert sq;


        system.debug('setup AstrumCRMSettings__c');
        AstrumCRMSettings__c crmsettings = new AstrumCRMSettings__c();
        crmsettings.ANNAPOLIS_JUNCTION_MD_SALES_COORD__C = 'anthony.rogers@astrumsolar.com';
        crmsettings.BRIDGEWATER_NJ_SALES_COORD__C = 'chris.echevarria@astrumsolar.com';
        crmsettings.HENRIETTA_NY_SALES_COORD__C = 'chris.echevarria@astrumsolar.com';
        crmsettings.HOPKINTON_MA_SALES_COORD__C = 'krystal.holt@astrumsolar.com';
        crmsettings.MA_SALES_COORD__C = 'krystal.holt@astrumsolar.com';
        crmsettings.MI_SALES_COORD__C = 'krystal.holt@astrumsolar.com';
        crmsettings.NY_SALES_COORD__C = 'chris.echevarria@astrumsolar.com';
        crmsettings.NORRISTOWN_PA_SALES_COORD__C = 'chris.echevarria@astrumsolar.com';
        crmsettings.WHITE_PLAINS_NY_SALES_COORD__C = 'chris.echevarria@astrumsolar.com';
        crmsettings.YOUNGSTOWN_OH_COORD__C = 'anthony.rogers@astrumsolar.com';
        insert crmsettings;

        
        system.debug('setup AstrumPM2__c');
        AstrumPM2__c pmSettings = new AstrumPM2__c();
        pmSettings.setupOwnerID = UserInfo.getUserId();
        insert pmSettings;


        system.debug('setup System_Design_Quote_Settings__c');
        System_Design_Quote_Settings__c sdqsettings = new System_Design_Quote_Settings__c();
        sdqsettings.Run_Promotions_Sync__c = true;
        sdqsettings.Run_Pricing_Automatically__c = true;
        sdqsettings.Run_CPO_matching_on_SDQs__c = true;
        sdqsettings.Scenario_1_Proposal_Term_Months__c = 240;
        sdqsettings.Scenario_2_Proposal_Term_Months__c = 240;
        sdqsettings.Scenario_3_Proposal_Term_Months__c = 240;
        sdqsettings.Scenario_4_Proposal_Term_Months__c = 240;
        sdqsettings.Run_SRECs_Sync__c = true;
        sdqsettings.Days_Proposal_Valid__c = 14;
        insert sdqsettings;

        system.debug('setup contractsettings__c');
        ContractSettings__c contractsettings = new ContractSettings__c();
        contractSettings.Minimum_Commission_Rate__c = 0.5;
        contractSettings.Maximum_Commission_Rate__c = 3.5;
        contractSettings.Maximum_Promotion__c = 0.5;
        contractSettings.Minimum_Promotion__c = 0.0;
        insert contractSettings;


        /*
            Consider using this method to import items like Bin Configuration and objects that are larger than normal but not custom settings.

            loadData(Schema.SObjectType, String)

            Inserts test records from the specified static resource .csv file and for the specified sObject type, and returns a list of the inserted sObjects.
            Signature
            public static List<sObject> loadData(Schema.SObjectType sObjectToken, String resourceName)
            Parameters
            sObjectToken
            Type: Schema.SObjectType
            The sObject type for which to insert test records.
            resourceName
            Type: String
            The static resource that corresponds to the .csv file containing the test records to load. The name is case insensitive.
            Return Value
            Type: List<sObject>
            Usage
            You must create the static resource prior to calling this method. The static resource is a comma-delimited file ending with a .csv extension. The file contains field names and values for the test records. The first line of the file must contain the field names and subsequent lines are the field values. To learn more about static resources, see “Defining Static Resources” in the Salesforce online help.
            Once you create a static resource for your .csv file, the static resource will be assigned a MIME type. Supported MIME types are:
            text/csv
            application/vnd.ms-excel
            application/octet-stream
            text/plain

        */

    }
    
    //Only call this method if your unit test is set to "seealldata=false"
    public static void setupCustomConfigObjects(){
        system.debug('setupCustomConfigObjects (Non-custom settings which would not transfer to a new dev sandbox)');
        id uid = UserInfo.getUserId();
        string uemail = UserInfo.getUserEmail();

        //list<Astrum_Sales_Region__c> srList = [select id from Astrum_Sales_Region__c];
        //delete srList;
        system.debug('setup Astrum_Sales_Region__c');
        list<Astrum_Sales_Region__c> srList = new list<Astrum_Sales_Region__c>();
        
        srList.add(new Astrum_Sales_Region__c(Name = 'NYC Region', Sales_Coordinator__c=uid));
        srList.add(new Astrum_Sales_Region__c(Name = 'WNY Region', Sales_Coordinator__c=uid));
        srList.add(new Astrum_Sales_Region__c(Name = 'MA Region', Sales_Coordinator__c=uid));
        srList.add(new Astrum_Sales_Region__c(Name = 'PA Region', Sales_Coordinator__c=uid));
        srList.add(new Astrum_Sales_Region__c(Name = 'OH Region', Sales_Coordinator__c=uid));
        srList.add(new Astrum_Sales_Region__c(Name = 'MD Region', Sales_Coordinator__c=uid));
        srList.add(new Astrum_Sales_Region__c(Name = 'CA Region', Sales_Coordinator__c=uid));
        srList.add(new Astrum_Sales_Region__c(Name = 'CT Region', Sales_Coordinator__c=uid));
        //srList.add(new Astrum_Sales_Region__c(Name = ' Region'));
        insert srList;


        system.debug('setup Pricing_Region__c');
        list<Pricing_Region__c> prList = new list<Pricing_Region__c>();
        
        prList.add(new Pricing_Region__c(Name = 'California'));
        prList.add(new Pricing_Region__c(Name = 'Connecticut'));
        prList.add(new Pricing_Region__c(Name = 'Delaware'));
        prList.add(new Pricing_Region__c(Name = 'Maryland'));
        prList.add(new Pricing_Region__c(Name = 'New Jersey'));
        prList.add(new Pricing_Region__c(Name = 'Pennsylvania East'));
        prList.add(new Pricing_Region__c(Name = 'Pennsylvania West'));
        //prList.add(new Pricing_Region__c(Name = ''));
        insert prList;
        
        //Setup State and county for MD
        State__c marylandState = new State__c();
        marylandState.name = 'Maryland';
        marylandState.FIPS_Code__c = '24';
        marylandState.State_Abbreviation__c = 'MD';
        insert marylandState;
        County__c county = new County__c();
        county.Name = 'Howard County, MD';
        county.Pricing_Region__c = prList[3].Id;
        county.Sales_Region__c = 'MD Region';
        county.State__c = marylandState.Id;
        county.FIPS_Code__c = '24027';
        insert county;
        

        //system.debug('setup Lease_Fund__c');
        //list<Lease_Fund__c> lfList = new list<Lease_Fund__c>();
        //lfList.add(new Lease_Fund__c(Name = 'CT Lease Fund', ));
        //insert lfList;


        system.debug('setup AstrumEventSettings__c');
        AstrumEventSettings__c eventsettings = new AstrumEventSettings__c();        
        eventsettings.Default_Onsite_Sales_Visit_Subject__c = 'Sales Visit';
        eventsettings.Number_day_options_to_return__c = 5;
        eventsettings.Number_days_to_schedule_new_visits_out__c = 4;
        eventsettings.Open_Blocks_SOQL__c = 100;
        insert eventsettings;

        createMainofficeSetting();

        system.debug('setup Office_Location__c');
        list<Office_Location__c> olList = new list<Office_Location__c>();
        olList.add(new Office_Location__c(Name = 'Annapolis Junction, MD', Street__c = '8955 Henkels Lane', City__c = 'Annapolis Junction', State__c = 'MD', Zip_Code__c = '20701', Director_of_Operations__c = uid, Sales_Coordinator__c = uid, Sales_Alert_Email__c = uemail, State_Coverage__c = 'MD; DC; VA', Location__Latitude__s = 39.125951, Location__Longitude__s = -76.794940, Active__c = true));        
        olList.add(new Office_Location__c(Name = Main_Office_Location_Settings__c.getOrgDefaults().Name__c, Street__c = '8955 Henkels Lane', City__c = Main_Office_Location_Settings__c.getOrgDefaults().City__c, State__c = 'MD', Zip_Code__c = '20721', Director_of_Operations__c = uid, Sales_Coordinator__c = uid, Sales_Alert_Email__c = uemail, State_Coverage__c = 'MD; DC; VA', Location__Latitude__s = 39.125951, Location__Longitude__s = -76.794940, Active__c = true));
        olList.add(new Office_Location__c(Name = 'Corona, CA', Street__c = '505 E Rincon St#100', City__c = 'Corona', State__c = 'CA', Zip_Code__c = '92879', Director_of_Operations__c = uid, Sales_Coordinator__c = uid, Sales_Alert_Email__c = uemail, State_Coverage__c = 'CA', Location__Latitude__s = 33.886215, Location__Longitude__s = -117.560626, Active__c = true));
        olList.add(new Office_Location__c(Name = 'Henrietta, NY', Street__c = '395 Summit Point Drive', City__c = 'Henrietta', State__c = 'NY', Zip_Code__c = '14467', Director_of_Operations__c = uid, Sales_Coordinator__c = uid, Sales_Alert_Email__c = uemail, State_Coverage__c = '', Location__Latitude__s = 43.056839, Location__Longitude__s = -77.651748, Active__c = true));
        olList.add(new Office_Location__c(Name = 'Hopkinton, MA', Street__c = '15 Avenue E', City__c = 'Hopkinton', State__c = 'MA', Zip_Code__c = '01748', Director_of_Operations__c = uid, Sales_Coordinator__c = uid, Sales_Alert_Email__c = uemail, State_Coverage__c = 'MA', Location__Latitude__s = 42.199145, Location__Longitude__s = -71.542656, Active__c = true));
        olList.add(new Office_Location__c(Name = 'Long Island, NY', Street__c = '626 RexCorp Plaza', City__c = 'Uniondale', State__c = 'NY', Zip_Code__c = '11556', Director_of_Operations__c = uid, Sales_Coordinator__c = uid, Sales_Alert_Email__c = uemail, State_Coverage__c = '', Location__Latitude__s = 40.718761, Location__Longitude__s = -73.586640, Active__c = true));
        olList.add(new Office_Location__c(Name = 'Middletown, NY', Street__c = '28 Industrial Drive', City__c = 'Middletown', State__c = 'NY', Zip_Code__c = '10941', Director_of_Operations__c = uid, Sales_Coordinator__c = uid, Sales_Alert_Email__c = uemail, State_Coverage__c = 'CT', Location__Latitude__s = 41.470589, Location__Longitude__s = -74.372508, Active__c = true));
        olList.add(new Office_Location__c(Name = 'Norristown, PA', Street__c = '705 General Washington Avenue', City__c = 'Norristown', State__c = 'PA', Zip_Code__c = '19403', Director_of_Operations__c = uid, Sales_Coordinator__c = uid, Sales_Alert_Email__c = uemail, State_Coverage__c = '', Location__Latitude__s = 40.127031, Location__Longitude__s = -75.400675, Active__c = true));
        olList.add(new Office_Location__c(Name = 'Youngstown, OH', Street__c = '1104 N. Meridian Road', City__c = 'Youngstown', State__c = 'OH', Zip_Code__c = '44509', Director_of_Operations__c = uid, Sales_Coordinator__c = uid, Sales_Alert_Email__c = uemail, State_Coverage__c = 'OH', Location__Latitude__s = 41.126535, Location__Longitude__s = -80.711205, Active__c = true));
        insert olList;

        system.debug('setup Server_Info__c');        
        Server_Info__c si = new Server_Info__c();
        insert si; //Formula field populates this.

        system.debug('setup Astrum_Application__c');        
        list<Astrum_Application__c> appList = new list<Astrum_Application__c>();
        applist.add(new Astrum_Application__c(Name='Astrum PM 2.0'));
        applist.add(new Astrum_Application__c(Name='Astrum Grants'));
        insert appList;

        system.debug('setup Bin_Configuration__c');
        list<Bin_Configuration__c> binList = new list<Bin_Configuration__c>();

        id aPMid = applist[0].id;
        binList.add(new Bin_Configuration__c(Astrum_Application__c = aPMid, Bin_Column_Width__c = 70, Bin_Grouping_Name__c = 'Pre-Installation', Bin_Grouping_Order__c = 1, Bin_Order__c = 118, Bin__c = 'Finance Notice to Construct', Field_Name__c = 'Lease_Design__c', Installer_Electrician_Access__c = false));
        binList.add(new Bin_Configuration__c(Astrum_Application__c = aPMid, Bin_Column_Width__c = 55, Bin_Grouping_Name__c = 'Pre-Installation', Bin_Grouping_Order__c = 1, Bin_Order__c = 102, Bin__c = 'Kickoff Photos', Field_Name__c = 'Kickoff_Photos__c', Installer_Electrician_Access__c = FALSE));
        binList.add(new Bin_Configuration__c(Astrum_Application__c = aPMid, Bin_Column_Width__c = 80, Bin_Grouping_Name__c = 'Pre-Installation', Bin_Grouping_Order__c = 1, Bin_Order__c = 103, Bin__c = 'Signed Conduit Run and Layout', Field_Name__c = 'Signed_Conduit_Run_and_Layout__c', Installer_Electrician_Access__c = FALSE));
        binList.add(new Bin_Configuration__c(Astrum_Application__c = aPMid, Bin_Column_Width__c = 65, Bin_Grouping_Name__c = 'Pre-Installation', Bin_Grouping_Order__c = 1, Bin_Order__c = 104, Bin__c = 'Drivers Licenses', Field_Name__c = 'Drivers_Licenses__c', Installer_Electrician_Access__c = FALSE));
        binList.add(new Bin_Configuration__c(Astrum_Application__c = aPMid, Bin_Column_Width__c = 55, Bin_Grouping_Name__c = 'Pre-Installation', Bin_Grouping_Order__c = 1, Bin_Order__c = 105, Bin__c = 'Install Prep Sheet', Field_Name__c = 'Install_Prep_Sheet__c', Installer_Electrician_Access__c = FALSE));
        binList.add(new Bin_Configuration__c(Astrum_Application__c = aPMid, Bin_Column_Width__c = 50, Bin_Grouping_Name__c = 'Pre-Installation', Bin_Grouping_Order__c = 1, Bin_Order__c = 106, Bin__c = 'Utility Bill', Field_Name__c = 'Utility_Bill__c', Installer_Electrician_Access__c = FALSE));
        binList.add(new Bin_Configuration__c(Astrum_Application__c = aPMid, Bin_Column_Width__c = 50, Bin_Grouping_Name__c = 'Pre-Installation', Bin_Grouping_Order__c = 1, Bin_Order__c = 107, Bin__c = 'NJ SREC Docs', Field_Name__c = 'NJ_SREC_Docs__c', Installer_Electrician_Access__c = FALSE));
        binList.add(new Bin_Configuration__c(Astrum_Application__c = aPMid, Bin_Column_Width__c = 50, Bin_Grouping_Name__c = 'Pre-Installation', Bin_Grouping_Order__c = 1, Bin_Order__c = 108, Bin__c = 'Permit Design', Field_Name__c = 'Permit_Design__c', Installer_Electrician_Access__c = FALSE));
        binList.add(new Bin_Configuration__c(Astrum_Application__c = aPMid, Bin_Column_Width__c = 70, Bin_Grouping_Name__c = 'Pre-Installation', Bin_Grouping_Order__c = 1, Bin_Order__c = 111, Bin__c = 'Electrical Review', Field_Name__c = 'Electrical_Review__c', Installer_Electrician_Access__c = FALSE));
        binList.add(new Bin_Configuration__c(Astrum_Application__c = aPMid, Bin_Column_Width__c = 60, Bin_Grouping_Name__c = 'Pre-Installation', Bin_Grouping_Order__c = 1, Bin_Order__c = 112, Bin__c = 'Building Permit', Field_Name__c = 'Building_Permit__c', Installer_Electrician_Access__c = FALSE));
        binList.add(new Bin_Configuration__c(Astrum_Application__c = aPMid, Bin_Column_Width__c = 60, Bin_Grouping_Name__c = 'Pre-Installation', Bin_Grouping_Order__c = 1, Bin_Order__c = 113, Bin__c = 'Electrical Permit', Field_Name__c = 'Electrical_Permit__c', Installer_Electrician_Access__c = FALSE));
        binList.add(new Bin_Configuration__c(Astrum_Application__c = aPMid, Bin_Column_Width__c = 80, Bin_Grouping_Name__c = 'Pre-Installation', Bin_Grouping_Order__c = 1, Bin_Order__c = 114, Bin__c = 'Utility Interconnect Part 1', Field_Name__c = 'Approved_Utility_Interconnect_Part_1__c', Installer_Electrician_Access__c = FALSE));
        binList.add(new Bin_Configuration__c(Astrum_Application__c = aPMid, Bin_Column_Width__c = 80, Bin_Grouping_Name__c = 'Pre-Installation', Bin_Grouping_Order__c = 1, Bin_Order__c = 115, Bin__c = 'Grant Reservation', Field_Name__c = 'Grant_Documents__c', Installer_Electrician_Access__c = FALSE));
        binList.add(new Bin_Configuration__c(Astrum_Application__c = aPMid, Bin_Column_Width__c = 80, Bin_Grouping_Name__c = 'Pre-Installation', Bin_Grouping_Order__c = 1, Bin_Order__c = 116, Bin__c = 'HOA Submitted Documents', Field_Name__c = 'HOA_Submitted_Documents__c', Installer_Electrician_Access__c = FALSE));
        binList.add(new Bin_Configuration__c(Astrum_Application__c = aPMid, Bin_Column_Width__c = 80, Bin_Grouping_Name__c = 'Pre-Installation', Bin_Grouping_Order__c = 1, Bin_Order__c = 117, Bin__c = 'Invoice at Start of Installation', Field_Name__c = 'Invoice_at_Start_of_Installation__c', Installer_Electrician_Access__c = FALSE));
        binList.add(new Bin_Configuration__c(Astrum_Application__c = aPMid, Bin_Column_Width__c = 70, Bin_Grouping_Name__c = 'Post-Installation', Bin_Grouping_Order__c = 3, Bin_Order__c = 205, Bin__c = 'Finance Completion Forms', Field_Name__c = 'Lease_Commissioning_Checklist__c', Installer_Electrician_Access__c = TRUE));
        binList.add(new Bin_Configuration__c(Astrum_Application__c = aPMid, Bin_Column_Width__c = 70, Bin_Grouping_Name__c = 'Post-Installation', Bin_Grouping_Order__c = 2, Bin_Order__c = 216, Bin__c = 'Finance Subst. Complete', Field_Name__c = 'Lease_Substantially_Complete_Approval__c', Installer_Electrician_Access__c = FALSE));
        binList.add(new Bin_Configuration__c(Astrum_Application__c = aPMid, Bin_Column_Width__c = 70, Bin_Grouping_Name__c = 'Post-Installation', Bin_Grouping_Order__c = 2, Bin_Order__c = 201, Bin__c = 'Installation Photos', Field_Name__c = 'Installation_Photos__c', Installer_Electrician_Access__c = TRUE));
        binList.add(new Bin_Configuration__c(Astrum_Application__c = aPMid, Bin_Column_Width__c = 75, Bin_Grouping_Name__c = 'Post-Installation', Bin_Grouping_Order__c = 2, Bin_Order__c = 210, Bin__c = 'Panel and Inverter Serial Numbers', Field_Name__c = 'Panel_and_Inverter_Serial_Numbers__c', Installer_Electrician_Access__c = FALSE));
        binList.add(new Bin_Configuration__c(Astrum_Application__c = aPMid, Bin_Column_Width__c = 50, Bin_Grouping_Name__c = 'Post-Installation', Bin_Grouping_Order__c = 2, Bin_Order__c = 215, Bin__c = 'Pull List', Field_Name__c = 'Pull_List__c', Installer_Electrician_Access__c = FALSE));
        binList.add(new Bin_Configuration__c(Astrum_Application__c = aPMid, Bin_Column_Width__c = 60, Bin_Grouping_Name__c = 'Post-Installation', Bin_Grouping_Order__c = 3, Bin_Order__c = 202, Bin__c = 'Enphase', Field_Name__c = 'Enphase_Map__c', Installer_Electrician_Access__c = TRUE));
        binList.add(new Bin_Configuration__c(Astrum_Application__c = aPMid, Bin_Column_Width__c = 80, Bin_Grouping_Name__c = 'Post-Inspection', Bin_Grouping_Order__c = 3, Bin_Order__c = 309, Bin__c = 'Finance Final Complete', Field_Name__c = 'Lease_Final_Package_Approved__c', Installer_Electrician_Access__c = FALSE));
        binList.add(new Bin_Configuration__c(Astrum_Application__c = aPMid, Bin_Column_Width__c = 70, Bin_Grouping_Name__c = 'Post-Inspection', Bin_Grouping_Order__c = 3, Bin_Order__c = 301, Bin__c = 'Proof of Inspection', Field_Name__c = 'Proof_of_Inspection__c', Installer_Electrician_Access__c = FALSE));
        binList.add(new Bin_Configuration__c(Astrum_Application__c = aPMid, Bin_Column_Width__c = 80, Bin_Grouping_Name__c = 'Post-Inspection', Bin_Grouping_Order__c = 3, Bin_Order__c = 303, Bin__c = 'Utility Interconnect Part 2', Field_Name__c = 'Approved_Utility_Interconnect_Part_2__c', Installer_Electrician_Access__c = FALSE));
        binList.add(new Bin_Configuration__c(Astrum_Application__c = aPMid, Bin_Column_Width__c = 80, Bin_Grouping_Name__c = 'Post-Inspection', Bin_Grouping_Order__c = 3, Bin_Order__c = 306, Bin__c = 'Grant Completion', Field_Name__c = 'Grant_Completion__c', Installer_Electrician_Access__c = FALSE));
        binList.add(new Bin_Configuration__c(Astrum_Application__c = aPMid, Bin_Column_Width__c = 50, Bin_Grouping_Name__c = 'Post-Inspection', Bin_Grouping_Order__c = 3, Bin_Order__c = 307, Bin__c = 'SREC Docs', Field_Name__c = 'SREC_Docs__c', Installer_Electrician_Access__c = FALSE));
        binList.add(new Bin_Configuration__c(Astrum_Application__c = aPMid, Bin_Column_Width__c = 80, Bin_Grouping_Name__c = 'Post-Inspection', Bin_Grouping_Order__c = 3, Bin_Order__c = 308, Bin__c = 'Property Tax', Field_Name__c = 'Property_Tax_Approved__c', Installer_Electrician_Access__c = FALSE));

        id aGrantid = applist[1].id;
        binList.add(new Bin_Configuration__c(Astrum_Application__c = aGrantID, Bin_Column_Width__c = 80, Bin_Grouping_Name__c = 'Pre-Installation', Bin_Grouping_Order__c = 1, Bin_Order__c = 108, Bin__c = 'SREC Docs', Field_Name__c = 'SREC_Docs__c', Installer_Electrician_Access__c = FALSE));
        binList.add(new Bin_Configuration__c(Astrum_Application__c = aGrantID, Bin_Column_Width__c = 80, Bin_Grouping_Name__c = 'Pre-Installation', Bin_Grouping_Order__c = 1, Bin_Order__c = 114, Bin__c = 'Grant Reservation', Field_Name__c = 'Grant_Documents__c', Installer_Electrician_Access__c = FALSE));
        binList.add(new Bin_Configuration__c(Astrum_Application__c = aGrantID, Bin_Column_Width__c = 80, Bin_Grouping_Name__c = 'Post-Inspection', Bin_Grouping_Order__c = 3, Bin_Order__c = 306, Bin__c = 'Grant Completion', Field_Name__c = 'Grant_Completion__c', Installer_Electrician_Access__c = FALSE));

        insert binList;

        system.debug('setup Category_Configuration__c');
        list<Category_Configuration__c> catList = new list<Category_Configuration__c>();

        //ASTRUM PM 2.0
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Building Permit', Category_Order_In_Bin__c = 1, Category__c = 'Building Permit Package', Document_Bin_State__c = 'Submitted', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = 'Building_Permit_Submitted__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Building Permit', Category_Order_In_Bin__c = 2, Category__c = 'Approved Building Permit', Document_Bin_State__c = 'Approved', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = 'Building_Permit__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Drivers Licenses', Category_Order_In_Bin__c = 1, Category__c = 'Drivers License', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 0, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Electrical Permit', Category_Order_In_Bin__c = 1, Category__c = 'Electrical Permit Package', Document_Bin_State__c = 'Submitted', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = 'Electrical_Permit_Submitted__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Electrical Permit', Category_Order_In_Bin__c = 2, Category__c = 'Approved Electrical Permit', Document_Bin_State__c = 'Approved', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = 'Electrical_Permit__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Electrical Review', Category_Order_In_Bin__c = 1, Category__c = 'Electrical Drawings', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Electrical Review', Category_Order_In_Bin__c = 3, Category__c = 'Master Electrician Review', Document_Bin_State__c = 'Completed', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = 'Electrical_Review__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Electrical Review', Category_Order_In_Bin__c = 2, Category__c = 'Review Information Submitted', Document_Bin_State__c = 'Submitted', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = 'Electrical_Review_Submitted__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Enphase', Category_Order_In_Bin__c = 1, Category__c = 'Enphase Map', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = TRUE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Enphase', Category_Order_In_Bin__c = 1, Category__c = 'Branch Map', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Finance Completion Forms', Category_Order_In_Bin__c = 4, Category__c = 'Delivered Materials Photo (NRG only)', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = TRUE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Finance Completion Forms', Category_Order_In_Bin__c = 1, Category__c = 'Commissioning and Production Verification Checklists', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = TRUE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Finance Completion Forms', Category_Order_In_Bin__c = 5, Category__c = 'Equip. Signed Confirmation Form (NRG only)', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = TRUE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Finance Completion Forms', Category_Order_In_Bin__c = 2, Category__c = 'Homeowner Acceptance Form (NRG only)', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = TRUE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Finance Completion Forms', Category_Order_In_Bin__c = 3, Category__c = 'Finance Approval to Inspect (NRG only)', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = 'Lease_Approval_To_Inspect__c', Maximum_Allowed__c = 0, Minimum_Required__c = 0, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Finance Final Complete', Category_Order_In_Bin__c = 2, Category__c = 'Finance Final Package Approved', Document_Bin_State__c = 'Completed', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = 'Lease_Final_Package_Approved__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Finance Final Complete', Category_Order_In_Bin__c = 1, Category__c = 'Finance Final Package Submission', Document_Bin_State__c = 'Submitted', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = 'Lease_Final_Package_Submission__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Finance Notice to Construct', Category_Order_In_Bin__c = 2, Category__c = 'Finance Contract Approval', Document_Bin_State__c = 'Signed', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = 'Lease_Contract_Approval__c', Maximum_Allowed__c = 5, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Finance Notice to Construct', Category_Order_In_Bin__c = 3, Category__c = 'Finance Design and Engineering Package', Document_Bin_State__c = 'Submitted', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = 'Lease_Design_Submitted__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Finance Notice to Construct', Category_Order_In_Bin__c = 4, Category__c = 'Package Approval and Notice-to Construct', Document_Bin_State__c = 'Approved', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = 'Lease_Design__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Finance Notice to Construct', Category_Order_In_Bin__c = 1, Category__c = 'Finance Contract Submission', Document_Bin_State__c = 'Ready to Sign', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = 'Lease_Contract_Submission__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Finance Subst. Complete', Category_Order_In_Bin__c = 2, Category__c = 'Finance Procurement Package Approval', Document_Bin_State__c = 'Signed', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = 'Lease_Procurement_Package_Approved__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Finance Subst. Complete', Category_Order_In_Bin__c = 1, Category__c = 'Finance Procurement Package Submission', Document_Bin_State__c = 'Ready to Sign', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = 'Lease_Procurement_Package_Submission__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Finance Subst. Complete', Category_Order_In_Bin__c = 4, Category__c = 'Finance Substantially Complete Approval', Document_Bin_State__c = 'Approved', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = 'Lease_Substantially_Complete__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Finance Subst. Complete', Category_Order_In_Bin__c = 3, Category__c = 'Finance Substantially Complete Package', Document_Bin_State__c = 'Submitted', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = 'Lease_Substantially_Submitted__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Grant Completion', Category_Order_In_Bin__c = 1, Category__c = 'Prepared Application', Document_Bin_State__c = 'Ready to Sign', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = 'Grant_Completion_Completed__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Grant Completion', Category_Order_In_Bin__c = 2, Category__c = 'Signed Application', Document_Bin_State__c = 'Signed', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = 'Grant_Completion_Signed__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Grant Completion', Category_Order_In_Bin__c = 3, Category__c = 'Submitted Application', Document_Bin_State__c = 'Submitted', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = 'Grant_Completion_Submitted__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Grant Completion', Category_Order_In_Bin__c = 4, Category__c = 'Approved Application', Document_Bin_State__c = 'Approved', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = 'Grant_Completion__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Grant Reservation', Category_Order_In_Bin__c = 1, Category__c = 'Prepared Application', Document_Bin_State__c = 'Ready to Sign', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = 'Grant_Reservation_Completed__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Grant Reservation', Category_Order_In_Bin__c = 2, Category__c = 'Signed Application', Document_Bin_State__c = 'Signed', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = 'Grant_Reservation_Signed__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Grant Reservation', Category_Order_In_Bin__c = 3, Category__c = 'Submitted Application', Document_Bin_State__c = 'Submitted', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = 'Grant_Reservation_Submitted__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Grant Reservation', Category_Order_In_Bin__c = 4, Category__c = 'Approved Application', Document_Bin_State__c = 'Approved', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = 'Grant_Documents__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Grant Reservation', Category_Order_In_Bin__c = 5, Category__c = 'Energy Audit', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 0, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'HOA Submitted Documents', Category_Order_In_Bin__c = 1, Category__c = 'HOA Document', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 0, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'HOA Submitted Documents', Category_Order_In_Bin__c = 2, Category__c = 'Historical Document', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 0, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Install Prep Sheet', Category_Order_In_Bin__c = 1, Category__c = 'Install Prep Sheet', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Installation Photos', Category_Order_In_Bin__c = 9, Category__c = 'CB Panel, Interconnect, Disconnect Box Photos', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 3, Installer_Electrician_Access__c = TRUE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Installation Photos', Category_Order_In_Bin__c = 5, Category__c = 'Array Detail Photos: Clearance, Pitch, Clamps', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 3, Installer_Electrician_Access__c = TRUE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Installation Photos', Category_Order_In_Bin__c = 8, Category__c = 'Conduit (Roof, Interior, Exterior) Photos', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 2, Installer_Electrician_Access__c = TRUE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Installation Photos', Category_Order_In_Bin__c = 7, Category__c = 'Roof Grounding Photo', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = TRUE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Installation Photos', Category_Order_In_Bin__c = 1, Category__c = 'Roof Photo', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = TRUE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Installation Photos', Category_Order_In_Bin__c = 2, Category__c = 'Flashing, Rail, Panel Wiring Photos', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 2, Installer_Electrician_Access__c = TRUE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Installation Photos', Category_Order_In_Bin__c = 6, Category__c = 'Roof Electrical Box Photos', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = TRUE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Installation Photos', Category_Order_In_Bin__c = 4, Category__c = 'Final Array Photo', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = TRUE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Installation Photos', Category_Order_In_Bin__c = 3, Category__c = 'Inverter Photo', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = TRUE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Installation Photos', Category_Order_In_Bin__c = 12, Category__c = 'Site Change Photo', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 0, Installer_Electrician_Access__c = TRUE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Installation Photos', Category_Order_In_Bin__c = 10, Category__c = 'Meter and Serial Number Photos', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Installation Photos', Category_Order_In_Bin__c = 11, Category__c = 'Structural Changes Photo', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 0, Installer_Electrician_Access__c = TRUE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Invoice at Start of Installation', Category_Order_In_Bin__c = 1, Category__c = 'Invoice', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 0, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Kickoff Photos', Category_Order_In_Bin__c = 1, Category__c = 'Property Photo', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = 'JPG', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'NJ SREC Docs', Category_Order_In_Bin__c = 2, Category__c = 'NJ SREC Application Package', Document_Bin_State__c = 'Submitted', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = 'NJ_SREC_Application_Package__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'NJ SREC Docs', Category_Order_In_Bin__c = 3, Category__c = 'Acceptance Letter', Document_Bin_State__c = 'Approved', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = 'NJ_SREC_Docs__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'NJ SREC Docs', Category_Order_In_Bin__c = 1, Category__c = 'NJ SREC Registration Form', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 0, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Panel and Inverter Serial Numbers', Category_Order_In_Bin__c = 1, Category__c = 'Serial Numbers', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Permit Design', Category_Order_In_Bin__c = 1, Category__c = 'System Design Plan', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Permit Design', Category_Order_In_Bin__c = 3, Category__c = 'Structural Engineer Review', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = 'Structural_Engineering_Review__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Permit Design', Category_Order_In_Bin__c = 2, Category__c = 'Structural Drawings', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 0, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Proof of Inspection', Category_Order_In_Bin__c = 1, Category__c = 'Proof of Inspection', Document_Bin_State__c = 'Inspected', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Property Tax', Category_Order_In_Bin__c = 1, Category__c = 'Application Submitted', Document_Bin_State__c = 'Submitted', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = 'Property_Tax_Submitted__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Property Tax', Category_Order_In_Bin__c = 2, Category__c = 'Application Approved', Document_Bin_State__c = 'Approved', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = 'Property_Tax_Approved__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Pull List', Category_Order_In_Bin__c = 1, Category__c = 'Pull List', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Signed Conduit Run and Layout', Category_Order_In_Bin__c = 1, Category__c = 'Conduit Run and Layout - Customer Signed', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'SREC Docs', Category_Order_In_Bin__c = 1, Category__c = 'SREC Application Package', Document_Bin_State__c = 'Submitted', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = 'SREC_Application_Package__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'SREC Docs', Category_Order_In_Bin__c = 2, Category__c = 'Certification Document', Document_Bin_State__c = 'Approved', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = 'SREC_Docs__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'SREC Docs', Category_Order_In_Bin__c = 3, Category__c = 'Affidavit', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 0, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'SREC Docs', Category_Order_In_Bin__c = 4, Category__c = 'Schedule A', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 0, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'SREC Docs', Category_Order_In_Bin__c = 5, Category__c = 'Certificate', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 0, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'SREC Docs', Category_Order_In_Bin__c = 6, Category__c = 'REC Purchase Agreement', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 0, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'SREC Docs', Category_Order_In_Bin__c = 7, Category__c = 'SREC Registration Form', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 0, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'SREC Docs', Category_Order_In_Bin__c = 8, Category__c = 'Solar Technical Worksheet', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 0, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'SREC Docs', Category_Order_In_Bin__c = 9, Category__c = 'Site Map', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 0, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'SREC Docs', Category_Order_In_Bin__c = 10, Category__c = 'Contract', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 0, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'SREC Docs', Category_Order_In_Bin__c = 11, Category__c = 'Completion Package', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 0, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'SREC Docs', Category_Order_In_Bin__c = 12, Category__c = 'PV Watts Printout', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 0, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'SREC Docs', Category_Order_In_Bin__c = 13, Category__c = 'Sun Eye Report', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 0, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'SREC Docs', Category_Order_In_Bin__c = 14, Category__c = 'Commissioning Form', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 0, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'SREC Docs', Category_Order_In_Bin__c = 15, Category__c = 'Meter Worksheet', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 0, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'SREC Docs', Category_Order_In_Bin__c = 16, Category__c = 'Recognition of Assignment', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 0, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Sunpower Warranty Cards', Category_Order_In_Bin__c = 1, Category__c = 'Warranty Cards', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 0, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Utility Bill', Category_Order_In_Bin__c = 1, Category__c = 'Utility Bill', Document_Bin_State__c = '', Document_Date_Required__c = FALSE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Utility Interconnect Part 1', Category_Order_In_Bin__c = 1, Category__c = 'Submit Utility Interconnect Part 1', Document_Bin_State__c = 'Submitted', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = 'Submit_Utility_Interconnect_Part_1__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Utility Interconnect Part 1', Category_Order_In_Bin__c = 2, Category__c = 'Approved Utility Interconnect Part 1', Document_Bin_State__c = 'Approved', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = 'Approved_Utility_Interconnect_Part_1__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Utility Interconnect Part 2', Category_Order_In_Bin__c = 1, Category__c = 'Submitted Utility Interconnect Part 2', Document_Bin_State__c = 'Submitted', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = 'Submitted_Utility_Interconnect_Part_2__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aPMid, Bin__c = 'Utility Interconnect Part 2', Category_Order_In_Bin__c = 2, Category__c = 'Approved Utility Interconnect Part 2', Document_Bin_State__c = 'Approved', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = 'Approved_Utility_Interconnect_Part_2__c', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));


        //ASTRUM GRANT
        catList.add(new Category_Configuration__c(Astrum_Application__c = aGrantID, Bin__c = 'Grant Completion', Category_Order_In_Bin__c = 1, Category__c = 'Prepared Application', Document_Bin_State__c = 'Ready to Sign', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aGrantID, Bin__c = 'Grant Completion', Category_Order_In_Bin__c = 2, Category__c = 'Signed Application', Document_Bin_State__c = 'Signed', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 0, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aGrantID, Bin__c = 'Grant Completion', Category_Order_In_Bin__c = 3, Category__c = 'Submitted Application', Document_Bin_State__c = 'Submitted', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aGrantID, Bin__c = 'Grant Completion', Category_Order_In_Bin__c = 4, Category__c = 'Approved Application', Document_Bin_State__c = 'Approved', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aGrantID, Bin__c = 'Grant Reservation', Category_Order_In_Bin__c = 1, Category__c = 'Prepared Application', Document_Bin_State__c = 'Ready to Sign', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aGrantID, Bin__c = 'Grant Reservation', Category_Order_In_Bin__c = 2, Category__c = 'Signed Application', Document_Bin_State__c = 'Signed', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 0, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aGrantID, Bin__c = 'Grant Reservation', Category_Order_In_Bin__c = 3, Category__c = 'Submitted Application', Document_Bin_State__c = 'Submitted', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));
        catList.add(new Category_Configuration__c(Astrum_Application__c = aGrantID, Bin__c = 'Grant Reservation', Category_Order_In_Bin__c = 4, Category__c = 'Approved Application', Document_Bin_State__c = 'Approved', Document_Date_Required__c = TRUE, Document_Types_Restriction__c = '', Field_Name__c = '', Maximum_Allowed__c = 0, Minimum_Required__c = 1, Installer_Electrician_Access__c = FALSE));

        insert catList;

        System_Design_Quote_Settings__c sdqsettings = System_Design_Quote_Settings__c.getOrgDefaults();
        if (sdqsettings != null){
            sdqsettings.County_Pricing_Region_Cutoff_Date__c = Date.newInstance(2015, 12, 1);
            update sdqsettings;
        } else {
            sdqsettings = new System_Design_Quote_Settings__c();
            sdqsettings.County_Pricing_Region_Cutoff_Date__c = Date.newInstance(2015, 12, 1);
            insert sdqsettings;
        }
    }

    public static id setupPropertyWithFieldSurvey() //returns ID of Survey
    {

        //ACCOUNT OBJECTS
        //==============================
        Account customer = new Account(Name = 'Test Customer');
        insert customer;
        //Property__c prop = CreateAstrumPM2ProjectTest.createProperty(customer.Id, '123 Test St');
        /*
        Utility_Company__c uc = new Utility_Company__c();
        uc.Name = 'BG&E';
        uc.States_Serviced__c = 'MD';
        insert uc;
        */
        //Utility Company master
        Utility_Company_Master__c utilCompany = new Utility_Company_Master__c();
        utilCompany.Name = 'BG&E';
        utilCompany.Solar_Compensation_Method__c = 'Net Metering';
        utilCompany.State_Serviced__c = 'MD';
        insert utilCompany;
        
        //Utility Rate Code
        Utility_Company__c urc = new Utility_Company__c();
        urc.Name = 'R1';
        urc.Utility_Company_Master__c = utilCompany.ID;
        urc.All_Electric_Service__c = 'No';
        urc.Utility_Service_Territory__c  = 'Test territory';
        urc.All_Electric_Service__c = 'Not Applicable';        
        insert urc;
        
        Pricing_Region__c mdPricingRegion = new Pricing_Region__c(Name = 'Maryland');
        insert mdPricingRegion;

        //Utility By Zip Code
        Utility_by_Zip_Code__c  utilByZip = new Utility_by_Zip_Code__c();
        utilByZip.Name = 'BG&E';
        utilByZip.Utility_Zip_Code__c = '20701';
        utilByZip.Utility_Company_Master__c = utilCompany.Id;
        utilByZip.Start_Date__c = Date.today().addYears(-2);
        utilByZip.Pricing_Region__c = mdPricingRegion.ID;
        insert utilByZip; 
        /*
        prop.Utility_Company__c = urc.id;
        update prop;
        
        Utility_Service__c utilService = new Utility_Service__c();
        utilService.Amperage__c = double.valueOf('200');
        utilService.Utility_Company__c = uc.Id;
        utilService.Property__c = prop.Id;
        utilService.Service_Account_Number__c = 'abc123';
        insert utilService; 
        */       
        
        //Property
        Property__c prop = new Property__c();
        prop.Name = '123 Main St';
        prop.RecordTypeid = [Select id from RecordType where sobjecttype = 'Property__c' and Name ='Residential' limit 1].id;
        prop.Property_Owner__c = customer.Id;       
        prop.Optimal_Site_Quality_kWh_y_kW__c = double.valueOf('1250');
        prop.Property_State__c = 'MD';
        prop.Property_City__c = 'Annapolis Junction';        
        prop.Property_ZIP__c = '20701';
        prop.Property_County__c = 'Howard';
        prop.Astrum_Office__c = defaultOffLocationName;        
        prop.Sales_Region__c = [select id from Astrum_Sales_Region__c where name='MD Region'].id;  
        prop.QAS_Property_County__c = 'Howard County, MD';    
        //prop.Utility_Company__c = urc.id;
        insert prop;
        
        //Utility Service
        Utility_Service__c utilService = new Utility_Service__c();
        utilService.Amperage__c = double.valueOf('200');
        utilService.Utility_Company__c = urc.Id;
        utilService.Utility_Rate_Code_Before_Solar__c = urc.Id;
        utilService.Utility_Rate_Code_After_Solar__c = urc.Id;
        utilService.Utility_Company_Master__c = utilCompany.ID;
        utilService.Property__c = prop.Id;
        utilService.Service_Account_Number__c = 'abc123';
        insert utilService;

        CB_Panel__c mainPanel = new CB_Panel__c();
        mainPanel.Utility_Service__c = utilService.Id;
        mainPanel.Main_Breaker_Rating_Amps__c = Double.valueOf('200');        
        insert mainPanel;        
       
        Survey__c surv = new Survey__c();
        surv.Property__c = prop.Id;
        surv.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'Survey__c' and r.Name = 'Field Survey'].id;        
        insert surv;       
                
            //Insert Physical Surface
        
            //     a.    Physical Surface
            //i.    Fields to Create
            //  1.  prop – Master-Detail(prop)
            //  2.  Surface Tilt – Number (17,1)
            //  3.  Surface Azimuth – Number (17,1)
            //  4.  Physical Surface Name – Physical Surface Record ID
            //  5.  Trenching Distance to Interconnection Point (ft) – Number (18,0)
            //  6.  Suneye Tilt & Orientation Factor (TOF) – Percentage (17,1)
        
        
        Physical_Surface__c ps = new Physical_Surface__c();
        ps.Property__c = prop.Id; //New link to prop
        ps.Surface_Tilt__c = 10;
        ps.Surface_Azimuth__c = 90;
        ps.Trenching_Dist_to_Intercon_Pt_ft__c = 10;
        ps.Suneye_Tilt_and_Orien_Factor__c = 2;        
        ps.Physical_Surface_Assigned_Letter__c = 'A'; //MK 2014-05-02
        ps.Surface_Type__c = 'Asphalt Shingle';//MK 2014-05-02
        insert ps;
        //MK 2014-05-02
        //Get PS in order to get the default mounting type
        ps = [select id, Default_Mounting_Type__c, Default_Mounting__c, Property__c, Surface_Tilt__c, Surface_Azimuth__c,
                Trenching_Dist_to_Intercon_Pt_ft__c, Suneye_Tilt_and_Orien_Factor__c, Surface_Type__c, 
                Name, Physical_Surface_Assigned_Letter__c from Physical_Surface__c where id =: ps.id];
        
        Install_Location__c instLoc = new Install_Location__c();
        instLoc.Physical_Surface__c = ps.id; //This is the master relationship now
        //instLoc.Property__c = prop.Id; //MK 2014-05-02        
        instLoc.Location__c = 'S01';//MK 2014-05-02        
        instLoc.Survey__c = surv.id;//MK 2014-05-02
        instLoc.Azimuth__c = double.valueOf('180');
        instLoc.Pitch__c = double.valueOf('23');
        instLoc.TSRF__c = double.valueOf('90');
        insert instLoc;
        
        return surv.id;

   }


    //MK - 2014-04-08

    public static id setupSystemDesign(string propType, string finType, id LeaseFund, boolean commProgram, double siteQuality) //returns ID of System Design
    {
        //USAGE:        
        ////Create system design and related items
        //id sdID = testData.setupSystemDesign('Residential', 'Purchase', null, true, 12000);

        //ACCOUNT OBJECTS
        //==============================
        Account acct = new Account();
        acct.name='TestAcct';        
        insert acct;

        //Insert Community Program Offer under any Account
        
   //       1.  Account – Master-Detail(Account)
            //2.    Baseline Site Quality – Number (18,0)
            //3.    Current Tier – Picklist (1,2,3,4,5)
            //4.    Early Adopter Promotion – Currency (16,2)
            //5.    Early Adopter Promotion Available – Checkbox
            //6.    Eligible ZIP Codes – Text
        
        Community_Program_Offer__c cpo = new Community_Program_Offer__c();
        cpo.Account__c = acct.id;
        cpo.Baseline_Site_Quality__c = 2000;
        cpo.Current_Tier__c = '1';
        cpo.Early_Adopter_Promotion__c = 100;
        cpo.Early_Adopter_Promotion_Available__c = true;
        //cpo.Eligible_Zip_Codes__c = '20701';
        insert cpo;
        
        Property__c prop = new Property__c();
        prop.Name = '123 Main St';
        prop.RecordTypeid = [Select id from RecordType where sobjecttype = 'Property__c' and Name =: propType limit 1].id;
        prop.Property_Owner__c = acct.Id;       
        prop.Optimal_Site_Quality_kWh_y_kW__c = double.valueOf('1250');
        prop.Property_State__c = 'MD';
        prop.Property_City__c = 'Annapolis Junction';        
        prop.Property_ZIP__c = '20701';
        prop.Property_County__c = 'Howard';
        prop.Astrum_Office__c = defaultOffLocationName;        
        prop.Sales_Region__c = [select id from Astrum_Sales_Region__c where name='MD Region'].id;  
        prop.QAS_Property_County__c = 'Howard County, MD';    //DK 12-23-14
        insert prop;
        
        //DK  11-25-14
        Utility_Company_Master__c utilCompany = new Utility_Company_Master__c();
        utilCompany.Name = 'BG&E';
        utilCompany.Solar_Compensation_Method__c = 'Net Metering';
        utilCompany.State_Serviced__c = 'MD';
        insert utilCompany;

        Utility_Company__c urc = new Utility_Company__c();
        urc.Name = 'BG&E';
        urc.Utility_Company_Master__c = utilCompany.ID;
        urc.All_Electric_Service__c = 'No';
        urc.Baseline_Consumption_kWh_day__c = '10.1;10.1;10.1;10.1;9.6;9.6;9.6;9.6;9.6;9.6;10.1;10.1';
        urc.Baseline_Consumption_kWh_month__c = 'NA';
        urc.Tier_1_Cap__c = 100;
        urc.Tier_2_Cap__c = 120;
        urc.Tier_3_Cap__c = 150;
        urc.Tier_4_Cap__c = 200;
        urc.Tier_5_Cap__c = 225;
        urc.Average_Consumption_Profile__c = '3.3;3.0;2.9;2.8;2.9;3.2;3.9;4.4;4.4;4.3;4.3;4.1;4.0;3.9;3.8;3.9;4.3;5.4;5.9;5.9;5.7;5.3;4.6;3.8;3.3;3.0;2.9;2.8;2.9;3.3;4.0;4.5;4.4;4.4;4.3;4.1;4.0;3.9;3.8;3.8;4.2;5.0;5.9;5.9;5.8;5.3;4.6;3.8;3.3;3.0;2.8;2.8;2.9;3.2;4.0;4.5;4.4;4.3;4.3;4.2;4.1;4.0;3.9;3.9;4.2;4.7;5.5;5.9;5.9;5.5;4.7;3.9;3.3;3.0;2.8;2.8;2.8;3.1;3.8;4.3;4.3;4.3;4.3;4.3;4.2;4.2;4.1;4.1;4.3;4.7;5.1;5.5;6.0;5.7;4.8;4.0;3.3;3.0;2.8;2.7;2.7;2.9;3.5;3.9;3.9;4.0;4.1;4.1;4.2;4.2;4.3;4.5;4.9;5.2;5.4;5.5;5.9;5.8;4.9;4.0;3.3;2.9;2.7;2.6;2.5;2.7;3.0;3.3;3.5;3.7;3.9;4.1;4.3;4.5;4.8;5.1;5.4;5.8;5.9;5.7;5.7;5.7;4.9;4.0;3.3;2.9;2.6;2.5;2.4;2.5;2.7;3.0;3.3;3.5;3.7;4.0;4.4;4.7;5.1;5.4;5.8;6.1;6.2;5.9;5.8;5.6;4.8;3.9;3.2;2.8;2.6;2.5;2.5;2.6;2.9;3.1;3.3;3.5;3.7;3.9;4.2;4.6;4.9;5.4;5.8;6.1;6.2;6.0;6.0;5.6;4.7;3.9;3.2;2.9;2.7;2.6;2.6;2.8;3.2;3.5;3.5;3.7;3.8;3.9;4.1;4.4;4.7;5.1;5.4;5.8;5.9;6.1;6.1;5.5;4.7;3.8;3.3;3.0;2.8;2.8;2.8;3.1;3.7;4.2;4.2;4.2;4.2;4.2;4.1;4.1;4.1;4.3;4.5;5.0;5.6;6.1;5.9;5.4;4.6;3.8;3.2;2.9;2.8;2.8;2.8;3.2;3.9;4.4;4.4;4.3;4.3;4.2;4.1;4.0;3.9;4.0;4.5;5.6;6.0;5.9;5.7;5.2;4.5;3.7;3.3;3.0;2.8;2.8;2.8;3.1;3.7;4.2;4.3;4.3;4.2;4.1;4.0;3.9;3.8;3.9;4.4;5.6;6.0;6.0;5.8;5.4;4.7;3.9;';
        urc.Weekend_Schedule__c = '111111111111111111111111222111111111111111111111111111111133111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';
        urc.Weekday_Schedule__c  = '111111111111111111111111111111111111111111111111221111111111111111111111111111133333311111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';
        insert urc;

        Survey__c surv = new Survey__c();
        surv.Property__c = prop.Id;
        surv.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'Survey__c' and r.Name = 'Field Survey'].id;        
        insert surv;
        
        Utility_Service__c utilService = new Utility_Service__c();
        utilService.Amperage__c = double.valueOf('200');
        utilService.Utility_Company__c = urc.Id;
        utilService.Utility_Rate_Code_Before_Solar__c = urc.Id;
        utilService.Utility_Rate_Code_After_Solar__c = urc.Id;
        utilService.Utility_Company_Master__c = utilCompany.ID;
        utilService.Property__c = prop.Id;
        utilService.Service_Account_Number__c = 'abc123';
        utilService.Monthly_Electric_Consumption_KWH_Jan__c = 300;
        utilService.Monthly_Electric_Consumption_KWH_Feb__c = 320;
        utilService.Monthly_Electric_Consumption_KWH_Mar__c = 330;
        utilService.Monthly_Electric_Consumption_KWH_Apr__c = 340;
        utilService.Monthly_Electric_Consumption_KWH_May__c = 350;
        utilService.Monthly_Electric_Consumption_KWH_Jun__c = 360;
        utilService.Monthly_Electric_Consumption_KWH_Jul__c = 370;
        utilService.Monthly_Electric_Consumption_KWH_Aug__c = 370;
        utilService.Monthly_Electric_Consumption_KWH_Sep__c = 360;
        utilService.Monthly_Electric_Consumption_KWH_Oct__c = 350;
        utilService.Monthly_Electric_Consumption_KWH_Nov__c = 340;
        utilService.Monthly_Electric_Consumption_KWH_Dec__c = 330;
        insert utilService;
        

        CB_Panel__c mainPanel = new CB_Panel__c();
        mainPanel.Name = 'Suniva';
        mainPanel.Utility_Service__c = utilService.Id;
        mainPanel.Main_Breaker_Rating_Amps__c = Double.valueOf('200');
        System.debug('mainPanel --> ' + mainPanel);      
        insert mainPanel;
        
        
        //Insert Physical Surface
        
   //     a.    Physical Surface
            //i.    Fields to Create
            //  1.  Property – Master-Detail(Property)
            //  2.  Surface Tilt – Number (17,1)
            //  3.  Surface Azimuth – Number (17,1)
            //  4.  Physical Surface Name – Physical Surface Record ID
            //  5.  Trenching Distance to Interconnection Point (ft) – Number (18,0)
            //  6.  Suneye Tilt & Orientation Factor (TOF) – Percentage (17,1)
        
        
        Physical_Surface__c ps = new Physical_Surface__c();
        ps.Property__c = prop.Id; //New link to property
        ps.Surface_Tilt__c = 10;
        ps.Surface_Azimuth__c = 90;
        ps.Trenching_Dist_to_Intercon_Pt_ft__c = 10;
        ps.Suneye_Tilt_and_Orien_Factor__c = 2;        
        ps.Physical_Surface_Assigned_Letter__c = 'A'; //MK 2014-05-02
        ps.Surface_Type__c = 'Asphalt Shingle';//MK 2014-05-02
        insert ps;        

        //MK 2014-05-02
        //Get PS in order to get the default mounting type
        ps = [select id, Default_Mounting_Type__c, Property__c, Surface_Tilt__c, Surface_Azimuth__c,
                Trenching_Dist_to_Intercon_Pt_ft__c, Suneye_Tilt_and_Orien_Factor__c, Surface_Type__c, 
                Name, Physical_Surface_Assigned_Letter__c from Physical_Surface__c where id =: ps.id];



        Install_Location__c instLoc = new Install_Location__c();
        instLoc.Physical_Surface__c = ps.id; //This is the master relationship now
        //instLoc.Property__c = prop.Id; //MK 2014-05-02        
        instLoc.Location__c = 'S01';//MK 2014-05-02        
        instLoc.Survey__c = surv.id;//MK 2014-05-02
        instLoc.Azimuth__c = double.valueOf('180');
        instLoc.Pitch__c = double.valueOf('23');
        instLoc.TSRF__c = double.valueOf('90');
        insert instLoc;
        
        


        //SYSTEM DESIGN OBJECTS
        //==============================
        System_Design_Product__c sdp = new System_Design_Product__c();
        sdp.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Product__c' and r.Name = 'Panel'].id;
        sdp.Description__c  = 'Sanyo 215';
        sdp.End_Clamp_Type__c = 'F End Clamp';  
        sdp.Make__c  = 'Sanyo';
        sdp.Max_Voltage__c = double.valueOf('600');
        sdp.Mid_Clamp_Type__c = 'F Mid Clamp';  
        sdp.Model__c = 'HIT Power 215N';
        sdp.Rated_Output_W__c = double.valueOf('300');
        sdp.Unit__c = 'Count';
        insert sdp;
        
        System_Design_Product__c sdp1 = new System_Design_Product__c();
        sdp1.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Product__c' and r.Name = 'Inverter'].id;
        sdp1.Description__c  = 'M215-60-240-S22';
        sdp1.End_Clamp_Type__c = 'F End Clamp';  
        sdp1.Make__c  = 'Enphase';
        sdp1.Max_Voltage__c = double.valueOf('600');
        sdp1.Mid_Clamp_Type__c = 'F Mid Clamp';  
        sdp1.Model__c = 'M215-60-240-S22';
        sdp1.Rated_Output_W__c = double.valueOf('300');
        sdp1.Unit__c = 'Count';
        insert sdp1;
        
        System_Design__c sd = new System_Design__c();
        sd.Property__c = prop.Id;        
        sd.Calculated_System_Price__c = decimal.valueOf('100000.25');
        sd.Default_CB_Panel__c = mainPanel.ID;    //DK 12-22-14
        sd.System_Inverter__c = sdp1.ID;
        //sd.NRG_Overall_Site_Quality__c = siteQuality;
        //sd.Sunnova_Overall_Site_Quality__c = siteQuality;
        insert sd;
                
        System_Design_Array__c sda = new System_Design_Array__c();
        sda.CB_Panel__c = mainPanel.Id;
        sda.System_Design__c = sd.Id;
        sda.Physical_Surface__c = ps.id;//MK 2014-05-02
        sda.Survey__c = surv.id;//MK 2014-05-02
        sda.Mounting_Type__c = ps.Default_Mounting_Type__c;//MK 2014-05-02
        insert sda;

        System_Design_Item__c sdi = new System_Design_Item__c();
        sdi.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Item__c' and r.Name = 'Panel'].id;
        sdi.System_Design_Array__c = sda.Id;
        sdi.Install_Location__c = instLoc.Id;
        sdi.System_Design_Product__c = sdp.Id;
        sdi.Quantity__c = double.valueOf('10');
        sdi.Annual_Solar_Access__c = double.valueOf('90');
        sdi.NRG_Site_Quality__c = siteQuality;
        sdi.Sunnova_Site_Quality__c = siteQuality;
        sdi.Astrum_PV_Watts_Site_Quality__c = siteQuality;
        sdi.Method_1_Period_1_Production_kWh__c = '103;120;124;144;149;149;152;151;124;135;115;70;';
        sdi.Method_1_Period_2_Production_kWh__c = '103;120;124;144;149;149;152;151;124;135;115;70;';
        sdi.Method_1_Period_3_Production_kWh__c = '103;120;124;144;149;149;152;151;124;135;115;70;';
        sdi.Method_1_Period_4_Production_kWh__c = '103;120;124;144;149;149;152;151;124;135;115;70;';
        sdi.Method_1_Period_5_Production_kWh__c = '103;120;124;144;149;149;152;151;124;135;115;70;';
        sdi.Method_1_Period_6_Production_kWh__c = '103;120;124;144;149;149;152;151;124;135;115;70;';
        insert sdi;





        //PRICING DEPENDANT OBJECTS
        //==============================



        //Insert System Pricing Table  ((((This is for panel pricing))))
        
   //       1.  Panel Type – Master-Detail(System Design Product)
            //2.    Sales Region – Lookup (Sales Region)
            //3.    Financing Type – Picklist (Purchase, Lease)
            //4.    Lease Fund – Lookup (Lease Fund)
            //5.    Community Program Offer – Lookup (Community Program Offer)
            //6.    Community Program Tier – Picklist (1,2,3,4,5)
            //7.    Start Date – Date
            //8.    End Date – Date
            //9.    Count N Root Price – Number (18,0) – create for N = 1-400
            //10.   System Pricing Table ID – Record ID
        Pricing_Region__c pricingRegion = new Pricing_Region__c(Name = 'Maryland');
        insert pricingRegion;

        //For Panel
        System_Pricing_Table__c spt = new System_Pricing_Table__c();
        spt.Panel_Type__c = sdp.id;
        spt.Sales_Region__c = prop.Sales_Region__c;
        spt.Pricing_Region__c = pricingRegion.ID; 
        spt.Financing_Type__c = finType;        
        if(leaseFund != null) spt.Lease_Fund__c = leaseFund; 
        if(commProgram) spt.Community_Program_Offer__c = cpo.id;
        spt.Community_Program_Tier__c = '1';
        spt.Start_Date__c = date.today().addDays(-1);
        spt.End_Date__c = date.today().addDays(1);
        spt.count_10_root_price__c = 2500;
        spt.count_20_root_price__c = 2470;
        spt.count_30_root_price__c = 2450;
        spt.Unique_ID__c = 'ThisFieldIsRequiredSoWeMustSetIt4321';    //DK 11-3-14
        insert spt;

             
        

        //Insert SDP Price Entry under SDP   ((((This is for non-panel pricing))))
        
   //       i.  Record Types to Create
            //  1.  Panel
            //  2.  Inverter
            //  3.  Mounting
            //  4.  Trenching
            //  5.  Labor
            //  6.  Special Part
            //ii.   Fields to Create
            //  1.  System Design Product – Master-Detail(System Design Product)
            //  2.  Start Date – Date
            //  3.  End Date – Date
            //  4.  Property Record Type – Picklist (Residential, Commercial)
            //  5.  Financing Type – Picklist (Purchase, Lease)
            //  6.  Lease Fund – Lookup (Lease Fund)
            //  7.  Community Program Offer – Lookup (Community Program Offer)
            //  8.  Adder ($/W) – Currency (16,2) (Record Type = ‘Panel’, ‘Inverter’, ‘Mounting’, ’Trenching’, ‘Labor’)
            //  9.  Adder (ea) – Currency (16,2) (Record Type = ‘Special Part’)
            //  10. SDP Price Entry ID – ID
        
        //For inverter
        SDP_Price_Entry__c sdpPE = new SDP_Price_Entry__c();
        sdpPE.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'SDP_Price_Entry__c' and r.Name = 'Inverter'].id;
        sdpPE.System_Design_Product__c = sdp1.id;
        sdpPE.Start_Date__c = date.today();
        sdpPE.End_Date__c = date.today();
        sdpPE.Property_Record_Type__c = propType;
        sdpPE.Financing_Type__c = finType;
        if(leaseFund != null) sdpPE.Lease_Fund__c = leaseFund;
        if(commProgram) sdpPE.Community_Program_Offer__c = cpo.id;
        sdpPE.Adder_W__c = 3; //For (Record Type = ‘Panel’, ‘Inverter’, ‘Mounting’, ’Trenching’, ‘Labor’)
        //sdpPE.Adder_ea__c = 2; //For (Record Type = ‘Special Part’)
        sdpPE.Unique_ID__c = 'ThereIsNoWayThatThisStringIsNotUnique12345';    //DK 11-2-14
        insert sdpPE;


 
        //TODO: Add price for trenching to test the non-community program pricing structure




        


        //TODO: Insert Lease Adjustment Table
        
   //       1.  State – Picklist 
            //2.    Sales Region – Lookup (Sales Region)
            //3.    Escalator Value – Percentage (16,2)
            //4.    Escalator Adjustment – Currency (13,5)
            //5.    Lease Fund – Lookup (Lease Fund)
            //6.    SQ Threshold 1 – Number (18,0)
            //7.    SQ Threshold 1 Adjustment – Currency (13,5)
            //8.    SQ Threshold 2 – Number (18,0)
            //9.    SQ Threshold 2 Adjustment – Currency (13,5)
            //10.   SQ Adjustment Type – Picklist (1,2,3)
            //11.   Utility Threshold – Currency (13,5)
            //12.   Utility Multiplier –  Number (13,5)
            //13.   Start Date – Date
            //14.   End Date – Date
            //15.   Minimum Size – Number (15,3)
            //16.   Maximum Size – Number (15,3)
            //17.   Community Program Offer – Lookup (Community Program)
            //18.   Down Payment Multiplier – Number (13,5)
            //19.   Lease Adjustment Table ID – Record ID
        




        return sd.id;

   }

  
   public static Property__c CreateTestProp(String AcctId,ID ucid){
       Property__c prop = new Property__c();
       prop.Name = '123 Main St';
       prop.Property_Owner__c = AcctId;
       
        prop.Optimal_Site_Quality_kWh_y_kW__c = double.valueOf('1250');
        prop.Property_State__c = 'MD';
        prop.Property_City__c = 'Annapolis Junction';
        prop.Property_ZIP__c = '20701';
        prop.Permit_Jurisdiction__c = 'Howard';
        prop.Property_County__c = 'Howard';
        prop.Astrum_Office__c = defaultOffLocationName;
        prop.Utility_Company__c = ucid;       
        insert prop;
        
       
       return prop;
    }
  
  public static Opportunity CreateTestOpp(){

        Utility_Company__c uc = new Utility_Company__c();
        uc.Name = 'BG&E';
        uc.States_Serviced__c = 'MD';
        uc.Weekend_Schedule__c = '111111111111111111111111222111111111111111111111111111111133111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';
        uc.Weekday_Schedule__c  = '111111111111111111111111111111111111111111111111221111111111111111111111111111133333311111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';
        insert uc;
        
        List<Rate_Period__c> rps = new List<Rate_Period__c>();
        Rate_period__c rp = new Rate_period__c();
        rp.Period_Type__c = 'Peak';
        rp.Name = 'Period 1';
        rp.Utility_Company__c = uc.Id;
        rp.Rate_Period__c = 1;
        rps.add(rp);

        Rate_period__c rp1 = new Rate_period__c();
        rp1.Period_Type__c = 'Part_Peak';
        rp1.Name = 'Period 2';
        rp1.Utility_Company__c = uc.id;
        rp1.Rate_Period__c = 2;
         rps.add(rp1);

        Rate_period__c rp2 = new Rate_period__c();
        rp2.Period_Type__c = 'Off_Peak';
        rp2.Name = 'Period 3';
        rp2.Utility_Company__c = uc.id;
        rp2.Rate_Period__c = 3;
        rps.add(rp2);

        insert rps;
        //Populate the Opportunity ID query parameter
       Account acct = new Account();
       acct.name='TestAcct';
       insert acct;
       System.Debug('Account:' + acct.id);
       
       Opportunity op = new Opportunity(); 
       OpportunityLineItem li= new OpportunityLineItem();
       List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
       Product2 product = new Product2();
       product.Name='testProduct223';
       insert product;
       PriceBook2 pbook2=[select id, Name from PriceBook2 where Name='Standard Price Book'];
              
       PriceBookEntry prod = new PricebookEntry();
       prod.UnitPrice = 2.32;
       prod.PriceBook2Id = pbook2.id;
       prod.UseStandardPrice=FALSE;
       prod.Product2ID=product.id;
       prod.IsActive     = true;
       insert prod;
       
       System.debug('Account Created with Id --> ' + acct.id);
       op.AccountId = acct.id;
       op.Name='Test Opportunity223';
       op.StageName = 'Submit Pending';
       op.CloseDate= Date.Today();
       op.Financing_Type__c = 'Purchase';
       op.Financing_Option__c = 'No Financing';
       op.Leasing_Option__c = null;
       
       Property__c prop = CreateTestProp(acct.id,uc.id);
       
      
       
        Survey__c surv = new Survey__c();
        surv.Property__c = prop.Id;
        surv.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'Survey__c' and r.Name = 'Field Survey'].id;
        
        insert surv;
        
      Utility_Service__c utilService = new Utility_Service__c();
      utilService.Amperage__c = double.valueOf('200');
      utilService.Utility_Company__c = uc.id;
      utilService.Property__c = prop.Id;
      utilService.Service_Account_Number__c = 'abc123';
      insert utilService;
      
      CB_Panel__c mainPanel = new CB_Panel__c();
      mainPanel.Utility_Service__c = utilService.Id;
      mainPanel.Main_Breaker_Rating_Amps__c = double.valueOf('200');
      
      insert mainPanel;      
      
      //MK 2014-05-02 - Move survey creation first so we can connect install locations to it

        //MK 2014-05-02
        //Insert Physical Surface & link survey        
        Physical_Surface__c ps = new Physical_Surface__c();
        ps.Property__c = prop.Id; //New link to property
        ps.Surface_Tilt__c = 10;
        ps.Surface_Azimuth__c = 90;
        ps.Trenching_Dist_to_Intercon_Pt_ft__c = 10;
        ps.Suneye_Tilt_and_Orien_Factor__c = 2;        
        ps.Physical_Surface_Assigned_Letter__c = 'A'; //MK 2014-05-02
        ps.Surface_Type__c = 'Asphalt Shingle';//MK 2014-05-02
        insert ps;
        //MK 2014-05-02
        //Get PS in order to get the default mounting type
        ps = [select id, Default_Mounting_Type__c, Property__c, Surface_Tilt__c, Surface_Azimuth__c,
                Trenching_Dist_to_Intercon_Pt_ft__c, Suneye_Tilt_and_Orien_Factor__c, Surface_Type__c, 
                Name, Physical_Surface_Assigned_Letter__c from Physical_Surface__c where id =: ps.id];

             
        Install_Location__c instLoc = new Install_Location__c();        
        instLoc.Location__c = 'S01';//MK 2014-05-02
        instLoc.Physical_Surface__c = ps.id;//MK 2014-05-02
        instLoc.Survey__c = surv.id;//MK 2014-05-02
        //instLoc.Property__c = propt.Id; //MK 2014-05-02
        instLoc.Azimuth__c = double.valueOf('180');
        instLoc.Pitch__c = double.valueOf('23');
        instLoc.TSRF__c = double.valueOf('90');
        insert instLoc;
        
        
        System_Design__c sd = new System_Design__c();
        sd.Property__c = prop.Id;
        insert sd;
                
        
    System_Design_Array__c sda = new System_Design_Array__c();
    sda.CB_Panel__c = mainPanel.Id;
        sda.System_Design__c = sd.Id;
        sda.Physical_Surface__c = ps.id;//MK 2014-05-02
        sda.Survey__c = surv.id;//MK 2014-05-02
        sda.Mounting_Type__c = ps.Default_Mounting_Type__c;//MK 2014-05-02
        insert sda;
        

        System_Design_Product__c sdp = new System_Design_Product__c();
        sdp.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Product__c' and r.Name = 'Panel'].id;
        sdp.Description__c  = 'Sanyo 215';
        sdp.End_Clamp_Type__c = 'F End Clamp';  
        sdp.Make__c  = 'Sanyo';
        sdp.Max_Voltage__c = double.valueOf('600');
        sdp.Mid_Clamp_Type__c = 'F Mid Clamp';  
        sdp.Model__c = 'HIT Power 215N';
        sdp.Rated_Output_W__c = double.valueOf('215');  
        sdp.Unit__c = 'Count';
        insert sdp;
                
        
        System_Design_Item__c sdi = new System_Design_Item__c();
        sdi.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Item__c' and r.Name = 'Panel'].id;
        sdi.System_Design_Array__c = sda.Id;
        sdi.Install_Location__c = instLoc.Id;
        sdi.System_Design_Product__c = sdp.Id;
        sdi.Quantity__c = double.valueOf('29');
        sdi.Annual_Solar_Access__c = double.valueOf('100');
        sdi.NRG_Site_Quality__c= double.valueOf('90');
        sdi.Rated_Output_kW__c = 12;
        sdi.Tilt__c = double.valueOf('3');
        sdi.Azimuth__c = double.valueOf('3');
        sdi.Astrum_PV_Watts_Site_Quality__c = double.valueOf('1200');
        insert sdi;
        
        sd.Calculated_System_Price__c = decimal.valueOf('100000.25');
        update(sd);
        
        System_Design_Quote__c sdq = new System_Design_Quote__c();
        sdq.System_Design__c = sd.Id;
        
        system.debug('SDA --> ' + [Select s.System_Design__c, s.SystemModstamp, s.Special_Parts_Required__c, s.Projected_Annual_Output_kWh_y__c, s.Panel_Count__c, s.Name, s.Mounting_Type__c, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Id, s.Electrical_Adder__c, s.CreatedDate, s.CreatedById, s.ConnectionSentId, s.ConnectionReceivedId, s.CB_Panel__c, s.Array_Size_kW__c From System_Design_Array__c s where s.Id = :sda.Id]);
        system.debug('SD --> ' + [Select s.Total_System_Size_kW__c, s.Total_Projected_Annual_Output_kWh_y__c, s.SystemModstamp, s.Survey__c, s.Property__c, s.Panel_Count__c, s.Overall_TSRF__c, s.Overall_Site_Quality__c, s.Notes__c, s.Name, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Id, s.CreatedDate, s.CreatedById, s.ConnectionSentId, s.ConnectionReceivedId, s.Calculated_System_Price__c, s.Calculated_Price_per_Watt__c, s.Account_Number__c From System_Design__c s where s.Id = :sd.Id]);
        insert sdq;
        
        op.SREC__c = 'Yearly';
        op.State_Grant_Amount__c = double.valueOf('100.00');
        op.System_Design_Quote__c = sdq.Id;       
       
        op.Property__c = prop.id;
       
        insert op;
       
        return op;
    }   

    public static Data_Tracking_Project__c createDtpWithAllData(){

        Data_Tracking_Project__c dtp= new Data_Tracking_Project__c();

        Utility_Company__c uc = new Utility_Company__c();
        uc.Name = 'BG&E';
        uc.States_Serviced__c = 'MD';
        uc.Weekend_Schedule__c = '111111111111111111111111222111111111111111111111111111111133111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';
        uc.Weekday_Schedule__c  = '111111111111111111111111111111111111111111111111221111111111111111111111111111133333311111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';
        insert uc;
        
        List<Rate_Period__c> rps = new List<Rate_Period__c>();
        Rate_period__c rp = new Rate_period__c();
        rp.Period_Type__c = 'Peak';
        rp.Name = 'Period 1';
        rp.Utility_Company__c = uc.id;
        rp.Rate_Period__c = 1;
        rps.add(rp);

        Rate_period__c rp1 = new Rate_period__c();
        rp1.Period_Type__c = 'Part_Peak';
        rp1.Name = 'Period 2';
        rp1.Utility_Company__c = uc.id;
        rp1.Rate_Period__c = 2;
         rps.add(rp1);

        Rate_period__c rp2 = new Rate_period__c();
        rp2.Period_Type__c = 'Off_Peak';
        rp2.Name = 'Period 3';
        rp2.Utility_Company__c = uc.id;
        rp2.Rate_Period__c = 3;
        rps.add(rp2);

        insert rps;

        Account acct = new Account();
        acct.name = 'Smith, John';
        insert acct;
        dtp.Account__c = acct.id;
        
        //Community Program Offer under any Account 
        Community_Program_Offer__c cpo = new Community_Program_Offer__c();
        cpo.Account__c = acct.id;
        cpo.Baseline_Site_Quality__c = 2000;
        cpo.Current_Tier__c = '1';
        cpo.Early_Adopter_Promotion__c = 100;
        cpo.Early_Adopter_Promotion_Available__c = true;
        cpo.Start_Date__c = Date.today().toStartOfMonth();
        cpo.Extension_End_Date__c = Date.today().addMonths(1).addDays(15);
        cpo.Initial_End_Date__c = Date.today().addMonths(1);
        //cpo.Eligible_Zip_Codes__c = '20701';
        insert cpo;

        Contact c = new Contact();
        c.FirstName = 'John';
        c.LastName = 'Smith';
        c.AccountId = acct.id;
        insert c;

        Property__c propt = new Property__c();
        propt.Name = '123 Test St';
        propt.Property_Owner__c = acct.id;
        propt.Optimal_Site_Quality_kWh_y_kW__c = double.valueOf('1250');
        propt.Property_State__c = 'MD';
        propt.Property_City__c = 'Annapolis Junction';
        propt.Property_ZIP__c = '20701';
        propt.Permit_Jurisdiction__c = 'Howard';
        propt.Property_County__c = 'Howard';
        propt.Astrum_Office__c = defaultOffLocationName;
        propt.Hours_From_Nearest_Office__c = 1.0;
          propt.Utility_Company__c =  uc.id; 
        insert propt;
        dtp.Property__c = propt.id;

        //MK 2014-05-02 - Move survey creation first so we can connect install locations to it
        Survey__c surv = new Survey__c();
        surv.Property__c = propt.id;
        surv.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'Survey__c' and r.Name = 'Field Survey'].id;                
        insert surv;

        //MK 2014-05-02
        //Insert Physical Surface & link survey        
        Physical_Surface__c ps = new Physical_Surface__c();
        ps.Property__c = propt.Id; //New link to property
        ps.Surface_Tilt__c = 10;
        ps.Surface_Azimuth__c = 90;
        ps.Trenching_Dist_to_Intercon_Pt_ft__c = 10;
        ps.Suneye_Tilt_and_Orien_Factor__c = 2;        
        ps.Physical_Surface_Assigned_Letter__c = 'A'; //MK 2014-05-02
        ps.Surface_Type__c = 'Asphalt Shingle';//MK 2014-05-02
        insert ps;
        //MK 2014-05-02
        //Get PS in order to get the default mounting type
        ps = [select id, Default_Mounting_Type__c, Property__c, Surface_Tilt__c, Surface_Azimuth__c,
                Trenching_Dist_to_Intercon_Pt_ft__c, Suneye_Tilt_and_Orien_Factor__c, Surface_Type__c, 
                Name, Physical_Surface_Assigned_Letter__c from Physical_Surface__c where id =: ps.id];

        Install_Location__c instLoc = new Install_Location__c();
        instLoc.Location__c = 'S01';//MK 2014-05-02
        instLoc.Physical_Surface__c = ps.id;//MK 2014-05-02
        instLoc.Survey__c = surv.id;//MK 2014-05-02
        //instLoc.Property__c = propt.Id; //MK 2014-05-02
        instLoc.Azimuth__c = double.valueOf('180');
        instLoc.Pitch__c = double.valueOf('23');
        instLoc.TSRF__c = double.valueOf('90');
        insert instLoc;

        Utility_Service__c utilService = new Utility_Service__c();
        utilService.Amperage__c = double.valueOf('200');
        utilService.Utility_Company__c = uc.id;
        utilService.Property__c = propt.id;
        utilService.Service_Account_Number__c = 'abc123';
        insert utilService;

        CB_Panel__c mainPanel = new CB_Panel__c();
        mainPanel.Utility_Service__c = utilService.id;
        mainPanel.Main_Breaker_Rating_Amps__c =Double.valueOf('200');
        insert mainPanel;

        System_Design_Product__c sdp = new System_Design_Product__c();
        sdp.RecordTypeId = [Select r.SobjectType, r.Name, r.id From RecordType r where r.sObjectType = 'System_Design_Product__c' and r.Name = 'Panel'].id;
        sdp.Description__c  = 'Sanyo 215';
        sdp.End_Clamp_Type__c = 'F End Clamp';  
        sdp.Make__c = 'Sanyo';
        sdp.Max_Voltage__c = double.valueOf('600');
        sdp.Mid_Clamp_Type__c = 'F Mid Clamp';  
        sdp.Model__c = 'HIT Power 215N';
        sdp.Rated_Output_W__c = double.valueOf('215');  
        sdp.Unit__c = 'Count';
        insert sdp;

        System_Design__c sd = new System_Design__c();
        sd.Property__c = propt.id;
        sd.Calculated_System_Price__c = decimal.valueOf('100000.25');
        insert sd;

        System_Design_Array__c sda = new System_Design_Array__c();
        sda.CB_Panel__c = mainPanel.id;
        sda.System_Design__c = sd.id;
        sda.Physical_Surface__c = ps.id;//MK 2014-05-02
        sda.Survey__c = surv.id;//MK 2014-05-02
        sda.Mounting_Type__c = ps.Default_Mounting_Type__c;//MK 2014-05-02
        insert sda;

        System_Design_Item__c sdi = new System_Design_Item__c();
                sdi.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Item__c' and r.Name = 'Panel'].id;
                sdi.System_Design_Array__c = sda.Id;
                sdi.Install_Location__c = instLoc.Id;
                sdi.System_Design_Product__c = sdp.Id;
                sdi.Quantity__c = double.valueOf('29');
                sdi.Annual_Solar_Access__c = double.valueOf('100');
                sdi.NRG_Site_Quality__c= double.valueOf('90');
                sdi.Rated_Output_kW__c = 12;
                sdi.Tilt__c = double.valueOf('3');
                sdi.Azimuth__c = double.valueOf('3');
                sdi.Astrum_PV_Watts_Site_Quality__c = double.valueOf('1200');

        insert sdi;

                
        System_Design_Quote__c sdq = new System_Design_Quote__c();
        sdq.System_Design__c = sd.id;
        sdq.Closed_Scenario__c = '1';   //DK: 05/06/15. Added so that SalesOrderTriggerHandler.updateCommissionsFields() won't find a null.
        sdq.Scenario_1_Commission_Impact_Promotions__c = 1;
        insert sdq;
        sdq.Community_Program_Offer__c = cpo.Id;
        dtp.System_Design_Q__c = sdq.id;

        Opportunity oppt = new Opportunity();
        oppt.AccountId = acct.id;
        oppt.name = 'Smith, John';
        oppt.CloseDate = Date.today();
        oppt.StageName = 'Closed - Won';
        oppt.Type = 'New Business';
        oppt.SREC__c = 'Yearly';
        oppt.State_Grant_Amount__c = double.valueOf('100.00');
        oppt.System_Design_Quote__c = sdq.Id;
        oppt.Property__c = propt.Id;
        oppt.Financing_Type__c = 'Purchase';
        oppt.Financing_Option__c = 'No Financing';
        oppt.LeadSource = 'Unknown';
        oppt.Lead_Source_Detail__c = 'Email';
         oppt.Leasing_Option__c = null;
        insert oppt;
        dtp.Opportunity__c = oppt.id;

        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = c.id;
        ocr.IsPrimary = true;
        ocr.Role = 'Decision Maker';
        ocr.OpportunityId = oppt.Id; 
        insert ocr;

        SCRB_SalesOrder__c so = new SCRB_SalesOrder__c();
        so.AccountId__c = acct.id;
        so.OpportunityId__c = oppt.id;
        so.System_Design_Quote__c= sdq.id;
        so.Property__c= propt.id;
        so.StatusCode__c = 'Sales Manager Approved';
        so.Requires_Tree_Removal__c='No';
        so.Has_Field_Survey_Been__c='Yes - Complete';
        insert so;
        dtp.Sales_Order__c = so.id;

        SalesOrderController.syncToOpp(so.Id, oppt.Id);

        Installed_System__c sys = new Installed_System__c();
        sys.Account__c = acct.id;
        insert sys;
        dtp.Installed_System__c = sys.id;

        Milestone1_Project__c proj = new Milestone1_Project__c();
        proj.name = 'Unit Testing 12345azv09y';
        proj.Sales_Order__c = so.id;
        insert proj;
        dtp.Project__c = proj.id;

        dtp.Account_ID__c='Already Correct';
        dtp.Address__c='Already Correct';
        dtp.Attachment_Installed_System__c='Already Correct';
        dtp.Billing_Address__c='Already Correct';
        dtp.CB_Panel__c='Already Correct';
        dtp.Contact__c='Already Correct';
        dtp.Contact_Role__c='Already Correct';
        dtp.Contact_Role_Contract__c='Already Correct';
        dtp.Contact_Role_Grant__c='Already Correct';
        dtp.Contact_Role_SREC_Contract__c='Already Correct';
        dtp.Contract_Matches_SO__c='Already Correct';
        dtp.Contract_Uploaded__c='Already Correct';
        dtp.Enphase_ID__c='Already Correct';
        dtp.Generation_Start_Date__c='Already Correct';
        dtp.Inspection_Date__c='Already Correct';
        dtp.Install_Locations__c='Already Correct';
        dtp.Installation_Date__c='Already Correct';
        dtp.Installed_Inverter__c='Already Correct';
        dtp.Installed_Panel__c='Already Correct';
        dtp.Installed_System_Picklist__c='Already Correct';
        dtp.Inverter_Serial_Numbers__c='Already Correct';
        dtp.Jpeg_Uploaded__c='Already Correct';
        dtp.Multiple_Contact_Roles__c='Already Correct';
        dtp.Name__c='Already Correct';
        dtp.Opportunity_Picklist__c='Already Correct';
        dtp.Paid_in_Full_Date__c='Already Correct';
        dtp.Panel_Serial_Numbers_Leased_Systems_Onl__c='Already Correct';
        dtp.Pitch_and_Azimuth__c='Already Correct';
        dtp.PJM_ID__c='Already Correct';
        dtp.Production_Start_Date__c='Already Correct';
        dtp.Project_Lead__c='Already Correct';
        dtp.Project_Picklist__c='Already Correct';
        dtp.Property_Picklist__c='Already Correct';
        dtp.Sales_Order_Picklist__c='Already Correct';
        dtp.SDQ_Matches_Contract__c='Already Correct';
        dtp.System_Design_Array__c='Already Correct';
        dtp.System_Design_Items__c='Already Correct';
        dtp.System_Design_Quote__c='Already Correct';
        dtp.System_Makeup_Opp__c='Already Correct';
        dtp.System_Makeup_SO__c='Already Correct';
        dtp.TSRF__c='Already Correct';
        dtp.Utility__c='Already Correct';
        dtp.Account_Check__c= true;
        dtp.Sales_Check__c= true;
        dtp.Ops_Check__c= true;

        return dtp;
    }
    
    //PB 04/17/2015
    public static System_Design_Quote__c setupSystemDesignQuote(string propType, string finType, id LeaseFund, boolean commProgram, double siteQuality)
    {
        //USAGE:        
        ////Create system design and related items
        //id sdID = testData.setupSystemDesignQuote('Residential', 'Purchase', null, true, 12000);

        //Account      
        Account acct = new Account();
        acct.name='TestAcct';        
        insert acct;
        
        //Contact
        Contact c = new Contact();
        c.FirstName = 'John';
        c.LastName = 'Smith';
        c.AccountId = acct.id;
        insert c;

        //Community Program Offer under any Account 
        Community_Program_Offer__c cpo = new Community_Program_Offer__c();
        cpo.Account__c = acct.id;
        cpo.Baseline_Site_Quality__c = 2000;
        cpo.Current_Tier__c = '1';
        cpo.Early_Adopter_Promotion__c = 100;
        cpo.Early_Adopter_Promotion_Available__c = true;
        cpo.Start_Date__c = Date.today().toStartOfMonth();
        cpo.Extension_End_Date__c = Date.today().addMonths(1).addDays(15);
        cpo.Initial_End_Date__c = Date.today().addMonths(1);
        //cpo.Eligible_Zip_Codes__c = '20701';
        insert cpo;
        
        //Property
        Property__c prop = new Property__c();
        prop.Name = '123 Main St';
        prop.RecordTypeid = [Select id from RecordType where sobjecttype = 'Property__c' and Name =: propType limit 1].id;
        prop.Property_Owner__c = acct.Id;       
        prop.Optimal_Site_Quality_kWh_y_kW__c = double.valueOf('1250');
        prop.Property_State__c = 'MD';
        prop.Property_City__c = 'Annapolis Junction';        
        prop.Property_ZIP__c = '20701';
        prop.Property_County__c = 'Howard';
        prop.Astrum_Office__c = defaultOffLocationName;        
        prop.Sales_Region__c = [select id from Astrum_Sales_Region__c where name='MD Region'].id;  
        prop.QAS_Property_County__c = 'Howard County, MD';    //DK 12-23-14
        insert prop;
        
        //Utility Company master
        Utility_Company_Master__c utilCompany = new Utility_Company_Master__c();
        utilCompany.Name = 'BG&E';
        utilCompany.Solar_Compensation_Method__c = 'Net Metering';
        utilCompany.State_Serviced__c = 'MD';
        insert utilCompany;
        
        //Utility Rate Code
        Utility_Company__c urc = new Utility_Company__c();
        urc.Name = 'R1';
        urc.Utility_Company_Master__c = utilCompany.ID;
        urc.All_Electric_Service__c = 'No';
        urc.Utility_Service_Territory__c  = 'Test territory';
        urc.All_Electric_Service__c = 'Not Applicable';        
        insert urc;
        
        Pricing_Region__c pricingRegion = [SELECT ID FROM Pricing_Region__c WHERE Name = 'Maryland' LIMIT 1];

        //Utility By Zip Code
        Utility_by_Zip_Code__c  utilByZip = new Utility_by_Zip_Code__c();
        utilByZip.Name = 'BG&E';
        utilByZip.Utility_Zip_Code__c = '20701';
        utilByZip.Utility_Company_Master__c = utilCompany.Id;
        utilByZip.Start_Date__c = Date.today().addYears(-2);
        utilByZip.Pricing_Region__c = pricingRegion.ID;     //CPQ-751
        insert utilByZip; 
        
        //Utility Service
        Utility_Service__c utilService = new Utility_Service__c();
        utilService.Amperage__c = double.valueOf('200');
        utilService.Utility_Company__c = urc.Id;
        utilService.Utility_Rate_Code_Before_Solar__c = urc.Id;
        utilService.Utility_Rate_Code_After_Solar__c = urc.Id;
        utilService.Utility_Company_Master__c = utilCompany.ID;
        utilService.Property__c = prop.Id;
        utilService.Service_Account_Number__c = 'abc123';
        utilService.Current_Usage_Type__c = 'Annual';
        utilService.Annual_Electricity_Consumption_kWh__c = 6000;
        utilService.Before_Tier_1_Cost__c = '86.92;86.82;86.82;86.74;129.98;130.36;130.5;130.36;130.36;130.36;87.18;86.92;';
        utilService.Solar_Method_1_Tier_1_Value__c = '86.92;86.82;86.82;86.74;129.98;130.36;130.5;130.36;130.36;130.36;87.18;86.92;';
        utilService.Before_Fixed_Costs__c = '0.00;0.00;0.00;0.00;0.00;0.00;0.00;0.00;0.00;0.00;0.00;0.00;';
        utilService.After_Fixed_Costs__c = '0.00;0.00;0.00;0.00;0.00;0.00;0.00;0.00;0.00;0.00;0.00;0.00;';
        utilService.Before_Total_Bill__c = '266.50;266.22;266.22;265.98;398.54;399.74;400.14;399.74;399.74;399.74;267.30;266.50';
        utilService.Method_1_Net_Bill__c = 3996.36;
        insert utilService;        
        
        //Survey
        Survey__c surv = new Survey__c();
        surv.Property__c = prop.Id;
        surv.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'Survey__c' and r.Name = 'Field Survey'].id;        
        insert surv;
        
        

        //CB Panel
        CB_Panel__c mainPanel = new CB_Panel__c();
        mainPanel.Name = 'Suniva';
        mainPanel.Utility_Service__c = utilService.Id;
        mainPanel.Main_Breaker_Rating_Amps__c = Double.valueOf('200');
        System.debug('mainPanel --> ' + mainPanel);      
        insert mainPanel;
        
        
        //Physical Surface
        Physical_Surface__c ps = new Physical_Surface__c();
        ps.Property__c = prop.Id; //New link to property
        ps.Surface_Tilt__c = 10;
        ps.Surface_Azimuth__c = 90;
        ps.Trenching_Dist_to_Intercon_Pt_ft__c = 10;
        ps.Suneye_Tilt_and_Orien_Factor__c = 2;        
        ps.Physical_Surface_Assigned_Letter__c = 'A'; //MK 2014-05-02
        ps.Surface_Type__c = 'Asphalt Shingle';//MK 2014-05-02
        insert ps; 
        
        //Get PS in order to get the default mounting type
        ps = [select id, Default_Mounting_Type__c, Property__c, Surface_Tilt__c, Surface_Azimuth__c,
                Trenching_Dist_to_Intercon_Pt_ft__c, Suneye_Tilt_and_Orien_Factor__c, Surface_Type__c, 
                Name, Physical_Surface_Assigned_Letter__c from Physical_Surface__c where id =: ps.id];


        //Install Location
        Install_Location__c instLoc = new Install_Location__c();
        instLoc.Physical_Surface__c = ps.id; //This is the master relationship now
        //instLoc.Property__c = prop.Id; //MK 2014-05-02        
        instLoc.Location__c = 'S01';//MK 2014-05-02        
        instLoc.Survey__c = surv.id;//MK 2014-05-02
        instLoc.Azimuth__c = double.valueOf('180');
        instLoc.Pitch__c = double.valueOf('23');
        instLoc.TSRF__c = double.valueOf('90');
        insert instLoc;

        //SYSTEM DESIGN OBJECTS
        //==============================
        List<System_Design_Product__c> sdpList = new List<System_Design_Product__c>();

        System_Design_Product__c sdp = new System_Design_Product__c();
        sdp.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Product__c' and r.Name = 'Panel'].id;
        sdp.Description__c  = 'Sanyo 215';
        sdp.End_Clamp_Type__c = 'F End Clamp';  
        sdp.Make__c  = 'Sanyo';
        sdp.Max_Voltage__c = double.valueOf('600');
        sdp.Mid_Clamp_Type__c = 'F Mid Clamp';  
        sdp.Model__c = 'HIT Power 215N';
        sdp.Rated_Output_W__c = double.valueOf('700');
        sdp.Unit__c = 'Count';

        sdpList.add(sdp);
        //insert sdp;
        
        System_Design_Product__c sdp1 = new System_Design_Product__c();
        sdp1.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Product__c' and r.Name = 'Inverter'].id;
        sdp1.Description__c  = 'M215-60-240-S22';
        sdp1.End_Clamp_Type__c = 'F End Clamp';  
        sdp1.Make__c  = 'Enphase';
        sdp1.Max_Voltage__c = double.valueOf('600');
        sdp1.Mid_Clamp_Type__c = 'F Mid Clamp';  
        sdp1.Model__c = 'M215-60-240-S22';
        sdp1.Rated_Output_W__c = double.valueOf('300');
        sdp1.Unit__c = 'Count';

        sdpList.add(sdp1);
        insert sdpList;
        
        //System Design
        System_Design__c sd = new System_Design__c();
        sd.Property__c = prop.Id;        
        sd.Calculated_System_Price__c = decimal.valueOf('100000.25');
        sd.Default_CB_Panel__c = mainPanel.ID;    //DK 12-22-14
        sd.System_Inverter__c = sdp1.ID;
        sd.Astrum_SQ_Calculation_Status__c = 'Valid';
        //sd.NRG_Overall_Site_Quality__c = siteQuality;
        //sd.Sunnova_Overall_Site_Quality__c = siteQuality;
        insert sd;
                
        //System Design Array
        System_Design_Array__c sda = new System_Design_Array__c();
        sda.CB_Panel__c = mainPanel.Id;
        sda.System_Design__c = sd.Id;
        sda.Physical_Surface__c = ps.id;//MK 2014-05-02
        sda.Survey__c = surv.id;//MK 2014-05-02
        sda.Mounting_Type__c = ps.Default_Mounting_Type__c;//MK 2014-05-02
        insert sda;
        
        //System Design Item - Panel
        System_Design_Item__c sdi = new System_Design_Item__c();
        sdi.RecordTypeId = [Select sObjectType, Name From RecordType WHERE sObjectType = 'System_Design_Item__c' AND Name = 'Panel'].id;
        sdi.System_Design_Array__c = sda.Id;
        sdi.Install_Location__c = instLoc.Id;
        sdi.System_Design_Product__c = sdp.Id;
        sdi.Quantity__c = double.valueOf(20);
        sdi.Annual_Solar_Access__c = double.valueOf(90);
        sdi.NRG_Site_Quality__c = siteQuality;
        sdi.Sunnova_Site_Quality__c = siteQuality;
        sdi.Astrum_PV_Watts_Site_Quality__c = siteQuality;
        sdi.Rated_Output_kW__c = 12;
        insert sdi;

        //System Design Item - Inverter
/*        sdi = new System_Design_Item__c();
        sdi.RecordTypeId = [Select sObjectType, Name From RecordType WHERE sObjectType = 'System_Design_Item__c' AND Name = 'Inverter'].id;
        sdi.System_Design_Array__c = sda.Id;
        sdi.Install_Location__c = instLoc.Id;
        sdi.System_Design_Product__c = sdp1.Id;
        sdi.Quantity__c = double.valueOf(20);
        sdi.Annual_Solar_Access__c = double.valueOf(90);
        sdi.NRG_Site_Quality__c = siteQuality;
        sdi.Sunnova_Site_Quality__c = siteQuality;
        sdi.Astrum_PV_Watts_Site_Quality__c = siteQuality;
        sdi.Rated_Output_kW__c = 12;
        insert sdi;
*/
        //PRICING DEPENDANT OBJECTS
        //==============================

        //Insert System Pricing Table For Panel
        System_Pricing_Table__c spt = new System_Pricing_Table__c();
        spt.Panel_Type__c = sdp.id;
        spt.Sales_Region__c = prop.Sales_Region__c;
        spt.Pricing_Region__c = pricingRegion.ID;    //DK 12-23-14  
        spt.Financing_Type__c = finType;        
        if(leaseFund != null) spt.Lease_Fund__c = leaseFund; 
        if(commProgram) spt.Community_Program_Offer__c = cpo.id;
        spt.Community_Program_Tier__c = '1';
        spt.Start_Date__c = date.today().addDays(-1);
        spt.End_Date__c = date.today().addDays(1);
        spt.count_10_root_price__c = 2500;
        spt.count_20_root_price__c = 2470;
        spt.count_30_root_price__c = 2450;
        spt.Unique_ID__c = 'ThisFieldIsRequiredSoWeMustSetIt4321';    //DK 11-3-14
        insert spt;
        
        //SDP Price Entry under SDP   ((((This is for non-panel pricing))))      
        
        //For inverter
        SDP_Price_Entry__c sdpPE = new SDP_Price_Entry__c();
        sdpPE.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'SDP_Price_Entry__c' and r.Name = 'Inverter'].id;
        sdpPE.System_Design_Product__c = sdp1.id;
        sdpPE.Start_Date__c = date.today();
        sdpPE.End_Date__c = date.today();
        sdpPE.Property_Record_Type__c = propType;
        sdpPE.Financing_Type__c = finType;
        if(leaseFund != null) sdpPE.Lease_Fund__c = leaseFund;
        if(commProgram) sdpPE.Community_Program_Offer__c = cpo.id;
        sdpPE.Adder_W__c = 3; //For (Record Type = ‘Panel’, ‘Inverter’, ‘Mounting’, ’Trenching’, ‘Labor’)
        //sdpPE.Adder_ea__c = 2; //For (Record Type = ‘Special Part’)
        sdpPE.Unique_ID__c = 'ThereIsNoWayThatThisStringIsNotUnique12345';    //DK 11-2-14
        insert sdpPE;        
        
        Product2 product = new Product2();
        product.Name='testProduct223';
        product.ProductCode = 'system';
        insert product;
        ID pbookID= Test.getStandardPricebookId();
              
        PriceBookEntry entry = new PricebookEntry();
        entry.UnitPrice = 2.32;
        entry.PriceBook2Id = pbookID;
        entry.UseStandardPrice=FALSE;
        entry.Product2ID=product.id;
        entry.IsActive  = true;
        insert entry;
        
        System_Design_Quote__c newsdq = SalesWorkflowValidationUtility.systemDesignQuoteWorkflowOnCreate(sd);        
        System_Design_Quote__c sdq = [Select id from System_Design_Quote__c Where System_Design__c = :sd.id And Current__c = true];
        sdq.Total_Closed_Scenario_Adjustments__c = 1;
        if(commProgram) sdq.Community_Program_Offer__c = cpo.id;        
        
        List<Lease_Fund__c> funds = createLeaseFunds();
        Entitlement_Offer__c entlOffer = createEntitlementOffer('Purchase', sdq.Community_Program_Offer__c);
        createProgramPromotion('Purchase');
        createStandardPromotions('Purchase');
        List<Incentive_Offer__c> incOffers = createIncentiveOffers();
        createSRECOffer('Purchase');
        
        //Create available srec offers for sdq
        List<Available_SREC_Contract_Offer__c> avlOffers = 
            [Select Upfront_Effective_Dollar_Amount__c,Contract_Offer_Applied__c,SREC_Contract_Offer__r.Name,Applicable_Scenario__c 
             from Available_SREC_Contract_Offer__c 
             Where System_Design_Quote__c = :sdq.Id];
        for(Available_SREC_Contract_Offer__c avlOffer: avlOffers){
            sdq.put('Scenario_' + avlOffer.Applicable_Scenario__c + '_Available_SREC_Contract_Offer__c', avlOffer.Id);
        }
        
        //create available incentives for sdq
        createAvailIncentiveOffer(sdq.Id, incOffers[0], '1', 'Tax Credit');
        createAvailIncentiveOffer(sdq.Id, incOffers[1], '2','Rebate ($)');
        createAvailIncentiveOffer(sdq.Id, incOffers[2], '3','Tax Credit');
        createAvailIncentiveOffer(sdq.Id, incOffers[3], '4','Tax Credit');
        createAvailIncentiveOffer(sdq.Id, incOffers[4], '1', 'Rebate ($/W)');
        
        //Set sdq financing options
        sdq.Scenario_1_Financing_Type__c = finType;
        sdq.Scenario_1_Term_Loan__c = funds[1].Id;
        sdq.Scenario_1_Adjusted_Price_NUM__c = 1000;
        sdq.Scenario_1_Installer_Paid_Incentive_Amt__c = 10;
        sdq.Scenario_1_First_Month_Payment__c = 197.46820636000578;
        sdq.Scenario_2_Financing_Type__c = finType;
        sdq.Scenario_2_SAC_Loan__c = funds[0].Id; 
        sdq.Scenario_3_Financing_Type__c = finType;
        sdq.Scenario_3_Term_Loan__c = funds[1].Id;
        sdq.Scenario_3_SAC_Loan__c = funds[3].Id;
        sdq.Scenario_4_Financing_Type__c = 'Lease';
        sdq.Scenario_4_Lease_Fund__c = funds[2].Id;
        sdq.Scenario_4_Lease_Option__c = 'One-Pay';
        sdq.Scenario_1_VP_Sales_Adjustments__c = 2000.00;
        sdq.Scenario_2_VP_Sales_Adjustments__c = 2000.00;
        sdq.Scenario_3_VP_Sales_Adjustments__c = 2000.00;
        sdq.Scenario_4_VP_Sales_Adjustments__c = 2000.00;
        
        sdq.Scenario_1_Set_Standard_Adjustment_Type__c = 'Dollar Amount';
        sdq.Scenario_1_Set_Standard_Adjustment_Amoun__c = -1500;
        sdq.Scenario_2_Set_Standard_Adjustment_Type__c = 'Percentage';
        sdq.Scenario_2_Set_Standard_Adjustment_Amoun__c = -3;
        sdq.Scenario_3_Set_Standard_Adjustment_Type__c = 'Dollar Per Watt';
        sdq.Scenario_3_Set_Standard_Adjustment_Amoun__c = -0.05;
        
        sdq.Pricing_Date__c = Date.today();
        sdq.Current__c = true;
        update sdq; 

        //Opportunity
        Opportunity oppt = new Opportunity();
        oppt.AccountId = acct.id;
        oppt.name = 'Smith, John';
        oppt.CloseDate = Date.today();
        oppt.StageName = 'Closed - Won';
        oppt.Type = 'New Business';
        oppt.SREC__c = 'Yearly';
        oppt.State_Grant_Amount__c = double.valueOf('100.00');
        oppt.System_Design_Quote__c = sdq.Id;
        oppt.Property__c = prop.Id;
        oppt.Financing_Type__c = finType;
        oppt.Financing_Option__c = 'No Financing';
        oppt.LeadSource = 'Unknown';
        oppt.Lead_Source_Detail__c = 'Email';
        oppt.Leasing_Option__c = null;
        insert oppt;        

        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = c.id;
        ocr.IsPrimary = true;
        ocr.Role = 'Decision Maker';
        ocr.OpportunityId = oppt.Id; 
        insert ocr;
        
        String query = 'SELECT ';
        LIST<String> sdqFields = new LIST<String>{ 'System_Design_Stored_State__c', 'System_Design_Stored_State_Mismatch__c', 'System_Design_Reconstruction_Record__c',  
                                        'Sys_Design_Reconstruct_Record_Mismatch__c', 'Current__c', 'Valid__c', 'System_Design__c', 'All_Electric_Service__c', 'Validation_Errors__c', 
                                        'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_Before_Solar__r.All_Electric_Service__c',
                                        'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_After_Solar__r.All_Electric_Service__c' ,
                                        'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Name', 'Pricing_Date__c', 'As_Of_Pricing_Date__c', 
                                        'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_After_Solar__r.Default_Rate_Code__c'  ,
                                        'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Has_Service_Territories__c'  ,
                                        'System_Design__r.Default_CB_Panel__r.Name', 'System_Design__r.System_Inverter__r.Make__c', 'System_Design__r.Property__r.RecordType.DeveloperName',
                                        'System_Design__r.System_Inverter__r.RecordType.DeveloperName', 'Disqualifying_Validation_Errors__c', 'Annual_Electricity_Consumption_kWh__c' ,
                                        'System_Design__r.Astrum_SQ_Calculation_Status__c','System_Design__r.Property__c', 'System_Design__r.Property__r.Property_State__c', 'System_Size_kW__c',
                                        'Scenario_1_Financing_Rate_Year_1_kWh__c', 'Scenario_2_Financing_Rate_Year_1_kWh__c' ,
                                        'Scenario_3_Financing_Rate_Year_1_kWh__c', 'Scenario_4_Financing_Rate_Year_1_kWh__c', 'Scenario_1_Avoided_Utility_Rate__c',
                                        'Scenario_2_Avoided_Utility_Rate__c', 'Scenario_3_Avoided_Utility_Rate__c', 'Scenario_4_Avoided_Utility_Rate__c', 
                                        'Scenario_1_Total_Projected_Annual_Output__c' ,'Scenario_2_Total_Projected_Annual_Output__c', 'Scenario_3_Total_Projected_Annual_Output__c', 'Scenario_4_Total_Projected_Annual_Output__c',
                                        'Community_Program_Offer__c','Community_Program_Offer__r.Current_Tier__c','Community_Program_Offer__r.Early_Adopter_Promotion_Available__c' ,
                                        'Community_Program_Offer__r.name','Scenario_1_Design_Override_Price__c', 'Scenario_1_Net_Initial_Outlay__c',
                                        'Scenario_1_Financing_Type__c','Scenario_2_Financing_Type__c','Scenario_3_Financing_Type__c','Scenario_4_Financing_Type__c',
                                        'Scenario_1_Lease_Fund__c','Scenario_2_Lease_Fund__c','Scenario_3_Lease_Fund__c','Scenario_4_Lease_Fund__c',
                                        'Scenario_1_Lease_Option__c','Scenario_2_Lease_Option__c','Scenario_3_Lease_Option__c','Scenario_4_Lease_Option__c', 
                                        'Scenario_1_Error_Log__c' , 'Scenario_2_Error_Log__c', 'Scenario_3_Error_Log__c', 'Scenario_4_Error_Log__c',
                                        'Scenario_1_Down_Payment__c','Scenario_2_Down_Payment__c','Scenario_3_Down_Payment__c','Scenario_4_Down_Payment__c',
                                        'Scenario_1_Lease_Escalator__c','Scenario_2_Lease_Escalator__c','Scenario_3_Lease_Escalator__c','Scenario_4_Lease_Escalator__c',
                                        'Scenario_1_Available_SREC_Contract_Offer__c','Scenario_2_Available_SREC_Contract_Offer__c','Scenario_3_Available_SREC_Contract_Offer__c','Scenario_4_Available_SREC_Contract_Offer__c',
                                        'Scenario_1_Final_EPC_Price__c', 'Scenario_2_Final_EPC_Price__c','Scenario_3_Final_EPC_Price__c','Scenario_4_Final_EPC_Price__c',
                                        'Scenario_1_Installer_Paid_Incentive_Amt__c','Scenario_2_Installer_Paid_Incentive_Amt__c' ,'Scenario_3_Installer_Paid_Incentive_Amt__c','Scenario_4_Installer_Paid_Incentive_Amt__c',
                                        'Scenario_1_Prepaid_Financing_Amount__c','Scenario_2_Prepaid_Financing_Amount__c','Scenario_3_Prepaid_Financing_Amount__c','Scenario_4_Prepaid_Financing_Amount__c',
                                        'Scenario_1_Set_Standard_Adjustment_Type__c','Scenario_2_Set_Standard_Adjustment_Type__c','Scenario_3_Set_Standard_Adjustment_Type__c','Scenario_4_Set_Standard_Adjustment_Type__c',
                                        'Scenario_1_Term_Loan__c','Scenario_2_Term_Loan__c','Scenario_3_Term_Loan__c','Scenario_4_Term_Loan__c',
                                        'Scenario_1_SAC_Loan__c','Scenario_2_SAC_Loan__c','Scenario_3_SAC_Loan__c','Scenario_4_SAC_Loan__c','Total_Closed_Scenario_Adjustments__c',
                                        'Utility_Annual_Increase__c','Quoted_SREC_Market__c','Scenario_1_Available_SREC_Contract_Offer__r.SREC_Contract_Offer__c','Scenario_2_Available_SREC_Contract_Offer__r.SREC_Contract_Offer__c',
                                        'Scenario_3_Available_SREC_Contract_Offer__r.SREC_Contract_Offer__c','Scenario_4_Available_SREC_Contract_Offer__r.SREC_Contract_Offer__c'
                                        };
                                            
        for(String field: sdqFields){
            query+= field + ',';
        }
        
        query = query.RemoveEnd(',');
        query+= ' from System_Design_Quote__c Where System_Design__c = '+ '\'' + sd.id + '\'' +' And Current__c = true LIMIT 1';
        System_Design_Quote__c quote = (System_Design_Quote__c) Database.query(query);

        return quote;

   }
    
    //PB 04/29/2015
    public static List<Lease_Fund__c> createLeaseFunds(){
        
        Account acct = new Account();
        acct.name='TestLeaseAcct';        
        insert acct;
        
        Map<String, Schema.RecordTypeInfo> fundsRTMap = Schema.SObjectType.Lease_Fund__c.getRecordTypeInfosByName();
        List<Lease_Fund__c> funds = new List<Lease_Fund__c>();
        Lease_Fund__c fund = new Lease_Fund__c();
        fund.recordTypeId = fundsRTMap.get('SAC Loan').getRecordTypeId();
        fund.Name = 'Test Hudson 12 Month SAC Loan';
        fund.Eligible_States__c = 'CA; CT; DC; MA; MD; NJ; NY; OH; PA; VA';
        fund.Eligible_Leasing_Options__c = 'Low-Upfront - Monthly';
        fund.APR__c = 5.9900 ;
        fund.Production_Degradation__c = 50.00;
        fund.Financing_Term_Months__c = 12;
        //fund.Fund_Open_Date__c = Date.today();
        fund.Overproduction_Allowed__c = true;
        fund.Fixed_Finance_Amount__c = true;
        fund.Fund_Partner__c = acct.Id;
        funds.add(fund);
        
        Lease_Fund__c fund2 = new Lease_Fund__c();
        fund2.recordTypeId = fundsRTMap.get('Term Loan').getRecordTypeId();
        fund2.Name = 'Test Hudson 20 Year Term Loan';
        fund2.Eligible_States__c = 'CA; CT; DC; MA; MD; NJ; NY; OH; PA; VA';
        fund2.Eligible_Leasing_Options__c = 'Term Loan';
        fund2.APR__c = 6.0000 ;
        fund2.Production_Degradation__c = 0.50;
        fund2.Financing_Term_Months__c = 12;
        //fund2.Fund_Open_Date__c = Date.today();
        fund2.Overproduction_Allowed__c = true;
        fund2.Fixed_Finance_Amount__c = true;
        fund2.Fund_Partner__c = acct.Id;
        fund2.Required_Utility_Savings__c = 5.0000;
        fund2.Assumed_Utility_Rate_Annual_Escalator__c = 4.0000;
        fund2.Max_Finance_Percent_of_Price__c = 100.0000;
        fund2.Maximum_Term_Loan_Amount__c = 9999999;
        fund2.Minimum_Term_Loan_Amount__c = 0;
        fund2.Maximum_Project_Cost__c = 9999999;
        fund2.Minimum_Project_Cost__c = 0;
        funds.add(fund2);               
        
        Lease_Fund__c fund3 = new Lease_Fund__c();
        fund3.recordTypeId = fundsRTMap.get('Lease').getRecordTypeId();
        fund3.Name = 'Test Kilowatt Systems ';
        fund3.Eligible_States__c = 'CA; CT; DC; MA; MD; NJ; NY; OH; PA; VA';
        fund3.Eligible_Leasing_Options__c = 'Low-Upfront - Monthly; One-Pay';
        fund3.APR__c = 0 ;
        fund3.Production_Degradation__c = 0.75;
        //fund3.Fund_Open_Date__c = Date.today();
        fund3.Overproduction_Allowed__c = false;
        fund3.Fixed_Finance_Amount__c = false;
        fund3.Fund_Partner__c = acct.Id;
        fund3.Finance_Pricing_Algorithm__c = 'Kilowatt';
        funds.add(fund3);
        
        insert funds;
        
        Lease_Fund__c fund4 = new Lease_Fund__c();
        fund4.recordTypeId = fundsRTMap.get('SAC Loan').getRecordTypeId();
        fund4.Name = 'Test Hudson 12 Month SAC Loan';
        fund4.Eligible_States__c = 'CA; CT; DC; MA; MD; NJ; NY; OH; PA; VA';
        fund4.Eligible_Leasing_Options__c = 'SAC Loan';
        fund4.APR__c = 5.9900 ;
        fund4.Production_Degradation__c = 50.00;
        fund4.Financing_Term_Months__c = 12;
        //fund4.Fund_Open_Date__c = Date.today();
        fund4.Overproduction_Allowed__c = true;
        fund4.Fixed_Finance_Amount__c = true;
        fund4.Fund_Partner__c = acct.Id;
        fund4.Min_Finance_Percent_of_Price__c = 50;
        fund4.Related_Finance_Record__c = funds[1].Id;        
        
        Lease_Fund__c fund5 = new Lease_Fund__c();  //Added PPA on 10/09/15
        fund5.recordTypeId = fundsRTMap.get('PPA').getRecordTypeId();
        fund5.Name = 'Test Kilowatt PPA';
        fund5.Eligible_States__c = 'CA; CT; DC; MA; MD; NJ; NY; OH; PA; VA';
        fund5.Eligible_Leasing_Options__c = 'Low-Upfront - Monthly; One-Pay; Fixed-Rate PPA';
        fund5.Production_Degradation__c = 0.75;
        //fund5.Fund_Open_Date__c = Date.today();
        fund5.Finance_Pricing_Algorithm__c = 'Kilowatt';
        fund5.Fixed_Finance_Amount__c = true;
        fund5.Fund_Partner__c = acct.Id;

        Lease_Fund__c fund6 = new Lease_Fund__c();  //Added OneRoof on 10/27/15
        fund6.recordTypeId = fundsRTMap.get('PPA').getRecordTypeId();
        fund6.Name = 'Test OneRoof PPA';
        fund6.Eligible_States__c = 'CA; CT; DC; MA; MD; NJ; NY; OH; PA; VA';
        fund6.Eligible_Leasing_Options__c = 'Fixed-Rate PPA';
        fund6.Production_Degradation__c = 0.75;
        //fund6.Fund_Open_Date__c = Date.today();
        fund6.Finance_Pricing_Algorithm__c = 'OneRoof';
        fund6.Fixed_Finance_Amount__c = true;
        fund6.Fund_Partner__c = acct.Id;

        Lease_Fund__c fund7 = new Lease_Fund__c();  //Added on 12/10/15 for CPQ-745
        fund7.recordTypeId = fundsRTMap.get('PPA').getRecordTypeId();
        fund7.Name = 'Test Portfolio PPA';
        fund7.Eligible_States__c = 'CA; CT; DC; MA; MD; NJ; NY; OH; PA; VA';
        fund7.Eligible_Leasing_Options__c = 'Portfolio PPA';
        fund7.Production_Degradation__c = 0.75;
        //fund7.Fund_Open_Date__c = Date.today();
        fund7.Finance_Pricing_Algorithm__c = 'Portfolio PPA';
        fund7.Fixed_Finance_Amount__c = true;
        fund7.Fund_Partner__c = acct.Id;

        insert new Lease_Fund__c[]{fund4, fund5, fund6, fund7};

        funds.add(fund4);
        funds.add(fund5);
        funds.add(fund6);
        funds.add(fund7);
        
        return funds;
    }
    
    public static void createFPP(Id leaseFundId){   //DK 10/27/15
        State__c marylandState = [SELECT ID FROM State__c WHERE Name = 'Maryland'];
        createFPP(leaseFundId, marylandState);
    }

    //PB 04/29/2015
    public static void createFPP(Id leaseFundId, State__c state){
        Financing_Product_Pricing__c fpp = new Financing_Product_Pricing__c();
        List<Financing_Product_Pricing__c> fpps = new List<Financing_Product_Pricing__c>();
        fpp.Alpha__c = 0.1000;
        fpp.Beta__c = 0.1000;
        fpp.Gamma__c = 0.1000;
        fpp.Delta__c = 0.1000;
        fpp.Lease_Fund__c = leaseFundId;
        fpp.Payment_Type__c = 'Monthly';
        fpp.Escalator__c = '0';
        fpp.Product_Type__c = 'Lease';
        fpp.State__c = state.Id;
        fpp.Epsilon__c = 0.1;
        fpps.add(fpp);
        
        Financing_Product_Pricing__c fppPrepaid = new Financing_Product_Pricing__c();
        fppPrepaid.Alpha__c = 0.1000;
        fppPrepaid.Beta__c = 0.1000;
        fppPrepaid.Gamma__c = 0.1000;
        fppPrepaid.Delta__c = 0.1000;
        fppPrepaid.Lease_Fund__c = leaseFundId;
        fppPrepaid.Payment_Type__c = 'Prepaid';
        fppPrepaid.Escalator__c = '0';
        fppPrepaid.Product_Type__c = 'Lease';
        fppPrepaid.State__c = state.Id;
        fppPrepaid.Epsilon__c = 0.1;
        fpps.add(fppPrepaid);

        insert fpps;
    }
    
    //PB 04/29/2015
    public static Promotion__c createProgramPromotion(String finType){
        
        Map<String, Schema.RecordTypeInfo> promotionRTMap = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName();
        Promotion__c promo = new Promotion__c();
        promo.Financing_Type__c = finType;
        promo.Name = 'Test Program Promotion' + finType;
        promo.State__c = 'AL; MD; PA';
        promo.Promo_Amount__c = 1200.00;
        promo.Start_Date__c = Date.today();
        promo.RecordTypeId = promotionRTMap.get('Program').getRecordTypeId();
        insert promo;
        
        return promo;
    }
    
    //PB 04/29/2015
    public static List<Promotion__c> createStandardPromotions(String finType){
        
        Map<String, Schema.RecordTypeInfo> promotionRTMap = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName();
        List<Promotion__c> promos = new List<Promotion__c>();
        Promotion__c dollaramntpromo = new Promotion__c();
        dollaramntpromo.Financing_Type__c = finType;
        dollaramntpromo.Name = 'Standard Dollar';
        dollaramntpromo.State__c = 'AL; MD; PA';
        dollaramntpromo.Promo_Amount__c = -1500.00;
        dollaramntpromo.Start_Date__c = Date.today();
        dollaramntpromo.RecordTypeId = promotionRTMap.get('Standard').getRecordTypeId();
        
        Promotion__c percentpromo = new Promotion__c();
        percentpromo.Financing_Type__c = finType;
        percentpromo.Name = 'Standard Percent';
        percentpromo.State__c = 'AL; MD; PA';
        //percentpromo.Promo_Amount__c = -3;
        percentpromo.Promo_Amount_Percent__c = -3;
        percentpromo.Start_Date__c = Date.today();
        percentpromo.RecordTypeId = promotionRTMap.get('Standard').getRecordTypeId();
                
        Promotion__c dollarwattpromo = new Promotion__c();
        dollarwattpromo.Financing_Type__c = finType;
        dollarwattpromo.Name = 'Standard rate';
        dollarwattpromo.State__c = 'AL; MD; PA';
        //dollarwattpromo.Promo_Amount__c = 0.05;
        dollarwattpromo.Promo_Amount_W__c = -0.05;
        dollarwattpromo.Start_Date__c = Date.today();
        dollarwattpromo.RecordTypeId = promotionRTMap.get('Standard').getRecordTypeId();
        
        promos.add(dollaramntpromo);
        promos.add(percentpromo);
        promos.add(dollarwattpromo);
        insert promos;
        return promos;
    }
    
    //PB 04/29/2015
    public static Entitlement_Offer__c createEntitlementOffer(String finType, Id commProgramId){
        
        Entitlement_Offer__c entlOffer = new Entitlement_Offer__c();
        entlOffer.Name = 'Test Astrum Extended Warranty ' + finType;
        //entlOffer.State__c = 'AL; AK; AZ; AR; CA; CO; CT; DE; FL; GA; HI; ID; IL; IN; IA; KS; KY; LA; ME; MD; MA; MI; MN; MS; MO; MT; NE; NV; NH; NJ; NM; NY; NC; ND; OH; OK; OR; PA; RI; SC; SD; TN; TX; UT; VT; VA; WA; WV; WI; WY';
        entlOffer.Financing_Type__c = finType;
        entlOffer.Opt_Out_Allowed__c = false;
        entlOffer.Start_Date__c = date.today().addDays(-2);
        entlOffer.Community_Program_Offer__c = commProgramId;
        entlOffer.Amount__c = 900;
        insert entlOffer;        
        
        return entlOffer;
    }
    
    //PB 04/29/2015
    public static List<Incentive_Offer__c> createIncentiveOffers(){
        //0- TaxtCredit-State, 1- Rebate-State, 2- Tax Credit-County, 3- Tax-credit federal
        Map<String, Schema.RecordTypeInfo> incentiveOfferRTMap = Schema.SObjectType.Incentive_Offer__c.getRecordTypeInfosByName();
        List<Incentive_Offer__c> offers = new List<Incentive_Offer__c> ();
        Incentive_Offer__c io = new Incentive_Offer__c();
        io.RecordTypeId = incentiveOfferRTMap.get('Tax Credit').getRecordTypeId();
        io.Name = 'Sample Incentive Offer1';
        io.Implementing_Sector__c = 'State';
        io.Eligible_Sector__c = 'Residential';
        io.Eligible_State__c = 'MD';
        io.Eligible_Financing_Type__c = 'Purchase';
        io.Customer_Description__c = 'Sample Customer Description';
        io.Tax_Credit_Rate__c = 30;
        io.Incentive_Recipient__c = 'Owner';
        //io.SAC_Eligible__c = true;
        io.Eligible_Cost_Basis__c ='Net of Federal Tax Credit';
        io.Start_Date__c = date.today().addDays(-2);
        io.Flat_Rebate_Amount__c = 1000;
        offers.add(io);
        
        Incentive_Offer__c io2 = new Incentive_Offer__c();
        io2.RecordTypeId = incentiveOfferRTMap.get('Rebate ($)').getRecordTypeId();
        io2.Name = 'Sample Incentive Offer2';
        io2.Implementing_Sector__c = 'State';
        io2.Eligible_Sector__c = 'Residential';
        io2.Eligible_State__c = 'MD';
        io2.Eligible_Financing_Type__c = 'Purchase';
        io2.Customer_Description__c = 'Sample Customer Description';
        io2.Tax_Credit_Rate__c = 30;
        io2.Incentive_Recipient__c = 'Owner';
        io2.Eligible_Cost_Basis__c ='Net of State Rebate';
        io2.Start_Date__c = date.today().addDays(-2);
        io2.Max_Rebate_Amount__c = 10000.00;
        io2.Flat_Rebate_Amount__c = 1000;
        offers.add(io2);
        
        Incentive_Offer__c io3 = new Incentive_Offer__c();
        io3.RecordTypeId = incentiveOfferRTMap.get('Tax Credit').getRecordTypeId();
        io3.Name = 'Sample Incentive Offer3';
        io3.Implementing_Sector__c = 'County';
        io3.Eligible_Sector__c = 'Residential';
        //io3.Eligible_State__c = 'MD';
        io3.Eligible_County__c = 'Howard County, MD';
        io3.Eligible_Financing_Type__c = 'Purchase';
        io3.Customer_Description__c = 'Sample Customer Description';
        io3.Tax_Credit_Rate__c = 30;
        io3.Incentive_Recipient__c = 'Owner';
        //io3.SAC_Eligible__c = true;
        io3.Eligible_Cost_Basis__c ='Net of Federal Tax Credit';
        io3.Start_Date__c = date.today().addDays(-2);
        //io3.Eligible_Cost_Basis__c ='Net of State Rebate';
        io3.Credit_Capped_by_Annual_Tax_Obligation__c = true;
        io3.System_Size_Units__c = 'AC';
        io3.Flat_Rebate_Amount__c = 1000;
        offers.add(io3);
        
        Incentive_Offer__c io4 = new Incentive_Offer__c();
        io4.RecordTypeId = incentiveOfferRTMap.get('Tax Credit').getRecordTypeId();
        io4.Name = 'Sample Incentive Offer4';
        io4.Implementing_Sector__c = 'Federal';
        io4.Eligible_Sector__c = 'Residential';
        //io4.Eligible_State__c = 'MD';
        io4.Eligible_Financing_Type__c = 'Lease';
        io4.Customer_Description__c = 'Sample Customer Description';
        io4.Tax_Credit_Rate__c = 30;
        io4.Incentive_Recipient__c = 'Owner';
        //io4.SAC_Eligible__c = true;
        io4.Eligible_Cost_Basis__c ='Net of Federal Tax Credit';
        io4.Start_Date__c = date.today().addDays(-2);
        //io4.Eligible_Cost_Basis__c ='Net of State Rebate';
        io4.Credit_Capped_by_Annual_Tax_Obligation__c = true;
        io4.Flat_Rebate_Amount__c = 1000;
        offers.add(io4) ;
        
        Incentive_Offer__c io5 = new Incentive_Offer__c();
        io5.RecordTypeId = incentiveOfferRTMap.get('Rebate ($/W)').getRecordTypeId();
        io5.Name = 'Sample Incentive Offer2';
        io5.Implementing_Sector__c = 'State';
        io5.Eligible_Sector__c = 'Residential';
        io5.Eligible_State__c = 'MD';
        io5.Eligible_Financing_Type__c = 'Purchase';
        io5.Customer_Description__c = 'Sample Customer Description';
        io5.Tax_Credit_Rate__c = 30;
        io5.Incentive_Recipient__c = 'Owner';
        io5.Eligible_Cost_Basis__c ='Net of State Rebate';
        io5.Start_Date__c = date.today().addDays(-2);
        io5.Max_Rebate_Amount__c = 10000.00;
        io5.Flat_Rebate_Amount__c = 1000;
        //io5.Size_Panel_Capped__c = true;
        io5.Tier_1_Incentive_Rate_W__c = 5;
        io5.Tier_1_Maximum_System_Size_kW__c = 50;
        io5.Tier_2_Incentive_Rate_W__c = 5;
        io5.Tier_2_Maximum_System_Size_kW__c = 50;
        //io5.System_Size_Units__c = 'PTC'
        offers.add(io5);

        insert offers;

        return offers;
    }
    
    //PB 04/29/2015
    public static Available_Incentive_Offer__c createAvailIncentiveOffer(Id sdqId, Incentive_Offer__c io, String ScenarioN, String recordTypeName){
        Map<String, Schema.RecordTypeInfo> incentiveOfferRTMap = Schema.SObjectType.Available_Incentive_Offer__c.getRecordTypeInfosByName();
        Available_Incentive_Offer__c aio = new Available_Incentive_Offer__c();
        aio.RecordTypeId = incentiveOfferRTMap.get(recordTypeName).getRecordTypeId();
        aio.System_Design_Quote__c = sdqId;
        aio.Incentive_Offer__c = io.Id;
        aio.Applicable_Scenario__c = ScenarioN;
        aio.Incentive_Applied__c = true;
        aio.Opted_Out_Manually__c = false;
        aio.Current_Matching_Incentive__c = true;
        aio.Effective_Dollar_Amount__c = 500;
        insert aio;

        return aio;
        
    }
    
    //PB 04/29/2015
    public static SREC_Contract_Offer__c createSRECOffer(String finType){
        
        SREC_Market__c market = new SREC_Market__c();
        market.Name = 'Test Market';
        market.Compliance_State__c = 'MD';
        market.Eligible_States__c = 'MD';
        market.First_Month_of_Compliance_Year__c = '1';
        market.Last_Month_of_Compliance_Year__c = '6';
        market.Primary_States__c = 'MD';
        market.Payment_Month__c = 6;
        insert market;
        
        Map<String, Schema.RecordTypeInfo> srecOfferRTMap = Schema.SObjectType.SREC_Contract_Offer__c.getRecordTypeInfosByName();
        
        SREC_Contract_Offer__c offer = new SREC_Contract_Offer__c();
        offer.Name = 'Test srec offer' + finType;
        offer.SREC_Market__c = market.Id;
        offer.Financing_Type__c = finType;
        offer.Upfront_Amount__c = 25.00;
        offer.Eligible_States__c = 'MD';
        offer.Start_Date__c = Date.today();
        offer.Default_Offer__c = true;
        offer.RecordTypeId = srecOfferRTMap.get('Upfront').getRecordTypeId();
        insert offer;
        
        return offer;
    }
    
    public static Available_Incentive_Offer__c setupAvailableIncentiveOffer(Id sdqId, String implementingSector, String eligibleSector, String eligibleStates, String eligibleFinancingType){
        Map<String, Schema.RecordTypeInfo> incentiveOfferRTMap = Schema.SObjectType.Incentive_Offer__c.getRecordTypeInfosByName();

        Incentive_Offer__c io = new Incentive_Offer__c();
        io.RecordTypeId = incentiveOfferRTMap.get('Rebate ($)').getRecordTypeId();
        io.Name = 'Sample Incentive Offer';
        io.Implementing_Sector__c = implementingSector; // 'State';
        io.Eligible_Sector__c = eligibleSector; // 'Residential';
        io.Eligible_State__c = eligibleStates;
        io.Eligible_Financing_Type__c = eligibleFinancingType; // 'Purchase'
        io.Customer_Description__c = 'Sample Customer Description';
        io.Max_Rebate_Amount__c = 10000.00;

        insert io;

        Available_Incentive_Offer__c aio = new Available_Incentive_Offer__c();
        aio.System_Design_Quote__c = sdqId;
        aio.Incentive_Offer__c = io.Id;
        aio.Applicable_Scenario__c = '1';

        return aio;
    }
    
    public static void setupCommunityProgramOffers(){
        Account acct = new Account();
        acct.name='TestAcctForCPO';        
        insert acct;

        List<Community_Program_Offer__c> cpoList = new List<Community_Program_Offer__c>();

        Community_Program_Offer__c cpo = new Community_Program_Offer__c();
        cpo.Account__c = acct.id;
        cpo.Baseline_Site_Quality__c = 2000;
        cpo.Current_Tier__c = '1';
        cpo.Early_Adopter_Promotion__c = 100;
        cpo.Early_Adopter_Promotion_Available__c = true;
        cpo.Start_Date__c = Date.today().toStartOfMonth();
        cpo.Extension_End_Date__c = Date.today().addMonths(1).addDays(15);
        cpo.Initial_End_Date__c = Date.today().addMonths(1);
        cpo.Eligibility_Criterion__c = 'ZIP';
        //cpo.Eligible_Values__c = '20701';
        cpoList.add(cpo);

        Community_Program_Offer__c cpo1 = new Community_Program_Offer__c();
        cpo1.Account__c = acct.id;
        cpo1.Baseline_Site_Quality__c = 2000;
        cpo1.Current_Tier__c = '1';
        cpo1.Early_Adopter_Promotion__c = 100;
        cpo1.Early_Adopter_Promotion_Available__c = true;
        cpo1.Start_Date__c = Date.today().toStartOfMonth();
        cpo1.Extension_End_Date__c = Date.today().addMonths(1).addDays(15);
        cpo1.Initial_End_Date__c = Date.today().addMonths(1);
        cpo1.Eligibility_Criterion__c = 'City';
        cpo1.Eligible_Values__c = defaultOffLocationName;
        cpoList.add(cpo1);

        Community_Program_Offer__c cpo2 = new Community_Program_Offer__c();
        cpo2.Account__c = acct.id;
        cpo2.Baseline_Site_Quality__c = 2000;
        cpo2.Current_Tier__c = '1';
        cpo2.Early_Adopter_Promotion__c = 100;
        cpo2.Early_Adopter_Promotion_Available__c = true;
        cpo2.Start_Date__c = Date.today().toStartOfMonth();
        cpo2.Extension_End_Date__c = Date.today().addMonths(1).addDays(15);
        cpo2.Initial_End_Date__c = Date.today().addMonths(1);
        cpo2.Eligibility_Criterion__c = 'County';
        cpo2.Eligible_Values__c = 'Howard county, MD, MD';
        cpoList.add(cpo2);

        insert cpoList;
    }
    
    //PB 04/29/2015
    public static System_Design_Quote__c setupSystemDesignQuotePricing(string propType, List<Lease_Fund__c> funds, boolean commProgram, double siteQuality){
        //USAGE:        
        //id sdID = testData.setupSystemDesignQuotePricing('Residential', leasefunds, true, 12000);

        //Account      
        Account acct = new Account();
        acct.name='TestAcct';        
        insert acct;
        
        //Contact
        Contact c = new Contact();
        c.FirstName = 'John';
        c.LastName = 'Smith';
        c.AccountId = acct.id;
        insert c;

        //Community Program Offer under any Account 
        Community_Program_Offer__c cpo = new Community_Program_Offer__c();
        cpo.Account__c = acct.id;
        cpo.Baseline_Site_Quality__c = 2000;
        cpo.Current_Tier__c = '1';
        cpo.Early_Adopter_Promotion__c = 100;
        cpo.Early_Adopter_Promotion_Available__c = true;
        cpo.Start_Date__c = Date.today().addDays(-2);
        cpo.Extension_End_Date__c = Date.today().addMonths(1).addDays(15);
        cpo.Initial_End_Date__c = Date.today().addMonths(1);
        cpo.Eligibility_Criterion__c = 'ZIP';
        cpo.Eligible_Values__c = '20701';
        insert cpo;
        
        //Property
        Property__c prop = new Property__c();
        prop.Name = '123 Main St';
        prop.RecordTypeid = [Select id from RecordType where sobjecttype = 'Property__c' and Name =: propType limit 1].id;
        prop.Property_Owner__c = acct.Id;       
        prop.Optimal_Site_Quality_kWh_y_kW__c = double.valueOf('1250');
        prop.Property_State__c = 'MD';
        prop.Property_City__c = 'Annapolis Junction';        
        prop.Property_ZIP__c = '20701';
        prop.Property_County__c = 'Howard';
        prop.Astrum_Office__c = defaultOffLocationName;        
        prop.Sales_Region__c = [select id from Astrum_Sales_Region__c where name='MD Region'].id;  
        prop.QAS_Property_County__c = 'Howard County, MD';    //DK 12-23-14
        insert prop;        
        
        //Survey
        Survey__c surv = new Survey__c();
        surv.Property__c = prop.Id;
        surv.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'Survey__c' and r.Name = 'Field Survey'].id;        
        insert surv;
        
        //Physical Surface
        Physical_Surface__c ps = new Physical_Surface__c();
        ps.Property__c = prop.Id; //New link to property
        ps.Surface_Tilt__c = 10;
        ps.Surface_Azimuth__c = 90;
        ps.Trenching_Dist_to_Intercon_Pt_ft__c = 10;
        ps.Suneye_Tilt_and_Orien_Factor__c = 2;        
        ps.Physical_Surface_Assigned_Letter__c = 'A'; //MK 2014-05-02
        ps.Surface_Type__c = 'Asphalt Shingle';//MK 2014-05-02
        insert ps; 
        
        //Get PS in order to get the default mounting type
        ps = [select id, Default_Mounting_Type__c, Property__c, Surface_Tilt__c, Surface_Azimuth__c,
                Trenching_Dist_to_Intercon_Pt_ft__c, Suneye_Tilt_and_Orien_Factor__c, Surface_Type__c, 
                Name, Physical_Surface_Assigned_Letter__c from Physical_Surface__c where id =: ps.id];


        //Install Location
        Install_Location__c instLoc = new Install_Location__c();
        instLoc.Physical_Surface__c = ps.id; //This is the master relationship now
        //instLoc.Property__c = prop.Id; //MK 2014-05-02        
        instLoc.Location__c = 'S01';//MK 2014-05-02        
        instLoc.Survey__c = surv.id;//MK 2014-05-02
        instLoc.Azimuth__c = double.valueOf('180');
        instLoc.Pitch__c = double.valueOf('23');
        instLoc.TSRF__c = double.valueOf('90');
        insert instLoc;
        
        //Utility Company master
        Utility_Company_Master__c utilCompany = new Utility_Company_Master__c();
        utilCompany.Name = 'BG&E';
        utilCompany.Solar_Compensation_Method__c = 'Net Metering';
        utilCompany.State_Serviced__c = 'MD';
        insert utilCompany;
        
        //Utility Rate Code
        Utility_Company__c urc = new Utility_Company__c();
        urc.Name = 'R1';
        urc.Utility_Company_Master__c = utilCompany.ID;
        urc.All_Electric_Service__c = 'No';
        urc.Utility_Service_Territory__c  = 'Test territory';
        urc.All_Electric_Service__c = 'Not Applicable';
        urc.Sector__c ='Residential';       
        insert urc;
        
        Id marylandRegion = [SELECT ID FROM Pricing_Region__c WHERE Name = 'Maryland' LIMIT 1].ID;

        //Utility By Zip Code
        Utility_by_Zip_Code__c  utilByZip = new Utility_by_Zip_Code__c();
        utilByZip.Name = 'BG&E';
        utilByZip.Utility_Zip_Code__c = '20701';
        utilByZip.Utility_Company_Master__c = utilCompany.Id;
        utilByZip.Start_Date__c = Date.today().addYears(-2);
        utilByZip.Pricing_Region__c = marylandRegion;
        insert utilByZip; 
        
        //Utility Service
        Utility_Service__c utilService = new Utility_Service__c();
        utilService.Amperage__c = double.valueOf('200');
        utilService.Utility_Company__c = urc.Id;
        utilService.Utility_Rate_Code_Before_Solar__c = urc.Id;
        utilService.Utility_Rate_Code_After_Solar__c = urc.Id;
        utilService.Utility_Company_Master__c = utilCompany.ID;
        utilService.Property__c = prop.Id;
        utilService.Service_Account_Number__c = 'abc123';
        insert utilService;

        //CB Panel
        CB_Panel__c mainPanel = new CB_Panel__c();
        mainPanel.Name = 'Suniva';
        mainPanel.Utility_Service__c = utilService.Id;
        mainPanel.Main_Breaker_Rating_Amps__c = Double.valueOf('200');
        System.debug('mainPanel --> ' + mainPanel);      
        insert mainPanel;

        //SYSTEM DESIGN OBJECTS
        //==============================
        Map<String, ID> sdpRecTypes = new Map<String, ID>();
        for (RecordType rt : [SELECT Name FROM RecordType WHERE sObjectType = 'System_Design_Product__c']){     //DK 10/27/15
            sdpRecTypes.put(rt.Name, rt.ID);
        }

        List<System_Design_Product__c> sysProducts = new List<System_Design_Product__c>();
        System_Design_Product__c sdp = new System_Design_Product__c();
        sdp.RecordTypeId = sdpRecTypes.get('Panel');
        sdp.Description__c  = 'Sanyo 215';
        sdp.End_Clamp_Type__c = 'F End Clamp';  
        sdp.Make__c  = 'Sanyo';
        sdp.Max_Voltage__c = double.valueOf('600');
        sdp.Mid_Clamp_Type__c = 'F Mid Clamp';  
        sdp.Model__c = 'HIT Power 215N';
        sdp.Rated_Output_W__c = double.valueOf('300');
        sdp.Unit__c = 'Count';
        sysProducts.add(sdp);
        
        System_Design_Product__c sdp1 = new System_Design_Product__c();
        sdp1.RecordTypeId = sdpRecTypes.get('Inverter');
        sdp1.Description__c  = 'M215-60-240-S22';
        sdp1.End_Clamp_Type__c = 'F End Clamp';  
        sdp1.Make__c  = 'Enphase';
        sdp1.Max_Voltage__c = double.valueOf('600');
        sdp1.Mid_Clamp_Type__c = 'F Mid Clamp';  
        sdp1.Model__c = 'M215-60-240-S22';
        sdp1.Rated_Output_W__c = double.valueOf('300');
        sdp1.Unit__c = 'Count';
        sysProducts.add(sdp1);
        
        System_Design_Product__c trench = new System_Design_Product__c();
        trench.RecordTypeId = sdpRecTypes.get('Trenching');
        trench.Description__c  = 'Test Trench 1 - Aluminum';         
        trench.Unit__c = 'Count';
        trench.Wire_Type__c = 'Aluminum';
        sysProducts.add(trench);
        
        System_Design_Product__c mounting = new System_Design_Product__c();
        mounting.RecordTypeId = sdpRecTypes.get('Mounting');
        mounting.Description__c  = 'Test Ballasted System';       
        sysProducts.add(mounting);
        
        System_Design_Product__c specialPart = new System_Design_Product__c();
        specialPart.RecordTypeId = sdpRecTypes.get('Special Part');
        specialPart.Description__c  = 'Test Special Part';
        specialPart.Unit__c = 'Count';
        specialPart.Active__c = true;
        sysProducts.add(specialPart);
        insert sysProducts;
        
        //System Design
        System_Design__c sd = new System_Design__c();
        sd.Property__c = prop.Id;        
        sd.Calculated_System_Price__c = decimal.valueOf('100000.25');
        sd.Default_CB_Panel__c = mainPanel.ID;    //DK 12-22-14
        sd.System_Inverter__c = sysProducts[1].ID;
        sd.Astrum_SQ_Calculation_Status__c = 'Valid';
        //sd.NRG_Overall_Site_Quality__c = siteQuality;
        //sd.Sunnova_Overall_Site_Quality__c = siteQuality;
        insert sd;
                
        //System Design Array
        System_Design_Array__c sda = new System_Design_Array__c();
        sda.CB_Panel__c = mainPanel.Id;
        sda.System_Design__c = sd.Id;
        sda.Physical_Surface__c = ps.id;//MK 2014-05-02
        sda.Survey__c = surv.id;//MK 2014-05-02
        sda.Mounting_Type__c = ps.Default_Mounting_Type__c;//MK 2014-05-02
        insert sda;
        
        //System Design Items
        List<System_Design_Item__c> items = new List<System_Design_Item__c>();
        
        System_Design_Item__c sdi = new System_Design_Item__c();
        sdi.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Item__c' and r.Name = 'Panel'].id;
        sdi.System_Design_Array__c = sda.Id;
        sdi.Install_Location__c = instLoc.Id;
        sdi.System_Design_Product__c = sysProducts[0].Id;
        sdi.Quantity__c = double.valueOf('10');
        sdi.Annual_Solar_Access__c = double.valueOf('90');
        sdi.NRG_Site_Quality__c = siteQuality;
        sdi.Sunnova_Site_Quality__c = siteQuality;
        sdi.Astrum_PV_Watts_Site_Quality__c = siteQuality;
        items.add(sdi);
        
        System_Design_Item__c sdiMount = new System_Design_Item__c();
        sdiMount.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Item__c' and r.Name = 'Mounting'].id;
        sdiMount.System_Design_Array__c = sda.Id;
        sdiMount.System_Design_Product__c = sysProducts[3].Id;
        sdiMount.Quantity__c = double.valueOf('1');
        sdiMount.Astrum_Balance_of_System_Derate_Text__c = 0.964;        
        items.add(sdiMount);
        
        System_Design_Item__c sdiTrench = new System_Design_Item__c();
        sdiTrench.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Item__c' and r.Name = 'Trenching'].id;
        sdiTrench.System_Design_Array__c = sda.Id;
        sdiTrench.System_Design_Product__c = sysProducts[2].Id;
        sdiTrench.Quantity__c = double.valueOf('1');
        sdiTrench.Total_Trenching_Lengthft__c = 5;
        items.add(sdiTrench); 
        
        System_Design_Item__c sdiSpPart = new System_Design_Item__c();
        sdiSpPart.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Item__c' and r.Name = 'Special Part'].id;
        sdiSpPart.System_Design_Array__c = sda.Id;
        sdiSpPart.System_Design_Product__c = sysProducts[4].Id;
        sdiSpPart.Quantity__c = double.valueOf('1');
        sdiSpPart.Tilt_Text__c = '0';
        sdiSpPart.TSRF_Adjustment__c = 0;
        sdiSpPart.Astrum_Balance_of_System_Derate_Text__c = 0.964;
        items.add(sdiSpPart);  
        
        insert items;

        //PRICING DEPENDANT OBJECTS
        //==============================

        //Insert System Pricing Table For Panel
        List<System_Pricing_Table__c> pricingTables = new List<System_Pricing_Table__c>();
        System_Pricing_Table__c spt = new System_Pricing_Table__c();
        spt.Panel_Type__c = sdp.id;
        spt.Sales_Region__c = prop.Sales_Region__c;
        spt.Pricing_Region__c = marylandRegion;   
        spt.Financing_Type__c = 'Purchase';        
        //spt.Lease_Fund__c = funds[1].Id; 
        if(commProgram) spt.Community_Program_Offer__c = cpo.id;
        spt.Community_Program_Tier__c = '1';
        spt.Start_Date__c = date.today().addDays(-1);
        spt.End_Date__c = date.today().addDays(2);
        spt.count_10_root_price__c = 2500;
        spt.count_20_root_price__c = 2470;
        spt.count_30_root_price__c = 2450;
        spt.Unique_ID__c = 'ThisFieldIsRequiredSoWeMustSetIt4321';    
        pricingTables.add(spt);
        
        System_Pricing_Table__c spt2 = new System_Pricing_Table__c();
        spt2.Panel_Type__c = sdp.id;
        spt2.Sales_Region__c = prop.Sales_Region__c;
        spt2.Pricing_Region__c = marylandRegion;     
        spt2.Financing_Type__c = 'Lease';        
        spt2.Lease_Fund__c = funds[2].Id; 
        if(commProgram) spt2.Community_Program_Offer__c = cpo.id;
        spt2.Community_Program_Tier__c = '1';
        spt2.Start_Date__c = date.today().addDays(-1);
        spt2.End_Date__c = date.today().addDays(2);
        spt2.count_10_root_price__c = 2500;
        spt2.count_20_root_price__c = 2470;
        spt2.count_30_root_price__c = 2450;
        spt2.Unique_ID__c = 'ThisFieldIsRequiredSoWeMustSetIt2345';    
        pricingTables.add(spt2);
        
        insert pricingTables;
        
        //List<System_Pricing_Table__c> tables = [SELECT Pricing_Region__c, Community_Program_Offer__c, Community_Program_Tier__c, Start_Date__c, End_Date__c FROM System_Pricing_Table__c];
        //for(System_Pricing_Table__c table: tables){
        //    System.debug(loggingLevel.ERROR,'------PANELS------');
        //    System.debug(loggingLevel.ERROR, 'Pricing_Region__c:' + table.Pricing_Region__c + ' ' + 'Community_Program_Offer__c:'  + table.Community_Program_Offer__c + ' ' + 'Community_Program_Tier__c' + table.Community_Program_Tier__c + ' ' + 'Start_Date__c' + table.Start_Date__c + ' ' + 'End_Date__c' + table.End_Date__c);
        //}
        
        //SDP Price Entry for non-panel pricing      
        
        //For inverter
        List<SDP_Price_Entry__c> entries = new List<SDP_Price_Entry__c>();
        ID inverterTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'SDP_Price_Entry__c' and r.Name = 'Inverter'].id;
        SDP_Price_Entry__c sdpPE = new SDP_Price_Entry__c();
        sdpPE.RecordTypeId = inverterTypeId;
        sdpPE.System_Design_Product__c = sysProducts[1].id;
        sdpPE.Start_Date__c = date.today().addDays(-1);
        sdpPE.End_Date__c = date.today().addDays(2);
        sdpPE.Property_Record_Type__c = propType;
        sdpPE.Financing_Type__c = 'Purchase';
        //sdpPE.Lease_Fund__c = funds[1].Id;////Fund[0] - SAC Loan, Fund[1] - Term Loan, Fund[2] - Lease, Fund[3] - Term & SAC
        if(commProgram) sdpPE.Community_Program_Offer__c = cpo.id;
        sdpPE.Adder_W__c = 3; //For (Record Type = ‘Panel’, ‘Inverter’, ‘Mounting’, ’Trenching’, ‘Labor’)
        //sdpPE.Adder_ea__c = 2; //For (Record Type = ‘Special Part’)
        sdpPE.Unique_ID__c = 'ThereIsNoWayThatThisStringIsNotUnique12345';    //DK 11-2-14
        sdpPE.Maximum_Size_kW__c = 20;
        sdpPE.Minimum_Size_kW__c = 0;
        entries.add(sdpPE);
        
        SDP_Price_Entry__c sdpPELease = new SDP_Price_Entry__c();
        sdpPELease.RecordTypeId = inverterTypeId;
        sdpPELease.System_Design_Product__c = sysProducts[1].id;
        sdpPELease.Start_Date__c = date.today().addDays(-1);
        sdpPELease.End_Date__c = date.today().addDays(2);
        sdpPELease.Property_Record_Type__c = propType;
        sdpPELease.Financing_Type__c = 'Lease';
        sdpPELease.Lease_Fund__c = funds[2].Id;////Fund[0] - SAC Loan, Fund[1] - Term Loan, Fund[2] - Lease, Fund[3] - Term & SAC
        if(commProgram) sdpPELease.Community_Program_Offer__c = cpo.id;
        sdpPELease.Adder_W__c = 3; //For (Record Type = ‘Panel’, ‘Inverter’, ‘Mounting’, ’Trenching’, ‘Labor’)
        //sdpPE.Adder_ea__c = 2; //For (Record Type = ‘Special Part’)
        sdpPELease.Unique_ID__c = 'ThereIsNoWayThatThisStringIsNotUnique12345Lease';    //DK 11-2-14
        sdpPELease.Maximum_Size_kW__c = 20;
        sdpPELease.Minimum_Size_kW__c = 0;
        entries.add(sdpPELease);
        
        
        ID trenchTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'SDP_Price_Entry__c' and r.Name = 'Trenching'].id;
        SDP_Price_Entry__c sdpPE2 = new SDP_Price_Entry__c();
        sdpPE2.RecordTypeId = trenchTypeId;
        sdpPE2.System_Design_Product__c = sysProducts[2].id;
        sdpPE2.Start_Date__c = date.today().addDays(-1);
        sdpPE2.End_Date__c = date.today().addDays(2);
        sdpPE2.Property_Record_Type__c = propType;
        sdpPE2.Financing_Type__c = 'Purchase';
        //sdpPE2.Lease_Fund__c = funds[1].Id;////Fund[0] - SAC Loan, Fund[1] - Term Loan, Fund[2] - Lease, Fund[3] - Term & SAC
        if(commProgram) sdpPE2.Community_Program_Offer__c = cpo.id;
        sdpPE2.Adder_W__c = 3; //For (Record Type = ‘Panel’, ‘Inverter’, ‘Mounting’, ’Trenching’, ‘Labor’)
        //sdpPE.Adder_ea__c = 2; //For (Record Type = ‘Special Part’)
        sdpPE2.Unique_ID__c = 'ThereIsNoWayThatThisStringIsNotUnique23456'; 
        sdpPE2.Maximum_Size_kW__c = 20;
        sdpPE2.Minimum_Size_kW__c = 0;
        entries.add(sdpPE2);
        
        SDP_Price_Entry__c sdpPE2Lease = new SDP_Price_Entry__c();
        sdpPE2Lease.RecordTypeId = trenchTypeId;
        sdpPE2Lease.System_Design_Product__c = sysProducts[2].id;
        sdpPE2Lease.Start_Date__c = date.today().addDays(-1);
        sdpPE2Lease.End_Date__c = date.today().addDays(2);
        sdpPE2Lease.Property_Record_Type__c = propType;
        sdpPE2Lease.Financing_Type__c = 'Lease';
        sdpPE2Lease.Lease_Fund__c = funds[2].Id;////Fund[0] - SAC Loan, Fund[1] - Term Loan, Fund[2] - Lease, Fund[3] - Term & SAC
        if(commProgram) sdpPE2Lease.Community_Program_Offer__c = cpo.id;
        sdpPE2Lease.Adder_W__c = 3; //For (Record Type = ‘Panel’, ‘Inverter’, ‘Mounting’, ’Trenching’, ‘Labor’)
        //sdpPE.Adder_ea__c = 2; //For (Record Type = ‘Special Part’)
        sdpPE2Lease.Unique_ID__c = 'ThereIsNoWayThatThisStringIsNotUnique23456Lease'; 
        sdpPE2Lease.Maximum_Size_kW__c = 20;
        sdpPE2Lease.Minimum_Size_kW__c = 0;
        entries.add(sdpPE2Lease);
        
        ID mountingTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'SDP_Price_Entry__c' and r.Name = 'Mounting'].id;
        SDP_Price_Entry__c sdpPE3 = new SDP_Price_Entry__c();
        sdpPE3.RecordTypeId = mountingTypeId;
        sdpPE3.System_Design_Product__c = sysProducts[3].id;
        sdpPE3.Start_Date__c = date.today().addDays(-1);
        sdpPE3.End_Date__c = date.today().addDays(2);
        sdpPE3.Property_Record_Type__c = propType;
        sdpPE3.Financing_Type__c = 'Purchase';
        //sdpPE2.Lease_Fund__c = funds[1].Id;////Fund[0] - SAC Loan, Fund[1] - Term Loan, Fund[2] - Lease, Fund[3] - Term & SAC
        if(commProgram) sdpPE3.Community_Program_Offer__c = cpo.id;
        sdpPE3.Adder_W__c = 3; //For (Record Type = ‘Panel’, ‘Inverter’, ‘Mounting’, ’Trenching’, ‘Labor’)
        //sdpPE.Adder_ea__c = 2; //For (Record Type = ‘Special Part’)
        sdpPE3.Unique_ID__c = 'ThereIsNoWayThatThisStringIsNotUnique6789'; 
        sdpPE3.Maximum_Size_kW__c = 20;
        sdpPE3.Minimum_Size_kW__c = 0;
        entries.add(sdpPE3);
        
        SDP_Price_Entry__c sdpPE3Lease = new SDP_Price_Entry__c();
        sdpPE3Lease.RecordTypeId = mountingTypeId;
        sdpPE3Lease.System_Design_Product__c = sysProducts[3].id;
        sdpPE3Lease.Start_Date__c = date.today().addDays(-1);
        sdpPE3Lease.End_Date__c = date.today().addDays(2);
        sdpPE3Lease.Property_Record_Type__c = propType;
        sdpPE3Lease.Financing_Type__c = 'Lease';
        sdpPE3Lease.Lease_Fund__c = funds[2].Id;////Fund[0] - SAC Loan, Fund[1] - Term Loan, Fund[2] - Lease, Fund[3] - Term & SAC
        if(commProgram) sdpPE3Lease.Community_Program_Offer__c = cpo.id;
        sdpPE3Lease.Adder_W__c = 3; //For (Record Type = ‘Panel’, ‘Inverter’, ‘Mounting’, ’Trenching’, ‘Labor’)
        //sdpPE.Adder_ea__c = 2; //For (Record Type = ‘Special Part’)
        sdpPE3Lease.Unique_ID__c = 'ThereIsNoWayThatThisStringIsNotUnique6789Lease'; 
        sdpPE3Lease.Maximum_Size_kW__c = 20;
        sdpPE3Lease.Minimum_Size_kW__c = 0;
        entries.add(sdpPE3Lease);
        
        ID spTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'SDP_Price_Entry__c' and r.Name = 'Special Part'].id;
        SDP_Price_Entry__c sdpPE4 = new SDP_Price_Entry__c();
        sdpPE4.RecordTypeId = spTypeId;
        sdpPE4.System_Design_Product__c = sysProducts[4].id;
        sdpPE4.Start_Date__c = date.today().addDays(-1);
        sdpPE4.End_Date__c = date.today().addDays(2);
        sdpPE4.Property_Record_Type__c = propType;
        sdpPE4.Financing_Type__c = 'Purchase';
        //sdpPE2.Lease_Fund__c = funds[1].Id;////Fund[0] - SAC Loan, Fund[1] - Term Loan, Fund[2] - Lease, Fund[3] - Term & SAC
        if(commProgram) sdpPE4.Community_Program_Offer__c = cpo.id;
        //sdpPE4.Adder_W__c = 3; //For (Record Type = ‘Panel’, ‘Inverter’, ‘Mounting’, ’Trenching’, ‘Labor’)
        sdpPE.Adder_ea__c = 2; //For (Record Type = ‘Special Part’)
        sdpPE4.Unique_ID__c = 'ThereIsNoWayThatThisStringIsNotUnique7890'; 
        sdpPE4.Maximum_Size_kW__c = 20;
        sdpPE4.Minimum_Size_kW__c = 0;
        entries.add(sdpPE4);
        
        SDP_Price_Entry__c sdpPE4Lease = new SDP_Price_Entry__c();
        sdpPE4Lease.RecordTypeId = spTypeId;
        sdpPE4Lease.System_Design_Product__c = sysProducts[4].id;
        sdpPE4Lease.Start_Date__c = date.today().addDays(-1);
        sdpPE4Lease.End_Date__c = date.today().addDays(2);
        sdpPE4Lease.Property_Record_Type__c = propType;
        sdpPE4Lease.Financing_Type__c = 'Lease';
        sdpPE4Lease.Lease_Fund__c = funds[2].Id;////Fund[0] - SAC Loan, Fund[1] - Term Loan, Fund[2] - Lease, Fund[3] - Term & SAC
        if(commProgram) sdpPE4Lease.Community_Program_Offer__c = cpo.id;
        //sdpPE4.Adder_W__c = 3; //For (Record Type = ‘Panel’, ‘Inverter’, ‘Mounting’, ’Trenching’, ‘Labor’)
        sdpPE4Lease.Adder_ea__c = 2; //For (Record Type = ‘Special Part’)
        sdpPE4Lease.Unique_ID__c = 'ThereIsNoWayThatThisStringIsNotUnique7890Lease'; 
        sdpPE4Lease.Maximum_Size_kW__c = 20;
        sdpPE4Lease.Minimum_Size_kW__c = 0;
        entries.add(sdpPE4Lease);
        
        insert entries;
        
        //List<SDP_Price_Entry__c> priceEntries = [Select s.Lease_Fund__c, s.Property_Record_Type__c, s.Financing_Type__c, s.Start_Date__c, s.End_Date__c, s.Community_Program_Offer__c From SDP_Price_Entry__c s];
        //for(SDP_Price_Entry__c entry: priceEntries){
        //    System.debug(loggingLevel.ERROR,'------iNVERTERS------');
        //    System.debug(loggingLevel.ERROR, 'Lease_Fund__c:' +  entry.Lease_Fund__c + 'Property_Record_Type__c:' + entry.Property_Record_Type__c + ' ' + 'Financing_Type__c:'  + entry.Financing_Type__c + ' ' + 'Start_Date__c:' + entry.Start_Date__c + ' ' +  'End_Date__c:' + entry.End_Date__c + ' ' + 'Community_Program_Offer__c:' + entry.Community_Program_Offer__c);
            
        //}
        
        Trenching_Table__c trenchTable = new Trenching_Table__c();
        trenchTable.Unique_Id__c = 'testtrenchuniqueid';
        trenchTable.Adder_W__c = 1;
        trenchTable.Minimum_Size__c = 0;
        trenchTable.Maximum_Size__c = 100;
        trenchTable.Maximum_Trench_Length__c = 50;
        trenchTable.Minimum_Trench_Length__c = 0;
        trenchTable.Wire_Type__c = 'Aluminum';
        trenchTable.Community_Program_Offer__c = cpo.Id;
        trenchTable.Start_Date__c = date.today().addDays(-1);
        trenchTable.End_Date__c = date.today().addDays(2);
        insert trenchTable;
        
        //Select id, Adder__c, Adder_W__c  From Trenching_Table__c
        
        //Create sdq
        System_Design_Quote__c newsdq = SalesWorkflowValidationUtility.systemDesignQuoteWorkflowOnCreate(sd);        
        System_Design_Quote__c sdq = [SELECT Quoted_SREC_Market__c, System_Design__r.System_Panel__c, System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__c, 
                                        System_Design__r.Property__c from System_Design_Quote__c WHERE System_Design__c = :sd.id AND Current__c = true];
        sdq.Total_Closed_Scenario_Adjustments__c = 1;
        sdq.Pricing_Date__c = Date.today();
        update sdq;
        
        //Product2
        Product2 product = new Product2();
        product.Name='testProduct223';
        product.ProductCode = 'system';
        insert product;
        ID pbookID= Test.getStandardPricebookId();
        
        //PriceBookEntry
        PriceBookEntry entry = new PricebookEntry();
        entry.UnitPrice = 2.32;
        entry.PriceBook2Id = pbookID;
        entry.UseStandardPrice=FALSE;
        entry.Product2ID=product.id;
        entry.IsActive  = true;
        insert entry;
        
        //Opportunity
        Opportunity oppt = new Opportunity();
        oppt.AccountId = acct.id;
        oppt.name = 'Smith, John';
        oppt.CloseDate = Date.today();
        oppt.StageName = 'Closed - Won';
        oppt.Type = 'New Business';
        oppt.SREC__c = 'Yearly';
        oppt.State_Grant_Amount__c = double.valueOf('100.00');
        oppt.Property__c = prop.Id;
        oppt.Financing_Type__c = 'Purchase';
        oppt.Financing_Option__c = 'No Financing';
        oppt.LeadSource = 'Unknown';
        oppt.Lead_Source_Detail__c = 'Email';
        oppt.Leasing_Option__c = null;
        oppt.System_Design_Quote__c = sdq.Id;
        insert oppt;        

        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = c.id;
        ocr.IsPrimary = true;
        ocr.Role = 'Contract Signer';
        ocr.OpportunityId = oppt.Id; 
        insert ocr;
        
        if(commProgram) sdq.Community_Program_Offer__c = cpo.id;
        return sdq;

   }

    public static System_Design_Quote__c setupSystemDesignQuoteForContract(string propType, double siteQuality){
        //USAGE:        
        //id sdID = testData.setupSystemDesignQuotePricing('Residential', 12000);

        setupCustomSettingsPricing();

        //Account      
        Account acct = new Account();
        acct.name='TestAcct';        
        insert acct;
        
        //Contact
        Contact c = new Contact();
        c.FirstName = 'John';
        c.LastName = 'Smith';
        c.AccountId = acct.id;
        insert c;
        
        Astrum_Sales_Region__c salesRegion = new Astrum_Sales_Region__c(Name = 'MD Region', Sales_Coordinator__c = UserInfo.getUserID());
        insert salesRegion;

        //State and County for MD
        State__c marylandState = new State__c();
        marylandState.name = 'Maryland';
        marylandState.FIPS_Code__c = '24';
        marylandState.State_Abbreviation__c = 'MD';
        insert marylandState;

        Pricing_Region__c mdPricingRegion = new Pricing_Region__c(Name = 'Maryland');
        insert mdPricingRegion;

        County__c county = new County__c();
        county.Name = 'Howard County, MD';
        county.Pricing_Region__c = mdPricingRegion.ID;
        county.Sales_Region__c = 'MD Region';
        county.State__c = marylandState.ID;
        county.FIPS_Code__c = '24027';
        insert county;

        Office_Location__c hq = new Office_Location__c(Name = defaultOffLocationName, Street__c = '8955 Henkels Lane', City__c = 'Columbia', State__c = 'MD', Zip_Code__c = '20701', Director_of_Operations__c = UserInfo.getUserID(), Sales_Coordinator__c = UserInfo.getUserID(), 
                                Sales_Alert_Email__c = UserInfo.getUserEmail(), State_Coverage__c = 'MD; DC; VA', Location__Latitude__s = 39.125951, Location__Longitude__s = -76.794940, Active__c = true);
        insert hq;

        //Property
        Property__c prop = new Property__c();
        prop.Name = '123 Main St';
        prop.RecordTypeid = [Select id from RecordType where sobjecttype = 'Property__c' and Name =: propType limit 1].id;
        prop.Property_Owner__c = acct.Id;       
        prop.Optimal_Site_Quality_kWh_y_kW__c = double.valueOf('1250');
        prop.Property_State__c = 'MD';
        prop.Property_City__c = 'Annapolis Junction';        
        prop.Property_ZIP__c = '20701';
        prop.Property_County__c = 'Howard';
        prop.Astrum_Office__c = defaultOffLocationName;        
        prop.Sales_Region__c = salesRegion.ID;  
        prop.QAS_Property_County__c = 'Howard County, MD';    //DK 12-23-14
        insert prop;        
        
        //Survey
        Survey__c surv = new Survey__c();
        surv.Property__c = prop.Id;
        surv.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'Survey__c' and r.Name = 'Field Survey'].id;        
        insert surv;
        
        //Physical Surface
        Physical_Surface__c ps = new Physical_Surface__c();
        ps.Property__c = prop.Id; //New link to property
        ps.Surface_Tilt__c = 10;
        ps.Surface_Azimuth__c = 90;
        ps.Trenching_Dist_to_Intercon_Pt_ft__c = 10;
        ps.Suneye_Tilt_and_Orien_Factor__c = 2;        
        ps.Physical_Surface_Assigned_Letter__c = 'A';
        ps.Surface_Type__c = 'Asphalt Shingle';
        insert ps; 
        
        //Get PS in order to get the default mounting type
        ps = [select id, Default_Mounting_Type__c, Property__c, Surface_Tilt__c, Surface_Azimuth__c,
                Trenching_Dist_to_Intercon_Pt_ft__c, Suneye_Tilt_and_Orien_Factor__c, Surface_Type__c, 
                Name, Physical_Surface_Assigned_Letter__c from Physical_Surface__c where id =: ps.id];


        //Install Location
        Install_Location__c instLoc = new Install_Location__c();
        instLoc.Physical_Surface__c = ps.id;
        //instLoc.Property__c = prop.Id;      
        instLoc.Location__c = 'S01';       
        instLoc.Survey__c = surv.id;
        instLoc.Azimuth__c = double.valueOf('180');
        instLoc.Pitch__c = double.valueOf('23');
        instLoc.TSRF__c = double.valueOf('90');
        insert instLoc;
        
        //Utility Company master
        Utility_Company_Master__c utilCompany = new Utility_Company_Master__c();
        utilCompany.Name = 'BG&E';
        utilCompany.Solar_Compensation_Method__c = 'Net Metering';
        utilCompany.State_Serviced__c = 'MD';
        insert utilCompany;
        
        //Utility Rate Code
        Utility_Company__c urc = new Utility_Company__c();
        urc.Name = 'R1';
        urc.Utility_Company_Master__c = utilCompany.ID;
        urc.Utility_Service_Territory__c  = 'Test territory';
        urc.All_Electric_Service__c = 'Not Applicable';
        urc.Sector__c ='Residential';
        urc.All_Electric_Service__c = 'No';
        urc.Baseline_Consumption_kWh_day__c = '10.1;10.1;10.1;10.1;9.6;9.6;9.6;9.6;9.6;9.6;10.1;10.1';
        urc.Baseline_Consumption_kWh_month__c = 'NA';
        urc.Tier_1_Cap__c = 100;
        urc.Tier_2_Cap__c = 120;
        urc.Tier_3_Cap__c = 150;
        urc.Tier_4_Cap__c = 200;
        urc.Tier_5_Cap__c = 225;
        urc.Average_Consumption_Profile__c = '3.3;3.0;2.9;2.8;2.9;3.2;3.9;4.4;4.4;4.3;4.3;4.1;4.0;3.9;3.8;3.9;4.3;5.4;5.9;5.9;5.7;5.3;4.6;3.8;3.3;3.0;2.9;2.8;2.9;3.3;4.0;4.5;4.4;4.4;4.3;4.1;4.0;3.9;3.8;3.8;4.2;5.0;5.9;5.9;5.8;5.3;4.6;3.8;3.3;3.0;2.8;2.8;2.9;3.2;4.0;4.5;4.4;4.3;4.3;4.2;4.1;4.0;3.9;3.9;4.2;4.7;5.5;5.9;5.9;5.5;4.7;3.9;3.3;3.0;2.8;2.8;2.8;3.1;3.8;4.3;4.3;4.3;4.3;4.3;4.2;4.2;4.1;4.1;4.3;4.7;5.1;5.5;6.0;5.7;4.8;4.0;3.3;3.0;2.8;2.7;2.7;2.9;3.5;3.9;3.9;4.0;4.1;4.1;4.2;4.2;4.3;4.5;4.9;5.2;5.4;5.5;5.9;5.8;4.9;4.0;3.3;2.9;2.7;2.6;2.5;2.7;3.0;3.3;3.5;3.7;3.9;4.1;4.3;4.5;4.8;5.1;5.4;5.8;5.9;5.7;5.7;5.7;4.9;4.0;3.3;2.9;2.6;2.5;2.4;2.5;2.7;3.0;3.3;3.5;3.7;4.0;4.4;4.7;5.1;5.4;5.8;6.1;6.2;5.9;5.8;5.6;4.8;3.9;3.2;2.8;2.6;2.5;2.5;2.6;2.9;3.1;3.3;3.5;3.7;3.9;4.2;4.6;4.9;5.4;5.8;6.1;6.2;6.0;6.0;5.6;4.7;3.9;3.2;2.9;2.7;2.6;2.6;2.8;3.2;3.5;3.5;3.7;3.8;3.9;4.1;4.4;4.7;5.1;5.4;5.8;5.9;6.1;6.1;5.5;4.7;3.8;3.3;3.0;2.8;2.8;2.8;3.1;3.7;4.2;4.2;4.2;4.2;4.2;4.1;4.1;4.1;4.3;4.5;5.0;5.6;6.1;5.9;5.4;4.6;3.8;3.2;2.9;2.8;2.8;2.8;3.2;3.9;4.4;4.4;4.3;4.3;4.2;4.1;4.0;3.9;4.0;4.5;5.6;6.0;5.9;5.7;5.2;4.5;3.7;3.3;3.0;2.8;2.8;2.8;3.1;3.7;4.2;4.3;4.3;4.2;4.1;4.0;3.9;3.8;3.9;4.4;5.6;6.0;6.0;5.8;5.4;4.7;3.9;';
        urc.Weekend_Schedule__c = '111111111111111111111111222111111111111111111111111111111133111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';
        urc.Weekday_Schedule__c  = '111111111111111111111111111111111111111111111111221111111111111111111111111111133333311111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';    
        insert urc;
        
        //Utility By Zip Code
        Utility_by_Zip_Code__c  utilByZip = new Utility_by_Zip_Code__c();
        utilByZip.Name = 'BG&E';
        utilByZip.Utility_Zip_Code__c = '20701';
        utilByZip.Utility_Company_Master__c = utilCompany.Id;
        utilByZip.Start_Date__c = Date.today().addYears(-2);
        utilByZip.Pricing_Region__c = mdPricingRegion.ID;     //CPQ-751
        insert utilByZip; 
        
        //Utility Service        
        Utility_Service__c utilService = new Utility_Service__c();
        utilService.Amperage__c = double.valueOf('200');
        utilService.Utility_Company__c = urc.Id;
        utilService.Utility_Rate_Code_Before_Solar__c = urc.Id;
        utilService.Utility_Rate_Code_After_Solar__c = urc.Id;
        utilService.Utility_Company_Master__c = utilCompany.ID;
        utilService.Property__c = prop.Id;
        utilService.Service_Account_Number__c = 'abc123';
        utilService.Monthly_Electric_Consumption_KWH_Jan__c = 300;
        utilService.Monthly_Electric_Consumption_KWH_Feb__c = 320;
        utilService.Monthly_Electric_Consumption_KWH_Mar__c = 330;
        utilService.Monthly_Electric_Consumption_KWH_Apr__c = 340;
        utilService.Monthly_Electric_Consumption_KWH_May__c = 350;
        utilService.Monthly_Electric_Consumption_KWH_Jun__c = 360;
        utilService.Monthly_Electric_Consumption_KWH_Jul__c = 370;
        utilService.Monthly_Electric_Consumption_KWH_Aug__c = 370;
        utilService.Monthly_Electric_Consumption_KWH_Sep__c = 360;
        utilService.Monthly_Electric_Consumption_KWH_Oct__c = 350;
        utilService.Monthly_Electric_Consumption_KWH_Nov__c = 340;
        utilService.Monthly_Electric_Consumption_KWH_Dec__c = 330;
        insert utilService;

        //CB Panel
        CB_Panel__c mainPanel = new CB_Panel__c();
        mainPanel.Name = 'Suniva';
        mainPanel.Utility_Service__c = utilService.Id;
        mainPanel.Main_Breaker_Rating_Amps__c = Double.valueOf('200');
        System.debug('mainPanel --> ' + mainPanel);      
        insert mainPanel;

        //SYSTEM DESIGN OBJECTS
        //==============================
        List<System_Design_Product__c> sysProducts = new List<System_Design_Product__c>();
        System_Design_Product__c sdp = new System_Design_Product__c();
        sdp.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Product__c' and r.Name = 'Panel'].id;
        sdp.Description__c  = 'Sanyo 215';
        sdp.End_Clamp_Type__c = 'F End Clamp';  
        sdp.Make__c  = 'Sanyo';
        sdp.Max_Voltage__c = double.valueOf('600');
        sdp.Mid_Clamp_Type__c = 'F Mid Clamp';  
        sdp.Model__c = 'HIT Power 215N';
        sdp.Rated_Output_W__c = double.valueOf('300');
        sdp.Unit__c = 'Count';
        sysProducts.add(sdp);
        
        System_Design_Product__c sdp1 = new System_Design_Product__c();

        Map<String, ID> sdpRecTypes = new Map<String, ID>();
        for (RecordType rt : [SELECT Name FROM RecordType WHERE sObjectType = 'System_Design_Product__c']){
            sdpRecTypes.put(rt.Name, rt.ID);
        }

        sdp1.RecordTypeId = sdpRecTypes.get('Inverter');
        sdp1.Description__c  = 'M215-60-240-S22';
        sdp1.End_Clamp_Type__c = 'F End Clamp';  
        sdp1.Make__c  = 'Enphase';
        sdp1.Max_Voltage__c = double.valueOf('600');
        sdp1.Mid_Clamp_Type__c = 'F Mid Clamp';  
        sdp1.Model__c = 'M215-60-240-S22';
        sdp1.Rated_Output_W__c = double.valueOf('300');
        sdp1.Unit__c = 'Count';
        sysProducts.add(sdp1);
        
        System_Design_Product__c trench = new System_Design_Product__c();
        trench.RecordTypeId = sdpRecTypes.get('Trenching');
        trench.Description__c  = 'Test Trench 1 - Aluminum';         
        trench.Unit__c = 'Count';
        trench.Wire_Type__c = 'Aluminum';
        sysProducts.add(trench);
        
        System_Design_Product__c mounting = new System_Design_Product__c();
        mounting.RecordTypeId = sdpRecTypes.get('Mounting');
        mounting.Description__c  = 'Test Ballasted System';       
        sysProducts.add(mounting);
        
        System_Design_Product__c specialPart = new System_Design_Product__c();
        specialPart.RecordTypeId = sdpRecTypes.get('Special Part');
        specialPart.Description__c  = 'Test Special Part';
        specialPart.Unit__c = 'Count';
        specialPart.Active__c = true;
        sysProducts.add(specialPart);
        insert sysProducts;
        
        //System Design
        System_Design__c sd = new System_Design__c();
        sd.Property__c = prop.Id;        
        sd.Calculated_System_Price__c = decimal.valueOf('100000.25');
        sd.Default_CB_Panel__c = mainPanel.ID;
        sd.System_Inverter__c = sysProducts[1].ID;
        sd.Astrum_SQ_Calculation_Status__c = 'Valid';
        insert sd;
                
        //System Design Array
        System_Design_Array__c sda = new System_Design_Array__c();
        sda.CB_Panel__c = mainPanel.Id;
        sda.System_Design__c = sd.Id;
        sda.Physical_Surface__c = ps.id;
        sda.Survey__c = surv.id;
        sda.Mounting_Type__c = ps.Default_Mounting_Type__c;
        insert sda;
        
        //System Design Items
        List<System_Design_Item__c> items = new List<System_Design_Item__c>();
        
        Map<String, ID> sdiRecTypes = new Map<String, ID>();
        for (RecordType rt : [SELECT Name FROM RecordType WHERE sObjectType = 'System_Design_Item__c']){
            sdiRecTypes.put(rt.Name, rt.ID);
        }

        System_Design_Item__c sdi = new System_Design_Item__c();
        sdi.RecordTypeId = sdiRecTypes.get('Panel');
        sdi.System_Design_Array__c = sda.Id;
        sdi.Install_Location__c = instLoc.Id;
        sdi.System_Design_Product__c = sysProducts[0].Id;
        sdi.Quantity__c = double.valueOf('10');
        sdi.Annual_Solar_Access__c = double.valueOf('90');
        sdi.NRG_Site_Quality__c = siteQuality;
        sdi.Sunnova_Site_Quality__c = siteQuality;
        sdi.Astrum_PV_Watts_Site_Quality__c = siteQuality;
        items.add(sdi);
        
        System_Design_Item__c sdiMount = new System_Design_Item__c();
        sdiMount.RecordTypeId = sdiRecTypes.get('Mounting');
        sdiMount.System_Design_Array__c = sda.Id;
        sdiMount.System_Design_Product__c = sysProducts[3].Id;
        sdiMount.Quantity__c = double.valueOf('1');
        sdiMount.Astrum_Balance_of_System_Derate_Text__c = 0.964;        
        items.add(sdiMount);
        
        System_Design_Item__c sdiTrench = new System_Design_Item__c();
        sdiTrench.RecordTypeId = sdiRecTypes.get('Trenching');
        sdiTrench.System_Design_Array__c = sda.Id;
        sdiTrench.System_Design_Product__c = sysProducts[2].Id;
        sdiTrench.Quantity__c = double.valueOf('1');
        sdiTrench.Total_Trenching_Lengthft__c = 5;
        items.add(sdiTrench); 
        
        System_Design_Item__c sdiSpPart = new System_Design_Item__c();
        sdiSpPart.RecordTypeId = sdiRecTypes.get('Special Part');
        sdiSpPart.System_Design_Array__c = sda.Id;
        sdiSpPart.System_Design_Product__c = sysProducts[4].Id;
        sdiSpPart.Quantity__c = double.valueOf('1');
        sdiSpPart.Tilt_Text__c = '0';
        sdiSpPart.TSRF_Adjustment__c = 0;
        sdiSpPart.Astrum_Balance_of_System_Derate_Text__c = 0.964;
        items.add(sdiSpPart);  
        
        insert items;

        //PRICING DEPENDANT OBJECTS
        //==============================

        //Insert System Pricing Table For Panel
        Id marylandRegion = mdPricingRegion.ID;
        System_Pricing_Table__c spt = new System_Pricing_Table__c();
        spt.Panel_Type__c = sdp.id;
        spt.Sales_Region__c = prop.Sales_Region__c;
        spt.Pricing_Region__c = marylandRegion;   
        spt.Financing_Type__c = 'Purchase';        
        spt.Community_Program_Tier__c = '1';
        spt.Start_Date__c = date.today().addDays(-1);
        spt.End_Date__c = date.today().addDays(2);
        spt.count_10_root_price__c = 2500;
        spt.count_20_root_price__c = 2470;
        spt.count_30_root_price__c = 2450;
        spt.Unique_ID__c = 'ThisFieldIsRequiredSoWeMustSetIt4321';    

        insert spt;
        
        //SDP Price Entry for non-panel pricing      
        
        Map<String, ID> priceEntryRecTypes = new Map<String, ID>();
        for (RecordType rt : [SELECT Name FROM RecordType WHERE sObjectType = 'SDP_Price_Entry__c']){
            priceEntryRecTypes.put(rt.Name, rt.ID);
        }

        //For inverter
        List<SDP_Price_Entry__c> entries = new List<SDP_Price_Entry__c>();
        ID inverterTypeId = priceEntryRecTypes.get('Inverter');
        SDP_Price_Entry__c sdpPE = new SDP_Price_Entry__c();
        sdpPE.RecordTypeId = inverterTypeId;
        sdpPE.System_Design_Product__c = sysProducts[1].id;
        sdpPE.Start_Date__c = date.today().addDays(-1);
        sdpPE.End_Date__c = date.today().addDays(2);
        sdpPE.Property_Record_Type__c = propType;
        sdpPE.Financing_Type__c = 'Purchase';
        sdpPE.Adder_W__c = 3; //For (Record Type = ‘Panel’, ‘Inverter’, ‘Mounting’, ’Trenching’, ‘Labor’)
        //sdpPE.Adder_ea__c = 2; //For (Record Type = ‘Special Part’)
        sdpPE.Unique_ID__c = 'ThereIsNoWayThatThisStringIsNotUnique12345';
        sdpPE.Maximum_Size_kW__c = 20;
        sdpPE.Minimum_Size_kW__c = 0;
        entries.add(sdpPE);
        
        ID trenchTypeId = priceEntryRecTypes.get('Trenching');
        SDP_Price_Entry__c sdpPE2 = new SDP_Price_Entry__c();
        sdpPE2.RecordTypeId = trenchTypeId;
        sdpPE2.System_Design_Product__c = sysProducts[2].id;
        sdpPE2.Start_Date__c = date.today().addDays(-1);
        sdpPE2.End_Date__c = date.today().addDays(2);
        sdpPE2.Property_Record_Type__c = propType;
        sdpPE2.Financing_Type__c = 'Purchase';
        //sdpPE2.Lease_Fund__c = funds[1].Id;////Fund[0] - SAC Loan, Fund[1] - Term Loan, Fund[2] - Lease, Fund[3] - Term & SAC
        sdpPE2.Adder_W__c = 3; //For (Record Type = ‘Panel’, ‘Inverter’, ‘Mounting’, ’Trenching’, ‘Labor’)
        //sdpPE.Adder_ea__c = 2; //For (Record Type = ‘Special Part’)
        sdpPE2.Unique_ID__c = 'ThereIsNoWayThatThisStringIsNotUnique23456'; 
        sdpPE2.Maximum_Size_kW__c = 20;
        sdpPE2.Minimum_Size_kW__c = 0;
        entries.add(sdpPE2);
        
        ID mountingTypeId = priceEntryRecTypes.get('Mounting');
        SDP_Price_Entry__c sdpPE3 = new SDP_Price_Entry__c();
        sdpPE3.RecordTypeId = mountingTypeId;
        sdpPE3.System_Design_Product__c = sysProducts[3].id;
        sdpPE3.Start_Date__c = date.today().addDays(-1);
        sdpPE3.End_Date__c = date.today().addDays(2);
        sdpPE3.Property_Record_Type__c = propType;
        sdpPE3.Financing_Type__c = 'Purchase';
        //sdpPE2.Lease_Fund__c = funds[1].Id;////Fund[0] - SAC Loan, Fund[1] - Term Loan, Fund[2] - Lease, Fund[3] - Term & SAC
        sdpPE3.Adder_W__c = 3; //For (Record Type = ‘Panel’, ‘Inverter’, ‘Mounting’, ’Trenching’, ‘Labor’)
        //sdpPE.Adder_ea__c = 2; //For (Record Type = ‘Special Part’)
        sdpPE3.Unique_ID__c = 'ThereIsNoWayThatThisStringIsNotUnique6789'; 
        sdpPE3.Maximum_Size_kW__c = 20;
        sdpPE3.Minimum_Size_kW__c = 0;
        entries.add(sdpPE3);

        ID spTypeId = priceEntryRecTypes.get('Special Part');
        SDP_Price_Entry__c sdpPE4 = new SDP_Price_Entry__c();
        sdpPE4.RecordTypeId = spTypeId;
        sdpPE4.System_Design_Product__c = sysProducts[4].id;
        sdpPE4.Start_Date__c = date.today().addDays(-1);
        sdpPE4.End_Date__c = date.today().addDays(2);
        sdpPE4.Property_Record_Type__c = propType;
        sdpPE4.Financing_Type__c = 'Purchase';
        //sdpPE2.Lease_Fund__c = funds[1].Id;////Fund[0] - SAC Loan, Fund[1] - Term Loan, Fund[2] - Lease, Fund[3] - Term & SAC
        //sdpPE4.Adder_W__c = 3; //For (Record Type = ‘Panel’, ‘Inverter’, ‘Mounting’, ’Trenching’, ‘Labor’)
        sdpPE.Adder_ea__c = 2; //For (Record Type = ‘Special Part’)
        sdpPE4.Unique_ID__c = 'ThereIsNoWayThatThisStringIsNotUnique7890'; 
        sdpPE4.Maximum_Size_kW__c = 20;
        sdpPE4.Minimum_Size_kW__c = 0;
        entries.add(sdpPE4);
        insert entries;
        
        Trenching_Table__c trenchTable = new Trenching_Table__c();
        trenchTable.Unique_Id__c = 'testtrenchuniqueid';
        trenchTable.Adder_W__c = 1;
        trenchTable.Minimum_Size__c = 0;
        trenchTable.Maximum_Size__c = 100;
        trenchTable.Maximum_Trench_Length__c = 50;
        trenchTable.Minimum_Trench_Length__c = 0;
        trenchTable.Wire_Type__c = 'Aluminum';
        trenchTable.Start_Date__c = date.today().addDays(-1);
        trenchTable.End_Date__c = date.today().addDays(2);
        insert trenchTable;
        
        //Create sdq
        System_Design_Quote__c newsdq = SalesWorkflowValidationUtility.systemDesignQuoteWorkflowOnCreate(sd);        
        System_Design_Quote__c sdq = [Select System_Design__c from System_Design_Quote__c Where System_Design__c = :sd.ID And Current__c = true];
        sdq.Total_Closed_Scenario_Adjustments__c = 1;
        sdq.All_Electric_Service__c = false;
        sdq.Pricing_Date__c = Date.today();
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = true;
        update sdq;
        SystemDesignQuoteTriggerHandler.skipSystemDesignQuoteTrigger = false;
        
        //Product2
        Product2 product = new Product2();
        product.Name='testProduct223';
        product.ProductCode = 'system';
        insert product;
        ID pbookID= Test.getStandardPricebookId();
        
        //PriceBookEntry
        PriceBookEntry entry = new PricebookEntry();
        entry.UnitPrice = 2.32;
        entry.PriceBook2Id = pbookID;
        entry.UseStandardPrice=FALSE;
        entry.Product2ID=product.id;
        entry.IsActive  = true;
        insert entry;
        
        //Opportunity
        Opportunity oppt = new Opportunity();
        oppt.AccountId = acct.id;
        oppt.name = 'Smith, John';
        oppt.CloseDate = Date.today();
        oppt.StageName = 'Closed - Won';
        oppt.Type = 'New Business';
        oppt.SREC__c = 'Yearly';
        oppt.State_Grant_Amount__c = double.valueOf('100.00');
        oppt.Property__c = prop.Id;
        oppt.Financing_Type__c = 'Purchase';
        oppt.Financing_Option__c = 'No Financing';
        oppt.LeadSource = 'Unknown';
        oppt.Lead_Source_Detail__c = 'Email';
        oppt.Leasing_Option__c = null;
        oppt.System_Design_Quote__c = sdq.Id;
        insert oppt;        

        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = c.id;
        ocr.IsPrimary = true;
        ocr.Role = 'Contract Signer';
        ocr.OpportunityId = oppt.Id; 
        insert ocr;
        
        return sdq;
   }
    
    //PB 04/29/2015
    public static System_Design_Quote__c setupSDQPricingData(System_Design_Quote__c sdq){
        
        String finType = 'Purchase';
        //Create Lease Funds, Entitlements, Promotions, SREC Offers
        List<Lease_Fund__c> funds = createLeaseFunds();
        Entitlement_Offer__c entlOffer = createEntitlementOffer('Purchase',sdq.Community_Program_Offer__c);
        createProgramPromotion('Purchase');
        createStandardPromotions('Purchase');
        List<Incentive_Offer__c> incOffers = createIncentiveOffers();
        createSRECOffer('Purchase');        
        
         //Create available srec offers for sdq
        List<Available_SREC_Contract_Offer__c> avlOffers = 
            [Select id,Upfront_Effective_Dollar_Amount__c,Contract_Offer_Applied__c 
             ,SREC_Contract_Offer__r.Name 
             from Available_SREC_Contract_Offer__c 
             Where System_Design_Quote__c = :sdq.Id];
        for(Available_SREC_Contract_Offer__c avlOffer: avlOffers){
            sdq.put('Scenario_' + avlOffer.Applicable_Scenario__c + '_Available_SREC_Contract_Offer__c', avlOffer.Id);
        }
        
        //create available incentives for sdq
        createAvailIncentiveOffer(sdq.Id, incOffers[0], '1','Tax Credit');
        createAvailIncentiveOffer(sdq.Id, incOffers[1], '2','Rebate ($)');
        createAvailIncentiveOffer(sdq.Id, incOffers[2], '3','Tax Credit');
        createAvailIncentiveOffer(sdq.Id, incOffers[3], '4','Tax Credit');
        createAvailIncentiveOffer(sdq.Id, incOffers[4], '1', 'Rebate ($/W)');
        
        //Set sdq financing options
        sdq.Scenario_1_Financing_Type__c = finType;
        sdq.Scenario_1_Term_Loan__c = funds[1].Id;
        sdq.Scenario_2_Financing_Type__c = finType;
        sdq.Scenario_2_SAC_Loan__c = funds[0].Id; 
        sdq.Scenario_3_Financing_Type__c = finType;
        sdq.Scenario_3_Term_Loan__c = funds[1].Id;
        sdq.Scenario_3_SAC_Loan__c = funds[3].Id;
        sdq.Scenario_4_Financing_Type__c = 'Lease';
        sdq.Scenario_4_Lease_Fund__c = funds[2].Id;
        sdq.Scenario_4_Lease_Option__c = 'One-Pay';
        sdq.Scenario_4_Adjusted_Price_NUM__c = 1000;
        sdq.Scenario_1_VP_Sales_Adjustments__c = 2000.00;
        sdq.Scenario_2_VP_Sales_Adjustments__c = 2000.00;
        sdq.Scenario_3_VP_Sales_Adjustments__c = 2000.00;
        sdq.Scenario_4_VP_Sales_Adjustments__c = 2000.00;
        
        sdq.Scenario_1_Set_Standard_Adjustment_Type__c = 'Dollar Amount';
        sdq.Scenario_1_Set_Standard_Adjustment_Amoun__c = -1500;
        sdq.Scenario_2_Set_Standard_Adjustment_Type__c = 'Percentage';
        sdq.Scenario_2_Set_Standard_Adjustment_Amoun__c = -3;
        sdq.Scenario_3_Set_Standard_Adjustment_Type__c = 'Dollar Per Watt';
        sdq.Scenario_3_Set_Standard_Adjustment_Amoun__c = -0.05;
        
        sdq.Current__c = true;        
        
        
        return sdq;
        
    }
    
    //PB 04/29/2015
    public static System_Design_Quote__c setupSDQPricingData(System_Design_Quote__c sdq, List<Lease_Fund__c> funds){
        
        String finType = 'Purchase';
        //Create Lease Funds, Entitlements, Promotions, SREC Offers
        Entitlement_Offer__c entlOffer = createEntitlementOffer('Purchase', sdq.Community_Program_Offer__c);
        createProgramPromotion('Purchase');
        createStandardPromotions('Purchase');
        List<Incentive_Offer__c> incOffers = createIncentiveOffers();
        //Incentive_Offer__c incOffer2 = createIncentiveOffer('State', 'Residential', 'MD', 'Purchase');
        createSRECOffer('Purchase');        
        
         //Create available srec offers for sdq
        List<Available_SREC_Contract_Offer__c> avlOffers = 
            [Select id,Upfront_Effective_Dollar_Amount__c,Contract_Offer_Applied__c 
             ,SREC_Contract_Offer__r.Name 
             from Available_SREC_Contract_Offer__c 
             Where System_Design_Quote__c = :sdq.Id];
        for(Available_SREC_Contract_Offer__c avlOffer: avlOffers){
            sdq.put('Scenario_' + avlOffer.Applicable_Scenario__c + '_Available_SREC_Contract_Offer__c', avlOffer.Id);
        }
        
        //create available incentives for sdq
        createAvailIncentiveOffer(sdq.Id, incOffers[0], '1','Tax Credit');
        createAvailIncentiveOffer(sdq.Id, incOffers[1], '2','Rebate ($)');
        createAvailIncentiveOffer(sdq.Id, incOffers[2], '3','Tax Credit');
        createAvailIncentiveOffer(sdq.Id, incOffers[3], '4','Tax Credit');
        createAvailIncentiveOffer(sdq.Id, incOffers[4], '1', 'Rebate ($/W)');
        
        //Set sdq financing options
        sdq.Scenario_1_Financing_Type__c = finType;
        sdq.Scenario_1_Term_Loan__c = funds[1].Id;
        sdq.Scenario_2_Financing_Type__c = finType;
        sdq.Scenario_2_SAC_Loan__c = funds[0].Id; 
        sdq.Scenario_3_Financing_Type__c = finType;
        sdq.Scenario_3_Term_Loan__c = funds[1].Id;
        sdq.Scenario_3_SAC_Loan__c = funds[3].Id;
        sdq.Scenario_4_Financing_Type__c = 'Lease';
        sdq.Scenario_4_Lease_Fund__c = funds[2].Id;
        //sdq.Scenario_4_Lease_Option__c = 'One-Pay';
        sdq.Scenario_4_Lease_Option__c = 'Low-Upfront - Monthly';
        sdq.Scenario_4_Lease_Escalator__c = '0';
        sdq.Scenario_1_VP_Sales_Adjustments__c = 2000.00;
        sdq.Scenario_2_VP_Sales_Adjustments__c = 2000.00;
        sdq.Scenario_3_VP_Sales_Adjustments__c = 2000.00;
        sdq.Scenario_4_VP_Sales_Adjustments__c = 2000.00;
        
        sdq.Scenario_1_Set_Standard_Adjustment_Type__c = 'Dollar Amount';
        sdq.Scenario_1_Set_Standard_Adjustment_Amoun__c = -1500;
        sdq.Scenario_2_Set_Standard_Adjustment_Type__c = 'Percentage';
        sdq.Scenario_2_Set_Standard_Adjustment_Amoun__c = -3;
        sdq.Scenario_3_Set_Standard_Adjustment_Type__c = 'Dollar Per Watt';
        sdq.Scenario_3_Set_Standard_Adjustment_Amoun__c = -0.05;
        
        sdq.Current__c = true;        
        sdq.Total_Closed_Scenario_Adjustments__c = 1;
        
        return sdq;
        
    }
    
    //PB 04/29/2015
    public static System_Design_Quote__c getSDQFields(System_Design_Quote__c sdq){        
        
        String query = 'SELECT ';
        LIST<String> sdqFields = new LIST<String>{ 'System_Design_Stored_State__c', 'System_Design_Stored_State_Mismatch__c', 'System_Design_Reconstruction_Record__c',  
                                        'Sys_Design_Reconstruct_Record_Mismatch__c', 'Current__c', 'Valid__c', 'System_Design__c', 'All_Electric_Service__c', 'Validation_Errors__c', 
                                        'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_Before_Solar__r.All_Electric_Service__c',
                                        'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_After_Solar__r.All_Electric_Service__c' ,
                                        'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Name'  ,
                                        'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_After_Solar__r.Default_Rate_Code__c',
                                        'System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Company_Master__r.Has_Service_Territories__c',
                                        'System_Design__r.Default_CB_Panel__r.Name', 'System_Design__r.System_Inverter__r.Make__c', 'System_Design__r.Property__r.RecordType.DeveloperName',
                                        'System_Design__r.System_Inverter__r.RecordType.DeveloperName', 'Disqualifying_Validation_Errors__c', 'Annual_Electricity_Consumption_kWh__c' ,
                                        'System_Design__r.Astrum_SQ_Calculation_Status__c','System_Design__r.Property__c', 'System_Design__r.Property__r.Property_State__c', 'System_Size_kW__c',
                                        'Scenario_1_Financing_Rate_Year_1_kWh__c', 'Scenario_2_Financing_Rate_Year_1_kWh__c' ,
                                        'Scenario_3_Financing_Rate_Year_1_kWh__c', 'Scenario_4_Financing_Rate_Year_1_kWh__c', 'Scenario_1_Avoided_Utility_Rate__c',
                                        'Scenario_2_Avoided_Utility_Rate__c', 'Scenario_3_Avoided_Utility_Rate__c', 'Scenario_4_Avoided_Utility_Rate__c', 
                                        'Scenario_1_Total_Projected_Annual_Output__c' ,'Scenario_2_Total_Projected_Annual_Output__c', 'Scenario_3_Total_Projected_Annual_Output__c', 'Scenario_4_Total_Projected_Annual_Output__c',
                                        'Community_Program_Offer__c','Community_Program_Offer__r.Current_Tier__c','Community_Program_Offer__r.Early_Adopter_Promotion_Available__c' ,
                                        'Community_Program_Offer__r.name','Scenario_1_Design_Override_Price__c', 'Scenario_1_Net_Initial_Outlay__c',
                                        'Scenario_1_Financing_Type__c','Scenario_2_Financing_Type__c','Scenario_3_Financing_Type__c','Scenario_4_Financing_Type__c',
                                        'Scenario_1_Lease_Fund__c','Scenario_2_Lease_Fund__c','Scenario_3_Lease_Fund__c','Scenario_4_Lease_Fund__c',
                                        'Scenario_1_Lease_Option__c','Scenario_2_Lease_Option__c','Scenario_3_Lease_Option__c','Scenario_4_Lease_Option__c', 
                                        'Scenario_1_Error_Log__c' , 'Scenario_2_Error_Log__c', 'Scenario_3_Error_Log__c', 'Scenario_4_Error_Log__c',
                                        'Scenario_1_Down_Payment__c','Scenario_2_Down_Payment__c','Scenario_3_Down_Payment__c','Scenario_4_Down_Payment__c',
                                        'Scenario_1_Lease_Escalator__c','Scenario_2_Lease_Escalator__c','Scenario_3_Lease_Escalator__c','Scenario_4_Lease_Escalator__c',
                                        'Scenario_1_Available_SREC_Contract_Offer__c','Scenario_2_Available_SREC_Contract_Offer__c','Scenario_3_Available_SREC_Contract_Offer__c','Scenario_4_Available_SREC_Contract_Offer__c',
                                        'Scenario_1_Final_EPC_Price__c', 'Scenario_2_Final_EPC_Price__c','Scenario_3_Final_EPC_Price__c','Scenario_4_Final_EPC_Price__c',
                                        'Scenario_1_Installer_Paid_Incentive_Amt__c','Scenario_2_Installer_Paid_Incentive_Amt__c' ,'Scenario_3_Installer_Paid_Incentive_Amt__c','Scenario_4_Installer_Paid_Incentive_Amt__c',
                                        'Scenario_1_Prepaid_Financing_Amount__c','Scenario_2_Prepaid_Financing_Amount__c','Scenario_3_Prepaid_Financing_Amount__c','Scenario_4_Prepaid_Financing_Amount__c',
                                        'Scenario_1_Set_Standard_Adjustment_Type__c','Scenario_2_Set_Standard_Adjustment_Type__c','Scenario_3_Set_Standard_Adjustment_Type__c','Scenario_4_Set_Standard_Adjustment_Type__c',
                                        'Scenario_1_Term_Loan__c','Scenario_2_Term_Loan__c','Scenario_3_Term_Loan__c','Scenario_4_Term_Loan__c',
                                        'Scenario_1_SAC_Loan__c','Scenario_2_SAC_Loan__c','Scenario_3_SAC_Loan__c','Scenario_4_SAC_Loan__c','Total_Closed_Scenario_Adjustments__c',
                                        'Utility_Annual_Increase__c','Quoted_SREC_Market__c','Scenario_1_Available_SREC_Contract_Offer__r.SREC_Contract_Offer__c','Scenario_2_Available_SREC_Contract_Offer__r.SREC_Contract_Offer__c',
                                        'Scenario_3_Available_SREC_Contract_Offer__r.SREC_Contract_Offer__c','Scenario_4_Available_SREC_Contract_Offer__r.SREC_Contract_Offer__c'
                                        
                                        };
                                            
        for(String field: sdqFields){
            query+= field + ',';
        }
        
        query = query.RemoveEnd(',');
        query+= ',(SELECT  id,RecordType.DeveloperName,Implementing_Sector__c,Incentive_Applied__c,Applicable_Scenario__c FROM Available_Incentive_Offers__r)';
        query+= ' ,(SELECT p.id, p.Type__c, Amount__c, p.RecordType.DeveloperName, p.Apply_As_Net_Adjustment__c, p.Adjustment_Applied__c, p.Applicable_Scenario__c from Price_Adjustments__r p)from System_Design_Quote__c Where System_Design__c = '+ '\'' + sdq.System_Design__c + '\'' +' And Current__c = true LIMIT 1';
        System_Design_Quote__c quote = (System_Design_Quote__c) Database.query(query);

        return quote;
    }
    
    //PB 04/29/2015
    public static void setupLeaseAdjustmentTabel(Id communityProgId, Id leaseFundId){
        
        Lease_Adjustment_Table__c adjTable = new Lease_Adjustment_Table__c();
        
        County__c county = [SELECT Id, State__c,Pricing_Region__c FROM County__c WHERE Name = 'Howard County, MD'];
        adjTable.Unique_Id__c = 'Uniqueidfortestleaseadjtable1' + leaseFundId;
        adjTable.Pricing_Region__c = county.Pricing_Region__c;
        adjTable.state__c = 'MD';
        adjTable.Minimum_Size__c = 0;
        adjTable.Maximum_Size__c = 50;
        adjTable.Start_Date__c  = date.today().addDays(-2);
        adjTable.End_Date__c = date.today().addDays(2);
        adjTable.Community_Program_Offer__c = communityProgId;
        adjTable.Lease_Fund__c = leaseFundId;
        adjTable.SQ_Threshold_1__c = 1150;
        adjTable.SQ_Threshold_1_Adjustment__c = 0.001;
        adjTable.SQ_Adjustment_Type__c = '3';
        adjTable.Escalator_Adjustment__c = -0.1;
        
        insert adjTable;
        
        
    }
    
    //PB 04/29/2015
    public static void setupCustomSettingsPricing(){
        system.debug('setupCustomSettings');

        system.debug('setup SiteQualitySettings__c');
        SiteQualitySettings__c sq = new SiteQualitySettings__c();
        sq.Name = 'SiteQuality';
        sq.Batch_Size__c = 5;
        sq.CPRE__c = false;
        sq.NRG__c = false;
        sq.NRG_Batch_Size__C = 5;
        sq.Astrum__c = false;
        insert sq;
        
        system.debug('setup System_Design_Quote_Settings__c');
        System_Design_Quote_Settings__c sdqsettings = new System_Design_Quote_Settings__c();
        sdqsettings.Run_Promotions_Sync__c = true;
        sdqsettings.Run_Pricing_Automatically__c = false;
        sdqsettings.Run_CPO_matching_on_SDQs__c = true;
        sdqsettings.Scenario_1_Proposal_Term_Months__c = 240;
        sdqsettings.Scenario_2_Proposal_Term_Months__c = 240;
        sdqsettings.Scenario_3_Proposal_Term_Months__c = 240;
        sdqsettings.Scenario_4_Proposal_Term_Months__c = 240;
        sdqsettings.Run_SRECs_Sync__c = true;
        sdqsettings.Days_Proposal_Valid__c = 14;
        sdqsettings.Run_Incentives_Sync__c = true;
        sdqsettings.County_Pricing_Region_Cutoff_Date__c = Date.newInstance(2015, 12, 1);
        insert sdqsettings;
    }
    
    //PB 04/29/2015
    public static void setupCustomConfigObjectsPricing(){
        
        id uid = UserInfo.getUserId();
        string uemail = UserInfo.getUserEmail();
        
        //Sales regions
        system.debug('setup Astrum_Sales_Region__c');
        list<Astrum_Sales_Region__c> srList = new list<Astrum_Sales_Region__c>();
        srList.add(new Astrum_Sales_Region__c(Name = 'NYC Region', Sales_Coordinator__c=uid));
        srList.add(new Astrum_Sales_Region__c(Name = 'WNY Region', Sales_Coordinator__c=uid));
        srList.add(new Astrum_Sales_Region__c(Name = 'MA Region', Sales_Coordinator__c=uid));
        srList.add(new Astrum_Sales_Region__c(Name = 'PA Region', Sales_Coordinator__c=uid));
        srList.add(new Astrum_Sales_Region__c(Name = 'OH Region', Sales_Coordinator__c=uid));
        srList.add(new Astrum_Sales_Region__c(Name = 'MD Region', Sales_Coordinator__c=uid));
        srList.add(new Astrum_Sales_Region__c(Name = 'CA Region', Sales_Coordinator__c=uid));
        srList.add(new Astrum_Sales_Region__c(Name = 'CT Region', Sales_Coordinator__c=uid));
        //srList.add(new Astrum_Sales_Region__c(Name = ' Region'));
        insert srList;

        //Pricing Region
        system.debug('setup Pricing_Region__c');
        list<Pricing_Region__c> prList = new list<Pricing_Region__c>();        
        prList.add(new Pricing_Region__c(Name = 'California'));
        prList.add(new Pricing_Region__c(Name = 'Connecticut'));
        prList.add(new Pricing_Region__c(Name = 'Delaware'));
        prList.add(new Pricing_Region__c(Name = 'Maryland'));
        prList.add(new Pricing_Region__c(Name = 'New Jersey'));
        prList.add(new Pricing_Region__c(Name = 'Pennsylvania East'));
        prList.add(new Pricing_Region__c(Name = 'Pennsylvania West'));
        //prList.add(new Pricing_Region__c(Name = ''));
        insert prList;
        
        //State and County for MD
        State__c marylandState = new State__c();
        marylandState.name = 'Maryland';
        marylandState.FIPS_Code__c = '24';
        marylandState.State_Abbreviation__c = 'MD';
        insert marylandState;
        County__c county = new County__c();
        county.Name = 'Howard County, MD';
        county.Pricing_Region__c = prList[3].Id;
        county.Sales_Region__c = 'MD Region';
        county.State__c = marylandState.Id;
        county.FIPS_Code__c = '24027';
        insert county;

        createMainofficeSetting();
        
        //Office Locations
        system.debug('setup Office_Location__c');
        list<Office_Location__c> olList = new list<Office_Location__c>();
        olList.add(new Office_Location__c(Name = 'Annapolis Junction, MD', Street__c = '8955 Henkels Lane', City__c = 'Annapolis Junction', State__c = 'MD', Zip_Code__c = '20701', Director_of_Operations__c = uid, Sales_Coordinator__c = uid, Sales_Alert_Email__c = uemail, State_Coverage__c = 'MD; DC; VA', Location__Latitude__s = 39.125951, Location__Longitude__s = -76.794940, Active__c = true));
        olList.add(new Office_Location__c(Name = Main_Office_Location_Settings__c.getOrgDefaults().Name__c, Street__c = '8955 Henkels Lane', City__c = Main_Office_Location_Settings__c.getOrgDefaults().City__c, State__c = 'MD', Zip_Code__c = '20701', Director_of_Operations__c = uid, Sales_Coordinator__c = uid, Sales_Alert_Email__c = uemail, State_Coverage__c = 'MD; DC; VA', Location__Latitude__s = 39.125951, Location__Longitude__s = -76.794940, Active__c = true));
        olList.add(new Office_Location__c(Name = 'Corona, CA', Street__c = '505 E Rincon St#100', City__c = 'Corona', State__c = 'CA', Zip_Code__c = '92879', Director_of_Operations__c = uid, Sales_Coordinator__c = uid, Sales_Alert_Email__c = uemail, State_Coverage__c = 'CA', Location__Latitude__s = 33.886215, Location__Longitude__s = -117.560626, Active__c = true));
        olList.add(new Office_Location__c(Name = 'Henrietta, NY', Street__c = '395 Summit Point Drive', City__c = 'Henrietta', State__c = 'NY', Zip_Code__c = '14467', Director_of_Operations__c = uid, Sales_Coordinator__c = uid, Sales_Alert_Email__c = uemail, State_Coverage__c = '', Location__Latitude__s = 43.056839, Location__Longitude__s = -77.651748, Active__c = true));
        olList.add(new Office_Location__c(Name = 'Hopkinton, MA', Street__c = '15 Avenue E', City__c = 'Hopkinton', State__c = 'MA', Zip_Code__c = '01748', Director_of_Operations__c = uid, Sales_Coordinator__c = uid, Sales_Alert_Email__c = uemail, State_Coverage__c = 'MA', Location__Latitude__s = 42.199145, Location__Longitude__s = -71.542656, Active__c = true));
        olList.add(new Office_Location__c(Name = 'Long Island, NY', Street__c = '626 RexCorp Plaza', City__c = 'Uniondale', State__c = 'NY', Zip_Code__c = '11556', Director_of_Operations__c = uid, Sales_Coordinator__c = uid, Sales_Alert_Email__c = uemail, State_Coverage__c = '', Location__Latitude__s = 40.718761, Location__Longitude__s = -73.586640, Active__c = true));
        olList.add(new Office_Location__c(Name = 'Middletown, NY', Street__c = '28 Industrial Drive', City__c = 'Middletown', State__c = 'NY', Zip_Code__c = '10941', Director_of_Operations__c = uid, Sales_Coordinator__c = uid, Sales_Alert_Email__c = uemail, State_Coverage__c = 'CT', Location__Latitude__s = 41.470589, Location__Longitude__s = -74.372508, Active__c = true));
        olList.add(new Office_Location__c(Name = 'Norristown, PA', Street__c = '705 General Washington Avenue', City__c = 'Norristown', State__c = 'PA', Zip_Code__c = '19403', Director_of_Operations__c = uid, Sales_Coordinator__c = uid, Sales_Alert_Email__c = uemail, State_Coverage__c = '', Location__Latitude__s = 40.127031, Location__Longitude__s = -75.400675, Active__c = true));
        olList.add(new Office_Location__c(Name = 'Youngstown, OH', Street__c = '1104 N. Meridian Road', City__c = 'Youngstown', State__c = 'OH', Zip_Code__c = '44509', Director_of_Operations__c = uid, Sales_Coordinator__c = uid, Sales_Alert_Email__c = uemail, State_Coverage__c = 'OH', Location__Latitude__s = 41.126535, Location__Longitude__s = -80.711205, Active__c = true));
        insert olList;
    }

    public static Opportunity createTestOppForProperty(Property__c prop){
        //Product2
        Product2 product = new Product2();
        product.Name='testProduct223';
        product.ProductCode = 'system';
        insert product;
        ID pbookID= Test.getStandardPricebookId();
        
        //PriceBookEntry
        PriceBookEntry entry = new PricebookEntry();
        entry.UnitPrice = 2.32;
        entry.PriceBook2Id = pbookID;
        entry.UseStandardPrice=FALSE;
        entry.Product2ID=product.id;
        entry.IsActive  = true;
        insert entry;
        
        //Opportunity
        Opportunity oppt = new Opportunity();
        oppt.AccountId = prop.Property_Owner__c;
        oppt.name = 'Smith, John';
        oppt.CloseDate = Date.today();
        oppt.StageName = 'Qualified';
        oppt.Type = 'New Business';
        oppt.SREC__c = 'Yearly';
        oppt.State_Grant_Amount__c = double.valueOf('100.00');
        oppt.Property__c = prop.Id;
        oppt.Financing_Type__c = 'Purchase';
        oppt.Financing_Option__c = 'No Financing';
        oppt.LeadSource = 'Unknown';
        oppt.Lead_Source_Detail__c = 'Email';
        oppt.Leasing_Option__c = null;
        insert oppt;
        return oppt;        

    }

    public static void createMainofficeSetting(){
        Main_Office_Location_Settings__c offsetting = new Main_Office_Location_Settings__c();
        offsetting.Name__c = 'Columbia, MD';
        offsetting.City__c = 'Columbia';
        insert offsetting;
    }

    public static String getdefaultOffLocName(){
        if(Main_Office_Location_Settings__c.getOrgDefaults()!= null){
            return Main_Office_Location_Settings__c.getOrgDefaults().Name__c;
        }else{
            createMainofficeSetting();
            return Main_Office_Location_Settings__c.getOrgDefaults().Name__c;
        }
    }
    
}