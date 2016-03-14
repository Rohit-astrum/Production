<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Astrum_Contract_Email_Alert</fullName>
        <description>Astrum Contract Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>info@directenergysolar.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Sighten_Status_Updates/Sighten_Signing_Status</template>
    </alerts>
    <rules>
        <fullName>Astrum Contract Status Update</fullName>
        <actions>
            <name>Astrum_Contract_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>A workflow rule to send a status update email alert</description>
        <formula>AND(ISCHANGED(Sighten_Signing_Status__c), OR(ISPICKVAL(Sighten_Signing_Status__c, &apos;DOWNLOADED&apos;), ISPICKVAL(Sighten_Signing_Status__c, &apos;ERROR&apos;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
