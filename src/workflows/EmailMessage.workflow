<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>MERC_Update_Case_Status</fullName>
        <description>Updates the case to Open should an email be received post closure of the case : MERC : Created on 05/02/2015 by Oliver Dunford</description>
        <field>Status</field>
        <literalValue>Open</literalValue>
        <name>MERC_Update_Case_Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>MERC_Close_Case_Inbound_Emails</fullName>
        <actions>
            <name>MERC_Update_Case_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Re-opens a case should an email be received post case closure : MERC : Created on 05/02/2015 by Oliver Dunford, Mavens Consulting</description>
        <formula>TEXT(Parent.Status) = &quot;Closed&quot; &amp;&amp; Incoming = TRUE &amp;&amp; NOT(CONTAINS( Subject , &quot;Out of Office&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
