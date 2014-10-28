<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>External_ID_ParticipantAgenda_MERC</fullName>
        <description>Populates External ID with OrdID and ID</description>
        <field>Mercury_External_Id_MERC__c</field>
        <formula>CASESAFEID($Organization.Id) &amp;&quot;_&quot;&amp; CASESAFEID(Id)</formula>
        <name>External ID-ParticipantAgenda</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MERC_Update_Confirm_Web_Service_Change</fullName>
        <description>Sets the Confirm Web Service Change field to false once a set of changes has been confirmed by CMS Cork, fututre changes should also trigger the validation rule : MERC : Created on 22/07/2014 by Oliver Dunford, Mavens Consulting</description>
        <field>Confirm_Web_Service_Change_MERC__c</field>
        <literalValue>0</literalValue>
        <name>MERC_Update_Confirm_Web_Service_Change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MERC_External ID-ParticipantAgenda</fullName>
        <actions>
            <name>External_ID_ParticipantAgenda_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Participant_Agenda_MERC__c.Mercury_External_Id_MERC__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Populates the external id upon creation of a record</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Update_Confirm_Web_Service_Change</fullName>
        <actions>
            <name>MERC_Update_Confirm_Web_Service_Change</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Participant_Agenda_MERC__c.Confirm_Web_Service_Change_MERC__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Sets the Confirm Web Service Change field to false once a set of changes has been confirmed by CMS Cork, fututre changes should also trigger the validation rule : MERC : Created on 22/07/2014 by Oliver Dunford, Mavens Consulting</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
