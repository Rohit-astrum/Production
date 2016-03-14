<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Proof_of_Inspection_Date</fullName>
        <description>Email Proof of Inspection Date</description>
        <protected>false</protected>
        <recipients>
            <recipient>hillel.halberstam@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jenny.yang@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Proof_of_Inspection_Added_or_Changed</template>
    </alerts>
    <alerts>
        <fullName>HandoffChecklistRejectionEmailAlert</fullName>
        <description>Handoff Checklist Rejection Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Project_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/HandoffRejectionNoticeVF</template>
    </alerts>
    <alerts>
        <fullName>Handoff_Checklist_Rejection_Email_Alert</fullName>
        <description>Handoff Checklist Rejection Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Project_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Handoff_Checklist_Rejection_Notice</template>
    </alerts>
    <alerts>
        <fullName>Lease_Fund_Status_Notification</fullName>
        <ccEmails>billing@astrumsolar.com</ccEmails>
        <description>Lease Fund Status Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Regional_Sales_Manager__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>Director_of_Field_Operations</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>Head_of_Solar_Operations</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>MA_Director_of_Regional_Operations</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>MA_Hopkinton_Manager_of_Field_Operations</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>MD_Manager_of_Field_Operations</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>MD_NJ_PA_DC_LI_Director_of_Regional_Operations</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>NJ_Manager_of_Field_Operations</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>NY_Middletown_Regional_Operations_Manager</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>anthony.bramante@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ben.davis@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
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
        <recipients>
            <recipient>jessica.treuth@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jessica.w@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>joe.rice@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>katelyn.williams@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kenita.williams@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>noah@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>thomas.reichelderfer@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Project_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/LeaseFundingActionsVF</template>
    </alerts>
    <alerts>
        <fullName>Utility_Interconnect_Part_2_Change_Alert</fullName>
        <description>Utility Interconnect Part 2 Change Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>Head_of_Solar_Operations</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Project_Alerts/Utility_Interconnect_Part_2_Approval</template>
    </alerts>
    <fieldUpdates>
        <fullName>Clear_Install_Date</fullName>
        <description>Clear the Install Date</description>
        <field>Install__c</field>
        <name>Clear Install Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_RSM_Email_in_Projects</fullName>
        <field>Regional_Sales_Manager__c</field>
        <formula>RSM_Email__c</formula>
        <name>Copy RSM Email in Projects</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Customer_Action_Note_Lease_Fund</fullName>
        <description>Do NOT Install Project at Current Time. Lease Fund TBD.</description>
        <field>Customer_Action_Notes__c</field>
        <formula>&apos;Do NOT Install Project at Current Time. Lease Fund TBD.  &apos;+ Customer_Action_Notes__c</formula>
        <name>Customer Action Note - Lease Fund</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Handoff_Checklist_Status_Rejected</fullName>
        <field>Handoff_Checklist_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Handoff Checklist Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Handoff_Checklist_Status_Verified</fullName>
        <field>Handoff_Checklist_Status__c</field>
        <literalValue>Verified</literalValue>
        <name>Handoff Checklist Status Verified</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Handoff_Email_Sent_Date</fullName>
        <field>Handoff_Email_Sent_Date__c</field>
        <formula>Today()</formula>
        <name>Handoff Email Sent Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Handoff_Update_Customer_Care_Date</fullName>
        <field>Customer_Care_Handoff__c</field>
        <formula>Today()</formula>
        <name>Handoff Update Customer Care Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lease_Fund_Customer_Action_Note</fullName>
        <field>Customer_Action_Notes__c</field>
        <formula>&quot;Change Pending - DO NOT INSTALL&quot;</formula>
        <name>Lease Fund - Customer Action Note</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lease_Fund_Ready_to_Install_Note</fullName>
        <field>Customer_Action_Notes__c</field>
        <name>Lease Fund - Ready to Install Note</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lease_Fund_Ready_to_Install_Note_Resol</fullName>
        <field>Customer_Action_Resolved__c</field>
        <literalValue>1</literalValue>
        <name>Lease Fund - Ready to Install Note Resol</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lease_Fund_Ready_to_Prepare_Note</fullName>
        <field>Customer_Action_Notes__c</field>
        <formula>&quot;Ready to Prepare - DO NOT INSTALL&quot;</formula>
        <name>Lease Fund - Ready to Prepare Note</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PM_Project_Approval_Comment_Required</fullName>
        <field>Approval_Comment_Check__c</field>
        <literalValue>Required</literalValue>
        <name>PM Project Approval Comment Required</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Install_Date_60_Days_Out</fullName>
        <description>Set Install Date to 60 Days in the future</description>
        <field>Install__c</field>
        <formula>IF(MOD((TODAY()-DATE(1900,1,1)),7)&gt;4,TODAY() +60+(MOD((TODAY()-DATE(1900,1,1)),7)-5),TODAY()+60)</formula>
        <name>Set Install Date 60 Days Out</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Install_Date_90_Days_Out</fullName>
        <description>Set Install Date 90 Days Out</description>
        <field>Install__c</field>
        <formula>IF(MOD((TODAY()-DATE(1900,1,1)),7)&gt;4,TODAY() +90+(MOD((TODAY()-DATE(1900,1,1)),7)-5),TODAY()+90)</formula>
        <name>Set Install Date 90 Days Out</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_PM_Project_Active</fullName>
        <description>Sets PM Project to active</description>
        <field>Status__c</field>
        <literalValue>Active</literalValue>
        <name>Set PM Project Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Handoff_Checklist_Completed_Flag</fullName>
        <field>Handoff_Check_list_Completed__c</field>
        <literalValue>0</literalValue>
        <name>Update Handoff Checklist Completed Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Handoff_Checklist_Completed_True</fullName>
        <field>Handoff_Check_list_Completed__c</field>
        <literalValue>1</literalValue>
        <name>Update Handoff Checklist Completed True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Handoff_Checklist_to_Reject</fullName>
        <field>Handoff_Checklist_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update Handoff Checklist to Reject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Handoff_Checklist_to_Verified</fullName>
        <field>Handoff_Checklist_Status__c</field>
        <literalValue>Verified</literalValue>
        <name>Update Handoff Checklist to Verified</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Handoff_Verification_date</fullName>
        <field>Handoff_Checklist_Verification_Date__c</field>
        <formula>Today()</formula>
        <name>Update Handoff Verification date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Active Project Must Have Install Date</fullName>
        <actions>
            <name>Set_Install_Date_60_Days_Out</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>PM_Project__c.Status__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <criteriaItems>
            <field>PM_Project__c.Install__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>If Project is Set to Active without an Install Date, Set Install Date 60 days out</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Clear Install Date For Cancelled</fullName>
        <actions>
            <name>Clear_Install_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>PM_Project__c.Status__c</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <description>Remove Install Date when a project is Cancelled</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Copy RSM Email in PM</fullName>
        <actions>
            <name>Copy_RSM_Email_in_Projects</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>PM_Project__c.RSM_Email__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Email Jennifer Barfield When Inspection is Complete</fullName>
        <actions>
            <name>Email_Proof_of_Inspection_Date</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>PM2.0 - Email Jennifer Barfield When Inspection is Complete</description>
        <formula>ISCHANGED( Proof_of_Inspection__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Handoff Update Customer Care Date</fullName>
        <actions>
            <name>Handoff_Update_Customer_Care_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>PM_Project__c.Handoff_Checklist_Status__c</field>
            <operation>equals</operation>
            <value>Rejected,Verified,Handoff Email Sent,Completed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lease Deal Ready to Prepare Notification</fullName>
        <actions>
            <name>Lease_Fund_Status_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Lease_Fund_Ready_to_Prepare_Note</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>PM_Project__c.Lease_Funding_Status__c</field>
            <operation>equals</operation>
            <value>Ready to Prepare</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lease Fund Customer Action Note</fullName>
        <actions>
            <name>Customer_Action_Note_Lease_Fund</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Add Customer Action Note when Lease Fund is &quot;Other&quot;</description>
        <formula>AND( Sales_Order__r.Financing_Type__c  = &apos;Lease&apos;,NOT(CONTAINS( BLANKVALUE(Customer_Action_Notes__c,&quot;Blank&quot;) , &quot;Do NOT Install Project&quot;)),OR(ISPICKVAL(Sales_Order__r.Lease_Fund__c , &apos;NJ - SPECIAL&apos;),ISPICKVAL(Sales_Order__r.Lease_Fund__c , &apos;MA - SPECIAL&apos;),ISPICKVAL(Sales_Order__r.Lease_Fund__c , &apos;CPF&apos;),ISPICKVAL(Sales_Order__r.Lease_Fund__c , &apos;Goldman - Do Not Install&apos;),ISPICKVAL(Sales_Order__r.Lease_Fund__c , &apos;Goldman - Do Not Install - Credit&apos;),ISPICKVAL(Sales_Order__r.Lease_Fund__c , &apos;GOLDMAN1&apos;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Lease Funding Status Cancelled</fullName>
        <actions>
            <name>Lease_Fund_Status_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>PM_Project__c.Lease_Funding_Status__c</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lease Funding Status Change Pending</fullName>
        <actions>
            <name>Lease_Fund_Status_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Lease_Fund_Customer_Action_Note</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISCHANGED(Change_Pending_Count__c),ISPICKVAL(Sales_Order__r.StatusCode__c, &apos;Conversion Pending&apos;) , ISPICKVAL(Lease_Funding_Status__c , &apos;Change Pending&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Lease Funding Status Ready to Install</fullName>
        <actions>
            <name>Lease_Fund_Status_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Lease_Fund_Ready_to_Install_Note</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>PM_Project__c.Lease_Funding_Status__c</field>
            <operation>equals</operation>
            <value>Ready to Install</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Monthly Update of On Hold Projects</fullName>
        <actions>
            <name>Set_Install_Date_90_Days_Out</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Install Date out 90 Days Monthly on</description>
        <formula>OR(ISPICKVAL(Status__c, &quot;On-Hold&quot;),AND(ISPICKVAL(Status__c  , &quot;On-Hold&quot;),Install__c=TODAY()+90))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Set_Install_Date_90_Days_Out</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>PM_Project__c.Install__c</offsetFromField>
            <timeLength>-60</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Set Project Active When Assigned</fullName>
        <actions>
            <name>Set_PM_Project_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets PM Project to active when assigned</description>
        <formula>AND (   OR (     ISNEW(),     ISBLANK(PRIORVALUE(Project_Lead__c))   ),   NOT(ISBLANK(Project_Lead__c)),   ISPICKVAL(Status__c, &apos;New&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Valone%2C Lisa Project Alert</fullName>
        <actions>
            <name>Utility_Interconnect_Part_2_Change_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify Ben Davis when Utility Interconnect Part 2 is Approved</description>
        <formula>AND(ISCHANGED( Approved_Utility_Interconnect_Part_2__c ), Name  = &apos;Valone, Lisa&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
