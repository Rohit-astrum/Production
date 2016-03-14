<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>SCA_Email_Alert</fullName>
        <description>SCA Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <field>Property_Owner_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>info@directenergysolar.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Sighten_Status_Updates/Sighten_Credit_Status</template>
    </alerts>
    <fieldUpdates>
        <fullName>SCA_Property_Owner_Email</fullName>
        <field>Property_Owner_Email__c</field>
        <formula>Property__r.Property_Owner__r.Owner.Email</formula>
        <name>SCA Property Owner Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>SCA Send Email On Status Change</fullName>
        <actions>
            <name>SCA_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send emails when appropriate on status change for credit approvals</description>
        <formula>AND(ISCHANGED(Credit_Status__c), OR(ISPICKVAL(Credit_Status__c, &apos;APPROVED&apos;), ISPICKVAL(Credit_Status__c, &apos;EXPIRED&apos;), ISPICKVAL(Credit_Status__c, &apos;FAILED&apos;), ISPICKVAL(Credit_Status__c, &apos;CONDITIONAL&apos;), ISPICKVAL(Credit_Status__c, &apos;ERROR&apos;), ISPICKVAL(Credit_Status__c, &apos;FRAUD&apos;), ISPICKVAL(Credit_Status__c, &apos;MANUAL&apos;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SCA Update Property Owner Email</fullName>
        <actions>
            <name>SCA_Property_Owner_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>Property_Owner_Email__c != Property__r.Property_Owner__r.Owner.Email</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
