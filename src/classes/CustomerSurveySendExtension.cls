/* FILE: CustomerSurveySendExtension.cls
 * AUTHOR: Rohit Jain
 * DATE: Oct 18, 2013
 * PURPOSE: Customer Survey Send from PM Project.
 * MODIFICATION HISTORY 
 *     12/07/14  DK  Made sendSurvey() method global to fix Salesforce Console errors
 */
global class CustomerSurveySendExtension{

    private ApexPages.StandardController controller;
    public String selectedContact { get; set; }    
    PM_Project__c project;
    
    public CustomerSurveySendExtension(ApexPages.StandardController controller) {
        this.controller = controller;
        project = (PM_Project__c) controller.getRecord();    
        project = [Select Sales_Order__r.AccountId__c from PM_Project__c Where id = :project.Id  ] ;  
    }
    
    public List<SelectOption> getContacts() {
        List<SelectOption> result = new List<SelectOption>();
        List<Contact> contacts = 
            [SELECT Id,Name,Email
               FROM Contact
              WHERE AccountId = :project.Sales_Order__r.AccountId__c
                AND Email != null
           ORDER BY Name];
        for (Contact ct: contacts) {
            result.add(new SelectOption(ct.Id+';'+project.Id, ct.Name));             
        }    
        if(result.size() < 1)
        {
           result.add(new SelectOption('', 'No Contacts'));        
        }
            
        return result;     
       
    }
    
    @RemoteAction
    global static String sendSurvey(String contactprjId) {
        String contactId;
        String projectId;
        if(contactprjId == null || contactprjId == '')
        {
            return 'Pelase select the receipient.';
        }
        else
        {
            String[] ids = contactprjId.split(';');     
            contactId = ids[0];
            projectId = ids[1];
        }
        
        List<Customer_Survey__c> surveys = [Select Id,Survey_Sent_To__c,Survey_Date_Sent__c,Survey_Completed__c
                                                  ,Survey_Completed_By__c,Survey_Date_Completed__c ,Survey_Sent_To_Email__c
                                                  ,Contact__r.Email
                                              from Customer_Survey__c Where PM_Project__c = :projectId];
       
        
        if(surveys != null && !surveys.isEmpty())
        {
            if(surveys[0].Survey_Completed__c)
            {
                return 'Survey has been sent for this project and was completed by '+surveys[0].Survey_Completed_By__c + ' on '+ surveys[0].Survey_Date_Completed__c ;      
            }
            else
            {
                if(surveys[0].Contact__c ==  contactId  &&  surveys[0].Contact__r.Email == surveys[0].Survey_Sent_To_Email__c )
                {
                    return 'Survey has been sent for this project to '+surveys[0].Survey_Sent_To__c + ' on '+ surveys[0].Survey_Date_Sent__c.format() ;      
                }
                else
                {
                     surveys[0].Survey_Sent_To_Email__c = surveys[0].Contact__r.Email;
                     surveys[0].Survey_Re_Sent_Date__C = System.Today(); 
                     update surveys[0];
                     return 'Survey is being Re Sent due to change of Email Address.'; 
                }    
            }    
        }
        else
        {
            System.debug('***contactId  '+contactId );
            Contact ct = [Select Id,Name,Email from Contact Where Id = :contactId];
            Customer_Survey__c   survey = new Customer_Survey__c();
            survey.PM_Project__c = projectId;
            survey.Survey_Date_Sent__C = System.Today();  
            survey.Contact__c = contactId;         
            survey.Survey_Sent_To__c = ct.Name;
            survey.Survey_Sent_To_Email__c = ct.Email;       
            insert survey;   
                 
            String surveyId = survey.Id;           
            String md5Coded = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(surveyId )));
            survey.md5code__c = md5Coded ;
            update survey;
            return ''; 
            
        }
    } 
}