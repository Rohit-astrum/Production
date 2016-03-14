@isTest
private class Test_Campaign_BIBU_Trigger{
    public static testMethod void testCampaignTrigger()
    {
        
        
        // Formating 
        String StartDate = System.now().format('yyMMMdd'); 
        List<Campaign> campinsert = new List<Campaign>();
        List<Campaign> campUpd = new List<Campaign>();
        
        String campName;
        
               
        Campaign camp = new Campaign();
        camp.Type = 'Trade Show';
        camp.StartDate = System.Today();
        camp.One_Day_event__c = true;
        camp.Event_Name__c = 'TestTradeShow';
        camp.City__c = 'Wayne';
        camp.State__c = 'PA';
        
        campinsert.add(camp); 
        
        Campaign camp1 = new Campaign();
        camp1.Type = 'Community Tabling';
        camp1.StartDate = System.Today();
        camp1.One_Day_event__c = true;
        camp1.Event_Name__c = 'TestTradeShow';
        camp1.City__c = 'Wayne';
        camp1.State__c = 'PA';
        
        campinsert.add(camp1); 
        
        Campaign camp2 = new Campaign();
        camp2.Type = 'Community Seminar';
        camp2.StartDate = System.Today();
        camp2.One_Day_event__c = true;
        camp2.Event_Name__c = 'TestTradeShow';
        camp2.City__c = 'Wayne';
        camp2.State__c = 'PA';
        
        campinsert.add(camp2); 
        
        Account a = new Account();
        a.Name = 'TestEvent';
        insert a;
        
        Campaign camp3 = new Campaign();
        camp3.Type = 'Solar Open House';
        camp3.StartDate = System.Today();
        camp3.One_Day_event__c = true;
        camp3.Customer_Host__c = a.Id;
        camp3.City__c = 'Wayne';
        camp3.State__c = 'PA';
        
        campinsert.add(camp3); 
        
        Campaign camp4 = new Campaign();
        camp4.Type = 'Canvassing';
        camp4.StartDate = System.Today();
        camp4.One_Day_event__c = true;
        camp4.Customer_Host_NA__c = true;
        camp4.Canvass_Area_Name__c = 'TestTradeShow';
        camp4.City__c = 'Wayne';
        camp4.State__c = 'PA';
        
        campinsert.add(camp4); 
        
        Campaign camp5 = new Campaign();
        camp5.Type = 'Retail Tabling';
        camp5.StartDate = System.Today();
        camp5.One_Day_event__c = true;
        camp5.Retailer_Name__c = 'TestTradeShow';
        camp5.City__c = 'Wayne';
        camp5.State__c = 'PA';
        
        campinsert.add(camp5); 
        
        Campaign camp6 = new Campaign();
        camp6.Type = 'Telemarket';
        camp6.StartDate = System.Today();        
        camp6.Name = 'TestTradeShow';
        
        campinsert.add(camp6); 
        
        Campaign camp7 = new Campaign();
        camp7.Type = 'Miscellaneous';
        camp7.StartDate = System.Today(); 
        
        campinsert.add(camp7); 
        
        insert campinsert;
        
        
        campUpd = [Select Name,Type from Campaign where id in :campinsert];
        
        for(Campaign c :campUpd )
        {
            if(c.Type == 'Trade Show')
                System.assertEquals( StartDate+'-'+'S'+'-'+'PA'+'-'+'TestTrad'+'-'+ 'Wayn',c.Name);    
                
            if(c.Type == 'Community Tabling')
                System.assertEquals( StartDate+'-'+'T'+'-'+'PA'+'-'+'TestTrad'+'-'+ 'Wayn',c.Name);
            
            if(c.Type == 'Community Seminar')
                System.assertEquals( StartDate+'-'+'P'+'-'+'PA'+'-'+'TestTrad'+'-'+ 'Wayn',c.Name);
                
            if(c.Type == 'Solar Open House')
                System.assertEquals( StartDate+'-'+'H'+'-'+'PA'+'-'+'TestEven'+'-'+ 'Wayn',c.Name);
                
            if(c.Type == 'Canvassing')
                System.assertEquals( StartDate+'-'+'C'+'-'+'PA'+'-'+'TestTrad'+'-'+ 'Wayn',c.Name);
                
            if(c.Type == 'Retail Tabling')
                System.assertEquals( StartDate+'-'+'R'+'-'+'PA'+'-'+'TestTrad'+'-'+ 'Wayn',c.Name);
                
            if(c.Type == 'Telemarket')
                System.assertEquals( StartDate+'-'+'M'+'-'+'XX'+'-'+'TestTrad'+'-'+ 'Misc',c.Name);
                
               
            if(c.Type == 'Miscellaneous')
                System.assertEquals( StartDate+'-'+'M'+'-'+'XX'+'-'+'MiscCamp'+'-'+ 'Misc',c.Name);   
                
        }
        
        Campaign camp8 = new Campaign();
        camp8.Type = 'Trade Show';
        camp8.StartDate = System.Today()+2;
        camp8.One_Day_event__c = true;
        camp8.Event_Name__c = 'TestTradeShow';
        camp8.City__c = 'Wayne';
        camp8.State__c = 'PA';
        
        insert camp8;
        
        camp8.State__c = 'MA';
        camp8.StartDate = System.Today();
        update camp8;
        
        Campaign c8 = [select Name from Campaign Where Id = : camp8.Id];
        System.assertEquals( StartDate+'-'+'S'+'-'+'MA'+'-'+'TestTrad'+'-'+ 'Wayn',c8.Name); 
        
        
    }
}