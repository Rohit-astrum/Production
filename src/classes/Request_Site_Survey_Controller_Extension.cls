//10/26/2012 TCM - replace notes with comments
public class Request_Site_Survey_Controller_Extension {

	private Opportunity theOpportunity;
	
	public Task theTask {get; set;}
	
    public Request_Site_Survey_Controller_Extension(ApexPages.StandardController stdController) {
        theOpportunity = (Opportunity) stdController.getRecord();
                
        theTask = new Task();
    }
		
   	public PageReference submit() {

		theOpportunity.Date_Site_Survey_Requested__c = Datetime.now();
		update theOpportunity;
				
		String comments = theTask.Description;
		String siteSurveyType = theTask.Site_Survey_Type__c;
		Date requestedDate = theTask.Requested_Date__c;
		Boolean highPriority = theTask.High_Priority__c;
						
		Request_Site_Survey_Utility.submitRequest(theOpportunity.Id, comments, siteSurveyType, requestedDate, highPriority);
		
		//  After Save, navigate to the default view page:  
	    return (new ApexPages.StandardController(theOpportunity)).view();
	}    
	
}