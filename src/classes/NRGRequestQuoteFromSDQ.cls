/* FILE: NRGRequestQuoteFromSDQ.cls
 * AUTHOR: Rohit Jain
 * DATE: Nov 13, 2013
 * PURPOSE: Class to Call NRG API for Receiving Lease Rates
 * MODIFICATION HISTORY:
 * Commented by RJ on 05/5/2015
 */

public with sharing class NRGRequestQuoteFromSDQ{
    
  /*
  @Future(callout=true)  
  public static void RequestNRGQuote(ID SdqId, ID sdID, String NRG_Installation_State, Decimal NRG_Calculator_System_Size_kW,Decimal NRG_Calculator_Projected_Annual_Output,Decimal NRG_Down_Payment,Decimal NRG_Prepaid_Down_Payment,Decimal NRG_Calculator_Lease_Escalator,Decimal NRG_Calculator_State_Grant,Decimal NRG_Calculator_Sales_Tax,Decimal NRG_EPC_Price,Decimal NRG_Prepaid_EPC_Price, String NRG_Calculator_Utility, Decimal NRG_Calculator_Avoided_Cost) { 
            
    System_Design_Quote__c sdq = [Select Id, NRG_Lead_Id__c, NRG_Monthly_Lease_Rate__c, NRG_Input_Error__c
                                        ,NRG_Input_Error_Description__c, NRG_Prepay_Amount__c ,Low_FICO__c ,NRG_Prepaid_Input_Error_Message__c
                                        ,NRG_LeadId__c, NRG_SolarID__c, NRG_QuoteId__c , NRG_Prepay_Amount_Inc_Tax__c
                                        ,NRG_Minimum_Down_Payment__c,NRG_Monthly_Payment_Inc_Tax__c , NRG_Run_Primary_Credit_Flag__c                                    
                                    from System_Design_Quote__c 
                                   Where Id = :sdqId];
    
    System.debug('$$$-'+NRG_Installation_State+ ' '+NRG_Calculator_System_Size_kW + ' '+NRG_EPC_Price + ' '+ NRG_Calculator_Avoided_Cost + ' '+NRG_Calculator_Utility+ ' '+NRG_Calculator_Projected_Annual_Output );
    if(NRG_Installation_State != null && NRG_Calculator_System_Size_kW != null && (NRG_EPC_Price != null || NRG_Prepaid_EPC_Price != null) && NRG_Calculator_Avoided_Cost != null  && NRG_Calculator_Utility != null && NRG_Calculator_Projected_Annual_Output != null)
    {
      sdq = getNRGLeasePricing(sdq,sdID,NRG_Installation_State, NRG_Calculator_System_Size_kW,NRG_Calculator_Projected_Annual_Output,NRG_Down_Payment,NRG_Prepaid_Down_Payment,NRG_Calculator_Lease_Escalator,NRG_Calculator_State_Grant,NRG_Calculator_Sales_Tax,NRG_EPC_Price,NRG_Prepaid_EPC_Price, NRG_Calculator_Utility, NRG_Calculator_Avoided_Cost) ;         
    }
    else
    {      
      sdq.NRG_Input_Error_Description__c = 'For Pricing, please provide following info - Current Utility, State, System Cost, Total System Size, Total First Year Production, Avoided Cost. Please provide Rebate Amount if you want to have PrePaid Pricing as well.';
      if(NRG_Prepaid_EPC_Price == null)
      {
        sdq.NRG_Prepaid_Input_Error_Message__c = 'Missing NRG Prepaid EPC Price. Please provide the same to get the Prepaid Pricing.';
      }
      sdq.NRG_Input_Error__c = true;  
    }  
    update sdq;
  }   

  public static System_Design_Quote__c getNRGLeasePricing(System_Design_Quote__c sdq,ID sdID,String NRG_Installation_State, Decimal NRG_Calculator_System_Size_kW,Decimal NRG_Calculator_Projected_Annual_Output,Decimal NRG_Down_Payment,Decimal NRG_Prepaid_Down_Payment,Decimal NRG_Calculator_Lease_Escalator,Decimal NRG_Calculator_State_Grant,Decimal NRG_Calculator_Sales_Tax,Decimal NRG_EPC_Price, Decimal NRG_Prepaid_EPC_Price,String NRG_Calculator_Utility, Decimal NRG_Calculator_Avoided_Cost) { 
    
    NRG_Lead__c lead;
    NRG_System__C sys;
    NRG_Quote__c nq;
    Boolean isMonthly = false;
    Boolean isPrepaid = false;
    if(NRG_EPC_Price != null && NRG_EPC_Price > 0)
    {
      isMonthly = true;
    }
    if(NRG_Prepaid_EPC_Price != null && NRG_Prepaid_EPC_Price > 0)
    {
      isPrepaid = true;
    }

    List<NRG_Array__c> narrayList = new List<NRG_Array__c>();

    System_design__c sd = [Select Id,s.Property__r.QAS_Property_County__c, s.Property__r.Property_County__c
                ,s.Property__r.Property_ZIP__c, s.Property__r.Property_State__c,s.Property__r.Property_City__c
                ,s.Property__r.Name, s.Property__c , s.property__r.property_Owner__c,s.system_makeup__c
                ,Total_Projected_Annual_Output_kWh_y__c,Total_System_Size_kW__c,NRG_Projected_Annual_Output_kWh_y__c                  
          From System_Design__c s
         Where id = :sdID ];        
          
       
    Account acct = [Select (Select LastName, FirstName, Email,Phone From Contacts) From Account a Where Id = :sd.property__r.Property_Owner__c];     
    
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
      lead.County__c = (sd.Property__r.QAS_Property_County__c != null ? sd.Property__r.QAS_Property_County__c : sd.Property__r.Property_County__c  );
      lead.Company__C = 'Astrum Solar, Inc.';
      lead.Lead_status__c = 'Active';
      lead.System_Design_Quote__c = sdq.Id;
      lead.System_Design__c = sd.Id;
      lead.NRG_Run_Primary_Credit_Flag__C = sdq.NRG_Run_Primary_Credit_Flag__C;
      //lead.NRG_Lead_Id__C = so.System_Design_Quote__r.NRG_Lead_Id__c;
      lead.Low_FICO__c = sdq.Low_FICO__c;
    }
    
    if (lead != null )
    {
      if(lead.Street__c  !=null && lead.City__C != null && lead.County__c != null && lead.Postal_Code__c != null && lead.Phone__c != null && lead.Email__c != null)
      {
        sys = new NRG_system__c();
        sys.description__C = sd.system_makeup__c;
        sys.System_Size__c = sd.Total_System_Size_kW__c;
        sys.First_Year_Production__c = sd.NRG_Projected_Annual_Output_kWh_y__c;             
      }
      else
      {
        sdq.NRG_Input_Error_Description__c = 'One of the required fields is missing - Last Name, First Name, Street, City, County, State, Zip. Phone, Email .';
        sdq.NRG_Input_Error__c = true;  
        return sdq;    
      }  
    }
    else
    {
      sdq.NRG_Input_Error_Description__c = 'Please check if Property Account is associated with Contact.';
      sdq.NRG_Input_Error__c = true;  
      return sdq;        
    }
       
    System.debug('*HEre2');        
    if (Sys != null)
    {       
      System.debug('**Insert Quote');
      nq = new NRG_Quote__c();         
      nq.Down_Payment__c  = NRG_Down_Payment;  //CEG_Deposit__c;
      nq.NRG_Prepaid_Down_Payment__c  = NRG_Prepaid_Down_Payment;  //CEG_Deposit__c;
      nq.Lease_Escalator__c = NRG_Calculator_Lease_Escalator;      
      nq.Rebate_Amount__c = NRG_Calculator_State_Grant;
      nq.Sales_Tax__c = NRG_Calculator_Sales_Tax;
      nq.System_Cost__c = NRG_EPC_Price;      
      nq.NRG_Prepaid_System_Cost__c = NRG_Prepaid_EPC_Price;      
      nq.Utility__c = NRG_Calculator_Utility;
      nq.Avoided_Cost__c = NRG_Calculator_Avoided_Cost;


      System.debug('**Insert Array');
      List<Lease_Fund_Product_Mapping__C> products = [Select Astrum_Product__C, Lease_Fund_Product__c from Lease_Fund_Product_Mapping__C];
      Map<Id,Id> productmapping = new Map<Id,Id>();
      for(Lease_Fund_Product_Mapping__C product : products)
      {
        productmapping.put(product.Astrum_Product__C, product.Lease_Fund_Product__c);             
      }

      List<NRG_String_Component__C> comps = [Select Id , Name,String_Component_id__c from NRG_String_Component__C];
      Map<Id,Id> compmapping = new Map<Id,Id>();
      Map<Id,String> compnamemapping = new Map<Id,String>();
      for(NRG_String_Component__C comp: comps)
      {
        compmapping.put(comp.Id, comp.String_Component_id__c);     
        compnamemapping.put(comp.Id, comp.Name);         
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
      
      for (AggregateResult sysitem : sysitems)
      {
        NRG_Array__c nrgarray = new NRG_Array__c();    

        //nrgarray.NRG_Lead__c = lead.Id;
        System.debug('**Insert Array22 ' + nrgarray);  
        if( sysitem.get('Azimuth_Text__c') == null || sysitem.get('Tilt_Text__c') == null || sysitem.get('Shading_Text__C') == null )
        {
          sdq.NRG_Input_Error_Description__c = 'Missing one of the Required fields in Array - Azimuth or Shading or Tilt.';
          sdq.NRG_Input_Error__c = true;  
          return sdq;
        }
        else
        {
          nrgarray.Azimuth__c = sysitem.get('Azimuth_Text__c') != '' ? Decimal.valueOf((String)sysitem.get('Azimuth_Text__c')) : null;
          nrgarray.Tilt__c = sysitem.get('Tilt_Text__c') != '' ? Decimal.valueOf((String)sysitem.get('Tilt_Text__c')) : null ; 
          nrgarray.Shading__c = sysitem.get('Shading_Text__C') != '' ? Decimal.valueOf((String)sysitem.get('Shading_Text__C'))/100 : null;
        }    
        nrgarray.NRG_Inverter_Id__c = compmapping.get(productmapping.get(inverterId));
        if(nrgarray.NRG_Inverter_Id__c == null || nrgarray.NRG_Inverter_Id__c == '')
        {
          sdq.NRG_Input_Error_Description__c = 'Missing Inverter Information. Please check the NRG Product Mappings.';
          sdq.NRG_Input_Error__c = true;  
          return sdq;
        }
        nrgarray.NRG_Inverter__c = compnamemapping.get(productmapping.get(inverterId));
        nrgarray.Inverter_Quantity__c = (Decimal)sysitem.get('expr0');
        nrgarray.System_Size__c = (Decimal)sysitem.get('expr1');     
        nrgarray.First_Year_Production__c = (Decimal)sysitem.get('expr2');    
        nrgarray.NRG_Module_Id__c = compmapping.get(productmapping.get((ID)sysitem.get('System_Design_Product__c')));  //a1pA0000000EqJN
        nrgarray.NRG_Module__c = compnamemapping.get(productmapping.get((ID)sysitem.get('System_Design_Product__c'))); 
        if(nrgarray.NRG_Module_Id__c == null || nrgarray.NRG_Module_Id__c == '')
        {
          sdq.NRG_Input_Error_Description__c = 'Missing Module Information. Please check the NRG Product Mappings.';
          sdq.NRG_Input_Error__c = true;  
          return sdq;
        }
        nrgarray.Module_Quantity__c  = (Decimal)sysitem.get('expr0');

        narrayList.add(nrgarray );
        System.debug('**Insert Array ' + nrgarray);    
      }
      System.debug('Insert Array ' + narrayList.size());            
    }      
    
    String jSonRequest;
    NRGAPIOAuth2Helper oauth = new NRGAPIOAuth2Helper(); 
    String jSonResponse;

    if(isMonthly)
    {
      jSonRequest = generateJSONContent('NRG',lead,sys,nq,narrayList,true);     
      try{
        jSonResponse = oauth.sendToNRG(jSonRequest);
      }
      catch(Exception e)
      {
        sdq.NRG_Input_Error_Description__c = e.getMessage();
        sdq.NRG_Input_Error__c = true;
        return sdq;
      }
      System.debug(jSonResponse);
      sdq = parsejSonResponse(jSonResponse,sdq, isMonthly, isPrepaid, 'Monthly');
    }  
    if(isPrepaid)
    {
      jSonRequest = generateJSONContent('NRG',lead,sys,nq,narrayList,false);     
      try{
        jSonResponse = oauth.sendToNRG(jSonRequest);
      }
      catch(Exception e)
      {
        sdq.NRG_Input_Error_Description__c = e.getMessage();
        sdq.NRG_Input_Error__c = true;
        return sdq;
      }
      System.debug(jSonResponse);
      sdq = parsejSonResponse(jSonResponse,sdq, isMonthly, isPrepaid, 'Prepaid');
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

    return sdq; 

    
  }     

  public Static String generateJSONContent(String Type,NRG_Lead__c lead, NRG_System__c sys,NRG_Quote__c nq, List<NRG_Array__C> arrayList , Boolean isMonthly) {
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
        gen.writeStringField('Company', 'Astrum Solar, Inc.');
        gen.writeStringField('Status', 'Active');

        gen.writeStringField('PrimaryLeadEmail', (lead.Email__c != null ? lead.Email__c : ''));
        gen.writeStringField('PrimaryLeadPhone', (lead.Phone__c != null ? lead.Phone__c : ''));
        gen.writeStringField('SecondaryLeadEmail', '');
        gen.writeStringField('SecondaryLeadPhone', '');

        gen.writeBooleanField('RunCreditOnPrimary', lead.NRG_Run_Primary_Credit_Flag__C);
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
        
        
        
        gen.writeStringField('ExternalId', lead.System_Design__c); 
         
        
        gen.writeStringField('State', lead.State__c);
        gen.writeStringField('CurrentUtility', (nq.Utility__c != null ? nq.Utility__c : ''));
        gen.writeStringField('PartnerCompany', 'Astrum Solar, Inc.');
        gen.writeStringField('PartnerUser', UserInfo.getUserName());
        gen.writeStringField('PartnerUserEmail', UserInfo.getUserEmail());

        gen.writeStringField('SysDesc', (sys.description__C != null ? sys.description__C : ''));
        gen.writeNumberField('RebateAmount', (nq.Rebate_Amount__c != null ? nq.Rebate_Amount__c : 0));
        if(isMonthly)
        {
          gen.writeNumberField('SystemCost', (nq.System_Cost__c != null ? nq.System_Cost__c : 0));
          gen.writeNumberField('DownPayment', (nq.Down_Payment__c != null ? nq.Down_Payment__c : 0));
        }
        else
        {
          gen.writeNumberField('SystemCost', (nq.NRG_Prepaid_System_Cost__c != null ? nq.NRG_Prepaid_System_Cost__c : 0));  
          gen.writeNumberField('DownPayment', (nq.NRG_Prepaid_Down_Payment__c != null ? nq.NRG_Prepaid_Down_Payment__c : 0));
        }
        gen.writeNumberField('LeaseEscalator', (nq.Lease_Escalator__c != null ? nq.Lease_Escalator__c: 0));
        
        gen.writeNumberField('MinimumDown', 0);
        gen.writeNumberField('SalesTax', (nq.Sales_Tax__c != null ? nq.Sales_Tax__c : 0));
        gen.writeNumberField('AvoidedCost', (nq.Avoided_Cost__c != null ? nq.Avoided_Cost__c : 0));
        
        gen.writeBooleanField('GeneratePricing', true);
        gen.writeBooleanField('RequestProposal', false);
        gen.writeBooleanField('LeadUpload', true);
        gen.writeBooleanField('SendProposalToHomeowner', false);
        gen.writeBooleanField('GenerateSampleLeaseDoc', true);
        gen.writeBooleanField('SendSampleLeaseDocToHomeOwner', false);
        
        gen.writeNumberField('TotalFirstYrProduction', (sys.First_Year_Production__c != null ? sys.First_Year_Production__c : 0));
        gen.writeNumberField('TotalArraySize', (sys.System_Size__c != null ? sys.System_Size__c * 1000 : 0));
                
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
  Static System_Design_Quote__c parsejSonResponse(String responseText,System_Design_Quote__c sdq, Boolean isMonthly, Boolean isPrepaid, String callType) {
  
    JSONParser parser = JSON.createParser(responseText);
    
    while (parser.nextToken() != null) {
      if (parser.getCurrentToken() == JSONToken.VALUE_STRING) {
        if(callType =='Monthly' && isMonthly)
        {
          if (parser.getCurrentName() == 'Message') {
            If(parser.getText() != '200: OK' ) {
              sdq.NRG_Input_Error_Description__c = parser.getText();
              sdq.NRG_Input_Error__c = true;
            }   
            else
            {
              sdq.NRG_Input_Error__c = false;            
            }       
          } 
          else if (parser.getCurrentName() == 'NRGLeadID') {          
             sdq.NRG_LeadId__c = parser.getText();            
          } 
          else if (parser.getCurrentName() == 'NRGSolarId') {          
             sdq.NRG_SolarId__c = parser.getText();            
          } 
          else if (parser.getCurrentName() == 'NRGQuoteId') {          
             sdq.NRG_QuoteId__c = parser.getText();            
          }
        }
        if(callType =='Prepaid' && isPrepaid)
        {
          if (parser.getCurrentName() == 'Message') {
            If(parser.getText() != '200: OK' ) {
              sdq.NRG_Prepaid_Input_Error_Message__c = parser.getText();
              sdq.NRG_Input_Error__c = true;
              sdq.NRG_Prepay_Amount__c = null;
              sdq.NRG_Prepay_Amount_Inc_Tax__c = null;
            }   
            else
            {
              sdq.NRG_Input_Error__c = false;            
            }       
          } 
          else if (parser.getCurrentName() == 'NRGLeadID') {          
             sdq.NRG_Prepaid_LeadId__c = parser.getText();            
          } 
          else if (parser.getCurrentName() == 'NRGSolarId') {          
             sdq.NRG_Prepaid_SolarId__c = parser.getText();            
          } 
          else if (parser.getCurrentName() == 'NRGQuoteId') {          
             sdq.NRG_Prepaid_QuoteId__c = parser.getText();            
          }

        } 
      } else if (parser.getCurrentToken() == JSONToken.VALUE_NUMBER_FLOAT) {
        if(callType =='Monthly' && isMonthly)
        {          
          if (parser.getCurrentName() == 'MonthlyPayment') {
            sdq.NRG_Monthly_Lease_Rate__c  = parser.getDoubleValue();         
          }
          else if (parser.getCurrentName() == 'MonthlyPaymentInclTax') {
            sdq.NRG_Monthly_Payment_Inc_Tax__c  = parser.getDoubleValue();         
          }         
          else if (parser.getCurrentName() == 'Minimum_Down') {
            sdq.NRG_Minimum_Down_Payment__c = parser.getDoubleValue();          
          }
          if(!isPrepaid)
          {
            if (parser.getCurrentName() == 'PrePayAmount') {          
              sdq.NRG_Prepay_Amount__c = parser.getDoubleValue();        
            } 
            else if (parser.getCurrentName() == 'PrePayAmountInclTax') {
              sdq.NRG_Prepay_Amount_Inc_Tax__c = parser.getDoubleValue();          
            }  
          }
        }
        if(callType =='Prepaid' && isPrepaid)
        {
          if(sdq.NRG_Prepaid_Input_Error_Message__c == null || sdq.NRG_Prepaid_Input_Error_Message__c == '')
          {
            if (parser.getCurrentName() == 'PrePayAmount') {          
              sdq.NRG_Prepay_Amount__c = parser.getDoubleValue();        
            } 
            else if (parser.getCurrentName() == 'PrePayAmountInclTax') {
              sdq.NRG_Prepay_Amount_Inc_Tax__c = parser.getDoubleValue();          
            }  
            else if (parser.getCurrentName() == 'Minimum_Down') {
              sdq.NRG_Prepaid_Minimum_Down_Payment__c = parser.getDoubleValue();          
            }           
          }
        }
      }
    }
    return sdq;
  }


  /*
  public Static String generateJSONContent(ID SdqId, String NRG_Installation_State, Decimal NRG_Calculator_System_Size_kW,Decimal NRG_Calculator_Projected_Annual_Output,Decimal NRG_Down_Payment,Decimal NRG_Calculator_Lease_Escalator,Decimal NRG_Calculator_State_Grant,Decimal NRG_Calculator_Sales_Tax,Decimal NRG_EPC_Price, String NRG_Calculator_Utility, Decimal NRG_Calculator_Avoided_Cost) {
    // Create a JSONGenerator object.
    // Pass true to the constructor for pretty print formatting.
    JSONGenerator gen = JSON.createGenerator(false);
            
    // Write data to the JSON string.
    gen.writeStartObject();
    gen.writeStringField('ExternalId', sdqId); 
    gen.writeStringField('State', NRG_Installation_State);
    gen.writeStringField('CurrentUtility', (NRG_Calculator_Utility != null ? NRG_Calculator_Utility : ''));        
    gen.writeStringField('PartnerCompany', 'Astrum Solar');
    gen.writeStringField('PartnerUser', UserInfo.getUserName());
    gen.writeStringField('PartnerUserEmail', UserInfo.getUserEmail());
    gen.writeStringField('SysDesc', '');
  
    gen.writeNumberField('RebateAmount', (NRG_Calculator_State_Grant != null ? NRG_Calculator_State_Grant : 0));
    gen.writeNumberField('SystemCost', (NRG_EPC_Price != null ? NRG_EPC_Price : 0));
    gen.writeNumberField('LeaseEscalator', (NRG_Calculator_Lease_Escalator != null ? NRG_Calculator_Lease_Escalator: 0));
    gen.writeNumberField('DownPayment', (NRG_Down_Payment != null ? NRG_Down_Payment : 0));
    gen.writeNumberField('MinimumDown', 0);
    gen.writeNumberField('SalesTax', (NRG_Calculator_Sales_Tax != null ? NRG_Calculator_Sales_Tax : 0));
    gen.writeNumberField('AvoidedCost', (NRG_Calculator_Avoided_Cost != null ? NRG_Calculator_Avoided_Cost : 0));

    gen.writeBooleanField('GeneratePricing', true);
    gen.writeBooleanField('RequestProposal', false);
    gen.writeBooleanField('LeadUpload', false);
    gen.writeBooleanField('SendProposalToHomeowner', false);
    gen.writeBooleanField('GenerateSampleLeaseDoc', false);
    gen.writeBooleanField('SendSampleLeaseDocToHomeOwner', false);
    gen.writeNumberField('TotalModuleQuantity', 0);
    gen.writeNumberField('TotalFirstYrProduction', NRG_Calculator_Projected_Annual_Output);
    gen.writeNumberField('TotalArraySize', NRG_Calculator_System_Size_kW* 1000);

    gen.writeEndObject();
    
    // Get the JSON string.
    String jsonRequest = gen.getAsString();
    
    System.debug(jsonRequest);
    return jsonRequest;
  }

    //parse the JSON result returned 
  static System_Design_Quote__c parsejSonResponse(String responseText,System_Design_Quote__c sdq) {
  
    JSONParser parser = JSON.createParser(responseText);
    
    while (parser.nextToken() != null) {
      if (parser.getCurrentToken() == JSONToken.VALUE_STRING) {
        if (parser.getCurrentName() == 'Message') {
          If(parser.getText() != '200: OK' ) {
            sdq.NRG_Input_Error_Description__c = parser.getText();
            sdq.NRG_Input_Error__c = true;
          }   
          else
          {
            sdq.NRG_Input_Error__c = false;            
          }       
        } 
      } else if (parser.getCurrentToken() == JSONToken.VALUE_NUMBER_FLOAT) {
        if (parser.getCurrentName() == 'PrePayAmount') {          
          sdq.NRG_Prepay_Amount__c = parser.getDoubleValue();
          System.debug('**Prepay  - '+sdq.NRG_Prepay_Amount__c  );
        }
        else if (parser.getCurrentName() == 'MonthlyPayment') {
          sdq.NRG_Monthly_Lease_Rate__c = parser.getDoubleValue();
          System.debug('**sdq.NRG_Monthly_Lease_Rate__c - '+sdq.NRG_Monthly_Lease_Rate__c );
        }
      }
    }
    return sdq;
  }
   
  
 
    @Future(callout=true)
    public static void RequestNRGQuote(ID SdqId, String NRG_Installation_State, Decimal NRG_Calculator_System_Size_kW,Decimal NRG_Calculator_Projected_Annual_Output,Decimal NRG_Down_Payment,Decimal NRG_Calculator_Lease_Escalator,Decimal NRG_Calculator_State_Grant,Decimal NRG_Calculator_Sales_Tax,Decimal NRG_EPC_Price, String NRG_Calculator_Utility, Decimal NRG_Calculator_Avoided_Cost) { 
              
       NRG_Lead__c lead;
       
       lead = new NRG_Lead__c();
       lead.State__c = NRG_Installation_State;
       lead.System_Design_Quote__c = SdqId;
       
       NRG_System__C sys;
       if (lead != null )
       {
           sys = new NRG_system__c();
           sys.System_Size__c = NRG_Calculator_System_Size_kW;
           sys.First_Year_Production__c = NRG_Calculator_Projected_Annual_Output;
       }
       
       NRG_Quote__c nq;
       System.debug('*HEre2');        
       if (Sys != null)
       {       
           System.debug('**Insert Quote');
           nq = new NRG_Quote__c();  
           nq.Down_Payment__c  = NRG_Down_Payment;
           nq.Lease_Escalator__c = NRG_Calculator_Lease_Escalator;
           nq.Rebate_Amount__c = NRG_Calculator_State_Grant;
           nq.Sales_Tax__c = NRG_Calculator_Sales_Tax;
           nq.System_Cost__c = NRG_EPC_Price;
           nq.Utility__c = NRG_Calculator_Utility;  
           nq.Avoided_Cost__c = NRG_Calculator_Avoided_Cost;         
        }
        
        List<NRG_Array__c> arrayList = new List<NRG_Array__c>();        
        
        NRG_Array__c narray = new NRG_Array__c();
        narray.System_Size__c = NRG_Calculator_System_Size_kW;
        narray.First_Year_Production__c = NRG_Calculator_Projected_Annual_Output;
        arrayList.add(narray);
        
        System.debug('*HEre3');
        System.debug('**lead '+lead);
        System.debug('**lead '+sys);
        System.debug('**lead '+nq);
        System.debug('**lead '+arrayList);        
        
        soapSforceComSchemasClassAstrumlead.AstrumLead nrlead = sendToNRG(lead,sys,nq,arrayList );
        
        System_Design_Quote__c sdq = [Select Id,NRG_Lead_Id__c , NRG_Monthly_Lease_Rate__c , NRG_Input_Error__c 
                                        from System_Design_Quote__c 
                                       Where Id = :sdqId];

        sdq.NRG_Lead_Id__c = nrlead.LeadId;
        sdq.NRG_Monthly_Lease_Rate__c = nrlead.MonthlyPayment;
        sdq.NRG_Input_Error__c = false;
        update sdq;
        lead.NRG_Lead_Id__C = nrlead.LeadId;
        insert lead;
        sys.Nrg_Lead__C = lead.Id;
        insert sys; 
        nq.Nrg_System__C = sys.Id;
        nq.Nrg_Quote_Id__C = lead.NRG_Lead_Id__C;
        insert nq;        
   } 

   
   /*
   public Static soapSforceComSchemasClassAstrumlead.AstrumLead sendToNRG (NRG_Lead__c lead, NRG_System__c sys,NRG_Quote__c nq, List<NRG_Array__C> arrayList  )
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
        al.AstrumleadId = lead.System_Design_Quote__c;
        
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
                
                System.debug('MonthlyPayment**'+le.MonthlyPayment);
                System.debug('MonthlyPaymentInclTax**'+le.MonthlyPaymentInclTax);
                System.debug('Minimum_Down**'+le.Minimum_Down);
                System.debug('FirstYearDollarPerKWH**'+le.FirstYearDollarPerKWH);
                
                //lead.NRG_Lead_Id__C = le.LeadId;
                return le;
            }
            else
            {
                return new soapSforceComSchemasClassAstrumlead.AstrumLead();  
            }   
         } catch(Exception e) {
            System.debug('The exception has been raised is'+e);
            soapSforceComSchemasClassAstrumlead.AstrumLead aler = new soapSforceComSchemasClassAstrumlead.AstrumLead();
            aler.LeadId = 'Error-'+e;
            return aler;
        } 
   
   }
   */
   
}