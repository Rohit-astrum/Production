<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Confirmation_of_Application_Submission</fullName>
        <description>Email Confirmation of Application Submission</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>info@directenergysolar.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Marketing/Partner_Application_Confirmation</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_Partner_Application_Name</fullName>
        <field>Name</field>
        <formula>First_Name__c + &apos; &apos; + Last_Name__c</formula>
        <name>Set Partner Application Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Partner Application Confirmation</fullName>
        <actions>
            <name>Email_Confirmation_of_Application_Submission</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Partner_Application__c.Email__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set Partner Application Name</fullName>
        <actions>
            <name>Set_Partner_Application_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets the name of the Partner Application to First and Last Name</description>
        <formula>OR(   ISNEW(),   ISCHANGED(First_Name__c),   ISCHANGED(Last_Name__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
