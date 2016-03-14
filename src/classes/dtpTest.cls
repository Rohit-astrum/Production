@isTest (SeeAllData=true)
public class dtpTest{
    
static testMethod void testDtpTriggerNew(){
    Data_Tracking_Project__c dtp= new Data_Tracking_Project__c();

    Test.startTest();
    //dtp.Project_Status__c = 'Not Started';
    insert dtp;//Project Status = "Not Started";
    Data_Tracking_Project__c dtp2 = [SELECT Project_Status__c from Data_Tracking_Project__c WHERE Id = :dtp.Id limit 1];
    System.assertEquals('Not Started', dtp2.Project_Status__c);
    Test.stopTest();
}

static testMethod void testDtpTriggerUpdate(){

Data_Tracking_Project__c dtp= new Data_Tracking_Project__c();

//dtp.Project_Status__c = 'Not Started';

Utility_Company__c uc = new Utility_Company__c();
        uc.Name = 'BG&E';
        uc.States_Serviced__c = 'MD';
        uc.Weekend_Schedule__c = '111111111111111111111111222111111111111111111111111111111133111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';
        uc.Weekday_Schedule__c  = '111111111111111111111111111111111111111111111111221111111111111111111111111111133333311111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';
        Database.Saveresult ucDBResult = Database.Insert(uc,false);
        Id ucId = ucDBResult.getId();
        if(ucId == null){
          System.debug('ucDBResult Insert Errors --> ' + ucDBResult.getErrors());
        }
        System.debug('Added Utility Company with Id --> ' + ucId);

        List<Rate_Period__c> rps = new List<Rate_Period__c>();
        Rate_period__c rp = new Rate_period__c();
        rp.Period_Type__c = 'Peak';
        rp.Name = 'Period 1';
        rp.Utility_Company__c = ucId;
        rp.Rate_Period__c = 1;
        rps.add(rp);

        Rate_period__c rp1 = new Rate_period__c();
        rp1.Period_Type__c = 'Part_Peak';
        rp1.Name = 'Period 2';
        rp1.Utility_Company__c = ucId;
        rp1.Rate_Period__c = 2;
         rps.add(rp1);

        Rate_period__c rp2 = new Rate_period__c();
        rp2.Period_Type__c = 'Off_Peak';
        rp2.Name = 'Period 3';
        rp2.Utility_Company__c = ucId;
        rp2.Rate_Period__c = 3;
        rps.add(rp2);

        insert rps;

Account acct = new Account();
acct.name = 'Smith, John';
insert acct;
dtp.Account__c = acct.id;

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
propt.Astrum_Office__c = testdata.defaultOffLocationName;// FPO Phase4 //'Annapolis Junction, MD';
propt.Hours_From_Nearest_Office__c = 1.0;
  propt.Utility_Company__c =  ucId; 
insert propt;
dtp.Property__c = propt.id;

//MK 2014-05-02 - Moved survey creation first so we can connect install locations to it
Survey__c surv = new Survey__c();
surv.Property__c = propt.id;
surv.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'Survey__c' and r.Name = 'Field Survey'].id;        
insert surv;

//MK 2014-05-02
//Insert Physical Surface & link survey
Physical_Surface__c ps = new Physical_Surface__c();
ps.Property__c = propt.Id; //New link to property
ps.Physical_Surface_Assigned_Letter__c = 'A'; //MK 2014-05-02
ps.Surface_Tilt__c = 10;
ps.Surface_Azimuth__c = 90;
ps.Trenching_Dist_to_Intercon_Pt_ft__c = 10;
ps.Suneye_Tilt_and_Orien_Factor__c = 2;        
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
sda.Physical_Surface__c = ps.id;//MK 2014-05-02
sda.Survey__c = surv.id;//MK 2014-05-02
sda.Mounting_Type__c = ps.Default_Mounting_Type__c;//MK 2014-05-02
sda.CB_Panel__c = mainPanel.id;
sda.System_Design__c = sd.id;
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
//sdq.Closed_Scenario__c = '1';   //DK: 05/06/15. Added so that SalesOrderTriggerHandler.updateCommissionsFields() won't find a null.
insert sdq;
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

//(l.System_Design_Q__c!=null)&&(l.Account__c!=null)&&(l.Opportunity__c!=null)&&(l.Property__c!=null)&&(l.Sales_Order__c!=null)&&(l.Project__c!=null)&&(l.Installed_System__c!=null)
Test.startTest();

insert dtp;//Project Status = "Completed"
Data_Tracking_Project__c dtp2 = [SELECT Project_Status__c from Data_Tracking_Project__c limit 1];
//System.assertEquals('Completed',dtp2.Project_Status__c);
System.debug('Completed -> '+dtp2.Project_Status__c);

dtp.Sales_Check__c = false;
update dtp;//Project Status = "Ready for Check"

dtp2 = [SELECT Project_Status__c from Data_Tracking_Project__c limit 1];
//System.assertEquals('Ready for Check',dtp2.Project_Status__c);
System.debug('Ready for Check -> '+dtp2.Project_Status__c);

dtp.Account_ID__c = 'Missing';
update dtp;//Project Status = "Needs Review"

dtp2 = [SELECT Project_Status__c from Data_Tracking_Project__c limit 1];
//System.assertEquals('Missing',dtp2.Project_Status__c);
System.debug('Missing -> '+dtp2.Project_Status__c);

dtp.Account_ID__c= '';
update dtp;//Project Status = "In Progress"

dtp2 = [SELECT Project_Status__c from Data_Tracking_Project__c limit 1];
//System.assertEquals('In Progress',dtp2.Project_Status__c);
System.debug('In Progress -> '+dtp2.Project_Status__c);

Test.stopTest();
}
}