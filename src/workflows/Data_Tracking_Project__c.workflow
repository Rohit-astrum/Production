<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Account_Check</fullName>
        <description>Account Check checkbox is checked</description>
        <field>Account_Check__c</field>
        <literalValue>1</literalValue>
        <name>Account Check</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Account_Check_Un_Check</fullName>
        <description>Un-checks the Account Check checkbox.</description>
        <field>Account_Check__c</field>
        <literalValue>0</literalValue>
        <name>Account Check Un-Check</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Ops_Check</fullName>
        <description>Updates Ops Check field to true</description>
        <field>Ops_Check__c</field>
        <literalValue>1</literalValue>
        <name>Ops Check</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Ops_Check_Un_Check</fullName>
        <description>Un-Checks the Ops Check checkbox</description>
        <field>Ops_Check__c</field>
        <literalValue>0</literalValue>
        <name>Ops Check Un-Check</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sales_Check</fullName>
        <description>Updates Sales Check field to true</description>
        <field>Sales_Check__c</field>
        <literalValue>1</literalValue>
        <name>Sales Check</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sales_Checkbox_Un_Check</fullName>
        <description>Un-Checks the Sales Check checkbox</description>
        <field>Sales_Check__c</field>
        <literalValue>0</literalValue>
        <name>Sales Checkbox Un-Check</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Account Check</fullName>
        <actions>
            <name>Account_Check</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Michelle__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Michelle1__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Michelle2__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Workflow rule for Account Check checkbox</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Account Check Deactivate</fullName>
        <actions>
            <name>Account_Check_Un_Check</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2 OR 3</booleanFilter>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Michelle__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Michelle1__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Michelle2__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Workflow rule for un-checking Account Check checkbox</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Ops Check</fullName>
        <actions>
            <name>Ops_Check</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 and 6</booleanFilter>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Ben__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Ben1__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Ben3__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Ben4__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Ben5__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Ben6__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Workflow Rule for Ops Check checkbox</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Ops Check Deactivate</fullName>
        <actions>
            <name>Ops_Check_Un_Check</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 or 2 or 3 or 4 or 5 or 6</booleanFilter>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Ben__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Ben1__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Ben3__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Ben4__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Ben5__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Ben6__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Workflow Rule for un-checking Ops Check checkbox</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Sales Check</fullName>
        <actions>
            <name>Sales_Check</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 and 6 and 7 and 8 and 9 and 10 and 11</booleanFilter>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Sandy__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Sandy1__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Sandy2__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Sandy3__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Sandy4__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Sandy5__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Sandy6__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Sandy7__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Sandy8__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Sandy9__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Sandy10__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Workflow rule to check Sales Check checkbox</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Sales Check Deactivate</fullName>
        <actions>
            <name>Sales_Checkbox_Un_Check</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 or 2 or 3 or 4 or 5 or 6 or 7 or 8 or 9 or 10 or 11</booleanFilter>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Sandy__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Sandy1__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Sandy2__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Sandy3__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Sandy4__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Sandy5__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Sandy6__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Sandy7__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Sandy8__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Sandy9__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Data_Tracking_Project__c.Checked_by_Sandy10__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Workflow rule to un-check Sales Check checkbox</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
