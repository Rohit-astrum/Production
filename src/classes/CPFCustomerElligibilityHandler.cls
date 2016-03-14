// Commented by RJ 05/5/2015
@RestResource(urlMapping='/Elligible/*')
global with sharing class CPFCustomerElligibilityHandler{
    /*
    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        System.debug(req.requestBody.toString());
        String xmlRequest = req.requestBody.toString();
        String CustomerId = parseRequest(xmlRequest);
        List<System_Design_Quote__c> sdqs = [Select CPF_Customer_Id__c, CPF_Eligibility_Completed__c 
                                               from System_Design_Quote__c 
                                              Where CPF_Customer_Id__c = : CustomerId];
        for(System_Design_Quote__c sdq : sdqs)
        {
            sdq.CPF_Eligibility_Completed__c  = true;
        }
      
        update sdqs;
         
        
    }

    Public Static String parseRequest(String xmlRequest)
    {
        Dom.Document doc = new Dom.Document();
        doc.load(xmlRequest);
        
        Dom.Xmlnode root = doc.getRootElement();  
        System.debug(root);      
        String  customerId = root.getChildElement('Customer', null).getText();       
      
        System.debug(customerId);

        return customerId;

    }
    */

}