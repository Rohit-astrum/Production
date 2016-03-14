<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Last_Contacted_Date</fullName>
        <description>Update Date/Time of Last Customer Contact on Case</description>
        <field>Last_Customer_Contact__c</field>
        <formula>NOW()</formula>
        <name>Last Contacted Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Update Last Contact Date on Case</fullName>
        <actions>
            <name>Last_Contacted_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When a new email comes in, updated last customer contact date on case</description>
        <formula>Incoming==TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
