<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Change_Request_Approval_Notice</fullName>
        <description>Change Request Approval Notice</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Change_Request_Final_Approval_Notice</template>
    </alerts>
    <alerts>
        <fullName>Change_Request_Completed_Rejection</fullName>
        <description>Change Request Completed Rejection</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/ChangeRequestComplatedRejectionVF</template>
    </alerts>
    <alerts>
        <fullName>Change_Request_Completion_Approval_Notice</fullName>
        <description>Change Request Completion Approval Notice</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>deborah.thomas@astrumsolar.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Change_Request_Completed_Approval_Notice</template>
    </alerts>
    <alerts>
        <fullName>Change_Request_Rejection</fullName>
        <description>Change Request Rejection</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/ChangeRequestRejectionVF</template>
    </alerts>
    <alerts>
        <fullName>Change_Request_Rejection_VP</fullName>
        <description>Change Request Rejection for VP</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/ChangeRequestRejectionVF</template>
    </alerts>
    <fieldUpdates>
        <fullName>CR_Approval_Comment_Requested</fullName>
        <field>Approval_Comment_Check__c</field>
        <literalValue>Requested</literalValue>
        <name>CR Approval Comment Requested</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CR_Approval_Comment_Required</fullName>
        <field>Approval_Comment_Check__c</field>
        <literalValue>Required</literalValue>
        <name>CR Approval Comment Required</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_CR_Accounting_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Accounting Rejected</literalValue>
        <name>Mark CR Accounting Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_CR_App_Flag_Checked</fullName>
        <field>Approval_Flag__c</field>
        <literalValue>1</literalValue>
        <name>Mark CR App Flag Checked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_CR_Approval_Flag</fullName>
        <field>Approval_Flag__c</field>
        <literalValue>0</literalValue>
        <name>Mark CR Approval Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_CR_Approved_Pending</fullName>
        <field>Status__c</field>
        <literalValue>Approved/Pending</literalValue>
        <name>Mark CR Approved Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_CR_Comp_Accounting_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Completion Accounting Rejected</literalValue>
        <name>Mark CR Comp Accounting Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_CR_Complete_Ready_to_Install</fullName>
        <field>Status__c</field>
        <literalValue>Complete/Ready for Install</literalValue>
        <name>Mark CR Complete/Ready to Install</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_CR_Completion_App_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Completion Approval Rejected</literalValue>
        <name>Mark CR Completion App Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_CR_Completion_Pending_Accounting</fullName>
        <field>Status__c</field>
        <literalValue>Completion Pending Accounting</literalValue>
        <name>Mark CR Completion Pending Accounting</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_CR_ME_Rejected</fullName>
        <description>Master Electrician Rejected</description>
        <field>Status__c</field>
        <literalValue>Master Electrician Rejected</literalValue>
        <name>Mark CR ME Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_CR_New_Request</fullName>
        <field>Status__c</field>
        <literalValue>New Request</literalValue>
        <name>Mark CR New Request</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_CR_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Mark CR Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_CR_Submitted</fullName>
        <field>Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Mark CR Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_CR_Submitted_to_Accounting</fullName>
        <field>Status__c</field>
        <literalValue>Submitted to Accounting</literalValue>
        <name>Mark CR Submitted to Accounting</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_ME_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Master Electrician Approved</literalValue>
        <name>Mark ME Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Timestamp_CR_Completion_Approval</fullName>
        <description>Updates the CR Completion Approval with NOW()</description>
        <field>CR_Completion_Approval__c</field>
        <formula>NOW()</formula>
        <name>Timestamp CR Completion Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Timestamp_CR_Original_Submit_Date</fullName>
        <description>Updates the CR Original Submit Date with NOW()</description>
        <field>CR_Original_Submit_Date__c</field>
        <formula>NOW()</formula>
        <name>Timestamp CR Original Submit Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CR Approval Comment Flag</fullName>
        <actions>
            <name>CR_Approval_Comment_Requested</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Change_Request__c.Approval_Comment_Check__c</field>
            <operation>equals</operation>
            <value>Required</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change Request Completed Rejection Email</fullName>
        <actions>
            <name>Change_Request_Completed_Rejection</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Change_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Completion Approval Rejected</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change Request Rejection Email</fullName>
        <actions>
            <name>Change_Request_Rejection</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Change_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Rejected</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change Request Rejection Email for VP</fullName>
        <actions>
            <name>Change_Request_Rejection_VP</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Change_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Completion Accounting Rejected,Accounting Rejected</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
