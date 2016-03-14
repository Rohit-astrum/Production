trigger Time_Sheet_Entry_Total_Hours_Trigger on Time_Sheet_Entry__c (before insert, before update, after update) {    
   
    Map<Id,Time_Sheet__c> timeSheetsPrj = new Map<Id,Time_Sheet__c>();
    Map<Id,Install_Project__c> instProjects ;
    Map<Id,Time_Sheet__c> timeSheets;
    Map<Id,Timesheet_Purpose__c> timeSheetPurpose;

    
    List<Id> oldProjId = new List<Id>();

    set<Id> instProjectIds = new Set<Id>();
    set<Id> timeSheetIds = new Set<Id>();


    for(Time_Sheet_Entry__c rec : Trigger.new){
        //if(Trigger.isBefore && (Trigger.isInsert||Trigger.isUpdate)){
        if (rec.Project_Client_Job__c != null)
        {
            instProjectIds.add(rec.Project_Client_Job__c);    
        }
        timeSheetIds.add(rec.Time_Sheet__c);
        //}    
    }    

    if(instProjectIds.size() > 0)
    {
        instProjects = new Map<Id,Install_Project__c>([Select id, Complete2__c, Date_Completed2__c from Install_Project__c Where id in :instProjectIds]);
    }
    if(timeSheetIds.size() > 0)
    {
        timeSheets = new Map<Id,Time_Sheet__c>([Select id, Employee__r.Job_Title__c, Employee__r.Employee_Class__c FROM Time_Sheet__c Where id in :timeSheetIds]);  
        timeSheetPurpose = new Map<Id,Timesheet_Purpose__c>([Select id, Name FROM Timesheet_Purpose__c ]);
    }
    
    for(Time_Sheet_Entry__c rec : Trigger.new){
        if(Trigger.isBefore && (Trigger.isInsert||Trigger.isUpdate)){
            
          
            
            Boolean isComplete;
            Date dateComplete;
            Install_Project__c instProj;
            
            system.debug('** Before '+rec.Project_Client_Job__c);
            
            if (rec.Project_Client_Job__c != null && instProjects.get(rec.Project_Client_Job__c) != null){
                System.debug('rec.Project_Client_Job__c '+rec.Project_Client_Job__c);
                instProj = instProjects.get(rec.Project_Client_Job__c);
                isComplete = instProj.Complete2__c;
                dateComplete = instProj.Date_Completed2__c;
            }
            
            //set Bonus_Type__c as INSTALLER or ELECTRICIAN
            /*
            if(rec.Purpose__c != null && rec.Purpose__c == 'Install'){
                rec.Bonus_Type__c='INSTALLER';
            } else if (rec.Purpose__c != null && rec.Purpose__c == 'Install-Electrical'){
                rec.Bonus_Type__c='ELECTRICIAN';
            } else {
                rec.Bonus_Type__c='OTHER';
            }
            */
            System.debug(rec.Timesheet_Purpose__c + ' ' +rec.Timesheet_Purpose__r.Name);
            if(rec.Timesheet_Purpose__c != null && timeSheetPurpose.get(rec.Timesheet_Purpose__c).Name == 'Install'){
                rec.Bonus_Type__c='INSTALLER';
            } else if (rec.Timesheet_Purpose__c != null && timeSheetPurpose.get(rec.Timesheet_Purpose__c).Name =='Install-Electric'){
                rec.Bonus_Type__c='ELECTRICIAN';
            } else {
                rec.Bonus_Type__c='OTHER';
            }
            
            //set Maintenance_Type__c as PRE-30 or POST-30 or N/A
            //IF(ISPICKVAL(Purpose__c,'Maintenance'),IF(Project_Client_Job__r.Complete__c,IF( Start_Time__c <=DATETIMEVALUE( Project_Client_Job__r.Date_Completed__c +30),'PRE-30','POST-30'),'PRE-30'),'N/A')
            if(rec.Timesheet_purpose__c!=null && timeSheetPurpose.get(rec.Timesheet_Purpose__c).Name=='Maintenance'){
                System.debug('Project Complete -->' + rec.Project_Client_Job__r.Complete2__c);
                System.debug('Project Complete Date -->' +  rec.Project_Client_Job__r.Date_Completed2__c);
                if(isComplete!=null&&isComplete&&dateComplete!=null){
                    
                    Date stop = dateComplete.addDays(30);
                    Time stpT = Time.newInstance(0,0,0,0);
                    DateTime stopDT = DateTime.newInstance(stop,stpT);
                    
                    if( rec.Start_Time__c!=null && rec.Start_Time__c>stopDT ){
                       rec.Maintenance_Type__c='POST-30'; 
                    } else {
                       rec.Maintenance_Type__c='PRE-30';
                    }                    
                } else {
                    rec.Maintenance_Type__c='PRE-30';
                }
                
            } else {
                rec.Maintenance_Type__c='N/A';
            }

            // 3/20/2015 - SZ: Added code to set the Half_Hour_Lunch_Break__c for the "Inside Sales - NP" employee class
            if(timesheets.get(rec.Time_Sheet__c).Employee__r.Employee_Class__c == 'Inside Sales - NP'){
                rec.Half_Hour_Lunch_Break__c = 'Yes';
            }
            else{
                rec.Half_Hour_Lunch_Break__c = 'No';
            }
            
            if(rec.Start_Time__c!=null&&rec.End_Time__c!=null&&rec.End_Time__c.isSameDay(rec.Start_Time__c)){
                Long diff =(rec.End_Time__c.getTime() - rec.Start_Time__c.getTime());
                rec.Total_Hours__c = diff/(1000*60*60*1.00);
                if(rec.Half_Hour_Lunch_Break__c=='Yes'){
                    rec.Total_Hours__c -= 0.5;
                }
               
            }
        }    
        
        // Added by RJ for Zen - 84 bug Fix
        if(Trigger.isAfter && Trigger.isUpdate){    
           system.debug('** After '+rec.Project_Client_Job__c + ' - '+Trigger.OldMap.get(rec.Id).Project_Client_Job__c);
          
           if ((rec.Project_Client_Job__c != Trigger.OldMap.get(rec.Id).Project_Client_Job__c) || (rec.Timesheet_purpose__c != Trigger.OldMap.get(rec.Id).Timesheet_purpose__c) )
           {
              //System.debug('**Project Update -> '+rec.Time_Sheet__r.Id + '  '+timeSheets.get(rec.Time_Sheet__r.Id)  );

              // 3/19/2015 - SZ: Since this is in a loop, make sure we aren't attempting to insert duplicates in the map
                if(!timeSheetsPrj.containsKey(rec.Time_Sheet__c)){
                    timeSheetsPrj.put(rec.Time_Sheet__c, timeSheets.get(rec.Time_Sheet__c));
                    if(Trigger.OldMap.get(rec.Id).Project_Client_Job__c != null)
                    {
                        oldProjId.add(Trigger.OldMap.get(rec.Id).Project_Client_Job__c); 
                    }
                }
            }
            // 3/19/2015 - SZ: Move outside the loop over Trigger.new to avoid "Too many SOQL" error
            /*
            System.debug('**Project Update Size'+timeSheetsPrj.size());
            if (timeSheetsPrj.size() > 0) {
               
              
                Time_Sheet_Trigger_Utility.computeHoursAndPay(timeSheetsPrj,oldProjId);
               
            }
            */
        }
        
        
    }

    System.debug('**Project Update Size'+timeSheetsPrj.size());
    if(Trigger.isAfter && Trigger.isUpdate && timeSheetsPrj.size() > 0) {
        Time_Sheet_Trigger_Utility.computeHoursAndPay(timeSheetsPrj,oldProjId);
    }
    
}