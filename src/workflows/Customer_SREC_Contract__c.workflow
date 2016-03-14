<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Unverify</fullName>
        <description>Remove &quot;Verify&quot; Checkbox</description>
        <field>Verified__c</field>
        <literalValue>0</literalValue>
        <name>Unverify</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Verify</fullName>
        <description>Check the &quot;Verified&quot; box on record</description>
        <field>Verified__c</field>
        <literalValue>1</literalValue>
        <name>Verify</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
