/* FILE: CPFIntegrationProcessor.cls
 * AUTHOR: Rohit Jain
 * DATE: Mar 27, 2014
 * PURPOSE: Class to Process CPF Calls
 * MODIFICATION HISTORY:
 * // Commented by RJ 05/5/2015
 */
public with sharing class CPFIntegrationProcessor {
	/*
	private static String[] months = new String[] {
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    };

	public CPFIntegrationProcessor() {
		
	}

	/*
	Public String getCPFUserList()
	{
		CPFAPIOAuthHelper cpfOauthHelper = new CPFAPIOAuthHelper();
		String xmlRequest = generateUserListXML(cpfOauthHelper);

		String xmlResponse;
	    try{
	      xmlResponse = cpfOauthHelper.submitWebRequest(xmlRequest,'/admin/v1/user/list');
	    }
	    catch(Exception e)
	    {
	      System.debug(e.getMessage());	      
	    }  
	    return xmlResponse;

	}
	

	Public System_Design_Quote__c sendCPFForSignature(System_Design_Quote__c sdq, String homeOwnerEmail, Boolean isPrepaid)
	{
		CPFAPIOAuthHelper cpfOauthHelper = new CPFAPIOAuthHelper();
		String xmlRequest = generateSendForSignatureXML(cpfOauthHelper,sdq,homeOwnerEmail,isPrepaid);
		System.debug(xmlRequest);

		String xmlResponse;
	    try{
	      xmlResponse = cpfOauthHelper.submitWebRequest(xmlRequest,'/quoting/v1/proposal/sendforsignature');
	      System.debug(xmlResponse);
	      parseSendForSignatureResponse(xmlResponse,sdq);
	    }
	    catch(Exception e)
	    {
	      System.debug(e.getMessage());	      
	    }  
	    return sdq;

	}

	Public System_Design_Quote__c initiateCPFElligibility(System_Design_Quote__c sdq, Boolean resend )
	{
		CPFAPIOAuthHelper cpfOauthHelper = new CPFAPIOAuthHelper();
		String xmlRequest = generateElligibilityInitiateXML(cpfOauthHelper,sdq, resend);

		String xmlResponse;
	    try{
	      xmlResponse = cpfOauthHelper.submitWebRequest(xmlRequest,'/quoting/v1/eligibility/initiate');

	      parseElligibleInitiateResponse(xmlResponse,sdq);
	    }
	    catch(Exception e)
	    {
	      System.debug(e.getMessage());	      
	    }  
	    return sdq;

	}

	Public static System_Design_Quote__c generateCPFDocuments(System_Design_Quote__c sdq, Boolean isPrepaid)
	{
		CPFAPIOAuthHelper cpfOauthHelper = new CPFAPIOAuthHelper();
		String xmlRequest = generateDocumentXML(cpfOauthHelper,sdq,isPrepaid);

		String xmlResponse;
	    try{
	      xmlResponse = cpfOauthHelper.submitWebRequest(xmlRequest,'/quoting/v1/job/generatedocs');

	      parseGenerateDocumentResponse(xmlResponse,sdq,isPrepaid);
	    }
	    catch(Exception e)
	    {
	      System.debug(e.getMessage());	      
	    }  
	    return sdq;

	}

	Public static System_Design_Quote__c getCPFDocuments(System_Design_Quote__c sdq, String proposalId, String ptype)
	{
		CPFAPIOAuthHelper cpfOauthHelper = new CPFAPIOAuthHelper();
		String xmlRequest = generateGetJobXML(cpfOauthHelper,sdq,proposalId);

		String xmlResponse;
	    try{
	      System.debug(xmlRequest);
	      xmlResponse = cpfOauthHelper.submitWebRequest(xmlRequest,'/quoting/v1/job/get');
	      //System.debug('****'+xmlResponse);
	      parseGetJobResponse(xmlResponse,sdq,ptype);
	    }
	    catch(Exception e)
	    {
	      System.debug(e.getMessage());	      
	    }  
	    return sdq;

	}

	/*
	Public String createCPFCustomer(System_Design_Quote__c sdq)
	{
		CPFAPIOAuthHelper cpfOauthHelper = new CPFAPIOAuthHelper();
		CPFAPIOAuthHelper.Customer lead; 

		System_design__c sd = [Select Id,s.Property__r.QAS_Property_County__c, s.Property__r.Property_County__c
                ,s.Property__r.Property_ZIP__c, s.Property__r.Property_State__c,s.Property__r.Property_City__c
                ,s.Property__r.Name, s.Property__c , s.property__r.property_Owner__c,s.system_makeup__c
                ,Total_Projected_Annual_Output_kWh_y__c,Total_System_Size_kW__c,NRG_Projected_Annual_Output_kWh_y__c 
                ,Property__r.Utility_Company__r.Name,  Property__r.Utility_Company_Rate_Code__c             
          From System_Design__c s
         Where id = :sdq.System_Design__c ];        
          
        /*Opportunity opty = [Select Id, (Select o.Contact.Email, o.Contact.FirstName, o.Contact.LastName, o.ContactId ,o.Contact.Phone
                                                        From OpportunityContactRole o 
                                                       Where Role = 'Contract Signer')
                 from Opportunity 
                Where Property__c = :sd.Property__c limit 1];
		

	    Account acct = [Select (Select LastName, FirstName, Email,Phone,Title From Contacts) From Account a Where Id = :sd.property__r.Property_Owner__c];     
	    
	    if(acct != null && acct.Contacts.size() > 0 )
	    {
	      lead = new CPFAPIOAuthHelper.Customer();
	      lead.ExternalCustomer = acct.Contacts[0].Id;
	      lead.CFirstname = acct.Contacts[0].FirstName;
	      lead.CLastname = acct.Contacts[0].LastName;
	      lead.CEmail = acct.Contacts[0].Email;
	      lead.CPhone1 = acct.Contacts[0].Phone;
	      lead.CAddress1 = sd.Property__r.Name;
	      lead.CCity = sd.Property__r.Property_City__c;
	      lead.CState = sd.Property__r.Property_State__c;
	      lead.CZip = ((sd.Property__r.Property_zip__c != null) ? sd.Property__r.Property_zip__c.subString(0,5) : null) ;     
	      lead.CTitle = acct.Contacts[0].Title;
	      lead.CType = 'residential';
	      lead.NewBuild = 'new';
	      lead.UtilityName = sd.Property__r.Utility_Company__r.Name;
	      lead.CurrentRateCode	= sd.Property__r.Utility_Company_Rate_Code__c;     
	    }

	    XmlStreamWriter w = new XmlStreamWriter();
		String xmlRequest = generateCustomerCreationXML(true,w,cpfOauthHelper,lead).getXmlString();

		String xmlResponse;
	    try{
	      xmlResponse = cpfOauthHelper.submitWebRequest(xmlRequest,'/quoting/v1/customer/create');
	    }
	    catch(Exception e)
	    {
	      System.debug(e.getMessage());	      
	    }  
	    String customerId = parseCustomerResponse(xmlResponse);
	    return xmlResponse;

	}
	

	@Future(callout=true) 
	Public static void createCPFProposal(ID SdqId)	
	{
		System_Design_Quote__c sdq = [Select  id,System_Design__c, Utility_Territory__c, CPF_Quick_Template_Id__c , Name, CPF_Annual_Increase__c , CPF_Down_Payment__c , CPF_Price_Per_Watt__c,  CPF_Prepaid_Template_Id__c                                   
                                    from System_Design_Quote__c 
                                   Where Id = :sdqId];

		CPFAPIOAuthHelper cpfOauthHelper = new CPFAPIOAuthHelper();
		CPFAPIOAuthHelper.Customer lead; 
		CPFAPIOAuthHelper.Proposal proposal; 
		
		System_design__c sd = [Select Id,s.Property__r.QAS_Property_County__c, s.Property__r.Property_County__c
                ,s.Property__r.Property_ZIP__c, s.Property__r.Property_State__c,s.Property__r.Property_City__c
                ,s.Property__r.Name, s.Property__c , s.property__r.property_Owner__c,s.system_makeup__c
                ,Total_Projected_Annual_Output_kWh_y__c,Total_System_Size_kW__c,NRG_Projected_Annual_Output_kWh_y__c 
                ,Property__r.Utility_Company__r.Name,  Property__r.Utility_Company_Rate_Code__c           
                ,Property__r.Utility_Company__r.CPF_Rate_Code_Id__c
          From System_Design__c s
         Where id = :sdq.System_Design__c ];        
        
        List<Utility_Service__c> services = [Select Monthly_Electric_Consumption_KWH_Apr__c,Monthly_Electric_Consumption_KWH_Aug__c,Monthly_Electric_Consumption_KWH_Dec__c
        										   ,Monthly_Electric_Consumption_KWH_Feb__c,Monthly_Electric_Consumption_KWH_Jan__c,Monthly_Electric_Consumption_KWH_Jul__c
        										   ,Monthly_Electric_Consumption_KWH_Jun__c,Monthly_Electric_Consumption_KWH_Mar__c,Monthly_Electric_Consumption_KWH_May__c
        										   ,Monthly_Electric_Consumption_KWH_Nov__c,Monthly_Electric_Consumption_KWH_Oct__c,Monthly_Electric_Consumption_KWH_Sep__c
        										   ,Monthly_Electric_Bill_Apr__c,Monthly_Electric_Bill_Aug__c,Monthly_Electric_Bill_Dec__c,Monthly_Electric_Bill_Feb__c
        										   ,Monthly_Electric_Bill_Jan__c,Monthly_Electric_Bill_Jul__c,Monthly_Electric_Bill_Jun__c,Monthly_Electric_Bill_Mar__c
        										   ,Monthly_Electric_Bill_May__c,Monthly_Electric_Bill_Nov__c,Monthly_Electric_Bill_Oct__c,Monthly_Electric_Bill_Sep__c
        										   ,Average_Monthly_Bill__c , Is_monthly_bill__c , Is_monthly_kwh__c, Annual_Electricity_Consumption_kWh_frm__c,Estimated_Average_Monthly_Bill__c        										   
        									   From Utility_Service__c Where Property__c = : sd.Property__c ];   

        List<Utility_Territory_Rate_Codes__c> utrs;
        if(sdq.Utility_Territory__c != null && sdq.Utility_Territory__c != '')
        {
        	utrs = [Select CPF_Rate_Code_Id__c 
        	         From Utility_Territory_Rate_Codes__c 
				   Where Utility_Company__c = :sd.Property__r.Utility_Company__c 
				   	 AND Territory__c = :sdq.Utility_Territory__c];
        }      
	    
	    Account acct = [Select (Select LastName, FirstName, Email,Phone,Title From Contacts) From Account a Where Id = :sd.property__r.Property_Owner__c];     
	    
	    if(acct != null && acct.Contacts.size() > 0 )
	    {
	      lead = new CPFAPIOAuthHelper.Customer();
	      proposal = new  CPFAPIOAuthHelper.Proposal();
	     
	      lead.ExternalCustomer = acct.Contacts[0].Id;
	      lead.CFirstname = acct.Contacts[0].FirstName;
	      lead.CLastname = acct.Contacts[0].LastName;
	      lead.CEmail = acct.Contacts[0].Email;
	      lead.CPhone1 = acct.Contacts[0].Phone;
	      if(acct.Contacts.size() > 1)
	      {
            lead.CSecondaryFirstname = acct.Contacts[1].FirstName;
            lead.CSecondaryLastname = acct.Contacts[1].LastName;
            lead.CSecondaryPhone = acct.Contacts[1].Phone;
            lead.CSecondaryEmail = acct.Contacts[1].Email;           
	      }


	      lead.CAddress1 = sd.Property__r.Name;
	      lead.CCity = sd.Property__r.Property_City__c;
	      lead.CState = sd.Property__r.Property_State__c;
	      lead.CZip = ((sd.Property__r.Property_zip__c != null) ? sd.Property__r.Property_zip__c.subString(0,5) : null) ; 
	      lead.CTitle = acct.Contacts[0].Title;
	      lead.CType = 'residential';
	      lead.NewBuild = '0';
	      lead.UtilityName = sd.Property__r.Utility_Company__r.Name;
	      Lead.QuickTemplateId = (sdq.CPF_Quick_Template_Id__c != null ? sdq.CPF_Quick_Template_Id__c : cpfOauthHelper.templateId );
	      Lead.PrepaidQuickTemplateId = (sdq.CPF_Prepaid_Template_Id__c != null ? sdq.CPF_Prepaid_Template_Id__c : cpfOauthHelper.prepaidTemplateId );
	      //lead.CurrentRateCode	= sd.Property__r.Utility_Company_Rate_Code__c;     
	      if(utrs != null && utrs.size() > 0)
	      {
	      	lead.CurrentRateScheduleId	= utrs[0].CPF_Rate_Code_Id__c;  
	      	lead.ProposedRateScheduleId	= utrs[0].CPF_Rate_Code_Id__c;  
	      }	
	      else
	      {
	      	lead.CurrentRateScheduleId	= sd.Property__r.Utility_Company__r.CPF_Rate_Code_Id__c;  
	      	lead.ProposedRateScheduleId	= sd.Property__r.Utility_Company__r.CPF_Rate_Code_Id__c;  	
	      }

	      proposal.AnnualIncrease = sdq.CPF_Annual_Increase__c;
	      proposal.DownPayment = sdq.CPF_Down_Payment__c;
	      proposal.ExternalProposalId = sdq.Id;
	      proposal.Name = sdq.Name;
	      proposal.PricePerWatt = (sdq.CPF_Price_Per_Watt__c != null ? String.valueOf(sdq.CPF_Price_Per_Watt__c) : null );

	      
	      
	      //lead.AverageElectricityBill = sd.Property__r.Average_Electricity_Bill__c  ; 
	    }

	    if (lead != null )
	    {
	      if(Lead.CAddress1 == null || Lead.CCity == null || Lead.CState == null || lead.cZip == null || Lead.CLastname == null)
	      {
	        sdq.put('CPF_Input_Error_Message__c' ,'One of the required fields is missing - Last Name, Street, City, State or Zip.');	       
	        update sdq;			  
			  return;
	      }  
	      /*if(Lead.AverageElectricityBill == null)
	      {
	        sdq.put('CPF_Input_Error_Message__c' ,'Average Electricity Bill is required. Please update it in Property record.');	       
	        return sdq;    
	      } 
	       
	      if(Lead.UtilityName == null)
	      {
	        sdq.put('CPF_Input_Error_Message__c' ,'Utility Company is required. Please update it in Property record.');	       
	       update sdq;			  
			  return;    
	      } 
	      if(Lead.CurrentRateScheduleId == null)
	      {
	        sdq.put('CPF_Input_Error_Message__c' ,'CPF Utility Rate Code not found. Please check the CPF Rate Code Mapping.');	       
	        update sdq;			  
			  return;   
	      }   
	    }
	    else
	    {
	      sdq.put('CPF_Input_Error_Message__c' , 'Please check if Property Account is associated with Contact.');	      
	      update sdq;			  
			  return;     
	    }

	    if(services != null && services.size() > 0)
	    {
	    	Utility_Service__c us = services[0];
	    	if(	us.Is_Monthly_Bill__c && us.Is_Monthly_KWH__c )
	    	{
	    		Lead.JanElectricityBill = us.Monthly_Electric_Bill_Jan__c;
		        Lead.FebElectricityBill= us.Monthly_Electric_Bill_Feb__c;
				Lead.MarElectricityBill= us.Monthly_Electric_Bill_Mar__c;
				Lead.AprElectricityBill= us.Monthly_Electric_Bill_Apr__c;
				Lead.MayElectricityBill= us.Monthly_Electric_Bill_May__c;
				Lead.JunElectricityBill= us.Monthly_Electric_Bill_Jun__c;
				Lead.JulElectricityBill= us.Monthly_Electric_Bill_Jul__c;
				Lead.AugElectricityBill= us.Monthly_Electric_Bill_Aug__c;
				Lead.SepElectricityBill= us.Monthly_Electric_Bill_Sep__c;
				Lead.OctElectricityBill= us.Monthly_Electric_Bill_Oct__c;
				Lead.NovElectricityBill= us.Monthly_Electric_Bill_Nov__c;
				Lead.DecElectricityBill= us.Monthly_Electric_Bill_Dec__c;
				Lead.JanElectricityKWH = us.Monthly_Electric_Consumption_KWH_Jan__c;
				Lead.FebElectricityKWH= us.Monthly_Electric_Consumption_KWH_Feb__c;
				Lead.MarElectricityKWH= us.Monthly_Electric_Consumption_KWH_Mar__c;
				Lead.AprElectricityKWH= us.Monthly_Electric_Consumption_KWH_Apr__c;
				Lead.MayElectricityKWH= us.Monthly_Electric_Consumption_KWH_May__c;
				Lead.JunElectricityKWH= us.Monthly_Electric_Consumption_KWH_Jun__c;
				Lead.JulElectricityKWH= us.Monthly_Electric_Consumption_KWH_Jul__c;
				Lead.AugElectricityKWH= us.Monthly_Electric_Consumption_KWH_Aug__c;
				Lead.SepElectricityKWH= us.Monthly_Electric_Consumption_KWH_Sep__c;
				Lead.OctElectricityKWH= us.Monthly_Electric_Consumption_KWH_Oct__c;
				Lead.NovElectricityKWH= us.Monthly_Electric_Consumption_KWH_Nov__c;
				Lead.DecElectricityKWH= us.Monthly_Electric_Consumption_KWH_Dec__c;
				Lead.monthlyKWH = true;
				Lead.monthlyBill = true;
				Lead.averageBill = false;
	    	}
	    	else if ( us.Is_Monthly_Bill__c && ! us.Is_Monthly_KWH__c )
	    	{
	    		if(us.Annual_Electricity_Consumption_kWh_frm__c > 0)
	    		{
	    			Lead.JanElectricityBill = us.Monthly_Electric_Bill_Jan__c;
			        Lead.FebElectricityBill= us.Monthly_Electric_Bill_Feb__c;
					Lead.MarElectricityBill= us.Monthly_Electric_Bill_Mar__c;
					Lead.AprElectricityBill= us.Monthly_Electric_Bill_Apr__c;
					Lead.MayElectricityBill= us.Monthly_Electric_Bill_May__c;
					Lead.JunElectricityBill= us.Monthly_Electric_Bill_Jun__c;
					Lead.JulElectricityBill= us.Monthly_Electric_Bill_Jul__c;
					Lead.AugElectricityBill= us.Monthly_Electric_Bill_Aug__c;
					Lead.SepElectricityBill= us.Monthly_Electric_Bill_Sep__c;
					Lead.OctElectricityBill= us.Monthly_Electric_Bill_Oct__c;
					Lead.NovElectricityBill= us.Monthly_Electric_Bill_Nov__c;
					Lead.DecElectricityBill= us.Monthly_Electric_Bill_Dec__c;
					Lead.JanElectricityKWH = us.Annual_Electricity_Consumption_kWh_frm__c/12;
					Lead.FebElectricityKWH= us.Annual_Electricity_Consumption_kWh_frm__c/12;
					Lead.MarElectricityKWH= us.Annual_Electricity_Consumption_kWh_frm__c/12;
					Lead.AprElectricityKWH= us.Annual_Electricity_Consumption_kWh_frm__c/12;
					Lead.MayElectricityKWH= us.Annual_Electricity_Consumption_kWh_frm__c/12;
					Lead.JunElectricityKWH= us.Annual_Electricity_Consumption_kWh_frm__c/12;
					Lead.JulElectricityKWH= us.Annual_Electricity_Consumption_kWh_frm__c/12;
					Lead.AugElectricityKWH= us.Annual_Electricity_Consumption_kWh_frm__c/12;
					Lead.SepElectricityKWH= us.Annual_Electricity_Consumption_kWh_frm__c/12;
					Lead.OctElectricityKWH= us.Annual_Electricity_Consumption_kWh_frm__c/12;
					Lead.NovElectricityKWH= us.Annual_Electricity_Consumption_kWh_frm__c/12;
					Lead.DecElectricityKWH= us.Annual_Electricity_Consumption_kWh_frm__c/12;
					Lead.monthlyKWH = true;
					Lead.monthlyBill = true;
					Lead.averageBill = false;

	    		}
	    		else 
	    		{
	    			Lead.AverageElectricityBill = us.Average_Monthly_Bill__c;
	    			Lead.averageBill = true;
	    		}	    		
	    	}
	    	else if (!us.Is_Monthly_Bill__c && us.Is_Monthly_KWH__c)
	    	{
	    		if(us.Estimated_Average_Monthly_Bill__c > 0)
	    		{	    
					Lead.JanElectricityBill = us.Estimated_Average_Monthly_Bill__c;
			        Lead.FebElectricityBill= us.Estimated_Average_Monthly_Bill__c;
					Lead.MarElectricityBill= us.Estimated_Average_Monthly_Bill__c;
					Lead.AprElectricityBill= us.Estimated_Average_Monthly_Bill__c;
					Lead.MayElectricityBill= us.Estimated_Average_Monthly_Bill__c;
					Lead.JunElectricityBill= us.Estimated_Average_Monthly_Bill__c;
					Lead.JulElectricityBill= us.Estimated_Average_Monthly_Bill__c;
					Lead.AugElectricityBill= us.Estimated_Average_Monthly_Bill__c;
					Lead.SepElectricityBill= us.Estimated_Average_Monthly_Bill__c;
					Lead.OctElectricityBill= us.Estimated_Average_Monthly_Bill__c;
					Lead.NovElectricityBill= us.Estimated_Average_Monthly_Bill__c;
					Lead.DecElectricityBill= us.Estimated_Average_Monthly_Bill__c;
					Lead.JanElectricityKWH = us.Monthly_Electric_Consumption_KWH_Jan__c;
					Lead.FebElectricityKWH= us.Monthly_Electric_Consumption_KWH_Feb__c;
					Lead.MarElectricityKWH= us.Monthly_Electric_Consumption_KWH_Mar__c;
					Lead.AprElectricityKWH= us.Monthly_Electric_Consumption_KWH_Apr__c;
					Lead.MayElectricityKWH= us.Monthly_Electric_Consumption_KWH_May__c;
					Lead.JunElectricityKWH= us.Monthly_Electric_Consumption_KWH_Jun__c;
					Lead.JulElectricityKWH= us.Monthly_Electric_Consumption_KWH_Jul__c;
					Lead.AugElectricityKWH= us.Monthly_Electric_Consumption_KWH_Aug__c;
					Lead.SepElectricityKWH= us.Monthly_Electric_Consumption_KWH_Sep__c;
					Lead.OctElectricityKWH= us.Monthly_Electric_Consumption_KWH_Oct__c;
					Lead.NovElectricityKWH= us.Monthly_Electric_Consumption_KWH_Nov__c;
					Lead.DecElectricityKWH= us.Monthly_Electric_Consumption_KWH_Dec__c;
					Lead.monthlyKWH = true;
					Lead.monthlyBill = true;	
					Lead.averageBill = false;
	    		}
	    		else
	    		{
	    			Lead.JanElectricityBill= 0;
			        Lead.FebElectricityBill= 0;
					Lead.MarElectricityBill= 0;
					Lead.AprElectricityBill= 0;
					Lead.MayElectricityBill= 0;
					Lead.JunElectricityBill= 0;
					Lead.JulElectricityBill= 0;
					Lead.AugElectricityBill= 0;
					Lead.SepElectricityBill= 0;
					Lead.OctElectricityBill= 0;
					Lead.NovElectricityBill= 0;
					Lead.DecElectricityBill= 0;
					Lead.JanElectricityKWH = us.Monthly_Electric_Consumption_KWH_Jan__c;
					Lead.FebElectricityKWH= us.Monthly_Electric_Consumption_KWH_Feb__c;
					Lead.MarElectricityKWH= us.Monthly_Electric_Consumption_KWH_Mar__c;
					Lead.AprElectricityKWH= us.Monthly_Electric_Consumption_KWH_Apr__c;
					Lead.MayElectricityKWH= us.Monthly_Electric_Consumption_KWH_May__c;
					Lead.JunElectricityKWH= us.Monthly_Electric_Consumption_KWH_Jun__c;
					Lead.JulElectricityKWH= us.Monthly_Electric_Consumption_KWH_Jul__c;
					Lead.AugElectricityKWH= us.Monthly_Electric_Consumption_KWH_Aug__c;
					Lead.SepElectricityKWH= us.Monthly_Electric_Consumption_KWH_Sep__c;
					Lead.OctElectricityKWH= us.Monthly_Electric_Consumption_KWH_Oct__c;
					Lead.NovElectricityKWH= us.Monthly_Electric_Consumption_KWH_Nov__c;
					Lead.DecElectricityKWH= us.Monthly_Electric_Consumption_KWH_Dec__c;
					Lead.monthlyKWH = true;
					Lead.monthlyBill = true;	
					Lead.averageBill = false;

	    		}
	    	}
	    	else if (!us.Is_Monthly_Bill__c && !us.Is_Monthly_KWH__c)
	    	{
	    		if(us.Estimated_Average_Monthly_Bill__c > 0)
	    		{
	    			Lead.AverageElectricityBill = us.Estimated_Average_Monthly_Bill__c;
	    			Lead.averageBill = true;
	    		}
	    		else if(us.Annual_Electricity_Consumption_kWh_frm__c > 0)
	    		{
	    			Lead.JanElectricityBill= 0;
			        Lead.FebElectricityBill= 0;
					Lead.MarElectricityBill= 0;
					Lead.AprElectricityBill= 0;
					Lead.MayElectricityBill= 0;
					Lead.JunElectricityBill= 0;
					Lead.JulElectricityBill= 0;
					Lead.AugElectricityBill= 0;
					Lead.SepElectricityBill= 0;
					Lead.OctElectricityBill= 0;
					Lead.NovElectricityBill= 0;
					Lead.DecElectricityBill= 0;
					Lead.JanElectricityKWH = us.Annual_Electricity_Consumption_kWh_frm__c/12;
					Lead.FebElectricityKWH= us.Annual_Electricity_Consumption_kWh_frm__c/12;
					Lead.MarElectricityKWH= us.Annual_Electricity_Consumption_kWh_frm__c/12;
					Lead.AprElectricityKWH= us.Annual_Electricity_Consumption_kWh_frm__c/12;
					Lead.MayElectricityKWH= us.Annual_Electricity_Consumption_kWh_frm__c/12;
					Lead.JunElectricityKWH= us.Annual_Electricity_Consumption_kWh_frm__c/12;
					Lead.JulElectricityKWH= us.Annual_Electricity_Consumption_kWh_frm__c/12;
					Lead.AugElectricityKWH= us.Annual_Electricity_Consumption_kWh_frm__c/12;
					Lead.SepElectricityKWH= us.Annual_Electricity_Consumption_kWh_frm__c/12;
					Lead.OctElectricityKWH= us.Annual_Electricity_Consumption_kWh_frm__c/12;
					Lead.NovElectricityKWH= us.Annual_Electricity_Consumption_kWh_frm__c/12;
					Lead.DecElectricityKWH= us.Annual_Electricity_Consumption_kWh_frm__c/12;
					Lead.monthlyKWH = true;
					Lead.monthlyBill = true;
					Lead.averageBill = false;

	    		}
	    		else
	    		{
	    			sdq.put('CPF_Input_Error_Message__c' , 'Utility Energy details not found in Utility Service Record.');	      
	        		update sdq;			  
			  		return;  
	    		}
	    	}


	    }
	    else
	    {
	    	sdq.put('CPF_Input_Error_Message__c' , 'Utility Service with Monthly or Average consumption not denied for the Property.');	      
	        update sdq;			  
			return; 	
	    }

	    List<CPF_Equipment_Mapping__C> products = [Select System_Design_Product__C, CPF_Id__c 
	    											 from CPF_Equipment_Mapping__c 
	    											Where System_Design_Product__C != null ];
		Map<Id,String> productmapping = new Map<Id,String>();
		for(CPF_Equipment_Mapping__C product : products)
		{
			productmapping.put(product.System_Design_Product__C, product.CPF_Id__c);             
		}

	    List<System_Design_Item__c> inverterList = [Select System_Design_Product__c ,System_Design_Array__c,Quantity__c
                                                   From System_Design_Item__c s
                                                  Where s.System_Design_Array__r.System_Design__c = :sd.id  
                                                    and s.Quantity__c > 0 and RecordType.Name = 'Inverter' order by System_Design_Array__c  ];

      
        Map<Id,String> arrayIndexMap = new Map<Id,String>();
        
       
        for(System_Design_Item__c sdiinv : inverterList)
        {
        	arrayIndexMap.put(sdiinv.System_Design_Array__c, productmapping.get(sdiinv.System_Design_Product__c));	
        	/*CPFAPIOAuthHelper.Inverter inverter = new CPFAPIOAuthHelper.Inverter();
        	inverter.InverterId = productmapping.get(sdiinv.System_Design_Product__c);
        	inverter.InverterQuantity = String.valueOf(sdiinv.Quantity__c);
        	inverter.Index = String.ValueOf(index);
        	index += 1;
        	inverters.add(inverter);
        }

        List<CPFAPIOAuthHelper.PvArray> pvarrays = new List<CPFAPIOAuthHelper.PvArray>();
        List<CPFAPIOAuthHelper.Inverter> inverters = new List<CPFAPIOAuthHelper.Inverter>();
        integer index = 1;

        List<System_Design_Item__c> sysitems = [Select s.System_Design_Array__c,s.System_Design_Product__c,s.Tilt_Text__c,s.Quantity__c
        											  ,Rated_Output_kW__c,s.Azimuth_Text__c, s.Shading_Text__C , CPF_Azimuth__c 
                                     		      From System_Design_Item__c s
                                    			 Where s.System_Design_Array__r.System_Design__c = :sd.id  
                                    			   and s.Quantity__c > 0 
                                    			   and RecordType.Name = 'Panel' ];
      
		for (System_Design_Item__c sysitem : sysitems)
		{
			CPFAPIOAuthHelper.PvArray pvarray = new CPFAPIOAuthHelper.PvArray();    

			if( sysitem.Azimuth_Text__c == null || sysitem.Tilt_Text__c == null || sysitem.Shading_Text__C == null )
			{
			  sdq.put('CPF_Input_Error_Message__c' , 'Missing one of the Required fields in Array - Azimuth or Shading or Tilt.');			  
			  update sdq;			  
			  return;
			}
			else
			{
			  pvarray.Azimuth = sysitem.Azimuth_Text__c != '' ? String.valueOf(sysitem.CPF_Azimuth__c) : null;
			  pvarray.Tilt = sysitem.Tilt_Text__c != '' ? sysitem.Tilt_Text__c : null ; 
			  pvarray.Shade = sysitem.Shading_Text__c != '' ? sysitem.Shading_Text__c : null;
			}    
			
			pvarray.InverterIndex = String.ValueOf(index);			
			pvarray.ModuleId = productmapping.get(sysitem.System_Design_Product__c);  //a1pA0000000EqJN
			pvarray.ModuleQuantity = String.ValueOf(sysitem.Quantity__c); 
			if(pvarray.ModuleId == null || pvarray.ModuleId == '')
			{
			  sdq.put('CPF_Input_Error_Message__c' ,'Missing Module Information. Please check the CPF Product Mappings.');			  
			  update sdq;			  
			  return;
			}		
			
			pvarrays.add(pvarray);	

			CPFAPIOAuthHelper.Inverter inverter = new CPFAPIOAuthHelper.Inverter();
        	inverter.InverterId = arrayIndexMap.get(sysitem.System_Design_Array__c);
        	if(inverter.InverterId == null || inverter.InverterId == '')
			{
			  sdq.put('CPF_Input_Error_Message__c' ,'Missing Inverter Information. Please check the CPF Product Mappings.');
			  update sdq;			  
			  return;
			}	

        	inverter.InverterQuantity = String.ValueOf(sysitem.Quantity__c);
        	inverter.Index = String.ValueOf(index);
        	index += 1;
        	inverters.add(inverter);        

        	System.debug('**Insert Array22 ' + pvarray);   
		} 

		String xmlRequest = generateCreateProposalXML(cpfOauthHelper,lead,proposal,pvarrays,inverters,false);		
		String xmlResponse;
	    try{	      
	      xmlResponse = cpfOauthHelper.submitWebRequest(xmlRequest,'/quoting/v1/job/createqualified');
	      System.debug(xmlResponse);
	    }
	    catch(Exception e)
	    {
	      System.debug(e.getMessage());	      
	    }  
	    //parseCreateJobResponse(xmlResponse,sdq);
	    parseJobResponse(xmlResponse,sdq,false);
	     
	    
	    if(sdq.CPF_API_status__c == 'success')
	    {
	    	sdq = generateCPFDocuments(sdq,false);
	    }


	    xmlRequest = generateCreateProposalXML(cpfOauthHelper,lead,proposal,pvarrays,inverters,true);				
	    try{	      
	      xmlResponse = cpfOauthHelper.submitWebRequest(xmlRequest,'/quoting/v1/job/createqualified');
	      System.debug(xmlResponse);
	    }
	    catch(Exception e)
	    {
	      System.debug(e.getMessage());	      
	    }  
	    //parseCreateJobResponse(xmlResponse,sdq);
	    parseJobResponse(xmlResponse,sdq,true);
	     
	    
	    if(sdq.CPF_API_status__c == 'success')
	    {
	    	sdq = generateCPFDocuments(sdq,true);
	    }
	    
		
	    update sdq;

	}

	public static double getValue(Dom.Xmlnode theParentNode, String elementName, String namespace) {
        Dom.xmlnode theNode = theParentNode.getChildElement(elementName, namespace);        
        return (theNode.getText() != null && theNode.getText().trim() != '' ? Double.valueOf(theNode.getText()) : null) ;       
    }
    
	Public Static System_Design_Quote__c parseJobResponse(String xmlResponse, System_Design_Quote__c sdq, Boolean isPrepaid)
	{
		Dom.Document doc = new Dom.Document();
        doc.load(xmlResponse);
        
        Dom.Xmlnode root = doc.getRootElement();  
        System.debug(root);      
        String  status = root.getChildElement('Status', null).getText();
                
      	System.debug(status);
      	
      	sdq.put('CPF_API_status__c', status);
      	if(status == 'success')
      	{
      		
      		sdq.put('CPF_API_Message__c', root.getChildElement('Message', null).getText());
      		//sdq.put('CPF_Customer_Id__c' , root.getChildElement('CustomerId', null).getText()); 
      		Dom.Xmlnode customerNode = root.getChildElement('Job', null).getChildElement('Customer', null);
  			sdq.put('CPF_Customer_Id__c' , customerNode.getChildElement('CustomerId', null).getText()); 
  			Dom.Xmlnode pvQuoteNode = root.getChildElement('Job', null).getChildElement('Proposal', null).getChildElement('Quotes', null).getChildElement('PVQuote', null);
  			sdq.put('CPF_Year_One_Production__c' , getValue(pvQuoteNode,'YearOneProduction',null)); 
  			Dom.Xmlnode finMethodNode = root.getChildElement('Job', null).getChildElement('Proposal', null).getChildElement('FinancingMethods', null).getChildElement('FinancingMethod', null);
  		
  			if(!isPrepaid)
      		{
      			sdq.put('CPF_Proposal_Id__c' , root.getChildElement('ProposalId', null).getText()); 
      			sdq.put('CPF_Input_Error_Message__c', '');
      		
      			
      			sdq.put('CPF_Product_Name__c' , finMethodNode.getChildElement('ProductName', null).getText()); 
      			sdq.put('CPF_Lease_Term__c' , getValue(finMethodNode,'Term',null)); 
      			sdq.put('CPF_Monthly_Payment__c' , getValue(finMethodNode,'MonthlyPayment',null)); 
      			sdq.put('CPF_Down_Payment__c' , getValue(finMethodNode,'DownPayment',null)); 
      			sdq.put('CPF_Annual_Increase__c' , getValue(finMethodNode,'AnnualIncrease',null)); 
      			sdq.put('CPF_Price_Per_Watt__c' , getValue(finMethodNode,'PricePerWatt',null)); 
	      		if(finMethodNode.getChildElement('YearZeroCumulativeCashFlow',null) != null)
	      		{
	      			sdq.put('CPF_Prepaid__c' , getValue(finMethodNode,'YearZeroCumulativeCashFlow',null)); 	
	      		}  
	      	}
	      	else
	      	{
	      		sdq.put('CPF_Prepaid_Proposal_Id__c' , root.getChildElement('ProposalId', null).getText()); 
      			sdq.put('CPF_Input_Error_Message__c', '');
      			sdq.put('CPF_Prepaid_Product_Name__c' , finMethodNode.getChildElement('ProductName', null).getText()); 
	      		if(finMethodNode.getChildElement('YearZeroCumulativeCashFlow',null) != null)
	      		{
	      			sdq.put('CPF_Prepaid__c' , getValue(finMethodNode,'YearZeroCumulativeCashFlow',null)); 	
	      		}  
	      	}	
      		String message = '';
      		Boolean first = true;

      		System.debug('** '+finMethodNode.getChildElement('Errors', null).getChildren());

      		for(Dom.Xmlnode mmode : finMethodNode.getChildElement('Errors', null).getChildren())
      		{
      			if(mmode.getName() == 'Error')
      			{
	      			if (first)
	      			{
	      				//System.debug('** mmode '+mmode);
	      				message = mmode.getChildElement('ErrorMessage', null).getText();		
	      				first = false;
	      			}
	      			else{
	      				//System.debug('** mmode '+mmode);
	      				message = message + '\n'+ mmode.getChildElement('ErrorMessage', null).getText();
	      			}	
      			}	
      		}    	
      		if(!isPrepaid)
      		{
      			sdq.put('CPF_Product_Disqual_Reasons__c', message);	
      		}
      		else
      		{
      			sdq.put('CPF_Prepaid_Disq_Reasons__c', message);		
      		}	
      		
      	}
      	else
      	{
      		String message = '';
      		Boolean first = true;
      		if(root.getChildElement('Messages', null) != null)
      		{
	      		for(Dom.Xmlnode mmode : root.getChildElement('Messages', null).getChildren())
	      		{
	      			if (first)
	      			{
	      				message = mmode.getText();		
	      				first = false;
	      			}
	      			else{
	      				message = message + '\n'+ mmode.getText();
	      			}	
	      				
	      		}
	      	}
	      	else if(root.getChildElement('Message', null) != null)	
	      	{
	      		message = 	root.getChildElement('Message', null).getText();
	      	}
      		sdq.put('CPF_API_Message__c', message);
      		sdq.put('CPF_Input_Error_Message__c', '');

      	}
        
        return sdq;

	}

	Public Static System_Design_Quote__c parseGetJobResponse(String xmlResponse, System_Design_Quote__c sdq, String ptype)
	{
		Dom.Document doc = new Dom.Document();
		List<Attachment> proposalDocuments = new List<Attachment>();
		String acctName = sdq.System_Design__r.Property__r.Property_Owner__r.Name;
        doc.load(xmlResponse);
        
        Dom.Xmlnode root = doc.getRootElement();  
        //System.debug(root);      
        String  status = root.getChildElement('Status', null).getText();
                
      	System.debug('$$'+status);
      	
      	sdq.put('CPF_API_status__c', status);
      	if(status == 'success')
      	{
      		Dom.Xmlnode docNode = root.getChildElement('Proposal', null).getChildElement('ProposalDocuments', null);      			
      		//System.debug(docNode.getChildElement('ProposalDocument', null).getChildElement('Name', null).getText());
      		for(Dom.Xmlnode prodoc : docNode.getChildren())
      		{
      			if(prodoc.getName() == 'ProposalDocument'){
	      			try{
	      				System.debug(prodoc.getChildElement('Name', null).getText()); 
	      				Attachment proposalDoc = new Attachment();     				
	      				proposalDoc.ParentId = sdq.Id;
	      				proposalDoc.Name = 'CPF '+acctName+' '+ptype +' '+prodoc.getChildElement('Name', null).getText();
	      				proposalDoc.Body = EncodingUtil.base64Decode(prodoc.getChildElement('Bytes', null).getText());
	      				proposalDoc.ContentType = 'application/pdf';	      				
	      				proposalDocuments.add(proposalDoc);

	      			}
	      			catch(Exception e)
	      			{
	      				System.debug(e.getMessage());
	      			}   
	      		}   			
      		}
      		if(proposalDocuments.size() > 0)
      		{
      			insert proposalDocuments;
      		}	      	
      		
      	}
      	else
      	{
      		String message = '';
      		Boolean first = true;
      		if(root.getChildElement('Messages', null) != null)
      		{
	      		for(Dom.Xmlnode mmode : root.getChildElement('Messages', null).getChildren())
	      		{
	      			if (first)
	      			{
	      				message = mmode.getText();		
	      				first = false;
	      			}
	      			else{
	      				message = message + '\n'+ mmode.getText();
	      			}	
	      				
	      		}
	      	}
	      	else if(root.getChildElement('Message', null) != null)	
	      	{
	      		message = 	root.getChildElement('Message', null).getText();
	      	}
      		sdq.put('CPF_API_Message__c', message);
      		sdq.put('CPF_Input_Error_Message__c', '');

      	}
        
        return sdq;

	}

	Public System_Design_Quote__c parseElligibleInitiateResponse(String xmlResponse, System_Design_Quote__c sdq)
	{
		Dom.Document doc = new Dom.Document();
        doc.load(xmlResponse);
        
        Dom.Xmlnode root = doc.getRootElement();  
        System.debug(root);      
        String  status = root.getChildElement('Status', null).getText();
                
      	System.debug(status);
      	
      	//sdq.put('CPF_API_status__c', status);
      	if(status == 'success')
      	{
      		sdq.put('CPF_Eligibility_Initiate__c', status);      		
      		sdq.put('CPF_Eligibility_Initiate_Message__c', root.getChildElement('Message', null).getText());
      	}
      	else
      	{
      		String message = '';
      		Boolean first = true;
      		if(root.getChildElement('Messages', null) != null)
      		{
	      		for(Dom.Xmlnode mmode : root.getChildElement('Messages', null).getChildren())
	      		{
	      			if (first)
	      			{
	      				message = mmode.getText();		
	      				first = false;
	      			}
	      			else{
	      				message = message + '\n'+ mmode.getText();
	      			}	
	      				
	      		}
	      	}
	      	else
	      	{
	      		message = root.getChildElement('Message', null).getText();
	      	}	      		
      		sdq.put('CPF_Eligibility_Initiate__c', status);      		
      		sdq.put('CPF_Eligibility_Initiate_Message__c', message);

      	}
        
        return sdq;

	}

	Public System_Design_Quote__c parseSendForSignatureResponse(String xmlResponse, System_Design_Quote__c sdq)
	{
		Dom.Document doc = new Dom.Document();
        doc.load(xmlResponse);
        
        Dom.Xmlnode root = doc.getRootElement();  
        System.debug(root);      
        String  status = root.getChildElement('Status', null).getText();
                
      	System.debug(status);
      	
      	//sdq.put('CPF_API_status__c', status);
      	if(status == 'success')
      	{
      		sdq.put('CPF_Sent_For_Signature__c', status);      		
      		sdq.put('CPF_Sent_For_Signature_Message__c', root.getChildElement('Message', null).getText());
      	}
      	else
      	{
      		String message = '';
      		Boolean first = true;
      		if(root.getChildElement('Messages', null) != null)
      		{
	      		for(Dom.Xmlnode mmode : root.getChildElement('Messages', null).getChildren())
	      		{
	      			if (first)
	      			{
	      				message = mmode.getText();		
	      				first = false;
	      			}
	      			else{
	      				message = message + '\n'+ mmode.getText();
	      			}	
	      				
	      		}
	      	}
	      	else
	      	{
	      		message = root.getChildElement('Message', null).getText();
	      	}	      		
      		sdq.put('CPF_Sent_For_Signature__c', status);      		
      		sdq.put('CPF_Sent_For_Signature_Message__c', message);

      	}
        
        return sdq;

	}

	Public Static System_Design_Quote__c parseGenerateDocumentResponse(String xmlResponse, System_Design_Quote__c sdq, Boolean isPrepaid)
	{
		System.debug(xmlResponse);
		Dom.Document doc = new Dom.Document();
        doc.load(xmlResponse);
        
        Dom.Xmlnode root = doc.getRootElement();  
        System.debug(root);      
        String  status = root.getChildElement('Status', null).getText();
                
      	System.debug(status);
      	
      	sdq.put('CPF_API_status__c', status);
      	if(status == 'success')
      	{
      		if(!isPrepaid)
      		{
	      		sdq.put('CPF_Generate_Document_Initiate__c', status);      		
	      		sdq.put('CPF_Generate_Document_Message__c', root.getChildElement('Message', null).getText());
	      	}
	      	else
	      	{
	      		sdq.put('CPF_Prepaid_Generate_Document_Initiate__c', status);      		
	      		sdq.put('CPF_Prepaid_Generate_Document_Message__c', root.getChildElement('Message', null).getText());	
	      	}
      	}
      	else
      	{
      		String message = '';
      		Boolean first = true;
      		if(root.getChildElement('Errors', null) != null)
      		{
	      		for(Dom.Xmlnode mmode : root.getChildElement('Errors', null).getChildren())
	      		{
	      			if(mmode.getName() == 'Error')
	      			{
		      			if (first)
		      			{
		      				message = mmode.getChildElement('Message', null).getText();		
		      				first = false;
		      			}
		      			else{
		      				message = message + '\n'+ mmode.getChildElement('Message', null).getText();
		      			}	
	      			}	
	      		}	      		
	      	}
	      	else
	      	{
	      		message = root.getChildElement('Message', null).getText();
	      	}	      		
      		if(!isPrepaid)
      		{
	      		sdq.put('CPF_Generate_Document_Initiate__c', status);      		
	      		sdq.put('CPF_Generate_Document_Message__c', message);
	      	}
	      	else
	      	{
	      		sdq.put('CPF_Prepaid_Generate_Document_Initiate__c', status);      		
	      		sdq.put('CPF_Prepaid_Generate_Document_Message__c', message);	
	      	}	
      	}
        
        return sdq;

	}


	
	/*
	Public String parseCustomerResponse(String xmlResponse)
	{
		Dom.Document doc = new Dom.Document();
        doc.load(xmlResponse);
        
        Dom.Xmlnode root = doc.getRootElement();  
        System.debug(root);      
        String  customerId = root.getChildElement('CustomerId', null).getText();       
      
        System.debug(customerId);

        return customerId;

	}
	

	Private static XmlStreamWriter getAPIInitials(XmlStreamWriter w,CPFAPIOAuthHelper cpfOauthHelper)
	{
		w.writeStartElement(null, 'Request', null);       
			
			w.writeStartElement(null, 'APIUsername', null);        
			w.writeCharacters(cpfOauthHelper.apiusername);
			w.writeEndElement(); //end apiusername
			
			w.writeStartElement(null, 'APIKey', null);        
			w.writeCharacters(cpfOauthHelper.apikey);
			w.writeEndElement(); //end APIKey
			
			w.writeStartElement(null, 'UserEmail', null);        
			w.writeCharacters('stephen.simons@astrumsolar.com');
			w.writeEndElement(); //end UserEmail
			return w;
	}

	Private Static XmlStreamWriter generateCustomerCreationXML(Boolean createCustomer,XmlStreamWriter w,CPFAPIOAuthHelper cpfOauthHelper,CPFAPIOAuthHelper.Customer lead)
	{
			if(createCustomer)
			{
				getAPIInitials(w,cpfOauthHelper);
			}	

			w.writeStartElement(null, 'Customer', null);    

				w.writeStartElement(null, 'SetConfirmed', null);        
				w.writeCharacters('1');
				w.writeEndElement(); //end CFirstname  

				w.writeStartElement(null, 'CFirstname', null);        
				w.writeCharacters((lead.CFirstname != null ? lead.CFirstname : ''));
				w.writeEndElement(); //end CFirstname  
				
				w.writeStartElement(null, 'CLastname', null);        
				w.writeCharacters(lead.CLastname);
				w.writeEndElement(); //end CLastname  

				w.writeStartElement(null, 'CEmail', null);        
				w.writeCharacters((lead.CEmail != null ? lead.CEmail : ''));
				w.writeEndElement(); //end CEmail  

				w.writeStartElement(null, 'CPhone1', null);        
				w.writeCharacters((lead.CPhone1 != null ? lead.CPhone1 : ''));
				w.writeEndElement(); //end CPhone1

				if(lead.CSecondaryFirstname != null)
				{
					w.writeStartElement(null, 'CSecondaryFirstname', null);        
					w.writeCharacters((lead.CSecondaryFirstname != null ? lead.CSecondaryFirstname : ''));
					w.writeEndElement(); //end CSecondaryFirstname  	
				}
				if(lead.CSecondaryLastname != null)
				{
					w.writeStartElement(null, 'CSecondaryLastname', null);        
					w.writeCharacters((lead.CSecondaryLastname != null ? lead.CSecondaryLastname : ''));
					w.writeEndElement(); //end CSecondaryLastname  	
				}
				if(lead.CSecondaryPhone != null)
				{
					w.writeStartElement(null, 'CSecondaryPhone', null);        
					w.writeCharacters((lead.CSecondaryPhone != null ? lead.CSecondaryPhone : ''));
					w.writeEndElement(); //end CSecondaryPhone  	
				}
				if(lead.CSecondaryEmail != null)
				{
					w.writeStartElement(null, 'CSecondaryEmail', null);        
					w.writeCharacters((lead.CSecondaryEmail != null ? lead.CSecondaryEmail : ''));
					w.writeEndElement(); //end CSecondaryEmail  	
				}

				w.writeStartElement(null, 'CAddress1', null);        
				w.writeCharacters((lead.CAddress1 != null ? lead.CAddress1 : ''));
				w.writeEndElement(); //end CAddress1

				w.writeStartElement(null, 'CCity', null);        
				w.writeCharacters(lead.CCity);
				w.writeEndElement(); //end CCity

				w.writeStartElement(null, 'CState', null);        
				w.writeCharacters(lead.CState);
				w.writeEndElement(); //end CState

				w.writeStartElement(null, 'CZip', null);        
				w.writeCharacters(lead.CZip);
				w.writeEndElement(); //end CZip 

				w.writeStartElement(null, 'CTitle', null);        
				w.writeCharacters((lead.CTitle != null ? lead.CTitle : ''));
				w.writeEndElement(); //end CTitle

				w.writeStartElement(null, 'CType', null);        
				w.writeCharacters(lead.CType);
				w.writeEndElement(); //end CType  

				w.writeStartElement(null, 'NewBuild', null);        
				w.writeCharacters(lead.NewBuild);
				w.writeEndElement(); //end NewBuild  

				if(Lead.averageBill)
				{
					if(lead.AverageElectricityBill != null)
					{
						w.writeStartElement(null, 'AverageElectricityBill', null);        
						w.writeCharacters(String.ValueOf(lead.AverageElectricityBill));
						w.writeEndElement(); //end AverageElectricityBill  
					}
				}
				else if(Lead.monthlyBill && Lead.monthlyKWH)
				{
					w.writeStartElement(null, 'EnergyDetails', null); 						
							w.writeStartElement(null, 'EnergyDetailsMonth', null);

								w.writeStartElement(null, 'MonthNum', null); 
								w.writeCharacters('1');
								w.writeEndElement(); //end MonthNum

								w.writeStartElement(null, 'EBill', null); 
								w.writeCharacters(String.valueOf(lead.JanElectricityBill));
								w.writeEndElement(); //end EBill

								w.writeStartElement(null, 'EUse', null); 
								w.writeCharacters(String.valueOf(lead.JanElectricityKWH));
								w.writeEndElement(); //end EUse

							w.writeEndElement(); //end EnergyDetailsMonth

							w.writeStartElement(null, 'EnergyDetailsMonth', null);

								w.writeStartElement(null, 'MonthNum', null); 
								w.writeCharacters('2');
								w.writeEndElement(); //end MonthNum

								w.writeStartElement(null, 'EBill', null); 
								w.writeCharacters(String.valueOf(lead.FebElectricityBill));
								w.writeEndElement(); //end EBill

								w.writeStartElement(null, 'EUse', null); 
								w.writeCharacters(String.valueOf(lead.FebElectricityKWH));
								w.writeEndElement(); //end EUse

							w.writeEndElement(); //end EnergyDetailsMonth

							w.writeStartElement(null, 'EnergyDetailsMonth', null);

								w.writeStartElement(null, 'MonthNum', null); 
								w.writeCharacters('3');
								w.writeEndElement(); //end MonthNum

								w.writeStartElement(null, 'EBill', null); 
								w.writeCharacters(String.valueOf(lead.MarElectricityBill));
								w.writeEndElement(); //end EBill

								w.writeStartElement(null, 'EUse', null); 
								w.writeCharacters(String.valueOf(lead.MarElectricityKWH));
								w.writeEndElement(); //end EUse

							w.writeEndElement(); //end EnergyDetailsMonth

							w.writeStartElement(null, 'EnergyDetailsMonth', null);

								w.writeStartElement(null, 'MonthNum', null); 
								w.writeCharacters('4');
								w.writeEndElement(); //end MonthNum

								w.writeStartElement(null, 'EBill', null); 
								w.writeCharacters(String.valueOf(lead.AprElectricityBill));
								w.writeEndElement(); //end EBill

								w.writeStartElement(null, 'EUse', null); 
								w.writeCharacters(String.valueOf(lead.AprElectricityKWH));
								w.writeEndElement(); //end EUse

							w.writeEndElement(); //end EnergyDetailsMonth

							w.writeStartElement(null, 'EnergyDetailsMonth', null);

								w.writeStartElement(null, 'MonthNum', null); 
								w.writeCharacters('5');
								w.writeEndElement(); //end MonthNum

								w.writeStartElement(null, 'EBill', null); 
								w.writeCharacters(String.valueOf(lead.MayElectricityBill));
								w.writeEndElement(); //end EBill

								w.writeStartElement(null, 'EUse', null); 
								w.writeCharacters(String.valueOf(lead.MayElectricityKWH));
								w.writeEndElement(); //end EUse

							w.writeEndElement(); //end EnergyDetailsMonth

							w.writeStartElement(null, 'EnergyDetailsMonth', null);

								w.writeStartElement(null, 'MonthNum', null); 
								w.writeCharacters('6');
								w.writeEndElement(); //end MonthNum

								w.writeStartElement(null, 'EBill', null); 
								w.writeCharacters(String.valueOf(lead.JunElectricityBill));
								w.writeEndElement(); //end EBill

								w.writeStartElement(null, 'EUse', null); 
								w.writeCharacters(String.valueOf(lead.JunElectricityKWH));
								w.writeEndElement(); //end EUse

							w.writeEndElement(); //end EnergyDetailsMonth

							w.writeStartElement(null, 'EnergyDetailsMonth', null);

								w.writeStartElement(null, 'MonthNum', null); 
								w.writeCharacters('7');
								w.writeEndElement(); //end MonthNum

								w.writeStartElement(null, 'EBill', null); 
								w.writeCharacters(String.valueOf(lead.JulElectricityBill));
								w.writeEndElement(); //end EBill

								w.writeStartElement(null, 'EUse', null); 
								w.writeCharacters(String.valueOf(lead.JulElectricityKWH));
								w.writeEndElement(); //end EUse

							w.writeEndElement(); //end EnergyDetailsMonth

							w.writeStartElement(null, 'EnergyDetailsMonth', null);

								w.writeStartElement(null, 'MonthNum', null); 
								w.writeCharacters('8');
								w.writeEndElement(); //end MonthNum

								w.writeStartElement(null, 'EBill', null); 
								w.writeCharacters(String.valueOf(lead.AugElectricityBill));
								w.writeEndElement(); //end EBill

								w.writeStartElement(null, 'EUse', null); 
								w.writeCharacters(String.valueOf(lead.AugElectricityKWH));
								w.writeEndElement(); //end EUse

							w.writeEndElement(); //end EnergyDetailsMonth

							w.writeStartElement(null, 'EnergyDetailsMonth', null);

								w.writeStartElement(null, 'MonthNum', null); 
								w.writeCharacters('9');
								w.writeEndElement(); //end MonthNum

								w.writeStartElement(null, 'EBill', null); 
								w.writeCharacters(String.valueOf(lead.SepElectricityBill));
								w.writeEndElement(); //end EBill

								w.writeStartElement(null, 'EUse', null); 
								w.writeCharacters(String.valueOf(lead.SepElectricityKWH));
								w.writeEndElement(); //end EUse

							w.writeEndElement(); //end EnergyDetailsMonth

							w.writeStartElement(null, 'EnergyDetailsMonth', null);

								w.writeStartElement(null, 'MonthNum', null); 
								w.writeCharacters('10');
								w.writeEndElement(); //end MonthNum

								w.writeStartElement(null, 'EBill', null); 
								w.writeCharacters(String.valueOf(lead.OctElectricityBill));
								w.writeEndElement(); //end EBill

								w.writeStartElement(null, 'EUse', null); 
								w.writeCharacters(String.valueOf(lead.OctElectricityKWH));
								w.writeEndElement(); //end EUse

							w.writeEndElement(); //end EnergyDetailsMonth

							w.writeStartElement(null, 'EnergyDetailsMonth', null);

								w.writeStartElement(null, 'MonthNum', null); 
								w.writeCharacters('11');
								w.writeEndElement(); //end MonthNum

								w.writeStartElement(null, 'EBill', null); 
								w.writeCharacters(String.valueOf(lead.NovElectricityBill));
								w.writeEndElement(); //end EBill

								w.writeStartElement(null, 'EUse', null); 
								w.writeCharacters(String.valueOf(lead.NovElectricityKWH));
								w.writeEndElement(); //end EUse

							w.writeEndElement(); //end EnergyDetailsMonth

							w.writeStartElement(null, 'EnergyDetailsMonth', null);

								w.writeStartElement(null, 'MonthNum', null); 
								w.writeCharacters('12');
								w.writeEndElement(); //end MonthNum

								w.writeStartElement(null, 'EBill', null); 
								w.writeCharacters(String.valueOf(lead.DecElectricityBill));
								w.writeEndElement(); //end EBill

								w.writeStartElement(null, 'EUse', null); 
								w.writeCharacters(String.valueOf(lead.DecElectricityKWH));
								w.writeEndElement(); //end EUse

							w.writeEndElement(); //end EnergyDetailsMonth
						
					w.writeEndElement(); //end EnergyDetails 

				}
				
				if(lead.ExternalCustomer != null)
				{
					w.writeStartElement(null, 'ExternalCustomerId', null);        
					w.writeCharacters(String.ValueOf(lead.ExternalCustomer));
					w.writeEndElement(); //end AverageElectricityBill  
				}
				if(lead.CurrentRateScheduleId != null)
				{
					w.writeStartElement(null, 'CurrentRateScheduleId', null);        
					w.writeCharacters(lead.CurrentRateScheduleId );
					w.writeEndElement(); //end CurrentRateScheduleId 
				}
				
				w.writeEndElement(); //end Customer

		if(createCustomer)
		{
			w.writeEndElement(); //end Request
		}

		return w;
	}

	Private String generateElligibilityInitiateXML(CPFAPIOAuthHelper cpfOauthHelper,System_Design_Quote__c sdq, Boolean resend)
	{
		XmlStreamWriter w = new XmlStreamWriter();
		getAPIInitials(w,cpfOauthHelper);

			w.writeStartElement(null, 'CustomerId', null);        
			w.writeCharacters(sdq.CPF_Customer_Id__c);
			w.writeEndElement(); //end QuickTemplateId	

			w.writeStartElement(null, 'EmailNotification', null);        
			w.writeCharacters(cpfOauthHelper.currentUserEmail);
			w.writeEndElement(); //end QuickTemplateId	

			w.writeStartElement(null, 'AuthEmail', null);        
			w.writeCharacters(cpfOauthHelper.currentUserEmail);
			w.writeEndElement(); //end UserEmail

			if(resend)
			{
				w.writeStartElement(null, 'ReSendEmail', null);        
				w.writeCharacters('1');
				w.writeEndElement(); //end UserEmail
			}

		w.writeEndElement(); //end Request

		String xmlOutput = w.getXmlString();
		System.debug(xmlOutput);
		return xmlOutput;	
		
	}

	Private Static String generateDocumentXML(CPFAPIOAuthHelper cpfOauthHelper,System_Design_Quote__c sdq, Boolean isPrepaid)
	{
		XmlStreamWriter w = new XmlStreamWriter();
		getAPIInitials(w,cpfOauthHelper);

			if(!isPrepaid)
			{
				w.writeStartElement(null, 'ProposalId', null);        
				w.writeCharacters(sdq.CPF_Proposal_Id__c);
				w.writeEndElement(); //end QuickTemplateId	
			}
			else
			{
				w.writeStartElement(null, 'ProposalId', null);        
				w.writeCharacters(sdq.CPF_Prepaid_Proposal_Id__c);
				w.writeEndElement(); //end QuickTemplateId		
			}	

			w.writeStartElement(null, 'EmailNotification', null);        
			w.writeCharacters(cpfOauthHelper.currentUserEmail);
			w.writeEndElement(); //end QuickTemplateId	

			w.writeStartElement(null, 'AuthEmail', null);        
			w.writeCharacters(cpfOauthHelper.currentUserEmail);
			w.writeEndElement(); //end UserEmail
			

		w.writeEndElement(); //end Request

		String xmlOutput = w.getXmlString();
		System.debug(xmlOutput);
		return xmlOutput;	
		
	}

	Private String generateSendForSignatureXML(CPFAPIOAuthHelper cpfOauthHelper,System_Design_Quote__c sdq , String homeOwnerEmail, Boolean isPrepaid)
	{
		XmlStreamWriter w = new XmlStreamWriter();
		getAPIInitials(w,cpfOauthHelper);

			if(!isPrepaid)
			{
				w.writeStartElement(null, 'ProposalId', null);        
				w.writeCharacters(sdq.CPF_Proposal_Id__c);
				w.writeEndElement(); //end QuickTemplateId	
			}
			else
			{
				w.writeStartElement(null, 'ProposalId', null);        
				w.writeCharacters(sdq.CPF_Prepaid_Proposal_Id__c);
				w.writeEndElement(); //end QuickTemplateId		
			}

			w.writeStartElement(null, 'AuthEmail', null);        
			w.writeCharacters(cpfOauthHelper.currentUserEmail);
			w.writeEndElement(); //end UserEmail

			w.writeStartElement(null, 'Recipients', null);        
				
				w.writeStartElement(null, 'Recipient', null);  
					w.writeStartElement(null, 'Role', null);        
					w.writeCharacters('HomeownerPrimarySigner');
					w.writeEndElement(); //end UserEmail   

					w.writeStartElement(null, 'Email', null);        
					w.writeCharacters(homeOwnerEmail);
					w.writeEndElement(); //end UserEmail  
				w.writeEndElement(); //end UserEmail

				w.writeStartElement(null, 'Recipient', null);        
					w.writeStartElement(null, 'Role', null);        
					w.writeCharacters('InstallerSigner');
					w.writeEndElement(); //end UserEmail   

					w.writeStartElement(null, 'Email', null);        
					w.writeCharacters(cpfOauthHelper.authorizedSigner);
					w.writeEndElement(); //end UserEmail 
				w.writeEndElement(); //end UserEmail

			w.writeEndElement(); //end UserEmail

			w.writeStartElement(null, 'DocsToSend', null);        
				w.writeStartElement(null, 'Doc', null);  
					w.writeStartElement(null, 'Type', null);
					w.writeCharacters('packet_homeowner');
					w.writeEndElement(); //end UserEmail      
				w.writeEndElement(); //end UserEmail
			w.writeEndElement(); //end UserEmail
			

		w.writeEndElement(); //end Request

		String xmlOutput = w.getXmlString();
		System.debug(xmlOutput);
		return xmlOutput;	
		
	}

	
	Private Static String generateGetJobXML(CPFAPIOAuthHelper cpfOauthHelper,System_Design_Quote__c sdq,String proposalId)
	{
		XmlStreamWriter w = new XmlStreamWriter();
		getAPIInitials(w,cpfOauthHelper);

			w.writeStartElement(null, 'ProposalId', null);        
			w.writeCharacters(proposalId);
			w.writeEndElement(); //end QuickTemplateId	

			w.writeStartElement(null, 'IncludeDocs', null);        
			w.writeCharacters('true');
			w.writeEndElement(); //end QuickTemplateId	
		w.writeEndElement(); //end Request

		String xmlOutput = w.getXmlString();
		System.debug(xmlOutput);
		return xmlOutput;	
		
	}
	

	Private static String generateCreateProposalXML(CPFAPIOAuthHelper cpfOauthHelper,CPFAPIOAuthHelper.Customer lead , CPFAPIOAuthHelper.Proposal proposal ,List<CPFAPIOAuthHelper.PvArray> pvarrays , List<CPFAPIOAuthHelper.Inverter> inverters, Boolean isPrepaid)
	{
		XmlStreamWriter w = new XmlStreamWriter();
		getAPIInitials(w,cpfOauthHelper);

		if(!isPrepaid)
		{
			w.writeStartElement(null, 'QuickTemplateId', null);        
			w.writeCharacters(Lead.QuickTemplateId);
			w.writeEndElement(); //end QuickTemplateId	
		}
		else
		{
			w.writeStartElement(null, 'QuickTemplateId', null);        
			w.writeCharacters(Lead.PrepaidQuickTemplateId);
			w.writeEndElement(); //end QuickTemplateId	
		}
		generateCustomerCreationXML(false,w,cpfOauthHelper,lead);
		
		w.writeStartElement(null, 'Proposal', null);  

			if(!isPrepaid)
			{
				w.writeStartElement(null, 'Name', null);        
				w.writeCharacters(proposal.Name + '-Monthly');
				w.writeEndElement(); //end PricePerWatt	
				w.writeStartElement(null, 'ExternalProposalId', null);        
				w.writeCharacters(proposal.ExternalProposalId+ 'M');
				w.writeEndElement(); //end PricePerWatt	
			}
			else
			{
				w.writeStartElement(null, 'Name', null);        
				w.writeCharacters(proposal.Name+ '-Prepaid');
				w.writeEndElement(); //end PricePerWatt		
				w.writeStartElement(null, 'ExternalProposalId', null);        
				w.writeCharacters(proposal.ExternalProposalId+ 'P');
				w.writeEndElement(); //end PricePerWatt	
			}	
			

			if(proposal.PricePerWatt != null)
			{
				w.writeStartElement(null, 'PricePerWatt', null);        
				w.writeCharacters(proposal.PricePerWatt);
				w.writeEndElement(); //end PricePerWatt	
			}
			if(proposal.DownPayment != null || proposal.AnnualIncrease != null)
			{
				
				w.writeStartElement(null, 'FinancingMethod', null);  
					if(proposal.DownPayment != null )
					{
						w.writeStartElement(null, 'DownPayment', null);        
						w.writeCharacters(String.valueOf(Integer.ValueOf(proposal.DownPayment)));
						w.writeEndElement(); //end DownPayment	
					}
					if(proposal.AnnualIncrease != null )
					{
						w.writeStartElement(null, 'AnnualIncrease', null);        
						w.writeCharacters(String.valueOf(proposal.AnnualIncrease));
						w.writeEndElement(); //end AnnualIncrease	
					}
				w.writeEndElement(); //end FinancingMethod	
			}
			
			w.writeStartElement(null, 'Quotes', null);  
				w.writeStartElement(null, 'PVQuote', null);  
					w.writeStartElement(null, 'PVArrays', null);  

					for(CPFAPIOAuthHelper.PvArray pvarray : pvarrays)
					{
						w.writeStartElement(null, 'PVArray', null);  

							w.writeStartElement(null, 'ModuleId', null);        
							w.writeCharacters(pvarray.ModuleId);
							w.writeEndElement(); //end ModuleId	

							w.writeStartElement(null, 'ModuleQuantity', null);        
							w.writeCharacters(pvarray.ModuleQuantity);
							w.writeEndElement(); //end ModuleQuantity	

							w.writeStartElement(null, 'InverterIndex', null);        
							w.writeCharacters(pvarray.InverterIndex);
							w.writeEndElement(); //end InverterIndex	

							w.writeStartElement(null, 'ShadeData', null);        
								for(integer i = 1;  i<=12; i++)
								{
									w.writeStartElement(null, 'Month', null);   	
										w.writeStartElement(null, 'MonthNum', null);        
										w.writeCharacters(String.valueOf(i));
										w.writeEndElement(); //end MonthNum	

										w.writeStartElement(null, 'Amount', null);        
										w.writeCharacters(pvarray.Shade);
										w.writeEndElement(); //end Amount	
									w.writeEndElement(); //end Month	
								}
							w.writeEndElement(); //end ShadeData	

							w.writeStartElement(null, 'Tilt', null);        
							w.writeCharacters(pvarray.Tilt);
							w.writeEndElement(); //end Tilt	

							w.writeStartElement(null, 'Azimuth', null);        
							w.writeCharacters(pvarray.Azimuth);
							w.writeEndElement(); //end Azimuth	

							w.writeStartElement(null, 'Height', null);        
							w.writeCharacters('0');
							w.writeEndElement(); //end Height	

							w.writeStartElement(null, 'Width', null);        
							w.writeCharacters('0');
							w.writeEndElement(); //end Width	

						w.writeEndElement(); //end PVArray	
					}
					w.writeEndElement(); //end PVArrays

					w.writeStartElement(null, 'Inverters', null);    
						for(CPFAPIOAuthHelper.Inverter inverter : inverters)
						{
							w.writeStartElement(null, 'Inverter', null);  

								w.writeStartElement(null, 'Index', null);        
								w.writeCharacters(inverter.Index);
								w.writeEndElement(); //end ModuleId	

								w.writeStartElement(null, 'InverterId', null);        
								w.writeCharacters(inverter.InverterId);
								w.writeEndElement(); //end InverterId	

								w.writeStartElement(null, 'Quantity', null);        
								w.writeCharacters(inverter.InverterQuantity);
								w.writeEndElement(); //end Quantity	

							w.writeEndElement(); //end Inverter	
    					}
					
					w.writeEndElement(); //end Inverters
				w.writeEndElement(); //end PVQuote	
			w.writeEndElement(); //end Quotes
		w.writeEndElement(); //end Proposal
		w.writeEndElement(); //end Request

		String xmlOutput = w.getXmlString();
		System.debug(xmlOutput);
		return xmlOutput;
	}
	/*
	Private String generateUserListXML(CPFAPIOAuthHelper cpfOauthHelper)
	{
		XmlStreamWriter w = new XmlStreamWriter();
		w.writeStartElement(null, 'Request', null);       
		w.writeStartElement(null, 'APIUsername', null);        
		w.writeCharacters(cpfOauthHelper.apiusername);
		w.writeEndElement(); //end apiusername
		w.writeStartElement(null, 'APIKey', null);        
		w.writeCharacters(cpfOauthHelper.apikey);
		w.writeEndElement(); //end APIKey
		w.writeEndElement(); //end Request
		String xmlOutput = w.getXmlString();
		System.debug(xmlOutput);
		return xmlOutput;
	}
	*/

}