<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Include_in_CAP_Rollup_MERC</fullName>
        <description>When Type of Service is not equal to &quot;Medical Research Consultant&quot;, set the &quot;Include_in_Cap_Rollup&quot; checkbox to True.</description>
        <field>Include_CAP_Roll_Up_MERC__c</field>
        <literalValue>1</literalValue>
        <name>Set Include in CAP Rollup_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MERC_Meeting_Potential_ToV_Update</fullName>
        <description>Sets the Meeting Level Participant ToV to &quot;Yes&quot; should a single MP meet the criteria : MERC : Created on 03/11/2015 by Oliver Dunford, Mavens Consulting</description>
        <field>Potential_ToV_MERC__c</field>
        <literalValue>Yes</literalValue>
        <name>MERC_Meeting_Potential_ToV_Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Meeting_MERC__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MERC_Participant_Potential_ToV</fullName>
        <description>Sets Meeting Participant Potential ToV to &quot;Yes&quot; should the criteria be made : MERC : Created on 03/11/2015 by Oliver Dunford, Mavens Consulting</description>
        <field>Potential_ToV_MERC__c</field>
        <literalValue>Yes</literalValue>
        <name>MERC_Participant_Potential_ToV</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MERC_Uncheck_Override_Status_Validation</fullName>
        <description>Updates the Override MP Validation field post update of MP Status via custom code : MERC : Created on 10/11/2015 by Oliver Dunford, Mavens Consulting</description>
        <field>Override_MP_Status_Validation_MERC__c</field>
        <literalValue>0</literalValue>
        <name>MERC_Uncheck_Override_Status_Validation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>MERC_Meeting_Potential_ToV_Update</fullName>
        <actions>
            <name>MERC_Meeting_Potential_ToV_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Meeting Potential ToV Flag should any Meeting Participant meet the rules : MERC : Created on 03/11/2015 by Oliver Dunford</description>
        <formula>((ISNEW() &amp;&amp; TEXT(Potential_ToV_MERC__c) = &quot;Yes&quot;) || (ISCHANGED(Potential_ToV_MERC__c) &amp;&amp; TEXT(Potential_ToV_MERC__c) = &quot;Yes&quot;)) &amp;&amp;  TEXT(Meeting_MERC__r.Potential_ToV_MERC__c) &lt;&gt; &quot;Yes&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Participant_Potential_ToV</fullName>
        <actions>
            <name>MERC_Participant_Potential_ToV</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Checks the criteria specifically on the Meeting Participant record to flag the Potential ToV should it be needed.  Hotel/Air Needed, Individual Sponsorship : MERC : Created on 03/11/2015 by Oliver Dunford</description>
        <formula>(ISNEW() &amp;&amp; ((TEXT(Hotel_Required_MERC__c) = &quot;YES&quot;) ||  (TEXT(Air_Travel_Required_MERC__c) = &quot;YES&quot;) ||  (RecordType.DeveloperName = &quot;Individual_Sponsorship&quot;))) || (
(ISCHANGED(Hotel_Required_MERC__c) &amp;&amp; (TEXT(Hotel_Required_MERC__c) = &quot;YES&quot;) ||  (ISCHANGED(Air_Travel_Required_MERC__c) &amp;&amp; TEXT(Air_Travel_Required_MERC__c) = &quot;YES&quot;) || (ISCHANGED(RecordTypeId) &amp;&amp; RecordType.DeveloperName = &quot;Individual_Sponsorship&quot;))
) &amp;&amp;  TEXT(Potential_ToV_MERC__c) &lt;&gt; &quot;Yes&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Uncheck_Override_Status_Validation</fullName>
        <actions>
            <name>MERC_Uncheck_Override_Status_Validation</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Unchecks the Override MP Status update validation field once the code has processed to update it automatically from a Daily Attendance &amp; ToV change  : MERC : Created on 03/11/2015 by Oliver Dunford</description>
        <formula>ISCHANGED(Override_MP_Status_Validation_MERC__c) &amp;&amp;  Override_MP_Status_Validation_MERC__c = TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Set_Include_Cap_Rollup</fullName>
        <actions>
            <name>Set_Include_in_CAP_Rollup_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_Participant_MERC__c.Types_of_Service_MERC__c</field>
            <operation>notEqual</operation>
            <value>Medical Research Consultant</value>
        </criteriaItems>
        <description>If the Type of Service is not equals to Medical Research, Set &quot;Include In Cap Rollup&quot; checkbox to &quot;true&quot; : MERC : Created on 11/04/2015 by Namrata Aggarwal</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
