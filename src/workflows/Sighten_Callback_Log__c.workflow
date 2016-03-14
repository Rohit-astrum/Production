<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Sighten_Callback_Log_Error_Detail</fullName>
        <field>Error_Detail__c</field>
        <formula>&quot;none&quot;</formula>
        <name>Sighten Callback Log Error Detail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Default Error Detail Field</fullName>
        <actions>
            <name>Sighten_Callback_Log_Error_Detail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>put a default value in the error detail field to avoid issue with blanks causing argument exception</description>
        <formula>ISBLANK( Error_Detail__c )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
