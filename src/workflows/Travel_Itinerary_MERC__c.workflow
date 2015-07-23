<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>MERC_Meeting_Process_Trigger_FALSE</fullName>
        <description>Sets the Evaluate Meeting Process Logic to False : MERC : Created on 29/06/2015 by Oliver Dunford</description>
        <field>Evaluate_Meeting_Process_Logic_MERC_c__c</field>
        <literalValue>0</literalValue>
        <name>MERC_Meeting_Process_Trigger_FALSE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MERC_Meeting_Process_Trigger_TRUE</fullName>
        <description>Sets the Evaluate Meeting Process Logic to True : MERC : Created on 29/06/2015 by Oliver Dunford</description>
        <field>Evaluate_Meeting_Process_Logic_MERC_c__c</field>
        <literalValue>1</literalValue>
        <name>MERC_Meeting_Process_Trigger_TRUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>MERC_Meeting Process Logic Trigger - FALSE</fullName>
        <actions>
            <name>MERC_Meeting_Process_Trigger_FALSE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets the Evaluate Meeting Process logic back to False to prevent Tasks from triggering again : MERC : Created on 29/06/2015 by Oliver Dunford, Mavens Consulting</description>
        <formula>Evaluate_Meeting_Process_Logic_MERC_c__c = TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Meeting Process Logic Trigger - TRUE</fullName>
        <actions>
            <name>MERC_Meeting_Process_Trigger_TRUE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets the Evaluate Meeting Process logic to true to kick off Meeting Task generation / updates : MERC : Created on 29/06/2015 by Oliver Dunford, Mavens Consulting</description>
        <formula>ISNEW() 

|| 

( RecordType.DeveloperName = &quot;MERC_Travel_Proposal&quot; &amp;&amp;  TEXT(Meeting_Participant_MERC__r.Meeting_MERC__r.Initiate_Delegate_Management_MERC__c) = &quot;YES&quot; &amp;&amp; ISCHANGED( Status_MERC__c ))

|| 

(Meeting_Participant_MERC__r.Has_Travel_Process_MERC__c &amp;&amp; ISCHANGED( Status_MERC__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
