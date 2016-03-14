/* FILE: MetricTargetGoalTrigger.trigger
   AUTHOR: Steve Zilligen
   DATE: 2015-06-04
   PURPOSE: Common trigger handler for Metric Target Goal
*/
public class MetricTargetGoalTriggerHandler {
    
    private boolean m_isExecuting = false;
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }

    public MetricTargetGoalTriggerHandler (boolean isExecuting){      
        m_isExecuting = isExecuting;
    }

    public void OnBeforeInsert(Metric_Target_Goal__c[] newMetricTargetGoals){
        // EXECUTE BEFORE INSERT LOGIC  
        EnsureValidEffectiveDates(newMetricTargetGoals);
        m_isExecuting = false;
    }

    public void OnBeforeUpdate(Metric_Target_Goal__c[] updatedMetricTargetGoals, Map<Id,Metric_Target_Goal__c> newMetricTargetGoalsMap, Map<Id,Metric_Target_Goal__c> oldMetricTargetGoalsMap){
        // BEFORE UPDATE LOGIC
        EnsureValidEffectiveDates(updatedMetricTargetGoals);
        m_isExecuting = false;
    }
    
    /*
    public void OnBeforeDelete(Map<Id, Metric_Target_Goal__c> oldMetricTargetGoalsMap){
        // BEFORE DELETE LOGIC
        m_isExecuting = false;
    }

    public void OnAfterInsert(Metric_Target_Goal__c[] insertedMetricTargetGoals, Map<Id, Metric_Target_Goal__c> insertedMetricTargetGoalsMap){
        // EXECUTE AFTER INSERT LOGIC        
        m_isExecuting = false;
    }

    public void OnAfterUpdate(Metric_Target_Goal__c[] updatedMetricTargetGoals, Map<Id,Metric_Target_Goal__c> updatedMetricTargetGoalsMap, Map<Id,Metric_Target_Goal__c> oldMetricTargetGoalsMap){
        //  EXECUTE AFTER UPDATE LOGIC
        m_isExecuting = false;
    }

    public void OnAfterDelete(Map<Id, Metric_Target_Goal__c> oldMetricTargetGoalsMap){
        // AFTER DELETE LOGIC
        m_isExecuting = false;
    }

    public void OnUndelete(Object[] restoredObjects){
        // AFTER UNDELETE LOGIC
    }
    */

    private void EnsureValidEffectiveDates(Metric_Target_Goal__c[] goalsToProcess){
        for(Metric_Target_Goal__c mtg : goalsToProcess){
            List<Metric_Target_Goal__c> overlappingGoals = [SELECT Id FROM Metric_Target_Goal__c WHERE Metric__c = :mtg.Metric__c 
                AND ((Effective_From__c <= :mtg.Effective_From__c AND Effective_To__c >= :mtg.Effective_From__c) OR
                     (Effective_From__c <= :mtg.Effective_To__c AND Effective_To__c >= :mtg.Effective_To__c) OR
                     (Effective_From__c >= :mtg.Effective_From__c AND Effective_To__c <= :mtg.Effective_To__c) OR
                     (Effective_From__c >= :mtg.Effective_From__c AND Effective_To__c <= :mtg.Effective_To__c)) LIMIT 1];
            if(overlappingGoals.size() > 0 && (trigger.isInsert || overlappingGoals[0].Id != mtg.Id)){
                mtg.Effective_From__c.addError('Effective Range overlaps with an existing target.');
                return;
            }
        }
    }
}