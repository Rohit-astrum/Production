/* FILE: TimeSheetLaborEntryProcessor.cls
 * AUTHOR: Pavitra Burla
 * DATE: Jan 22, 2015
 * PURPOSE: Create Labor Entries for corresponding Time Sheet Entries.
 * MODIFICATION HISTORY
 * 04/03/2015 SZ - Update code to retrieve the correct office state based on Home_Office_c changing to a lookup instead of a picklist
 * 06/23/2015 PB - Added filter for CreatedDate to the query
 * 09/11/2015 PB - FPO-Phase4  
*/
global virtual class TimeSheetLaborEntryProcessor implements Schedulable{
    
    private Map<String,Id> workOrdOpnsMap;
    private Map<Decimal,Id> sysUsrsMap;
    private Map<String,Time_Sheet_Entry__c> workOrdOpnTimeMap;
    private List<TimeSheet_Labor_Entry__c> empRegLbrEntries;
    private List<TimeSheet_Labor_Entry__c> empOTLbrEntries;
    private List<EmpLbr> empLbrs;
    private Decimal totRegWeekHrs;
    private Decimal dayHrsCounter;
    private Id currentEmp;
    private Date currentEntryDate;
    private Integer dayCounter;        
    //private String query;
    private String errors;
    
    public TimeSheetLaborEntryProcessor(){
    /*    System.debug('TimeSheetLaborEntryProcessor*----constructor start');
        dayHrsCounter = 0;
    	currentEmp = NULL;
        currentEntryDate = NULL;
        dayCounter = 0;
        totRegWeekHrs = 0;
        empLbrs =  new List<EmpLbr>();
        workOrdOpnTimeMap = new Map<String,Time_Sheet_Entry__c>(); 
        
        List<rstk__woordop__c> workOrdOpns = ([SELECT Id, rstk__externalid__c, rstk__woordop_ordno__c FROM rstk__woordop__c]);        
        workOrdOpnsMap = new Map<String,Id>();        
        for(rstk__woordop__c workOrdOpn : workOrdOpns){
            workOrdOpnsMap.put(workOrdOpn.rstk__externalid__c,workOrdOpn.Id);            
        }
        
        List<rstk__syusr__c> sysUsrs = [SELECT Id, rstk__syusr_clockno__c FROM rstk__syusr__c];        
        sysUsrsMap = new Map<Decimal,Id>();        
        for(rstk__syusr__c sysUsr : sysUsrs){
            sysUsrsMap.put(sysUsr.rstk__syusr_clockno__c, sysUsr.Id);            
        }
        
        System.debug('TimeSheetLaborEntryProcessor*----constructor End');*/
        
    }    
    
    public void processLabor(String queryStr){
        
        System.debug('TimeSheetLaborEntryProcessor*----Process labor start');
        //Declare counters
        Decimal totHrsUnAssigned = 0;
        Decimal hrsAssigned = 0;        
        String officeState = NULL;
        
        System.debug('TimeSheetLaborEntryProcessor*----Process labor step1 -- Query entries');
        List<Time_Sheet_Entry__c> timeSheetEntries = new List<Time_Sheet_Entry__c>();
        try{
        	 timeSheetEntries = Database.query(queryStr);
        }catch(Exception e){
            System.debug('Exception in getting the timesheet entries ***' + e.getCause() + e.getMessage() + e.getStackTraceString());
            
        }
        System.debug('TimeSheetLaborEntryProcessor*----result timesheet entries size:' + timeSheetEntries.size());
        
        List<TimeSheet_Labor_Entry__c> laborEntries = new List<TimeSheet_Labor_Entry__c>();
		List<Time_Sheet_Entry__c> processedTimeSheetEntries = new List<Time_Sheet_Entry__c>();        
        
        //Initialize variables and Maps
        dayHrsCounter = 0;
        currentEmp = NULL;
        currentEntryDate = NULL;
        dayCounter = 0;
        totRegWeekHrs = 0;
        empLbrs =  new List<EmpLbr>();
        workOrdOpnTimeMap = new Map<String,Time_Sheet_Entry__c>();
        workOrdOpnsMap = new Map<String,Id>();
        Set<Id> workOrdsSet = new Set<Id>();
        List<rstk__woordop__c> workOrdOpns = new List<rstk__woordop__c>();
        
        List<rstk__syusr__c> sysUsrs = [SELECT Id, rstk__syusr_clockno__c FROM rstk__syusr__c];        
        sysUsrsMap = new Map<Decimal,Id>();        
        for(rstk__syusr__c sysUsr : sysUsrs){
            sysUsrsMap.put(sysUsr.rstk__syusr_clockno__c, sysUsr.Id);            
        }
        
        for(Time_Sheet_Entry__c timeSheetEntry:timeSheetEntries){
            workOrdsSet.add(timeSheetEntry.Project_Client_Job__r.Work_Order__c);
        }

        workOrdOpns = ([SELECT Id, rstk__externalid__c, rstk__woordop_ordno__c 
                            FROM rstk__woordop__c 
                            WHERE rstk__woordop_ordno__c IN:workOrdsSet]);        
        System.debug('TimeSheetLaborEntryProcessor*----workOrdOpns.size():' + workOrdOpns.size());        
        for(rstk__woordop__c workOrdOpn : workOrdOpns){
            workOrdOpnsMap.put(workOrdOpn.rstk__externalid__c,workOrdOpn.Id);            
        }
        //End of Initialization.


        System.debug('TimeSheetLaborEntryProcessor*----Process labor step2--- loop through timesheet entries');
        for(Time_Sheet_Entry__c timeSheetEntry:timeSheetEntries){
            if(getDiv(timeSheetEntry) == 10){
                workOrdOpnTimeMap.put(getWoorOpnExtId(timeSheetEntry, 10),timeSheetEntry);
                workOrdOpnTimeMap.put(getWoorOpnExtId(timeSheetEntry, 20),timeSheetEntry);
                workOrdOpnTimeMap.put(getWoorOpnExtId(timeSheetEntry, 30),timeSheetEntry);
                //FPO-Phase4// workOrdOpnTimeMap.put(getWoorOpnExtId(timeSheetEntry, 40),timeSheetEntry);
            }
            totHrsUnAssigned = timeSheetEntry.Total_Hours__c;
            hrsAssigned = 0;          
            
            if(timeSheetEntry.Time_Sheet__r.Employee__c != currentEmp){
                if(currentEmp != null){                    
                    empLbrs.add(new EmpLbr(
                        currentEmp
                        , empRegLbrEntries
                        , empOTLbrEntries
                        , totRegWeekHrs
                        , dayCounter
                        , officeState));
                    empRegLbrEntries = null;
                }
                //Reset counters for current employee
                dayCounter = 1;
                dayHrsCounter = 0;                
                currentEntryDate = timeSheetEntry.Entry_Date__c;                
            	currentEmp = timeSheetEntry.Time_Sheet__r.Employee__c;
                empRegLbrEntries = new List<TimeSheet_Labor_Entry__c>();
                empOTLbrEntries = new List<TimeSheet_Labor_Entry__c>();
                totRegWeekHrs = 0;
                System.debug(timeSheetEntry.Name + timeSheetEntry.Time_Sheet__r.Employee__c + ':New Employee');
            }else if(timeSheetEntry.Entry_Date__c != currentEntryDate){
                //Reset counter for current day
                currentEntryDate = timeSheetEntry.Entry_Date__c;
                dayHrsCounter = 0;
				dayCounter = dayCounter + 1;
				System.debug(timeSheetEntry.Name + timeSheetEntry.Time_Sheet__r.Employee__c + ':New Day');                
            }
            
            // Get the State__c field from the lookup
            //officeState = timeSheetEntry.Time_Sheet__r.Employee__r.Home_Office__c.split(',')[1];
            officeState = timeSheetEntry.Time_Sheet__r.Employee__r.Home_Office_Location__r.State__c;
            
            if(officeState.trim().equals('CA')){//Check if Employee office in CA 
                if(dayCounter == 7){

                    //FPO-Phase4 Do not book time for operations 30 and 40
                    //if(!timeSheetEntry.Timesheet_Purpose__r.name.equals('Maintenance') && !timeSheetEntry.Timesheet_Purpose__r.name.equals('Warranty Maintenance') &&
                        
                    if(!timeSheetEntry.Timesheet_Purpose__r.name.equals('Install') 
                       && !timeSheetEntry.Timesheet_Purpose__r.name.equals('Install-Electric')){
                           continue;                           
                       }
                    if(dayHrsCounter < 8){//Rate factor 1.5 bucket
                        if(totHrsUnAssigned > (8-dayHrsCounter)){
                            hrsAssigned = (8-dayHrsCounter);                            
                        }else{
                            hrsAssigned = totHrsUnAssigned;                        
                        }
                        TimeSheet_Labor_Entry__c laborEntry = createLaborEntry(timeSheetEntry,hrsAssigned,1.5);
                        empOTLbrEntries.add(laborEntry);
                        totHrsUnAssigned = totHrsUnAssigned - hrsAssigned;
                        dayHrsCounter = dayHrsCounter + hrsAssigned;
                    }
                    if(totHrsUnAssigned >0){//Rate factor 2 bucket
                        hrsAssigned = totHrsUnAssigned;
                        TimeSheet_Labor_Entry__c laborEntry = createLaborEntry(timeSheetEntry,hrsAssigned,2);
                        empOTLbrEntries.add(laborEntry);
                        totHrsUnAssigned = 0;
                        dayHrsCounter = dayHrsCounter + hrsAssigned;
                    }
                }else{//For days 1-6                    
                    if(dayHrsCounter < 8){//Rate factor 1 bucket
                        if(totHrsUnAssigned > (8-dayHrsCounter)){
                            hrsAssigned = (8-dayHrsCounter);
                        }else{
                            hrsAssigned = totHrsUnAssigned;                        
                        }
                        //FPO-Phase4 Do not book time for operations 30 and 40
                        //if(timeSheetEntry.Timesheet_Purpose__r.name.equals('Maintenance')|| timeSheetEntry.Timesheet_Purpose__r.name.equals('Warranty Maintenance')
                        
                        //Check for other                        
                        if(timeSheetEntry.Timesheet_Purpose__r.name.equals('Install') 
                           || timeSheetEntry.Timesheet_Purpose__r.name.equals('Install-Electric')){
                               totRegWeekHrs+= hrsAssigned;                               
                           }else{                               
                               totRegWeekHrs+= timeSheetEntry.Total_Hours__c;
                               //FPO Phase4
                               timeSheetEntry.Labor_Processed__c = true;
                               processedTimeSheetEntries.add(timeSheetEntry);
                               continue;
                           }
                        
                        TimeSheet_Labor_Entry__c laborEntry = createLaborEntry(timeSheetEntry,hrsAssigned,1);
                        empRegLbrEntries.add(laborEntry);
                        totHrsUnAssigned = totHrsUnAssigned - hrsAssigned;
                        dayHrsCounter = dayHrsCounter + hrsAssigned;
                    }
                    if((totHrsUnAssigned >0) && (dayHrsCounter<12)){//Rate factor 1.5 bucket
                        if(totHrsUnAssigned > (12-dayHrsCounter)){
                            hrsAssigned = (12-dayHrsCounter);
                        }else{
                            hrsAssigned = totHrsUnAssigned;                        
                        }
                        TimeSheet_Labor_Entry__c laborEntry = createLaborEntry(timeSheetEntry,hrsAssigned,1.5);
                        empOTLbrEntries.add(laborEntry);
                        totHrsUnAssigned = totHrsUnAssigned - hrsAssigned;
                        dayHrsCounter = dayHrsCounter + hrsAssigned;
                    }
                    if(totHrsUnAssigned >0){//Rate factor 2 bucket
                        hrsAssigned = totHrsUnAssigned;
                        TimeSheet_Labor_Entry__c laborEntry = createLaborEntry(timeSheetEntry,hrsAssigned,2);
                        empOTLbrEntries.add(laborEntry);
                        totHrsUnAssigned = 0;
                        dayHrsCounter = dayHrsCounter + hrsAssigned;                        
                    }                    
                }
            }else{//Assign default Rate Factor for all other states

                //FPO-Phase4 Do not book time for operations 30 and 40
                //if(timeSheetEntry.Timesheet_Purpose__r.name.equals('Maintenance')|| timeSheetEntry.Timesheet_Purpose__r.name.equals('Warranty Maintenance')
                        
                //Check for other 
                if(timeSheetEntry.Timesheet_Purpose__r.name.equals('Install') 
                   || timeSheetEntry.Timesheet_Purpose__r.name.equals('Install-Electric')){
                       totRegWeekHrs+= timeSheetEntry.Total_Hours__c;                               
                   }else{                               
                       totRegWeekHrs+= timeSheetEntry.Total_Hours__c;
                       //FPO Phase4
                       timeSheetEntry.Labor_Processed__c = true;
                       processedTimeSheetEntries.add(timeSheetEntry);
                       continue;
                   }
                hrsAssigned = totHrsUnAssigned;
                TimeSheet_Labor_Entry__c laborEntry = createLaborEntry(timeSheetEntry,hrsAssigned,1);
                empRegLbrEntries.add(laborEntry);                
            }
            timeSheetEntry.Labor_Processed__c = true;
            processedTimeSheetEntries.add(timeSheetEntry);
        }//End of for loop
        
        System.debug('TimeSheetLaborEntryProcessor*----Process labor step3 -- Update processed timesheetentries');
        update processedTimeSheetEntries;
        
        //Last Emp
        System.debug('CurrentEmployee:' + currentEmp);
        if(currentEmp != null){
            empLbrs.add(new EmpLbr(
                currentEmp
                , empRegLbrEntries
                , empOTLbrEntries
                , totRegWeekHrs
                , dayCounter
                , officeState));
        }        
		//Check for weekly overtime (Above 40 hrs)
		System.debug('TimeSheetLaborEntryProcessor*----Process labor step4 -- Check for weekly overtime (Above 40 hrs)');
        for(EmpLbr empLbr: empLbrs){
            if(empLbr.overtimeHrs > 0){
                Decimal overtimeHrsCounter = empLbr.overtimeHrs;
                if(empLbr.officeState.equalsIgnoreCase('CA') && (empLbr.regLbrEntries.size()>0)){
                    //Loop through regularlabor entries backwards from Saturday - Monday
                    Integer startDay = (empLbr.numOfDaysWorked == 7)?(empLbr.regLbrEntries.size()-2):(empLbr.regLbrEntries.size()-1);
                    for(Integer i = startDay; i>=0 && overtimeHrsCounter>0  ; i--){
                        if(overtimeHrsCounter >= empLbr.regLbrEntries[i].Labor_Booking_Hours__c){
                            //Update for Overtime
                            empLbr.regLbrEntries[i].Rate_Factor__c = 1.5;
                            overtimeHrsCounter = overtimeHrsCounter - empLbr.regLbrEntries[i].Labor_Booking_Hours__c;
                        }else{
                            //Create new labor entry
							TimeSheet_Labor_Entry__c newLaborEntry = empLbr.regLbrEntries[i].clone(false,true,false,false);
                            newLaborEntry.Labor_Booking_Hours__c = empLbr.regLbrEntries[i].Labor_Booking_Hours__c - overtimeHrsCounter;
                            newLaborEntry.Rate_Factor__c = 1;
                            empLbr.oTLbrEntries.add(newLaborEntry);
                            //Update the existing for overtime
                            empLbr.regLbrEntries[i].Rate_Factor__c = 1.5;
                            empLbr.regLbrEntries[i].Labor_Booking_Hours__c = overtimeHrsCounter;
                            overtimeHrsCounter = 0;							                            
                        }
                    }
                }else{// For other states
                    //Loop through regularlabor entries backwards from Saturday - Monday
                    Integer startDay = (empLbr.regLbrEntries.size()-1);
                    for(Integer i = startDay;  overtimeHrsCounter>0 && i>=0 ; i--){
                        if(overtimeHrsCounter >= empLbr.regLbrEntries[i].Labor_Booking_Hours__c){
                            //Update for Overtime
                            empLbr.regLbrEntries[i].Rate_Factor__c = 1.5;
                            overtimeHrsCounter = overtimeHrsCounter - empLbr.regLbrEntries[i].Labor_Booking_Hours__c;
                        }else{
                            //Create new labor entry
							TimeSheet_Labor_Entry__c newLaborEntry = empLbr.regLbrEntries[i].clone(false,true,false,false);
                            newLaborEntry.Labor_Booking_Hours__c = empLbr.regLbrEntries[i].Labor_Booking_Hours__c - overtimeHrsCounter;
                            newLaborEntry.Rate_Factor__c = 1;
                            empLbr.oTLbrEntries.add(newLaborEntry);
                            //Update the existing for overtime
                            empLbr.regLbrEntries[i].Rate_Factor__c = 1.5;
                            empLbr.regLbrEntries[i].Labor_Booking_Hours__c = overtimeHrsCounter;
                            overtimeHrsCounter = 0;							                            
                        }
                    }
                }//End of else
            }
        }
        for(EmpLbr empLbr: empLbrs){
            //Reg entries
            laborEntries.addAll(empLbr.regLbrEntries);
            //Over time entries
            laborEntries.addAll(empLbr.oTLbrEntries);
        }
        System.debug('TimeSheetLaborEntryProcessor*----Process labor step -- Create Labor Entry for Qty');             
        for(String woorOpnExtId: getSortedKeySet(workOrdOpnTimeMap.keySet())){
            //Create Labor Entry for Qty
            if(!String.isBlank(getWoorOpn(woorOpnExtId)))
            laborEntries.add(createLaborEntry(woorOpnExtId, workOrdOpnTimeMap.get(woorOpnExtId)));
        }
	        
        System.debug('TimeSheetLaborEntryProcessor*----Process labor step -- insert labor entries');
        //Insert labor time Entries
        Database.SaveResult[] results;
        if(!laborEntries.isEmpty()){
            results = Database.insert(laborEntries,false);
            for (Database.SaveResult result : results) {
                if (!result.isSuccess()) {
                    // Operation failed, so get all errors                
                    for(Database.Error err : result.getErrors()) {
                        errors += result.getId() + ':'+err.getFields() + ':' + err.getStatusCode() + ': ' + err.getMessage() +'\n\n';
                    }
                }
            } 
        } 
        
        if (!String.isBlank(errors)) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(UserInfo.getUserId());
            mail.setSubject('Time Sheet Labor Entry Batch Errors');
            mail.setPlainTextBody(errors);
            mail.setSaveAsActivity(false);
            Messaging.sendEmail(new Messaging.Email[] { mail }, false);     
        }
        
    }
    
    global void execute(SchedulableContext sc){
        
        processLabor(getQuery());       
    }
    
    public virtual String getQuery(){
        
        String endOfWeek =  String.valueof(date.today().addDays(-7).toStartOfWeek().addDays(8));
		String startOfWeek =  String.valueof(date.today().addDays(-7).toStartOfWeek().addDays(1));
        
        // SZ: Change the query string to retrieve the State__c from the lookup
        // PB: Added filter for CreatedDate to the query        
        String query = 'SELECT End_Time__c,Entry_Date__c,Id,Name,Posted__c,Project_Client_Job__r.Work_Order__c, Project_Client_Job__r.Work_Order__r.rstk__wocst_qtyreq__c, Project_Client_Job__r.Work_Order__r.rstk__externalid__c ,Start_Time__c,Timesheet_Purpose__r.name, Timesheet_Purpose__r.DE_Code__c ,Time_Sheet__r.Employee__c,Time_Sheet__r.Employee__r.Home_Office_Location__r.State__c,Total_Hours__c,Time_Sheet__r.Employee__r.Employee_Number__c';
        query+= ' FROM Time_Sheet_Entry__c';
        //query+= ' WHERE Posted__c = true';
        query+= ' WHERE CreatedDate = LAST_N_DAYS:45';
        query+= ' AND Posted__c = true';
        query+= ' AND Entry_Date__c >=' + startOfWeek;
        query+= ' AND Entry_Date__c <' + endOfWeek;
        query+= ' AND Timesheet_Purpose__r.DE_Code__c = \'9005\'';
        query+= ' AND Labor_Processed__c = false';
        query+= ' AND Total_Hours__c > 0';
        query+= ' ORDER BY Time_Sheet__r.Employee__r.Employee_Number__c, Entry_Date__c';
        
        return query;
        
    }
	
    public Integer getDiv(Time_Sheet_Entry__c timeSheetEntry){
        
        Integer div = 0;
        
        if(timeSheetEntry.Timesheet_Purpose__r.name.equals('Install')){
            div = 10;            
        }else if(timeSheetEntry.Timesheet_Purpose__r.name.equals('Install-Electric')){
            div = 20;            
        }else if(timeSheetEntry.Timesheet_Purpose__r.name.equals('Maintenance')){
            div = 30;            
        }else if(timeSheetEntry.Timesheet_Purpose__r.name.equals('Warranty Maintenance')){
            div = 40;            
        }
        
        return div;
        
    }
	
    public String getWoorOpnExtId(Time_Sheet_Entry__c timeSheetEntry, Integer div){
        
        return (timeSheetEntry.Project_Client_Job__r.Work_Order__r.rstk__externalid__c + '_' + String.valueOf(div));         
        
    }

	public String getWoorOpn(Time_Sheet_Entry__c timeSheetEntry){
        
        return workOrdOpnsMap.get(timeSheetEntry.Project_Client_Job__r.Work_Order__r.rstk__externalid__c + '_' + String.valueOf(getDiv(timeSheetEntry)));         
        
    }
    
    public String getWoorOpn(String woorOpnExtId){
        
        return workOrdOpnsMap.get(woorOpnExtId);         
        
    }
    
    public List<String> getSortedKeySet(Set<String> keySet){
        
        List<String> sortedKeySet = new List<String>();
        sortedKeySet.addAll(keySet);
        sortedKeySet.sort();        
        return sortedKeySet;
        
    }
    
    public TimeSheet_Labor_Entry__c createLaborEntry(Time_Sheet_Entry__c timeSheetEntry, Decimal hrsAssigned, Decimal rateFactor){
        
        TimeSheet_Labor_Entry__c laborEntry = new TimeSheet_Labor_Entry__c();
        
        laborEntry.Status__c = 'New';        
        laborEntry.Source_Program__c = 'Labor_Load';
        laborEntry.Transaction_Type__c = 'Labor Booking';
        laborEntry.Work_Order__c = timeSheetEntry.Project_Client_Job__r.Work_Order__c;
        laborEntry.Work_Order_Operation__c = getWoorOpn(timeSheetEntry);
        laborEntry.Rate_Factor__c = rateFactor;
        laborEntry.Time_Sheet_Entry__c = timeSheetEntry.Id;       
        laborEntry.Labor_Booking_Hours__c = hrsAssigned.setScale(2);
        laborEntry.Booking_User__c = sysUsrsMap.get(timeSheetEntry.Time_Sheet__r.Employee__r.Employee_Number__c);
        
        return laborEntry;
        
    }
    
    public TimeSheet_Labor_Entry__c createLaborEntry(String woorOpnExtId,Time_Sheet_Entry__c timeSheetEntry){
        
        TimeSheet_Labor_Entry__c laborEntry = new TimeSheet_Labor_Entry__c();
        
        laborEntry.Status__c = 'New';        
        laborEntry.Source_Program__c = 'Labor_Load';
        laborEntry.Transaction_Type__c = 'Labor Booking';
        laborEntry.Work_Order__c = timeSheetEntry.Project_Client_Job__r.Work_Order__c;
        laborEntry.Work_Order_Operation__c = getWoorOpn(woorOpnExtId); 
        laborEntry.Transaction_Qty__c = 1;       
        laborEntry.Booking_User__c = sysUsrsMap.get(timeSheetEntry.Time_Sheet__r.Employee__r.Employee_Number__c);
        
        return laborEntry;
        
    }   
    
    public class EmpLbr{
        public Id empId {get; private set;}
        public List<TimeSheet_Labor_Entry__c> regLbrEntries {get; private set;}
        public List<TimeSheet_Labor_Entry__c> oTLbrEntries {get; private set;}
        public Decimal totRegHrsWorked {get; private set;}
        public Integer numOfDaysWorked {get; private set;}
        public String officeState {get; private set;}
        public Decimal overtimeHrs {get{return (totRegHrsWorked-40 > 0)?totRegHrsWorked-40:0;} private set;}
		     
        
        public EmpLbr(
            Id empId
            , List<TimeSheet_Labor_Entry__c> regLbrEntries
            , List<TimeSheet_Labor_Entry__c> oTLbrEntries
            , Decimal totRegHrsWorked
            , Integer numOfDaysWorked
            , String officeState)
        {
            this.empId = empId;
            this.regLbrEntries = regLbrEntries;
            this.oTLbrEntries = oTLbrEntries;
            this.totRegHrsWorked = totRegHrsWorked;
            this.numOfDaysWorked = numOfDaysWorked;
            this.officeState = officeState;
                
        }
        
    }

}