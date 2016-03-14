<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Timesheet_Weekly_Summary_Email</fullName>
        <description>Timesheet Weekly Summary Email</description>
        <protected>false</protected>
        <recipients>
            <field>Employee_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/TimtsheetWeeklySummary</template>
    </alerts>
    <fieldUpdates>
        <fullName>Timesheet_Employee_Email_Update</fullName>
        <field>Employee_Email__c</field>
        <formula>Employee__r.Email__c</formula>
        <name>Timesheet Employee Email Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Timesheet Weekly Summary</fullName>
        <actions>
            <name>Timesheet_Employee_Email_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Time_Sheet__c.For_The_Week_Starting__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Timesheet_Weekly_Summary_Email</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Time_Sheet__c.For_The_Week_Starting__c</offsetFromField>
            <timeLength>9</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
