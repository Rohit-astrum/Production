<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Company_Wide_Report_Daily</fullName>
        <ccEmails>team@directenergysolar.com</ccEmails>
        <description>Company Wide Report Daily</description>
        <protected>false</protected>
        <senderAddress>salesforceinfo@directenergysolar.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Company_Wide_Report/Company_Wide_Report_Daily</template>
    </alerts>
    <alerts>
        <fullName>Company_Wide_Report_Monthly</fullName>
        <ccEmails>steven.zilligen@directenergysolar.com</ccEmails>
        <ccEmails>kyle.morris@directenergysolar.com</ccEmails>
        <ccEmails>rohit.jain@directenergysolar.com</ccEmails>
        <ccEmails>sophie.lockerby@directenergysolar.com</ccEmails>
        <ccEmails>testteam@directenergysolar.com</ccEmails>
        <description>Company Wide Report Monthly</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Company_Wide_Report/Company_Wide_Report_Monthly</template>
    </alerts>
    <alerts>
        <fullName>Company_Wide_Report_Monthly_MO</fullName>
        <ccEmails>steven.zilligen@directenergysolar.com</ccEmails>
        <ccEmails>kyle.morris@directenergysolar.com</ccEmails>
        <ccEmails>rohit.jain@directenergysolar.com</ccEmails>
        <ccEmails>sophie.lockerby@directenergysolar.com</ccEmails>
        <ccEmails>testteam@directenergysolar.com</ccEmails>
        <description>Company Wide Report Monthly Management Only</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Company_Wide_Report/Company_Wide_Report_Monthly_MO</template>
    </alerts>
    <alerts>
        <fullName>Company_Wide_Report_Weekly</fullName>
        <ccEmails>team@directenergysolar.com</ccEmails>
        <description>Company Wide Report Weekly</description>
        <protected>false</protected>
        <senderAddress>salesforceinfo@directenergysolar.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Company_Wide_Report/Company_Wide_Report_Weekly</template>
    </alerts>
    <alerts>
        <fullName>Company_Wide_Report_Weekly_MO</fullName>
        <ccEmails>leadershipteam@directenergysolar.com</ccEmails>
        <ccEmails>itdev@directenergysolar.com</ccEmails>
        <description>Company Wide Report Weekly Management Only</description>
        <protected>false</protected>
        <senderAddress>salesforceinfo@directenergysolar.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Company_Wide_Report/Company_Wide_Report_Weekly_MO</template>
    </alerts>
    <fieldUpdates>
        <fullName>Sent_Datetime_Update</fullName>
        <field>Sent_Datetime__c</field>
        <formula>Now()</formula>
        <name>Sent Datetime Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Company Wide Report Daily</fullName>
        <active>true</active>
        <description>This is the workflow rule to trigger the daily report</description>
        <formula>AND(   End_Date__c = TODAY() - 1,   ISPICKVAL(Reporting_Frequency__c, &apos;Daily&apos;),   Ready_To_Send__c,   ISNULL(Sent_Datetime__c) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Company_Wide_Report_Daily</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Sent_Datetime_Update</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Company Wide Report Monthly</fullName>
        <active>true</active>
        <description>This is the workflow rule to trigger the monthly report</description>
        <formula>AND(   ISPICKVAL(Reporting_Frequency__c, &apos;Monthly&apos;),   Ready_To_Send__c,   ISNULL(Sent_Datetime__c) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Company_Wide_Report_Monthly</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Company_Wide_Report_Monthly_MO</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Sent_Datetime_Update</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Company Wide Report Weekly</fullName>
        <active>true</active>
        <description>This is the workflow rule to trigger the weekly report</description>
        <formula>AND(   ISPICKVAL(Reporting_Frequency__c, &apos;Weekly&apos;),   Ready_To_Send__c,   ISNULL(Sent_Datetime__c) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Company_Wide_Report_Weekly</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Company_Wide_Report_Weekly_MO</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Sent_Datetime_Update</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
