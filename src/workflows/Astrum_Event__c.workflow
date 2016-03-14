<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>D2D_System_Designer_Alert</fullName>
        <description>D2D System Designer Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>info@directenergysolar.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>D2D_Email_Templates/Notify_System_Designer</template>
    </alerts>
    <alerts>
        <fullName>New_Sales_Visit_Event_Scheduled</fullName>
        <description>New Sales Visit Event Scheduled</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/New_Sales_Visit_Scheduled</template>
    </alerts>
    <rules>
        <fullName>Astrum Event Scheduled</fullName>
        <actions>
            <name>New_Sales_Visit_Event_Scheduled</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Astrum_Event__c.Status__c</field>
            <operation>equals</operation>
            <value>Scheduled</value>
        </criteriaItems>
        <criteriaItems>
            <field>Astrum_Event__c.Event_ID__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>When an event status is set to Scheduled, send an email to the owner of the event.  Workflow on Astrum Event because Event cannot send email from Workflow.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>D2D Site Survey Request</fullName>
        <actions>
            <name>D2D_System_Designer_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This workflow rule sends an email alert to the AssignedTo person on the event.</description>
        <formula>AND(D2D_Survey_Request__c, Record_Type_Developer_Name__c = &apos;Site_Survey_Remote&apos;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
