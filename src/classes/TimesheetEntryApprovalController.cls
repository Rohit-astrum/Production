public with sharing class TimesheetEntryApprovalController {

	
    private final Time_Sheet__c timeSheet; 
    public List<Time_Sheet_Entry__c> entries{get;set;}
    public List<TimesheetEntryWrapper> wrappers {get; set;}

    public TimesheetEntryApprovalController(ApexPages.StandardController stdController) {
        this.timeSheet = (Time_Sheet__c)stdController.getRecord();
        List<Time_Sheet_Entry__c> entries = [SELECT id, name, Approved__c,Approval_date__c,Approved_By__c,Time_Sheet__c, Project_Client_Job__r.Name
        											,Timesheet_Purpose__r.name, Start_Time__c, Start_Time_On_Site__c, Start_Time_Off_Site__c, End_Time__c, Stayed_Overnight__c
        											,Hotel_Cost__c, Half_Hour_Lunch_Break__c, Total_Hours__c, Bonus_Type__c, Maintenance_Type__c 
       										   FROM Time_Sheet_Entry__c 
       										  WHERE Time_Sheet__c=:this.timeSheet.id And Approved__c = false order by Name ];
        wrappers=new List<TimesheetEntryWrapper>();
		for (Time_Sheet_Entry__c tse : entries )
		{
			wrappers.add(new TimesheetEntryWrapper(tse.Approved__c,tse));
		}
    }

    public PageReference approveEntries()
	{
		System.debug('Calling Approve '+wrappers);
		List<Time_Sheet_Entry__c> tsentries =new List<Time_Sheet_Entry__c>();
		for (TimesheetEntryWrapper wtse : wrappers)
		{
			System.debug('Calling Approve sele '+wtse.selected);
			if(wtse.selected)
			{
				wtse.tse.approved__c = true;
				wtse.tse.Approval_Date__c = System.now();
				wtse.tse.Approved_By__c = UserInfo.getUserId();
				tsentries.add(wtse.tse);
			}
		}

		if(tsentries.size() > 0)
		{
			update tsentries;
			return new PageReference('/' + timeSheet.Id );
		}
		else
		{
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select at lease one Entry to Approve');
			ApexPages.addMessage(myMsg);
			return null;
		}

		//return new PageReference('/' + timeSheet.Id );
	}

   
	
    public class TimesheetEntryWrapper
 	{
  		public Time_Sheet_Entry__c tse {get; set;}

  		public boolean selected {get; set;}
   
		public TimesheetEntryWrapper(Boolean  inselected, Time_Sheet_Entry__c intse)
		{
			selected=inselected;
			tse =intse;
		}
 	}

}