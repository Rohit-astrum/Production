public with sharing class AstrumEventToScheduleController {

    public Astrum_Event__c astrumEvent;
    public boolean hideForm {get;set;}
    public boolean showSuccessNav {get;set;}    
    //public string startDateTimeString{get;set;}
    //public string stopDateTimeString{get;set;}    
    //public TimeZone localTZ{get;set;} //Timezone local to the customer/Sales person        

    //private string tzID;
    private string retURL;
    private string successURL = '/';
    
    public AstrumEventToScheduleController(ApexPages.StandardController stdController) {
        this.astrumEvent = (Astrum_Event__c)stdController.getRecord();
        hideForm = false;

        Map<String,String> params = ApexPages.currentPage().getParameters();
        retURL = params.get('retURL');        
        if(retURL == null){
            retURL = '/';
        }else{
            retURL = EncodingUtil.urlDecode(retURL, 'UTF-8');
        }

        //Verify that this event is ready for scheduling
        if(astrumEvent.Status__c == null || astrumEvent.Status__c != 'Schedule Pending'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to schedule this Astrum Event because the status is not in the "Schedule Pending" state.'));
            hideForm = true;
            return;
        }

        //Format the date/time for the customer local time.
        //If linked to an Opportunity
        if(astrumEvent.Opportunity__c != null){
            successURL = '/' + astrumEvent.Opportunity__c;
            //if(astrumEvent.Opportunity__r.Property__r.Time_Zone__c == null){
            //    hideForm = true;
            //    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to schedule for this Property because the Time Zone can not be calculated for the property\'s state'));
            //    return;
            //}
            ////localTZ = TimeZone.getTimeZone(astrumEvent.Opportunity__r.Property__r.Time_Zone__c);            
            //tzID = astrumEvent.Opportunity__r.Property__r.Time_Zone__c
            
        }else if(astrumEvent.Lead__c != null){
            successURL = '/' + astrumEvent.Lead__c;
            //if(astrumEvent.Lead__r.Time_Zone__c == null){
            //    hideForm = true;
            //    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to schedule for this Lead because the Time Zone can not be calculated for the Lead\'s state'));
            //    return;
            //}
            ////localTZ = TimeZone.getTimeZone(astrumEvent.Lead__r.Time_Zone__c);
            //tzID = astrumEvent.Lead__r.Time_Zone__c;
        }

        /*
            Set the local time zone object
            http://salesforce.stackexchange.com/questions/8538/convert-time-from-a-different-timezone-other-than-local-to-gmt
            string customerTimeZoneSidId = 'America/Los_Angeles';

            TimeZone customerTimeZone = TimeZone.getTimeZone(customerTimeZoneSidId);
            System.assertEquals('Pacific Standard Time',  customerTimeZone.getDisplayName());
        */  
        //try{           
        //    tzID = localTZ.getID();
        //}catch(exception e){
        //    hideForm = true;
        //    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to set the local time zone: ' + e));
        //    return; 
        //}

        //startDateTimeString = astrumEvent.Start_Date_Time__c.format('M/d/yyyy h:mm a zzzzz', tzID);
        //stopDateTimeString = astrumEvent.Stop_Date_Time__c.format('M/d/yyyy h:mm a zzzzz', tzID);

    }

    public pagereference save(){
        
        //Validation
        if(astrumEvent.Subject__c == null || astrumEvent.get('Notes__c') == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill in required fields.'));
            return null;
        }

        //Set to scheduled
        astrumEvent.Status__c = 'Scheduled';

        //DML
        try{
            update astrumEvent;
        }catch(exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error upon save: ' + e));
            return null;
        }


        //Set the linked Opp stage to "Sales Visit Scheduled"
        if(astrumEvent.Opportunity__c != null){
            Opportunity opp = new Opportunity(id = astrumEvent.Opportunity__c);
            opp.stageName = 'Sales Visit Scheduled';
            //DML
            try{
                update opp;
            }catch(exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error upon saving the new Opportunity stage: ' + e));
                return null;
            }
        }

        //Display Success
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'This event was scheduled and an email has been sent.'));
        hideForm = true;
        showSuccessNav = true;
        return null;
    }

    public pagereference successFinish(){
                
        PageReference pageRef = new PageReference(successURL);
        return pageRef;
    }

    public pagereference cancel(){
        
        astrumEvent.Status__c = 'Schedule Pending - Cancelled';

        //DML
        try{
            update astrumEvent;
        }catch(exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error upon cancel: ' + e));
            return null;
        }
        
        PageReference pageRef = new PageReference(retURL);        
        return pageRef;
    }
    
}