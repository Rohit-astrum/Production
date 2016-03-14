/*
* MODIFICATION HISTORY: 
* 07/20/2015 PB FPO Phase2- Create test data and remove dependency on existing org data
*/
@isTest//(SeeAllData=true)
public class LeadConvertPropertyTriggerTest {
    
     // Address in MA
     static testMethod void lead_with_Office_MA_Locations() {
    
        Lead l = new Lead (
            LeadSource = 'Events',
            //Lead_Source_Detail_1__c = 'xyz',
            FirstName = 'Test1',
            LastName = 'Lead1',
            Company = 'Lead1, Test1', 
            Site_Type__c = 'Residential',         
            Street  = '135 E Main Street',
            City = 'Westborough',
            QAS_County__c = 'Worcester',
            State = 'MA',
            PostalCode = '01581',
            QAS_Latitude__c = '42.283932',
            QAS_Longitude__c = '-71.597206'           
        );
        
        insert l;
        
        //Test.startTest();
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(l.Id);
        lc.setConvertedStatus('Qualified');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        //Test.stopTest();
        
        System.assert(lcr.isSuccess());
      
        Property__c p = 
            [SELECT Id, Astrum_Office__c,Astrum_Office_New__r.Name 
            FROM Property__c
            WHERE Property_Owner__c = :lcr.getAccountId()];   
            
        //property.Astrum_Office__c = Astrum_Distance_Calculation.assignOffice(officeMap,officeLocations,l);        
      
        System.assertEquals(p.Astrum_Office_New__r.Name , 'Hopkinton, MA');
            
    }
    
     // Address in DE Close to MD Office
    static testMethod void lead_with_Office_DE_Locations() {
    
        Lead l = new Lead (
            LeadSource = 'Events',
            //Lead_Source_Detail_1__c = 'xyz',
            FirstName = 'Test1',
            LastName = 'Lead1', 
            Site_Type__c = 'Residential', 
            Company = 'Lead1, Test1',            
            Street  = '100 E 4th St',
            City = 'Laurel',
            QAS_County__c = 'Sussex',
            State = 'DE',
            PostalCode = '19956',
            QAS_Latitude__c = '38.556084',
            QAS_Longitude__c = '-75.570971'           
        );
        
        insert l;
        
        Test.startTest();
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(l.Id);
        lc.setConvertedStatus('Qualified');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        Test.stopTest();
        
        System.assert(lcr.isSuccess());
        
        Property__c p = 
            [SELECT Id, Astrum_Office__c,Astrum_Office_New__r.Name 
            FROM Property__c
            WHERE Property_Owner__c = :lcr.getAccountId()];      
        
        System.assertEquals(p.Astrum_Office_New__r.Name , 'Annapolis Junction, MD');
            
    }
    
     // Address in WV Close to OH Office
    static testMethod void lead_with_Office_WV_Locations() {
    
        Lead l = new Lead (
            LeadSource = 'Events',
            //Lead_Source_Detail_1__c = 'xyz',
            FirstName = 'Test1',
            LastName = 'Lead1',
            Company = 'Lead1, Test1', 
            Site_Type__c = 'Residential',           
            Street  = '1300 Eoff St',
            City = 'Wheeling',
            QAS_County__c = 'Ohio',
            State = 'WV',
            PostalCode = '26003',
            QAS_Latitude__c = '40.066591',
            QAS_Longitude__c = '-80.719947'           
        );
        
        insert l;
        
        Test.startTest();
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(l.Id);
        lc.setConvertedStatus('Qualified');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        Test.stopTest();
        
        System.assert(lcr.isSuccess());
        
        Property__c p = 
            [SELECT Id, Astrum_Office__c ,Astrum_Office_New__r.Name
            FROM Property__c
            WHERE Property_Owner__c = :lcr.getAccountId()];      
        
        System.assertEquals(p.Astrum_Office_New__r.Name ,  'Youngstown, OH');
            
    }
    
    
    // Address Close to MD Office but in PA State - Assigned to PA Office.
    static testMethod void lead_with_Office_PA_Locations() {
    
        Lead l = new Lead (
            LeadSource = 'Events',
            //Lead_Source_Detail_1__c = 'xyz',
            FirstName = 'Test',
            LastName = 'Lead', 
            Site_Type__c = 'Residential', 
            Company = 'Lead, Test',            
            Street  = '305 W Baltimore St',
            City = 'Greencastle',
            QAS_County__c = 'Franklin',
            State = 'PA',
            PostalCode = '17225',
            QAS_Latitude__c = '39.791236',
            QAS_Longitude__c = '-77.731471'           
        );
        
        insert l;
        
        Test.startTest();
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(l.Id);
        lc.setConvertedStatus('Qualified');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        Test.stopTest();
        
        System.assert(lcr.isSuccess());
        
        Property__c p = 
            [SELECT Id, Astrum_Office__c,Astrum_Office_New__r.Name 
            FROM Property__c
            WHERE Property_Owner__c = :lcr.getAccountId()];      
        
        System.assertEquals(p.Astrum_Office_New__r.Name , 'Pennsauken, NJ');   //Norristown, PA
            
    }
    
    // Address in NJ - Close to MIddletown Office Assigned to Middletown Office.
    static testMethod void lead_with_Office_NJ_Locations() {
    
        Lead l = new Lead (
            LeadSource = 'Events',
            //Lead_Source_Detail_1__c = 'xyz',
            FirstName = 'Test',
            LastName = 'Lead',
            Site_Type__c = 'Residential', 
            Company = 'Lead, Test',            
            Street  = '47 Kossuth St',
            City = 'Wharton',
            QAS_County__c = 'Morris',
            State = 'NJ',
            PostalCode = '07885',
            QAS_Latitude__c = '40.900366',
            QAS_Longitude__c = '-74.580686'           
        );
        
        insert l;
        
        Test.startTest();
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(l.Id);
        lc.setConvertedStatus('Qualified');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        Test.stopTest();
        
        System.assert(lcr.isSuccess());
        
        Property__c p = 
            [SELECT Id, Astrum_Office__c ,Astrum_Office_New__r.Name
            FROM Property__c
            WHERE Property_Owner__c = :lcr.getAccountId()];      
        
        System.assertEquals(p.Astrum_Office_New__r.Name , 'Pennsauken, NJ');     //Middletown, NY
            
    }
    // Address in Suffold County NY assigned to LI Office
    static testMethod void lead_with_Office_NY_LI_Locations() {
    
        Lead l = new Lead (
            LeadSource = 'Events',
            //Lead_Source_Detail_1__c = 'xyz',
            FirstName = 'Test1',
            LastName = 'Lead1', 
            Site_Type__c = 'Residential', 
            Company = 'Lead1, Test1',            
            Street  = '143 Old Country Rd',
            City = 'Melville',
            QAS_County__c = 'Suffolk',
            State = 'NY',
            PostalCode = '11747',
            QAS_Latitude__c = '40.793125',
            QAS_Longitude__c = '-73.418229'           
        );
        
        insert l;
        
        Test.startTest();
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(l.Id);
        lc.setConvertedStatus('Qualified');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        Test.stopTest();
        
        System.assert(lcr.isSuccess());
        
        Property__c p = 
            [SELECT Id, Astrum_Office__c,Astrum_Office_New__r.Name 
            FROM Property__c
            WHERE Property_Owner__c = :lcr.getAccountId()];      
        
        System.assertEquals(p.Astrum_Office_New__r.Name , 'Long Island, NY');
            
    }
     // Address in NY  Close to MIddletown Office
     static testMethod void lead_with_Office_NY_NonLI_Locations() {

        Lead l = new Lead (
            LeadSource = 'Events',
            //Lead_Source_Detail_1__c = 'xyz',
            FirstName = 'Test1',
            LastName = 'Lead1', 
            Site_Type__c = 'Residential', 
            Company = 'Lead1, Test1',            
            Street  = '46 Parkview Dr',
            City = 'Harpursville',
            QAS_County__c = 'Broome',
            State = 'NY',
            PostalCode = '13787',
            QAS_Latitude__c = '42.141463',
            QAS_Longitude__c = '-75.693252'           
        );
        
        insert l;
        
        Test.startTest();
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(l.Id);
        lc.setConvertedStatus('Qualified');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        Test.stopTest();
        
        System.assert(lcr.isSuccess());
        
        Property__c p = 
            [SELECT Id, Astrum_Office__c,Astrum_Office_New__r.Name 
            FROM Property__c
            WHERE Property_Owner__c = :lcr.getAccountId()];      
        
        System.assertEquals(p.Astrum_Office_New__r.Name , 'Middletown, NY');
            
    }
    // Address in PA Close to OH Office
    static testMethod void lead_with_Office_OH_Locations() {
    
        Lead l = new Lead (
            LeadSource = 'Events',
            //Lead_Source_Detail_1__c = 'xyz',
            FirstName = 'Test1',
            LastName = 'Lead1', 
            Site_Type__c = 'Residential', 
            Company = 'Lead1, Test1',            
            Street  = '826 Graham Blvd',
            City = 'Pittsburgh',
            QAS_County__c = 'Allegheny',
            State = 'PA',
            PostalCode = '15221',
            QAS_Latitude__c = '40.443134',
            QAS_Longitude__c = '-79.857562'           
        );
        
        insert l;
        
        Test.startTest();
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(l.Id);
        lc.setConvertedStatus('Qualified');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        Test.stopTest();
        
        System.assert(lcr.isSuccess());
        
        Property__c p = 
            [SELECT Id, Astrum_Office__c,Astrum_Office_New__r.Name 
            FROM Property__c
            WHERE Property_Owner__c = :lcr.getAccountId()];      
        
        System.assertEquals(p.Astrum_Office_New__r.Name , 'Pennsauken, NJ');   //Youngstown, OH
            
    }
     // Address in MD
     static testMethod void lead_with_Office_MD_Locations() {
    
        Lead l = new Lead (
            LeadSource = 'Events',
            //Lead_Source_Detail_1__c = 'xyz',
            FirstName = 'Test1',
            LastName = 'Lead1', 
            Site_Type__c = 'Residential', 
            Company = 'Lead1, Test1',            
            Street  = '1 Collingwood Rd',
            City = 'Phoenix',
            QAS_County__c = 'Baltimore',
            State = 'MD',
            PostalCode = '21131',
            QAS_Latitude__c = '39.472154',
            QAS_Longitude__c = '-76.534904'           
        );
        
        insert l;
        
        Test.startTest();
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(l.Id);
        lc.setConvertedStatus('Qualified');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        Test.stopTest();
        
        System.assert(lcr.isSuccess());
        
        Property__c p = 
            [SELECT Id, Astrum_Office__c,Astrum_Office_New__r.Name 
            FROM Property__c
            WHERE Property_Owner__c = :lcr.getAccountId()];      
        
        System.assertEquals(p.Astrum_Office_New__r.Name , 'Annapolis Junction, MD');
            
    }
    
     
    
      // Address in CT
     static testMethod void lead_with_Office_CT_Locations() {
    
        Lead l = new Lead (
            LeadSource = 'Events',
            //Lead_Source_Detail_1__c = 'xyz',
            FirstName = 'Test1',
            LastName = 'Lead1',
            Site_Type__c = 'Residential', 
            Company = 'Lead1, Test1', 
            Street  = '597 Naugatuck Ave',
            City = 'Milford',
            QAS_County__c = 'New Haven',
            State = 'CT',
            PostalCode = '06461',
            QAS_Latitude__c = '41.198521',
            QAS_Longitude__c = '-73.123269'           
        );
        
        insert l;
        
        Test.startTest();
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(l.Id);
        lc.setConvertedStatus('Qualified');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        Test.stopTest();
        
        System.assert(lcr.isSuccess());
        
        Property__c p = 
            [SELECT Id, Astrum_Office__c,Astrum_Office_New__r.Name 
            FROM Property__c
            WHERE Property_Owner__c = :lcr.getAccountId()];      
        
        System.assertEquals(p.Astrum_Office_New__r.Name , 'Middletown, NY');
            
    }
    
    // Address without corrdinates in PA
     static testMethod void lead_with_Office_Other_Locations() {
    
        Lead l = new Lead (
            LeadSource = 'Events',
            //Lead_Source_Detail_1__c = 'xyz',
            FirstName = 'Test1',
            LastName = 'Lead1', 
            Site_Type__c = 'Residential',
            Company = 'Lead1, Test1',            
            Street  = 'Test Ave',
            City = 'Wayne',
            QAS_County__c = 'Chester',
            State = 'PA',
            PostalCode = '19087'                  
        );
        
        insert l;
        
        Test.startTest();
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(l.Id);
        lc.setConvertedStatus('Qualified');
        
        Database.LeadConvertResult lcr;
        try{
            //Will cause a dmlexception because coordiantes are not provided
            lcr = Database.convertLead(lc);
        }catch(DmlException de){}
        
        Test.stopTest();
        
        //System.assertEquals(null,lcr);
        
        
        Property__c p = 
            [SELECT Id, Astrum_Office__c,Astrum_Office_New__r.Name 
            FROM Property__c
            WHERE Property_Owner__c = :lcr.getAccountId()];      
        
        System.assertEquals(p.Astrum_Office_New__r.Name , testdata.defaultOffLocationName);// FPO Phase4 //'Annapolis Junction, MD');   //Norristown, PA
        
            
    }
    
    static testMethod void assignToPropTest() {
        
        Account account = new Account(Name='QAS Test Account',                                    
                  ShippingStreet = 'Hamilton Ave',
                  ShippingCountry = 'US',
                  ShippingState = 'NY',
                  ShippingPostalCode = '10606',
                  ShippingCity = 'White Plains');
        insert account;        
        
        Property__c property = new Property__c(
                                    Name = '1 Snowden Ave',
                                    Property_City__c='Delmar',
                                    Property_ZIP__c='12054',
                                    Property_Owner__c=account.Id,
                                    Property_County__c='Albany',
                                    Property_State__c='NY',
                                    QAS_Latitude__c = '42.628040',
                                    QAS_Longitude__c = '-73.815376',
                                    Astrum_Office__c='Norristown, PA');
        insert property;        
        
       
        Property_Batch_Update ipBatch = new Property_Batch_Update();  
        ipBatch.query =   'Select Name,Astrum_Office__c,QAS_Property_County__c,QAS_Latitude__c,QAS_Longitude__c, Property_State__c,Property_County__C  from Property__c Where Id = \''+ property.Id+ '\'';
        ipBatch.batch = 'Office';
        Test.startTest();
        database.executeBatch(ipBatch,200); 
        Test.stopTest();
        
        Property__c p = 
            [SELECT Id, Astrum_Office__c,Astrum_Office_New__r.Name 
            FROM Property__c
            WHERE Id = :property.Id];      
        
        System.assertEquals(p.Astrum_Office_New__r.Name , 'Middletown, NY');
            
    }
    
    static testMethod void assignSalesRegion() {
        
        Account account = new Account(Name='QAS Test Account',                                    
                  ShippingStreet = 'Hamilton Ave',
                  ShippingCountry = 'US',
                  ShippingState = 'NY',
                  ShippingPostalCode = '10606',
                  ShippingCity = 'White Plains');
        insert account;        
        
        Property__c property = new Property__c(
                                    Name = '1 Snowden Ave',
                                    Property_City__c='Delmar',
                                    Property_ZIP__c='12054',
                                    Property_Owner__c=account.Id,
                                    Property_County__c='Albany',
                                    Property_State__c='NY',
                                    QAS_Latitude__c = '42.628040',
                                    QAS_Longitude__c = '-73.815376',
                                    Astrum_Office__c='Norristown, PA',
                                    Sales_Region__c = 'NYC Region');
        insert property;        
        property.Astrum_Sales_Region__c = null;
        update property;
       
        Property_Batch_Update ipBatch = new Property_Batch_Update();  
        ipBatch.query =   'Select Name,Astrum_Office__c,QAS_Property_County__c,QAS_Latitude__c,QAS_Longitude__c, Property_State__c,Property_County__C,Astrum_Sales_Region__c,Sales_Region__c  from Property__c Where Id = \''+ property.Id+ '\'';
        ipBatch.batch = 'SalesRegion';
        Test.startTest();
        database.executeBatch(ipBatch,200); 
        Test.stopTest();
        
        Property__c p = 
            [SELECT Id, Astrum_Sales_Region__r.Name 
            FROM Property__c
            WHERE Id = :property.Id];      
        
        System.assertEquals(p.Astrum_Sales_Region__r.Name , 'NYC Region');
            
    }
    

    @testSetup static void setupConfigData(){
        
        system.debug('setup Office_Location__c');
        id uid = UserInfo.getUserId();
        string uemail = UserInfo.getUserEmail();

        Main_Office_Location_Settings__c offsetting = new Main_Office_Location_Settings__c();
        offsetting.Name__c = 'Columbia, MD';
        insert offsetting;

        list<Office_Location__c> olList = new list<Office_Location__c>();
        olList.add(new Office_Location__c(Name = 'Columbia, MD', Street__c = '7101 Riverwood Drive', City__c = 'Columbia', State__c = 'MD', Zip_Code__c = '21046', Director_of_Operations__c = uid, Sales_Coordinator__c = uid, Sales_Alert_Email__c = uemail, State_Coverage__c = 'MD; DC; VA', Location__Latitude__s = 39.125951, Location__Longitude__s = -76.794940, Active__c = true));        
        olList.add(new Office_Location__c(Name = 'Annapolis Junction, MD', Street__c = '8955 Henkels Lane', City__c = 'Annapolis Junction', State__c = 'MD', Zip_Code__c = '20701', Director_of_Operations__c = uid, Sales_Coordinator__c = uid, Sales_Alert_Email__c = uemail, State_Coverage__c = 'MD; DC; VA', Location__Latitude__s = 39.125951, Location__Longitude__s = -76.794940, Active__c = true));
        olList.add(new Office_Location__c(Name = 'Corona, CA', Street__c = '505 E Rincon St#100', City__c = 'Corona', State__c = 'CA', Zip_Code__c = '92879', Director_of_Operations__c = uid, Sales_Coordinator__c = uid, Sales_Alert_Email__c = uemail, State_Coverage__c = 'CA', Location__Latitude__s = 33.886215, Location__Longitude__s = -117.560626, Active__c = true));
        olList.add(new Office_Location__c(Name = 'Henrietta, NY', Street__c = '395 Summit Point Drive', City__c = 'Henrietta', State__c = 'NY', Zip_Code__c = '14467', Director_of_Operations__c = uid, Sales_Coordinator__c = uid, Sales_Alert_Email__c = uemail, State_Coverage__c = '', Location__Latitude__s = 43.056839, Location__Longitude__s = -77.651748, Active__c = true));
        olList.add(new Office_Location__c(Name = 'Hopkinton, MA', Street__c = '15 Avenue E', City__c = 'Hopkinton', State__c = 'MA', Zip_Code__c = '01748', Director_of_Operations__c = uid, Sales_Coordinator__c = uid, Sales_Alert_Email__c = uemail, State_Coverage__c = 'MA', Location__Latitude__s = 42.199145, Location__Longitude__s = -71.542656, Active__c = true));
        olList.add(new Office_Location__c(Name = 'Long Island, NY', Street__c = '626 RexCorp Plaza', City__c = 'Uniondale', State__c = 'NY', Zip_Code__c = '11556', Director_of_Operations__c = uid, Sales_Coordinator__c = uid, Sales_Alert_Email__c = uemail, State_Coverage__c = '', Location__Latitude__s = 40.718761, Location__Longitude__s = -73.586640, Active__c = true));
        olList.add(new Office_Location__c(Name = 'Middletown, NY', Street__c = '28 Industrial Drive', City__c = 'Middletown', State__c = 'NY', Zip_Code__c = '10941', Director_of_Operations__c = uid, Sales_Coordinator__c = uid, Sales_Alert_Email__c = uemail, State_Coverage__c = 'CT', Location__Latitude__s = 41.470589, Location__Longitude__s = -74.372508, Active__c = true));
        olList.add(new Office_Location__c(Name = 'Norristown, PA', Street__c = '705 General Washington Avenue', City__c = 'Norristown', State__c = 'PA', Zip_Code__c = '19403', Director_of_Operations__c = uid, Sales_Coordinator__c = uid, Sales_Alert_Email__c = uemail, State_Coverage__c = '', Location__Latitude__s = 40.127031, Location__Longitude__s = -75.400675, Active__c = true));
        olList.add(new Office_Location__c(Name = 'Youngstown, OH', Street__c = '1104 N. Meridian Road', City__c = 'Youngstown', State__c = 'OH', Zip_Code__c = '44509', Director_of_Operations__c = uid, Sales_Coordinator__c = uid, Sales_Alert_Email__c = uemail, State_Coverage__c = 'OH', Location__Latitude__s = 41.126535, Location__Longitude__s = -80.711205, Active__c = true));
        olList.add(new Office_Location__c(Name = 'Pennsauken, NJ', Street__c = '35 Twinbridge Dr', City__c = 'Pennsauken', State__c = 'NJ', Zip_Code__c = '08110', Director_of_Operations__c = uid, Sales_Coordinator__c = uid, Sales_Alert_Email__c = uemail, State_Coverage__c = 'NJ; PA', Location__Latitude__s = 39.983623, Location__Longitude__s = -75.023549, Active__c = true));
        
        insert olList;

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

        State__c NYState = new State__c();
        NYState.name = 'New York';
        NYState.FIPS_Code__c = '36';
        NYState.State_Abbreviation__c = 'NY';
        insert NYState;
        County__c county = new County__c();
        county.Name = 'Suffolk County, NY';
        //county.Pricing_Region__c = prList[3].Id;
        //county.Sales_Region__c = 'MD Region';
        county.State__c = NYState.Id;
        county.FIPS_Code__c = '36103';
        insert county;

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
    }

}