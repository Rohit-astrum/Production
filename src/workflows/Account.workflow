<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Account_Default_Currency_Update</fullName>
        <description>This sets the Account Trading Currency field on the Account object to &quot;USD&quot;</description>
        <field>c2g__CODAAccountTradingCurrency__c</field>
        <formula>&quot;USD&quot;</formula>
        <name>Account Default Currency Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Account_Update_Account_Number</fullName>
        <field>AccountNumber</field>
        <formula>Accounting_ID__c</formula>
        <name>Account - Update Account Number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Country_on_Account</fullName>
        <field>BillingCountry</field>
        <formula>&quot;USA&quot;</formula>
        <name>Update Country on Account</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Shipping_Country_on_Account</fullName>
        <field>ShippingCountry</field>
        <formula>&quot;USA&quot;</formula>
        <name>Update Shipping Country on Account</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Account - Set Default Values</fullName>
        <actions>
            <name>Account_Default_Currency_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Account_Update_Account_Number</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets the default values on Account records upon creation</description>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Default Country on Account to USA</fullName>
        <actions>
            <name>Update_Country_on_Account</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.BillingCountry</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Default Shipping Country on Account to USA</fullName>
        <actions>
            <name>Update_Shipping_Country_on_Account</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.ShippingCountry</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
