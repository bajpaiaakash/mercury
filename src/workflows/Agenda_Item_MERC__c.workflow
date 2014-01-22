<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>External_ID_Agenda_Item_MERC</fullName>
        <description>Populates External ID with OrdID and ID</description>
        <field>Mercury_External_Id_MERC__c</field>
        <formula>CASESAFEID($Organization.Id) &amp;&quot;_&quot;&amp; CASESAFEID(Id)</formula>
        <name>External ID-Agenda Item</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Confirm_Change_Final_Agenda</fullName>
        <description>Updates the &quot;Confirm Change to Final Agenda&quot; checkbox to False. 
Created by John A Adams 12/19/2013</description>
        <field>Cnfrm_Chg_Fnl_Agnd_MERC__c</field>
        <literalValue>0</literalValue>
        <name>Update Confirm Change Final Agenda</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Clear_Confirm_Change_to_Final_Agenda_MERC</fullName>
        <actions>
            <name>Update_Confirm_Change_Final_Agenda</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Triggers the clearing of the checkbox set by user when they wish to change a finalized agenda item.  Created by John A Adams 12/19/2013</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Mercury External ID-Agenda Item_MERC</fullName>
        <actions>
            <name>External_ID_Agenda_Item_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Agenda_Item_MERC__c.Mercury_External_Id_MERC__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Populates the external id upon creation of a record</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
