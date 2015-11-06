<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>MERC_Meeting_Day_Potential_ToV</fullName>
        <description>Flags the Meeting Potential ToV field with a &quot;Yes&quot; should a Meeting have associated Meeting Days : MERC : Created on 03/11/2015 by Oliver Dunford, Mavens Consulting</description>
        <field>Potential_ToV_MERC__c</field>
        <literalValue>Yes</literalValue>
        <name>MERC_Meeting_Day_Potential_ToV</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Meeting_MERC__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>MERC_Meeting_Day_Potential_ToV</fullName>
        <actions>
            <name>MERC_Meeting_Day_Potential_ToV</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Highlights the meeting has having potential ToV due to the inclusion of a meeting day : MERC : created on 03/11/2015 by Oliver Dunford, Mavens Consulting</description>
        <formula>TEXT(Meeting_MERC__r.Potential_ToV_MERC__c) &lt;&gt; &quot;Yes&quot;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
