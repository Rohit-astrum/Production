<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>New_Idea_in_Idea_Exchange</fullName>
        <description>New Idea in Idea Exchange</description>
        <protected>false</protected>
        <recipients>
            <recipient>vadim.polikov@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/New_Idea_in_the_Idea_Exchange</template>
    </alerts>
    <rules>
        <fullName>Email Vadim on New Ideas</fullName>
        <actions>
            <name>New_Idea_in_Idea_Exchange</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Idea.CommunityId</field>
            <operation>equals</operation>
            <value>Astrum Employees</value>
        </criteriaItems>
        <description>Email Vadim Every Time a New Idea is Posted in the Idea Exchange</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
