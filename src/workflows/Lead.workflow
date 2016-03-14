<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_New_Lead_Info</fullName>
        <description>Email New Lead Info</description>
        <protected>false</protected>
        <recipients>
            <recipient>vadim.polikov@directenergysolar.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/New_Lead_With_Lead_Source_Info_HTML</template>
    </alerts>
    <alerts>
        <fullName>New_Lead_Confirmation_Email</fullName>
        <description>New Lead Confirmation Email</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>info@astrumsolar.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Marketing/New_Web_Form_Lead_Confirmation</template>
    </alerts>
    <fieldUpdates>
        <fullName>Add_Lead_to_Web_Queue</fullName>
        <description>Add Lead To Web To Lead Queue For Sales Coordinators</description>
        <field>OwnerId</field>
        <lookupValue>WebLeadQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Add Lead to Web Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Customer_Update_Huntington</fullName>
        <description>Update Lead: Solarize customer check box to TRUE.</description>
        <field>Solarize_Customer__c</field>
        <literalValue>1</literalValue>
        <name>CP Customer Update - Huntington</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Customer_Update_Somers_New_Castle</fullName>
        <field>Solarize_Customer__c</field>
        <literalValue>1</literalValue>
        <name>CP Customer Update - Somers-New Castle</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_Andover_Lead</fullName>
        <description>Update &quot;Community Program&quot; to &apos;Solarize Andover&apos;</description>
        <field>Community_Program__c</field>
        <literalValue>Solarize Andover</literalValue>
        <name>CP Update -- Andover (Lead)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_Avon_Lead</fullName>
        <description>Update Community Program field to &apos;Solarize Avon&apos;.</description>
        <field>Community_Program__c</field>
        <literalValue>Solarize Avon</literalValue>
        <name>CP Update Avon Lead</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_Belmont_Goes_Solar_Lead</fullName>
        <field>Community_Program__c</field>
        <literalValue>Belmont Goes Solar</literalValue>
        <name>CP Update -- Belmont Goes Solar (Lead)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_Bridgeport_Lead</fullName>
        <description>Update &quot;Community Program&quot; to &apos;Solarize Bridgeport&apos;</description>
        <field>Community_Program__c</field>
        <literalValue>Solarize Bridgeport</literalValue>
        <name>CP Update -- Bridgeport (Lead)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_CPN_College_Park_Lead</fullName>
        <field>Community_Program__c</field>
        <literalValue>CPN College Park</literalValue>
        <name>CP Update CPN College Park Lead</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_CT_Solarize_Online_Lead</fullName>
        <field>Community_Program__c</field>
        <literalValue>CT Solarize Online</literalValue>
        <name>CP Update -- CT Solarize Online (Lead)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_Cheshire_Lead</fullName>
        <field>Community_Program__c</field>
        <literalValue>Solarize Cheshire</literalValue>
        <name>CP Update -- Cheshire(Lead)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_Concord_Lead</fullName>
        <description>Updates &quot;Community Program&quot; to &apos;Concord Solar Challenge&apos;</description>
        <field>Community_Program__c</field>
        <literalValue>Concord Solar Challenge</literalValue>
        <name>CP Update -- Concord (Lead)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_Fairfield_Lead</fullName>
        <description>Update &quot;Community Program&quot; to &apos;Fairfield Energy Challenge&apos;</description>
        <field>Community_Program__c</field>
        <literalValue>Fairfield Energy Challenge</literalValue>
        <name>CP Update -- Fairfield (Lead)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_Frederick_Lead</fullName>
        <description>Update &quot;Community Program&quot; to &apos;Solarize Frederick&apos;</description>
        <field>Community_Program__c</field>
        <literalValue>Solarize Frederick</literalValue>
        <name>CP Update -- Frederick (Lead)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_Glastonbury_Lead</fullName>
        <field>Community_Program__c</field>
        <literalValue>Solarize Glastonbury</literalValue>
        <name>CP Update -- Glastonbury(Lead)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_Gloucester_Lead</fullName>
        <description>Update &quot;Community Program&quot; to &apos;Gloucester Solar Challenge&apos;</description>
        <field>Community_Program__c</field>
        <literalValue>Gloucester Solar Challenge</literalValue>
        <name>CP Update -- Gloucester (Lead)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_Goshen_Warwick_Lead</fullName>
        <description>Update Community Program to &apos;Goshen Warwick&apos;</description>
        <field>Community_Program__c</field>
        <literalValue>Solarize Goshen Warwick</literalValue>
        <name>CP Update -- Goshen Warwick (Lead)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_Huntington</fullName>
        <description>Update &quot;Community Program&quot; to &apos;Solarize Huntington&apos;</description>
        <field>Community_Program__c</field>
        <literalValue>Solarize Huntington</literalValue>
        <name>CP Update -- Huntington</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_Lexington_Bedford_Lead</fullName>
        <description>Update &quot;Community Program&quot; to &apos;Solarize Lexington-Bedford&apos;</description>
        <field>Community_Program__c</field>
        <literalValue>Solarize Lexington-Bedford</literalValue>
        <name>CP Update -- Lexington-Bedford (Lead)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_Mass_Energy_Solar_Connect_Lead</fullName>
        <description>Update Community Program field to &apos;Mass Energy Solar Connect&apos;.</description>
        <field>Community_Program__c</field>
        <literalValue>Mass Energy Solar Connect</literalValue>
        <name>CP Update Mass Energy Solar Connect Lead</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_Needham_Lead</fullName>
        <description>Update &quot;Community Program&quot; to &apos;Solarize Needham&apos;</description>
        <field>Community_Program__c</field>
        <literalValue>Solarize Needham</literalValue>
        <name>CP Update -- Needham (Lead)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_Newtown_Energy_Challenge</fullName>
        <field>Community_Program__c</field>
        <literalValue>Newtown Energy Challenge</literalValue>
        <name>CP Update -- Newtown Energy Challenge</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_Newtown_Lead</fullName>
        <field>Community_Program__c</field>
        <literalValue>Solarize Newtown</literalValue>
        <name>CP Update -- Newtown (Lead)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_No_Program_Lead</fullName>
        <description>Updates &quot;Community Program&quot; to &apos;--None--&apos;</description>
        <field>Community_Program__c</field>
        <name>CP Update -- No Program (Lead)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_Pikesville_Lead</fullName>
        <field>Community_Program__c</field>
        <literalValue>Pikesville Solar Sprint</literalValue>
        <name>CP Update -- Pikesville(Lead)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_RetroFit_Baltimore_Lead</fullName>
        <field>Community_Program__c</field>
        <literalValue>Solarize RetroFit Baltimore</literalValue>
        <name>CP Update - RetroFit Baltimore (Lead)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_SOMA_Lead</fullName>
        <description>Update &quot;Community Program&quot; to &apos;Solarize SOMA&apos;</description>
        <field>Community_Program__c</field>
        <literalValue>Solarize SOMA</literalValue>
        <name>CP Update -- SOMA (Lead)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_Solarize_Aquidneck_Lead</fullName>
        <description>Update Community Program field to &quot;Solarize Aquidneck&quot;.</description>
        <field>Community_Program__c</field>
        <literalValue>Solarize Aquidneck</literalValue>
        <name>CP Update -- Solarize Aquidneck Lead</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_Solarize_Northern_Dutchess</fullName>
        <field>Community_Program__c</field>
        <literalValue>Solarize Northern Dutchess</literalValue>
        <name>CP Update - Solarize Northern Dutchess</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_Solarize_PlainAshBuck_Lead</fullName>
        <field>Community_Program__c</field>
        <literalValue>Solarize Plainfield Ashfield Buckland</literalValue>
        <name>CP Update -- Solarize PlainAshBuck Lead</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_Solarize_Saugerties</fullName>
        <field>Community_Program__c</field>
        <literalValue>Solarize Saugerties</literalValue>
        <name>CP Update - Solarize Saugerties</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_Somers_New_Castle</fullName>
        <field>Community_Program__c</field>
        <literalValue>Solarize Somers-New Castle</literalValue>
        <name>CP Update -- Somers-New Castle</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_Southern_Tier_Solar</fullName>
        <description>Update Community Program field to &apos;Southern Tier Solar&apos;.</description>
        <field>Community_Program__c</field>
        <literalValue>Southern Tier Solar</literalValue>
        <name>CP Update Southern Tier Solar</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_Stamford_Lead</fullName>
        <field>Community_Program__c</field>
        <literalValue>Solarize Stamford</literalValue>
        <name>CP Update -- Stamford(Lead)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_Tompkins_lead</fullName>
        <field>Community_Program__c</field>
        <literalValue>Solar Tompkins</literalValue>
        <name>CP Update - Tompkins (lead)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_Torrington_Lead</fullName>
        <description>Update &quot;Community Program&quot; to &apos;Solarize Torrington&apos;</description>
        <field>Community_Program__c</field>
        <literalValue>Solarize Torrington</literalValue>
        <name>CP Update -- Torrington (Lead)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_Wellesley_Lead</fullName>
        <description>Update &quot;Community Program&quot; to &apos;Wellesley Power to Choose Sun&apos;</description>
        <field>Community_Program__c</field>
        <literalValue>Wellesley Power to Choose Sun</literalValue>
        <name>CP Update -- Wellesley (Lead)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_Westport_Lead</fullName>
        <description>Update &quot;Community Program&quot; to &apos;Solarize Westport&apos;</description>
        <field>Community_Program__c</field>
        <literalValue>Solarize Westport</literalValue>
        <name>CP Update -- Westport (Lead)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CP_Update_Windham_Lead</fullName>
        <description>Update &quot;Community Program&quot; to &apos;Solarize Windham&apos;</description>
        <field>Community_Program__c</field>
        <literalValue>Solarize Windham</literalValue>
        <name>CP Update -- Windham (Lead)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CT_Solarize_Online_Customer_Update</fullName>
        <field>Solarize_Customer__c</field>
        <literalValue>1</literalValue>
        <name>CT Solarize Online Customer Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lead_Do_Not_Call_TRUE</fullName>
        <description>Do NOT solicit through telephone calls.</description>
        <field>DoNotCall</field>
        <literalValue>1</literalValue>
        <name>Lead Do Not Call TRUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lead_Do_Not_Email_TRUE</fullName>
        <description>Do NOT solicit through email.</description>
        <field>HasOptedOutOfEmail</field>
        <literalValue>1</literalValue>
        <name>Lead Do Not Email TRUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lead_Do_Not_Fax_TRUE</fullName>
        <description>Do NOT solicit through faxing.</description>
        <field>HasOptedOutOfFax</field>
        <literalValue>1</literalValue>
        <name>Lead Do Not Fax TRUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lead_Do_Not_Mail_TRUE</fullName>
        <description>Update field Lead: Do Not Mail to TRUE.</description>
        <field>Do_Not_Mail__c</field>
        <literalValue>1</literalValue>
        <name>Lead Do Not Mail TRUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lead_Do_Not_Solicit_TRUE</fullName>
        <description>Update field Lead: Do Not Solicit to TRUE.</description>
        <field>Do_Not_Solicit__c</field>
        <literalValue>1</literalValue>
        <name>Lead Do Not Solicit TRUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lead_Do_Not_Text_TRUE</fullName>
        <description>Update field Lead: Do Not Text to TRUE.</description>
        <field>Do_Not_Text__c</field>
        <literalValue>1</literalValue>
        <name>Lead Do Not Text TRUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lead_Partner_Type_Update</fullName>
        <field>Partner_Type__c</field>
        <literalValue>Internal</literalValue>
        <name>Lead Partner Type Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lead_Status_to_Prospect_Contacted</fullName>
        <description>Update the Lead Status to &quot;Prospect Contacted&quot;</description>
        <field>Status</field>
        <literalValue>Prospect Contacted</literalValue>
        <name>Lead Status to &quot;Prospect Contacted&quot;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lead_Status_to_Prospect_Unresponsive</fullName>
        <description>Update the Lead Status to &quot;Prospect Unresponsive&quot;</description>
        <field>Status</field>
        <literalValue>Prospect Unresponsive</literalValue>
        <name>Lead Status to &quot;Prospect Unresponsive&quot;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mass_Energy_Solar_Connect_Customer_Updat</fullName>
        <field>Solarize_Customer__c</field>
        <literalValue>1</literalValue>
        <name>Mass Energy Solar Connect Customer Updat</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Orig_2nd_Campaign_Copy</fullName>
        <field>Orig_2nd_Source_Campaign__c</field>
        <formula>Secondary_Source_Campaign__r.Name</formula>
        <name>Orig 2nd Campaign Copy</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Orig_2nd_Lead_Source_Copy</fullName>
        <description>Copy 2nd Lead Source</description>
        <field>Orig_2nd_Lead_Source__c</field>
        <formula>TEXT(Second_Lead_Source__c )</formula>
        <name>Orig 2nd Lead Source Copy</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Orig_2nd_Lead_Source_Detail_Copy</fullName>
        <description>Copy 2nd Lead Source Detail</description>
        <field>Orig_2nd_Lead_Source_Detail__c</field>
        <formula>TEXT(Second_Lead_Source_Detail__c )</formula>
        <name>Orig 2nd Lead Source Detail Copy</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Orig_2nd_Referring_Account_Copy</fullName>
        <field>Orig_2nd_Referring_Account__c</field>
        <formula>Secondary_Referring_Account__r.Name</formula>
        <name>Orig 2nd Referring Account Copy</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Orig_Lead_Source_Copy</fullName>
        <description>Copy Lead Source to Orig Lead Source on Lead Creation</description>
        <field>Orig_Lead_Source__c</field>
        <formula>TEXT(LeadSource )</formula>
        <name>Orig Lead Source Copy</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Orig_Lead_Source_Detail_Copy</fullName>
        <description>Copy Lead Source Detail to Orig Lead Source Detail</description>
        <field>Orig_Lead_Source_Detail__c</field>
        <formula>text(Lead_Source_Detail__c )</formula>
        <name>Orig Lead Source Detail Copy</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Orig_Method_Of_Contact_Copy</fullName>
        <description>Copy Method of Contact</description>
        <field>Orig_Method_Of_Contact__c</field>
        <formula>text(Method_of_Contact__c )</formula>
        <name>Orig Method Of Contact Copy</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Orig_Primary_Campaign_Copy</fullName>
        <field>Orig_Primary_Source_Campaign__c</field>
        <formula>Primary_Source_Campaign__r.Name</formula>
        <name>Orig Primary Campaign Copy</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Orig_Referring_Account_Copy</fullName>
        <description>Copy Referring Account</description>
        <field>Orig_Referring_Account__c</field>
        <formula>Referring_Account__r.Name</formula>
        <name>Orig Referring Account Copy</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Prospect_to_Lead_Conversion_Date_update</fullName>
        <field>Prospect_to_Lead_Conversion_Date__c</field>
        <formula>TODAY()</formula>
        <name>Prospect to Lead Conversion Date update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Solarize_Avon_Customer_Update</fullName>
        <field>Solarize_Customer__c</field>
        <literalValue>1</literalValue>
        <name>Solarize Avon Customer Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Solarize_Customer_Update</fullName>
        <field>Solarize_Customer__c</field>
        <literalValue>1</literalValue>
        <name>Solarize Customer Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Solarize_Customer_Update_Not_Solarize</fullName>
        <description>If Lead is updated so that customer is no longer in Solarize community, update &quot;Solarize Customer&quot; checkbox to &apos;False&apos;</description>
        <field>Solarize_Customer__c</field>
        <literalValue>0</literalValue>
        <name>Solarize Customer Update -- Not Solarize</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Solarize_PlainAshBuck_Customer_Update</fullName>
        <field>Solarize_Customer__c</field>
        <literalValue>1</literalValue>
        <name>Solarize PlainAshBuck Customer Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Southern_Tier_Solar_Customer_Update</fullName>
        <description>Update Solarize Customer checkbox to &quot;Southern Tier Solar&quot;.</description>
        <field>Solarize_Customer__c</field>
        <literalValue>1</literalValue>
        <name>Southern Tier Solar Customer Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UTM_Content_Direct_Mail</fullName>
        <description>Updates UTM Content to Lead Source Detail</description>
        <field>UTM_Content__c</field>
        <formula>Text(Lead_Source_Detail__c)</formula>
        <name>UTM Content - Direct Mail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_LeadCreatedDate_field</fullName>
        <description>Copy CreatedDate to LeadCreatedDate</description>
        <field>Lead_Created_Date__c</field>
        <formula>CreatedDate</formula>
        <name>Update LeadCreatedDate field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Lead_Prospect_Lead_to_True</fullName>
        <field>Prospect_Lead__c</field>
        <literalValue>1</literalValue>
        <name>Update Lead: Prospect Lead to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>Call_Now_Referral_Leads</fullName>
        <apiVersion>35.0</apiVersion>
        <description>When a referral lead is created, queue it up to be the next record in the seek list</description>
        <endpointUrl>https://astrumsolar1.insidesales.com/do=noauth/salesforce_add_lead?do=call_now&amp;dialer_initiative_id=333</endpointUrl>
        <fields>Email</fields>
        <fields>FirstName</fields>
        <fields>Id</fields>
        <fields>LastName</fields>
        <fields>Phone</fields>
        <fields>Status</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>stephen.simons@directenergysolar.com</integrationUser>
        <name>Call Now - Referral Leads</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Call_Now_Standard_Residential_Leads</fullName>
        <apiVersion>27.0</apiVersion>
        <description>When a standard residential lead is created, queue it up to be the next record in the seek list</description>
        <endpointUrl>https://astrumsolar1.insidesales.com/do=noauth/salesforce_add_lead?do=call_now&amp;dialer_initiative_id=147</endpointUrl>
        <fields>Email</fields>
        <fields>FirstName</fields>
        <fields>Id</fields>
        <fields>LastName</fields>
        <fields>Phone</fields>
        <fields>Status</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>stephen.simons@directenergysolar.com</integrationUser>
        <name>Call Now - Standard Residential Leads</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>ISC_PowerStandings_Lead_Disqualified</fullName>
        <apiVersion>28.0</apiVersion>
        <endpointUrl>https://powerstandings.insidesales.com/kpi/disqlld</endpointUrl>
        <fields>Id</fields>
        <fields>LastModifiedById</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>stephen.simons@directenergysolar.com</integrationUser>
        <name>ISC - PowerStandings - Lead Disqualified</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>ISC_PowerStandings_Lead_Qualified</fullName>
        <apiVersion>29.0</apiVersion>
        <description>Qualified Opportunity Call</description>
        <endpointUrl>https://powerstandings.insidesales.com/kpi/qualopp</endpointUrl>
        <fields>Id</fields>
        <fields>LastModifiedById</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>stephen.simons@directenergysolar.com</integrationUser>
        <name>ISC - PowerStandings - Lead Qualified</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Pop_3rd_Party_Leads</fullName>
        <apiVersion>26.0</apiVersion>
        <description>Prioritize 3rd Party Leads</description>
        <endpointUrl>https://astrumsolar1.insidesales.com/do=noauth/salesforce_add_lead?do=call_now&amp;dialer_initiative_id=2</endpointUrl>
        <fields>Id</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>stephen.simons@directenergysolar.com</integrationUser>
        <name>Pop 3rd Party Leads</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>ResponsePop_Leads</fullName>
        <apiVersion>30.0</apiVersion>
        <description>Prioritize 3rd Party Leads 2</description>
        <endpointUrl>https://astrumsolar1.insidesales.com/do=noauth/salesforce_add_lead?do=responsepop&amp;inbound_initiative_id=8</endpointUrl>
        <fields>Id</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>stephen.simons@directenergysolar.com</integrationUser>
        <name>ResponsePop Leads</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Bright Current Leads to Hot Transfer</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Lead.Lead_Source_Detail_3__c</field>
            <operation>equals</operation>
            <value>BrightCurrent</value>
        </criteriaItems>
        <description>Move All New BrightCurrent Leads to Hot Transfer Queue</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Call Now - Referral Leads</fullName>
        <actions>
            <name>Call_Now_Referral_Leads</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>This is the &quot;call now&quot; feature from Inside Sales for our referral leads. When a lead is created, it will be the next record called while reps are in the referral seek list.</description>
        <formula>OwnerId = &quot;00GC0000001yWcW&quot;
&amp;&amp;
(TEXT(Status) = &quot;Open – New&quot; || TEXT(Status) = &quot;Open ? New&quot;)
&amp;&amp;
!ISPICKVAL(Site_Type__c, &quot;Commercial&quot;)
&amp;&amp;
(
   ISPICKVAL(LeadSource, &quot;Individual Referral&quot;) || ISPICKVAL(LeadSource, &quot;Partner Referral&quot;)
   ||
   ISPICKVAL(Method_of_Contact__c, &quot;Individual Referral&quot;) || ISPICKVAL(Method_of_Contact__c, &quot;Referral&quot;) 
)
&amp;&amp;
(
   (
      State = &quot;CA&quot;
      &amp;&amp;

      /* Timezone conversion: https://help.salesforce.com/HTViewSolution?id=000181642 */
      IF ( DATEVALUE(NOW()) &gt;= DATE ( YEAR (DATEVALUE(NOW())),3,1) +
      (14 - CASE( MOD(DATE ( YEAR (DATEVALUE(NOW())),3,1) - DATE (1900,1,7),7) ,
      0,7,MOD(DATE ( YEAR (DATEVALUE(NOW())),3,1) - DATE (1900,1,7),7))
      )
      &amp;&amp;
      DATEVALUE(NOW()) &lt; DATE ( YEAR (DATEVALUE(NOW())),11,1) +
      (7 - CASE( MOD(DATE ( YEAR (DATEVALUE(NOW())),11,1) - DATE (1900,1,7),7) ,
      0,7,MOD(DATE ( YEAR (DATEVALUE(NOW())),11,1) - DATE (1900,1,7),7))
      ),
      /* End timezone conversion */

      VALUE( MID ( TEXT (NOW() - 7/24 ), 12, 2)) &gt;= 8,
      VALUE( MID ( TEXT (NOW() - 8/24), 12, 2)) &gt;=8
      )
   )
   ||
   (
      State = &quot;TX&quot;
      &amp;&amp;

      /* Timezone conversion: https://help.salesforce.com/HTViewSolution?id=000181642 */
      IF ( DATEVALUE(NOW()) &gt;= DATE ( YEAR (DATEVALUE(NOW())),3,1) +
      (14 - CASE( MOD(DATE ( YEAR (DATEVALUE(NOW())),3,1) - DATE (1900,1,7),7) ,
      0,7,MOD(DATE ( YEAR (DATEVALUE(NOW())),3,1) - DATE (1900,1,7),7))
      )
      &amp;&amp;
      DATEVALUE(NOW()) &lt; DATE ( YEAR (DATEVALUE(NOW())),11,1) +
      (7 - CASE( MOD(DATE ( YEAR (DATEVALUE(NOW())),11,1) - DATE (1900,1,7),7) ,
      0,7,MOD(DATE ( YEAR (DATEVALUE(NOW())),11,1) - DATE (1900,1,7),7))
      ),
      /* End timezone conversion */

      VALUE( MID ( TEXT (NOW() - 5/24 ), 12, 2)) &gt;= 8 &amp;&amp;
         VALUE( MID ( TEXT (NOW() - 5/24 ), 12, 2)) &lt; 20,
      VALUE( MID ( TEXT (NOW() - 6/24), 12, 2)) &gt;=8 &amp;&amp;
         VALUE( MID ( TEXT (NOW() - 5/24 ), 12, 2)) &lt; 20
      )
   )
   ||
   (
      State != &quot;CA&quot; &amp;&amp; State != &quot;TX&quot;
      &amp;&amp;

      /* Timezone conversion: https://help.salesforce.com/HTViewSolution?id=000181642 */
      IF ( DATEVALUE(NOW()) &gt;= DATE ( YEAR (DATEVALUE(NOW())),3,1) +
      (14 - CASE( MOD(DATE ( YEAR (DATEVALUE(NOW())),3,1) - DATE (1900,1,7),7) ,
      0,7,MOD(DATE ( YEAR (DATEVALUE(NOW())),3,1) - DATE (1900,1,7),7))
      )
      &amp;&amp;
      DATEVALUE(NOW()) &lt; DATE ( YEAR (DATEVALUE(NOW())),11,1) +
      (7 - CASE( MOD(DATE ( YEAR (DATEVALUE(NOW())),11,1) - DATE (1900,1,7),7) ,
      0,7,MOD(DATE ( YEAR (DATEVALUE(NOW())),11,1) - DATE (1900,1,7),7))
      ),
      /* End timezone conversion */

      VALUE( MID ( TEXT (NOW() - 4/24 ), 12, 2)) &lt; 20,
      VALUE( MID ( TEXT (NOW() - 5/24), 12, 2)) &lt; 20
      )
   )
)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Call Now - Standard Residential Leads</fullName>
        <actions>
            <name>Call_Now_Standard_Residential_Leads</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>This is the &quot;call now&quot; feature from Inside Sales for our standard residential leads. When a lead is created, it will be the next record called while reps are in the standard seek list.</description>
        <formula>OwnerId = &quot;00GC0000001yWcW&quot;
&amp;&amp;
(TEXT(Status) = &quot;Open – New&quot; || TEXT(Status) = &quot;Open ? New&quot;)
&amp;&amp;
!ISPICKVAL(Site_Type__c, &quot;Commercial&quot;)
&amp;&amp;
!ISPICKVAL(LeadSource, &quot;Individual Referral&quot;) &amp;&amp; !ISPICKVAL(LeadSource, &quot;Partner Referral&quot;)
&amp;&amp;
!ISPICKVAL(Method_of_Contact__c, &quot;Individual Referral&quot;) &amp;&amp; !ISPICKVAL(Method_of_Contact__c, &quot;Referral&quot;) 
&amp;&amp;
(
   (
      State = &quot;CA&quot;
      &amp;&amp;

      /* Timezone conversion: https://help.salesforce.com/HTViewSolution?id=000181642 */
      IF ( DATEVALUE(NOW()) &gt;= DATE ( YEAR (DATEVALUE(NOW())),3,1) +
      (14 - CASE( MOD(DATE ( YEAR (DATEVALUE(NOW())),3,1) - DATE (1900,1,7),7) ,
      0,7,MOD(DATE ( YEAR (DATEVALUE(NOW())),3,1) - DATE (1900,1,7),7))
      )
      &amp;&amp;
      DATEVALUE(NOW()) &lt; DATE ( YEAR (DATEVALUE(NOW())),11,1) +
      (7 - CASE( MOD(DATE ( YEAR (DATEVALUE(NOW())),11,1) - DATE (1900,1,7),7) ,
      0,7,MOD(DATE ( YEAR (DATEVALUE(NOW())),11,1) - DATE (1900,1,7),7))
      ),
      /* End timezone conversion */

      VALUE( MID ( TEXT (NOW() - 7/24 ), 12, 2)) &gt;= 8,
      VALUE( MID ( TEXT (NOW() - 8/24), 12, 2)) &gt;=8
      )
   )
   ||
   (
      State = &quot;TX&quot;
      &amp;&amp;

      /* Timezone conversion: https://help.salesforce.com/HTViewSolution?id=000181642 */
      IF ( DATEVALUE(NOW()) &gt;= DATE ( YEAR (DATEVALUE(NOW())),3,1) +
      (14 - CASE( MOD(DATE ( YEAR (DATEVALUE(NOW())),3,1) - DATE (1900,1,7),7) ,
      0,7,MOD(DATE ( YEAR (DATEVALUE(NOW())),3,1) - DATE (1900,1,7),7))
      )
      &amp;&amp;
      DATEVALUE(NOW()) &lt; DATE ( YEAR (DATEVALUE(NOW())),11,1) +
      (7 - CASE( MOD(DATE ( YEAR (DATEVALUE(NOW())),11,1) - DATE (1900,1,7),7) ,
      0,7,MOD(DATE ( YEAR (DATEVALUE(NOW())),11,1) - DATE (1900,1,7),7))
      ),
      /* End timezone conversion */

      VALUE( MID ( TEXT (NOW() - 5/24 ), 12, 2)) &gt;= 8 &amp;&amp;
         VALUE( MID ( TEXT (NOW() - 5/24 ), 12, 2)) &lt; 20,
      VALUE( MID ( TEXT (NOW() - 6/24), 12, 2)) &gt;=8 &amp;&amp;
         VALUE( MID ( TEXT (NOW() - 5/24 ), 12, 2)) &lt; 20
      )
   )
   ||
   (
      State != &quot;CA&quot; &amp;&amp; State != &quot;TX&quot;
      &amp;&amp;

      /* Timezone conversion: https://help.salesforce.com/HTViewSolution?id=000181642 */
      IF ( DATEVALUE(NOW()) &gt;= DATE ( YEAR (DATEVALUE(NOW())),3,1) +
      (14 - CASE( MOD(DATE ( YEAR (DATEVALUE(NOW())),3,1) - DATE (1900,1,7),7) ,
      0,7,MOD(DATE ( YEAR (DATEVALUE(NOW())),3,1) - DATE (1900,1,7),7))
      )
      &amp;&amp;
      DATEVALUE(NOW()) &lt; DATE ( YEAR (DATEVALUE(NOW())),11,1) +
      (7 - CASE( MOD(DATE ( YEAR (DATEVALUE(NOW())),11,1) - DATE (1900,1,7),7) ,
      0,7,MOD(DATE ( YEAR (DATEVALUE(NOW())),11,1) - DATE (1900,1,7),7))
      ),
      /* End timezone conversion */

      VALUE( MID ( TEXT (NOW() - 4/24 ), 12, 2)) &lt; 20,
      VALUE( MID ( TEXT (NOW() - 5/24), 12, 2)) &lt; 20
      )
   )
)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- Andover</fullName>
        <actions>
            <name>CP_Update_Andover_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Solarize_Customer_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>If Lead is located in Andover, MA, update Community Program to &apos;Andover&apos;</description>
        <formula>AND(City = &quot;Andover&quot;, State = &quot;MA&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- Belmont Goes Solar</fullName>
        <actions>
            <name>CP_Update_Belmont_Goes_Solar_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Solarize_Customer_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Lead is located in Belmont, MA, update Community Program to &apos;Belmont Goes Solar&quot;</description>
        <formula>AND(City = &quot;Belmont&quot;, State = &quot;MA&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- Bridgeport</fullName>
        <actions>
            <name>CP_Update_Bridgeport_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Solarize_Customer_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>If Lead is located in Bridgeport ZIP Code, update Community Program to &apos;Solarize Bridgeport&apos;</description>
        <formula>OR(LEFT(PostalCode,5) = &quot;06601&quot;, LEFT(PostalCode,5) = &quot;06602&quot;, LEFT(PostalCode,5) = &quot;06604&quot;, LEFT(PostalCode,5) = &quot;06605&quot;, LEFT(PostalCode,5) = &quot;06606&quot;, LEFT(PostalCode,5) = &quot;06607&quot;, LEFT(PostalCode,5) = &quot;06608&quot;, LEFT(PostalCode,5) = &quot;06610&quot;, LEFT(PostalCode,5) = &quot;06650&quot;, LEFT(PostalCode,5) = &quot;06673&quot;, LEFT(PostalCode,5) = &quot;06699&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- CPN College Park</fullName>
        <actions>
            <name>CP_Update_CPN_College_Park_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>If Lead is located in College Park, MD, update Community Program to &apos;CPN College Park&apos;</description>
        <formula>AND(City = &quot;College Park&quot;, State = &quot;MD&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- CT Solarize Online</fullName>
        <actions>
            <name>CP_Update_CT_Solarize_Online_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CT_Solarize_Online_Customer_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Lead is located in South Windsor, CT or Lyme, CT or Old Lyme, CT or Woodstock, CT, update Community Program to &apos;CT Solarize Online&apos;</description>
        <formula>OR(AND(City = &quot;South Windsor&quot;, State = &quot;CT&quot;),AND(City = &quot;Lyme&quot;, State = &quot;CT&quot;),AND(City = &quot;Old Lyme&quot;, State = &quot;CT&quot;),AND(City = &quot;Woodstock&quot;, State = &quot;CT&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- Cheshire</fullName>
        <actions>
            <name>CP_Update_Cheshire_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>If Lead is located in Cheshire ZIP Code, update Community Program to &apos;Solarize Cheshire&apos;</description>
        <formula>OR(LEFT(PostalCode,5) = &quot;06408&quot;, LEFT(PostalCode,5) = &quot;06410&quot;, LEFT(PostalCode,5) = &quot;06411&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- Concord</fullName>
        <actions>
            <name>CP_Update_Concord_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>If Lead is located in Concord ZIP Code, update Community Program to &apos;Concord Solar Challenge&apos;</description>
        <formula>LEFT(PostalCode,5) = &apos;01742&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- Fairfield</fullName>
        <actions>
            <name>CP_Update_Fairfield_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Solarize_Customer_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>If Lead is located in Fairfield, CT, update Community Program to &apos;Fairfield Energy Challange&apos;</description>
        <formula>AND(City = &quot;Fairfield&quot;, State = &quot;CT&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- Frederick</fullName>
        <actions>
            <name>CP_Update_Frederick_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>If a Lead is located in a Frederick County ZIP Code, update Community Program to &apos;Solarize Frederick&apos;</description>
        <formula>or(LEFT(PostalCode,5) = &quot;21701&quot;,  LEFT(PostalCode,5) = &quot;21702&quot;,  LEFT(PostalCode,5) = &quot;21703&quot;,  LEFT(PostalCode,5) = &quot;21704&quot;,  LEFT(PostalCode,5) = &quot;21705&quot;,  LEFT(PostalCode,5) = &quot;21709&quot;,  LEFT(PostalCode,5) = &quot;21710&quot;,  LEFT(PostalCode,5) = &quot;21714&quot;,  LEFT(PostalCode,5) = &quot;21716&quot;,  LEFT(PostalCode,5) = &quot;21717&quot;,  LEFT(PostalCode,5) = &quot;21718&quot;,  LEFT(PostalCode,5) = &quot;21727&quot;,  LEFT(PostalCode,5) = &quot;21754&quot;,  LEFT(PostalCode,5) = &quot;21755&quot;, LEFT(PostalCode,5) = &quot;21758&quot;,  LEFT(PostalCode,5) = &quot;21759&quot;,  LEFT(PostalCode,5) = &quot;21762&quot;,  LEFT(PostalCode,5) = &quot;21769&quot;,  LEFT(PostalCode,5) = &quot;21770&quot;,  LEFT(PostalCode,5) = &quot;21771&quot;,  LEFT(PostalCode,5) = &quot;21773&quot;,  LEFT(PostalCode,5) = &quot;21774&quot;,  LEFT(PostalCode,5) = &quot;21775&quot;,  LEFT(PostalCode,5) = &quot;21777&quot;,  LEFT(PostalCode,5) = &quot;21778&quot;,  LEFT(PostalCode,5) = &quot;21780&quot;,  LEFT(PostalCode,5) = &quot;21788&quot;,  LEFT(PostalCode,5) = &quot;21790&quot;,  LEFT(PostalCode,5) = &quot;21792&quot;,  LEFT(PostalCode,5) = &quot;21793&quot;,  LEFT(PostalCode,5) = &quot;21798&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- Glastonbury</fullName>
        <actions>
            <name>CP_Update_Glastonbury_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>If Lead is located in Glastonbury ZIP Code, update Community Program to &apos;Solarize Bridgeport&apos;</description>
        <formula>OR(LEFT(PostalCode,5) = &quot;06025&quot;, LEFT(PostalCode,5) = &quot;06033&quot;, LEFT(PostalCode,5) = &quot;06073&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- Gloucester</fullName>
        <actions>
            <name>CP_Update_Gloucester_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Solarize_Customer_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Lead is located in Gloucester, MA, update Community Program to &apos;Gloucester Solar Challenge&apos;</description>
        <formula>AND(City = &quot;Gloucester&quot;, State = &quot;MA&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- Goshen Warwick</fullName>
        <actions>
            <name>CP_Update_Goshen_Warwick_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Solarize_Customer_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Lead is located in the following zip codes, update Community Program to &apos;Goshen Warwick&apos;</description>
        <formula>BEGINS( PostalCode ,&quot;10910&quot;) ||
BEGINS( PostalCode ,&quot;10912&quot;) ||
BEGINS( PostalCode ,&quot;10914&quot;) ||
BEGINS( PostalCode ,&quot;10915&quot;) ||
BEGINS( PostalCode ,&quot;10916&quot;) ||
BEGINS( PostalCode ,&quot;10917&quot;) ||
BEGINS( PostalCode ,&quot;10918&quot;) ||
BEGINS( PostalCode ,&quot;10919&quot;) ||
BEGINS( PostalCode ,&quot;10921&quot;) ||
BEGINS( PostalCode ,&quot;10922&quot;) ||
BEGINS( PostalCode ,&quot;10924&quot;) ||
BEGINS( PostalCode ,&quot;10925&quot;) ||
BEGINS( PostalCode ,&quot;10926&quot;) ||
BEGINS( PostalCode ,&quot;10928&quot;) ||
BEGINS( PostalCode ,&quot;10930&quot;) ||
BEGINS( PostalCode ,&quot;10932&quot;) ||
BEGINS( PostalCode ,&quot;10933&quot;) ||
BEGINS( PostalCode ,&quot;10940&quot;) ||
BEGINS( PostalCode ,&quot;10941&quot;) ||
BEGINS( PostalCode ,&quot;10949&quot;) ||
BEGINS( PostalCode ,&quot;10950&quot;) ||
BEGINS( PostalCode ,&quot;10953&quot;) ||
BEGINS( PostalCode ,&quot;10959&quot;) ||
BEGINS( PostalCode ,&quot;10963&quot;) ||
BEGINS( PostalCode ,&quot;10969&quot;) ||
BEGINS( PostalCode ,&quot;10973&quot;) ||
BEGINS( PostalCode ,&quot;10975&quot;) ||
BEGINS( PostalCode ,&quot;10979&quot;) ||
BEGINS( PostalCode ,&quot;10981&quot;) ||
BEGINS( PostalCode ,&quot;10985&quot;) ||
BEGINS( PostalCode ,&quot;10987&quot;) ||
BEGINS( PostalCode ,&quot;10988&quot;) ||
BEGINS( PostalCode ,&quot;10990&quot;) ||
BEGINS( PostalCode ,&quot;10992&quot;) ||
BEGINS( PostalCode ,&quot;10996&quot;) ||
BEGINS( PostalCode ,&quot;10997&quot;) ||
BEGINS( PostalCode ,&quot;10998&quot;) ||
BEGINS( PostalCode ,&quot;12518&quot;) ||
BEGINS( PostalCode ,&quot;12520&quot;) ||
BEGINS( PostalCode ,&quot;12543&quot;) ||
BEGINS( PostalCode ,&quot;12549&quot;) ||
BEGINS( PostalCode ,&quot;12553&quot;) ||
BEGINS( PostalCode ,&quot;12566&quot;) ||
BEGINS( PostalCode ,&quot;12575&quot;) ||
BEGINS( PostalCode ,&quot;12577&quot;) ||
BEGINS( PostalCode ,&quot;12584&quot;) ||
BEGINS( PostalCode ,&quot;12586&quot;) ||
BEGINS( PostalCode ,&quot;12729&quot;) ||
BEGINS( PostalCode ,&quot;12746&quot;) ||
BEGINS( PostalCode ,&quot;12771&quot;) ||
BEGINS( PostalCode ,&quot;12780&quot;) ||
BEGINS( PostalCode ,&quot;10958&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- Huntington</fullName>
        <actions>
            <name>CP_Customer_Update_Huntington</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CP_Update_Huntington</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Lead is located in Huntington, NY ZIP Code set, update Community Program to &apos;Solarize Huntington&apos;</description>
        <formula>OR(LEFT(PostalCode,5) = &quot;11721&quot;, LEFT(PostalCode,5) = &quot;11724&quot;, LEFT(PostalCode,5) = &quot;11731&quot;, LEFT(PostalCode,5) = &quot;11740&quot;, LEFT(PostalCode,5) = &quot;11743&quot;, LEFT(PostalCode,5) = &quot;11746&quot;, LEFT(PostalCode,5) = &quot;11747&quot;, LEFT(PostalCode,5) = &quot;11750&quot;, LEFT(PostalCode,5) = &quot;11768&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- Lexington-Bedford</fullName>
        <actions>
            <name>CP_Update_Lexington_Bedford_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Solarize_Customer_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>If Lead is located in Lexington, MA or Bedford, MA, update Community Program to &apos;Solarize Lexington-Bedford&apos;</description>
        <formula>OR(AND(City = &quot;Lexington&quot;, State = &quot;MA&quot;),AND(City = &quot;Bedford&quot;, State = &quot;MA&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- Mass Energy Solar Connect</fullName>
        <actions>
            <name>CP_Update_Mass_Energy_Solar_Connect_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Mass_Energy_Solar_Connect_Customer_Updat</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Lead Source Detail = &apos;Mass Energy Solar Connect&apos; and Lead is located in MA, update Community Program to &apos;Mass Energy Solar Connect&apos;</description>
        <formula>AND( ISPICKVAL(Lead_Source_Detail__c, &quot;Mass Energy Solar Connect&quot;), State = &quot;MA&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- Needham</fullName>
        <actions>
            <name>CP_Update_Needham_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Solarize_Customer_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>If Lead is located in Needham or Needham Heights, MA, update Community Program to &apos;Solarize Needham&apos;</description>
        <formula>AND(OR(City = &quot;Needham&quot;, City = &quot;Needham Heights&quot;), State = &quot;MA&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- Newtown</fullName>
        <actions>
            <name>CP_Update_Newtown_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Solarize_Customer_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>If Lead is located in Newtown ZIP Code, update Community Program to &apos;Solarize Newtown&apos;</description>
        <formula>or(LEFT(PostalCode,5) = &quot;06470&quot;, LEFT(PostalCode,5) = &quot;06482&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- Newtown Energy Challenge</fullName>
        <actions>
            <name>CP_Update_Newtown_Energy_Challenge</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Solarize_Customer_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>If Lead is located in ZIP Code set 06740, 06482, update Community Program to &apos;Newtown Energy Challenge&apos;</description>
        <formula>OR(LEFT(PostalCode,5) = &quot;06740&quot;, 
   LEFT(PostalCode,5) = &quot;06482&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- None</fullName>
        <actions>
            <name>CP_Update_No_Program_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Solarize_Customer_Update_Not_Solarize</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Removes Community Program name if address is updated to ZIP Code outside eligibility</description>
        <formula>AND(LEFT(PostalCode,5) &lt;&gt; &quot;06601&quot;, LEFT(PostalCode,5) &lt;&gt; &quot;06602&quot;, LEFT(PostalCode,5) &lt;&gt; &quot;06604&quot;, LEFT(PostalCode,5) &lt;&gt; &quot;06605&quot;, LEFT(PostalCode,5) &lt;&gt; &quot;06606&quot;, LEFT(PostalCode,5) &lt;&gt; &quot;06607&quot;, LEFT(PostalCode,5) &lt;&gt; &quot;06608&quot;, LEFT(PostalCode,5) &lt;&gt; &quot;06610&quot;, LEFT(PostalCode,5) &lt;&gt; &quot;06650&quot;, LEFT(PostalCode,5) &lt;&gt; &quot;06673&quot;, LEFT(PostalCode,5) &lt;&gt; &quot;06699&quot;, LEFT(PostalCode,5) &lt;&gt; &apos;01742&apos;, LEFT(PostalCode,5) &lt;&gt; &quot;06482&quot;, LEFT(PostalCode,5) &lt;&gt; &quot;06408&quot;, LEFT(PostalCode,5) &lt;&gt; &quot;06410&quot;, LEFT(PostalCode,5) &lt;&gt; &quot;06411&quot;, LEFT(PostalCode,5) &lt;&gt; &quot;06025&quot;, LEFT(PostalCode,5) &lt;&gt; &quot;06033&quot;, LEFT(PostalCode,5) &lt;&gt; &quot;06073&quot;, LEFT(PostalCode,5) &lt;&gt; &quot;06901&quot;, LEFT(PostalCode,5) &lt;&gt; &quot;06902&quot;, LEFT(PostalCode,5) &lt;&gt; &quot;06903&quot;, LEFT(PostalCode,5) &lt;&gt; &quot;06905&quot;, LEFT(PostalCode,5) &lt;&gt; &quot;06906&quot;, LEFT(PostalCode,5) &lt;&gt; &quot;06907&quot;, OR(City &lt;&gt; &quot;Wellesley&quot;, State &lt;&gt; &quot;MA&quot;), OR(City &lt;&gt; &quot;Wellesley Hills&quot;, State &lt;&gt; &quot;MA&quot;), OR(City &lt;&gt; &quot;Needham&quot;, State &lt;&gt; &quot;MA&quot;), OR(City &lt;&gt; &quot;Lexington&quot;, State &lt;&gt; &quot;MA&quot;), OR(City &lt;&gt; &quot;Bedford&quot;, State &lt;&gt; &quot;MA&quot;), OR(City &lt;&gt; &quot;Andover&quot;, State &lt;&gt; &quot;MA&quot;), OR(City &lt;&gt; &quot;Plainfield&quot;, State &lt;&gt; &quot;MA&quot;), OR(City &lt;&gt; &quot;Ashfield&quot;, State &lt;&gt; &quot;MA&quot;), OR(City &lt;&gt; &quot;Buckland&quot;, State &lt;&gt; &quot;MA&quot;), OR(City &lt;&gt; &quot;Shelburne Falls&quot;, State &lt;&gt; &quot;MA&quot;), OR(City &lt;&gt; &quot;South Orange&quot;, State &lt;&gt; &quot;NJ&quot;), OR(City &lt;&gt; &quot;Maplewood&quot;, State &lt;&gt; &quot;NJ&quot;), OR(City &lt;&gt; &quot;Torrington&quot;, State &lt;&gt; &quot;CT&quot;), OR(City &lt;&gt; &quot;Westport&quot;, State &lt;&gt; &quot;CT&quot;), OR(City &lt;&gt; &quot;Windham&quot;, State &lt;&gt; &quot;CT&quot;), OR(City &lt;&gt; &quot;College Park&quot;, State &lt;&gt; &quot;MD&quot;), OR(City &lt;&gt; &quot;Fairfield&quot;, State &lt;&gt; &quot;CT&quot;), OR(City &lt;&gt; &quot;Needham Heights&quot;, State &lt;&gt; &quot;MA&quot;), OR(NOT(ISPICKVAL(County__c,&quot;Tompkins (NY)&quot; ))), OR(AND(QAS_County__c &lt;&gt; &quot;Tompkins&quot;), State &lt;&gt; &quot;NY&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- Pikesville</fullName>
        <actions>
            <name>CP_Update_Pikesville_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>If Lead is located in Pikesville ZIP Code, update Community Program to &apos;Pikesville Solar Sprint&apos;</description>
        <formula>LEFT(PostalCode,5) = &quot;21209&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- RetroFit Baltimore</fullName>
        <actions>
            <name>CP_Update_RetroFit_Baltimore_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Solarize_Customer_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the Community Program Field when a lead is in the MD counties of Baltimore City, Baltimore, Anne Arundel and Howard</description>
        <formula>AND( State = &quot;MD&quot;,
  OR(QAS_County__c  = &quot;Baltimore City&quot;, 
     QAS_County__c  = &quot;Baltimore&quot;, 
     QAS_County__c  = &quot;Anne Arundel&quot;, 
     QAS_County__c  = &quot;Howard&quot;)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- SOMA</fullName>
        <actions>
            <name>CP_Update_SOMA_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>If Lead is located in South Orange or Maplewood, NJ, update Community Program to &apos;SOMA&apos;</description>
        <formula>AND(OR(City = &quot;South Orange&quot;,City= &quot;Maplewood&quot;), State = &quot;NJ&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- Solarize Aquidneck</fullName>
        <actions>
            <name>CP_Update_Solarize_Aquidneck_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Solarize_Customer_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Lead is located in Portsmouth, RI or Middletown , RI or Newport, RI, update Community Program to &apos;Solarize Aquidneck&apos;</description>
        <formula>AND( 
OR(AND(City = &quot;Portsmouth&quot;, State = &quot;RI&quot;), 
AND(City = &quot;Middletown&quot;, State = &quot;RI&quot;), 
AND(City = &quot;Newport&quot;, State = &quot;RI&quot;) 
), 
Lead_Date__c &gt; DATE(2015,10,26) 
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- Solarize Avon</fullName>
        <actions>
            <name>CP_Update_Avon_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Solarize_Avon_Customer_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Lead is located in Avon, CT, update Community Program to &apos;Solarize Avon&apos;</description>
        <formula>AND(City = &quot;Avon&quot;, State = &quot;CT&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- Solarize Northern Dutchess</fullName>
        <actions>
            <name>CP_Update_Solarize_Northern_Dutchess</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Solarize_Customer_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the Community Program Field when a lead is in the NY county of Dutchess.</description>
        <formula>AND( State = &quot;NY&quot;, QAS_County__c  = &quot;Dutchess&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- Solarize Plainfield Ashfield Buckland</fullName>
        <actions>
            <name>CP_Update_Solarize_PlainAshBuck_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Solarize_PlainAshBuck_Customer_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Lead is located in Plainfield, MA or Ashfield , MA or Buckland, MA, update Community Program to &apos;Solarize Plainfield Ashfield Buckland&apos;</description>
        <formula>AND( 
OR(AND(City = &quot;Plainfield&quot;, State = &quot;MA&quot;), 
AND(City = &quot;Shelburne Falls&quot;, State = &quot;MA&quot;), 
AND(City = &quot;Ashfield&quot;, State = &quot;MA&quot;), 
AND(City = &quot;Buckland&quot;, State = &quot;MA&quot;) 
), 
Lead_Date__c &gt; DATE(2015,3,31) 
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- Solarize Saugerties</fullName>
        <actions>
            <name>CP_Update_Solarize_Saugerties</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Solarize_Customer_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the Community Program Field when a lead is in the NY county of Ulster.</description>
        <formula>AND( State = &quot;NY&quot;, QAS_County__c  = &quot;Ulster&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- Solarize Somers-New Castle</fullName>
        <actions>
            <name>CP_Customer_Update_Somers_New_Castle</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CP_Update_Somers_New_Castle</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Lead is located in ZIP Code set 10546, 10589, 10514, update Community Program to &apos;Solarize Somers-New Castle&apos;</description>
        <formula>OR(LEFT(PostalCode,5) = &quot;10546&quot;, 
   LEFT(PostalCode,5) = &quot;10589&quot;, 
   LEFT(PostalCode,5) = &quot;10514&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- Southern Tier Solar</fullName>
        <actions>
            <name>CP_Update_Southern_Tier_Solar</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Southern_Tier_Solar_Customer_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Lead is located in NY state AND counties of Broome, Chenango, Delaware, Otsego or Tioga, update Community Program to &apos;Southern Tier Solar&apos;.</description>
        <formula>OR( 
AND(State = &quot;NY&quot;, QAS_County__c = &quot;Broome&quot;), 
AND(State = &quot;NY&quot;, QAS_County__c = &quot;Broome (NY)&quot;), 
AND(State = &quot;NY&quot;, QAS_County__c = &quot;Chenango&quot;), 
AND(State = &quot;NY&quot;, QAS_County__c = &quot;Chenango (NY)&quot;), 
AND(State = &quot;NY&quot;, QAS_County__c = &quot;Delaware&quot;), 
AND(State = &quot;NY&quot;, QAS_County__c = &quot;Delaware (NY)&quot;), 
AND(State = &quot;NY&quot;, QAS_County__c = &quot;Otsego&quot;), 
AND(State = &quot;NY&quot;, QAS_County__c = &quot;Otsego (NY)&quot;), 
AND(State = &quot;NY&quot;, QAS_County__c = &quot;Tioga&quot;), 
AND(State = &quot;NY&quot;, QAS_County__c = &quot;Tioga (NY)&quot;) 
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- Stamford</fullName>
        <actions>
            <name>CP_Update_Stamford_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>If Lead is located in Stamford ZIP Code, update Community Program to &apos;Solarize Stamford&apos;</description>
        <formula>OR(LEFT(PostalCode,5) = &quot;06901&quot;, LEFT(PostalCode,5) = &quot;06902&quot;, LEFT(PostalCode,5) = &quot;06903&quot;, LEFT(PostalCode,5) = &quot;06905&quot;, LEFT(PostalCode,5) = &quot;06906&quot;, LEFT(PostalCode,5) = &quot;06907&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- Tompkins</fullName>
        <actions>
            <name>CP_Update_Tompkins_lead</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Solarize_Customer_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Update the Community Program Field when a lead is in Tompkins County, NY</description>
        <formula>OR(ISPICKVAL(County__c,&quot;Tompkins (NY)&quot;),AND(QAS_County__c  = &quot;Tompkins&quot;, State = &quot;NY&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- Torrington</fullName>
        <actions>
            <name>CP_Update_Torrington_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>If Lead is located in Torrington, CT, update Community Program to &apos;Torrington&apos;</description>
        <formula>AND(City = &quot;Torrington&quot;, State = &quot;CT&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- Wellesley</fullName>
        <actions>
            <name>CP_Update_Wellesley_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Solarize_Customer_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>If Lead is located in Wellesley or Wellesley Hills, MA, update Community Program to &apos;Wellesley Power to Choose Sun&apos;</description>
        <formula>AND(OR(City = &quot;Wellesley&quot;,City = &quot;Wellesley Hills&quot;), State = &quot;MA&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- Westport</fullName>
        <actions>
            <name>CP_Update_Westport_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Solarize_Customer_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>If Lead is located in Westport, CT, update Community Program to &apos;Westport&apos;</description>
        <formula>AND(City= &quot;Westport&quot;, State = &quot;CT&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Community Program Update -- Windham</fullName>
        <actions>
            <name>CP_Update_Windham_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>If Lead is located in Windham, CT, update Community Program to &apos;Windham&apos;</description>
        <formula>AND(City = &quot;Windham&quot;, State = &quot;CT&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Copy CreatedDate to LeadCreatedDate</fullName>
        <actions>
            <name>Update_LeadCreatedDate_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Copies to the created date to &quot;lead created date&quot;</description>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Email Vadim New Leads</fullName>
        <actions>
            <name>Email_New_Lead_Info</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Email Vadim Notification of Every New Lead</description>
        <formula>OR( ISNEW(),ISCHANGED(LeadSource),ISCHANGED( Lead_Source_Detail__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ISC - PowerStandings - Lead Disqualified</fullName>
        <actions>
            <name>ISC_PowerStandings_Lead_Disqualified</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Marketing – Influencer,Did Not Want Contact,Unresponsive,Bad Contact Information,Lost – Competition,Unqualified</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISC - PowerStandings - Lead Qualified</fullName>
        <actions>
            <name>ISC_PowerStandings_Lead_Qualified</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Qualified</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Inside Sales Pop 3rd Party Leads</fullName>
        <actions>
            <name>Call_Now_Standard_Residential_Leads</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.LeadSource</field>
            <operation>equals</operation>
            <value>3rd Party Lead Gen</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Inside Sales Pop All Web Lead Queue Leads</fullName>
        <actions>
            <name>Call_Now_Standard_Residential_Leads</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.OwnerId</field>
            <operation>equals</operation>
            <value>Web Lead Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.qbdialer__Dials__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Pop New Leads to Inside Sales.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Inside Sales ResponsePop All Web Lead Queue Leads</fullName>
        <actions>
            <name>ResponsePop_Leads</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.OwnerId</field>
            <operation>equals</operation>
            <value>Web Lead Queue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>startsWith</operation>
            <value>Open</value>
        </criteriaItems>
        <description>ResponsePop New Leads to Inside Sales.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead Global Opt Out Solicitation</fullName>
        <actions>
            <name>Lead_Do_Not_Call_TRUE</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Lead_Do_Not_Email_TRUE</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Lead_Do_Not_Fax_TRUE</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Lead_Do_Not_Mail_TRUE</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Lead_Do_Not_Solicit_TRUE</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Lead_Do_Not_Text_TRUE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Global_Opt_Out__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>When global opt out=True (checked) all opt out fields should be selected.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead Original User Inputs</fullName>
        <actions>
            <name>Orig_2nd_Campaign_Copy</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Orig_2nd_Lead_Source_Copy</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Orig_2nd_Lead_Source_Detail_Copy</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Orig_2nd_Referring_Account_Copy</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Orig_Lead_Source_Copy</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Orig_Lead_Source_Detail_Copy</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Orig_Method_Of_Contact_Copy</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Orig_Primary_Campaign_Copy</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Orig_Referring_Account_Copy</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Company</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Workflow Rule to Populate Original User Input Fields on Lead Creation</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Lead Partner Type Assignment</fullName>
        <actions>
            <name>Lead_Partner_Type_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Assign Partner Type = Internal under the appropriate criteria.</description>
        <formula>AND( ISPICKVAL( LeadSource, &quot;Partner Referral&quot;), 
OR( 
ISPICKVAL( Lead_Source_Detail__c, 
&quot;Benjamin Franklin (DES)&quot;), 
ISPICKVAL( Lead_Source_Detail__c, 
&quot;Mr. Sparky (DES)&quot;), 
ISPICKVAL( Lead_Source_Detail__c, 
&quot;OneHour Air Conditioning &amp; Heating (DES)&quot;), 
ISPICKVAL( Lead_Source_Detail__c, 
&quot;DE MyAccount&quot;), 
ISPICKVAL( Lead_Source_Detail__c, 
&quot;Airtron (DES)&quot;), 
ISPICKVAL( Lead_Source_Detail__c, 
&quot;Home Warranty of America (DES)&quot;), 
ISPICKVAL( Lead_Source_Detail__c, 
&quot;Other (DES)&quot;) 
))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Marketo Leads To Inside Sales Queue</fullName>
        <actions>
            <name>Add_Lead_to_Web_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.OwnerId</field>
            <operation>equals</operation>
            <value>Marketo Marketo</value>
        </criteriaItems>
        <description>Push All Marketo Leads to Inside Sales (Web Lead Queue)</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Prospect Contacted with 3 Dials</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Prospect Contacted</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.qbdialer__Dials__c</field>
            <operation>equals</operation>
            <value>3</value>
        </criteriaItems>
        <description>When a Lead has a status of &quot;Prospect Contacted&quot; and 3 Dials, update the status field</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Lead_Status_to_Prospect_Unresponsive</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Prospect Lead True if Prospect Status</fullName>
        <actions>
            <name>Update_Lead_Prospect_Lead_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>contains</operation>
            <value>Prospect New,Prospect Contacted,Prospect Unresponsive,Prospect duplicate,Prospect Unqualified</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Prospect New with 1 Dial</fullName>
        <actions>
            <name>Lead_Status_to_Prospect_Contacted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Prospect New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.qbdialer__Dials__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <description>When a Lead has a status of &quot;Prospect New&quot; and 1 Dial, update the status field</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Prospect to Lead Conversion Date</fullName>
        <actions>
            <name>Prospect_to_Lead_Conversion_Date_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Date a Prospect Lead is converted to an active Lead.</description>
        <formula>AND( Prospect_Lead__c  = TRUE,   NOT(OR (ISPICKVAL(Status, &quot;Prospect New&quot;),          ISPICKVAL(Status, &quot;Prospect Contacted&quot;),          ISPICKVAL(Status, &quot;Prospect Unresponsive&quot;),          ISPICKVAL(Status, &quot;Prospect Duplicate&quot;),          ISPICKVAL(Status, &quot;Prospect Unqualified&quot;) )))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send New Web Form Lead Auto-Response Email</fullName>
        <actions>
            <name>New_Lead_Confirmation_Email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.Method_of_Contact__c</field>
            <operation>equals</operation>
            <value>Astrum Web Form</value>
        </criteriaItems>
        <description>Send Confirmation Email to New Lead That Came from an Astrum Web Form</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Solarize Customer</fullName>
        <actions>
            <name>Solarize_Customer_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.Community_Program__c</field>
            <operation>equals</operation>
            <value>Solarize Bridgeport</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UTM Content - Direct Mail</fullName>
        <actions>
            <name>UTM_Content_Direct_Mail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.LeadSource</field>
            <operation>equals</operation>
            <value>Direct Mail</value>
        </criteriaItems>
        <description>Populates the field UTM Content with Lead Source Detail if Lead Source = &apos;Direct Mail&apos;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Web To Lead To Queue</fullName>
        <actions>
            <name>Add_Lead_to_Web_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Lead.OwnerId</field>
            <operation>equals</operation>
            <value>Josh Goldberg</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Method_of_Contact__c</field>
            <operation>equals</operation>
            <value>Astrum Input,Phone,Email,In-Person,Other,Calculator,Referral</value>
        </criteriaItems>
        <description>Push All Referral Leads to Sales Coordinator Queue</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
