// Commented by RJ 05/5/2015
public with sharing class CPFSignatureRequestController {

	/*
    SCRB_SalesOrder__c so; 
    system_Design__c sd; 
    List<NRG_Array__c> arrayList = new List<NRG_Array__c>();
    NRG_Quote__c nq;
    Boolean IsPrepaid;

    public CPFSignatureRequestController (ApexPages.StandardController stdController) {
      so = (SCRB_SalesOrder__c) stdController.getRecord();      
      so = [Select Id,Name,System_Design_Quote__r.CPF_Proposal_Id__c,System_Design_Quote__r.System_Design__c
                  ,System_Design_Quote__r.CPF_Annual_Increase__c,System_Design_Quote__r.CPF_Customer_Id__c
                  ,System_Design_Quote__r.CPF_Document_Generation_Completed__c, System_Design_Quote__r.CPF_Down_Payment__c
                  ,System_Design_Quote__r.CPF_Eligibility_Completed__c , System_Design_Quote__r.CPF_Monthly_Payment__c
                  ,System_Design_Quote__r.CPF_Year_One_Production__c
                  ,CEG_Deposit__c,Lease_Escalator__c,Year_1__c,Total_Grant_Amount__c
                  ,Sales_Tax_Percentage__c,CEG_Total_System_Price__c,Calculator_Utility_Company__r.Name
                 ,Leasing_option__c, AccountId__c ,OpportunityId__c, System_Design_Quote__r.CPF_PrepaidDocument_Generation_Completed__c
             From SCRB_SalesOrder__c Where Id = :so.Id ];
             
    }

    public PageReference RequestSignatureForCPFQuote() {
        PageReference requestPage = Page.LeaseFundDetail;        
        System_Design_Quote__C sdq;
        String homeOwnerEmail;
        if(so.System_Design_Quote__c == null )
        {        
            requestPage.getParameters().put('leadsent','NSDQ');
            requestPage.setRedirect(true);
            return requestPage;     
        }       
        
        if(so.leasing_option__c.contains ('Monthly'))      
        {
            IsPrepaid = false;  
            System.debug('M*** '+so.leasing_option__c);
        }
        else if(so.leasing_option__c == 'One-Pay' || so.leasing_option__c ==  'One-Pay – Massachusetts')
        {
            IsPrepaid = true;  
        }
        else
        {
            requestPage.getParameters().put('leadsent','ILO');
            requestPage.setRedirect(true);
            return requestPage;  
        }

        if(IsPrepaid && !so.System_Design_Quote__r.CPF_PrepaidDocument_Generation_Completed__c )
        {        
            requestPage.getParameters().put('leadsent','NDOC');
            requestPage.setRedirect(true);
            return requestPage;     
        }

        if(!IsPrepaid && !so.System_Design_Quote__r.CPF_Document_Generation_Completed__c )
        {        
            requestPage.getParameters().put('leadsent','NDOC');
            requestPage.setRedirect(true);
            return requestPage;     
        }

        if(!so.System_Design_Quote__r.CPF_Eligibility_Completed__c )
        {        
            requestPage.getParameters().put('leadsent','NCRE');
            requestPage.setRedirect(true);
            return requestPage;     
        }
        sdq = [Select CPF_Sent_For_Signature__c,CPF_Sent_For_Signature_Message__c,CPF_Customer_Id__c,CPF_Proposal_Id__c 
                                           From System_Design_Quote__c 
                                          Where Id = :so.System_Design_Quote__c];

        List<OpportunityContactRole>  contactRoles = [Select o.Contact.Email, o.Contact.FirstName, o.Contact.LastName, o.ContactId ,o.Contact.Phone
                                                        From OpportunityContactRole o 
                                                       Where Role = 'Contract Signer' and OpportunityId = :so.OpportunityId__c];



        if(contactRoles != null && contactRoles.size() > 0 )
        {
            homeOwnerEmail = contactRoles[0].Contact.Email;
        }
        else
        {
            requestPage.getParameters().put('leadsent','NCO');
            requestPage.setRedirect(true);
            return requestPage;  
        }

        if(homeOwnerEmail == null || homeOwnerEmail == '')
        {
            requestPage.getParameters().put('leadsent','NCO');
            requestPage.setRedirect(true);
            return requestPage; 
        }
        

        CPFIntegrationProcessor cpi = new CPFIntegrationProcessor();
        sdq = cpi.sendCPFForSignature(sdq, homeOwnerEmail, IsPrepaid);
        update sdq;  

        requestPage.getParameters().put('id',sdq.Id);
        requestPage.setRedirect(true);
        return requestPage;  
        
        return null;  
         
    }  
    */
}