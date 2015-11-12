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
