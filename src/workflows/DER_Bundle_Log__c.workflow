<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>DER_Bundle_Email_Alert</fullName>
        <description>DER Bundle Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Email_To_Contact__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>info@directenergysolar.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>DER_Bundle_Folder/DER_Bundle_Email_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>DER_Bundle_Field_Update</fullName>
        <field>Email_Sent__c</field>
        <literalValue>1</literalValue>
        <name>DER Bundle Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>DER Bundle Log Email Alert</fullName>
        <actions>
            <name>DER_Bundle_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>DER_Bundle_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>DER_Bundle_Log__c.Email_To_Contact__c</field>
            <operation>notEqual</operation>
            <value>NULL</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
