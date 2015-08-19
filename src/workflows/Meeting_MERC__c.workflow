<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>MERC_Update_Local_CMS_Review</fullName>
        <description>Set the Local CMS Review Completed field to Yes.  Completed 11AUG15 by BHo.</description>
        <field>Local_CMS_Review_Completed_MERC__c</field>
        <literalValue>Yes</literalValue>
        <name>MERC_Update_Local_CMS_Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MERC Meeting Active Date</fullName>
        <actions>
            <name>MERC_Meeting_Active_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>MERC_Update_Local_CMS_Review</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_MERC__c.Meeting_Status_MERC__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <description>Date on which Meeting Status is updated to ACTIVE.  Captured for SLA Reporting : MERC : Created on 23/2/15 by Mike Cashman, Mavens Consulting
Update &quot;Local CMS Review Completed&quot; field on the Meeting object to True.  MERC : Updated on 12/8/15 by Billy Ho</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
