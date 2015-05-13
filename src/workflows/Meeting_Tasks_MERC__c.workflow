<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>MERC_Check_for_Changes</fullName>
        <description>Updates the check for changes field to either trigger or not trigger the delegate management field updates at MP level, temporary till next release : MERC : Created on 13/05/2015 by Oliver Dunford, Mavens Consulting</description>
        <field>Check_for_Changes_MERC__c</field>
        <formula>IF(ISNEW(),&quot;TRUE&quot;, 
IF(
( 
ISCHANGED( Process_State_MERC__c ) || 
ISCHANGED( Task_Status_MERC__c ) || 
ISCHANGED( Due_Date_MERC__c ) || 
ISCHANGED( Process_MERC__c ) 
)
,&quot;TRUE&quot;,&quot;FALSE&quot;)
)</formula>
        <name>MERC_Check for Changes</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MERC_Set_Meeting_Task_Unique_Field</fullName>
        <description>Sets the unique process field to prevent errors for process entry : MERC : Created on 27/04/2015 by Oliver Dunford, Mavens Consulting</description>
        <field>Force_Unique_Process_State_MERC__c</field>
        <formula>Meeting_Participant_MERC__c &amp; &quot; - &quot; &amp; TEXT(Process_MERC__c) &amp; &quot; - &quot; &amp; 

 CASE(TEXT(Process_State_MERC__c), 
     &quot;Started&quot;, &quot;Start&quot;, 
     &quot;Unresponsive&quot;, &quot;End&quot;, 
     &quot;Completed&quot;, &quot;End&quot;, 
     &quot;Cancelled&quot;, &quot;End&quot;, 
     Id 
  )</formula>
        <name>MERC_Set Meeting Task Unique Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MERC_Stamp_External_Id_Meeting_Task</fullName>
        <description>Set External Id : MERC : Created on 27/04/2015 by Oliver Dunford, Mavens Consulting</description>
        <field>Mercury_External_Id_MERC__c</field>
        <formula>CASESAFEID($Organization.Id) &amp;&quot;_&quot;&amp; CASESAFEID(Id)</formula>
        <name>MERC_Stamp External Id - Meeting Task</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MERC_Stamp_HCP_Country_Field</fullName>
        <description>Stamps the HCP Country of Residence to trigger sharing : MERC : Created on 22/04/2015 by Oliver Dunford, Mavens Consulting</description>
        <field>HCP_Country_of_Residence_Stamped_MERC__c</field>
        <formula>TEXT(Meeting_Participant_MERC__r.Account_MERC__r.Country_of_Residence_GLBL__c)</formula>
        <name>MERC_Stamp_HCP_Country</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MERC_Check for Changes</fullName>
        <actions>
            <name>MERC_Check_for_Changes</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Stamps a concatenated text field to ensure process builder can check for changes to the record before triggering an update : MERC : Created on 13/05/2015 by Oliver Dunford, Mavens Consulting</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Ensure Unique Process Start%2FEnd</fullName>
        <actions>
            <name>MERC_Set_Meeting_Task_Unique_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Ensures each Process has a unique start and end step : MERC : Created on 27/04/2015 by Oliver Dunford, Mavens Consulting</description>
        <formula>ISNEW() || (ISCHANGED( Process_MERC__c ) || ISCHANGED( Process_State_MERC__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Set External Id - Meeting Tasks</fullName>
        <actions>
            <name>MERC_Stamp_External_Id_Meeting_Task</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_Tasks_MERC__c.Mercury_External_Id_MERC__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Stamps the External Id for Integration / Data Migration : MERC : Created on 27/04/2015 by Oliver Dunford, Mavens Consulting</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Stamp_HCP_Country</fullName>
        <actions>
            <name>MERC_Stamp_HCP_Country_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Stamps the HCP Country of Residence to Control record visibility to Meeting Tasks : MERC : Created on 22/04/2015 by Oliver Dunford, Mavens Consulting</description>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
