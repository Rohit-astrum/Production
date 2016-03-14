trigger JournalBatchIntegrationRuleEngine on QB_Trans_Detail__c (before insert) 
{
    ffirule.IntegrationRuleEngine.triggerHandler();}