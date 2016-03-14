public with sharing class Sales_Visit_Complete_Controller_Ext {

	private Event theEvent;
	
    public Sales_Visit_Complete_Controller_Ext(ApexPages.StandardController stdController) {
        theEvent = (Event) stdController.getRecord();        
    }

   public PageReference updateEvent() {

		if (theEvent != null) {
	        // update the event
	        theEvent.Completed__c = true;        
	        
	        update theEvent;
	
			Event tempEvent = [select OwnerId, whatId, Related_Property_Link__c from Event where id =:theEvent.id limit 1];
			
			// send notification email
			Sales_Visit_Complete_Utility.sendNotificationEmail(tempEvent);        		
		}
		
		//  After Save, navigate to the default view page:  
	    return (new ApexPages.StandardController(theEvent)).view();
	}    

}