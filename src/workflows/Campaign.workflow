<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Campaign_Set_Record_Type</fullName>
        <description>Set the record type of a campaign to &quot;Standard&quot;</description>
        <field>RecordTypeId</field>
        <lookupValue>Standard</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Campaign Set Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set Record Type</fullName>
        <actions>
            <name>Campaign_Set_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Sets the record type to Standard if no record type is present</description>
        <formula>ISNULL(RecordTypeId)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
