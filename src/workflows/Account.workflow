<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>MERC_Transparency_reporting_last_modify</fullName>
        <description>To capture last modify date when Transparency Reporting consent has been modified.</description>
        <field>Transparency_Reporting_last_update_MERC__c</field>
        <formula>PRIORVALUE(  Transparency_Reporting_current_time_MERC__c  )</formula>
        <name>MERC_Transparency_reporting_last_modify</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MERC_Transparency_reporting_modify_date</fullName>
        <description>To capture current time stamp when Transparency Reporting consent  has been modified.</description>
        <field>Transparency_Reporting_current_time_MERC__c</field>
        <formula>NOW()</formula>
        <name>MERC_Transparency_reporting_modify_date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MERC_Transparency_reporting_last_modify_date_captured</fullName>
        <actions>
            <name>MERC_Transparency_reporting_last_modify</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>MERC_Transparency_reporting_modify_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>To capture the last date of modification of field Transparency Reporting Consent  on Account object.</description>
        <formula>OR(
     ISNEW(),
     AND(
          NOT(ISNEW()),
          ISCHANGED( Transparency_Reporting_Opt_Out_MERC__c )
     )
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
