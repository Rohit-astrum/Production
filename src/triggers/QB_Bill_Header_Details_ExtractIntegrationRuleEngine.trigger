trigger QB_Bill_Header_Details_ExtractIntegrationRuleEngine on QB_Bill_Header_Details_Extract__c (before insert) 
{
    ffirule.IntegrationRuleEngine.triggerHandler();
}