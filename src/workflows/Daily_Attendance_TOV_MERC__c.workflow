<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Clear_Confirm_ToV_Change_MERC</fullName>
        <description>Clears the confirm ToV change checkbox after each record update</description>
        <field>Confirm_ToV_Reporting_Change_MERC__c</field>
        <literalValue>0</literalValue>
        <name>Clear Confirm ToV Change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_TOV_External_Id</fullName>
        <description>Sets TOV External Id to Meeting Participant + Meeting Day to enforce uniqueness.</description>
        <field>External_ID_MERC__c</field>
        <formula>CASESAFEID(Meeting_Participant_MERC__c) &amp; &apos;_&apos; &amp; CASESAFEID(Meeting_Day_MERC__c)</formula>
        <name>Set TOV External Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Clear Confirm ToV Change_MERC</fullName>
        <actions>
            <name>Clear_Confirm_ToV_Change_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Clear the Confirm ToV Change checkbox after each record update. Created 01/07/2014 by KLorenti</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set TOV External Id_MERC</fullName>
        <actions>
            <name>Set_TOV_External_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_Day_MERC__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Enforces uniqueness on TOV per participant per day</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
