trigger QB_Invoice_FilesIntegrationRuleEngine on QB_Invoice_File__c (before Insert) 

{
    ffirule.IntegrationRuleEngine.triggerHandler();
}