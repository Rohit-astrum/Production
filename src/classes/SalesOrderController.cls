/*
* MODIFICATION HISTORY
*  03/29/15  DK  Added support for optional Attachment ID parameter
*  06/16/15  PB  FPO Calculate and update costprojections
*  08/05/15  DK  Populate new fields that were created for CPQ-224.
*  09/09/15  DK  Calculate Commission_System_Price__c for CPQ-122.
*  10/07/15  PB  SO Apv Process - capture sold system design 
*/
global with sharing class SalesOrderController {
    
    public Account account {get; private set;}
    public Opportunity opportunity {get; private set;}
    public Property__c property {get; private set;}
    public SCRB_SalesOrder__c order {get; private set;}
    public OpportunityLineItem oppLineItem {get; private set;}
    public SCRB_SalesOrderLineItem__c[] salesOrderLineItems {get; private set;}
    public SCRB_SalesOrderLineItem__c salesOrderLineItem {get; private set;}
    public List<SCRB_SalesOrderLineItem__c> lineItems= new List<SCRB_SalesOrderLineItem__c>();
    public System_Design__c sysdes {get; private set;}
    private integer itemCount=0;
    
    private PriceBookEntry pbEntry;
    
    public Id soId;
        //Id accountId=ApexPages.currentPage().getParameters().get('aId');
    public Id oppId;
    

	webservice static void syncToOpp(String soId, String oppId){
		
		System.Debug('In SalesOrderController : syncToOpp --> ' + soId + '  oppId --> ' + oppId );
		Opportunity opportunity = SalesOrder_Utilitity.retrieveOppById(oppId);
		SCRB_SalesOrder__c order = SalesOrder_Utilitity.buildSalesOrderFromOpportunity(opportunity, soId);
		Milestone1_Project__c[] projects = [Select Sales_Order_Changed__c From Milestone1_Project__c Where Sales_Order__c=:soId];

		if(order.Changed_By_Sales__c == true && projects.size()>0){
			for(Milestone1_Project__c project:projects){
				project.Sales_Order_Changed__c=true;
				update(project);			
			}
		}
		SalesOrder_Utilitity.removeSOLineItems(order);
		List<SCRB_SalesOrderLineItem__c> salesOrderLineItems = SalesOrder_Utilitity.createSOLineItems(order, opportunity);
		update(order);
		upsert(salesOrderLineItems);

        //calculate and update cost projections
        CostProjectionProcessor.updateRtskCstProjections(order.Id);
	} 	
    
    public SalesOrderController() {
               
        Boolean ShowPartner=false;  
        soId = ApexPages.currentPage().getParameters().get('id');
        //Id accountId=ApexPages.currentPage().getParameters().get('aId');
        String oppId = ApexPages.currentPage().getParameters().get('oId');
		
		opportunity = SalesOrder_Utilitity.retrieveOppById(oppId);
		order = SalesOrder_Utilitity.buildSalesOrderFromOpportunity(opportunity, soId);
		salesOrderLineItems = SalesOrder_Utilitity.createSOLineItems(order, opportunity);
		
		account = [SELECT  
					a.name, 
                	a.Accounting_ID__c, 
                	a.JobCount__c,       
                    a.accountnumber, 
                    a.billingstreet, 
                    a.BillingCity, 
                    a.BillingState, 
                    a.BillingPostalCode, 
                    a.BillingCountry, 
                    a.ShippingStreet, 
                    a.ShippingCity, 
                    a.ShippingState, 
                    a.ShippingPostalCode, 
                    a.ShippingCountry, 
                    a.phone, 
                    a.fax 
		from Account a Where a.Id = :order.AccountId__c];
		
        //System.Debug('Finished Page Load');
	}
             
    //Returns the user back to the opportunities page this was launched from
    public PageReference cancel(){
        return (new ApexPages.StandardController(opportunity)).view();
    }

    //saves order and child orders
    public PageReference save() {
		System.Debug('Entering save() in SalesOrderController');
        
        try {
			SalesOrder_Utilitity.CreateJobId(account, opportunity, order);

            //SO Apv Process - Automated assignment of SO
            try{
                Senior_Project_Compliance_Member__c complianceSpecialist = [SELECT User__c FROM Senior_Project_Compliance_Member__c ORDER BY Date_Last_SO_Assigned__c ASC LIMIT 1];
                order.Contract_Admin__c = complianceSpecialist.User__c;

                complianceSpecialist.Date_Last_SO_Assigned__c = Datetime.now();
                update complianceSpecialist;

            }catch(QueryException qe){}
            
			insert order;
     		System.Debug('New Sales Order: ' + order.id);
     		for (SCRB_SalesOrderLineItem__c li: salesOrderLineItems){
         		li.SalesOrderId__c = order.id;                   
     		}
     		
     		insert salesOrderLineItems;

            //--- Update the "Applied" junction objects [CPQ-818] ---//
            if (order.Astrum_Contract__c != null){
                Applied_Price_Adjustment__c[] appliedPriceAdjs = [SELECT Sales_Order__c FROM Applied_Price_Adjustment__c WHERE Astrum_Contract__c = :order.Astrum_Contract__c];
                Applied_Incentive_Offer__c[] appliedIncOffers = [SELECT Sales_Order__c FROM Applied_Incentive_Offer__c WHERE Astrum_Contract__c = :order.Astrum_Contract__c];
                Applied_SREC_Contract_Offer__c[] appliedSrecOffers = [SELECT Sales_Order__c FROM Applied_SREC_Contract_Offer__c WHERE Astrum_Contract__c = :order.Astrum_Contract__c];
                //Each query should only return one record, but bulkify the handling to be safe
                for (Applied_Price_Adjustment__c apa : appliedPriceAdjs)
                    apa.Sales_Order__c = order.ID;
                for (Applied_Incentive_Offer__c aio : appliedIncOffers)
                    aio.Sales_Order__c = order.ID;
                for (Applied_SREC_Contract_Offer__c asco : appliedSrecOffers)
                    asco.Sales_Order__c = order.ID;
                update appliedPriceAdjs;
                update appliedIncOffers;
                update appliedSrecOffers;
            }
     		
     		//If the Opportunity Stage is not 'Closed Won' then update it
			if (Opportunity.StageName != 'Closed - Won'){
         		Opportunity.StageName = 'Closed - Won';
				update Opportunity;
            }

            String signedContractPdfID = ApexPages.currentPage().getParameters().get('attchID');    //DK 3-29-15
            if (String.isNotBlank(signedContractPdfID)){
                //The CloseContract VF page sent us a Contract Attachment that needs to be cloned onto the new Sales Order
                try {
                    Attachment existingPDF = [SELECT Name, Body FROM Attachment WHERE ID = :signedContractPdfID LIMIT 1];
                    Attachment newPDF = new Attachment(Name = existingPDF.Name, ContentType = 'application/pdf', Body = existingPDF.Body, ParentID = order.ID);
                    delete existingPDF;
                    insert newPDF;
                } catch (Exception e){
                    System.debug('Attachment handling failed: ' + e.getStackTraceString());
                }
            }

            // Check for Sighten External Contract
            try{
                List<Astrum_Contract__c> contracts = [SELECT Id, Sighten_Signing_Status__c FROM Astrum_Contract__c WHERE Id = :opportunity.Astrum_Contract__c LIMIT 2];
                if(contracts.size() == 1){
                    Id contractId = contracts[0].Id;

                    List<Attachment> attachmentsToInsert = new List<Attachment>();
                    List<Attachment> attachments = [SELECT Name, Body, ContentType FROM Attachment WHERE ParentId = :contractId AND Name LIKE '%_ext_Signed%' ORDER BY CreatedDate DESC LIMIT 1];
                    for(Attachment att : attachments){
                        Attachment newAtt = new Attachment();
                        newAtt.Name = att.Name;
                        newAtt.Body = att.Body;
                        newAtt.ContentType = att.ContentType;
                        newAtt.ParentId = order.Id;
                        //Attachment newAtt = att.clone();
                        //newAtt.ParentId = order.Id;
                        attachmentsToInsert.add(newAtt);
                    }
                    insert attachmentsToInsert;
                } else {
                    System.debug('**SZ: No contract could be found based on the opportunity.');
                    return null;
                }
            } catch(Exception e){
                System.debug('Update Exception --> ' + e);
                ApexPages.addMessages(e);
                return null;
            }

		} catch(System.DMLException e) {
    		System.debug('Update Exception --> ' + e);
    		ApexPages.addMessages(e);
			return null;
		}         
                     
        //  After Save, navigate to the default view page:  
        return (new ApexPages.StandardController(order)).view();
 	}
  

    public PageReference loadHelpPage(){
        PageReference pg = new PageReference('/apex/CreateSalesOrderHelp');
        return pg;
    }

}