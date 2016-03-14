<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Astrum_Est_Annual_Prod_Roll_up</fullName>
        <description>Updates the Astrum Est Annual Prod (Roll-up) field</description>
        <field>Astrum_Est_Annual_Prod_Roll_up__c</field>
        <formula>Astrum_Estimated_Annual_Production_kWh__c</formula>
        <name>Astrum Est Annual Prod (Roll-up)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Astrum_Est_Annual_SRECs_Roll_up</fullName>
        <description>Updates the Astrum Est Annual SRECs (Roll-up) field</description>
        <field>Astrum_Est_Annual_SRECs_Roll_up__c</field>
        <formula>Astrum_Estimated_Annual_SRECs__c</formula>
        <name>Astrum Est Annual SRECs (Roll-up)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Registry Annual Production Rollup</fullName>
        <actions>
            <name>Astrum_Est_Annual_Prod_Roll_up</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Registry_Unit_Installed_System_Junction__c.Astrum_Estimated_Annual_Production_kWh__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Populates Astrum Est Annual Prod (Roll-up) field to be used in roll-up formula on SREC Registry Unit</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Registry Annual SRECs Rollup</fullName>
        <actions>
            <name>Astrum_Est_Annual_SRECs_Roll_up</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Registry_Unit_Installed_System_Junction__c.Astrum_Estimated_Annual_SRECs__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Populates Astrum Est Annual SRECs (Roll-up) field to be used in roll-up formula on SREC Registry Unit</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
