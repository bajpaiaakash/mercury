<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>MERC_Update_Unique_Process_Field</fullName>
        <description>Updates the unique field to trigger a validation error for duplicate processes : MERC : Created on 16/07/2015 by Oliver Dunford, Mavens Consulting</description>
        <field>Force_Unique_Process_Logic_Record_MERC__c</field>
        <formula>IF( RecordType.DeveloperName = &quot;MERC_Meeting_Participant&quot;,  Meeting_Participant_Key_MERC__c , 
IF( RecordType.DeveloperName = &quot;MERC_Meeting_Process&quot;,   Meeting_Process_Key_MERC__c ,
IF( RecordType.DeveloperName = &quot;MERC_Meeting_Task&quot;,   Meeting_Task_Key_MERC__c ,
IF( RecordType.DeveloperName = &quot;MERC_Travel_Proposal&quot;,   Travel_Proposal_Key_MERC__c , Id ))))</formula>
        <name>MERC_Update_Unique_Process_Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>MERC_Unique_Meeting_Process_Logic</fullName>
        <actions>
            <name>MERC_Update_Unique_Process_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Forces a unique meeting process logic record : MERC : Created on 16/07/2015 by Oliver Dunford, Mavens Consulting</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
