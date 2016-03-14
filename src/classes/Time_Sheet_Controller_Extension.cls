public class Time_Sheet_Controller_Extension {
    
    private final Time_Sheet__c timeSheet; 
    public List<Time_Sheet_Entry__c> entries{get;set;}
     
    private void LoadData(){
        this.entries = [SELECT id, name, Time_Sheet__c, Project_Client_Job__c,Timesheet_Purpose__c, Purpose__c, Start_Time__c, Start_Time_On_Site__c, Start_Time_Off_Site__c, End_Time__c, Stayed_Overnight__c, Hotel_Cost__c, Half_Hour_Lunch_Break__c, Total_Hours__c, Bonus_Type__c, Maintenance_Type__c 
        FROM Time_Sheet_Entry__c WHERE Time_Sheet__c=:this.timeSheet.id And Posted__c = false];
    
    }
    
    public Time_Sheet_Controller_Extension(ApexPages.StandardController stdController) {
        this.timeSheet = (Time_Sheet__c)stdController.getRecord();
        LoadData();
    }
    
    public PageReference doAddEntry(){
        Time_Sheet_Entry__c tse = new Time_Sheet_Entry__c();
        tse.Time_Sheet__c = this.timeSheet.id;
        if(this.entries.size()>0){
            Time_Sheet_Entry__c cp = this.entries.get(this.entries.size()-1);
            tse.Project_Client_Job__c = cp.Project_Client_Job__c;
            tse.Timesheet_Purpose__c=cp.Timesheet_Purpose__c;
            tse.Purpose__c=cp.Purpose__c;
            tse.Start_Time__c=cp.Start_Time__c;
            tse.Start_Time_On_Site__c=cp.Start_Time_On_Site__c;
            tse.Start_Time_Off_Site__c=cp.Start_Time_Off_Site__c;
            tse.End_Time__c=cp.End_Time__c;
            tse.Half_Hour_Lunch_Break__c = cp.Half_Hour_Lunch_Break__c;
        }
        this.entries.add(tse);
        return null;
    }
    
    public PageReference doSaveEntries(){
        try{
            upsert this.entries;
        } Catch (DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
        LoadData();
        return new PageReference('/'+ApexPages.currentPage().getParameters().get('id'));
    }
    
    public PageReference doCancel(){
        return new PageReference('/'+ApexPages.currentPage().getParameters().get('id'));
    }
}