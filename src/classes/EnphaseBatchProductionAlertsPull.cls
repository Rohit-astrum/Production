global class EnphaseBatchProductionAlertsPull implements Database.Batchable<sObject>,Database.AllowsCallouts,Schedulable, Database.Stateful{
    public String query;

    global Database.QueryLocator start(Database.BatchableContext BC){
        query = 'SELECT Id, Enphase_ID__c, PJM_Id__c, Generation_Start_Date__c,Quoted_System_Design__r.System_Design__r.Total_System_Size_kW__c,Quoted_System_Design__r.System_Design__r.Total_Projected_Annual_Output_kWh_y__c,Property__r.Snow_De_Rate_kWh_y_kW__c ';
        query = query + ' FROM Installed_System__c WHERE Enphase_ID__c <> NULL AND Id NOT IN '; 
        query = query + ' (SELECT Installed_System__c FROM Enphase_Alert__c  WHERE CreatedDate = THIS_WEEK) ' ;
              
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        String status; 
        List<Enphase_Alert__c> alerts = new List<Enphase_Alert__c>();     
        for(sObject s : scope)
        {
          
          Installed_System__c sys = (Installed_System__c)s;
          status =       processSystem(sys,alerts   );    
          System.debug('*Sys - '+Sys.Enphase_ID__c+' - '+Status);     
                
        }   
        
        if (!alerts.isEmpty()) {
          upsert alerts;
        }    
       
    }
    
    global void finish(Database.BatchableContext BC){
    } 
    
    global void execute(SchedulableContext SC) {
      EnphaseBatchProductionAlertsPull batch = new EnphaseBatchProductionAlertsPull();
      Id batchId = Database.executeBatch(batch, 10);
    }
    
    public String processSystem(Installed_System__c sys, List<Enphase_Alert__c> alerts ) {
    
       try {
      
      EnphaseAPI api = new EnphaseAPI();
      //List<Enphase_Alert__c> alerts = new List<Enphase_Alert__c>();
    
      //get alerts from enphase
      List<EnphaseAPI.EnphaseAlert> e_alerts = api.alerts(Integer.valueOf(sys.Enphase_ID__c), 'low');
          
      List<Enphase_Alert__c> s_alerts = 
        [SELECT Id, Alert_Level__c, Alert_Name__c, Alert_Start__c, Number_of_Devices__c, Acknowledged__c 
        FROM Enphase_Alert__c
        WHERE Installed_System__c = :sys.Id];
  
      Set<Id> foundIds = new Set<Id>();
          
      for (EnphaseAPI.EnphaseAlert e_alert : e_alerts) {
        Boolean found = false;
        for (Enphase_Alert__c s_alert : s_alerts) {
          //if the number of inverters or level changes, unacknowledge and update
          if (s_alert.Alert_Start__c == e_alert.alert_start 
          && s_alert.Alert_Name__c == e_alert.alert_name) {
            if (s_alert.Alert_Level__c != e_alert.level
            || s_alert.Number_of_Devices__c != e_alert.num_devices) {
              s_alert.Acknowledged__c = false;
              s_alert.Alert_Level__c = e_alert.level;
              s_alert.Number_of_Devices__c = e_alert.num_devices;
              alerts.add(s_alert);
            }
            foundIds.add(s_alert.Id);
            found = true;
            break;
          }
        }
        if (found != true) {
          alerts.add(new Enphase_Alert__c (
            Installed_System__c = sys.Id,
            Alert_Start__c = e_alert.alert_start,
            Alert_Name__c = e_alert.alert_name,
            Alert_Level__c = e_alert.level,
            Number_of_Devices__c = e_alert.num_devices
          ));
        }
      }
        
      //look for ones that no longer appear, auto-acknowledge
      for (Enphase_Alert__c s_alert : s_alerts) {
        if (!foundIds.contains(s_alert.Id) && s_alert.Acknowledged__c != true) {
          s_alert.Acknowledged__c = true;
          alerts.add(s_alert);
        }
      }

      /*if (!alerts.isEmpty()) {
        upsert alerts;        
      }*/
        
    } catch (Exception e) {
      return e.getMessage() + ' \n' + e.getStackTraceString();
    }

    return 'Success';     
        
   }
}