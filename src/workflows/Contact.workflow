<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Contact_Do_Not_Call_TRUE</fullName>
        <description>Do NOT solicit through telephone calls.</description>
        <field>DoNotCall</field>
        <literalValue>1</literalValue>
        <name>Contact Do Not Call TRUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contact_Do_Not_Email_TRUE</fullName>
        <description>Do NOT solicit through email.</description>
        <field>HasOptedOutOfEmail</field>
        <literalValue>1</literalValue>
        <name>Contact Do Not Email TRUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contact_Do_Not_Fax_TRUE</fullName>
        <description>Do NOT solicit through faxing.</description>
        <field>HasOptedOutOfFax</field>
        <literalValue>1</literalValue>
        <name>Contact Do Not Fax TRUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contact_Do_Not_Mail_TRUE</fullName>
        <description>Do NOT solicit through mail services.</description>
        <field>Do_Not_Mail__c</field>
        <literalValue>1</literalValue>
        <name>Contact Do Not Mail TRUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contact_Do_Not_Solicit_TRUE</fullName>
        <description>Do NOT solicit at the door.</description>
        <field>Do_Not_Solicit__c</field>
        <literalValue>1</literalValue>
        <name>Contact Do Not Solicit TRUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contact_Do_Not_Text_TRUE</fullName>
        <description>Do NOT solicit through text messaging.</description>
        <field>Do_Not_Text__c</field>
        <literalValue>1</literalValue>
        <name>Contact Do Not Text TRUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Contact Global Opt Out Solicitation</fullName>
        <actions>
            <name>Contact_Do_Not_Call_TRUE</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Contact_Do_Not_Email_TRUE</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Contact_Do_Not_Fax_TRUE</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Contact_Do_Not_Mail_TRUE</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Contact_Do_Not_Solicit_TRUE</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Contact_Do_Not_Text_TRUE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Global_Opt_Out__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>When global opt out=True (checked) all opt out fields should be selected.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
