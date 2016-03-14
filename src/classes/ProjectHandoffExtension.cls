/* FILE: ProjectHandoffExtension.cls
 * AUTHOR: Rohit Jain
 * DATE: April 22, 2013
 * PURPOSE: Controller for ProjectHandoff page  
 * MODIFICATION HISTORY 
 *    01/05/15  DK  Added Handoff_Big_Ticket_Electrical_Type__c field to constructor
 *    01/19/16 RJ SOA-75
 */ 

global class ProjectHandoffExtension {


    private ApexPages.StandardController controller;
    private PM_Project__c pmproject;
    private String emailsent;
    public Boolean showOtherElectric { get; private set; }
    public String errorFields { get; set; }
    
    public ProjectHandoffExtension (ApexPages.StandardController controller) {
        if (!Test.isRunningTest())
            controller.addFields(new String[]{'Handoff_Big_Ticket_Electrical_Type__c'});
        this.controller = controller;
        pmproject = (PM_Project__c)controller.getRecord();   
        errorFields = '';
        
        emailsent = ApexPages.CurrentPage().getParameters().get('sfdcIFrameOrigin'); //01/19/16 RJ SOA-75
        System.debug('** '+ ApexPages.CurrentPage().getParameters());
        System.debug('*emailsent '+emailsent);             
        bigTicketElectricalChanged();
    }
    
    Public String getReturnURL()
    {
        String pageurl = '/apex/ProjectHandoff?Id='+pmproject.id+'&emailsent=true';
        return EncodingUtil.urlEncode(pageurl,'UTF-8');
    }
    
    public void updateProject()
    {
        if(emailsent != null && emailsent != '')
        {
            System.debug(' ** Updating Project Handoff Date *****');
            pmproject.Handoff_Checklist_Status__c = 'Handoff Email Sent';     
            pmproject.Handoff_Email_Sent_Date__c = System.today(); 
            pmproject.Status__c = 'PL Complete'; 
           
            update pmproject;
            
        }
    
    }
    
    public Id getContactId() {
        
        Contact result = [
        SELECT Id,Name,Email 
         FROM Contact
         WHERE AccountId = :pmproject.Sales_Order__r.AccountId__c Limit 1 ];
    
    
        return result.Id;
    
    } 
    
    public Id getTemplateId() {
        
        Handoff_Settings__c mc = Handoff_Settings__c.getValues('Customer Care Handoff');
        
        String templatename = mc.Handoff_Email_Template__c;
        
        EmailTemplate result = [
        SELECT Id
         FROM EmailTemplate
         WHERE NAme = :templatename Limit 1 ];    
    
        return result.Id;
    
    } 
    
    public String getCcEmail() {
        
        Handoff_Settings__c mc = Handoff_Settings__c.getValues('Customer Care Handoff');        
        return mc.Customer_Care_Email__c;             
    
    } 
    
     //determine whether to show other electrical field
    public PageReference bigTicketElectricalChanged() {
        
        showOtherElectric = false;  
        if (pmproject.Handoff_Big_Ticket_Electrical_Type__c != null && pmproject.Handoff_Big_Ticket_Electrical_Type__c!= '')
        {
            String[] tmpString = pmproject.Handoff_Big_Ticket_Electrical_Type__c.split(';');      
            for(String s : tmpString)
            {  
               System.debug('##'+s);               
               if(s.equalsIgnoreCase('Other'))
               {                   
                   showOtherElectric = true;    
                   break;
               }
            }   
        }    
        return null;
    }
    
    private void grabPostData() {
        Map<String,String> params = ApexPages.currentPage().getParameters();
        pmproject.Handoff_Other_System_Location__c = params.get('system_location_other');
        //pmproject.Handoff_Internet_Access__c = params.get('customer_has_internet');        
    } 
       
    public PageReference checkListCompleted() {        
        
        //if(pmproject.Handoff_Check_list_completed__c)
        //{
            pmproject = (PM_Project__c)controller.getRecord();
            errorFields = '';           
            
            System.debug('Locother##'+pmproject.Handoff_Other_System_Location__c ); 
                        
            if (pmproject.Handoff_System_Location__c == null || pmproject.Handoff_System_Location__c.trim() == '') {
                errorFields += '[1][sysloc]';
            }
            if (pmproject.Handoff_System_Location__c == 'Other' &&(pmproject.Handoff_Other_System_Location__c == null || pmproject.Handoff_Other_System_Location__c.trim() == '')) {
                System.debug('Locother##'+pmproject.Handoff_Other_System_Location__c );
                errorFields += '[1][sysotherloc]';
            }
            if ((pmproject.Handoff_System_Location__c == 'Other'||pmproject.Handoff_System_Location__c == 'Barn'||pmproject.Handoff_System_Location__c == 'Garage' ||pmproject.Handoff_System_Location__c == 'Ground Mount') &&(pmproject.Handoff_Distance_to_Mail_Supply_ft__c == null || pmproject.Handoff_Distance_to_Mail_Supply_ft__c.trim() == '')) {
                System.debug('Locother##'+pmproject.Handoff_Distance_to_Mail_Supply_ft__c );
                errorFields += '[1][syssupploc]';
            }
            if (pmproject.Handoff_Is_Internet_Access__c == null || pmproject.Handoff_Is_Internet_Access__c.trim() == '') {
                errorFields += '[1][intertacc]';
            }
            if (pmproject.Handoff_Is_Internet_Access__c == 'Yes' &&(pmproject.Handoff_Type_of_Internet_Access__c == null || pmproject.Handoff_Type_of_Internet_Access__c.trim() == '')) {
                errorFields += '[1][intertype]';
            }
            if (pmproject.Handoff_Type_of_Internet_Access__c == 'Other' &&(pmproject.Handoff_Other_Internet_Access_Type__c == null || pmproject.Handoff_Other_Internet_Access_Type__c.trim() == '')) {
                errorFields += '[1][intertypeother]';
            }
            if (pmproject.Handoff_Bridge_Installed__c == null || pmproject.Handoff_Bridge_Installed__c.trim() == '') {
                errorFields += '[1][bridgeinst]';
            }
            if (pmproject.Handoff_Bridge_Installed__c == 'Yes' &&(pmproject.Handoff_Bridge_Type__c == null || pmproject.Handoff_Bridge_Type__c.trim() == '')) {
                errorFields += '[1][bridgetype]';
            }
            if (pmproject.Handoff_Bridge_Type__c == 'Other' &&(pmproject.Handoff_Bridge_Model_Number__c == null || pmproject.Handoff_Bridge_Model_Number__c.trim() == '')) {
                errorFields += '[1][bridgetypeother]';
            }
            if (pmproject.Handoff_Envoy_Location__c == null || pmproject.Handoff_Envoy_Location__c.trim() == '') {
                errorFields += '[1][envloc]';
            }
            if (pmproject.Handoff_Envoy_Location__c == 'Not immediately next to panel' &&(pmproject.Handoff_Envoy_Location_Explanation__c == null || pmproject.Handoff_Envoy_Location_Explanation__c.trim() == '')) {
                errorFields += '[1][envoyother]';
            }
            if (pmproject.Handoff_Dedicate_Outlet_Breaker_Location__c == null || pmproject.Handoff_Dedicate_Outlet_Breaker_Location__c.trim() == '') {
                errorFields += '[1][outletbr]';
            }
            if (pmproject.Handoff_Dedicate_Outlet_Breaker_Location__c == 'Other' &&(pmproject.Handoff_Other_Outlet_Breaker_Location__c == null || pmproject.Handoff_Other_Outlet_Breaker_Location__c.trim() == '')) {
                errorFields += '[1][outletother]';
            }
            if (pmproject.Handoff_Revenue_Grade_Meter_Installed__c == null || pmproject.Handoff_Revenue_Grade_Meter_Installed__c.trim() == '') {
                errorFields += '[1][grademeterins]';
            }
            if (pmproject.Handoff_Dedicated_Outlet_for_Envoy__c == null || pmproject.Handoff_Dedicated_Outlet_for_Envoy__c.trim() == '') {
                errorFields += '[1][envoy]';
            }
            if (pmproject.Handoff_Dedicated_Outlet_for_Envoy__c == 'Yes' && (pmproject.Handoff_Dedicated_Outlet_is_GFCI__c == null || pmproject.Handoff_Dedicated_Outlet_is_GFCI__c.trim() == '')) {
                errorFields += '[1][envoygfci]';
            }
            if (pmproject.Handoff_Revenue_Grade_Meter_Installed__c == 'Yes' &&(pmproject.Handoff_Revenue_Grade_Meter_Type__c == null || pmproject.Handoff_Revenue_Grade_Meter_Type__c.trim() == '')) {
                errorFields += '[1][grademeter]';
            }
            if (pmproject.Handoff_Revenue_Grade_Meter_Type__c  == 'Other' &&(pmproject.Handoff_Other_Revenue_Grade_Meter_Make__c == null || pmproject.Handoff_Other_Revenue_Grade_Meter_Make__c.trim() == '')) {
                errorFields += '[1][grademeterother]';
            }
            if (pmproject.Handoff_Big_Ticket_Electrical_Item__c == null || pmproject.Handoff_Big_Ticket_Electrical_Item__c.trim() == '') {
                errorFields += '[1][electric]';
            }
            if (pmproject.Handoff_Big_Ticket_Electrical_Item__c == 'Yes' &&(pmproject.Handoff_Big_Ticket_Electrical_Type__c == null || pmproject.Handoff_Big_Ticket_Electrical_Type__c.trim() == '')) {
                errorFields += '[1][electrictype]';
            }
            if (pmproject.Handoff_Enlighten_Activated__c == null || pmproject.Handoff_Enlighten_Activated__c.trim() == '') {
                errorFields += '[1][enlighten]';
            }
            if (pmproject.Handoff_Enlighten_Verification_Date__c == null ) {
                errorFields += '[1][everify]';
            }
            if (pmproject.Handoff_Enphase_ID__c == null || pmproject.Handoff_Enphase_ID__c.trim() == '') {
                errorFields += '[1][enphaseid]';
            }
            if(errorFields == '' && !(pmproject.Handoff_Check_list_completed__c))
            {
               pmproject.Handoff_Checklist_Completion_Date__c = system.today();
              //pmproject.Customer_Care_Handoff__c = pmproject.Handoff_Checklist_Completion_Date__c;
               //pmproject.Handoff_Check_list_completed__c = true;    
               pmproject.Handoff_Checklist_Status__c = 'Completed';  
               
               controller.save(); 
               
               // Submit the Approval Process here
               Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
               req1.setComments('Submitted');
               req1.setObjectId(pmproject.Id);
                // Submit the approval request for the account
                Approval.ProcessResult result = Approval.process(req1);
                 
            }
            else
            {
               pmproject.Handoff_Checklist_Completion_Date__c = null;
               pmproject.Handoff_Check_list_completed__c = false;    
               pmproject.Handoff_Checklist_Status__c = 'New';  
               controller.save(); 
            
            }
            //controller.save();    
            System.debug('errorFields ##'+errorFields  ); 
        //}
        //else
        //{
         //   errorFields = '';
        //}
        return null;
        
    }
    
    public PageReference verifyChecklist() {   
        try{
            
            //controller.save(); 
            pmproject.Handoff_Checklist_Status__c = 'Verified';  
            List<ProcessInstanceWorkitem> processitems = [Select ID From ProcessInstanceWorkitem p Where p.ProcessInstance.TargetObjectId = :pmproject.Id and 
                                                p.ProcessInstance.Status = 'Pending'];
              for(ProcessInstanceWorkitem processItem : processitems )
              {
                  System.debug('*Rem-'+processitem.Id);
                  Approval.ProcessWorkitemRequest req2 = 
                    new Approval.ProcessWorkitemRequest();          
         
                  req2.setAction('Approve');  
                  req2.setComments(pmproject.Handoff_Customer_Care_Comments__c);    
                  // Use the ID from the newly created item to specify the item to be worked
                  req2.setWorkitemId(processitem.Id);
                  // Submit the request for approval
                  Approval.ProcessResult result2 =  Approval.process(req2);                    
             
              }
              
              
          }
          catch(Exception e)
          {
              System.debug('No Pending Actions');
          }  
          return null;    
    }
    
    public PageReference rejectChecklist() {   
         errorFields = '';
         if (pmproject.Handoff_Customer_Care_Comments__c == null || pmproject.Handoff_Customer_Care_Comments__c.trim() == '') {
                errorFields += '[1][cccomm]';
            }
        
         if(errorFields == ''){
            System.debug('*pmproject.Handoff_Customer_Care_Comments__c '+pmproject.Handoff_Customer_Care_Comments__c);     
            //controller.save();  
            pmproject.Handoff_Checklist_Status__c = 'Rejected';         
            try{
                List<ProcessInstanceWorkitem> processitems = [Select ID From ProcessInstanceWorkitem p Where p.ProcessInstance.TargetObjectId = :pmproject.Id and 
                                                    p.ProcessInstance.Status = 'Pending'];
                  for(ProcessInstanceWorkitem processItem : processitems )
                  {
                      System.debug('*Rem-'+processitem.Id);
                      Approval.ProcessWorkitemRequest req2 = 
                        new Approval.ProcessWorkitemRequest();          
             
                      req2.setAction('Reject');  
                      req2.setComments(pmproject.Handoff_Customer_Care_Comments__c);   
                      // Use the ID from the newly created item to specify the item to be worked
                      req2.setWorkitemId(processitem.Id);
                      // Submit the request for approval
                      Approval.ProcessResult result2 =  Approval.process(req2);  
                      //pmproject.Handoff_Checklist_Status__c = 'Rejected';    
                      //pmproject.Handoff_Check_list_Completed__c = false; 
                 
                  }
                  
                 
              }
              catch(Exception e)
              {
                  System.debug('No Pending Actions');
              } 
          } 
          return null;    
    }
     /*
     public PageReference sendHandoffEmail() {   
        
         errorFields = '';
         if (pmproject.Handoff_Checklist_Status__c != 'Verified' ) {
                errorFields += '[1][comm]';
         }
        
         if(errorFields == ''){ 
             pmproject.Handoff_Checklist_Status__c = 'Handoff Email Sent';     
             pmproject.Handoff_Email_Sent_Date__c = System.today()+1; 
             //controller.save();     
         }
         
         //String emailurl = '/_ui/core/email/author/EmailAuthor?template_id=00Xc0000000M7OE&rtype=003&isdtp=vw&p3_lkid='+pmproject.Sales_Order__r.AccountId__c+'&p2_lkid='+getContactId()+'&p4=customercare@astrumsolar.com1&retURL=/apex/ProjectHandoff?id='+pmproject.Id';
         //PageReference emailPage = new PageReference(emailurl ); 
         //emailPage.setRedirect(true); 
         return null;
         
         
    }
    
    */
    public PageReference savePage() {
        System.debug('*Save called');
        Savepoint sp = Database.setSavepoint();
      
        try {
            
            if(!pmproject.Handoff_Check_list_completed__c)
            {
                //PageReference pg = checkListCompleted();
                controller.save();
            }    
            return null;
            //controller.view();            
        } catch (Exception e) {
            System.debug('*Error '+e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            Database.rollback(sp);
            return null;
        }
    }
    /*
    public List<SelectOption> systemLocations{
        get {
            List<SelectOption> result = new List<SelectOption>();
            
            Schema.DescribeFieldResult systemLocation = PM_Project__c.Handoff_System_Location__c.getDescribe();
            for (Schema.PicklistEntry ple : systemLocation.getPickListValues()) {
                result.add(new SelectOption(ple.getValue(), ple.getLabel()));
            }
            return result;
        }
    }
    
    public List<SelectOption> internetTypes{
        get {
            List<SelectOption> result = new List<SelectOption>();
            
            Schema.DescribeFieldResult systemLocation = PM_Project__c.Handoff_Type_of_Internet_Access__c.getDescribe();
            result.add(new SelectOption('', '--Select--'));
            for (Schema.PicklistEntry ple : systemLocation.getPickListValues()) {                
                result.add(new SelectOption(ple.getValue(), ple.getLabel()));
            }
            return result;
        }
    }
    
    public List<SelectOption> bridgeInstallTypes{
        get {
            List<SelectOption> result = new List<SelectOption>();
            
            Schema.DescribeFieldResult systemLocation = PM_Project__c.Handoff_Bridge_Type__c.getDescribe();
            result.add(new SelectOption('', '--Select--'));
            for (Schema.PicklistEntry ple : systemLocation.getPickListValues()) {                
                result.add(new SelectOption(ple.getValue(), ple.getLabel()));
            }
            return result;
        }
    }
    
    public List<SelectOption> envoyLocations{
        get {
            List<SelectOption> result = new List<SelectOption>();
            
            Schema.DescribeFieldResult envoyLocation = PM_Project__c.Handoff_Envoy_Location__c.getDescribe();
            result.add(new SelectOption('', '--Select--'));
            for (Schema.PicklistEntry ple : envoyLocation.getPickListValues()) {                
                result.add(new SelectOption(ple.getValue(), ple.getLabel()));
            }
            return result;
        }
    }
    
    public List<SelectOption> outletBreakers{
        get {
            List<SelectOption> result = new List<SelectOption>();
            
            Schema.DescribeFieldResult envoyLocation = PM_Project__c.Handoff_Dedicate_Outlet_Breaker_Location__c.getDescribe();
            result.add(new SelectOption('', '--Select--'));
            for (Schema.PicklistEntry ple : envoyLocation.getPickListValues()) {                
                result.add(new SelectOption(ple.getValue(), ple.getLabel()));
            }
            return result;
        }
    }
    
    public List<SelectOption> gradeMeterTypes{
        get {
            List<SelectOption> result = new List<SelectOption>();
            
            Schema.DescribeFieldResult envoyLocation = PM_Project__c.Handoff_Revenue_Grade_Meter_Type__c.getDescribe();
            result.add(new SelectOption('', '--Select--'));
            for (Schema.PicklistEntry ple : envoyLocation.getPickListValues()) {                
                result.add(new SelectOption(ple.getValue(), ple.getLabel()));
            }
            return result;
        }
    }
    */

}