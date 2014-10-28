<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>MICO_Approval_Pending</fullName>
        <description>The approval status will be set to Awaiting Approval on submission</description>
        <field>Approval_Status__c</field>
        <literalValue>Pending Approval</literalValue>
        <name>Pending Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MICO_Approval_Rejection_Update</fullName>
        <description>The approval status will be set to Rejected based on the rejection action taken by approver</description>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Approval Rejection Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MICO_Approved</fullName>
        <description>The Approval status will be updated to Approved once the record is approved by SME</description>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MICO_Update_Approval_Date</fullName>
        <description>This step will blank out the Approval date when an approved design record is updated</description>
        <field>MICO_Approval_Date__c</field>
        <name>MICO Update Approval Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MICO_Update_Status</fullName>
        <description>This Step will update the Approval Status field when an approved Design record is updated</description>
        <field>Approval_Status__c</field>
        <literalValue>Open</literalValue>
        <name>MICO Update Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MICO_Update_date_time</fullName>
        <description>This will set the approved date on Design</description>
        <field>MICO_Approval_Date__c</field>
        <formula>NOW()</formula>
        <name>Update date/time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Unlock_Design_Flag</fullName>
        <description>This step will unset the Unlock Design Flag</description>
        <field>Unlock_Design__c</field>
        <literalValue>0</literalValue>
        <name>Reset Unlock Design Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Status</fullName>
        <description>This will update the Approval Status from &quot;Pending Approval&quot; to &quot;Open&quot;</description>
        <field>Approval_Status__c</field>
        <literalValue>Open</literalValue>
        <name>Update Approval Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MICO Reopen Design for Approval</fullName>
        <active>false</active>
        <description>This workflow will reopen i.e. change the approval status from Approved to Open when an approved design is edited.</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MICO Update Approved Design</fullName>
        <actions>
            <name>MICO_Update_Approval_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>MICO_Update_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow will change the Approval Status on Design from Approved to Open when a Design is edited by a user</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
