<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>MERC_Status_Complete_Date</fullName>
        <field>MERC_Meeting_Complete_Canceled_Clsd_Date__c</field>
        <formula>Now()</formula>
        <name>MERC_Status_Complete_Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MERC_Meeting_Complete_Cancelled_Date_Captured</fullName>
        <actions>
            <name>MERC_Status_Complete_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_MERC__c.Meeting_Status_MERC__c</field>
            <operation>equals</operation>
            <value>Complete - Closed,Complete - Cancelled</value>
        </criteriaItems>
        <description>When any meeting will be closed-completed or cancelled, it will capture that closed-complete/cancelled date.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
