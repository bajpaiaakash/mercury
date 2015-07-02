<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>MERC_Stamp_HCP_Country_Field</fullName>
        <description>Stamps the HCP Country of Residence to trigger sharing : MERC : Created on 22/04/2015 by Oliver Dunford, Mavens Consulting</description>
        <field>HCP_Country_of_Residence_Stamped_MERC__c</field>
        <formula>TEXT(Meeting_Process_MERC__r.Meeting_Participant_MERC__r.Account_MERC__r.Country_of_Residence_GLBL__c)</formula>
        <name>MERC_Stamp_HCP_Country</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MERC_Stamp_HCP_Country</fullName>
        <actions>
            <name>MERC_Stamp_HCP_Country_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Stamps the HCP Country of Residence to Control record visibility to Meeting Tasks : MERC : Created on 22/04/2015 by Oliver Dunford, Mavens Consulting</description>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
