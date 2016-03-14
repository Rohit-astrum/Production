<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Customer_Survey_Received</fullName>
        <description>Customer Survey Received</description>
        <protected>false</protected>
        <recipients>
            <recipient>diane.benedetti@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Customer_Survey_Completed_Notice</template>
    </alerts>
    <alerts>
        <fullName>Customer_Survey_Send_Survey_Email</fullName>
        <description>Customer Survey : Send Survey Email</description>
        <protected>false</protected>
        <recipients>
            <field>Survey_Sent_To_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Customer_Survey_Email</template>
    </alerts>
    <alerts>
        <fullName>Customer_Survey_Send_Survey_Email_Reminder</fullName>
        <description>Customer Survey : Send Survey Email Reminder</description>
        <protected>false</protected>
        <recipients>
            <field>Survey_Sent_To_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Customer_Survey_Email_Reminder</template>
    </alerts>
    <fieldUpdates>
        <fullName>Customer_Survey_Reminder_Date</fullName>
        <field>Last_Reminder_Sent_Date__c</field>
        <formula>Today()</formula>
        <name>Customer Survey Reminder Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Customer_Survey_Reminder_Times</fullName>
        <field>Times_Reminder_Sent__c</field>
        <formula>Times_Reminder_Sent__c + 1</formula>
        <name>Customer Survey Reminder Times</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Customer Survey Re-Send</fullName>
        <actions>
            <name>Customer_Survey_Send_Survey_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Re Send Email to Customer for Survey</description>
        <formula>NOT(ISNULL(Survey_Re_Sent_Date__c) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Customer Survey Received</fullName>
        <actions>
            <name>Customer_Survey_Received</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Customer_Survey__c.Survey_Completed__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Customer Survey Reminder Email - 1</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Customer_Survey__c.Survey_Completed__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Send a reminder email if Survey is not completed after 3 days.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Customer_Survey_Send_Survey_Email_Reminder</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Customer_Survey_Reminder_Date</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Customer_Survey_Reminder_Times</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Customer_Survey__c.Initial_Send_Day__c</offsetFromField>
            <timeLength>72</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Customer Survey Reminder Email - 2</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Customer_Survey__c.Survey_Completed__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Send a reminder email if Survey is not completed after 7 days.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Customer_Survey_Send_Survey_Email_Reminder</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Customer_Survey_Reminder_Date</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Customer_Survey_Reminder_Times</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Customer_Survey__c.Second_Send_Day__c</offsetFromField>
            <timeLength>48</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Customer Survey Reminder Email - 3</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Customer_Survey__c.Survey_Completed__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Send a reminder email if Survey is not completed after 10 days.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Customer_Survey_Send_Survey_Email_Reminder</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Customer_Survey_Reminder_Date</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Customer_Survey_Reminder_Times</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Customer_Survey__c.Third_Send_Day__c</offsetFromField>
            <timeLength>48</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Customer Survey Send</fullName>
        <actions>
            <name>Customer_Survey_Send_Survey_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send Email to Customer for Survey</description>
        <formula>MD5Code__c != Null</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
