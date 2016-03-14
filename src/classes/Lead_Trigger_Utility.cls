/* FILE: Lead_Trigger_Utility.cls
 * AUTHOR: Stephen Simons
 * DATE: 06/11/13
 * PURPOSE: Organized Lead triggers
 * MODIFICATION HISTORY:   
 *     10/30/14  DK  Updated Utility Rate Code and Utility Company logic in handlePropertyCreation_AU()
 *     1/27/15  RJ  Commented Utility Rate Code and Utility Company logic in handlePropertyCreation_AU() as it is moved to Utility Service
 *     1/27/15  RJ  Added the logic to derive the Record Type based on Site Type
 *     7/16/15  PB  FPO Phase2 Query only for active Office Locations.Assign office based on State coverage and Proximity.
 *     9/11/15  PB  FPO-Phase4  
 */
public with sharing class Lead_Trigger_Utility {
 
        
    public static final String TASK_STATUS = 'Not Started';
    public static final String TASK_PRIORITY = 'Normal';
    public static final String TASK_SUBJECT = 'Follow-Up';
    public static final String TASK_DESCRIPTION = 'This lead was just re-entered. Please follow up with this prospect. Details of the duplicate Lead are as follows : ';
    public static final Set<String> LEAD_STATUS  = new Set<String> {'Open – New','Contacted by Us', 'Qualified' , 'Contacted Us Back'};
    Server_Info__c serverInfo;
    public Lead_Trigger_Utility()
    {
        if(!Test.isRunningTest())
        {
            serverInfo = [select Server_URL__c from Server_Info__c limit 1];        
        }
        else
        {
            serverinfo = new Server_Info__c();         
            insert serverinfo;
        }    
    }
    public void handlePropertyCreation_AU(Map<Id,Lead> newMap){
        // Variable Declarations
        List<Property__c> propertyInsert= new List<Property__C>();  
        Map<Id,Property__C> optyUpdateMap = new Map<Id,Property__C>();
        List<Office_Location__c> officeLocations   = new List<Office_Location__c>();  
        Map<String,String> officeMap = new Map<String,String>();
        Set<String> zipCodesSet   = new Set<String>();
        Map<String,ID> UtilityMap = new Map<String,ID>();
        Property__c property;
        String[] tmpString;
        String assignOffice;
        Boolean convertLeadFlag = false;
        
        // Added by RJ on 01/27/2015
        Map<String, Schema.RecordTypeInfo> proertyRTMap = Schema.SObjectType.Property__c.getRecordTypeInfosByName() ;

        for (Lead l : newMap.values()) {
              if (l.IsConverted == true){
                  convertLeadFlag = true;
                 if(l.PostalCode != null)
                  {
                    zipCodesSet.add(l.PostalCode.subString(0,5));
                  }
              }    
        }
        //zipCodesList.add('00000');

        //FPO-Phase4
        Map<Id,Office_Location__c> officeLocMap = 
            new Map<Id,Office_Location__c>(
            [Select Name,Location__Latitude__s, Location__Longitude__s,State_Coverage__c,State__c  
                FROM Office_Location__c 
                WHERE Active__c = true]);

        Map<String,Id> officezipcodeMap = new Map<String,Id>();
        List<Office_Zip_Code__c> officeZipCodes = new List<Office_Zip_Code__C>();
        officeZipCodes = [SELECT Name, Office_Location__c FROM Office_Zip_Code__c WHERE Office_Location__r.Active__c = true AND Name in:zipCodesSet];
        for(Office_Zip_Code__c officeZip: officeZipCodes){
          officezipcodeMap.put(officeZip.Name,officeZip.Office_Location__c);
        }

       
        if(convertLeadFlag)
        {

            officeLocations = officeLocMap.values();
            /*FPO-Phase4 Commented below code
            officeLocations = [Select Name,Location__Latitude__s, Location__Longitude__s,State_Coverage__c,State__c  
                                from Office_Location__c 
                                where Active__c = true]; //FPO Phase2 PB

            */   
      
            /* FPO Phase2 - Commented old code
            for (Office_Location__c ol :officeLocations  )
            {   
                if(ol.State_Coverage__c != null)
                    tmpString = ol.State_Coverage__c.split(';');
                    
                if(tmpString != null && tmpString.size() > 0) 
                {
                   for(String s : tmpString)
                        officeMap.put(s,ol.Name);   
                   tmpString.clear();          
                }        
                
            }
            */

            /*for(Utility_by_zip_code__c uc : [Select Utility_Zip_Code__c, Utility_Company_Master__c from Utility_by_zip_code__c Where Utility_Company_Master__c !=null And Utility_Zip_Code__c in :zipCodesList])
            {
           
              UtilityMap.put(uc.utility_zip_code__c, uc.Utility_Company_Master__c);
            }  
        
            System.debug('**'+officeMap);
            */
            
            Map<ID, ID> utilCompanyDefaults = new Map<ID, ID>();        //Utility Company ID --> Utility Rate Code ID
            for (Utility_Company__c urc : [SELECT Utility_Company_Master__c FROM Utility_Company__c WHERE Default_Rate_Code__c = true AND Utility_Company_Master__c IN :UtilityMap.values() LIMIT 10000]){
                utilCompanyDefaults.put(urc.Utility_Company_Master__c, urc.ID);
            }
            
            for (Lead l : newMap.values()) {
                if (l.IsConverted == true) {               
                    if (l.ConvertedAccountId != null && l.Street != null && l.city != null && (l.QAS_County__c != null || l.County__c != null) && l.PostalCode != null && l.State != null  ) {
                           // Create Property Object
                        
                            property = new Property__c();   
                            property.RecordTypeId =  proertyRTMap.get(l.Site_Type__c).getRecordTypeId();  
                            property.Name = l.Street;
                            property.Property_City__c = l.city;
                            property.Property_State__c = l.State;
                            property.Property_County__c = (l.QAS_County__c != null ? l.QAS_County__c : SalesRegionHelper.removeState(l.County__c));
                            property.Property_ZIP__c = l.PostalCode;
                            property.Property_Country__c = l.Country;
                            property.Sales_Region__c  = l.Sales_Region__c ;
                            property.Property_Owner__c = l.ConvertedAccountId ;
                            property.QAS_Latitude__c = l.QAS_Latitude__c;
                            property.QAS_Longitude__c = l.QAS_Longitude__c;   
                            property.ValidationStatus__c = l.ValidationStatus_Address__c;   
                            property.ValidationTimestamp__c = l.ValidationTimestamp_Address__c;   
                            property.QAS_Property_County__c   = (l.QAS_County__c != null ? l.QAS_County__c : SalesRegionHelper.removeState(l.County__c));
                            //FPO Phase2 PB
                            //property.Astrum_Office__c = Astrum_Distance_Calculation.assignOffice(officeMap,officeLocations,l); 
                            
                            //FPO Phase4 Office assignment logic change
                            //property.Astrum_Office__c = Astrum_Distance_Calculation.assignOffice(officeLocations,l); 
                            
                            if(String.isNotBlank(l.Current_Company_Office__c)){
                              if(officeLocMap.containsKey(l.Current_Company_Office__c)){
                                property.Astrum_Office__c = officeLocMap.get(l.Current_Company_Office__c).Name;
                              }
                              property.Astrum_Office_New__c = l.Current_Company_Office__c;
                            }else{
                              property.Astrum_Office__c = Astrum_Distance_Calculation.assignOfficeLocation(officeLocations,l).Name;
                              property.Astrum_Office_New__c = Astrum_Distance_Calculation.assignOfficeLocation(officeLocations,l).Id;                              
                            }
                            //End of FPO Phase4

                            /*if(l.PostalCode != null)
                            {
                              property.Utility_Company_Master__c = (UtilityMap.get(l.PostalCode.subString(0,5)) != null ? UtilityMap.get(l.PostalCode.subString(0,5)) : UtilityMap.get('00000'));
                            }
                            else
                            {
                              property.Utility_Company_Master__c = UtilityMap.get('00000');  
                            }

                            property.Utility_Company__c = utilCompanyDefaults.get(property.Utility_Company_Master__c);   //Get the default Utility Rate Code for this Utility Company
                            */
                            property.Confirmed_Location__Latitude__s = l.Confirmed_Location__Latitude__s;
                            property.Confirmed_Location__Longitude__s = l.Confirmed_Location__Longitude__s;
                            property.Affiliate_Community_Program__c = l.Affiliate_Community_Program__c;
                            property.Community_Program_Offer__c = l.Community_Program_Offer__c;

                            propertyInsert.add(property);              
                            optyUpdateMap.put(l.ConvertedOpportunityId, property);                                      
                    }
                }
            }
            
        }
        
        if (!propertyInsert.isEmpty()) {
        insert propertyInsert;
        }
        // Associate Property to Opportunity
        if(!optyUpdateMap.isEmpty())
        {
          List<Opportunity> opty = [Select Id,Property__c from Opportunity where Id in :optyUpdateMap.keySet()];
          List<Opportunity> optyUpdate = new List<Opportunity>();
          
          for(Opportunity opt: opty )
          {
             
              opt.Property__c = optyUpdateMap.get(opt.Id).Id;
              optyUpdate.add(opt); 
          }  
      
          if (!optyUpdate.isEmpty()) {
           upsert optyUpdate;
          }
        }  
        
    }
    
    public void createTasksForLeads(Map<Lead, Lead> leadsMap) {
       
        
        List<Task> tasksToAdd = new List<Task>();
        List<Lead> leadsToUpdate = new List<Lead>();

        for (Lead tempLead : leadsMap.keyset()) {
            Task tempTask = createTask(tempLead.id, leadsMap.get(tempLead));
            tasksToAdd.add(tempTask);
            
            if(!LEAD_STATUS.contains(tempLead.Status))
            {
                tempLead.Status = 'Contacted Us Back';
                leadsToUpdate.add(tempLead); 
                
            }    
                
        }

        if (!tasksToAdd.isEmpty()) {
            insert tasksToAdd;
        }   
        
        if (!leadsToUpdate.isEmpty()) {
            update leadsToUpdate;
        }       
    }
    
    public Task createTask(Id theId, Lead oldLead) {

        Task tempTask = new Task();
        tempTask.whoId = theId;  
        tempTask.activityDate = System.today();
        
        tempTask.description = TASK_DESCRIPTION;
        tempTask.description = tempTask.description + 'Name : '+oldLead.FirstName + ' '+ OldLead.LastName + ' Phone : '+ OldLead.Phone + ' Email : '+ OldLead.Email;
        tempTask.priority = TASK_PRIORITY;
        tempTask.status = TASK_STATUS;
        tempTask.subject = TASK_SUBJECT;
        
        return tempTask;        
    }
    
    public void sendEmailForLeads(List<Lead> leadslist) {
        
           
        List<Messaging.SingleEmailMessage> email = new List<Messaging.SingleEmailMessage>();         
        for (Lead lead : leadslist) {
            
          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          
          if (!Test.isRunningTest()) {
            mail.setToAddresses(new String[] {lead.owner.Email});           
          }
          else {
            User me = [Select email from user where id = :UserInfo.getUserId() limit 1];   
            mail.setToAddresses(new String[] { me.Email });
          }
            
          mail.setSubject('Duplicate Lead Alert');
    
          String plainTextContent ='This Lead: ' + lead.Name +' was just re-submitted. Please follow up with this prospect.';
          String htmlContent = 'This Lead: ' + ' <a href="' + serverInfo.Server_URL__c + lead.Id+ '">' + lead.Name + '</a>' +' was just re-submitted. Please follow up with this prospect.';
            
          mail.setPlainTextBody(plainTextContent);
          mail.setHtmlBody(htmlContent );
          
          email.add(mail); 
          
          //Messaging.sendEmail(new Messaging.Singleemailmessage[] { mail });
          if (Test.isRunningTest()) {
            // only send one email
            break;
          } 
          
               
        }
        Messaging.sendEmail(email);       
               
    }
    
    public void sendEmailForOpps(Map<Id,Lead> OppIdLeadMap,Map<String, Lead> leadMap) {
        
        Map<Id,Opportunity> OppMap = new Map<Id,Opportunity>([Select ID,Owner.Email from Opportunity Where Id in :OppIdLeadMap.Keyset()]);
        
                       
        List<Messaging.SingleEmailMessage> email = new List<Messaging.SingleEmailMessage>();         
        for (Id oppId : OppIdLeadMap.KeySet()) {
          
          if(OppMap.get(oppId) != null)
          {  
              
              Lead newLead = LeadMap.get(OppIdLeadMap.get(oppId).Address_Key__c);
              newLead.Status = 'Not a Lead - DUPLICATE'; 
              
              Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
              
              if (!Test.isRunningTest()) {
                mail.setToAddresses(new String[] {OppMap.get(oppId).Owner.Email});           
              }
              else {
                User me = [Select email from user where id = :UserInfo.getUserId() limit 1];   
                mail.setToAddresses(new String[] { me.Email });
              }
                
              mail.setSubject('Duplicate Lead Alert');
        
              String plainTextContent ='This Lead: ' + OppIdLeadMap.get(OppId).Name +' was just re-submitted. Please follow up with this prospect.';
              String htmlContent = 'This Lead: ' + ' <a href="' + serverInfo.Server_URL__c + OppIdLeadMap.get(OppId).Id+ '">' + OppIdLeadMap.get(OppId).Name + '</a>' +' was just re-submitted. Please follow up with this prospect.';
                
              mail.setPlainTextBody(plainTextContent);
              mail.setHtmlBody(htmlContent );
              
              email.add(mail); 
              
              //Messaging.sendEmail(new Messaging.Singleemailmessage[] { mail });
              if (Test.isRunningTest()) {
                // only send one email
                break;
              } 
           }
        }
        Messaging.sendEmail(email);       
                
    }
    
    /*public void defaultCommunityProgram(Map<Id, Lead> newLeadsMap){    
        ID[] leadIDs = new ID[]{};
        for (Lead ld : newLeadsMap.values()){
            if (ld.Community_Program_Offer__c == null)
                leadIDs.add(ld.ID);
        }
        
        if (leadIDs.isEmpty())
            return;
        
        Lead[] leads = [SELECT Community_Program_Offer__c, PostalCode, City, County__c FROM Lead WHERE ID IN :leadIDs];
        
        Map<Community_Program_Offer__c, Set<String>> commProgVals = new Map<Community_Program_Offer__c, Set<String>>();     //Community_Program_Offer__c --> Set of eligible values
        for (Community_Program_Offer__c cpo : [SELECT Eligibility_Criterion__c, Eligible_Values__c FROM Community_Program_Offer__c WHERE Active__c = true]){
            String[] vals = cpo.Eligible_Values__c.split(',');
            for (Integer i = 0; i < vals.size(); i++)
                vals[i] = vals[i].trim();
            Set<String> valSet = new Set<String>(vals);
            commProgVals.put(cpo, valSet);
        }
        
        Lead[] updateLeads = new Lead[]{};
        for (Lead ld : leads){
            String zip = ld.PostalCode;
            String city = ld.City;
            String county = ld.County__c;
            String matchType = '';    //Could also be a boolean, but a string is more extendable if necessary
            for (Community_Program_Offer__c cpo : commProgVals.keySet()){
                Set<String> valSet = commProgVals.get(cpo);
                //Order of priority: zip, city, county
                if (cpo.Eligibility_Criterion__c == 'ZIP'){
                    if (valSet.contains(zip)){
                        ld.Community_Program_Offer__c = cpo.ID;
                        break;    //Quit once we find a matching zip
                    }
                } else if (cpo.Eligibility_Criterion__c == 'City'){
                    if (valSet.contains(city)){    //Supercedes any existing county matches
                        ld.Community_Program_Offer__c = cpo.ID;
                        matchType = 'city';
                    }
                } else if (cpo.Eligibility_Criterion__c == 'County'){
                    if (valSet.contains(county) && matchType != 'city')    //Only set the county match if no city has been found
                        ld.Community_Program_Offer__c = cpo.ID;
                }
            }
            if (ld.Community_Program_Offer__c != null)
                updateLeads.add(ld);
        }
        update updateLeads;
    }*/
}