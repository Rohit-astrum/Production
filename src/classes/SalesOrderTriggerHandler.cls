/* FILE: SalesOrderTriggerHandler.cls
 * AUTHOR: Michael Katulka
 * DATE: 2014-04-03
 * PURPOSE: To handle all code logic for the SalesOrderTrigger.trigger
 * MODIFICATION HISTORY: 
 *        MK - 2014-04-04: Moved other trigger code into this combined trigger handler
 *        SZ - 2015-04-14: Added code for setting fields related to commissions
 *         PB - 10/06/2015: SOA - reference apv date (datetime) instead of (date)
 *         PB - 10/06/2015: SOA - Send email when order is cancelled
 *         PB - 12/15/2015: SOA Sprint2 - 47 fix for Sales Order numbers duplication 
 *         PB - 12/15/2015: SFS-652 - fix for Sales Order numbers duplication
 *         PB - 01/04/2016: SOA - 53,55 Additional recipients for Sales Order Email 
 */
public class SalesOrderTriggerHandler {

    public static boolean isSalesOrderTriggerRunning = false;
    public static boolean skipSalesOrderTrigger = false;
    private static boolean firstRunFlag = true;
    public static boolean firstRun(){
      if(firstRunFlag){
       firstRunFlag=false;
       return true;
      }else{
          return firstRunFlag;
      }
    }

  //Summary by MK on 2014-04-04:
  //Set SO name and assign to director of operations as needed
  //Field: Assign to Dir of Ops – when checked should change the owner of the SO to the director of operations
  //SO Name should be “SO-yyMMdd-#”  where # represents the 1-n of SO’s created today.  The first SO for the day would be 0, the second 1, etc. 
  public static void setNameAndAssignOnInsert(list<SCRB_SalesOrder__c> salesOrders, boolean fromTrigger){
    ////Integer soCount = [Select Count() from SCRB_SalesOrder__c so WHERE so.CreatedDate = TODAY ALL ROWS];
    datetime DT = Datetime.now();
        String dateString = DT.format('yyMMdd');  // 2 Digit Year followed by Month and Day 
        Integer i = 0;

        String namestr = 'SO-' + dateString + '-%';
        Integer nextOrderNumber = 0;
        List <SCRB_SalesOrder__c> todaysOrders = new List<SCRB_SalesOrder__c>();
        
        /*todaysOrders = [Select name from SCRB_SalesOrder__c so WHERE so.name LIKE :namestr ORDER BY Name DESC ALL ROWS ];
        if(todaysOrders.size()>0){
          nextOrderNumber =  Integer.valueOf(todaysOrders[0].Name.Substring(10)) + 1 ;
        }*/
        //SFS-652
        Integer soCount = [Select Count() from SCRB_SalesOrder__c WHERE Name LIKE :namestr ALL ROWS ];
        
        nextOrderNumber = soCount + 1 ;

        for(SCRB_SalesOrder__c rec : salesOrders)
        {   
            //MK - 2014-04-04 - Refactor this, no soql inside for loop, all common variables set outside of for loop
            //Integer soCount = [Select Count() from SCRB_SalesOrder__c so WHERE so.CreatedDate = TODAY];
            //String soName = 'SO-' + dateString + '-' + soCount;     //MK - 2014-04-04 - refactored because if 2 are inserted at the same time, the name would have been the same.
            ////String soName = 'SO-' + dateString + '-' + (soCount + i);     
            ////i++; //Prevent duplicate names, increase for the next SO.
            
          String soName = 'SO-' + dateString + '-' + nextOrderNumber;
          nextOrderNumber++;
          System.debug('soName:' + soName);
            rec.Name = soName;
            
            if (rec.Assign_to_Dir_of_Ops__c){
                rec.OwnerId = rec.Director_of_Operations__r.Id;
                rec.Assign_to_Dir_of_Ops__c = false;
            }
        
      }
      if(!fromTrigger) update salesOrders;
    }


  /* FILE: SalesOrderSalesRegion.trigger
   * AUTHOR: Tino Mattheou
   * DATE: August 16, 2012
   * PURPOSE: set the sales region on sales order based on the property sales region when sales order is attached to a property
   * MODIFICATION HISTORY
   *                 //MK - 2014-04-04 - Moved from seperate trigger into common handler
   */
     public static void updateSalesRegion(list<SCRB_SalesOrder__c> salesOrders, map<id, SCRB_SalesOrder__c> salesOrdersOldMap, boolean fromTrigger, boolean isInsert){
    //don't perform updates if property opportunity trigger is updating the opportunity or bypass is on
    if (SalesRegionHelper.propertyOpportunityTriggerFiring
    || SalesRegionHelper.bypassSalesRegionTriggers) {
      System.debug('** Return '+SalesRegionHelper.propertyOpportunityTriggerFiring + ' '+SalesRegionHelper.bypassSalesRegionTriggers);
      return;
    }

    List<SCRB_SalesOrder__c> ordersToUpdate = new List<SCRB_SalesOrder__c>();
    Set<Id> propertyIds = new Set<Id>();

    for (SCRB_SalesOrder__c so : salesOrders) {
      if (so.Property__c != null
      && (isInsert
      || so.Sales_Region__c == null
      || SalesRegionHelper.reprocessSalesRegions //force update to sales region
      || so.Property__c != salesOrdersOldMap.get(so.Id).Property__c)) {
        propertyIds.add(so.Property__c);
        ordersToUpdate.add(so);
      }
    }
    
    if (!ordersToUpdate.isEmpty()) {
    
      Map<Id, Property__c> propertyMap = new Map<Id, Property__c>(
        [SELECT Id, Sales_Region__c
        FROM Property__c
        WHERE Id IN :propertyIds]
      );
    
      for (SCRB_SalesOrder__c so : ordersToUpdate) {
        Property__c property = propertyMap.get(so.Property__c);
        if (property != null) {
          so.Sales_Region__c = property.Sales_Region__c;
        }  
      }

      if(!fromTrigger) update ordersToUpdate;
    
    }

  }

  //Summary by MK on 2014-04-04:
  //Make sure Sales coordinator is set properly which gets copied from the “Property.Astrum Sales Region.Sales Coordinator” record.
  //Capture comments feature: This copies comments from the approval steps into a field on the sales order called “SO Approval/Rejection Comments”
  //Copy field values into "old" field values when first time status = "Conversion Pending" 
  public static void salesOrderCaptureData(list<SCRB_SalesOrder__c> salesOrders, map<id, SCRB_SalesOrder__c> salesOrdersOldMap, boolean fromTrigger){
        System.debug(loggingLevel.ERROR, 'In salesOrderCaptureData');
    if(!fromTrigger) return;
    Map<Id, SCRB_SalesOrder__c> salesOrdersToCapture  = new Map<Id,SCRB_SalesOrder__c>();   
      for (SCRB_SalesOrder__c rec : salesOrders) {      
        //Only get from old map once
        SCRB_SalesOrder__c recOld = salesOrdersOldMap.get(rec.id); //MK - 2014-04-04: refactored for performance

          System.debug('** Started '+ rec.Approval_Comment_Check__C );
          if (rec.Approval_Comment_Check__C == 'Requested') {
              System.debug('** Requested ');
              salesOrdersToCapture.put(rec.Id, rec);
              rec.Approval_Comment_Check__C = null;
          }

          // Logic to Update Sales Coordinator
          if(rec.Sales_Coordinator__c != rec.Sales_Region_SC__c)
          {
              rec.Sales_Coordinator__c = rec.Sales_Region_SC__c;    
          }

          // Logic to Update RSM
          if(rec.Owner_User__c != rec.ownerId)
          {
              rec.Owner_User__c = rec.ownerId;           
          }

          // Logic to Update Sales Manager - MK - 2014-04-09 - Added this field update in order to assign SO
          if(rec.Sales_Manager__c != rec.RSM_ID__c)
          {
              rec.Sales_Manager__c = rec.RSM_ID__c;
          }
          
          // Logic to Update Lease fields for Conversion Pending Status
          if(rec.StatusCode__c != recOld.StatusCode__c && rec.StatusCode__c == 'Conversion Pending' && !rec.Orig_Populated__c )
          {
             
              rec.Orig_Populated__c                = true;
              rec.Orig_Amount__C                  =  String.valueof(recOld.Amount__c);  
              rec.Orig_Astrum_Lease_Revenue__c            =  String.valueof(recOld.Astrum_Lease_Revenue__c) ;     
              rec.Orig_Astrum_Upfront_SREC_Value__c           =  String.valueof(recOld.Astrum_Upfront_SREC_Value__c);
              rec.Orig_Base_Electricity_Price__c         =  String.valueof(recOld.Base_Electricity_Price__c);
              rec.Orig_CEG_Deposit__c                 =  String.valueof(recOld.CEG_Deposit__c);
              rec.Orig_CEG_FMV_per_Watt_W__c              =  String.valueof(recOld.CEG_FMV_per_Watt_W__c);
              rec.Orig_CEG_Total_System_Price_W__c            =  String.valueof(rec.CEG_Total_System_Price_W__c);
              rec.Orig_CEG_Total_System_Price__c          =  String.valueof(recOld.CEG_Total_System_Price__c);
              rec.Orig_CEG_Total_System_Price_Lookup__c       =  String.valueof(recOld.CEG_Total_System_Price_Lookup__c);
              rec.Orig_Constellation_Job_Id__c            =  recOld.Constellation_Job_Id__c;
              rec.Orig_Constellation_Lease_Inverters__c       =  recOld.Constellation_Lease_Inverters__c;
              rec.Orig_CP_Model_Days__c               =  String.valueof(recOld.CP_Model_Days__c);
              rec.Orig_CSD_Pricing__c                 =  String.valueof(recOld.CSD_Pricing__c);
              rec.Orig_Down_Payment__c                =  recOld.Down_Payment__c;
              rec.Orig_Escalation_Comments__c             =  recOld.Escalation_Comments__c;          
              rec.Orig_FCRA_Letter_Mailed__c              =  String.valueof(recOld.FCRA_Letter_Mailed__c);           
              rec.Orig_Financing_Type__c              =  recOld.Financing_Type__c;
              rec.Orig_Installed_Year__c              =   recOld.Installed_Year__c;
              rec.Orig_Lease_Capacity_Factor__c           =   String.valueof(recOld.Lease_Capacity_Factor__c);
              rec.Orig_Lease_Escalator__c             =   String.valueof(recOld.Lease_Escalator__c);
              rec.Orig_Lease_Financing_Approved_By__c         =   recOld.Lease_Financing_Approved_By__c;
              rec.Orig_Lease_Fund__c                  =   recOld.Lease_Fund__c;
              rec.Orig_Lease_Term_months__c               =   String.valueof(recOld.Lease_Term_months__c);
              rec.Orig_Leasing_Option__c              =   recOld.Leasing_Option__c;
              rec.Orig_Leasing_SREC_Curve__c              =   recOld.Leasing_SREC_Curve__c;
              rec.Orig_Opportunity_Close_Date__c          =   String.valueof(recOld.Opportunity_Close_Date__c);
              rec.Orig_Opportunity_Close_Date_Lookup__c       =   String.valueof(recOld.Opportunity_Close_Date_Lookup__c);
              rec.Orig_Potential_Lease_Inverters__c           =   recOld.Potential_Lease_Inverters__c;
              rec.Orig_Pricebook__c                   =   recOld.Pricebook__c;
              rec.Orig_Projected_Annual_SRECs_Generated__c        =   String.valueof(recOld.Projected_Annual_SRECs_Generated__c);
              rec.Orig_Projected_Annual_SRECs_UnTruncated__c      =   String.valueof(recOld.Projected_Annual_SRECs_UnTruncated__c);
              rec.Orig_Quoted_System_Site_Quality__c          =   String.valueof(recOld.Quoted_System_Site_Quality__c);
              rec.Orig_RequestedShipmentOn__c             =   String.valueof(recOld.RequestedShipmentOn__c);
              rec.Orig_Sales_Error_Tracking__c            =   recOld.Sales_Error_Tracking__c;
              // SO Apv Process changes - reference apprv date (datetime) instead of (date) - PB 10/06/2015 
              //rec.Orig_Sales_Order_Approval_Date__c           =   String.valueof(recOld.Sales_Order_Approval_Date__c);
              rec.Orig_Sales_Order_Approval_Date__c           =   (recOld.Approval_Date__c != null)?String.valueOf((recOld.Approval_Date__c).dateGMT()):'';
              rec.Orig_Sales_Tax_First_Month__c           =   String.valueof(recOld.Sales_Tax_First_Month__c);
              rec.Orig_Sales_Tax_Paid_to_CEG_Date__c          =   String.valueof(recOld.Sales_Tax_Paid_to_CEG_Date__c);
              rec.Orig_Sales_Tax_Percentage__c            =   String.valueof(recOld.Sales_Tax_Percentage__c);
              rec.Orig_Sales_Tax_Prepaid__c               =   String.valueof(recOld.Sales_Tax_Prepaid__c);
              rec.Orig_Sales_Order_Approval_Comments__c       =   recOld.Sales_Order_Approval_Comments__c;
              rec.Orig_SREC_Responsible_Party__c          =   recOld.SREC_Responsible_Party__c;
              rec.Orig_State_Grant_W__c               =   String.valueof(recOld.State_Grant_W__c);
              rec.Orig_SState_Grant_Date_Paid_To_CEG__c        =   String.valueof(recOld.State_Grant_Date_Paid_To_CEG__c);
              rec.Orig_State_Grant_Estimated_vs_Actual__c     =   String.valueof(recOld.State_Grant_Estimated_vs_Actual__c);
              rec.Orig_State_Grant_Received__c            =   String.valueof(recOld.State_Grant_Received__c);
              rec.Orig_State_Grant_Received_Date__c           =   String.valueof(recOld.State_Grant_Received_Date__c);
              rec.Orig_System_Makeup__c               =   recOld.System_Makeup__c;
              rec.Orig_System_Size_kW__c              =   String.valueof(recOld.System_Size_kW__c);
              rec.Orig_Total_Grant_Amount__c              =   String.valueof(recOld.Total_Grant_Amount__c);
              rec.Orig_Total_Panel_Count__c               =   String.valueof(recOld.Total_Panel_Count__c);
              rec.Orig_Total_State_Grant_Est__c           =   String.valueof(recOld.Total_State_Grant_Est__c);
              rec.Orig_Total_Upfront_Lease_Payment__c         =   String.valueof(recOld.Total_Upfront_Lease_Payment__c);
             // rec.Orig_Tranche_Number__c              =   String.valueof(recOld.Tranche_Number__c);
             // rec.Orig_Treasury_Grant_Approval_Date__c        =   String.valueof(recOld.Treasury_Grant_Approval_Date__c);
             // rec.Orig_Treasury_Grant_Filing_Date__c          =   String.valueof(recOld.Treasury_Grant_Filing_Date__c);
            //  rec.Orig_Treasury_Grant_Received_Amount__c      =   String.valueof(recOld.Treasury_Grant_Received_Amount__c);
            //  rec.Orig_Treasury_Grant_Requested_Amount__c     =   String.valueof(recOld.Treasury_Grant_Requested_Amount__c);
            //  rec.Orig_Treasury_Grant_Requested_vs_Received__c    =   String.valueof(recOld.Treasury_Grant_Requested_vs_Received__c);
              rec.Orig_Upfrnt_Lease_Pmt_DueAtInstl__c    =   String.valueof(recOld.Upfront_Lease_Payment_Due_At_Install__c);
              rec.Orig_Upfrnt_Lease_Pmt_DueAtSign__c    =   String.valueof(recOld.Upfront_Lease_Payment_Due_At_Signing__c);
              rec.Orig_VP_of_Sales_Notes__c               =   recOld.VP_of_Sales_Notes__c;
              rec.Orig_Year_1__c                  =   String.valueof(recOld.Year_1__c);
          
          }
      }
      
      if (!salesOrdersToCapture.isEmpty())  
      {
           
           //SalesOrderApprovalUtility.captureComments(salesOrderIds );
           Id oldTargetId;         
          
          for (SCRB_SalesOrder__c pi : [SELECT Id , 
                                      (  
                                         SELECT Id, StepStatus, Comments 
                                         FROM ProcessSteps Where StepStatus in ('Approved', 'Rejected') order by SystemModstamp desc Limit 1) from  SCRB_SalesOrder__c where Id in
                                         :salesOrdersToCapture.keySet() 
                                       ORDER BY CreatedDate DESC
                                      ])                      
          {
                        
              System.debug('**Comm- size '+pi.ProcessSteps.Size());
              if (pi.ProcessSteps.Size()> 0 )
              {   
                  System.debug('**Comm-'+pi.ProcessSteps[0].Comments);
                  if ((pi.ProcessSteps[0].Comments == null || 
                     pi.ProcessSteps[0].Comments.trim().length() == 0))
                  {
                     salesOrdersToCapture.get(pi.Id).addError('Operation Cancelled: Please provide a reason for Approval/Rejection !'); 
                  }
                  else
                  {
                      System.debug('**Comm-'+pi.ProcessSteps[0].Comments);                   
                      salesOrdersToCapture.get(pi.Id).Sales_Order_Approval_Comments__C = pi.ProcessSteps[0].Comments;
                  } 
                 
              } 
              
          }     
      }
  }




  /* METHOD: trackSalesOrderStatusHistory
   * AUTHOR: Michael Katulka
   * DATE: 2014-04-04
   * PURPOSE: This is used for Sales Bonus tracking
   * MODIFICATION HISTORY: 
   *
  */    
  
  //Flow of approval processes:
      //SO is created
      //Once submitted, the first approval process will set to "submitted".
      //Upon approval or rejection, the current approval process will END but the StatusCode__c will be different.
      //Then Sales_Order_Approval_Trigger will look for certain statuses and will submit the SO again which will fall into a
      //different approval process.
      //Eventually, the statusCode__c will not match the Sales_Order_Approval_Trigger statuses and it will not be resubmitted.
      

  //APEX ORDER OF EXECUTION NOTES:
    //Approval Processes with [Field updates inside of "INITIAL SUBMISSION ACTIONS"] fire BEFORE any triggers.
      //Expect triggers to fire 1 time after this.

      //Regular Workflow WILL NOT FIRE AFTER THESE TRIGGERS

    //Next, Approval Steps (approval/rejection) with a Field Update will also fire triggers
        //Expect triggers to fire 1 time for this.

        //This seems to fire regular workflow - which in turn could fire triggers again

    //Next, Final actions (approval/rejection) with a Field Update will also fire triggers
        //Expect triggers to fire 1 time for this.

        //This might?! fire regular workflow - which in turn could fire triggers again


    //TOTALLY DEPENDANT ON THE APPROVAL PROCESS CONFIGURATION: At the end of the execution, triggers might have fired up to 
    //3/4 times.  This is why we needed to track globally if a Sales Order change has been tracked during any of the 1-n triggers
    //and prevent running it again (especially for the counter++ fields).

    //You can see this in the debug logs when you Submit/Approve/Reject.
  public static set<string> trackSalesOrderStatusHistoryLOGGED = new set<string>(); //This set is global to all of this execution
  public static void trackSalesOrderStatusHistory(list<SCRB_SalesOrder__c> salesOrders, map<id, SCRB_SalesOrder__c> salesOrdersOldMap, boolean fromTrigger){
    system.debug('***trackSalesOrderStatusHistory begin');

    //SalesOrderTriggerHandler.trackSalesOrderStatusHistoryFiredCounter++;
    
    //Variables used to identify changes that have been logged already somewhere in trigger execution 1..n.
    final string FIRST_TIME_SUBMITTED = 'FIRST TIME SUBMITTED';
    final string SALES_COORDINATOR_REJECTED = 'SALES COORDINATOR REJECTED';
    final string RE_SUBMITTED = 'RE-SUBMITTED';
    final string SALES_COORDINATOR_APPROVED = 'SALES COORDINATOR APPROVED';
    final string CONTRACT_REJECTED = 'CONTRACT REJECTED';
    final string FINAL_APPROVAL = 'FINAL APPROVAL';
    final string RE_SUBMIT_PENALTY = 'RE-SUBMIT PENALTY';
    
    //final string CONTRACT_ADMIN_REJECTED = 'Contract Administrator Rejected';
    //final string PRELIM_APPROVED = 'Prelim Approved';

    set<id> cancelPendingOppIDs = new set<id>();    
    set<id> salesOrdersNeedingReAssignToManager = new set<id>();

    //Set business hours id for the time delta calculations
    List<BusinessHours> bhList = [select id from businesshours where isActive = true and Name = 'Full 24 hour weekdays' limit 1];
    BusinessHours Full24WeekdayBusinessHours;
    if(bhList.isEmpty()) system.debug('*******ERROR: The Business Hours are not configured in order to calculate the Time Delta.  Looking for active record with name: Full 24 hour weekdays');
    else Full24WeekdayBusinessHours = bhList[0];

    if(!fromTrigger) return;
    id userID = UserInfo.getUserId(); // call userinfo once    
    datetime now = datetime.now(); //same timestamp for all records
    for(SCRB_SalesOrder__c so : salesOrders){
      if(so.Type__c != 'Order') continue; //skip to next SO

      //IMPORTANT!!!!!
      //First check to see if this Sales Order has been logged in this execution before.
      //If it has been logged already, then skip it.  The issue here is that the trigger.old values still 
      //differ from trigger.new values on the second iteration of triggers firing when approval process field updates happen.  
      //It's way more complicated to try to prevent recursion by counting how many times the triggers fire because if anyone 
      //modifies field updates in the approval process, it will break the # times the triggers fire depending on which approval process 
      //is running.  See ORDER OF EXECUTION ABOVE

      
      //if(SalesOrderTriggerHandler.trackSalesOrderStatusHistoryLOGGED.contains(so.id)) continue; //go to next record.

      //Reset our log flag for each record
      //boolean changeHasBeenLogged = false;

      //First grab the old values
      SCRB_SalesOrder__c soOld = salesOrdersOldMap.get(so.id); 

      //Initialize numbers if needed
      if(so.Coordinator_Rejected_Count__c == null) so.Coordinator_Rejected_Count__c = 0;
      if(so.Contract_Rejected_Count__c == null) so.Contract_Rejected_Count__c = 0;
      

      //Check for status changes
      
      system.debug('***so.StatusCode__c: ' + so.StatusCode__c);
      system.debug('***old: soOld.StatusCode__c: ' + soOld.StatusCode__c);

      //FIRST TIME SUBMITTED
      if(so.Original_Submit_Sales_Rep__c == null && so.StatusCode__c=='Sales Submitted'){//SOA PB - CHANGED STATUS FROM Submitted to Sales Submitted
        string uniqueChangeID = so.id + FIRST_TIME_SUBMITTED;
        if(SalesOrderTriggerHandler.trackSalesOrderStatusHistoryLOGGED.contains(uniqueChangeID)) continue; //go to next record.
        
        //Log the tracked change so it only happens once, and perform the the field updates
        SalesOrderTriggerHandler.trackSalesOrderStatusHistoryLOGGED.add(uniqueChangeID);

        //Update Sales Order
        so.Original_Submit_Sales_Rep__c = userID;
        so.Time_Original_Submit_Sales_Rep__c = now;
      }

      /*SALES COORDINATOR REJECTED - Always get the last time this happened
      if(so.StatusCode__c == 'Sales Coordinator Rejected' && soOld.StatusCode__c != 'Sales Coordinator Rejected'){        
        string uniqueChangeID = so.id + SALES_COORDINATOR_REJECTED;
        if(SalesOrderTriggerHandler.trackSalesOrderStatusHistoryLOGGED.contains(uniqueChangeID)) continue; //go to next record.
        
        //Log the tracked change so it only happens once, and perform the the field updates
        SalesOrderTriggerHandler.trackSalesOrderStatusHistoryLOGGED.add(uniqueChangeID);
        
        //Update Sales Order
        so.Coordinator_Rejected_Count__c++;
        so.Time_Last_Coordinator_Rejected__c = now;
        
        //Calculate the next penalty date deadline
        if(Full24WeekdayBusinessHours != null && so.Time_Last_Coordinator_Rejected__c != null){
          //120 hours = 5 full 24 hour non-weekend non-holiday days.
          so.Re_Submit_Penalty_Deadline__c = BusinessHours.addGmt(Full24WeekdayBusinessHours.id, so.Time_Last_Coordinator_Rejected__c, 120 * 60 * 60 * 1000L);
        }


      } */

      //RE-SUBMITTED - Always get the last time this happened
      if(so.StatusCode__c=='Sales ReSubmitted' && soOld.StatusCode__c != 'Sales ReSubmitted'){//SOA PB - CHANGED STATUS FROM Re-Submitted to Sales Submitted
        string uniqueChangeID = so.id + RE_SUBMITTED;
        if(SalesOrderTriggerHandler.trackSalesOrderStatusHistoryLOGGED.contains(uniqueChangeID)) continue; //go to next record.
        
        //Log the tracked change so it only happens once, and perform the the field updates
        SalesOrderTriggerHandler.trackSalesOrderStatusHistoryLOGGED.add(uniqueChangeID);
        
        //Update Sales Order
        so.Last_Resubmit_Sales_Rep__c = userID;
        so.Time_Last_Resubmit_Sales_Rep__c = now;
        
        //Clear the penalty deadline
        //so.Re_Submit_Penalty_Deadline__c = null; Workflow is clearing this now.
      }

      /*SALES COORDINATOR APPROVED - Always get the last time this happened
      if(so.StatusCode__c == 'Sales Coordinator Approved' && soOld.StatusCode__c != 'Sales Coordinator Approved'){
        string uniqueChangeID = so.id + SALES_COORDINATOR_APPROVED;
        if(SalesOrderTriggerHandler.trackSalesOrderStatusHistoryLOGGED.contains(uniqueChangeID)) continue; //go to next record.
        
        //Log the tracked change so it only happens once, and perform the the field updates
        SalesOrderTriggerHandler.trackSalesOrderStatusHistoryLOGGED.add(uniqueChangeID);
        
        //Update Sales Order
        so.Last_Coordinator_Approved__c = userID;
        so.Time_Last_Coordinator_Approved__c = now;
      } */

      //CONTRACT REJECTED - Always get the last time this happened
      if(so.StatusCode__c == 'Contract Administrator Rejected' && soOld.StatusCode__c != 'Contract Administrator Rejected'){
        string uniqueChangeID = so.id + CONTRACT_REJECTED;
        if(SalesOrderTriggerHandler.trackSalesOrderStatusHistoryLOGGED.contains(uniqueChangeID)) continue; //go to next record.
        
        //Log the tracked change so it only happens once, and perform the the field updates
        SalesOrderTriggerHandler.trackSalesOrderStatusHistoryLOGGED.add(uniqueChangeID);
        
        //Update Sales Order
        so.Contract_Rejected_Count__c++;
        so.Time_Last_Coordinator_Rejected__c = now;//SOA PB         
      }

      //FINAL APPROVAL
      if(so.StatusCode__c == 'Final/Accounting Approved' && soOld.StatusCode__c != 'Final/Accounting Approved'){
        string uniqueChangeID = so.id + FINAL_APPROVAL;
        if(SalesOrderTriggerHandler.trackSalesOrderStatusHistoryLOGGED.contains(uniqueChangeID)) continue; //go to next record.
        //Log the tracked change so it only happens once, and perform the the field updates
        SalesOrderTriggerHandler.trackSalesOrderStatusHistoryLOGGED.add(uniqueChangeID);
        so.Final_Approval__C = true;
      }

      //RESUBMIT PENALTY
      //if(so.Re_Submit_Penalty_Re_Assign_To_Manager__c && !soOld.Re_Submit_Penalty_Re_Assign_To_Manager__c){
      if(so.StatusCode__c == 'Re-Assigned to Sales Manager' && soOld.StatusCode__c != 'Re-Assigned to Sales Manager'){        
        string uniqueChangeID = so.id + RE_SUBMIT_PENALTY;
        if(SalesOrderTriggerHandler.trackSalesOrderStatusHistoryLOGGED.contains(uniqueChangeID)) continue; //go to next record.
        //Log the tracked change so it only happens once, and perform the the field updates
        SalesOrderTriggerHandler.trackSalesOrderStatusHistoryLOGGED.add(uniqueChangeID);

        //Change the stage of parent Opps
        cancelPendingOppIDs.add(so.OpportunityId__c);

        //Cancel the approval process and resubmit to
        salesOrdersNeedingReAssignToManager.add(so.id);
      }
      //Need to calculate the time differences

      //Start by clearing the 3 timedelta fields in case something has been changed like a counter or a time.
      //Null because 0 could be valid (but hard to get to 0 unless it all happens within seconds.)
      so.Time_Delta_1__c = null;
      so.Time_Delta_2__c = null;
      so.Time_Delta_3__c = null;

      //Calculate time difference
      if(Full24WeekdayBusinessHours != null && so.Time_Last_Coordinator_Approved__c != null && so.Time_Original_Submit_Sales_Rep__c != null){
        long timeDiffL = BusinessHours.diff (Full24WeekdayBusinessHours.id, so.Time_Original_Submit_Sales_Rep__c, so.Time_Last_Coordinator_Approved__c);
        //Convert milliseconds to minutes                
        decimal inMins = (timeDiffL/1000.00)/60.00;
        //TimeDelta1: 
        if(so.Time_Original_Submit_Sales_Rep__c != null && so.Time_Last_Coordinator_Approved__c != null && so.Coordinator_Rejected_Count__c == 0 && so.Contract_Rejected_Count__c == 0) so.Time_Delta_1__c = inMins;
        //TimeDelta2:
        if(so.Time_Original_Submit_Sales_Rep__c != null && so.Time_Last_Coordinator_Approved__c != null && so.Coordinator_Rejected_Count__c > 0 && so.Contract_Rejected_Count__c == 0) so.Time_Delta_2__c = inMins;
        //TimeDelta3: 
        if(so.Time_Original_Submit_Sales_Rep__c != null && so.Time_Last_Coordinator_Approved__c != null && so.Contract_Rejected_Count__c > 0) so.Time_Delta_3__c = inMins;
      }      
    }
    
    if(!cancelPendingOppIDs.isEmpty()){      
      list<Opportunity> cancelPendingOpps;
      cancelPendingOpps = [Select id, StageName from Opportunity where id in: cancelPendingOppIDs];

      //Once a sales order hits that 120-hour time threshold, the consultant will lose control over the sale. It will be automatically 
      //be staged as Cancel Pending, and the next Approver will be your Sales Manager. The manager will be responsible to move it to 
      //Cancel, On Hold, or to re-run it thru approval process.
      //Set Opportunity stage to Cancel Pending
      for(Opportunity opp:cancelPendingOpps){
        opp.StageName = 'Cancel Pending';
      }
      update cancelPendingOpps;
    }

    if(!salesOrdersNeedingReAssignToManager.isEmpty()){
      //Recall all of these processes, and the after trigger will resubmit      
      for(ProcessInstanceWorkitem piwi: [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem 
                                       WHERE ProcessInstance.TargetObjectId in: salesOrdersNeedingReAssignToManager]){
        system.debug('***Recalling approval process for SO with id: ' + piwi.ProcessInstance.TargetObjectId);
          Approval.ProcessWorkitemRequest PWR = new Approval.ProcessWorkitemRequest();
        PWR.setComments('Re-Submit Penalty Deadline reached. Re-assign to Sales Manager.');
        PWR.setAction('Removed');
        PWR.setWorkitemId(piwi.id);
        Approval.ProcessResult result =  Approval.process(PWR);
      }

      //If the SO was not in the ProcessInstanceWorkitem, then it is not in approval process.

      //FINALLY: The Sales_Order_Approval_Trigger will handle the Re submit.
    }
    system.debug('***trackSalesOrderStatusHistory end');
  }

  // SZ - 2015-04-14: Code for setting of commissions related fields
     public static void updateCommissionsFields(list<SCRB_SalesOrder__c> salesOrders, Map<Id, SCRB_SalesOrder__c> salesOrdersOldMap, Boolean fromTrigger){
       if (fromTrigger){
         if (salesOrdersOldMap == null){
           // Is From Insert Trigger
         }
         else{
           // Is From Update Trigger
         }

         ContractSettings__c contractSettings = ContractSettings__c.getOrgDefaults();

         Set<Id> sdqIds = new Set<Id>();
         Set<Id> oppIds = new Set<Id>();
         for(SCRB_SalesOrder__c so : salesOrders){
           if(!sdqIds.contains(so.System_Design_Quote__c)){
             sdqIds.add(so.System_Design_Quote__c);
           }
           if(!oppIds.contains(so.OpportunityId__c)){
             oppIds.add(so.OpportunityId__c);
           }
         }
         Map<Id, System_Design_Quote__c> systemDesignQuotes = new Map<Id, System_Design_Quote__c>(
           [SELECT Closed_Scenario__c, Community_Program_Offer__c, System_Size_kW__c,
             Scenario_1_Commission_Impact_Promotions__c, Scenario_2_Commission_Impact_Promotions__c, 
             Scenario_3_Commission_Impact_Promotions__c, Scenario_4_Commission_Impact_Promotions__c,
             Scenario_1_Total_Program_Adjustments__c, Scenario_2_Total_Program_Adjustments__c, 
             Scenario_3_Total_Program_Adjustments__c, Scenario_4_Total_Program_Adjustments__c,  
             Scenario_1_Upfront_SREC_Amount__c, Scenario_2_Upfront_SREC_Amount__c, 
             Scenario_3_Upfront_SREC_Amount__c, Scenario_4_Upfront_SREC_Amount__c,
             Scenario_1_Final_EPC_Price__c, Scenario_2_Final_EPC_Price__c, 
             Scenario_3_Final_EPC_Price__c, Scenario_4_Final_EPC_Price__c, 
             Scenario_1_Base_Commission_Percent__c, Scenario_2_Base_Commission_Percent__c, Scenario_3_Base_Commission_Percent__c, Scenario_4_Base_Commission_Percent__c
           FROM System_Design_Quote__c WHERE Id IN :sdqIds]);
         Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>(
           [SELECT Id, Contact_Detail__c, LeadSource, Referring_Account__r.Type, Self_Generated__c FROM Opportunity WHERE Id IN :oppIds]);
         Map<Id, Price_Adjustment__c> priceAdjustments = new Map<Id, Price_Adjustment__c>(
           [SELECT Id, Applicable_Scenario__c, Entitlement_Offer__c, Effective_Dollar_Amount__c,
             System_Design_Quote__c, System_Design_Quote__r.Closed_Scenario__c
           FROM Price_Adjustment__c 
           WHERE System_Design_Quote__c IN :sdqIds AND Entitlement_Offer__c != null AND Adjustment_Applied__c = true]);
         Set<Id> eoIds = new Set<Id>();
         for(Price_Adjustment__c pa : priceAdjustments.values()){
           if(pa.Applicable_Scenario__c == pa.System_Design_Quote__r.Closed_Scenario__c && !eoIds.contains(pa.Entitlement_Offer__c)){
             eoIds.add(pa.Entitlement_Offer__c);
           }
         }
         Map<Id, Id> entitlementOffersToPriceAdjustments = new Map<Id, Id>();
         for(Price_Adjustment__c pa : priceAdjustments.values()){
           if(pa.Applicable_Scenario__c == pa.System_Design_Quote__r.Closed_Scenario__c){
             if(!entitlementOffersToPriceAdjustments.containsKey(pa.Entitlement_Offer__c)){
               entitlementOffersToPriceAdjustments.put(pa.Entitlement_Offer__c, pa.Id);
             }
           }
         }

         Map<Id, Entitlement_Offer__c> entitlementOffers = new Map<Id, Entitlement_Offer__c>(
           [SELECT Id, Name, Commission_Impact__c, Commission_Impact_Percent__c, Commission_Impact_W__c, Commission_Impact_Sliding_Scale_Applied__c
           FROM Entitlement_Offer__c WHERE Id IN :eoIds]);

         Map<Id, List<Price_Adjustment__c>> sdqPriceAdjustments = new Map<Id, List<Price_Adjustment__c>>();
         for(Price_Adjustment__c pa : priceAdjustments.values()){
           if(pa.Applicable_Scenario__c == pa.System_Design_Quote__r.Closed_Scenario__c){
             if(!sdqPriceAdjustments.containsKey(pa.System_Design_Quote__c)){
               sdqPriceAdjustments.put(pa.System_Design_Quote__c, new List<Price_Adjustment__c>());
             }
             sdqPriceAdjustments.get(pa.System_Design_Quote__c).add(pa);
           }
         }

         Map<Id, List<Entitlement_Offer__c>> sdqEntitlementOffers = new Map<Id, List<Entitlement_Offer__c>>();
         for(Price_Adjustment__c pa : priceAdjustments.values()){
           if(pa.Applicable_Scenario__c == pa.System_Design_Quote__r.Closed_Scenario__c){
             if(!sdqEntitlementOffers.containsKey(pa.System_Design_Quote__c)){
               sdqEntitlementOffers.put(pa.System_Design_Quote__c, new List<Entitlement_Offer__c>());
             }
             sdqEntitlementOffers.get(pa.System_Design_Quote__c).add(entitlementOffers.get(pa.Entitlement_Offer__c));           
           }
         }

         for(SCRB_SalesOrder__c salesOrder : salesOrders){
           System_Design_Quote__c sdq = systemDesignQuotes.get(salesOrder.System_Design_Quote__c);
           Opportunity opp = opportunities.get(salesOrder.OpportunityId__c);

           /* SZ Commented out for now until we get a new "Amount" field
           double totalProgramAdjustments = (double)sdq.get('Scenario_' + sdq.Closed_Scenario__c + '_Total_Program_Adjustments__c');
           double upfrontSRECAmount = (double)sdq.get('Scenario_' + sdq.Closed_Scenario__c + '_Upfront_SREC_Amount__c');
           // upfrontSRECAmount is stored as a positive, so subtract it
           opp.Amount = sdq.Commission_Design_Price__c + totalProgramAdjustments - upfrontSRECAmount;
           */
           if(sdq != null && opp != null && sdq.Closed_Scenario__c != null) 
           { 
             salesOrder.Sold_As_EPC_Price__c = (double)sdq.get('Scenario_' + sdq.Closed_Scenario__c + '_Final_EPC_Price__c');
             salesOrder.Contact_Detail__c = opp.Contact_Detail__c;
             salesOrder.Lead_Source__c = opp.LeadSource;
             salesOrder.Referring_Account__c = opp.Referring_Account__c;
             salesOrder.Self_Generated__c = opp.Self_Generated__c;

             //CPQ-790
             Decimal referralCommissionBonus = ContractSettings__c.getOrgDefaults().Referral_Commission_Bonus__c != null ? ContractSettings__c.getOrgDefaults().Referral_Commission_Bonus__c : 700;
             String referringAcctType = opp.Referring_Account__c != null ? opp.Referring_Account__r.Type : 'Employee';  //Default value will act as a fail condition. 
             if (salesOrder.Self_Generated__c == true || (salesOrder.Self_Generated__c == false && salesOrder.Lead_Source__c == 'Individual Referral' && referringAcctType != 'Employee') || salesOrder.Lead_Source__c == 'Event'){
                 salesOrder.Lead_Source_Commission_Bonus__c = referralCommissionBonus;
             } else {
                 salesOrder.Lead_Source_Commission_Bonus__c = 0;
             }

             double commissionImpactPromotions = (double)sdq.get('Scenario_' + sdq.Closed_Scenario__c + '_Commission_Impact_Promotions__c');
             salesOrder.Commission_Impact_Promotions_Given__c = commissionImpactPromotions;

             try {
               //if (sdq.Community_Program_Offer__c == null){
               //  salesOrder.Base_Commission_Percent__c = 
               //    (((contractSettings.Minimum_Commission_Rate__c - contractSettings.Maximum_Commission_Rate__c) /
               //      (contractSettings.Maximum_Promotion__c - contractSettings.Minimum_Promotion__c)) *
               //      commissionImpactPromotions) + (contractSettings.Maximum_Commission_Rate__c);
               //}
               //else{
               //  salesOrder.Base_Commission_Percent__c = contractSettings.Solarize_Commission_Rate__c;
               //}
               salesOrder.Base_Commission_Percent__c = (Decimal)sdq.get('Scenario_' + sdq.Closed_Scenario__c + '_Base_Commission_Percent__c'); //CPQ-790
             } catch (Exception e){
               System.debug('Error in SalesOrderTriggerHandler.updateCommissionsFields() on line ' + e.getLineNumber() + ': ' + e.getMessage());
             }
            
             salesOrder.Commission_Rate__c = salesOrder.Base_Commission_Percent__c + salesOrder.Additional_Commission_Percent__c;

             List<Entitlement_Offer__c> sdqEntitlementOffersValues = sdqEntitlementOffers.get(sdq.Id);
             Decimal eoSum = 0.00;
             String eoDetails = '';
             if (sdqEntitlementOffersValues != null && !sdqEntitlementOffersValues.isEmpty()){
               for(Entitlement_Offer__c eo : sdqEntitlementOffersValues){
                 eoDetails += eo.Name + ' ';
                 if(priceAdjustments.get(entitlementOffersToPriceAdjustments.get(eo.Id)).Effective_Dollar_Amount__c != null)
                 {
                   eoDetails += priceAdjustments.get(entitlementOffersToPriceAdjustments.get(eo.Id)).Effective_Dollar_Amount__c + ' @ ';
                 }

                 if(eo.Commission_Impact__c != null){
                   eoSum += eo.Commission_Impact__c;
                   eoDetails += eo.Commission_Impact__c + ' = ';
                   eoDetails += eo.Commission_Impact__c;
                 } else if(eo.Commission_Impact_Percent__c != null && priceAdjustments.get(entitlementOffersToPriceAdjustments.get(eo.Id)).Effective_Dollar_Amount__c != null){
                   eoSum += ((eo.Commission_Impact_Percent__c/100) * priceAdjustments.get(entitlementOffersToPriceAdjustments.get(eo.Id)).Effective_Dollar_Amount__c);
                   eoDetails += eo.Commission_Impact_Percent__c + ' = ';
                   eoDetails += ((eo.Commission_Impact_Percent__c/100) * priceAdjustments.get(entitlementOffersToPriceAdjustments.get(eo.Id)).Effective_Dollar_Amount__c);
                 } else if(eo.Commission_Impact_W__c != null){
                   eoSum += (eo.Commission_Impact_W__c * sdq.System_Size_kW__c * 1000);
                   eoDetails += eo.Commission_Impact_W__c + ' = ';
                   eoDetails += (eo.Commission_Impact_W__c * sdq.System_Size_kW__c * 1000);
                 } else if(eo.Commission_Impact_Sliding_Scale_Applied__c != null && eo.Commission_Impact_Sliding_Scale_Applied__c && priceAdjustments.get(entitlementOffersToPriceAdjustments.get(eo.Id)).Effective_Dollar_Amount__c != null){
                   eoSum += (salesOrder.Commission_Rate__c / 100 * priceAdjustments.get(entitlementOffersToPriceAdjustments.get(eo.Id)).Effective_Dollar_Amount__c);
                   eoDetails += formatDecimalValue(salesOrder.Commission_Rate__c / 100, 3) + ' = ';
                   eoDetails += formatDecimalValue(salesOrder.Commission_Rate__c / 100 * priceAdjustments.get(entitlementOffersToPriceAdjustments.get(eo.Id)).Effective_Dollar_Amount__c, 2);
                 }
                 eoDetails += '\r\n';
               }
             }
             salesOrder.Adder_Commission_Value__c = eoSum;
             salesOrder.Adder_Commission_Details__c = eoDetails;

             salesOrder.Final_Commission__c = salesOrder.Base_Commission__c + salesOrder.Adder_Commission_Value__c + salesOrder.Lead_Source_Commission_Bonus__c;  //Updated for CPQ-790
           }
         }
       }
     }

  public static String formatDecimalValue(Decimal d, Integer scale) {
    return d.setScale(scale).toPlainString();
  }

  public static void updateOpportunityFields(list<SCRB_SalesOrder__c> salesOrders, Map<Id, SCRB_SalesOrder__c> salesOrdersOldMap){
    Map<Id, SCRB_SalesOrder__c> salesOrdersByOppId = new Map<Id, SCRB_SalesOrder__c>();
    for(SCRB_SalesOrder__c salesOrder : salesOrders){
      if(salesOrder.Time_Original_Submit_Sales_Rep__c != null && salesOrdersOldMap.get(salesOrder.Id).Time_Original_Submit_Sales_Rep__c == null){
        // Sales_Order_Approval_Date__c changed, check to update the opportunity
        if(salesOrdersByOppId.containsKey(salesOrder.OpportunityId__c)){
          if(salesOrder.Time_Original_Submit_Sales_Rep__c < salesOrdersByOppId.get(salesOrder.OpportunityId__c).Time_Original_Submit_Sales_Rep__c){
            salesOrdersByOppId.put(salesOrder.OpportunityId__c, salesOrder);
          }
        } else {
          salesOrdersByOppId.put(salesOrder.OpportunityId__c, salesOrder);
        }
      }
    }

    if(salesOrdersByOppId.size() > 0){
      List<Opportunity> opportunitiesToUpdate = [SELECT Id, Initial_Sales_Order_Close_Date__c FROM Opportunity WHERE Id IN :salesOrdersByOppId.keySet() AND Initial_Sales_Order_Close_Date__c = null];
      for(Opportunity opp : opportunitiesToUpdate){
        Datetime timeOriginalSubmitSalesRep = salesOrdersByOppId.get(opp.Id).Time_Original_Submit_Sales_Rep__c;
        opp.Initial_Sales_Order_Close_Date__c = Date.newInstance(timeOriginalSubmitSalesRep.year(), timeOriginalSubmitSalesRep.month(), timeOriginalSubmitSalesRep.day());
      }

      if(opportunitiesToUpdate.size() > 0){
        update opportunitiesToUpdate;
      }
    }
  }

  public static void sendSalesOrderEmails(list<SCRB_SalesOrder__c> salesOrders, Map<Id, SCRB_SalesOrder__c> salesOrdersOldMap){
    List<Id> soIdsForOrderCancellation = new List<Id>();
    List<Id> soIdsForPrelimApproval = new List<Id>();
    List<Id> soIdsForFinalApproval = new List<Id>();
    List<Id> soIdsForRej = new List<Id>();
    for(SCRB_SalesOrder__c so:salesOrders){
      if(so.statusCode__c != salesOrdersOldMap.get(so.Id).statusCode__c){
        if(so.statusCode__c == 'Canceled' 
          && so.Canceled_Date__c != salesOrdersOldMap.get(so.Id).Canceled_Date__c){
          soIdsForOrderCancellation.add(so.Id);
        }
        //Prelim Approval
        else if(so.statusCode__c == 'Prelim Approved'
          && so.Prelim_Approval_Date__c != salesOrdersOldMap.get(so.Id).Prelim_Approval_Date__c && firstRun()){
          System.debug('**new approval date:' + so.Prelim_Approval_Date__c + '**old approval date:' + salesOrdersOldMap.get(so.Id).Prelim_Approval_Date__c);
          System.debug('**new status:' + so.statusCode__c + '**old status:' + salesOrdersOldMap.get(so.Id).statusCode__c);
          soIdsForPrelimApproval.add(so.Id);
        }
        //Final Approval
        else if(so.statusCode__c == 'Final/Accounting Approved'
          && so.Approval_Date__c != salesOrdersOldMap.get(so.Id).Approval_Date__c && firstRun()){
          soIdsForFinalApproval.add(so.Id);
        }
        //Rejection
        else if((so.statusCode__c == 'Contract Administrator Rejected' || so.statusCode__c == 'Director of P&A Rejected' || so.statusCode__c == 'Regional Director Rejected')
          && so.Prelim_Approval_Date__c != null && firstRun()){
          soIdsForRej.add(so.Id);
        }

      }
    }
    
    if(!soIdsForOrderCancellation.isEmpty()){
      //sendOrderCancellationEmails(soIdsForOrderCancellation);
      sendOrderEmails(soIdsForOrderCancellation, 'Cancellation');
      System.debug('**send order cancellation email');
    }
    else if(!soIdsForPrelimApproval.isEmpty()){
      sendOrderEmails(soIdsForPrelimApproval, 'Prelim Approval');
      System.debug('**send prelim approval email');
    }
    else if(!soIdsForFinalApproval.isEmpty()){
      sendOrderEmails(soIdsForFinalApproval, 'Final Approval');
      System.debug('**send final approval email');
    }
    else if(!soIdsForRej.isEmpty()){
      sendOrderEmails(soIdsForRej, 'Rejection');
      System.debug('**send Rejection email');
    }
  }

  @future
  public static void sendOrderEmails(List<Id> soIds, String emailType){
    final String CANCELLATION = 'Cancellation';
    final String PRELIM_APPROVAL = 'Prelim Approval';
    final String FINAL_APPROVAL = 'Final Approval';
    final String REJECTION = 'Rejection';
    List<User> cancellationRecipients;

    Id currentProj;
    Map<Id,List<String>> emailrecipientsMap = new Map<Id,List<String>>();
    List<Id> userIds = new List<Id>();
    Map<Id,SCRB_SalesOrder__c> salesordersMap 
      = new Map<Id,SCRB_SalesOrder__c>([SELECT Property__r.Astrum_Office_New__r.Director_of_Operations__c
                        , Contract_Admin__c, Finance_Associate__c, Incentive_Associate__c
                        , Sales_Manager__c, OwnerId
                        FROM SCRB_SalesOrder__c 
                        WHERE Id in:soIds]);
    
    //MIS-251 PB 03/03/2016
    try{
      cancellationRecipients = [SELECT Id 
                                FROM User 
                                WHERE (FirstName = 'Daniel' AND LastName='Schneider') 
                                OR (FirstName = 'Jessica' AND LastName='Treuth') 
                                OR (FirstName = 'Harry' AND LastName='Keifer')];
    }catch(QueryException qe){System.debug('**User for manager compliance doesn\'t exist');  }
    //
    
    for(Id soId:salesordersMap.keySet()){
      List<String> emailrecipients = new List<String>();
      if(!emailType.equalsIgnoreCase(REJECTION)){
        if(salesordersMap.get(soId).Property__r.Astrum_Office_New__r.Director_of_Operations__c != null){
          emailrecipients.add(salesordersMap.get(soId).Property__r.Astrum_Office_New__r.Director_of_Operations__c);
          userIds.add(salesordersMap.get(soId).Property__r.Astrum_Office_New__r.Director_of_Operations__c);
        }
      }
      
      if(emailType.equalsIgnoreCase(CANCELLATION)){
        if(salesordersMap.get(soId).Contract_Admin__c != null){
          emailrecipients.add(salesordersMap.get(soId).Contract_Admin__c);
          userIds.add(salesordersMap.get(soId).Contract_Admin__c);
        }
        if(salesordersMap.get(soId).Finance_Associate__c != null){
          emailrecipients.add(salesordersMap.get(soId).Finance_Associate__c);
          userIds.add(salesordersMap.get(soId).Finance_Associate__c);
        }
        if(salesordersMap.get(soId).Incentive_Associate__c != null){
          emailrecipients.add(salesordersMap.get(soId).Incentive_Associate__c);
          userIds.add(salesordersMap.get(soId).Incentive_Associate__c);
        }
        //MIS-251 PB 03/03/2016
        if(cancellationRecipients != null){
          for(User recipient:cancellationRecipients){
            emailrecipients.add(recipient.Id);
            userIds.add(recipient.Id);
          }          
        }//
        if(salesordersMap.get(soId).Sales_Manager__c != null){
          emailrecipients.add(salesordersMap.get(soId).Sales_Manager__c);
          userIds.add(salesordersMap.get(soId).Sales_Manager__c);
        }
        emailrecipients.add(salesordersMap.get(soId).OwnerId);
        userIds.add(salesordersMap.get(soId).OwnerId);

        emailrecipients.add('accountsreceivable');

      }      
      emailrecipientsMap.put(soId,emailrecipients);
    }

    if(emailType.equalsIgnoreCase(CANCELLATION) || emailType.equalsIgnoreCase(FINAL_APPROVAL) || emailType.equalsIgnoreCase(REJECTION)){

      List<PM_Project__c> pmprojects = new List<PM_Project__c>();

      pmprojects = [SELECT Compliance_Specialist__c, Project_Lead__c, Electrical_Designer__c,Project_Engineer__c, System_Designer__c, Sales_Order__c 
              FROM PM_Project__c WHERE Sales_Order__c in: soIds
              ORDER BY Sales_Order__c ASC ];
      for(PM_Project__c proj:pmprojects){
        List<String> recipients = new List<String>();
        if(proj.Id == currentProj){
          continue;
        }
        currentProj = proj.id;
        
        if(proj.Project_Lead__c != null){
          recipients.add(proj.Project_Lead__c);
          userIds.add(proj.Project_Lead__c);
        }
        if(emailType.equalsIgnoreCase(CANCELLATION)){
          if(proj.Electrical_Designer__c != null){
          recipients.add(proj.Electrical_Designer__c);
          userIds.add(proj.Electrical_Designer__c);
          }
          if(proj.Project_Engineer__c != null){
            recipients.add(proj.Project_Engineer__c);
            userIds.add(proj.Project_Engineer__c);
          }
          if(proj.System_Designer__c != null){
            recipients.add(proj.System_Designer__c);
            userIds.add(proj.System_Designer__c);
          }
        }
        
        if(!recipients.isEmpty()){
          emailrecipientsMap.get(proj.Sales_Order__c).addAll(recipients);
        }      
      }

    }

    //Send email
    List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
    EmailTemplate templateId;
    if(emailType.equalsIgnoreCase(CANCELLATION)){
      templateId = [SELECT Id FROM EmailTemplate WHERE Name = 'Sales Order CancellationVF' LIMIT 1];
    }
    else if(emailType.equalsIgnoreCase(PRELIM_APPROVAL)){
      templateId = [SELECT Id FROM EmailTemplate WHERE Name = 'SOA Sales Order Prelim ApprovalVF' LIMIT 1];
    }
    else if(emailType.equalsIgnoreCase(FINAL_APPROVAL)){
      templateId = [SELECT Id FROM EmailTemplate WHERE Name = 'SOA Sales Order Final ApprovalVF' LIMIT 1];
    }
    else if(emailType.equalsIgnoreCase(REJECTION)){
      templateId = [SELECT Id FROM EmailTemplate WHERE Name = 'SOA Sales Order RejectionVF' LIMIT 1];
    }

    Map<Id,User> userMap = new Map<Id,User>([SELECT Email,FirstName,LastName FROM User WHERE Id in:userIds]);
    List<Contact> contacts = new List<Contact>();

    System.debug('**soId' + emailrecipientsMap.keySet());    
    
    for(Id soId:emailrecipientsMap.keySet()){
      for(String emailRecipient:emailrecipientsMap.get(soId)){
        Contact con;
        if(emailRecipient == 'accountsreceivable'){
          String accountsRecvEmail = SO_Email_Setting__c.getOrgDefaults().AccountsRecv__c;
          System.debug('accountsRecvEmail:' + accountsRecvEmail);
          if(String.isNotBlank(accountsRecvEmail)){
            con = new Contact(
            Email = accountsRecvEmail
            , FirstName = 'accountsrecv'
            , LastName = 'accountsrecv');
          }          

        }else{
          con = new Contact(
          Email=userMap.get(emailRecipient).Email
          , FirstName=userMap.get(emailRecipient).FirstName
          , LastName=userMap.get(emailRecipient).LastName);

        }
        if(con != null){
          contacts.add(con);
        }   
      }
      insert contacts;

      for(Contact con: contacts){
        System.debug('**contactEmail:' + con.email);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(con.Id);
        message.setWhatId(soId);
        message.setTemplateId(templateId.Id);        
        message.setSaveAsActivity(false);
        messages.add(message);
      }      
    }

    try{
      Messaging.sendEmail(messages);      

    }catch(Exception ex){
      System.debug('**Error in sending order emails' + ex.getMessage() + ex.getStackTraceString());      
    }

    if(contacts!= null && (!contacts.isEmpty())){
      delete contacts;
    }

  }

  


/*  @future(callout=false)
  private static void updateOpportunityFieldsFuture(Map<Id, Datetime> opportunityToDateMap){
    List<Opportunity> opportunitiesToUpdate = [SELECT Id, Initial_Sales_Order_Close_Date__c FROM Opportunity WHERE Id IN :opportunityToDateMap.keySet() AND Initial_Sales_Order_Close_Date__c = null];
    for(Opportunity opp : opportunitiesToUpdate){
      Datetime timeOriginalSubmitSalesRep = opportunityToDateMap.get(opp.Id);
      opp.Initial_Sales_Order_Close_Date__c = Date.newInstance(timeOriginalSubmitSalesRep.year(), timeOriginalSubmitSalesRep.month(), timeOriginalSubmitSalesRep.day());
    }

    if(opportunitiesToUpdate.size() > 0){
      update opportunitiesToUpdate;
    }
  }*/
}