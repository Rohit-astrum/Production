<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ZCSA_Populate_Employee_Id</fullName>
        <field>Employee_Id__c</field>
        <formula>Employee__c + &apos;|&apos; +  Office_Zip_Code__c</formula>
        <name>ZCSA Populate Employee Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>ZCSA Populate Employee Id</fullName>
        <actions>
            <name>ZCSA_Populate_Employee_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Zip_Code_Schedule_Availability__c.Employee__c</field>
            <operation>notEqual</operation>
            <value>NULL</value>
        </criteriaItems>
        <description>Populate the employee id field</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
