<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Communication_chnl_Account</fullName>
        <description>Update Communication Channel field on Account based on preference selection.</description>
        <field>Account_Field_Update_MERC__c</field>
        <formula>&quot;Communication_Channel_MERC__c =&quot; &amp; TEXT( Preference_Sub_Type_MERC__c)</formula>
        <name>Set Communication_chnl_Account</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MERC_Set Communication Channel</fullName>
        <actions>
            <name>Set_Communication_chnl_Account</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Preferences_and_Consent_GLBL__c.Preference_Type_MERC__c</field>
            <operation>equals</operation>
            <value>Communication Channel</value>
        </criteriaItems>
        <description>Set Communication Channel on Account.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
