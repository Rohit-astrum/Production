<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Case_Work_Request_Email</fullName>
        <description>Case Work Request Email</description>
        <protected>false</protected>
        <recipients>
            <recipient>diane.benedetti@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>toby.noyes@astrumsolar.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>To_Whom__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Work_Request</template>
    </alerts>
    <fieldUpdates>
        <fullName>Case_Work_Request_Sent_Date</fullName>
        <description>Date/Time Case Work Request Was Sent</description>
        <field>Date_Sent__c</field>
        <formula>NOW()</formula>
        <name>Case Work Request Sent Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Case Work Request Email</fullName>
        <actions>
            <name>Case_Work_Request_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Case_Work_Request_Sent_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Send Email on Case Work Request Creation</description>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
