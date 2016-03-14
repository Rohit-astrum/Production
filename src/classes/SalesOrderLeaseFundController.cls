/* FILE: SalesOrderLeaseFundController.cls
 * AUTHOR: Rohit Jain
 * DATE: July 13, 2013
 * PURPOSE: Controller for Sending Lead Information to NRG from Sales Order
 * MODIFICATION HISTORY:
 *
 */

public with sharing class SalesOrderLeaseFundController {
 /*
  SCRB_SalesOrder__c so; 
  system_Design__c sd; 
  List<NRG_Array__c> arrayList = new List<NRG_Array__c>();
  NRG_Quote__c nq;

  public SalesOrderLeaseFundController (ApexPages.StandardController stdController) {
      so = (SCRB_SalesOrder__c) stdController.getRecord();
      /*so = [Select Id,Name,System_Design_Quote__r.NRG_LeadId__c,System_Design_Quote__c,
                 System_Design_Quote__r.NRG_SolarId__c,System_Design_Quote__r.NRG_QuoteId__c
                 ,leasing_option__c
             From SCRB_SalesOrder__c Where Id = :so.Id ];
      
      so = [Select Id,Name,System_Design_Quote__r.NRG_Lead_Id__c,System_Design_Quote__r.System_Design__c
                  ,CEG_Deposit__c,Lease_Escalator__c,Year_1__c,Total_Grant_Amount__c
                  ,Sales_Tax_Percentage__c,CEG_Total_System_Price__c,Calculator_Utility_Company__r.Name
                  ,System_Design_Quote__r.NRG_Down_Payment__c,System_Design_Quote__r.NRG_Calculator_Lease_Escalator__c
                  , System_Design_Quote__r.NRG_Monthly_Lease_Rate__c,System_Design_Quote__r.NRG_Calculator_Avoided_Cost__c
                  ,Calculator_Avoided_Utility_Price_kWh__c
                  ,System_Design_Quote__r.NRG_Calculator_State_Grant__c,System_Design_Quote__r.NRG_Calculator_Sales_Tax__c
                  ,System_Design_Quote__r.NRG_EPC_Price__c ,System_Design_Quote__r.NRG_Calculator_Utility__c
                  ,System_Design_Quote__r.Low_FICO__c, Upfront_Lease_Payment_Due_at_Final_Comp__c
                  ,System_Design_Quote__r.NRG_Prepay_Amount__c,System_Design_Quote__c,System_Design_Quote__r.NRG_SolarId__c
                  ,System_Design_Quote__r.NRG_QuoteId__c
                 ,leasing_option__c,System_Design_Quote__r.NRG_LeadId__c
             From SCRB_SalesOrder__c Where Id = :so.Id ];
             
  }
  
  public PageReference sendAcceptNRGLeaseFundQuote() {
    PageReference requestPage = Page.LeaseFundDetail;
    Boolean IsPrepaid;
    System_Design_Quote__C sdq;
    if(so.System_Design_Quote__c == null )
    {        
        requestPage.getParameters().put('leadsent','NSDQ');
        requestPage.setRedirect(true);
        return requestPage;     
    }
    else
    {
        sdq = [Select NRG_Quote_Accepted__c , NRG_Quote_Accept_Message__c from System_Design_Quote__c Where id = :so.System_Design_Quote__c];
    }
    if(so.System_Design_Quote__r.NRG_LeadId__c == null || so.System_Design_Quote__r.NRG_SolarId__c == null  || so.System_Design_Quote__r.NRG_QuoteId__c == null)
    {        
        requestPage.getParameters().put('leadsent','NR');
        requestPage.setRedirect(true);
        return requestPage;     
    }
    if(so.leasing_option__c == null)
    {        
        requestPage.getParameters().put('leadsent','LO');
        requestPage.setRedirect(true);
        return requestPage;     
    }
    else
    {
      System.debug('*** '+so.leasing_option__c);
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
    }

    String jSonRequest = generateJSONContent(IsPrepaid);
    NRGAPIOAuth2Helper oauth = new NRGAPIOAuth2Helper();
    String jSonResponse;
    try{
      jSonResponse = oauth.sendQuoteToNRG(jSonRequest);
      System.debug(jSonResponse);
      sdq = parsejSonResponse(jSonResponse,sdq);
      if(sdq.NRG_Quote_Accepted__c)
      {
        requestPage.getParameters().put('leadsent','Y');
      }
      else
      {
        requestPage.getParameters().put('leadsent','EY');  
      }  
    }
    catch(Exception e)
    {
      sdq.NRG_Quote_Accept_Message__c = e.getMessage();
      requestPage.getParameters().put('leadsent','EY');   
    } 
    update sdq; 
    
    requestPage.getParameters().put('id',sdq.Id);
    requestPage.setRedirect(true);
    return requestPage;  
     
  }  

  public String generateJSONContent(Boolean IsPrepaid) {
        // Create a JSONGenerator object.
        // Pass true to the constructor for pretty print formatting.
        JSONGenerator gen = JSON.createGenerator(true);
                
        // Write data to the JSON string.
        gen.writeStartObject();
        gen.writeStringField('NRGQuoteId', so.System_Design_Quote__r.NRG_QuoteId__c);
        gen.writeStringField('NRGSolarId',so.System_Design_Quote__r.NRG_SolarId__c);
        gen.writeStringField('NRGLeadId', so.System_Design_Quote__r.NRG_LeadId__c);
        gen.writeStringField('ExternalId', so.System_Design_Quote__c);
        gen.writeBooleanField('GenerateLease', false);
        gen.writeBooleanField('SendLeaseToHomeowner', false);
        gen.writeBooleanField('IsPrepaid', IsPrepaid);
        gen.writeStringField('PartnerCompany', 'Astrum Solar, Inc.');
        gen.writeStringField('PartnerUser', UserInfo.getUserName());
        gen.writeStringField('PartnerUserEmail', UserInfo.getUserEmail());
        // Get the JSON string.
        String jsonRequest = gen.getAsString();
        
        System.debug(jsonRequest);
        return jsonRequest;
  }
  
  private System_Design_Quote__c parsejSonResponse(String responseText,System_Design_Quote__c sdq) {
  
    JSONParser parser = JSON.createParser(responseText);
    
    while (parser.nextToken() != null) {
      if (parser.getCurrentToken() == JSONToken.VALUE_STRING) {
        if (parser.getCurrentName() == 'Message') {
          If(parser.getText() != '200: OK' ) {
            sdq.NRG_Quote_Accepted__c = false;
          }          
          else
          {
            sdq.NRG_Quote_Accepted__c = true;
          }
           sdq.NRG_Quote_Accept_Message__c = parser.getText();
        }           
      }      
    }   
    return sdq;
    
  }
  
  
  public PageReference sendNewToNRGLeaseFund() { 
       
       List<NRG_Lead__c> nlead;     
       List<NRG_System__c> nsystem ;
       List<NRG_Quote__c> nquote ;
       List<NRG_Array__C> narrays;
       Boolean recreate = true;
       List<NRG_Array__c> narrayList = new List<NRG_Array__c>();
      
       sd = [Select Id,s.Property__r.QAS_Property_County__c, s.Property__r.Property_ZIP__c, s.Property__r.Property_State__c
                 , s.Property__r.Property_City__c, s.Property__r.Name, s.Property__c , s.property__r.property_Owner__c, s.system_makeup__c
                 ,Total_Projected_Annual_Output_kWh_y__c,Total_System_Size_kW__c,NRG_Projected_Annual_Output_kWh_y__c                  
              From System_Design__c s
             Where id = :so.System_Design_Quote__r.System_Design__c ]; 
       
          
       
       Account acct = [Select (Select LastName, FirstName, Email,Phone From Contacts) From Account a Where Id = :sd.property__r.Property_Owner__c];     
       NRG_Lead__c lead;
       if(acct != null && acct.Contacts.size() > 0 )
       {
           lead = new NRG_Lead__c();
           lead.Name = acct.Contacts[0].LastName + ', '+ acct.Contacts[0].FirstName;
           lead.First_Name__c = acct.Contacts[0].FirstName;
           lead.Last_Name__c = acct.Contacts[0].LastName;
           lead.Email__c = acct.Contacts[0].Email;
           lead.Phone__c = acct.Contacts[0].Phone;
           lead.Street__c = sd.Property__r.Name;
           lead.City__C = sd.Property__r.Property_City__c;
           lead.State__c = sd.Property__r.Property_State__c;
           lead.Postal_Code__c = sd.Property__r.Property_ZIP__c;
           lead.County__c = sd.Property__r.QAS_Property_County__c;
           lead.Company__C = 'Astrum Solar';
           lead.Lead_status__c = 'Open';
           lead.System_Design_Quote__c = so.System_Design_Quote__c;
           lead.NRG_Lead_Id__C = so.System_Design_Quote__r.NRG_Lead_Id__c;
           lead.Low_FICO__c = so.System_Design_Quote__r.Low_FICO__c;
          
       }
       NRG_System__C sys;
       if (lead != null )
       {
           sys = new NRG_system__c();
         
           sys.description__C = sd.system_makeup__c;
           sys.System_Size__c = sd.Total_System_Size_kW__c;
           sys.First_Year_Production__c = sd.NRG_Projected_Annual_Output_kWh_y__c; 
                
       }
       else
       {
          PageReference requestPage = Page.LeaseFundDetailSoap;
          requestPage.getParameters().put('leadsent','F');
          requestPage.setRedirect(true);
          return requestPage;
           
       }
       
       System.debug('*HEre2');        
       if (Sys != null)
       {       
           System.debug('**Insert Quote');
           nq = new NRG_Quote__c();    
           nq.Sales_Order__c = so.id;
           nq.Sales_Order_Name__c = so.Name;
           if(so.System_Design_Quote__r.NRG_Lead_Id__C != null && so.System_Design_Quote__r.NRG_Lead_Id__C != '' && !so.System_Design_Quote__r.NRG_Lead_ID__C.contains('Error'))
           {
               nq.Down_Payment__c  = so.System_Design_Quote__r.NRG_Down_Payment__c;  //CEG_Deposit__c;
               nq.Lease_Escalator__c = so.System_Design_Quote__r.NRG_Calculator_Lease_Escalator__c;
               nq.Monthly_Payment__c = so.System_Design_Quote__r.NRG_Monthly_Lease_Rate__c;
               nq.Rebate_Amount__c = so.System_Design_Quote__r.NRG_Calculator_State_Grant__c;
               nq.Sales_Tax__c = so.System_Design_Quote__r.NRG_Calculator_Sales_Tax__c;
               nq.System_Cost__c = so.System_Design_Quote__r.NRG_EPC_Price__c;
               nq.Utility__c = so.System_Design_Quote__r.NRG_Calculator_Utility__c;
               nq.Avoided_Cost__c = so.System_Design_Quote__r.NRG_Calculator_Avoided_Cost__c;   
               
               so.System_Design_Quote__r.NRG_Down_Payment__c = nq.Down_Payment__c ;
               so.System_Design_Quote__r.NRG_Calculator_Lease_Escalator__c = nq.Lease_Escalator__c;
               so.System_Design_Quote__r.NRG_Monthly_Lease_Rate__c = nq.Monthly_Payment__c;
               so.System_Design_Quote__r.NRG_Calculator_State_Grant__c = nq.Rebate_Amount__c;
               so.System_Design_Quote__r.NRG_Calculator_Sales_Tax__c =nq.Sales_Tax__c;
               so.System_Design_Quote__r.NRG_EPC_Price__c =nq.System_Cost__c ;
               so.Calculator_Avoided_Utility_Price_kWh__c = nq.Avoided_Cost__c ;
                  
           }
           else
           {
           
               nq.Down_Payment__c  = so.CEG_Deposit__c;
               nq.Lease_Escalator__c = so.Lease_Escalator__c;
               nq.Monthly_Payment__c = so.Year_1__c;
               nq.Rebate_Amount__c = so.Total_Grant_Amount__c;
               nq.Sales_Tax__c = so.Sales_Tax_Percentage__c;
               nq.System_Cost__c = so.CEG_Total_System_Price__c;
               nq.Utility__c = so.Calculator_Utility_Company__r.Name;
               nq.Avoided_Cost__c = so.Calculator_Avoided_Utility_Price_kWh__c;
           }
           
           
           System.debug('**Insert Array');
           List<Lease_Fund_Product_Mapping__C> products = [Select Astrum_Product__C, Lease_Fund_Product__c from Lease_Fund_Product_Mapping__C];
           Map<Id,Id> productmapping = new Map<Id,Id>();
           for(Lease_Fund_Product_Mapping__C product : products)
           {
              productmapping.put(product.Astrum_Product__C, product.Lease_Fund_Product__c);             
           }
           
           List<NRG_String_Component__C> comps = [Select Id , String_Component_id__c from NRG_String_Component__C];
           Map<Id,Id> compmapping = new Map<Id,Id>();
           for(NRG_String_Component__C comp: comps)
           {
              compmapping.put(comp.Id, comp.String_Component_id__c);             
           }
           System.debug('**Insert Array 2');

           List<System_Design_Item__c> inverterList = [Select System_Design_Product__C 
                                                   From System_Design_Item__c s
                                                  Where s.System_Design_Array__r.System_Design__c = :sd.id  
                                                    and s.Quantity__c > 0 and RecordType.Name = 'Inverter'  ];
            Id inverterId;
            if(inverterList != null && inverterList.size() > 0)
            {
               inverterId = inverterList[0].System_Design_Product__C;
            }
            else
            {
              System_Design_Product__C inverter = [Select Id from System_Design_Product__C Where MOdel__c = 'M215-60-240-S22' limit 1];
              inverterId = inverter.Id;        
            }
       
           
           System.debug('Insert Array sd.id ' + sd.id );
           AggregateResult[] sysitems = [Select s.Tilt_Text__c, s.System_Design_Product__c, sum(s.Quantity__c),sum(Rated_Output_kW__c),sum(NRG_Projected_Annual_Output_kWh_y__c),s.Azimuth_Text__c, s.Shading_Text__C 
                                           From System_Design_Item__c s
                                          Where s.System_Design_Array__r.System_Design__c = :sd.id  and s.Quantity__c > 0 and RecordType.Name = 'Panel'
                                       Group by s.System_Design_Product__c, s.Tilt_Text__c,s.Shading_Text__C,s.Azimuth_Text__c ];
                                    
           
           System.debug('** Insert Array s size ' + sysitems.size());
           
           //Map<Id,System_Design_Items__c> sysmap = new Map<Id,System_Design_Items__c>();       
           
            
                   
           for (AggregateResult sysitem : sysitems)
           {
               NRG_Array__c nrgarray = new NRG_Array__c();    
               
               //nrgarray.NRG_Lead__c = lead.Id;
               System.debug('**Insert Array22 ' + nrgarray);  
               if( sysitem.get('Azimuth_Text__c') == null || sysitem.get('Tilt_Text__c') == null || sysitem.get('Shading_Text__C') == null )
               {
                  PageReference requestPage = Page.LeaseFundDetailSoap;
                  requestPage.getParameters().put('leadsent','AF');
                  requestPage.setRedirect(true);
                  return requestPage;        
               }
               else
               {
                   nrgarray.Azimuth__c = sysitem.get('Azimuth_Text__c') != '' ? Decimal.valueOf((String)sysitem.get('Azimuth_Text__c')) : null;
                   nrgarray.Tilt__c = sysitem.get('Tilt_Text__c') != '' ? Decimal.valueOf((String)sysitem.get('Tilt_Text__c')) : null ; 
                   nrgarray.Shading__c = sysitem.get('Shading_Text__C') != '' ? Decimal.valueOf((String)sysitem.get('Shading_Text__C'))/100 : null;
               }    
               nrgarray.NRG_Inverter_Id__c = compmapping.get(productmapping.get(inverterId));
               //nrgarray.NRG_Inverter_Id__c = compmapping.get(productmapping.get(inverter.Id));
               nrgarray.Inverter_Quantity__c = (Decimal)sysitem.get('expr0');
               nrgarray.System_Size__c = (Decimal)sysitem.get('expr1');     
               nrgarray.First_Year_Production__c = (Decimal)sysitem.get('expr2');    
               nrgarray.NRG_Module_Id__c = compmapping.get(productmapping.get((ID)sysitem.get('System_Design_Product__c')));  //a1pA0000000EqJN
               if(nrgarray.NRG_Module_Id__c == null || nrgarray.NRG_Module_Id__c == '')
               {
                  PageReference requestPage = Page.LeaseFundDetailSoap;
                  requestPage.getParameters().put('leadsent','MF');
                  requestPage.setRedirect(true);
                  return requestPage;         
               }
               nrgarray.Module_Quantity__c  = (Decimal)sysitem.get('expr0');
               
               narrayList.add(nrgarray );
               System.debug('**Insert Array ' + nrgarray);    
           }
            System.debug('Insert Array ' + narrayList.size());  
          
       }
       
        System.debug('*HEre3');
        lead.NRG_Lead_Id__C = sendToNRG('NRG',lead,sys,nq,narrayList);
        
        
        if(nlead    != null)
        {
            delete nlead;
        }
        if(nsystem != null)
        {    
            delete nsystem;
        }
        if(narrays != null)    
        {
            delete narrays;
        } 
        if(nquote  != null)
        {
            delete nquote;
        }     
        
        insert lead;
        sys.Nrg_Lead__C = lead.Id;
        insert sys; 
        nq.Nrg_System__C = sys.Id;
        nq.Nrg_Quote_Id__C = lead.NRG_Lead_Id__C;
        insert nq;
        for(NRG_Array__c nrgarray :narrayList )           
        {
            nrgarray.Solar_System__c = sys.Id;
            nrgarray.NRG_Lead__c = lead.Id;
        }    
        if(!narrayList.isEmpty())
        {          
           insert narrayList;
        }
        update so;
       // Share the Record
      
       PageReference requestPage = Page.LeaseFundDetailSoap;
       requestPage.getParameters().put('id',lead.Id);
       if (lead.NRG_Lead_Id__C != null && lead.NRG_Lead_Id__C != '' && !lead.NRG_Lead_Id__C.contains('Error'))
       {
           requestPage.getParameters().put('leadsent','Y');
       }
       else{
           requestPage.getParameters().put('leadsent','E');
       }    
       requestPage.setRedirect(true);
      
       return requestPage; 
        
       return null;
   }    
      
  
  
  public String sendToNRG (String Type,NRG_Lead__c lead, NRG_System__c sys,NRG_Quote__c nq, List<NRG_Array__C> arrayList  )
  {
        
        
        soapSforceComSchemasClassAstrumlead.AstrumLead al = new soapSforceComSchemasClassAstrumlead.AstrumLead();
        
        al.FirstName = lead.First_Name__c;
        al.LastName = lead.Last_Name__c;
        al.Street = lead.Street__c;
        al.City = lead.City__C;
        al.State = lead.State__c;
        al.County = lead.County__c;
        al.PostalCode = lead.Postal_Code__c;
        al.Company = 'Astrum Solar';
        al.Email = lead.Email__c;
        al.Phone = lead.Phone__c;
        al.status = 'Open';
        al.LowFico = lead.Low_FICO__c;
        if(Type == 'NRG')
        {
            al.AstrumleadId = lead.System_Design_Quote__c;
        }
        else if(Type == 'Astrum')
        {
            al.AstrumleadId = lead.System_Design__c;
        }    
        al.LeadId = lead.NRG_Lead_Id__c;
        
        soapSforceComSchemasClassAstrumlead.AstrumSystem asys = new soapSforceComSchemasClassAstrumlead.AstrumSystem();
        asys.Description = sys.description__C;
        asys.First_Year_Production = sys.First_Year_Production__c;
        asys.System_Size = sys.System_Size__c ;
        
        soapSforceComSchemasClassAstrumlead.AstrumQuote aquote = new soapSforceComSchemasClassAstrumlead.AstrumQuote();
        aquote.Down_Payment = nq.Down_Payment__C;
        aquote.ExternalQuoteId = nq.Sales_Order_Name__c;
        aquote.Lease_Escalator = nq.Lease_Escalator__c;
        aquote.Monthly_Payment = nq.Monthly_Payment__c;
        aquote.Rebate_Amount = nq.Rebate_Amount__c;
        aquote.Sales_Tax     = nq.Sales_Tax__c;
        aquote.System_Cost    = nq.System_Cost__c;
        aquote.Utility       = nq.Utility__c;
        aquote.AvoidedCost  = nq.Avoided_Cost__c;
        
        System.debug('*Lead-'+al);
        System.debug('*aquote-'+aquote);
        System.debug('*asys-'+asys);
        
        List<soapSforceComSchemasClassAstrumlead.AstrumArray> lar = new List<soapSforceComSchemasClassAstrumlead.AstrumArray>(); 
        for(NRG_Array__c nrgarray :arrayList )           
        {
            soapSforceComSchemasClassAstrumlead.AstrumArray ar = new soapSforceComSchemasClassAstrumlead.AstrumArray();
            ar.Tilt = nrgarray.Tilt__c ;
            ar.Azimuth = nrgarray.Azimuth__c;
            ar.Shading = nrgarray.Shading__c;
            ar.Invertor = nrgarray.NRG_Inverter_Id__c;
            ar.Module = nrgarray.NRG_Module_Id__c; //'a1pA0000000EqJN';
            ar.InverterQuantity = nrgarray.Inverter_Quantity__c;
            ar.ModuleQuantity = nrgarray.Module_Quantity__c ;
            ar.Racking = 'a1pA0000000FVeDIAW';
            ar.First_Year_Production = nrgarray.First_Year_Production__c;
            ar.System_Size = nrgarray.System_Size__c;       
            lar.add(ar);
        }
        try {
            if (!Test.isRunningTest()) 
            {
                
                partnerSoapSforceCom.Soap sp = new partnerSoapSforceCom.Soap();        
        
                NRG_Lease_Fund__c mc = NRG_Lease_Fund__c.getValues('NRG Lease Fund');
                
                String username = mc .API_Username__c;
                String password =  mc.API_Password__c;
                partnerSoapSforceCom.LoginResult loginResult = sp.login(username, password); 
                system.debug('   loginResult ' + loginResult);
                
                soapSforceComSchemasClassAstrumlead apexWebSvc = new soapSforceComSchemasClassAstrumlead();        
                soapSforceComSchemasClassAstrumlead.AstrumLeadIntegrationWS apx = new soapSforceComSchemasClassAstrumlead.AstrumLeadIntegrationWS(); 
                apx.timeout_x = 100000;
                soapSforceComSchemasClassAstrumlead.SessionHeader_element SessionHeader = new soapSforceComSchemasClassAstrumlead.SessionHeader_element();
                sessionHeader.sessionid=loginResult.sessionid; 
                apx.sessionheader=sessionHeader;
                soapSforceComSchemasClassAstrumlead.AstrumLead  le =apx.createLead(al,asys,aquote ,lar);
                system.debug('The value of NRG Lead Id is ' + le.LeadId);
                //lead.NRG_Lead_Id__C = le.LeadId;
                return le.LeadId;
            }
            else
            {
                return '00QK00000044PUQMA2';  
            }   
         } catch(Exception e) {
            System.debug('The exception has been raised is'+e);
            return 'Error-'+e;
        } 
   
   }*/
   /*

   public String generateJSONContent(String Type,NRG_Lead__c lead, NRG_System__c sys,NRG_Quote__c nq, List<NRG_Array__C> arrayList ) {
        // Create a JSONGenerator object.
        // Pass true to the constructor for pretty print formatting.
        JSONGenerator gen = JSON.createGenerator(true);
                
        // Write data to the JSON string.
        gen.writeStartObject();
        gen.writeStringField('PrimaryLeadFirstName', lead.First_Name__c);
        gen.writeStringField('PrimaryLeadLastName', lead.Last_Name__c);
        gen.writeStringField('SecondaryLeadFirstName', '');
        gen.writeStringField('SecondaryLeadLastName', '');
        gen.writeStringField('Street', lead.Street__c);
        gen.writeStringField('City', lead.City__c);
        gen.writeStringField('Country', 'USA');
        gen.writeStringField('County', lead.County__c);
        gen.writeStringField('PostalCode', lead.Postal_Code__c);
        gen.writeStringField('Company', 'Astrum Solar');
        gen.writeStringField('Status', 'Active');

        gen.writeStringField('PrimaryLeadEmail', (lead.Email__c != null ? lead.Email__c : ''));
        gen.writeStringField('PrimaryLeadPhone', (lead.Phone__c != null ? lead.Phone__c : ''));
        gen.writeStringField('SecondaryLeadEmail', '');
        gen.writeStringField('SecondaryLeadPhone', '');

        gen.writeBooleanField('RunCreditOnPrimary', false);
        gen.writeBooleanField('RunJointCredit', false);
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
        
        if(Type == 'NRG')
        {
            gen.writeStringField('ExternalId', lead.System_Design_Quote__c); 
        }
        else if(Type == 'Astrum')
        {
            gen.writeStringField('ExternalId', lead.System_Design__c); 
        }    
        
        gen.writeStringField('State', lead.State__c);
        gen.writeStringField('CurrentUtility', (nq.Utility__c != null ? nq.Utility__c : ''));
        gen.writeStringField('PartnerCompany', 'Astrum Solar');
        gen.writeStringField('PartnerUser', UserInfo.getUserName());
        gen.writeStringField('PartnerUserEmail', UserInfo.getUserEmail());

        gen.writeStringField('SysDesc', (sys.description__C != null ? sys.description__C : ''));
        gen.writeNumberField('Rebate', (nq.Rebate_Amount__c != null ? nq.Rebate_Amount__c : 0));
        gen.writeNumberField('SystemCost', (nq.System_Cost__c != null ? nq.System_Cost__c : 0));
        gen.writeNumberField('LeaseEscalator', (nq.Lease_Escalator__c != null ? nq.Lease_Escalator__c: 0));
        gen.writeNumberField('DownPayment', (nq.Down_Payment__c != null ? nq.Down_Payment__c : 0));
        gen.writeNumberField('MinimumDown', 0);
        gen.writeNumberField('SalesTax', (nq.Sales_Tax__c != null ? nq.Sales_Tax__c : 0));
        gen.writeNumberField('AvoidedCost', (nq.Avoided_Cost__c != null ? nq.Avoided_Cost__c : 0));
        
        gen.writeBooleanField('GeneratePricing', false);
        gen.writeBooleanField('RequestProposal', false);
        gen.writeBooleanField('LeadUpload', true);
        gen.writeBooleanField('SendProposalToHomeowner', true);
        gen.writeBooleanField('GenerateSampleLeaseDoc', true);
        gen.writeBooleanField('SendSampleLeaseDocToHomeOwner', false);
        
        gen.writeNumberField('TotalFirstYrProduction', (sys.First_Year_Production__c != null ? sys.First_Year_Production__c : 0));
        gen.writeNumberField('TotalArraySize', (sys.System_Size__c != null ? sys.System_Size__c : 0));
                
        gen.writeFieldName('SystemArray');
        gen.writeStartArray();
        double total_modules = 0;
        integer externalArrayID = 1;
        for(NRG_Array__c nrgarray :arrayList )           
        {
          gen.writeStartObject();

            gen.writeNumberField('FirstYrProduction', (nrgarray.First_Year_Production__c != null ? nrgarray.First_Year_Production__c : 0));
            gen.writeNumberField('ArraySize', (nrgarray.System_Size__c != null ? nrgarray.System_Size__c : 0));
            gen.writeNumberField('Tilt', nrgarray.Tilt__c);
            gen.writeNumberField('Azimuth',  nrgarray.Azimuth__c);
            gen.writeNumberField('Shading', nrgarray.Shading__c);
            gen.writeNumberField('InverterQunatity', nrgarray.Inverter_Quantity__c.intValue());
            gen.writeNumberField('ModuleQuantity', nrgarray.Module_Quantity__c.intValue() );
            gen.writeStringField('Inverter', nrgarray.NRG_Inverter__c);
            gen.writeStringField('Module', nrgarray.NRG_Module__c);
            gen.writeStringField('Racking', '');
            gen.writeStringField('ExternalArrayId', 'AstrumTest-'+externalArrayID);
            externalArrayID += 1;
            total_modules = total_modules+nrgarray.Module_Quantity__c; 

          gen.writeEndObject();            
        }
        gen.writeEndArray();
        gen.writeNumberField('TotalModuleQuantity', total_modules.intValue());
       
        gen.writeEndObject();
        
        // Get the JSON string.
        String jsonRequest = gen.getAsString();
        
        System.debug(jsonRequest);
        return jsonRequest;
  }

   
    //parse the JSON result returned 
  private NRG_Lead__c parsejSonResponse(String responseText,NRG_Lead__c lead) {
  
    JSONParser parser = JSON.createParser(responseText);
    
    while (parser.nextToken() != null) {
      if (parser.getCurrentToken() == JSONToken.VALUE_STRING) {
        if (parser.getCurrentName() == 'Message') {
          If(parser.getText() != '200: OK' ) {
            lead.NRG_Lead_Id__c = parser.getText();
          }          
        }  
        else if (parser.getCurrentName() == 'NRGLeadID') {
          If(lead.NRG_Lead_Id__c == null) {
            lead.NRG_Lead_Id__c = parser.getText();
          }          
        }  
      }      
    }
    return lead;
  } 
     */ 
}