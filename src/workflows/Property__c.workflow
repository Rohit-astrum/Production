<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Property_Update_Lat_from_QAS</fullName>
        <field>Latitude__c</field>
        <formula>VALUE( QAS_Latitude__c )</formula>
        <name>Property - Update Lat from QAS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Property_Update_Lon_from_QAS</fullName>
        <field>Longitude__c</field>
        <formula>VALUE( QAS_Longitude__c )</formula>
        <name>Property - Update Lon from QAS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set Property Lat Lon from QAS</fullName>
        <actions>
            <name>Property_Update_Lat_from_QAS</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Property_Update_Lon_from_QAS</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets the Lat and Lon on property from the QAS values</description>
        <formula>AND(   NOT(ISNULL( QAS_Latitude__c )),   NOT(ISNULL( QAS_Longitude__c )),   OR (     ISNEW(),     ISCHANGED( QAS_Latitude__c ),     ISCHANGED( QAS_Longitude__c )   ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
