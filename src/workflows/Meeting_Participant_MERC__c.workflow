<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>MERC_Set_registration_status_field</fullName>
        <description>Sets the field registration status to Pending Review when the status of Meeting Participant is set to Accepted. : MERC : Created on 03/03/2016 by Edith Sereno, Mavens Consulting</description>
        <field>Registration_Status_MERC__c</field>
        <literalValue>Pending Review</literalValue>
        <name>MERC Set registration status field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MERC_Update Registration Status</fullName>
        <actions>
            <name>MERC_Set_registration_status_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets the Registration Status to Pending Review when the Meeting Participant status is set to Accepted : MERC : Created on 03/03/2016 by Edith Sereno, Mavens Consulting</description>
        <formula>AND(
ISPICKVAL(Status_MERC__c , &quot;Accepted&quot;),
ISBLANK(TEXT(Registration_Status_MERC__c)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
