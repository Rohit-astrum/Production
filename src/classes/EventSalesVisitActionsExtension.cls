public class EventSalesVisitActionsExtension {

  private Event theEvent;
  public String parentDomain{get;set;}
  public String selectedReason {get; set;}
  public String errorFields { get; private set; }
  public String manageUpdate{ get; private set; }
  
   public EventSalesVisitActionsExtension (ApexPages.StandardController stdController) {
        theEvent = (Event) stdController.getRecord();   
        parentDomain = ApexPages.currentPage().getHeaders().get('referer');     
   }
   public List<SelectOption> notCompleteReasons{
        get { 
            List<SelectOption> result = new List<SelectOption>();
            result.add(new SelectOption('', '-- Select Reason --'));
            result.add(new SelectOption('Disqualified', 'Disqualified'));
            result.add(new SelectOption('Missed', 'Missed'));
            result.add(new SelectOption('Canceled by Customer', 'Canceled by Customer (*Event will be removed from Calendar.)'));
            result.add(new SelectOption('Customer No-Show', 'Customer No-Show (*Event will be removed from Calendar.)'));
            
            return result;         
        }
   }
   
   public List<SelectOption> disqOptions{
        get { 
            List<SelectOption> result = new List<SelectOption>();
            result.add(new SelectOption('', '-- Select --'));
            result.add(new SelectOption('Approve', 'Approve (*Event will be removed from Calendar.)'));
            result.add(new SelectOption('Reject', 'Reject'));
            return result;         
        }
   }
   
   public PageReference updateEventNotComplete() {
    
    set<string> eventStatusToDelete = new set<string>{'Customer No-Show', 'Disqualified-Approved', 'Canceled by Customer'};

    if (theEvent != null) {
        System.debug('**selectedReason '+selectedReason);
        errorFields = '';
        if (String.isBlank(selectedReason)) {            
            errorFields += '[1][reason]';
            return null;
        }
        else {
            if(selectedReason == 'Disqualified')
            {
                theEvent.Disqualified_Date__c = System.Now();  
                theEvent.Event_Status__c = selectedReason; 
                
                Event tempEvent = [select Subject,OwnerId, whatId, Related_Property_Link__c from Event where id =:theEvent.id limit 1];
      
                //send notification email to Manager for Disqualification Approval
                Sales_Visit_Complete_Utility.sendNotificationEmail(tempEvent,selectedReason );    
            
            }
            else if(selectedReason == 'Missed')
            {
                theEvent.Missed_Date__c = System.Now();  
                theEvent.Event_Status__c = selectedReason ; 
                theEvent.Ever_Been_Missed__c = true;
                Event tempEvente = [select StartDateTime from Event where id =:theEvent.id limit 1];
               // Date myDate = date.newinstance(tempEvente.StartDateTime.year(), tempEvente.StartDateTime.month(), tempEvente.StartDateTime.day());
                Datetime dt = datetime.newInstance(tempEvente.StartDateTime.year(), tempEvente.StartDateTime.month(), tempEvente.StartDateTime.day());
                theEvent.StartDateTimeCopy__c = dt;
            }
            else if(selectedReason == 'Canceled by Customer')
            {
                theEvent.Canceled_by_Customer_Date__c = System.Now();  
                theEvent.Event_Status__c = selectedReason ; 
            } 
            else if(selectedReason == 'Customer No-Show')
            {
                theEvent.Customer_No_Show_Date__c = System.Now();  
                theEvent.Event_Status__c = selectedReason ; 
            } 
            else if(selectedReason == 'Approve')
            {
                theEvent.Disqualified_Approved_Date__c = System.Now();  
                theEvent.Event_Status__c = 'Disqualified-Approved'; 
                manageUpdate = 'true';
            }
            else if(selectedReason == 'Reject')
            {
                theEvent.Disqualified_Rejected_Date__c = System.Now();  
                theEvent.Event_Status__c = 'Missed'; 
                manageUpdate = 'true';
            }
            theEvent.run_trigger__c = true;     
            update theEvent;
        }
                  
    }    
    //  After Save, navigate to the default view page:  
    /*if(eventStatusToDelete.contains(selectedReason))
    {
        PageReference pageRef;
        pageRef = new PageReference('/');            
        return pageRef; 
    }*/
    return null;
  }    
  
  public PageReference rescheduleEvent() {

    if (theEvent != null) {
        theEvent.Rescheduled_Date__c     = System.Now();  
        theEvent.Event_Status__c         = 'Rescheduled'; 
        theEvent.completed__c = true;
        theEvent.run_trigger__c = true; 
        update theEvent;        
        
        Event tempEvent = [select whoId,RecordTypeId,Subject,OwnerId, whatId
                                 ,Related_Property_Link__c,DurationInMinutes
                                 ,ActivityDateTime
                             from Event where id =:theEvent.id limit 1];
        
        Event newEvent = new event();
        newEvent.subject = tempEvent.Subject;
        newevent.Related_Property_Link__c =  tempEvent.Related_Property_Link__c;
        newevent.RecordTypeId =  tempEvent.RecordTypeId;
        newevent.DurationInMinutes =  tempEvent.DurationInMinutes;
        newevent.whatId =  tempEvent.whatId;
        newevent.ActivityDateTime=  tempEvent.ActivityDateTime;
        newevent.Event_Status__c         = 'Scheduled'; 
        newEvent.whoID = tempEvent.whoId; //MK - 2014-06-16 - copying the linked contact
        
        insert newevent;
        
        PageReference newPage;
 
        newPage = new PageReference('/' + newevent.id + '/e');
        //newPage.getParameters().put('nooverride', '1');
        //newPage.getParameters().put('id', newevent.id);
        newPage.getParameters().put('retURL', tempEvent.whatId);
 
        return newPage.setRedirect(true);
        //return  urlFor($Action.event.Edit, newevent.id, null, true)
        // return (new ApexPages.StandardController(newevent)).view();
        
    }    
    //  After Save, navigate to the default view page:  
   
    return (new ApexPages.StandardController(theEvent )).edit();
  }    

}