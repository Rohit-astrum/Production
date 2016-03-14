<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Contract_Admin_Rejection_Email_Alert</fullName>
        <description>Contract Admin Rejection Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SalesOrderRejectionVF</template>
    </alerts>
    <alerts>
        <fullName>Contract_Administrator_Auto_Rejection_Email_Alert</fullName>
        <description>Contract Administrator Auto Rejection Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Coordinator__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Sales_Order_Rejection_Notice</template>
    </alerts>
    <alerts>
        <fullName>Contract_Administrator_Rejection_Email_Alert</fullName>
        <description>Contract Administrator Rejection Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Regional_Sales_Manager__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>daniel.schneider@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Sales_Coordinator__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SalesOrderSCRejectionVF</template>
    </alerts>
    <alerts>
        <fullName>Controller_Rejection_Email_Alert</fullName>
        <description>Controller Rejection Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>thomas.reichelderfer@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SalesOrderRejectionVF</template>
    </alerts>
    <alerts>
        <fullName>Conversion_Pricing_Rejected_Alert</fullName>
        <description>Conversion Pricing Rejected Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SalesOrderRejectionVF</template>
    </alerts>
    <alerts>
        <fullName>Customer_Care_Conversion_Contract_Rejection_Alert</fullName>
        <description>Customer Care Conversion Contract Rejection Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SalesOrderRejectionVF</template>
    </alerts>
    <alerts>
        <fullName>Notify_Ron</fullName>
        <description>Notify Ron</description>
        <protected>false</protected>
        <recipients>
            <recipient>Controller</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SalesOrderVPApprovalNoticeVF</template>
    </alerts>
    <alerts>
        <fullName>Proposal_Rejected_Alert</fullName>
        <description>Proposal Rejected Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SalesOrderRejectionVF</template>
    </alerts>
    <alerts>
        <fullName>SO_Dir_of_P_A</fullName>
        <description>SO Dir of P&amp;A Rejection Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>daniel.schneider@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>david.shaw@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jennifer.king@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>thom.smith@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SOA_Sales_Order_RejectionVF</template>
    </alerts>
    <alerts>
        <fullName>SO_Escalation_Alert</fullName>
        <description>SO Escalation Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>chris.benonis@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>daniel.schneider@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SOA_Sales_Order_EscalationVF</template>
    </alerts>
    <alerts>
        <fullName>SO_Final_Approval_Alert</fullName>
        <description>SO Final Approval Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Regional_Sales_Manager__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>daniel.schneider@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jennifer.king@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jessica.treuth@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Finance_Associate__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Incentive_Associate__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SOA_Sales_Order_Final_ApprovalVF</template>
    </alerts>
    <alerts>
        <fullName>SO_Prelim_Approval_Email_Alert</fullName>
        <description>SO Prelim Approval Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Regional_Sales_Manager__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>daniel.schneider@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jennifer.king@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jessica.treuth@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Finance_Associate__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Incentive_Associate__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SOA_Sales_Order_Prelim_ApprovalVF</template>
    </alerts>
    <alerts>
        <fullName>SO_Regional_Dir_Rejection_Alert</fullName>
        <description>SO Regional Dir Rejection Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>chris.benonis@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>daniel.schneider@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jennifer.king@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SOA_Sales_Order_RejectionVF</template>
    </alerts>
    <alerts>
        <fullName>SO_Rejection_Alert</fullName>
        <description>SO Rejection Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Regional_Sales_Manager__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>daniel.schneider@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jennifer.king@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jessica.treuth@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SOA_Sales_Order_RejectionVF</template>
    </alerts>
    <alerts>
        <fullName>SO_Review_Alert</fullName>
        <description>SO Review Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Regional_Sales_Manager__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SOA_Sales_Order_ReviewVF</template>
    </alerts>
    <alerts>
        <fullName>SO_Review_Alert2</fullName>
        <description>SO Review Alert2</description>
        <protected>false</protected>
        <recipients>
            <field>Regional_Sales_Manager__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SOA_Sales_Order_ReviewVF</template>
    </alerts>
    <alerts>
        <fullName>SO_Review_Alert3</fullName>
        <description>SO Review Alert3</description>
        <protected>false</protected>
        <recipients>
            <recipient>daniel.schneider@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jennifer.king@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Contract_Admin__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SOA_Sales_Order_ReviewVF</template>
    </alerts>
    <alerts>
        <fullName>SO_Sales_Alert</fullName>
        <description>SO Sales Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Alert_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-reply-sales@directenergysolar.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/SOA_Sales_AlertVF</template>
    </alerts>
    <alerts>
        <fullName>Sales_Alert</fullName>
        <description>Sales Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Alert_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-reply-sales@directenergysolar.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Sales_Alert</template>
    </alerts>
    <alerts>
        <fullName>Sales_Consultant_Re_Submit_Deadline_Reached</fullName>
        <description>Sales Consultant Re-Submit Deadline Reached</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Sales_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SalesOrderRejectedTooLong</template>
    </alerts>
    <alerts>
        <fullName>Sales_Coordinator_Escalation_FYI_Alert</fullName>
        <description>Sales Coordinator Escalation FYI Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>Controller</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Sales_Order_Escalation_FYI_Notice</template>
    </alerts>
    <alerts>
        <fullName>Sales_Coordinator_Rejection_Email_Alert</fullName>
        <description>Sales Coordinator Rejection Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SalesOrderRejectionVF</template>
    </alerts>
    <alerts>
        <fullName>Sales_Manager_Rejection_Email_Alert</fullName>
        <description>Sales Manager Rejection Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SalesOrderRejectionVF</template>
    </alerts>
    <alerts>
        <fullName>Sales_Order_Hand_Off_to_Ops</fullName>
        <ccEmails>billing@astrumsolar.com</ccEmails>
        <description>Sales Order Hand Off to Ops</description>
        <protected>false</protected>
        <recipients>
            <field>Contact_Detail_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>Accounting</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>Lease_Adminstration</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>chris.benonis@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kenita.williams@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Director_of_Operations__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SalesOrderHandOffNoticeVF</template>
    </alerts>
    <alerts>
        <fullName>VP_Sales_Escalation_Email_Alert</fullName>
        <description>VP Sales Escalation Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>thomas.reichelderfer@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Sales_Order_Escalation_Approval_Notice</template>
    </alerts>
    <alerts>
        <fullName>VP_Sales_Rejection_Email_Alert</fullName>
        <description>VP Sales Rejection Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Regional_Sales_Manager__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>daniel.schneider@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Sales_Coordinator__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SalesOrderRejectionVF</template>
    </alerts>
    <fieldUpdates>
        <fullName>Anthony_Review_Complete</fullName>
        <field>StatusCode__c</field>
        <literalValue>Conversion Ongoing</literalValue>
        <name>Anthony Review Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Comment_Requested</fullName>
        <field>Approval_Comment_Check__c</field>
        <literalValue>Requested</literalValue>
        <name>Approval Comment Requested</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Comment_Required</fullName>
        <field>Approval_Comment_Check__c</field>
        <literalValue>Required</literalValue>
        <name>Approval Comment Required</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_to_Dir_of_Ops_flag</fullName>
        <field>Assign_to_Dir_of_Ops__c</field>
        <literalValue>1</literalValue>
        <name>Assign to Dir of Ops flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CC_Contract_Rejection</fullName>
        <field>StatusCode__c</field>
        <literalValue>Conversion Ongoing</literalValue>
        <name>CC Contract Rejection</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CC_Conversion_Rejection</fullName>
        <field>StatusCode__c</field>
        <literalValue>Conversion Proposal Review</literalValue>
        <name>CC Conversion Rejection</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Chris_Anthony_Outreach_Complete</fullName>
        <field>StatusCode__c</field>
        <literalValue>Conversion Processing</literalValue>
        <name>Chris/Anthony Outreach Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Chris_Anthony_Proposal_Complete</fullName>
        <field>StatusCode__c</field>
        <literalValue>Conversion Proposal Review</literalValue>
        <name>Chris/Anthony Proposal Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Chris_Review_Complete</fullName>
        <field>StatusCode__c</field>
        <literalValue>Conversion Ongoing</literalValue>
        <name>Chris Review Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Re_Submit_Penalty_Deadline</fullName>
        <field>Re_Submit_Penalty_Deadline__c</field>
        <name>Clear Re Submit Penalty Deadline</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contract_Admin_Appr_Financed</fullName>
        <field>StatusCode__c</field>
        <literalValue>Contract Admin Approved - Finance</literalValue>
        <name>Contract Admin Appr -- Financed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Controller_Rejected_Finance</fullName>
        <field>StatusCode__c</field>
        <literalValue>Controller Rejected - Finance</literalValue>
        <name>Controller Rejected - Finance</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Controller_Rejection</fullName>
        <field>StatusCode__c</field>
        <literalValue>Conversion Processing</literalValue>
        <name>Controller Rejection</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Conversion_Approved</fullName>
        <field>StatusCode__c</field>
        <literalValue>Conversion Approved</literalValue>
        <name>Conversion Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Conversion_Pricing_Rejected</fullName>
        <field>StatusCode__c</field>
        <literalValue>Conversion Pending</literalValue>
        <name>Conversion Pricing Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_RSM_Email</fullName>
        <field>Regional_Sales_Manager__c</field>
        <formula>RSM_Email__c</formula>
        <name>Copy RSM Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_Accounting_Approved</fullName>
        <field>StatusCode__c</field>
        <literalValue>Final/Accounting Approved</literalValue>
        <name>Mark Accounting Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_CA_Rejected</fullName>
        <description>Mark Contract Administrator Rejected</description>
        <field>StatusCode__c</field>
        <literalValue>Contract Administrator Rejected</literalValue>
        <name>Mark CA Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_Controller_Rejected</fullName>
        <field>StatusCode__c</field>
        <literalValue>Controller Rejected</literalValue>
        <name>Mark Controller Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_Conversion_Pending</fullName>
        <field>StatusCode__c</field>
        <literalValue>Conversion Pending</literalValue>
        <name>Mark Conversion Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_Conversion_Proposal_Creation</fullName>
        <field>StatusCode__c</field>
        <literalValue>Conversion Proposal Creation</literalValue>
        <name>Mark Conversion Proposal Creation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_Coordinator_Approved</fullName>
        <field>StatusCode__c</field>
        <literalValue>Sales Coordinator Approved</literalValue>
        <name>Mark Sales Coordinator Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_Manager_Approved</fullName>
        <field>StatusCode__c</field>
        <literalValue>Sales Manager Approved</literalValue>
        <name>Mark Manager Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_Re_Submitted</fullName>
        <field>StatusCode__c</field>
        <literalValue>Re-Submitted</literalValue>
        <name>Mark Re-Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_Resubmit_to_SC</fullName>
        <description>Mark Resubmit to Sales Coordinator</description>
        <field>StatusCode__c</field>
        <literalValue>Re-Submit To Sales Coordinator</literalValue>
        <name>Mark Resubmit to SC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_Submit_Pending</fullName>
        <field>StatusCode__c</field>
        <literalValue>Sales Coordinator Rejected</literalValue>
        <name>Mark Sales Coordinator Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_Submitted</fullName>
        <field>StatusCode__c</field>
        <literalValue>Submitted</literalValue>
        <name>Mark Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_VP_Sales_Approved</fullName>
        <field>StatusCode__c</field>
        <literalValue>VP Sales Approved</literalValue>
        <name>Mark VP Sales Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_VP_Sales_Rejected</fullName>
        <field>StatusCode__c</field>
        <literalValue>VP Sales Rejected</literalValue>
        <name>Mark VP Sales Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Outreach_Complete</fullName>
        <field>StatusCode__c</field>
        <literalValue>Conversion Processing</literalValue>
        <name>Outreach Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Processing_Complete</fullName>
        <field>StatusCode__c</field>
        <literalValue>Conversion Review</literalValue>
        <name>Processing Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Proposal_Complete</fullName>
        <field>StatusCode__c</field>
        <literalValue>Conversion Proposal Review</literalValue>
        <name>Proposal Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Proposal_Rejected</fullName>
        <field>StatusCode__c</field>
        <literalValue>Conversion Proposal Creation</literalValue>
        <name>Proposal Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Review_Complete</fullName>
        <field>StatusCode__c</field>
        <literalValue>Conversion Ongoing</literalValue>
        <name>Review Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SO_Director_of_P_A_Rejected</fullName>
        <field>StatusCode__c</field>
        <literalValue>Director of P&amp;A Rejected</literalValue>
        <name>SO Director of P&amp;A Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SO_OPS_Submitted</fullName>
        <field>StatusCode__c</field>
        <literalValue>OPS Submitted</literalValue>
        <name>SO OPS Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SO_Prelim_Approval_Date</fullName>
        <field>Prelim_Approval_Date__c</field>
        <formula>NOW()</formula>
        <name>SO Prelim Approval Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SO_Prelim_Approved</fullName>
        <field>StatusCode__c</field>
        <literalValue>Prelim Approved</literalValue>
        <name>SO Prelim Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SO_Regional_Director_Approved</fullName>
        <field>StatusCode__c</field>
        <literalValue>Regional Director Approved</literalValue>
        <name>SO Regional Director Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SO_Regional_Director_Rejected</fullName>
        <field>StatusCode__c</field>
        <literalValue>Regional Director Rejected</literalValue>
        <name>SO Regional Director Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SO_Sales_Final_Submitted</fullName>
        <field>StatusCode__c</field>
        <literalValue>Sales Final Submitted</literalValue>
        <name>SO Sales Final Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SO_Sales_Re_Submitted</fullName>
        <field>StatusCode__c</field>
        <literalValue>Sales ReSubmitted</literalValue>
        <name>SO Sales Re-Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SO_Sales_Submitted</fullName>
        <field>StatusCode__c</field>
        <literalValue>Sales Submitted</literalValue>
        <name>SO Sales Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SO_Status_to_Contract_Admin_Rejected</fullName>
        <field>StatusCode__c</field>
        <literalValue>Contract Administrator Rejected</literalValue>
        <name>SO Status to Contract Admin Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Canceled_Date</fullName>
        <field>Canceled_Date__c</field>
        <formula>NOW()</formula>
        <name>Set Canceled Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Re_Assigned_to_Sales_Manager</fullName>
        <field>StatusCode__c</field>
        <literalValue>Re-Assigned to Sales Manager</literalValue>
        <name>Set Re-Assigned to Sales Manager</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Re_Submit_Penalty</fullName>
        <field>Re_Submit_Penalty__c</field>
        <literalValue>1</literalValue>
        <name>Set Re-Submit Penalty</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Timestamp_Ops_Submitted_Date</fullName>
        <description>Updates the Ops Submitted Date with NOW()</description>
        <field>Ops_Submitted_Date__c</field>
        <formula>NOW()</formula>
        <name>Timestamp Ops Submitted Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Date_On_SalesOrder</fullName>
        <description>Update Approval Date On SalesOrder</description>
        <field>Approval_Date__c</field>
        <formula>NOW()</formula>
        <name>Update Approval Date On SalesOrder</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_SO_Status_to_cancel_pending</fullName>
        <description>Update sales order status to &quot;cancel pending&quot;</description>
        <field>StatusCode__c</field>
        <literalValue>Cancel Pending</literalValue>
        <name>Update SO Status to cancel pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Sales_Order_Approval_Date</fullName>
        <description>Update Sales Order Approval Date on Sales Order</description>
        <field>Sales_Order_Approval_Date__c</field>
        <formula>NOW()</formula>
        <name>Update Sales Order Approval Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Approval Comment Flag</fullName>
        <actions>
            <name>Approval_Comment_Requested</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SCRB_SalesOrder__c.Approval_Comment_Check__c</field>
            <operation>equals</operation>
            <value>Required</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Copy RSM Email</fullName>
        <actions>
            <name>Copy_RSM_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SCRB_SalesOrder__c.RSM_Email__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Email Alert for Sales Order Escalation</fullName>
        <actions>
            <name>VP_Sales_Escalation_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>SCRB_SalesOrder__c.StatusCode__c</field>
            <operation>equals</operation>
            <value>VP Sales Rejected</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Canceled Date</fullName>
        <actions>
            <name>Set_Canceled_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>IF( ISPICKVAL(StatusCode__c, &quot;Canceled&quot;) , TRUE, FALSE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Sales Order Re-Submit Penalty</fullName>
        <active>false</active>
        <criteriaItems>
            <field>SCRB_SalesOrder__c.StatusCode__c</field>
            <operation>equals</operation>
            <value>Sales Coordinator Rejected</value>
        </criteriaItems>
        <criteriaItems>
            <field>SCRB_SalesOrder__c.Re_Submit_Penalty_Deadline__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This will set the penalty flag when the status code has been Sales Coordinator Rejected for 5 days.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clear_Re_Submit_Penalty_Deadline</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Set_Re_Assigned_to_Sales_Manager</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Set_Re_Submit_Penalty</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>SCRB_SalesOrder__c.Re_Submit_Penalty_Deadline__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update SO Status if Status in Adm rejected for 30 days</fullName>
        <active>true</active>
        <criteriaItems>
            <field>SCRB_SalesOrder__c.StatusCode__c</field>
            <operation>equals</operation>
            <value>Contract Administrator Rejected</value>
        </criteriaItems>
        <description>Update SO Status to &quot;Cancel Pending&quot; if Status in Adm rejected for 30 days</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_SO_Status_to_cancel_pending</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
