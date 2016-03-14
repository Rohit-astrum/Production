/* FILE: SystemDesignLeaseFundController.cls
 * AUTHOR: Rohit Jain
 * DATE: July 13, 2013
 * PURPOSE: Controller for Sending Lead Information to NRG from System Design  
 * MODIFICATION HISTORY:
 * Commented by RJ 05/5/2015
 */
public with sharing class SystemDesignLeaseFundController {
    /*
    System_Design__c sd; 
    List<NRG_Array__c> arrayList = new List<NRG_Array__c>();
    
    public SystemDesignLeaseFundController (ApexPages.StandardController stdController) {
        sd = (System_Design__c) stdController.getRecord();
    }

   public PageReference sendToLeaseFund() { 
      
       List<NRG_Lead__c> nrglead = [Select Id,NRG_Lead_Id__C from NRG_Lead__c where System_Design__C = :sd.Id limit 1]; 
       
       NRG_Lead__c nlead;     
       NRG_System__c nsystem ;
       List<NRG_Array__C> narrays;
       
       if(!nrglead.isEmpty())
       {
          
           PageReference requestPage = Page.LeaseFundDetail;
           requestPage.getParameters().put('id',nrglead[0].Id);          
                      
           if (nrglead[0].NRG_Lead_Id__C != null && nrglead[0].NRG_Lead_Id__C != '' && !nrglead[0].NRG_Lead_Id__C.contains('Error') )
           {
               requestPage.getParameters().put('leadsent','N');
               requestPage.setRedirect(true);
               return requestPage;
           }
           else
           {
               nlead = [Select Id,NRG_Lead_Id__C, First_Name__c,Last_Name__c,Email__c,Phone__c,Street__c,City__C,State__c,Postal_Code__c,County__c,Company__C,Lead_status__c,System_Design__c 
                                      FROM NRG_Lead__c Where System_Design__C = :sd.Id limit 1 ];    
                                      
               nsystem = [Select Description__c,First_Year_Production__c,System_Size__c  from  NRG_System__c  where NRG_Lead__c = :nlead.Id];
               
               narrays = [Select Azimuth__c,Tilt__c,Shading__c,NRG_Inverter_Id__c,Inverter_Quantity__c,NRG_Module_Id__c,Module_Quantity__c,First_Year_PRoduction__c,System_Size__c from NRG_Array__C Where Solar_System__c = :nsystem.Id   ];                       
               
               arrayList = new List<NRG_Array__c>();
               //nlead.NRG_Lead_Id__C = sendToNRG(nlead,nsystem ,narrays );
               
               //update nlead;               
               
               //if (nlead.NRG_Lead_Id__C != null && nlead.NRG_Lead_Id__C != '')
               //{
                   //requestPage.getParameters().put('leadsent','Y');
               //}
               //else{
                   //requestPage.getParameters().put('leadsent','E');
               //}    
               //requestPage.setRedirect(true);
               //return requestPage;
               
               
               
           
           }
       }
       
       sd = [Select Id,s.Property__r.QAS_Property_County__c, s.Property__r.Property_ZIP__c, s.Property__r.Property_State__c
                 , s.Property__r.Property_City__c, s.Property__r.Name, s.Property__c , s.property__r.property_Owner__c, s.system_makeup__c
                  ,Total_Projected_Annual_Output_kWh_y__c,Total_System_Size_kW__c
              From System_Design__c s
             Where id = :sd.id]; 
       
       Account acct = [Select (Select LastName, FirstName, Email,Phone From Contacts) From Account a Where Id = :sd.property__r.Property_Owner__c];     
       NRG_Lead__c lead;
       if(acct != null && acct.Contacts.size() > 0 )
       {
           lead = new NRG_Lead__c();
           lead.Name = acct.Contacts[0].LastName + ', ' + acct.Contacts[0].FirstName;
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
           lead.System_Design__c = sd.Id;
          
       }
       NRG_System__C sys;
       if (lead != null )
       {
           sys = new NRG_system__c();
           
           sys.description__C = sd.system_makeup__c;
           sys.System_Size__c = sd.Total_System_Size_kW__c;
           sys.First_Year_Production__c = sd.Total_Projected_Annual_Output_kWh_y__c; 
                
       }
       else
       {
          PageReference requestPage = Page.LeaseFundDetail;
          requestPage.getParameters().put('leadsent','F');
          requestPage.setRedirect(true);
          return requestPage;
           
       }
       
       if (Sys != null)
       {       
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
       
           System_Design_Product__c inverter = [Select Id from System_Design_Product__C Where MOdel__c = 'M215-60-240-S22' limit 1];
           System.debug('Insert Array sd.id ' + sd.id );
           AggregateResult[] sysitems = [Select s.Tilt_Text__c, s.System_Design_Product__c, sum(s.Quantity__c),sum(Rated_Output_kW__c),sum(Projected_Annual_Output_kWh_y__c) ,s.Azimuth_Text__c, s.Shading_Text__C 
                                           From System_Design_Item__c s
                                          Where s.System_Design_Array__r.System_Design__c = :sd.id and s.Quantity__c > 0
                                       Group by s.System_Design_Product__c, s.Tilt_Text__c,s.Shading_Text__C,s.Azimuth_Text__c ];
                                    
           
           System.debug('** Insert Array s size ' + sysitems.size());
           
           //Map<Id,System_Design_Items__c> sysmap = new Map<Id,System_Design_Items__c>();       
           
       
           for (AggregateResult sysitem : sysitems)
           {
               NRG_Array__c nrgarray = new NRG_Array__c();    
               
               if( sysitem.get('Azimuth_Text__c') == null || sysitem.get('Tilt_Text__c') == null || sysitem.get('Shading_Text__C') == null )
               {
                  PageReference requestPage = Page.LeaseFundDetail;
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
               nrgarray.NRG_Inverter_Id__c = compmapping.get(productmapping.get(inverter.Id));
               nrgarray.Inverter_Quantity__c = (Decimal)sysitem.get('expr0');
               nrgarray.System_Size__c = (Decimal)sysitem.get('expr1');     
               nrgarray.First_Year_Production__c = (Decimal)sysitem.get('expr2');             
               nrgarray.NRG_Module_Id__c = compmapping.get(productmapping.get((ID)sysitem.get('System_Design_Product__c')));  //a1pA0000000EqJN
               if(nrgarray.NRG_Module_Id__c == null || nrgarray.NRG_Module_Id__c == '')
               {
                  PageReference requestPage = Page.LeaseFundDetail;
                  requestPage.getParameters().put('leadsent','MF');
                  requestPage.setRedirect(true);
                  return requestPage;         
               }
               nrgarray.Module_Quantity__c  = (Decimal)sysitem.get('expr0');
               
               arrayList.add(nrgarray );
               System.debug('**Insert Array ' + nrgarray);    
           }
            System.debug('Insert Array ' + arrayList.size());  
          
       }
       
        
        lead.NRG_Lead_Id__C = sendToNRG(lead,sys,arrayList);
        
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
        
        insert lead;
        sys.Nrg_Lead__C = lead.Id;
        insert sys; 
        for(NRG_Array__c nrgarray :arrayList )           
        {
            nrgarray.Solar_System__c = sys.Id;
            nrgarray.NRG_Lead__c = lead.Id;
        }    
        if(!arrayList.isEmpty())
        {
          
           insert arrayList;
        }        
       
       PageReference requestPage = Page.LeaseFundDetail;
       requestPage.getParameters().put('id',lead.Id);
       if (lead.NRG_Lead_Id__C != null && lead.NRG_Lead_Id__C != '' && !lead.NRG_Lead_Id__C.contains('Error')  )
       {
           requestPage.getParameters().put('leadsent','Y');
       }
       else{
           requestPage.getParameters().put('leadsent','E');
       }    
       requestPage.setRedirect(true);
       return requestPage;
      
       //return null;
   }    
      
   public String sendToNRG (NRG_Lead__c lead, NRG_System__c sys, List<NRG_Array__C> arrayList  )
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
        al.AstrumleadId = lead.System_Design__c;
        
        soapSforceComSchemasClassAstrumlead.AstrumSystem asys = new soapSforceComSchemasClassAstrumlead.AstrumSystem();
        asys.Description = sys.description__C;
        asys.First_Year_Production = sys.First_Year_Production__c;
        asys.System_Size = sys.System_Size__c ;
        
        soapSforceComSchemasClassAstrumlead.AstrumQuote aquote = new soapSforceComSchemasClassAstrumlead.AstrumQuote();
        //asys.Description = sys.description__C;
        
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
                apx.timeout_x = 9000;
                soapSforceComSchemasClassAstrumlead.SessionHeader_element SessionHeader = new soapSforceComSchemasClassAstrumlead.SessionHeader_element();
                sessionHeader.sessionid=loginResult.sessionid; 
                apx.sessionheader=sessionHeader;
                
                soapSforceComSchemasClassAstrumlead.AstrumLead  le = apx.createLead(al,asys,aquote ,lar);            
                system.debug('The value of the NRG Lead id is' + le.LeadId);
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
   
   
   
   }   
   */ 
   
}