/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 * MODIFICATION HISTORY: 
 * 07/16/2015 PB FPO Phase2- Set active field on Office Location
 */
@isTest
private class AstrumTriggerTests {

    static testMethod void AstrumSalesDataModelTests() {
        //[Select u.SystemModstamp, u.States_Serviced__c, u.Rate__c, u.OwnerId, u.Name, u.LastModifiedDate, u.LastModifiedById, u.IsDeleted, u.Id, u.CreatedDate, u.CreatedById, u.ConnectionSentId, u.ConnectionReceivedId From Utility_Company__c u where u.Name = 'BG&E'];
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
        acct.Name = 'test account';
        Database.Saveresult acctDBResult = Database.Insert(acct,false);
        Id acctId = acctDBResult.getId();
        if(acctId == null){
            System.debug('acctDBResult Insert Errors --> ' + acctDBResult.getErrors());
        }
        System.debug('Added Account with Id --> ' + acctId);
        
        Office_Location__c off = new Office_Location__c();
        off.Name = 'Annapolis Junction, MD';
        off.City__c = 'Annapolis Junction';
        off.State__c = 'MD';
        off.Street__c = '123 Test';
        off.Zip_Code__c = '20701';
        off.Active__c = true;
        insert off;
        
        Property__c prop = new Property__c();
        prop.Name = '123 Test St';
        prop.Property_Owner__c = acctId;
        prop.Optimal_Site_Quality_kWh_y_kW__c = double.valueOf('1250');
        prop.Property_State__c = 'MD';
        prop.Property_City__c = 'Annapolis Junction';
        prop.Property_ZIP__c = '20701';
        prop.Permit_Jurisdiction__c = 'Howard';
        prop.Property_County__c = 'Howard';
        prop.Astrum_Office__c = 'Annapolis Junction, MD';
        prop.Hours_From_Nearest_Office__c = 1.0;
        prop.Utility_Company__c =  ucId; 
        Database.Saveresult propDBResult = Database.Insert(prop,false);
        Id propId = propDBResult.getId();
        if(propId == null){
            System.debug('propDBResult Insert Errors --> ' + propDBResult.getErrors());
        }        
        
        System.debug('Added Property with Id --> ' + propId);
        
        Survey__c surv = new Survey__c();
        surv.Property__c = propId;
        surv.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'Survey__c' and r.Name = 'Field Survey'].id;
        
        insert surv;
        
        Utility_Service__c utilService = new Utility_Service__c();
        utilService.Amperage__c = double.valueOf('200');
        utilService.Utility_Company__c = ucId;
        utilService.Property__c = propId;
        utilService.Service_Account_Number__c = 'abc123';
        Database.Saveresult utilServiceDBResult = Database.Insert(utilService,false);
        Id utilServiceId = utilServiceDBResult.getId();
        if(utilServiceId == null){
            System.debug('utilServiceDBResult Insert Errors --> ' + utilServiceDBResult.getErrors());
        }        
        System.debug('Added Utility_Service__c with Id --> ' + utilServiceId);

        CB_Panel__c mainPanel = new CB_Panel__c();
        mainPanel.Utility_Service__c = utilServiceId;
        mainPanel.Main_Breaker_Rating_Amps__c =Double.valueOf('200');
        
        Database.Saveresult mainPanelDBResult = Database.Insert(mainPanel,false);
        Id mainPanelId = mainPanelDBResult.getId();
        if(mainPanelId == null){
            System.debug('mainPanelDBResult Insert Errors --> ' + mainPanelDBResult.getErrors());
        }        
        System.debug('Added CB_Panel__c with Id --> ' + mainPanelId);
        
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
        Database.Saveresult instLocDBResult = Database.Insert(instLoc,false);
        Id instLocId = instLocDBResult.getId();
        if(instLocId == null){
          System.debug('instLocDBResult Insert Errors --> ' + instLocDBResult.getErrors());
        }
        System.debug('Added Install Location with Id --> ' + instLocId);
        
        
        System_Design__c sd = new System_Design__c();
        sd.Property__c = propId;
        Database.Saveresult sdDBResult = Database.Insert(sd,false);
        Id sdId = sdDBResult.getId();
        if(sdId == null){
            System.debug('sdDBResult Insert Errors --> ' + sdDBResult.getErrors());
        }
        System.debug('Added System_Design__c with Id --> ' + sdId);
        
        
        System_Design_Array__c sda = new System_Design_Array__c();
        sda.CB_Panel__c = mainPanelId;
        sda.System_Design__c = sdId;
        sda.Physical_Surface__c = ps.id;//MK 2014-05-02
        sda.Survey__c = surv.id;//MK 2014-05-02
        sda.Mounting_Type__c = ps.Default_Mounting_Type__c;//MK 2014-05-02

        Database.Saveresult sdaDBResult = Database.Insert(sda,false);
        Id sdaId = sdaDBResult.getId();
        if(sdaId == null){
            System.debug('sdaDBResult Insert Errors --> ' + sdaDBResult.getErrors());
        }
        System.debug('Added System_Design_Array__c with Id --> ' + sdaId);

        System_Design_Product__c sdp = new System_Design_Product__c();
        sdp.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Product__c' and r.Name = 'Panel'].id;
        sdp.Description__c  = 'Sanyo 215';
        sdp.End_Clamp_Type__c = 'F End Clamp';  
        sdp.Make__c = 'Sanyo';
        sdp.Max_Voltage__c = double.valueOf('600');
        sdp.Mid_Clamp_Type__c = 'F Mid Clamp';  
        sdp.Model__c = 'HIT Power 215N';
        sdp.Rated_Output_W__c = double.valueOf('215');  
        sdp.Unit__c = 'Count';

        Database.Saveresult sdpDBResult = Database.Insert(sdp,false);
        Id sdpId = sdpDBResult.getId();
        if(sdpId == null){
            System.debug('sdpDBResult Insert Errors --> ' + sdpDBResult.getErrors());
        }
        System.debug('Added System_Design_Product__c with Id --> ' + sdpId);
        
        
        
         System_Design_Item__c sdi = new System_Design_Item__c();
        sdi.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'System_Design_Item__c' and r.Name = 'Panel'].id;
        sdi.System_Design_Array__c = sdaId;
        sdi.Install_Location__c = instLocId;
        sdi.System_Design_Product__c = sdp.Id;
        sdi.Quantity__c = double.valueOf('29');
        sdi.Annual_Solar_Access__c = double.valueOf('100');
        sdi.NRG_Site_Quality__c= double.valueOf('90');
        sdi.Rated_Output_kW__c = 12;
        sdi.Tilt__c = double.valueOf('3');
        sdi.Azimuth__c = double.valueOf('3');
        sdi.Astrum_PV_Watts_Site_Quality__c = double.valueOf('1200');
        
        
        
        
        Database.Saveresult sdiDBResult = Database.Insert(sdi,false);
        Id sdiId = sdiDBResult.getId();
        if(sdiId == null){
            System.debug('sdiDBResult Insert Errors --> ' + sdiDBResult.getErrors());
        }
        System.debug('Added System_Design_Item__c with Id --> ' + sdiId);
                
        
        sd.Calculated_System_Price__c = decimal.valueOf('100000.25');
        update(sd);
        
        
        //Test Install Location Trigger: Update_SDI_onLocation_Change
        // Making the change to the Install Location should update the related SDIs by re-running their triggers.
        instLoc.TSRF__c = double.valueOf('94');
        update(instLoc);
        
        
        
        System_Design_Quote__c sdq = new System_Design_Quote__c();
        sdq.System_Design__c = sdId;
        
        system.debug('SDA --> ' + [Select s.System_Design__c, s.SystemModstamp, s.Special_Parts_Required__c, s.Projected_Annual_Output_kWh_y__c, s.Panel_Count__c, s.Name, s.Mounting_Type__c, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Id, s.Electrical_Adder__c, s.CreatedDate, s.CreatedById, s.ConnectionSentId, s.ConnectionReceivedId, s.CB_Panel__c, s.Array_Size_kW__c From System_Design_Array__c s where s.Id = :sdaId]);
        system.debug('SD --> ' + [Select s.Total_System_Size_kW__c, s.Total_Projected_Annual_Output_kWh_y__c, s.SystemModstamp, s.Survey__c, s.Property__c, s.Panel_Count__c, s.Overall_TSRF__c, s.Overall_Site_Quality__c, s.Notes__c, s.Name, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Id, s.CreatedDate, s.CreatedById, s.ConnectionSentId, s.ConnectionReceivedId, s.Calculated_System_Price__c, s.Calculated_Price_per_Watt__c, s.Account_Number__c From System_Design__c s where s.Id = :sdId]);
        Database.Saveresult sdqDBResult = Database.Insert(sdq,false);
        Id sdqId = sdqDBResult.getId();
        if(sdqId == null){
            System.debug('sdqDBResult Insert Errors --> ' + sdqDBResult.getErrors());
        }
        System.debug('Added System_Design_Quote__c with Id --> ' + sdqId);
   


        
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Pete';
        opp.AccountId = acctId;
        opp.StageName = 'On Hold';
        opp.CloseDate = Date.today() + 20;
        opp.SREC__c = 'Yearly';
        opp.State_Grant_Amount__c = double.valueOf('100.00');
        opp.System_Design_Quote__c = sdqId;
        opp.Property__c = propId;
        opp.Financing_Type__c = 'Purchase';
        opp.Financing_Option__c = 'No Financing';
        opp.Leasing_Option__c = null;
        opp.On_Hold_Until__c = Date.today().addDays(14);  
        opp.LeadSource = 'Unknown'; 
        opp.Lead_Source_Detail__c = 'Email';            
       
        Database.Saveresult oppDBResult = Database.Insert(opp,false);
        Id oppId = oppDBResult.getId();
        if(oppId == null){
            System.debug('oppDBResult Insert Errors --> ' + oppDBResult.getErrors());
        }
        System.debug('Added Opportunity with Id --> ' + oppId);

        Contact c = new Contact();
        c.FirstName = 'Pete';
        c.LastName = 'Varga';
        c.AccountId = acctId;
        Database.Saveresult contactDBResult = Database.Insert(c,false);
        Id cId = contactDBResult.getId();
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = cId;
        ocr.IsPrimary = true;
        ocr.Role = 'Decision Maker';
        ocr.OpportunityId = oppId;
        
        Database.Saveresult ocrDBResult = Database.Insert(ocr,false);
        Id ocrId = ocrDBResult.getId();
       
        //Add Price Adjustment to SDQ to trigger opp Update. 
        Price_Adjustment__c pa = new Price_Adjustment__c();
        pa.RecordTypeId = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.sObjectType = 'Price_Adjustment__c' and r.Name = 'Dollar Amount'].id;
        pa.Amount__c = decimal.valueof('-5000');
        pa.Type__c = 'Standard';        
        pa.System_Design_Quote__c = sdq.id;
        
        Database.Saveresult paDBResult = Database.Insert(pa,false);
        Id paId = paDBResult.getId();
        if(paId == null){
            System.debug('paDBResult Insert Errors --> ' + paDBResult.getErrors());
        }
        System.debug('Added Price Adjustment with Id --> ' + paId);
        
 
        
        
        
        opp.StageName = 'Closed - Won';
        opp.Type = 'New Business';
        update(opp);                
        
        SCRB_SalesOrder__c so = new SCRB_SalesOrder__c();
        so.OpportunityId__c = oppId;
        so.Property__c = propId;

        Database.Saveresult soDBResult = Database.Insert(so,false);
        Id soId = soDBResult.getId();
        if(soId == null){
            System.debug('soDBResult Insert Errors --> ' + soDBResult.getErrors());
        }
        System.debug('Added Sales Order with Id --> ' + soId);
        
        //so.StatusCode__c = 'Sales Coordinator Approved';
        //System.debug('About to update Sales Order --> ' + so);
        //update(so);

        // Change Calculated System Price on SD to trigger Opp Update.
        
        sd.Calculated_System_Price__c = sd.Calculated_System_Price__c + decimal.valueOf('5000');
        update(sd);
        
        Test.startTest();   //DK 05/07/15
        SalesOrderController.syncToOpp(soId, oppId);
        Test.stopTest();

    }
 /*   
    static testMethod void AstrumSalesDataModelTests() {
        Time_Sheet__c ts = new Time_Sheet__c();
        
        Time_Sheet_Entry__c tse = new Time_Sheet_Entry__c();
        tse.Start_Time__c = Datetime.now() + 5;
        tse.Start_Time_On_Site__c = Datetime.now() + 5;
        tse.End_Time__c = Datetime.now() + 6;
        tse.Start_Time_Off_Site__c = Datetime.now() + 6;
        insert tse;
    }
  */  
}