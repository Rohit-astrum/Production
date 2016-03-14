<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Date_On_Hold_Timestamp</fullName>
        <description>Puts NOW() in the Date On Hold field</description>
        <field>Date_On_Hold__c</field>
        <formula>NOW()</formula>
        <name>Date On Hold Timestamp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Community Program set to On Hold</fullName>
        <actions>
            <name>Date_On_Hold_Timestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Community_Program_Opportunity__c.Stage__c</field>
            <operation>equals</operation>
            <value>On Hold</value>
        </criteriaItems>
        <description>Community Program is set to On Hold</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
