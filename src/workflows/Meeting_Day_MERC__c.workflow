<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>External_ID_MeetingDay_MERC</fullName>
        <description>Populates External ID with OrdID and ID</description>
        <field>Mercury_External_Id_MERC__c</field>
        <formula>CASESAFEID($Organization.Id) &amp;&quot;_&quot;&amp; CASESAFEID(Id)</formula>
        <name>External ID-MeetingDay</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Participant_ToV_Update_Dt_MDay_MERC</fullName>
        <description>Set Participant ToV Update Date when ToV Values are changed on Meeting Day as part of ToV correction process</description>
        <field>Participant_ToV_Updated_Date_MERC__c</field>
        <formula>Now()</formula>
        <name>Set Participant ToV Update Date_MERC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Meeting_MERC__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Confirm_ToV_Change_MERC</fullName>
        <description>Update &quot;Confirm ToV Change&quot; checkbox to FALSE after each record update. Created 01/08/2014 by KLorenti, Mavens Consulting</description>
        <field>Confirm_ToV_Reporting_Change_MERC__c</field>
        <literalValue>0</literalValue>
        <name>Update Confirm ToV Change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Unique_Meeting_Day_MERC</fullName>
        <description>Updates the Force Unique Meeting Day 
Created by John A Adams 1/8/2014</description>
        <field>Force_Unique_Meeting_Day_MERC__c</field>
        <formula>Meeting_MERC__c &amp; &quot;-&quot; &amp; TEXT(Date_MERC__c)</formula>
        <name>Update Unique Meeting Day</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MERC_Clear Confirm ToV Change</fullName>
        <actions>
            <name>Update_Confirm_ToV_Change_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Clears out the &quot;Confirm ToV Change&quot; checkbox after each record update : MERC : Created on 12/5/2013 by Katy Lorenti, Mavens Consulting</description>
        <formula>Confirm_ToV_Reporting_Change_MERC__c = TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_External ID-MeetingDay</fullName>
        <actions>
            <name>External_ID_MeetingDay_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_Day_MERC__c.Mercury_External_Id_MERC__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Populates the external id upon creation of a record : MERC : Created on 12/5/2013 by Oliver Dunford, Mavens Consulting</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Update Participant ToV Update Date</fullName>
        <actions>
            <name>Set_Participant_ToV_Update_Dt_MDay_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Meeting_Day_MERC__c.Confirm_ToV_Reporting_Change_MERC__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Update Participant ToV Final Update Date when ToV information is changed on Meeting Day  : MERC : Created on 01/10/2014 by Katy Lorenti, Mavens Consulting</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MERC_Update Unique Meeting Day</fullName>
        <actions>
            <name>Update_Unique_Meeting_Day_MERC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Unique Meeting Day text field to enforce uniqueness for a Meeting Day  : MERC : Created on 01/10/2014 by Katy Lorenti, Mavens Consulting</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
