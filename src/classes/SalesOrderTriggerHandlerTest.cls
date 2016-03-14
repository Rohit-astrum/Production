/* FILE: SalesOrderTriggerHandlerTest.cls
 * AUTHOR: Mike Katulka
 * DATE: 2014-04-07
 * PURPOSE: Test class for SalesOrderTrigger
 * MODIFICATION HISTORY
 *
 */
 
@isTest(seealldata=true)
public class SalesOrderTriggerHandlerTest {
	
	static testMethod void testSalesOrderApprovalProcess() {
		
		Data_Tracking_Project__c dtp= testData.createDtpWithAllData();

        Test.startTest();
        
	    SCRB_SalesOrder__c salesOrder = [select id, statusCode__c from SCRB_SalesOrder__c where id =: dtp.Sales_Order__c];	    
	    salesOrder.statusCode__c = 'Submit Pending';
        salesOrder.Contract_Admin__c = UserInfo.getUserId();
	    update salesOrder;

        Map<id, SCRB_SalesOrder__c> salesMap = new Map<id, SCRB_SalesOrder__c>();
        salesMap.put(salesOrder.Id, salesOrder);
        SalesOrderTriggerHandler.salesOrderCaptureData(new List<SCRB_SalesOrder__c>{salesOrder}, salesMap, true); 

	    //Entry criteria for first approval process:
	    System.assertEquals('Submit Pending', [select statusCode__c from SCRB_SalesOrder__c where id =: salesOrder.id].statusCode__c);
	    System.assertEquals('Closed - Won', [select OpportunityId__r.StageName from SCRB_SalesOrder__c where id =: salesOrder.id].OpportunityId__r.StageName);
	    

		// Create an approval request
        //ProcessResult class: http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_ProcessResult.htm
        //Valid values are: Approved, Rejected, Removed or Pending.        
        Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(salesOrder.id);
        
        // Submit the approval request
        Approval.ProcessResult result = Approval.process(req1);
        
        // Verify the result
        System.assert(result.isSuccess());
        
        System.assertEquals('Pending', result.getInstanceStatus()); 
        //System.assertEquals('Submitted', [select statusCode__c from SCRB_SalesOrder__c where id =: salesOrder.id].statusCode__c);
        //System.assertEquals('Sales Submitted', [select statusCode__c from SCRB_SalesOrder__c where id =: salesOrder.id].statusCode__c);
        
        // Approve the submitted request
        // First, get the ID of the newly created item
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        
        // Instantiate the new ProcessWorkitemRequest object and populate it
        Approval.ProcessWorkitemRequest req2 = 
            new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        
        // Use the ID from the newly created item to specify the item to be worked
        req2.setWorkitemId(newWorkItemIds.get(0));
        
        // Submit the request for approval
        Approval.ProcessResult result2 =  Approval.process(req2);
        
        // Verify the results
        System.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());
        
        System.assertEquals('Approved', result2.getInstanceStatus());
        //Automatic rejection based on step 1 of "Contract Administrator Approval 4"
        //System.assertEquals('Contract Administrator Rejected', [select statusCode__c from SCRB_SalesOrder__c where id =: salesOrder.id].statusCode__c);
        //System.assertEquals('Prelim Approved', [select statusCode__c from SCRB_SalesOrder__c where id =: salesOrder.id].statusCode__c);

        Test.stopTest();
	}

    //SOA PB 11/20/2015
    static testMethod void salesorderEmailTest(){
        
        Data_Tracking_Project__c dtp= testData.createDtpWithAllData();

        Test.startTest();
        
        SCRB_SalesOrder__c salesOrder = [select id, statusCode__c from SCRB_SalesOrder__c where id =: dtp.Sales_Order__c];      
        
        PM_Project__c proj = new PM_Project__c();
        proj.Name = 'Test proj for salesorder';
        proj.Sales_Order__c = salesOrder.Id;
        proj.Project_Lead__c = UserInfo.getUserId();
        proj.Electrical_Designer__c = UserInfo.getUserId();
        proj.Project_Engineer__c = UserInfo.getUserId();
        proj.System_Designer__c = UserInfo.getUserId();
        insert proj;

        salesOrder.StatusCode__c = 'Canceled';
        salesOrder.Contract_Admin__c = UserInfo.getUserId();
        salesOrder.Finance_Associate__c = UserInfo.getUserId();
        salesOrder.Incentive_Associate__c = UserInfo.getUserId();
        update salesOrder;

        Test.stopTest();
         /*   
        salesOrder = [select id, statusCode__c from SCRB_SalesOrder__c where id =: salesOrder.Id];      
        salesOrder.StatusCode__c = 'Prelim Approved';
        salesOrder.Prelim_Approval_Date__c = Datetime.now();
        update salesOrder;

        salesOrder = [select id, statusCode__c from SCRB_SalesOrder__c where id =: salesOrder.Id];      
        salesOrder.StatusCode__c = 'Final/Accounting Approved';
        salesOrder.Approval_Date__c = Datetime.now();
        update salesOrder;*/
    }

    //SOA PB 11/20/2015
    static testMethod void salesorderEmailTest2(){
        
        Data_Tracking_Project__c dtp= testData.createDtpWithAllData();

        Test.startTest();
        
        SCRB_SalesOrder__c salesOrder = [select id, statusCode__c from SCRB_SalesOrder__c where id =: dtp.Sales_Order__c];      
        
        PM_Project__c proj = new PM_Project__c();
        proj.Name = 'Test proj for salesorder';
        proj.Sales_Order__c = salesOrder.Id;
        proj.Project_Lead__c = UserInfo.getUserId();
        proj.Electrical_Designer__c = UserInfo.getUserId();
        proj.Project_Engineer__c = UserInfo.getUserId();
        proj.System_Designer__c = UserInfo.getUserId();
        insert proj;

        salesOrder.Contract_Admin__c = UserInfo.getUserId();
        salesOrder.Finance_Associate__c = UserInfo.getUserId();
        salesOrder.Incentive_Associate__c = UserInfo.getUserId();
        salesOrder.StatusCode__c = 'Prelim Approved';
        salesOrder.Prelim_Approval_Date__c = Datetime.now();
        update salesOrder;

        Test.stopTest();

    }
    //SOA PB 11/20/2015
    static testMethod void salesorderEmailTest3(){
        
        Data_Tracking_Project__c dtp= testData.createDtpWithAllData();

        Test.startTest();
        
        SCRB_SalesOrder__c salesOrder = [select id, statusCode__c from SCRB_SalesOrder__c where id =: dtp.Sales_Order__c];      
        
        PM_Project__c proj = new PM_Project__c();
        proj.Name = 'Test proj for salesorder';
        proj.Sales_Order__c = salesOrder.Id;
        proj.Project_Lead__c = UserInfo.getUserId();
        proj.Electrical_Designer__c = UserInfo.getUserId();
        proj.Project_Engineer__c = UserInfo.getUserId();
        proj.System_Designer__c = UserInfo.getUserId();
        insert proj;

        salesOrder.Contract_Admin__c = UserInfo.getUserId();
        salesOrder.Finance_Associate__c = UserInfo.getUserId();
        salesOrder.Incentive_Associate__c = UserInfo.getUserId();
        salesOrder.StatusCode__c = 'Final/Accounting Approved';
        salesOrder.Approval_Date__c = Datetime.now();
        update salesOrder;

        Test.stopTest();

    }   	
	
}