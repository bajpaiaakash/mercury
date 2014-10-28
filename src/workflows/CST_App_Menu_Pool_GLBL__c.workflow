<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Check_Lookup_CUST</fullName>
        <description>Sets a uniwue text field based on the status of a lookup</description>
        <field>App_Settings_Unique_Check_CUST__c</field>
        <formula>App_Settings_CUST__c</formula>
        <name>Check Lookup</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CUST_CST Check Lookup</fullName>
        <actions>
            <name>Check_Lookup_CUST</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates a unique text field based on lookup value : CUST : Created on 12/5/2013 by Sam Rosen, Mavens Consulting</description>
        <formula>NOT(ISNULL(App_Settings_CUST__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
