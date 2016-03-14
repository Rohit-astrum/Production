//Commented by RJ on 05/5/2015
public with sharing class NRGOpportunityLeadSendController {
    /*
    private opportunity opty;

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public NRGOpportunityLeadSendController(ApexPages.StandardController stdController) {
        this.opty = (Opportunity)stdController.getRecord();
        opty = [Select AccountId,System_Design_Quote__c,System_Design_Quote__r.NRG_Run_Primary_Credit_Flag__c, System_Design_Quote__r.System_Design__c
                      ,Property__r.QAS_Property_County__c, Property__r.Property_County__c, Property__r.Property_ZIP__c
                      ,Property__r.Property_State__c, Property__r.Property_City__c, Property__r.Name, Property__c , property__r.property_Owner__c
                      ,Property__r.Utility_Company__r.Name,Property__r.Utility_Company__c
                 from Opportunity 
                Where Id = :opty.Id];
    }

    public PageReference sendNRGLead() {
        PageReference requestPage = Page.LeaseFundDetailSoap;
        NRG_Lead__c lead;
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
        // Check if Credit Request is already being sent
        if(opty.System_Design_Quote__r.NRG_Run_Primary_Credit_Flag__c)
        {        
            PageReference requestPage1 = Page.NRGResendCreditRequest;
            requestPage1.getParameters().put('id',opty.Id);
            requestPage1.setRedirect(true);
            return requestPage1;     
        }
       
        List<OpportunityContactRole>  contactRoles = [Select o.Contact.Email, o.Contact.FirstName, o.Contact.LastName, o.ContactId ,o.Contact.Phone
                                                        From OpportunityContactRole o 
                                                       Where Role = 'Contract Signer' and OpportunityId = :opty.Id];
    
        if(contactRoles.size() > 0 )
        {
            lead = new NRG_Lead__c();
            lead.Name = contactRoles[0].Contact.LastName + ', '+ contactRoles[0].Contact.FirstName;
            lead.First_Name__c = contactRoles[0].Contact.FirstName;
            lead.Last_Name__c = contactRoles[0].Contact.LastName;
            lead.Email__c = contactRoles[0].Contact.Email;
            lead.Phone__c = contactRoles[0].Contact.Phone;
            if(contactRoles.size() > 1)
            {
                lead.Secondary_First_Name__c = contactRoles[1].Contact.FirstName;
                lead.Secondary_Last_Name__c = contactRoles[1].Contact.LastName;
                lead.Secondary_Email__c = contactRoles[1].Contact.Email;
                lead.Secondary_Phone__c = contactRoles[1].Contact.Phone;
                lead.NRG_Run_Joint_Credit__C = true; 
            }
            else
            {
                lead.NRG_Run_Primary_Credit_Flag__C = true;    
            }
            lead.Street__c = opty.Property__r.Name;
            lead.City__C = opty.Property__r.Property_City__c;
            lead.State__c = opty.Property__r.Property_State__c;
            lead.Postal_Code__c = opty.Property__r.Property_ZIP__c;
            lead.County__c = (opty.Property__r.QAS_Property_County__c != null ? opty.Property__r.QAS_Property_County__c : opty.Property__r.Property_County__c  );
            lead.Company__C = 'Astrum Solar, Inc.';
            lead.Lead_status__c = 'Active';
            lead.System_Design_Quote__c = opty.System_Design_Quote__c;
            lead.System_Design__c = opty.System_Design_Quote__r.System_Design__c;
                   
            //lead.Low_FICO__c = sdq.Low_FICO__c;
        }
    
        if (lead != null )
        {
            if(lead.Street__c  ==null || lead.City__C == null || lead.County__c == null || lead.Postal_Code__c == null || lead.Phone__c == null || lead.Email__c == null)
            {
                requestPage.getParameters().put('leadsent','LFS');
                requestPage.setRedirect(true);
                return requestPage;    
            }        
        }
        else
        {
            requestPage.getParameters().put('leadsent','NOC');
            requestPage.setRedirect(true);
            return requestPage;  
        }
        
        String jSonRequest = generateJSONContent(lead,opty.Property__r.Utility_Company__r.Name);
        NRGAPIOAuth2Helper oauth = new NRGAPIOAuth2Helper();
        String jSonResponse;
        try{
          jSonResponse = oauth.sendToNRG(jSonRequest);
        }
        catch(Exception e)
        {
           requestPage.getParameters().put('leadsent','FS');
           requestPage.setRedirect(true);
           return requestPage;   
        }  
        System.debug(jSonResponse);
        lead.NRG_Lead_Id__C = parsejSonResponse(jSonResponse);
        insert lead;
        
        requestPage.getParameters().put('id',lead.Id);
        if (lead.NRG_Lead_Id__C != null && lead.NRG_Lead_Id__C != '' && !lead.NRG_Lead_Id__C.contains('Error'))
        {
           requestPage.getParameters().put('leadsent','CY');
           System_Design_Quote__c sdq = [Select NRG_Run_Primary_Credit_Flag__c 
                                           From System_Design_Quote__c 
                                          Where Id = :opty.System_Design_Quote__c];
           sdq.NRG_Run_Primary_Credit_Flag__c = true;
           update sdq;
        }
        else{
           requestPage.getParameters().put('leadsent','E');
        }    
        requestPage.setRedirect(true);
      
        return requestPage; 
    }

    public PageReference ResendNRGLead() {
        PageReference requestPage = Page.LeaseFundDetailSoap;
        NRG_Lead__c lead;
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
       
       
        List<OpportunityContactRole>  contactRoles = [Select o.Contact.Email, o.Contact.FirstName, o.Contact.LastName, o.ContactId ,o.Contact.Phone
                                                        From OpportunityContactRole o 
                                                       Where Role = 'Contract Signer' and OpportunityId = :opty.Id];
    
        if(contactRoles.size() > 0 )
        {
            lead = new NRG_Lead__c();
            lead = new NRG_Lead__c();
            lead.Name = contactRoles[0].Contact.LastName + ', '+ contactRoles[0].Contact.FirstName;
            lead.First_Name__c = contactRoles[0].Contact.FirstName;
            lead.Last_Name__c = contactRoles[0].Contact.LastName;
            lead.Email__c = contactRoles[0].Contact.Email;
            lead.Phone__c = contactRoles[0].Contact.Phone;
            if(contactRoles.size() > 1)
            {
                lead.Secondary_First_Name__c = contactRoles[1].Contact.FirstName;
                lead.Secondary_Last_Name__c = contactRoles[1].Contact.LastName;
                lead.Secondary_Email__c = contactRoles[1].Contact.Email;
                lead.Secondary_Phone__c = contactRoles[1].Contact.Phone;
                lead.NRG_Run_Joint_Credit__C = true; 
            }
            else
            {
                lead.NRG_Run_Primary_Credit_Flag__C = true;    
            }
            lead.Street__c = opty.Property__r.Name;
            lead.City__C = opty.Property__r.Property_City__c;
            lead.State__c = opty.Property__r.Property_State__c;
            lead.Postal_Code__c = opty.Property__r.Property_ZIP__c;
            lead.County__c = (opty.Property__r.QAS_Property_County__c != null ? opty.Property__r.QAS_Property_County__c : opty.Property__r.Property_County__c  );
            lead.Company__C = 'Astrum Solar, Inc.';
            lead.Lead_status__c = 'Active';
            lead.System_Design_Quote__c = opty.System_Design_Quote__c;
            lead.System_Design__c = opty.System_Design_Quote__r.System_Design__c;
            //lead.NRG_Run_Primary_Credit_Flag__C = true;           
            //lead.Low_FICO__c = sdq.Low_FICO__c;
        }
    
        if (lead != null )
        {
            if(lead.Street__c  ==null || lead.City__C == null || lead.County__c == null || lead.Postal_Code__c == null || lead.Phone__c == null || lead.Email__c == null)
            {
                requestPage.getParameters().put('leadsent','LFS');
                requestPage.setRedirect(true);
                return requestPage;    
            }        
        }
        else
        {
            requestPage.getParameters().put('leadsent','NOC');
            requestPage.setRedirect(true);
            return requestPage;  
        }
        
        String jSonRequest = generateJSONContent(lead,opty.Property__r.Utility_Company__r.Name);
        NRGAPIOAuth2Helper oauth = new NRGAPIOAuth2Helper();
        String jSonResponse;
        try{
          jSonResponse = oauth.sendToNRG(jSonRequest);
        }
        catch(Exception e)
        {
           requestPage.getParameters().put('leadsent','FS');
           requestPage.setRedirect(true);
           return requestPage;   
        }  
        System.debug(jSonResponse);
        lead.NRG_Lead_Id__C = parsejSonResponse(jSonResponse);
        insert lead;
        
        requestPage.getParameters().put('id',lead.Id);
        if (lead.NRG_Lead_Id__C != null && lead.NRG_Lead_Id__C != '' && !lead.NRG_Lead_Id__C.contains('Error'))
        {
           requestPage.getParameters().put('leadsent','CY');           
        }
        else{
           requestPage.getParameters().put('leadsent','E');
        }    
        requestPage.setRedirect(true);
      
        return requestPage; 
    }


    Static String parsejSonResponse(String responseText) {
  
        JSONParser parser = JSON.createParser(responseText);
        String nrgLeadText;
        while (parser.nextToken() != null) {
          if (parser.getCurrentToken() == JSONToken.VALUE_STRING) {
            if (parser.getCurrentName() == 'Message') {
              If(parser.getText() != '200: OK' ) {
                nrgLeadText = parser.getText();               
              }
            } 
            else if (parser.getCurrentName() == 'NRGLeadID') {          
               nrgLeadText = parser.getText();            
            } 
          
          } 
        }
        return nrgLeadText;
  }

    public String generateJSONContent(NRG_Lead__c lead, String utilityName) {
        // Create a JSONGenerator object.
        // Pass true to the constructor for pretty print formatting.
        JSONGenerator gen = JSON.createGenerator(true);
                
        // Write data to the JSON string.
        gen.writeStartObject();
        gen.writeStringField('PrimaryLeadFirstName', lead.First_Name__c);
        gen.writeStringField('PrimaryLeadLastName', lead.Last_Name__c);
        gen.writeStringField('SecondaryLeadFirstName', (lead.Secondary_First_Name__c != null ? lead.Secondary_First_Name__c : ''));
        gen.writeStringField('SecondaryLeadLastName', (lead.Secondary_Last_Name__c != null ? lead.Secondary_Last_Name__c : ''));
        gen.writeStringField('Street', lead.Street__c);
        gen.writeStringField('City', lead.City__c);
        gen.writeStringField('Country', 'USA');
        gen.writeStringField('County', lead.County__c);
        gen.writeStringField('PostalCode', lead.Postal_Code__c);
        gen.writeStringField('Company', 'Astrum Solar, Inc.');
        gen.writeStringField('Status', 'Active');
        gen.writeStringField('PrimaryLeadEmail', (lead.Email__c != null ? lead.Email__c : ''));
        gen.writeStringField('PrimaryLeadPhone', (lead.Phone__c != null ? lead.Phone__c : ''));
        gen.writeStringField('SecondaryLeadEmail', (lead.Secondary_Email__c != null ? lead.Secondary_Email__c : ''));
        gen.writeStringField('SecondaryLeadPhone', (lead.Secondary_Phone__c != null ? lead.Secondary_Phone__c : ''));
        gen.writeBooleanField('RunCreditOnPrimary', lead.NRG_Run_Primary_Credit_Flag__C);
        gen.writeBooleanField('RunJointCredit', lead.NRG_Run_joint_Credit__C);
        gen.writeStringField('Tariff', 'DR - Domestic');
        gen.writeNumberField('UtilityAnnualRateIncrease', 0.00);
        gen.writeNumberField('X01JanConsumption', 0);
        gen.writeNumberField('X02FebConsumption', 0);
        gen.writeNumberField('X03MarConsumption', 0);
        gen.writeNumberField('X04AprConsumption', 0);
        gen.writeNumberField('X05MayConsumption', 0);
        gen.writeNumberField('X06JunConsumption', 0);
        gen.writeNumberField('X07JulConsumption', 0);
        gen.writeNumberField('X08AugConsumption', 0);
        gen.writeNumberField('X09SepConsumption', 0);
        gen.writeNumberField('X10OctConsumption', 0);
        gen.writeNumberField('X11NovConsumption', 0);
        gen.writeNumberField('X12DecConsumption', 0);
        gen.writeStringField('ExternalId', lead.System_Design__c);         
        gen.writeStringField('State', lead.State__c);
        gen.writeStringField('CurrentUtility', utilityName);
        gen.writeStringField('PartnerCompany', 'Astrum Solar, Inc.');
        gen.writeStringField('PartnerUser', UserInfo.getUserName());
        gen.writeStringField('PartnerUserEmail', UserInfo.getUserEmail());

        gen.writeNullField('SysDesc');
        gen.writeNullField('RebateAmount');
        gen.writeNullField('SystemCost');
        gen.writeNullField('LeaseEscalator' );
        gen.writeNullField('DownPayment');
        gen.writeNullField('MinimumDown');
        gen.writeNullField('SalesTax');
        gen.writeNullField('AvoidedCost');
        
        gen.writeNullField('GeneratePricing');
        gen.writeNullField('RequestProposal');
        gen.writeBooleanField('LeadUpload', true);
        gen.writeNullField('SendProposalToHomeowner');
        gen.writeNullField('GenerateSampleLeaseDoc');
        gen.writeNullField('SendSampleLeaseDocToHomeOwner');
        
        gen.writeNullField('TotalFirstYrProduction');
        gen.writeNullField('TotalArraySize');
                
        gen.writeFieldName('SystemArray');
        gen.writeStartArray();
        
        
          gen.writeStartObject();

            gen.writeNullField('FirstYrProduction');
            gen.writeNullField('ArraySize' );
            gen.writeNullField('Tilt');
            gen.writeNullField('Azimuth');
            gen.writeNullField('Shading');
            gen.writeNullField('InverterQunatity');
            gen.writeNullField('ModuleQuantity');
            gen.writeNullField('Inverter');
            gen.writeNullField('Module');
            gen.writeNullField('Racking');
            gen.writeNullField('ExternalArrayId');
            

          gen.writeEndObject();            
       
        gen.writeEndArray();
        gen.writeNullField('TotalModuleQuantity');
       
        gen.writeEndObject();
        
        // Get the JSON string.
        String jsonRequest = gen.getAsString();
        
        System.debug(jsonRequest);
        return jsonRequest;
  }
  */
}