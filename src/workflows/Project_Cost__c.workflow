<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Project_Cost_Revision_Update</fullName>
        <field>Revision__c</field>
        <formula>NULLVALUE(PRIORVALUE( Revision__c), 0)  + 1</formula>
        <name>Project Cost Revision Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Project Cost Update</fullName>
        <actions>
            <name>Project_Cost_Revision_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Project_Cost__c.Qty__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
