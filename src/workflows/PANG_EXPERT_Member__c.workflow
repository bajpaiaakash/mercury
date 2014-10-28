<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>PANG_St_EXPERT_Nm_Vlu_to_Usr_Rcord_Nm</fullName>
        <field>Name</field>
        <formula>Salesforce_User__r.FirstName  &amp; &quot; &quot; &amp;  Salesforce_User__r.LastName</formula>
        <name>PANG St EXPERT Nm Vlu to Usr Rcord Nm</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>PANG_31_EXPERT_Record_Save</fullName>
        <actions>
            <name>PANG_St_EXPERT_Nm_Vlu_to_Usr_Rcord_Nm</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>PANG_EXPERT_Member__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>When creating EXPERT Member records in the RWE EXPERT Members object, this workflow updates the Record Name to match that of the User selected.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
