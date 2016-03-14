// Commented by RJ 05/5/2015
@RestResource(urlMapping='/Proposal/*')
global with sharing class CPFProposalCallBackHandler{
    //https://fullstage-astrumsolar.cs14.force.com/cpf/services/apexrest/Proposal
    //<Request><GetJobURI>https://astrum.cpfmirror.com:443/api/quoting/v1/job/get</GetJobURI><ProposalUUID>71aa114f-f6fa-11e3-bd00-bc764e1009c4</ProposalUUID><Status>success</Status><Message>Documents Generated Successfully</Message></Request>    
    /*
    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        System.debug(req.requestBody.toString());
        String xmlRequest = req.requestBody.toString();
        String ProposalId = parseRequest(xmlRequest);
        List<System_Design_Quote__c> sdqs = [Select CPF_Customer_Id__c, CPF_Document_Generation_Completed__c , CPF_PrepaidDocument_Generation_Completed__c , 
                                                    System_Design__r.Property__r.Property_Owner__r.Name        
                                               from System_Design_Quote__c 
                                              Where CPF_Proposal_Id__c = : ProposalId];
        
        if(sdqs != null && sdqs.size() > 0 )
        {
            for(System_Design_Quote__c sdq : sdqs)
            {
                sdq.CPF_Document_Generation_Completed__c  = true;
                sdq = CPFIntegrationProcessor.getCPFDocuments(sdq,ProposalId,'Monthly');

            }
            update sdqs;
        }
        else
        {
            List<System_Design_Quote__c> sdqsp = [Select CPF_Customer_Id__c, CPF_Document_Generation_Completed__c , CPF_PrepaidDocument_Generation_Completed__c
                                              , System_Design__r.Property__r.Property_Owner__r.Name        
                                               from System_Design_Quote__c 
                                              Where CPF_Prepaid_Proposal_Id__c = : ProposalId];    
            if(sdqsp != null && sdqsp.size() > 0 )
            {
                for(System_Design_Quote__c sdq : sdqsp)
                {
                    sdq.CPF_PrepaidDocument_Generation_Completed__c  = true;
                    sdq = CPFIntegrationProcessor.getCPFDocuments(sdq,ProposalId,'Prepaid');
                }
            }    
            update sdqsp;
        }
        
         
        
    }

    Public Static String parseRequest(String xmlRequest)
    {
        Dom.Document doc = new Dom.Document();
        doc.load(xmlRequest);
        
        Dom.Xmlnode root = doc.getRootElement();  
        System.debug(root);      
        String  ProposalId = root.getChildElement('ProposalUUID', null).getText();       
      
        System.debug(ProposalId);

        return ProposalId;

    }
    */

}