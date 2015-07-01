<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>MERC_Meeting_Process_Trigger_FALSE</fullName>
        <description>Sets the Evaluate Meeting Process Logic to False</description>
        <field>Evaluate_Meeting_Process_Logic_MERC__c</field>
        <literalValue>0</literalValue>
        <name>MERC_Meeting_Process_Trigger_FALSE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MERC_Meeting_Process_Trigger_TRUE</fullName>
        <description>Updates the Evaluate Meeting Process field to TRUE : MERC : Created on 29/06/2015 by Oliver Dunford, Mavens Consulting</description>
        <field>Evaluate_Meeting_Process_Logic_MERC__c</field>
        <literalValue>1</literalValue>
        <name>MERC_Meeting Process Trigger - TRUE</name>
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
        <criteriaItems>
            <field>Meeting_MERC__c.Evaluate_Meeting_Process_Logic_MERC__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Sets the Meeting Process Logic Evaluation back to False post execution : MERC : Created on 29/06/2015 by Oliver Dunford, Mavens Consulting</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Meeting Process Logic Trigger - TRUE</fullName>
        <actions>
            <name>MERC_Meeting_Process_Trigger_TRUE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set when the Meeting Process Logic should be evaluated based upon Meeting changes : MERC : Created on 29/06/2015 by Oliver Dunford, Mavens Consulting</description>
        <formula>ISCHANGED(Initiate_Delegate_Management_MERC__c) &amp;&amp;  TEXT(Initiate_Delegate_Management_MERC__c) = &quot;Yes&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
