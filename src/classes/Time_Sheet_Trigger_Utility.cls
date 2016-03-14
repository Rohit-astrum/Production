public without sharing class Time_Sheet_Trigger_Utility {

    public static final Integer STANDARD_HOURS_PER_WEEK = 40;
    
    // Added new Parameter by RJ for Zen - 84 bug Fix
    public static void computeHoursAndPay(Map<Id, Time_Sheet__c> timeSheetMap, List<Id> OldProjIds) {
        List<Install_Project__c> theProjects = new List<Install_Project__c>();
        
        
        System.debug('**Test Size'+timeSheetMap);
        // add new query to get all client jobs that are on timesheet entries for these timesheets 
        Map<Id,Time_Sheet_Entry__c> timeSheetEntryMap = new Map<Id,Time_Sheet_Entry__c>(
                                                               [SELECT id, Time_Sheet__c, Project_Client_Job__c 
                                                                FROM Time_Sheet_Entry__c
                                                                WHERE Time_Sheet__c in :timeSheetMap.keySet() ALL ROWS ]);   // Added ALL ROWS by RJ for Zen - 84 bug Fix
                
        
        
        Set<Id> projectClientJobIds = getProjectClientJobIds(timeSheetEntryMap.values(), OldProjIds);
        
        if(projectClientJobIds != null && projectClientJobIds.size() > 0)
        {
         
        
        //
        // limit this by timesheet entries for the client jobs that are being modified 
        //  Time_Sheet__r.Employee__r.overtime_rate__c otr
        //
            List<AggregateResult> agTimeSheetEntries = new List<AggregateResult>(
                                                                    [SELECT Timesheet_Purpose__r.Name purpose, Project_Client_Job__c project, Time_Sheet__c timeSheet,
                                                                            SUM(Total_Hours__c) sumTotalHours 
                                                                    FROM Time_Sheet_Entry__c 
                                                                    WHERE Project_Client_Job__c in :projectClientJobIds
                                                                    AND End_Time__C != null
                                                                    AND Time_Sheet__c in 
                                                                        (SELECT id 
                                                                         FROM Time_Sheet__c 
                                                                         WHERE  Weekly_Overtime_Hours__c > 0)                                                                     
                                                                    GROUP BY Timesheet_Purpose__r.Name, Time_Sheet__c, Project_Client_Job__c ORDER BY Project_Client_Job__c]);
    
            List<AggregateResult> agTimeSheetEntriesForPay = new List<AggregateResult>(
                                                                    [SELECT Timesheet_Purpose__r.Name purpose, Project_Client_Job__c project, Time_Sheet__c timeSheet, Time_Sheet__r.Employee__r.overtime_hourly_rate_string__c overtimeHourlyRate,
                                                                            SUM(Total_Hours__c) sumTotalHours 
                                                                    FROM Time_Sheet_Entry__c 
                                                                    WHERE Project_Client_Job__c in :projectClientJobIds
                                                                    AND End_Time__C != null
                                                                    AND Time_Sheet__c in 
                                                                        (SELECT id 
                                                                         FROM Time_Sheet__c 
                                                                         WHERE  Weekly_Overtime_Hours__c > 0)                                                                     
                                                                    GROUP BY Timesheet_Purpose__r.Name, Time_Sheet__c, Project_Client_Job__c,Time_Sheet__r.Employee__r.overtime_hourly_rate_string__c ORDER BY Project_Client_Job__c]);
    
            // need all the ids for timsheetentries
            Set<Id> theTimeSheetIds = new Set<Id>();
            for (AggregateResult agTemp : agTimeSheetEntries) {
               Object timeSheetObj = agTemp.get('timeSheet');
    
              if (timeSheetObj != null) {
                Id timeSheetId = String.valueOf(timeSheetObj);
                theTimeSheetIds.add(timeSheetId);
              }             
            }
            
            Map<Id,Time_Sheet__c> ts = new Map<Id,Time_Sheet__c>([SELECT id, Weekly_Overtime_Hours__c, Weekly_Standard_Hours__c, Weekly_Total_Hours__c
                                                                  FROM Time_Sheet__c
                                                                  WHERE id in :theTimeSheetIds]);       
            
           
            
            Map<Id, Double> InstPrjOTH = new Map<Id,Double>();
            Map<Id, Double> ElecPrjOTH = new Map<Id,Double>();
    
            Map<Id, Double> InstPrjOvertimePay = new Map<Id,Double>();
            Map<Id, Double> ElecPrjOvertimePay = new Map<Id,Double>();
    
            Map<Id, Double> InstPrjInstallPay = new Map<Id,Double>();
            Map<Id, Double> ElecPrjInstallPay = new Map<Id,Double>();
    
            Map<Id, Double> ElecPrjPre30MaintPay = new Map<Id,Double>();
            Map<Id, Double> ElecPrjPost30MaintPay = new Map<Id,Double>();
    
            Map<Id, Double> InstPrjPre30MaintPay = new Map<Id,Double>();
            Map<Id, Double> InstPrjPost30MaintPay = new Map<Id,Double>();
            
            Map<Id,Double> elecHotel = new Map<Id,Double>();
            Map<Id,Double> instHotel = new Map<Id,Double>();
            Map<Id,Double> elecHours = new Map<Id,Double>();
            Map<Id,Double> instHours = new Map<Id,Double>();
            Map<Id,Double> elecPre30MaintHours = new Map<Id,Double>();
            Map<Id,Double> elecPost30MaintHours = new Map<Id,Double>();
            Map<Id,Double> instPre30MaintHours = new Map<Id,Double>();
            Map<Id,Double> instPost30MaintHours = new Map<Id,Double>();
            
            //
            //  OVERTIME
            //
            
            for(AggregateResult agTemp : agTimeSheetEntries){
                
               Object timeSheetObj = agTemp.get('timeSheet');
               
              if (timeSheetObj != null) {
                
                Double overTime = 0;
                Id timeSheetId = String.valueOf(timeSheetObj);
                
                Time_Sheet__c tempTimeSheet = ts.get(timeSheetId);
                Double tpr = Double.valueOf(agTemp.get('sumTotalHours'));
                Double weeklyTotalHours = tempTimeSheet.Weekly_Total_Hours__c;
                Double weeklyOvertimeHours = tempTimeSheet.Weekly_Overtime_Hours__c;
                Id projectId = String.valueOf(agTemp.get('project'));
                
                // compute overtime
                overTime = weeklyOvertimeHours * (tpr / weeklyTotalHours);
                
                String purpose = (String) agTemp.get('purpose');
                
                // store project overtime in the map
                if(purpose == 'Install'){
                    if(InstPrjOTH.containsKey(projectId)){
                        overTime += InstPrjOTH.get(projectId);  
                    } 
                    InstPrjOTH.put(projectId, overTime);                                
                } else if (purpose == 'Install-Electric'){
                    if(ElecPrjOTH.containsKey(projectId)){
                        overTime += ElecPrjOTH.get(projectId);  
                    } 
                    ElecPrjOTH.put(projectId, overTime);
                }  
              }      
            }       
    
            System.debug('agTimeSheetEntriesForPay.size()=' + agTimeSheetEntriesForPay.size());
            
            for(AggregateResult agTemp : agTimeSheetEntriesForPay){
                
               Object timeSheetObj = agTemp.get('timeSheet');
               
              if (timeSheetObj != null) {
                
                Double overTime = 0;
                Id timeSheetId = String.valueOf(timeSheetObj);
                
                Time_Sheet__c tempTimeSheet = ts.get(timeSheetId);
                
                //System.debug('tempTimeSheet  =' + tempTimeSheet );
                
                
                Double tpr = Double.valueOf(agTemp.get('sumTotalHours'));
                Double weeklyTotalHours = tempTimeSheet.Weekly_Total_Hours__c;
                Double weeklyOvertimeHours = tempTimeSheet.Weekly_Overtime_Hours__c;
                Id projectId = String.valueOf(agTemp.get('project'));
                
                // compute overtime
                overTime = weeklyOvertimeHours * (tpr / weeklyTotalHours);
                
                Double overTimeHourlyRate = Double.valueOf(agTemp.get('overtimeHourlyRate'));
                Decimal totalPay = overTimeHourlyRate * overTime;
                
                String purpose = (String) agTemp.get('purpose');
                
                System.debug('* Pu-'+purpose +' '+ projectId+ ' tempTimeSheet  =' + tempTimeSheet );
                
                // store project overtime in the map
                if(purpose == 'Install'){
                    
                    if(InstPrjOvertimePay.containsKey(projectId)){
                        totalPay += InstPrjOvertimePay.get(projectId);  
                    } 
                    
                    System.debug('InstPrjOvertimePay.totalPay=' + totalPay);
                    InstPrjOvertimePay.put(projectId, totalPay);                                
                } else if (purpose == 'Install-Electric'){
                    if(ElecPrjOvertimePay.containsKey(projectId)){
                        totalPay += ElecPrjOvertimePay.get(projectId);  
                    } 
                    
                    ElecPrjOvertimePay.put(projectId, totalPay);
                    System.debug('ElecPrjOvertimePay.totalPay=' + totalPay);
                }  
              }      
            }       
            
            //
            //  INSTALL HOURS, MAINTENANCE HOURS AND HOTEL
            //
                    
            List<AggregateResult> agHotel = new List<AggregateResult>([SELECT Project_Client_Job__c p, Bonus_Type__c b, SUM(Hotel_Cost__c) h 
                                                                    FROM Time_Sheet_Entry__c 
                                                                    WHERE Project_Client_Job__c in :projectClientJobIds
                                                                    AND End_Time__C != null
                                                                    AND (Timesheet_Purpose__r.Name='Install' OR Timesheet_Purpose__r.Name='Install-Electric' OR Timesheet_Purpose__r.Name='Maintenance') 
                                                                    GROUP BY CUBE (Project_Client_Job__c, Bonus_Type__c)]);
                                                                    
            List<AggregateResult> agInstHours = new List<AggregateResult>([SELECT Project_Client_Job__c project, Bonus_Type__c bonusType, SUM(Total_Hours__c) totalHours
                                                                            FROM Time_Sheet_Entry__c 
                                                                            WHERE Project_Client_Job__c in :projectClientJobIds 
                                                                            AND End_Time__C != null
                                                                            AND (Timesheet_Purpose__r.Name='Install' OR Timesheet_Purpose__r.Name='Install-Electric')
                                                                            GROUP BY CUBE(Project_Client_Job__c, Bonus_Type__c)]);
                                                                            
            
    
            List<AggregateResult> agInstHoursForPay = new List<AggregateResult>([SELECT Project_Client_Job__c project, Bonus_Type__c bonusType, Time_Sheet__r.id timesheetId, Time_Sheet__r.Employee__r.hourly_rate_string__c hourlyRate, SUM(Total_Hours__c) totalHours
                                                                            FROM Time_Sheet_Entry__c 
                                                                            WHERE Project_Client_Job__c in :projectClientJobIds 
                                                                            AND End_Time__C != null
                                                                            AND (Timesheet_Purpose__r.Name='Install' OR Timesheet_Purpose__r.Name='Install-Electric')                                                                       
                                                                            GROUP BY Project_Client_Job__c, Bonus_Type__c, Time_Sheet__r.id, Time_Sheet__r.Employee__r.hourly_rate_string__c]);
            
            // , Time_Sheet__r.Employee__r.hourly_rate__c hourly_rate                                                       
            List<AggregateResult> agMaintHours = new List<AggregateResult>([SELECT Project_Client_Job__c p, Maintenance_Type__c m, SUM(Total_Hours__c) t
                                                        FROM Time_Sheet_Entry__c
                                                        WHERE Project_Client_Job__c in :projectClientJobIds
                                                        AND End_Time__C != null
                                                        AND Timesheet_Purpose__r.Name= 'Maintenance'
                                                        GROUP BY CUBE(Project_Client_Job__c,Maintenance_Type__c)]);
    
            for(AggregateResult ag:agMaintHours){
                Double ht = 0;
                if(ag.get('t') != null) {
                    ht=Double.valueOf(ag.get('t'))/2;
                }
                
                if(ag.get('m')=='PRE-30'){
                    elecPre30MaintHours.put(String.valueOf(ag.get('p')),ht);
                    instPre30MaintHours.put(String.valueOf(ag.get('p')),ht);                
                } else if (ag.get('m')=='POST-30'){
                    elecPost30MaintHours.put(String.valueOf(ag.get('p')),ht);
                    instPost30MaintHours.put(String.valueOf(ag.get('p')),ht);
                }       
            }       
    
            List<AggregateResult> agMaintHoursForPay = new List<AggregateResult>([SELECT Project_Client_Job__c p, Maintenance_Type__c m,  Time_Sheet__r.Employee__r.hourly_rate_string__c hourlyRate, SUM(Total_Hours__c) t
                                                        FROM Time_Sheet_Entry__c
                                                        WHERE Project_Client_Job__c in :projectClientJobIds
                                                        AND End_Time__C != null
                                                        AND Timesheet_Purpose__r.Name= 'Maintenance'
                                                        GROUP BY Project_Client_Job__c,Maintenance_Type__c, Time_Sheet__r.Employee__r.hourly_rate_string__c]);
                    
    
            for(AggregateResult ag : agMaintHoursForPay){
                Double ht = 0;
                if(ag.get('t') != null) {
                    ht=Double.valueOf(ag.get('t'))/2;
                }
                
                Double hourlyRate = getValue(ag.get('hourlyRate'));
                Double totalPay = ht * hourlyRate;
                
                String projectId = String.valueOf(ag.get('p'));
                if(ag.get('m')=='PRE-30') {
                    ElecPrjPre30MaintPay.put(projectId, totalPay);
                    InstPrjPre30MaintPay.put(projectId, totalPay);                  
                } else if (ag.get('m')=='POST-30'){
                    ElecPrjPost30MaintPay.put(projectId, totalPay);
                    InstPrjPost30MaintPay.put(projectId, totalPay);                                 
                }       
            }       
        
            for(AggregateResult ag:agHotel){
                Double ht = 0;
                if(ag.get('h')!=null) {
                    ht=Double.valueOf(ag.get('h'));
                }
                
                if(ag.get('b')=='ELECTRICIAN'){
                    elecHotel.put(String.valueOf(ag.get('p')),ht);
                } else if (ag.get('b')=='INSTALLER'){
                    instHotel.put(String.valueOf(ag.get('p')),ht);
                }
            }
          
            // HOURS
            for(AggregateResult ag : agInstHours){
                Double totalHours = Double.valueOf(ag.get('totalHours'));
                String projectId = String.valueOf(ag.get('project'));
                String bonusType = String.valueOf(ag.get('bonusType'));
    
                if (bonusType == 'ELECTRICIAN'){
                    if (elecHours.containsKey(projectId)) {
                        totalHours += elecHours.get(projectId); 
                    }
                    
                    elecHours.put(projectId, totalHours);
                } else if (bonusType == 'INSTALLER'){
                    if (instHours.containsKey(projectId)) {
                        totalHours += instHours.get(projectId); 
                    }
    
                    instHours.put(projectId, totalHours);
                }
            }       
    
            // PAY
            for(AggregateResult ag : agInstHoursForPay){
                Double totalHours = Double.valueOf(ag.get('totalHours'));
                Double hourlyRate = getValue(ag.get('hourlyRate'));
    
                String projectId = String.valueOf(ag.get('project'));
                String bonusType = String.valueOf(ag.get('bonusType'));
    
                Id timesheetId = String.valueOf(ag.get('timesheetId'));
                
                Double totalPay = 0;
                if (totalHours <= STANDARD_HOURS_PER_WEEK) {
                    totalPay = totalHours * hourlyRate;
                }
                else {
                    totalPay = STANDARD_HOURS_PER_WEEK * hourlyRate;
                }
                
                if (bonusType == 'ELECTRICIAN'){
                    if (ElecPrjInstallPay.containsKey(projectId)) {
                        totalPay += ElecPrjInstallPay.get(projectId);                   
                    }
                    ElecPrjInstallPay.put(projectId, totalPay); 
                                
                } else if (bonusType == 'INSTALLER'){
                    if (InstPrjInstallPay.containsKey(projectId)) {
                        totalPay += InstPrjInstallPay.get(projectId);
                    }
                    InstPrjInstallPay.put(projectId, totalPay);
                }
            }       
    
            List<Install_Project__c> instProjects = [SELECT id, Installer_Overtime_Hours__c, Electrician_Overtime_Hours__c 
                                                     FROM Install_Project__c 
                                                     WHERE id in :projectClientJobIds];
                    
            for(Install_Project__c instProj : instProjects){
    
                //pull in current project totals for installers and electricians
                Double currElecInstallHours = 0;
                Double currInstInstallHours = 0;
                Double currElecPre30MaintHours = 0;
                Double currInstPre30MaintHours = 0;
                Double currElecPost30MaintHours = 0;
                Double currInstPost30MaintHours = 0;
                Double currElecHotel = 0;
                Double currInstHotel = 0;
                
                Double currInstInstallPay = 0;
                Double currElecInstallPay = 0;
                
                if(elecHours.get(instProj.id) != null){
                    currElecInstallHours = elecHours.get(instProj.id);
                } 
                if(instHours.get(instProj.id) != null){
                    currInstInstallHours = instHours.get(instProj.id);
                }
                if(elecPre30MaintHours.get(instProj.id) != null){
                    currElecPre30MaintHours = elecPre30MaintHours.get(instProj.id);
                } 
                if(instPre30MaintHours.get(instProj.id) != null){
                    currInstPre30MaintHours = instPre30MaintHours.get(instProj.id);
                }
                if(elecPost30MaintHours.get(instProj.id) != null){
                    currElecPost30MaintHours = elecPost30MaintHours.get(instProj.id);
                } 
                if(instPost30MaintHours.get(instProj.id) != null){
                    currInstPost30MaintHours = instPost30MaintHours.get(instProj.id);
                }
                if(elecHotel.get(instProj.id) != null){
                    currElecHotel = elecHotel.get(instProj.id);
                } 
                if(instHotel.get(instProj.id) != null){
                    currInstHotel = instHotel.get(instProj.id);
                }
    
                if(InstPrjInstallPay.get(instProj.id) != null){
                    currInstInstallPay = InstPrjInstallPay.get(instProj.id);
                }
    
                if(ElecPrjInstallPay.get(instProj.id) != null){
                    currElecInstallPay = ElecPrjInstallPay.get(instProj.id);
                }
    
                Double currElecPre30MaintPay = 0;
                Double currInstPre30MaintPay = 0;
                Double currElecPost30MaintPay = 0;
                Double currInstPost30MaintPay = 0;
                
                if(InstPrjPre30MaintPay.containsKey(instProj.id)) {
                    currInstPre30MaintPay = InstPrjPre30MaintPay.get(instProj.id);
                }
    
                if(InstPrjPost30MaintPay.containsKey(instProj.id)) {
                    currInstPost30MaintPay = InstPrjPost30MaintPay.get(instProj.id);
                }
    
                if(ElecPrjPre30MaintPay.containsKey(instProj.id)) {
                    currElecPre30MaintPay = ElecPrjPre30MaintPay.get(instProj.id);
                }
    
                if(ElecPrjPost30MaintPay.containsKey(instProj.id)) {
                    currElecPost30MaintPay = ElecPrjPost30MaintPay.get(instProj.id);
                }
                
                instProj.Installer_Install_Hours__c=currInstInstallHours;
                instProj.Installer_Pre30_Maintenance_Hours__c=currInstPre30MaintHours;
                instProj.Installer_Post30_Maintenance_Hours__c=currInstPost30MaintHours;
                instProj.Electrician_Install_Hours__c=currElecInstallHours;
                instProj.Electrician_Pre30_Maintenance_Hours__c=currElecPre30MaintHours;
                instProj.Electrician_Post30_Maintenance_Hours__c=currElecPost30MaintHours;
                instProj.Electrician_Hotel_Costs__c=currElecHotel;
                instProj.Installer_Hotel_Costs__c=currInstHotel;
                
                instProj.Electrician_Install_Pay__c = currElecInstallPay;
                instProj.Installer_Install_Pay__c = currInstInstallPay;
    
                instProj.Installer_Pre30_Maintenance_Pay__c = currInstPre30MaintPay;
                instProj.Installer_Post30_Maintenance_Pay__c = currInstPost30MaintPay;
    
                instProj.Electrician_Pre30_Maintenance_Pay__c = currElecPre30MaintPay;
                instProj.Electrician_Post30_Maintenance_Pay__c = currElecPost30MaintPay;
                        
                // overtime hours and pay
                if(InstPrjOTH.containsKey(instProj.id)){
                    instProj.Installer_Overtime_Hours__c = InstPrjOTH.get(instProj.id);
                }
                
                if(ElecPrjOTH.containsKey(instProj.id)){
                    instProj.Electrician_Overtime_Hours__c = ElecPrjOTH.get(instProj.id);
                }
                
                // ElecPrjOvertimePay
                if(ElecPrjOvertimePay.containsKey(instProj.id)){
                    instProj.Electrician_Overtime_Pay__c = ElecPrjOvertimePay.get(instProj.id);
                }
    
                // InstPrjOvertimePay
                if(InstPrjOvertimePay.containsKey(instProj.id)){
                    instProj.Installer_Overtime_Pay__c = InstPrjOvertimePay.get(instProj.id);
                }
                                           
                theProjects.add(instProj);          
            }
    
            update theProjects;   
        }                  
    }

    
    private static Set<Id> getProjectClientJobIds(List<Time_Sheet_Entry__c> timeSheetEntries, List<Id> OldProjIds) {
        Set<Id> jobIds = new Set<Id>();
                
        for (Time_Sheet_Entry__c tempTimeSheetEntry : timeSheetEntries) {
            Id tempJobId = tempTimeSheetEntry.Project_Client_Job__c;
            if(tempJobId != null)
            {
                jobIds.add(tempJobId);
            }
        }
        if (OldProjIds != null && OldProjIds.size() > 0)
        {
            system.debug(' **OldProjIds.size() ->>' +OldProjIds.size()); 
            jobIds.addAll(OldProjIds);
        }   
        
        return jobIds;      
    }
        
    private static Double getValue(Object theField) {
        Double result = 0;
        
        if (theField != null) {
            result = Double.valueOf(theField);
        }
        
        return result;
    }
}