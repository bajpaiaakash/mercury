<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Key_Uniqueness_MERC</fullName>
        <description>Updates the Unique Key field. Oliver Dunford 12th May 2014.</description>
        <field>Key_for_Uniqueness_Check_MERC__c</field>
        <formula>Key_for_Lookup_MERC__c</formula>
        <name>Update Key Uniqueness_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MERC_Update Key Uniqueness</fullName>
        <actions>
            <name>Update_Key_Uniqueness_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Unique Key on the Portal Logic object to ensure each record uploaded is unique  : MERC : Created on 05/01/2014 by Katy Lorenti, Mavens Consulting</description>
        <formula>ISNEW() || (  ISCHANGED( Key_for_Lookup_MERC__c ) || ISCHANGED( Account_Record_Type_MERC__c ) || ISCHANGED( Air_Required_MERC__c ) || ISCHANGED( Country_MERC__c ) || ISCHANGED( Hotel_Required_MERC__c) || ISCHANGED( Participant_Record_Type_MERC__c) || ISCHANGED( Transparency_Consent_Exists_MERC__c )  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
