@isTest
public class CaseServiceCloudExtensionTest {
    
    @isTest static void caseService(){
        
        testData.setupCustomSettingsPricing();
        testdata.setupCustomConfigObjectsPricing();
        
        //Create account
        Account acct = new Account();
        acct.name = 'Test Account';
        insert acct;
        
        //Create case
        Case c = new Case();
        c.subject = 'Test Subject';
        c.AccountId = acct.Id;
        insert c;
        
        //Create email message
        EmailMessage msg = new EmailMessage(Subject='Test Message',Incoming=true,ParentId=c.Id);
        insert msg;
            
        //Create property        
        Property__c prop = new Property__c();
        prop.Name = '123 Main St';
        prop.RecordTypeid = [Select id from RecordType where sobjecttype = 'Property__c' and Name ='Residential' limit 1].id;
        prop.Property_Owner__c = acct.Id;       
        prop.Optimal_Site_Quality_kWh_y_kW__c = double.valueOf('1250');
        prop.Property_State__c = 'MD';
        prop.Property_City__c = 'Annapolis Junction';        
        prop.Property_ZIP__c = '20701';
        prop.Property_County__c = 'Howard';
        prop.Astrum_Office__c = 'Annapolis Junction, MD';        
        prop.Sales_Region__c = [select id from Astrum_Sales_Region__c where name='MD Region'].id;  
        prop.QAS_Property_County__c = 'Howard County, MD';    //DK 12-23-14
        insert prop;
        
        prop = [SELECT Id, Property_Owner__c FROM Property__c WHERE Id=:prop.Id];
        
        //Create opportunity
        Opportunity opp = testdata.createTestOppForProperty(prop);
        opp.StageName = 'Qualified';
        update opp;
        
        //Create systemdesign
        System_Design__c sd = new System_Design__c();
        sd.Property__c = prop.Id;
        sd.Calculated_System_Price__c = decimal.valueOf('100000.25');
        insert sd;
        
        //Create sdq
        System_Design_Quote__c sdq = new System_Design_Quote__c();
        sdq.System_Design__c = sd.Id;
        insert sdq;
        
        //Create salesorder
        SCRB_SalesOrder__c salesOrder = new SCRB_SalesOrder__c(
            Property__c = prop.Id, 
            OpportunityId__c = opp.Id,
            Requires_Tree_Removal__c = 'No',
            Has_Field_Survey_Been__c = 'No',
            Job_Id__c = 'P-343123232',
            System_Design_Quote__c= sdq.id,
            AccountId__c = c.AccountId
        );
        insert salesOrder;
        
        PM_Project__c newProject = new PM_Project__c(
            Name = salesOrder.AccountId__r.Name,
            Sales_Order__c = salesOrder.Id,
            Salesperson__c = salesOrder.OpportunityId__r.OwnerId
        );        
        
        newProject.Install__c = date.today().addDays(90);        
        newProject.Kickoff__c = Datetime.newInstance(date.today().addDays(2), Time.newInstance(12,0,0,0));        
        insert newProject;
        
        Test.startTest();
        
        ApexPages.StandardController stdCntrl = new ApexPages.StandardController(c);
        CaseServiceCloudExtension caseService = new CaseServiceCloudExtension(stdCntrl);
        
		System.assertEquals(prop.Id, caseService.Properties[0].Id);
        System.assertEquals(salesOrder.Id, caseService.salesOrders[0].Id);  
        System.assertEquals(msg.Id, caseService.lastEmailMessage[0].Id);  
        System.assertEquals(newProject.Id, caseService.pmProjects[0].Id);
        System.assertEquals(sd.Id, caseService.systemDesigns[0].Id);
        
        Test.stopTest();
        
    }

}