<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <outboundMessages>
        <fullName>ISC_PowerStandings_Sales_Visit_Sched</fullName>
        <apiVersion>29.0</apiVersion>
        <description>Appointment Scheduled</description>
        <endpointUrl>https://powerstandings.insidesales.com/kpi/apptsset</endpointUrl>
        <fields>Id</fields>
        <fields>LastModifiedById</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>stephen.simons@directenergysolar.com</integrationUser>
        <name>ISC - PowerStandings - Sales Visit Sched</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Event -- Mark Completed Date</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Event.Completed__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Sets Completed Date when Complete checkbox is marked &apos;TRUE&apos;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISC - PowerStandings - Sales Visit Scheduled</fullName>
        <actions>
            <name>ISC_PowerStandings_Sales_Visit_Sched</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>Event.RecordTypeId</field>
            <operation>equals</operation>
            <value>Sales Visit Onsite,Sales Visit Remote</value>
        </criteriaItems>
        <criteriaItems>
            <field>Event.CreatedById</field>
            <operation>equals</operation>
            <value>Stephen Lewis,Steven Penn,Cary Bohlin,Rudy Halim,Bob Blahnik,Robert Fuentes,Charles Paris,Robert Helvey,Leon Copeland Jr,Robert Nelson,Jonas Jeanty,Alexander Langfield,Janine Fields,Mark Miley,Tim Day,Jennifer Schulhoff,Alvin Francis,Peter Warren</value>
        </criteriaItems>
        <criteriaItems>
            <field>Event.CreatedById</field>
            <operation>equals</operation>
            <value>Brian Coe,William Hamous Jr,Fenton Savage,Lamond Brown,Julie Forde</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
