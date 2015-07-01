<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>MERC_Stamp_HCP_Country_Field</fullName>
        <description>Stamps the HCP Country of Residence to trigger sharing : MERC : Created on 30/06/2015 by Oliver Dunford, Mavens Consulting</description>
        <field>HCP_Country_of_Residence_Stamped_MERC__c</field>
        <formula>TEXT( Meeting_Participant_MERC__r.Account_MERC__r.Country_of_Residence_GLBL__c  )</formula>
        <name>MERC_Stamp_HCP_Country</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MERC_Unique_Meeting_Participant_Process</fullName>
        <description>Stamps the MP Id &amp; the Process : MERC : Created on 30/06/2015 by Oliver Dunford, Mavens Consulting</description>
        <field>Unique_MP_Process_MERC__c</field>
        <formula>Meeting_Participant_MERC__c &amp; &quot; - &quot; &amp;  TEXT(Process_Type_MERC__c)</formula>
        <name>MERC_Unique Meeting Participant Process</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>MERC_Stamp_HCP_Country</fullName>
        <actions>
            <name>MERC_Stamp_HCP_Country_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Stamps the HCP Country of Residence to Control record visibility to Meeting Process : MERC : Created on 30/06/2015 by Oliver Dunford, Mavens Consulting</description>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Unique Meeting Participant Process</fullName>
        <actions>
            <name>MERC_Unique_Meeting_Participant_Process</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Ensure a single process type for each Meeting Participant : MERC : Created on 30/06/2015 by Oliver Dunford, Mavens Consulting</description>
        <formula>ISNEW() || ISCHANGED( Process_Type_MERC__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
