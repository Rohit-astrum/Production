trigger QB_Credit_NotesIntegrationRuleEngine on QB_Credit_Notes__c (before insert) {
ffirule.IntegrationRuleEngine.triggerHandler();
}