<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>PANG_Set_Record_Type_as_RWE_Data_Asset</fullName>
        <field>RecordTypeId</field>
        <lookupValue>RWE_Data_Asset</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>PANG_Set_Record_Type_as_RWE_Data_Asset</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>PANG_33_Data Asset Save</fullName>
        <actions>
            <name>PANG_Set_Record_Type_as_RWE_Data_Asset</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>PANG_Data_Asset__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Updates the Record Type of all Data Asset records created to &quot;Data Asset&quot; regardless if created using the Long Form or the Short Form.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
