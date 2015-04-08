<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>MERC_Maximum_Fee_last_modify</fullName>
        <description>To capture last modify date when Maximum Fee has been modified.</description>
        <field>Maximum_Fee_last_updated_MERC__c</field>
        <formula>PRIORVALUE( Maximum_Fee_current_time_updated_MERC__c )</formula>
        <name>MERC_Maximum_Fee_last_modify</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MERC_Maximum_Fee_modify_date</fullName>
        <description>To capture current time stamp when maximum fee has been modified.</description>
        <field>Maximum_Fee_current_time_updated_MERC__c</field>
        <formula>NOW()</formula>
        <name>MERC_Maximum_Fee_modify_date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MERC_Maximum_Fee_last_modify_date_captured</fullName>
        <actions>
            <name>MERC_Maximum_Fee_last_modify</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>MERC_Maximum_Fee_modify_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>To capture the last date of modification of field Maximum Fee on Meeting Participant object.</description>
        <formula>OR(
     ISNEW(),
     AND(
          NOT(ISNEW()),
          ISCHANGED( Maximum_Fee_MERC__c )
     )
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
