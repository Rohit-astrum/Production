public with sharing class Milestone1_Project_Controller {
    private final Milestone1_Project__c proj;
    // The extension constructor initializes the private member
    // variable acct by using the getRecord method from the standard
    // controller.
    public Milestone1_Project_Controller(ApexPages.StandardController stdController) {
        this.proj = (Milestone1_Project__c)stdController.getRecord();
/*      
        SCRB_SalesOrder__c so = [
        Select so.Property__c,
            so.Type__c,
            so.TrackingNumber__c,
            so.TotalDiscountAmount__c,
            so.Tax__c,
            so.SubmitMessage__c,
            so.StatusCode__c,
            so.ShippingStreet__c,
            so.ShippingState__c,
            so.ShippingPostalCode__c,
            so.ShippingPhone__c,
            so.ShippingMethod__c,
            so.ShippingLocation__c,
            so.ShippingFax__c,
            so.ShippingCountry__c,
            so.ShippingContact__c,
            so.ShippingCity__c,
            so.RequestedShipmentOn__c,
            so.Pricebook__c,
            so.PaymentTerms__c,
            so.OriginatingDocument__c,
            so.OpportunityId__c,
            so.LineItemAmount__c,
            so.FreightAmount__c,
            so.Failed__c,
            so.DocumentNumber__c,
            so.DocumentDate__c,
            so.DiscountAmount__c,
            so.Description__c,
            so.BillingStreet__c,
            so.BillingState__c,
            so.BillingPostalCode__c,
            so.BillingPhone__c,
            so.BillingFax__c,
            so.BillingCountry__c,
            so.BillingCity__c,
            so.Amount__c,
            so.AccountId__c,
            so.SystemModstamp,
            so.LastModifiedById,
            so.LastModifiedDate,
            so.CreatedById,
            so.CreatedDate,
            so.Name,
            so.IsDeleted,
            so.OwnerId,
            so.Id
        From SCRB_SalesOrder__c so
        Where so.Id = :proj.Sales_Order__r.id
        ];
        proj.Sales_Order__c = so.Id;*/
    }
    
    public String getGreeting() {
        return 'Hello ' + proj.name + ' (' + proj.id + ')';
    }
    /*  
    public Property__c getProperty(){
    
        Property__c prop = [ 
        Select
            p.RecordTypeId, 
            p.Property_ZIP__c, 
            p.Property_State__c, 
            p.Property_Owner__c, 
            p.Property_County__c, 
            p.Property_City__c, 
            p.Property_Address_2__c, 
            p.Name, 
            p.Id, 
            p.HOA_Contact_Phone__c, 
            p.HOA_Contact_Name__c, 
            p.HOA_Contact_Email__c, 
            p.Authorization_Bodies__c, 
            p.Astrum_Office__c 
        From Property__c p 
        where id = :proj.Sales_Order__r.Id
        limit 1];
        return prop;
    }
    
    public List<Install_Location__c> getInstallLocations(){
    List<Install_Location__c> locations = [
            select id, 
                Name,
                Utility_Service__r.Name,
                TSRF__c,
                Tilt__c,
                Surface_Type__c,
                Stuctural_Members__c,
                Orientation__c
            from Install_Location__c i
            where Install_Location__c.Property__c = :proj.Property__c
            ];
        return locations;   }
    
    public Account getPropertyOwner(){
        Account acct = [
            Select 
                a.Website, 
                a.Type, 
                a.ShippingStreet, 
                a.ShippingState, 
                a.ShippingPostalCode, 
                a.ShippingCountry, 
                a.ShippingCity, 
                a.Phone, 
                a.ParentId, 
                a.OwnerId, 
                a.NumberOfEmployees, 
                a.Name, 
                a.MasterRecordId, 
                a.Industry, 
                a.Id, 
                a.Fax, 
                a.Description, 
                a.BillingStreet, 
                a.BillingState, 
                a.BillingPostalCode, 
                a.BillingCountry, 
                a.BillingCity, 
                a.AnnualRevenue, 
                a.AccountNumber 
            From Account a
            where a.Id = :getProperty().Property_Owner__r.id
            limit 1];
        return acct;
    }
    
    public List<OpportunityContactRole> getOppContacts(){
        
        String OppId = proj.Sales_Order__r.OpportunityId__r.id;
        
        List<OpportunityContactRole> ocrList = [
            Select o.Role, 
                o.OpportunityId, 
                o.IsPrimary, 
                o.Id, 
                o.ContactId 
            From OpportunityContactRole o
            where o.OpportunityId = :OppId];
        
        return ocrList;
    
    }
    */
}