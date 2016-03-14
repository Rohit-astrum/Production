<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Assign_to_Grants_Coordinator</fullName>
        <description>Assign to Grants Coordinator</description>
        <field>Assigned_To__c</field>
        <lookupValue>chris.benonis@directenergysolar.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Assign to Grants Coordinator</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_to_Master_Electrician</fullName>
        <description>Assign to Master Electrician</description>
        <field>Assigned_To__c</field>
        <lookupValue>john.teti@directenergysolar.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Assign to Master Electrician</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_to_coordinator_for_Parts_Calc</fullName>
        <description>Assign to coordinator for Parts Calculator</description>
        <field>Assigned_To__c</field>
        <lookupValue>jessica.w@directenergysolar.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Assign to coordinator for Parts Calc</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_Complete</fullName>
        <description>Mark Complete</description>
        <field>Complete__c</field>
        <literalValue>1</literalValue>
        <name>Mark Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mark_NA</fullName>
        <field>Not_Applicable__c</field>
        <literalValue>1</literalValue>
        <name>Mark Not Applicable</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Complete_Date</fullName>
        <description>Set Complete Date</description>
        <field>Complete_Date__c</field>
        <formula>Today()</formula>
        <name>Set Complete Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Default_Start_Date</fullName>
        <description>Set Task&apos;s Default Start Date</description>
        <field>Start_Date__c</field>
        <formula>Project_Milestone__r.Kickoff__c</formula>
        <name>Set Default Start Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Task_Default_Stop_Date</fullName>
        <description>Set Default Task Due Date</description>
        <field>Due_Date__c</field>
        <formula>Project_Milestone__r.Deadline__c</formula>
        <name>Set Task Default Due Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Auto-Complete Paid In Full</fullName>
        <active>false</active>
        <description>Fill In Paid In Full Date on Project</description>
        <formula>AND(Complete__c , NOT(ISNULL( Complete_Date__c )), (Workflow_Key__c  = &apos;t_final_30_invoice&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Default Task Start</fullName>
        <actions>
            <name>Set_Default_Start_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Default Start Date for Tasks</description>
        <formula>NOT( ISNULL( Project_Milestone__r.Kickoff__c ))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set Task Default Due Date</fullName>
        <actions>
            <name>Set_Task_Default_Stop_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Default Deadline for Task Completion</description>
        <formula>NOT(ISNULL(Project_Milestone__r.Deadline__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Task Assignment for Master Electrician Review</fullName>
        <actions>
            <name>Assign_to_Master_Electrician</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Task Assignment for Master Electrician Review</description>
        <formula>Workflow_Key__c  = &apos;t_master_electrician_review&apos;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Task Assignment for Notification of Grants</fullName>
        <actions>
            <name>Assign_to_Grants_Coordinator</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Mark_Complete</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Mark_NA</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Complete_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Task Assignment for Notification of Grants</description>
        <formula>and ( OR(ISPICKVAL(Project_Milestone__r.Project__r.Sales_Order__r.Property__r.Property_State__c, &quot;OH&quot;), ISPICKVAL(Project_Milestone__r.Project__r.Sales_Order__r.Property__r.Property_State__c, &quot;MI&quot;), ISPICKVAL(Project_Milestone__r.Project__r.Sales_Order__r.Property__r.Property_State__c, &quot;VA&quot;)), Workflow_Key__c = &quot;t_get_grants_notification&quot;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Task Assignment for Parts Calculator</fullName>
        <actions>
            <name>Assign_to_coordinator_for_Parts_Calc</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Milestone1_Task__c.Workflow_Key__c</field>
            <operation>equals</operation>
            <value>t_create_parts_calculator</value>
        </criteriaItems>
        <description>Task Assignment for Parts Calculator</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Task Assignment for Property Tax Credit Paperwork</fullName>
        <actions>
            <name>Assign_to_Grants_Coordinator</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Mark_Complete</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Mark_NA</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Complete_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Task Assignment for Property Tax Credit Paperwork</description>
        <formula>and (not( OR(ISPICKVAL(Project_Milestone__r.Project__r.Sales_Order__r.Property__r.Property_County__c, &quot;Howard&quot;), ISPICKVAL(Project_Milestone__r.Project__r.Sales_Order__r.Property__r.Property_County__c, &quot;Anne Arundel&quot;), ISPICKVAL(Project_Milestone__r.Project__r.Sales_Order__r.Property__r.Property_County__c, &quot;Baltimore&quot;))), Workflow_Key__c = &quot;t_property_tax_credit&quot;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Task Completion for Copy of Utility Bill</fullName>
        <actions>
            <name>Mark_Complete</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Complete_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Task Completion for Copy of Utility Bill</description>
        <formula>and( Project_Milestone__r.Project__r.Sales_Order__r.Utility_Bill_Attached__c , Workflow_Key__c  == &quot;t_utility_bill&quot;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Task Completion for HOA Documents Approved</fullName>
        <actions>
            <name>Mark_Complete</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Mark_NA</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Complete_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Task Completion for HOA Documents Approved</description>
        <formula>and ( not( includes(Project_Milestone__r.Project__r.Sales_Order__r.Property__r.Authorization_Bodies__c, &quot;HOA&quot;)) , Workflow_Key__c = &quot;t_hoa_approved&quot;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Task Completion for HOA Documents Submitted</fullName>
        <actions>
            <name>Mark_Complete</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Mark_NA</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Complete_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Task Completion for HOA Documents Submitted</description>
        <formula>and ( not( includes(Project_Milestone__r.Project__r.Sales_Order__r.Property__r.Authorization_Bodies__c, &quot;HOA&quot;)) , Workflow_Key__c = &quot;t_hoa_submitted&quot;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Task Completion for Historical Documents Approved</fullName>
        <actions>
            <name>Mark_Complete</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Mark_NA</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Complete_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Task Completion for Historical Documents Approved</description>
        <formula>and ( not(includes(Project_Milestone__r.Project__r.Sales_Order__r.Property__r.Authorization_Bodies__c, &quot;Historical Area&quot;)) , Workflow_Key__c = &quot;t_historical_documents_approve&quot;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Task Completion for Historical Documents Submitted</fullName>
        <actions>
            <name>Mark_Complete</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Mark_NA</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Complete_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Task Completion for Historical Documents Submitted</description>
        <formula>and ( not(includes(Project_Milestone__r.Project__r.Sales_Order__r.Property__r.Authorization_Bodies__c, &quot;Historical Area&quot;)) , Workflow_Key__c = &quot;t_historical_documents_submitt&quot;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Task Completion for ROA Signed</fullName>
        <actions>
            <name>Mark_Complete</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Mark_NA</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Complete_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Task Completion for ROA Signed</description>
        <formula>AND( NOT(ISPICKVAL(Project_Milestone__r.Project__r.Sales_Order__r.Property__r.Property_State__c ,&quot;PA&quot;)), Workflow_Key__c = &quot;t_roa_signed&quot;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Task Completion for SREC Contract signed</fullName>
        <actions>
            <name>Mark_Complete</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Complete_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Task Completion for SREC Contract signed</description>
        <formula>AND(Project_Milestone__r.Project__r.Sales_Order__r.SREC_Contract_Attached__c, Workflow_Key__c  = &apos;t_srec_signed&apos;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
