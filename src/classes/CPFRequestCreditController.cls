// Commented by RJ 05/5/2015
public with sharing class CPFRequestCreditController {

    /*
    private opportunity opty;

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public CPFRequestCreditController (ApexPages.StandardController stdController) {
        this.opty = (Opportunity)stdController.getRecord();
        opty = [Select AccountId,System_Design_Quote__c,System_Design_Quote__r.CPF_Eligibility_Initiate__c, System_Design_Quote__r.CPF_Customer_Id__c
                      ,Property__r.QAS_Property_County__c, Property__r.Property_County__c, Property__r.Property_ZIP__c
                      ,Property__r.Property_State__c, Property__r.Property_City__c, Property__r.Name, Property__c , Property__r.Property_Owner__c
                      ,Property__r.Utility_Company__r.Name,Property__r.Utility_Company__c
                 from Opportunity 
                Where Id = :opty.Id];
    }

    public PageReference initiateCreditCheck() {
        PageReference requestPage = Page.LeaseFundDetailSoap;  
        System_Design_Quote__c sdq;     
        // Check if Opportunity is linked to SDQ 
        if(opty.System_Design_Quote__c == null )
        {        
            requestPage.getParameters().put('leadsent','CSDQ');
            requestPage.setRedirect(true);
            return requestPage;     
        }

        // Check if Utility is associated
        if(opty.Property__r.Utility_Company__c == null )
        {        
            requestPage.getParameters().put('leadsent','NPU');
            requestPage.setRedirect(true);
            return requestPage;     
        }
        // Check if Credit Request is already being sent
        if(opty.System_Design_Quote__r.CPF_Eligibility_Initiate__c == 'success')
        {        
            PageReference requestPage1 = Page.CPFResendCreditRequest;
            requestPage1.getParameters().put('id',opty.Id);
            requestPage1.setRedirect(true);
            return requestPage1;     
        }

        // Check if CPF Customer Exists
        if(opty.System_Design_Quote__r.CPF_Customer_Id__c == null || opty.System_Design_Quote__r.CPF_Customer_Id__c == '' )
        {        
            requestPage.getParameters().put('leadsent','CCN');
            requestPage.setRedirect(true);
            return requestPage;     
        }
        else
        {
            sdq = [Select CPF_Eligibility_Initiate__c,CPF_Eligibility_Initiate_Message__c,CPF_Customer_Id__c 
                                           From System_Design_Quote__c 
                                          Where Id = :opty.System_Design_Quote__c];

            CPFIntegrationProcessor cpi = new CPFIntegrationProcessor();
            sdq = cpi.initiateCPFElligibility(sdq,false);
            update sdq;
        }
        PageReference sdqPage = new PageReference('/'+sdq.Id);     
        sdqPage.setRedirect(true); 
        return sdqPage;
    }
    
    public PageReference ResendCreditRequest() {
        PageReference requestPage = Page.LeaseFundDetailSoap;   
        System_Design_Quote__c sdq;    
        // Check if Opportunity is linked to SDQ 
        if(opty.System_Design_Quote__c == null )
        {        
            requestPage.getParameters().put('leadsent','NSDQ');
            requestPage.setRedirect(true);
            return requestPage;     
        }

        // Check if Utility is associated
        if(opty.Property__r.Utility_Company__c == null )
        {        
            requestPage.getParameters().put('leadsent','NPU');
            requestPage.setRedirect(true);
            return requestPage;     
        }        

        // Check if CPF Customer Exists
        if(opty.System_Design_Quote__r.CPF_Customer_Id__c == null || opty.System_Design_Quote__r.CPF_Customer_Id__c == '' )
        {        
            requestPage.getParameters().put('leadsent','CCN');
            requestPage.setRedirect(true);
            return requestPage;     
        }
        else
        {
            sdq = [Select CPF_Eligibility_Initiate__c,CPF_Eligibility_Initiate_Message__c,CPF_Customer_Id__c 
                                           From System_Design_Quote__c 
                                          Where Id = :opty.System_Design_Quote__c];

            CPFIntegrationProcessor cpi = new CPFIntegrationProcessor();
            sdq = cpi.initiateCPFElligibility(sdq,true);
            update sdq;
        }
        PageReference sdqPage = new PageReference('/'+sdq.Id);     
        sdqPage.setRedirect(true); 
        return sdqPage;
    }
    
    */
    
}