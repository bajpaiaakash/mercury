<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>MERC_Meeting_Process_Trigger_FALSE</fullName>
        <description>Sets the Evaluate Meeting Process Logic to FALSE : MERC : Created on 29/06/2015 by Oliver Dunford, Mavens Consulting</description>
        <field>Evaluate_Meeting_Process_Logic_MERC__c</field>
        <literalValue>0</literalValue>
        <name>MERC_Meeting_Process_Trigger_FALSE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MERC_Meeting_Process_Trigger_TRUE</fullName>
        <description>Sets the Evaluate Meeting Process Logic to TRUE : MERC : Created on 29/06/2015 by Oliver Dunford, Mavens Consulting</description>
        <field>Evaluate_Meeting_Process_Logic_MERC__c</field>
        <literalValue>1</literalValue>
        <name>MERC_Meeting_Process_Trigger_TRUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>MERC_Meeting Process Logic Trigger - FALSE</fullName>
        <actions>
            <name>MERC_Meeting_Process_Trigger_FALSE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates Evaluate Meeting Process Logic and sets to False after its been True and fired already : MERC : Created on 29/06/2015 by Oliver Dunford</description>
        <formula>Evaluate_Meeting_Process_Logic_MERC__c = TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Meeting Process Logic Trigger - TRUE</fullName>
        <actions>
            <name>MERC_Meeting_Process_Trigger_TRUE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates Evaluate Meeting Process Logic and sets to True should the trigger needed : MERC : Created on 29/06/2015 by Oliver Dunford</description>
        <formula>ISNEW() || ( TEXT(Meeting_MERC__r.Initiate_Delegate_Management_MERC__c) = &quot;Yes&quot; &amp;&amp; ISCHANGED( Status_MERC__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
