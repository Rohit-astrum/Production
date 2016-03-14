public class Opportunity_Trigger_Utility {
    
    //MK - 2014-08-25 - prevent recursive firing of triggers, saves unnecessary processing
    public static boolean isOpportunityTriggerRunning = false;
    public static boolean skipOpportunityTrigger = false;
 
    public static final String ON_HOLD_STAGE = 'On Hold';
    
    public static final String TASK_STATUS = 'Not Started';
    public static final String TASK_PRIORITY = 'Normal';
    public static final String TASK_SUBJECT = 'Follow-Up';
    public static final String TASK_DESCRIPTION = 'Please contact the Opportunity by given due date.';
 
 
    private Map<Id,Opportunity> oppMap;
    private Id StandardPricebookId;

    public Opportunity_Trigger_Utility(){
        if(Test.isRunningTest()){
            this.StandardPricebookId = Test.getStandardPricebookId();
            
        }else{
            this.StandardPricebookId = [Select id from Pricebook2 where Pricebook2.IsStandard = true ].Id;            
        }
        
    }

    private Map<Id, Opportunity> lookupOpps(Set<Id> ids){
            return new Map<Id, Opportunity>([
            select o.id, 
            o.Name,
            o.Pricebook2Id,
            o.System_Design_Quote__c,
            o.System_Design_Quote__r.Total_Standard_Rate_Adj__c, 
            o.System_Design_Quote__r.Total_Standard_Percent_Adj__c, 
            o.System_Design_Quote__r.Total_Standard_Dollar_Adj__c, 
            o.System_Design_Quote__r.Total_Program_Rate_Adj__c, 
            o.System_Design_Quote__r.Total_Program_Percent_Adj__c, 
            o.System_Design_Quote__r.Total_Program_Dollar_Adj__c, 
            o.System_Design_Quote__r.Total_Price_Adjustment__c, 
            o.System_Design_Quote__r.System_Size_kW__c, 
            o.System_Design_Quote__r.System_Design__c, 
            o.System_Design_Quote__r.Name, 
            o.System_Design_Quote__r.Id, 
            o.System_Design_Quote__r.Final_Adjusted_Price_per_Watt__c, 
            o.System_Design_Quote__r.Final_Adjusted_Price__c, 
            o.System_Design_Quote__r.Calculated_System_Price__c, 
            o.System_Design_Quote__r.Calculated_Price_per_Watt__c, 
            o.System_Design_Quote__r.Total_Closed_Scenario_Adjustments__c, 
            o.Account.Name,
            o.Account.OppCountIndex__c,
            o.Property__c,           
            o.Property__r.Name,
            o.Property__r.Property_State__c,
            o.Opp_Index__c
            from Opportunity o
            where o.Id in :ids]);
        
    }

    public void handleBeforeInsertTrigger(List<Opportunity> newList) {
system.debug('**SZ: No. Queries - ' + Limits.getQueries());        
        // set opp.Opp_Index__c
        incrementOppCountIndex(newList);
system.debug('**SZ: No. Queries - ' + Limits.getQueries());        
        // Set Opp Name
        setOppName(newList);        
system.debug('**SZ: No. Queries - ' + Limits.getQueries());        
        //Match up the community program offers and fill these fields in
        getCommunityProgramOffers(newList);
system.debug('**SZ: No. Queries - ' + Limits.getQueries());        
    }

    public void handleBeforeUpdateTrigger(Map<Id,Opportunity> oldMap, Map<Id,Opportunity> newMap){
        // Validate Lease Fund
        validateLeaseFund(newMap.Values());
        
        // Set Opp Name
        setOppName(newMap.Values());
        // SetOpportunityContactCount
        setOpportunityContactCount(newMap);
        
        //
        // 2015-12-07 - SZ: Moved to after trigger to prevent recursive update error
        //createTasksForOpportunitiesInOnHoldStage(oldMap,newMap);     
        clearOnHoldDateForOpportunitiesLeavingOnHoldStatus(oldMap, newMap);

        //Match up the community program offers and fill these fields in
        getCommunityProgramOffers(newMap.values());

        //SZ - 2015-07-02: Part of CompanyWideReport
        updateDateOppCancelled(newMap.values(), oldMap);
    }

    public void handleAfterInsertTrigger(Map<Id,Opportunity> newMap){
        // addAstrumProducts
        System.debug('TriggerUtility.isOpportunityUpdate --> ' + TriggerUtility.isOpportunityUpdate);
        if(TriggerUtility.isOpportunityUpdate != true){
system.debug('**SZ: No. Queries - ' + Limits.getQueries());        
            addAstrumProducts(newMap);
        }
        //defaultCommunityProgram(newMap);    //DK 10/15/14
    }

    public void handleAfterUpdateTrigger(Map<Id,Opportunity> newMap){
        // addAstrumProducts
        System.debug('TriggerUtility.isOpportunityUpdate --> ' + TriggerUtility.isOpportunityUpdate);
        if(TriggerUtility.isOpportunityUpdate != true){
            addAstrumProducts(newMap);
        }
        //defaultCommunityProgram(newMap);    //DK 10/15/14
    }

    public void handleAfterUpdateTriggerForTasks(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap){
        createTasksForOpportunitiesInOnHoldStage(oldMap,newMap);
    }

    //SZ - 2015-07-02: Part of CompanyWideReport
    private void updateDateOppCancelled(List<Opportunity> newList, Map<Id,Opportunity> oldMap){
        for(Opportunity opp : newList){
            if(opp.StageName == 'Contract Cancelled' && oldMap.get(opp.Id).StageName != 'Contract Cancelled'){
                opp.Date_Opp_Cancelled__c = Date.today();
            } else if(opp.StageName != 'Contract Cancelled' && oldMap.get(opp.Id).StageName == 'Contract Cancelled'){
                opp.Date_Opp_Cancelled__c = null;
            }
        }
    }

    //MK - 2014-08-21
    private void getCommunityProgramOffers(list<Opportunity> Opps){
        system.debug('getCommunityProgramOffers');

        //Call common class to 
        CommunityProgramOfferUtility.matchCommunityProgramOffer(Opps);
    }

    private void setOpportunityContactCount(Map<Id, Opportunity> oppMap){
        //opp.Contact_Role_Count__c = [Select count() From OpportunityContactRole o where o.OpportunityId = : opp.Id];
        Set<Id> keys = oppMap.keySet();
        
        AggregateResult[] groupedResults = [Select OpportunityId, count(Contact.Name) From OpportunityContactRole where OpportunityId in :keys  group by OpportunityId];
        for (AggregateResult ar : groupedResults) {
            Id currOppId = (Id) ar.get('OpportunityId'); 
            Integer currOppContactCount = Integer.valueOf(ar.get('expr0'));
            System.debug('Opp ID --> ' + currOppId);
            System.debug('Contact Count --> ' + currOppContactCount);
            Opportunity currOpp = oppMap.get(currOppId);
            currOpp.Contact_Role_Count__c = double.valueOf(currOppContactCount);
        
        }
    }

    private void incrementOppCountIndex(List<Opportunity> oppList){
        //Map of AccountIds and the number of opps by which to increment counter
        Map<Id, Account> oppIdToAcctMap = new Map<Id, Account>();
        List<Id> opAcctIds = new List<Id>();
        for(Opportunity opp : oppList){
            opAcctIds.add(opp.AccountId);
        }
        
        Map<Id, Account> AcctMap = new Map<Id, Account>([Select id, Name, OppCountIndex__c from Account where Id in :opAcctIds ]);
        for(Opportunity opp : oppList){
            oppIdToAcctMap.put(opp.Id, AcctMap.get(opp.AccountId));
        }
        // oppIdToAcctMap now contains a map of Opp Ids to Account Objects
        
        // now for each Opp in the list, we can simply add 1 to that account's OppCountIndex__c
        
        for(Opportunity opp : oppList){
                
                Account acct = oppIdToAcctMap.get(opp.Id);
                if (acct.OppCountIndex__c == null){
                    acct.OppCountIndex__c = 0;
                }
                acct.OppCountIndex__c = acct.OppCountIndex__c + 1;
                opp.Opp_Index__c = acct.OppCountIndex__c;

        }
        
        update(acctMap.values());
    }
        
    private void addAstrumProducts(Map<Id, Opportunity> oppMap){
        
        Map<Id, Opportunity> lookedUpOppMap = lookupOpps(oppMap.keySet());

        Id SystemProductId = getSystemProductIdFromStdPricebook();
             
        Map<Id, OpportunityLineItem> oliMap = new Map<Id, OpportunityLineItem>([
                select id,
                OpportunityId
                from OpportunityLineItem
                where OpportunityLineItem.OpportunityId in :oppMap.keySet() ]);
        
        // Prepare Map of OppId and List<OpportunityLineItem>        
        Map<Id,List<OpportunityLineItem>> oppOliMap = new Map<Id,List<OpportunityLineItem>>();
        for(OpportunityLineItem oli : oliMap.values()){
            if(oppOliMap.containsKey(oli.OpportunityId)){
                oppOliMap.get(oli.OpportunityId).add(oli);
            } else {
                List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
                oliList.add(oli);
                oppOliMap.put(oli.OpportunityId, oliList);
            }
        }
        
        
        // If opp.System_Design_Quote__c exists, clear this opp's line items and insert two new line items.
        // one for the "System" product and one for "Discount" product.
        for (Opportunity opp : lookedUpOppMap.values()){
        
            if(opp.System_Design_Quote__c != null){
                
                List<OpportunityLineItem> oliList = oppOliMap.get(opp.Id);
                System.debug('oliList --> ' + oliList);
                if(oliList != null){
                    System.debug('oliList.size() --> ' + oliList.size());
                    if(oliList.size() > 0){
                      TriggerUtility.isOpportunityUpdate = true;
                      delete oliList; 
                      TriggerUtility.isOpportunityUpdate = false;
                    }
                }               
                // insert System Product
                addSystemProduct(lookedUpOppMap.get(opp.id), SystemProductId);
                
            }
                
        }
    }

private Id getSystemProductIdFromStdPricebook(){
        
        
        PricebookEntry systemPbe = [
            Select p.UseStandardPrice, 
            p.UnitPrice, 
            p.ProductCode, 
            p.Product2Id, 
            p.Pricebook2Id, 
            p.Name, 
            p.IsActive, 
            p.Id
            From PricebookEntry p
            where p.ProductCode = 'system' 
            and p.IsActive = true
            and p.Pricebook2Id = :StandardPricebookId
            limit 1 ];
            
        return systemPbe.Id;
}        

private void addSystemProduct(Opportunity opp, Id pbeId){
        //opp.Pricebook2Id = StandardPricebookId;
        OpportunityLineItem sysOli = new OpportunityLineItem();
        sysOli.OpportunityId = opp.Id;
        sysOli.Description = 'System';
        sysOli.PricebookEntryId = pbeId;
        
        System.debug('**SZ: Quantity = ' + opp.System_Design_Quote__r.System_Size_kW__c);
        sysOli.Quantity = opp.System_Design_Quote__r.System_Size_kW__c * 1000;
        //sysOli.UnitPrice = sdq.Final_Adjusted_Price_per_Watt__c;
        System.debug('o.System_Design_Quote__r.Final_Adjusted_Price__c --> ' + opp.System_Design_Quote__r.Final_Adjusted_Price__c);
        System.debug('o.System_Design_Quote__r.Total_Closed_Scenario_Adjustments__c --> ' + opp.System_Design_Quote__r.Total_Closed_Scenario_Adjustments__c);
        
        double closedScenarioAdjustments  = opp.System_Design_Quote__r.Total_Closed_Scenario_Adjustments__c != null ? opp.System_Design_Quote__r.Total_Closed_Scenario_Adjustments__c : 0;
        sysOli.TotalPrice = opp.System_Design_Quote__r.Final_Adjusted_Price__c + closedScenarioAdjustments;
     
          /*Before we perform this update we want to set the isOpportunityUpdate boolean in our utility class to true */
        TriggerUtility.isOpportunityUpdate = true;
     
            /*Now we can perform the update. The trigger will still 
        fire but none of the code inside of it will execute and
        this method will not be called again*/
        
        insert(sysOli);
                    
    }
    
    private void setOppName(List<Opportunity> oppList){
 

        System.debug('Inside setOppName,  oppList --> ' + oppList );
        
        /*List<Id> propIds = new List<Id>();
        List<Id> acctIds = new List<Id>();
        for (Opportunity o : oppList ){
            propIds.add(o.Property__c);
            acctIds.add(o.AccountId);
        }
        Map<Id,Property__c> propMap = new Map<Id,Property__c>([select id, Name, Property_State__c from Property__c where id in :propIds]); 
        Map<Id,Account> acctMap = new Map<Id,Account>([select id, Name from Account where id in :acctIds]); */
         
         for (Opportunity opp : oppList ){
            /*String truncPropName = '';
            Integer truncPropSize = 10;
            String truncAcctName = '';
            Integer truncAcctSize = 5;
    
            // Truncate Account Name
            String acctName = acctMap.get(opp.AccountId).Name;
            Integer acctLen = acctName.length();
            if(acctLen <= truncAcctSize){
                truncAcctName = acctName.substring(0, acctLen);
            } else {
                truncAcctName = acctName.substring(0, truncAcctSize);
            }
            truncAcctName = truncAcctName.trim(); 
            
            datetime DT = Datetime.now();
            String monthString = DT.format('yyMMM');  // 2 Digit Year followed by Abbreviated Month
            Decimal oppIndex = Decimal.valueof('0');
            if(opp.Opp_Index__c != null)
                oppIndex = opp.Opp_Index__c;
                    
                        
            String nameToSet = truncAcctName + '-' + monthString+ '-' + oppIndex.intValue();

            // Truncate Prop Name if it exists
            if(opp.Property__c != null){
                String propName = propMap.get(opp.Property__c).name;
                String propState = propMap.get(opp.Property__c).Property_State__c;
                Integer propLen = propName.length();
                if(propLen <= truncPropSize){
                    truncPropName = propName.substring(0, propLen);
                } else {
                    truncPropName = propName.substring(0, truncPropSize);
                }
                truncPropName = truncPropName.trim();
                
                //Construct Opp Name
 
                nameToSet = propState + '-' + truncAcctName + '-' + truncPropName + '-' + monthString + '-' + oppIndex.intValue(); 
            }
            
            if(nameToSet <> opp.Name){
                System.debug('opp.Name --> ' + opp.Name);
                System.debug('nameToSet --> ' + nameToSet);
                opp.Name = nameToSet;
            } */
           // if( opp.Property__r.Name != null )
            
            //System.Debug('** Prop Name  ->>' + opp.Property__r.Name); 
            //System.Debug('** Account Rollup Count  ->>' + opp.Account.Name + ' '+ opp.Account.peteOppCountRollup__C );    
            
            Decimal oppIndex = Decimal.valueof('0');
            if(opp.Opp_Index__c != null)
                oppIndex = opp.Opp_Index__c;
                
            System.Debug('** opp.Opportunity_Name_New__c  ->>' + opp.Custom_Opportunity_Name__c+'-'+oppIndex );          
            opp.Name = opp.Custom_Opportunity_Name__c+'-'+oppIndex ;
            
        }
    } 
    
     private void validateLeaseFund(List<Opportunity> oppList){
        
        List<ID> fundIds = new List<ID>();

        for (Opportunity opp : oppList){        
            if (opp.Lease_PPA_Fund__C != null)
                fundIds.add(opp.Lease_PPA_Fund__c);
        }

         if(!fundIds.isEmpty())         
         {
             Map<Id,Lease_Fund__c> leaseFunds = new Map<Id,Lease_Fund__c>([Select Id, Eligible_States__c, Eligible_Leasing_Options__c FROM Lease_Fund__c Where Id IN :fundIds]);
                                                   
             for(Opportunity opp : oppList){   
                System.debug('*** opp.Lease_PPA_Fund__c ' + opp.Lease_PPA_Fund__c);          
                if(opp.Lease_PPA_Fund__C != null && opp.Property_State__c != null )
                {
                    String eligibleStates = leaseFunds.get(opp.Lease_PPA_Fund__C).Eligible_States__c;
                    
                    System.debug('*** eligibleStates  ' + eligibleStates );
                    
                    if( eligibleStates != null && !(eligibleStates.Contains(opp.Property_State__c)))
                    {
                        opp.Lease_PPA_Fund__C.addError('Lease Fund is not eligible in ' + opp.Property_State__c + ' State');                    
                    } 
                    else if(eligibleStates == null )
                    {
                        opp.Lease_PPA_Fund__C.addError('Lease Fund is currently not eligible in any state.');    
                    }
                 } 
                 if(opp.Lease_PPA_Fund__C != null && opp.Leasing_option__c != null )
                 {  
                    String eligibleOptions = leaseFunds.get(opp.Lease_PPA_Fund__C).Eligible_Leasing_Options__c;
                    if( eligibleOptions  != null && !(eligibleOptions.Contains(opp.Leasing_option__c)))
                    {
                        opp.Leasing_option__c.addError('Leasing Option not eligible for selected Lease Fund.');                    
                    } 
                    else if(eligibleOptions  == null)
                    {
                        opp.Leasing_option__c.addError('No Leasing Options are currently eligible for the selected Lease Fund.');    
                    }
                }
             }
                 
         }
    } 
    
    public void clearOnHoldDateForOpportunitiesLeavingOnHoldStatus(Map<Id, Opportunity> oldOpportunitiesMap, Map<Id, Opportunity> newOpportunitiesMap) {
        
        Set<Id> theIds = oldOpportunitiesMap.keySet();
        
        for (Id tempId : theIds) {
            Opportunity oldTempOpp = oldOpportunitiesMap.get(tempId);
            Opportunity newTempOpp = newOpportunitiesMap.get(tempId);
            
            if (isMovingFromOnHoldStatus(oldTempOpp, newTempOpp)) {
                newTempOpp.On_Hold_Until__c = null;
            }
        }
    }
    
    private boolean isMovingFromOnHoldStatus(Opportunity oldOpp, Opportunity newOpp) {
        return oldOpp.StageName == ON_HOLD_STAGE && newOpp.StageName != ON_HOLD_STAGE;
    }
    
    public void createTasksForOpportunitiesInOnHoldStage(Map<Id, Opportunity> oldOpportunitiesMap,Map<Id, Opportunity> newOpportunitiesMap) {

        List<Opportunity> leadsInOnHoldStatus = getOpportunitiesInOnHoldStatus(oldOpportunitiesMap,newOpportunitiesMap);    
        
        //List<Event> tempEvent = [select OwnerId, whatId, Related_Property_Link__c from Event where whatId in :leadsInOnHoldStatus];
        
        //System.debug('Event to Delete size() = ' + tempEvent .size());
        //delete tempEvent;


        System.debug('leadsInOnHoldStatus.size() = ' + leadsInOnHoldStatus.size());
        
        List<Task> tasksToAdd = new List<Task>();

        for (Opportunity tempOpp : leadsInOnHoldStatus) {
            Task tempTask = createTask(tempOpp.id, tempOpp.On_Hold_Until__c);
            tasksToAdd.add(tempTask);
        }

        if (!tasksToAdd.isEmpty()) {
            insert tasksToAdd;
        }       
    }
    
    public List<Opportunity> getOpportunitiesInOnHoldStatus(Map<Id, Opportunity> oldOpportunitiesMap,Map<Id, Opportunity> newOpportunitiesMap) {

        List<Opportunity> leadsInOnHoldStatus = new List<Opportunity>();

        //List<Opportunity> newOpportunities = newOpportunitiesMap.values();
        
        Set<Id> theIds = oldOpportunitiesMap.keySet();
        
        for (Id tempId : theIds) {
            Opportunity oldTempOpp = oldOpportunitiesMap.get(tempId);
            Opportunity newTempOpp = newOpportunitiesMap.get(tempId);
            
            if (oldTempOpp.StageName != ON_HOLD_STAGE && newTempOpp.StageName == ON_HOLD_STAGE) {
                leadsInOnHoldStatus.add(newTempOpp);   
            }
        }
        /*            
        for (Opportunity tempOpp : newOpportunities) {
            
            if (tempOpp.StageName == ON_HOLD_STAGE) {
                leadsInOnHoldStatus.add(tempOpp);
            }
        }
        */
        return leadsInOnHoldStatus;
    }   
    
    //DK 10/15/14
    /*public void defaultCommunityProgram(Map<Id, Opportunity> newOppsMap){
        ID[] oppIDs = new ID[]{};
        for (Opportunity opp : newOppsMap.values()){
            if (opp.Property__c != null && opp.Community_Program_Offer__c == null)
                oppIDs.add(opp.ID);
        }
        
        if (oppIDs.isEmpty())
            return;
        
        Opportunity[] opps = [SELECT Community_Program_Offer__c, Property__c, Property__r.Property_ZIP__c, Property__r.Property_City__c, Property__r.Property_County__c FROM Opportunity WHERE ID IN :oppIDs];
        
        Map<Community_Program_Offer__c, Set<String>> commProgVals = new Map<Community_Program_Offer__c, Set<String>>();     //Community_Program_Offer__c --> Set of eligible values
        for (Community_Program_Offer__c cpo : [SELECT Eligibility_Criterion__c, Eligible_Values__c FROM Community_Program_Offer__c WHERE Active__c = true]){
            String[] vals = cpo.Eligible_Values__c.split(';');
            for (Integer i = 0; i < vals.size(); i++)
                vals[i] = vals[i].trim();
            Set<String> valSet = new Set<String>(vals);
            commProgVals.put(cpo, valSet);
        }
        
        Opportunity[] updateOpps = new Opportunity[]{};
        for (Opportunity opp : opps){
            String zip = opp.Property__r.Property_ZIP__c;
            String city = opp.Property__r.Property_City__c;
            String county = opp.Property__r.Property_County__c;
            String matchType = '';    //Could also be a boolean, but a string is more extendable if necessary
            for (Community_Program_Offer__c cpo : commProgVals.keySet()){
                Set<String> valSet = commProgVals.get(cpo);
                //Order of priority: zip, city, county
                if (cpo.Eligibility_Criterion__c == 'ZIP'){
                    if (valSet.contains(zip)){
                        opp.Community_Program_Offer__c = cpo.ID;
                        break;    //Quit once we find a matching zip
                    }
                } else if (cpo.Eligibility_Criterion__c == 'City'){
                    if (valSet.contains(city)){    //Supercedes any existing county matches
                        opp.Community_Program_Offer__c = cpo.ID;
                        matchType = 'city';
                    }
                } else if (cpo.Eligibility_Criterion__c == 'County'){
                    if (valSet.contains(county) && matchType != 'city')    //Only set the county match if no city has been found
                        opp.Community_Program_Offer__c = cpo.ID;
                }
            }
            if (opp.Community_Program_Offer__c != null)
                updateOpps.add(opp);
        }
        update updateOpps;
    }*/
    
    public Task createTask(Id theId, Date onHoldUntil) {

        Task tempTask = new Task();
        tempTask.whatId = theId;  
        tempTask.activityDate = onHoldUntil;
        
        tempTask.description = TASK_DESCRIPTION;
        tempTask.priority = TASK_PRIORITY;
        tempTask.status = TASK_STATUS;
        tempTask.subject = TASK_SUBJECT;
        
        return tempTask;        
    }
}       
/*         
//OLD!!!!!!!!!!!!        
        for (Opportunity opp : opps){
            
            String truncPropName = '';
            Integer truncPropSize = 10;
            String truncAcctName = '';
            Integer truncAcctSize = 5;
    
            // Truncate Account Name
            String acctName = [Select id, Name from Account where Id = :opp.AccountId limit 1].name;
            Integer acctLen = acctName.length();
            if(acctLen <= truncAcctSize){
                truncAcctName = acctName.substring(0, acctLen);
            } else {
                truncAcctName = acctName.substring(0, truncAcctSize);
            }
            truncAcctName = truncAcctName.trim(); 
            
            datetime DT = Datetime.now();
            String monthString = DT.format('yyMMM');  // 2 Digit Year followed by Abbreviated Month
            String nameToSet;
            // Truncate Prop Name if it exists
            if(opp.Property__c != null){
                Property__c p = [Select id, Name, Property_State__c from Property__c where Id = :opp.Property__c limit 1];
                String propName = p.name;
                String propState = p.Property_State__c;
                Integer propLen = propName.length();
                if(propLen <= truncPropSize){
                    truncPropName = propName.substring(0, propLen);
                } else {
                    truncPropName = propName.substring(0, truncPropSize);
                }
                truncPropName = truncPropName.trim();
                Integer CalMonth = date.today().month();
                
                //Construct Opp Name
                if (opp.Opp_Index__c == null){  //Only manage Opp_Index__c if it has not yet been set
                    
                    //Discover the opps for this property this month.  sort by Opp_Index__c Descending
                    List<Opportunity> oppsCreatedThisMonth = [
                        Select id, name, CreatedDate,Opp_Index__c  
                        from Opportunity 
                        where Opportunity.Property__c = :opp.Property__c 
                        and Opportunity.AccountId = :opp.AccountId
                        and CALENDAR_MONTH(CreatedDate) = :CalMonth
                        and Opportunity.Opp_Index__c != null
                        ORDER BY Opp_Index__c DESC];
                    
                    Integer currMaxOppIndex = 0;
                    if(oppsCreatedThisMonth.size() > 0){
                        currMaxOppIndex = integer.valueOf(oppsCreatedThisMonth[0].Opp_Index__c);
                    } 
                    opp.Opp_Index__c = currMaxOppIndex + 1; 
                }
                
                //o Varga-12660 Fred-11Feb now would be MD-Varga-12660 Fred-11Feb
                
                if (opp.Opp_Index__c > 1) { //More than one opportunity for this property this month
                     nameToSet = propState + '-' + truncAcctName + '-' + truncPropName + '-' + monthString + '-' + opp.Opp_Index__c;
                } else { //Only one opportunity for this property this month
                     nameToSet = propState + '-' + truncAcctName + '-' + truncPropName + '-' + monthString;
                }
                 
            } else { //Property is not yet assigned
                nameToSet = truncAcctName + '-' + monthString;
            }
            
            if(nameToSet <> opp.Name){
                System.debug('opp.Name --> ' + opp.Name);
                System.debug('nameToSet --> ' + nameToSet);
                opp.Name = nameToSet;
            }
        
        }
 
   }
}
}
*/