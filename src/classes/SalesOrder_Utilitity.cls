global with sharing class SalesOrder_Utilitity {
    public class MissingAccountException extends Exception {}
    public class MissingPropertyException extends Exception {}
    public class NoLineItemsException extends Exception {}

    public static SCRB_SalesOrder__c buildSalesOrderFromOpportunity(Opportunity opportunity, String soId){ 
        //soId can be null - if not null, the salesorder will be retrieved and updated.  If null, we'll create a new sales order
        Account acct = new Account();   
                   
        if  (opportunity.AccountId != null){ 
             acct = [SELECT 
                    Name, 
                    AccountNumber, 
                    Accounting_ID__c,
                    JobCount__c,    
                    BillingStreet, 
                    BillingCity, 
                    BillingState, 
                    BillingPostalCode, 
                    BillingCountry,
                    ShippingStreet,  
                    ShippingCity, 
                    ShippingState, 
                    ShippingPostalCode, 
                    ShippingCountry, 
                    Phone, 
                    Fax 
                FROM Account 
                WHERE Id = :opportunity.AccountId] ;
        }else {
             throw new MissingAccountException('Cannot create an order from this opportunity: Please assign an account to the opportunity.  opportunity.Id --> ' + opportunity.Id );        
        }
 
        Property__c property = new Property__c();
                
        if  (opportunity.Property__c != null){  
               
                property = [
                    SELECT 
                    name, //Property_Address_1
                    Survey_Count__c,
                    RecordTypeId,
                    Qualified_Utililty_Service_Count__c,
                    Property_ZIP__c,
                    Property_State__c,
                    Property_Owner__c,
                    Property_County__c,
                    Property_City__c,
                    Property_Address_2__c,
                    Permit_Jurisdiction__c,
                    OwnerId,
                    Optimal_Site_Quality_kWh_y_kW__c,
                    HOA_Contact_Phone__c,
                    HOA_Contact_Name__c,
                    HOA_Contact_Email__c,
                    ConnectionSentId,
                    ConnectionReceivedId,
                    Authorization_Bodies__c,
                    Astrum_Office__c,
                    Account_Number__c,
                    Astrum_Sales_Region__r.Sales_Coordinator__c,
                    Astrum_Office_New__r.Director_of_Operations__c,
                    Astrum_Office_New__r.Sales_Alert_Email__c                                    
                FROM Property__c 
                WHERE id = :opportunity.Property__c] ;
        }else {
             throw new MissingPropertyException('Cannot create an order from this opportunity: Please assign a property to the opportunity.');        
        }
        
        Boolean newOrder=false;
        if(soId==null){
            newOrder=true;
        }
        SCRB_SalesOrder__c order = (soId == null) ? new SCRB_SalesOrder__c() : 
        [SELECT SCRB_SalesOrder__c.Name, StatusCode__c, Astrum_Contract__c, Commission_System_Price__c, OwnerID, Regional_Sales_Manager_Commission__c FROM SCRB_SalesOrder__c WHERE id = :soId];
                                       
        //Pre-populate Opportunity and account information
        //order.Name=Opportunity.Name;
        order.AccountId__c=opportunity.AccountId;             
        order.OpportunityId__c = opportunity.id;
        order.Description__c=opportunity.description;
        order.Amount__c = opportunity.Amount;
        order.discountAmount__c=0;
        order.freightAmount__c=0; 
        order.Type__c='Order';
        if(newOrder){
            order.StatusCode__c='Submit Pending';
        } else {
            if(order.StatusCode__c=='Sales Manager Approved'){order.Changed_By_Sales__c = true;}

            if (order.Astrum_Contract__c != null && opportunity.Astrum_Contract__c != null && order.Astrum_Contract__c != opportunity.Astrum_Contract__c){
                //Reset the "Applied" junctions [CPQ-818]
                Applied_Price_Adjustment__c[] appliedPriceAdjs = [SELECT Sales_Order__c, Astrum_Contract__c FROM Applied_Price_Adjustment__c 
                                                                  WHERE Astrum_Contract__c = :order.Astrum_Contract__c OR Astrum_Contract__c = :opportunity.Astrum_Contract__c];
                Applied_Incentive_Offer__c[] appliedIncOffers = [SELECT Sales_Order__c, Astrum_Contract__c FROM Applied_Incentive_Offer__c 
                                                                 WHERE Astrum_Contract__c = :order.Astrum_Contract__c OR Astrum_Contract__c = :opportunity.Astrum_Contract__c];
                Applied_SREC_Contract_Offer__c[] appliedSrecOffers = [SELECT Sales_Order__c, Astrum_Contract__c FROM Applied_SREC_Contract_Offer__c 
                                                                      WHERE Astrum_Contract__c = :order.Astrum_Contract__c OR Astrum_Contract__c = :opportunity.Astrum_Contract__c];
                for (Applied_Price_Adjustment__c apa : appliedPriceAdjs)
                    apa.Sales_Order__c = apa.Astrum_Contract__c == opportunity.Astrum_Contract__c ? soId : null;
                
                for (Applied_Incentive_Offer__c aio : appliedIncOffers)
                    aio.Sales_Order__c = aio.Astrum_Contract__c == opportunity.Astrum_Contract__c ? soId : null;

                for (Applied_SREC_Contract_Offer__c asco : appliedSrecOffers)
                    asco.Sales_Order__c = asco.Astrum_Contract__c == opportunity.Astrum_Contract__c ? soId : null;

                update appliedPriceAdjs;
                update appliedIncOffers;
                update appliedSrecOffers;
            }
        }
        order.RequestedShipmentOn__c=Date.Today() + 60;
        order.DocumentDate__c=Date.Today();
        System_Design__c sysdes; 
        if(opportunity.System_Design_Quote__c != null){
            sysdes = [Select System_Makeup__c, Total_System_Size_kW__c, Panel_Count__c FROM System_Design__c WHERE id=:[Select System_Design__c FROM System_Design_Quote__c WHERE id=:opportunity.System_Design_Quote__c LIMIT 1].System_Design__c];
            System_Design_Quote__c sdq = opportunity.System_Design_Quote__r;
            order.System_Design_Quote__c = sdq.ID;
            // Added by RJ 1/22/14
            order.Upfront_Lease_Payment_Due_at_Final_Comp__c = sdq.NRG_Prepay_Amount__c;
            order.Astrum_Upfront_SREC_Value__c = sdq.Upfront_SREC_Value__c;
            order.Sales_Tax_Prepaid__c = sdq.Sales_Tax_Prepaid__c;

            //CPQ-224
            order.Rate_Code_Before_Solar__c = sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_Before_Solar__c;
            order.Rate_Code_After_Solar__c = sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_After_Solar__c;
            order.Custom_Utility_Rate_Set_By__c = sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Custom_Utility_Rate_Set_By__c;
            order.Custom_Utility_Rate_Applied__c = sdq.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Custom_Utility_Rate_Applied__c;

            //SO Apv Process - capture sold system design PB 10/07/2015
            order.Sold_System_Design__c = sdq.System_Design__c;

            if (opportunity.Closed_Scenario__c != null){
                String n = opportunity.Closed_Scenario__c;
                order.Cash_Rebate_Amount__c = (Decimal)sdq.get('Scenario_' + n + '_Total_Net_Adjustment__c');  //CPQ-792
                order.Commission_System_Price__c = sdq.get('Scenario_' + n + '_Adjusted_Price_NUM__c') != null ? (Decimal)sdq.get('Scenario_' + n + '_Adjusted_Price_NUM__c') : 0;
            } else {
                order.Commission_System_Price__c = -1;  //To make it clear that an error occurred
            }
        }
                      
        if(sysdes != null) {
            order.System_Makeup__c = sysdes.System_Makeup__c;
            order.System_Size_kW__c = sysdes.Total_System_Size_kW__c;
            order.Total_Panel_Count__c = sysdes.Panel_Count__c;
        }
        order.BillingStreet__c = acct.BillingStreet;
        order.BillingCity__c=acct.BillingCity;
        order.BillingState__c=acct.BillingState;
        order.BillingPostalCode__c=acct.BillingPostalCode;
        order.BillingPhone__c=acct.Phone;
        order.BillingFax__c=acct.Fax;
        order.BillingCountry__c=acct.BillingCountry;                                
         
        order.ShippingStreet__c= acct.ShippingStreet;
        order.ShippingCity__c=acct.ShippingCity;
        order.ShippingState__c=acct.ShippingState;
        order.ShippingPostalCode__c=acct.ShippingPostalCode;
        order.ShippingPhone__c=acct.Phone;
        order.ShippingFax__c=acct.Fax;
        order.ShippingCountry__c=acct.ShippingCountry;
             
        //Begin Astrum Specific Order Fields
             
        order.Property__c = property.id;
        order.Installation_Address_1__c=property.name;
        order.Installation_Address_2__c=property.Property_Address_2__c;
        order.Installation_City__c=property.Property_City__c;
        order.Installation_State__c=property.Property_State__c;
        order.Installation_Zip_PostalCode__c=property.Property_ZIP__c;
        order.Installation_Permit_Jurisdiction__c=property.Permit_Jurisdiction__c;
         
        order.Opportunity_Close_Date__c = opportunity.CloseDate;
        order.Financing_Option__c = opportunity.Financing_Option__c;
        order.Financing_Type__c = opportunity.Financing_Type__c;
        order.Leasing_Option__c = opportunity.Leasing_Option__c;
        // Added by RJ on 10/24/13
        order.Lease_PPA_Fund__c = opportunity.Lease_PPA_Fund__c;

        //CPQ-748
        order.Astrum_Contract__c = opportunity.Astrum_Contract__c;
        order.SREC_Contract_Discount__c = opportunity.SREC_Contract_Discount__c;
        order.SREC_Cash_Back__c = opportunity.SREC_Cash_Back__c;
        order.Closed_Scenario__c = opportunity.Closed_Scenario__c;

        //CPQ-795
        order.Sold_Financing_Rate_Year_1_kWh__c = opportunity.Sold_Financing_Rate_Year_1_kWh__c;
        order.Lease_Escalator__c = opportunity.Sold_Lease_Escalator__c;

        // Added by RJ 1/18/13
        order.Sales_Coordinator__c = property.Astrum_Sales_Region__r.Sales_Coordinator__c;
        order.Director_of_Operations__c = property.Astrum_Office_New__r.Director_of_Operations__c;      
        order.Sales_Alert_Email__c = property.Astrum_Office_New__r.Sales_Alert_Email__c;        
        order.Owner_User__c = UserInfo.getUserId();
        
        // SO Apv Process changes - set Approved_System_Design__c PB 10/07/2015 
        order.Approved_System_Design__c = opportunity.Approved_System_Design__c;
        
        User contactDetail;
        User ownerUser;
        ID ownerID = order.OwnerID != null ? order.OwnerID : order.Owner_User__c;
        for (User u : [SELECT Alias, Email, Profile.Name, ManagerID, Manager.ManagerID, Manager.Manager.ManagerID FROM User WHERE ID = :ownerID OR Alias = :opportunity.Contact_Detail__c]){
            if (u.Alias == opportunity.Contact_Detail__c)
                contactDetail = u;
            if (u.ID == ownerID)
                ownerUser = u;
        }

        if (opportunity.contact_detail__c != null && contactDetail != null)
            order.Contact_Detail_Email__c = contactDetail.email;    

        //CPQ-790
        Decimal regionalManagerCommissionRate = ContractSettings__c.getOrgDefaults().Regional_Sales_Manager_Commission_Rate__c != null ? ContractSettings__c.getOrgDefaults().Regional_Sales_Manager_Commission_Rate__c/100.0 : 0.005;
        
        if (newOrder){
            if (ownerUser.Profile.Name == 'Sales User'){
                order.Regional_Sales_Manager_Name__c = ownerUser.ManagerID;
            } else if (ownerUser.Profile.Name == 'Sales Manager') {
                order.Regional_Sales_Manager_Name__c = ownerUser.ID;
            }
        }

        order.Regional_Sales_Manager_Commission__c = 0;
        if (ownerUser.Profile.Name == 'Sales User')
            order.Regional_Sales_Manager_Commission__c = order.Commission_System_Price__c * regionalManagerCommissionRate;

        //End Astrum Specific     
        
        return order;
    }    
   
    public static void CreateJobId(Account acct, Opportunity opportunity, SCRB_SalesOrder__c objOrder)
    {
        // 
        // Create the Job Id
        //
        integer idx = acct.Accounting_ID__c.indexOf('-');   
        integer cnt = 0;            
        
        if (acct.JobCount__c != null)
        {
            cnt = acct.JobCount__c.intValue();  
        }                           
            
        cnt++;
        acct.JobCount__c = cnt;
        
        // update the account with the new job count
       
        try
        {
            update(acct);
        }
        catch (DmlException de)
        {
            throw new MissingAccountException(de.getMessage());         
        }
        
        
        // Lead char comes from financing type
        // Figure out if "L" or "P"     
        String jobId;
        jobId = opportunity.Financing_Type__c.substring(0,1);
        
        jobId += acct.Accounting_ID__c.substring(idx) + '-' + cnt;
        
        objOrder.Job_Id__c = jobId;                         
    }
    
    public static List<SCRB_SalesOrderLineItem__c> createSOLineItems(SCRB_SalesOrder__c order, Opportunity opportunity){
        //Retrieve the PriceBook name for Prepopulation in order 
        string pbID = opportunity.Pricebook2Id;
        PriceBook2 pb = (opportunity.Pricebook2Id == null) ? new PriceBook2() : 
        [Select Id, Name from Pricebook2 where Id=:pbID];
        order.Pricebook__c=pb.Name;     
         
        //Create a new SCRB_SalesOrderLineItem__c and populate a row for each oppLineItem that exists
        
        integer i = 0;
        List<SCRB_SalesOrderLineItem__c> salesOrderLineItems = new SCRB_SalesOrderLineItem__c[0];
        for(OpportunityLineItem oli: [SELECT Id, SortOrder, 
                                        PricebookEntryId, Description, Quantity, 
                                        ListPrice, UnitPrice, TotalPrice, ServiceDate 
                                      FROM OpportunityLineItem 
                                      WHERE Opportunityid = :opportunity.Id]){
            string pbeID = oli.PricebookEntryId;
            PriceBookEntry pbEntry = (pbeId == null) ? new PriceBookEntry() : 
            [Select Id, Name, Pricebook2Id, Product2Id, ProductCode from PricebookEntry where Id=:pbeID];
                       
            SCRB_SalesOrderLineItem__c salesOrderLineItem = new SCRB_SalesOrderLineItem__c();
            salesOrderLineItem.SalesOrderId__c=order.Id;
            salesOrderLineItem.SortOrder__c = i+1;
            salesOrderlineItem.ProductId__c = pbEntry.Product2Id;  
            salesOrderLineItem.Name = pbEntry.Name;
            salesOrderLineItem.Quantity__c = oli.Quantity;
            salesOrderLineItem.ListPrice__c= oli.ListPrice;
            salesOrderLineItem.SalesPrice__c=oli.UnitPrice;
            salesOrderLineItem.TotalPrice__c=oli.TotalPrice;
            salesOrderLineItem.RequestedShipmentOn__c=Date.Today();
            SalesOrderLineItems.add(salesOrderLineItem);
            i++;
        }
        Integer itemCount=i;
        if (itemCount == 0) {
            throw new NoLineItemsException('Unable to create Sales Order: Products must be added to the Opportunity before creating a Sales Order.');
        }
        
        return salesOrderLineItems;     
    }

    public static void removeSOLineItems(SCRB_SalesOrder__c so){
            List<SCRB_SalesOrderLineItem__c> salesOrderLineItems = [
                            Select s.SalesOrderId__c, 
                            s.Id 
                            From SCRB_SalesOrderLineItem__c s 
                            Where s.SalesOrderId__c = :so.Id];
            delete(salesOrderLineItems);
    }

    public static Opportunity retrieveOppById(Id oppId){
        System.Debug('In SalesOrder_Utilitity : retrieveOppById - oppId --> ' + oppId );
        
        // SO Apv Process changes - fetch Approved_System_Design__c PB 10/07/2015
        Opportunity opportunity = [SELECT name, Property__c, Astrum_Contract__c, SREC_Contract_Discount__c, SREC_Cash_Back__c, Closed_Scenario__c, 
                                    accountID, CloseDate, Sold_Financing_Rate_Year_1_kWh__c, Sold_Lease_Escalator__c,  
                                    Description, StageName, System_Design_Quote__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_Before_Solar__c, 
                                    System_Design_Quote__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Utility_Rate_Code_After_Solar__c, 
                                    System_Design_Quote__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Custom_Utility_Rate_Set_By__c, 
                                    System_Design_Quote__r.System_Design__r.Default_CB_Panel__r.Utility_Service__r.Custom_Utility_Rate_Applied__c, 
                                    Pricebook2Id, System_Design_Quote__r.Upfront_SREC_Value__c,System_Design_Quote__r.Sales_Tax_Prepaid__c,
                                    System_Design_Quote__r.NRG_Prepay_Amount__c,  System_Design_Quote__r.System_Design__r.Tree_Removal__c,
                                    Amount,Financing_Option__c,Financing_Type__c,Leasing_Option__c,Contact_Detail__C,Lease_PPA_Fund__c,
                                    Approved_System_Design__c, System_Design_Quote__r.Scenario_1_Total_Net_Adjustment__c, 
                                    System_Design_Quote__r.Scenario_2_Total_Net_Adjustment__c, System_Design_Quote__r.Scenario_3_Total_Net_Adjustment__c, 
                                    System_Design_Quote__r.Scenario_4_Total_Net_Adjustment__c, System_Design_Quote__r.Scenario_1_Adjusted_Price_NUM__c, 
                                    System_Design_Quote__r.Scenario_2_Adjusted_Price_NUM__c, System_Design_Quote__r.Scenario_3_Adjusted_Price_NUM__c, 
                                    System_Design_Quote__r.Scenario_4_Adjusted_Price_NUM__c 
                                    //Amount, Financing_Type__c, Leasing_Option__c
                                   FROM Opportunity 
                                   WHERE id = :oppId];
        System.Debug('opportunity --> ' + opportunity );
        return opportunity;
    }
}