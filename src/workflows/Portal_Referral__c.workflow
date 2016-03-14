<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Portal_Referral_Scheduled_Visit</fullName>
        <description>Portal Referral Scheduled Visit</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>info@directenergysolar.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>D2D_Email_Templates/Notify_Scheduled_Visit</template>
    </alerts>
    <fieldUpdates>
        <fullName>Portal_Referral_Sales_Process_Ongoing</fullName>
        <field>Detail__c</field>
        <formula>&quot;Sales Process Ongoing&quot;</formula>
        <name>Portal Referral - Sales Process Ongoing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Portal_Referral_Scheduled_Visit_Reset</fullName>
        <field>D2D_Visit_Scheduled__c</field>
        <literalValue>0</literalValue>
        <name>Portal Referral Scheduled Visit Reset</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Portal_Referral_Set_Long_Term_Oppty</fullName>
        <description>Sets the Detail to long-term opportunity</description>
        <field>Detail__c</field>
        <formula>&quot;Long-Term Opportunity&quot;</formula>
        <name>Portal Referral - Set Long Term Oppty</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Portal_Referral_Set_Status_Change_Date</fullName>
        <field>Last_Status_Change_Date__c</field>
        <formula>TODAY()</formula>
        <name>Portal Referral - Set Status Change Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Portal_Referral_Set_Status_to_Closed</fullName>
        <field>Status__c</field>
        <literalValue>CLOSED</literalValue>
        <name>Portal Referral - Set Status to Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Portal Referral - Set Closed after 120 days Unresponsive</fullName>
        <active>true</active>
        <description>Set Closed after 120 days Qualified Unresponsive</description>
        <formula>AND (   ISPICKVAL(Status__c, &apos;QUALIFIED&apos;),   Detail__c = &apos;Unresponsive&apos; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Portal_Referral_Set_Status_Change_Date</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Portal_Referral_Set_Status_to_Closed</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Portal_Referral__c.Last_Status_Change_Date__c</offsetFromField>
            <timeLength>120</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Portal Referral - Set Closed after 60 days Open Unresponsive</fullName>
        <active>true</active>
        <description>Set Closed after 60 days Open Unresponsive</description>
        <formula>AND (   ISPICKVAL(Status__c, &apos;OPEN&apos;),   Detail__c = &apos;Unresponsive&apos; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Portal_Referral_Set_Status_Change_Date</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Portal_Referral_Set_Status_to_Closed</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Portal_Referral__c.Last_Status_Change_Date__c</offsetFromField>
            <timeLength>60</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Portal Referral - Set Long-Term Oppty 60 days after Sales Process Ongoing</fullName>
        <active>true</active>
        <description>Set Long-Term Oppty 60 days after Sales Process Ongoing</description>
        <formula>AND (   ISPICKVAL(Status__c, &apos;QUALIFIED&apos;),   Detail__c = &apos;Sales Process Ongoing&apos; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Portal_Referral_Set_Long_Term_Oppty</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Portal_Referral_Set_Status_Change_Date</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Portal_Referral__c.Last_Status_Change_Date__c</offsetFromField>
            <timeLength>60</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Portal Referral - Set Long-Term Oppty after 90 days</fullName>
        <active>true</active>
        <description>Set Long-Term Oppty 90 days after Evaluation or Site Survey</description>
        <formula>AND (   ISPICKVAL(Status__c, &apos;QUALIFIED&apos;),   OR (     Detail__c = &apos;Evaluation In Progress&apos;,     Detail__c = &apos;Site Survey Completed&apos;   ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Portal_Referral_Set_Long_Term_Oppty</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Portal_Referral_Set_Status_Change_Date</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Portal_Referral__c.Last_Status_Change_Date__c</offsetFromField>
            <timeLength>90</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Portal Referral - Set Sales Process Ongoing after 30 days</fullName>
        <active>true</active>
        <description>Set Sales Process Ongoing after 30 days</description>
        <formula>AND (   ISPICKVAL(Status__c, &apos;QUALIFIED&apos;),   Detail__c = &apos;Sales Call Completed&apos; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Portal_Referral_Sales_Process_Ongoing</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Portal_Referral_Set_Status_Change_Date</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Portal_Referral__c.Last_Status_Change_Date__c</offsetFromField>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Portal Referral Scheduled Visit</fullName>
        <actions>
            <name>Portal_Referral_Scheduled_Visit_Reset</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Portal_Referral__c.D2D_Visit_Scheduled__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Portal_Referral_Scheduled_Visit</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Portal_Referral__c.D2D_Scheduled_Visit_Datetime__c</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
