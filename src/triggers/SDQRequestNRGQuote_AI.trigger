trigger SDQRequestNRGQuote_AI on System_Design_Quote__c (After Insert) {
   
   /* MK - 2014-07-21: Moved to trigger handler
    for(System_Design_Quote__c sdq: Trigger.New)
    {
        if (sdq.NRG_Calculator_Valid_SDQ__c || Test.isRunningTest()) 
        {   
            NRGRequestQuoteFromSDQ.RequestNRGQuote(sdq.Id, sdq.System_design__c,sdq.NRG_Installation_State__c, sdq.NRG_Calculator_System_Size_kW__c,sdq.NRG_Calculator_Projected_Annual_Output__c,sdq.NRG_Down_Payment__c,sdq.NRG_Prepaid_Down_Payment__c,sdq.NRG_Calculator_Lease_Escalator__c,sdq.NRG_Calculator_State_Grant__c,sdq.NRG_Calculator_Sales_Tax__c,sdq.NRG_EPC_Price__c,sdq.NRG_Prepaid_EPC_Price__c, sdq.NRG_Calculator_Utility__c,sdq.NRG_Calculator_Avoided_Cost__c );        
        }         
        CPFIntegrationProcessor.createCPFProposal(sdq.Id); 
    }
    */
}