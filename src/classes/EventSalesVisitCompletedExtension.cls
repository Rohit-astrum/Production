public class EventSalesVisitCompletedExtension {

   private Opportunity opp;
   private String eventId;
   public String parentDomain{get;set;}
   public String selectedReason {get; set;}
   public String errorFields { get; private set; }
   public String updateStatus{ get; private set; }
   public transient Map<String, Decimal> probabilityStageNameMap;
   
   
   public EventSalesVisitCompletedExtension (ApexPages.StandardController stdController) {
       opp= (Opportunity) stdController.getRecord();   
       parentDomain = ApexPages.currentPage().getHeaders().get('referer');  
       eventId =  ApexPages.currentPage().getParameters().get('eventid');    
   }
   
   public PageReference changeStageName() {

       if (probabilityStageNameMap == null) {
           probabilityStageNameMap = new Map<String, Decimal>();
           for (OpportunityStage oppStage : [Select MasterLabel, DefaultProbability
                                       From OpportunityStage]) {
               probabilityStageNameMap.put(oppStage.MasterLabel, oppStage.DefaultProbability);
           }
       }
  
       if (probabilityStageNameMap.containsKey(opp.StageName)) {
           opp.Probability = probabilityStageNameMap.get(opp.StageName);
       }

       return null;
  }
   
   public PageReference updateEventCompleted() {
       if(eventId!= null && eventId != '')
       {
           
           Database.SaveResult  sr = database.update(opp, false); 
            
           
            if (!sr.isSuccess()) {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) { 
                    errorFields = 'ERROR -';                   
                    errorFields += err.getMessage() +'\n\n';
                }
            }
            else
            {
               Event theEvent = [Select Event_Status__c , Completed__c , Completed_Date__c from Event Where id = :eventId ];
               theEvent.Event_Status__c = 'Completed';
               theEvent.Completed__c = true;
               theEvent.run_trigger__c = true;
               theEvent.Completed_Date__c = System.now();           
               update theEvent; 
               updateStatus = 'true';                
            }
          
       }
       return null;
  }    

}