<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>New_Incoming_Email_on_This_Case</fullName>
        <description>New Incoming Email on This Case</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Customer_Care/New_Incoming_Case_Email</template>
    </alerts>
    <rules>
        <fullName>Notify Case Owner of New Email</fullName>
        <actions>
            <name>New_Incoming_Email_on_This_Case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Email Case Owner when an email comes in on their case.</description>
        <formula>ISCHANGED(Last_Customer_Contact__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
