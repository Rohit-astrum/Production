trigger SalesOrder_BU on SCRB_SalesOrder__c (before update) {
/*        
    Map<Id, SCRB_SalesOrder__c> salesOrdersToCapture  = new Map<Id,SCRB_SalesOrder__c>();   
    for (SCRB_SalesOrder__c rec : Trigger.new) {      
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
        
        // Logic to Update Lease fields for Conversion Pending Status
        if(rec.StatusCode__c != Trigger.oldmap.get(rec.id).StatusCode__c && rec.StatusCode__c == 'Conversion Pending' && !rec.Orig_Populated__c )
        {
           
            rec.Orig_Populated__c                = true;
            rec.Orig_Amount__C                  =  String.valueof(Trigger.oldmap.get(rec.id).Amount__c);  
            rec.Orig_Astrum_Lease_Revenue__c            =  String.valueof(Trigger.oldmap.get(rec.id).Astrum_Lease_Revenue__c) ;     
            rec.Orig_Astrum_Upfront_SREC_Value__c           =  String.valueof(Trigger.oldmap.get(rec.id).Astrum_Upfront_SREC_Value__c);
            rec.Orig_Base_Electricity_Price__c         =  String.valueof(Trigger.oldmap.get(rec.id).Base_Electricity_Price__c);
            rec.Orig_CEG_Deposit__c                 =  String.valueof(Trigger.oldmap.get(rec.id).CEG_Deposit__c);
            rec.Orig_CEG_FMV_per_Watt_W__c              =  String.valueof(Trigger.oldmap.get(rec.id).CEG_FMV_per_Watt_W__c);
            rec.Orig_CEG_Total_System_Price_W__c            =  String.valueof(rec.CEG_Total_System_Price_W__c);
            rec.Orig_CEG_Total_System_Price__c          =  String.valueof(Trigger.oldmap.get(rec.id).CEG_Total_System_Price__c);
            rec.Orig_CEG_Total_System_Price_Lookup__c       =  String.valueof(Trigger.oldmap.get(rec.id).CEG_Total_System_Price_Lookup__c);
            rec.Orig_Constellation_Job_Id__c            =  Trigger.oldmap.get(rec.id).Constellation_Job_Id__c;
            rec.Orig_Constellation_Lease_Inverters__c       =  Trigger.oldmap.get(rec.id).Constellation_Lease_Inverters__c;
            rec.Orig_CP_Model_Days__c               =  String.valueof(Trigger.oldmap.get(rec.id).CP_Model_Days__c);
            rec.Orig_CSD_Pricing__c                 =  String.valueof(Trigger.oldmap.get(rec.id).CSD_Pricing__c);
            rec.Orig_Down_Payment__c                =  Trigger.oldmap.get(rec.id).Down_Payment__c;
            rec.Orig_Escalation_Comments__c             =  Trigger.oldmap.get(rec.id).Escalation_Comments__c;          
            rec.Orig_FCRA_Letter_Mailed__c              =  String.valueof(Trigger.oldmap.get(rec.id).FCRA_Letter_Mailed__c);           
            rec.Orig_Financing_Type__c              =  Trigger.oldmap.get(rec.id).Financing_Type__c;
            rec.Orig_Installed_Year__c              =   Trigger.oldmap.get(rec.id).Installed_Year__c;
            rec.Orig_Lease_Capacity_Factor__c           =   String.valueof(Trigger.oldmap.get(rec.id).Lease_Capacity_Factor__c);
            rec.Orig_Lease_Escalator__c             =   String.valueof(Trigger.oldmap.get(rec.id).Lease_Escalator__c);
            rec.Orig_Lease_Financing_Approved_By__c         =   Trigger.oldmap.get(rec.id).Lease_Financing_Approved_By__c;
            rec.Orig_Lease_Fund__c                  =   Trigger.oldmap.get(rec.id).Lease_Fund__c;
            rec.Orig_Lease_Term_months__c               =   String.valueof(Trigger.oldmap.get(rec.id).Lease_Term_months__c);
            rec.Orig_Leasing_Option__c              =   Trigger.oldmap.get(rec.id).Leasing_Option__c;
            rec.Orig_Leasing_SREC_Curve__c              =   Trigger.oldmap.get(rec.id).Leasing_SREC_Curve__c;
            rec.Orig_Opportunity_Close_Date__c          =   String.valueof(Trigger.oldmap.get(rec.id).Opportunity_Close_Date__c);
            rec.Orig_Opportunity_Close_Date_Lookup__c       =   String.valueof(Trigger.oldmap.get(rec.id).Opportunity_Close_Date_Lookup__c);
            rec.Orig_Potential_Lease_Inverters__c           =   Trigger.oldmap.get(rec.id).Potential_Lease_Inverters__c;
            rec.Orig_Pricebook__c                   =   Trigger.oldmap.get(rec.id).Pricebook__c;
            rec.Orig_Projected_Annual_SRECs_Generated__c        =   String.valueof(Trigger.oldmap.get(rec.id).Projected_Annual_SRECs_Generated__c);
            rec.Orig_Projected_Annual_SRECs_UnTruncated__c      =   String.valueof(Trigger.oldmap.get(rec.id).Projected_Annual_SRECs_UnTruncated__c);
            rec.Orig_Quoted_System_Site_Quality__c          =   String.valueof(Trigger.oldmap.get(rec.id).Quoted_System_Site_Quality__c);
            rec.Orig_RequestedShipmentOn__c             =   String.valueof(Trigger.oldmap.get(rec.id).RequestedShipmentOn__c);
            rec.Orig_Sales_Error_Tracking__c            =   Trigger.oldmap.get(rec.id).Sales_Error_Tracking__c;
            rec.Orig_Sales_Order_Approval_Date__c           =   String.valueof(Trigger.oldmap.get(rec.id).Sales_Order_Approval_Date__c);
            rec.Orig_Sales_Tax_First_Month__c           =   String.valueof(Trigger.oldmap.get(rec.id).Sales_Tax_First_Month__c);
            rec.Orig_Sales_Tax_Paid_to_CEG_Date__c          =   String.valueof(Trigger.oldmap.get(rec.id).Sales_Tax_Paid_to_CEG_Date__c);
            rec.Orig_Sales_Tax_Percentage__c            =   String.valueof(Trigger.oldmap.get(rec.id).Sales_Tax_Percentage__c);
            rec.Orig_Sales_Tax_Prepaid__c               =   String.valueof(Trigger.oldmap.get(rec.id).Sales_Tax_Prepaid__c);
            rec.Orig_Sales_Order_Approval_Comments__c       =   Trigger.oldmap.get(rec.id).Sales_Order_Approval_Comments__c;
            rec.Orig_SREC_Responsible_Party__c          =   Trigger.oldmap.get(rec.id).SREC_Responsible_Party__c;
            rec.Orig_State_Grant_W__c               =   String.valueof(Trigger.oldmap.get(rec.id).State_Grant_W__c);
            rec.Orig_SState_Grant_Date_Paid_To_CEG__c        =   String.valueof(Trigger.oldmap.get(rec.id).State_Grant_Date_Paid_To_CEG__c);
            rec.Orig_State_Grant_Estimated_vs_Actual__c     =   String.valueof(Trigger.oldmap.get(rec.id).State_Grant_Estimated_vs_Actual__c);
            rec.Orig_State_Grant_Received__c            =   String.valueof(Trigger.oldmap.get(rec.id).State_Grant_Received__c);
            rec.Orig_State_Grant_Received_Date__c           =   String.valueof(Trigger.oldmap.get(rec.id).State_Grant_Received_Date__c);
            rec.Orig_System_Makeup__c               =   Trigger.oldmap.get(rec.id).System_Makeup__c;
            rec.Orig_System_Size_kW__c              =   String.valueof(Trigger.oldmap.get(rec.id).System_Size_kW__c);
            rec.Orig_Total_Grant_Amount__c              =   String.valueof(Trigger.oldmap.get(rec.id).Total_Grant_Amount__c);
            rec.Orig_Total_Panel_Count__c               =   String.valueof(Trigger.oldmap.get(rec.id).Total_Panel_Count__c);
            rec.Orig_Total_State_Grant_Est__c           =   String.valueof(Trigger.oldmap.get(rec.id).Total_State_Grant_Est__c);
            rec.Orig_Total_Upfront_Lease_Payment__c         =   String.valueof(Trigger.oldmap.get(rec.id).Total_Upfront_Lease_Payment__c);
           // rec.Orig_Tranche_Number__c              =   String.valueof(Trigger.oldmap.get(rec.id).Tranche_Number__c);
           // rec.Orig_Treasury_Grant_Approval_Date__c        =   String.valueof(Trigger.oldmap.get(rec.id).Treasury_Grant_Approval_Date__c);
           // rec.Orig_Treasury_Grant_Filing_Date__c          =   String.valueof(Trigger.oldmap.get(rec.id).Treasury_Grant_Filing_Date__c);
          //  rec.Orig_Treasury_Grant_Received_Amount__c      =   String.valueof(Trigger.oldmap.get(rec.id).Treasury_Grant_Received_Amount__c);
          //  rec.Orig_Treasury_Grant_Requested_Amount__c     =   String.valueof(Trigger.oldmap.get(rec.id).Treasury_Grant_Requested_Amount__c);
          //  rec.Orig_Treasury_Grant_Requested_vs_Received__c    =   String.valueof(Trigger.oldmap.get(rec.id).Treasury_Grant_Requested_vs_Received__c);
            rec.Orig_Upfrnt_Lease_Pmt_DueAtInstl__c    =   String.valueof(Trigger.oldmap.get(rec.id).Upfront_Lease_Payment_Due_At_Install__c);
            rec.Orig_Upfrnt_Lease_Pmt_DueAtSign__c    =   String.valueof(Trigger.oldmap.get(rec.id).Upfront_Lease_Payment_Due_At_Signing__c);
            rec.Orig_VP_of_Sales_Notes__c               =   Trigger.oldmap.get(rec.id).VP_of_Sales_Notes__c;
            rec.Orig_Year_1__c                  =   String.valueof(Trigger.oldmap.get(rec.id).Year_1__c);
        
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
                   salesOrdersToCapture.get(pi.Id).addError(
          'Operation Cancelled: Please provide a reason for Approval/Rejection !'); 
                }
                else
                {
                    System.debug('**Comm-'+pi.ProcessSteps[0].Comments);                   
                    salesOrdersToCapture.get(pi.Id).Sales_Order_Approval_Comments__C = pi.ProcessSteps[0].Comments;
                } 
               
            } 
            
        }     
    }
    */
}